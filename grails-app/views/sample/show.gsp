<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title>${sampleInstance.name}</title>
		<r:require modules="visualsearch-sample-show"/>
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
				<div class="page-header row-fluid">
					<div class="pull-left">
						<h1 id="${sampleInstance.name}"><small>SAMPLE</small> <g:fieldValue bean="${sampleInstance}" field="name"/><br>
						<small><g:fieldValue bean="${sampleInstance}" field="description"/></small></h1>
					</div>
					<auth:ifAnyGranted access="[(sampleInstance?.project):['collaborator', 'owner']]">
					<div class="pull-right">
						<div class="modal hide fade" id="create">
				            <div class="modal-header">
				              <a data-dismiss="modal" class="close">×</a>
				              <h3>Add Alignment</h3>
				            </div>
				            <fieldset>
								<g:form class="form-horizontal" controller="alignment" action="save" style="margin:0">
									<fieldset>
										<g:render template="/alignment/create" model="[alignmentInstance: new Alignment(['sample':sampleInstance.name, 'project':sampleInstance.project])]"/>
									</fieldset>
								</g:form>
							</fieldset>
				        </div>
						<g:link action="edit" class="btn" id="${sampleInstance?.name}">
							<i class="icon-pencil"></i>
							<g:message code="default.button.edit.label" default="Edit" />
						</g:link>
						<g:link controller="alignment" action="create" params="[project:sampleInstance.project, sample:sampleInstance.name]"  class="btn btn-primary" data-target="#create" data-toggle="modal">
							<i class="icon-plus icon-white"></i>
							Alignment
						</g:link>
					</div>
					</auth:ifAnyGranted>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<ul class="nav nav-tabs">
			    	<li class="active"><a href="#hits" data-toggle="tab">Genome Hits</a></li>
				    <li><a href="#alignments" data-toggle="tab">Alignments</a></li>
			    </ul>

				<div class="tab-content">
					<div class="tab-pane active" id="hits">
						<h2>Genome Hits</h2>
						<div class="visual_search" style="height:32px;"></div>
						<div id="stats-table" class="results">
							<table class="table table-striped table-condensed">
								<thead>
									<tr>
										<g:sortableColumn params="${params}" property="genome" title="${message(code: 'project.genome.label', default: 'Genome')}" />
										<g:sortableColumn params="${params}" property="genomeHits" title="${message(code: 'project.genome.label', default: 'Hits')}" />
										<g:sortableColumn params="${params}" property="geneHits" title="${message(code: 'project.genome.label', default: 'Hits on Genes')}" />
										<g:sortableColumn params="${params}" property="genomeCoverage" title="${message(code: 'project.genome.label', default: 'Coverage')}" />
										<g:sortableColumn params="${params}" property="geneCoverageAvg" title="${message(code: 'project.genome.label', default: 'Avg Gene Coverage')}" />
										<g:sortableColumn params="${params}" property="geneCoverageMax" title="${message(code: 'project.genome.label', default: 'Max Gene Coverage')}" />
										<th></th>
									</tr>
								</thead>
								<tbody>
								<g:each in="${statistics}" var="statisticsInstance">
									<tr>
										<td><g:link controller="genome" action="show" id="${statisticsInstance.accession}">${fieldValue(bean: statisticsInstance, field: "genome")}</g:link>
										<td>${fieldValue(bean: statisticsInstance, field: "genomeHits")}</td>
										<td>${fieldValue(bean: statisticsInstance, field: "geneHits")}</td>
										<td><g:formatNumber number="${statisticsInstance.genomeCoverage}" maxFractionDigits="2" type="percent"/></td>
										<td><g:formatNumber number="${statisticsInstance.geneCoverageAvg}" maxFractionDigits="2" type="percent"/></td>
										<td><g:formatNumber number="${statisticsInstance.geneCoverageMax}" maxFractionDigits="2" type="percent"/></td>
										<td><g:link controller="jbrowse" action="show" id="${statisticsInstance.accession}" params="[track:statisticsInstance.sample]">
											<i class="icon-share"></i> View Reads
										</g:link></td>
									</tr>
								</g:each>
								</tbody>
							</table>
							<div class="pagination">
								<bootstrap:paginate id="${sampleInstance?.name}" total="${statistics.totalCount}" params="${params}" />
							</div>
						</div>
					</div>
					<div class="tab-pane" id="alignments">
						<h2>Alignments</h2>
						<div class="visual_search" style="height:32px;"></div>
						<div id="alignments-table" class="results">
							<table class="table table-striped table-condensed">
								<thead>
									<tr>
										<g:sortableColumn params="${params}" property="name" title="${message(code: 'alignment.name.label', default: 'Name')}" />
										<g:sortableColumn params="${params}" property="sample" title="${message(code: 'alignment.sample.label', default: 'Sample')}" />
										<g:sortableColumn params="${params}" property="project" title="${message(code: 'alignment.project.label', default: 'Project')}" />
										<g:sortableColumn params="${params}" property="aligner" title="${message(code: 'alignment.aligner.label', default: 'Aligner')}" />
										<g:sortableColumn params="${params}" property="platform" title="${message(code: 'alignment.platform.label', default: 'Platform')}" />
										<g:sortableColumn params="${params}" property="type" title="${message(code: 'alignment.type.label', default: 'Type')}" />
									</tr>
								</thead>
								<tbody>
								<g:each in="${alignments}" var="alignmentInstance">
									<tr>
										<td><g:link controller="alignment" action="show" id="${alignmentInstance.name}">${fieldValue(bean: alignmentInstance, field: "name")}</g:link></td>
										<td><g:link controller="sample" action="show" id="${alignmentInstance.sample}">${fieldValue(bean: alignmentInstance, field: "sample")}</g:link></td>
										<td><g:link controller="project" action="show" id="${alignmentInstance.project}">${fieldValue(bean: alignmentInstance, field: "project")}</g:link></td>
										<td>${fieldValue(bean: alignmentInstance, field: "aligner")}</td>
										<td>${fieldValue(bean: alignmentInstance, field: "platform")}</td>
										<td>${fieldValue(bean: alignmentInstance, field: "type")}</td>
									</tr>
								</g:each>
								</tbody>
							</table>
							<div class="pagination">
								<bootstrap:paginate id="${sampleInstance?.name}" total="${alignments.totalCount}" params="${params}" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
