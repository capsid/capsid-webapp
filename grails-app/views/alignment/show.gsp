<%@ page import="ca.on.oicr.capsid.Alignment" %>
<%@ page import="ca.on.oicr.capsid.Sample" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'alignment.label', default: 'Alignment')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
      <div class="unit">
        <h1>${alignmentInstance.name}</h1>
      </div>
      <auth:ifAnyGranted access="[(alignmentInstance.project):['collaborator', 'admin']]">
        <div class="unit right">
          <span id="edit-wrap"><button data-dojo-type="dijit.form.Button" jsId="editButton" id="/alignment/edit/${alignmentInstance.name}">Edit Alignment</button></span>
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
                <g:link controller="project" action="show" id="${alignmentInstance.project}">${Project.findByLabel(alignmentInstance.project).name}</g:link>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Sample</td>
              <td valign="top" class="value">
                <g:link controller="sample" action="show" id="${alignmentInstance.sample}">${alignmentInstance.sample}</g:link>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Aligner</td>
              <td valign="top" class="value">${alignmentInstance.aligner}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Platform</td>
              <td valign="top" class="value">${alignmentInstance.platform}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Input File Location</td>
              <td valign="top" class="value">${alignmentInstance.infile}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Output File Location</td>
              <td valign="top" class="value">${alignmentInstance.outfile}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Type</td>
              <td valign="top" class="value">${alignmentInstance.type}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </body>
</html>
