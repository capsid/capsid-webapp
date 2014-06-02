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
 * Service to handle authorization. 
 */
class AuthService {

  /**
   * Dependency injection for the SpringSecurityService.
   */
  def springSecurityService

  /**
   * Don't use transactions. 
   */
  static transactional = false

  /**
   * Finds the roles assigned for the current user. 
   * 
   * @return a list of roles.
   */
  List getRoles() {
    String authorities = springSecurityService.principal.authorities.toString()
    List result = authorities.replaceAll(~"[\\[\\] ]", "").tokenize(',')
    log.debug("Calling getRoles: authorities: " + authorities + " => " + result)
    return result
  }

  /**
   * Finds the current user. 
   * 
   * @return the current user.
   */
  User getCurrentUser() {
    User.findByUsername(springSecurityService.principal.username)
  }

  /**
   * Reauthenticates the current user. 
   */
  void reauthenticate(User user) {
    if (springSecurityService.isLoggedIn() &&
        springSecurityService.principal.username == user.username) {
      springSecurityService.reauthenticate user.username
    }
  }

  /**
   * Returns the access levels for the specified user. 
   * 
   * @param user the specified user, which defaults to the current user.
   * @return a map of access levels.
   */
  Map getAccessLevels(User user = getCurrentUser()) {
    if (user) {
      user.accessLevels()
    } else {
      // creates user if logging in through ldap for the first time
      Map params = [:]
      params.username = springSecurityService.principal.username
      params.password = springSecurityService.encodePassword(getRandomString(8))
      params.enabled = true
      User userInstance = new User(params)
      userInstance.save(flush: true)
      Role roleInstance = Role.findByAuthority('ROLE_CAPSID')
      UserRole.create userInstance, roleInstance, 'user'
      userInstance.accessLevels()
    }
  }

  /**
   * Returns the roles with the requested access level. 
   * 
   * @param level the access level.
   * @return a list of roles.
   */
  List getRolesWithAccess(List level) {
    Map accessLevels = getAccessLevels()
    List result = accessLevels.findAll {
      it.value in level
    }.keySet() as List
    log.debug("getRolesWithAccess: result: " + result.toString())
    return result
  }

  /**
   * Returns the user roles with the given role name. 
   * 
   * @param roleName the role.
   * @return a list of user roles.
   */
  List<UserRole> getUsersWithRole(String roleName) {
    Role role = Role.findByAuthority(roleName)
    List<UserRole> users = UserRole.findAllByRole(role)
  }

  /**
   * Checks if the specified user is an administrator.
   *
   * @param user the specified user, which defaults to the current user.
   * @return true if the specified user is an administrator
   */
  boolean isCapsidAdmin(User user = getCurrentUser()) {
    Map access = getAccessLevels(user)
    access.get('ROLE_CAPSID') == 'owner'
  }

  /**
   * Checks if the specified user is the current user.
   *
   * @param user the specified user.
   * @return true if the specified user is the current user
   */
  boolean isCurrentUser(User user) {
    user == getCurrentUser()
  }

  /**
   * Checks authorization for the specified project.
   *
   * @param project the specified project.
   * @param access the required access.
   * @return true if access is allowed.
   */
  boolean authorize(Project project, List access) {
    isCapsidAdmin() || !project?.roles?.disjoint(getRolesWithAccess(access))
  }

  /**
   * Checks authorization for the specified sample.
   *
   * @param sample the specified sample.
   * @param access the required access.
   * @return true if access is allowed.
   */
  boolean authorize(Sample sample, List access) {
    Project project = Project.findById(sample.projectId)
    authorize(project, access)
  }

  /**
   * Checks authorization for the specified mapped read.
   *
   * @param mapped the specified mapped read.
   * @param access the required access.
   * @return true if access is allowed.
   */
  boolean authorize(Mapped mapped, List access) {
    Project project = Project.findById(mapped.projectId)
    authorize(project, access)
  }

  /**
   * Checks authorization for the specified alignment.
   *
   * @param alignment the specified alignment.
   * @param access the required access.
   * @return true if access is allowed.
   */
  boolean authorize(Alignment align, List access) {
    Project project = Project.findByLabel(align.project)
    authorize(project, access)
  }

  /**
   * Checks authorization for the specified roles.
   *
   * @param roles the specified roles.
   * @param access the required access.
   * @return true if access is allowed.
   */
  boolean authorize(List roles, List access) {
    isCapsidAdmin() || !roles?.disjoint(getRolesWithAccess(access))
  }

  /**
   * Checks authorization for the specified user.
   *
   * @param user the specified user.
   * @return true if access is allowed.
   */
  boolean authorize(User user) {
    isCapsidAdmin() || user?.username == springSecurityService.principal.username
  }

  /**
   * Generates a random character string.
   *
   * @param length the number of characters.
   * @return the random string.
   */
  String getRandomString(length) {
    String charset = "!0123456789abcdefghijklmnopqrstuvwxyz";
    Random rand = new Random(System.currentTimeMillis());
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < length; i++) {
      int pos = rand.nextInt(charset.length());
      sb.append(charset.charAt(pos));
    }
    return sb.toString();
  }
}
