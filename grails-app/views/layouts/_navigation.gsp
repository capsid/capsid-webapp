<sec:ifLoggedIn>
<div id="nav" class="line">
<g:set var="menuItems" value="[['controller':'project','name':'Projects'],['controller':'genome','name':'Genomes'],['controller':'sample','name':'Samples']]"/>
<g:each var="item" in="${menuItems}">
<span class="item unit${controllerName==item.controller?' selected':''}"><g:link controller="${item.controller}" action="list">${item.name}</g:link></span>
</g:each>
<sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">
<span class="item unit right ${controllerName=='user' ? ' selected' : ''}"><g:link controller="user" action="list">Access Control</g:link></span>
</sec:ifAnyGranted>
</div>
</sec:ifLoggedIn>
