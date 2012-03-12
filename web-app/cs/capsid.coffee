$ ->
	visualSearch = VS.init
		container: $ '.visual_search'
		query: ''
		callbacks: 
			search: (query, searchCollection) ->
				alert 'search'
				return
			facetMatches: (callback) ->
				callback ['accession', 'gi', 'name', 'taxonomy', 'organism']
			valueMatches: (facet, serachTerm, callback) ->
				switch facet
					when 'accession'
						callback [
						          { value: '1-amanda', label: 'Amanda' },
						          { value: '2-aron',   label: 'Aron' },
						          { value: '3-eric',   label: 'Eric' },
						          { value: '4-jeremy', label: 'Jeremy' },
						          { value: '5-samuel', label: 'Samuel' },
						          { value: '6-scott',  label: 'Scott' }
						          ]
					when 'gi'
						callback ['published', 'unpublished', 'draft']
					when 'name'
						callback ['public', 'private', 'protected']
					when 'taxonomy'
						callback [
						          'Pentagon Papers',
						          'CoffeeScript Manual',
						          'Laboratory for Object Oriented Thinking',
						          'A Repository Grows in Brooklyn'
						          ]
					when 'organism'
						callback ['orga', 'nism']

	s = $ '#search' 
	s.fadeIn()
	return