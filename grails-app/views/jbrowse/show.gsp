<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
		<title>${genomeInstance.accession} - ${genomeInstance.name}</title>
		<script src="/capsiddev/js/jbrowse/jslib/dojo/dojo.js" data-dojo-config="parseOnLoad:true"/></script>
	    <r:require module="jbrowse"/>
		
		<r:script>
    		dojo.ready(function() {
    			var queryParams = dojo.queryToObject(window.location.search.slice(1));
            
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
     	         	}
        	    });
           });
	    </r:script>
	</head>
	<body>
		<div class="content" style="margin: 0pt -20px;">
			<div class="page-header">
				<h1>
					<g:link controller="genome" action="show" id="${genomeInstance.accession}">${fieldValue(bean: genomeInstance, field: "name")} (${fieldValue(bean: genomeInstance, field: "accession")})</g:link>
					<small> ${fieldValue(bean: genomeInstance, field: "length")}bp</small>
				</h1>
				[<a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank" style="color:#444">Link to NCBI Nucleotide DB</a>]
			</div>
			<g:if test="${flash.message}">
			<div class="message">${flash.message}</div>
			</g:if>
			<div id="setup-loader"><span>Setting Up jBrowse...</span></div>
			<div id="browser" style="border-right: 1px solid #ddd; border-bottom: 1px solid #ddd; height:750px;width:100%"></div>
		</div>
	</body>
</html>
