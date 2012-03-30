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

class FeatureService {

    static transactional = false

    Feature get(String uid) {
        Feature.findByUid uid
    }

    List list(Map params) {
		def criteria = Feature.createCriteria()
		
		List results = criteria.list(params) {
			eq('type', 'gene')
		}
  
		return results
	}
}
