'use strict';

/**
 * Common JS functions and events for handling the filtering code. 
 */

jQuery(function($) {
	$("fieldset.filter-fields.filter-basic input.filter-search").bind('keyup', function(evt) { 
		var _this = $(this);
		function submitFilterText(element, evt) {
		    var form = element.parents("form");
		    form.trigger("submit");
	    }
	    clearTimeout(_this.data('timeout'));
		_this.data('timeout', setTimeout(function() { submitFilterText(_this, evt) }, 500));
	});
	$("fieldset.filter-fields.filter-basic").parent().bind('submit', function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		var id = '#' + $(this).parents(".tab-pane").attr('id');
		var form = $(evt.target);

	    $(id + ' .results').load(form.attr('action') + ' ' + id + ' .results', form.serialize());
	    return false;
	});
	$("fieldset.filter-fields.filter-basic span.userclear").bind('click', function(evt){
	    evt.preventDefault();
	    var form = $(evt.target).parents("form");
	    form.find("input.search-query").val("").focus();
	    form.trigger("submit");
	    return false;
	});

	$("fieldset.filter-fields.filter-advanced input.filter-search").bind('keyup', function(evt) { 
		var _this = $(this);
		function submitFilterText(element, evt) {
			var form = element.parents("form");
			form.trigger("submit");
		}
		clearTimeout(_this.data('timeout'));
		_this.data('timeout', setTimeout(function() { submitFilterText(_this, evt) }, 500));
	});
	$("fieldset.filter-fields.filter-advanced input[type=checkbox]").bind('change', function(evt) {
		var form = $(evt.target).parents("form").trigger("submit");
	});
	$("fieldset.filter-fields.filter-advanced").parent().bind('submit', function(evt) {
		var id = '#' + $(this).parents(".tab-pane").attr('id');
		var form, filters = '';
	    form = $(evt.target);

	    form.find("input[type=checkbox]:checked").each(function(){
	      filters = filters + '&filters=' + $(this).data('filterName');
	    });

	    $(id + ' .results').load(form.attr('action') + ' ' + id + ' .results', form.serialize() + filters);
	    return false;
	});
	$("fieldset.filter-fields.filter-advanced span.userclear").bind('click', function(evt){
	    evt.preventDefault();
	    var form = $(evt.target).parents("form");
	    form.find("input.search-query").val("").focus();
	    form.trigger("submit");
	    return false;
	});
});
