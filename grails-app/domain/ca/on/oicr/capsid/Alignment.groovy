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

class Alignment {

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
		name unique:true, blank: false, display: false, matches: /[\w\d\-]+/
		aligner blank: true
		platform blank: true
		type blank: true
		infile blank: true, widget: 'textarea'
		outfile blank: true, widget: 'textarea'
		sample blank: false, editable: false, validator: { val -> val in Sample.list().name }
		project blank: false, editable: false, validator: { val -> val in Project.list().label }
    }

	static mapping = { cache true }

	static namedQueries = {}
}
