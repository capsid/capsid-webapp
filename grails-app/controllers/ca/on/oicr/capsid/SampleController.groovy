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
class SampleController {

	static scaffold = true
	static navigation = [
		group:'project', 
		order:20, 
		title:'Samples', 
		action:'list'
	]

}
