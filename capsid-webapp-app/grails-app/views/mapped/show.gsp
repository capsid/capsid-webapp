
<%@ page import="ca.on.oicr.capsid.Mapped" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<%@ page import="ca.on.oicr.capsid.Feature" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'mapped.label', default: 'Mapped')}" />
		<g:set var="genomeInstance" value="${Genome.findByGi(mappedInstance.genome)}" />
		<title>${mappedInstance.readId}</title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="span3">
				<div class="well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Details</li>
						<table class="table">
							<tbody>
								<g:if test="${mappedInstance?.PG}">
								<tr><td><g:message code="mapped.PG.label" default="PG" /></td>
								
									<td><g:fieldValue bean="${mappedInstance}" field="PG"/></td></tr>	
								</g:if>
						
								<tr><td><g:message code="mapped.platform.label" default="Platform" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="platform"/></td></tr>
								
								<tr><td><g:message code="mapped.sequencingType.label" default="Sequencing Type" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="sequencingType"/></td></tr>
								
								<tr><td><g:message code="mapped.readLength.label" default="Read Length" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="readLength"/></td></tr>

								<tr><td><g:message code="mapped.alignLength.label" default="Align Length" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="alignLength"/></td></tr>
								
								<tr><td><g:message code="mapped.alignScore.label" default="Align Score" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="alignScore"/></td></tr>
								
								<tr><td><g:message code="mapped.mapq.label" default="Mapq" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="mapq"/></td></tr>

								<tr><td><g:message code="mapped.minQual.label" default="Min Qual" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="minQual"/></td></tr>
								
								<tr><td><g:message code="mapped.avgQual.label" default="Avg Qual" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="avgQual"/></td></tr>
							
								<tr><td><g:message code="mapped.miscalls.label" default="Miscalls" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="miscalls"/></td></tr>
								
								<tr><td><g:message code="mapped.mismatch.label" default="Mismatch" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="mismatch"/></td></tr>		

								<tr><td><g:message code="mapped.refStrand.label" default="Strand" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="refStrand"/></td></tr>		

								<tr><td><g:message code="mapped.refStart.label" default="Start" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="refStart"/></td></tr>		

								<tr><td><g:message code="mapped.refEnd.label" default="End" /></td>
									<td><g:fieldValue bean="${mappedInstance}" field="refEnd"/></td></tr>		
							</tbody>
							</table>		
					</ul>
					<g:if test="${mappedInstance?.mapsGene}">
					<hr>
					<ul class="nav nav-list">
						<li class="nav-header">Mapped to Genes</li>
					</ul>
					<ul id="items" class="nav nav-list">
						<g:each in="${mappedInstance.mapsGene}" var="uid">

							<g:set var="featureInstance" value="${Feature.findByUidAndType(uid, 'gene')}" />
							<g:if test="${featureInstance}">
								<li><g:link controller="feature" action="show" id="${featureInstance.uid}">${featureInstance.name}</g:link></li>
							</g:if>
							<g:else>
								<g:set var="featureInstance" value="${Feature.findByGeneIdAndType(uid.toInteger(), 'gene')}" />
								<g:if test="${featureInstance}">
									<li><g:link controller="feature" action="show" id="${featureInstance.uid}">${featureInstance.name}</g:link></li>
								</g:if>
								<g:else>
								<a href="http://www.ncbi.nlm.nih.gov/gene/${uid}" target="_blank">${uid}</a>
							</g:else>
							</g:else>
						</g:each>
					</ul>
					</g:if>
				</div>
			</div>
			<div class="content span9">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${mappedInstance.projectLabel}">
						${Project.findById(mappedInstance.projectId).name}
						</g:link> 
						<span class="divider">/</span>
					</li>
					<li>
						<g:link controller="sample" action="show" id="${mappedInstance.sample}">
						${mappedInstance.sample}
						</g:link> 
						<span class="divider">/</span>
					</li>
					<li>
						<g:link controller="alignment" action="show" id="${mappedInstance.alignment}">
						${mappedInstance.alignment}
						</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="row-fluid page-header">
					<h1 class="pull-left"><small>READ</small> ${mappedInstance.readId}</h1>
					<div id="blast" class="btn-group pull-right">
			        	<button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
			          		<i class="icon-share-alt icon-white"></i>
			          		BLAST <span class="caret"></span>
			        	</button>
			        	<ul class="dropdown-menu" style="left:auto; right:0;">
			            	<li><a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&LINK_LOC=blasthome&QUERY=${mappedInstance.sequence}" target="_blank">BLAST Read Sequence</a></li>
			            	<li data-tab="#contig"><span class="disabled">Generating Contig...</span></li>
			        	</ul>
			        </div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<h2><small>MAPS TO GENOME</small> <g:link controller="genome" action="show" id="${genomeInstance.accession}">${genomeInstance.name}</g:link></h2>
			    <ul class="nav nav-tabs">
			    	<li class="active"><a href="#fasta" data-toggle="tab">Fasta</a></li>
			    	<li class="ajax"><a class="disabled" href="#alignment" data-toggle="tab" data-loaded="Alignment" data-url="${createLink([action:'alignment',id:mappedInstance.id])}">Generating Alignment...</a></li>
				    <li class="ajax"><a class="disabled" href="#contig" data-toggle="tab" data-url="${createLink([action:'contig',id:mappedInstance.id])}" data-loaded="Contig Sequence">Generating Contig...</a></li>
					<g:if test="${otherHits}">
					<li><a href="#other" data-toggle="tab">Other Hits</a></li>
					</g:if>
			    </ul>
			    <div class="tab-content">
					<div class="tab-pane active" id="fasta">
						<g:render template='/mapped/fasta' model="[fasta:fasta, mappedInstance:mappedInstance]"/>
					</div>
					<div class="tab-pane" id="alignment">
					    <div class="progress progress-info progress-striped active"> 
					    	<div class="bar" style="width: 100%;"></div>
						</div>
					</div>
					<div class="tab-pane" id="contig">
					    <div class="progress progress-info progress-striped active"> 
					    	<div class="bar" style="width: 100%;"></div>
					    </div>
					</div>
					<g:if test="${otherHits}">
					<div class="tab-pane" id="other">
						<div id="other-table" class="results">
							<h2>Hits on Other Genomes</h2>
							<table class="table table-striped table-condensed capsid-results">
								<thead>
									<tr>
										<th>Genome</th>
										<th>Start</th>
										<th>End</th>
										<th></th>
									</tr>
								</thead>
								<tbody>
									<g:each in="${otherHits}" var="hit">
										<g:set var="genomeInstance" value="${Genome.findByGi(hit.gi)}" />
										<tr>
											<td><g:link controller="genome" action="show" id="${fieldValue(bean: genomeInstance, field: 'accession')}">${fieldValue(bean: genomeInstance, field: "name")}</g:link></td>
											<td>${hit.refStart}</td>
											<td>${hit.refEnd}</td>
												<td><g:link action="show" id="${hit.id}" class="btn btn-small">View Hit</g:link></td>
										</tr>
									</g:each>
								</tbody>
							</table>
							<div class="pagination">
								<bootstrap:paginate id="${mappedInstance?.id}" total="${otherHits.size()}" params="${params}" />
							</div>
						</div>
					</div>
					</g:if>
				</div>
			</div>
		</div>
	</body>
</html>
