<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid has_sidebar use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Details</li>
						<table class="table">
							<tbody>
							<g:if test="${sampleInstance?.cancer}">
							<tr>
								<td><g:message code="sample.cancer.label" default="Cancer" /></td>
								<td><g:fieldValue bean="${sampleInstance}" field="cancer"/></td>
							</tr>
							</g:if>
						
							<g:if test="${sampleInstance?.role}">
							<tr>
								<td><g:message code="sample.role.label" default="Role" /></td>						
								<td><g:fieldValue bean="${sampleInstance}" field="role"/></td>
							</tr>
							</g:if>
						
							<g:if test="${sampleInstance?.source}">
							<tr>
								<td><g:message code="sample.source.label" default="Source" /></td>
								<td><g:fieldValue bean="${sampleInstance}" field="source"/></td>
							</tr>
							</g:if>
							</tbody>
						</table>
					</ul>
					<hr>
					<ul class="nav nav-list">
						<li class="nav-header">Alignments</li>
						<input class="search-query span2" placeholder="Filter Alignments" type="text" id="filter">
						<auth:ifAnyGranted access="[(sampleInstance?.project):['collaborator', 'owner']]">
						<li>
							<div class="modal hide fade" id="myModal" style="display: none;">
					            <div class="modal-header">
					              <a data-dismiss="modal" class="close">×</a>
					              <h3>Add Alignment</h3>
					            </div>
				            	<div class="modal-body"></div>
					        </div>
							<g:link controller="alignment" action="create" params="[project:sampleInstance.project, sample:sampleInstance.name]" style="margin-top:10px;margin-bottom:3px;" data-target="#myModal" data-toggle="modal">
								<i class="icon-plus"></i>
								Add Alignment
							</g:link>
						</li>
						</auth:ifAnyGranted>
					</ul>
					<ul id="items" class="nav nav-list">
						<g:each in="${sampleInstance['alignments']}" var="alignmentInstance">
						<li rel="popover" data-placement="right" data-content="<strong>Aligner: </strong>${alignmentInstance.aligner}<br><strong>Platform: </strong>${alignmentInstance.platform}<br><strong>Type: </strong>${alignmentInstance.type}" data-title="${alignmentInstance.name}">
							<g:link controller="alignment" action="show" id="${alignmentInstance.name}">
								<i class="icon-folder-open"></i>
								${alignmentInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			
			<div class="content">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${sampleInstance.project}">${Project.findByLabel(sampleInstance.project).name}</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:fieldValue bean="${sampleInstance}" field="name"/><br>
						<small><g:fieldValue bean="${sampleInstance}" field="description"/></small></h1>
					</div>
					<auth:ifAnyGranted access="[(sampleInstance?.project):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${sampleInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${sampleInstance?.name}">
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
						<bootstrap:paginate id="${sampleInstance?.name}" total="${statisticsInstanceTotal}" params="${params}" />
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
