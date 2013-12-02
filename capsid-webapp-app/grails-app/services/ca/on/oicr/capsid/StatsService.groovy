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
import grails.plugins.springsecurity.Secured

class StatsService {

	static transactional = false

	def authService
	def projectService
	def springSecurityService

	List list(Map params) {

		// If we have a taxon identifier, we should use this as a filter. To do so, we
		// need to get the taxon and use its left/right values as a between filter on 
		// the left in the statistics. 
		Taxon tx = null;
		if (params.taxonRootId) {
			tx = Taxon.findById(params.taxonRootId);
		}

		def criteria = Statistics.createCriteria()

		log.info("Params: " + params.toString())

		List results = criteria.list(params) {
			and {
				
				// Security Check
                //'in'("label", projectService.list([:]).label)
            
            	// Project
				// if (params.label) {
				// 	if (params.label instanceof String) {
				// 		eq("label",params.label)
				// 	}
				// }

				if (params.ownerId && params.ownerId instanceof ObjectId) {
					eq("ownerId", params.ownerId)
				}

				if (params.ownerType) {
					eq("ownerType", params.ownerType)
				}

				if (params.projectId && params.projectId instanceof ObjectId) {
					eq("projectId", params.projectId)
				}

				// And this adds the filter on taxon range, if we need it. 
				if (tx != null) {
					between("left", tx.left, tx.right);
				}

				// Genome identifier
				if (params.gi) {
					eq("gi", params.gi)
				}

				// Text
				if (params.text) {
					String text = '%' + params.text + '%'
					or {
						ilike("genome", text)
						ilike("sample", text)
						ilike("project", text)
					}
				}

				// Filters
				if (params.filters && params.filters != "false") {
					'in'("filter", params.filters)
				}		
			}
		}

    	return results
	}
}
