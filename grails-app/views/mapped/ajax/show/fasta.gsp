<div class="line">
<b>>${mappedInstance.readId}</b><br>
<code>
<g:each var="i" in="${sequence}">
${i}<br>
</g:each>
</code>
</div>
<div class="line">
	<br>
	<a href="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?PROGRAM=blastn&BLAST_PROGRAMS=megaBlast&PAGE_TYPE=BlastSearch&SHOW_DEFAULTS=on&LINK_LOC=blasthome&QUERY=${sequence.join('')}" target="_blank">
	Send Sequence to NCBI BLAST</a>
</div>