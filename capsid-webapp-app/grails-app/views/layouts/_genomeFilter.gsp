<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-filters">
	<fieldset class="filter-fields filter-advanced">
		<legend>Search</legend>
		<label><input type="text" name="text" class="input-small search-query filter-search"><span class="userclear">&times;</span> Search</label>
		<legend>Filters</legend>
		<div class="help-block">Remove from the list</div>
		<input type="hidden" name="taxonRootId" value="">
		<label class="checkbox"><input type="checkbox" data-filter-name="phage"> Bacteriophages</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowMaxCover"> Low max gene coverage</label>
		<label class="checkbox explained"><input type="checkbox" data-filter-name="lowgeneCoverageAvg"> Below average gene coverage</label>
		<div class="help-block explanation">Relative to background</div>
		<label class="checkbox explained"><input type="checkbox" data-filter-name="lowgenomeCoverage"> Low genome coverage</label>
		<div class="help-block explanation">Relative to background</div>
		<legend>Export</legend>
		<div class="btn search-export">Save data as tab file</div>
		<div class="download-target"></div>
	</fieldset>
</g:form>
