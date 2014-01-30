<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
		
		<title>${genomeInstance.accession.replaceAll('_',' ')} - ${genomeInstance.name}</title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="page-header row-fluid">
					<div>
						<h1 id="${genomeInstance.accession}"><small>GENOME</small> <g:fieldValue bean="${genomeInstance}" field="name"/><br><small>${genomeInstance.taxonomy.join(', ')}</small></h1>
					</div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<div class="row-fluid">
					<div class="span6">
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
						</ul>
					</div>
					<div class="span6">
						<ul class="nav nav-list">
							<li class="nav-header">Links</li>
				 			<li><a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank">NCBI Nucleotide DB</a></li>
				        	<g:if test="${genomeInstance.organism == 'Homo sapiens'}">
				            <li><a href="http://www.ncbi.nlm.nih.gov/mapview/maps.cgi?taxid=9606&amp;chr=${genomeInstance.name.minus('chr')}" target="_blank">NCBI Map Viewer</a></li>
				          	</g:if>
				          	<li><a href="http://www.ncbi.nlm.nih.gov/sites/gquery?term=${genomeInstance.accession}" target="_blank">Search NCBI</a></li>
				          	<li><g:link controller="browse" action="show" id="${genomeInstance.accession}" params="${[projectLabel: projectInstance?.label]}">View in genome browser</g:link></li>
				          </ul>
					</div>
				</div>

				<ul class="nav nav-tabs">
			    	<li class="active"><a href="#sample-stats" data-toggle="tab">Sample Statistics</a></li>
			    	<li><a href="#project-stats" data-toggle="tab">Project Statistics</a></li>
				    <li><a href="#features" data-toggle="tab">Features</a></li>
			    </ul>

			    <div class="tab-content">
					<div class="tab-pane active" id="sample-stats">
						<div class="row-fluid">
							<div class="span2">
								<g:render template="/layouts/filter" model="['id':genomeInstance.accession, 'projectLabel': projectInstance?.label]"/>
							</div>
							<div class="span10">
								<div id="sample-stats-table" class="results">
									<table class="table table-striped table-condensed">
										<thead>
											<tr>
												<g:sortableColumn params="${params}" property="sample" title="${message(code: 'statistics.sample.label', default: 'Sample')}" />
												<g:sortableColumn params="${params}" property="project" title="${message(code: 'statistics.project.label', default: 'Project')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeHits" title="${message(code: 'statistics.genomeHits.label', default: 'Hits')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneHits" title="${message(code: 'statistics.geneHits.label', default: 'Hits on Genes')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeCoverage" title="${message(code: 'statistics.genomeCoverage.label', default: 'Coverage')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageAvg" title="${message(code: 'statistics.geneCoverageAvg.label', default: 'Avg Gene Coverage')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageMax" title="${message(code: 'statistics.geneCoverageMax.label', default: 'Max Gene Coverage')}" />
												<th></th>
											</tr>
										</thead>
										<tbody>
										<g:each in="${sStatistics}" var="statisticsInstance">
											<tr>
												<td><g:link controller="sample" action="show" id="${statisticsInstance.sample}" params="${[projectLabel: statisticsInstance.projectLabel]}">${fieldValue(bean: statisticsInstance, field: "sample")}</g:link>
												<td><g:link controller="project" action="show" id="${statisticsInstance.projectLabel}">${fieldValue(bean: statisticsInstance, field: "project")}</g:link>
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
										<bootstrap:paginate action="show" id="${genomeInstance?.accession}" total="${sStatistics.totalCount}" params="${params}" />
									</div>
								</div>
							</div>
						</div>
					</div>

					<div class="tab-pane" id="project-stats">
						<div class="row-fluid">
							<div class="span2">
								<g:render template="/layouts/filter" model="['id':genomeInstance.accession, 'projectLabel': projectInstance?.label]"/>
							</div>
							<div class="span10">
								<div id="project-stats-table" class="results">
									<table class="table table-striped table-condensed">
										<thead>
											<tr>
												<g:sortableColumn params="${params}" property="project" title="${message(code: 'statistics.project.label', default: 'Project')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeHits" title="${message(code: 'statistics.genomeHits.label', default: 'Hits')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneHits" title="${message(code: 'statistics.geneHits.label', default: 'Hits on Genes')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="genomeCoverage" title="${message(code: 'statistics.genomeCoverage.label', default: 'Coverage')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageAvg" title="${message(code: 'statistics.geneCoverageAvg.label', default: 'Avg Gene Coverage')}" />
												<g:sortableColumn params="${params}" defaultOrder="desc" property="geneCoverageMax" title="${message(code: 'statistics.geneCoverageMax.label', default: 'Max Gene Coverage')}" />
											</tr>
										</thead>
										<tbody>
										<g:each in="${pStatistics}" var="statisticsInstance">
											<tr>
												<td><g:link controller="project" action="show" id="${statisticsInstance.projectLabel}">${fieldValue(bean: statisticsInstance, field: "project")}</g:link>
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
										<bootstrap:paginate action="show" id="${genomeInstance?.accession}" total="${pStatistics.totalCount}" params="${params}" />
									</div>
								</div>
							</div>
						</div>
					</div>

					<div class="tab-pane" id="features">
						<div class="row-fluid">
							<div class="span2">
								<g:render template="/layouts/filter" model="['id':genomeInstance.accession, 'projectLabel': projectInstance?.label]"/>
							</div>
							<div class="span10">
								<div id="features-table" class="results">
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
										<g:each in="${features}" var="featureInstance">
											<tr>
												<td><g:link controller="feature" action="show" id="${featureInstance.uid}" params="${[projectLabel: projectInstance?.label]}">${fieldValue(bean: featureInstance, field: "name")}</g:link></td>
												<td>${genomeInstance.name}</td>
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
										<bootstrap:paginate total="${features.totalCount}" params="${params}"/>
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
