<%@ page import="ca.on.oicr.capsid.User" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body>
       	<input type="hidden" id="id" value="${fieldValue(bean: userInstance, field: "id")}"/>
        <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
        <div class="line">
            <div class="unit">
                <h1>${userInstance.username}</h1>
            </div>
            <g:if test="${loggedInUsername == userInstance.username}">
	        <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Change Password</button>
	        <div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Change Password" >
				<g:form action="changePassword" method="post" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
				<g:hiddenField name="username" value="${userInstance.username}" />
                <table>
                	<tbody> 
                	    <tr class="prop">
                            <td valign="top" class="name">
                             <label for="password"><g:message code="user.password.label" default="Old Password" /></label>
                            </td>
                            <td valign="top" class="value">
                            	<g:passwordField name="oldPassword" dojoType="dijit.form.ValidationTextBox" regExp='.{1,}' required="true" invalidMessage="Password must be at least 8 characters"/>
							</td>
                        </tr>
                        <tr class="prop">
                            <td valign="top" class="name">
                             <label for="password"><g:message code="user.password.label" default="Password" /></label>
                            </td>
                            <td valign="top" class="value">
                            	<g:passwordField name="newPassword" dojoType="dijit.form.ValidationTextBox" regExp='.{8,}' required="true" invalidMessage="Password must be at least 8 characters"/>
							</td>
                        </tr>
                    </tbody>
                </table>
				<button dojoType="dijit.form.Button" name="createSubmit" type="submit">Submit</button>
				</g:form>
	    	</div>
	    	</g:if>
        </div>
        <div class="line">
            <div class="dialog unit size1of3">
           	<g:form action="update" method="post" dojoType="dijit.form.Form" id="editForm" jsId="editForm">
           	<g:hiddenField name="username" value="${userInstance.username}" />
                <table>
                    <tbody>
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="user.userRealName.label" default="Name" /></td>
                            <td valign="top" class="value"><span dojoType="dijit.InlineEditBox" editor="dijit.form.Textarea" autoSave="false" width="400" title="Edit sample description" 
				            editorParams="{name:'userRealName'}"
				            class="subheader">${fieldValue(bean: userInstance, field: 'userRealName')}</span></td>
                        </tr>
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="user.email.label" default="Email" /></td>
                            <td valign="top" class="value"><span dojoType="dijit.InlineEditBox" editor="dijit.form.Textarea" autoSave="false" width="400" title="Edit sample description" 
				            editorParams="{name:'email'}"
				            class="subheader">${fieldValue(bean: userInstance, field: 'email')}</span></td>
                        </tr>
                        
            			<sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="user.admin.label" default="Admin" /></td>
                            <td valign="top" class="value"><g:checkBox name="admin" value="${'ROLE_CAPSID_ADMIN' in userInstance.authorities.authority}"/></td>
                        </tr>
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="user.enabled.label" default="Enabled" /></td>
                            <td valign="top" class="value"><g:checkBox name="enabled" value="${userInstance.enabled}"/></td>
                        </tr>
						</sec:ifAnyGranted>
                    </tbody>
                </table>
				<button dojoType="dijit.form.Button" name="createSubmit" type="submit">Submit Changes</button>
            </g:form>
            </div>
        </div>
    </body>
</html>
