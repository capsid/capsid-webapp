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
class GenomeController {

    static navigation = [
        group:'genome', 
        order:10, 
        title:'Genomes', 
        action:'list'
    ]

    def genomeService
    def statsService

    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "sampleCount"
        params.order = params.order ?: "desc"

        List results = genomeService.list params
        
        if (params._pjax) {
            params.remove('_pjax')
            return [genomeInstanceList: results, genomeInstanceTotal: results.totalCount, layout:'ajax']
        }      
        withFormat {
            html genomeInstanceList: results, genomeInstanceTotal: results.totalCount
            json { render results as JSON  }
        }
    }

    def show() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        params.sort = params.sort ?: "geneCoverageMax"
        params.order = params.order ?: "desc"
        params.accession = params.id

        Genome genomeInstance = findInstance()
        
        params.sample = 'only'
        List results = statsService.list params 

        if (params._pjax) {
            params.remove('_pjax')
            return [genomeInstance: genomeInstance, statisticsInstanceList: results, statisticsInstanceTotal: results.totalCount, layout:'ajax']
        }

        genomeInstance['genes'] = Feature.findAllByGenomeAndType(genomeInstance.gi, 'gene')
        List pResults = statsService.list([accession:params.accession, sample: 'none', sort: "geneCoverageMax", order: "desc"]) 

        withFormat {
            html genomeInstance: genomeInstance, 
                 statisticsInstanceList: results, statisticsInstanceTotal: results.totalCount,
                 pStatisticsInstanceList: pResults, pStatisticsInstanceTotal: pResults.totalCount
            json { render results as JSON }
        }
    }

	private Genome findInstance() {
		Genome genomeInstance = genomeService.get(params.id)
		if (!genomeInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'genome.label', default: 'Genome'), params.id])
		  redirect action: 'list'
		}
		genomeInstance
	}
}
