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

import ca.on.oicr.capsid.browse.Histogram
import grails.converters.JSON
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class BrowseController {

  def authService
  def projectService

  def index = {redirect(action: "show", params: params)}
  def show = {
    Genome genomeInstance = Genome.findByAccession(params.id)
    [genomeInstance:genomeInstance]
  }

  def config = {
    def datasets = [datasets: [capsid: [url: '?data=sample_data/json/capsid', name: 'CaPSID']], dataset_id: 'capsid']
    render datasets as JSON
  }

  def names = {
    def rootNames = [
      lowercase_keys:1,
      track_names:["DNA","Genes","ReadingFrame","CDS","Transcript","Clones","EST"],
      hash_bits:4,
      last_changed_entry:"seg15"
    ]
    render rootNames as JSON
  }

  def refSeqs = {
    Genome genomeInstance = Genome.findByAccession(params.id)
    def refSeqs = [[
        name:genomeInstance.accession,
        length:genomeInstance.length,
        start:1,
        end:genomeInstance.length,
        seqChunkSize:20000,
        seqDir:'genome/'+genomeInstance.accession+'/sequence'
      ]] 
    render refSeqs as JSON
  }

  def tracks = {
    def genesTrack = [
      storeClass : "JBrowse/Store/SeqFeature/REST",
      baseUrl: resource(dir:'browse'),
      query: [data: "genes"],
      style : [height : 7],
      type : "JBrowse/View/Track/HTMLFeatures",
      displayMode: 'normal',
      maxHeight: 400,
      metadata : [description: "RESTful BAM-format alignments of simulated resequencing reads on the volvox test ctgA reference."],
      label : "Genes",
      key : "Genes"
    ]
    def readTrack = [
      storeClass : "JBrowse/Store/SeqFeature/REST",
      baseUrl: resource(dir:'browse'),
      query: [data: "reads"],
      style : [height : 7],
      type : "JBrowse/View/Track/HTMLFeatures",
      displayMode: 'normal',
      maxHeight: 400,
      metadata : [description: "RESTful BAM-format alignments of simulated resequencing reads on the volvox test ctgA reference."],
      label : "Reads",
      key : "REST - volvox-sorted"
    ]
    def trackList = [
      tracks: [genesTrack]
    ]
    render trackList as JSON
  }

  def stats = {
    def data = [
      featureDensity: 0.002,
      featureCount: 100,
      scoreMin: 87,
      scoreMax: 87,
      scoreMean: 42,
      scoreStdDev: 2.1
    ]
    render data as JSON
  }

  def geneFeatures(String identifier, Integer start, Integer end) {
    Genome genomeInstance = Genome.findByAccession(params.id)

    List headers = ['start', 'end', 'strand', 'name', 'id', 'subfeatures'];
    int ncIndex = headers.size();

    List histograms = [new Histogram(1000)]
    List features = []

    log.info("Looking for hits: type: gene, " + genomeInstance.gi + ", start: " + start + ", end: " + end)

    Feature.collection.find(genome:genomeInstance.gi, type: 'gene').sort([start: 1]).collect { val ->
      if (val.end >= start && val.start <= end) {
        def hit = [val.start, val.end, val.strand, val.name, val.name, []]
        //addToNcList(hits, ncIndex, hit)
        //histograms*.count(val.start)
        features.add([start: val.start, end: val.end, strand: val.strand, uniqueID: val.name, name: val.name])
      }
      null;
    }

    return features
  }

  def features = {
    def identifier = params.id
    def dataType = params.data
    def start = params.start
    def end = params.end

    def features

    log.info("Features: " + identifier + ", " + dataType + ", " + start + ", " + end)

    if (dataType == 'genes') {
      features = geneFeatures(identifier, start.toInteger(), end.toInteger())
    } else {
      features = [
       
        /* minimal required data */
        [start: 123, end: 456, uniqueID: 'globallyUniqueString1' ],
     
        /* typical quantitative data */
        [start: 123, end: 456, score: 42, uniqueID: 'globallyUniqueString2' ],
     
        /* Expected format of the single feature expected when the track is a sequence data track. */
        [seq: 'gattacagattaca', start: 0, end: 14, uniqueID: 'globallyUniqueString3'],
     
        /* typical processed transcript with subfeatures */
        [type: 'mRNA', start: 5975, end: 9744, score: 0.84, strand: 1,
         name: 'au9.g1002.t1', uniqueID: 'globallyUniqueString4']
      ]
    }
    def data = [features: features]
    render data as JSON
  }

//  def setup = {
//    Genome genomeInstance = Genome.findByAccession(params.id)
//    // jbrowse breaks when refseq name contains spaces or commas. So we use accession.
//    List seqs = [[
//        name:genomeInstance.accession,
//        length:genomeInstance.length,
//        start:1,
//        end:genomeInstance.length,
//        seqChunkSize:20000,
//        seqDir:'genome/'+genomeInstance.accession+'/sequence'
//      ]]
//
//    List tracks = [
//      [
//        label: "ROOT",
//        type: "ROOT",
//        children: [["_reference": "General"]],
//        key: "ROOT"
//      ],
//      [
//        label: "General",
//        type: "TrackGroup",
//        children: [
//          [ "_reference" : "Genes"],
//          [ "_reference" : "DNA"]
//        ],
//        key: "General"
//      ],
//      [
//        url : "../sequence/{refseq}?",
//        args_chunkSize : 20000,
//        label : "DNA",
//        type : "JBrowse/View/Track/Wiggle/Density",
//        key : "DNA",
//        storeClass : "JBrowse/Store/SeqFeature/REST",
//        baseUrl : "http://my.site.com/rest/api/base"
//      ],
//      [
//        url : "../genes/{refseq}?",
//        label : "Genes",
//        type : "JBrowse/View/Track/HTMLFeatures",
//        key : "Genes",
//        storeClass : "JBrowse/Store/SeqFeature/REST",
//        baseUrl : "http://my.site.com/rest/api/base"
//      ]
//    ]
//
//    ArrayList samples = []
//    def projects = [:]
//
//    List projectList = projectService.list [:]
//
//    projectList.each {
//      projects[it.label] = [
//            label: ':' + it.name.replaceAll(' ', '_').replaceAll('-', '_')
//        ,   type: "TrackGroup"
//        ,   children: []
//        ,   key: ':' + it.name.replaceAll(' ', '_').replaceAll('-', '_')
//      ]
//    }
//
//    genomeInstance.samples.each {
//      Sample sampleInstance = Sample.findByName(it)
//      if (sampleInstance == null) return
//      Project projectInstance = Project.findByLabel(sampleInstance.project)
//      if (projects[projectInstance.label]) {
//        projects[projectInstance.label]["children"].add(["_reference":it])
//      }
//      samples += [
//        url: "../track/{refseq}?track="+it
//        ,	type: 'FeatureTrack'
//        ,	label: it
//        ,	key: it
//      ]
//    }
//
//    projects.each {
//      if (it.value['children'].length) {
//        tracks.add(it.value)
//        tracks[0]['children'].add("_reference" : it.value['label'])
//      }
//    }
//
//    tracks.addAll(samples);
//    def s = [refseqs:seqs, trackInfo:tracks]
//    render s as JSON
//  }

  def track = {
    Genome genomeInstance = Genome.findByAccession(params.id)
    Sample sampleInstance = Sample.findByName(params.track)
    
    List headers = ['start', 'end', 'strand', 'id', 'isRef', 'label'];
    int ncIndex = headers.size();

    List histograms = [new Histogram(1000)]
    List hits = []

    def mapped = Mapped.collection.find(genome: genomeInstance.gi, sample: sampleInstance.name).sort([refStart: 1])
    mapped.each {
      List hit = [it.refStart, it.refEnd, it.refStrand, it._id.toString(), it.isRef, ""]
      addToNcList(hits, ncIndex, hit)
      histograms*.count(it.refStart)
    }

    Map trackInfo =
      [
        className:'feature',
        featureCount: hits.size,
        headers: headers,
        key: sampleInstance.name,
        label: sampleInstance.name,
        type: 'FeatureTrack',
        sublistIndex:ncIndex,
        onFeatureClick:"onClickFeature(event, fields);",
        clientConfig:[featureCallback:"function(feature,fields,featDiv){if(feature[fields['isRef']]) {dojo.addClass(featDiv, 'human')}}"],
        featureNCList: hits
      ]

    trackInfo.putAll(hist(histograms, "../sample-hist/"+params.id+"?sample="+sampleInstance.name+"&chunk={chunk}"))
    render trackInfo as JSON
  }

  def sequence = {
    Genome genomeInstance = Genome.findByAccession(params.id)
    Sequence seq = Sequence.get(genomeInstance.seqId)

    // TODO: hook this to the Sequence table when available
    // Sequence table available - but what does this do?

    Random random = new Random()
    List chars=['A','C','G','T','a','c','g','t']
    def sequence = (1..20000).collect{ chars[random.nextInt(chars.size())] }.join()
    render seq
  }

  def genes = {
    Genome genomeInstance = Genome.findByAccession(params.id)

    List headers = ['start', 'end', 'strand', 'name', 'id', 'subfeatures'];
    int ncIndex = headers.size();

    List histograms = [new Histogram(1000)]
    List hits = []

    Feature.collection.find(genome:genomeInstance.gi, type: 'gene').sort([start: 1]).collect { val ->
      def hit = [val.start, val.end, val.strand, val.name, val.name, []]
      addToNcList(hits, ncIndex, hit)
      histograms*.count(val.start)
      null;
    }

    int cdsIndex = 0;
    int lastHit = 0;

    Feature.collection.find(genome:genomeInstance.gi, type: 'cds').sort([start: 1]).collect { val ->
      // find the gene that has gene.stop >= cds.stop
      while(val.stop > hits[lastHit][1]) {
        lastHit++
          }
      hits[lastHit][ncIndex-1] << cdsIndex++
        }


    Map trackInfo =
      [
        className:'transcript',
        arrowheadClass:"transcript-arrowhead",
        featureCount: hits.size,
        headers: headers,
        key: 'Genes',
        label: 'genes',
        type: 'FeatureTrack',
        sublistIndex:ncIndex,
        urlTemplate: 'http://www.ncbi.nlm.nih.gov/gene?term='+params.id+'%20{id}',
        featureNCList: hits,
        subfeatureArray: [chunkSize:cdsIndex, length: cdsIndex, urlTemplate:'../cds/'+params.id+'?c={chunk}'],
        subfeatureHeaders: ['start', 'end', 'strand', 'type'],
        subfeatureClasses: [CDS: 'transcript-CDS']
      ]
    trackInfo.putAll(hist(histograms, "../gene-hist/"+params.id+"?chunk={chunk}"))
    render trackInfo as JSON
  }

  def cds = {
    Genome genomeInstance = Genome.findByAccession(params.id)

    List cds = Feature.collection.find(genome:genomeInstance.gi, type: 'cds').sort([start: 1]).collect { val ->
      [val.start, val.stop, val.strand, 'CDS']
    }

    render cds as JSON
  }

  // This builds the NCList http://bioinformatics.oxfordjournals.org/content/23/11/1386.full
  // First argument is the current list, second is the index within "it" where to store contained lists, and "it" is the current value to insert.
  // the value should have [0] == start and [1] == end
  def addToNcList = { ncList, ncIndex, it ->
    def container = ncList.size() > 0 ? ncList[-1] : null;
    def lastContainer = null;
    while(contained(container, it)) {
      lastContainer = container;
      container = container.size() > ncIndex ? container[ncIndex][-1] : null;
    }
    if(lastContainer != null) {
      if(lastContainer.size() > ncIndex) {
        lastContainer[-1] << it;
      } else {
        lastContainer[ncIndex] = [it];
      }
    } else {
      ncList << it;
    }
  }

  def hist(histograms, histoChunkUrl) {
    def histStats = histograms.collect({h ->
      [bases:h.binSize(), mean:h.mean(), max:h.max()]
                                       })
    def histogramMeta = histograms.collect({h ->
      [ basesPerBin:h.binSize(),
        arrayParams:[
          length:h.binCount(),chunkSize:h.binCount(),urlTemplate:histoChunkUrl+ "&binSize=" + h.binSize()
        ]
      ]
                                           })
    [histStats:histStats, histogramMeta:histogramMeta]
  }

  def contained = { container, containee ->
    return container != null && container[0] < containee[0] && container[1] > containee[1];
  }

}
