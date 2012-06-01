<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
		<auth:ifCurrentUser username="${userInstance.username}">
			<g:set var="isUser" value="true"/>
		</auth:ifCurrentUser>
		<auth:ifCapsidAdmin>
			<g:set var="isAdmin" value="true"/>
		</auth:ifCapsidAdmin>			
		<title>Editing ${userInstance.username}</title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
			<section>
				<div class="page-header">
					<h1>Edit ${userInstance.username}</h1>
				</div>
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

				<ul class="nav nav-tabs">
			    	<g:if test="${isUser}">
			    	<li class="${isUser?'active':''}"><a href="#attrib" data-toggle="tab">Attributes</a></li>
				    </g:if>
				    <g:if test="${isAdmin}">
				    <li class="${isUser?'':'active'}"><a href="#access" data-toggle="tab">Access</a></li>
			    	</g:if>
			    </ul>

				<div class="tab-content">
					<auth:ifCurrentUser username="${userInstance.username}">
					<div class="tab-pane ${isUser?'active':''}" id="attrib">
						<h1><small>Edit User Attributes</small></h1>
						<fieldset>
							<g:form class="form-horizontal" action="update" id="${userInstance?.username}" >
								<g:hiddenField name="version" value="${userInstance?.version}" />
								<fieldset>
									<f:all bean="userInstance"/>
									<div class="form-actions" style="border-radius:0; border:none;">
										<button type="submit" class="btn btn-success">
											<i class="icon-ok icon-white"></i>
											<g:message code="default.button.update.label" default="Update" />
										</button>
										<g:link action="show" id="${userInstance?.username}" class="btn">Cancel</g:link>
									</div>
								</fieldset>
							</g:form>
						</fieldset>
					</div>
					</auth:ifCurrentUser>
					<auth:ifCapsidAdmin>
					<div class="tab-pane ${isUser?'':'active'}" id="access">
						<h1><small>Edit User Access Status</small></h1>
						<fieldset>
							<g:form class="form-horizontal" action="update_status" id="${userInstance?.username}" >
								<g:hiddenField name="version" value="${userInstance?.version}" />
								<fieldset>
									<div class="control-group ">
										<label for="label" class="control-label">Enabled</label>
										<div class="controls">
											<g:hiddenField name="enabled" id="enabled" value="${userInstance.enabled}" />			
											<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="enabled">
												<button type="button" value="true" class="btn success"><i class="icon-ok-sign"></i> Enabled</button>
												<button rel="tooltip" title="Disable this account" type="button" value="false" class="btn warning"><i class="icon-remove-sign"></i> Disabled</button>
											</div>
										</div>
									</div>
									<div class="control-group ">
										<label for="label" class="control-label">Access</label>
										<div class="controls">
											<g:hiddenField name="is_admin" id="is_admin" value="${admin}" />			
											<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_admin">
												<button type="button" value="false" class="btn"><i class="icon-user"></i> User</button>
												<button rel="tooltip" title="Make this user a CaPSID administrator" type="button" value="true" class="btn"><i class="icon-lock"></i> Admin</button>
											</div>
										</div>
									</div>
									<div class="form-actions" style="border-radius:0; border:none;">
										<button type="submit" class="btn btn-success">
											<i class="icon-ok icon-white"></i>
											<g:message code="default.button.update.label" default="Update" />
										</button>
										<g:link action="list" class="btn">Cancel</g:link>
									</div>
								</fieldset>
							</g:form>
						</fieldset>
					</div>
					</auth:ifCapsidAdmin>
				</div>
			</section>
			<section>
				<div class="page-header">
					<h1>Delete User</h1>
				</div>
				<div class="row-fluid">
					<div class="span alert alert-danger">Deleting a User is permanent, please be certain before continuing.</div>
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
		            <h3>Delete User</h3>
		            </div>
		            <div class="modal-body">
		            	<div class="alert alert-danger">Deleting a User is permanent, please be certain before continuing.</div>	
		            </div>
				    <div class="modal-footer">
						<g:form action="update" id="${userInstance?.username}" >
							<g:hiddenField name="version" value="${userInstance?.username}" />
							<a data-dismiss="modal" class="btn" href="#">Close</a>
							<button type="submit" class="btn btn-danger" name="_action_delete" formnovalidate>
								<i class="icon-trash icon-white"></i>
								<g:message code="default.button.delete.label" default="Delete" />
							</button>
						</g:form>
					</div>
				</div>
			</section>
			</div>
		</div>
	</body>
</html>
