<%@ page import="ca.on.oicr.capsid.Genome" %>
<html>
<head>
  <meta name="layout" content="main">
	<link rel="stylesheet" type="text/css" href="${resource(dir:'js/jbrowse/jslib/dijit/themes/tundra',file:'tundra.css')}"></link>
    <link rel="stylesheet" type="text/css" href="${resource(dir:'js/jbrowse', file:'genome.css')}"></link>
	<p:dependantJavascript>
    <script type="text/javascript" src="${resource(dir:'js/jbrowse/jslib/dojo', file:'jbrowse_dojo.js')}" ></script>
    <script type="text/javascript" src="${resource(dir:'js/jbrowse', file:'prototype.js')}"></script>
    <script type="text/javascript" src="${resource(dir:'js/jbrowse', file:'jbrowse.js')}"></script>
    
    <script type="text/javascript">
    /* <![CDATA[ */
			var queryParams = dojo.queryToObject(window.location.search.slice(1));
            console.log(queryParams);
            dojo.ready(function() {
        	    dojo.xhrGet({
	   	            url: "${createLink(controller:'jbrowse', action:'setup', id:params.id)}",
	   	            handleAs: "json",
	   	            load: function(setup) {
	   	            	// Hide Loader
	   	            	dojo.destroy(dojo.byId("setup-loader"));
	   	            	// Create Browser
	   	                var b = new Browser({
	   	                    containerID: "browser"
	   	                ,   refSeqs: setup.refseqs
	   	                ,   trackData: setup.trackInfo
	   	                ,   overviewTrackData: []
	   	                ,   defaultTracks: "DNA,genes"
	   	                ,   location: queryParams.loc
	   	                ,   tracks: "DNA,genes," + queryParams.track
	   	                ,   dataRoot: ""
		                ,   browserRoot: "${resource(dir:'js/jbrowse')}/"
			            ,   conf : {'flags': {'trackCustomizationOff': true, 'facetedOff': true,}}
	   	                });
	   	                 
		   	            /* var gb=document.getElementById("browser").genomeBrowser;
			   	        b.removeAllTracks();
		                b.showTracks("DNA,genes," + queryParams.track);
                        */
	   	         	}
        	    });
           });
    /* ]]> */
    </script>
    </p:dependantJavascript>
</head>
<body>
<g:if test="${flash.message}">
<div class="message">${flash.message}</div>
</g:if>
<h1 style="display:inline">${genomeInstance?.name.replaceAll("_"," ")} (${genomeInstance?.accession.replaceAll("_"," ")}), ${genomeInstance?.length}bp</h1> [<a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank" style="color:#444">Link to NCBI Nucleotide DB</a>]
<div id="setup-loader"><span>Setting Up jBrowse...</span></div>
<div id="browser" style="height:500px;width:100%"></div>
</body>
</html>
