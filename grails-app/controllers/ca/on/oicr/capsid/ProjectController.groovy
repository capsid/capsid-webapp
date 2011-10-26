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

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.springframework.dao.DataIntegrityViolationException

@Secured(['ROLE_CAPSID'])
class ProjectController {

    def projectService
    def authService

    def index = {redirect(action: "list", params: params)}

    def list = {}

    def list_data = {
        List projects = projectService.getAllowedProjects().collect {
            [
                label: it.label
            ,   name: it.name
            ,   description: it.description
            ,   wikiLink: it.wikiLink
            ]
        }

        Map ret = [
            'identifier': 'label',
            'label': 'name',
            'items': projects
        ]

        render ret as JSON
    }

    def show = {
        Project projectInstance = findInstance()
        [projectInstance: projectInstance]
    }

    def create = {
        [projectInstance: new Project(params)]
    }

    def save = {
        Project project = projectService.create(params)
        if (!renderWithErrors('create', project)) {
            redirectShow "${message(code: 'default.created.message', args: [message(code: 'project.label', default: 'Project'), project.label])}", project.label
        }
    }

    def update = {
        def projectInstance = Project.findByLabel(params.label)

        projectInstance.properties = params

        if (projectInstance.save(flush: true)) {
            render 'Updated!'
        }
        else {
            render 'Error while trying to update'
        }
    }

    def delete = {
        Project project = findInstance()

        try {
            projectService.delete project
            flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect action: list
        } catch (DataIntegrityViolationException e) {
            redirectShow "Project $project.label could not be deleted", project.label
        }
    }


    /* ************************************************************************
     * AJAX Tabs
     *********************************************************************** */
    /* ** Show  ** */
    def show_samples = {
        Project projectInstance = findInstance()
        render(view: 'ajax/show/samples', model: [projectInstance: projectInstance])
    }
    def show_samples_data = {
        Project projectInstance = findInstance()
        ArrayList samples = Sample.collection.find(project: projectInstance.label).collect {
            [
                name: it.name
            ,   description: it.description
            ,   cancer: it.cancer
            ,   source: it.source
            ,   role: it.role
            ]
        }

        Map ret = [
            'identifier': 'name',
            'label': 'name',
            'items': samples
        ]

        render ret as JSON
    }

    def show_alignments = {
        Project projectInstance = findInstance()
        render(view: 'ajax/show/alignments', model: [projectInstance: projectInstance])
    }
    def show_alignments_data = {
        Project projectInstance = findInstance()
        ArrayList alignments = Alignment.collection.find(project: projectInstance.label).collect {
            [
                name: it.name
            ,   aligner: it.aligner
            ,   platform: it.platform
            ,   sample: it.sample
            ,   type: it.type
            ,   infile: it.infile
            ,   outfile: it.outfile
            ]
        }

        Map ret = [
            'identifier': 'name',
            'label': 'name',
            'items': alignments
        ]

        render ret as JSON
    }

    def show_stats = {
        Project projectInstance = findInstance()
        render(view: 'ajax/show/stats', model: [projectInstance: projectInstance])
    }
    def show_stats_data = {
        Project projectInstance = findInstance()
        ArrayList stats = Statistics.collection.find(threshold:20, projectId:projectInstance.id, sampleId:0).collect {
            [
                id: it._id.toString()
            ,   accession: it.genomeAccession
            ,   gname: it.genomeName
            ,   hits: it.hits
            ,   geneHits: it.geneHits
            ,   totalCoverage: it.totalCoverage
            ,   geneCoverage: it.geneCoverage
            ,   maxCoverage: it.maxCoverage
            ]
        }

        Map ret = [
                'identifier': 'id',
                'label': 'gname',
                'items': stats
        ]

        render ret as JSON
    }

    private Project findInstance() {
        def projectInstance = projectService.get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect action: list
        }
        projectInstance
    }

    private void redirectShow(message, id) {
        flash.message = message
        redirect action: show, id: id
    }

    private boolean renderWithErrors(String view, Project projectInstance) {
        if (projectInstance.hasErrors()) {
            render view: view, model: [projectInstance: projectInstance]
            return true
        }
        false
    }
}
