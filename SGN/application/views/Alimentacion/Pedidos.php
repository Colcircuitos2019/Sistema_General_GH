<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Pedidos</title>
	<!-- Favicon -->
	<link rel="icon" type="image/png" href="<?php echo base_url();?>assets/login/images/icons/favicon.ico"/>
	<!-- JQuery v2.2.4 -->
	<script data-require="jquery@2.2.4" data-semver="2.2.4" src="<?php echo base_url();?>boostrap/bootstrapselect/jquery.min.js"></script>
	 <!-- Popper.js-->
	<script src="<?php echo base_url();?>boostrap/bootstrapselect/popper.min.js"></script>
	<!-- Boostrap -->
	<link rel="stylesheet" type="text/css" href="<?php echo base_url();?>boostrap/css/bootstrap.min.css" id="bootstrap-css" >
    <!-- select css -->
    <link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/css/select.css">
    <link rel="stylesheet" href="<?php echo base_url();?>boostrap/bootstrapselect/select2-bootstrap.min1.css"/>
	<!-- Estilo principal -->
	<link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/Alimentacion/Pedidos/css/main.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="<?php echo base_url();?>assets/Librerias/bower_components/font-awesome/css/font-awesome.min.css">
    <!-- Table de boostrap-->
    <link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/Librerias/plugins/DataTables/jquery.dataTables.min.css">
    <!-- DatePiker -->
    <link href="<?php echo base_url();?>boostrap/bootstrapdataPiker/css/bootstrap-datepicker.css" rel="stylesheet" type="text/css">
</head>
<body oncontextmenu="return false" onkeydown="return validaTechaF12(event);">
 <style type="text/css">
	.table-fixed tbody {
	  overflow-y: auto;
	}
	#divT{
		overflow:scroll;
		height: 230px;
		 width: 100%;
	}
	.color{
		background-color: #009B07;
	}
 </style>
	<!-- Colocar las imagenes en los botones -->
	<div class="limiter">
		<div class="container-formulario">
			<div class="wrap-formulario">
				<div class="titulo-formulario" style="background-image: url(<?php echo base_url();?>assets/login/images/bg-01.jpg);">
					<span class="titulo-formulario-1" id="titulo">
						Pedidos
					</span>
				</div>
				<!-- Formulario de depidos -->
					<form name="pedidos" method="POST" class="posicion1" >
						<!-- row 1 -->
						<div class="form-horizontal ancho">
							<div class="panel">
							  <div class="row">
								<!-- Columna numero 1 -->
								<div class="col-sm-6">
								  <div class="form-group">
									<!-- selector de proveedor --> 
                                    <div class="col-sm-12">
									  <div class="form-group">
									  	<label class="radio-inline col-sm-6">
                                          <input type="radio" name="optradio" id="D" value="1" onclick="consultarProveedores($('#selProveedor'),0,1);">Desayuno
                                        </label>
                                        <label class="radio-inline">
                                          <input type="radio" name="optradio" id="A" value="2" onclick="consultarProveedores($('#selProveedor'),0,2,)">Almuerzo
                                        </label>
									  </div>
                                      <label for="selProveedor" class="panel1"><b>*</b> Proveedor:</label>
                                      <select class="form-control selectpicker proveedores"  id="selProveedor" data-orden='0'>
                                      	<option value="0" >Seleccione...</option>
										<!-- Proveedores -->
                                      </select>
                                    </div>
                                   <!-- selector de proveedor -->
								  </div>
								</div>
								<!-- /Columna numero 1 -->
								<!-- Columna numero 2 -->
								<div class="col-sm-6">
									<div class="form-group">
										<div class="row">
											<div class="col-sm-11">
												<label class="fecha-pedido pull-right" id="FechaP"></label>
											</div>
											<div class="col-sm-1">
												<button type="button" id="btnClausulas" class="pull-right" style="box-shadow: none; outline: none; border: 0px; background: none; cursor: hand;"><i class="fas fa-question-circle"></i></button>
											</div>
										</div>
									</div>
									<h6>Precio total del pedido</h6>
									<div class="form-group precio-total">
										<h2 id="Total">0</h2>
										<!-- <input type="text" name="" id="Total" readonly="true"> -->
									</div>
								</div>
								<!-- /Columna numero 2 -->
							</div>
							</div>
						</div>
						<!-- /row 1 -->
						<!-- row 2 -->
						<div class="form-horizontal ancho">
							<div class="panel">
							  <div class="row">
								<div class="col-sm-8">
								   <div class="form-group">
								   	<!-- Seleccion del producto -->
                                      <label for="pro">Producto:</label>
                                      <select class="form-control selectpicker" id="pro" data-live-search="true">
										<!-- Selector buscar de productos -->
										<option value="0" >Seleccione...</option>
                                      </select> 
                                   </div>
								</div>
								<!-- Segunda Columna -->
								<div class="col-sm-2">
								   <div class="form-group">
								   	<!-- Cantidad del produccto-->
                                      <label for="cant">Cantidad:</label>
                                      <input type="text" class="form-control" maxlength="2" onkeypress="return valida(event)" id="cant" style="text-align: center;">
                                   </div>
								</div>
							    <!-- Boton de agregar -->
								<div class="col-sm-2">
								   <div class="form-group">
								   	<!-- Cantidad del produccto-->
                                      <label for="bot"></label>
                                      <button type="button" class="btn btn-primary btn-block" for="bot" id="Agregar">Agregar</button>
                                   </div>
								</div>
							  </div>
							</div>
						</div>
						<!-- /row 2 -->
						<!-- row 3 -->
						<div class="form-horizontal ancho">
							<div class="panel">
							  <div class="row">
								<!-- Inicio de tabla -->  
                                    <div class="col-sm-12">
                                      <h4>Linea de pedido</h4>
                                        <div class="table-responsive">   
                                         <table id="tblLineas" class="table table-striped">
                                           <thead id="cabeza">
                                              <th scope="col">Producto</th>
                                              <th scope="col">Cantidad</th>
                                              <th scope="col">Precio</th>
                                              <th scope="col">Momento</th>
                                              <th scope="col">Acciones</th>      
                                           </thead>
                                           <tbody id="cuerpo">    
											<!-- Cuerpo de las linea de pedido -->
                                           </tbody>    
                                       </table>
                                     </div>   
                                   </div>            
								<!-- Fin de la tabla -->	
							  </div>
							</div>
						</div>
						<!-- row 4 -->	
						<div class="form-horizontal ancho">
						 <div class="panel">
						   <div class="row">
						   	<!-- Columna numero 1 -->
						   	<!-- Falta solucionar temas de responsividad -->
						  	 <div class="col-sm-4">
						  	 	<button href="#consultarPedidos" type="button" class="btn btn-info pull-left" data-toggle="modal">Consultar Pedido</button>
						  	 </div>
						  	 <!-- Columna numero 2 -->
						  	 <div class="col-sm-4">
								<button id="productosModal" type="button" class="btn btn-info pull-left" data-toggle="modal">Productos</button>
								<!-- .-.-.-.-. -->
								<button type="button" href="#LiquidacionM" class="btn btn-warning pull-right" data-toggle="modal">Liquidación</button>
							 </div> 	
						  	 <div class="col-sm-2">
						  	 <!-- Columna numero 3 -->
							  	<button id="Limpiar" type="button" class="btn btn-success pull-right">Limpiar</button>
						  	 </div>
						  	 <div class="col-sm-2">
						  	 <!-- Columna numero 3 -->
							  	<button  id="realizarP" type="button" class="btn btn-success pull-right" data-toggle="modal">Realizar</button>
						  	 </div>
						  	</div>
						  </div>
						</dir>

					</form>
					
				<!-- /Formulario de depidos -->
				
