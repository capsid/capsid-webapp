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

class FeatureService {

    static transactional = false

    Feature get(String uid) {
        Feature.findByUid uid
    }

    List list(Map params) {
		def criteria = Feature.createCriteria()
		
		List results = criteria.list(params) {
			eq('type', 'gene')
			and {
				if (params.name) {
					// Single name param being passed
					if (params.name instanceof String) {
						ilike("name", "%" + params.name + "%")
					}
					else if (params.name instanceof String[]) {
						'in'("name", params.name)
					}
				}
				if (params.geneId) {
					// Single name param being passed
					if (params.geneId instanceof String) {
						eq("geneId", params.geneId as int)
					}
					else if (params.geneId instanceof String[]) {
						'in'("geneId", params.geneId)
					}
				}
				if (params.text) {
					String text = params.text.replaceAll (/\"/, '%')
					or {
						ilike("name", text)
						eq("geneId", params.text as int)
					}
				}
			}
		}
  
		return results
	}
}
