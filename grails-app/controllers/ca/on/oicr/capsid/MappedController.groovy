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


import groovy.time.*


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



  /* ************************************************************************
   * AJAX Tabs
   *********************************************************************** */
  /* ** Show  ** */
  def show_fasta = {
    Mapped mappedInstance = findInstance()
    List sequence = mappedService.bucket(mappedInstance.sequence)

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


  def show_contig = {
    Mapped mappedInstance = findInstance()

    Date start = new Date()
    ArrayList reads = mappedService.getOverlappingReads(mappedInstance)
    Date stop = new Date()
    TimeDuration td = TimeCategory.minus( stop, start )
    println td

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

    start = new Date()
    //List contig = mappedService.bucket(mappedService.getContig(reads, mappedInstance))
    List contig = mappedService.getContig(reads, mappedInstance)
    stop = new Date()
    td = TimeCategory.minus( stop, start )
    println td

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

  private boolean authorize(def auth, List access) {
    if (!authService.authorize(auth, access)) {
      render view: '../login/denied'
    }
  }
}
