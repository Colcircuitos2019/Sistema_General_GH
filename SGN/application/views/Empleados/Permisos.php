<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
            <meta content="width=device-width, initial-scale=1.0" name="viewport">
                <title>
                    Permisos
                </title>
                <!-- Favicon -->
                <link href="<?php echo base_url();?>assets/login/images/icons/favicon.ico" rel="icon" type="image/png"/>
                <!-- JQuery v2.2.4 -->
                <script data-require="jquery@2.2.4" data-semver="2.2.4" src="<?php echo base_url();?>boostrap/bootstrapselect/jquery.min.js">
                </script>
                <!-- Popper.js-->
                <script src="<?php echo base_url();?>boostrap/bootstrapselect/popper.min.js">
                </script>
                <!-- Boostrap -->
                <link href="<?php echo base_url();?>boostrap/css/bootstrap.min.css" id="bootstrap-css" rel="stylesheet" type="text/css">
                <!-- select css -->
                <link href="<?php echo base_url();?>assets/css/select.css" rel="stylesheet" type="text/css">
                <link href="<?php echo base_url();?>boostrap/bootstrapselect/select2-bootstrap.min1.css" rel="stylesheet"/>
                <!-- Estilo principal -->
                <link href="<?php echo base_url();?>assets/Alimentacion/Pedidos/css/main.css" rel="stylesheet" type="text/css">
                <!-- Font Awesome -->
                <link href="<?php echo base_url();?>assets/Librerias/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet">
                <!-- Table de boostrap-->
                <link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/Librerias/plugins/DataTables/jquery.dataTables.min.css">
                <!-- Data Table -->
                <script src="<?php echo base_url();?>assets/Librerias/plugins/DataTables/jquery.dataTables.min.js"></script>
                <!-- DatePiker -->
                <link href="<?php echo base_url();?>boostrap/bootstrapdataPiker/css/bootstrap-datepicker.css" rel="stylesheet" type="text/css">
                <!-- DateTimePiker -->
                <!-- <script type="text/javascript" src="https://bower_components/moment/min/moment.min.js"></script> -->
                <!-- <link rel="stylesheet" href="https://bower_components/bootstrap/dist/css/bootstrap.min.css" /> -->
                <!-- <link rel="stylesheet" href="https://bower_components/eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min.css" /> -->
                <!-- Time Picker -->
                  <script src="<?php echo base_url();?>boostrap/timePiker/js/bootstrap-timepicker.min.js"></script>
                  <link rel="stylesheet" type="text/css" href="<?php echo base_url();?>boostrap/timePiker/css/bootstrap-timepicker.min.css">
            </meta>
        </meta>
    </head>
    <body>
        <style type="text/css">
            .table-fixed tbody {
             overflow-y: auto;
            }
            
            #divT{
	         overflow:scroll;
	         height: 230px;
	         width: 100%;
            }

            .codigoP{
                background-color: #28A745;
                padding: 6px;
                border-radius: 5px;
                margin: auto;
                color: white;
            }

            .codigoA{
                background-color: #D3D520;
                padding: 6px;
                border-radius: 5px;
                margin: auto;
                color: white;
            }
            .estadoE{
                background-color: #001EFF;
                padding: 6px;
                border-radius: 5px;
                margin: auto;
                color: white;
            }

            .tamañoEstado{
                font-size: 12px;
                padding: 3px;
            }
        </style>
        <!-- Colocar las imagenes en los botones -->
        <div class="limiter">
            <div class="container-formulario">
                <div class="wrap-formulario">
                    <div class="titulo-formulario" style="background-image: url(<?php echo base_url();?>assets/login/images/bg-01.jpg);">
                        <span class="titulo-formulario-1" id="titulo">
                            Permisos
                        </span>
                    </div>
                    <!-- Formulario de depidos -->
                    <form class="posicion1" name="pedidos">
                        <!-- fila 1 -->
                        <div class="form-horizontal ancho">
                            <div class="panel">
                                <div class="row">
                                    <!-- Columna 1 -->
                                    <div class="col-sm-4">
                                        <label>Fecha de solicitud:</label>
                                            <br>
                                            <label style="font-size: 1.3em;" id="fechaSolicitud" class="form-control">
                                                <!-- Fecha del sistema -->
                                            </label>
                                    </div>
                                    <!-- Columna 2 -->
                                    <div class="col-sm-4">
                                        <!-- Espacio -->
                                    </div>
                                    <!-- Columna 3 -->
                                    <div class="col-sm-4">
                                        <label for=""><STRONG>*</STRONG>Fecha del permiso:</label>
                                        <div class="input-group date fh-date">
                                            <input class="form-control" id="fechaPermiso" type="text" readonly="readonly">
                                                <span class="input-group-addon">
                                                    <i class="glyphicon glyphicon-th">
                                                    </i>
                                                </span>
                                            </input>
                                        </div>
                                    </div>
                                </div><br>
                                <!-- Fila 2 -->
                                <div class="row">
                                  <div class="col-sm-11">
                                    <label for="pro"><STRONG>*</STRONG>Solicitante:</label>
                                    <select class="form-control selectpicker" id="solicitante" data-live-search="true">
                                    <!-- Selector buscar de productos -->
                                    <option value="0" >Seleccione...</option>
                                    </select> 
                                  </div>
                                </div><br><br>
                                <!-- Fila 3 -->
                                <div class="row">
                                  <div class="col-sm-6">
                                    <label for="pro"><STRONG>*</STRONG>Concepto:</label>
                                    <select class="form-control selectpicker" data-size="8" id="concepto" data-live-search="true">
                                    <!-- Selector buscar de productos -->
                                    <option value="0" >Seleccione...</option>
                                    </select> 
                                  </div>
                                  <div class="col-sm-6">
                                      <label for="pro"><STRONG>*</STRONG>Momento:</label>
                                      <select class="form-control selectpicker" data-size="8" id="momento" data-live-search="true">
                                      <!-- Selector buscar de productos -->
                                      <option value="0">Seleccione...</option>
                                      <option value="1">Salida Temprano</option>
                                      <option value="2">Ingreso Tarde</option>
                                      <option value="3">Salida e Ingreso</option>
                                      </select> 
                                  </div>
                                </div><br><br>
                                <!-- Fila 4 -->
                                <div class="row">
                                  <div class="col-sm-12">
                                    <div class="form-group" id="otrasCausas">
                                     <label for="comment"><STRONG>*</STRONG>Otra causa, ¿Cúal?:</label>
                                     <textarea class="form-control" rows="5" id="descripcion" maxlength="100"></textarea>
                                    </div>
                                  </div>
                                </div>
                                <!-- Fila 5 -->
                                <div class="row">
                                    <!-- Columna 1 -->
                                  <div class="col-sm-4">
                                    <label><strong>*</strong>Hora:</label>
                                        <!-- <input type="text" name="" maxlength="5" class="form-control" placeholder="HH:MM"> -->
                                        <div class='col-sm-12'>
                                          <div class="form-group">
                                            <div class="input-group bootstrap-timepicker timepicker pull-right">
                                              <input id="horaPermiso" type="text" class="form-control input-small tiempos">
                                            </div>
                                          </div>
                                      </div>
                                  </div>
                                  <div class="col-sm-4">    
                                  </div>
                                  <!-- Columna 4 -->
                             <!--     <div class="col-sm-4">
                                    <label><strong>*</strong>Momento:</label> -->
                                        <!-- <input type="text" name="" maxlength="5" class="form-control" placeholder="HH:MM"> -->
                                  <!--       <div class='col-sm-12'>
                                          <div class="from-group">
                                            <select class="selectpicker show-tick" id="momento">
                                                <option value="0">Seleccione...</option>
                                                <option value="1">Llegada tarde</option>
                                                <option value="2">Salida temprano</option>
                                            </select>
                                          </div>
                                      </div>
                                  </div> -->
                                </div>
                            </div>
                        </div>
                        <!-- /row 1 -->
                            <!-- row 4 -->
                            <div class="form-horizontal ancho">
                                <div class="panel">
                                    <div class="row">
                                        <!-- Columna2 -->
                                        <div class="col-sm-12"> 
                                            <button class="btn btn-success pull-right" id="realizarP" type="button">
                                                Realizar
                                            </button>
                                          <div class="col-sm-3">
                                            <button class="btn btn-success pull-right" id="consultarPer" type="button">
                                                Consultar Permiso
                                            </button>
                                            <!-- Boton de prueba -->
                                            <!--   <button href="#modificarPermiso" class="btn btn-success pull-right" data-toggle="modal" type="button">
                                                Modificar Permiso
                                            </button> -->
                                          </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>
