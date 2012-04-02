
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
		<div class="row-fluid has_sidebar use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">
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
							</tbody>
							</table>		
					</ul>
					<hr>
					<g:if test="${mappedInstance?.mapsGene}">
					<ul class="nav nav-list">
						<li class="nav-header">Mapped to Genes</li>
					</ul>
					<ul id="items" class="nav nav-list">
						<g:each in="${mappedInstance.mapsGene}" var="geneId">
						<g:set var="geneInstance" value="${Feature.findByGeneId(geneId)}" />
						<!--
						<li rel="popover" data-placement="right" data-content="<strong>Gene ID: </strong>${geneInstance?.geneId}<br>" data-title="${geneInstance?.name}">
							<g:link controller="gene" action="show" id="${geneInstance?.name}">
								<i class="icon-folder-open"></i>
								${geneInstance?.name}
							</g:link>
						</li>
						-->
						<li><a target="_blank" href="http://www.ncbi.nlm.nih.gov/gene/${geneId}">${geneInstance?.name}</a></li>
						</g:each>
					</ul>
					<hr>
					</g:if>
					<g:if test="${otherGenomes}">
					<ul class="nav nav-list">
						<li class="nav-header">Hits on Other Genomes</li>
					</ul>
					<ul id="items" class="nav nav-list">
						<g:each in="${otherGenomes}" var="hit">
						<g:set var="genomeInstance" value="${Genome.findByGi(hit.gi)}" />
						<li rel="popover" data-placement="right" data-content="<strong>Accession: </strong>${genomeInstance?.accession}<br><strong>Start: </strong>${hit?.refStart}<br><strong>End: </strong>${hit?.refEnd}<br>" data-title="${genomeInstance?.name}">
							<g:link controller="mapped" action="show" id="${hit?.id}">
								<i class="icon-folder-open"></i>
								${genomeInstance?.name}
							</g:link>
						</li>
						</g:each>
					</ul>
					</g:if>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			<div class="content">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${mappedInstance.project}">
						${Project.findByLabel(mappedInstance.project).name}
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
					<h1>${mappedInstance.readId}</h1>
					<div id="blast" class="btn-group">
			        	<button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
			          		<i class="icon-share-alt icon-white"></i>
			          		BLAST <span class="caret"></span>
			        	</button>
			        	<ul class="dropdown-menu">
			            	<li><a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&LINK_LOC=blasthome&QUERY=${mappedInstance.sequence}" target="_blank">BLAST Sequence</a></li>
			            	<li data-tab="#contig"><span class="disabled">Generating Contig...</span></li>
			        	</ul>
			        </div>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<h2><g:link controller="genome" action="show" id="${genomeInstance.accession}">${genomeInstance.name}</g:link> 
					<small>[<g:fieldValue bean="${mappedInstance}" field="refStrand"/> : <g:fieldValue bean="${mappedInstance}" field="refStart"/> - <g:fieldValue bean="${mappedInstance}" field="refEnd"/>]</small>
				</h2>
			    <ul class="nav nav-tabs">
			    	<li class="active"><a href="#fasta" data-toggle="tab">Fasta Sequence</a></li>
				    <li class="ajax"><a class="disabled" href="#alignment" data-toggle="tab" data-loaded="Alignment" data-url="${createLink([action:'alignment',id:mappedInstance.id])}">Generating Alignment...</a></li>
				    <li class="ajax"><a class="disabled" href="#contig" data-toggle="tab" data-url="${createLink([action:'contig',id:mappedInstance.id])}" data-loaded="Contig Sequence">Generating Contig...</a></li>
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
				</div>
			</div>
		</div>
	</body>
</html>
