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

		<r:require modules="scaffolding"/>

		<!-- Le fav and touch icons -->
		<link rel="shortcut icon" href="${resource(dir: 'images', file: 'favicon.ico')}" type="image/x-icon">
		<link rel="apple-touch-icon" sizes="72x72" href="${resource(dir: 'images', file: 'apple-touch-icon.png')}">
		<link rel="apple-touch-icon" sizes="114x114" href="${resource(dir: 'images', file: 'apple-touch-icon-114x114.png')}">
		<nav:resources override="true"/>
		<g:layoutHead/> 
		<r:layoutResources/>
	</head>

	<body>
		<nav class="navbar navbar-fixed-top">
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
							<nav:eachItem var="item" group="project">
								<li class="${item.active?'active':''}">
									<g:link controller="${item.controller}" action="${item.action}">${item.title}</g:link>
								</li>
							</nav:eachItem>
						</ul>
						<ul class="nav">							
							<li class="divider-vertical"></li>
							<nav:eachItem var="item" group="genome">
								<li class="${item.active?'active':''}">
									<g:link controller="${item.controller}" action="${item.action}">${item.title}</g:link>
								</li>
							</nav:eachItem>
						</ul>
						<ul class="nav pull-right">
							<li class="divider-vertical"></li>
							<li class="dropdown">
								<a data-toggle="dropdown" class="dropdown-toggle" href="#"><sec:username/> <b class="caret"></b></a>
					            <ul class="dropdown-menu">
					                <li><a href="#">Dashboard</a></li>
					                <li><g:link controller="user" action="edit">Edit Account</g:link></li>
					                <li class="divider"></li>
					                <li><g:link controller="logout" action="index">Logout</g:link></li>
					            </ul>
							</li>
						</ul>
					</div>
					</sec:ifLoggedIn>
					<sec:ifNotLoggedIn>
						<ul class="nav pull-right">
							<li class="divider-vertical"></li>							
							<li><g:link controller="login" action="auth">Login</g:link></li>
						</ul>
					</sec:ifNotLoggedIn>
				</div>
			</div>
		</nav>

		<div class="container-fluid">
			<g:layoutBody/>

			<hr>

			<footer>
				<p>&copy; Company 2011</p>
			</footer>
		</div>

		<r:layoutResources/>

	</body>
</html>
