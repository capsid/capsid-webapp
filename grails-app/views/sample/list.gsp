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
        <sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">    
        <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Add Sample</button>
           <div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Add Sample" >
            <g:form action='save' method="get" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
                <div id="formError" style="color:red"></div>
                <table>
                   <tbody>
                       <tr class="prop">
                           <td valign="top" class="name">
                               <label for="name"><g:message code="sample.name.label" default="Name" /></label>
                           </td>
                           <td valign="top" class="value">
                               <g:textField name="name" value="${sampleInstance?.name}" dojoType="dijit.form.ValidationTextBox" regExp='[\\w]+' required="true" invalidMessage="Invalid Symbol or Space."/>
                           </td>
                       </tr>
                         <tr class="prop">
                           <td valign="top" class="name">
                               <label for="project"><g:message code="sample.project.label" default="Project" /></label>
                           </td>
                           <td valign="top" class="value">
                               <g:select name="project" from="${Project.security(roles).list()}" optionValue="name" optionKey="label"  dojoType="dijit.form.FilteringSelect" required="true"/>
                           </td>
                       </tr>
                       <tr class="prop">
                           <td valign="top" class="name">
                               <label for="cancer"><g:message code="sample.cancer.label" default="Cancer" /></label>
                           </td>
                           <td valign="top" class="value">
                               <g:textField name="cancer" value="${sampleInstance?.cancer}" dojoType="dijit.form.ValidationTextBox" required="true"/>
                           </td>
                       </tr>
                       <tr class="prop">
                           <td valign="top" class="name">
                               <label for="description"><g:message code="sample.description.label" default="Description" /></label>
                           </td>
                           <td valign="top" class="value">
                               <g:textArea name="description" value="${sampleInstance?.description}" dojoType="dijit.form.Textarea"/>
                           </td>
                       </tr>
                       <tr class="prop">
                           <td valign="top" class="name">
                               <label for="source"><g:message code="sample.source.label" default="Source" /></label>
                           </td>
                           <td valign="top" class="value">
                               <g:textField name="source" value="${sampleInstance?.source}" dojoType="dijit.form.TextBox"/>
                           </td>
                       </tr>
                       <tr class="prop">
                           <td valign="top" class="name">
                               <label for="role"><g:message code="sample.role.label" default="Role" /></label>
                           </td>
                           <td valign="top" class="value">
                               <g:textField name="role" value="${sampleInstance?.role}" dojoType="dijit.form.TextBox"/>
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
    <div dojoType="dojox.grid.EnhancedGrid" id="grid" jsId="grid" style="height:450px" store="store"
              sortInfo="1"
              plugins="{
                 pagination: true, 
                 filter: {
                     itemsName : 'samples'
                     }
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
