/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*	This program and the accompanying materials are made available under the
*	terms of the GNU Public License v3.0.
*
*	You should have received a copy of the GNU General Public License along with
*	this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

class Mapped {
	static mapWith = 'mongo'
	
	Long id
	String readId
    String sequencingType
	String platform
	Integer readLength
	Byte minQuality
	Float avgQuality
	Byte miscalls
	String isHuman
	String mapsGene
	Integer readStart
	Integer refStart
	String refStrand
	Integer alignLength
	Byte score
	Byte mismatch
	//*
	Integer genomeId
	Integer alignmentId
	Integer projectId
	Integer sampleId
	//*/
	static constraints = {
		readId nullable:false, blank:false		
		sequencingType nullable:false, inList: ['WT']
		platform nullable:false, inList: ['SOLID', 'Illumina']
		readLength nullable:false, blank:false
		minQuality nullable:false, blank:false
		avgQuality nullable:false, blank:false
		miscalls nullable:false, blank:false
		isHuman nullable:false, blank:false
		readStart nullable:false, blank:false
		refStart nullable:false, blank:false
		refStrand nullable:false, inList: ['PLUS', 'MINUS']
		alignLength nullable:false, blank:false
		score nullable:false, blank:false
		mismatch nullable:false, blank:false
    }
	
	static mapping = {
	}
	
	static namedQueries = {
		threshold {threshold ->
			or {
				and {
					eq("platform", 'Illumina', [ignoreCase:true])
					ge("avgQuality", threshold?.iAvgQual ?: new Float(1))
					ge("minQuality", threshold?.iMinQual ?: 1 as byte)
					le("miscalls", threshold?.iMaxMiscalls ?: 50 as byte)
					or { 
						le("score", threshold?.iAlignScoreLow ?: 3 as byte)
						ge("score", threshold?.iAlignScoreHigh ?: 20 as byte)
					}
					le("mismatch", threshold?.iMaxMismatches ?: 50 as byte)
				}
				and {
					eq("platform", 'Solid', [ignoreCase:true])
					ge("avgQuality", threshold?.sAvgQual ?: new Float(1)) // 0
					ge("minQuality", threshold?.sMinQual ?: 1 as byte) //0
					le("miscalls", threshold?.sMaxMiscalls ?: 50 as byte) //50
					or {
						le("score", threshold?.sAlignScoreLow ?: 3 as byte) // <3 
						ge("score", threshold?.sAlignScoreHigh ?: 20 as byte) // >20
					}
					le("mismatch", threshold?.sMaxMismatches ?: 50 as byte) //50
				}
			}
		}
		
		/*** Project Controller ***/
		//** Used in project/show_summary
		projectSummary { project ->
			createAlias("sample", "s")
			
			projections {
				count("id", "hits")
				countDistinct("s.id", "samples")
			}	
			
			eq("project", project)
	    }

		//** Used in project/show_genomes
		genomesByProject { project ->
			createAlias("genome", "g")

			projections {
				groupProperty("g.id", "id")
				groupProperty("g.xseqId", "xseqId")
				groupProperty("g.name", "name")
				countDistinct("sample", "samples")
				count("id", "hits")
			}

			eq("project", project)
		}
		filterGenomesByProject {params ->
            if (params.xseqId) ilike("g.xseqId", "%" + params.xseqId + "%")
            if (params.name) ilike("g.name", "%" + params.name + "%")
		}

		//** Used in project/genome_summary
		projectGenomeSummary { project, genome ->
			createAlias("sample", "s")
			
			projections {
				count("s.id", "hits")
				countDistinct("s.id", "samples")
			}	
			
			eq("project", project)
			eq("genome", genome)
	    }
		
        //** Used in project/genome_samples
        samplesByProjectGenome {project, genome ->
            createAlias("sample", "s")

            projections {
                groupProperty("s.id", "id")
                groupProperty("s.name", "name")
                count("id", "hits")
            }

            eq("project", project)
            eq("genome", genome)
        }
        filterSamplesByProjectGenome {params ->
        }

		//OLD
		querySampleDataByProjectAndGenome { project, genome ->
			createAlias("sample", "s")
			
			projections {
				groupProperty("s.id", "sid")
				groupProperty("s.name", "name")
				count("id", "hits")
			}
			
			eq("project", project)
			eq("genome", genome)
		}
		filterSampleDataByProjectAndGenome { params ->
			if (params.sid) eq("s.id", params.sid as short)
			if (params.name) ilike("s.name", "%" + params.name + "%")
		}
		
		/* Genome Controller */
		//** Used in genome/summary
		genomeSummary { genome ->
			createAlias("sample", "s")
			
			projections {
				count("s.id", "hits")
				countDistinct("s.id", "samples")
			}	
			
			eq("genome", genome)
		} 

        //** Used in genome/show_samples
		samplesByGenome { genome ->
			createAlias("project", "p")
			createAlias("sample", "s")

			projections {
				groupProperty("s.id", "id")
				groupProperty("s.name", "name")
				groupProperty("p.id", "pid")
				groupProperty("p.name", "pname")
				count("id", "hits")
			}

			eq("genome", genome)
		}
		filterSamplesByGenome { params ->
			if (params.name) ilike("s.name", "%" + params.name + "%")
			if (params.pname) ilike("p.name", "%" + params.pname + "%")
		}

		//OLD
		bySampleAndGenome { sample, genome ->
			projections {
				property("id")
				property("refStart")
				property("readLength")
				property("refStrand")
				property("isHuman")
			}
			
			eq("sampleId", sample)
			eq("refgenomeId", genome)
			
			order("refStart", "asc")
		}
	}
}
