<%@ page import="ca.on.oicr.capsid.Sample" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <h1>${sampleInstance.name} Details</h1>
    <div class="line">
      <g:form action="update" method="post" id="${sampleInstance.name}" dojoType="dijit.form.Form" class="unit size1of2">
        <g:hiddenField name="name" value="${sampleInstance.name}"/>
        <table>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="description"><g:message code="sample.description.label" default="Description" /></label>
              </td>
              <td valign="top" class="value">
                <g:textArea name="description" value="${sampleInstance?.description}" style="width:350px;" dojoType="dijit.form.Textarea"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="cancer"><g:message code="sample.cancer.label" default="Cancer" /></label>
              </td>
              <td valign="top" class="value">
                <g:textField name="cancer" value="${sampleInstance?.cancer}" dojoType="dijit.form.TextBox"/>
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
            <tr class="prop">
              <td valign="top" class="name">
                <label for="source"><g:message code="sample.source.label" default="Source" /></label>
              </td>
              <td valign="top" class="value">
                <g:textField name="source" value="${sampleInstance?.source}" dojoType="dijit.form.TextBox"/>
              </td>
            </tr>
          </tbody>
        </table>
        <button dojoType="dijit.form.Button" type="submit">Update Sample</button>
      </g:form>
    </div>
      <div class="line">
        <h1 style="color:red">Delete Sample</h1>
        <div class="errors unit size1of3">
          <div class="unit size3of4">
            <p>Deleting a sample is permanent.<br/>Please be certain before continuing.</p>
          </div>
          <div class="">
            <button type="submit" style="color:#333;" class="right" id="deleteButton" jsID="deleteButton" dojoType="dijit.form.Button">Delete Sample</button>
            <div style="display:none" style="width:400px;" id="deleteDialog" jsId="deleteDialog" dojoType="dijit.Dialog" title="Delete Sample">
              <g:form action="delete" id="deleteForm" jsId="deleteForm" method="post" dojoType="dijit.form.Form" id="${sampleInstance.name}">
Deleting this sample will also delete all alignments and mapped reads associated with it. <br/><br/>Are you sure you want to continue?
              <br/><br/>

                <button type="submit" id="deleteConfirm" jsID="deleteConfirm" dojoType="dijit.form.Button">Delete Sample</button>
                <button id="deleteCancel" jsID="deleteCancel" dojoType="dijit.form.Button">Cancel</button>
              </g:form>
            </div>
          </div>
        </div>
      </div>
  </body>
</html>
