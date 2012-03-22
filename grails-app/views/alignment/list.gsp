
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="row-fluid page-header">
					<div>
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<table class="table table-striped table-condensed">
						<thead>
							<tr>
							
								<g:sortableColumn params="${params}" property="aligner" title="${message(code: 'alignment.aligner.label', default: 'Aligner')}" />
							
								<g:sortableColumn params="${params}" property="infile" title="${message(code: 'alignment.infile.label', default: 'Infile')}" />
							
								<g:sortableColumn params="${params}" property="name" title="${message(code: 'alignment.name.label', default: 'Name')}" />
							
								<g:sortableColumn params="${params}" property="outfile" title="${message(code: 'alignment.outfile.label', default: 'Outfile')}" />
							
								<g:sortableColumn params="${params}" property="platform" title="${message(code: 'alignment.platform.label', default: 'Platform')}" />
							
								<g:sortableColumn params="${params}" property="project" title="${message(code: 'alignment.project.label', default: 'Project')}" />
							
							</tr>
						</thead>
						<tbody>
						<g:each in="${alignmentInstanceList}" var="alignmentInstance">
							<tr>
							
								<td>${fieldValue(bean: alignmentInstance, field: "aligner")}</td>
							
								<td>${fieldValue(bean: alignmentInstance, field: "infile")}</td>
							
								<td>${fieldValue(bean: alignmentInstance, field: "name")}</td>
							
								<td>${fieldValue(bean: alignmentInstance, field: "outfile")}</td>
							
								<td>${fieldValue(bean: alignmentInstance, field: "platform")}</td>
							
								<td>${fieldValue(bean: alignmentInstance, field: "project")}</td>
							
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate total="${alignmentInstanceTotal}" params="${params}"/>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
