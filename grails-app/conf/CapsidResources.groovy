modules = {
	
	capsid {
		dependsOn 'jquery, jqueryplugins, bootstrap'
		resource url:'less/responsive.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_capsid'
		resource url:'less/style.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_capsid'
		resource url:'cs/capsid.coffee', bundle: 'bundle_capsid'
	}

    jqueryplugins {
        dependsOn 'jquery'
        resource url:'js/lib/jquery.pjax.js', bundle: 'bundle_jquery'   
    }

    
    jbrowse {   
        resource url:'js/jbrowse/jslib/dijit/themes/tundra/tundra.css', bundle: 'bundle_jbrowse'
        resource url:'js/jbrowse/genome.css', bundle: 'bundle_jbrowse'
        resource url:'less/jbrowse.less',attrs:[rel: "stylesheet/less", type:'css'], bundle:'bundle_jbrowse'

        resource url:'js/jbrowse/jslib/dojo/jbrowse_dojo.js'
        resource url:'js/jbrowse/prototype.js'        
        resource url:'js/jbrowse/jbrowse.js', bundle: 'bundle_jbrowse'
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