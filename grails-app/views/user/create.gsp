<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="ajax">
		<g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
		<title><g:message code="default.create.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div>
				<div class="page-header">
					<h1><g:message code="default.create.label" args="[entityName]" /></h1>
				</div>
				<div id="ajax">
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<g:hasErrors bean="${userInstance}">
				<bootstrap:alert class="alert-error">
				<ul>
					<g:eachError bean="${userInstance}" var="error">
					<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
					</g:eachError>
				</ul>
				</bootstrap:alert>
				</g:hasErrors>

				<fieldset>
					<g:form class="form-horizontal" action="save" >
						<fieldset>
							<f:field bean="${userInstance}" property="username"/>
							<f:all bean="${userInstance}"/>
							<div class="control-group ">
								<label for="label" class="control-label">Security</label>
								<div class="controls">
									<g:hiddenField name="is_admin" id="is_admin" value="${false}" />
									
									<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_admin">
										<button type="button" value="false" class="btn active"><i class="icon-user"></i> User</button>
										<button rel="tooltip" title="Make this user a CaPSID administrator" type="button" value="true" class="btn"><i class="icon-lock"></i> Admin</button>
									</div>
								</div>
							</div>
							<div class="control-group ">
								<label for="label" class="control-label">LDAP</label>
								<div class="controls">
									<g:hiddenField name="is_ldap" id="is_ldap" value="${false}" />
									
									<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_ldap">
										<button rel="tooltip" title="CaPSID will use the Database for authorization" type="button" value="false" class="btn active">No</button>
										<button rel="tooltip" title="CaPSID will use LDAP for authorization" type="button" value="true" class="btn">LDAP</button>
									</div>
								</div>
							</div>
							<div class="form-actions modal-footer">
								<g:link action="list" class="btn" data-dismiss="modal">Close</g:link>
								<button type="submit" class="btn btn-success">
									<i class="icon-ok icon-white"></i>
									<g:message code="default.button.create.label" default="Create" />
								</button>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
				</div>
			</div>

		</div>
	</body>
</html>
