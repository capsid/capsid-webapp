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

import grails.converters.JSON
import grails.plugins.springsecurity.Secured
import org.bson.types.ObjectId

import com.mongodb.gridfs.GridFS
import com.mongodb.gridfs.GridFSFile
import com.mongodb.gridfs.GridFSDBFile
import com.mongodb.DB

@Secured(['ROLE_CAPSID'])
class MappedController {

  def mappedService
  def authService
  def fileService
  def mongo

  def index = {redirect(controller: "project", action: "list")}

  def show = {
    Mapped mappedInstance = findInstance()

    DB db = mongo.mongo.getDB('capsid')
    GridFS gfs = new GridFS(db)
    GridFSDBFile file = gfs.findOne(mappedInstance.genome)

    int count = 1
    file.getInputStream().each {
      if (count >= mappedInstance.refStart && count <= mappedInstance.refEnd) {
        print new String(it)
      }
      count++
    }

    //Map alignment = mappedService.getSplitAlignment("ACCAGGGAATATTGGTACCCTGCCAGTATCCCTGGATTTAAACATATCTACTACTACTCATCATCATCAATGCCATCTCAATCTCATACTACTACTCATAGGGCGCCGCGGGGCATAATCGATCATGTCGATGCGATCGAGTCAACAAGCGGGTGGAGCGGACG", file.getInputStream().getAt(mappedInstance.refStart..mappedInstance.refEnd-1))
    Map alignment = mappedService.getSplitAlignment("ACGTACTGATCGATCGATGCATCGATCGATCGATCGACTGATCGACTGACTAGCTACGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGTACGTACGATCGATCGATCGATCGATCGATCGATCATCGA", "ACGTACTGATCGATCGATGCATCGATCGATCGATCGACTGATCGACTGACTAGCTACGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGTACGTACGATCGATCGATCGATCGATCGATCGATCATCGA")

    alignment.ref.pos.each {val -> val + mappedInstance.refStart}

    [mappedInstance: mappedInstance, alignment: alignment]
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
