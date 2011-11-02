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
        println params
        if (params.private) {
            project.roles = ['ROLE_' + params.label.toUpperCase()]
        } else {
            project.roles = ['ROLE_CAPSID', 'ROLE_' + params.label.toUpperCase()]
        }

        project.properties = params
        project.save()
    }

    Project get(label) {
        Project.findByLabel label
    }

    List<Project> getAllowedProjects() {
        if (authService.isCapsidAdmin()) {
            Project.list()
        } else {
            Project.security(authService.getRolesWithAccess(['user', 'collaborator', 'owner'])).list()
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
            UserRole.create user, role, 'owner'
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

    Map users(Project project) {
        Map userMap = [
                owners: []
            ,   collaborators: []
            ,   users: []
            ]

        authService.getUsersWithRole('ROLE_'+project.label.toUpperCase()).each {
            if ('owner' in it.access) {
                userMap.owners.push(it.user)
            } else if ('collaborator' in it.access) {
                userMap.collaborators.push(it.user)
            } else if ('user' in it.access) {
                userMap.users.push(it.user)
            }
        }

        userMap
    }
}
