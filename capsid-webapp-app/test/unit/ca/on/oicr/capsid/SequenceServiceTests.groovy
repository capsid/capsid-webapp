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
    	Map result = service.calculateAlignment(sequence,  "10",  "5M5I5M")
    	assert result["sequence"] ==  "AGTGATGGGAGGATG"
    	assert result["markup"] ==    "|||||     |||||"
    	assert result["reference"] == "AGTGA-----GGATG"
    }

    void testCalculateAlignment2() {
    	Map result = service.calculateAlignment(sequence,  "^AGTGA",  "5D")
    	assert result["sequence"] ==  "-----"
    	assert result["markup"] ==    "     "
    	assert result["reference"] == "AGTGA"
    }

    void testCalculateAlignment3() {
    	Map result = service.calculateAlignment(sequence,  "5",  "5M")
    	assert result["sequence"] ==  "AGTGA"
    	assert result["markup"] ==    "|||||"
    	assert result["reference"] == "AGTGA"
    }

    void testCalculateAlignment4() {
    	Map result = service.calculateAlignment(sequence,  "2C2",  "5M")
    	assert result["sequence"] ==  "AGTGA"
    	assert result["markup"] ==    "||.||"
    	assert result["reference"] == "AGCGA"
    }

    void testCalculateAlignment5() {
    	Map result = service.calculateAlignment(sequence,  "2C2^AGTGA5",  "5M5D5M")
    	assert result["sequence"] ==  "AGTGA-----TGGGA"
    	assert result["markup"] ==    "||.||     |||||"
    	assert result["reference"] == "AGCGAAGTGATGGGA"
    }

    void testCalculateAlignment6() {
    	Map result = service.calculateAlignment(sequence,  "3C3T1^GCTCAG26",  "2M1I7M6D26M")
    	assert result["sequence"] ==  "AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA"
    	assert result["markup"] ==    "|| |.|||.|      ||||||||||||||||||||||||||"
    	assert result["reference"] == "AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA"
    }

    void testCalculateAlignment7() {
    	String longSequence = "AAGAAGAGAGAGAGAGAGAGAGAGAGAGAGAAGAGAGAGAGAGAGAGAGAGGGGGGGGGAGAAAGAGAGAGAGAGA"
    	Map result = service.calculateAlignment(longSequence,  "3G27^G20A1A1A1A4G13",  "31M1D45M")
    	assert result["sequence"] ==  "AAGAAGAGAGAGAGAGAGAGAGAGAGAGAGA-AGAGAGAGAGAGAGAGAGAGGGGGGGGGAGAAAGAGAGAGAGAGA"
    	assert result["markup"] ==    "|||.||||||||||||||||||||||||||| ||||||||||||||||||||.|.|.|.||||.|||||||||||||"
    	assert result["reference"] == "AAGGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGAGA"
    }

    void testCalculateAlignment8() {
    	String longSequence = "GTCCCCCAACTACGACAAGTGGGAAATGGAGCGCACCGACATCACCATGAAGCACAAGTTGGGTGGAGGCCAGTACGGGGAGGTGTACGAGGGCG"
    	Map result = service.calculateAlignment(longSequence,  "95",  "6S95M")
    	assert result["sequence"] ==  "GTCCCCCAACTACGACAAGTGGGAAATGGAGCGCACCGACATCACCATGAAGCACAAGTTGGGTGGAGGCCAGTACGGGGAGGTGTACGAGGGCG"
    	assert result["markup"] ==    "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    	assert result["reference"] == "GTCCCCCAACTACGACAAGTGGGAAATGGAGCGCACCGACATCACCATGAAGCACAAGTTGGGTGGAGGCCAGTACGGGGAGGTGTACGAGGGCG"
    }

    void testCalculateAlignment9() {
    	String longSequence = "ACACACGGACACACACACACACACGCACACAGACACACACACA"
    	Map result = service.calculateAlignment(longSequence,  "25G17",  "4H43M3H")
    	assert result["sequence"] ==  "ACACACGGACACACACACACACACGCACACAGACACACACACA"
    	assert result["markup"] ==    "|||||||||||||||||||||||||.|||||||||||||||||"
    	assert result["reference"] == "ACACACGGACACACACACACACACGGACACAGACACACACACA"
    }

    void testCalculateAlignmentA() {
    	String longSequence = "AGAGAGACCCCCTGAAAAAACGCACACACACACACACACACACACACACACACACACACACACACGCACATGCACA"
    	Map result = service.calculateAlignment(longSequence,  "1C1C1C2A1A1A0C1C1C2A1G41A8",  "12M1I57M2I4M")
    	assert result["sequence"] ==  "AGAGAGACCCCCTGAAAAAACGCACACACACACACACACACACACACACACACACACACACACACGCACATGCACA"
    	assert result["markup"] ==    "|.|.|.||.|.| ..|.|.||.|.|||||||||||||||||||||||||||||||||||||||||.||||  ||||"
    	assert result["reference"] == "ACACACACACAC-ACACACACACGCACACACACACACACACACACACACACACACACACACACACACACA--CACA"
    }

    void testCalculateAlignmentB() {
        String longSequence = "TGCATATGATTGTATCTGTTAATTATTTCAATTTGCTTTTAAATATCTAATTCTTGTCTATTGTTTCAACATTTTGTTAAACTGTTTTTCTCTGTTCATGA"
        Map result = service.calculateAlignment(longSequence,  "7C0A6^GAAC3^CAG1^G0G5G7A6G2T2T2G1G2G3A2^G6T2^CCCA9C0",  "4M1I1M1I8M1I2M4D3M3D1M1D41M4I1M1D3M4I1M1I5M4D2M7I3M2I5M")
        assert result["sequence"] ==  "TGCATATGATTGTATCTG----TTA---A-TTATTTCAATTTGCTTTTAAATATCTAATTCTTGTCTATTGTTTCA-ACATTTTGTTAAAC----TGTTTTTCTCTGTTCATGA"
        assert result["markup"] ==    "|||| | ||..|||| ||    |||   | .|||||.|||||||.||||||.||.||.||.|.||.|||.|    | |||    | ||.||    ||       |||  ||||."
        assert result["reference"] == "TGCA-A-GACAGTAT-TGGAACTTACAGAGGTATTTGAATTTGCATTTAAAGATTTATTTGTGGTGTATAG----AGACA----G-TATACCCCATG-------CTG--CATGC"
    }

    void testTupleToCIGAR1() {
    	String result = service.tupleToCIGAR([[0, 5]])
    	assert result == "5M"
    }

    void testTupleToCIGAR2() {
    	String result = service.tupleToCIGAR([[0, 5], [2, 10], [1, 3], [0, 20]])
    	assert result == "5M10D3I20M"
    }

    void testTupleToCIGAR3() {
    	String result = service.tupleToCIGAR([[5, 4], [0, 43], [5, 3]])
    	assert result == "4H43M3H"
    }

    void testTupleToCIGAR4() {
    	String result = service.tupleToCIGAR([[0, 12], [1, 1], [0, 57], [1, 2], [0, 4]])
    	assert result == "12M1I57M2I4M"
    }

    void testTupleToCIGAR5() {
        String result = service.tupleToCIGAR([[0, 4], [1, 1], [0, 1], [1, 1], [0, 8], [1, 1], [0, 2], [2, 4], [0, 3], [2, 3], [0, 1], [2, 1], [0, 41], [1, 4], [0, 1], [2, 1], [0, 3], [1, 4], [0, 1], [1, 1], [0, 5], [2, 4], [0, 2], [1, 7], [0, 3], [1, 2], [0, 5]])
        assert result == "4M1I1M1I8M1I2M4D3M3D1M1D41M4I1M1D3M4I1M1I5M4D2M7I3M2I5M"
    }
}
