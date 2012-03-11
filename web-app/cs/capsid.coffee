$ ->
	visualSearch = VS.init
	    container: $ '.visual_search'
	    query: ''
	    callbacks: 
	        search: (query, searchCollection) ->
	        facetMatches: (callback) ->
		        callback [
		          'account', 
		          'filter', 
		          'access', 
		          'title',
		          { label: 'city',    category: 'location' },
		          { label: 'address', category: 'location' },
		          { label: 'country', category: 'location' },
		          { label: 'state',   category: 'location' }
		        ]
		        return
	        valueMatches: (facet, serachTerm, callback) ->
		        switch facet
			        when 'account'
			            callback [
			                { value: '1-amanda', label: 'Amanda' },
			                { value: '2-aron',   label: 'Aron' },
			                { value: '3-eric',   label: 'Eric' },
			                { value: '4-jeremy', label: 'Jeremy' },
			                { value: '5-samuel', label: 'Samuel' },
			                { value: '6-scott',  label: 'Scott' }
			            ]
			        when 'filter'
			            callback ['published', 'unpublished', 'draft']
			        when 'access'
			            callback ['public', 'private', 'protected']
			        when 'title'
			            callback [
			                'Pentagon Papers',
			                'CoffeeScript Manual',
			                'Laboratory for Object Oriented Thinking',
			                'A Repository Grows in Brooklyn'
			            ]
		return

	s = $ '#search' 
	s.fadeIn()