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

	/**
	 * Unique identifier.
	 */
	Integer id

	/**
	 * Left value for the modified preorder tree traversal index.
	 */
	Integer left

	/**
	 * Right value for the modified preorder tree traversal index.
	 */
	Integer right

	/**
	 * Parent taxon identifier.
	 */
	Integer parent

	/**
	 * Scientific name for this taxon.
	 */
	String sciName

	/**
	 * Common name for this taxon.
	 */
	String comName

	/**
	 * Rank for this taxon.
	 */
	String rank

	/**
	 * Use MongoDB for mapping.
	 */
	static mapWith = "mongo"
	
    /**
     * Define the field constraints.
     */
    static constraints = {}

    /**
     * Mapping attributes.
     */
	static mapping = {
		collection "taxa"
        version false
        stateless true
        id generator: 'assigned'
    }
}
