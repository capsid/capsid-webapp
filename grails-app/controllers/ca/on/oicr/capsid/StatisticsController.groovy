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
class StatisticsController {

	static scaffold = true
	static navigation = [
		group:'statistics', 
		order:10, 
		title:'Statistics', 
		action:'list'
	]

	def list() {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [statisticsInstanceList: Statistics.list(params), statisticsInstanceTotal: Statistics.count()]
    }

}
