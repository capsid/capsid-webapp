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
        <input type="hidden" id="id" value="${fieldValue(bean: projectInstance, field: "id")}"/>
        <input type="hidden" id="label" value="${fieldValue(bean: projectInstance, field: "label")}"/>
        <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
        <h1>Project Details</h1>
        <div class="line">
            <g:form action="save" method="get" dojoType="dijit.form.Form" id="createForm" jsId="createForm" class="unit size1of2" style="margin-bottom: 25px;">
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
                                <label for="Private"><g:message code="project.private.label" default="Private" /></label>
                            </td>
                            <td valign="top" class="value">
                                <input id="private" name="private" dojoType="dijit.form.CheckBox" value="agreed"/>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </g:form>
        </div>
        <div class="line">
            <h1>Access Control</h1>
            <div dojoType="dijit.layout.TabContainer" style="width: 50%;" doLayout="false"
            tabPosition="left-h" tabStrip="true" parseOnLoad="true">
                <div dojoType="dijit.layout.ContentPane" title="Owners">
                    <div class="line">
                        <div class="user-box-wrap unit size1of2">
                            <g:each var="admin" in="${userInstanceList * 3}">
                                <div class="user-box">
                                    <g:link controller="user" action="show" id="${admin.username}">${admin.username}</g:link>
                                    <g:link controller="user" action="demote" id="${admin.username}" params="[pid:projectInstance.label, role:'admin']" class="delete"></g:link>
                                    <g:link controller="user" action="show" id="${admin.username}" params="[pid:projectInstance.label, role:'admin']" class="edit"></g:link>
                                </div>
                            </g:each>
                            <g:select style="width: 80%; float:left; margin:5px 0;" dojoType="dijit.form.ComboBox" id="admin-users" name="admin-users" from="${User.list()}" noSelection="${['null':'Find user...']}" optionValue="username" optionKey="username" />
                            <button class="unit right" id="add-admin" dojoType="dijit.form.Button" type="button">Add</button>
                        </div>
                        <div class="dialog lastUnit">
                            <h3>Owners</h3>
                            <p>
                                All the power
                            </p>
                        </div>
                    </div>
                </div>
                <div dojoType="dijit.layout.ContentPane" title="Collaborators">
                    <div class="line">
                        <div class="user-box-wrap unit size1of2">
                            <g:each var="admin" in="${userInstanceList * 5}">
                                <div class="user-box">
                                    <g:link controller="user" action="show" id="${admin.username}">${admin.username}</g:link>
                                    <g:link controller="user" action="demote" id="${admin.username}" params="[pid:projectInstance.label, role:'admin']" class="delete"></g:link>
                                    <g:link controller="user" action="show" id="${admin.username}" params="[pid:projectInstance.label, role:'admin']" class="edit"></g:link>
                                </div>
                            </g:each>
                            <g:select style="width: 80%; float:left; margin:5px 0;" dojoType="dijit.form.ComboBox" id="collab-users" name="collab-users" from="${User.list()}" noSelection="${['null':'Find user...']}" optionValue="username" optionKey="username" />
                            <button class="unit right" id="add-collab" dojoType="dijit.form.Button" type="button">Add</button>
                        </div>
                        <div class="dialog lastUnit">
                            <h3>Collaborators</h3>
                            <p>
                                some power
                            </p>
                        </div>
                    </div>
                </div>
                <div dojoType="dijit.layout.ContentPane" title="Users">
                    <div class="line">
                        <div class="user-box-wrap unit size1of2">
                            <g:each var="admin" in="${userInstanceList * 13}">
                                <div class="user-box">
                                    <g:link controller="user" action="show" id="${admin.username}">${admin.username}</g:link>
                                    <g:link controller="user" action="demote" id="${admin.username}" params="[pid:projectInstance.label, role:'admin']" class="delete"></g:link>
                                    <g:link controller="user" action="show" id="${admin.username}" params="[pid:projectInstance.label, role:'admin']" class="edit"></g:link>
                                </div>
                            </g:each>
                            <g:select style="width: 80%; float:left; margin:5px 0;" dojoType="dijit.form.ComboBox" id="user-users" name="user-users" from="${User.list()}" noSelection="${['null':'Find user...']}" optionValue="username" optionKey="username" />
                            <button class="unit right" id="add-user" dojoType="dijit.form.Button" type="button">Add</button>
                        </div>
                        <div class="dialog lastUnit">
                            <h3>Users</h3>
                            <p>
                                No power
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
