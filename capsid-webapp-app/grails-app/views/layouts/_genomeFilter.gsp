<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-filters">
	<fieldset class="filter-fields">
		<legend>Filters</legend>
		<input type="hidden" name="taxonRootId" value="">
		<label class="checkbox"><input type="checkbox" data-filter-name="phage"> Bacteriophages</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowMaxCover"> Low max gene coverage</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowgeneCoverageAvg"> Below average gene coverage</label>
		<label class="checkbox"><input type="checkbox" data-filter-name="lowgenomeCoverage"> Low genome coverage</label>
		<label><input type="text" name="text" class="input-small search-query filter-search"> Search</label>
	</fieldset>
</g:form>
<g:javascript>
function submitFilterText(element, evt) {
	var form = element.parents("form");
	form.trigger("submit");
}
jQuery("input.filter-search").bind('keyup', function(evt) { 
	var _this = jQuery(this);
	clearTimeout(_this.data('timeout'));
	_this.data('timeout', setTimeout(function() { submitFilterText(_this, evt) }, 500));
});
jQuery("fieldset.filter-fields input[type=checkbox]").bind('change', function(evt) {
	var form = jQuery(evt.target).parents("form").trigger("submit");
});
jQuery("fieldset.filter-fields").parent().bind('submit', function(evt) {
	var id = '#' + jQuery(this).parents(".tab-pane").attr('id');
	var form, filters = '';
    form = jQuery(evt.target);

    form.find("input[type=checkbox]:checked").each(function(){
      filters = filters + '&filters=' + jQuery(this).data('filterName');
    });

    jQuery(id + ' .results').load(form.attr('action') + ' ' + id + ' .results', form.serialize() + filters);
    return false;
});
</g:javascript>
