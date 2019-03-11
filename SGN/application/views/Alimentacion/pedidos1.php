 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Pedidos
        <small>Desktop</small>
      </h1>
      <!--<ol class="breadcrumb">
        <li><a href="#"><i class="fas fa-desktop"></i> Home</a></li>
        <li class="active">Dashboard</li>
      </ol> -->
    </section>
    <!-- /Content Header (Page header) -->
<style type="text/css">
.accion{
  font-size: 10px;
   padding: 3px;
}
.precio-total{
  width: 100%; 
  height: 40px; 
  text-align: center;
  padding: 2px;
  border: 1px solid #E4E6E7;
  border-radius: 5px;
}
</style>
<section class="content">
	<div class="row">
		<!-- Left col (Formularios de la izquierda) -->
        <section class="col-md-12 connectedSortable">
          <!-- Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
          <!-- Div 1-->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-users"></i>
              <h3 class="box-title">Liquidación Proveedor por dia</h3>
              <!-- btn X -->

              <div class="pull-right box-tools">
                
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
              <!-- /.btn X -->
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
              <!-- form Persona -->
              <div class="from-control">
                <div class="panel">
                  <!-- Fila 1 -->
                  <div class="row">
                    <!-- Colum 1 -->
                    <div class="col-sm-3">
                      <label>Fecha de liquidación</label>
                      <div class="input-group date fh-date" >
                        <input type="text" id="fechaL"  class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                      </div>              
                    </div>
                    <div class="col-sm-3">
                      <div>
                        <button class="btn btn-primary" type="button" id="Buscar1">Buscar</button>
                      </div>
                    </div>
                  <br>
                  <!-- Fila 2 -->
                    <div class="row col-md-12">
                    <!-- Cuerpo del reporte de liquidacion de empleado -->
                        <div class="table-responsive"> 
                         <div class="box-body" id="tabla1">
                          <!-- tabla de pedidos diarios -->

                         </div>
                      </div>   
                  </div>
              </div>
                </div>
              <!-- /form Persona -->
              <div class="box-footer clearfix">
                  <!-- <a href="<?php //echo base_url(); ?>cPedido/" target="_blank">Descargar excel</a>   -->
              </div>
            </div>
          </div>
        </section>
    </div>
<div class="row">
    <!-- Left col (Formularios de la izquierda) -->
        <section class="col-md-12 connectedSortable">
          <!-- Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
          <!-- Div 1-->
          <div class="box box-info">
            <div class="box-header">
              <i class="fas fa-users"></i>
              <h3 class="box-title">Liquidación de empleado</h3>
              <!-- btn X -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
              <!-- /.btn X -->
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
              <!-- form Persona -->
              <div class="from-control">
                <div class="panel">
                  <!-- Fila 1 -->
                  <div class="row">
                    <!-- Colum 1 -->
                    <div class="col-md-3">
                      <label for="">Fecha Inicio</label>
                      <div class="input-group date fh-date" >
                        <input type="text" id="fechaI" class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                      </div>              
                    </div>
                    <!-- Colum 2 -->
                    <div class="col-md-3">
                      <label for="">Fecha Fin</label>
                      <div class="input-group date fh-date" >
                        <input type="text" id="fechaF" class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                      </div>              
                    </div>
                    <!-- Columna 3 -->
                    <div class="col-md-3">
                      <label></label>
                      <button type="button" class="btn btn-primary " id="Buscar2">Buscar</button>
                    </div>
                  </div>
                  <br>
                  <!-- Fila 2 -->
                  <div class="row col-md-12">
                    <!-- Cuerpo del reporte de liquidacion de empleado -->
                        <div class="table-responsive"> 
                         <div class="box-body" id="tabla">
                          <!-- tabla de pedidos diarios -->
                         </div>
                      </div>   
                  </div>
                  <!-- Este boton se encargara de generar un excel en un futuro... -->
<!--                     <div class="row">
                      <div class="col-sm-12">
                        <button type="button" class="btn btn-primary pull-right"><span><i class="far fa-file-excel"></i>Generar</span></button>
                      </div>
                   </div>
 -->                </div>
              </div>
              <!-- /form Persona -->
              <div class="box-footer clearfix">
                <div class="col-sm-4">
                  <a target="_blank" id="linkF1">liquidacion por día</a>
                </div>
                <!--  -->
                <div class="col-sm-4">
                  <a class="pull-right" target="_blank" id="linkF3">Pedidos proveedores por rango de fechas</a>   
                </div>
                <div class="col-sm-4">
                  <a class="pull-right" target="_blank" id="linkF2">liquidacion empleado por rango de fechas</a> 
                </div>
              </div>
            </div>
          </div>
<!-- Modal  -->
        <!-- Visualizar detalle -->
        <div class="modal fade" id="detallePedido">
          <div class="modal-dialog  modal-lg">
             <div class="modal-content">
              <!-- cabeza -->
               <div class="modal-header">
                <button type="button" id="cerrar" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2 id="titulo"></h2>
               </div>
               <!-- Cuerpo -->
               <div class="modal-body">
                  <div class="form-horizontal ancho">
              <div class="panel">
                <div class="row" style="padding: 5px;">
                      <div class="col-sm-6">
                        <label>Fecha:</label>
                        <div class="input-group date fh-date" >
                          <input type="text" id="fechaPedido" class="form-control"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                        </div>                        
                      </div>
                      <div class="col-sm-6">
                        <label>Precio total del pedido</label>
                        <div class="form-group precio-total">
                          <label id="Total" style="font-size: 1.7em;">0</label>
                        </div>
                      </div>
                </div>

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
                                              <th scope="col">Acción</th>    
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
                 <button type="button" class="btn btn-warning" id="btnActualizarC">Guardar Cambios</button>
                 <button type="button" class="btn btn-danger" id="eliminarPedido">Eliminar</button>
               </div>    
             </div>
          </div>  
        </div>
        <!-- Modificar pedido -->
        <div class="modal fade" id="modificar">
          <div class="modal-dialog">
            <div class="modal-content">
              <!-- Header de la ventana -->
              <div class="modal-header">
                 <button type="button" id="cerrar" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2>Modificar Pedido</h2>
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
                                          <input type="radio" name="optradioM" id="UD" value="1">Desayuno
                                        </label>
                                        <label class="radio-inline">
                                          <input type="radio" name="optradioM" id="UA" value="2">Almuerzo
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
                <button type="button" class="btn btn-warning" id="btnActualizarL">Actulizar</button>
              </div>  
            </div>
          </div>
        </div>  
<!-- Modal  -->
        </section>
    </div>    