<%@ page import="ca.on.oicr.capsid.User" %>
<form action="save" method="post" dojoType="dijit.form.Form" id="addUserForm" jsId="addUserForm">
  <div class="error">${flash.message}</div>
  <table>
    <tbody>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="username"><g:message code="user.username.label" default="Username" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="username" value="${userInstance?.username}" dojoType="dijit.form.TextBox"/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="userRealName"><g:message code="user.userRealName.label" default="Full Name" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="userRealName" value="${userInstance?.userRealName}" dojoType="dijit.form.TextBox"/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="email"><g:message code="user.email.label" default="Email Address" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="email" value="${userInstance?.email}" dojoType="dijit.form.TextBox"/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="institute"><g:message code="user.institute.label" default="Institute" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="institute" value="${userInstance?.institute}" dojoType="dijit.form.TextBox"/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="location"><g:message code="user.location.label" default="Location" /></label>
        </td>
        <td valign="top" class="value">
          <g:textField name="location" value="${userInstance?.location}" dojoType="dijit.form.TextBox"/>
        </td>
      </tr>
      <tr class="prop">
        <td valign="top" class="name">
          <label for="admin"><g:message code="user.admin.label" default="CaPSID Admin" /></label>
        </td>
        <td valign="top" class="value">
          <g:checkBox name="admin" value="${admin}"/>
        </td>
      </tr>
    </tbody>
  </table>
  <button dojoType="dijit.form.Button" type="submit">Add User</button>
</form>
