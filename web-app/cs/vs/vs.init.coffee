$ ->
	generateParams = (facets) ->
		$.each facets, (i, item) ->
			for key in item
				if _.contains visualSearch.options.unquotable, key 
					params.push key + '=' + item[key]
				else params.push key + '="' + item[key] + '"'

				
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
			vs.options.callbacks.search query, null, false
		   
			
	visualSearch = VS.init
		container: ($ '.visual_search')
		unquotable: []
		callbacks: 
			search: (query, searchCollection, push) ->	    		
	    		($ "#results").css opacity: 0.5
	    		
	    		params = generateParams(visualSearch.searchQuery.facets())
	    		uriParams = params.join '&'
	    		
	    		($ '#results').load 'table', uriParams, ->
    				window.history.pushState null, '', window.location.pathname + '?' + uriParams if push
		    		($ "#results").css opacity: 1.0
	
		    		
	window.addEventListener "popstate", (e) ->
		watch(visualSearch)

		
	return false