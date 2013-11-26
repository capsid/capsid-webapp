package ca.on.oicr.capsid

/*
 *  Copyright 2013(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Domain class definition for a taxonomy entry. The left and right fields are 
 * present to provide a nested set model for navigating the hierarchy efficiently. 
 */
class Taxon {

	Integer id

	Integer left
	Integer right
	Integer parent
	String sciName
	String comName
	String rank

	static mapWith = "mongo"
	
    static constraints = {}

	static mapping = {
		collection "taxa"
        version false
        stateless true
        id generator: 'assigned'
    }
}
