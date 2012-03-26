<%@ page import="org.codehaus.groovy.grails.web.servlet.GrailsApplicationAttributes" %>
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title><g:layoutTitle default="${meta(name: 'app.name')}"/></title>
		<meta name="description" content="">
		<meta name="author" content="">

		<meta name="viewport" content="initial-scale = 1.0">
		<!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
		<!--[if lt IE 9]>
			<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->

		<link href='hhttp://fonts.googleapis.com/css?family=Ubuntu' rel='stylesheet' type='text/css'>
		
		<r:require modules="capsid"/>
		<r:require module="visualsearch"/>
		<!-- fav and touch icons -->
		<link rel="shortcut icon" href="${resource(dir: 'images', file: 'favicon.ico')}" type="image/x-icon">
		<link rel="apple-touch-icon" sizes="72x72" href="${resource(dir: 'images', file: 'apple-touch-icon.png')}">
		<link rel="apple-touch-icon" sizes="114x114" href="${resource(dir: 'images', file: 'apple-touch-icon-114x114.png')}">
		<nav:resources override="true"/>
		<g:layoutHead/> 
		<r:layoutResources/>
	</head>

	<body>
		<div class="modal hide fade" id="bookmark" style="display: none;">
	        <div class="modal-header">
	          <a data-dismiss="modal" class="close">×</a>
	          <h3>Add Bookmark</h3>
	        </div>
	        <div class="modal-body">
	        	<g:form class="form-horizontal">
		        	<fieldset>
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
					</fieldset>
				</g:form>
	        </div>
	        <div class="modal-footer">
              <a href="#" class="btn" data-dismiss="modal">Close</a>
              <a href="#" class="btn btn-success"><i class="icon-ok icon-white"></i> Save</a>
            </div>
	    </div>
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
					
					<div class="nav-collapse">
						<ul class="nav">		
							<li class="divider-vertical"></li>
							<nav:eachItem var="item" group="project">
								<li class="${controllerName==item.controller?'active':''}">
									<g:link controller="${item.controller}" action="${item.action}">${item.title}</g:link>
								</li>
							</nav:eachItem>
							<li class="dropdown ${['genome','feature'].contains(controllerName)?'active':''}">
								<a data-toggle="dropdown" class="dropdown-toggle" href="#">Reference DB <b class="caret"></b></a>
					            <ul class="dropdown-menu">
							        <nav:eachItem var="item" group="genome">
										<li class="${controllerName==item.controller?'active':''}">
											<g:link controller="${item.controller}" action="${item.action}"><i class="icon-th-list"></i> ${item.title}</g:link>
										</li>
									</nav:eachItem>        
					            </ul>
							</li>					
							<li class="divider-vertical"></li>
							<li class="dropdown">
								<a data-toggle="dropdown" class="dropdown-toggle" href="#">Bookmarks <b class="caret"></b></a>
					            <ul class="dropdown-menu">
					                <li>
						                <a href="#" data-target="#bookmark" data-toggle="modal"><i class="icon-plus"></i> Add Bookmark</a>
									</li>
					                <auth:ifCapsidAdmin>
					                <li><g:link controller="user" action="show"><i class="icon-book"></i> Organize Bookmarks</g:link></li>
					                </auth:ifCapsidAdmin>
					                <li class="divider"></li>
					                <li><g:link controller="logout" action="index"><i class="icon-off"></i> Logout</g:link></li>
					            </ul>
							</li>					
							<li class="divider-vertical"></li>
						</ul>
					</div>

					<div class="nav-collapse">
						<ul class="nav pull-right">
							<li class="divider-vertical"></li>
							<li class="dropdown">
								<a data-toggle="dropdown" class="dropdown-toggle" href="#"><sec:username/> <b class="caret"></b></a>
					            <ul class="dropdown-menu">
					                <li><g:link controller="user" action="edit"><i class="icon-pencil"></i> Edit Account</g:link></li>
					                <auth:ifCapsidAdmin>
					                <li><g:link controller="user" action="list"><i class="icon-cog"></i> Administration</g:link></li>
					                </auth:ifCapsidAdmin>
					                <li class="divider"></li>
					                <li><g:link controller="logout" action="index"><i class="icon-off"></i> Logout</g:link></li>
					            </ul>
							</li>
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
