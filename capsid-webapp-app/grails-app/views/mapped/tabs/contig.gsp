<g:set var="counter" value="${0}" />
<pre class="well well-small">>${mappedInstance.readId}
<g:each var="base" in="${sequence}">${base}<g:set var="counter" value="${counter + 1}"/><g:if test="${counter % 80 == 0}">
</g:if></g:each>
</pre>
<input type="hidden" id="contig-sequence" value="${sequence.join('')}"/>
