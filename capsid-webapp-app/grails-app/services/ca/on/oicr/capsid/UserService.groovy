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

class UserService {

  static transactional = false

  def authService
  def springSecurityService

  User get(String username) {
	  User.findByUsername username
	}
  
  List list(Map params) {
	  def criteria = User.createCriteria()
	  
	  List results = criteria.list(params) {
      // Text
        if (params.text) {
          String text = '%' + params.text + '%'
          or {
            ilike("username", text)
            ilike("userRealName", text)
            ilike("email", text)
            ilike("institute", text)
          }
        }
    }

    results.each {
      it['admin'] = authService.isCapsidAdmin(it)
    }

	  return results
  }
  
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

  boolean changePassword(User user, Map params) {
    String old = springSecurityService.encodePassword(params.old)
    String password = springSecurityService.encodePassword(params.password)
    String confirm = springSecurityService.encodePassword(params.confirm)
    if (old == user.password) {
      user.password = password
      if (user.save(flush: true)) {
        authService.reauthenticate user
        return true
      }
    }

    false
  }

  Set unassigned(Map params) {
    Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
    Set roles = UserRole.findAll().user.username
	if (roleInstance) {
		roles = roles.minus(UserRole.findAllByRole(roleInstance).user.username)
	}
	roles
  }    
}
