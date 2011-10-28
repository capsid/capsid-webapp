<%@ page import="grails.util.Environment" %>
<!doctype html>
<!--[if lt IE 7]> <html class="no-js ie6" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title><g:layoutTitle default="OICR"/>::CaPSID</title>
<link rel="shortcut icon" href="${resource(dir:'images', file:'favicon.ico')}">
<link href='http://fonts.googleapis.com/css?family=Syncopate' rel='stylesheet' type='text/css'>
<link href='http://fonts.googleapis.com/css?family=Gruppo' rel='stylesheet' type='text/css'>

<link rel="stylesheet" href="${resource(dir:'js/' + grailsApplication.config.js.dojo.path + '/dijit/themes/claro',file:'claro.css')}">
<link rel="stylesheet" href="${resource(dir:'js/' + grailsApplication.config.js.dojo.path + '/dojox/grid/enhanced/resources/claro',file:'EnhancedGrid.css')}">
<link rel="stylesheet" href="${resource(dir:'css/',file:'style.css')}">
<g:layoutHead />
</head>
<body class="claro">
<div id="wrap">
<header>
    <div class="line"> 
        <span id="title" class="unit size3of5">CaPSID<span id="version">v${grailsApplication.metadata.'app.version'}</span></span>
		<span class="unit lastUnit" id="account-links"> 
	        <sec:ifLoggedIn><span id="account-name"><a href="${createLink(controller:'user', action:'show')}/<sec:username/>"><sec:username/></a></span>
	        <span id="account-tabs">
		        <a href="${createLink(controller:"logout")}">Logout</a> 
	        </span>
            </sec:ifLoggedIn>
		</span>
    </div> 
</header>
<div id="container">
<g:render template="/layouts/navigation"/>
<g:layoutBody />
</div>
</div>
<footer>
<script>var baseUrl = "${grailsApplication.config.grails.serverURL}";</script>
<g:if test="${Environment.current==Environment.DEVELOPMENT}">
<script>var dojoConfig = {modulePaths : {'capsid': '../../capsid'}};</script>
</g:if>
<script type="text/javascript" src='${resource(dir:'js/' + grailsApplication.config.js.dojo.path + '/dojo/',file:'dojo.js')}' djConfig="parseOnLoad:true"></script>
<script type="text/javascript" src='${resource(dir:'js/' + grailsApplication.config.js.dojo.path + '/dijit/',file:'dijit.js')}' djConfig="parseOnLoad:true"></script>
<script src='${resource(dir:'js/' + grailsApplication.config.js.path + '/capsid/',file:'capsid.js')}'></script>
<p:renderDependantJavascript />
</footer>
</body>
</html>
