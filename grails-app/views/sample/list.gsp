<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<r:require module="visualsearch"/>
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
					<auth:ifCapsidAdmin>
					<div class="pull-right">
						<g:link class="btn btn-primary" action="create">
							<i class="icon-plus icon-white"></i>
							<g:message code="default.button.create.label" default="Create" />
						</g:link>
					</div>
					</auth:ifCapsidAdmin>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<div id="table">
						<table class="table table-striped table-condensed">
							<thead>
								<tr>
									<g:sortableColumn property="name" title="${message(code: 'sample.name.label', default: 'Name')}" />
									<g:sortableColumn property="project" title="${message(code: 'sample.project.label', default: 'Project')}" />
									<g:sortableColumn property="description" title="${message(code: 'sample.description.label', default: 'Description')}" />
									<g:sortableColumn property="cancer" title="${message(code: 'sample.cancer.label', default: 'Cancer')}" />
									<g:sortableColumn property="role" title="${message(code: 'sample.role.label', default: 'Role')}" />								
									<g:sortableColumn property="source" title="${message(code: 'sample.source.label', default: 'Source')}" />
								</tr>
							</thead>
							<tbody>
							<g:each in="${sampleInstanceList}" var="sampleInstance">
								<tr>
								
									<td>${fieldValue(bean: sampleInstance, field: "name")}</td>
									<td>${fieldValue(bean: sampleInstance, field: "project")}</td>
									<td>${fieldValue(bean: sampleInstance, field: "description")}</td>
									<td>${fieldValue(bean: sampleInstance, field: "cancer")}</td>
									<td>${fieldValue(bean: sampleInstance, field: "role")}</td>
									<td>${fieldValue(bean: sampleInstance, field: "source")}</td>
									<td class="link">
										    <div class="btn-group pull-right">
											    <g:link action="show" id="${sampleInstance.name}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
											    <auth:ifAnyGranted access="[(sampleInstance.project):['collaborator', 'owner']]">
											    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
											    <span class="caret"></span>
											    </a>
											    <ul class="dropdown-menu">
											    	<li><g:link action="show" id="${sampleInstance.name}"><i class="icon-chevron-right"></i> Show</g:link></li>
											    	<li><g:link action="edit" id="${sampleInstance.name}"><i class="icon-pencil"></i> Edit</g:link></li>
												</ul>
												</auth:ifAnyGranted>
										    </div>
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
			</div>
		</div>
	</body>
</html>
