modules = {
	'visualsearch-sample-list' {
		dependsOn 'visualsearch'
		resource url:'js/visualsearch/visualsearch.sample.list.js'
	}
	'visualsearch-feature-list' {
		dependsOn 'visualsearch'
		resource url:'js/visualsearch/visualsearch.feature.list.js'
	}
	'visualsearch-genome-list' {
		dependsOn 'visualsearch'
		resource url:'js/visualsearch/visualsearch.genome.list.js'
	}
	'visualsearch-project-list' {
		dependsOn 'visualsearch'
		resource url:'js/visualsearch/visualsearch.project.list.js'
	}
	visualsearch {
		dependsOn 'jquery, jquery-ui, backbone'
		resource url:'css/visualsearch-datauri.css'
		resource url:'js/lib/visualsearch.js'
	}
	backbone {
		dependsOn 'underscore, json2'
		resource url:'js/lib/backbone-min.js', bundle: 'bundle_backbone'
	}
	underscore {
		resource url:'js/lib/underscore.js', bundle: 'bundle_backbone'
	}
	json2 {
		resource url:'js/lib/json2.js', bundle: 'bundle_backbone'
	}
    
}