<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
    <title>${projectInstance.name}</title>
  </head>
  <body>
    <g:hiddenField name="label" value="${projectInstance.label}"/>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
      <div class="unit">
        <h1>${projectInstance.name}</h1>
        <div class="subheader">${projectInstance.description}</div>
        <g:if test="${projectInstance.wikiLink}"><a href="${projectInstance.wikiLink}">Wiki Link</a></g:if>
      </div>
      <auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'owner']]">
        <div class="unit right">
          <span id="edit-wrap"><button data-dojo-type="dijit.form.Button" jsId="editButton" id="/project/edit/${projectInstance.label}">Edit Project</button></span>
          <button data-dojo-type="dijit.form.Button" id="addSampleButton" jsId="addSampleButton">Add Sample</button>
          <div style="display:none" href="${createLink(controller:'sample', action:'create', id:projectInstance.label)}" id="addSampleDialog" jsId="addSampleDialog" dojoType="dijit.Dialog" title="Add Sample" refreshOnShow="true"></div>
          <span id="alignhide" style="display:${Sample.countByProject(projectInstance.label)?'inline':'none'}">
            <button data-dojo-type="dijit.form.Button" id="addAlignButton" jsId="addAlignButton">Add Alignment</button>
          </span>
          <div style="display:none" href="${createLink(controller:'alignment', action:'create', id:projectInstance.label)}" id="addAlignDialog" jsId="addAlignDialog" dojoType="dijit.Dialog" title="Add Alignment" refreshOnShow="true"></div>
        </div>
      </auth:ifAnyGranted>
    </div>
    <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="true" persist="true" jsID="tabs">
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_stats', id:projectInstance.label)}" rel="Statistics" title="Stats"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_samples', id:projectInstance.label)}" rel="Samples" title="Samples"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_alignments', id:projectInstance.label)}" rel="Alignments" title="Alignments"></div>
    </div>
  </body>
</html>
