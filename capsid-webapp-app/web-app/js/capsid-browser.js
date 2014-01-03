// Additional stuff associated with the Capsid browser, implementing
// components and functionality not typically handled by the main browser.

function handleDragOver(e) {
	if (e.preventDefault) e.preventDefault(); 

	var trackType = this.getAttribute('data-track-type');
	var y = e.originalEvent.offsetY;
	var height = e.currentTarget.offsetHeight;

	var direction = (y < height / 2) ? "above" : "below";
	if (trackType == 'genes' && direction == 'above') direction = "";

	var je = jQuery(this);
	if (direction !== "above" && je.hasClass("capsid-track-insert-above")) je.removeClass("capsid-track-insert-above");
	if (direction !== "below" && je.hasClass("capsid-track-insert-below")) je.removeClass("capsid-track-insert-below");

	if (direction) je.addClass("capsid-track-insert-" + direction);

	if (direction) {
		e.originalEvent.dataTransfer.dropEffect = 'link';
	} else {
		e.originalEvent.dataTransfer.dropEffect = 'none';
	}

	return true;
}

function handleMouseDown(e) {
	e.stopPropagation();
	return true;
}

function handleDragLeave(e) {
	if (e.preventDefault) e.preventDefault(); 
	e.stopPropagation();

	var je = jQuery(this);
	if (je.hasClass("capsid-track-insert-above")) je.removeClass("capsid-track-insert-above");
	if (je.hasClass("capsid-track-insert-below")) je.removeClass("capsid-track-insert-below");
	return true;
}

function handleDragStart(e) {
	e.stopPropagation();
	var data = jQuery(this).attr('data-track-identifier');

	e.originalEvent.dataTransfer.effectAllowed = 'link';
	e.originalEvent.dataTransfer.setData('Text', data);

	return true;
}

function handleDrop(e, genomeViewer) {
	if (e.preventDefault) e.preventDefault();
	e.stopPropagation();

	var je = jQuery(e.currentTarget);
	var direction = null;

	if (je.hasClass("capsid-track-insert-above")) {
		je.removeClass("capsid-track-insert-above");
		direction = "above";
	}
	if (je.hasClass("capsid-track-insert-below")) {
		je.removeClass("capsid-track-insert-below");
		direction = "below";
	}

	var currentTrack = e.originalEvent.dataTransfer.getData('Text');

	var trackListPanel = genomeViewer.trackListPanel;
	var targetId = e.currentTarget.id;
	targetId = targetId.slice(0, -4);

	var oldIndex = trackListPanel.swapHash[targetId].index;
	var trackData = genomeViewer.getTrackSvgById(currentTrack);

	// Now we can start to handle where we currently are.
	if (trackData) {
		// We're handling an existing track, so we're actually moving it, to what might be a new index. 

		var newIndex = (direction == "below") ? (oldIndex + 1) : oldIndex;
		if (newIndex !== oldIndex) {
			genomeViewer.setTrackIndex(currentTrack, newIndex);
		}

	} else {

		// There's no existing track, so we better make one :-)

		var urlBase = jQuery("#gv-application").attr('data-capsid-url-base');
		var accession = jQuery("#gv-application").attr('data-capsid-accession');
		var items = currentTrack.split("-", 2);
		var projectLabel = items[0];
		var sampleName = items[1];
		var params = {
			accession: accession,
			projectLabel: projectLabel,
			sampleName: sampleName
		}
		var track = addSampleTrack(genomeViewer, urlBase, params);

		// We can now work out the new index, which ought to be related to the previous one. 
		var newIndex = (direction == "below") ? (oldIndex + 1) : oldIndex;
		genomeViewer.setTrackIndex(currentTrack, newIndex);
	}

	return true;
}

function bootstrapGenomeViewer(genomeViewer) {

	function handleDragOverMove(e) {
		if (e.preventDefault) e.preventDefault(); 
		e.originalEvent.dataTransfer.dropEffect = 'move';
		return false;
	}

	function handleDropMove(e) {
		if (e.preventDefault) e.preventDefault(); 
		var trackIdentifier = e.originalEvent.dataTransfer.getData('Text');
		genomeViewer.removeTrack(trackIdentifier);
		return false;
	}

	jQuery("#gv-tracks li").attr('draggable', 'true');
	jQuery("#gv-tracks li").on('dragstart', handleDragStart);

	jQuery("#gv-tracks").on('dragenter', handleDragOverMove);
	jQuery("#gv-tracks").on('dragover', handleDragOverMove);
	jQuery("#gv-tracks").on('drop', handleDropMove);
}

