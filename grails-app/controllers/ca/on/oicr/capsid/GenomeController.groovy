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
class GenomeController {

  def authService
  def projectService
  def genomeService

  def index = {redirect(action: "list", params: params)}

  def list = {}

  def show = {
    Genome genomeInstance = findInstance()
    [genomeInstance: genomeInstance]
  }

  def project = {
    Project projectInstance = findProject()
    Genome genomeInstance = findInstance()

    [projectInstance: projectInstance,genomeInstance: genomeInstance]
  }

  /* ************************************************************************
   * AJAX Tabs
   *********************************************************************** */
  def list_data = {
    List genomes = Genome.withCriteria({ne('organism', "Homo sapiens")}).collect {
      [
          gi: it.gi
        ,	accession: it.accession
        ,	name: it.name
        ,	taxonomy: it.taxonomy?.join(", ")
        , length: it.length
        , samples: it.samples?.size()
      ]
    }

    def ret = [
      'identifier': 'gi',
      'label': 'name',
      'items': genomes
    ]

    render ret as JSON
  }

  /*** Project ***/
  def project_stats = {
    Project projectInstance = findProject()
    Genome genomeInstance = findInstance()

    render(view: 'ajax/project/stats', model: [projectInstance: projectInstance, genomeInstance: genomeInstance])

  }
  def project_stats_data = {
    Project projectInstance = findProject()
    Genome genomeInstance = findInstance()
    ArrayList samples = Statistics.collection.find(
      label:projectInstance.label
      ,	accession:genomeInstance.accession
      ,	sample: [$exists: 1])
    .collect{
      [
        id: it._id.toString()
        ,	sample: it.sample
        ,	label:it.label
        ,	project:it.project
        ,	genomeHits:it.genomeHits
        ,	geneHits:it.geneHits
        ,	genomeCoverage:it.genomeCoverage
        ,	geneCoverageAvg:it.geneCoverageAvg
        ,	geneCoverageMax:it.geneCoverageMax
        ,	accession: it.accession
      ]
    }

    def ret = [
      'identifier': 'id',
      'label': 'sname',
      'items': samples
    ]

    render ret as JSON

  }

  /*** Show ***/
  def show_project_stats = {
    Genome genomeInstance = findInstance()
    render(view: 'ajax/show/project_stats', model: [genomeInstance: genomeInstance])
  }
  def show_project_stats_data = {
    Genome genomeInstance = findInstance()
    ArrayList projects = Statistics.collection.find(
      accession: genomeInstance.accession
      , sample: [$exists: 0]
      , label: [$in:projectService.getAllowedProjects().label])
    .collect {
      [
        id : it._id.toString()
        , label: it.label
        , project: it.project
        , genomeHits: it.genomeHits
        , geneHits: it.geneHits
        , genomeCoverage: it.genomeCoverage
        , geneCoverageAvg: it.geneCoverageAvg
        , geneCoverageMax: it.geneCoverageMax
        , accession: it.accession
      ]
    }

    def ret = [
      'identifier': 'id',
      'label': 'project',
      'items': projects
    ]

    render ret as JSON
  }

  def show_sample_stats = {
    Genome genomeInstance = findInstance()
    render(view: 'ajax/show/sample_stats', model: [genomeInstance: genomeInstance])
  }
  def show_sample_stats_data = {
    Genome genomeInstance = findInstance()
    ArrayList samples = Statistics.collection.find(
      accession: genomeInstance.accession
      ,	sample: [$exists: 1]
      ,	label: [$in:projectService.getAllowedProjects().label])
    .collect {
      [
        id : it._id.toString()
        ,	sample: it.sample
        ,	label: it.label
        ,	project: it.project
        ,	genomeHits: it.genomeHits
        ,	geneHits: it.geneHits
        ,	genomeCoverage: it.genomeCoverage
        ,	geneCoverageAvg: it.geneCoverageAvg
        ,	geneCoverageMax: it.geneCoverageMax
        ,	accession: it.accession
      ]
    }

    def ret = [
      'identifier': 'id',
      'label': 'sample',
      'items': samples
    ]

    render ret as JSON
  }

  def show_features = {
    Genome genomeInstance = findInstance()
    render(view: 'ajax/show/features', model: [genomeInstance: genomeInstance])
  }
  def show_features_data = {
    Genome genomeInstance = findInstance()
    ArrayList features = Feature.collection.find(genome: genomeInstance.gi).collect {
      [
        id: it._id.toString()
        ,	name: it.name
        ,	type: it.type
        ,	locusTag: it.locusTag
        ,	geneId: it.geneId
        ,	start: it.start
        ,	stop: it.end
        ,	length: it.end - it.start
      ]
    }

    def ret = [
      'identifier': 'id',
      'label': 'name',
      'items': features
    ]
    render ret as JSON
  }

  private Genome findInstance() {
    Genome genomeInstance = genomeService.get(params.id)
    if (!genomeInstance) {
      flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'genome.label', default: 'Genome'), params.id])}"
      redirect(action: 'list')
    }
    genomeInstance
  }

  private Project findProject() {
    Project projectInstance = projectService.get(params.pid)
    authorize(projectInstance, ['user', 'collaborator', 'owner'])
    if (!projectInstance) {
      flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'project.label', default: 'Project'), params.pid])}"
      redirect(action: 'list')
    }
    projectInstance
  }

  private boolean authorize(def auth, List access) {
    if (!authService.authorize(auth, access)) {
      render view: '../login/denied'
    }
  }
}
