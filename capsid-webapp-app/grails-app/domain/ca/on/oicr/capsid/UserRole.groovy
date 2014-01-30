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

import org.apache.commons.lang.builder.HashCodeBuilder
import org.bson.types.ObjectId

/**
 * An individual user's role.
 */
class UserRole implements Serializable {

    /**
     * Unique identifier.
     */
    ObjectId id

    /**
     * Reference to the user.
     */
    User user

    /**
     * Reference to the role.
     */
    Role role

    /**
     * Access level.
     */
    String access

    /**
     * Tests to see if two user roles are the same.
     * 
     * @return Boolean true if they are, otherwise false.
     */
    boolean equals(other) {
        if (!(other instanceof UserRole)) {
            return false
        }

        other.user?.id == user?.id &&
        other.role?.id == role?.id
    }

    /**
     * Generates a user role's hash code.
     * 
     * @return Integer hash code.
     */
    int hashCode() {
        def builder = new HashCodeBuilder()
        if (user) builder.append(user.id)
        if (role) builder.append(role.id)
        builder.toHashCode()
    }

    /**
     * Finds a given user's role.
     */ 
    static UserRole get(long userId, long roleId) {
        find 'from UserRole where user.id=:userId and role.id=:roleId',
        [userId: userId, roleId: roleId]
    }

    /**
     * Creates the requested user's role.
     */ 
    static UserRole create(User user, Role role, String access = 'user', boolean flush = false) {
        new UserRole(user: user, role: role, access: access).save(flush: flush, insert: true)
    }

    /**
     * Removes the requested user's role.
     */ 
    static boolean remove(User user, Role role, boolean flush = false) {
        UserRole instance = UserRole.findByUserAndRole(user, role)
        instance ? instance.delete(flush: flush) : false
    }

    /**
     * Updates the requested user's role.
     */ 
    static boolean update(User user, Role role, String access, boolean flush = false) {
        UserRole instance = UserRole.findByUserAndRole(user, role)
        instance?.access = access
        instance ? instance.save(flush: flush) : false
    }

    /**
     * Removes all a user's roles.
     */ 
    static void removeAll(User user) {
        UserRole.findAllByUser(user).each { it.delete(flush: true) }
    }

    /**
     * Removes all a references to a given role for all users.
     */ 
    static void removeAll(Role role) {
        UserRole.findAllByRole(role).each { it.delete(flush: true) }
    }

    /**
     * Use MongoDB for mapping.
     */
    static mapWith = "mongo"

    /**
     * Mapping attributes.
     */
    static mapping = {
        // id composite: ['role', 'user']
        version false
    }
}
