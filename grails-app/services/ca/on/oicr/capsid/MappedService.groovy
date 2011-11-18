/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*   This program and the accompanying materials are made available under the
*   terms of the GNU Public License v3.0.
*
*   You should have received a copy of the GNU General Public License along with
*   this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import grails.plugins.springsecurity.Secured

class MappedService {

    static transactional = false

    def authService
    def projectService

    Mapped get(String name) {
        Mapped.findByName name
    }

    List<Mapped> getAllowedMappeds() {
        if (authService.isCapsidAdmin()) {
            Mapped.list()
        } else {
            Mapped.security(projectService.getAllowedProjects()?.label)?.list()
        }
    }
}
