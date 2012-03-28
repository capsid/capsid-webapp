
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
		<title>${alignmentInstance.name}</title>
	</head>
	<body>
		<div class="row-fluid has_sidebar use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Details</li>
						<table class="table">
							<tbody>
							<g:if test="${alignmentInstance?.aligner}">
							<tr>
								<td><g:message code="sample.aligner.label" default="Aligner" /></td>
								<td><g:fieldValue bean="${alignmentInstance}" field="aligner"/></td>
							</tr>
							</g:if>
						
							<g:if test="${alignmentInstance?.platform}">
							<tr>
								<td><g:message code="sample.platform.label" default="Platform" /></td>						
								<td>${alignmentInstance.platform}</td>
							</tr>
							</g:if>
						
							<g:if test="${alignmentInstance?.type}">
							<tr>
								<td><g:message code="sample.type.label" default="Type" /></td>
								<td><g:fieldValue bean="${alignmentInstance}" field="type"/></td>
							</tr>
							</g:if>

							<g:if test="${alignmentInstance?.infile}">
							<tr>
								<td><g:message code="sample.infile.label" default="Input" /></td>
								<td><g:fieldValue bean="${alignmentInstance}" field="infile"/></td>
							</tr>
							</g:if>

							<g:if test="${alignmentInstance?.outfile}">
							<tr>
								<td><g:message code="sample.outfile.label" default="Output" /></td>
								<td><g:fieldValue bean="${alignmentInstance}" field="outfile"/></td>
							</tr>
							</g:if>
							</tbody>
						</table>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			
			<div class="content">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${alignmentInstance.project}">${Project.findByLabel(alignmentInstance.project).name}</g:link> 
						<span class="divider">/</span>
					</li>
					<li>
						<g:link controller="sample" action="show" id="${alignmentInstance.sample}">${Sample.findByName(alignmentInstance.sample).name}</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1>${alignmentInstance.name}</h1>
					</div>
					<auth:ifAnyGranted access="[(alignmentInstance?.project):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${alignmentInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${alignmentInstance?.name}">
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
								<g:sortableColumn params="${params}" property="sample" title="${message(code: 'statistics.sample.label', default: 'Sample')}" />
								<g:sortableColumn params="${params}" property="genomeHits" title="${message(code: 'statistics.genomeHits.label', default: 'Hits')}" />
								<g:sortableColumn params="${params}" property="geneHits" title="${message(code: 'statistics.geneHits.label', default: 'Hits on Genes')}" />
								<g:sortableColumn params="${params}" property="genomeCoverage" title="${message(code: 'statistics.genomeCoverage.label', default: 'Coverage')}" />
								<g:sortableColumn params="${params}" property="geneCoverageAvg" title="${message(code: 'statistics.geneCoverageAvg.label', default: 'Average Gene Coverage')}" />
								<g:sortableColumn params="${params}" property="geneCoverageMax" title="${message(code: 'statistics.geneCoverageMax.label', default: 'Maximum Gene Coverage')}" />
							</tr>
						</thead>
						<tbody>
						<g:each in="${statisticsInstanceList}" var="statisticsInstance">
							<tr>
								<td><g:link controller="sample" action="show" id="${statisticsInstance.sample}">${fieldValue(bean: statisticsInstance, field: "sample")}</g:link>
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
