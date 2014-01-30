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

class Role {
	
	/**
	 * Unique identifier.
	 */
	ObjectId id

	/**
	 * String authority name for authorization.
	 */
	String authority
	
    /**
     * Define the field constraints.
     */
	static constraints = {
		authority blank: false, unique: true
	}

	/**
	 * Use MongoDB for mapping.
	 */
	static mapWith = "mongo"

    /**
     * Mapping attributes.
     */
	static mapping = { cache true }
}
