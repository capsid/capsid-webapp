<div class="line">
  <div class="unit lastUnit size1of1">
    <g:if test="${flash.message}">
      <div class="message">${flash.message}</div>
    </g:if>
    <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:"show_features_data", id:genomeInstance.accession)}" jsId="featureStore"
         query="{}"
         queryOptions="{'deep':true}">
    </div>
    <div class="list">
      <div dojoType="dojox.grid.EnhancedGrid" id="featuresGrid" jsId="featuresGrid" style="height:550px" store="featureStore" rowsPerPage="25"
           sortInfo="1"
           plugins="{
                    pagination: {
                      pageSizes: ['25', '50', '100', '250']
                    },
                    filter: {
                    itemsName : 'features'
                    }
                    }"
           selectable="true"
           structure='[{cells:[
                      {field: "name", name:"Name", datatype: "string", autoComplete: true, width: "auto"},
                      {field: "locusTag", name:"Locus Tag", datatype: "string", autoComplete: true, width: "auto"},
                      {field: "geneId", name:"Gene Id", datatype: "string", autoComplete: true, width: "auto"},
                      {field: "type", name:"Type", datatype: "string", autoComplete: true, width: "auto"},
                      {field: "start", name:"Start", datatype: "number", width: "auto"},
                      {field: "stop", name:"Stop", datatype: "number", width: "auto"},
                      {field: "length", name:"Length", datatype: "number", width: "auto"}
                      ]}]'>
      </div>
    </div>
  </div>
</div>