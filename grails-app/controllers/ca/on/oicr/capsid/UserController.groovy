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

import grails.plugins.springsecurity.Secured
import grails.converters.JSON
import org.bson.types.ObjectId
import org.springframework.dao.DataIntegrityViolationException

@Secured(['ROLE_CAPSID'])
class UserController {

  def authService
  def userService
  def springSecurityService

  def index = {redirect(action: "list", params: params)}
  def list = {isCapsidAdmin()}

  def list_data = {
    List users = User.list().collect {
      [
        id: it.id.toString()
        ,    username: it.username,
        ,    userRealName: it.userRealName
        ,    email: it.email
        ,    institute: it.institute
        ,    location: it.location
        ,    admin: authService.isCapsidAdmin(it)
        ,    enabled: it.enabled
      ]
    }

    def ret = [
      'identifier': 'id',
      'label': 'username',
      'items': users
    ]

    render ret as JSON
  }

  def show = {
    if (!userService.get(params.id) &&
        params.id == springSecurityService.principal.username) {
      render view: 'ldap'
    } else {
      User user = findInstance()
      [userInstance: user, admin: authService.isCapsidAdmin(user)]
    }
  }

  def create = {
    isCapsidAdmin()
    [userInstance: new User(params)]
  }

  def save = {
    isCapsidAdmin()
    userService.save params

    render 'created'
  }

  def edit = {
    User user = findInstance()
    authorize(user)
    [userInstance: user, admin: authService.isCapsidAdmin(user)]
  }

  def update = {
    User user = findInstance()
    authorize(user)
    userService.update user, params

    flash.message = "${message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), user.username])}"
    redirect action:'editi', id:user.username
  }

  def delete = {
    User user = findInstance()
    isCapsidAdmin()

    try {
      userService.delete user
      flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
      redirect action: 'list'
    } catch (DataIntegrityViolationException e) {
      redirectShow "User $user.username could not be deleted", user.username
    }
  }

  def changePassword = {
    User user = findInstance()
    authorize(user)

    if (userService.changePassword(user, params)) {
      if (!renderWithErrors('edit', user)) {
        redirectShow "${message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), user.username])}", user.username
      }
    } else {
      flash.message = 'Incorrect password'
      redirect(action: 'edit', id: user.username)
    }
  }

  def unassigned = {
    Role role = Role.findByAuthority('ROLE_' + params.id.toUpperCase())

    Set users = UserRole.findAll().user.username.minus(UserRole.findAllByRole(role).user.username).collect {
      [
        username: it
      ]
    }

    def ret = [
      'identifier': 'username'
      ,   'label': 'username'
      ,   'items': users
    ]

    render ret as JSON
  }

  def promote = {
    Role role = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
    List<User> users = []
    params.users.split(',').each {
      User user = User.findByUsername(it)
      if (user) {
        users.push(user)
        UserRole.create user, role, params.level
      }
    }
    render template:'/layouts/userbox', model: [users:users, projectInstance: Project.findByLabel(params.id)]
  }

  def demote = {
    Role role = Role.findByAuthority('ROLE_' + params.pid.toUpperCase())
    User user = User.findByUsername(params.id)
    UserRole.remove user, role
    render 'removed user access level'
  }

  private User findInstance() {
    User userInstance = userService.get(params.id)
    authorize(userInstance)
    if (!userInstance) {
      flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
      redirect action: 'list'
    }
    userInstance
  }

  private void redirectShow(message, id) {
    flash.message = message
    redirect action: 'show', id: id
  }

  private boolean renderWithErrors(String view, User userInstance) {
    if (userInstance.hasErrors()) {
      render view: 'view', model: [userInstance: userInstance]
      return true
    }
    false
  }

  private boolean authorize(User user) {
    if (!authService.authorize(user)) {
      render view: '../login/denied'
    }
  }

  private boolean isCapsidAdmin() {
    if (!authService.isCapsidAdmin()) {
      render view: '../login/denied'
    }
  }
}
