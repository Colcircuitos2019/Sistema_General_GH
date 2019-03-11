<!DOCTYPE html>
<html lang="en">
<head>
	<title>Gestor de pedidos</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!--===============================================================================================-->	
	<link rel="icon" type="image/png" href="<?php echo base_url();?>assets/login/images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/login/vendor/bootstrap/css/bootstrap.min.css">
<!--===============================================================================================-->
    <!-- Font Awesome -->
    <link rel="stylesheet" href="<?php echo base_url();?>assets/Librerias/bower_components/font-awesome/css/font-awesome.min.css">
<!--===============================================================================================-->
<!-- Estilo principal -->
	<link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/Alimentacion/Pedidos/css/main.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/login/css/util.css">
	<link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/login/css/main.css">
<!--===============================================================================================-->
<!-- select css -->
    <link href="<?php echo base_url();?>assets/css/select.css" rel="stylesheet" type="text/css">
    <link href="<?php echo base_url();?>boostrap/bootstrapselect/select2-bootstrap.min1.css" rel="stylesheet"/>
  <!-- Table de boostrap-->
  <link rel="stylesheet" type="text/css" href="<?php echo base_url();?>assets/Librerias/plugins/DataTables/jquery.dataTables.min.css">
<script src="<?php echo base_url();?>assets/login/vendor/jquery/jquery-3.2.1.min.js"></script>
  <!-- Data Table -->
  <script src="<?php echo base_url();?>assets/Librerias/plugins/DataTables/jquery.dataTables.min.js"></script>
  <!-- Sweet alert -->
  <script src="<?php echo base_url();?>js/sweetalert2.all.js"></script>

</head>
<body oncontextmenu="return false" onkeydown="return validaTechaF12(event);">
	<div class="limiter">
		<div class="container-formulario">
			<div class="wrap-formulario">
				<div class="titulo-formulario" style="background-image: url(<?php echo base_url();?>assets/login/images/bg-01.jpg);">
					<span class="titulo-formulario-1">
						Gestor de pedidos
					</span>
				</div>

					<form class="posicion1">
						<div class="form-horizontal" style="padding: 15px;">
							  <div class="row">
								<!-- Inicio de tabla -->  
                                    <div class="col-sm-12">
                                      <h4 style="padding: 5px;">Pedidos <button class="btn btn-primary pull-right" type="button" onclick="" id="btnActualizar"><span><i class="fas fa-redo-alt"></i></span></button></h4>
                                       <div class="table-responsive"> 
                                        <div class="box-body" id="tabla">
									    <!-- tabla de pedidos diarios -->
                                       </div>
                                     </div>   
                                   </div>            
								<!-- Fin de la tabla -->	
							  </div>
							  <br><br>
							  <!-- Fila numero 2 -->
							  <div class="row">
							  	<div class="col-sm-12">
							  		<div class="table-responsive">
							  			<h4 style="padding: 5px;">Cantidad Productos</h4>
							  			<div class="box-body" id="tablaP">
							  				<!-- Tabla de cantidad de productos -->
							  			</div>
							  		</div>
							  	</div>
							  </div>
						</div>
						    <!-- Botones footer-->
						    <div class="container-fluid" style="padding: 15px;">
						      <div class="row">
						    	  	<!-- Boton 1 -->
						    	  	<div class="col-sm-3">
										<button class="btn btn-success" type="button" onclick="" id="btnEnviarPedidos"><span>Enviar Pedidos</span></button>
									</div>
									<!-- Boton 2 -->
									<div class="col-sm-5">
										    <select class="selectpicker show-tick form-control" id="proveedores" >
                                                <option value="0">Seleccione...</option>
                                            </select>
									</div>
									<!-- Boton 3 -->
						    		<div class="col-sm-4">
										<div class="col-sm-12">
											<a target="_black" class="btn btn-primary" href="<?= base_url();?>Alimentacion/cPedidos/listaPedidosConfirmar">Confirmacion</a>
									 <!-- <button class="btn btn-primary" type="button" onclick="" id="btnListadoConfirmacion" data-toggle="tooltip" tittle="Listado de confirmación"><span>Confirmación</span></button> -->
									 <button type="button" id="btnClausulas" class="pull-right" style="background: none; outline: none; "><span><i class="fas fa-question-circle"></i></span></button>
										</div>
									</div>
						      </div>						    	
						    </div>
							<!-- Boton 3 -->
							<!-- <div class="form-horizontal" style="padding: 15px;">
								<div class="row">
									<div class="col-sm-12">
										
									</div>
								</div>
							</div> -->
					</form>
					<div class="row">
						<div class="col-sm-12" id="tblPed">
							
						</div>
					</div>
			</div>
		</div>
	</div>
	<style type="text/css">
/* *, *::before, *::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  background-color: #fafafa;
}*/

@keyframes loading {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}

