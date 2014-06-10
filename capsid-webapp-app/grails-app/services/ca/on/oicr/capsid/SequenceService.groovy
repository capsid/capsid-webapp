package ca.on.oicr.capsid

import java.util.regex.Matcher
import org.apache.commons.logging.LogFactory

class SequenceService {

	private static final log = LogFactory.getLog(this)

	public static final String CIGAR_INSERT = "CIGAR_INSERT"
	public static final String CIGAR_DELETE = "CIGAR_DELETE"
	public static final String CIGAR_MATCH = "CIGAR_MATCH"
	public static final String CIGAR_SOFT_CLIPPING = "CIGAR_SOFT"
	public static final String CIGAR_HARD_CLIPPING = "CIGAR_HARD"

	public static final String MD_COPY = "MD_COPY"
	public static final String MD_INSERT = "MD_INSERT"
	public static final String MD_REPLACE = "MD_REPLACE"

	ArrayList cigarActions(String cigar) {
    	ArrayList cigarActions = [] as ArrayList

		Matcher matcher = cigar =~ /(\d+)([MIDNSHP=X])/
    	matcher.each {
    		Integer count = it[1] as Integer
    		String identifier = it[2]
    		if (identifier == 'D' || identifier == 'N' || identifier == 'P') {
                cigarActions << [CIGAR_DELETE, count] 
            } else if (identifier == 'I') {
    			cigarActions << [CIGAR_INSERT, count] 
    		} else if (identifier == 'M' || identifier == '=' || identifier == 'X') {
    			cigarActions << [CIGAR_MATCH, count] 
    		} else if (identifier == 'H') {
    			cigarActions << [CIGAR_HARD_CLIPPING, count] 
			} else if (identifier == 'S') {
    			cigarActions << [CIGAR_SOFT_CLIPPING, count] 
			}
    	}

    	return cigarActions
	}

	ArrayList mdActions(String MD) {
    	ArrayList mdActions = [] as ArrayList

    	Matcher matcher = MD =~ /\^[A-Z]+|[A-Z]+|\d+/
    	matcher.each {
    		String token = it
    		if (token.isNumber()) {
    			mdActions << [MD_COPY, it as Integer]
    		} else if (token.startsWith("^")) {
    			mdActions << [MD_INSERT, token.substring(1)]
    		} else {
    			mdActions << [MD_REPLACE, token]
    		}
    	}

    	return mdActions
	}

