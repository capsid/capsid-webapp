<%@ page import="ca.on.oicr.capsid.Project" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
    <title><g:message code="default.list.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
      <div class="unit">
        <h1>Projects</h1>
      </div>
      <auth:ifCapsidAdmin">
        <button dojoType="dijit.form.Button" jsId="addProjectButton" id="addProjectButton" class="unit right">Create Project</button>
        <div style="display:none" href="${createLink(action:'create')}" id="addProjectDialog" jsId="addProjectDialog" dojoType="dijit.Dialog" title="Create New Project" refreshOnShow="true"></div>
      </auth:ifCapsidAdmin>
    </div>
    <div dojoType="dojox.data.AndOrReadStore" url="list_data/" idAttribute="id" jsId="store" query="{}" clearOnClose="true"></div>
    <div dojoType="dojox.grid.EnhancedGrid" id="grid" jsId="grid" style="height:700px" store="store"
         sortInfo="1"
         plugins='{
                    pagination: {
                      pageSizes: ["25", "50", "100", "250"]
                    },
                    filter: { itemsName : "projects" }
                  }'
         selectable="true"
         structure='[{cells:[
                    {fields: ["label", "name"], name: "Name", datatype: "string", width: "300px", formatter: capsid.grid.Formatter.prototype.links.project},
                    {field: "description", name: "Description", datatype: "string", filterable: false, width: "auto"},
                    {field: "samples", name: "Samples", datatype: "string", width: "150px"}
                    ]}]'>
    </div>
  </body>
</html>