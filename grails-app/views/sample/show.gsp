<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Alignment" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body>
       	<input type="hidden" id="id" value="${fieldValue(bean: sampleInstance, field: "id")}"/>
        <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
        <div class="line">
            <sec:ifNotGranted roles="ROLE_CAPSID_ADMIN">
            <div class="unit">
                <h1>${sampleInstance.name}</h1>    
                <div class="subheader">${fieldValue(bean: sampleInstance, field: "description")}</div>
            </div>
            </sec:ifNotGranted>
            <sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">
            <div class="unit">
                <h1>${sampleInstance.name}</h1>
            	<g:form url="[controller:'sample', action:'update']" method="get" dojoType="dijit.form.Form" id="editForm" jsId="editForm">
            	<g:hiddenField name="name" value="${sampleInstance.name}" />
			    <div dojoType="dijit.InlineEditBox" editor="dijit.form.Textarea" autoSave="false" width="500" title="Edit sample description" 
	            editorParams="{name:'description'}"
	            onChange="capsid.form.Inline.prototype.update('editForm');"
	            class="subheader">${fieldValue(bean: sampleInstance, field: "description")}</div>
            	</g:form>
            </div>
            <button class="unit right" id="createButton" dojoType="dijit.form.Button" type="button">Add Alignment</button>
      		<div style="display:none" id="createDialog" dojoType="dijit.Dialog" title="Add Alignment" >
				<g:form url="[controller:'alignment', action:'save']" method="get" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
					<div id="formError" style="color:red"></div>
					<g:hiddenField name="project" value="${sampleInstance.project}" />
					<g:hiddenField name="sample" value="${sampleInstance.name}" />
					<table>
				       <tbody>
				       	   <tr class="prop">
				               <td valign="top" class="name">
				                   <label for="name"><g:message code="alignment.name.label" default="Name" /></label>
				               </td>
				               <td valign="top" class="value">
				                   <g:textField name="name" value="${alignmentInstance?.name}" dojoType="dijit.form.ValidationTextBox" required="true"/>
				               </td>
				           </tr>
				           <tr class="prop">
				               <td valign="top" class="name">
				                   <label for="aligner"><g:message code="alignment.aligner.label" default="Aligner" /></label>
				               </td>
				               <td valign="top" class="value">
				                   <g:textField name="aligner" value="${alignmentInstance?.aligner}" dojoType="dijit.form.ValidationTextBox" required="true"/>
				               </td>
				           </tr>
				           <tr class="prop">
				               <td valign="top" class="name">
				                   <label for="platform"><g:message code="alignment.platform.label" default="Platform" /></label>
				               </td>
				               <td valign="top" class="value">
				                   <g:textField name="platform" value="${alignmentInstance?.platform}" dojoType="dijit.form.ValidationTextBox" required="true"/>
				               </td>
				           </tr>
				           <tr class="prop">
				               <td valign="top" class="name">
				                   <label for="infile"><g:message code="alignment.infile.label" default="Input File Location" /></label>
				               </td>
				               <td valign="top" class="value">
				                   <g:textArea name="infile" value="${alignmentInstance?.infile}" dojoType="dijit.form.Textarea"/>
				               </td>
				           </tr>
				           <tr class="prop">
				               <td valign="top" class="name">
				                   <label for="outfile"><g:message code="alignment.outfile.label" default="Output File Location" /></label>
				               </td>
				               <td valign="top" class="value">
				                   <g:textArea name="outfile" value="${alignmentInstance?.outfile}" dojoType="dijit.form.Textarea"/>
				               </td>
				           </tr>
				           <tr class="prop">
				               <td valign="top" class="name">
				                   <label for="type"><g:message code="alignment.type.label" default="Type" /></label>
				               </td>
				               <td valign="top" class="value">
				                   <g:textField name="type" value="${alignmentInstance?.type}" dojoType="dijit.form.ValidationTextBox" required="true"/>
				               </td>
				           </tr>
				       </tbody>
					</table>
					<button dojoType="dijit.form.Button" name="createSubmit" type="submit">Add</button>
		      	</g:form>
		  	</div>
		   </sec:ifAnyGranted>
        </div>
        <div class="line">
            <div class="dialog unit size1of3">
                <table>
                    <tbody>
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="sample.project.label" default="Project" /></td>
                            <td valign="top" class="value"><g:link controller="project" action="show" id="${fieldValue(bean: sampleInstance, field: 'project')}">${Project.findByLabel(sampleInstance.project).name}</g:link></td>
                        </tr>
		            	<tr class="prop">
                            <td valign="top" class="name" ><g:message code="sample.role.label" default="Role" /></td>
                            <td valign="top" class="value">
				            	<sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">
				            	<g:form url="[controller:'sample', action:'update']" method="get" dojoType="dijit.form.Form" id="editForm2" jsId="editForm2">
								<g:hiddenField name="name" value="${sampleInstance.name}" />
					            <span dojoType="dijit.InlineEditBox" editor="dijit.form.TextBox" autoSave="true" title="Edit sample role" editorParams="{name:'role'}" onChange="capsid.form.Inline.prototype.update('editForm2');">
					            ${fieldValue(bean: sampleInstance, field: "role")}
					            </span>
					            </g:form>
					            </sec:ifAnyGranted>
					            <sec:ifNotGranted roles="ROLE_CAPSID_ADMIN">
					            ${fieldValue(bean: sampleInstance, field: "role")}
					            </sec:ifNotGranted>
				            </td>
                        </tr>
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="sample.source.label" default="Source" /></td>
                            <td valign="top" class="value">
                            <sec:ifAnyGranted roles="ROLE_CAPSID_ADMIN">
				            	<g:form url="[controller:'sample', action:'update']" method="get" dojoType="dijit.form.Form" id="editForm3" jsId="editForm3">
								<g:hiddenField name="name" value="${sampleInstance.name}" />
					            <span dojoType="dijit.InlineEditBox" editor="dijit.form.TextBox" autoSave="true" title="Edit sample source" editorParams="{name:'source'}" onChange="capsid.form.Inline.prototype.update('editForm3');">
					            ${fieldValue(bean: sampleInstance, field: "source")}
					            </span>
					            </g:form>
					            </sec:ifAnyGranted>
					            <sec:ifNotGranted roles="ROLE_CAPSID_ADMIN">
					            ${fieldValue(bean: sampleInstance, field: "source")}
					            </sec:ifNotGranted>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="line">
            <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="true" persist="true">
             <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_stats", id:sampleInstance.id)}" rel="Statistics" title="Stats"></div>
             <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_alignments", id:sampleInstance.id)}" rel="Alignments" title="Alignments"></div>
            </div>
        </div>
    </body>
</html>
