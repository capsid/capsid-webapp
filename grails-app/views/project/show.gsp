
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid has_sidebar use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
					<div class="modal hide fade" id="myModal" style="display: none;">
			            <div class="modal-header">
			              <a data-dismiss="modal" class="close">×</a>
			              <h3>Add Sample</h3>
			            </div>
			            <div class="modal-body"></div>
			        </div>
					<ul class="nav nav-list">
						<li class="nav-header">Samples</li>
						<input class="search-query span2" placeholder="Filter Samples" type="text" id="filter">
						<li>
							<g:link controller="sample" action="create" params="[project:projectInstance.label]" style="margin-top:10px;margin-bottom:3px;" data-target="#myModal" data-toggle="modal">
								<i class="icon-plus"></i>
								Add Sample
							</g:link>
						</li>
					</ul>
					<ul id="items" class="nav nav-list">
						<g:each in="${projectInstance['samples']}" var="sampleInstance">
						<li rel="popover" data-placement="right" data-content="${sampleInstance.description}<br><strong>Cancer: </strong>${sampleInstance.cancer}<br><strong>Role: </strong>${sampleInstance.role}<br><strong>Source: </strong>${sampleInstance.source}" data-title="${sampleInstance.name}">
							<g:link controller="sample" action="show" id="${sampleInstance.name}">
								<i class="icon-folder-open"></i>
								${sampleInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			<div class="content">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:fieldValue bean="${projectInstance}" field="name"/><br>
						<small><g:fieldValue bean="${projectInstance}" field="description"/></small>
						</h1>
						<a href="${projectInstance.wikiLink}" target="_blank">${projectInstance.wikiLink}</a>
					</div>
					<auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${projectInstance?.label}" />
						<div>
							<g:link class="btn" action="edit" id="${projectInstance?.label}">
								<i class="icon-pencil"></i>
								<g:message code="default.button.edit.label" default="Edit" />
							</g:link>
						</div>
					</g:form>
					</auth:ifAnyGranted>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<table class="table table-striped table-condensed">
						<thead>
							<tr>
								<g:sortableColumn params="${params}" property="genome" title="${message(code: 'project.genome.label', default: 'Genome')}" />
								<g:sortableColumn params="${params}" property="genomeHits" title="${message(code: 'project.genome.label', default: 'Hits')}" />
								<g:sortableColumn params="${params}" property="geneHits" title="${message(code: 'project.genome.label', default: 'Hits on Genes')}" />
								<g:sortableColumn params="${params}" property="genomeCoverage" title="${message(code: 'project.genome.label', default: 'Coverage')}" />
								<g:sortableColumn params="${params}" property="geneCoverageAvg" title="${message(code: 'project.genome.label', default: 'Average Gene Coverage')}" />
								<g:sortableColumn params="${params}" property="geneCoverageMax" title="${message(code: 'project.genome.label', default: 'Maximum Gene Coverage')}" />
							</tr>
						</thead>
						<tbody>
						<g:each in="${statisticsInstanceList}" var="statisticsInstance">
							<tr>
								<td><g:link controller="genome" action="show" id="${statisticsInstance.accession}">${fieldValue(bean: statisticsInstance, field: "genome")}</g:link>
								<td>${fieldValue(bean: statisticsInstance, field: "genomeHits")}</td>
	
								<td>${fieldValue(bean: statisticsInstance, field: "geneHits")}</td>
	
								<td><g:formatNumber number="${statisticsInstance.genomeCoverage}" maxFractionDigits="2" type="percent"/></td>
	
								<td><g:formatNumber number="${statisticsInstance.geneCoverageAvg}" maxFractionDigits="2" type="percent"/></td>
	
								<td><g:formatNumber number="${statisticsInstance.geneCoverageMax}" maxFractionDigits="2" type="percent"/></td>
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate id="${projectInstance?.label}" total="${statisticsInstanceTotal}" params="${params}" />
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
