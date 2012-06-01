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

        List fasta = mappedService.bucket(mappedInstance.sequence)
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


<<<<<<< HEAD
    Map ret = [
      'identifier': 'id',
      'label': 'gname',
      'items': reads
    ]

    render ret as JSON
  }


  def show_contig = {
    Mapped mappedInstance = findInstance()
    
    //Date start = new Date()
    ArrayList reads = mappedService.getOverlappingReads(mappedInstance)
    //Date stop = new Date()
    //TimeDuration td = TimeCategory.minus( stop, start )
    //println td
    
    /*
    ArrayList reads = [
      ['refStart': 11,
       'refEnd': 30,
       'sequence': 'ABCDEFGHIJKLMNOPQRST'],
      ['refStart': 16,
       'refEnd': 35,
       'sequence': 'FGHIJKLMNOPQRST43210'],
      ['refStart': 21,
       'refEnd': 40,
       'sequence': '!@#$%^&*())(*&^%$#@!']
    ]
    */

    //start = new Date()
    //List contig = mappedService.bucket(mappedService.getContig(reads, mappedInstance))
    List contig = mappedService.getContig(reads, mappedInstance)
    //stop = new Date()
    //td = TimeCategory.minus( stop, start )
    //println td

    render(view: 'ajax/show/contig', model: [mappedInstance: mappedInstance, sequence: contig])
  }

  private Mapped findInstance() {
    Mapped mappedInstance = mappedService.get(params.id)
    authorize(mappedInstance, ['user', 'collaborator', 'owner'])
    if (!mappedInstance) {
      flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'mapped.name', default: 'Mapped'), params.id])}"
      redirect(controller:'project', action: 'list')
    }
    mappedInstance
  }
=======
	private Mapped findInstance() {
		Mapped mappedInstance = mappedService.get(params.id)
		authorize(mappedInstance, ['user', 'collaborator', 'owner'])
		if (!mappedInstance) {
			flash.message = message(code: 'default.not.found.message', args: [message(code: 'mapped.label', default: 'Mapped'), params.id])
			redirect action: 'list'
		}
		mappedInstance
	}
>>>>>>> feature/bootstrap

	private void authorize(def auth, List access) {
		if (!authService.authorize(auth, access)) {
		  render view: '../login/denied'
		}
	}
}
