<div class="line">
  <div class="unit lastUnit">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url='${createLink(action:"show_stats_data", id:sampleInstance.name)}' jsId="statStore"
         query="{}"
         queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="statsGrid" jsId="statsGrid" style="height:550px" store="statStore"
           sortInfo="-7"
           plugins="{
                    pagination: {
                      pageSizes: ['25', '50', '100', '250']
                    },
                    filter: true
                    }"
           selectable="true"
           structure='[{cells:[
                      {field: "accession", name: "Accession", datatype: "string", width: "100px", formatter: capsid.grid.Formatter.prototype.links.genome},
                      {field: "genome", name: "Genome", datatype: "string", width: "auto"},
                      {field: "genomeHits", name:"Hits on Genomes", datatype: "number", width: "100px"},
                      {field: "geneHits", name:"Hits on Genes", datatype: "number", width: "100px"},
                      {field: "genomeCoverage", name:"Genome Coverage", datatype: "number", width: "100px", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverageAvg", name:"Average Gene Coverage", datatype: "number", width: "100px", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverageMax", name:"Max Gene Coverage", datatype: "number", width: "100px", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {fields: ["accession", "sample"], name:"Links", datatype: "string", width: "150px", formatter: capsid.grid.Formatter.prototype.links.jbrowse}
                      ]}]'>
      </div>
    </div>
  </div>
</div>