<%@ page import="ca.on.oicr.capsid.Sample" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
		<title><g:message code="default.create.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="page-header">
					<h1><g:message code="default.create.label" args="[entityName]" /></h1>
				</div>
				
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<g:hasErrors bean="${sampleInstance}">
				<bootstrap:alert class="alert-error">
				<ul>
					<g:eachError bean="${sampleInstance}" var="error">
					<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
					</g:eachError>
				</ul>
				</bootstrap:alert>
				</g:hasErrors>

				<g:form class="form-horizontal" action="save" >
					<fieldset>
						<f:field bean="sampleInstance" property="name"/>
						<f:all bean="sampleInstance"/>
						<div class="form-actions">
							<button type="submit" class="btn btn-success">
								<i class="icon-ok icon-white"></i>
								<g:message code="default.button.create.label" default="Create" />
							</button>
							<g:link action="list" class="btn" data-dismiss="modal">Cancel</g:link>
						</div>
					</fieldset>
				</g:form>
			</div>
		</div>
	</body>
</html>
