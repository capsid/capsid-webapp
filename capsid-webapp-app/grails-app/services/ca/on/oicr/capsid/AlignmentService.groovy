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


    Map buildRelativeAbundanceTree(alignment) {

        // Loosely, this is actually a kind of garbage collection process. Stuff that is too small
        // we mark, and then we can sweep through the tree. 

        // Stage 1, build a real tree. This involves adding in additional placeholders
        // where we need them. 

        Map parentTable = [:] as Map
        Map childTable = [:] as Map
        Map entryTable = [:] as Map
        Map levelTable = [:] as Map
        Map markTable = [:] as Map

        List levels = ["SPECIES", "GENUS", "FAMILY", "ORDER"]
        Map parentLevelMap = [
            "SPECIES": "GENUS",
            "GENUS": "FAMILY",
            "FAMILY": "ORDER",
            "ORDER": "ROOT"
        ]

        // Step 1A. Make the basic tree.
        for(element in alignment.gra) {
            String level = element["level"]
            String parentLevel = parentLevelMap[level]
            String parent = element["parent"] ?: "oi:" + parentLevel  

            entryTable[element["id"]] = element

            if (childTable[parent] == null) childTable[parent] = [] as List
            childTable[parent] << element["id"]

            parentTable[element["id"]] = parent

            if (levelTable[level] == null) levelTable[level] = [] as List
            levelTable[level] << element["id"]
        }

        // Step 1B. Add any required placeholder elements and associations to make top-down traversal work.
        for(level in levels) {
            String key = "oi:" + level  
            String nextLevel = parentLevelMap[level]
            if (nextLevel == null) continue
            String nextParent = "oi:" + nextLevel

            parentTable[key] = nextParent
            if (childTable[nextParent] == null) childTable[nextParent] = [] as List
        }

        // Step 2A. Work down through the tree. Well, probably not actual recursion as we are working
        // a level at a time. At each level, mark the ones we want to keep.
        for(level in levels.reverse()) {
            List elementIds = levelTable[level]

            // These will actually be sorted by score, so we can work through them linearly until we 
            // are done. At each level, keep the entries that match our criteria and mark all the rest
            // for collection. 

            Integer maxCount = 5
            Integer count = 0
            for(elementId in elementIds) {
                markTable[elementId] = (count++ >= maxCount)
            }
        }

        // Step 2B. Recurse through the tree, marking sub elements when we have marked a parent
        // element. 
        def handleMarking = { id, marked ->
            if (marked) markTable[id] = marked
            for(child in childTable[id]) {
                handleMarking(child, markTable[id])
            }
        }

        for(child in childTable["ROOT"]) {
            handleMarking(child, markTable[child])
        }

        // Step 2C. Merge marked child elements. This involves a bottom-up recursion, so we do it
        // in a more interesting way, using the result of a recursive call. Basically, when we find
        // everything for an entity is safe, we can merge and mark. The result 

        // Combines two entities, and all their descendants, which must be marked, into a new 
        // block, which is then returned. 
        def mergeEntities = { id1, id2 ->
            assert childTable[id1].length <= 1
            assert childTable[id2].length <= 1
            assert childTable[id1] == childTable[id2]

            def child = null
            if (childTable[id1].length) {
                child = mergeEntities(childTable[id1][0], childTable[id1][1])
            }

            entryTable[id1]["score"] += entryTable[id2]["score"]
            childTable[parentTable[id2]].remove(id2)
            parentTable.remove(id2)
            childTable.remove(id2)

            if (child) {
                childTable[id1] = [child]
                parentTable[child] = id1
            }
        }

        def handleMerging = { id ->
            List children = childTable[id]
            if (children == null) return
            if (children.length == 0) return

            for(child in children) {
                handleMerging(child)
            }

            List mergable = children.findAll { markTable[it] }
            if (mergable.length > 0) {
                def initial = mergable.pop()
                mergable.inject(initial) { acc, val -> mergeEntities(acc, val) }
            }

            Boolean entirelyMergable = ! children.find { ! markTable[it] }
            if (entirelyMergable) {
                markTable[id] = true
            }
        }

        handleMerging("ROOT")

        // Step 3. We need to recalculate the actual breakdowns from the root down. This
        // assumes that at each level we have a total of 1.0, which gets evenly distributed
        // across everything. 

        def displayTree = { id, depth ->
            StringBuilder sb = new StringBuilder()
            sb.append("         ".substring(0, depth))
            sb.append(id)
            if (markTable[id]) sb.append("*")
            sb.append(" ")
            sb.append(entryTable[id]?.getAt("score"))
            System.err.println(sb.toString())
            
            List children = childTable[id]
            if (children == null) return
            for(child in children) {
                displayTree(child, depth + 2)
            }
        }

        System.err.println("")
        displayTree("ROOT", 0)

//        log.info("Parents: " + parentTable.toString())
//        log.info("Children: " + childTable.toString())
//        log.info("Marked: " + markTable.toString())
    }

    /**
     * Reads the genome relative abundance data from a gven alignment.
     *
     * @param alignment the alignment.
     */
    String genomeRelativeAbundance(Alignment alignment) {

        // The logic here does make a few assumptions about the basic format of the
        // data, in particular that it is ordered and in bands by rank. The challenge 
        // is to make sure that we handle the hierarchy correctly. Strictly, the best
        // way to handle that is to handle the clipping only at the species level, and 
        // then to use that to accumulate at parent levels. Parent levels then get
        // accumulated only when all their child levels are accumulated. If we have 
        // 10 species, we cannot have >10 genera, and so on, but what determines which
        // are accumulated is different. 

        buildRelativeAbundanceTree(alignment)

        List input = alignment.gra
        Integer maxCount = 5
        Integer count = 0
        Boolean accumulating = false

        BasicDBList result = [] as BasicDBList
        Integer i = 0
        String currentRank

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

        log.info result.toString()

        return result.toString()
    }
}
