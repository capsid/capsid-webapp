
<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
		<title>${userInstance.username}</title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1>
							${userInstance.username}
							<g:if test="${userInstance?.userRealName}">(${userInstance.userRealName})</g:if><br>
							<small>
								<g:if test="${userInstance?.institute}">${userInstance.institute}, </g:if>
								<g:if test="${userInstance?.location}">${userInstance.location}</g:if>
							</small>
						</h1>
						<h4>${userInstance.email}</h4>
					</div>
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${userInstance?.username}" />
						<div>
							<g:link class="btn" action="edit" id="${userInstance?.username}">
								<i class="icon-pencil"></i>
								<g:message code="default.button.edit.label" default="Edit" />
							</g:link>
						</div>
					</g:form>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				<h1>Bookmarks <!--<small>Drag & Drop to re-order</small>--></h1>
				<div class="row">
					<ul class="nav span4" id="sortable-bookmarks">
					<g:each var="bookmark" in="${userInstance.bookmarks}">
						<li class="well well-small" style="margin-bottom:5px;">
							<span>
								<a href="${bookmark['address']}"><i class="icon-bookmark"></i> ${bookmark['title']}</a>
							</span>
							<g:link action="remove_bookmark" id="${userInstance.username}" params="[_id: bookmark['_id']]" class="icon-remove close delete" style="margin-top:4px;margin-left:5px;"></g:link>
							<!--
							<i class="icon-pencil close delete" style="margin-top:4px;"></i>
							-->
						</li>
					</g:each> 
				</div>
			</div>
		</div>
	</body>
</html>
