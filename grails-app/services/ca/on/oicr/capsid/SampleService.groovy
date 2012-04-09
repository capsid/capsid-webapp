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
		
		List results = criteria.list(params) {
            and {
                // Security Check
                if (!authService.isCapsidAdmin()) {
                    'in'("roles", authService.getRolesWithAccess(['user', 'collaborator', 'owner']))
                }

                // Filters by label, using project name on client side
                if (params.name) {
                    // Single name param being passed
                    if (params.name instanceof String) {
                        ilike("label", "%" + params.name + "%")
                    }
                    else if (params.name instanceof String[]) {
                        'in'("label", params.name)
                    }
                }
                if (params.project) {
                    // Single project param being passed
                    if (params.project instanceof String) {
                        ilike("label", "%" + params.project + "%")
                    }
                    else if (params.project instanceof String[]) {
                        'in'("label", params.project)
                    }
                }
                if (params.cancer) {
                    // Single cancer param being passed
                    if (params.cancer instanceof String) {
                        ilike("label", "%" + params.cancer + "%")
                    }
                    else if (params.cancer instanceof String[]) {
                        'in'("label", params.cancer)
                    }
                }
                if (params.role) {
                    // Single role param being passed
                    if (params.role instanceof String) {
                        ilike("label", "%" + params.role + "%")
                    }
                    else if (params.role instanceof String[]) {
                        'in'("label", params.role)
                    }
                }
                if (params.source) {
                    // Single source param being passed
                    if (params.source instanceof String) {
                        ilike("label", "%" + params.source + "%")
                    }
                    else if (params.source instanceof String[]) {
                        'in'("label", params.source)
                    }
                }
                if (params.text) {
                    or {
                        ilike("name", params.text.replaceAll (/\"/, '%'))
                        ilike("project", params.text.replaceAll (/\"/, '%'))
                        ilike("description", params.text.replaceAll (/\"/, '%'))
                        ilike("cancer", params.text.replaceAll (/\"/, '%'))
                        ilike("role", params.text.replaceAll (/\"/, '%'))
                        ilike("source", params.text.replaceAll (/\"/, '%'))
                    }
                }
            }
        }
  
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
