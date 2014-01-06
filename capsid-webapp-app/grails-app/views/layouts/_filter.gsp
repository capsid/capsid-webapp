<g:form action="${id?'show':'list'}" id="${id}" params="${projectLabel ? [projectLabel: projectLabel] : []}" class="form-horizontal pull-right search">
	<div class="input-prepend input-append pull-right" style="margin: 0 10px;">
		<span class="add-on"><i class="icon-search"></i></span><input type="search" name="text" value="${query}"><span><span class="clear btn btn-danger">&times;</span><button class="btn">Search</button></span>
	</div>
</g:form>