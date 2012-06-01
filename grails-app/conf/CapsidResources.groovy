modules = {
	
	capsid {
        dependsOn 'bootstrap'
		resource url:'js/capsid.js'
        resource url:'css/style.css'        
	}

    jbrowse {
        resource url:'js/jbrowse/jslib/dijit/themes/tundra/tundra.css', bundle: 'bundle_jbrowse'
        resource url:'js/jbrowse/genome.css', bundle: 'bundle_jbrowse'
        resource url:'css/jbrowse.css', bundle:'bundle_jbrowse'

        resource url:'js/jbrowse/jslib/dojo/jbrowse_dojo.js'
        resource url:'js/jbrowse/prototype.js'        
        resource url:'js/jbrowse/jbrowse.js', bundle: 'bundle_jbrowse'
    }

    bootstrap {
        dependsOn 'jquery'
        resource url:'js/bootstrap.min.js'
        resource url:'css/bootstrap.min.css'   
    }

    overrides {
        jquery {
            resource id:'js', disposition:'defer'    
        }
    }
}