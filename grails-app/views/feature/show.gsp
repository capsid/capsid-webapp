
<%@ page import="ca.on.oicr.capsid.Feature" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'feature.label', default: 'Feature')}" />
		<g:set var="genomeInstance" value="${Genome.findByGi(featureInstance.genome)}"/>
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<ul class="breadcrumb">
					<li>
						<g:link controller="genome" action="show" id="${genomeInstance.accession}">
						${genomeInstance.name}
						</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="page-header">
					<div>
						<h1><g:fieldValue bean="${featureInstance}" field="name"/></h1>
					</div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<dl>
					<g:if test="${featureInstance?.geneId}">
						<dt><g:message code="feature.geneId.label" default="Gene Id" /></dt>
						
							<dd>${featureInstance.geneId}</dd>
						
					</g:if>
	
					<g:if test="${featureInstance?.locusTag}">
						<dt><g:message code="feature.locusTag.label" default="Locus Tag" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="locusTag"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.start}">
						<dt><g:message code="feature.start.label" default="Start" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="start"/></dd>
						
					</g:if>
				

					<g:if test="${featureInstance?.end}">
						<dt><g:message code="feature.end.label" default="End" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="end"/></dd>
						
					</g:if>
					
				
					
					<g:if test="${featureInstance?.strand}">
						<dt><g:message code="feature.strand.label" default="Strand" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="strand"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.type}">
						<dt><g:message code="feature.type.label" default="Type" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="type"/></dd>
						
					</g:if>
				
				</dl>
			</div>
		</div>
	</body>
</html>
