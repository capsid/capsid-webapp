/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package ca.on.oicr.capsid
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class FeatureController {

	static scaffold = true
	static navigation = [
		group:'genome', 
		order:20, 
		title:'Genes', 
		action:'list'
	]

	def create() { redirect action: 'list', params: params }
	def edit() { redirect action: 'list', params: params }
	def delete() { redirect action: 'list', params: params }
}