.loading {
  position: absolute;
  top: 50%;
  left: 50%;
  margin: -25px 0 0 -25px;
  height: 50px;
  width: 50px;
  border: 6px solid #fafafa;
  border-top-color: #24EA1F;
  border-bottom-color: #24EA1F;
  border-radius: 100%;
  animation: loading 1.5s infinite linear;
}
	</style>
	<!-- Modals -->
	      <!-- Visualizar detalle -->
	      <div class="modal fade" id="detallePedido">
	      	<div class="modal-dialog  modal-lg">
	      	   <div class="modal-content">
	      	   	<!-- cabeza -->
	      	   	 <div class="modal-header">
	      	   	 	<h4 id="titulo"></h4>
	      	   	 	<button type="button" id="cerrar" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	      	   	 </div>
	      	   	 <!-- Cuerpo -->
	      	   	 <div class="modal-body">
	      	   	 		<div class="form-horizontal ancho">
							<div class="panel">
							  <div class="row" style="padding: 5px;">
								<!-- Inicio de tabla -->  
                                    <div class="col-sm-12">
                                      <h4 style="padding: 5px;">Lineas de pedido</h4>
                                        <div class="table-responsive">   
                                         <table id="tblLineas" class="table table-striped">
                                           <thead id="cabeza">
                                           	  <th scope="col">Proveedor</th>
                                              <th scope="col">Producto</th>
                                              <th scope="col">Cantidad</th>
                                              <th scope="col">Precio</th>
                                              <th scope="col">Momento</th>     
                                           </thead>
                                           <tbody id="cuerpoP">    
											<!-- Cuerpo de las linea de pedido -->
                                           </tbody>    
                                       </table>
                                     </div>   
                                   </div>            
								<!-- Fin de la tabla -->	
							  </div>
							</div>
						</div>
	      	   	 </div>
	      	   	 <!-- Footer -->
	      	   	 <div class="modal-footer">
	      	   	 	
	      	   	 </div>
	      	   </div>
	      	</div>
	      </div>	
	<!-- Carga de datos -->
		      <div class="modal fade" id="detalleEnvioPedidos">
	      	<div class="modal-dialog  modal-lg">
	      	   <div class="modal-content">
	      	   	<!-- cabeza -->
	      	   	 <div class="modal-header">
	      	   	 	<h4 id="titulo"></h4>
	      	   	 	<button type="button" id="cerrarEnvios" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	      	   	 </div>
	      	   	 <!-- Cuerpo -->
	      	   	 <div class="modal-body">
	      	   	    <div class="form-horizontal">
	      	   	 			<div class="col-sm-12">
	      	   	 				<div class="table-responsive">
	      	   	 					<table class="table table-striped ">
	      	   	 						<thead>
	      	   	 							<th align="center">Proveedor</th>
	      	   	 							<th align="center">Estado</th>
	      	   	 						</thead>
	      	   	 						<tbody id="cuerpoEnvios">
	      	   	 							<!-- <tr>
	      	   	 								<td></td>
	      	   	 								<td></td>
	      	   	 							</tr> -->
	      	   	 						</tbody>
	      	   	 					</table>
	      	   	 				</div>
	      	   	 			</div>
	      	   	 	</div>
	      	   	 </div>
	      	   	 <!-- Footer -->
	      	   	 <div class="modal-footer">
	      	   	 	<!-- <button type="button" id="cerrar">Cerrar</button> -->
	      	   	 		<div class="row" style="height: 2em;">
	      	   	 			<div class="col-sm-11">
	      	   	 				<div class="loading"></div>
	      	   	 			</div>
	      	   	 		</div>
	      	   	 </div>
	      	   </div>
	      	</div>
	      	
	      </div>
<!--===============================================================================================-->
		<!-- Font Awesome -->
    <script src="<?php echo base_url();?>img/js/fontawesome-all.js"></script>
<!--===============================================================================================-->
	<script src="<?php echo base_url();?>assets/login/vendor/bootstrap/js/popper.js"></script>
	<script src="<?php echo base_url();?>assets/login/vendor/bootstrap/js/bootstrap.min.js"></script>
<!--===============================================================================================-->
	<script src="<?php echo base_url();?>js/Login/login.js"></script>
<!--===============================================================================================-->
<!-- Funcion de f12 -->
<script src="<?php echo base_url()?>js/global.js"></script>
<!-- Select bootstrap -->
    <script src="<?php echo base_url();?>boostrap/bootstrapselect/bootstrap-select.min.js"></script>	
	<script type="text/javascript">
		var baseurl= '<?php echo base_url();?>';
	</script>
<!-- sweet alert -->
	<!-- <script src="<?php //echo base_url();?>js/sweetalert2.all.js"></script> -->
	<?php if($this->uri->segment(2)=='cPedidos'){ ?>
    <script src="<?php echo base_url();?>js/Alimentacion/getorPedido.js"></script>
    <?php }?>


</body>
</html>