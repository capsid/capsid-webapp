modules = {
	
	capsid {
        dependsOn 'bootstrap'
		resource url:'js/capsid.js'
        resource url:'css/style.css'        
	}

    browser {
        dependsOn 'bootstrap'
        resource url:'js/jquery.qtip.min.js'
        resource url:'js/bootstrap-slider.js'
        resource url:'js/underscore-min.js'
        resource url:'js/backbone-min.js'
        resource url:'js/d3.v3.js'
        resource url:'js/hierarchy.js'
        resource url:'js/genome-viewer-1.0.2.js'
        resource url:'js/capsid-navigation-bar.js'
        resource url:'js/capsid-gene-track.js'
        resource url:'js/capsid-gene-adapter.js'
        resource url:'js/capsid-gene-renderer.js'
        resource url:'js/capsid-feature-track.js'
        resource url:'js/capsid-feature-adapter.js'
        resource url:'js/capsid-feature-renderer.js'
        resource url:'js/browser-config.js'
        resource url:'js/capsid-browser.js'
        resource url:'css/slider.css'
        resource url:'css/jquery.qtip.css'
        resource url:'css/treeview.css'
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