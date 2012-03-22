
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid has_sidebar use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">${entityName}</li>
						<li>
							<g:link class="list" action="list">
								<i class="icon-list"></i>
								<g:message code="default.list.label" args="[entityName]" />
							</g:link>
						</li>
						<li>
							<g:link class="create" action="create">
								<i class="icon-plus"></i>
								<g:message code="default.create.label" args="[entityName]" />
							</g:link>
						</li>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			
			<div class="content">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.show.label" args="[entityName]" /></h1>
					</div>
					<auth:ifAnyGranted access="[(${alignmentInstance}.label):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${alignmentInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${alignmentInstance?.id}">
								<i class="icon-pencil"></i>
								<g:message code="default.button.edit.label" default="Edit" />
							</g:link>
						</div>
					</g:form>
					</auth:ifAnyGranted>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<dl>
				
					<g:if test="${alignmentInstance?.aligner}">
						<dt><g:message code="alignment.aligner.label" default="Aligner" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="aligner"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.infile}">
						<dt><g:message code="alignment.infile.label" default="Infile" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="infile"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.name}">
						<dt><g:message code="alignment.name.label" default="Name" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="name"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.outfile}">
						<dt><g:message code="alignment.outfile.label" default="Outfile" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="outfile"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.platform}">
						<dt><g:message code="alignment.platform.label" default="Platform" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="platform"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.project}">
						<dt><g:message code="alignment.project.label" default="Project" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="project"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.sample}">
						<dt><g:message code="alignment.sample.label" default="Sample" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="sample"/></dd>
						
					</g:if>
				
					<g:if test="${alignmentInstance?.type}">
						<dt><g:message code="alignment.type.label" default="Type" /></dt>
						
							<dd><g:fieldValue bean="${alignmentInstance}" field="type"/></dd>
						
					</g:if>
				
				</dl>
			</div>
		</div>
	</body>
</html>
