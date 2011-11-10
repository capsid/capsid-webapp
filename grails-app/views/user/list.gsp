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
      <auth:ifAnyGranted access="['capsid': ['owner']]">
        <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Add User</button>
        <div style="display:none" href="${createLink(action:'create')}" id="createDialog" jsID="createDialog" dojoType="dijit.Dialog" title="Add New User" refreshOnShow="true"></div>
      </auth:ifAnyGranted>
    </div>
    <div dojoType="dojox.data.AndOrReadStore" url="list_data/" idAttribute="id" jsId="store" query="{}"></div>
    <div dojoType="dojox.grid.EnhancedGrid" id="grid" jsId="grid" style="height:465px"
         store="store"
         sortInfo="1"
         plugins="{
                  pagination: true,
                  filter: {itemsName : 'users'}
                  }"
         selectable="true"
         structure='[{cells:[
                    {field: "username", name: "Username", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.user}
                    ,	{field: "userRealName", name: "Name", datatype: "string", width: "auto"}
                    ,	{field: "email", name: "Email", datatype: "string", width: "auto"}
                    ,	{field: "institute", name: "Institute", datatype: "string", width: "auto"}
                    ,	{field: "location", name: "Location", datatype: "string", width: "auto"}
                    ,	{field: "enabled", name: "Enabled", styles:"text-align: center;", width: "50px"}
                    ,	{field: "admin", name: "Admin", styles:"text-align: center;", width: "50px"}
                    ]}]'>
    </div>
  </body>
</html>
