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
    <div class="line">
      <div class="unit">
        <h1>${userInstance.username}</h1>
      </div>
      <div class="unit right">
        <a href="${createLink(action:'edit', id:userInstance.username)}" style="font-weight:normal;color:#333;">
          <button data-dojo-type="dijit.form.Button" id="editButton" jsId="editButton">Edit User</button>
        </a>
      </div>
    </div>
    <div class="line">
      <div class="dialog unit size1of3">
        <table>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name">Full Name</td>
              <td valign="top" class="value">${userInstance.userRealName}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Email Address</td>
              <td valign="top" class="value">${userInstance.email}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Institute</td>
              <td valign="top" class="value">${userInstance.institute}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Location</td>
              <td valign="top" class="value">${userInstance.location}</td>
            </tr>
            <auth:ifAnyGranted access="[('capsid'):['owner']]">
              <tr class="prop">
                <td valign="top" class="name">Enabled</td>
                <td valign="top" class="value">${userInstance.enabled}</td>
              </tr>
              <tr class="prop">
                <td valign="top" class="name">Admin</td>
                <td valign="top" class="value">${admin}</td>
              </tr>
            </auth:ifAnyGranted>
          </tbody>
        </table>
      </div>
    </div>
  </body>
</html>
