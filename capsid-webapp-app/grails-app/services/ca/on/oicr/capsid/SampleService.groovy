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

import java.util.List;
import java.util.Map;

import org.bson.types.ObjectId

/**
 * Service to handle sample data access. 
 */
class SampleService {

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
     * Finds a requested sample
     *
     * @param name the sample name.
     * @param projectId the project identifier.
     * @return the sample.
     */
    Sample get(String name, ObjectId projectId) {
        Sample.findByNameAndProjectId name, projectId
    }

    /**
     * Finds all samples matching the given criteria
     *
     * @param params a map of the search criteria from the original request.
     * @return a list of samples.
     */
	List list(Map params) {
		def criteria = Sample.createCriteria()

		List results = criteria.list(params) {
            and {
                // Security Check
                //'in'("project", projectService.list([:]).label)
                
                // Filters by label, using project name on client side
                if (params.name) {
                    // Single name param being passed
                    if (params.name instanceof String) {
                        ilike("name", "%" + params.name + "%")
                    }
                    else if (params.name instanceof String[]) {
                        'in'("name", params.name)
                    }
                }
                if (params.projectId) {
                    // Single project param being passed
                    if (params.projectId instanceof ObjectId) {
                        eq("projectId", params.projectId)
                    }
                    else if (params.projectId instanceof ObjectId[]) {
                        'in'("projectId", params.projectId)
                    }
                }
                if (params.cancer) {
                    // Single cancer param being passed
                    if (params.cancer instanceof String) {
                        ilike("cancer", "%" + params.cancer + "%")
                    }
                    else if (params.cancer instanceof String[]) {
                        'in'("cancer", params.cancer)
                    }
                }
                if (params.role) {
                    // Single role param being passed
                    if (params.role instanceof String) {
                        ilike("role", "%" + params.role + "%")
                    }
                    else if (params.role instanceof String[]) {
                        'in'("role", params.role)
                    }
                }
                if (params.source) {
                    // Single source param being passed
                    if (params.source instanceof String) {
                        ilike("source", "%" + params.source + "%")
                    }
                    else if (params.source instanceof String[]) {
                        'in'("source", params.source)
                    }
                }
                if (params.text) {
                    String text = '%' + params.text + '%'
                    or {
                        ilike("name", text)
                        ilike("project", text)
                        ilike("description", text)
                        ilike("cancer", text)
                        ilike("role", text)
                        ilike("source", text)
                    }
                }
            }
        }
  
		return results
	}

    /**
     * Deletes data associated with a given sample.
     * 
     * @param sample the sample to delete associated data for. 
     */
    void delete(String sample) {
        Alignment.findAllBySample(sample).each { it.delete(flush: true) }
        Mapped.findAllBySample(sample).each { it.delete(flush: true) }
    }
}
