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

import org.bson.types.ObjectId

/**
 * Service to handle feature data access. 
 */
class FeatureService {

    /**
     * Don't use transactions. 
     */
    static transactional = false

    /**
     * Finds a requested feature
     *
     * @param the feature unique identifier.
     * @return the feature.
     */
    Feature get(String id) {
        Feature.get(new ObjectId(id))
    }

    /**
     * Finds all features matching the given criteria
     *
     * @param params a map of the search criteria from the original request.
     * @return a list of features.
     */
    List list(Map params) {
		def criteria = Feature.createCriteria()
		
		List results = criteria.list(params) {
			eq('type', 'gene')
			and {
				if (params?.name) {
					// Single name param being passed
					if (params.name instanceof String) {
						ilike("name", "%" + params.name + "%")
					}
					else if (params.name instanceof String[]) {
						'in'("name", params.name)
					}
				}
				if (params?.locusTag) {
					// Single name param being passed
					if (params.locusTag instanceof String) {
						ilike("locusTag", "%" + params.locusTag + "%")
					}
					else if (params.locusTag instanceof String[]) {
						'in'("locusTag", params.locusTag)
					}
				}
				if (params?.geneId) {
					// Single name param being passed
					if (params.geneId instanceof String) {
						eq("geneId", params.geneId as int)
					}
					else if (params.geneId instanceof String[]) {
						'in'("geneId", params.geneId)
					}
				}
				if (params?.genome) {
					if (params.genome instanceof Long) {
						//'in'("genome", Genome.withCriteria{ilike("name",params.genome.replaceAll(/\"/,'%'))}.gi)
						eq("genome", params.genome as Long)
					}
				}
				if (params?.text) {
          			String text = '%' + params.text + '%'
					or {
						ilike("name", text)
						ilike("genome", text)
						'in'("genome", Genome.withCriteria{ilike("name",text)}.gi)
					}
				}
			}
		}
  
		return results
	}
}
