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
class FeatureController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']
    static navigation = [
            group:'genome', 
            order:20, 
            title:'Genes', 
            action:'list'
        ]

    def authService
    def featureService
    def statsService

    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        List results = featureService.list params
        
        if (params._pjax) {
            params.remove('_pjax')
            return [featureInstanceList: results, featureInstanceTotal: results.totalCount, layout:'ajax']
        }        
        
        withFormat {
            html featureInstanceList: results, featureInstanceTotal: results.totalCount
            json { render results as JSON  }
        }
    }

    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)

        Feature featureInstance = findInstance()

        withFormat {
            html featureInstance: featureInstance
        }
    }

	private Feature findInstance() {
		Feature featureInstance = featureService.get(params.id)

		if (!featureInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'feature.label', default: 'Feature'), params.id])
		  redirect action: 'list'
		}
		featureInstance
	}
}
