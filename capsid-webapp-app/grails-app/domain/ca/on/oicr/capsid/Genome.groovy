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

class Genome {

    ObjectId id
    List<String> taxonomy
    List<ObjectId> samples
    Integer sampleCount
    String accession
    String version
    String name
    String strand
    Long length
    Long gi
    String organism

    static mapWith = "mongo"
    static constraints = {}
    static mapping = {
        version false
        stateless true
    }
}
