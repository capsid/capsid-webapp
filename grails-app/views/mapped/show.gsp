<%@ page import="ca.on.oicr.capsid.Mapped" %>
<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.Genome" %>
<%@ page import="ca.on.oicr.capsid.Feature" %>
<g:set var="genome" value="${Genome.findByGi(mappedInstance.genome as int)}"/>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="layout" content="main" />
    <g:set var="entityName" value="${message(code: 'mapped.label', default: 'Mapped')}" />
    <title>${mappedInstance.readId}</title>
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
              <td valign="top" class="name">Alignment</td>
              <td valign="top" class="value">
                <g:link controller="alignment" action="show" id="${mappedInstance.alignment}">${mappedInstance.alignment}</g:link>
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
            <g:if test="${mappedInstance.alignScore}">
            <tr class="prop">
              <td valign="top" class="name">Alignment Score</td>
              <td valign="top" class="value">${mappedInstance.alignScore}</td>
            </tr>
            </g:if>
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
              <td valign="top" class="name">Maps to Gene(s)</td>
              <td valign="top" class="value">
              <g:each in="${mappedInstance.mapsGene}">
                <a target="_blank" href="http://www.ncbi.nlm.nih.gov/gene/${it}">
                  ${Feature.collection.findOne('type': 'gene', 'geneId': it)?.name}
                </a>
              </g:each>
              </td>
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
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_alignment', id:mappedInstance.id)}" rel="Genomes" title="Alignment" errorMessage="<span class='dijitContentPaneError'>Alignment data for this read not found in database.</span>"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_fasta', id:mappedInstance.id)}" rel="Genomes" title="FASTA Sequence"></div>
      <div dojoType="dijit.layout.ContentPane" href="${createLink(action:'show_reads', id:mappedInstance.id)}" rel="Genomes" title="Hits on other Genomes"></div>
   </div>
  </body>
</html>
