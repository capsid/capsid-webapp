<div class="line">
    <div class="unit lastUnit size1of1">
        <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
        </g:if>
        <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:"show_alignments_data", id:projectInstance.label)}" jsId="alignStore" clearOnClose="true"
             query="{}"
             queryOptions="{'deep':true}">
        </div>
        <div class="list">
            <div dojoType="dojox.grid.EnhancedGrid" id="alignGrid" jsId="alignGrid" style="height:450px" store="alignStore" rowsPerPage="25" clearOnClose="true"
                 sortInfo="1"
                 plugins="{
                     pagination: true,
                     filter: {
                             itemsName : 'alignments'
                             }
                     }"
                 selectable="true">
              
            </div>
                 structure='[{cells:[
                             {field: "name", name:"Read Name", datatype: "string", autoComplete: true, width: "auto" }
                        ,    {field: "aligner", name:"Aligner", datatype: "string", autoComplete: true, width: "150px" }
                        ,    {field: "platform", name:"Platform", datatype: "string", width: "150px"}
                        ,    {field: "sample", name:"Sample", datatype: "string", autoComplete: true, width: "150px", formatter: capsid.grid.Formatter.prototype.links.sample}
                        ,    {field: "type", name:"Type", datatype: "string", width: "100px"}
                        ,    {field: "infile", name:"InFile", datatype: "string", filterable: false, width: "auto"}
                        ,    {field: "outfile", name:"OutFile", datatype: "string", filterable: false, width: "auto"}
                        ]}]'>
            </div>
           </div>
    </div>
</div>
