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

/**
 * Controller class for the sample controller. 
 */
@Secured(['ROLE_CAPSID'])
class SampleController {

    /**
     * The allowed methods.
     */
    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    /**
     * Navigation and menu data.
     */
	static navigation = [
        group:'sample', 
        order:10, 
        title:'Samples', 
        action:'list'
    ]

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the SampleService.
     */
    def sampleService

    /**
     * Dependency injection for the AlignmentService.
     */
    def alignmentService

    /**
     * Dependency injection for the StatsService.
     */
    def statsService

    /**
     * The index action. Redirects to the list action. 
     */
    def index() { redirect action: 'list', params: params }

    /**
     * The list action. 
     */
    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)

        List samples = sampleService.list params
        
        [samples: samples]
    }

    /**
     * The show action. 
     */
    def show() {

        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageAvg"
        params.order = params.order ?: "desc"
        params.offset = params.offset ?: 0

        // We might also specify a root taxon identifier. This will default to 
        // a root identifier of one. We can inject this into the request if we
        // like to filter. 
        Integer taxonRootId = (params.taxonRootId ?: "1").toInteger();

        Map model = findModel()
        Project projectInstance = model['projectInstance']
        assert projectInstance != null
        Sample sampleInstance = model['sampleInstance']
        assert sampleInstance != null

        model['statistics'] = statsService.list(taxonRootId: taxonRootId, ownerId: sampleInstance.id, filters: params.filters, text: params.text, offset: params.offset, max: params.max, sort: params.sort, order: params.order)
        model['alignments'] = alignmentService.list(projectId: projectInstance.id, sampleId: sampleInstance.id, text: params.text, offset: params.offset, max: params.max, sort: params.sort, order: params.order)

        model
    }

    /**
     * The create action. 
     */
    def create() { 
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])
        [sampleInstance: new Sample(params)] 
    }

    /**
     * The save action. 
     */
	def save() {
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])	
        Sample sampleInstance = new Sample(params)
		
		if (!sampleInstance.save(flush: true)) {
			render view: 'create', model: [sampleInstance: sampleInstance]
			return
		}
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'sample.label', default: 'Sample'), sampleInstance.name])
        redirect action: 'show', id: sampleInstance.name
    }

    /**
     * The edit action. 
     */
    def edit() {
        findModel()
	}

    /**
     * The update action. 
     */
    def update() {
        Map model = findModel(['collaborator', 'owner'])
        Sample sampleInstance = model['sampleInstance']

        checkVersion(sampleInstance, params)
        
        sampleInstance.properties = params

        if (!sampleInstance.save(flush: true)) {
            render view: 'edit', model: [sampleInstance: sampleInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'sample.label', default: 'Sample'), sampleInstance.name])
        redirect action: 'show', id: sampleInstance.name
	}

    /**
     * The delete action. 
     */
    def delete() {
        Map model = findModel(['collaborator', 'owner'])
        Sample sampleInstance = model['sampleInstance']

        try {
            sampleInstance.delete(flush: true)
            sampleService.delete sampleInstance.name

			flash.message = message(code: 'default.deleted.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])
            redirect controller: 'project', action: 'show', id: sampleInstance.project
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])
            redirect action: 'show', id: params.id
        }
    }

    /**
     * Builds a basic model comprising the alignment, sample, and project in a basic map
     * that can be extended after return. 
     * 
     * @return Map containing the model.
     */
	private Map findModel(List roles = ['user', 'collaborator', 'owner']) {

        Project projectInstance = Project.findByLabel(params.projectLabel)
        authorize(projectInstance, roles)

		Sample sampleInstance = sampleService.get(params.id, projectInstance.id)
		if (!sampleInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])
		  redirect action: 'list'
          [:]
		} else {
  		  [sampleInstance: sampleInstance, projectInstance: projectInstance]
        }
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
    private void checkVersion(Sample sampleInstance, def params) {
        if (params.version) {
            Long version = params.version.toLong()
            if (sampleInstance.version > version) {
                sampleInstance.errors.rejectValue('version', 'default.optimistic.locking.failure',
                          [message(code: 'sample.label', default: 'Sample')] as Object[],
                          "Another user has updated this Sample while you were editing")
                render view: 'edit', model: [sampleInstance: sampleInstance]
                return
            }
        }
    } 
}
