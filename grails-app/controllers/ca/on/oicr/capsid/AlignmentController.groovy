/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
 *
 *	This program and the accompanying materials are made available under the
 *	terms of the GNU Public License v3.0.
 *
 *	You should have received a copy of the GNU General Public License along with
 *	this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package ca.on.oicr.capsid

import grails.plugins.springsecurity.Secured
import org.springframework.dao.DataIntegrityViolationException

@Secured(['ROLE_CAPSID'])
class AlignmentController {

    def projectService
    def sampleService
    def alignmentService
    def authService

    def index = {redirect(action: "list", params: params)}

    def list = {}

    def show = {
        Alignment alignmentInstance = findInstance()
        [alignmentInstance: alignmentInstance]
    }

    def create = {
        authorize(['ROLE_' + params.id.toUpperCase()], ['collaborator', 'owner'])

        Alignment alignment = new Alignment(params)
        List<Sample> samples = []

        if (projectService.get(params.id)) {
            alignment.project = params.id
            samples = Sample.findAllByProject(params.id)
        } else if (sampleService.get(params.id)) {
            Sample sample = sampleService.get(params.id)
            alignment.project = sample.project
            samples = [sample]
        }

        [alignmentInstance: alignment, sampleList: samples]
    }

    def save = {
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])
        alignmentService.save(params)

        render 'created'
    }

    def edit = {
        Alignment alignment = findInstance()
        authorize(alignment, ['collaborator', 'owner'])
        [alignmentInstance: alignment]
    }

    def update = {
        Alignment alignment = findInstance()
        authorize(alignment, ['collaborator', 'owner'])
        alignmentService.update alignment, params

        if (!renderWithErrors('edit', alignment)) {
            redirectShow "${message(code: 'default.updated.message', args: [message(code: 'alignment.label', default: 'Alignment'), alignment.name])}", alignment.name
        }
    }

    def delete = {
        Alignment alignment = findInstance()
        authorize(alignment, ['owner'])

        try {
            String sample = alignment.sample
            alignmentService.delete alignment
            flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'alignment.name', default: 'Alignment'), params.id])}"
            redirect controller: 'sample', action: 'show', id:sample
        } catch (DataIntegrityViolationException e) {
            redirectShow "Alignment $alignment.name could not be deleted", alignment.name
        }
    }

    private Alignment findInstance() {
        Alignment alignmentInstance = alignmentService.get(params.id)
        authorize(alignmentInstance, ['user', 'collaborator', 'owner'])
        if (!alignmentInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.name', default: 'Sample'), params.id])}"
            redirect action: list
        }
        alignmentInstance
    }

    private void redirectShow(message, id) {
        flash.message = message
        redirect action: show, id: id
    }

    private boolean renderWithErrors(String view, Alignment alignmentInstance) {
        if (alignmentInstance.hasErrors()) {
            render view: view, model: [alignmentInstance: alignmentInstance]
            return true
        }
        false
    }

    private boolean authorize(def auth, List access) {
        if (!authService.authorize(auth, access)) {
            render view: '../login/denied'
        }
    }

}
