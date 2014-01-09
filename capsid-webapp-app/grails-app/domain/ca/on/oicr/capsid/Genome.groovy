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
 * A genome.
 */
class Genome {

    /**
     * Unique identifier.
     */
    ObjectId id

    /**
     * The taxonomy, a path of ancestors.
     */
    List<String> taxonomy

    /**
     * List of associated samples.
     */
    List<ObjectId> samples

    /**
     * Count of associated samples.
     */
    Integer sampleCount

    /**
     * Accession string.
     */
    String accession

    /**
     * Version string.
     */
    String version

    /**
     * Genome name.
     */
    String name

    /**
     * Genome strand.
     */
    String strand

    /**
     * Genome length.
     */
    Long length

    /**
     * Genome numeric identifier.
     */
    Long gi

    /**
     * Organism name.
     */
    String organism

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
