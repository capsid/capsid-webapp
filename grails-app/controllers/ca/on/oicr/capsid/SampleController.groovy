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
class SampleController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']
	
    def authService
    def sampleService
    def statsService

    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List results = sampleService.list params
        
        if (params._pjax) {
            params.remove('_pjax')
            return [sampleInstanceList: results, sampleInstanceTotal: results.totalCount, layout:'ajax']
        }

        withFormat {
            html sampleInstanceList: results, sampleInstanceTotal: results.totalCount
            json { render results as JSON  }
        }
    }

    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageMax"
        params.order = params.order ?: "desc"
        params.label = params.id
        
        Sample sampleInstance = findInstance()
        sampleInstance['alignments'] = Alignment.findAllBySample(sampleInstance.name)
        
        List results = statsService.list params 

        if (params._pjax) {
            params.remove('_pjax')
            return [sampleInstance: sampleInstance, statisticsInstanceList: results, statisticsInstanceTotal: results.totalCount, layout:'ajax']
        }

        withFormat {
            html sampleInstance: sampleInstance, statisticsInstanceList: results, statisticsInstanceTotal: results.totalCount
            json { render results as JSON }
        }
    }

    def create() { 
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])
        [sampleInstance: new Sample(params)] 
    }

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

    def edit() {
        Sample sampleInstance = findInstance()
        [sampleInstance: sampleInstance]
	}

    def update() {
        Sample sampleInstance = findInstance(['collaborator', 'owner'])

        checkVersion(sampleInstance, params)
        
        sampleInstance.properties = params

        if (!sampleInstance.save(flush: true)) {
            render view: 'edit', model: [sampleInstance: sampleInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'sample.label', default: 'Sample'), sampleInstance.name])
        redirect action: 'show', id: sampleInstance.name
	}

    def delete() {
        Sample sampleInstance = findInstance(['collaborator', 'owner'])

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

	private Sample findInstance(List roles = ['user', 'collaborator', 'owner']) {
		Sample sampleInstance = sampleService.get(params.id)
		authorize(sampleInstance, roles)
		if (!sampleInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])
		  redirect action: 'list'
		}
		sampleInstance
	}

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}

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
