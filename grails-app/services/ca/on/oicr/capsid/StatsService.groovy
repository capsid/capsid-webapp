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

class StatsService {

	static transactional = false

	def authService
	def springSecurityService

	List list(Map params) {
		def criteria = Statistics.createCriteria()

		List results = criteria.list(params) {
			and {
				// Project
				if (params.project) {
					if (params.project instanceof String) {
						ilike("label", "%" + params.project + "%")
					}
					else if (params.name instanceof String[]) {
						'in'("label", params.project)
					}
				}

				// Sample
				if (params.sample) {
					if (params.sample instanceof String) {
						ilike("sample", "%" + params.sample + "%")
					}
					else if (params.name instanceof String[]) {
						'in'("sample", params.sample)
					}
				}

				// Genome
				if (params.accession) {
					if (params.accession instanceof String) {
						ilike("accession", "%" + params.accession + "%")
					}
					else if (params.name instanceof String[]) {
						'in'("accession", params.accession)
					}
				}
				if (params.gi) {
					if (params.gi instanceof String) {
						eq("gi", params.gi)
					}
					else if (params.gi instanceof String[]) {
						'in'("gi", params.gi)
					}
				}
				if (params.genome) {
					ilike("genome", params.genome.replaceAll (/\"/, '%'))
				}				
			}
		}

    	return results
	}
}
