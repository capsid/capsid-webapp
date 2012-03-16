
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="span3">
				<div class="well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Details</li>
						<table class="table">
							<tbody>
							<g:if test="${genomeInstance?.accession}">
							<tr>
								<td><g:message code="sample.accession.label" default="Accession" /></td>
								<td><g:fieldValue bean="${genomeInstance}" field="accession"/></td>
							</tr>
							</g:if>
						
							<g:if test="${genomeInstance?.gi}">
							<tr>
								<td><g:message code="sample.gi.label" default="GI" /></td>						
								<td><g:fieldValue bean="${genomeInstance}" field="gi"/></td>
							</tr>
							</g:if>
						
							<g:if test="${genomeInstance?.organism}">
							<tr>
								<td><g:message code="sample.organism.label" default="Organism" /></td>
								<td><g:fieldValue bean="${genomeInstance}" field="organism"/></td>
							</tr>
							</g:if>

							<g:if test="${genomeInstance?.length}">
							<tr>
								<td><g:message code="sample.length.label" default="Length" /></td>
								<td><g:fieldValue bean="${genomeInstance}" field="length"/></td>
							</tr>
							</g:if>
							</tbody>
						</table>
						<hr>
						<li class="nav-header">Links</li>
			 			<li><a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank">NCBI Nucleotide DB</a></li>
			        	<g:if test="${genomeInstance.organism == 'Homo sapiens'}">
			            <li><a href="http://www.ncbi.nlm.nih.gov/mapview/maps.cgi?taxid=9606&chr=${genomeInstance.name.minus('chr')}" target="_blank">NCBI Map Viewer</a></li>
			          	</g:if>
			          	<li><a href="http://www.ncbi.nlm.nih.gov/sites/gquery?term=${genomeInstance.accession}" target="_blank">Search NCBI</a></li>
			          	<li><g:link controller="jbrowse" action="show" id="${genomeInstance.accession}">View in JBrowse</g:link></li>
					</ul>
					<hr>
					<ul class="nav nav-list">
						<li class="nav-header">Genes</li>
						<input class="search-query span2" placeholder="Filter Genes" type="text" id="gene_filter">
						<g:each in="${genomeInstance['genes']}" var="featureInstance">
						<li class="popover_item" rel="popover" data-placement="right" data-title="${featureInstance.name}" data-content="hi">
							<g:link controller="feature" action="show" id="${featureInstance.uid}">
								<i class="icon-folder-open"></i>
								${featureInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
			</div>
			
			<div class="span9">
				<div class="row-fluid page-header">
					<div>
						<h1><g:fieldValue bean="${genomeInstance}" field="name"/><br><small>${genomeInstance.taxonomy.join(', ')}</small></h1>
					</div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
			</div>
		</div>
	</body>
</html>
