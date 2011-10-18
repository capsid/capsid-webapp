<head>
<meta name='layout' content='main' />
<title>Login</title>
<style type='text/css' media='screen'>
#loginModal {
display: block; width: 500px;
position: absolute; top: -1px; left: 50%;
margin-left: -250px;
padding: 30px 30px;
background: url("../images/gradient.jpg") repeat-x scroll 0 0 transparent;
-webkit-box-shadow: 0px 3px 6px rgba(0,0,0,0.25);
-moz-box-shadow: 0px 3px 6px rgba(0,0,0,0.25);
-webkit-border-bottom-left-radius: 6px;
-webkit-border-bottom-right-radius: 6px;
-moz-border-radius-bottomright: 6px;
-moz-border-radius-bottomleft: 6px;
}
#loginModal.show {
-webkit-transform: translateY(-80px);
-moz-transform: translatey(-80px);
}
#loginForm {
	border-top: 1px dashed #cdcdcd;
	padding-top: 10px;
}
#login form input {width: 90%;}
#loginButton {
	padding: 10px;
	margin-top: 10px;
	font-weight: bold;
	width: 100px;
	background: hsla(203,27%,50%,1.0);
	color: #fff;
	
	-moz-border-radius: 3px;
    -webkit-border-radius: 3px;
}
</style>
</head>

<body>
	<div id='loginModal'>
		<g:if test='${flash.message}'>
		<div style="width:450px; margin:0 auto 15px;" class="message errors">${flash.message}</div>
		</g:if>
		<h1>Please Login</h1>
		<form action='${postUrl}' method='POST' id='loginForm' autocomplete='off' class="line">
			<div class='line'>
				<div class="unit size1of2">
					<label for='username'>Login ID</label>
					<input type='text' class='text_' name='j_username' id='username' />
				</div>
				<div class="unit size1of2">
					<label for='password'>Password</label>
					<input type='password' class='text_' name='j_password' id='password' />
				</div>
			</div>
			<p class='line'>
				<button id="loginButton" type='submit'>Sign In</button>
			</p>
		</form>
	</div>
<script type='text/javascript'>
<!--
(function(){
	document.forms['loginForm'].elements['j_username'].focus();
})();
// -->
</script>
</body>
