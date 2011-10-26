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

@Secured(['ROLE_CAPSID'])
class SampleController {
    def AuthService

    def index = {redirect(action: "list", params: params)}
    def list = {[roles:AuthService.getRoles()]}
    def list_data = {
        List samples = Sample.security(AuthService.getAllowedProjects().label).list().collect {
                [
                    id:it.id.toString()
                ,    name:it.name
                ,    plabel: it.project
                ,    pname: Project.findByLabel(it.project).name
                ,    cancer: it.cancer
                ,    role: it.role
                ,    source: it.source
                ]
            }

        def ret = [
               'identifier': 'id',
               'label': 'name',
               'items': samples
                ]
       
       render ret as JSON
    }

    @Secured(['ROLE_CAPSID_ADMIN'])
    def save = {
        Sample sampleInstance = new Sample(params)

        if (sampleInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'sample.label', default: 'Sample'), sampleInstance.name])}"
            redirect(controller:"project", action: "show", id: sampleInstance.project)
        } else {
            render 'Error while trying to save' //render(view: "ajax/create/sample", model: [sampleInstance: sampleInstance])
        }
    }
    
    @Secured(['ROLE_CAPSID_ADMIN'])
    def update = {
        def sampleInstance = Sample.findByName(params.name)
        sampleInstance.properties = params
        
        if (sampleInstance.save(flush: true)) {
            render 'Updated!'
        }
        else {
            render 'Error while trying to update'
        }
    }
    
    def show = {
        def sampleInstance = Sample.security(AuthService.getAllowedProjects().label).findByName(params.id)

        if (!sampleInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])}"
            redirect(action: "list")
        } else {
            [sampleInstance: sampleInstance]
        }
    }
    
    
    /* ************************************************************************
    * AJAX Tabs
    ************************************************************************ */
    /*** Show ***/
    def show_alignments = {
        Sample sampleInstance = Sample.security(AuthService.getAllowedProjects().label).get(params.id)
        if (!sampleInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])}"
            redirect(action: "list")
        } else {
            render(view: 'ajax/show/alignments', model: [sampleInstance: sampleInstance])
        }
    }
    def show_alignments_data = {
        Sample sampleInstance = Sample.security(AuthService.getAllowedProjects().label).get(params.id)
        if (!sampleInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])}"
            redirect(action: "list")
        } else {
            ArrayList alignments = Alignment.collection.find(sample: sampleInstance.name).collect({[
                                    id: it._id.toString()
                                ,    name: it.name
                                ,   aligner: it.aligner
                                ,    platform: it.platform
                                ,    type: it.type
                                ,    infile: it.infile
                                ,    outfile: it.outfile
                                ]})
            
           def ret = [
                   'identifier': 'id',
                   'label': 'aligner',
                   'items': alignments
                    ]
           
           render ret as JSON
        }
    }

    def show_stats = {
        Sample sampleInstance = Sample.security(AuthService.getAllowedProjects().label).get(params.id)
        if (!sampleInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])}"
            redirect(action: "list")
        } else {
            render(view: 'ajax/show/stats', model: [sampleInstance: sampleInstance])
        }
    }
    def show_stats_data = {
        Sample sampleInstance = Sample.security(AuthService.getAllowedProjects().label).get(params.id)
        if (!sampleInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), params.id])}"
            redirect(action: "list")
        } else {
            ArrayList stats = Statistics.collection.find(threshold:20, sampleId:sampleInstance.id).collect{
                [
                    id: it._id.toString()
                ,   accession: it.genomeAccession
                ,    gname: it.genomeName
                ,   hits: it.hits
                ,   geneHits: it.geneHits
                ,   totalCoverage: it.totalCoverage
                ,   geneCoverage: it.geneCoverage
                ,   maxCoverage: it.maxCoverage
                ,    sname: it.sampleName
                ]
            }

            def ret = [
               'identifier': 'id',
               'label': 'name',
               'items': stats
                ]
           
           render ret as JSON
        }
    }
         
    def jbrowse_samples = {}
}
