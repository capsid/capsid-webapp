/*
* Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
*
* This program and the accompanying materials are made available under the
* terms of the GNU Public License v3.0.
*
* You should have received a copy of the GNU General Public License along with
* this program. If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

/**
* Authorization tags.
*
*/
class AuthTagLib {

    /** Set the namespace. */
    static namespace = 'auth'

    /** Dependency injection for AuthService. */
    def authService

    /** Dependency injection for springSecurityService. */
    def springSecurityService

    /**
    * Renders the body if any of the specified roles are granted to the user. Roles are
    * specified in the 'roles' attribute which is a comma-delimited string.
    *
    * @attr roles REQUIRED the role name(s)
    */
    def ifAnyGranted = { attrs, body ->
        boolean access = false
        Map roles = assertAttribute('access', attrs, 'ifAnyGranted')
        Map user = authService.getAccessLevels()

        if (authService.isCapsidAdmin()) {
            access = true
        } else {
            roles.each { k,v ->
                if (user['ROLE_' + k.toUpperCase()] in v) {
                    access = true
                }
            }
        }

        if (access) {
            out << body()
        }
    }

    /**
     * Checks if an administrator and includes the body if so.
     */
    def ifCapsidAdmin = { attrs, body ->
        if (authService.isCapsidAdmin()) {
            out << body()
        }
    }

    /**
     * Checks if the current user matches and includes the body if so.
     */
    def ifCurrentUser = { attrs, body ->
        String username = assertAttribute('username', attrs, 'ifCurrentUser')
        User userInstance = User.findByUsername(username)
        if (authService.isCurrentUser(userInstance)) {
            out << body()
        }
    }

    /**
     * Asserts that a given attribute is present.
     */
    protected assertAttribute(String name, attrs, String tag) {
        if (!attrs.containsKey(name)) {
            throwTagError "Tag [$tag] is missing required attribute [$name]"
        }
        attrs.remove name
    }
}