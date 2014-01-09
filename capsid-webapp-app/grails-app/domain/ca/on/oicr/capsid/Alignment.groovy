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
 * An alignment for a given sample.
 */
class Alignment {

	/**
	 * Unique identifier.
	 */
	ObjectId id

	/**
	 * Alignment name.
	 */
	String name

	/**
	 * The aligner used.
	 */
	String aligner

	/**
	 * The platform.
	 */
	String platform

	/**
	 * The input file name.
	 */
	String infile

	/**
	 * The outpt file name.
	 */
	String outfile

	/**
	 * The alignment type.
	 */
	String type

	/**
	 * Reference to the sample.
	 */
	ObjectId sampleId

	/**
	 * The name of the sample.
	 */
	String sample

	/**
	 * Reference to the project.
	 */
	ObjectId projectId

	/**
	 * The name of the project.
	 */
	String projectLabel

	/**
	 * Use MongoDB for mapping.
	 */
	static mapWith = "mongo"

	/**
	 * Define the field constraints.
	 */
    static constraints = {
		name unique:'sampleId', blank: false, display: false, matches: /[\w\d\-]+/
		aligner blank: true
		platform blank: true
		type blank: true
		infile blank: true, widget: 'textarea'
		outfile blank: true, widget: 'textarea'
		sample blank: false
		projectLabel blank: false
		sampleId nullable: false, editable: false, validator: { val -> val in Sample.list()._id }
		projectId nullable: false, editable: false, validator: { val -> val in Project.list()._id }
    }

	/**
	 * Mapping attributes.
	 */
	static mapping = { cache true }

	/**
	 * Named queries.
	 */
	static namedQueries = {}
}
