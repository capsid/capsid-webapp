<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
    <title><g:message code="default.list.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
      <div class="unit">
        <h1>Samples</h1>
      </div>
      <auth:ifAnyGranted access="['capsid': ['owner']]">
        <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Add Sample</button>
        <div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Add Sample" ></div>
      </auth:ifAnyGranted>
    </div>
    <div dojoType="dojox.data.AndOrReadStore" url="list_data/" idAttribute="id" jsId="store" query="{}"></div>
    <div dojoType="dojox.grid.EnhancedGrid" id="grid" jsId="grid" style="height:450px" store="store"
         sortInfo="1"
         plugins="{
                  filter: {itemsName : 'samples'}
                  }"
         selectable="true"
         structure='[{cells:[
                    {field: "name", name: "Name", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.sample}
                    ,    {fields: ["plabel", "pname"], name: "Project", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.project}
                    ,    {field: "cancer", name: "Cancer", datatype: "string", width: "auto"}
                    ,    {field: "role", name: "Role", datatype: "string", width: "auto"}
                    ,    {field: "source", name: "Source", datatype: "string", width: "auto"}
                    ]}]'>
    </div>
  </body>
</html>
