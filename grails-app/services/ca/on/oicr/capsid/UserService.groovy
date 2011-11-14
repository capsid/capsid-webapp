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

class UserService {

    static transactional = false

    def authService
    def springSecurityService

    void update(User user, Map params) {
        user.properties = params

        if (authService.isCapsidAdmin()) {
            Role role = Role.findByAuthority('ROLE_CAPSID')
            if (params.admin) {
                UserRole.update user, role, 'owner', true
            } else {
                UserRole.update user, role, 'user', true
            }
        }

        if (user.save(flush: true)) {
            authService.reauthenticate user
        }
    }

    User get(String username) {
        User.findByUsername username
    }

    User save(Map params) {
        if (get(params.username)) {
            return false
        }

        User user = new User(params)

        // Generate password
        user.password = springSecurityService.encodePassword('admin')

        user.enabled = "true"
        // Give capsid:user role:access
        Role role = Role.findByAuthority('ROLE_CAPSID')
        if (params.admin) {
            UserRole.create user, role, 'owner'
        } else {
            UserRole.create user, role, 'user'
        }

        user.save(flush:true)

        // In LDAP or Email
    }

    void delete(User user) {
        user.delete()
    }
}
