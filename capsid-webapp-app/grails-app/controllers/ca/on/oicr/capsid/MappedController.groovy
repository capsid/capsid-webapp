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
 * Controller class for the mapped controller. 
 */
@Secured(['ROLE_CAPSID'])
class MappedController {

    /**
     * The allowed methods.
     */
    static allowedMethods = [create: 'GET', save: 'POST', update: 'POST', delete: 'POST']

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the MappedService.
     */
    def mappedService

    /**
     * Dependency injection for the ProjectService.
     */
    def projectService

    /**
     * The show action.
     */
    def show() {
        Mapped mappedInstance = findInstance()
        assert mappedInstance

        List fasta = mappedService.bucket(mappedInstance.sequence)
        ArrayList otherHits = mappedService.otherHits mappedInstance

        [mappedInstance: mappedInstance, fasta: fasta, otherHits: otherHits]
    }

    /**
     * The alignment action.
     */
    def alignment() {
		Mapped mappedInstance = findInstance()
		Genome genomeInstance = Genome.findByGi(mappedInstance.genome as int)

	    Map alignment = mappedService.getSplitAlignment(mappedInstance)

    	alignment.ref.pos.each {val -> val + mappedInstance.refStart}

    	render(view: 'tabs/alignment', model: [mappedInstance: mappedInstance, alignment: alignment, genomeInstance: genomeInstance])
    }

    /**
     * The contig action.
     */
	def contig() {
	    Mapped mappedInstance = findInstance()

	    ArrayList reads = mappedService.getOverlappingReads(mappedInstance)
	    List sequence = mappedService.getContig(reads, mappedInstance)

    	render(view: 'tabs/contig', model: [mappedInstance: mappedInstance, sequence: sequence])
	}

    /**
     * Finds a mapped instance using the specified identifier in the form parameters. 
     */
	private Mapped findInstance() {
		Mapped mappedInstance = mappedService.get(params.id)
        if (!mappedInstance) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'mapped.label', default: 'Mapped'), params.id])
            redirect action: 'list'
        }

        //Project projectInstance = projectService.getById(mappedInstance.projectId)
		//authorize(projectInstance, ['user', 'collaborator', 'owner'])

		mappedInstance
	}

    /**
     * Checks authorization and redirects to the login denied page if not.
     */
    private void authorize(Project auth, List access) {
        if (!authService.authorize(auth, access)) {
          render view: '../login/denied'
        }
    }
}
