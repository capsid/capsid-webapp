
<%@ page import="ca.on.oicr.capsid.Feature" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'feature.label', default: 'Feature')}" />
		<g:set var="genomeInstance" value="${Genome.findByGi(featureInstance.genome)}"/>
		<title><g:fieldValue bean="${featureInstance}" field="name"/> : ${genomeInstance.accession}</title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="row-fluid page-header">
					<h1 class="pull-left"><small>FEATURE</small> ${featureInstance.name}</h1>
					<g:if test="${1 == 2}">
					<div id="blast" class="btn-group pull-right">
			        	<button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
			          		<i class="icon-share-alt icon-white"></i>
			          		BLAST <span class="caret"></span>
			        	</button>
			        	<ul class="dropdown-menu" style="left:auto; right:0;">
			            	<li><a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&LINK_LOC=blasthome&QUERY=${sequence}" target="_blank">BLAST Sequence</a></li>
			        	</ul>
			        </div>
			    	</g:if>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<h2><small>${featureInstance.type.toUpperCase()} ON GENOME</small> <g:link controller="genome" action="show" id="${genomeInstance.accession}">${genomeInstance.name}</g:link></h2>
				
				<div class="row-fluid">
					<div class="span6">
						<ul class="nav nav-list">
							<li class="nav-header">Details</li>
							<table class="table">
								<tbody>
								<g:if test="${featureInstance?.geneId}">
								<tr>
									<td><g:message code="feature.geneId.label" default="Gene Id" /></td>
									<td>${featureInstance.geneId}</td>
								</tr>
								</g:if>
							
								<g:if test="${featureInstance?.locusTag}">
								<tr>
									<td><g:message code="feature.locusTag.label" default="Locus Tag" /></td>						
									<td>${featureInstance.locusTag}</td>
								</tr>
								</g:if>
							
								<g:if test="${featureInstance?.start}">
								<tr>
									<td><g:message code="feature.start.label" default="Start" /></td>
									<td><g:fieldValue bean="${featureInstance}" field="start"/></td>
								</tr>
								</g:if>

								<g:if test="${featureInstance?.end}">
								<tr>
									<td><g:message code="feature.end.label" default="End" /></td>
									<td><g:fieldValue bean="${featureInstance}" field="end"/></td>
								</tr>
								</g:if>

								<g:if test="${featureInstance?.strand}">
								<tr>
									<td><g:message code="feature.strand.label" default="Strand" /></td>
									<td><g:fieldValue bean="${featureInstance}" field="strand"/></td>
								</tr>
								</g:if>
								</tbody>
							</table>
						</ul>
					</div>
					<div class="span6">
						<ul class="nav nav-list">
							<li class="nav-header">Links</li>

				 			<li><a href="http://www.ncbi.nlm.nih.gov/gene/${featureInstance.geneId}" target="_blank">NCBI Gene DB</a></li>
				          	<li><a href="http://www.ncbi.nlm.nih.gov/sites/gquery?term=${featureInstance.geneId}" target="_blank">Search NCBI</a></li>
				          	<li><g:link controller="browse" action="show" id="${genomeInstance.accession}" params="${[projectLabel: projectInstance?.label]}">View in genome browser</g:link></li>
				          </ul>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
