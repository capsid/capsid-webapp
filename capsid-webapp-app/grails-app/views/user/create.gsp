<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="none">
		<g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
		<title><g:message code="default.create.label" args="[entityName]" /></title>
	</head>
	<body>
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
						<label for="label" class="control-label">Access</label>
						<div class="controls">
							<g:hiddenField name="is_admin" id="is_admin" value="${params.is_admin?:false}" />			
							<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_admin">
								<button type="button" value="false" class="btn active"><i class="icon-user"></i> User</button>
								<button rel="tooltip" title="Make this user a CaPSID administrator" type="button" value="true" class="btn"><i class="icon-lock"></i> Admin</button>
							</div>
						</div>
					</div>
					<div class="control-group ">
						<label for="label" class="control-label">LDAP</label>
						<div class="controls">
							<g:hiddenField name="is_ldap" id="is_ldap" value="${params.is_ldap?:false}" />
							
							<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_ldap">
								<button rel="tooltip" title="CaPSID will use the Database for authorization" type="button" value="false" class="btn active">No</button>
								<button rel="tooltip" title="CaPSID will use LDAP for authorization" type="button" value="true" class="btn">LDAP</button>
							</div>
						</div>
					</div>
				</fieldset>
			</g:form>
		</fieldset>
	</body>
</html>
