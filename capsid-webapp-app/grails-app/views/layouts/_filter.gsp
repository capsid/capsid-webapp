<g:form action="${id?'show':'list'}" id="${id}" params="${projectLabel ? [projectLabel: projectLabel] : []}" class="form-horizontal pull-right search">
	<g:if test="${buttons=='true'}">
	<div class="pull-left filter">
		<input type="hidden" name="filter" value="false">
		<div class="btn-group" data-toggle="buttons-checkbox">
			<button class="btn" data-filter-name="lowMaxCover" rel="tooltip" data-original-title="Filter viral genomes with low coverage (only those with max gene coverage >50% are returned)">Coverage</button>
			<button class="btn" data-filter-name="phage" rel="tooltip" data-original-title="Return bacteriophage viral genome sequences">Bacteriophage</button>
			<button class="btn" data-filter-name="humanbg" rel="tooltip" data-original-title="Use a human background model to report only viruses with read composition significantly different from those expected from the human mRNA">Human</button>
		</div>
	</div>
	</g:if>
	<div class="input-prepend input-append pull-right" style="margin: 0 10px;">
		<span class="add-on"><i class="icon-search"></i></span><input type="search" name="text" value="${query}"><span><span class="clear btn btn-danger">&times</span><button class="btn">Search</button></span>
	</div>
</g:form>