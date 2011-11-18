<%@ page import="ca.on.oicr.capsid.Mapped" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<g:set var="genome" value="${Genome.get(mappedInstance.genomeId)}"/>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'mapped.label', default: 'Mapped')}" />
    <title><g:message code="default.show.label" args="[entityName]" /></title>
  </head>
  <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <h1>${mappedInstance.readId}</h1>
    <div class="line">
      <div class="dialog unit size1of3">
        <table>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name">Project</td>
              <td valign="top" class="value">
                <g:link controller="project" action="show" id="${mappedInstance.project}">${Project.findByLabel(mappedInstance.project).name}</g:link>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Sample</td>
              <td valign="top" class="value">
                <g:link controller="sample" action="show" id="${mappedInstance.sample}">${mappedInstance.sample}</g:link>
              </td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Genome</td>
              <td valign="top" class="value"><g:link controller="genome" action="show" id="${genome.accession}">${genome.name}</g:link></td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Accession</td>
              <td valign="top" class="value"><g:link controller="genome" action="show" id="${genome.accession}">${genome.accession.replace("_"," ")}</g:link></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </body>
</html>
