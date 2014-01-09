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
 * A sample.
 */
class Sample {
	
	/**
	 * Unique identifier.
	 */
	ObjectId id

	/**
	 * Sample name.
	 */
	String name

	/**
	 * Sample description.
	 */
	String description

	/**
	 * Sample role.
	 */
	String role

	/**
	 * Sample source.
	 */
	String source

	/**
	 * Sample cancer type.
	 */
	String cancer

	/**
	 * Project label.
	 */
	String projectLabel

	/**
	 * Reference to the project.
	 */
	ObjectId projectId
	
    /**
     * Define the field constraints.
     */
    static constraints = {
		name unique:'projectId', blank:false, display: false, matches: /[\w\d\-]+/
		description blank:true, widget: 'textarea'
		cancer blank:true
		role blank:true
		source blank:true
		projectLabel blank:false
		projectId nullable:false, editable: false, validator: { val -> val in Project.list()._id }
    }
	
	/**
	 * Use MongoDB for mapping.
	 */
	static mapWith = "mongo"

    /**
     * Mapping attributes.
     */
	static mapping = {}
	
	/**
	 * Named queries.
	 */
	static namedQueries = { security { label -> 'in'("project", label) } }
}
