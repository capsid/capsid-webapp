/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*	This program and the accompanying materials are made available under the
*	terms of the GNU Public License v3.0.
*
*	You should have received a copy of the GNU General Public License along with
*	this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
* Authorization tags.
*
*/
class AuthTagLib {

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

        if (user['ROLE_CAPSID'] == 'owner') {
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

    protected assertAttribute(String name, attrs, String tag) {
        if (!attrs.containsKey(name)) {
            throwTagError "Tag [$tag] is missing required attribute [$name]"
        }
        attrs.remove name
    }
}
