<%@ page import="ca.on.oicr.capsid.Alignment" %>



<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'aligner', 'error')} ">
	<label for="aligner">
		<g:message code="alignment.aligner.label" default="Aligner" />
		
	</label>
	<g:textField name="aligner" value="${alignmentInstance?.aligner}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'infile', 'error')} ">
	<label for="infile">
		<g:message code="alignment.infile.label" default="Infile" />
		
	</label>
	<g:textField name="infile" value="${alignmentInstance?.infile}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'name', 'error')} ">
	<label for="name">
		<g:message code="alignment.name.label" default="Name" />
		
	</label>
	<g:textField name="name" value="${alignmentInstance?.name}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'outfile', 'error')} ">
	<label for="outfile">
		<g:message code="alignment.outfile.label" default="Outfile" />
		
	</label>
	<g:textField name="outfile" value="${alignmentInstance?.outfile}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'platform', 'error')} ">
	<label for="platform">
		<g:message code="alignment.platform.label" default="Platform" />
		
	</label>
	<g:textField name="platform" value="${alignmentInstance?.platform}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'project', 'error')} ">
	<label for="project">
		<g:message code="alignment.project.label" default="Project" />
		
	</label>
	<g:textField name="project" value="${alignmentInstance?.project}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'sample', 'error')} ">
	<label for="sample">
		<g:message code="alignment.sample.label" default="Sample" />
		
	</label>
	<g:textField name="sample" value="${alignmentInstance?.sample}" />
</div>

<div class="fieldcontain ${hasErrors(bean: alignmentInstance, field: 'type', 'error')} ">
	<label for="type">
		<g:message code="alignment.type.label" default="Type" />
		
	</label>
	<g:textField name="type" value="${alignmentInstance?.type}" />
</div>

