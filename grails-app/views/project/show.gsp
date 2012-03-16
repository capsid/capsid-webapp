
<%@ page import="ca.on.oicr.capsid.Project" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title><g:message code="default.show.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid use_sidebar">
			<div class="span sidebar">
				<div class="span well well-small">	
					<ul class="nav nav-list">
						<li class="nav-header">Samples</li>
						<input class="search-query span2" placeholder="Filter Samples" type="text" id="sample_filter">
						<li>
							<g:link controller="sample" action="create">
								<i class="icon-plus"></i>
								Add Sample
							</g:link>
						</li>
						<g:each in="${projectInstance['samples']}" var="sampleInstance">
						<li rel="popover" data-placement="right" data-content="${sampleInstance.description}<br><strong>Cancer: </strong>${sampleInstance.cancer}<br><strong>Role: </strong>${sampleInstance.role}<br><strong>Source: </strong>${sampleInstance.source}" data-title="${sampleInstance.name}">
							<g:link controller="sample" action="show" id="${sampleInstance.name}">
								<i class="icon-folder-open"></i>
								${sampleInstance.name}
							</g:link>
						</li>
						</g:each>
					</ul>
				</div>
				<div class="span well well-small separator"></div>
			</div>
			<div class="main">
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:fieldValue bean="${projectInstance}" field="name"/><br>
						<small><g:fieldValue bean="${projectInstance}" field="description"/></small>
						</h1>
						<a href="${projectInstance.wikiLink}" target="_blank">${projectInstance.wikiLink}</a>
					</div>
					<auth:ifAnyGranted access="[(projectInstance.label):['collaborator', 'owner']]">
					<g:form class="pull-right">
						<g:hiddenField name="id" value="${projectInstance?.label}" />
						<div>
							<g:link class="btn" action="edit" id="${projectInstance?.label}">
								<i class="icon-pencil"></i>
								<g:message code="default.button.edit.label" default="Edit" />
							</g:link>
						</div>
					</g:form>
					</auth:ifAnyGranted>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>





















<div id="results">
					<div id="table">
						<table class="table table-striped table-condensed">
							<thead>
								<tr>
									<th class="sortable"><a href="/capsid/sample/list?sort=name&amp;max=15&amp;order=asc">Name</a></th>
									<th class="sortable"><a href="/capsid/sample/list?sort=project&amp;max=15&amp;order=asc">Project</a></th>
									<th class="sortable"><a href="/capsid/sample/list?sort=description&amp;max=15&amp;order=asc">Description</a></th>
									<th class="sortable"><a href="/capsid/sample/list?sort=cancer&amp;max=15&amp;order=asc">Cancer</a></th>
									<th class="sortable"><a href="/capsid/sample/list?sort=role&amp;max=15&amp;order=asc">Role</a></th>								
									<th class="sortable"><a href="/capsid/sample/list?sort=source&amp;max=15&amp;order=asc">Source</a></th>
								</tr>
							</thead>
							<tbody>
							
								<tr>
								
									<td><a href="/capsid/sample/show/simulated">simulated</a></td>
									<td><a href="/capsid/project/show/simulated">simulated</a></td>
									<td>singl-end</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>P</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0003">OVCA0003</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OVCAR-429 from Gordon Mills</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0005">OVCA0005</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OVCAR-5 from Gordon Mills</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0006">OVCA0006</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OVCAR-8 from Gordon Mills</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0004">OVCA0004</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OVCAR-432 from Gordon Mills</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0016">OVCA0016</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0002">OVCA0002</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OV-1369 from Anne Marie Mes-Masson</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0007">OVCA0007</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OVCAR-433 from Gordon Mills</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0008">OVCA0008</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line SKOV-3 from Anne Marie Mes-Masson</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0009">OVCA0009</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line TOV-1946 from Anne Marie Mes-Masson</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0010">OVCA0010</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OV-1946 from Anne Marie Mes-Masson</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0011">OVCA0011</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line OVCAR-3 from Gordon Mills</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0001">OVCA0001</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line TOV-1369_TR from Anne Marie Mes-Masso</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0013">OVCA0013</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
								<tr>
								
									<td><a href="/capsid/sample/show/OVCA0012">OVCA0012</a></td>
									<td><a href="/capsid/project/show/ova">Ovarian OICR</a></td>
									<td>Cell line</td>
									<td>Ovarian</td>
									<td>CASE</td>
									<td>C</td>
								</tr>
							
							</tbody>
						</table>
						<div class="pagination">
							<ul><li class="disabled"><a title="Previous" class="prevLink" href="/capsid/sample/list?offset=-15&amp;max=15"><i class="icon-chevron-left"></i></a></li><li class="active"><a class="step" href="/capsid/sample/list?offset=0&amp;max=15">1</a></li><li><a class="step" href="/capsid/sample/list?offset=15&amp;max=15">2</a></li><li><a class="step" href="/capsid/sample/list?offset=30&amp;max=15">3</a></li><li><a class="step" href="/capsid/sample/list?offset=45&amp;max=15">4</a></li><li><a class="step" href="/capsid/sample/list?offset=60&amp;max=15">5</a></li><li><a class="step" href="/capsid/sample/list?offset=75&amp;max=15">6</a></li><li><a class="step" href="/capsid/sample/list?offset=90&amp;max=15">7</a></li><li><a class="step" href="/capsid/sample/list?offset=105&amp;max=15">8</a></li><li><a title="Next" class="nextLink" href="/capsid/sample/list?offset=15&amp;max=15"><i class="icon-chevron-right"></i></a></li></ul><div style="line-height:34px" class="pull-right">Showing <strong>1</strong> to <strong>15</strong> of <strong>111</strong> </div>
						</div>
					</div>
				</div>


























			</div>
		</div>
	</body>
</html>
