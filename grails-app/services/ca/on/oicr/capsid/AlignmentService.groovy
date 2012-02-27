/*
*  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
*
*   This program and the accompanying materials are made available under the
*   terms of the GNU Public License v3.0.
*
*   You should have received a copy of the GNU General Public License along with
*   this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import grails.plugins.springsecurity.Secured

class AlignmentService {

    static transactional = false

    def authService
    def springSecurityService

    void update(Alignment alignment, Map params) {
        alignment.properties = params
        alignment.save()
    }

    Alignment get(String name) {
        Alignment.findByName name
    }

    List<Alignment> getAllowedAlignments() {
        if (authService.isCapsidAdmin()) {
            Alignment.list()
        } else {
            Alignment.security(authService.getRolesWithAccess(['user', 'collaborator', 'owner'])).list()
        }
    }

    Alignment save(Map params) {
        if (get(params.name)) {
            return false
        }
        Alignment alignment = new Alignment(params)
        alignment.save(flush:true)
    }

    void delete(Alignment alignment) {
        String name = alignment.name
        alignment.delete()
        Mapped.findAllByAlignment(name).each { it.delete(flush: true) }
    }
}
