<b>&gt${mappedInstance.readId}</b><br>
<code style='display:"block";width:"200px";'>
<g:set var="counter" value="${0}" />
<g:each var="base" in="${sequence}">${base}<g:set var="counter" value="${counter + 1}"/><g:if test="${counter % 80 == 0}"><br></g:if></g:each>
</code>