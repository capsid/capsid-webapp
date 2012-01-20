<div id="alignment" class="line">
    <g:each var="i" in="${(0..<alignment.query.seq.size())}">
    	<div class="line seqrow">
		    <div class="line seq query">
		      	<span class="seqlabel">Query</span>
		      	<span class="seqpos">${(i==0)?1:(alignment.query.pos[i-1]+1)}</span>
		      	<span class="seqstr">
		      		<g:each var="base" in="${alignment.query.seq[i]}">
		      			<span class="base">${base}</span>
		  			</g:each>
				</span>
				<span class="seqpos">${alignment.query.pos[i]}</span>
			</div>
		    <div class="line seq markup">
		    	<span class="seqlabel"></span>
		    	<span class="seqpos"></span>
		    	<g:each var="base" in="${alignment.markup[i]}">
		    		<span class="base">${base}</span>
		    	</g:each>
		    </div>
		    <div class="line seq ref">
		    	<span class="seqlabel">${genomeInstance.accession}</span>
		    	<span class="seqpos">${(i==0)?mappedInstance.refStart:(mappedInstance.refStart+alignment.ref.pos[i-1]+1)}</span>
		    	<span class="seqstr">
		    		<g:each var="base" in="${alignment.ref.seq[i]}">
		    			<span class="base">${base}</span>
		    		</g:each>
		    	</span>
		    	<span class="seqpos">${mappedInstance.refStart+alignment.ref.pos[i]}</span>
		    </div>
	    </div>
    </g:each>
</div>