
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
		<title>${alignmentInstance.name}</title>
		<r:require modules="charts"/>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${alignmentInstance.projectLabel}">${projectInstance.name}</g:link> 
						<span class="divider">/</span>
					</li>
					<li>
						<g:link controller="sample" action="show" id="${alignmentInstance.sample}" params="${[projectLabel: alignmentInstance.projectLabel]}">${sampleInstance.name}</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="page-header row-fluid">
					<div class="pull-left">
						<h1><small>ALIGNMENT</small> ${alignmentInstance.name}</h1>
					</div>
					<auth:ifAnyGranted access="[(alignmentInstance?.project):['collaborator', 'owner']]">
					<div class="pull-right">
						<g:link class="btn" action="edit" id="${alignmentInstance?.name}">
							<i class="icon-pencil"></i>
							<g:message code="default.button.edit.label" default="Edit" />
						</g:link>
					</div>
					</auth:ifAnyGranted>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<ul class="nav nav-tabs">
			    	<li class="active"><a href="#gra-tab" data-toggle="tab">Genome Relative Abundance</a></li>
				    <li><a href="#genomes-tab" data-toggle="tab">Genomes</a></li>
			    </ul>

				<div class="tab-content">
					<div class="tab-pane active" id="gra-tab">
						<div class="row-fluid">
							<h2>Genome Relative Abundance</h2>
							<div class="span4">
								<g:zoomableSunburst display="${alignmentInstance}"/>
							</div>
							<div class="span6">
								<dl class="dl-horizontal">
									<g:if test="${alignmentInstance?.aligner}">
									<dt><g:message code="sample.aligner.label" default="Aligner" /></dt>
									<dd><g:fieldValue bean="${alignmentInstance}" field="aligner"/></dd>
									</g:if>

									<g:if test="${alignmentInstance?.platform}">
									<dt><g:message code="sample.platform.label" default="Platform" /></dt>						
									<dd>${alignmentInstance.platform}</dd>
									</g:if>

									<g:if test="${alignmentInstance?.type}">
									<dt><g:message code="sample.type.label" default="Type" /></dt>
									<dd><g:fieldValue bean="${alignmentInstance}" field="type"/></dd>
									</g:if>

									<g:if test="${alignmentInstance?.infile}">
									<dt><g:message code="sample.infile.label" default="Input" /></dt>
									<dd><g:fieldValue bean="${alignmentInstance}" field="infile"/></dd>
									</g:if>

									<g:if test="${alignmentInstance?.outfile}">
									<dt><g:message code="sample.outfile.label" default="Output" /></dt>
									<dd><g:fieldValue bean="${alignmentInstance}" field="outfile"/></dd>
									</g:if>
								</dl>
							</div>
						</div>
					</div>

					<div class="tab-pane" id="genomes-tab">
						<div class="row-fluid">
							<h2 class="pull-left">Genomes</h2>
							<div id="hierarchy-chooser"></div>
						</div>
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
		</div>

		<div id="tooltip-container"></div>

		<g:javascript>
		var url = "${resource(dir: '/taxon/api')}";
		var selfUrl = "${forwardURI}";
		jQuery("#hierarchy-chooser").hierarchyChooser({baseUrl: url, taxonRootId: 1});
		jQuery("#hierarchy-chooser").bind('change', function(evt, value) { 
			jQuery("#stats-table").load(selfUrl + "?taxonRootId=" + encodeURIComponent(value.id) + " #stats-table");
			console.log (evt, value); 
		});
		</g:javascript>
	</body>
</html>
