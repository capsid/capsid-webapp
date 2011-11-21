<div class="line">
  <div class="unit lastUnit">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url='${createLink(action:"show_reads_data", id:mappedInstance.id)}' jsId="readsStore" clearOnClose="true" query="{}" queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="readsGrid" jsId="readsGrid" style="height:450px" store="readsStore" rowsPerPage="25" sortInfo="1"
           plugins="{
                    pagination: true,
                    filter: {
                    itemsName : 'Genomes'
                    }
                    }"
           selectable="true"
           structure='[{cells:[
                      {field: "accession", name:"Accession", datatype: "string", autoComplete: true, width: "150px", formatter: capsid.grid.Formatter.prototype.links.genome}
                      ,	{field: "gname", name:"Genome", datatype: "string", autoComplete: true, width: "auto" }
                      ,	{field: "refStart", name:"Start", datatype: "string", width: "100px"}
                      ,	{field: "refEnd", name:"End", datatype: "string", width: "100px"}
                      ,	{field: "id", name:"Links", datatype: "string", filterable: false, width: "150px", formatter: capsid.grid.Formatter.prototype.links.mapped}
                      ]}]'>
      </div>
    </div>
  </div>
</div>
