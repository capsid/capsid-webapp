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

import java.util.List;
import java.util.Map;

import grails.plugins.springsecurity.Secured

class SampleService {

    static transactional = false

    def authService
    def projectService

    Sample get(String name) {
        Sample.findByName name
    }

	List list(Map params) {
		def criteria = Sample.createCriteria()
		
		List results = criteria.list(params) {}
  
		return results
	}

    List<Sample> getAllowedSamples() {
        if (authService.isCapsidAdmin()) {
            Sample.list()
        } else {
            Sample.security(projectService.getAllowedProjects()?.label)?.list()
        }
    }

    void delete(String sample) {
        Alignment.findAllBySample(sample).each { it.delete(flush: true) }
        Mapped.findAllBySample(sample).each { it.delete(flush: true) }
    }
}
