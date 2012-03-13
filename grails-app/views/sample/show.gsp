<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="span3">
				<div class="well well-small">
					<ul class="nav nav-list">
						<li class="nav-header">Summary</li>
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
				<div class="well well-small">
					<ul class="nav nav-list">
						<li>
							<g:link controller="alignment" action="create">
								<i class="icon-plus"></i>
								Add Alignment
							</g:link>
						</li>
						<li class="nav-header">Alignments</li>
						<input class="search-query span2" placeholder="Filter Alignments" type="text" id="alignment_filter">
						<g:each in="${sampleInstance['alignments']}" var="alignmentInstance">
						<li class="popover_item" rel="popover" data-placement="right" data-content="<strong>Aligner: </strong>${alignmentInstance.aligner}<br><strong>Platform: </strong>${alignmentInstance.platform}<br><strong>Type: </strong>${alignmentInstance.type}" data-title="${alignmentInstance.name}">
							<g:link controller="alignment" action="show" id="${alignmentInstance.name}">
								<i class="icon-folder-open"></i>
								${alignmentInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
			</div>
			
			<div class="span9">
				<ul class="breadcrumb">
					<li>
						<g:link controller="project" action="show" id="${sampleInstance.project}">${Project.findByLabel(sampleInstance.project).name}</g:link> 
						<span class="divider">/</span>
					</li>
				</ul>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:fieldValue bean="${sampleInstance}" field="name"/><br>
						<small><g:fieldValue bean="${sampleInstance}" field="description"/></small></h1>
					</div>
					<auth:ifAnyGranted access="[(sampleInstance?.name):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${sampleInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${sampleInstance?.name}">
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
			</div>
		</div>
	</body>
</html>
