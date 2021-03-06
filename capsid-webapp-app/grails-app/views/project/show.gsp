<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title>${projectInstance.name}</title>
		<asset:javascript src="charts.js"/>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="page-header row-fluid">
					<div class="pull-left">
						<h1 id="${projectInstance.label}"><small>PROJECT</small> <g:fieldValue bean="${projectInstance}" field="name"/><br>
						<small><g:fieldValue bean="${projectInstance}" field="description"/></small>
						</h1>
						<a href="${projectInstance.wikiLink}" target="_blank">${projectInstance.wikiLink}</a>
					</div>
					<auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'owner']]">
					<div class="pull-right">
						<div class="modal hide fade" id="create" style="display: none;">
				            <div class="modal-header">
				            	<a data-dismiss="modal" class="close">×</a>
				            	<h3>Add Sample</h3>
				            </div>
							<g:form class="form-horizontal" controller="sample" action="save" style="margin:0">
								<fieldset>
						            <g:render template="/sample/create" model="[sampleInstance: new Sample(['project':projectInstance.label])]"/>
						       	</fieldset>
							</g:form>
				        </div>
						<g:link action="edit" class="btn" id="${projectInstance?.label}">
							<i class="icon-pencil"></i>
							<g:message code="default.button.edit.label" default="Edit" />
						</g:link>
						<g:link action="create" class="btn btn-primary" data-target="#create" data-toggle="modal">
							<i class="icon-plus icon-white"></i>
							Sample
						</g:link>
					</div>
					</auth:ifAnyGranted>
				</div>
				<div class="row-fluid">
					<g:if test="${flash.message}">
					<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
					</g:if>

					<ul id="nav-tab-controller" class="nav nav-tabs">
				    	<li class="active"><a href="#genomes-tab" data-toggle="tab">Genomes</a></li>
					    <li><a href="#samples" data-toggle="tab">Samples</a></li>
				    </ul>


				    <div class="tab-content">

						<div class="tab-pane active" id="genomes-tab">
							<div class="row-fluid">
								<div class="span2">
									<g:render template="/layouts/genomeFilter" model="['id':projectInstance.label]"/>
								</div>
								<div class="span10">

									<div id="stats-table" class="results">

										<div class="pull-right"><bootstrap:pageSummary total="${statistics.totalCount}" params="${params}" /></div>
										<table class="table table-striped table-condensed capsid-results">
											<thead>
												<tr>
													<g:sortableColumn params="${params}" property="genome" title="${message(code: 'project.genome.label', default: 'Genome')}" />
													<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeHits" title="${message(code: 'project.genome.label', default: 'Hits')}" />
													<g:sortableColumn params="${params}" defaultOrder="desc" property="geneHits" title="${message(code: 'project.genome.label', default: 'Hits on Genes')}" />
													<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeCoverage" title="${message(code: 'project.genome.label', default: 'Coverage')}" />
													<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageAvg" title="${message(code: 'project.genome.label', default: 'Average Gene Coverage')}" />
													<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageMax" title="${message(code: 'project.genome.label', default: 'Maximum Gene Coverage')}" />
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
												</tr>
											</g:each>
											</tbody>
										</table>
										<div class="pagination">
											<bootstrap:paginate action="show" id="${projectInstance?.label}" total="${statistics.totalCount}" params="${params}" />
										</div>
									</div>
								</div>
							</div>
						</div>


						<div class="tab-pane" id="samples">
							<div class="row-fluid">

								<div class="span2">
									<g:render template="/layouts/filter" model="['id':projectInstance.label]"/>
								</div>
								<div class="span10">

									<div id="samples-table" class="results">
										<div class="pull-right"><bootstrap:pageSummary total="${statistics.totalCount}" params="${params}" /></div>
										<table class="table table-striped table-condensed capsid-results">
											<thead>
												<tr>
													<g:sortableColumn params="${params}" property="name" title="${message(code: 'sample.name.label', default: 'Name')}" />
													<g:sortableColumn params="${params}" property="description" title="${message(code: 'sample.description.label', default: 'Description')}" />
													<g:sortableColumn params="${params}" property="cancer" title="${message(code: 'sample.cancer.label', default: 'Cancer')}" />
													<g:sortableColumn params="${params}" property="role" title="${message(code: 'sample.role.label', default: 'Role')}" />
													<g:sortableColumn params="${params}" property="source" title="${message(code: 'sample.source.label', default: 'Source')}" />
												</tr>
											</thead>
											<tbody>
											<g:each in="${samples}" var="sampleInstance">
												<tr>
													<td><g:link controller="sample" action="show" id="${sampleInstance.name}" params="${[projectLabel: sampleInstance.projectLabel]}">${fieldValue(bean: sampleInstance, field: "name")}</g:link></td>
													<td>${fieldValue(bean: sampleInstance, field: "description")}</td>
													<td>${fieldValue(bean: sampleInstance, field: "cancer")}</td>
													<td>${fieldValue(bean: sampleInstance, field: "role")}</td>
													<td>${fieldValue(bean: sampleInstance, field: "source")}</td>
												</tr>
											</g:each>
											</tbody>
										</table>
										<div class="pagination">
											<bootstrap:paginate action="show" id="${projectInstance?.label}" total="${samples.totalCount}" params="${params}" />
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
