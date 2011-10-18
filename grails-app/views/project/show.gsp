<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />        
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body>
       	<input type="hidden" id="id" value="${fieldValue(bean: projectInstance, field: "id")}"/>
        <input type="hidden" id="label" value="${fieldValue(bean: projectInstance, field: "label")}"/>
        <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
        <div class="line">
            <sec:ifNotGranted roles="ROLE_CAPSID_ADMIN">
            <div class="unit">
	            <h1>${projectInstance.name}</h1>
	            <div class="subheader">${projectInstance.description}</div>
	            <g:if test="${projectInstance.wikiLink}"><a href="wikisomewhere/${projectInstance.wikiLink}">Wiki Link</a></g:if>
            </div>
            </sec:ifNotGranted>
            <sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">
            <g:form url="[controller:'project', action:'update']" method="get" dojoType="dijit.form.Form" id="editForm" jsId="editForm">
				<g:hiddenField name="label" value="${projectInstance.label}" />
				<div class="unit">
		            <h1 dojoType="dijit.InlineEditBox" editor="dijit.form.ValidationTextBox" autoSave="true" title="Edit project name" 
		            editorParams="{name:'name',required:'true'}"
		            onChange="xeno.form.Inline.prototype.update('editForm');">${projectInstance.name}</h1>
		            <div dojoType="dijit.InlineEditBox" editor="dijit.form.Textarea" autoSave="false" title="Edit project description" 
		            editorParams="{name:'description'}"
		            onChange="xeno.form.Inline.prototype.update('editForm');"
		            class="subheader">${projectInstance.description}</div>
		            <g:if test="${projectInstance.wikiLink}"><a href="wikisomewhere/${projectInstance.wikiLink}">Wiki Link</a></g:if>
	            </div>
            </g:form>			                
       		<button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Add Sample</button>
      		<div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Add Sample" >
				<g:form url="[controller:'sample', action:'save']" method="get" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
					<div id="formError" style="color:red"></div>
					<g:hiddenField name="project" value="${projectInstance.label}" />
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
        <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="true" persist="true">
	        <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_stats", id:projectInstance.id)}" rel="Statistics" title="Stats"></div>
        	<div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_samples", id:projectInstance.id)}" rel="Samples" title="Samples"></div>
    	    <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_alignments", id:projectInstance.id)}" rel="Alignments" title="Alignments"></div>
        </div>
    </body>
</html>