<!-- /Formulario de depidos -->
<!-- Modals -->
<!-- Consultar Permisos -->
<div class="modal fade" id="consultarPermisosE"><!--  role="dialog" -->
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <!-- Header -->
            <div class="modal-header">
                <h2>Consultar Permiso</h2>
                <button aria-hidden="true" class="close" data-dismiss="modal" id="" type="button">&times;</button>
            </div>
            <!-- Cuerpo -->
            <div class="modal-body">
                <div class="col-sm-12">
                    <label>Numero documento</label>
                    <input type="numeber" name="" class="form-control" id="documentoPermiso" max="13" >
                </div>
                <br><br>
                <div class="col-sm-12">
                   <div class="table-responsive" id="tblPermisosEmpleado">

                   </div>
                 </div>
            </div>
            <!-- Footer -->
            <div class="modal-footer">
                <button class="btn btn-primary" id="conPermiso">Consultar</button>
            </div>
        </div>
    </div>
</div>

<!-- Confirmar Permiso -->
<div class="modal fade" id="ConfirmarPermiso">
    <!-- coloca la pantalla de color oscuro con opacidad -->
    <div class="modal-dialog">
        <!-- Encargada de colocar el contenido en la ventana -->
        <div class="modal-content">
            <!-- Contenido del cuadro blanco -->
            <!-- Header de la ventana -->
            <div class="modal-header">
                <h2 class="modal-title">
                    Confirmar Permiso
                </h2>
                <button aria-hidden="true" class="close" data-dismiss="modal" type="button">
                    &times;
                </button>
                <!-- chasde de ampersand -->
            </div>
            <!-- Header de la ventana -->
            <div class="modal-body">
                <form>
                    <div class="form-group">
                        <label for="documento">
                            Documento:
                        </label>
                        <div class="input-group">
                            <input class="form-control" id="documento" maxlength="13" placeholder="Numero documento de identidad" type="text">
                            </input>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="pwd">
                            Contraseña:
                        </label>
                        <div class="input-group">
                            <input class="form-control" id="pwd" maxlength="4" placeholder="Contraseña" type="password">
                            </input>
                        </div>
                    </div>
                </form>
            </div>
            <!-- Footer de la ventana-->
            <div class="modal-footer">
                <button class="btn btn-primary" id="terminarPermiso" type="button" value="0">
                    Terminar Permiso
                </button>
            </div>
        </div>
    </div>
