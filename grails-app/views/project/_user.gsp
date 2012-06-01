<div class="well well-small" style="margin-bottom:5px">
<g:link controller="user" action="show" id="${username}">${username}</g:link>
<g:link controller="user" action="demote" id="${label}" params="[username:username]" class="close delete" data-dismiss="alert">&times;</g:link>
</div>