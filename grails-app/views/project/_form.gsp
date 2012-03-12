<%@ page import="ca.on.oicr.capsid.Project" %>



<div class="fieldcontain ${hasErrors(bean: projectInstance, field: 'description', 'error')} ">
	<label for="description">
		<g:message code="project.description.label" default="Description" />
		
	</label>
	<g:textField name="description" value="${projectInstance?.description}" />
</div>

<div class="fieldcontain ${hasErrors(bean: projectInstance, field: 'label', 'error')} ">
	<label for="label">
		<g:message code="project.label.label" default="Label" />
		
	</label>
	<g:textField name="label" value="${projectInstance?.label}" />
</div>

<div class="fieldcontain ${hasErrors(bean: projectInstance, field: 'name', 'error')} ">
	<label for="name">
		<g:message code="project.name.label" default="Name" />
		
	</label>
	<g:textField name="name" value="${projectInstance?.name}" />
</div>

<div class="fieldcontain ${hasErrors(bean: projectInstance, field: 'wikiLink', 'error')} ">
	<label for="wikiLink">
		<g:message code="project.wikiLink.label" default="Wiki Link" />
		
	</label>
	<g:textField name="wikiLink" value="${projectInstance?.wikiLink}" />
</div>

