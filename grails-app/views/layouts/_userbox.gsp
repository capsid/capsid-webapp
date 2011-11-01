<g:each var="user" in="${users}">
<li class="user-box">
    <g:link controller="user" action="show" id="${user.username}">${user.username}</g:link>
    <g:link controller="user" action="demote" id="${user.username}" params="[pid:projectInstance.label]" class="delete"></g:link>
    <g:link controller="user" action="show" id="${user.username}" params="[pid:projectInstance.label]" class="edit"></g:link>
</li>
</g:each>
