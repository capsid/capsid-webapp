
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


				<div class="row">
					<div class="span4">
						<g:zoomableSunburst display="${alignmentInstance}"/>
					</div>
					<div class="span8">
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
		</div>
		<div id="tooltip-container"></div>
	</body>
</html>