<!-- Modals -->
				<!-- Modificar Pedido -->
				<div class="modal fade" id="modificar">
					<div class="modal-dialog">
						<div class="modal-content">
							<!-- Header de la ventana -->
							<div class="modal-header">
								<h2>Modificar Pedido</h2>
								<button type="button" id="cerrar" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
							</div>
							<!-- Body de la ventana -->
							<div class="modal-body">							
									<!-- Proveedores-->
									<div class="form-group col-sm-12">
										<!-- revisar el combo de proveedores Tiene un bug -->
								      <label for="Uprove" ><b>*</b> Proveedor:</label>
                                      <select class="form-control proveedores" id="selProveedorM1" name="subProveedor" data-orden='1'>
                                      	<!--proveedores -->
                                      </select>
                                    </div>                                     
                                    <!-- Seleccion del producto --> 
                                    <div class="form-group col-sm-12">
                                      <label for="Upro"><b>*</b> Producto:</label>
                                      <select class="selectpicker form-control" id="Upro" name="subProducto" data-live-search="true">
										<!-- productos del modal -->
                                      </select>
                                    </div>
									 <!-- Tipo de evento-->
									  <div class="form-group col-sm-12">
									  	<label class="radio-inline col-sm-6">
                                          <input type="radio" name="optradioM" id="UD" value="1" onclick="consultarProveedores($('#selProveedorM1'),1,1);">Desayuno
                                        </label>
                                        <label class="radio-inline">
                                          <input type="radio" name="optradioM" id="UA" value="2" onclick="consultarProveedores($('#selProveedorM1'),1,2);">Almuerzo
                                        </label>
									  </div>	                                   
                                    <!-- Cantidad del produccto-->
                                    <div class="form-group col-sm-12">
                                      <label for="Ucant"> <b>*</b> Cantidad:</label>
                                      <input type="text" class="form-control" maxlength="2" onkeypress="return valida(event)" id="Ucant">
                                   </div> 
							</div>
							<!-- Footer de la ventana -->
							<div class="modal-footer">
								<button type="button" class="btn btn-warning" id="btnActualizar">Actulizar</button>
							</div>	
						</div>
					</div>
				</div>

				<!-- Consultar Pedido -->
				<div class="modal fade" id="consultarPedidos">
					<div class="modal-dialog modal-lg">
						<div class="modal-content">
							<!-- Header de la ventana -->
							<div class="modal-header">
								<h2>Consultar Pedido</h2>
								<button type="button" id="cerrarConsultarP" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
							</div>
							<!-- Body de la ventana -->
							<div class="modal-body">
								<form id="formConsultarP">
								 <div class="form-group">
                                    <label for="doc">Documento:</label>
                                    <input type="text" autocomplete="off" maxlength="13" class="form-control" id="docP" placeholder="ej: 9812543657" onkeypress="return valida(event)">
                                 </div>
								<div class="table-responsive">
                                 <div class="form-group">
                                 	    <table id="tblPedidos" class="table table-striped">
                                           <thead id="cabeza">
                                              <th scope="col">N°P</th>
                                              <th scope="col">Empleado</th>
                                              <th scope="col">Fecha</th>
                                              <th scope="col">Total</th>
                                              <th scope="col">Acciones</th>      
                                           </thead>
                                           <tbody id="cuerpoP">    
											<!-- Cuerpo de las linea de pedido -->
                                           </tbody>    
                                       </table>
                                 </div>									
								</div>
							</div>
							<!-- Footer de la ventana -->
							<div class="modal-footer">
								<button type="submit" id="consultarPedido" class="btn btn-primary">Consultar</button>
							</div>	
						 </form>
						</div>
					</div>
				</div>
		    </div>	
				<!-- Confirmar Pedido -->
				<div class="modal fade" id="Confirmar"><!-- coloca la pantalla de color oscuro con opacidad -->
					<div class="modal-dialog"><!-- Encargada de colocar el contenido en la ventana -->
						<div class="modal-content"><!-- Contenido del cuadro blanco -->
							<!-- Header de la ventana -->
							<div class="modal-header">
								<h2 class="modal-title">Confirmar Pedido</h2>
								<button type="button" id="cerrarConfirmar" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><!-- chasde de ampersand -->
							</div>
							<!-- Header de la ventana -->
							<div class="modal-body">
								<form>
                                  <div class="form-group">
                                    <label for="usr">Documento:</label>
                                    <div class="input-group">
                                    	<input type="text" class="form-control" id="usr" onkeypress="return valida(event)" maxlength="13" autocomplete="off" placeholder="ej: 981532745">
                                    </div>
                                  </div>
                                  <div class="form-group">
                                    <label for="pwd">Contraseña:</label>
                                    <div class="input-group">
                                       <input type="password" class="form-control" maxlength="4" id="pwd" placeholder="1234">
                                    </div>
                                  </div>
                                </form>
							</div>
							<!-- Footer de la ventana-->
							<div class="modal-footer">
								<button type="button" value="0" id="Pedir"  class="btn btn-primary">Terminar Pedido</button>
							</div>
						</div>
					</div>
				</div>

				<!-- Consultar Productos -->
				<div class="modal fade" id="Productos">
					<div class="modal-dialog modal-lg">
						<div class="modal-content">
							<!-- Header de la ventana -->
							<div class="modal-header">
								<h2 class="modal-title"> Productos</h2>
								<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
							</div>
							<!-- Cuerpode la ventana -->
							<div class="modal-body">
								    <label for="selProveedorM2" class="panel1"><b>*</b> Proveedor:</label>
                                      <select class="form-control selectpicker proveedores" id="selProveedorM2" data-orden='2'>
										<!-- Proveedores -->
                                      </select>
                                      <br><br>
                              <div id="divT">
                                <div class="form-control">
								 <div class="table-responsive" id="tablaResponsivaProductos">   
                                         <table id="tblConsultarProductos" class="table table-striped">
                                           <thead>
                                              <th>Producto</th>
                                              <th>Precio Unitario</th>
                                           </thead>
                                        <tbody id="cuerpoM">    
										<!-- -->
											
                                        </tbody>    
                                      </table>
                                   </div> 									
								</div>
							</div>
                          </div>
								
							<!-- Footer la ventana -->
							<div class="modal-footer">
								<button type="button" class="btn btn-primary" data-dismiss="modal" aria-hidden="true">Cerrar</button>
							</div>
						</div>
					</div>					
				</div>
				<!-- /Boton modal de boton productos -->
				<!-- Liquidacion -->
								<!-- Consultar liquidación -->
								<div class="modal fade" id="LiquidacionM">
									<div class="modal-dialog modal-lg">
										<div class="modal-content">
											<!-- Header de la ventana -->
											<div class="modal-header">
												<h2 class="modal-title"> Liquidación por Empleado</h2>
												<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
											</div>
											<!-- Cuerpode la ventana -->
											<div class="modal-body">
											<!-- Primera fila -->
											  <div class="row">
											  	<!-- Columna 1 -->
											  	<div class="col-sm-4">
											  		<label><STRONG>*</STRONG> Documento:</label>
											  		<input type="text" autocomplete="off" maxlength="13" class="form-control" id="documentoL" placeholder="ej: 9812543657" onkeypress="return valida(event)">
											  	</div>
											  	<!-- Columna 2 -->
											  	<div class="col-sm-4">
											  		<label><STRONG>*</STRONG> Fecha Inicio</label>
											  		<div class="input-group date fh-date">
											  		    <input class="form-control" id="fechaInicioL" type="text" readonly="readonly">
											  		        <span class="input-group-addon">
											  		            <i class="glyphicon glyphicon-th">
											  		            </i>
											  		        </span>
											  		    </input>
											  		</div>
											  	</div>
											  	<!-- Columna 3 -->
											  	<div class="col-sm-4">
											  		<label><STRONG>*</STRONG> Fecha Fin</label>
											  		<div class="input-group date fh-date">
											  		    <input class="form-control" id="fechaFinL" type="text" readonly="readonly">
											  		        <span class="input-group-addon">
											  		            <i class="glyphicon glyphicon-th">
											  		            </i>
											  		        </span>
											  		    </input>
											  		</div>
											  	</div>
											  </div>
											  <br>
											  <!-- Segunda fila -->
											  <div class="row">
											  	<!-- Nombre -->
											  	<div class="col-sm-6">
											  		<label>Nombre Empleado:</label>
											  		<br>
											  		<h3 id="nombreLiquidado"></h3>
											  	</div>
											  	<!-- Empresa contratante -->
											  	<div class="col-sm-6">
											  		<div align="center">
											  			<label>Empresa Contratante:</label>
											  			<br>
											  			<h3 id="empresaLiquidado"></h3>
											  		</div>
											  	</div>
											  </div>
											  <br>
											  <!-- Tercera fila -->
											  <div class="row">
											  	<!-- Informacion de la liquidacion -->
											  	<div class="col-sm-12">
											  		<div class="table-responsive" id="tablaDeLiquidacion">
											  			
											  		</div>
											  	</div>
											  </div>
											  <!-- Cuarta Fila -->
											  <div class="row">
											  	<div class="col-sm-12" align="center">
											  		<label>Monto total:</label>
											  		<br>
											  		<h1 id="montoLiquidacion"></h1>
											  	</div>
											  </div>
				                          </div>
												
											<!-- Footer la ventana -->
											<div class="modal-footer">
												<!-- <button type="button" class="btn btn-primary" data-dismiss="modal" aria-hidden="true">Cerrar</button> -->
												<button type="button" id="btnLiquidacion" class="btn btn-primary">liquidar</button>
											</div>
										</div>
									</div>					
								</div>
