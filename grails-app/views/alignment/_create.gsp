<%@ page import="ca.on.oicr.capsid.Alignment" %>
<div class="modal-body">
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

	<f:field bean="alignmentInstance" property="name"/>
	<f:all bean="alignmentInstance"/>
</div>
<div class="modal-footer">
	<g:link controller="alignment" action="show" id="${alignmentInstance.sample}" class="btn" data-dismiss="modal">Close</g:link>
	<button type="submit" class="btn btn-success">
		<i class="icon-ok icon-white"></i>
		<g:message code="default.button.create.label" default="Create" />
	</button>
</div>
			