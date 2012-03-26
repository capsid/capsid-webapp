<%@ page import="ca.on.oicr.capsid.Project" %>
<div class="modal-body">
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

	<f:all bean="projectInstance"/>
	<f:field bean="projectInstance" property="label"/>
	<div class="control-group ">
		<label for="label" class="control-label">Security</label>
		<div class="controls">
			<g:hiddenField name="is_private" id="is_private" value="${true}" />
			
			<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_private">
				<button rel="tooltip" title="Your project will only be visable to users that are given access" type="button" value="true" class="btn active"><i class="icon-lock"></i> Private</button>
				<button rel="tooltip" title="Project will be visable to all CaPSID users" type="button" value="false" class="btn"><i class="icon-eye-open"></i> Public</button>
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
