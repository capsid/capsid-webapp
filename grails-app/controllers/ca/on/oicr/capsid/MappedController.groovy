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
class MappedController {

    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    def authService
    def mappedService

    def show() {
        Mapped mappedInstance = findInstance()

        List fasta = [] //mappedService.bucket(mappedInstance.sequence)
        ArrayList otherHits = mappedService.otherHits mappedInstance

        [mappedInstance: mappedInstance, fasta: fasta, otherHits: otherHits]
    }

    def alignment() {
		Mapped mappedInstance = findInstance()
		Genome genomeInstance = Genome.findByGi(mappedInstance.genome as int)

	    Map alignment = mappedService.getSplitAlignment(mappedInstance)

    	alignment.ref.pos.each {val -> val + mappedInstance.refStart}

    	render(view: 'tabs/alignment', model: [mappedInstance: mappedInstance, alignment: alignment, genomeInstance: genomeInstance])
    }

	def contig() {
	    Mapped mappedInstance = findInstance()

	    ArrayList reads = mappedService.getOverlappingReads(mappedInstance)
	    List sequence = mappedService.getContig(reads, mappedInstance)

    	render(view: 'tabs/contig', model: [mappedInstance: mappedInstance, sequence: sequence])
	}


	private Mapped findInstance() {
		Mapped mappedInstance = mappedService.get(params.id)
		authorize(mappedInstance, ['user', 'collaborator', 'owner'])
		if (!mappedInstance) {
			flash.message = message(code: 'default.not.found.message', args: [message(code: 'mapped.label', default: 'Mapped'), params.id])
			redirect action: 'list'
		}
		mappedInstance
	}

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}
}
