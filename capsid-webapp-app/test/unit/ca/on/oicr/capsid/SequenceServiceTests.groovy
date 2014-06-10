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

    void testCalculateAlignment7() {
    	String longSequence = "AAGAAGAGAGAGAGAGAGAGAGAGAGAGAGAAGAGAGAGAGAGAGAGAGAGGGGGGGGGAGAAAGAGAGAGAGAGA"
    	Map result = service.calculateAlignment(longSequence, "3G27^G20A1A1A1A4G13", "31M1D45M") 
    	assert result["sequence"] ==  "AAGAAGAGAGAGAGAGAGAGAGAGAGAGAGA-AGAGAGAGAGAGAGAGAGAGGGGGGGGGAGAAAGAGAGAGAGAGA"
    	assert result["markup"] ==    "|||.||||||||||||||||||||||||||| ||||||||||||||||||||.|.|.|.||||.|||||||||||||"
    	assert result["reference"] == "AAGGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGA"
    }

    void testCalculateAlignment8() {
    	String longSequence = "GTCCCCCAACTACGACAAGTGGGAAATGGAGCGCACCGACATCACCATGAAGCACAAGTTGGGTGGAGGCCAGTACGGGGAGGTGTACGAGGGCG"
    	Map result = service.calculateAlignment(longSequence, "95", "6S95M") 
    	assert result["sequence"] ==  "GTCCCCCAACTACGACAAGTGGGAAATGGAGCGCACCGACATCACCATGAAGCACAAGTTGGGTGGAGGCCAGTACGGGGAGGTGTACGAGGGCG"
    	assert result["markup"] ==    "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    	assert result["reference"] == "GTCCCCCAACTACGACAAGTGGGAAATGGAGCGCACCGACATCACCATGAAGCACAAGTTGGGTGGAGGCCAGTACGGGGAGGTGTACGAGGGCG"
    }

    void testTupleToCIGAR1() {
    	String result = service.tupleToCIGAR([[0, 5]])
    	assert result == "5M"
    }

    void testTupleToCIGAR2() {
    	String result = service.tupleToCIGAR([[0, 5], [2, 10], [1, 3], [0, 20]])
    	assert result == "5M10D3I20M"
    }
}
