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

class Sample {
	
	ObjectId id
	String name
	String description
	String role
	String source
	String cancer
	String projectLabel
	ObjectId projectId
	
    static constraints = {
		name unique:'projectId', blank:false, display: false, matches: /[\w\d\-]+/
		description blank:true, widget: 'textarea'
		cancer blank:true
		role blank:true
		source blank:true
		projectLabel blank:false
		projectId nullable:false, editable: false, validator: { val -> val in Project.list()._id }
    }
	
	static mapWith = "mongo"
	static mapping = {}
	
	static namedQueries = { security { label -> 'in'("project", label) } }
}
