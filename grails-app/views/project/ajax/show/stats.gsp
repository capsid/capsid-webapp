<div class="line">
  <div class="unit lastUnit">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:'show_stats_data', id:projectInstance.label)}" jsId="statStore"
         query="{}"
         queryOptions="{'deep':true}">
    </div>
    <div dojoType="dojox.grid.EnhancedGrid" id="statsGrid" jsId="statsGrid" style="height:450px" store="statStore" rowsPerPage="25"
         sortInfo="-7"
         plugins="{
                  filter: true
                  }"
         selectable="true"
         structure='[{cells:[
                    {field: "accession", name: "Accession", datatype: "string", width: "100px", formatter: capsid.grid.Formatter.prototype.links.genome},
                    {field: "gname", name: "Genome", datatype: "string", width: "auto"},
                    {field: "hits", name:"Hits on Genomes", datatype: "number", width: "100px"},
                    {field: "geneHits", name:"Hits on Genes", datatype: "number", width: "100px"},
                    {field: "totalCoverage", name:"Genome Coverage", datatype: "number", width: "100px", formatter: capsid.grid.Formatter.prototype.math.percent},
                    {field: "geneCoverage", name:"Average Gene Coverage", datatype: "number", width: "100px", formatter: capsid.grid.Formatter.prototype.math.percent},
                    {field: "maxCoverage", name:"Max Gene Coverage", datatype: "number", width: "100px", formatter: capsid.grid.Formatter.prototype.math.percent},
                    {field: "accession", name:"Links", datatype: "string", width: "150px", formatter: capsid.grid.Formatter.prototype.links.genomeDetails}
                    ]}]'>
    </div>
  </div>
</div>
