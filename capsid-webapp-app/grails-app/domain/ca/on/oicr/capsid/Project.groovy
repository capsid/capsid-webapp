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
 * A project.
 */
class Project {

    /**
     * Unique identifier.
     */
    ObjectId id

    /**
     * The project name.
     */
    String name

    /**
     * The project label.
     */
    String label

    /**
     * The project description.
     */
    String description

    /**
     * Link to the project.
     */
    String wikiLink

    /**
     * A set of roles for authorization.
     */
    Set roles

    static constraints = {
        name unique: true, blank:false
        label unique:true, blank:false, display:false, matches:/[\w\d\-]+/
        description blank:true, widget: 'textarea'
        wikiLink blank:true, url: true
        roles display:false, editable: false
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
    static namedQueries = {}
}
