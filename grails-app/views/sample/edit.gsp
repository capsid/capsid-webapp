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
  </body>
</html>
