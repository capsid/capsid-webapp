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

@Secured(['ROLE_CAPSID'])
class MappedController {

  def mappedService
  def authService

  def index = {redirect(controller: "project", action: "list")}

  def show = {
    Mapped mappedInstance = findInstance()
    [mappedInstance: mappedInstance]
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
      ,  "_id": [$ne: new ObjectId(mappedInstance.id)])
    .collect {
      [
        id: it._id.toString()
        ,  accession: Genome.get(it.genomeId).accession
        ,  gname: Genome.get(it.genomeId).name
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

  private boolean authorize(def auth, List access) {
    if (!authService.authorize(auth, access)) {
      render view: '../login/denied'
    }
  }
}
