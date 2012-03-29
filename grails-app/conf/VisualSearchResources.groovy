modules = {

	'vs-project-list' {
		dependsOn 'visualsearch'
		resource url:'cs/vs/vs.project.list.coffee'
	}
	
	visualsearch {
		dependsOn 'jquery, jquery-ui, backbone'
		resource url:'css/visualsearch-datauri.css'
		resource url:'js/lib/visualsearch.js'
		resource url:'cs/vs/vs.init.coffee'
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