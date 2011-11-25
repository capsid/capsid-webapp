<%@ page import="ca.on.oicr.capsid.Sample" %>
<form action="${createLink(controller:'sample', action:'save')}" method="post" dojoType="dijit.form.Form" id="addSampleForm" jsId="addSampleForm">
  <div class="error">${flash.message}</div>
  <input type="hidden" value="${sampleInstance?.project}" name="project"/>
  <table>
    <tbody>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="name"><g:message code="sample.name.label" default="Name" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="name" value="${sampleInstance?.name}" dojoType="dijit.form.ValidationTextBox" regExp='[\\w]+' required="true" invalidMessage="Invalid Symbol or Space"/>
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
  <button dojoType="dijit.form.Button" type="submit">Add Sample</button>
</form>
