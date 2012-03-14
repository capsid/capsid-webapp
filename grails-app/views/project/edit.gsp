<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title><g:message code="default.edit.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<section>
				<div class="page-header">
					<h1>Edit ${projectInstance.name} <small>Edit Project Attributes</small></h1>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<g:hasErrors bean="${projectInstance}">
				<bootstrap:alert class="alert-error">
				<ul>
					<g:eachError bean="${projectInstance}" var="error">
					<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
					</g:eachError>
				</ul>
				</bootstrap:alert>
				</g:hasErrors>

				<fieldset>
					<g:form class="form-horizontal" action="update" id="${projectInstance?.label}" >
						<g:hiddenField name="version" value="${projectInstance?.version}" />
						<g:hiddenField name="label" id="label" value="${projectInstance?.label}" />
						<fieldset>
							<f:all bean="projectInstance"/>
							<div class="control-group ">
								<label for="label" class="control-label">Security</label>
								<div class="controls">
									<g:set var="is_private" value="${!('ROLE_CAPSID' in projectInstance.roles)}" />
									<g:hiddenField name="is_private" id="is_private" value="${is_private}" />
									
									<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_private">
										<button rel="tooltip" title="Your project will only be visable to users that are given access" type="button" value="true" class="btn"><i class="icon-eye-close"></i> Private</button>
										<button rel="tooltip" title="Project will be visable to all CaPSID users" type="button" value="false" class="btn"><i class="icon-eye-open"></i> Public</button>
									</div>
								</div>
							</div>
							<div class="form-actions" style="border-radius:0; border:none;">
								<button type="submit" class="btn btn-success">
									<i class="icon-ok icon-white"></i>
									<g:message code="default.button.update.label" default="Update" />
								</button>
								<g:link action="show" id="${projectInstance.label}" class="btn">Cancel</g:link>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
			</section>
			<section>
				<div class="page-header">
					<h1>Edit Permissions <small>Change User Access Levels</small></h1>
				</div>
			</section>
			<section>
				<div class="page-header">
					<h1>Delete Project</h1>
				</div>
				<fieldset>
					<g:form class="form-horizontal" action="update" id="${projectInstance?.label}" >
						<g:hiddenField name="version" value="${projectInstance?.version}" />
						<fieldset>
							<div class="form-actions">
								<button type="submit" class="btn btn-danger" name="_action_delete" formnovalidate>
									<i class="icon-trash icon-white"></i>
									<g:message code="default.button.delete.label" default="Delete" />
								</button>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
			</section>
		</div>
	</body>
</html>
