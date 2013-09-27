<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="Genome" />
		<title>${genomeInstance.accession} - ${genomeInstance.name}</title>
		<script src="${resource(dir: 'js/jbrowse', file: 'dojo.js.uncompressed.js')}"></script>
	    <r:require module="jbrowse"/>
		
		<r:script>
		require(["dojo", "dojo/ready", "JBrowse/Browser"], function(dojo, ready, Browser){
    		ready(function() {
    			var queryParams = dojo.queryToObject(window.location.search.slice(1));
    			var resourceBase = "${resource(dir: "static/jbrowse")}";
            
            	dojo.destroy(dojo.byId("setup-loader"));
            	console.log("Link", resourceBase);
                new Browser({
                    containerID: "browser",
                    browserRoot: resourceBase,
                    include: [
                      '../config'
                    ],
                    refSeqs: "${createLink(controller:'browse', action:'refSeqs', id:params.id)}",
                    nameUrl: "${createLink(controller:'browse', action:'names', id:params.id)}",
                    defaultTracks: "DNA,Genes",
                    location: queryParams.loc,
                    tracks : [{
				        urlTemplate    : "sequence/{refseq}?",
				        args_chunkSize : 20000,
				        label          : "DNA",
				        type           : "JBrowse/View/Track/Wiggle/Density",
				        key            : "DNA",
				        storeClass     : "JBrowse/Store/SeqFeature/REST"
				      },
				      {
				        urlTemplate    : "genes/{refseq}?",
				        label          : "Genes",
				        type           : "JBrowse/View/Track/HTMLFeatures",
				        key            : "Genes",
				        storeClass     : "JBrowse/Store/SeqFeature/REST"
				      }]
                });

           	});
        });
	    </r:script>
	</head>
	<body>
		<div class="content" style="margin: 0 -20px;">
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
