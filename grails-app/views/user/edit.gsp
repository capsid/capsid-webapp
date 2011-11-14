<%@ page import="ca.on.oicr.capsid.User" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'user.label', default: 'User')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <h1>${userInstance.username}</h1>
    <div class="line">
      <g:form action="update" method="post" id="${userInstance.username}" dojoType="dijit.form.Form" class="unit size1of2">
        <g:hiddenField name="username" value="${userInstance.username}" />
        <table>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name">
                <label for="userRealName"><g:message code="user.userRealName.label" default="Name" /></label>
              </td>
              <td valign="top" class="value">
                <g:textField name="userRealName" dojoType="dijit.form.TextBox" value="${userInstance.userRealName}"/>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
              <label for="email"><g:message code="user.email.label" default="Email" /></label></td>
              <td valign="top" class="value">
              <g:textField name="email" dojoType="dijit.form.TextBox" value="${userInstance.email}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
              <label for="institute"><g:message code="user.institute.label" default="Institute" /></label></td>
              <td valign="top" class="value">
              <g:textField name="institute" dojoType="dijit.form.TextBox" value="${userInstance.institute}"/></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">
              <label for="location"><g:message code="user.location.label" default="Location" /></label></td>
              <td valign="top" class="value">
              <g:textField name="location" dojoType="dijit.form.TextBox" value="${userInstance.location}"/></td>
            </tr>
            <auth:ifAnyGranted access="[('capsid'):['owner']]">
              <tr class="prop">
                <td valign="top" class="name">
                <label for="enabled"><g:message code="user.enabled.label" default="Enabled" /></label></td>
                <td valign="top" class="value"><g:checkBox name="enabled" value="${userInstance.enabled}"/></td>
              </tr>
              <tr class="prop">
                <td valign="top" class="name">
                <label for="admin"><g:message code="user.admin.label" default="Admin" /></label></td>
                <td valign="top" class="value">
                <g:checkBox name="admin" value="${admin}"/></td>
              </tr>
            </auth:ifAnyGranted>
          </tbody>
        </table>
        <button dojoType="dijit.form.Button" type="submit">Update User</button>
      </g:form>
    </div>
    <auth:ifAnyGranted access="[('capsid'):['owner']]">
      <div class="line">
        <h1 style="margin-top:20px;color:red">Delete User</h1>
        <div class="errors unit size1of3">
          <div class="unit size1of2">
            Delete the user
          </div>
          <div class="unit size1of2">
            <g:form action="delete" method="post" dojoType="dijit.form.Form" id="${userInstance.username}">
              <button type="submit" dojoType="dijit.form.Button">Delete User</button>
            </g:form>
          </div>
        </div>
      </div>
    </auth:ifAnyGranted>
  </body>
</html>
