
<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
		<r:require module="visualsearch"/>
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
					<auth:ifCapsidAdmin>
					<div class="pull-right">
						<g:link class="btn btn-primary" action="create">
							<i class="icon-plus icon-white"></i>
							<g:message code="default.button.create.label" default="Create" />
						</g:link>
					</div>
					</auth:ifCapsidAdmin>
				</div>
				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<div id="table">
						<table class="table table-striped table-condensed">
							<thead>
								<tr>
								
									<g:sortableColumn property="accountExpired" title="${message(code: 'user.accountExpired.label', default: 'Account Expired')}" />
								
									<g:sortableColumn property="accountLocked" title="${message(code: 'user.accountLocked.label', default: 'Account Locked')}" />
								
									<g:sortableColumn property="email" title="${message(code: 'user.email.label', default: 'Email')}" />
								
									<g:sortableColumn property="enabled" title="${message(code: 'user.enabled.label', default: 'Enabled')}" />
								
									<g:sortableColumn property="institute" title="${message(code: 'user.institute.label', default: 'Institute')}" />
								
									<g:sortableColumn property="location" title="${message(code: 'user.location.label', default: 'Location')}" />
								
								</tr>
							</thead>
							<tbody>
							<g:each in="${userInstanceList}" var="userInstance">
								<tr>
								
									<td><g:formatBoolean boolean="${userInstance.accountExpired}" /></td>
								
									<td><g:formatBoolean boolean="${userInstance.accountLocked}" /></td>
								
									<td>${fieldValue(bean: userInstance, field: "email")}</td>
								
									<td><g:formatBoolean boolean="${userInstance.enabled}" /></td>
								
									<td>${fieldValue(bean: userInstance, field: "institute")}</td>
								
									<td>${fieldValue(bean: userInstance, field: "location")}</td>
								
									<td class="link">
										    <div class="btn-group pull-right">
											    <g:link action="show" id="${userInstance.id}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
											    <auth:ifAnyGranted access="[(userInstance.label):['collaborator', 'owner']]">
											    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
											    <span class="caret"></span>
											    </a>
											    <ul class="dropdown-menu">
											    	<li><g:link action="show" id="${userInstance.label}"><i class="icon-chevron-right"></i> Show</g:link></li>
											    	<li><g:link action="edit" id="${userInstance.label}"><i class="icon-pencil"></i> Edit</g:link></li>
												</ul>
												</auth:ifAnyGranted>
										    </div>
									</td>
								</tr>
							</g:each>
							</tbody>
						</table>
						<div class="pagination">
							<bootstrap:paginate total="${userInstanceTotal}" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
