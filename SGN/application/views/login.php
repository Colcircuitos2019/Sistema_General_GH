<!DOCTYPE html>
<html lang="en">
<head>
	<title>Login V15</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!--===============================================================================================-->	
	<link rel="icon" type="image/png" href="<?= base_url();?>assets/login/images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/vendor/bootstrap/css/bootstrap.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/fonts/font-awesome-4.7.0/css/font-awesome.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/fonts/Linearicons-Free-v1.0.0/icon-font.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/vendor/animate/animate.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/vendor/css-hamburgers/hamburgers.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/vendor/animsition/css/animsition.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/vendor/select2/select2.min.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/vendor/daterangepicker/daterangepicker.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/css/util.css">
	<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/login/css/main.css">
<!--===============================================================================================-->
</head>
<body onload="nobackbutton();">
	<div class="limiter">
		<div class="container-login100">
			<div class="wrap-login100">
				<div class="login100-form-title" style="background-image: url(<?php echo base_url();?>assets/login/images/bg-01.jpg);">
					<span class="login100-form-title-1">
						Sistema General de Gestión Humana
					</span>
				</div>
				<!-- action="<?php //echo base_url();?>cLogin/iniciarSession1" -->
				<form  method="POST" class="login100-form validate-form" id="iniciar">
					<div class="wrap-input100 validate-input m-b-26" data-validate="Requiere nombre de usuario">
						<span class="label-input100">Usuario</span>
						<input class="input100" id="user" type="text" name="username" placeholder="Ingrese nombre de usuario">
						<span class="focus-input100"></span>
					</div>

					<div class="wrap-input100 validate-input m-b-18" data-validate = "requiere contraseña">
						<span class="label-input100">Contraseña</span>
						<input class="input100" id="contraseña" type="password" name="pass" placeholder="Ingrese contraseña">
						<span class="focus-input100"></span>
					</div>

					<div class="flex-sb-m w-full p-b-30">

					</div>

					<div class="container-login100-form-btn">
						<button type="submit" class="login100-form-btn">
							Ingresar
						</button>
						<!-- <input type="submit" name="Enviar" class="btn btn-primary"> -->

				   <div class="btn-group pull-right">
                      <!-- <button type="button" class="btn btn-link">User</button> -->
                      <button class="btn btn-link dropdown-toggle" data-toggle="dropdown">
                       <span class="caret"></span>
                      </button>
                     <ul class="dropdown-menu" role="menu">
                       <li><STRONG>User:</STRONG> Empleado</li>
                       <li><STRONG>Cont:</STRONG> 123</li>
                     </ul>
                   </div>

					</div>
				</form>
				<div><button type="button" id="btnClausulas" class="pull-right" style="background: none; outline: none; margin: 8px;"><span><i class="fas fa-question-circle"></i></span></button></div>
			</div>
		</div>
	</div>
	
<!--===============================================================================================-->
	<script src="<?= base_url();?>assets/login/vendor/jquery/jquery-3.2.1.min.js"></script>
<!--===============================================================================================-->
	<script src="<?= base_url();?>assets/login/vendor/animsition/js/animsition.min.js"></script>
<!--===============================================================================================-->
	<script src="<?= base_url();?>assets/login/vendor/bootstrap/js/popper.js"></script>
	<script src="<?= base_url();?>assets/login/vendor/bootstrap/js/bootstrap.min.js"></script>
<!--===============================================================================================-->
	<script src="<?= base_url();?>assets/login/vendor/select2/select2.min.js"></script>
<!--===============================================================================================-->
	<script src="<?= base_url();?>assets/login/vendor/daterangepicker/moment.min.js"></script>
	<script src="<?= base_url();?>assets/login/vendor/daterangepicker/daterangepicker.js"></script>
<!--===============================================================================================-->
	<!-- <script src="<?php //echo base_url();?>assets/login/vendor/countdowntime/countdowntime.js"></script> -->
<!--===============================================================================================-->
	<script src="<?= base_url();?>assets/login/js/main.js"></script>
<!--===============================================================================================-->
	<script src="<?= base_url();?>js/Login/login.js"></script>
<!--===============================================================================================-->	
	<script type="text/javascript">
		//Pendiente encriptar la base url
		var baseurl= '<?php echo base_url();?>';
	</script>
<!-- sweet alert -->
	<script src="<?= base_url();?>js/sweetalert2.all.js"></script>
	<!-- Font Awesome -->
<script src="<?= base_url();?>img/js/fontawesome-all.js"></script>	

</body>
</html>