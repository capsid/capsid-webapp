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

  private boolean authorize(def auth, List access) {
    if (!authService.authorize(auth, access)) {
      render view: '../login/denied'
    }
  }
}
