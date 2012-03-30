
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
		<div class="row-fluid">
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
				<div class="page-header">
					<div>
						<h1>${alignmentInstance.name}</h1>
					</div>
					<auth:ifAnyGranted access="[(alignmentInstance?.project):['collaborator', 'owner']]">
					<g:form style="margin:10px 0 0">
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
			</div>
		</div>
	</body>
</html>
