
<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="${layout?:'bootstrap'}">
		<g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
					<div class="pull-right">
						<div class="modal hide fade" id="myModal" style="display: none;">
				            <div class="modal-header">
				              <a data-dismiss="modal" class="close">×</a>
				              <h3>Add New User</h3>
				            </div>
				            <div class="modal-body"></div>
				        </div>
						<g:link action="create" class="btn btn-primary" data-target="#myModal" data-toggle="modal">
							<i class="icon-plus icon-white"></i>
							<g:message code="default.button.create.label" default="Create" />
						</g:link>
					</div>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<table class="table table-striped table-condensed">
						<thead>
							<tr>
								<g:sortableColumn params="${params}" property="username" title="${message(code: 'user.username.label', default: 'Username')}" />
								<g:sortableColumn params="${params}" property="email" title="${message(code: 'user.email.label', default: 'Email')}" />							
								<g:sortableColumn params="${params}" property="userRealName" title="${message(code: 'user.userRealName.label', default: 'Full Name')}" />		
								<g:sortableColumn params="${params}" property="institute" title="${message(code: 'user.institute.label', default: 'Institute')}" />							
								<g:sortableColumn params="${params}" property="location" title="${message(code: 'user.location.label', default: 'Location')}" />												
								<g:sortableColumn params="${params}" property="accountExpired" title="${message(code: 'user.accountExpired.label', default: 'Account Expired')}" />
								<g:sortableColumn params="${params}" property="accountLocked" title="${message(code: 'user.accountLocked.label', default: 'Account Locked')}" />
								<g:sortableColumn params="${params}" property="enabled" title="${message(code: 'user.enabled.label', default: 'Enabled')}" />						
							</tr>
						</thead>
						<tbody>
						<g:each in="${userInstanceList}" var="userInstance">
							<tr>
								<td><g:link action="show" id="${userInstance.username}">${fieldValue(bean: userInstance, field: "username")}</g:link></td>
								<td>${fieldValue(bean: userInstance, field: "email")}</td>
								<td>${fieldValue(bean: userInstance, field: "userRealName")}</td>
								<td>${fieldValue(bean: userInstance, field: "institute")}</td>
								<td>${fieldValue(bean: userInstance, field: "location")}</td>
								<td><g:formatBoolean boolean="${userInstance.accountExpired}" /></td>
								<td><g:formatBoolean boolean="${userInstance.accountLocked}" /></td>						
								<td><g:formatBoolean boolean="${userInstance.enabled}" /></td>
							</tr>
						</g:each>
						</tbody>
					</table>
					<div class="pagination">
						<bootstrap:paginate total="${userInstanceTotal}" params="${params}"/>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
