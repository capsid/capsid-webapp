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
                <label for="institute"><g:message code="user.institute.label" default="Institute" /></label>
              </td>
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
        <g:link action="show" id="${userInstance.username}">Cancel Edit</g:link>
      </g:form>
    </div>
    <div style="margin:20px 0" class="line">
      <h1>Password</h1>
      <g:form action="changePassword" method="post" id="${userInstance.username}" dojoType="dijit.form.Form" class="unit size1of2" jsId="changepassForm">
        <table>
          <tr class="prop">
            <td valing="top" class="name">
              <label for="old">Password</label>
            </td>
            <td valign="top" class="value">
              <g:passwordField name="old" dojoType="dijit.form.ValidationTextBox" required="true" regExp=".{8,}" invalidMessage="Password must be at least 8 characters" value=""/>
            </td>
          </tr>
          <tr class="prop">
            <td valing="top" class="name">
              <label for="password">New Password</label>
            </td>
            <td valign="top" class="value">
              <g:passwordField name="password" dojoType="dijit.form.ValidationTextBox" required="true" regExp=".{8,}" jsId="password" invalidMessage="Password must be at least 8 characters" value=""/>
            </td>
          </tr>
          <tr class="prop">
            <td valing="top" class="name">
              <label for="confirm">Confirm</label>
            </td>
            <td valign="top" class="value">
              <g:passwordField name="confirm" dojoType="dijit.form.ValidationTextBox" required="true" regExp=".{8,}" jsId="confirm" invalidMessage="Password must be at least 8 characters" value=""/>
            </td>
          </tr>
        </table>
        <button id="changepassButton" dojoType="dijit.form.Button" type="submit">Change Password</button>
      </g:form>
    </div>

    <auth:ifAnyGranted access="[('capsid'):['owner']]">
      <div class="line">
        <h1 style="color:red">Delete User</h1>
        <div class="errors unit size1of3">
          <div class="unit size1of2">
            Deleting a user is permanent. <br>
            Please be certain before continuing.
          </div>
          <div class="unit size1of2">
            <g:form action="delete" method="post" dojoType="dijit.form.Form" id="${userInstance.username}">
              <button type="submit" style="color: #333;" dojoType="dijit.form.Button">Delete User</button>
            </g:form>
          </div>
        </div>
      </div>
    </auth:ifAnyGranted>
  </body>
</html>
