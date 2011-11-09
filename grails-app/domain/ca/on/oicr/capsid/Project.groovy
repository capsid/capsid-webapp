/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*    This program and the accompanying materials are made available under the
*    terms of the GNU Public License v3.0.
*
*    You should have received a copy of the GNU General Public License along with
*    this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import org.bson.types.ObjectId

class Project {
    static mapWith = 'mongo'

    ObjectId id
    String name
    String label
    String description
    String wikiLink
    Set roles

    static constraints = {
        name unique: true, nullable:false, blank:false
        label unique:true, nullable:false, blank:false, matches:/[\w]+/
        description nullable:false, blank:true
        wikiLink nullable:true, blank:true
        roles nullable:false, blank:false
    }

    static mapping = { cache true }

    static namedQueries = {
        security { roles ->
            'in'("roles", roles)
        }
    }
}
