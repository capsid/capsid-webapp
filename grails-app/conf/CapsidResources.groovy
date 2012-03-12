modules = {

    capsid {
    	dependsOn 'bootstrap, jquery'
    	resource url:'less/responsive.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_capsid'
    	resource url:'less/style.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_capsid'
        resource url:'cs/capsid.coffee', bundle: 'bundle_capsid'
    }

    visualsearch {
        dependsOn 'jquery, jquery-ui, backbone'
        resource url:'css/visualsearch-datauri.css', bundle: 'bundle_vsjs'
        resource url:'js/lib/visualsearch.js', bundle: 'bundle_vsjs'
		resource url:'js/visualsearch/visualsearch.project.list.js', bundle: 'bundle_vsjs'
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

    overrides {
        jquery {
            resource id:'js', disposition:'defer'    
        }
        'jquery-ui' {
            dependsOn 'jquery'
            resource id:'js', disposition: 'defer'
        }
    }
}