<div class="line">
  <div class="unit lastUnit">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:"show_stats_data", id:genomeInstance.accession)}" jsId="statsStore"
         query="{}"
         queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="statsGrid" jsId="statsGrid" style="height:450px" store="statsStore" rowsPerPage="25"
           sortInfo="-7"
           plugins="{
                    filter: {
                    itemsName : 'samples'
                    }
                    }"
           selectable="true"
           structure='[{cells:[
                      {field: "sname", name: "Sample", datatype: "string", width: "200px", formatter: capsid.grid.Formatter.prototype.links.sample},
                      {fields: ["plabel", "pname"], name: "Project", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.project},
                      {field: "hits", name:"Hits on Genomes", datatype: "number", width: "auto"},
                      {field: "geneHits", name:"Hits on Genes", datatype: "number", width: "auto"},
                      {field: "totalCoverage", name:"Genome Coverage", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverage", name:"Coverage Over Genes", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "maxCoverage", name:"Max Coverage", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {fields: ["accession", "sname"], name:"Links", datatype: "string", width: "200px", formatter: capsid.grid.Formatter.prototype.links.jbrowse}
                      ]}]'>
      </div>
    </div>
  </div>
</div>
