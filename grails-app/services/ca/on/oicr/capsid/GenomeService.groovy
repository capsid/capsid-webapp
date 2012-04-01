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

class GenomeService {

    static transactional = false

    Genome get(String accession) {
        Genome.findByAccession accession
    }

    List list(Map params) {
		def criteria = Genome.createCriteria()
		
		List results = criteria.list(params) {
			and {
				if (params.accession) {
					// Single name param being passed
					if (params.accession instanceof String) {
						ilike("accession", "%" + params.accession + "%")
					}
					else if (params.accession instanceof String[]) {
						'in'("accession", params.accession)
					}
				}
				if (params.gi) {
					// Single name param being passed
					if (params.gi instanceof String) {
						ilike("gi", "%" + params.gi + "%")
					}
					else if (params.gi instanceof String[]) {
						'in'("gi", params.gi)
					}
				}
				if (params.name) {
					// Single name param being passed
					if (params.name instanceof String) {
						ilike("name", "%" + params.name + "%")
					}
					else if (params.name instanceof String[]) {
						'in'("gi", params.name)
					}
				}
				if (params.taxonomy) {
					// Single name param being passed
					if (params.taxonomy instanceof String) {
						ilike("taxonomy", "%" + params.taxonomy + "%")
					}
					else if (params.taxonomy instanceof String[]) {
						'in'("taxonomy", params.taxonomy)
					}
				}
				if (params.text) {
				  ilike("accession", params.text.replaceAll (/\"/, '%'))
				  ilike("gi", params.text.replaceAll (/\"/, '%'))
				  ilike("name", params.text.replaceAll (/\"/, '%'))
				  ilike("taxonomy", params.text.replaceAll (/\"/, '%'))

				}
			}
		}
  
		return results
	}
}
