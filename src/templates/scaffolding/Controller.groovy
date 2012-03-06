<%=packageName ? "package ${packageName}\n\n" : ''%>import org.springframework.dao.DataIntegrityViolationException

class ${className}Controller {

    static allowedMethods = [create: 'POST', edit: 'POST', delete: 'POST']

    def authService
    def ${domainClass.propertyName}Service

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [${propertyName}List: ${className}.list(params), ${propertyName}Total: ${className}.count()]
    }

    def show() {
        ${className} ${propertyName} = findInstance()
        [${propertyName}: ${propertyName}]
    }

    def create() {
		[${propertyName}: new ${className}(params)]
	}

	def save() {
	    ${className} ${propertyName} = new ${className}(params)
        if (!${propertyName}.save(flush: true)) {
            render view: 'create', model: [${propertyName}: ${propertyName}]
            return
        }

		flash.message = message(code: 'default.created.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ${propertyName}.id])
        redirect action: 'show', id: ${propertyName}.name
    }

    def edit() {
        ${className} ${propertyName} = findInstance()
        [${propertyName}: ${propertyName}]
	}

    def update() {
        ${className} ${propertyName} = findInstance()

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

        ${propertyName}.properties = params

        if (!${propertyName}.save(flush: true)) {
            render view: 'edit', model: [${propertyName}: ${propertyName}]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: '${domainClass.propertyName}.label', default: '${className}'), ${propertyName}.id])
        redirect action: 'show', id: ${propertyName}.name
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

	private boolean authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}

	private boolean isCapsidAdmin() {
		if (!authService.isCapsidAdmin()) {
		  render view: '../login/denied'
		}
	}

}
