<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="Genome" />
		<title>${genomeInstance.accession} - ${genomeInstance.name}</title>
		<r:require modules="browser"/>

	</head>
	<body>
		<div class="content">
			<div class="page-header">
				<h1>
					<g:link controller="genome" action="show" id="${genomeInstance.accession}">${fieldValue(bean: genomeInstance, field: "name")} (${fieldValue(bean: genomeInstance, field: "accession")})</g:link>
					<small> ${fieldValue(bean: genomeInstance, field: "length")}bp</small>
				</h1>
				[<a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank" style="color:#444">Link to NCBI Nucleotide DB</a>]
			</div>

			<g:if test="${flash.message}">
			<div class="message">${flash.message}</div>
			</g:if>
			
			<div id="setup-loader"><span>Setting up genome browser...</span></div>

			<div id="checkBrowser"></div>

			<span data-ng-if="options.panels">
			    <button class="btn btn-small">Region Overview</button>
			</span>

			<div id="navigationBar"></div>
			<div id="gm">
				<div id="gv-application"></div>
			</div>
		</div>

		<g:javascript>
var regionObj = new Region({chromosome: '1', start: 1, end: 800000});

var tracks = {};

var genomeViewer = new GenomeViewer({
    width: 800,
    height: 580,
    region: regionObj,
    defaultRegion: regionObj,
    sidePanel: false,
    targetId: 'gv-application',
    autoRender: true,
    drawNavigationBar: false,
    drawChromosomePanel: false,
    drawKaryotypePanel: false,
    drawRegionOverviewPanel: true,
    version: ''
});

var navigationBar = new CapsidNavigationBar({
  targetId: "navigationBar",
  handlers: {
    'region:change': function(event) {
      Utils.setMinRegion(event.region, genomeViewer.getSVGCanvasWidth());
      genomeViewer.trigger('region:change', event);
    },
    'restoreDefaultRegion:click': function(event) {
      Utils.setMinRegion(genomeViewer.defaultRegion, genomeViewer.getSVGCanvasWidth());
      event.region = genomeViewer.defaultRegion;
      genomeViewer.trigger('region:change', event);
    }
  }
});
genomeViewer.setNavigationBar(navigationBar);

genomeViewer.draw();

// mutationGenomeViewer.setRegionOverviewPanelVisible(false);

tracks.capsidGeneTrack = new CapsidGeneTrack({
  targetId: null,
  id: 2,
  title: 'Genes',
  histogramZoom: 50,
  labelZoom: 55,
  height: 300,
  visibleRange: {start: 0, end: 100},
  featureTypes: FEATURE_TYPES,

  renderer: new CapsidGeneRenderer({
  	label: function(f) {
  	  return f.name;
  	},
  	tooltipText: function(f) {

      return 'gene:&nbsp;<span class="ssel">' + f.name + '</span><br>' +
        'start-end:&nbsp;<span class="emph">' + f.start + '-' + f.end + '</span><br>' + 
        'strand:&nbsp;<span class="ssel">' + (f.strand == 1 ? "sense (positive)" : "antisense (negative)") + '</span><br>';
    },
        
  	height: 8
  }),

  dataAdapter: new CapsidGeneAdapter({
    urlBase: "${resource(dir: '/browse/api')}",
    category: 'genomic',
    subCategory: 'region',
    resource: 'gene',
    species: genomeViewer.species,
    params: {track: 'gene', accession: "${genomeInstance.accession}"},
    featureCache: {
      gzip: true,
      chunkSize: 10000
    },
    filters: {},
    featureConfig: FEATURE_CONFIG.gene
  })
});

genomeViewer.addTrack(tracks.capsidGeneTrack);

this.capsidFeatureTrack = new CapsidFeatureTrack({
	targetId: null,
	id: 3,
	title: 'Capsid Features',
	histogramZoom: 75,
	labelZoom: 85,
	height: 240,
	visibleRange: {start: 0, end: 100},
    featureTypes: FEATURE_TYPES,

	renderer: new CapsidFeatureRenderer({
		label: function(f) {
			return f.id;
		},
		height: 6,
      	tooltipText: function(f) {

          return 'start-end:&nbsp;<span class="emph">' + f.start + '-' + f.end + '</span><br>' + 
            'strand:&nbsp;<span class="ssel">' + (f.strand == 1 ? "sense (positive)" : "antisense (negative)") + '</span><br>';
        },
		blockClass: 'capsid-feature capsid-feature-read'
	}),

	dataAdapter: new CapsidFeatureAdapter({
    	urlBase: "${resource(dir: '/browse/api')}",
		category: 'genomic',
		subCategory: 'region',
		resource: 'feature',
		params: {
    		track: 'feature', 
    		accession: "${genomeInstance.accession}",
    		projectLabel: "${projectInstance.label}",
    		sampleName: "${sampleInstance.name}"
		},
		species: genomeViewer.species,
		featureCache: {
			gzip: true,
			chunkSize: 10000
		},
		filters: {},
		featureConfig: FEATURE_CONFIG.feature
	})
});

genomeViewer.addTrack(this.capsidFeatureTrack);

		</g:javascript>
	</body>
</html>
