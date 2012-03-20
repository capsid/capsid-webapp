<div class="well well-small user" style="margin-bottom:5px">
<g:link controller="user" action="show" id="${username}">${username}</g:link>
<g:link controller="user" action="demote" id="${label}" params="[username:username]" class="close" data-dismiss="alert" href="#">&times;</g:link>
</div>