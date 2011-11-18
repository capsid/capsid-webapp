<%@ page import="ca.on.oicr.capsid.Alignment" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <h1>${alignmentInstance.name} Details</h1>
    <div class="line">
      <g:form action="update" method="post" id="${alignmentInstance.name}" dojoType="dijit.form.Form" class="unit size1of2">
        <g:hiddenField name="name" value="${alignmentInstance.name}"/>
        <table>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="aligner"><g:message code="alignment.aligner.label" default="Aligner" /></label>
              </td>
              <td valign="top" class="value">
                <g:textField name="aligner" value="${alignmentInstance?.aligner}" dojoType="dijit.form.TextBox"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="platform"><g:message code="alignment.platform.label" default="Platform" /></label>
              </td>
              <td valign="top" class="value">
                <g:textField name="platform" value="${alignmentInstance?.platform}" dojoType="dijit.form.TextBox"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="infile"><g:message code="alignment.infile.label" default="Input File Location" /></label>
              </td>
              <td valign="top" class="value">
                <g:textArea name="infile" value="${alignmentInstance?.infile}" style="width:350px" dojoType="dijit.form.Textarea"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="outfile"><g:message code="alignment.outfile.label" default="Output File Location" /></label>
              </td>
              <td valign="top" class="value">
                <g:textArea name="outfile" value="${alignmentInstance?.outfile}" style="width:350px" dojoType="dijit.form.Textarea"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="type"><g:message code="alignment.type.label" default="Type" /></label>
              </td>
              <td valign="top" class="value">
                <g:textField name="type" value="${alignmentInstance?.type}" dojoType="dijit.form.TextBox"/>
              </td>
            </tr>
          </tbody>
        </table>
        <button dojoType="dijit.form.Button" type="submit">Update Alignment</button>
      </g:form>
    </div>
      <div class="line">
        <h1 style="color:red">Delete Alignment</h1>
        <div class="errors unit size1of3">
          <div class="unit size3of4">
            <p>Deleting an alignment is permanent.<br/>Please be certain before continuing.</p>
          </div>
          <div class="">
            <button type="submit" style="color:#333;" class="right" id="deleteButton" jsID="deleteButton" dojoType="dijit.form.Button">Delete Alignment</button>
            <div style="display:none" style="width:400px;" id="deleteDialog" jsId="deleteDialog" dojoType="dijit.Dialog" title="Delete Alignment">
              <g:form action="delete" id="deleteForm" jsId="deleteForm" method="post" dojoType="dijit.form.Form" id="${alignmentInstance.name}">
Deleting this alignment will also delete all mapped reads associated with it. <br/><br/>Are you sure you want to continue?
              <br/><br/>

                <button type="submit" id="deleteConfirm" jsID="deleteConfirm" dojoType="dijit.form.Button">Delete Alignment</button>
                <button id="deleteCancel" jsID="deleteCancel" dojoType="dijit.form.Button">Cancel</button>
              </g:form>
            </div>
          </div>
        </div>
      </div>
  </body>
</html>
