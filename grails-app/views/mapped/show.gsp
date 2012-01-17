<%@ page import="ca.on.oicr.capsid.Mapped" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<g:set var="genome" value="${Genome.findByGi(mappedInstance.genome as int)}"/>
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
                <g:link controller="sample" action="show" id="${mappedInstance.sample}">${mappedInstance.sample.replace("_"," ")}</g:link>
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
            <tr class="prop">
              <td valign="top" class="name">Score</td>
              <td valign="top" class="value">${mappedInstance.mapq}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Min Quality</td>
              <td valign="top" class="value">${mappedInstance.minQual}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Avg Quality</td>
              <td valign="top" class="value">${mappedInstance.avgQual}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Mismatch</td>
              <td valign="top" class="value">${mappedInstance.mismatch}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Miscalls</td>
              <td valign="top" class="value">${mappedInstance.miscalls}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Ref Strand</td>
              <td valign="top" class="value">${mappedInstance.refStrand}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Ref Start</td>
              <td valign="top" class="value">${mappedInstance.refStart}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Ref End</td>
              <td valign="top" class="value">${mappedInstance.refEnd}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Read Length</td>
              <td valign="top" class="value">${mappedInstance.readLength}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Alignment Length</td>
              <td valign="top" class="value">${mappedInstance.alignLength}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Sequencing Type</td>
              <td valign="top" class="value">${mappedInstance.sequencingType}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Platform</td>
              <td valign="top" class="value">${mappedInstance.platform}</td>
            </tr>
            <tr class="prop">
              <td valign="top" class="name">Maps to a Gene</td>
              <td valign="top" class="value">${mappedInstance.mapsGene?'True':'False'}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="unit size1of3 hidden">
        <h2>Analysis</h2>
        <ul class="links">
          <li>BLAST</li>
          <li>Contig</li>
        </ul>
      </div>
    </div>
    <div dojoType="dijit.layout.TabContainer" style="width: 100%;" doLayout="false" tabStrip="false" persist="true">
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_fasta', id:mappedInstance.id)}" rel="Genomes" title="FASTA Sequence"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_alignment', id:mappedInstance.id)}" rel="Genomes" title="Alignment" errorMessage="<span class='dijitContentPaneError'>Genome Sequence not found in Database.</span>"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_reads', id:mappedInstance.id)}" rel="Genomes" title="Hits on other Genomes"></div>
   </div>
  </body>
</html>
