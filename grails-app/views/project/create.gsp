<%@ page import="ca.on.oicr.capsid.Project" %>
<form action="save" method="post" dojoType="dijit.form.Form" id="createForm" jsId="createForm">
  <div class="error">${flash.message}</div>
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
      <tr class="prop">
        <td valign="top" class="name">
          <label for="private"><g:message code="project.private.label" default="Private" /></label>
        </td>
        <td valign="top" class="value">
          <input id="private" name="private" dojoType="dijit.form.CheckBox" value="agreed"/>
        </td>
      </tr>
    </tbody>
  </table>
  <button dojoType="dijit.form.Button" type="submit">Create</button>
</form>
