<!DOCTYPE html>
<html lang="en">
    <head>
        <title>
            Asistencia
        </title>
        <meta charset="utf-8">
            <meta content="width=device-width, initial-scale=1" name="viewport">
                <!--===============================================================================================-->
                <link href="<?php echo base_url();?>assets/login/images/icons/favicon.ico" rel="icon" type="image/png"/>
                <!--===============================================================================================-->
                <link href="<?php echo base_url();?>assets/login/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css">
                    <!--===============================================================================================-->
                    <link href="<?php echo base_url();?>assets/login/fonts/font-awesome-4.7.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">
                        <!--===============================================================================================-->
                        <link href="<?php echo base_url();?>assets/login/fonts/Linearicons-Free-v1.0.0/icon-font.min.css" rel="stylesheet" type="text/css">
                            <!--===============================================================================================-->
                            <link href="<?php echo base_url();?>assets/login/vendor/animate/animate.css" rel="stylesheet" type="text/css">
                                <!--===============================================================================================-->
                                <link href="<?php echo base_url();?>assets/login/vendor/css-hamburgers/hamburgers.min.css" rel="stylesheet" type="text/css">
                                    <!--===============================================================================================-->
                                    <link href="<?php echo base_url();?>assets/login/vendor/animsition/css/animsition.min.css" rel="stylesheet" type="text/css">
                                        <!--===============================================================================================-->
                                        <link href="<?php echo base_url();?>assets/login/vendor/select2/select2.min.css" rel="stylesheet" type="text/css">
                                            <!--===============================================================================================-->
                                            <link href="<?php echo base_url();?>assets/login/vendor/daterangepicker/daterangepicker.css" rel="stylesheet" type="text/css">
                                                <!--===============================================================================================-->
                                                <link href="<?php echo base_url();?>assets/login/css/util.css" rel="stylesheet" type="text/css">
                                                    <link href="<?php echo base_url();?>assets/login/css/main.css" rel="stylesheet" type="text/css">
                                                        <!--===============================================================================================-->
                                                    </link>
                                                </link>
                                            </link>
                                        </link>
                                    </link>
                                </link>
                            </link>
                        </link>
                    </link>
                </link>
            </meta>
        </meta>
    </head>
    <body onload="nobackbutton();">
        <div class="limiter">
            <div class="container-login100">
                <div class="wrap-login100">
                    <div class="login100-form-title" style="background-image: url(<?php echo base_url();?>assets/login/images/bg-01.jpg); height: 1em;">
                        <span class="login100-form-title-1">
                            Asistencias
                        </span>
                    </div>
                    <div class="row">
                        <div class="col-md-11">
                            <label class="pull-right" style="margin: 7px; font-size: 20px;" id="horaServidor"></label>
                        </div>
                    </div>
                    <!-- action="<?php //echo base_url();?>cLogin/iniciarSession1" -->
                    <form class="login100-form validate-form" id="asistir" method="POST">
                        <div class="wrap-input100 validate-input m-b-26" data-validate="Requiere contraseña">
                            <span class="label-input100">
                                Contraseña:
                            </span>
                            <input class="input100" id="contra" maxlength="4" name="contraseña" placeholder="****" type="password">
                                <span class="focus-input100">
                                </span>
                            </input>
                        </div>
                        <div class="flex-sb-m w-full p-b-30">
                        </div>
                        <div class="container-login100-form-btn">
                            <button class="login100-form-btn pull-right" type="submit">
                                Asistencia
                            </button>
                            <!-- <input type="submit" name="Enviar" class="btn btn-primary"> -->
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <!--===============================================================================================-->
        <script src="<?php echo base_url();?>assets/login/vendor/jquery/jquery-3.2.1.min.js">
        </script>
        <!--===============================================================================================-->
        <script src="<?php echo base_url();?>assets/login/vendor/animsition/js/animsition.min.js">
        </script>
        <!--===============================================================================================-->
        <script src="<?php echo base_url();?>assets/login/vendor/bootstrap/js/popper.js">
        </script>
        <script src="<?php echo base_url();?>assets/login/vendor/bootstrap/js/bootstrap.min.js">
        </script>
        <!--===============================================================================================-->
        <script src="<?php echo base_url();?>assets/login/vendor/select2/select2.min.js">
        </script>
        <!--===============================================================================================-->
        <script src="<?php echo base_url();?>assets/login/vendor/daterangepicker/moment.min.js">
        </script>
        <script src="<?php echo base_url();?>assets/login/vendor/daterangepicker/daterangepicker.js">
        </script>
        <!--===============================================================================================-->
        <!-- <script src="<?php echo base_url();?>assets/login/vendor/countdowntime/countdowntime.js"></script> -->
        <!--===============================================================================================-->
        <script src="<?php echo base_url();?>assets/login/js/main.js">
        </script>
        <!--===============================================================================================-->
        <!-- <script src="<?php //echo base_url();?>js/Login/login.js"></script> -->
        <!--===============================================================================================-->
        <script type="text/javascript">
            var baseurl= '<?php echo base_url();?>';
            $('#contra').focus();
            $(document).ready(function() {

                horaservidor();

                setInterval(function(){
                    horaservidor();
                }
                ,1000);

                function horaservidor(){
                 $.ajax({
                     url: baseurl+'Empleado/cAsistencia/horaServidor',
                     type: 'POST',
                     dataType: 'json',
                     success: function (hora) {
                         // console.log(hora);
                         $('#horaServidor').text(hora);
                     }
                 });                       
                }


            });

        </script>
        <!-- sweet alert -->
        <script src="<?php echo base_url();?>js/sweetalert2.all.js">
        </script>
        <!-- Acciones -->
        <script type="text/javascript">
            $('#asistir').submit(function(event) {//Hasta acá se llego el 02-10-2018
    		event.preventDefault();
    		// ...
    		if ($('#contra').val()!='') {
    			$.post(baseurl+'Empleado/cAsistencia/registrarAsistenciaEmpleado', {contra: $('#contra').val()}, function(documento) {
    				// ...
    				if (documento!='' && documento!='-1' && documento!='-2' && documento!='3' && documento!='4') {
    					// swal('Realizado','Asistencia registrada','success');
    					// Consultar la asistencia del día del empleado
    					$.post(baseurl+'Empleado/cAsistencia/consultarTipoAsistencia', {doc: documento}, function(data) {
    						// ...
    						var respuesta= JSON.parse(data);
    						// ...
    						$.each(respuesta, function(index, row) {
    							// Tipo de evento 1=Laboral, 2=Desayuno y 3=Almuerzo
    							switch(Number(row.inicioFinEvento)){//Optimizar codigo
    								case 0://Inicio de la toma de tiempo indiferente del tipo de evento...
    									if (row.idTipo_evento==1) {//Evento laboral (Inicio de evento)
    										if (row.idEstado_asistencia==1) {//Llego a tiempo
    											swal({
    											  title: 'A tiempo...',
    											  type: 'success',
    											  timer:2000,
    											  backdrop: `rgba(0, 236, 44, 0.3)`
    											});
    										}else{//Llego tarde
    											swal({
    											  title: 'Llegada tarde',
    											  type: 'warning',
    											  animation: false,
    											  customClass: 'animated tada',
    											  timer:2000,
    											  backdrop: `rgba(215, 44, 44, 0.4)`
    											});
    										}
    									}else{//Los otros eventos desayuno y almuerzo (inicio de los eventos)
                                            swal({
                                                title: 'Toma de asistencia',
                                                text: 'toma de tiempo de evento: '+(row.idTipo_evento==2?'Desayuno':'Almuerzo'),
                                                type: 'question',
                                                timer: 2000,
                                                buttons: false 
                                            });
    									}
    									break;
    								case 1://Ya finalizo la toma de tiempos//Falta mostrar cuando se termina el dia laboral
    									if (row.idTipo_evento==1) {//Evento laboral (Fin del evento)
    										swal({
    										  title: 'Fin del dia laboral',
    										  type: 'success',
    										  timer: 2000,
    										  backdrop: `rgba(0, 236, 44, 0.3)`
    										});
    									}else{//Evento de desayuno o almuerzo (Fin de los eventos)
    										switch(Number(row.idEstado_asistencia)){
    											case 1://Llegada a tiempo
    												swal({
    												  title: 'A tiempo...',
    												  text: 'Llegaste a tiempo del evento: '+(row.idTipo_evento==2?'Desayuno':'Almuerzo'),
    												  type: 'success',
    												  timer:2000,
    												  backdrop: `rgba(0, 236, 44, 0.3)`
    												});
    												break;
    											case 2://Llegada tarde
    											    swal({
    											      title: 'Llegada tarde',
    											      text: 'Llegaste tarde del evento: '+(row.idTipo_evento==2?'Desayuno':'Almuerzo'),
    											      type: 'warning',
    											      animation: false,
    											      timer:2000,
    											      customClass: 'animated tada',
    											      backdrop: `rgba(215, 44, 44, 0.4)`
    											    });	
    												break;
    											case 3://No asistio al evento
    												swal({
    												  title: 'No asistio al evento',
    												  text: 'No asististe al evento: '+(row.idTipo_evento==2?'Desayuno':'Almuerzo'),
    												  timer:2000,
    												  backdrop: `rgba(255, 252, 0, 0.3)`
    												});
    												break;	
    										}
    									}
    									break;
    							}
    						});
    					});
    					// Limpiar componenete de contraseña
    					$('#contra').val('');
                        $('#contra').focus();
                        // var ID= '<?php //echo $_SERVER['REMOTE_ADDR']; ?>';
                        // console.log(ID);
    					// ...
    				}else{
                        // ...
                        var typeS='';
                        var mensaje='';
                        var title='';
                        var color='';
                        switch(documento){
                            case '-1':
                                title='Alerta!';
                                typeS='warning';
                                mensaje='El empleado no cuenta con un horario para el día de hoy.';
                                color='rgba(255, 252, 0, 0.3)';//Amarillo
                                break;
                            case '':
                                title='Alerta!';
                                typeS='error';
                                mensaje='El ususario o la contraseña es incorrecto';
                                color='rgba(215, 44, 44, 0.4)';//Rojo
                                break;
                            case '-2':
                                title='Alerta!';
                                typeS='warning';
                                mensaje='Aún no puede ingresar al horario laboral';
                                color='rgba(255, 252, 0, 0.3)';//Amarillo
                                break;
                                //Permiso de Salida e Ingreso
                            case '3'://Salida de la empresa
                            case '4'://Ingreso a la empresa
                                title='Realizado';
                                typeS='success';
                                mensaje=(documento=='3'?'Saliste de permiso de la empresa':'Ingresas a la empresa de un permiso.');
                                color='rgba(0, 236, 44, 0.3)';//verde
                                break;
                        }
                        // ...
                        swal({title: title,
                              text: mensaje,
                              type: typeS,
                              timer: 2000,
                              backdrop: color
                            });
                        // ...
                        $('#contra').val('');
                        $('#contra').focus();
    					// ...
    				}
                    $('#contra').val('');
                    $('#contra').focus();
    				// ...
    			});
    		}
    	});
        // ...
        function nobackbutton(){

           window.location.hash="no-back-button";

           window.location.hash="Again-No-back-button" //chrome

           window.onhashchange=function(){window.location.hash="no-back-button";}

        }

        </script>
    </body>
</html>