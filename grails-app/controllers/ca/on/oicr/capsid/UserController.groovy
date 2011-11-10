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

import org.codehaus.groovy.grails.commons.ConfigurationHolder as CH
import grails.plugins.springsecurity.Secured
import grails.converters.JSON
import org.bson.types.ObjectId
import org.springframework.dao.DataIntegrityViolationException

import java.util.Random

@Secured(['ROLE_CAPSID'])
class UserController {

       def authService
       def userService

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
       /*
       def save = {
          if (!User.findByUsername(params.username)) {
               User userInstance = new User(
                username: params.username,
                userRealName: '',
                email: params.email,
                enabled: true)

              String password = getRandomString(8)
              userInstance.password = springSecurityService.encodePassword(password)

              if (userInstance.save(flush: true)) {
                  Role roleInstance = Role.findByAuthority('ROLE_CAPSID')
                  if (!userInstance.authorities.id.contains(roleInstance.id)) {
                      UserRole.create userInstance, roleInstance
                  }

                  sendMail {
                      to userInstance.email
                      subject "[capsid] CaPSID User Created"
                      body 'New user created for CaPSID.\n\nUsername:\t' + userInstance.username + '\nPassword:\t' + password + '\n\n CaPSID - ' + CH.config.grails.serverURL + '\nPlease do not respond to this email'
                    }

                  flash.message = "The user was created"
                  redirect action: 'show', id: userInstance.username
              } else {
                  render 'Error while trying to save'
              }
          } else {
          render 'Username taken'
          }
       }
       */

       def changePassword = {
           User userInstance = User.findByUsername(params.username)

           if (springSecurityService.isLoggedIn() &&
                 springSecurityService.principal.username == userInstance.username ||
                 'ROLE_CAPSID_ADMIN' in springSecurityService.principal.authorities.authority) {

                   if (springSecurityService.encodePassword(params.oldPassword) == userInstance.password) {
                       params.password = springSecurityService.encodePassword(params.newPassword)
                       userInstance.properties = params
                       if (userInstance.save(flush: true)) {
                           if (springSecurityService.isLoggedIn() &&
                               springSecurityService.principal.username == userInstance.username) {
                                   springSecurityService.reauthenticate userInstance.username
                           }

                          flash.message = "The user was updated"
                          redirect action: 'show', id: userInstance.username
                       }
                   } else {
                    flash.message = "Error while updating"
                  redirect action: 'show', id: userInstance.username
                   return
               }
           }
       }

       @Secured(['ROLE_CAPSID_ADMIN'])
       def resetPassword = {
           User userInstance = User.findByUsername(params.username)

           params.password = springSecurityService.encodePassword(params.newPassword)
           userInstance.properties = params
           if (userInstance.save(flush: true)) {
               if (springSecurityService.isLoggedIn() &&
                   springSecurityService.principal.username == userInstance.username) {
                       springSecurityService.reauthenticate userInstance.username
               }

              flash.message = "The user was updated"
              redirect action: 'show', id: userInstance.username

           } else {
            flash.message = "Error while updating"
            redirect action: 'show', id: userInstance.username
            return
           }
       }

    def show = {
        User user = findInstance()
        [userInstance: user, admin: authService.isCapsidAdmin(user)]
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
        [userInstance: user, admin: authService.isCapsidAdmin(user)]
    }

    def update = {
        User user = findInstance()
        userService.update user, params

        if (!renderWithErrors('edit', user)) {
            redirectShow "${message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), user.username])}", user.username
        }
    }

    def delete = {
        User user = findInstance()
        isCapsidAdmin()

        try {
            userService.delete user
            flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])}"
            redirect action: list
        } catch (DataIntegrityViolationException e) {
            redirectShow "User $user.username could not be deleted", user.username
        }
    }

       def getRandomString(length) {
           String charset = "!0123456789abcdefghijklmnopqrstuvwxyz";
           Random rand = new Random(System.currentTimeMillis());
           StringBuffer sb = new StringBuffer();
           for (int i = 0; i < length; i++) {
               int pos = rand.nextInt(charset.length());
               sb.append(charset.charAt(pos));
           }
           return sb.toString();
       }

       def unassigned = {
            Role role = Role.findByAuthority('ROLE_' + params.id.toUpperCase())

            List users = UserRole.findAll().user.username.minus(UserRole.findAllByRole(role).user.username).collect {
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
            redirect action: list
        }
        userInstance
    }

    private void redirectShow(message, id) {
        flash.message = message
        redirect action: show, id: id
    }

    private boolean renderWithErrors(String view, User userInstance) {
        if (userInstance.hasErrors()) {
            render view: view, model: [userInstance: userInstance]
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
