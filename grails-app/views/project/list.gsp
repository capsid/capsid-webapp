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
        <sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">	
        <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Create Project</button>
        <div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Create Project" >
			<g:form action="save" method="get" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
				<div id="formError" style="color:red"></div>
				<table>
			       <tbody>
			           <tr class="prop">
			               <td valign="top" class="name">
			                   <label for="name"><g:message code="project.name.label" default="Name" /></label>
			               </td>
			               <td valign="top" class="value">
			                   <g:textField name="name" value="${projectInstance?.name}" dojoType="dijit.form.ValidationTextBox" required="true"/>
			               </td>
			           </tr>
			           <tr class="prop">
			               <td valign="top" class="name">
			                   <label for="label"><g:message code="project.label.label" default="Label" /></label>
			               </td>
			               <td valign="top" class="value">
			                   <g:textField name="label" value="${projectInstance?.label}"  dojoType="dijit.form.ValidationTextBox" regExp='[\\w]+' required="true" invalidMessage="Invalid Symbol or Space."/>
			               </td>
			           </tr>
			           <tr class="prop">
			               <td valign="top" class="name">
			                   <label for="description"><g:message code="project.description.label" default="Description" /></label>
			               </td>
			               <td valign="top" class="value">
			                   <g:textArea name="description" value="${projectInstance?.description}" dojoType="dijit.form.Textarea"/>
			               </td>
			           </tr>
			           <tr class="prop">
			               <td valign="top" class="name">
			                   <label for="wikiLink"><g:message code="project.wikiLink.label" default="Wiki Link" /></label>
			               </td>
			               <td valign="top" class="value">
			                   <g:textField name="wikiLink" value="${projectInstance?.wikiLink}" dojoType="dijit.form.TextBox"/>
			               </td>
			           </tr>
			       </tbody>
				</table>
				<button dojoType="dijit.form.Button" name="createSubmit" type="submit">Create</button>
        	</g:form>
    	</div>
        </sec:ifAnyGranted>	
    </div>
    <div dojoType="dojox.data.AndOrReadStore" url="list_data/" idAttribute="id" jsId="store" query="{}"></div>
    <div dojoType="dojox.grid.EnhancedGrid" id="grid" jsId="grid" style="height:450px" store="store"
                  sortInfo="1"
                  plugins="{
		             pagination: true,
		             filter: { itemsName : 'projects' },
		             cookie: true
		             }"
				 selectable="true"
		         structure='[{cells:[
		                {fields: ["label", "name"], name: "Name", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.project},
		                {field: "description", name: "Description", datatype: "string", filterable: false, width: "auto"},
		                {field: "links",  name: "Links", datatype: "string", filterable: false, width: "auto"}
		                ]}]'>
    </div>
    </body>
</html>
