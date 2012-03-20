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

@Secured(['ROLE_CAPSID'])
class UserController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    def authService
    def userService

    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List results = userService.list params
        
        withFormat {
            html userInstanceList: results, userInstanceTotal: results.totalCount
            json { render results as JSON  }
        }
    }

    def show() {
        User userInstance = findInstance()
        [userInstance: userInstance]
    }

    def create() { [userInstance: new User(params)] }

	def save() {
	    User userInstance = new User(params)
		
		if (!userInstance.save(flush: true)) {
			render view: 'create', model: [userInstance: userInstance]
			return
		}
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'user.label', default: 'User'), userInstance.name])
        redirect action: 'show', id: userInstance.label
    }

    def edit() {
        User userInstance = findInstance()
        [userInstance: userInstance]
	}

    def update() {
        User userInstance = findInstance()

        checkVersion(userInstance, params)
        
        userInstance.properties = params

        if (!userInstance.save(flush: true)) {
            render view: 'edit', model: [userInstance: userInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'user.label', default: 'User'), userInstance.name])
        redirect action: 'show', id: userInstance.label
	}

    def delete() {
        User userInstance = findInstance()

        try {
            userInstance.delete(flush: true)
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
		authorize(userInstance, ['user', 'collaborator', 'owner'])
		if (!userInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'user.label', default: 'User'), params.id])
		  redirect action: 'list'
		}
		userInstance
	}

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
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
}
