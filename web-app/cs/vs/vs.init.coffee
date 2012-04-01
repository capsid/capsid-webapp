$ ->		

	convertParamsToVS = (uri) ->
   		#// This is needed to serialize properly for server side filtering.
   		#// Would be better if it could be done from the model
		uri.replace(/((offset|max|sort|order)=.+\&?)|(\?)|(\%22)/g,'')
		   .replace(/(\%20)|(\&)/, ' ')
		   .replace(/\=/g, ': ')

		   
	watch = (vs) ->
		query = convertParamsToVS window.location.search
		
		#// Refresh if params changed, but not during refresh
		if query != visualSearch.searchBox.currentQuery
			vs.searchBox.value query
			vs.options.callbacks.search query, null, true
		   
			
	visualSearch = VS.init
		container: ($ '.visual_search')
		unquotable: ['name']
		callbacks: 
			search: (query, searchCollection, push) ->	    		
	    		($ "#results").css opacity: 0.5
	    		vsParams = []
	    		
	    		$.each visualSearch.searchQuery.facets(), (i, item) ->
		       		for key in item
		       			if _.contains unq, key 
		       				vsParams.push(key + '=' + item[key])
		       			else vsParams.push(key + '="' + item[key] + '"')
		       	console.log vsParams
	    		uriParams = vsParams.join '&'
	    		
	    		($ '#results').load 'list #results', uriParams, ->
	    			console.log uriParams
    				window.history.pushState null, '', window.location.pathname + '?' + uriParams if push
		    		($ "#results").css opacity: 1.0
	
			facetMatches: (callback) ->
			    callback ['name']
		    		
			valueMatches: (facet, searchTerm, callback) ->
				switch facet
					when 'name'
						list = []
						$.getJSON 'list.json?name=' + searchTerm, (data) ->
							$.each data, (i, item) ->
								list.push 'value':item.label, 'label': item.name

							return callback list
		    		
			
	window.addEventListener "popstate", (e) ->
		watch(visualSearch)

		
	return false