<%@ page import="ca.on.oicr.capsid.Alignment" %>
<form action="${createLink(controller:'alignment', action:'save')}" method="post" dojoType="dijit.form.Form" id="addAlignForm" jsId="addAlignForm">
  <div class="error">${flash.message}</div>
  <input type="hidden" name="project" value="${alignmentInstance?.project}"/>
  <table>
    <tbody>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="name"><g:message code="alignment.name.label" default="Name" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField jsID="aname" id="aname" name="name" value="${alignmentInstance?.name}" dojoType="dijit.form.ValidationTextBox" regExp='[\\w]+' required="true" invalidMessage="Invalid Symbol or Space."/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="sample"><g:message code="alignment.sample.label" default="Sample" /></label>
        </td>
        <td valign="top" class="value">
          <g:select name="sample" dojoType="dijit.form.Select" style="width:165px;" value="${alignmentInstance?.sample?.name}" from="${sampleList}" optionKey="name" optionValue="name"/>
        </td>
      </tr>
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
          <label for="infile"><g:message code="alignment.infile.label" default="Input file location" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="infile" value="${alignmentInstance?.infile}" dojoType="dijit.form.Textarea"/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="outfile"><g:message code="alignment.outfile.label" default="Output file location" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="outfile" value="${alignmentInstance?.outfile}" dojoType="dijit.form.Textarea"/>
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
  <button dojoType="dijit.form.Button" name="addAlignSubmit" type="submit">Add Alignment</button>
</form>