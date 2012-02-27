/*
*  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
*
*	This program and the accompanying materials are made available under the
*	terms of the GNU Public License v3.0.
*
*	You should have received a copy of the GNU General Public License along with
*	this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import org.bson.types.ObjectId

class Feature {
	static mapWith = 'mongo'
	
	ObjectId id
    String locusTag
    String operator
    String name
    Integer strand
    Integer start
    Integer end
    Integer geneId
    String type
    Integer genome

    static constraints = {
    }
	
	static mapping = {
		cache true
	}
}
