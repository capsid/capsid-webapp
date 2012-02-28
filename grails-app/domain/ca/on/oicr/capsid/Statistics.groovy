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

class Statistics {
	static mapWith = 'mongo'
	
	ObjectId id
	Integer threshold
	Integer hits
	Integer geneHits
	Float totalCoverage
	Float geneCoverage
	Float maxCoverage
	String projectId
	String projectLabel
	String projectName
	String genomeId
	String genomeAccession
	String genomeName
	String sampleId
	String sampleName
	
    static constraints = { }
	
    static mapping = { cache true }
	
	static namedQueries = {	}
}

