<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="Genome" />
		<title>${genomeInstance.accession} - ${genomeInstance.name}</title>
		<r:require modules="browser"/>

	</head>
	<body>
		<div class="content">
			<div class="page-header">
				<h1>
					<g:link controller="genome" action="show" id="${genomeInstance.accession}" params="${[projectLabel: projectInstance.label]}">${fieldValue(bean: genomeInstance, field: "name")} (${fieldValue(bean: genomeInstance, field: "accession")})</g:link>
					<small> ${fieldValue(bean: genomeInstance, field: "length")}bp</small>
				</h1>
				[<a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank" style="color:#444">Link to NCBI Nucleotide DB</a>]
			</div>

			<g:if test="${flash.message}">
			<div class="message">${flash.message}</div>
			</g:if>
			
			<div id="setup-loader"><span>Setting up genome browser...</span></div>

			<div id="checkBrowser"></div>

			<div id="gm" >
				<div id="gv-application"></div>
				<div id="gv-tracks" class="css-treeview">
					<ul>
					<g:each var="project" status="p" in="${projectService.list([:])}">
						<li><input type="checkbox" id="item-${p}" /><label for="item-${p}">${project.name}</label>
							<ul>
							<g:each var="sample" status="s" in="${sampleService.list([projectId: project.id])}">
								<li class="capsid-draggable-track-title" draggable="true" data-track-identifier="${project.label}-${sample.name}">${sample.name}</li>
							</g:each>
							</ul>
					</g:each>
					</ul>
				</div>
			</div>
			<div id="gv-closer"></div>
		</div>

		<g:javascript>
var genomeViewer = initializeGenomeViewer();
var urlBase = "${resource(dir: '/browse/api')}";
addGeneTrack(genomeViewer, urlBase, {
	accession: "${genomeInstance.accession}"
});
		</g:javascript>
		<g:if test="${sampleInstance}">
		<g:javascript>
addSampleTrack(genomeViewer, urlBase, {
	accession: "${genomeInstance.accession}",
	projectLabel: "${projectInstance.label}",
	sampleName: "${sampleInstance.name}"
});
		</g:javascript>
		</g:if>
		<g:javascript>
bootstrapGenomeViewer(genomeViewer);
jQuery("#setup-loader").remove();
		</g:javascript>
	</body>
</html>
