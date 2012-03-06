<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<g:set var="project" value="${Project.findByLabel(sampleInstance.project)}" />
		
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
					<li><g:link controller="project" action="show" id="${sampleInstance.project}">${project.name}</g:link> <span class="divider">/</span></li>
					<li class="active"><g:fieldValue bean="${sampleInstance}" field="name"/> <span class="divider">/</span></li>
					<li class="active">Summary</li>
				</ul>	
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:fieldValue bean="${sampleInstance}" field="name"/></h1>
					</div>
					<g:form style="float:right">
						<g:hiddenField name="id" value="${sampleInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${sampleInstance?.name}">
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
					<g:if test="${sampleInstance?.cancer}">
						<dt><g:message code="sample.cancer.label" default="Cancer" /></dt>
						
							<dd><g:fieldValue bean="${sampleInstance}" field="cancer"/></dd>
						
					</g:if>
				
					<g:if test="${sampleInstance?.description}">
						<dt><g:message code="sample.description.label" default="Description" /></dt>
						
							<dd><g:fieldValue bean="${sampleInstance}" field="description"/></dd>
						
					</g:if>
				
					<g:if test="${sampleInstance?.project}">
						<dt><g:message code="sample.project.label" default="Project" /></dt>
						
							<dd><g:fieldValue bean="${sampleInstance}" field="project"/></dd>
						
					</g:if>
				
					<g:if test="${sampleInstance?.role}">
						<dt><g:message code="sample.role.label" default="Role" /></dt>
						
							<dd><g:fieldValue bean="${sampleInstance}" field="role"/></dd>
						
					</g:if>
				
					<g:if test="${sampleInstance?.source}">
						<dt><g:message code="sample.source.label" default="Source" /></dt>
						
							<dd><g:fieldValue bean="${sampleInstance}" field="source"/></dd>
						
					</g:if>
				</dl>
			</div>
		</div>
	</body>
</html>
