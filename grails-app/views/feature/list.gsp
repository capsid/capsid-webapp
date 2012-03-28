
<%@ page import="ca.on.oicr.capsid.Feature" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'feature.label', default: 'Feature')}" />
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
								<g:sortableColumn params="${params}" property="name" title="${message(code: 'feature.name.label', default: 'Name')}" />
							
								<g:sortableColumn params="${params}" property="genome" title="${message(code: 'feature.genome.label', default: 'Genome')}" />

								<g:sortableColumn params="${params}" property="geneId" title="${message(code: 'feature.geneId.label', default: 'Gene Id')}" />
								
								<g:sortableColumn params="${params}" property="locusTag" title="${message(code: 'feature.locusTag.label', default: 'Locus Tag')}" />
							
								<g:sortableColumn params="${params}" property="type" title="${message(code: 'feature.type.label', default: 'Type')}" />
								<g:sortableColumn params="${params}" property="start" title="${message(code: 'feature.start.label', default: 'Start')}" />
								<g:sortableColumn params="${params}" property="end" title="${message(code: 'feature.end.label', default: 'End')}" />
								<th>${message(code: 'feature.length.label', default: 'Length')}</th>
							
								
								
							
								
								
								
							</tr>
						</thead>
						<tbody>
						<g:each in="${featureInstanceList}" var="featureInstance">
							<tr>
							
								<td><g:link action="show" id="${featureInstance.uid}">${fieldValue(bean: featureInstance, field: "name")}</g:link></td>
							
								<td>${fieldValue(bean: featureInstance, field: "genome")}</td>
							
								<td>${fieldValue(bean: featureInstance, field: "geneId")}</td>
							
								<td>${fieldValue(bean: featureInstance, field: "locusTag")}</td>
							
								<td>${fieldValue(bean: featureInstance, field: "type")}</td>
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