<!-- /Modals -->						
			</div>
		</div>
	</div>

</body>
	<!-- Boostrap -->
	<script src="<?php echo base_url();?>boostrap/js/bootstrap.min.js"></script>
	<!-- select bootstrap -->
    <script src="<?php echo base_url();?>boostrap/bootstrapselect/bootstrap-select.min.js"></script>
	<!-- sweet alert -->
	<script src="<?php echo base_url();?>js/sweetalert2.all.js"></script>
	<!-- Font Awesome -->
    <script src="<?php echo base_url();?>img/js/fontawesome-all.js"></script>
    <!-- datepicker -->
    <script src="<?php echo base_url();?>assets/Librerias/bower_components/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js">
    </script>
    <!-- Funciones globales (funcion de F12) -->
    <script src="<?php echo base_url()?>js/global.js"></script>
    	<!-- Data Table -->
        <script src="<?php echo base_url();?>assets/Librerias/plugins/DataTables/jquery.dataTables.min.js"></script>
     <script type="text/javascript">
     var dateToday = new Date();
     //DateTimePiker
     $('.fh-date').datepicker({
       format: "dd-mm-yyyy",
       numberOfMonths: 3,
       showButtonPanel: true,
       minDate: -1//Validar que no permita el ingreso de fechas anteriores.
    });

     </script>
    <!-- Base url -->
    <script type="text/javascript">
     var baseurl= '<?php echo base_url();?>';
    </script>
    <!-- Funcionalidades de Pedidos -->
    <?php if($this->uri->segment(2)=='cPedidos'){ ?>
    <script src="<?php echo base_url();?>js/Alimentacion/Pedidos.js"></script>
    <?php }?>

</body>

</html>

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