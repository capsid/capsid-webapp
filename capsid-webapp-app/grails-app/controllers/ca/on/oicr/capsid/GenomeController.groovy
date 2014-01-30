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
 * Controller class for the genome controller. 
 */
@Secured(['ROLE_CAPSID'])
class GenomeController {

    /**
     * Navigation and menu data.
     */
    static navigation = [
        group:'genome', 
        order:10, 
        title:'Genomes', 
        action:'list'
    ]

    /**
     * Dependency injection for the GenomeService.
     */
    def genomeService

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
        params.sort = params.sort ?: "sampleCount"
        params.order = params.order ?: "desc"

        List genomes = genomeService.list params
    
        [genomes: genomes]
    }

    /**
     * The show action.
     */
    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageAvg"
        params.order = params.order ?: "desc"
        params.accession = params.id

        Genome genomeInstance = findInstance()

        Project projectInstance = projectService.get(params.projectLabel)
        assert projectInstance != null

        List pStatistics = statsService.list(ownerId: projectInstance.id, gi: genomeInstance.gi, text: params.text, max: params.max, sort: params.sort, order: params.order, offset: params.offset) 
        List sStatistics = statsService.list(projectId: projectInstance.id, gi: genomeInstance.gi, ownerType: "sample", text: params.text, max: params.max, sort: params.sort, order: params.order, offset: params.offset) 

        params.genome = genomeInstance.gi
        List features = featureService.list params

        // These appear to be pointless - SNW
        params.remove('sample')
        params.remove('genome')

        [
            genomeInstance: genomeInstance, 
            projectInstance: projectInstance,
            pStatistics: pStatistics, 
            sStatistics: sStatistics,
            features: features
        ]
    }

    /**
     * Finds a genome instance using the specified identifier in the form parameters. 
     */
	private Genome findInstance() {
		Genome genomeInstance = genomeService.get(params.id)
		if (!genomeInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'genome.label', default: 'Genome'), params.id])
		  redirect action: 'list'
		}
		genomeInstance
	}
}
