<%@ page import="ca.on.oicr.capsid.Project" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <h1>Project Details</h1>
    <div class="line">
      <g:form action="update" method="post" id="${projectInstance.label}" dojoType="dijit.form.Form" class="unit size1of2">
        <input type="hidden" name="label" value="${projectInstance.label}"/>
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
                <label for="description"><g:message code="project.description.label" default="Description" /></label>
              </td>
              <td valign="top" class="value">
                <g:textArea name="description" value="${projectInstance?.description}" style="width:350px;" dojoType="dijit.form.Textarea"/>
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
            <tr class="prop">
              <td valign="top" class="name">
                <label for="private"><g:message code="project.private.label" default="Private" /></label>
              </td>
              <td valign="top" class="value">
                <g:checkBox name="private" value="${!('ROLE_CAPSID' in projectInstance.roles)}"/>
              </td>
            </tr>
          </tbody>
        </table>
        <button type="submit" dojoType="dijit.form.Button">Update Project</button>
      </g:form>
    </div>
    <auth:ifAnyGranted access="[(projectInstance.label):['admin']]">
      <div class="line" style="margin: 25px 0;">
        <h1>Access Control</h1>
        <div dojoType="dojo.data.ItemFileReadStore" jsId="userStore" url="../../user/unassigned/${projectInstance.label}" clearOnClose="true" urlPreventCache="true"></div>
        <div dojoType="dijit.layout.TabContainer" style="width: 50%;" doLayout="false"
             tabStrip="true" parseOnLoad="true" id="access-panel">
          <g:render template='/layouts/projectaccesspanel' model="[users:users, projectInstance:projectInstance, level: 'owner']"/>
          <g:render template='/layouts/projectaccesspanel' model="[users:users, projectInstance:projectInstance, level: 'collaborator']"/>
          <g:render template='/layouts/projectaccesspanel' model="[users:users, projectInstance:projectInstance, level: 'user']"/>
        </div>
      </div>
      <div class="line">
        <h1 style="color:red">Delete Project</h1>
        <div class="errors unit size1of3">
          <div class="unit size3of4">
            <p>Deleting a project is permanent.<br/>Please be certain before continuing.</p>
          </div>
          <div class="">
            <button type="submit" style="color:#333;" class="right" id="deleteButton" jsID="deleteButton" dojoType="dijit.form.Button">Delete Project</button>
            <div style="display:none" style="width:400px;" id="deleteDialog" jsId="deleteDialog" dojoType="dijit.Dialog" title="Delete Project">
              <g:form action="delete" id="deleteForm" jsId="deleteForm" method="post" dojoType="dijit.form.Form" id="${projectInstance.label}">
Deleting this project will also delete all samples, alignments and mapped reads associated with it. <br/><br/>Are you sure you want to continue?
              <br/><br/>

                <button type="submit" id="deleteConfirm" jsID="deleteConfirm" dojoType="dijit.form.Button">Delete Project</button>
                <button id="deleteCancel" jsID="deleteCancel" dojoType="dijit.form.Button">Cancel</button>
              </g:form>
            </div>
          </div>
        </div>
      </div>
    </auth:ifAnyGranted>
  </body>
</html>
