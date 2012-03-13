
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
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
								
									<g:sortableColumn property="accession" title="${message(code: 'genome.accession.label', default: 'Accession')}" />
								
									<g:sortableColumn property="gi" title="${message(code: 'genome.gi.label', default: 'Gi')}" />
								
									<g:sortableColumn property="length" title="${message(code: 'genome.length.label', default: 'Length')}" />
								
									<g:sortableColumn property="name" title="${message(code: 'genome.name.label', default: 'Name')}" />
								
									<g:sortableColumn property="organism" title="${message(code: 'genome.organism.label', default: 'Organism')}" />
								
									<g:sortableColumn property="sampleCount" title="${message(code: 'genome.sampleCount.label', default: 'Sample Count')}" />
								
								</tr>
							</thead>
							<tbody>
							<g:each in="${genomeInstanceList}" var="genomeInstance">
								<tr>
								
									<td>${fieldValue(bean: genomeInstance, field: "accession")}</td>
								
									<td>${fieldValue(bean: genomeInstance, field: "gi")}</td>
								
									<td>${fieldValue(bean: genomeInstance, field: "length")}</td>
								
									<td>${fieldValue(bean: genomeInstance, field: "name")}</td>
								
									<td>${fieldValue(bean: genomeInstance, field: "organism")}</td>
								
									<td>${fieldValue(bean: genomeInstance, field: "sampleCount")}</td>
								
									<td class="link">
										    <div class="btn-group pull-right">
											    <g:link action="show" id="${genomeInstance.id}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
											    <auth:ifAnyGranted access="[(genomeInstance.label):['collaborator', 'owner']]">
											    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
											    <span class="caret"></span>
											    </a>
											    <ul class="dropdown-menu">
											    	<li><g:link action="show" id="${genomeInstance.label}"><i class="icon-chevron-right"></i> Show</g:link></li>
											    	<li><g:link action="edit" id="${genomeInstance.label}"><i class="icon-pencil"></i> Edit</g:link></li>
												</ul>
												</auth:ifAnyGranted>
										    </div>
									</td>
								</tr>
							</g:each>
							</tbody>
						</table>
						<div class="pagination">
							<bootstrap:paginate total="${genomeInstanceTotal}" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
