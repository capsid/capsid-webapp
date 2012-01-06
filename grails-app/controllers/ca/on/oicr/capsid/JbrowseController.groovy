/*
*  Copyright 2011(c) The Ontario Institute for Cancer Reserach. All rights reserved.
*
*	This program and the accompanying materials are made available under the
*	terms of the GNU Public License v3.0.
*
*	You should have received a copy of the GNU General Public License along with
*	this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package ca.on.oicr.capsid

import org.bson.types.ObjectId

import ca.on.oicr.ferv.jbrowser.Histogram
import grails.converters.JSON
import grails.plugins.springsecurity.Secured

@Secured(['ROLE_CAPSID'])
class JbrowseController {

    def AuthService

	def index = {redirect(action: "show", params: params)}
	def show = {
		Genome genomeInstance = Genome.findByAccession(params.id)
		[genomeInstance:genomeInstance]
	}

	def setup = {
		Genome genomeInstance = Genome.findByAccession(params.id)
		// jbrowse breaks when refseq name contains spaces or commas. So we use accession.
		List seqs = [[
				name:genomeInstance.accession,
				length:genomeInstance.length,
				start:1,
				end:genomeInstance.length,
				seqChunkSize:20000,
				seqDir:'genome/'+genomeInstance.accession+'/sequence'
			]]

		List tracks = [
				[
					label: "ROOT"
				,	type: "ROOT"
				,	children: [["_reference": "General"]]
				,	key: "ROOT"
				],
				[
					label: "General"
                ,   type: "TrackGroup"
                ,	children: [
	                    [ "_reference" : "Genes"]
	                ,   [ "_reference" : "DNA"]
                    ]
                ,   key: "General"
				],
				[
					url : "../sequence/{refseq}?"
				,	args_chunkSize : 20000
				,	label : "DNA"
				,	type : "SequenceTrack"
				,	key : "DNA"
				],
				[
					url : "../genes/{refseq}?"
				,	label : "genes"
				,	type : "FeatureTrack"
				,	key : "Genes"
				]
			]

		ArrayList samples = []
		def projects = [:]
        Project.security(AuthService.getRoles()).list().each {
			projects[it.label] = [
					label: it.label
                ,   type: "TrackGroup"
                ,   children: []
                ,   key: it.label
				]
		}
		genomeInstance.samples.each {
			Sample sampleInstance = Sample.findByName(it)
			Project projectInstance = Project.findByLabel(sampleInstance.project)
            if (projects[projectInstance.label]) {
                projects[projectInstance.label]["children"].add(["_reference":it])
            }
			samples += [
				url: "../track/{refseq}?track="+it
			,	type: 'FeatureTrack'
			,	label: it
			,	key: it
			]
		}

		projects.each {
			if (it.value['children'].length) {
				tracks.add(it.value)
				tracks[0]['children'].add("_reference" : it.value['label'])
			}
		}

		tracks.addAll(samples);

		def s = [refseqs:seqs, trackInfo:tracks]
		render s as JSON
	}

	def track = {
		Genome genomeInstance = Genome.findByAccession(params.id)
		Sample sampleInstance = Sample.findByName(params.track)

		List headers = ['start', 'end', 'strand', 'id', 'isHuman', 'label'];
		int ncIndex = headers.size();

		List histograms = [new Histogram(1000)]
		List hits = []

		def mapped = Mapped.collection.find(genomeId: genomeInstance.id, sample: sampleInstance.name).sort([refStart: 1])
		mapped.each {
			List hit = [it.refStart, it.refEnd, it.refStrand, it._id.toString(), it.isHuman, ""]
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
                        clientConfig:[featureCallback:"function(feature,fields,featDiv){if(feature[fields['isHuman']]) {dojo.addClass(featDiv, 'human')}}"],
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

		Feature.collection.find(genomeId:genomeInstance.id, type: 'gene').sort([start: 1]).collect { val ->
			def hit = [val.start, val.end, val.strand, val.name, val.name, []]
			addToNcList(hits, ncIndex, hit)
			histograms*.count(val.start)
			null;
		}

		int cdsIndex = 0;
		int lastHit = 0;

		Feature.collection.find(genomeId:genomeInstance.id, type: 'cds').sort([start: 1]).collect { val ->
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

		List cds = Feature.collection.find(genomeId:genomeInstance.id, type: 'cds').sort([start: 1]).collect { val ->
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
