
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
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
									<g:sortableColumn property="name" title="${message(code: 'project.name.label', default: 'Name')}" />
									
									<g:sortableColumn property="description" title="${message(code: 'project.description.label', default: 'Description')}" />
								
									<th>Samples</th>
								
								</tr>
							</thead>
							<tbody>
							<g:each in="${projectInstanceList}" var="projectInstance">
								<tr>
									<td><strong>${fieldValue(bean: projectInstance, field: "name")}</strong></td>
									<td>${fieldValue(bean: projectInstance, field: "description")}</td>
									<td>${projectInstance["sampleCount"]}</td>
								
									<td class="link">
										    <div class="btn-group pull-right">
											    <g:link action="show" id="${projectInstance.label}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
											    <auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'owner']]">
											    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
											    <span class="caret"></span>
											    </a>
											    <ul class="dropdown-menu">
											    	<li><g:link action="show" id="${projectInstance.label}"><i class="icon-chevron-right"></i> Show</g:link></li>
											    	<li><g:link action="edit" id="${projectInstance.label}"><i class="icon-pencil"></i> Edit</g:link></li>
												</ul>
												</auth:ifAnyGranted>
										    </div>
									</td>
								</tr>
							</g:each>
							</tbody>
						</table>
						<div class="pagination">
							<bootstrap:paginate total="${projectInstanceTotal}" />
						</div>
					</div>
				</div>
			</div>

		</div>
	</body>
</html>
