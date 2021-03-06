<%@ page import="ca.on.oicr.capsid.Project" %>
<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="bootstrap">
		<g:set var="entityName" value="${message(code: 'project.label', default: 'Project')}" />
		<title>Editing ${projectInstance.name}</title>
	</head>
	<body>
		<div class="row-fluid">
			<div class="content">
			<section>
				<div class="page-header">
					<h1>Edit ${projectInstance.name} <small>Edit Project Attributes</small></h1>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>

				<g:hasErrors bean="${projectInstance}">
				<bootstrap:alert class="alert-error">
				<ul>
					<g:eachError bean="${projectInstance}" var="error">
					<li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message error="${error}"/></li>
					</g:eachError>
				</ul>
				</bootstrap:alert>
				</g:hasErrors>

				<fieldset>
					<g:form class="form-horizontal" action="update" id="${projectInstance?.label}" >
						<g:hiddenField name="version" value="${projectInstance?.version}" />
						<g:hiddenField name="label" id="label" value="${projectInstance?.label}" />
						<fieldset>
							<f:all bean="projectInstance"/>
							<div class="control-group ">
								<label for="label" class="control-label">Security</label>
								<div class="controls">
									<g:set var="is_private" value="${!('ROLE_CAPSID' in projectInstance.roles)}" />
									<g:hiddenField name="is_private" id="is_private" value="${is_private}" />
									
									<div class="btn-group" data-toggle="buttons-radio" data-toggle-name="is_private">
										<button rel="tooltip" title="Your project will only be visable to users that are given access" type="button" value="true" class="btn"><i class="icon-lock"></i> Private</button>
										<button rel="tooltip" title="Project will be visable to all CaPSID users" type="button" value="false" class="btn"><i class="icon-eye-open"></i> Public</button>
									</div>
								</div>
							</div>
							<div class="form-actions" style="border-radius:0; border:none;">
								<button type="submit" class="btn btn-success">
									<i class="icon-ok icon-white"></i>
									<g:message code="default.button.update.label" default="Update" />
								</button>
								<g:link action="show" id="${projectInstance.label}" class="btn">Cancel</g:link>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
			</section>
			<auth:ifAnyGranted access="[(projectInstance.label):['owner']]">
			<section id="uac">
				<div class="page-header">
					<h1>Edit Permissions <small>Change User Access Levels</small></h1>
				</div>
				<div class="row-fluid">
					<div id="accordion" class="accordion" style="width:768px">
				        <div class="accordion-group">
				          <div class="accordion-heading">
				            <a href="#owners" data-parent="#accordion" data-toggle="collapse" class="accordion-toggle">
				              Owners Group
				            </a>
				          </div>
				          <div class="accordion-body in" id="owners" style="height: auto;">
				            <div class="accordion-inner">
				            	<div class="row-fluid">
				                  	<div class="span6">
					            		<div class="alert alert-info">
					            			<strong>Owners</strong> have full access to the project, which includes the ability to give permission for others users to access the project, and to remove the project and all associated data entirely from the platform.
					            		</div>
					            	</div>
					            	<div class="span6">
					            		<div class="user-list">
						            		<g:each var="userRoleInstance" in="${userRoles.findAll{it.access=='owner'}}">
							            		<g:render template="/project/user" model="['username':userRoleInstance.user.username,'label':projectInstance.label]"/>
						            		</g:each>
						            	</div>
										<g:form autocomplete="off" controller="user" action="promote" id="${projectInstance.label}" params="['access':'owner']" class="well well-small form-search" >
									    	<input type="text" class="search-query" placeholder="Search for users..." name="username" data-provide="typeahead" data-source='${unassignedUsers}'/>
									    	<button class="btn btn-success pull-right" type="submit">Add User</button>
									    </g:form>
					            	</div>
				            	</div>
				            </div>
				          </div>
				        </div>
				        <div class="accordion-group">
				          <div class="accordion-heading">
				            <a href="#collaborators" data-parent="#accordion" data-toggle="collapse" class="accordion-toggle">
				              Collaborators Group
				            </a>
				          </div>
				          <div class="accordion-body collapse" id="collaborators" style="height: 0px;">
				            <div class="accordion-inner">
				            	<div class="row-fluid">
					            	<div class="span6">
					            		<div class="alert alert-info">
					            			<strong>Collaborators</strong> have permission to add, edit and remove samples
					            		</div>
					            	</div>
					            	<div class="span6">
					            		<div class="user-list">
						            		<g:each var="userRoleInstance" in="${userRoles.findAll{it.access=='collaborator'}}">
						            			<g:render template="/project/user" model="['username':userRoleInstance.user.username,'label':projectInstance.label]"/>
						            		</g:each>
						            	</div>
										<g:form autocomplete="off" controller="user" action="promote" id="${projectInstance.label}" params="['access':'collaborator']" class="well well-small form-search" >
									    	<input type="text" class="search-query" placeholder="Search for users..." name="username" data-provide="typeahead" data-source='${unassignedUsers}'/>
									    	<button class="btn btn-success pull-right" type="submit">Add User</button>
									    </g:form>
					            	</div>
				            	</div>
				            </div>
				          </div>
				        </div>
				        <div class="accordion-group">
				          <div class="accordion-heading">
				            <a href="#users" data-parent="#accordion" data-toggle="collapse" class="accordion-toggle">
				              Users Group
				            </a>
				          </div>
				          <div class="accordion-body collapse" id="users" style="height: 0px;">
				            <div class="accordion-inner">
				            	<div class="row-fluid">
					            	<div class="span6">
					            		<div class="alert alert-info">
					            			<strong>Users</strong> have read-only access to projects
					            		</div>
					            	</div>
					            	<div class="span6">
					            		<div class="user-list">
						            		<g:each var="userRoleInstance" in="${userRoles.findAll{it.access=='user'}}">
						            			<g:render template="/project/user" model="['username':userRoleInstance.user.username,'label':projectInstance.label]"/>
						            		</g:each>
						            	</div>
										<g:form autocomplete="off" controller="user" action="promote" id="${projectInstance.label}" params="['access':'user']" class="well well-small form-search" >
									    	<input type="text" class="search-query" placeholder="Search for users..." name="username" data-provide="typeahead" data-source='${unassignedUsers}'/>
									    	<button class="btn btn-success pull-right" type="submit">Add User</button>
									    </g:form>
					            	</div>
				            	</div>
				            </div>
				          </div>
				        </div>
				    </div>
				</div>
			</section>
			<section>
				<div class="page-header">
					<h1>Delete Project</h1>
				</div>
				<div class="row-fluid">
					<div class="span alert alert-danger">Deleting this project <i>(${projectInstance.name})</i> will also delete all samples, alignments and mapped reads associated with it.</div>
				</div>
				<fieldset>
					<form class="form-horizontal">
						<fieldset>
							<div class="form-actions">
								<button type="button" class="btn btn-danger" data-target="#delete" data-toggle="modal">
									<i class="icon-trash icon-white"></i>
									<g:message code="default.button.delete.label" default="Delete" />
								</button>
							</div>
						</fieldset>
					</form>
				</fieldset>
				<div class="modal hide" id="delete" style="display: none;">
					<div class="modal-header">
		            <a data-dismiss="modal" class="close">×</a>
		            <h3>Delete Project</h3>
		            </div>
		            <div class="modal-body">
		            	<div class="alert alert-danger">Deleting this project <i>(${projectInstance.name})</i> will also delete all samples, alignments and mapped reads associated with it.<br/><br/>Deleting a project is permanent, please be certain before continuing.<br/></div>	
		            </div>
				    <div class="modal-footer">
						<g:form action="update" id="${projectInstance?.label}" >
							<g:hiddenField name="version" value="${projectInstance?.version}" />
							<a data-dismiss="modal" class="btn" href="#">Close</a>
							<button type="submit" class="btn btn-danger" name="_action_delete" formnovalidate>
								<i class="icon-trash icon-white"></i>
								<g:message code="default.button.delete.label" default="Delete" />
							</button>
						</g:form>
					</div>
				</div>
			</section>
			</auth:ifAnyGranted>
			</div>
		</div>
	</body>
</html>
