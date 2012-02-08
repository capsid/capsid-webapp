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

import org.codehaus.groovy.grails.commons.ConfigurationHolder as CH

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.bson.types.ObjectId


@Secured(['ROLE_CAPSID'])
class MappedController {

  def mappedService
  def authService
  def fileService

  def index = {redirect(controller: "project", action: "list")}

  def show = {
    Mapped mappedInstance = findInstance()
    
    [mappedInstance: mappedInstance]
  }

  def contig = {
    Mapped mapped = findInstance()
    ArrayList contig = Mapped.collection.find(
      sample: mapped.sample
      ,  genomeId: new ObjectId(mapped.genomeId)
      ,  refStrand: mapped.refStrand
    ).collect {
      [
        id: it._id.toString()
      ]
    }

    render contig.size()
  }

  /* ************************************************************************
   * AJAX Tabs
   *********************************************************************** */
  /* ** Show  ** */
  def show_fasta = {
    Mapped mappedInstance = findInstance()
    List sequence = mappedInstance.sequence.replaceAll(/.{80}/){all -> all + ';'}.split(';')

    render(view: 'ajax/show/fasta', model: [mappedInstance: mappedInstance, sequence: sequence])
  }

  def show_alignment = {
    Mapped mappedInstance = findInstance()    
    Genome genomeInstance = Genome.findByGi(mappedInstance.genome as int)

    Map alignment = mappedService.getSplitAlignment(mappedInstance)

    alignment.ref.pos.each {val -> val + mappedInstance.refStart}

    render(view: 'ajax/show/align', model: [mappedInstance: mappedInstance, alignment: alignment, genomeInstance: genomeInstance])
  }

  def show_reads = {
    Mapped mappedInstance = findInstance()
    render(view: 'ajax/show/reads', model: [mappedInstance: mappedInstance])
  }
  def show_reads_data = {
    Mapped mappedInstance = findInstance()
    ArrayList reads = Mapped.collection.find(
      "readId": mappedInstance.readId
      ,  "_id": [$ne: mappedInstance.id])
    .collect {
      [
        id: it._id.toString()
        ,  accession: Genome.findByGi(it.genome).accession
        ,  gname: Genome.findByGi(it.genome).name
        ,  refStart: it.refStart
        ,  refEnd: it.refEnd
      ]
    }

    Map ret = [
      'identifier': 'id',
      'label': 'gname',
      'items': reads
    ]

    render ret as JSON
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

  private boolean authorize(def auth, List access) {
    if (!authService.authorize(auth, access)) {
      render view: '../login/denied'
    }
  }
}
