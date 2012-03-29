
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>	
		<r:require modules="visualsearch"/>
		<r:require modules="vs-project-list"/>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
					<auth:ifCapsidAdmin>
					<div class="pull-right">
						<div class="modal hide fade" id="create" style="display: none;">
				            <div class="modal-header">
				              <a data-dismiss="modal" class="close">×</a>
				              <h3>Create Project</h3>
				            </div>
				            <fieldset>
								<g:form class="form-horizontal" action="save" style="margin:0">
									<fieldset>
							            <g:render template="/project/create" model="[projectInstance: new Project(params)]"/>
							       	</fieldset>
								</g:form>
							</fieldset>
				        </div>
						<g:link action="create" class="btn btn-primary" data-target="#create" data-toggle="modal">
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
					<table class="table table-striped table-condensed">
						<thead>
							<tr>
								<g:sortableColumn params="${params}" property="name" title="${message(code: 'project.name.label', default: 'Name')}" />						
								<g:sortableColumn params="${params}" property="description" title="${message(code: 'project.description.label', default: 'Description')}" />							
								<th>Samples</th>						
							</tr>
						</thead>
						<tbody>
						<g:each in="${projectInstanceList}" var="projectInstance">
							<tr>
								<td><g:link action="show" id="${projectInstance.label}">${fieldValue(bean: projectInstance, field: "name")}</g:link>
								<td>${fieldValue(bean: projectInstance, field: "description")}</td>
								<td>${projectInstance["sampleCount"]}</td>
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate total="${projectInstanceTotal}" params="${params}"/>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
