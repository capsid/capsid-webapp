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
class AlignmentController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    def authService
    def alignmentService

    def index() { redirect action: 'list', params: params }

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

    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageMax"
        params.order = params.order ?: "desc"
        params.label = params.id

        Alignment alignmentInstance = findInstance()
        
        List results = statsService.list params 

        if (params._pjax) {
            params.remove('_pjax')
            return [alignmentInstance: alignmentInstance, statisticsInstanceList: results, statisticsInstanceTotal: results.totalCount, layout:'ajax']
        }

        withFormat {
            html alignmentInstance: alignmentInstance, statisticsInstanceList: results, statisticsInstanceTotal: results.totalCount
            json { render results as JSON }
        }
    }

    def create() { [alignmentInstance: new Alignment(params)] }

	def save() {
	    Alignment alignmentInstance = new Alignment(params)
		
		if (!alignmentInstance.save(flush: true)) {
			render view: 'create', model: [alignmentInstance: alignmentInstance]
			return
		}
		
		flash.message = message(code: 'default.created.message', args: [message(code: 'alignment.label', default: 'Alignment'), alignmentInstance.name])
        redirect action: 'show', id: alignmentInstance.label
    }

    def edit() {
        Alignment alignmentInstance = findInstance()
        [alignmentInstance: alignmentInstance]
	}

    def update() {
        Alignment alignmentInstance = findInstance()

        checkVersion(alignmentInstance, params)
        
        alignmentInstance.properties = params

        if (!alignmentInstance.save(flush: true)) {
            render view: 'edit', model: [alignmentInstance: alignmentInstance]
            return
        }

		flash.message = message(code: 'default.updated.message', args: [message(code: 'alignment.label', default: 'Alignment'), alignmentInstance.name])
        redirect action: 'show', id: alignmentInstance.label
	}

    def delete() {
        Alignment alignmentInstance = findInstance()

        try {
            alignmentInstance.delete(flush: true)
			flash.message = message(code: 'default.deleted.message', args: [message(code: 'alignment.label', default: 'Alignment'), params.id])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
			flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'alignment.label', default: 'Alignment'), params.id])
            redirect action: 'show', id: params.id
        }
    }

	private Alignment findInstance() {
		Alignment alignmentInstance = alignmentService.get(params.id)
		authorize(alignmentInstance, ['user', 'collaborator', 'owner'])
		if (!alignmentInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'alignment.label', default: 'Alignment'), params.id])
		  redirect action: 'list'
		}
		alignmentInstance
	}

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}

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
