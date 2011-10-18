<%@ page import="ca.on.oicr.capsid.Genome" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'genome.label', default: 'Genome')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>
    <body>
    <g:if test="${flash.message}"><div class="message">${flash.message}</div></g:if>
    <div class="line">
        <div class="unit lastUnit">
            <h1>Genomes</h1>
        </div>
    </div>
    <div dojoType="dojox.data.AndOrReadStore" url="list_data/" idAttribute="id" jsId="store" query="{}"></div>
	<div dojoType="dojox.grid.EnhancedGrid" id="genomeGrid" jsId="genomeGrid" style="height:450px" store="store"
          	 sortInfo="-6"
      		 plugins="{
			 	pagination: true, 
			 	filter: {
			 		itemsName : 'genomes'
			 		}
			 	}"			 	
			selectable="true"
		 	structure='[{cells:[
			    	{field: "accession", name: "Accession", datatype: "string", width: "100px", formatter: capsid.grid.Formatter.prototype.links.genome}
			    ,	{field: "name", name: "Name", datatype: "string", width: "auto"}
			    ,  	{field: "gi", name: "GI", datatype: "string", width: "150px"}
			    ,	{field: "taxonomy", name: "Taxonomy", datatype: "string", width: "auto"}
			    ,	{field: "length", name: "Length", datatype: "number", width: "100px"}
			    ,	{field: "samples", name: "Samples", datatype: "number", width: "100px"}
				]}]'>
	</div>
    </body>
</html>
