<%@ page import="ca.on.oicr.capsid.Genome" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
    <title>${genomeInstance.accession}</title>
  </head>
  <body>
    <input type="hidden" id="id" value="${fieldValue(bean: genomeInstance, field: "id")}"/>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
      <div class="unit lastUnit">
        <h1>${genomeInstance.name.replaceAll("_"," ")} (${genomeInstance.accession.replaceAll("_"," ")})</h1>
        <div class="subheader">${genomeInstance.taxonomy.join(', ')}</div>
      </div>
    </div>
    <div class="line">
      <div class="dialog unit size1of3">
        <table>
          <tbody>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="genome.organism.label" default="Organism" /></td>
              <td valign="top" class="value">${fieldValue(bean: genomeInstance, field: "organism")}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="genome.gi.label" default="GI" /></td>
              <td valign="top" class="value">${genomeInstance.gi}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="genome.version.label" default="version" /></td>
              <td valign="top" class="value">${fieldValue(bean: genomeInstance, field: "version")}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name"><g:message code="genome.length.label" default="Length" /></td>
              <td valign="top" class="value">${fieldValue(bean: genomeInstance, field: "length")}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="unit size1of5">
        <ul class="links">
          <li><a href="http://www.ncbi.nlm.nih.gov/nuccore/${genomeInstance.accession}" target="_blank">NCBI Nucleotide DB</a></li>
          <g:if test="${genomeInstance.organism == 'Homo sapiens'}">
            <li><a href="http://www.ncbi.nlm.nih.gov/mapview/maps.cgi?taxid=9606&chr=${genomeInstance.name.minus('chr')}" target="_blank">NCBI Map Viewer</a></li>
          </g:if>
          <li><a href="http://www.ncbi.nlm.nih.gov/sites/gquery?term=${genomeInstance.accession}" target="_blank">Search NCBI</a></li>
          <li><g:link controller="jbrowse" action="show" id="${genomeInstance.accession}">Map with jBrowse</g:link></li>
        </ul>
      </div>
    </div>
    <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="false" persist="true">
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_project_stats', id:genomeInstance.accession)}" rel="PStatistics" title="Project Statistics"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_sample_stats', id:genomeInstance.accession)}" rel="SStatistics" title="Sample Statistics"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_features', id:genomeInstance.accession)}" rel="Features" title="Features"></div>
   </div>
  </body>
</html>
