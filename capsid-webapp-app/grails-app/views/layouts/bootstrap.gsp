<%@ page import="org.codehaus.groovy.grails.web.servlet.GrailsApplicationAttributes" %>
<%@ page import="ca.on.oicr.capsid.User" %>
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title><g:layoutTitle default="${meta(name: 'app.name')}"/></title>
		<meta name="description" content="">
		<meta name="author" content="">

		<meta name="viewport" content="initial-scale = 1.0">
		<!-- HTML5 shim, for IE6-8 support of HTML elements -->
		<!--[if lt IE 9]>
			<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->

		<link href='http://fonts.googleapis.com/css?family=Ubuntu' rel='stylesheet' type='text/css'>
		
		<r:require modules="capsid"/>
		<!-- fav and touch icons -->
		<nav:resources override="true"/>
		<g:layoutHead/> 
		<r:layoutResources/>
	</head>
	
	<body>
		<nav class="navbar">
			<div class="navbar-inner">
				<div class="container-fluid">		
					<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</a>
					
					<a class="brand" href="${createLink(uri: '/')}">CaPSIDv${grailsApplication.metadata.'app.version'}</a>
					
					<sec:ifLoggedIn>
					<g:set var="user" value="${User.findByUsername(sec?.username())}" />
					<div class="modal hide fade" id="add-bookmark-modal" style="display: none;">
				        <div class="modal-header">
				          <a data-dismiss="modal" class="close">×</a>
				          <h3>Add Bookmark</h3>
				        </div>
				        <g:form controller="user" action="add_bookmark" id="${sec.username()}" class="form-horizontal" style="margin:0">
					        <fieldset>
						    
				        	<div class="modal-body">
			        	    	<div class="control-group ">
									<label class="control-label" for="title">Title</label>
									<div class="controls">
										<input type="text" name="title" value="" required="" id="title">
									</div>
								</div>
								<div class="control-group ">
									<label class="control-label" for="address">Address</label>
									<div class="controls">
										<input type="text" name="address" value="" required="" id="address">
									</div>
								</div>
						    </div>
						        <div class="modal-footer">
					              <a href="#" class="btn" data-dismiss="modal">Close</a>
					              <button type="submit" class="btn btn-success"><i class="icon-ok icon-white"></i> Save</button>
					            </div>
			        		</fieldset>
						</g:form>
				    </div>		
					<div class="nav-collapse">
						<ul class="nav">		
							<li class="divider-vertical"></li>
							<nav:eachItem var="item" group="project">
								<li class="${controllerName==item.controller?'active':''}">
									<g:link controller="${item.controller}" action="${item.action}">${item.title}</g:link>
								</li>
							</nav:eachItem>
							<nav:eachItem var="item" group="sample">
								<li class="${controllerName==item.controller?'active':''}">
									<g:link controller="${item.controller}" action="${item.action}">${item.title}</g:link>
								</li>
							</nav:eachItem>
							<li class="divider-vertical"></li>
							<li class="dropdown">
								<a data-toggle="dropdown" class="dropdown-toggle" href="#">Bookmarks <b class="caret"></b></a>
					            <ul class="dropdown-menu" id="bookmarks">
					                <li>
						                <a href="#" data-target="#add-bookmark-modal" data-toggle="modal" id="add-bookmark"><i class="icon-plus"></i> Add Bookmark</a>
									</li>
					                <li><g:link controller="user" action="show" id="${sec.username()}"><i class="icon-book"></i> Organize Bookmarks</g:link></li>
					                <li class="divider"></li>
					                <g:each var="bookmark" in="${user?.bookmarks ?: []}">
					                	<li><a href="${bookmark['address']}"><i class="icon-bookmark"></i> ${bookmark['title']}</a></li>
					            	</g:each>
					            </ul>
							</li>					
							<li class="divider-vertical"></li>
						</ul>

						<ul class="nav pull-right">
							<li><span class="capsid-username">${sec.username()}</span></li>
							<li class="divider-vertical"></li>
							<li><g:link controller="user" action="edit" id="${sec.username()}" rel="tooltip" title="Account Settings" data-placement="bottom"><i class="icon-pencil nav-icon"></i></g:link></li>
							<auth:ifCapsidAdmin>
			                <li><g:link controller="user" action="list" rel="tooltip" title="Administration" data-placement="bottom"><i class="icon-cog nav-icon"></i></g:link></li>
			                </auth:ifCapsidAdmin>
			                <li><g:link controller="logout" action="index" rel="tooltip" title="Log Out" data-placement="bottom"><i class="icon-share-alt nav-icon"></i></g:link></li>
						</ul>
					</div>
					</sec:ifLoggedIn>

					<sec:ifNotLoggedIn>
					<div class="nav-collapse">
						<ul class="nav pull-right">
							<li class="divider-vertical"></li>							
							<li><g:link controller="login" action="auth">Login</g:link></li>
						</ul>
					</div>
					</sec:ifNotLoggedIn>
				</div>
			</div>
		</nav>

		<div class="container-fluid">
			<g:layoutBody/>
		</div>
		<r:layoutResources/>
	</body>
</html>
