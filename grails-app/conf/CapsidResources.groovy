modules = {
    style {
    	dependsOn 'bootstrap'
    	resource url:'less/responsive.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    	resource url:'less/style.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_style'
    }
    coffee {
        dependsOn 'jquery, backbone'
        resource url:'cs/capsid.coffee'
    }
    visualsearch {
        dependsOn 'jquery, backbone'
        resource url:'css/visualsearch-datauri.css',attrs:[rel: 'stylesheet/css', type:'css']
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