package ca.on.oicr.capsid

/*
 *  Copyright 2011(c) The Ontario Institute for Cancer Research. All rights reserved.
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the GNU Public License v3.0.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import grails.converters.JSON

/**
 * Controller class for the taxon controller.
 */
class TaxonController {

	/**
	 * The api action.
     * 
     * If the parent parameter is set, returns JSON for all the child taxa. If the
     * ancestors parameter is set, returns JSON for all the ancestor taxa. 
	 */
    def api() {

    	if (params.parent) {

    		List<Taxon> result = Taxon.findAllByParent(params.parent).toArray() 
    		result.sort { a,b -> 
    			Integer difference = (b.right - b.left) - (a.right - a.left)
    			return difference;
    		}.collect { it.right - it.left }

    		render result as JSON  

    	} else if (params.ancestors) {

    		Integer identifier = params.ancestors.toInteger();
    		List<Taxon> result = [] as List<Taxon>;
    		while(identifier != 1) {
    			Taxon tx = Taxon.findById(identifier);
    			result.add(tx);
    			identifier = tx.parent;
    		}
    		render result as JSON  
    	}
    }
}
