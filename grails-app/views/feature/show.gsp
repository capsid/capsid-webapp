
<%@ page import="ca.on.oicr.capsid.Feature" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'feature.label', default: 'Feature')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid has_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Details</li>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			
			<div class="content">
				<div class="page-header">
					<div>
						<h1><g:message code="default.show.label" args="[entityName]" /></h1>
					</div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<dl>
				
					<g:if test="${featureInstance?.end}">
						<dt><g:message code="feature.end.label" default="End" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="end"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.geneId}">
						<dt><g:message code="feature.geneId.label" default="Gene Id" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="geneId"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.genome}">
						<dt><g:message code="feature.genome.label" default="Genome" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="genome"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.locusTag}">
						<dt><g:message code="feature.locusTag.label" default="Locus Tag" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="locusTag"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.name}">
						<dt><g:message code="feature.name.label" default="Name" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="name"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.operator}">
						<dt><g:message code="feature.operator.label" default="Operator" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="operator"/></dd>
						
					</g:if>
				
					<g:if test="${featureInstance?.start}">
						<dt><g:message code="feature.start.label" default="Start" /></dt>
						
							<dd><g:fieldValue bean="${featureInstance}" field="start"/></dd>
						
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
