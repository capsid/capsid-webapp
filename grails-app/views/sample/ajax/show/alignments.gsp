<div class="line">
  <div class="unit lastUnit">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url='${createLink(action:"show_alignments_data", id:sampleInstance.name)}' jsId="alignStore" clearOnClose="true" query="{}" queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="alignGrid" jsId="alignGrid" style="height:550px" store="alignStore" sortInfo="1"
           plugins="{
                    pagination: {
                      pageSizes: ['25', '50', '100', '250']
                    },
                    filter: {
                    itemsName : 'alignments'
                    }
                    }"
           selectable="true"
           structure='[{cells:[
                      {field: "name", name:"Read Name", datatype: "string", autoComplete: true, width: "auto", formatter: capsid.grid.Formatter.prototype.links.alignment}
                      ,	{field: "aligner", name:"Aligner", datatype: "string", autoComplete: true, width: "150px" }
                      ,	{field: "platform", name:"Platform", datatype: "string", autoComplete: true, width: "150px" }
                      ,	{field: "type", name:"Type", datatype: "string", width: "100px"}
                      ,	{field: "infile", name:"InFile", datatype: "string", filterable: false, width: "auto"}
                      ,	{field: "outfile", name:"OutFile", datatype: "string", filterable: false, width: "auto"}
                      ]}]'>
      </div>
    </div>
  </div>
</div>
