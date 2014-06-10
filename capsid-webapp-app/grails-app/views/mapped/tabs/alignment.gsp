<div id="alignment-sequence" class="well well-small">
    <g:each var="i" in="${(0..<alignment.query.seq.size())}">
	    <div class="seqrow">
			<div class="seq query">
				<span class="seqlabel">Query</span>
				<span class="seqpos">${(i==0)?1:(alignment.query.pos[i-1]+1)}</span>
				<span class="seqstr">${alignment.query.seq[i]}</span>
				<span class="seqpos">${alignment.query.pos[i]}</span>
			</div>
			<div class="seq markup">
				<span class="seqlabel"></span>
				<span class="seqpos"></span>
				<span class="seqstr">${alignment.markup[i]}</span>
			</div>
			<div class="seq ref">
				<span class="seqlabel">${genomeInstance.accession}</span>
				<span class="seqpos">${(i==0)?mappedInstance.refStart:(mappedInstance.refStart+alignment.ref.pos[i-1])}</span>
				<span class="seqstr">${alignment.ref.seq[i]}</span>
				<span class="seqpos">${mappedInstance.refStart+alignment.ref.pos[i] - 1}</span>
			</div>
		</div>
    </g:each>
</div>