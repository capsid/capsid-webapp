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

import grails.converters.JSON
import org.springframework.dao.DataIntegrityViolationException
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class ProjectController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']
	static navigation = [
		group:'project',
		order:10,
		title:'Projects',
		action:'list'
	]
	
    def authService
    def projectService

    def index() { redirect action: 'list', params: params }

    def list() {
        println params
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
		List results = projectService.list params
		
		withFormat {
			html projectInstanceList: results, projectInstanceTotal: results.totalCount
			json { render results as JSON  }
		}
    }

    def show() {
        Project projectInstance = findInstance()
        projectInstance['samples'] = Sample.findAllByProject(projectInstance.label)

        [projectInstance: projectInstance]
    }

    def create() { [projectInstance: new Project(params)] }

	def save() {
	    Project projectInstance = projectService.save params
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.label])
        redirect action: 'show', id: projectInstance.label
    }

    def edit() {
        Project projectInstance = findInstance()
        [projectInstance: projectInstance]
	}

    def update() {
        Project projectInstance = findInstance()

        checkVersion(projectInstance, params)
        
        projectInstance.properties = params

        if (!projectInstance.save(flush: true)) {
            render view: 'edit', model: [projectInstance: projectInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.label])
        redirect action: 'show', id: projectInstance.label
	}

    def delete() {
        Project projectInstance = findInstance()

        try {
            projectInstance.delete(flush: true)
			flash.message = message(code: 'default.deleted.message', args: [message(code: 'project.label', default: 'Project'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'project.label', default: 'Project'), params.id])
            redirect action: 'show', id: params.id
        }
    }

	private Project findInstance() {
		Project projectInstance = projectService.get(params.id)
		authorize(projectInstance, ['user', 'collaborator', 'owner'])
		if (!projectInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])
		  redirect action: 'list'
		}
		projectInstance
	}

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}

    private void checkVersion(Project projectInstance, def params) {
        if (params.version) {
            Long version = params.version.toLong()
            if (projectInstance.version > version) {
                projectInstance.errors.rejectValue('version', 'default.optimistic.locking.failure',
                          [message(code: 'project.label', default: 'Project')] as Object[],
                          "Another user has updated this Project while you were editing")
                render view: 'edit', model: [projectInstance: projectInstance]
                return
            }
        }
    } 

	private boolean isCapsidAdmin() {
		if (!authService.isCapsidAdmin()) {
		  render view: '../login/denied'
		}
	}
}
