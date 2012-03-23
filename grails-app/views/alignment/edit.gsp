<%@ page import="ca.on.oicr.capsid.Alignment" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
		<title><g:message code="default.edit.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
			<section>
				<div class="page-header">
					<h1>Edit ${alignmentInstance.name} <small>Edit Alignment Attributes</small></h1>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<g:hasErrors bean="${alignmentInstance}">
				<bootstrap:alert class="alert-error">
				<ul>
					<g:eachError bean="${alignmentInstance}" var="error">
					<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
					</g:eachError>
				</ul>
				</bootstrap:alert>
				</g:hasErrors>

				<fieldset>
					<g:form class="form-horizontal" action="update" id="${alignmentInstance?.name}" >
						<g:hiddenField name="version" value="${alignmentInstance?.version}" />
						<fieldset>
							<f:all bean="alignmentInstance"/>
							<div class="form-actions" style="border-radius:0; border:none;">
								<button type="submit" class="btn btn-success">
									<i class="icon-ok icon-white"></i>
									<g:message code="default.button.update.label" default="Update" />
								</button>
								<g:link action="show" id="${alignmentInstance?.name}" class="btn">Cancel</g:link>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
			</section>
			<auth:ifAnyGranted access="[(alignmentInstance?.project):['collaborator', 'owner']]">
			<section>
				<div class="page-header">
					<h1>Delete Alignment</h1>
				</div>
				<div class="row-fluid">
					<div class="span alert alert-danger">Deleting this Alignment <i>(${alignmentInstance?.name})</i> will also delete all mapped reads associated with it.</div>
				</div>
				<fieldset>
					<form class="form-horizontal">
						<fieldset>
							<div class="form-actions">
								<button type="button" class="btn btn-danger" data-target="#myModal" data-toggle="modal">
									<i class="icon-trash icon-white"></i>
									<g:message code="default.button.delete.label" default="Delete" />
								</button>
							</div>
						</fieldset>
					</form>
				</fieldset>
				<div class="modal hide" id="myModal" style="display: none;">
					<div class="modal-header">
		            <a data-dismiss="modal" class="close">×</a>
		            <h3>Delete Alignment</h3>
		            </div>
		            <div class="modal-body">
		            	<div class="alert alert-danger">Deleting this Alignment <i>(${alignmentInstance?.name})</i> will also delete all mapped reads associated with it.<br/><br/>Deleting a Alignment is permanent, please be certain before continuing.<br/></div>	
		            </div>
				    <div class="modal-footer">
						<g:form action="update" id="${alignmentInstance?.name}" >
							<g:hiddenField name="version" value="${alignmentInstance?.name}" />
							<button type="submit" class="btn btn-danger" name="_action_delete" formnovalidate>
								<i class="icon-trash icon-white"></i>
								<g:message code="default.button.delete.label" default="Delete" />
							</button>
							<a data-dismiss="modal" class="btn" href="#">Close</a>
						</g:form>
					</div>
				</div>
			</section>
			</auth:ifAnyGranted>
			</div>
		</div>
	</body>
</html>
