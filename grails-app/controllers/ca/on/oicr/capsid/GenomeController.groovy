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
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class GenomeController {

    static allowedMethods = [create: 'POST', edit: 'POST', delete: 'POST']

    def authService
    def genomeService

    def index() { redirect action: 'list', params: params }

    def list() {
        params.max = Math.min(params.max ? params.int('max') : 15, 100)
        [genomeInstanceList: Genome.list(params), genomeInstanceTotal: Genome.count()]
    }

    def show() {
        Genome genomeInstance = findInstance()
        [genomeInstance: genomeInstance]
    }

	private Genome findInstance() {
		Genome genomeInstance = genomeService.get(params.id)
		if (!genomeInstance) {
		  flash.message = message(code: 'default.not.found.message', args: [message(code: 'genome.label', default: 'Genome'), params.accession])
		  redirect action: 'list'
		}
		genomeInstance
	}
}