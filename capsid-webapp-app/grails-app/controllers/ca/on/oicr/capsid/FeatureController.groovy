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
 * Controller class for the feature controller. 
 */
@Secured(['ROLE_CAPSID'])
class FeatureController {

    /**
     * The allowed methods.
     */
    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    /**
     * Navigation and menu data.
     */
    static navigation = [
            group:'genome', 
            order:20, 
            title:'Genes', 
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
     * Dependency injection for the FeatureService.
     */
    def featureService

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
        List results = featureService.list params
        
        [featureInstanceList: results, featureInstanceTotal: results.totalCount]
    }

    /**
     * The show action. 
     */
    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)

        Feature featureInstance = findInstance()

        Project projectInstance = projectService.get(params.projectLabel)
        assert projectInstance != null

        [
            featureInstance: featureInstance, 
            projectInstance: projectInstance
        ]
    }

    /**
     * Finds a feature instance using the specified identifier in the form parameters. 
     */
	private Feature findInstance() {
		Feature featureInstance = featureService.get(params.id)

		if (!featureInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'feature.label', default: 'Feature'), params.id])
		  redirect action: 'list'
		}
		featureInstance
	}
}
