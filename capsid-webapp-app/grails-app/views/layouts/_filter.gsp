<g:form action="${id?'show':'list'}" id="${id}" params="${(projectLabel ? [projectLabel: projectLabel] : [:]).plus(sampleName ? [sampleName: sampleName] : [:])}" class="form-horizontal pull-right search">
	<fieldset class="filter-fields filter-basic">
		<legend>Filters</legend>
		<label><input type="text" name="text" class="input-small search-query filter-search"><span class="userclear">&times;</span> Search</label>
	</fieldset>
</g:form>
<g:javascript>
jQuery("fieldset.filter-fields.filter-basic input.filter-search").bind('keyup', function(evt) { 
	var _this = jQuery(this);
	function submitFilterText(element, evt) {
	    var form = element.parents("form");
	    form.trigger("submit");
    }
    clearTimeout(_this.data('timeout'));
	_this.data('timeout', setTimeout(function() { submitFilterText(_this, evt) }, 500));
});
jQuery("fieldset.filter-fields.filter-basic").parent().bind('submit', function(evt) {
	evt.preventDefault();
	evt.stopPropagation();
	var id = '#' + jQuery(this).parents(".tab-pane").attr('id');
	var form = jQuery(evt.target);

    jQuery(id + ' .results').load(form.attr('action') + ' ' + id + ' .results', form.serialize());
    return false;
});
jQuery("span.userclear").bind('click', function(evt){
    evt.preventDefault();
    var form = jQuery(evt.target).parents("form");
    form.find("input.search-query").val("").focus();
    form.trigger("submit");
    return false;
});
</g:javascript>
