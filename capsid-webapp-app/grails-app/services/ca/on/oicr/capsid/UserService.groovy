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

/**
 * Service to handle user data access. 
 */
class UserService {

  /**
   * Don't use transactions. 
   */
  static transactional = false

  /**
   * Dependency injection for the AuthService.
   */
  def authService

  /**
   * Dependency injection for the SpringSecurityService.
   */
  def springSecurityService

  /**
   * Finds a requested user
   *
   * @param username the user's username.
   * @return the user.
   */
  User get(String username) {
	  User.findByUsername username
	}
  
  /**
   * Finds all users matching the given criteria
   *
   * @param params a map of the search criteria from the original request.
   * @return a list of users.
   */
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
  
  /**
   * Updates a specified user and saves it, handling roles and reauthentication when needed.
   * 
   * @param user the specified user
   * @param params a map of the new values
   */
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

  /**
   * Updates a specified user's password and saves it, handling roles and reauthentication when needed.
   * 
   * @param user the specified user
   * @param params a map of the new values
   */
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

  /**
   * Finds a list of unassigned roles. 
   * 
   * @param params a map of the form values
   */
  Set unassigned(Map params) {
    Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
    Set roles = UserRole.findAll().user.username
	  if (roleInstance) {
		  roles = roles.minus(UserRole.findAllByRole(roleInstance).user.username)
	  }
	  roles
  }    
}
