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
    def sampleService
    def statsService
    def userService
	
    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List projects = projectService.list params
		
        projects.each {
          it['sampleCount'] = Sample.countByProject(it.label)
        }

		[projects: projects]
    }

    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageMax"
        params.order = params.order ?: "desc"
        params.sample = "none"

        Project projectInstance = findInstance()
        
        params.label = params.id
        List statistics = statsService.list params 
        params.project = params.id
        List samples = sampleService.list params 
        params.remove('label')
        params.remove('project')
        
        [projectInstance: projectInstance, statistics: statistics, samples: samples]
    }

    def create() { 
        isCapsidAdmin()
        [projectInstance: new Project(params)] 
    }

	def save() {
        isCapsidAdmin()
	    Project projectInstance = new Project(params)
		
        String projectRole = 'ROLE_' + projectInstance.label.toUpperCase()
        List roles = [projectRole]

        if (!params.is_private.toBoolean()) { roles.push("ROLE_CAPSID") }
        projectInstance.roles = roles
    
        // Role saved first because a project with no role is worse than a role with no project
        Role role = Role.findByAuthority(projectRole) ?: new Role(authority: projectRole).save(failOnError: true)

        if (!projectInstance.save(flush: true)) {
            render view: 'create', model: [projectInstance: projectInstance]
            return
        }

        User user = authService.getCurrentUser()    

        /* 
        *  If this step fails it doesn't matter that much since only Admins can create projects
        *  and Admins can already access any project. The user would be able to get in and add permission
        *  and probably wouldn't even notice. The owner role is more for adding non-Admins to the project
        */
        UserRole.create user, role, 'owner'
        
		flash.message = message(code: 'default.created.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.name])
        redirect action: 'show', id: projectInstance.label 
    }

    def edit() {
        Project projectInstance = findInstance()
        
        List userRoles = UserRole.findAllByRole(Role.findByAuthority('ROLE_' + projectInstance.label.toUpperCase()))
        Set unassignedUsers = userService.unassigned params

        [projectInstance: projectInstance, userRoles: userRoles, unassignedUsers: unassignedUsers as JSON]
	}

    def update() {
        Project projectInstance = findInstance()

        checkVersion(projectInstance, params)
        
        projectInstance.properties = params

        if (params.is_private.toBoolean()) {
            projectInstance.roles = ['ROLE_' + params.label.toUpperCase()]
        } else {
            projectInstance.roles = ['ROLE_CAPSID', 'ROLE_' + params.label.toUpperCase()]
        }

        if (!projectInstance.save(flush: true)) {
            render view: 'edit', model: [projectInstance: projectInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.name])
        redirect action: 'show', id: projectInstance.label
	}

    def delete() {
        Project projectInstance = findInstance()

        try {
            projectInstance.delete(flush: true)
            projectService.delete projectInstance.label
            
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