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

import grails.plugins.springsecurity.Secured

class AlignmentService {

    static transactional = false

    def authService
    def projectService
    def springSecurityService

    Alignment get(String name) {
        Alignment.findByName name
    }

    List list(Map params) {
        def criteria = Alignment.createCriteria()
        
        List results = criteria.list(params) {
            and {
                // Security Check
                'in'("project", projectService.list([:]).label)

                // Sample
                if (params.sample) {
                    if (params.sample instanceof String) {
                        ilike("sample", "%" + params.sample + "%")
                    }
                    else if (params.sample instanceof String[]) {
                        'in'("sample", params.sample)
                    }
                }

                // Text
                if (params.text) {
                    String text = '%' + params.text + '%'
                    or {
                        ilike("name", text)
                        ilike("sample", text)
                        ilike("project", text)
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
