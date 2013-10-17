/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package ca.on.oicr.capsid

import java.lang.Math

class GenomeService {

    static transactional = false

    Genome get(String accession) {
        Genome.findByAccession accession
    }

    List list(Map params) {
		def criteria = Genome.createCriteria()

		List results = criteria.list(params) {
			and {
				if (params.accession) {
					// Single name param being passed
					if (params.accession instanceof String) {
						eq("accession", params.accession)
					}
					else if (params.accession instanceof String[]) {
						'in'("accession", params.accession)
					}
				}
				if (params.gi) {
					// Single name param being passed
					if (params.gi instanceof String) {
						eq("gi", params.gi as int)
					}
					else if (params.gi instanceof String[]) {
						'in'("gi", params.gi)
					}
				}
				if (params.name) {
					// Single name param being passed
					if (params.name instanceof String) {
						ilike("name", params.name.replaceAll (/\"/, '%'))
					}
					else if (params.name instanceof String[]) {
						'in'("name", params.name.replaceAll (/\"/, '%'))
					}
				}
				if (params.organism) {
					// Single name param being passed
					if (params.organism instanceof String) {
						ilike("organism", params.organism.replaceAll (/\"/, '%'))
					}
					else if (params.name instanceof String[]) {
						'in'("organism", params.organism.replaceAll (/\"/, '%'))
					}
				}
				if (params.taxonomy) {
					// Single name param being passed
					if (params.taxonomy instanceof String) {
						ilike("taxonomy", params.taxonomy.replaceAll (/\"/, '%'))
					}
					else if (params.taxonomy instanceof String[]) {
						'in'("taxonomy", params.taxonomy)
					}
				}
				if (params.text) {
          			String text = '%' + params.text + '%'
					or {
						ilike("name", text)
						ilike("taxonomy", text)
					}
				}
			}
		}
  
		return results
	}

	// Calculate and build a histogram for the gene data across the region.
	def getHistogramRegion(Genome genome, Integer start, Integer end, Integer interval) {

        Integer histogramCount = Math.ceil((end - start) / interval).toInteger()

        Integer[] data = new int[histogramCount]

		def criteria = Feature.createCriteria();
		List<Feature> results = criteria.list(params) {
			eq("genome", genome.gi)
			eq("type", "gene")
			le("start", end)
			ge("end", start)
		}

		for(Feature f in results) {
			Integer box = Math.floor((f.start - start) / interval).toInteger()
			data[box]++
		}

		Integer maximum = data.max()
	    if (maximum == 0) {
	      	maximum = 1;
	    }

		List<Map> result = data.collect { count ->
			[start: (start += interval),
			 end: start,
			 interval: 0,
			 absolute: count,
			 value: count / maximum]
		}

        return result
	}

	// Calculate and build a histogram for the gene data across the region.
	def getGenesRegion(Genome genome, Integer start, Integer end) {

		def criteria = Feature.createCriteria();
		List<Feature> results = criteria.list(params) {
			eq("genome", genome.gi)
			eq("type", "gene")
			le("start", end)
			ge("end", start)
		}

	    List<Map> data = results.collect { Feature f ->
	      	[start: f.start, end: f.end, strand: f.strand, name: f.name, locusTag: f.locusTag]
    	}

        return [data: data]
	}
}
