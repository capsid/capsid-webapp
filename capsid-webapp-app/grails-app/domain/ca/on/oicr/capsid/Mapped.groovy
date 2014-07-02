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
 * A mapped read.
 */
class Mapped {

    /**
     * Unique identifier.
     */
    ObjectId id

    /**
     * Read identifier.
     */
    String readId

    /**
     * Average quality.
     */
    Float avgQual

    /**
     * Minimum quality.
     */
    Float minQual

    /**
     * The mapq value.
     */
    Integer mapq

    /**
     * Number of miscalls.
     */
    Integer miscalls

    /**
     * Number of mismatches.
     */
    Integer mismatch

    /**
     * Reference strand.
     */
    Integer refStrand

    /**
     * Read length.
     */
    Integer readLength

    /**
     * Aligned length.
     */
    Integer alignLength

    /**
     * Start position on the reference.
     */
    Integer refStart

    /**
     * End position on the reference.
     */
    Integer refEnd

    /**
     * Sequencing type.
     */
    String sequencingType

    /**
     * Sequencing platform.
     */
    String platform

    /**
     * List of mapped genes.
     */
    List mapsGene

    /**
     * List of mapped genes.
     */
    List cigar

    /**
     * The actual sequence.
     */
    String sequence

    /**
     * Alignment score.
     */
    Integer alignScore

    /**
     * Genome identifier.
     */
    Long genome

    /**
     * Reference to the alignment.
     */
    ObjectId alignmentId

    /**
     * Reference to the project.
     */
    ObjectId projectId

    /**
     * Reference to the sample.
     */
    ObjectId sampleId

    /**
     * Alignment name.
     */
    String alignment

    /**
     * Project label.
     */
    String projectLabel

    /**
     * Sample name.
     */
    String sample

    /**
     * Use MongoDB for mapping.
     */
    static mapWith = "mongo"

    /**
     * Define the field constraints.
     */
    static constraints = {
                
    }

    /**
     * Mapping attributes.
     */
    static mapping = {
            cache false
            version false
            stateless true
    }

    /**
     * Named queries.
     */
    static namedQueries = {

    }
}
