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

/**
 * Controller class for the alignment controller. 
 */
@Secured(['ROLE_CAPSID'])
class AlignmentController {

    /**
     * The allowed methods.
     */
    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the AlignmentService.
     */
    def alignmentService

    /**
     * Dependency injection for the StatsService.
     */
	def statsService

    /**
     * Dependency injection for the SampleService.
     */
    def sampleService

    /**
     * The index action. Redirects to the list action. 
     */
    def index() { redirect action: 'list', params: params }

    /**
     * The list action.
     */
    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List results = alignmentService.list params
        
        if (params._pjax) {
            params.remove('_pjax')
            return [alignmentInstanceList: results, alignmentInstanceTotal: results.totalCount, layout:'ajax']
        }        
        
        withFormat {
            html alignmentInstanceList: results, alignmentInstanceTotal: results.totalCount
            json { render results as JSON  }
        }
    }

    /**
     * The show action.
     */
    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageAvg"
        params.order = params.order ?: "desc"
        params.label = params.id

        // We might also specify a root taxon identifier. This will default to 
        // a root identifier of one. We can inject this into the request if we
        // like to filter. 
        Integer taxonRootId = (params.taxonRootId ?: "1").toInteger();

        Map model = findModel()

        Alignment alignmentInstance = model['alignmentInstance']
        assert alignmentInstance != null
        model['statistics'] = statsService.list(taxonRootId: taxonRootId, ownerId: alignmentInstance.id, filters: params.filters, text: params.text, offset: params.offset, max: params.max, sort: params.sort, order: params.order)
        model['forwardURI'] = request.forwardURI;

        model
    }

    /**
     * The create action.
     */
    def create() { 
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])
        [alignmentInstance: new Alignment(params)] }

    /**
     * The save action.
     */
	def save() {
	    Alignment alignmentInstance = new Alignment(params)
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])

		if (!alignmentInstance.save(flush: true)) {
			render view: 'create', model: [alignmentInstance: alignmentInstance]
			return
		}
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'alignment.label', default: 'Alignment'), alignmentInstance.name])
        redirect action: 'show', id: alignmentInstance.name
    }

    /**
     * The edit action.
     */
    def edit() {
        Alignment alignmentInstance = findInstance(['collaborator', 'owner'])
        [alignmentInstance: alignmentInstance]
	}

    /**
     * The update action.
     */
    def update() {
        Alignment alignmentInstance = findInstance(['collaborator', 'owner'])

        checkVersion(alignmentInstance, params)
        
        alignmentInstance.properties = params

        if (!alignmentInstance.save(flush: true)) {
            render view: 'edit', model: [alignmentInstance: alignmentInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'alignment.label', default: 'Alignment'), alignmentInstance.name])
        redirect action: 'show', id: alignmentInstance.name
	}

    /**
     * The delete action.
     */
    def delete() {
        Alignment alignmentInstance = findInstance(['collaborator', 'owner'])

        try {
            alignmentInstance.delete(flush: true)
			alignmentService.delete alignmentInstance.name
			
			flash.message = message(code: 'default.deleted.message', args: [message(code: 'alignment.label', default: 'Alignment'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'alignment.label', default: 'Alignment'), params.id])
            redirect action: 'show', id: params.id
        }
    }

    /**
     * The taxonomy action.
     */
    def taxonomy() {
        Map model = findModel()
        Alignment alignmentInstance = model.alignmentInstance

        String abundance = alignmentService.genomeRelativeAbundance(alignmentInstance)

        render(contentType: "application/json", text: abundance)
    }

    /**
     * Builds a basic model comprising the alignment, sample, and project in a basic map
     * that can be extended after return. 
     * 
     * @return Map containing the model.
     */
	private Map findModel(List roles = ['user', 'collaborator', 'owner']) {

        Project projectInstance = Project.findByLabel(params.projectLabel)
        //authorize(projectInstance, roles)

        Sample sampleInstance = sampleService.get(params.sampleName, projectInstance.id)
        assert sampleInstance != null

		Alignment alignmentInstance = alignmentService.get(params.id, projectInstance.id, sampleInstance.id)

		if (!alignmentInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'alignment.label', default: 'Alignment'), params.id])
		  redirect action: 'list'
		}
		[alignmentInstance: alignmentInstance, sampleInstance: sampleInstance, projectInstance: projectInstance]
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
    private void checkVersion(Alignment alignmentInstance, def params) {
        if (params.version) {
            Long version = params.version.toLong()
            if (alignmentInstance.version > version) {
                alignmentInstance.errors.rejectValue('version', 'default.optimistic.locking.failure',
                          [message(code: 'alignment.label', default: 'Alignment')] as Object[],
                          "Another user has updated this Alignment while you were editing")
                render view: 'edit', model: [alignmentInstance: alignmentInstance]
                return
            }
        }
    } 
}
