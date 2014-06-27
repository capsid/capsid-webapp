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
import grails.plugin.springsecurity.annotation.Secured
import org.bson.types.ObjectId

/**
 * Controller class for the user controller.
 */
@Secured(['ROLE_CAPSID'])
class UserController {

    /**
     * The allowed methods.
     */
    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    /**
     * Dependency injection for the GrailsApplication.
     */
    def grailsApplication

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the UserService.
     */
    def userService

    /**
     * Dependency injection for the SpringSecurityService.
     */
	def springSecurityService

    /**
     * The index action. Redirects to the list action. 
     */
    def index() { redirect action: 'list', params: params }

    /**
     * The list action. 
     */
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

    /**
     * The show action. 
     */
    def show() {
        User userInstance = findInstance()
        isCurrentUser(userInstance)
        
		withFormat {
			html userInstance: userInstance
			json { render userInstance as JSON }
        }
    }

    /**
     * The create action. 
     */
    def create() {
        isCapsidAdmin()
        [userInstance: new User(params)] 
    }

    /**
     * The save action. 
     */
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

        if (!params.is_ldap.toBoolean() && userInstance.email) {
            sendMail {
                to userInstance.email
                subject "[capsid] CaPSID User Created"
                body 'New user created for CaPSID.\n\nUsername:\t' + userInstance.username + '\nPassword:\t' + password + '\n\nCaPSID - ' + grailsApplication.config.grails.serverURL + '\nPlease do not respond to this email'
            }
        }
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'user.label', default: 'User'), userInstance.username])
        redirect action: 'list'
    }

    /**
     * The edit action. 
     */
    def edit() {
        User userInstance = findInstance()
        [userInstance: userInstance, admin: authService.isCapsidAdmin(userInstance)]
	}

    /**
     * The update action. 
     */
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

    /**
     * The update_status action. 
     */
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

    /**
     * The add_bookmark action. 
     */
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

    /**
     * The remove_bookmark action. 
     */
    def remove_bookmark() {
        User userInstance = findInstance()
        
        userInstance.bookmarks.removeAll {it._id == new ObjectId(params._id)}
        userInstance.save(flush: true)
        
        render userInstance.bookmarks as JSON
    }

    /**
     * The delete action. 
     */
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

    /**
     * The unassigned action. 
     */
    def unassigned() {
        Set users = userService.unassigned params
        render users as JSON
    }

    /**
     * The promote action. 
     */
    def promote() {
        Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
        User userInstance = User.findByUsername(params.username)
        UserRole.remove userInstance, roleInstance
        UserRole.create userInstance, roleInstance, params.access

        render template:"/project/user", model:[username:params.username, label:params.id]
    }

    /**
     * The demote action. 
     */
    def demote() {
        Role roleInstance = Role.findByAuthority('ROLE_' + params.id.toUpperCase())
        User userInstance = User.findByUsername(params.username)
        UserRole.remove userInstance, roleInstance

        render userInstance as JSON
    }

    /**
     * Finds a user instance using the specified identifier in the form parameters. 
     */
	private User findInstance() {
		User userInstance = userService.get(params.id)
		authorize(userInstance)
		if (!userInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])
		  redirect action: 'list'
		}
		userInstance
	}

    /**
     * Checks authorization and redirects to the login denied page if not.
     */
	private void authorize(def auth) {
		if (!authService.authorize(auth)) {
		  render view: '../login/denied'
		}
	}

    /**
     * Checks the stored object version for optimistic locking control.
     * 
     * @param alignmentInstance the alignment. 
     * @param params the received new form values.
     */
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

    /**
     * Checks if adminstrator and redirects to the login denied page if not.
     */
    private void isCapsidAdmin() {
        if (!authService.isCapsidAdmin()) {
          render view: '../login/denied'
        }
    }

    /**
     * Checks if the current user and redirects to the login denied page if not.
     */
    private void isCurrentUser(User userInstance) {
        if (!authService.isCurrentUser(userInstance)) {
          render view: '../login/denied'
        }
    }
}
