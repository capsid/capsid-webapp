package ca.on.oicr.capsid


import grails.test.mixin.*
import org.junit.*

/**
 * See the API for {@link grails.test.mixin.services.ServiceUnitTestMixin} for usage instructions
 */
@TestFor(SequenceService)
class SequenceServiceTests {

   	String sequence = "AGTGATGGGAGGATGTCTCGTCTGTGAGTTACAGCAGAGTTACAGCA"

	void testCigarActions() {
		ArrayList result = service.cigarActions("5I") 
		assert result.size() == 1
	}

	void testMdActions() {
		ArrayList result = service.mdActions("10^GCTCAG26") 
		assert result.size() == 3
	}

    void testCalculateAlignment1() {
    	Map result = service.calculateAlignment(sequence, "10", "5M5I5M") 
    	assert result["sequence"] ==  "AGTGATGGGAGGATG"
    	assert result["markup"] ==    "|||||     |||||"
    	assert result["reference"] == "AGTGA-----GGATG"
    }

    void testCalculateAlignment2() {
    	Map result = service.calculateAlignment(sequence, "^AGTGA", "5D") 
    	assert result["sequence"] ==  "-----"
    	assert result["markup"] ==    "     "
    	assert result["reference"] == "AGTGA"
    }

    void testCalculateAlignment3() {
    	Map result = service.calculateAlignment(sequence, "5", "5M") 
    	assert result["sequence"] ==  "AGTGA"
    	assert result["markup"] ==    "|||||"
    	assert result["reference"] == "AGTGA"
    }

    void testCalculateAlignment4() {
    	Map result = service.calculateAlignment(sequence, "2C2", "5M") 
    	assert result["sequence"] ==  "AGTGA"
    	assert result["markup"] ==    "||.||"
    	assert result["reference"] == "AGCGA"
    }

    void testCalculateAlignment5() {
    	Map result = service.calculateAlignment(sequence, "2C2^AGTGA5", "5M5D5M") 
    	assert result["sequence"] ==  "AGTGA-----TGGGA"
    	assert result["markup"] ==    "||.||     |||||"
    	assert result["reference"] == "AGCGAAGTGATGGGA"
    }

    void testCalculateAlignment6() {
    	Map result = service.calculateAlignment(sequence, "3C3T1^GCTCAG26", "2M1I7M6D26M") 
    	assert result["sequence"] ==  "AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA"
    	assert result["markup"] ==    "|| |.|||.|      ||||||||||||||||||||||||||"
    	assert result["reference"] == "AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA"
    }

	/*
	// Check a single deletion against the reference
    void testCalculateAlignmentDelete() {
    	String sequence = "AGTGATGGGAGGATGTCTCGTCTGTGAGTTACAGCA"
    	String MD = "10^GCTCAG26"
    	String cigar = "10M6D26M"

    	Map result = service.calculateAlignment(sequence, MD, cigar) 
    	assert result != null
    	assert result.containsKey("sequence")
    	assert result.containsKey("reference")
    	assert result.containsKey("markup")

    	assert result["sequence"] ==  "AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA"
    	assert result["markup"] ==    "||||||||||      ||||||||||||||||||||||||||"
    	assert result["reference"] == "AGTGATGGGAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA"
    }

	// Check an insertion and a deletion against the reference
    void testCalculateAlignmentDeleteAndInsert() {
    	String sequence = "AGTGATGGGA"
    	String MD = "9"
    	String cigar = "2M1I7M"

    	Map result = service.calculateAlignment(sequence, MD, cigar) 
    	assert result != null
    	assert result.containsKey("sequence")
    	assert result.containsKey("reference")
    	assert result.containsKey("markup")

    	assert result["sequence"] ==  "AGTGATGGGA"
    	assert result["markup"] ==    "|| |||||||"
    	assert result["reference"] == "AG-GATGGGA"
    }

    void testCalculateAlignment1() {
    	String sequence = "AGTGATGGGAGGATGTCTCGTCTGTGAGTTACAGCA"
    	String MD = "3C3T1^GCTCAG26"
    	String cigar = "2M1I7M6D26M"

    	Map result = service.calculateAlignment(sequence, MD, cigar) 
    	assert result != null
    	assert result.containsKey("sequence")
    	assert result.containsKey("reference")
    	assert result.containsKey("markup")

    	assert result["sequence"] ==  "AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA"
    	assert result["markup"] ==    "|| |.|||.|      ||||||||||||||||||||||||||"
    	assert result["reference"] == "AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA"
    }

    void testCalculateAlignment3() {
    	String sequence = "AAGAAGAGAGAGAGAGAGAGAGAGAGAGAGAAGAGAGAGAGAGAGAGAGAGGGGGGGGGAGAAAGAGAGAGAGAGA"
    	String MD = "3G27^G20A1A1A1A4G13"
    	String cigar = "31M1D45M"

    	Map result = service.calculateAlignment(sequence, MD, cigar) 
    	assert result != null
    	assert result.containsKey("sequence")
    	assert result.containsKey("reference")
    	assert result.containsKey("markup")

    }
    */
}
