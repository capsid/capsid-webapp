<div class="line">
  <div class="unit lastUnit size1of1">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:'project_stats_data', id:genomeInstance.accession, params:[pid:projectInstance.label])}" jsId="statsStore"
         query="{}"
         queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="statsGrid" jsId="statsGrid" style="height:550px" store="statsStore"
           sortInfo="-7"
           plugins="{
                    filter: {
                    itemsName : 'samples'
                    }
                    }"
           selectable="true"
           structure='[{cells:[
                      {field: "sample", name: "Sample", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.sample},
                      {fields: ["label", "project"], name: "Project", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.project},
                      {field: "genomeHits", name:"Hits on Genomes", datatype: "number", width: "auto"},
                      {field: "geneHits", name:"Hits on Genes", datatype: "number", width: "auto"},
                      {field: "genomeCoverage", name:"Genome Coverage", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverageAvg", name:"Coverage Over Genes", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverageMax", name:"Max Coverage", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {fields: ["accession", "sample"], name:"Links", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.jbrowse}
                      ]}]'>
      </div>
    </div>
  </div>
</div>
