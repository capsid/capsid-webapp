
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
			</div>
			
			<div class="span9">
				<ul class="breadcrumb">
					<li class="active"><g:fieldValue bean="${projectInstance}" field="name"/> <span class="divider">/</span></li>
				</ul>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.show.label" args="[entityName]" /></h1>
					</div>
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${projectInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${projectInstance?.id}">
								<i class="icon-pencil"></i>
								<g:message code="default.button.edit.label" default="Edit" />
							</g:link>
							<button class="btn btn-danger" type="submit" name="_action_delete">
								<i class="icon-trash icon-white"></i>
								<g:message code="default.button.delete.label" default="Delete" />
							</button>
						</div>
					</g:form>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<dl>
				
					<g:if test="${projectInstance?.description}">
						<dt><g:message code="project.description.label" default="Description" /></dt>
						
							<dd><g:fieldValue bean="${projectInstance}" field="description"/></dd>
						
					</g:if>
				
					<g:if test="${projectInstance?.label}">
						<dt><g:message code="project.label.label" default="Label" /></dt>
						
							<dd><g:fieldValue bean="${projectInstance}" field="label"/></dd>
						
					</g:if>
				
					<g:if test="${projectInstance?.name}">
						<dt><g:message code="project.name.label" default="Name" /></dt>
						
							<dd><g:fieldValue bean="${projectInstance}" field="name"/></dd>
						
					</g:if>
				
					<g:if test="${projectInstance?.wikiLink}">
						<dt><g:message code="project.wikiLink.label" default="Wiki Link" /></dt>
						
							<dd><g:fieldValue bean="${projectInstance}" field="wikiLink"/></dd>
						
					</g:if>
				
				</dl>
			</div>

		</div>
	</body>
</html>
