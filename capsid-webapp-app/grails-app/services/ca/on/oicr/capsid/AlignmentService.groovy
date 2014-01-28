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
import com.mongodb.BasicDBObject
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


    List buildRelativeAbundanceTree(alignment) {

        // Loosely, this is actually a kind of garbage collection process. Stuff that is too small
        // we mark, and then we can sweep through the tree. 

        // Stage 1, build a real tree. This involves adding in additional placeholders
        // where we need them. 

        Map parentTable = [:] as Map
        Map childTable = [:] as Map
        Map entryTable = [:] as Map
        Map levelTable = [:] as Map
        Map markTable = [:] as Map
        Map scoreTable = [:] as Map

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

            if (level == "SEQUENCE") continue

            //log.info("Basic element: " + element["id"] + ", " + parent + ", " + level)

            entryTable[element["id"]] = element
            scoreTable[element["id"]] = element["score"]

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

            //log.info("Adding level: " + key + ", " + nextParent)

            parentTable[key] = nextParent
            if (childTable[nextParent] == null) childTable[nextParent] = [] as List
            childTable[nextParent] << key
            entryTable[key] = [level: level]
        }

        //log.info("Root children: " + childTable["oi:ROOT"])

        // Step 2A. Work down through the tree. Well, probably not actual recursion as we are working
        // a level at a time. At each level, mark the ones we want to keep.
        for(level in levels.reverse()) {
            List elementIds = levelTable[level]

            // These will actually be sorted by score, so we can work through them linearly until we 
            // are done. At each level, keep the entries that match our criteria and mark all the rest
            // for collection. 

            Integer maxCount = 10
            Integer count = 0
            for(elementId in elementIds) {
                markTable[elementId] = (count++ >= maxCount)
            }
        }

        // Step 2B. Recurse through the tree, marking sub elements when we have marked a parent
        // element. 
        def handleMarking = { id, marked ->
            if (marked) markTable[id] = marked
            if (marked) log.info("Marking as mergable: " + id)
            for(child in childTable[id]) {
                call(child, markTable[id])
            }
        }

        for(child in childTable["ROOT"]) {
            //log.info("Handling marking: " + child)
            handleMarking(child, markTable[child])
        }

        // Step 2C. Merge marked child elements. This involves a bottom-up recursion, so we do it
        // in a more interesting way, using the result of a recursive call. Basically, when we find
        // everything for an entity is safe, we can merge and mark. The result 

        // Combines two entities, and all their descendants, which must be marked, into a new 
        // block, which is then returned. 
        def mergeEntities = { id1, id2 ->
            //log.info("mergeEntities: " + id1 + ", " + id2)
            assert id1 != null
            assert id2 != null

            // When we merge entities, we should to check the number of mergable children
            // is zero or one. 

            def children1 = (childTable[id1] ?: []).findAll { markTable[it] }
            def children2 = (childTable[id2] ?: []).findAll { markTable[it] }

            assert children1.size() <= 1
            assert children2.size() <= 1

            def child = null
            if (children1.size() > 0 && children2.size()) {
                //log.info("Merging children: " + children1 + ", " + children2)
                child = call(children1[0], children2[0])
            }

            entryTable[id1]["score"] += entryTable[id2]["score"]
            scoreTable[id1] += scoreTable[id2]
            childTable[parentTable[id2]].remove(id2)
            parentTable.remove(id2)
            childTable.remove(id2)

            if (child) {
                childTable[id1] = [child]
                parentTable[child] = id1
            }

            return id1
        }

        def handleMerging = { id ->
            List children = childTable[id]
            //log.info("handleMerging: " + id + ", " + children)
            if (children == null) return
            if (children.size() == 0) return

            // First of all, merge all child nodes if we can
            for(child in children) {
                call(child)
            }

            // This list will contain all the marked elements, and we can merge these
            List mergable = children.findAll { markTable[it] }
            if (mergable.size() > 0) {
                //log.info("About to merge: " + id + " => " + mergable)
                def initial = mergable.pop()
                mergable.inject(initial) { acc, val -> mergeEntities.call(acc, val) }
            }

            Boolean entirelyMergable = ! children.find { ! markTable[it] }
            //log.info("Anything else? " + id + " => " + entirelyMergable + ", " + children.find { ! markTable[it] })
            if (entirelyMergable) {
                //log.info("Marking as mergable: " + id)
                markTable[id] = true
            }
        }

        handleMerging("oi:ROOT")

        // Step 3. We need to recalculate the actual breakdowns from the root down. This
        // assumes that at each level we have a total of 1.0, which gets evenly distributed
        // across everything. We can also remove any items which have a zero score after 
        // we have done this. The result is basically the hierarchy we want to send back
        // to the server. Also, anything that is marked can be tagged as a placeholder, as 
        // these are residuals. 

        def removedMarkedSubtrees = { id ->
            Boolean parentMarked = markTable[id]
            for(child in (childTable[id] ?: [])) {
                if (parentMarked && markTable[child]) {
                    //log.info("Removing subtree: " + id)
                    childTable[id] = []
                    break
                }
                call(child)
            }
        }

        removedMarkedSubtrees("oi:ROOT")

        def calculateScores = { id ->
            def children = childTable[id] ?: []
            //log.info("Scoring: " + id + ", " + children)
            if (children.size() != 0 && scoreTable[id] == null) {
                Float total = 0.0
                for(child in children) {
                    //log.info("Scoring: " + id + " -> " + child)
                    total = total + (call(child) ?: 0.0)
                }
                scoreTable[id] = total
            }
            return scoreTable[id]
        }

        def scaleScores = { id, factor -> 
            if (scoreTable[id] != null) scoreTable[id] = scoreTable[id] * factor
            if (childTable[id] != null) {
                for(child in childTable[id]) {
                    call(child, factor)
                }
            }
        }

        scaleScores("oi:ROOT", 1 / calculateScores("oi:ROOT"))

        def sortScores = { id ->
            if (childTable[id] != null) {
                childTable[id] = childTable[id].grep { scoreTable[it] }.sort { a, b ->
                    //log.info("Sorting: " + a + ", " + b + " -> " + markTable[b])
                    if (markTable[b]) {
                        return -1
                    } else {
                        return 0
                    }
                }
                for(child in childTable[id]) {
                    call(child)
                }
            }
        }

        sortScores("oi:ROOT")

        // def displayTree = { id, depth ->
        //     StringBuilder sb = new StringBuilder()
        //     sb.append("         ".substring(0, depth))
        //     sb.append(id)
        //     if (markTable[id]) sb.append("*")
        //     sb.append(" ")
        //     sb.append(entryTable[id]?.getAt("score"))
        //     sb.append(" -> ")
        //     sb.append(scoreTable[id])
        //     System.err.println(sb.toString())
        //     
        //     List children = childTable[id]
        //     if (children == null) return
        //     for(child in children) {
        //         call(child, depth + 2)
        //     }
        // }

        // We're doing a breadth first walk through the tree, so 
        def generateResults = { id ->
            BasicDBList results = [] as BasicDBList
            List queue = [] as List
            queue << id
            while(queue.asBoolean()) {
                String next = queue.remove(0)            // Remove from the head of queue
                if (childTable[next] != null) queue.addAll(childTable[next])
                results << [
                    id: (markTable[next] ? "mi:" + next : next),
                    level: entryTable[next]?.getAt("level"),
                    score: scoreTable[next],
                    parent: (markTable[parentTable[next]] ? "mi:" + parentTable[next] : parentTable[next]),
                    placeholder: next.startsWith("oi:"),
                    name: (markTable[next] ? "Other" : entryTable[next]?.getAt("name")) ?: ""
                ]
            }
            
            return results
        }

        // System.err.println("")
        // displayTree("oi:ROOT", 0)

        def results = generateResults("oi:ROOT")
        results.remove(0)
        //log.info(results)
        return results

        // Now we can generate the data we need, which is the normalized and merged 
        // genome relative abundance. This is very similar to the recursive crawl, but 
        // is actually simpler. 

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

        return buildRelativeAbundanceTree(alignment)
    }
}
