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

import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class AlignmentController {

    def index = { }
	
	@Secured(['ROLE_CAPSID_ADMIN'])
	def save = {
		Alignment alignmentInstance = new Alignment(params)
		if (alignmentInstance.save(flush: true)) {
			flash.message = "${message(code: 'default.created.message', args: [message(code: 'alignment.label', default: 'Alignment'), alignmentInstance.name])}"
			redirect(controller:"sample", action: "show", id: alignmentInstance.sample)
		} else {
			render 'Error while trying to save' //render(view: "ajax/create/alignment", model: [alignmentInstance: alignmentInstance])
		}
	}
}
