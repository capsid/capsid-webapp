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
        resource url:'css/jbrowse_main.css'
        resource url:'css/sequence.css'
        resource url:'css/menubar.css'
        resource url:'css/icons.css'
        resource url:'css/file_dialog.css'
        resource url:'css/combination_tracks.css'
        resource url:'css/export_dialog.css'
        resource url:'css/track_styles.css'
        resource url:'css/faceted_track_selector.css'



        //@import url("main.css");
        //@import url("sequence.css");
        //@import url("menubar.css");
        //@import url("icons.css");
        //@import url("file_dialog.css");
        //@import url("combination_tracks.css");
        //@import url("export_dialog.css");

        // ///* CSS styles for the various types of feature glyphs */
        //@import url("track_styles.css");
        //@import url("faceted_track_selector.css");


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