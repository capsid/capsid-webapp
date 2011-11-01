/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*    This program and the accompanying materials are made available under the
*    terms of the GNU Public License v3.0.
*
*    You should have received a copy of the GNU General Public License along with
*    this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

class AuthService {

    def springSecurityService

    static transactional = false

    List getRoles() {
        springSecurityService.principal.authorities.toString().replaceAll(~"[\\[\\] ]", "").tokenize(',')
    }

    Map getAccessLevels() {
        User user = User.findByUsername(springSecurityService.principal.username)
        if (user) {
            user.accessLevels()
        } else {
            ['ROLE_CAPSID' : 'user']
        }
    }

    List getRolesWithAccess(List level) {
        Map accessLevels = getAccessLevels()
        accessLevels.findAll {
            it.value in level
            }.keySet() as List

    }

    List<UserRole> getUsersWithRole(String roleName) {
        Role role = Role.findByAuthority(roleName)
        List<UserRole> users = UserRole.findAllByRole(role)
    }

    boolean hasAccess(Map requiredAccess) {
        Map accessLevels = getAccessLevels()

        requiredAccess.find { k,v ->
            if (accessLevels.get(k) && v.intersect(accessLevels[k])) {
                return true
            }
        }
    }

    boolean isCapsidAdmin() {
        Map access = getAccessLevels()
        access.get('ROLE_CAPSID') == 'owner'
    }

    boolean authorize(Project project, List access) {
        isCapsidAdmin() || !project?.roles?.disjoint(getRolesWithAccess(access))
    }
    boolean authorize(List roles, List access) {
        isCapsidAdmin() || !roles?.disjoint(getRolesWithAccess(access))
    }
}
