(function($) {
 
    $.fn.hierarchyChooser = function(options) {

        var settings = $.extend({
            // These are the defaults.
            taxonRootId: 1,
            baseUrl: "http://localhost:3000/"
        }, options);

    	var chooser = '<div class="btn-group">' +
			'<a class="btn btn-small dropdown-toggle" data-toggle="dropdown" data-taxon-id="1" href="#">/ <span class="caret"></span></a>' +
			'<ul class="dropdown-menu">' +
			'</ul>' +
			'</div>'

		var _this = this;
		var internalChangeEvent = false;

    	function trim1 (str) {
 		   	return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
		}

    	function handleMenuClick(evt) {
    		var target = jQuery(evt.target);
    		var taxonId = parseInt(target.attr('data-taxon-id'));
    		var comName = target.text();

    		// Now we can create the new added item, and then refresh the menu.
    		var dropdown = $(_this).find(".dropdown-toggle");

    		// To add, modify the current item and a new one after it. 
    		var currentItemLabel = trim1(dropdown.text());
    		var newItem = "<a class='btn btn-small dropdown-toggle' data-toggle='dropdown' data-taxon-id='" + taxonId + "' href='#'>" + comName + " <span class='caret'></span></a>";

    		// This done, change the immediate text of the dropdown to the new common name. 
    		// The text() method should remove the old caret, sneakily. 
    		dropdown.text(currentItemLabel);
    		dropdown.removeClass('dropdown-toggle');
    		dropdown.removeAttr('data-toggle');
    		dropdown.after(newItem);

    		// We can also modify the click handling for the old item, so that it pops everything 
    		// back the way it was. 
    		dropdown.bind({'click' : handleRestoreClick});

    		refreshDropdownMenu(taxonId);
    		internalChangeEvent = true;
    		$(_this).trigger("change", {id: taxonId});
    		internalChangeEvent = false;
    	}

    	function handleRestoreClick(evt) {
    		evt.stopPropagation();
    		evt.preventDefault();

    		var target = jQuery(evt.target);
    		var taxonId = parseInt(target.attr('data-taxon-id'));
    		var comName = target.text();

    		// First of all, remove this handler.
    		target.unbind('click');

    		// Remove all the subsequent sibling controls, which are all <a> elements.
    		while(true) {
    			var next = target.next();
    			if (next.get(0).tagName == 'A') {
    				next.remove();
    			} else {
    				break;
    			}
    		}

    		// Now let's fix the current element back into having what we need. 
    		target.addClass('dropdown-toggle');
    		target.attr('data-toggle', 'dropdown');
    		target.append(" <span class='caret'></span>");

    		refreshDropdownMenu(taxonId);
    		internalChangeEvent = true;
    		$(_this).trigger("change", {id: taxonId});
    		internalChangeEvent = false;
    	}

    	function refreshDropdownMenu(taxonId) {
    		var serviceUrl = settings.baseUrl + "?parent=" + encodeURIComponent(taxonId);
	    	$.ajax({
	  			url: serviceUrl
			}).done(function(data) {
				// Handles the new data. This will be a list of values for the children of the
				// given taxon. These should be inserted into a new item and used to populate the
				// dropdown menu. 
				var elements = data.map(function(taxon) {
					return "<li><a data-taxon-id='" + taxon.id + "'>" + taxon.comName + "</a></li>"
				}).join("");
				var menu = $(_this).find(".dropdown-menu");
				menu.empty();
				menu.append(elements);

				menu.find("a").bind({'click': handleMenuClick});
			});
    	}

    	// The other main issue is initialization. We can be called with any valid identifier, and
    	// we need to figure out the full hierarchy for that. Which can be quite deep. This is 
    	// an API call, at least in theory. 

    	function initialize(taxonId) {
    		$(_this).empty();
    		$(_this).append(jQuery(chooser));
	    	var serviceUrl = settings.baseUrl + "?ancestors=" + encodeURIComponent(taxonId);
	    	$.ajax({
	  			url: serviceUrl
			}).done(function(data) {

				// In order of parenting, this allows us to add new items to the hierarchy. 
				for(var i = data.length - 1; i >= 0; i--) {
					var taxon = data[i];

		    		var dropdown = $(_this).find(".dropdown-toggle");

		    		// To add, modify the current item and a new one after it. 
		    		var currentItemLabel = trim1(dropdown.text());
		    		var newItem = "<a class='btn btn-small dropdown-toggle' data-toggle='dropdown' data-taxon-id='" + taxon.id + "' href='#'>" + taxon.comName + " <span class='caret'></span></a>";

		    		// This done, change the immediate text of the dropdown to the new common name. 
		    		// The text() method should remove the old caret, sneakily. 
		    		dropdown.text(currentItemLabel);
		    		dropdown.removeClass('dropdown-toggle');
		    		dropdown.removeAttr('data-toggle');
		    		dropdown.after(newItem);

		    		// We can also modify the click handling for the old item, so that it pops everything 
		    		// back the way it was. 
		    		dropdown.bind({'click' : handleRestoreClick});
				}
			});	
    	}

    	initialize(settings.taxonRootId);
    	refreshDropdownMenu(settings.taxonRootId);

    	$(_this).bind('change', function(evt, value) {
    		if (! internalChangeEvent) {
    			initialize(value.id);
    			refreshDropdownMenu(value.id);
    		}
    	});
    };
 
}(jQuery));