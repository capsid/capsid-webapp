
<%@ page import="ca.on.oicr.capsid.Genome" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			
			<div class="span3">
				<div class="well">
					<ul class="nav nav-list">
						<li class="nav-header">${entityName}</li>
						<li>
							<g:link class="list" action="list">
								<i class="icon-list"></i>
								<g:message code="default.list.label" args="[entityName]" />
							</g:link>
						</li>
						<li>
							<g:link class="create" action="create">
								<i class="icon-plus"></i>
								<g:message code="default.create.label" args="[entityName]" />
							</g:link>
						</li>
					</ul>
				</div>
			</div>
			
			<div class="span9">
				<ul class="breadcrumb">
					<li class="active"><g:fieldValue bean="${genomeInstance}" field="name"/> <span class="divider">/</span></li>
				</ul>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.show.label" args="[entityName]" /></h1>
					</div>
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${genomeInstance?.name}" />
						<div>
							<g:link class="btn" action="edit" id="${genomeInstance?.id}">
								<i class="icon-pencil"></i>
								<g:message code="default.button.edit.label" default="Edit" />
							</g:link>
							<button class="btn btn-danger" type="submit" name="_action_delete">
								<i class="icon-trash icon-white"></i>
								<g:message code="default.button.delete.label" default="Delete" />
							</button>
						</div>
					</g:form>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<dl>
				
					<g:if test="${genomeInstance?.accession}">
						<dt><g:message code="genome.accession.label" default="Accession" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="accession"/></dd>
						
					</g:if>
				
					<g:if test="${genomeInstance?.gi}">
						<dt><g:message code="genome.gi.label" default="Gi" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="gi"/></dd>
						
					</g:if>
				
					<g:if test="${genomeInstance?.length}">
						<dt><g:message code="genome.length.label" default="Length" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="length"/></dd>
						
					</g:if>
				
					<g:if test="${genomeInstance?.name}">
						<dt><g:message code="genome.name.label" default="Name" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="name"/></dd>
						
					</g:if>
				
					<g:if test="${genomeInstance?.organism}">
						<dt><g:message code="genome.organism.label" default="Organism" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="organism"/></dd>
						
					</g:if>
				
					<g:if test="${genomeInstance?.sampleCount}">
						<dt><g:message code="genome.sampleCount.label" default="Sample Count" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="sampleCount"/></dd>
						
					</g:if>
				
					<g:if test="${genomeInstance?.strand}">
						<dt><g:message code="genome.strand.label" default="Strand" /></dt>
						
							<dd><g:fieldValue bean="${genomeInstance}" field="strand"/></dd>
						
					</g:if>
				
				</dl>
			</div>

		</div>
	</body>
</html>
