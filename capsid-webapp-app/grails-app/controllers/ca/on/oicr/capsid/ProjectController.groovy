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
import grails.plugin.springsecurity.annotation.Secured

/**
 * Controller class for the project controller.
 */
@Secured(['ROLE_CAPSID'])
class ProjectController {

    /**
     * The allowed methods.
     */
    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    /**
     * Navigation and menu data.
     */
	static navigation = [
		group:'project',
		order:10,
		title:'Projects',
		action:'list'
	]

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the ProjectService.
     */
    def projectService

    /**
     * Dependency injection for the SampleService.
     */
    def sampleService

    /**
     * Dependency injection for the StatsService.
     */
    def statsService

    /**
     * Dependency injection for the UserService.
     */
    def userService

    /**
     * The index action. Redirects to the list action.
     */
    def index() { redirect action: 'list', params: params }

    /**
     * The list action.
     */
    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List projects = projectService.list params

        projects.each {
          it['sampleCount'] = Sample.countByProjectId(it.id)
        }

		[projects: projects]
    }

    /**
     * The show action.
     */
    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageAvg"
        params.order = params.order ?: "desc"
        params.sample = "none"
        params.offset = params.offset ?: 0

        // We might also specify a root taxon identifier. This will default to
        // a root identifier of one. We can inject this into the request if we
        // like to filter.
        Integer taxonRootId = (params.taxonRootId ?: "1").toInteger();

        Project projectInstance = findInstance()

        List statistics = statsService.list(taxonRootId: taxonRootId, ownerId: projectInstance.id, filters: params.filters, text: params.text, sort: params.sort, order: params.order, offset: params.offset)
        List samples = sampleService.list(projectId: projectInstance.id, filters: params.filters, text: params.text, sort: params.sort, order: params.order, offset: params.offset)

        [projectInstance: projectInstance, statistics: statistics, samples: samples]
    }

    /**
     * The create action.
     */
    def create() {
        isCapsidAdmin()
        [projectInstance: new Project(params)]
    }

    /**
     * The save action.
     */
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

    /**
     * The edit action.
     */
    def edit() {
        Project projectInstance = findInstance()

        List userRoles = UserRole.findAllByRole(Role.findByAuthority('ROLE_' + projectInstance.label.toUpperCase()))
        Set unassignedUsers = userService.unassigned params

        [projectInstance: projectInstance, userRoles: userRoles, unassignedUsers: unassignedUsers as JSON]
	}

    /**
     * The update action.
     */
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

    /**
     * The delete action.
     */
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

    /**
     * The export action.
     */
    def export() {
        Project projectInstance = findInstance()
        Integer taxonRootId = 1
        List statistics = statsService.list(taxonRootId: taxonRootId, ownerId: projectInstance.id, filters: params.filters, text: "", sort: "geneCoverageAvg", order: "desc", offset: 0)

        response.setHeader("Pragma", "public")
        response.setHeader("Expires", "0")
        response.setHeader("Cache-Control", "must-revalidate, post-check=0, pre-check=0")
        response.addHeader("Cache-Control", "private")
        response.setHeader("Content-Disposition", "attachment; filename=file.tsv")
        response.setContentType("application/octet-stream")
        [projectInstance: projectInstance, statistics: statistics]
    }

    /**
     * Finds a project instance using the specified identifier in the form parameters.
     */
	private Project findInstance() {
		Project projectInstance = projectService.get(params.id)
		//authorize(projectInstance, ['user', 'collaborator', 'owner'])
		if (!projectInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])
		  redirect action: 'list'
		}
		projectInstance
	}

    /**
     * Checks authorization and redirects to the login denied page if not.
     */
	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}

    /**
     * Checks the stored object version for optimistic locking control.
     *
     * @param alignmentInstance the alignment.
     * @param params the received new form values.
     */
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

    /**
     * Checks if an administrator and redirects to the login denied page if not.
     */
	private boolean isCapsidAdmin() {
		if (!authService.isCapsidAdmin()) {
		  render view: '../login/denied'
		}
	}
}
