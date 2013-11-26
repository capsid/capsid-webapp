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

class User {

    ObjectId id
    String username
    String userRealName
    String email
    String password
    String institute
    String location
    List<Map> bookmarks
    boolean enabled
    boolean accountExpired
    boolean accountLocked
    boolean passwordExpired

    static mapWith = "mongo"

    static transients = ['authorities']

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

    static mapping = {
        password column: '`password`'
    }

    Set<Role> getAuthorities() {
        UserRole.findAllByUser(this).collect { it.role } as Set
    }

    Map accessLevels() {
        Map ret = [:]
        UserRole.findAllByUser(this).each {
            ret[(it.role.authority)] =  it.access
        }
        ret
    }
}