	/**
	 * Calculates a reference string and a set of displayable markers that will show how
	 * a sequence matches that reference. This is calculated from the MD string and the
	 * cigar string. The result is a Map with three keys: sequence, reference, and markup,
	 * which can then be converted into buckets. Note that the sequence is returned as we
	 * may well embed marks in for reference data.
	 * 
	 * @param inputSequence a sequence string
	 * @param MD an MD string
	 * @param cigar a CIGAR string
	 * @return a map with sequence, reference, and markup keys
	 */
    Map<String, String> calculateAlignment(String inputSequence, String MD, String cigar) {

    	ArrayList cigarActions = cigarActions(cigar)
    	ArrayList mdActions = mdActions(MD)

    	// Helpfully*, our sequence already has soft clipping removed, so there is nothing
    	// we can do apart from drop it.
    	//
    	// * I lied. It isn't helpful. 

    	Integer inputSequencePosition = 0
     	StringBuilder sequence = new StringBuilder()
    	StringBuilder reference = new StringBuilder()
    	StringBuilder markup = new StringBuilder()

    	log.error("sequence:     " + inputSequence)
    	log.error("cigar string: " + cigar)
    	log.error("MD string:    " + MD)

    	log.debug("cigarActions: " + cigarActions)

    	// Main loop involves pulling cigar actions. When we are done, we are done. 
    	// During this, we rely a lot on the basic principle that we are dealing entirely 
    	// with commands that consist of a length (for MD == 0). This allows us to modify
    	// the length as we work through the cigar actions. Should we need to.
    	while(cigarActions.size() > 0) {

    		ArrayList action = cigarActions[0]
    		Integer count = action[1]

    		log.debug("Handling cigar action: " + action)

    		if (action[0] == CIGAR_SOFT_CLIPPING || action[0] == CIGAR_HARD_CLIPPING) {
    			log.debug("Dropping cigar action")
    			cigarActions.remove(0)

    		} else if (action[0] == CIGAR_INSERT) {

    			// Case: we're an insert. This is an additional set of chars in the sequence
    			// so we can infer the reference as a subset, by dropping them from the 
    			// reference, and not matching them. 

    			// There *must not* be a corresponding MD action. In fact, the next MD action
    			// *must* be an MD_COPY, and we decrement its count. If that count becomes zero or less
    			// we drop it.

    			//assert mdActions[0][0] == MD_COPY
    			//mdActions[0][1] -= count

    			sequence <<  inputSequence[inputSequencePosition..(inputSequencePosition + count - 1)]
    			markup <<    ' '*count
    			reference << '-'*count
    			inputSequencePosition += count

    			// We're done.
    			log.debug("Dropping cigar action")
    			cigarActions.remove(0)
    			//if (mdActions[0][1] <= 0) {
    			//	log.debug("Dropping MD action")
    			//	mdActions.remove(0)
    			//}

    		} else if (action[0] == CIGAR_DELETE) {

    			// Case, we're a delete. This is an additional set of chars in the reference, 
    			// so we expect an MD_INSERT action, and if we don't find one, then we will moan.
    			// We also expect the length of the insert to be the same as the length of the
    			// deletion action. And unlike the insert, we don't move the sequence pointer as 
    			// we don't use any sequence chars.

    			assert mdActions[0][0] == MD_INSERT
    			assert mdActions[0][1].size() == count

    			sequence << '-'*count
    			markup <<    ' '*count
    			reference << mdActions[0][1]

    			// We're done.
    			log.debug("Dropping cigar action")
    			cigarActions.remove(0)
    			log.debug("Dropping MD action")
    			mdActions.remove(0)

    		} else if (action[0] == CIGAR_MATCH) {

    			// Case, we're a match. In a naive world, we can simply copy across stuff. In 
    			// practice, we might well encounter various MD substitutions along the way, and
    			// we will need to handle these if they exist. 

    			Integer mdHandled = 0

    			// So we should process some pending MD actions. While we can.
    			while(mdActions.size() > 0) {
    				ArrayList firstMdAction = mdActions[0]

    				log.debug("About to perform action: " + firstMdAction + ", handled: " + mdHandled + " of " + count)
    				if (mdHandled >= count) {
    					log.debug("On second thoughts, let's bail out")
    					break
    				}

    				if (firstMdAction[0] == MD_INSERT) {
    					throw new RuntimeException("Conflict between CIGAR and MD strings: attempting insert at: " + inputSequencePosition)
    				}

    				// If we're handling an MD_COPY, we simply do it, and advance the pointers that
    				// we need to advance.

    				if (firstMdAction[0] == MD_COPY) {
    					Integer mdCount = firstMdAction[1]
    					if (mdCount > count) {
    						mdCount = count
    					}
    					firstMdAction[1] -= count

    					log.debug("Copying " + mdCount + " characters")

    					String segment = inputSequence[inputSequencePosition..(inputSequencePosition + mdCount - 1)]
		    			sequence <<  segment
		    			markup <<    '|'*mdCount
		    			reference << segment
		    			inputSequencePosition += mdCount

		    			if (firstMdAction[1] <= 0) {
		    				log.debug("Dropping MD action")
			    			mdActions.remove(0)
			    		}
		    			mdHandled += mdCount
		    			continue;
    				}

    				if (firstMdAction[0] == MD_REPLACE) {
    					String mdToken = firstMdAction[1]
    					Integer mdCount = mdToken.size()

    					sequence <<  inputSequence[inputSequencePosition..(inputSequencePosition + mdCount - 1)]
		    			markup <<    '.'*mdCount
		    			reference << mdToken
		    			inputSequencePosition += mdCount

		    			log.debug("Dropping MD action")
		    			mdActions.remove(0)
		    			mdHandled += mdCount
						continue;
    				}

    				throw new RuntimeException("Unexpected MD command");
    			}

    			// We're done.
    			log.debug("Dropping cigar action")
    			cigarActions.remove(0)

   			} else {

    			throw new RuntimeException("Can't handle action: " + action)
    		}
    	}

   		log.debug("sequence:  " + sequence)
   		log.debug("markup:    " + markup)
   		log.debug("reference: " + reference)

   		while(cigarActions.size() > 0 && cigarActions[0][0] == CIGAR_HARD_CLIPPING) {
   			cigarActions.remove(0)
   		}

   		assert mdActions.size() == 0
   		assert cigarActions.size() == 0
    	return [sequence: sequence.toString(), reference: reference.toString(), markup: markup.toString()]    	
    }

    private static final String[] cig_ops = ['M','I','D','N','S','H','P','M','X']

    String tupleToCIGAR(List readcig) {
    	StringBuilder cigar = new StringBuilder()
    	for(tuple in readcig) {
    		cigar << tuple[1]
    		cigar << cig_ops[tuple[0]]
    	}
    	return cigar.toString()    
    }
}
