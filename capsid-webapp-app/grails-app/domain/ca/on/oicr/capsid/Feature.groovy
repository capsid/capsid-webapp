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
 * A feature for a given genome.
 */
class Feature {
	
    /**
     * Unique identifier.
     */
	ObjectId id

    /**
     * Unique string identifier.
     */
    String uid

    /**
     * The locus tag.
     */
    String locusTag

    /**
     * The operator.
     */
    String operator

    /**
     * The name of the feature.
     */
    String name

    /**
     * Strand, +1 or -1.
     */
    Integer strand

    /**
     * Start position in genomic coordinates.
     */
    Integer start

    /**
     * End position in genomic coordinates.
     */
    Integer end

    /**
     * The gene identifier, if a gene.
     */
    Integer geneId

    /**
     * The type of feature, e.g., CDS, gene.
     */
    String type

    /**
     * The genome identifier, an integer.
     */
    Long genome

    /**
     * Use MongoDB for mapping.
     */
    static mapWith = "mongo"

    /**
     * Define the field constraints.
     */
    static constraints = {}

    /**
     * Mapping attributes.
     */
	static mapping = {
        version false
        stateless true
    }
}
