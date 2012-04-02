
<%@ page import="ca.on.oicr.capsid.Feature" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'feature.label', default: 'Feature')}" />
		<title>Gene List</title>
		<r:require modules="visualsearch-feature-list"/>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="row-fluid page-header">
					<div>
						<h1>Gene List</h1>
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
								<g:sortableColumn params="${params}" property="name" title="${message(code: 'feature.name.label', default: 'Name')}" />
							
								<g:sortableColumn params="${params}" property="genome" title="${message(code: 'feature.genome.label', default: 'Genome')}" />

								<g:sortableColumn params="${params}" property="geneId" title="${message(code: 'feature.geneId.label', default: 'Gene Id')}" />
								
								<g:sortableColumn params="${params}" property="locusTag" title="${message(code: 'feature.locusTag.label', default: 'Locus Tag')}" />
							
								<g:sortableColumn params="${params}" property="start" title="${message(code: 'feature.start.label', default: 'Start')}" />

								<g:sortableColumn params="${params}" property="end" title="${message(code: 'feature.end.label', default: 'End')}" />
								<th>${message(code: 'feature.length.label', default: 'Length')}</th>
							</tr>
						</thead>
						<tbody>
						<g:each in="${featureInstanceList}" var="featureInstance">
							<g:set var="genomeInstance" value="${Genome.findByGi(featureInstance.genome)}"/>
							<tr>
							
								<td><g:link action="show" id="${featureInstance.uid}">${fieldValue(bean: featureInstance, field: "name")}</g:link></td>
							
								<td><g:link controller="genome" action="show" id="">${genomeInstance.name}</g:link></td>
							
								<td>${featureInstance.geneId}</td>
							
								<td>${fieldValue(bean: featureInstance, field: "locusTag")}</td>
							
								<td>${fieldValue(bean: featureInstance, field: "start")}</td>
								<td>${fieldValue(bean: featureInstance, field: "end")}</td>

								<td>${featureInstance.end - featureInstance.start}</td>
							
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate total="${featureInstanceTotal}" params="${params}"/>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
