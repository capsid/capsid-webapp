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
 * A statistics object, representing aggregated read mapping data.
 */
class Statistics {
	
	/**
	 * Unique identifier.
	 */
	ObjectId id

	/**
	 * Reference to the project.
	 */
	ObjectId projectId

	/**
	 * The project name.
	 */
	String project

	/**
	 * The project label.
	 */
	String projectLabel

	/**
	 * The sample name.
	 */
	String sample

	/**
	 * Reference to the sample.
	 */
	ObjectId sampleId

	/**
	 * The alignment name.
	 */
	String alignment

	/**
	 * Reference to the alignment.
	 */
	ObjectId alignmentId

	/**
	 * The genome string name.
	 */
	String genome

	/**
	 * Numeric genome identifier.
	 */
	Integer gi

	/**
	 * Reference to the genome.
	 */
	ObjectId genomeId

	/**
	 * Left position for the modified preorder tree traversal index.
	 */
	Integer left

	/**
	 * Srring accession identifier.
	 */
	String accession

	/**
	 * Number of hits against the genome.
	 */
	Integer genomeHits

	/**
	 * Number of hits against a gene.
	 */
	Integer geneHits

	/**
	 * Genome coverage.
	 */
	Float genomeCoverage

	/**
	 * Average gene coverage.
	 */
	Float geneCoverageAvg

	/**
	 * Maximum gene coverage.
	 */
	Float geneCoverageMax

	/**
	 * A set of filter attributes for dynamic queries.
	 */
	Set filter

	/**
	 * Use MongoDB for mapping.
	 */
	static mapWith = "mongo"

    /**
     * Define the field constraints.
     */
    static constraints = { }

    /**
     * Mapping attributes.
     */
    static mapping = { version false }

	/**
	 * Named queries.
	 */
	static namedQueries = {	}
}

