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

@Secured(['ROLE_CAPSID'])
class ProjectController {

    def AuthService

    def index = {redirect(action: "list", params: params)}

    def list = {}
    def list_data = {
        List projects = Project.security(AuthService.getRoles()).list().collect {
            [
                id: it.id.toString()
            ,   label: it.label
            ,   name: it.name
            ,   description: it.description
            ,   wikiLink: it.wikiLink
            ]
        }

        def ret = [
            'identifier': 'id',
            'label': 'name',
            'items': projects
        ]

        render ret as JSON
    }

    @Secured(['ROLE_CAPSID_ADMIN'])
    def save = {
        def projectInstance = new Project(params)
        projectInstance.roles = ['ROLE_CAPSID']

        if (projectInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'project.label', default: 'Project'), projectInstance.label])}"
            redirect(action: "show", id: projectInstance.label)
        } else {
            render 'Error while trying to save' //render(view: "ajax/create/project", model: [projectInstance: projectInstance])
        }
    }

    @Secured(['ROLE_CAPSID_ADMIN'])
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

    def show = {
        Project projectInstance = Project.security(AuthService.getRoles()).findByLabel(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            [projectInstance: projectInstance]
        }
    }

    /* ************************************************************************
     * AJAX Tabs
     *********************************************************************** */
    /* ** Show  ** */
    def show_samples = {
        Project projectInstance = Project.security(AuthService.getRoles()).get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            render(view: 'ajax/show/samples', model: [projectInstance: projectInstance])
        }
    }
    def show_samples_data = {
        Project projectInstance = Project.security(AuthService.getRoles()).get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            ArrayList samples = Sample.collection.find(project: projectInstance.label).collect {
                [
                    id: it._id.toString(),
                    name: it.name,
                    description: it.description,
                    cancer: it.cancer,
                    source: it.source,
                    role: it.role,
                ]
            }

            def ret = [
                'identifier': 'id',
                'label': 'name',
                'items': samples
            ]

            render ret as JSON
        }
    }

    def show_alignments = {
        Project projectInstance = Project.security(AuthService.getRoles()).get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            render(view: 'ajax/show/alignments', model: [projectInstance: projectInstance])
        }
    }
    def show_alignments_data = {
        Project projectInstance = Project.security(AuthService.getRoles()).get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            ArrayList alignments = Alignment.collection.find(project: projectInstance.label).collect {
                [
                        id: it._id.toString()
					,	name: it.name
                    ,   aligner: it.aligner
                    ,   platform: it.platform
                    ,   sample: it.sample
                    ,   type: it.type
                    ,   infile: it.infile
                    ,   outfile: it.outfile
                ]
            }

            def ret = [
                'identifier': 'id',
                'label': 'name',
                'items': alignments
            ]

            render ret as JSON
        }
    }

    def show_stats = {
        Project projectInstance = Project.security(AuthService.getRoles()).get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
            render(view: 'ajax/show/stats', model: [projectInstance: projectInstance])
        }
    }
    def show_stats_data = {
        Project projectInstance = Project.security(AuthService.getRoles()).get(params.id)
        if (!projectInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.id])}"
            redirect(action: "list")
        } else {
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

            def ret = [
                    'identifier': 'id',
                    'label': 'gname',
                    'items': stats
            ]

            render ret as JSON
        }
    }
}
