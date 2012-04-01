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

class ProjectService {

  static transactional = false

  def authService
  def springSecurityService

  Project get(label) {
	  Project.findByLabel label
	}

  List list(Map params) {
	  def criteria = Project.createCriteria()
	  
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
			  if (params.text) {
			    ilike("description", params.text.replaceAll (/\"/, '%'))
			  }
		  }
	  }

    results.each {
      it['sampleCount'] = Sample.countByProject(it.label)
    }

    return results
  }

  List<Project> getAllowedProjects() {
    if (authService.isCapsidAdmin()) {
      Project.list()
    } else {
      Project.security(authService.getRolesWithAccess(['user', 'collaborator', 'owner'])).list()
    }
  }

  void delete(String label) {
    // Delete the ACL information as well
    Role role = Role.findByAuthority('ROLE_' + label.toUpperCase())
    UserRole.removeAll role
    role.delete()

    // Remove elements associated with the project
    Sample.findAllByProject(label).each { it.delete(flush: true) }
    Alignment.findAllByProject(label).each { it.delete(flush: true) }
    Mapped.findAllByProject(label).each { it.delete(flush: true) }
  }
}
