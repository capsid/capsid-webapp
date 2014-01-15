<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-horizontal pull-right search">
	<fieldset class="filter-fields filter-basic">
		<legend>Filters</legend>
		<label><input type="text" name="text" class="input-small search-query filter-search"><span class="userclear">&times;</span> Search</label>
	</fieldset>
</g:form>
