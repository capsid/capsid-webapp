<%@ page import="ca.on.oicr.capsid.Genome" %>



<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'accession', 'error')} ">
	<label for="accession">
		<g:message code="genome.accession.label" default="Accession" />
		
	</label>
	<g:textField name="accession" value="${genomeInstance?.accession}" />
</div>

<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'gi', 'error')} ">
	<label for="gi">
		<g:message code="genome.gi.label" default="Gi" />
		
	</label>
	<g:field type="number" name="gi" value="${fieldValue(bean: genomeInstance, field: 'gi')}" />
</div>

<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'length', 'error')} ">
	<label for="length">
		<g:message code="genome.length.label" default="Length" />
		
	</label>
	<g:field type="number" name="length" value="${fieldValue(bean: genomeInstance, field: 'length')}" />
</div>

<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'name', 'error')} ">
	<label for="name">
		<g:message code="genome.name.label" default="Name" />
		
	</label>
	<g:textField name="name" value="${genomeInstance?.name}" />
</div>

<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'organism', 'error')} ">
	<label for="organism">
		<g:message code="genome.organism.label" default="Organism" />
		
	</label>
	<g:textField name="organism" value="${genomeInstance?.organism}" />
</div>

<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'sampleCount', 'error')} ">
	<label for="sampleCount">
		<g:message code="genome.sampleCount.label" default="Sample Count" />
		
	</label>
	<g:field type="number" name="sampleCount" value="${fieldValue(bean: genomeInstance, field: 'sampleCount')}" />
</div>

<div class="fieldcontain ${hasErrors(bean: genomeInstance, field: 'strand', 'error')} ">
	<label for="strand">
		<g:message code="genome.strand.label" default="Strand" />
		
	</label>
	<g:textField name="strand" value="${genomeInstance?.strand}" />
</div>

