/*
*    Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
*
*    This program and the accompanying materials are made available under the
*    terms of the GNU Public License v3.0.
*
*    You should have received a copy of the GNU General Public License along with
*    this program.  If not, see <http://www.gnu.org/licenses/>.
*/

<%=packageName ? "package ${packageName}\n\n" : ''%>import org.springframework.dao.DataIntegrityViolationException
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class ${className}Controller {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    def authService
    def ${domainClass.propertyName}Service

    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List results = ${domainClass.propertyName}Service.list(params)
        
        withFormat {
            html ${propertyName}List: results, ${propertyName}Total: results.totalCount
            json { render results as JSON  }
        }
    }

    def show() {
        ${className} ${propertyName} = findInstance()
        [${propertyName}: ${propertyName}]
    }

    def create() { [${propertyName}: new ${className}(params)] }

	def save() {
	    ${className} ${propertyName} = ${domainClass.propertyName}Service.save params

		flash.message = message(code: 'default.created.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ${propertyName}.name])
        redirect action: 'show', id: ${propertyName}.label
    }

    def edit() {
        ${className} ${propertyName} = findInstance()
        [${propertyName}: ${propertyName}]
	}

    def update() {
        ${className} ${propertyName} = findInstance()

        checkVersion(${propertyName}, params)
        
        ${propertyName}.properties = params

        if (!${propertyName}.save(flush: true)) {
            render view: 'edit', model: [${propertyName}: ${propertyName}]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ${propertyName}.name])
        redirect action: 'show', id: ${propertyName}.label
	}

    def delete() {
        ${className} ${propertyName} = findInstance()

        try {
            ${propertyName}.delete(flush: true)
			flash.message = message(code: 'default.deleted.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), params.id])
            redirect action: 'show', id: params.id
        }
    }

	private ${className} findInstance() {
		${className} ${propertyName} = ${domainClass.propertyName}Service.get(params.id)
		authorize(${propertyName}, ['user', 'collaborator', 'owner'])
		if (!${propertyName}) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), params.id])
		  redirect action: 'list'
		}
		${propertyName}
	}

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}

    private void checkVersion(${className} ${propertyName}, def params) {
        if (params.version) {
            Long version = params.version.toLong()
            if (${propertyName}.version > version) {<% def lowerCaseName = grails.util.GrailsNameUtils.getPropertyName(className) %>
                ${propertyName}.errors.rejectValue('version', 'default.optimistic.locking.failure',
                          [message(code: '${domainClass.propertyName}.label', default: '${className}')] as Object[],
                          "Another user has updated this ${className} while you were editing")
                render view: 'edit', model: [${propertyName}: ${propertyName}]
                return
            }
        }
    } 
}
