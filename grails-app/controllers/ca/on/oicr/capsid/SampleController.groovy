/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*    This program and the accompanying materials are made available under the
*    terms of the GNU Public License v3.0.
*
*    You should have received a copy of the GNU General Public License along with
*    this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import grails.plugins.springsecurity.Secured
import grails.converters.JSON
import org.bson.types.ObjectId
import org.springframework.dao.DataIntegrityViolationException

@Secured(['ROLE_CAPSID'])
class SampleController {

    def sampleService
    def authService

    def index = {redirect(action: "list", params: params)}

    def list = {}

    def show = {
        Sample sampleInstance = findInstance()
        [sampleInstance: sampleInstance]
    }

    def create = {
        authorize(['ROLE_' + params.id.toUpperCase()], ['collaborator', 'owner'])
        Sample sample = new Sample(params)
        sample.project = params.id
        [sampleInstance: sample]
    }

    def save = {
        authorize(['ROLE_' + params.project.toUpperCase()], ['collaborator', 'owner'])
        sampleService.save params

        render 'created'
    }

    def edit = {
        Sample sample = findInstance()
        authorize(sample, ['collaborator', 'owner'])
        [sampleInstance: sample]
    }

    def update = {
        Sample sample = findInstance()
        authorize(sample, ['collaborator', 'owner'])
        sampleService.update sample, params

        if (!renderWithErrors('edit', sample)) {
            redirectShow "${message(code: 'default.updated.message', args: [message(code: 'sample.label', default: 'Sample'), sample.name])}", sample.name
        }
    }

    def delete = {
        Sample sample = findInstance()
        authorize(sample, ['collaborator', 'owner'])

        try {
            String project = sample.project
            sampleService.delete sample
            flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'sample.name', default: 'Sample'), params.id])}"
            redirect controller: 'project', action: 'show', id:project
        } catch (DataIntegrityViolationException e) {
            redirectShow "Sample $sample.name could not be deleted", sample.name
        }
    }

    /* ************************************************************************
    * AJAX Tabs
    ************************************************************************ */
    def list_data = {
        List samples = sampleService.getAllowedSamples().collect {
                [
                     name:it.name
                ,    plabel: it.project
                ,    pname: Project.findByLabel(it.project).name
                ,    cancer: it.cancer
                ,    role: it.role
                ,    source: it.source
                ]
            }

        def ret = [
               'identifier': 'name',
               'label': 'name',
               'items': samples
                ]

       render ret as JSON
    }

    /*** Show ***/
    def show_alignments = {
        Sample sampleInstance = findInstance()
        render(view: 'ajax/show/alignments', model: [sampleInstance: sampleInstance])
    }
    def show_alignments_data = {
        Sample sampleInstance = findInstance()
        ArrayList alignments = Alignment.collection.find(sample: sampleInstance.name).collect {
                [
                      name: it.name
                 ,    aligner: it.aligner
                 ,    platform: it.platform
                 ,    type: it.type
                 ,    infile: it.infile
                 ,    outfile: it.outfile
                 ]
        }

        def ret = [
                   'identifier': 'name'
              ,    'label': 'name'
              ,    'items': alignments
        ]

        render ret as JSON

    }

    def show_stats = {
        Sample sampleInstance = findInstance()
        render(view: 'ajax/show/stats', model: [sampleInstance: sampleInstance])
    }
    def show_stats_data = {
        Sample sampleInstance = findInstance()
        ArrayList stats = Statistics.collection.find(sname:sampleInstance.name).collect{
                [
                    id: it._id.toString()
                ,   accession: it.genomeAccession
                ,   gname: it.genomeName
                ,   hits: it.hits
                ,   geneHits: it.geneHits
                ,   totalCoverage: it.totalCoverage
                ,   geneCoverage: it.geneCoverage
                ,   maxCoverage: it.maxCoverage
                ,   sname: it.sampleName
                ]
        }

        def ret = [
               'identifier': 'id'
           ,   'label': 'name'
           ,   'items': stats
           ]

        render ret as JSON
    }

    def jbrowse_samples = {}

    private Sample findInstance() {
        Sample sampleInstance = sampleService.get(params.id)
        authorize(sampleInstance, ['user', 'collaborator', 'owner'])
        if (!sampleInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.name', default: 'Sample'), params.id])}"
            redirect action: list
        }
        sampleInstance
    }

    private void redirectShow(message, id) {
        flash.message = message
        redirect action: show, id: id
    }

    private boolean renderWithErrors(String view, Sample sampleInstance) {
        if (sampleInstance.hasErrors()) {
            render view: view, model: [sampleInstance: sampleInstance]
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
