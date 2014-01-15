<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-filters">
	<fieldset class="filter-fields filter-advanced">
		<legend>Filters</legend>
		<input type="hidden" name="taxonRootId" value="">
		<label class="checkbox"><input type="checkbox" data-filter-name="phage"> Bacteriophages</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowMaxCover"> Low max gene coverage</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowgeneCoverageAvg"> Below average gene coverage</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowgenomeCoverage"> Low genome coverage</label>
		<div class="help-block">Relative to background</div>
		<label><input type="text" name="text" class="input-small search-query filter-search"><span class="userclear">&times;</span> Search</label>
	</fieldset>
</g:form>
</g:javascript>
