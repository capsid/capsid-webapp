$(function() {
  var s, query, visualSearch;

  visualSearch = VS.init({
    container: $('.visual_search'),
    query: '',
    unquotable : ['name'],
    callbacks: {
      search: function(query, searchCollection, noPush) {
    	  var params = [], noPush = noPush, unq = visualSearch.options.unquotable;
    	  console.log(noPush);
    	  // Fade out on s
    	  $("#results").css({ opacity: 0.5 });
    	  
    	  /* This is need to serialize properly for server side filtering.
    	   * Would be better if it could be done from the model
    	   */
    	  $.each(visualSearch.searchQuery.facets(), function(i, item){
    		  for (key in item) {
    			  if (_.contains(unq, key)) {params.push(key + '=' + item[key]);}
    			  else {params.push(key + '="' + item[key] + '"');}
    		  }
    	  });
    	  
    	  // Load results and fade in
    	  $('#results').load('list #table', params.join('&'), function() {
          if (!noPush) {
    		    window.history.pushState(null, '', window.location.pathname + '?' + params.join('&'));
    		  }
          $("#results").css({ opacity: 1.0 });
    	  });
      },
      facetMatches: function(callback) {
        callback(['name', 'description', 'samples']);
      },
      valueMatches: function(facet, serachTerm, callback) {
        switch (facet) {
          case 'name':
        	var list = [];
        	$.getJSON('list.json', function(data) {
        		$.each(data, function(i, item) {
        			list.push({'value':item.label, 'label': item.name});
        		});
        		return callback(list);
        	});
            
          case 'gi':
        	return callback(['published', 'unpublished', 'draft']);
          case 'taxonomy':
            return callback(['Pentagon Papers', 'CoffeeScript Manual', 'Laboratory for Object Oriented Thinking', 'A Repository Grows in Brooklyn']);
          case 'organism':
            return callback(['orga', 'nism']);
        }
      }
    }
  });
  
  q = window.location.search.replace(/\?/, '').replace(/\=/g, ': ').replace(/\&/g, ' ').replace(/\%20/g, ' ');
  visualSearch.searchBox.value(q);

  window.addEventListener("popstate", function(e) {
	  q = window.location.search.replace(/\?/, '').replace(/\=/g, ': ').replace(/\&/g, ' ').replace(/\%20/g, ' ');
    visualSearch.searchBox.value(q);
	  visualSearch.options.callbacks.search(q, '', true);
  });
  s = $('#search');
  s.fadeIn();
});