<g:form action="${id?'show':'list'}" id="${id}" class="form-horizontal pull-right search">
	<g:if test="${buttons=='true'}">
	<div class="span filter">
		<input type="hidden" name="filter" value="false">
		<div class="btn-group" data-toggle-name="filter" data-toggle="buttons-radio">
			<button class="btn" value="false">No Filter</button>
			<button class="btn" value="coverage" rel="tooltip" data-original-title="Filter viral genomes with low coverage (only those with max gene coverage >50% are returned)">Coverage</button>
			<button class="btn" value="phage" rel="tooltip" data-original-title="Return bacteriophage viral genome sequences">Bacteriophage</button>
			<button class="btn" value="humanbg" rel="tooltip" data-original-title="Use a human background model to report only viruses with read composition significantly different from those expected from the human mRNA">Human</button>
		</div>
	</div>
	</g:if>
	<div class="input-prepend input-append span">
		<span class="add-on"><i class="icon-search"></i></span><input type="search" name="text" class="span3"><button class="btn">Search</button>
	</div>
</g:form>