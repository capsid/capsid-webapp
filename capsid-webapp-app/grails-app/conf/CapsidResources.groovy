modules = {
	
	capsid {
        dependsOn 'bootstrap'
		resource url:'js/capsid.js'
        resource url:'css/style.css'        
	}

    //dojo {
    //    resource url:'js/jbrowse/jslib/dijit/themes/tundra/tundra.css'
    //}

    jbrowse {
        //dependsOn 'dojo'
        //resource url:'js/jbrowse/jslib/dijit/themes/tundra/tundra.css', bundle: 'bundle_jbrowse'
        //resource url:'js/jbrowse/genome.css', bundle: 'bundle_jbrowse'
        resource url:'css/tundra.css'
        resource url:'css/jbrowse.css'
        //resource url:'js/jbrowse/dojo.js'
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