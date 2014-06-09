package ca.on.oicr.capsid

import java.util.regex.Matcher
import org.apache.commons.logging.LogFactory

class SequenceService {

	private static final log = LogFactory.getLog(this)

	public static final int CIGAR_INSERT = -1
	public static final int CIGAR_DELETE = 1
	public static final int CIGAR_MATCH = 0

	public static final int MD_COPY = 0
	public static final int MD_INSERT = 1
	public static final int MD_REPLACE = 2

	ArrayList cigarActions(String cigar) {
    	ArrayList cigarActions = [] as ArrayList

		Matcher matcher = cigar =~ /(\d+)([MIDNSHP=X])/
    	matcher.each {
    		Integer count = it[1] as Integer
    		String identifier = it[2]
    		if (identifier == 'D' || identifier == 'N' || identifier == 'P' || identifier == 'H') {
                cigarActions << [CIGAR_DELETE, count] 
            } else if (identifier == 'I' || identifier == 'S') {
    			cigarActions << [CIGAR_INSERT, count] 
    		} else if (identifier == 'M' || identifier == '=' || identifier == 'X') {
    			cigarActions << [0, count] 
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

    	Integer inputSequencePosition = 0
     	StringBuilder sequence = new StringBuilder()
    	StringBuilder reference = new StringBuilder()
    	StringBuilder markup = new StringBuilder()

    	log.error("cigarActions: " + cigarActions)

    	// Main loop involves pulling cigar actions. When we are done, we are done. 
    	// During this, we rely a lot on the basic principle that we are dealing entirely 
    	// with commands that consist of a length (for MD == 0). This allows us to modify
    	// the length as we work through the cigar actions. Should we need to.
    	while(cigarActions.size() > 0) {

    		ArrayList action = cigarActions[0]
    		Integer count = action[1]

    		log.error(action)

    		if (action[0] == CIGAR_INSERT) {

    			// Case: we're an insert. This is an additional set of chars in the sequence
    			// so we can infer the reference as a subset, by dropping them from the 
    			// reference, and not matching them. 

    			// There *must not* be a corresponding MD action. In fact, the next MD action
    			// *must* be an MD_COPY, and we decrement its count. 

    			assert mdActions[0][0] == MD_COPY
    			mdActions[0][1] -= count

    			sequence <<  inputSequence[inputSequencePosition..(inputSequencePosition + count - 1)]
    			markup <<    ' '*count
    			reference << '-'*count
    			inputSequencePosition += count

    			// We're done.
    			cigarActions.remove(0)

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
    			cigarActions.remove(0)

    		} else if (action[0] == CIGAR_MATCH) {

    			// Case, we're a match. In a naive world, we can simply copy across stuff. In 
    			// practice, we might well encounter various MD substitutions along the way, and
    			// we will need to handle these if they exist. 

    			ArrayList firstMdAction = mdActions[0]

    			sequence <<  inputSequence[inputSequencePosition..(inputSequencePosition + count - 1)]
    			markup <<    '|'*count
    			reference << inputSequence[inputSequencePosition..(inputSequencePosition + count - 1)]

    			// We're done.
    			cigarActions.remove(0)

   			} else {

    			throw new RuntimeException("Can't handle action: " + action)
    		}
    	}

   		log.error("sequence:  " + sequence)
   		log.error("markup:    " + markup)
   		log.error("reference: " + reference)
    	return [sequence: sequence.toString(), reference: reference.toString(), markup: markup.toString()]    	
    }
}
