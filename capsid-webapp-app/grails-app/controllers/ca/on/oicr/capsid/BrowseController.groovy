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

import java.util.regex.Matcher
import java.util.regex.Pattern

import org.bson.types.ObjectId
import org.bson.types.ObjectId
import com.mongodb.BasicDBObject

import ca.on.oicr.capsid.browse.Histogram
import grails.converters.JSON
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class BrowseController {

  def authService
  def projectService
  def genomeService
  def mappedService
  def sampleService

  def index = {redirect(action: "show", params: params)}

  def show = {
    String accession = params.id
    assert accession != null
    Genome genomeInstance = Genome.findByAccession(accession)

    String projectLabel = params.projectLabel
    String sampleName = params.sampleName
    assert projectLabel != null
    assert sampleName != null

    Project projectInstance = Project.findByLabel(projectLabel)
    assert projectInstance != null
    Sample sampleInstance = sampleService.get(sampleName, projectInstance.id)
    assert sampleInstance != null

    [genomeInstance:genomeInstance, projectInstance: projectInstance, sampleInstance: sampleInstance]
  }

  def apiGeneTrack() {

    String segment = params.segment
    Pattern segmentRegex = ~/^(\w+):(\d+)-(\d+)$/
    def segmentMatch = segment =~ segmentRegex

    String accession = params.accession
    assert accession != null

    Genome genomeInstance = Genome.findByAccession(accession)
    assert genomeInstance != null

    Integer start = segmentMatch[0][2].toInteger()
    Integer end = segmentMatch[0][3].toInteger()

    assert start != null
    assert end != null

    if (params.histogram == 'true') {
      Integer interval = params.interval.toInteger()
      assert interval != null
  
      def histogram = genomeService.getHistogramRegion(genomeInstance, start, end, interval)
      render histogram as JSON
    } else {
      def genes = genomeService.getGenesRegion(genomeInstance, start, end)
      render genes as JSON      
    }
  }

  def apiFeatureTrack() {

    String segment = params.segment
    Pattern segmentRegex = ~/^(\w+):(\d+)-(\d+)$/
    def segmentMatch = segment =~ segmentRegex

    Integer start = segmentMatch[0][2].toInteger()
    Integer end = segmentMatch[0][3].toInteger()

    assert start != null
    assert end != null

    String projectLabel = params.projectLabel
    String sampleName = params.sampleName
    assert projectLabel != null
    assert sampleName != null

    Project projectInstance = Project.findByLabel(projectLabel)
    assert projectInstance != null
    Sample sampleInstance = sampleService.get(sampleName, projectInstance.id)
    assert sampleInstance != null

    String accession = params.accession
    assert accession != null

    Genome genomeInstance = Genome.findByAccession(accession)
    assert genomeInstance != null

    if (params.histogram == 'true') {
      Integer interval = params.interval.toInteger()
      assert interval != null
  
      def histogram = mappedService.getHistogramRegion(genomeInstance, sampleInstance, start, end, interval)
      render histogram as JSON
    } else {
      def features = mappedService.getMappedRegion(genomeInstance, sampleInstance, start, end)
      render features as JSON      
    }
  }

  def api = {
    if (params.track == 'gene') {
      apiGeneTrack();
    } else if (params.track == 'feature') {
      apiFeatureTrack();
    } else {
      throw new Error("Invalid track type: " + params.track)
    } 
  }
}