function initializeGenomeViewer(genomeLength) {
	var start = 1;
	var end = typeof genomeLength !== 'undefined' ? genomeLength : 800000;

	var regionObj = new Region({chromosome: '1', start: start, end: end});

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

	return genomeViewer;
}

function addGeneTrack(genomeViewer, urlBase, params) {
	params.track = 'gene';
	var trackIdentifier = params.accession + "-genes";
	var capsidGeneTrack = new CapsidGeneTrack({
		targetId: null,
		id: trackIdentifier,
		title: 'Genes',
		histogramZoom: 50,
		labelZoom: 55,
		height: 150,
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
			urlBase: urlBase,
			category: 'genomic',
			subCategory: 'region',
			resource: 'gene',
			species: genomeViewer.species,
			params: params,
			featureCache: {
				gzip: true,
				chunkSize: 10000
			},
			filters: {},
			featureConfig: FEATURE_CONFIG.gene
		})
	});

	genomeViewer.addTrack(capsidGeneTrack);

	jQuery("#gv-application").attr('data-capsid-url-base', urlBase);
	jQuery("#gv-application").attr('data-capsid-accession', params.accession);

	jQuery("#" + trackIdentifier + "-div").attr('data-track-type', 'genes');

	jQuery("#" + trackIdentifier + "-div").addClass('capsid-track-block');

	jQuery("#" + trackIdentifier + "-div").on('dragenter', handleDragOver);
	jQuery("#" + trackIdentifier + "-div").on('dragleave', handleDragLeave);
	jQuery("#" + trackIdentifier + "-div").on('dragover', handleDragOver);
	jQuery("#" + trackIdentifier + "-div").on('drop', function(e) { return handleDrop(e, genomeViewer); });

	return capsidGeneTrack;
}

function addSampleTrack(genomeViewer, urlBase, params) {
	params.track = 'feature';
	var trackIdentifier = params.projectLabel + "-" + params.sampleName;
	var capsidFeatureTrack = new CapsidFeatureTrack({
		targetId: null,
		id: trackIdentifier,
		title: params.sampleName,
		histogramZoom: 70,
		labelZoom: 85,
		height: 150,
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
	    	urlBase: urlBase,
			category: 'genomic',
			subCategory: 'region',
			resource: 'feature',
			params: params,
			species: genomeViewer.species,
			featureCache: {
				gzip: true,
				chunkSize: 10000
			},
			filters: {},
			featureConfig: FEATURE_CONFIG.feature
		})
	});

	genomeViewer.addTrack(capsidFeatureTrack);

	function handleDragStartMove(e) {
		e.stopPropagation();
		e.originalEvent.dataTransfer.effectAllowed = 'linkMove';
		var data = jQuery(this).attr('data-track-identifier');
		e.originalEvent.dataTransfer.setData('Text', data);
	}

	jQuery("#" + trackIdentifier + "-div").attr('data-track-type', 'reads');

	jQuery("#" + trackIdentifier + "-div").addClass('capsid-track-block');

	jQuery("#" + trackIdentifier + "-div").on('dragenter', handleDragOver);
	jQuery("#" + trackIdentifier + "-div").on('dragleave', handleDragLeave);
	jQuery("#" + trackIdentifier + "-div").on('dragover', handleDragOver);
	jQuery("#" + trackIdentifier + "-div").on('drop', function(e) { return handleDrop(e, genomeViewer); });

	jQuery("#" + trackIdentifier + "-titlediv").attr("draggable", "true");
	jQuery("#" + trackIdentifier + "-titlediv").on('dragstart', handleDragStartMove);
	jQuery("#" + trackIdentifier + "-titlediv").on('mousedown', handleMouseDown);

	jQuery("#" + trackIdentifier + "-titlediv").addClass("capsid-track-title capsid-draggable-track-title");
	jQuery("#" + trackIdentifier + "-titlediv").attr('data-track-identifier', trackIdentifier);

	return capsidFeatureTrack;
}