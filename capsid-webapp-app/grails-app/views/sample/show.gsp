<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title>${sampleInstance.name}</title>
		<r:require modules="charts"/>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${sampleInstance.projectLabel}">${Project.findById(sampleInstance.projectId).name}</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="page-header row-fluid">
					<div class="pull-left">
						<h1 id="${sampleInstance.name}"><small>SAMPLE</small> <g:fieldValue bean="${sampleInstance}" field="name"/><br>
						<small><g:fieldValue bean="${sampleInstance}" field="description"/></small></h1>
					</div>

					<auth:ifAnyGranted access="[(sampleInstance?.projectLabel):['collaborator', 'owner']]">
					<div class="pull-right">
						<div class="modal hide fade" id="create">
				            <div class="modal-header">
				              <a data-dismiss="modal" class="close">×</a>
				              <h3>Add Alignment</h3>
				            </div>
							<g:form class="form-horizontal" controller="alignment" action="save" style="margin:0">
								<fieldset>
									<g:render template="/alignment/create" model="[alignmentInstance: new Alignment(['sample':sampleInstance.name, 'project':sampleInstance.projectLabel])]"/>
								</fieldset>
							</g:form>
				        </div>
						<g:link action="edit" class="btn" id="${sampleInstance?.name}" params="[projectLabel:sampleInstance.projectLabel]">
							<i class="icon-pencil"></i>
							<g:message code="default.button.edit.label" default="Edit" />
						</g:link>
						<g:link controller="alignment" action="create" params="[project:sampleInstance.projectLabel, sample:sampleInstance.name]"  class="btn btn-primary" data-target="#create" data-toggle="modal">
							<i class="icon-plus icon-white"></i>
							Alignment
						</g:link>
					</div>
					</auth:ifAnyGranted>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<ul id="nav-tab-controller" class="nav nav-tabs">
					<li><a href="#details-tab" data-toggle="tab">Details</a></li>
			    	<li class="active"><a href="#genomes-tab" data-toggle="tab">Genomes</a></li>
				    <li><a href="#alignments-tab" data-toggle="tab">Alignments</a></li>
			    </ul>

				<div class="tab-content">

					<div class="tab-pane" id="details-tab">
						<div class="row-fluid">
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
						</div>
					</div>

					<div class="tab-pane active" id="genomes-tab">
						<div class="row-fluid">
							<div class="span2">
								<g:render template="/layouts/genomeFilter" model="['id':sampleInstance.name, 'projectLabel': projectInstance.label]"/>
							</div>
							<div class="span10">
								<g:each in="${alignments}" var="alignmentInstance" status="i">
									<div id="gra-vis-${i}"></div>
								</g:each>

								<div id="hierarchy-chooser"></div>

								<div id="stats-table" class="results">

									<div class="pull-right"><bootstrap:pageSummary total="${statistics.totalCount}" params="${params}" /></div>
									<table class="table table-striped table-condensed">
										<thead>
											<tr>
												<g:sortableColumn params="${params}" property="genome" title="${message(code: 'project.genome.label', default: 'Genome')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeHits" title="${message(code: 'project.genome.label', default: 'Hits')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneHits" title="${message(code: 'project.genome.label', default: 'Hits on Genes')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeCoverage" title="${message(code: 'project.genome.label', default: 'Coverage')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageAvg" title="${message(code: 'project.genome.label', default: 'Avg Gene Coverage')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageMax" title="${message(code: 'project.genome.label', default: 'Max Gene Coverage')}" />
												<th></th>
											</tr>
										</thead>
										<tbody>
										<g:each in="${statistics}" var="statisticsInstance">
											<tr>
												<td><g:link controller="genome" action="show" id="${statisticsInstance.accession}" params="${[projectLabel: statisticsInstance.projectLabel]}">${fieldValue(bean: statisticsInstance, field: "genome")}</g:link>
												<td>${fieldValue(bean: statisticsInstance, field: "genomeHits")}</td>
												<td>${fieldValue(bean: statisticsInstance, field: "geneHits")}</td>
												<td><g:formatNumber number="${statisticsInstance.genomeCoverage}" maxFractionDigits="2" type="percent"/></td>
												<td><g:formatNumber number="${statisticsInstance.geneCoverageAvg}" maxFractionDigits="2" type="percent"/></td>
												<td><g:formatNumber number="${statisticsInstance.geneCoverageMax}" maxFractionDigits="2" type="percent"/></td>
												<td><g:link controller="browse" action="show" id="${statisticsInstance.accession}" params="[projectLabel: statisticsInstance.projectLabel, sampleName:statisticsInstance.sample]">
													<i class="icon-share"></i> View Reads
												</g:link></td>
											</tr>
										</g:each>
										</tbody>
									</table>
									<div class="pagination">
										<bootstrap:paginate action="show" id="${sampleInstance?.name}" total="${statistics.totalCount}" params="${params}" />
									</div>
								</div>
							</div>
						</div>
					</div>
					
					<div class="tab-pane" id="alignments-tab">
						<div class="row-fluid">
							<div class="span2">
								<g:render template="/layouts/filter" model="['id':sampleInstance.name, 'projectLabel': projectInstance.label]"/>
							</div>
							<div class="span10">
								<div id="alignments-table" class="results">
									<div class="pull-right"><bootstrap:pageSummary total="${statistics.totalCount}" params="${params}" /></div>
									<table class="table table-striped table-condensed">
										<thead>
											<tr>
												<g:sortableColumn params="${params}" property="name" title="${message(code: 'alignment.name.label', default: 'Name')}" />
												<g:sortableColumn params="${params}" property="aligner" title="${message(code: 'alignment.aligner.label', default: 'Aligner')}" />
												<g:sortableColumn params="${params}" property="platform" title="${message(code: 'alignment.platform.label', default: 'Platform')}" />
												<g:sortableColumn params="${params}" property="type" title="${message(code: 'alignment.type.label', default: 'Type')}" />
											</tr>
										</thead>
										<tbody>
										<g:each in="${alignments}" var="alignmentInstance">
											<tr>
												<td><g:link controller="alignment" action="show" id="${alignmentInstance.name}" params="${[projectLabel: alignmentInstance.projectLabel, sampleName: alignmentInstance.sample]}">${fieldValue(bean: alignmentInstance, field: "name")}</g:link></td>
												<td>${fieldValue(bean: alignmentInstance, field: "aligner")}</td>
												<td>${fieldValue(bean: alignmentInstance, field: "platform")}</td>
												<td>${fieldValue(bean: alignmentInstance, field: "type")}</td>
											</tr>
										</g:each>
										</tbody>
									</table>
									<div class="pagination">
										<bootstrap:paginate action="show" id="${sampleInstance?.name}" total="${alignments.totalCount}" params="${params}" />
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div id="tooltip-container"></div>

		<g:javascript>
		function addChart(i, actionUrl) {
			function handler(_) {
				var id = _.id;
				var result = /^ti:(\d+)/.exec(id);
				if (result) {
					jQuery("#hierarchy-chooser").trigger('change', {id: parseInt(result[1])});
				}
			}
			buildHierarchy(actionUrl, function(data) {
  				var chart = hierarchyChart().width(300).height(300).handler(handler);
  				d3.select("#gra-vis-" + i.toString())
    				.datum(data)
    				.call(chart);
			});
		}
		</g:javascript>

		<g:each in="${alignments}" var="alignmentInstance" status="i">
		<g:javascript>
		addChart(${i}, "${g.createLink(
			controller: 'alignment', 
			action: 'taxonomy', 
			id: alignmentInstance.name, 
			params: [projectLabel: alignmentInstance.projectLabel, sampleName: alignmentInstance.sample]
		)}");
		</g:javascript>
		</g:each>
		<g:javascript>
		jQuery("#hierarchy-chooser").hierarchyChooser({baseUrl: "${resource(dir: '/taxon/api')}", taxonRootId: 1});
		jQuery("#hierarchy-chooser").bind('change', function(evt, value) { 
			var form = jQuery("#genomes-tab form.form-filters");
		    form.find("input[name=taxonRootId]").val(value.id);
		    form.trigger("submit");
		});
		</g:javascript>
	</body>
</html>
