<div class="line">
    <div class="unit lastUnit size1of1">
        <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
        </g:if>
        <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:"show_samples_data", id:projectInstance.name)}" jsId="sampleStore"
             query="{}"
             queryOptions="{'deep':true}">
        </div>
        <div class="list">
            <div dojoType="dojox.grid.EnhancedGrid" id="samplesGrid" jsId="samplesGrid" style="height:450px" store="sampleStore" rowsPerPage="25"
                 sortInfo="1"
                 plugins="{
                     pagination: true,
                     filter: {
                             itemsName : 'samples'
                             }
                     }"
                 selectable="true"
                 structure='[{cells:[
                        {field: "name", name: "Name", datatype: "string", autoComplete: true, width: "auto", formatter: capsid.grid.Formatter.prototype.links.sample},
                        {field: "description", name: "Description", datatype: "string", width: "auto"},
                        {field: "cancer", name: "Cancer", datatype: "string", autoComplete: true, width: "auto"},
                        {field: "source", name: "Source", datatype: "string", autoComplete: true, width: "150px"},
                        {field: "role", name: "Role", datatype: "string", autoComplete: true, width: "150px"}
                        ]}]'>
            </div>
           </div>
    </div>
</div>
