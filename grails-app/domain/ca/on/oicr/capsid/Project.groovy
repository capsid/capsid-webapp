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

class Project {

    ObjectId id
    String name
    String label
    String description
    String wikiLink
    Set roles

    static constraints = {
        name unique: true, blank:false
        label unique:true, blank:false, display: false, editable: false, matches:/[\w]+/
        description blank:true
        wikiLink blank:true
        roles blank:false, display:false, editable: false
    }

    static mapping = {}
    static namedQueries = { security { roles -> 'in'("roles", roles) } }
}
