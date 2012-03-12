<% import grails.persistence.Event %>
<%=packageName%>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="\${message(code: '${domainClass.propertyName}.label', default: '${className}')}" />
		<r:require module="visualsearch"/>
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div>
				<div class="row-fluid page-header">
					<div class="span9">
						<h1><g:message code="default.list.label" args="[entityName]" /></h1>
					</div>
					<auth:ifCapsidAdmin>
					<div class="pull-right">
						<g:link class="btn btn-primary" action="create">
							<i class="icon-plus icon-white"></i>
							<g:message code="default.button.create.label" default="Create" />
						</g:link>
					</div>
					</auth:ifCapsidAdmin>
				</div>
				<g:if test="\${flash.message}">
				<bootstrap:alert class="alert-info">\${flash.message}</bootstrap:alert>
				</g:if>

				<div class="visual_search" style="height:32px;"></div>
				<div id="results">
					<div id="table">
						<table class="table table-striped table-condensed">
							<thead>
								<tr>
								<%  excludedProps = Event.allEvents.toList() << 'id' << 'version'
									allowedNames = domainClass.persistentProperties*.name << 'dateCreated' << 'lastUpdated'
									props = domainClass.properties.findAll { allowedNames.contains(it.name) && !excludedProps.contains(it.name) && it.type != null && !Collection.isAssignableFrom(it.type) }
									Collections.sort(props, comparator.constructors[0].newInstance([domainClass] as Object[]))
									props.eachWithIndex { p, i ->
										if (i < 6) {
											if (p.isAssociation()) { %>
									<th class="header"><g:message code="${domainClass.propertyName}.${p.name}.label" default="${p.naturalName}" /></th>
								<%      } else { %>
									<g:sortableColumn property="${p.name}" title="\${message(code: '${domainClass.propertyName}.${p.name}.label', default: '${p.naturalName}')}" />
								<%  }   }   } %>
								</tr>
							</thead>
							<tbody>
							<g:each in="\${${propertyName}List}" var="${propertyName}">
								<tr>
								<%  props.eachWithIndex { p, i ->
								        if (i < 6) {
											if (p.type == Boolean || p.type == boolean) { %>
									<td><g:formatBoolean boolean="\${${propertyName}.${p.name}}" /></td>
								<%          } else if (p.type == Date || p.type == java.sql.Date || p.type == java.sql.Time || p.type == Calendar) { %>
									<td><g:formatDate date="\${${propertyName}.${p.name}}" /></td>
								<%          } else { %>
									<td>\${fieldValue(bean: ${propertyName}, field: "${p.name}")}</td>
								<%  }   }   } %>
									<td class="link">
										    <div class="btn-group pull-right">
											    <g:link action="show" id="\${${propertyName}.id}" class="btn btn-small"><i class="icon-chevron-right"></i> Show</g:link>
											    <auth:ifAnyGranted access="[(${propertyName}.label):['collaborator', 'owner']]">
											    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
											    <span class="caret"></span>
											    </a>
											    <ul class="dropdown-menu">
											    	<li><g:link action="show" id="\${${propertyName}.label}"><i class="icon-chevron-right"></i> Show</g:link></li>
											    	<li><g:link action="edit" id="\${${propertyName}.label}"><i class="icon-pencil"></i> Edit</g:link></li>
												</ul>
												</auth:ifAnyGranted>
										    </div>
									</td>
								</tr>
							</g:each>
							</tbody>
						</table>
						<div class="pagination">
							<bootstrap:paginate total="\${${propertyName}Total}" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
