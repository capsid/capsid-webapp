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

class Mapped {
	static mapWith = 'mongo'

	ObjectId id
	String readId
        Float avgQual
        Float minQual
        Integer mapq
        Integer miscalls
        Integer mismatch
        Integer refStrand
        Integer readLength
        Integer alignLength
        Integer refStart
        Integer refEnd
        String sequencingType
        String platform
        List mapsGene
        String sequence

	String genome
	String alignment
	String project
	String sample

	static constraints = {}
	static mapping = {}
	static namedQueries = {}
}
