<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-horizontal pull-right search">
	<div class="pull-left filter">
		<input type="hidden" name="taxonRootId" value="">
		<div class="btn-group" data-toggle="buttons-checkbox">
			<button class="btn" data-filter-name="phage" rel="tooltip" data-original-title="Return bacteriophage viral genome sequences">Bacteriophage</button>
			<button class="btn" data-filter-name="lowMaxCover" rel="tooltip" data-original-title="Filter viral genomes with low coverage (only those with max gene coverage >50% are returned)">Low max gene coverage</button>
			<button class="btn" data-filter-name="lowgeneCoverageAvg" rel="tooltip" data-original-title="Filter viral genomes with low coverage (only those with average gene coverage > human background average gene coverage are returned)">Average gene coverage &lt; bg</button>
			<button class="btn" data-filter-name="lowgenomeCoverage" rel="tooltip" data-original-title="Use a human background model to report only viruses with read composition significantly different from those expected from the human mRNA">Genome coverage &lt; bg</button>
		</div>
		<div id="hierarchy-chooser"></div>
	</div>
	<div class="input-prepend input-append pull-right" style="margin: 0 10px;">
		<span class="add-on"><i class="icon-search"></i></span><input type="search" name="text" value="${query}"><span><span class="clear btn btn-danger">&times;</span><button class="btn">Search</button></span>
	</div>
</g:form>
<g:javascript>
jQuery("#hierarchy-chooser").hierarchyChooser({baseUrl: "${resource(dir: '/taxon/api')}", taxonRootId: 1});
jQuery("#hierarchy-chooser").bind('change', function(evt, value) { 
    var form = jQuery("#hierarchy-chooser").parents("form");
    form.find("input[name=taxonRootId]").val(value.id);
    form.trigger("submit");
//	jQuery("#stats-table").load("${forwardURI}" + "?taxonRootId=" + encodeURIComponent(value.id) + " #stats-table");
});
</g:javascript>
