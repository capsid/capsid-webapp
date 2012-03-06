package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class ProjectController {

	static scaffold = true
	static navigation = [
		group:'project', 
		order:10, 
		title:'Project', 
		action:'list'
	]

	def update() {
        Project projectInstance = findInstance()

        checkVersion(projectInstance, params)
        
        projectInstance.properties = params

        if (!projectInstance.save(flush: true)) {
            render view: 'edit', model: [projectInstance: projectInstance]
            return
        }

        println 'in project controller'

		flash.message = message(code: 'default.updated.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.label])
        redirect action: 'show', id: projectInstance.label
	}
}
