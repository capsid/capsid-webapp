package ca.on.oicr.capsid

/*
* Copyright 2013(c) The Ontario Institute for Cancer Research. All rights reserved.
*
* This program and the accompanying materials are made available under the
* terms of the GNU Public License v3.0.
*
* You should have received a copy of the GNU General Public License along with
* this program. If not, see <http://www.gnu.org/licenses/>.
*/

/**
 * Charting tags.
 *
 */
class ChartTagLib {

	/**
	 * Renders a zoomable sunburst chart. 
	 */

	def zoomableSunburst = { attrs ->
        out << """
<div id="vis"></div>
		"""

		def object = attrs.display

		log.info("Attributes: " + attrs)

		def name = object.name
		def projectLabel = object.projectLabel
		def sample = object.sample
		def actionUrl = g.createLink(controller: "alignment", action: "taxonomy", id: name, params: [projectLabel: projectLabel, sampleName: sample])

		out << g.javascript() { """
buildHierarchy("${actionUrl}", function(data) {
  var chart = hierarchyChart().width(500).height(500);
  d3.select("#vis")
    .datum(data)
    .call(chart);
})
        """}
    }
}
