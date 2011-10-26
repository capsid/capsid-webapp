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

class ProjectService {

    static transactional = false

    def authService
    def springSecurityService

    void update(Project project, String name) {
       project.name = name
    }

    def get(label) {
        String projectRole = 'ROLE_' + label.toUpperCase()
        if (!authService.hasAccess([projectRole: ['read','admin'], 'ROLE_CAPSID': ['admin']])) {
            return false
        }
        Project.findByLabel label
    }

    List<Project> getAllowedProjects() {
        Project.security(authService.getRolesWithAccess(['read','admin'])).list()
    }

    Project create(Map params) {
        Project project = new Project(params)
        String projectRole = 'ROLE_' + project.label.toUpperCase()
        project.roles = [projectRole]

        if (project.save(flush: true)) {
            Role role = Role.findByAuthority(projectRole) ?: new Role(authority: projectRole).save(failOnError: true)
            User user = springSecurityService.getCurrentUser()
            UserRole.create user, role, ['read', 'update', 'delete', 'admin'] as Set
        }

        project
    }

    void delete(Project project) {
        String projectRole = 'ROLE_' + project.label.toUpperCase()
        project.delete()

        // Delete the ACL information as well
        Role role = Role.findByAuthority(projectRole)
        role.delete()
        User user = springSecurityService.getCurrentUser()
        UserRole.remove user, role, true
    }
}
