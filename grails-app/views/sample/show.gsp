<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
      <div class="unit">
        <h1>${sampleInstance.name}</h1>
        <div class="subheader">${fieldValue(bean: sampleInstance, field: "description")}</div>
      </div>
      <auth:ifAnyGranted access="[(sampleInstance.project):['collaborator', 'admin']]">
        <div class="unit right">
          <span id="edit-wrap"><button data-dojo-type="dijit.form.Button" jsId="editButton" id="/sample/edit/${sampleInstance.name}">Edit Sample</button></span>
          <button data-dojo-type="dijit.form.Button" id="addAlignButton" jsId="addAlignButton">Add Alignment</button>
          <div style="display:none" href="${createLink(controller:'alignment', action:'create', id:sampleInstance.name)}" id="addAlignDialog" jsId="addAlignDialog" dojoType="dijit.Dialog" title="Add Alignment" refreshOnShow="true"></div>
        </div>
      </auth:ifAnyGranted>
    </div>
  <div class="line">
    <div class="dialog unit size1of3">
      <table>
        <tbody>
          <tr class="prop">
            <td valign="top" class="name">Project</td>
            <td valign="top" class="value">
              <g:link controller="project" action="show" id="${sampleInstance.project}">${Project.findByLabel(sampleInstance.project).name}</g:link>
            </td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name" >Role</td>
            <td valign="top" class="value">${sampleInstance.role}</td>
          </tr>
          <tr class="prop">
            <td valign="top" class="name">Source</td>
            <td valign="top" class="value">${sampleInstance.source}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
    <div class="line">
      <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="true" persist="true">
        <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_stats", id:sampleInstance.name)}" rel="Statistics" title="Stats"></div>
        <div dojoType="dijit.layout.ContentPane" href="${createLink(action:"show_alignments", id:sampleInstance.name)}" rel="Alignments" title="Alignments"></div>
      </div>
    </div>
  </body>
</html>
