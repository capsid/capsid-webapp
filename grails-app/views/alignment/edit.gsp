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
								<button type="submit" class="btn btn-primary">
									<i class="icon-ok icon-white"></i>
									<g:message code="default.button.update.label" default="Update" />
								</button>
								<button type="submit" class="btn btn-danger" name="_action_delete" formnovalidate>
									<i class="icon-trash icon-white"></i>
									<g:message code="default.button.delete.label" default="Delete" />
								</button>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
			</section>
			<section>
				<div class="page-header">
					<h1>Delete Alignment</h1>
				</div>
				<fieldset>
					<g:form class="form-horizontal" action="update" id="${alignmentInstance?.name}" >
						<g:hiddenField name="version" value="${alignmentInstance?.version}" />
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
