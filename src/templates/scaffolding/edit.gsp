<%=packageName%>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="\${message(code: '${domainClass.propertyName}.label', default: '${className}')}" />
		<title><g:message code="default.edit.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
			<section>
				<div class="page-header">
					<h1>Edit \${${propertyName}.name} <small>Edit ${className} Attributes</small></h1>
				</div>

				<g:if test="\${flash.message}">
				<bootstrap:alert class="alert-info">\${flash.message}</bootstrap:alert>
				</g:if>

				<g:hasErrors bean="\${${propertyName}}">
				<bootstrap:alert class="alert-error">
				<ul>
					<g:eachError bean="\${${propertyName}}" var="error">
					<li <g:if test="\${error in org.springframework.validation.FieldError}">data-field-id="\${error.field}"</g:if>><g:message error="\${error}"/></li>
					</g:eachError>
				</ul>
				</bootstrap:alert>
				</g:hasErrors>

				<fieldset>
					<g:form class="form-horizontal" action="update" id="\${${propertyName}?.label}" <%= multiPart ? ' enctype="multipart/form-data"' : '' %>>
						<g:hiddenField name="version" value="\${${propertyName}?.version}" />
						<fieldset>
							<f:all bean="${propertyName}"/>
							<div class="form-actions" style="border-radius:0; border:none;">
								<button type="submit" class="btn btn-success">
									<i class="icon-ok icon-white"></i>
									<g:message code="default.button.update.label" default="Update" />
								</button>
								<g:link action="show" id="\${${propertyName}?.name}" class="btn">Cancel</g:link>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
			</section>
			<section>
				<div class="page-header">
					<h1>Delete ${className}</h1>
				</div>
				<div class="row-fluid">
					<div class="span alert alert-danger">Deleting this ${className} <i>(\${${propertyName}?.name})</i> will also delete all mapped reads associated with it.</div>
				</div>
				<fieldset>
					<form class="form-horizontal">
						<fieldset>
							<div class="form-actions">
								<button type="button" class="btn btn-danger" data-target="#myModal" data-toggle="modal">
									<i class="icon-trash icon-white"></i>
									<g:message code="default.button.delete.label" default="Delete" />
								</button>
							</div>
						</fieldset>
					</form>
				</fieldset>
				<div class="modal hide" id="myModal" style="display: none;">
					<div class="modal-header">
		            <a data-dismiss="modal" class="close">×</a>
		            <h3>Delete ${className}</h3>
		            </div>
		            <div class="modal-body">
		            	<div class="alert alert-danger">Deleting this ${className} <i>(\${${propertyName}?.name})</i> will also delete all mapped reads associated with it.<br/><br/>Deleting a ${className} is permanent, please be certain before continuing.<br/></div>	
		            </div>
				    <div class="modal-footer">
						<g:form action="update" id="\${${propertyName}??.name}" >
							<g:hiddenField name="version" value="\${${propertyName}??.name}" />
							<button type="submit" class="btn btn-danger" name="_action_delete" formnovalidate>
								<i class="icon-trash icon-white"></i>
								<g:message code="default.button.delete.label" default="Delete" />
							</button>
							<a data-dismiss="modal" class="btn" href="#">Close</a>
						</g:form>
					</div>
				</div>
			</section>
			</div>
		</div>
	</body>
</html>
