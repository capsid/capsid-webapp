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

/**
 * A user record.
 */
class User {

    /**
     * Unique identifier.
     */
    ObjectId id

    /**
     * Username.
     */
    String username

    /**
     * The user's real name.
     */
    String userRealName

    /**
     * The user's email address.
     */
    String email

    /**
     * The user's password.
     */
    String password

    /**
     * The user's institution.
     */
    String institute

    /**
     * The user's location.
     */
    String location

    /**
     * The user's bookmarks.
     */
    List<Map> bookmarks

    /**
     * Flag to indicate the account is enabled.
     */
    boolean enabled

    /**
     * Flag to indicate the account is expired.
     */
    boolean accountExpired

    /**
     * Flag to indicate the account is locked.
     */
    boolean accountLocked

    /**
     * Flag to indicate the password is expired.
     */
    boolean passwordExpired

    /**
     * Use MongoDB for mapping.
     */
    static mapWith = "mongo"

    /**
     * Don't persist the authorities.
     */
    static transients = ['authorities']

    /**
     * Define the field constraints.
     */
    static constraints = {
        username blank: false, unique: true, display: false
        userRealName blank: true, nullable: true
        email blank: false, nullable: true, email: true
        password blank: false, display: false
        institute blank: true, nullable: true
        location blank: true, nullable: true    
		enabled display: false
	    accountExpired display: false
	    accountLocked display: false
	    passwordExpired display: false
        bookmarks display: false, editable: false
    }

    /**
     * Mapping attributes.
     */
    static mapping = {
        password column: '`password`'
    }

    /**
     * Return a set of authority roles.
     *
     * @return Set of roles
     */
    Set<Role> getAuthorities() {
        log.debug("Requesting authorities for: " + username + " using " + id.toString())
        UserRole.findAllByUser(this).collect { it.role } as Set
    }

    /**
     * Return a map of access levels.
     *
     * @return Map of access levels
     */
    Map accessLevels() {
        log.debug("Requesting access levels for: " + username)
        Map ret = [:]
        UserRole.findAllByUser(this).each {
            ret[(it.role.authority)] =  it.access
        }
        log.debug("Access levels for: " + username + " are " + ret)
        ret
    }
}
