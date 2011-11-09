<g:each var="user" in="${users}">
<li class="user-box">
    <g:link controller="user" action="show" id="${user.username}">${user.username}</g:link>
    <g:set var="un"><sec:username/></g:set>
    <g:if test="${un != user.username}">
    <g:link controller="user" action="demote" id="${user.username}" params="[pid:projectInstance.label]" class="delete"></g:link>
    </g:if>
    <g:link controller="user" action="show" id="${user.username}" params="[pid:projectInstance.label]" class="edit"></g:link>
</li>
</g:each>