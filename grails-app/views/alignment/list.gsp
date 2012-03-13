
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
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
								
									<g:sortableColumn property="aligner" title="${message(code: 'alignment.aligner.label', default: 'Aligner')}" />
								
									<g:sortableColumn property="infile" title="${message(code: 'alignment.infile.label', default: 'Infile')}" />
								
									<g:sortableColumn property="name" title="${message(code: 'alignment.name.label', default: 'Name')}" />
								
									<g:sortableColumn property="outfile" title="${message(code: 'alignment.outfile.label', default: 'Outfile')}" />
								
									<g:sortableColumn property="platform" title="${message(code: 'alignment.platform.label', default: 'Platform')}" />
								
									<g:sortableColumn property="project" title="${message(code: 'alignment.project.label', default: 'Project')}" />
								
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
								
									<td class="link">
										    <div class="btn-group pull-right">
											    <g:link action="show" id="${alignmentInstance.id}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
											    <auth:ifAnyGranted access="[(alignmentInstance.label):['collaborator', 'owner']]">
											    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
											    <span class="caret"></span>
											    </a>
											    <ul class="dropdown-menu">
											    	<li><g:link action="show" id="${alignmentInstance.label}"><i class="icon-chevron-right"></i> Show</g:link></li>
											    	<li><g:link action="edit" id="${alignmentInstance.label}"><i class="icon-pencil"></i> Edit</g:link></li>
												</ul>
												</auth:ifAnyGranted>
										    </div>
									</td>
								</tr>
							</g:each>
							</tbody>
						</table>
						<div class="pagination">
							<bootstrap:paginate total="${alignmentInstanceTotal}" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
