
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="span3">
				<div class="well">
					<ul class="nav nav-list">
						<li>
							<g:link controller="sample" action="create">
								<i class="icon-plus"></i>
								Add Sample
							</g:link>
						</li>
						<li class="nav-header">Samples</li>
						<input class="search-query span2" placeholder="Filter Samples" type="text" id="sample_filter">
						<g:each in="${projectInstance['samples']}" var="sampleInstance">
						<li class="popover_item" rel="popover" data-placement="right" data-content="${sampleInstance.description}<br><strong>Cancer: </strong>${sampleInstance.cancer}<br><strong>Role: </strong>${sampleInstance.role}<br><strong>Source: </strong>${sampleInstance.source}" data-title="${sampleInstance.name}">
							<g:link controller="sample" action="show" id="${sampleInstance.name}">
								<i class="icon-folder-open"></i>
								${sampleInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
			</div>
			<div class="span9">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:fieldValue bean="${projectInstance}" field="name"/><br>
						<small><g:fieldValue bean="${projectInstance}" field="description"/></small>
						</h1>
						<a href="${projectInstance.wikiLink}" target="_blank">${projectInstance.wikiLink}</a>
					</div>
					<auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${projectInstance?.label}" />
						<div>
							<g:link class="btn" action="edit" id="${projectInstance?.label}">
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
			</div>
		</div>
	</body>
</html>
