<div class="line">
    <div class="unit lastUnit size1of1">
        <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
        </g:if>
        <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:'show_samples_data', id:projectInstance.label)}" jsId="sampleStore" clearOnClose="true"
             query="{}"
             queryOptions="{'deep':true}">
        </div>
            <div dojoType="dojox.grid.EnhancedGrid" id="sampleGrid" jsId="sampleGrid" style="height:650px" store="sampleStore" rowsPerPage="25"
                 sortInfo="1"
                 plugins="{
                    pagination: {
                      pageSizes: ['25', '50', '100', '250']
                    },
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