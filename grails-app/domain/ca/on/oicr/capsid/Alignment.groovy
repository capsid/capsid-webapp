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

class Alignment {
	static mapWith = 'mongo'
	
	ObjectId id
	String name
	String aligner
	String platform
	String infile
	String outfile
	String type
	
	String sample
	String project
	
    static constraints = {
		name unique:true, nullable:false, blank: false
		aligner nullable:false, blank: false
		platform nullable:false, blank: false
		infile nullable:false, blank: false
		outfile nullable:false, blank: false
		type nullable:false, blank: false
		sample nullable:false, blank: false
		project nullable:false, blank: false
    }
	
	static mapping = { cache true }
	
	static namedQueries = {}
}
