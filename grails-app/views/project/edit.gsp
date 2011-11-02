<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.User" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body>
        <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
        <h1>Project Details</h1>
        <div class="line">
            <g:form action="update" method="post" dojoType="dijit.form.Form" id="${projectInstance.label}" class="unit size1of2" style="margin-bottom: 25px;">
                <input type="hidden" name="label" id="label" value="${fieldValue(bean: projectInstance, field: 'label')}"/>
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
                        </tr>
                        <tr class="prop">
                            <td valign="top" class="name">
                                <label for="description"><g:message code="project.description.label" default="Description" /></label>
                            </td>
                            <td valign="top" class="value">
                                <g:textArea name="description" value="${projectInstance?.description}" style="width:350px;" dojoType="dijit.form.Textarea"/>
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
                                <g:checkBox name="private" value="${!('ROLE_CAPSID' in projectInstance.roles)}"/>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <button type="submit" dojoType="dijit.form.Button" type="button">Submit</button>
            </g:form>
        </div>
        <auth:ifAnyGranted access="[(projectInstance.label):['admin']]">
        <div class="line">
            <h1>Access Control</h1>
            <div dojoType="dojo.data.ItemFileReadStore" jsId="userStore" url="../../user/unassigned/${projectInstance.label}" clearOnClose="true" urlPreventCache="true"></div>
            <div dojoType="dijit.layout.TabContainer" style="width: 50%;" doLayout="false"
            tabPosition="left-h" tabStrip="true" parseOnLoad="true" id="access-panel">
                <g:render template='/layouts/projectaccesspanel' model="[users:users, projectInstance:projectInstance, level: 'owner']"/>
                <g:render template='/layouts/projectaccesspanel' model="[users:users, projectInstance:projectInstance, level: 'collaborator']"/>
                <g:render template='/layouts/projectaccesspanel' model="[users:users, projectInstance:projectInstance, level: 'user']"/>
            </div>
        </div>
        </auth:ifAnyGranted>
    </body>
</html>
