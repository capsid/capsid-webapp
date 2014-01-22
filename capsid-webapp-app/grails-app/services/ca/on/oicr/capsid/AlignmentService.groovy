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
import com.mongodb.BasicDBList
import grails.plugins.springsecurity.Secured

/**
 * Service to handle alignment data access. 
 */
class AlignmentService {

    /**
     * Don't use transactions. 
     */
    static transactional = false

    /**
     * Dependency injection for the AuthService.
     */
    def authService

    /**
     * Dependency injection for the ProjectService.
     */
    def projectService

    /**
     * Dependency injection for the SpringSecurityService.
     */
    def springSecurityService

    /**
     * Finds a requested alignment
     *
     * @param name the alignment name.
     * @param projectId the project identifier.
     * @param sampleId the sample identifier
     * @return the alignment.
     */
    Alignment get(String name, ObjectId projectId, ObjectId sampleId) {
        return Alignment.createCriteria().get {
            eq("projectId", projectId)
            eq("sampleId", sampleId)
            eq("name", name)
        }
    }

    /**
     * Finds all alignments matching the given criteria
     *
     * @param params a map of the search criteria from the original request.
     * @return a list of alignments.
     */
    List list(Map params) {
        def criteria = Alignment.createCriteria()

        List results = criteria.list(params) {
            and {
                // Security Check
                //'in'("project", projectService.list([:]).label)

                // Sample
                if (params.sampleId) {
                    if (params.sampleId instanceof ObjectId) {
                        eq("sampleId", params.sampleId)
                    }
                    else if (params.sampleId instanceof ObjectId[]) {
                        'in'("sampleId", params.sampleId)
                    }
                }

                // Text
                if (params.text) {
                    String text = '%' + params.text + '%'
                    or {
                        ilike("name", text)
                        ilike("sample", text)
                        ilike("projectLabel", text)
                    }
                }
            }
        }
  
        return results
    }

    /**
     * Deletes all mapped reads relating to a given alignment.
     *
     * @param alignment the alignment to search for.
     */
    void delete(String alignment) {
        Mapped.findAllByAlignment(alignment).each { it.delete(flush: true) }
    }

    /**
     * Reads the genome relative abundance data from a gven alignment.
     *
     * @param alignment the alignment.
     */
    String genomeRelativeAbundance(Alignment alignment) {

        // The logic here does make a few assumptions about the basic format of the
        // data, in particular that it is ordered and in bands by rank.

        Integer maxCount = 10
        BasicDBList result = [] as BasicDBList
        Integer i = 0
        Integer count = 0
        String currentRank
        Boolean accumulating = false
        List input = alignment.gra

        for(element in input) {
            String rank = element["level"]
            if (rank == "SEQUENCE")
                continue;

            if (rank == currentRank) {
                if (accumulating) {
                    result.last()["score"] += element["score"]
                } else if (count++ == maxCount) {
                    result << element
                    result.last()["name"] = "Other"
                    result.last()["id"] = "oi:"
                    accumulating = true
                } else {
                    result << element
                }
            } else {
                count = 0
                accumulating = false
                currentRank = rank
                result << element
            }
        }

        return result.toString()
    }
}
