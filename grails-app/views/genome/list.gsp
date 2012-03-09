<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
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
					</ul>
				</div>
			</div>

			<div class="span9">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<table class="table table-striped table-condensed">
					<thead>
						<tr>
						
							<g:sortableColumn property="accession" title="${message(code: 'genome.accession.label', default: 'Accession')}" />
						
							<g:sortableColumn property="gi" title="${message(code: 'genome.gi.label', default: 'Gi')}" />
						
							<g:sortableColumn property="length" title="${message(code: 'genome.length.label', default: 'Length')}" />
						
							<g:sortableColumn property="name" title="${message(code: 'genome.name.label', default: 'Name')}" />
						
							<g:sortableColumn class="nav-compress" property="organism" title="${message(code: 'genome.organism.label', default: 'Organism')}" />
						
							<g:sortableColumn property="sampleCount" title="${message(code: 'genome.sampleCount.label', default: 'Sample Count')}" />
						
							<th width="75">
								<div class="btn btn-info btn-small pull-right">Fitler &raquo;</div>
							</th>
						</tr>
					</thead>
					<tbody>
					<g:each in="${genomeInstanceList}" var="genomeInstance">
						<tr>
						
							<td>${fieldValue(bean: genomeInstance, field: "accession")}</td>
						
							<td>${genomeInstance.gi}</td>
						
							<td>${fieldValue(bean: genomeInstance, field: "length")}</td>
						
							<td>${fieldValue(bean: genomeInstance, field: "name")}</td>
						
							<td>${fieldValue(bean: genomeInstance, field: "organism")}</td>
						
							<td>${fieldValue(bean: genomeInstance, field: "sampleCount")}</td>
						
							<td class="link">
								    <div class="btn-group pull-right">
									    <g:link action="show" id="${genomeInstance.id}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
									    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
									    <span class="caret"></span>
									    </a>
									    <ul class="dropdown-menu">
									    	<li><g:link action="show" id="${genomeInstance.id}"><i class="icon-chevron-right"></i> Show</g:link></li>
									    	<li><g:link action="edit" id="${genomeInstance.id}"><i class="icon-pencil"></i> Edit</g:link></li>
									    	<li class="divider"></li>
									    	<li><g:link action="delete" id="${genomeInstance.id}"><i class="icon-trash"></i> Delete</g:link></li>
										</ul>
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
	</body>
</html>
