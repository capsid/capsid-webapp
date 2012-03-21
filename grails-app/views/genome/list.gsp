
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
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
								<g:sortableColumn params="${params}" property="accession" title="${message(code: 'genome.accession.label', default: 'Accession')}" />
								<g:sortableColumn params="${params}" property="name" title="${message(code: 'genome.name.label', default: 'Name')}" />
								<g:sortableColumn params="${params}" property="gi" title="${message(code: 'genome.gi.label', default: 'Gi')}" />
								<g:sortableColumn params="${params}" property="Taxonomy" title="${message(code: 'genome.taxonomy.label', default: 'Taxonomy')}" />
								<g:sortableColumn params="${params}" class="compress"  property="length" title="${message(code: 'genome.length.label', default: 'Length')}" />
								<g:sortableColumn params="${params}" class="compress" property="organism" title="${message(code: 'genome.organism.label', default: 'Organism')}" />
								<g:sortableColumn params="${params}" property="sampleCount" title="${message(code: 'genome.sampleCount.label', default: 'Sample Count')}" />
							</tr>
						</thead>
						<tbody>
						<g:each in="${genomeInstanceList}" var="genomeInstance">
							<tr>
								<td><g:link action="show" id="${genomeInstance.accession}">${fieldValue(bean: genomeInstance, field: "accession")}</g:link></td>
								<td>${fieldValue(bean: genomeInstance, field: "name")}</td>
								<td>${genomeInstance.gi}</td>
								<td>${genomeInstance.taxonomy.join(', ')}</td>
								<td class="compress">${fieldValue(bean: genomeInstance, field: "length")}</td>
								<td class="compress">${fieldValue(bean: genomeInstance, field: "organism")}</td>
								<td>${fieldValue(bean: genomeInstance, field: "sampleCount")}</td>
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate total="${genomeInstanceTotal}" params="${params}" />
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
