/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*	This program and the accompanying materials are made available under the
*	terms of the GNU Public License v3.0.
*
*	You should have received a copy of the GNU General Public License along with
*	this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import org.bson.types.ObjectId

class Sample {
	static mapWith = 'mongo'
	
	ObjectId id
	String name
	String description
	String role
	String source
	String cancer
	String project
	
    static constraints = {
		name unique:true, nullable:false, blank:false
		description nullable:false, blank:true
		cancer nullable:false, blank:true
		role nullable:false, blank:true
		source nullable:false, blank:true
		project nullable:false, blank:false
    }
	
	static mapping = { cache true }
	
	static namedQueries = { security { label -> 'in'("project", label) } }
}
