<%@ page import="ca.on.oicr.capsid.User" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>
    <body>
	<g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
        <div class="unit">
            <h1>Users</h1>
        </div>
        <sec:ifAnyGranted roles="ROLE_CAPSID">
	    <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Add User</button>
	  	<div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Add User" >
			<g:form action='save' method="post" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
				<div id="formError" style="color:red"></div>
				<table>
			       <tbody>
			           <tr class="prop">
			               <td valign="top" class="name">
			                   <label for="name"><g:message code="user.username.label" default="Username" /></label>
			               </td>
			               <td valign="top" class="value">
			                   <g:textField name="username" value="" dojoType="dijit.form.ValidationTextBox" regExp='[\\w]+' required="true" invalidMessage="Invalid Symbol or Space."/>
			               </td>
			           </tr>
			      	   <tr class="prop">
			               <td valign="top" class="name">
			                   <label for="email"><g:message code="user.email.label" default="Email" /></label>
			               </td>
			               <td valign="top" class="value">
			                   <g:textField name="email" dojotype="dijit.form.ValidationTextBox" regexpgen="dojox.validate.regexp.emailAddress" required="true" invalidmessage="Invalid Email Address."/>
			               </td>
			           </tr>
			       </tbody>
				</table>
				<button dojoType="dijit.form.Button" name="createSubmit" type="submit">Add</button>
	      	</g:form>
	  	</div>
	  	</sec:ifAnyGranted>
	</div>
    <div dojoType="dojox.data.AndOrReadStore" url="list_data/" idAttribute="id" jsId="store" query="{}"></div>
	<div dojoType="dojox.grid.EnhancedGrid" id="grid" jsId="grid" style="height:465px" store="store"
         	 sortInfo="1"
     		 plugins="{
			 	pagination: true, 
			 	filter: {itemsName : 'users'}
                }"
			selectable="true"
			editable="true"
		 	structure='[{cells:[
			    	{field: "username", name: "Username", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.user}
			    ,	{field: "userRealName", name: "Name", datatype: "string", width: "auto"}
			    ,	{field: "email", name: "Email", datatype: "string", width: "auto"}
                ,	{field: "enabled", name: "Enabled", styles:"text-align: center;", datatype: "bool", type: dojox.grid.cells.Bool, editable: true, width: "50px"}
			    ,	{field: "admin", name: "Admin", styles:"text-align: center;", datatype: "bool", type: dojox.grid.cells.Bool, editable: true, width: "50px"}
			    ,	{field: "roles", name: "Roles", datatype: "string", width: "auto"}
			    ]}]'>
	</div>
    </body>
</html>
