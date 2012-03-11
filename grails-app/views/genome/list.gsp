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
			<div class="">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<div class="visual_search" style="height:32px;"></div>

				<table class="table table-striped table-condensed">
					<thead>
						<tr>
						
							<g:sortableColumn property="accession" title="${message(code: 'genome.accession.label', default: 'Accession')}" />
							
							<g:sortableColumn property="name" title="${message(code: 'genome.name.label', default: 'Name')}" />
						
							<g:sortableColumn property="gi" title="${message(code: 'genome.gi.label', default: 'Gi')}" />
						
							<g:sortableColumn property="taxonomy" title="${message(code: 'genome.taxonomy.label', default: 'Taxonomy')}" />	
							
							<g:sortableColumn class="compress" property="organism" title="${message(code: 'genome.organism.label', default: 'Organism')}" />
						
							<g:sortableColumn class="compress" property="length" title="${message(code: 'genome.length.label', default: 'Length')}" />
						
							<g:sortableColumn property="sampleCount" title="${message(code: 'genome.sampleCount.label', default: 'Sample Count')}" />
						</tr>
					</thead>
					<tbody>
					<g:each in="${genomeInstanceList}" var="genomeInstance">
						<tr>
						
							<td>${fieldValue(bean: genomeInstance, field: "accession")}</td>
							
							<td>${fieldValue(bean: genomeInstance, field: "name")}</td>
							
							<td>${genomeInstance.gi}</td>

							<td>${genomeInstance.taxonomy.join(', ')}</td>
							
							<td class="compress">${fieldValue(bean: genomeInstance, field: "organism")}</td>

							<td class="compress">${fieldValue(bean: genomeInstance, field: "length")}</td>				
						
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
