modules = {

    capsid {
    	dependsOn 'modernizr, bootstrap, jquery'
    	resource url:'less/responsive.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    	resource url:'less/style.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    }

    visualsearch {
        dependsOn 'jquery, jquery-ui, backbone'
        resource url:'css/visualsearch-datauri.css'
        resource url:'js/lib/visualsearch.js', bundle: 'bundle_vsjs'
        resource url:'cs/capsid.coffee', bundle: 'bundle_vsjs'
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
            resource id:'js', url:'plugins/jquery-1.7.1/js/jquery/jquery-1.7.1.min.js', disposition:'defer'    
        }
        'jquery-ui' {
            dependsOn 'jquery'
            resource id:'js', url:'plugins/jquery-ui-1.8.15/jquery-ui/js/jquery-ui-1.8.15.custom.min.js',disposition: 'defer'
        }
    }
}