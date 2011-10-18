<div class="line">
    <div class="unit lastUnit">
        <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
        </g:if>
        <div dojoType="dojox.data.AndOrReadStore" url="${createLink(action:"show_alignments_data", id:sampleInstance.id)}" jsId="alignStore"
        	 query="{}" 
			 queryOptions="{'deep':true}">
		</div>
        <div class="list">
			<div dojoType="dojox.grid.EnhancedGrid" id="alignsGrid" jsId="alignsGrid" style="height:450px" store="alignStore" rowsPerPage="25"
				 sortInfo="1"
				 plugins="{
				 	pagination: true, 
				 	filter: {
					 		itemsName : 'alignments'
					 		}
				 	}"
				 selectable="true"
				 structure='[{cells:[
					    	{field: "name", name:"Read Name", datatype: "string", autoComplete: true, width: "auto" }
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
