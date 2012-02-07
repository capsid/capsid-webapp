<div class="line">
  <div class="unit lastUnit">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:"show_project_stats_data", id:genomeInstance.accession)}" jsId="pstatsStore"
         query="{}"
         queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="pstatsGrid" jsId="pstatsGrid" style="height:550px" store="pstatsStore" rowsPerPage="25"
           sortInfo="-7"
           plugins="{
                    filter: {
                    itemsName : 'projects'
                    }
                    }"
           selectable="true"
           structure='[{cells:[
                      {fields: ["label", "project"], name: "Project", datatype: "string", width: "auto", formatter: capsid.grid.Formatter.prototype.links.project},
                      {field: "genomeHits", name:"Hits on Genomes", datatype: "number", width: "auto"},
                      {field: "geneHits", name:"Hits on Genes", datatype: "number", width: "auto"},
                      {field: "genomeCoverage", name:"Genome Coverage", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverageAvg", name:"Coverage Over Genes", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {field: "geneCoverageMax", name:"Max Coverage", datatype: "number", width: "auto", formatter: capsid.grid.Formatter.prototype.math.percent},
                      {fields: ["accession", "label"], name:"Links", datatype: "string", width: "150px", formatter: capsid.grid.Formatter.prototype.links.genomeDetails}
                      ]}]'>
      </div>
    </div>
  </div>
</div>
