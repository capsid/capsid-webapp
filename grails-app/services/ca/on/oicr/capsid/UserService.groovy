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

    void update(User user, Map params) {
        user.properties = params

        if (authService.isCapsidAdmin()) {
            if (params.admin) {
                Role role = Role.findByAuthority('ROLE_CAPSID')
                UserRole.update user, role, 'owner', true
            } else {
                Role role = Role.findByAuthority('ROLE_CAPSID')
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
        if (get(params.name)) {
            return false
        }
        // Generate password
        User user = new User(params)
        user.save(flush:true)
        // Give capsid:user role:access
        // In LDAP or Email
    }

    void delete(User user) {
        user.delete()
    }
}
