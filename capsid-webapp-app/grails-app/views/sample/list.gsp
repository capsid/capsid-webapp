<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content tab-pane" id="sample-list">
				<div class="row-fluid page-header">
					<div>
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<div class="row-fluid">

					<div class="span2">
						<g:render template="/layouts/filter" model="[]"/>
 					</div>
					<div class="span10">
 						<div id="samples" class="results">
							<div class="pull-right"><bootstrap:pageSummary total="${samples.totalCount}" params="${params}" /></div>

							<table class="table table-striped table-condensed">
								<thead>
									<tr>
										<g:sortableColumn params="${params}" property="name" title="${message(code: 'sample.name.label', default: 'Name')}" />
										<g:sortableColumn params="${params}" property="project" title="${message(code: 'sample.project.label', default: 'Project')}" />
										<g:sortableColumn params="${params}" property="description" title="${message(code: 'sample.description.label', default: 'Description')}" />
										<g:sortableColumn params="${params}" property="cancer" title="${message(code: 'sample.cancer.label', default: 'Cancer')}" />
										<g:sortableColumn params="${params}" property="role" title="${message(code: 'sample.role.label', default: 'Role')}" />								
										<g:sortableColumn params="${params}" property="source" title="${message(code: 'sample.source.label', default: 'Source')}" />
									</tr>
								</thead>
								<tbody>
								<g:each in="${samples}" var="sampleInstance">
									<tr>		
										<td><g:link action="show" id="${sampleInstance.name}" params="${[projectLabel: sampleInstance.projectLabel]}">${fieldValue(bean: sampleInstance, field: "name")}</g:link></td>
										<td><g:link controller="project" action="show" id="${sampleInstance.projectLabel}">${Project.findById(sampleInstance.projectId).name}</g:link></td>
										<td>${fieldValue(bean: sampleInstance, field: "description")}</td>
										<td>${fieldValue(bean: sampleInstance, field: "cancer")}</td>
										<td>${fieldValue(bean: sampleInstance, field: "role")}</td>
										<td>${fieldValue(bean: sampleInstance, field: "source")}</td>
									</tr>
								</g:each>
								</tbody>
							</table>
							<div class="pagination">
								<bootstrap:paginate total="${samples.totalCount}" params="${params}" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
