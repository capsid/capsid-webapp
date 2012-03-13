<%@ page import="ca.on.oicr.capsid.Sample" %>



<div class="fieldcontain ${hasErrors(bean: sampleInstance, field: 'cancer', 'error')} ">
	<label for="cancer">
		<g:message code="sample.cancer.label" default="Cancer" />
		
	</label>
	<g:textField name="cancer" value="${sampleInstance?.cancer}" />
</div>

<div class="fieldcontain ${hasErrors(bean: sampleInstance, field: 'description', 'error')} ">
	<label for="description">
		<g:message code="sample.description.label" default="Description" />
		
	</label>
	<g:textField name="description" value="${sampleInstance?.description}" />
</div>

<div class="fieldcontain ${hasErrors(bean: sampleInstance, field: 'name', 'error')} ">
	<label for="name">
		<g:message code="sample.name.label" default="Name" />
		
	</label>
	<g:textField name="name" value="${sampleInstance?.name}" />
</div>

<div class="fieldcontain ${hasErrors(bean: sampleInstance, field: 'project', 'error')} ">
	<label for="project">
		<g:message code="sample.project.label" default="Project" />	
	</label>
	<g:textField name="project" value="${sampleInstance?.project}" />
</div>

<div class="fieldcontain ${hasErrors(bean: sampleInstance, field: 'role', 'error')} ">
	<label for="role">
		<g:message code="sample.role.label" default="Role" />
		
	</label>
	<g:textField name="role" value="${sampleInstance?.role}" />
</div>

<div class="fieldcontain ${hasErrors(bean: sampleInstance, field: 'source', 'error')} ">
	<label for="source">
		<g:message code="sample.source.label" default="Source" />
		
	</label>
	<g:textField name="source" value="${sampleInstance?.source}" />
</div>

