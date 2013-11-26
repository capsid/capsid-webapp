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

import org.bson.types.ObjectId
import grails.plugins.springsecurity.Secured

class StatsService {

	static transactional = false

	def authService
	def projectService
	def springSecurityService

	List list(Map params) {

		// If we have a taxon identifier, we should use this as a filter. To do so, we
		// need to get the taxon and use its left/right values as a between filter on 
		// the left in the statistics. 
		Taxon tx = null;
		if (params.taxonRootId) {
			tx = Taxon.findById(params.taxonRootId);
		}

		def criteria = Statistics.createCriteria()

		log.info("Params: " + params.toString())

		List results = criteria.list(params) {
			and {
				// Security Check
                //'in'("label", projectService.list([:]).label)
            
            	// Project
				// if (params.label) {
				// 	if (params.label instanceof String) {
				// 		eq("label",params.label)
				// 	}
				// }
				if (params.projectId) {
					if (params.projectId instanceof ObjectId) {
						eq("projectId", params.projectId)
					}
					else if (params.projectId instanceof ObjectId[]) {
						'in'("projectId", params.projectId)
					}
				}

				// And this adds the filter on taxon range, if we need it. 
				if (tx != null) {
					between("left", tx.left, tx.right);
				}

				// Alignment
				if (params.alignmentId) {
					if (params.alignmentId == 'only') {
						isNotNull('alignmentId')
					}
					else if (params.alignmentId == 'none') {
						isNull('alignmentId')
					}
					else if (params.alignmentId instanceof ObjectId) {
						eq("alignmentId", params.alignmentId)
					}
					else if (params.alignmentId instanceof ObjectId[]) {
						'in'("alignmentId", params.alignmentId)
					}
				}

				// Sample
				if (params.sampleId) {
					if (params.sampleId == 'only') {
						isNotNull('sampleId')
					}
					else if (params.sampleId == 'none') {
						isNull('sampleId')
					}
					else if (params.sampleId instanceof ObjectId) {
						eq("sampleId", params.sampleId)
					}
					else if (params.sampleId instanceof ObjectId[]) {
						'in'("sampleId", params.sampleId)
					}
				}

				// Genome
				if (params.accession) {
					if (params.accession instanceof String) {
						eq("accession", params.accession)
					}
					else if (params.name instanceof String[]) {
						'in'("accession", params.accession)
					}
				}
				if (params.genome) {
					ilike("genome", '%' + params.genome + '%')
				}	

				// Text
				if (params.text) {
					String text = '%' + params.text + '%'
					or {
						ilike("genome", text)
						ilike("sample", text)
						ilike("project", text)
					}
				}

				// Filters
				if (params.filters && params.filters != "false") {
					'in'("filter", params.filters)
				}		
			}
		}

    	return results
	}
}
