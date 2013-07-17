/*
*    Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
*
*    This program and the accompanying materials are made available under the
*    terms of the GNU Public License v3.0.
*
*    You should have received a copy of the GNU General Public License along with
*    this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import org.springframework.dao.DataIntegrityViolationException
import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.codehaus.groovy.grails.commons.ConfigurationHolder as CH
import org.bson.types.ObjectId

@Secured(['ROLE_CAPSID'])
class UserController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    def authService
    def userService
	def springSecurityService

    def index() { redirect action: 'list', params: params }

    def list() {
        isCapsidAdmin()
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List results = userService.list params
        
        if (params._pjax) {
            params.remove('_pjax')
            return [userInstanceList: results, userInstanceTotal: results.totalCount, layout:'ajax']
        }        
        
        withFormat {
            html userInstanceList: results, userInstanceTotal: results.totalCount
            json { render results as JSON  }
        }
    }

    def show() {
        User userInstance = findInstance()
        isCurrentUser(userInstance)
        
		withFormat {
			html userInstance: userInstance
			json { render userInstance as JSON }
        }
    }

    def create() {
        isCapsidAdmin()
        [userInstance: new User(params)] 
    }

	def save() {
        isCapsidAdmin()

        // Generate password
        String password = authService.getRandomString(8)
        
		params.password = springSecurityService.encodePassword(password)
        params.enabled = true

	    User userInstance = new User(params)
		
		if (!userInstance.save(flush: true)) {
			render view: 'create', model: [userInstance: userInstance]
			return
		}

        // Give capsid:user role:access
        Role roleInstance = Role.findByAuthority('ROLE_CAPSID')

        if (params.is_admin.toBoolean()) {
          UserRole.create userInstance, roleInstance, 'owner'
        } else {
          UserRole.create userInstance, roleInstance, 'user'
        }

        if (!params.is_ldap.toBoolean()) {
            sendMail {
                to userInstance.email
                subject "[capsid] CaPSID User Created"
                body 'New user created for CaPSID.\n\nUsername:\t' + userInstance.username + '\nPassword:\t' + password + '\n\nCaPSID - ' + CH.config.grails.serverURL + '\nPlease do not respond to this email'
            }
        }
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'user.label', default: 'User'), userInstance.username])
        redirect action: 'list'
    }

    def edit() {
        User userInstance = findInstance()
        [userInstance: userInstance, admin: authService.isCapsidAdmin(userInstance)]
	}

    def update() {
        User userInstance = findInstance()

        checkVersion(userInstance, params)
        
        userInstance.properties = params

        if (!userInstance.save(flush: true)) {
            render view: 'edit', model: [userInstance: userInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), userInstance.username])
        redirect action: 'show', id: userInstance.username
	}

    def update_status() {
        User userInstance = findInstance()

        checkVersion(userInstance, params)
        
        userInstance.properties = params

        if (!userInstance.save(flush: true)) {
            render view: 'edit', model: [userInstance: userInstance]
            return
        }
        
        Role roleInstance = Role.findByAuthority('ROLE_CAPSID')
        
        UserRole.remove userInstance, roleInstance
        UserRole instance = UserRole.findByUserAndRole(userInstance, roleInstance)
        
        if (params.is_admin.toBoolean()) {
          UserRole.create userInstance, roleInstance, 'owner'
        } else {
          UserRole.create userInstance, roleInstance, 'user'
        }

        flash.message = message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), userInstance.username])
        redirect action: 'list'
    }

    def add_bookmark() {
        User userInstance = findInstance()
		Map bookmark = [title: params.title, address: params.address, _id: new ObjectId()]
		
        if (!userInstance.bookmarks) {
            userInstance.bookmarks = []   
        }
        userInstance.bookmarks.push(bookmark)

        userInstance.save(flush: true)

        render bookmark as JSON
    }

    def remove_bookmark() {
        User userInstance = findInstance()
        
        userInstance.bookmarks.removeAll {it._id == new ObjectId(params._id)}
        userInstance.save(flush: true)
        
        render userInstance.bookmarks as JSON
    }

    def delete() {
        User userInstance = findInstance()

        try {
            userInstance.delete(flush: true)
			UserRole.removeAll userInstance
			
			flash.message = message(code: 'default.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'user.label', default: 'User'), params.id])
            redirect action: 'show', id: params.id
        }
    }

    def unassigned() {
        Set users = userService.unassigned params
        render users as JSON
    }

    def promote() {
        Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
        User userInstance = User.findByUsername(params.username)
        UserRole.remove userInstance, roleInstance
        UserRole.create userInstance, roleInstance, params.access

        render template:"/project/user", model:[username:params.username, label:params.id]
    }

    def demote() {
        Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
        User userInstance = User.findByUsername(params.username)
        UserRole.remove userInstance, roleInstance

        render userInstance as JSON
    }

	private User findInstance() {
		User userInstance = userService.get(params.id)
		authorize(userInstance)
		if (!userInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])
		  redirect action: 'list'
		}
		userInstance
	}

	private void authorize(def auth) {
		if (!authService.authorize(auth)) {
		  render view: '../login/denied'
		}
	}

    private void checkVersion(User userInstance, def params) {
        if (params.version) {
            Long version = params.version.toLong()
            if (userInstance.version > version) {
                userInstance.errors.rejectValue('version', 'default.optimistic.locking.failure',
                          [message(code: 'user.label', default: 'User')] as Object[],
                          "Another user has updated this User while you were editing")
                render view: 'edit', model: [userInstance: userInstance]
                return
            }
        }
    } 

    private void isCapsidAdmin() {
        if (!authService.isCapsidAdmin()) {
          render view: '../login/denied'
        }
    }

    private void isCurrentUser(User userInstance) {
        if (!authService.isCurrentUser(userInstance)) {
          render view: '../login/denied'
        }
    }


}
