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

class UserRole implements Serializable {

    ObjectId id
    User user
    Role role
    String access

    boolean equals(other) {
        if (!(other instanceof UserRole)) {
            return false
        }

        other.user?.id == user?.id &&
        other.role?.id == role?.id
    }

    int hashCode() {
        def builder = new HashCodeBuilder()
        if (user) builder.append(user.id)
        if (role) builder.append(role.id)
        builder.toHashCode()
    }

    static UserRole get(long userId, long roleId) {
        find 'from UserRole where user.id=:userId and role.id=:roleId',
        [userId: userId, roleId: roleId]
    }

    static UserRole create(User user, Role role, String access = 'user', boolean flush = false) {
        new UserRole(user: user, role: role, access: access).save(flush: flush, insert: true)
    }

    static boolean remove(User user, Role role, boolean flush = false) {
        UserRole instance = UserRole.findByUserAndRole(user, role)
        instance ? instance.delete(flush: flush) : false
    }

    static boolean update(User user, Role role, String access, boolean flush = false) {
        UserRole instance = UserRole.findByUserAndRole(user, role)
        instance?.access = access
        instance ? instance.save(flush: flush) : false
    }

    static void removeAll(User user) {
        UserRole.findAllByUser(user).each { it.delete(flush: true) }
    }

    static void removeAll(Role role) {
        UserRole.findAllByRole(role).each { it.delete(flush: true) }
    }

    static mapWith = "mongo"
    static mapping = {
        // id composite: ['role', 'user']
        version false
    }
}
