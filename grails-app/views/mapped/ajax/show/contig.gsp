<div class="line">
<b>&gt${mappedInstance.readId}</b><br>
<code style='display:"block";width:"200px";'>
<g:set var="counter" value="${0}" />
<g:each var="base" in="${sequence}">${base}<g:set var="counter" value="${counter + 1}"/><g:if test="${counter % 80 == 0}"><br></g:if></g:each>
</code>
</div>
<div class="line">
	<br>
	<a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&LINK_LOC=blasthome&QUERY=${sequence.join('')}" target="_blank">
	Send Contig to NCBI BLAST</a>
</div>