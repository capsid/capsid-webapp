<%@ page import="ca.on.oicr.capsid.Project" %>
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
        <div class="line">
            <div class="unit">
                <h1>${projectInstance.name}</h1>
                <div class="subheader">${projectInstance.description}</div>
                <g:if test="${projectInstance.wikiLink}"><a href="wikisomewhere/${projectInstance.wikiLink}">Wiki Link</a></g:if>
            </div>

            <auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'admin']]">
            <div id="admin-nav" class="unit right">
                <g:set var="menuItems" value="[['controller':'project', 'action':'edit', 'id': projectInstance.label, 'params': '[:]', 'name':'Edit Project'],
                                            ['controller':'sample', 'action': 'create', 'id': '', 'params': '[project: projectInstance.label]', 'name':'Add Sample'],
                                            ['controller':'alignment', 'action': 'create', 'id': '', 'params': '[project: projectInstance.label]', 'name':'Add Alignment']]"/>
                <g:each var="item" in="${menuItems}">
                <span class="item unit"><g:link controller="${item.controller}" action="${item.action}" id="${item.id}" params="${item.params}">${item.name}</g:link></span>
                </g:each>
            </div>
            </auth:ifAnyGranted>
        </div>
        <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="true" persist="true">
            <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_stats", id:projectInstance.label)}" rel="Statistics" title="Stats"></div>
            <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_samples", id:projectInstance.label)}" rel="Samples" title="Samples"></div>
            <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_alignments", id:projectInstance.label)}" rel="Alignments" title="Alignments"></div>
        </div>
    </body>
</html>