</div>
<!-- /Boton modal de boton productos -->
<!-- /Modals -->
<!-- Boostrap -->
<script src="<?php echo base_url();?>boostrap/js/bootstrap.min.js">
</script>
<!-- select bootstrap -->
<script src="<?php echo base_url();?>boostrap/bootstrapselect/bootstrap-select.min.js">
</script>
<!-- sweet alert -->
<script src="<?php echo base_url();?>js/sweetalert2.all.js">
</script>
<!-- Font Awesome -->
<script src="<?php echo base_url();?>img/js/fontawesome-all.js">
</script>
<!-- daterangepicker -->
<script src="<?php echo base_url();?>assets/Librerias/bower_components/moment/min/moment.min.js"></script>
<script src="<?php echo base_url();?>assets/Librerias/bower_components/bootstrap-daterangepicker/daterangepicker.js"></script>
<!-- datepicker -->
<script src="<?php echo base_url();?>assets/Librerias/bower_components/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js">
</script>
<!-- DateTimePiker -->
<!-- <script type="text/javascript" src="https://bower_components/eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min.js"></script> -->
        <script type="text/javascript">
        var dateToday = new Date();
        //DateTimePiker
        $('.fh-date').datepicker({
          format: "dd-mm-yyyy",
          numberOfMonths: 3,
          showButtonPanel: true,
          minDate: -1//Validar que no permita el ingreso de fechas anteriores.
          // todayBtn: "linked"
       });
       // $('#datetimepicker3').data("DateTimePicker").FUNCTION()
       // $('#datetimepicker3').datetimepicker({
       //  format: 'LT'
       // });
        </script>
<!-- Base url -->
<script type="text/javascript">
    var baseurl= '<?php echo base_url();?>';
</script>
<!-- Funcionalidades de Permisos (La vista que utiliza los empleados)-->
<script src="<?php echo base_url();?>js/Empleados/permisosCompartido.js"></script> 
<script src="<?php echo base_url();?>js/Empleados/permisoEmpleado.js"></script>
<!--preConfirm: function () {
    return new Promise(function (resolve) {
      resolve([
        $('#swal-input1').val(),
        $('#swal-input2').val()
      ])
    })
  } 


<script type="text/javascript">
		
		function validacionEliminarLineaPedido() {
			swal({
               title: '¿Estas seguro?',
               text: "Si eliminas esta linea de pedido no quedara en el pedido",
               type: 'warning',
               showCancelButton: true,
               confirmButtonColor: '#3085d6',
               cancelButtonColor: '#d33',
               confirmButtonText: 'Si'
            }).then((result) => {
                  if (result.value) {
                    swal(
                    'Deleted!',
                    'Your file has been deleted.',
                    'success'
                    )
                  }
               });
		}

		function validarTerminacionDePedido() {			
         swal({
              title: 'Confirmar Pedido',
              html:
                '<input id="swal-input1" class="swal2-input" placeholder="User Name">' +
                '<input id="swal-input2" class="swal2-input" placeholder="Passwors">',
              confirmButtonColor: '#3085d6',
              confirmButtonText: 'Pedir',
              showCancelButton: true,
              cancelButtonColor: '#d33',
              focusConfirm: false,
         }).then(function (op) {
	               if (op.value) {
		              swal(
                        'Realizado',
                        'Su pedido fue realizado',
                        'success'
                         )
	                }
                }).catch(swal.noop);
		}

		function validarModificacionDePedido() {
			swal('Formulario para actualziar al informacion');
		}

		function consultarProductos() {
			swal('Mostrar tabla de productos');
		}
	</script>

  -->
