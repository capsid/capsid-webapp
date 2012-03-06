<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="span3">
				<div class="well">
					<ul class="nav nav-list">
						<li class="nav-header">${entityName}</li>
						<li class="active">
							<g:link class="list" action="list">
								<i class="icon-list icon-white"></i>
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
				<div class="page-header">
					<h1><g:message code="default.list.label" args="[entityName]" /></h1>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<filterpane:filterPane 
					domain="${Sample}" 
					style="display:block"
					filterPropertyValues="${[
						'project':[values: Project.list().name, keys:Project.list().label]
					,	'cancer':[values: Sample.list().cancer, keys:Sample.list().cancer]
					,	'source':[values: Sample.list().source, keys:Sample.list().source]
					]}"
				/>
				<table class="table table-striped">
					<thead>
						<tr>
						
							<g:sortableColumn property="cancer" title="${message(code: 'sample.cancer.label', default: 'Cancer')}" />
						
							<g:sortableColumn property="description" title="${message(code: 'sample.description.label', default: 'Description')}" />
						
							<g:sortableColumn property="name" title="${message(code: 'sample.name.label', default: 'Name')}" />
						
							<g:sortableColumn property="project" title="${message(code: 'sample.project.label', default: 'Project')}" />
						
							<g:sortableColumn property="role" title="${message(code: 'sample.role.label', default: 'Role')}" />
						
							<g:sortableColumn property="source" title="${message(code: 'sample.source.label', default: 'Source')}" />
						
							<th></th>
						</tr>
					</thead>
					<tbody>
					<g:each in="${sampleInstanceList}" var="sampleInstance">
						<tr>
						
							<td>${fieldValue(bean: sampleInstance, field: "cancer")}</td>
						
							<td>${fieldValue(bean: sampleInstance, field: "description")}</td>
						
							<td>${fieldValue(bean: sampleInstance, field: "name")}</td>
						
							<td>${fieldValue(bean: sampleInstance, field: "project")}</td>
						
							<td>${fieldValue(bean: sampleInstance, field: "role")}</td>
						
							<td>${fieldValue(bean: sampleInstance, field: "source")}</td>
						
							<td class="link">
								<g:link action="show" id="${sampleInstance.name}" class="btn btn-small">Show &raquo;</g:link>
							</td>
						</tr>
					</g:each>
					</tbody>
				</table>
				<div class="pagination">
					<bootstrap:paginate total="${sampleInstanceTotal}" />
				</div>
			</div>

		</div>
	</body>
</html>
