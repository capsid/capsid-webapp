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
    	  console.log(window.location);
    	  // Load results and fade in
    	  $('#results').load('list #table', params.join('&'), function() {
          if (!noPush) {
    		    window.history.pushState(null, '', window.location.pathname + '?' + params.join('&'));
    		  }
          $("#results").css({ opacity: 1.0 });
    	  });
      },
      facetMatches: function(callback) {
        callback(['project', 'accession', 'genome']);
      },
      valueMatches: function(facet, searchTerm, callback) {
        switch (facet) {
          case 'project':
        	var list = [];
        	$.getJSON('list.json', searchTerm, function(data) {
        		$.each(data, function(i, item) {
        			list.push({'value':item.label, 'label': item.name});
        		});
        		return callback(list);
        	});
        }
      }
    }
  });
  
  q = window.location.search.replace(/(offset|max)=\d+\&?/g,'').replace(/\?/, '').replace(/\=/g, ': ').replace(/\&/g, ' ')
                              .replace(/\%20/g, ' ').replace(/\%22/g, '');
  visualSearch.searchBox.value(q);

  window.addEventListener("popstate", function(e) {
	  q = window.location.search.replace(/(offset|max)=\d+\&?/g,'').replace(/\?/, '').replace(/\=/g, ': ').replace(/\&/g, ' ')
                              .replace(/\%20/g, ' ').replace(/\%22/g, '');
	  // Don't search if reloading the page - server already sending data back
	  if (q !== visualSearch.searchBox.currentQuery) {
		  visualSearch.searchBox.value(q);
		  visualSearch.options.callbacks.search(q, '', true);
	  }
  });
});