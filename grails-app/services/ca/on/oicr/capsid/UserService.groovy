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

import java.util.List;
import java.util.Map;

import grails.plugins.springsecurity.Secured
import org.codehaus.groovy.grails.commons.ConfigurationHolder as CH

class UserService {

  static transactional = false

  def authService
  def springSecurityService

  User get(String username) {
	  User.findByUsername username
	}
  
  List list(Map params) {
	  def criteria = User.createCriteria()
	  
	  List results = criteria.list(params) {}

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

  def save(Map params) {
    if (get(params.username)) {
      return false
    }

    // Generate password
    String password = authService.getRandomString(8)

    User user = new User(
        username: params.username,
        userRealName: params.userRealName,
        email: params.email,
        institute:params.institute,
        location: params.location,
        password: springSecurityService.encodePassword(password),
        enabled: true).save(failOnError: true)

    // Give capsid:user role:access
    Role role = Role.findByAuthority('ROLE_CAPSID')

    if (params.admin) {
      UserRole.create user, role, 'owner'
    } else {
      UserRole.create user, role, 'user'
    }

    if (user.save(flush:true)) {
      // Use LDAP or Send email
      if (!params.ldap) {
        sendMail {
          to user.email
          subject "[capsid] CaPSID User Created"
          body 'New user created for CaPSID.\n\nUsername:\t' + user.username + '\nPassword:\t' + password + '\n\nCaPSID - ' + CH.config.grails.serverURL + '\nPlease do not respond to this email'
        }
      }
    }
  }

  void delete(User user) {
    user.delete()
    UserRole.removeAll user
  }

  Set unassigned(Map params) {
    Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
    UserRole.findAll().user.username.minus(UserRole.findAllByRole(roleInstance).user.username)
  }    
}
