
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
		<title>${genomeInstance.accession} - ${genomeInstance.name}</title>
	</head>
	<body>
		<div class="row-fluid has_sidebar use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Details</li>
						<table class="table">
							<tbody>
							<g:if test="${genomeInstance?.accession}">
							<tr>
								<td><g:message code="sample.accession.label" default="Accession" /></td>
								<td><g:fieldValue bean="${genomeInstance}" field="accession"/></td>
							</tr>
							</g:if>
						
							<g:if test="${genomeInstance?.gi}">
							<tr>
								<td><g:message code="sample.gi.label" default="GI" /></td>						
								<td>${genomeInstance.gi}</td>
							</tr>
							</g:if>
						
							<g:if test="${genomeInstance?.organism}">
							<tr>
								<td><g:message code="sample.organism.label" default="Organism" /></td>
								<td><g:fieldValue bean="${genomeInstance}" field="organism"/></td>
							</tr>
							</g:if>

							<g:if test="${genomeInstance?.length}">
							<tr>
								<td><g:message code="sample.length.label" default="Length" /></td>
								<td><g:fieldValue bean="${genomeInstance}" field="length"/></td>
							</tr>
							</g:if>
							</tbody>
						</table>
						<hr>
						<li class="nav-header">Links</li>
			 			<li><a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank">NCBI Nucleotide DB</a></li>
			        	<g:if test="${genomeInstance.organism == 'Homo sapiens'}">
			            <li><a href="http://www.ncbi.nlm.nih.gov/mapview/maps.cgi?taxid=9606&chr=${genomeInstance.name.minus('chr')}" target="_blank">NCBI Map Viewer</a></li>
			          	</g:if>
			          	<li><a href="http://www.ncbi.nlm.nih.gov/sites/gquery?term=${genomeInstance.accession}" target="_blank">Search NCBI</a></li>
			          	<li><g:link controller="jbrowse" action="show" id="${genomeInstance.accession}">View in JBrowse</g:link></li>
					</ul>
					<hr>

					<ul class="nav nav-list">
						<li class="nav-header">Genes</li>
						<input class="search-query span2" placeholder="Filter Genes" type="text" id="filter">
					</ul>
					<ul id="items" class="nav nav-list">
						<g:each in="${genomeInstance['genes']}" var="geneInstance">
						<li rel="popover" data-placement="right" data-content="<strong>Gene ID: </strong>${geneInstance.geneId}<br>" data-title="${geneInstance.name}">
							<g:link controller="gene" action="show" id="${geneInstance.name}">
								<i class="icon-folder-open"></i>
								${geneInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			
			<div class="content">
				<div class="page-header">
					<div>
						<h1><g:fieldValue bean="${genomeInstance}" field="name"/><br><small>${genomeInstance.taxonomy.join(', ')}</small></h1>
					</div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<h2>Sample Statistics</h2>
				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<table class="table table-striped table-condensed">
						<thead>
							<tr>
								<g:sortableColumn params="${params}" property="sample" title="${message(code: 'statistics.sample.label', default: 'Sample')}" />
								<g:sortableColumn params="${params}" property="project" title="${message(code: 'statistics.project.label', default: 'Project')}" />
								<g:sortableColumn params="${params}" property="genomeHits" title="${message(code: 'statistics.genomeHits.label', default: 'Hits')}" />
								<g:sortableColumn params="${params}" property="geneHits" title="${message(code: 'statistics.geneHits.label', default: 'Hits on Genes')}" />
								<g:sortableColumn params="${params}" property="genomeCoverage" title="${message(code: 'statistics.genomeCoverage.label', default: 'Coverage')}" />
								<g:sortableColumn params="${params}" property="geneCoverageAvg" title="${message(code: 'statistics.geneCoverageAvg.label', default: 'Avg Gene Coverage')}" />
								<g:sortableColumn params="${params}" property="geneCoverageMax" title="${message(code: 'statistics.geneCoverageMax.label', default: 'Max Gene Coverage')}" />
								<th></th>
							</tr>
						</thead>
						<tbody>
						<g:each in="${statisticsInstanceList}" var="statisticsInstance">
							<tr>
								<td><g:link controller="sample" action="show" id="${statisticsInstance.sample}">${fieldValue(bean: statisticsInstance, field: "sample")}</g:link>
								<td><g:link controller="project" action="show" id="${statisticsInstance.label}">${fieldValue(bean: statisticsInstance, field: "project")}</g:link>
								<td>${fieldValue(bean: statisticsInstance, field: "genomeHits")}</td>
	
								<td>${fieldValue(bean: statisticsInstance, field: "geneHits")}</td>
	
								<td><g:formatNumber number="${statisticsInstance.genomeCoverage}" maxFractionDigits="2" type="percent"/></td>
	
								<td><g:formatNumber number="${statisticsInstance.geneCoverageAvg}" maxFractionDigits="2" type="percent"/></td>
	
								<td><g:formatNumber number="${statisticsInstance.geneCoverageMax}" maxFractionDigits="2" type="percent"/></td>
								<td><g:link controller="jbrowse" action="show" id="${genomeInstance.accession}" params="[track:statisticsInstance.sample]">
									<i class="icon-share"></i> View Reads
								</g:link></td>
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate id="${sampleInstance?.name}" total="${statisticsInstanceTotal}" params="${params}" />
					</div>
				</div>
				<h2>Project Statistics</h2>
				<table class="table table-striped table-condensed">
					<thead>
						<tr>
							<th>Project</th>
							<th>Hits</th>
							<th>Hits on Genes</th>
							<th>Coverage</th>
							<th>Average Gene Coverage</th>
							<th>Maximum Gene Coverage</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
					<g:each in="${pStatisticsInstanceList}" var="statisticsInstance">
						<tr>
							<td><g:link controller="project" action="show" id="${statisticsInstance.label}">${fieldValue(bean: statisticsInstance, field: "project")}</g:link>
							<td>${fieldValue(bean: statisticsInstance, field: "genomeHits")}</td>

							<td>${fieldValue(bean: statisticsInstance, field: "geneHits")}</td>

							<td><g:formatNumber number="${statisticsInstance.genomeCoverage}" maxFractionDigits="2" type="percent"/></td>

							<td><g:formatNumber number="${statisticsInstance.geneCoverageAvg}" maxFractionDigits="2" type="percent"/></td>

							<td><g:formatNumber number="${statisticsInstance.geneCoverageMax}" maxFractionDigits="2" type="percent"/></td>
							<td><g:link class="external-filter" action="show" id="${genomeInstance.accession}" params="[project:statisticsInstance.label]">
								<i class="icon-search"></i>
								Filter Samples
							</g:link></td>
						</tr>
					</g:each>
					</tbody>
				</table>
			</div>
		</div>
	</body>
</html>
