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
 * Service to handle statistics record data access. 
 */
class StatsService {

    /**
     * Don't use transactions. 
     */
	static transactional = false

    /**
     * Dependency injection for the AuthService.
     */
	def authService

    /**
     * Dependency injection for the ProjectService.
     */
	def projectService

    /**
     * Dependency injection for the SpringSecurityService.
     */
	def springSecurityService

    /**
     * Finds all statistics records matching the given criteria
     *
     * @param params a map of the search criteria from the original request.
     * @return a list of statistics records.
     */
	List list(Map params) {

		// If we have a taxon identifier, we should use this as a filter. To do so, we
		// need to get the taxon and use its left/right values as a between filter on 
		// the left in the statistics. 
		Taxon tx = null;
		if (params.taxonRootId) {
			tx = Taxon.findById(params.taxonRootId);
		}

		def criteria = Statistics.createCriteria()

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

				// Add the filters
				if (params.filters) {
					def filters = (params.filters instanceof String ? [params.filters] : params.filters)
					for (filter in filters) {
						ne("tags", filter)
					}
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
			}
		}

    	return results
	}
}
