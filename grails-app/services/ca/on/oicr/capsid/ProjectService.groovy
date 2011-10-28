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

    void update(Project project, Map params) {
       project.properties = params
    }

    Project get(label) {
        Project.findByLabel label
    }

    List<Project> getAllowedProjects() {
        if (authService.isCapsidAdmin()) {
            Project.list()
        } else {
            Project.security(authService.getRolesWithAccess(['read','admin'])).list()
        }
    }

    Project save(Map params) {
        Project project = new Project(params)
        String projectRole = 'ROLE_' + project.label.toUpperCase()
        List roles = [projectRole]

        if (!params.private) {
            roles.push("ROLE_CAPSID")
        }

        project.roles = roles

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

    List users(Project project) {
        authService.getUsersWithRole('ROLE_'+project.label.toUpperCase()).collect {[
            'username': it.user.username
        ,   'read': 'read' in it.access
        ,   'update': 'update' in it.access
        ,   'delete': 'delete' in it.access
        ,   'create': 'create' in it.access
        ,   'admin': 'admin' in it.access
        ]}
    }
}
