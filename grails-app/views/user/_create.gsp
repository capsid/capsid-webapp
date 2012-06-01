<%@ page import="ca.on.oicr.capsid.User" %>
<div class="modal-body">
	<f:field bean="${userInstance}" property="username"/>
	<f:all bean="${userInstance}"/>
	<div class="control-group ">
		<label for="label" class="control-label">Access</label>
		<div class="controls">
			<g:hiddenField name="is_admin" id="is_admin" value="${params.is_admin?:false}" />			
			<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_admin">
				<button type="button" value="false" class="btn"><i class="icon-user"></i> User</button>
				<button rel="tooltip" title="Make this user a CaPSID administrator" type="button" value="true" class="btn"><i class="icon-lock"></i> Admin</button>
			</div>
		</div>
	</div>
	<div class="control-group ">
		<label for="label" class="control-label">LDAP</label>
		<div class="controls">
			<g:hiddenField name="is_ldap" id="is_ldap" value="${params.is_ldap?:false}" />
			
			<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_ldap">
				<button rel="tooltip" title="CaPSID will use the Database for authorization" type="button" value="false" class="btn">No</button>
				<button rel="tooltip" title="CaPSID will use LDAP for authorization" type="button" value="true" class="btn">LDAP</button>
			</div>
		</div>
	</div>
</div>
<div class="modal-footer">
	<g:link action="list" class="btn" data-dismiss="modal">Close</g:link>
	<button type="submit" class="btn btn-success">
		<i class="icon-ok icon-white"></i>
		<g:message code="default.button.create.label" default="Create" />
	</button>
</div>
