<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-horizontal pull-right search">
	<fieldset class="filter-fields">
		<legend>Filters</legend>
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
jQuery("fieldset.filter-fields").parent().bind('submit', function(evt) {
	var id = '#' + jQuery(this).parents(".tab-pane").attr('id');
	var form = jQuery(evt.target);

    jQuery(id + ' .results').load(form.attr('action') + ' ' + id + ' .results', form.serialize());
    return false;
});
</g:javascript>
