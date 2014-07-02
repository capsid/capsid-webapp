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

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured

/**
 * Controller class for the browser controller. 
 */
@Secured(['ROLE_CAPSID'])
class BrowseController {

  /**
   * Dependency injection for the AuthService.
   */
  def authService

  /**
   * Dependency injection for the ProjectService.
   */
  def projectService

  /**
   * Dependency injection for the GenomeService.
   */
  def genomeService

  /**
   * Dependency injection for the MappedService.
   */
  def mappedService

  /**
   * Dependency injection for the SampleService.
   */
  def sampleService

  /**
   * The index action. Redirects to the list action. 
   */
  def index = {redirect(action: "show", params: params)}

  /**
   * The show action.
   */
  def show = {
    String accession = params.id
    assert accession != null
    Genome genomeInstance = Genome.findByAccession(accession)

    Map model = [genomeInstance:genomeInstance, projectService: projectService, sampleService: sampleService]

    // The genome browser might also be invoked with a project and sample. If so, we should add that
    // into the view. If not, we just display the genome. 

    String projectLabel = params.projectLabel
    String sampleName = params.sampleName

    if (projectLabel) {
      Project projectInstance = Project.findByLabel(projectLabel)
      assert projectInstance != null
      
      model['projectInstance'] = projectInstance

      if (sampleName) {
        Sample sampleInstance = sampleService.get(sampleName, projectInstance.id)
        assert sampleInstance != null

        model['sampleInstance'] = sampleInstance        
      }   
    }

    return model
  }

  /**
   * The apiGeneTrack action.
   * 
   * Called when the action has its track parameter set to 'gene'.
   */
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

  /**
   * The apiFeatureTrack action handler method.
   * 
   * Called when the action has its track parameter set to 'feature'.
   */
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

  /**
   * The api action.
   */
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
