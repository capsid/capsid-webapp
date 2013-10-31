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

class AlignmentService {

    static transactional = false

    def authService
    def projectService
    def springSecurityService

    Alignment get(String name, ObjectId projectId, ObjectId sampleId) {
        return Alignment.createCriteria().get {
            eq("projectId", projectId)
            eq("sampleId", sampleId)
            eq("name", name)
        }
    }

    List list(Map params) {
        def criteria = Alignment.createCriteria()

        System.err.println("list()")
        System.err.println(params)
        
        List results = criteria.list(params) {
            and {
                // Security Check
                //'in'("project", projectService.list([:]).label)

                // Sample
                if (params.sampleId) {
                    if (params.sampleId instanceof ObjectId) {
                        eq("sampleId", params.sampleId)
                    }
                    else if (params.sampleId instanceof ObjectId[]) {
                        'in'("sampleId", params.sampleId)
                    }
                }

                // Text
                if (params.text) {
                    String text = '%' + params.text + '%'
                    or {
                        ilike("name", text)
                        ilike("sample", text)
                        ilike("projectLabel", text)
                    }
                }
            }
        }
  
        return results
    }

    List<Alignment> getAllowedAlignments() {
        if (authService.isCapsidAdmin()) {
            Alignment.list()
        } else {
            Alignment.security(authService.getRolesWithAccess(['user', 'collaborator', 'owner'])).list()
        }
    }

    void delete(String alignment) {
        Mapped.findAllByAlignment(alignment).each { it.delete(flush: true) }
    }
}
