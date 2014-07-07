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

/**
 * Service to handle project data access. 
 */
class ProjectService {

  /**
   * Don't use transactions. 
   */
  static transactional = false

  /**
   * Dependency injection for the AuthService.
   */
  def authService

  /**
   * Dependency injection for the SpringSecurityService.
   */
  def springSecurityService

  /**
   * Finds a requested project
   *
   * @param label the project label.
   * @return the project.
   */
  Project get(label) {
	  Project.findByLabel label
	}

  /**
   * Finds a requested project by identifier
   *
   * @param identifier the project identifier.
   * @return the project.
   */
  Project getById(identifier) {
    Project.get identifier
  }

  /**
   * Finds all projects matching the given criteria
   *
   * @param params a map of the search criteria from the original request.
   * @return a list of projects.
   */
  List list(Map params) {
	  def criteria = Project.createCriteria()
	  
	  criteria.list(params) {
		  and {
			  // Security Check
			  //if (!authService.isCapsidAdmin()) {
				//  'in'("roles", authService.getRolesWithAccess(['user', 'collaborator', 'owner']))
			  //}

			  // Filters by label, using project name on client side
			  if (params?.name) {
				  // Single name param being passed
				  if (params.name instanceof String) {
					  ilike("label", "%" + params.name + "%")
				  }
				  else if (params.name instanceof String[]) {
					  'in'("label", params.name)
				  }
			  }
			  if (params.text) {
          String text = '%' + params.text + '%'
          or {
            ilike("name", text)
            ilike("label", text)
            ilike("description", text)
          }
			  }
		  }
	  }
  }

  /**
   * Returns a list of projects the current user is allowed to access.
   * 
   * @return a list of projects
   */
  List<Project> getAllowedProjects() {
    if (authService.isCapsidAdmin()) {
      Project.list()
    } else {
      Project.security(authService.getRolesWithAccess(['user', 'collaborator', 'owner'])).list()
    }
  }

  /**
   * Deletes data associated with a given project.
   * 
   * @param label the project label.
   */
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
