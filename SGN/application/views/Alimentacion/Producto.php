 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Producto
        <small>Desktop</small>
      </h1>
<!--       <ol class="breadcrumb">
        <li><a href=""><i class="fas fa-desktop"></i> Home</a></li>
        <li class="active">Dashboard</li>
      </ol> -->
    </section>
    <!-- /Content Header (Page header) -->

<section class="content">
	<div class="row">
		<!-- Left col (Primer formulario) -->
        <section class="col-lg-12 connectedSortable">
          <!-- Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
          <!-- Div 1-->
          <div class="box box-success">
            <div class="box-header">
              <i class="fas fa-wine-glass"></i>
              <h3 class="box-title">Formulario de productos</h3>
              <!-- btn X -->
               <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
              <!--<div class="pull-right box-tools">
                <button type="button" class="btn btn-success btn-sm" data-widget="remove" data-toggle="tooltip"
                        title="Remove">
                  <i class="fa fa-times"></i></button>
              </div>-->
              <!-- /.btn X -->
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
              <!-- form Producto -->
              <form  method="POST" class="form-horizontal" id="formCiudad">
                <!-- input Nombres -->
                <div class="form-group col-sm-12">
                  <!-- Proveedor -->
                  <label>Proveedor</label>
                  <select class="form-control" id="selectProveedor">
                    <!-- Options -->
                  </select>
                </div>
                <div class="form-group">
                  <!-- Nombre del producto -->
                  <label for="txtProducto" class="col-sm-2 control-label">Nombre Producto:</label>
                   <div class="input-group col-sm-9">
                     <span class="input-group-addon"><i class="fas fa-utensils"></i></span>
                     <input type="text" id="txtProducto" class="form-control" maxlength="45" placeholder="Ej: Almuerzo especial del dia">
                   </div>
                </div>
                <div class="form-group">
                  <!-- Precio del producto -->
                  <label for="txtPrecioProducto" class="col-sm-2 control-label">Precio Producto:</label>
                   <div class="input-group col-sm-9">
                     <span class="input-group-addon"><i class="fas fa-dollar-sign"></i></span>
                     <input type="text" id="txtPrecioProducto" class="form-control"  onkeypress="return valida(event)" maxlength="8" placeholder="Ej: $12000">
                   </div>
                </div>
                <!-- input submit -->
                 <div class="box-footer clearfix">
                   <button type="button" class="pull-right btn btn-success" id="sendInfoProducto">Registrar
                   <i class="fa fa-arrow-circle-right"></i></button>
                 </div>
              </form>
              <!-- /form Producto-->

              <!-- Tabla de productos -->
              <div class="form-group">
            <div class="box">
            <div class="box-header">
              <h3 class="box-title">Productos</h3>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <div class="table-responsive" id="tblTable">
                
              </div>
            </div>
            <!-- /.box-body -->
            </div>
              </div>
              <!-- /Tabla de productos -->
            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- /Div 1-->
          <div class="box box-success">
            <div class="box-header">
              <i class="fas fa-wine-glass"></i>
              <h3 class="box-title">Productos más vendidos</h3>
              <!-- btn X -->
               <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
              <!--<div class="pull-right box-tools">
                <button type="button" class="btn btn-success btn-sm" data-widget="remove" data-toggle="tooltip"
                        title="Remove">
                  <i class="fa fa-times"></i></button>
              </div>-->
              <!-- /.btn X -->
                 </div>
                <!-- Cuerpo -->
                <div class="box-body">
                  
                </div>
              </div>
              <!-- /Tabla de productos -->
            </div>
            <!-- /Cuerpo -->
          </div>


        <!-- Modificar Producto -->
        <div class="modal fade" id="modificar">
          <div class="modal-dialog">
            <div class="modal-content">
              <!-- Header de la ventana -->
              <div class="modal-header">
                <button type="button"  class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2>Modificar Producto</h2>      
              </div>
              <!-- Body de la ventana -->
              <div class="modal-body">
              <!-- Productos-->
              <form  method="POST" class="form-horizontal" id="formCiudad">
                <!-- input Nombres -->
                <div class="form-group col-sm-12">
                  <!-- Proveedor -->
                  <label>Proveedor</label>
                  <select class="form-control" id="selectProveedorM">
                    <option value="0">Seleccione...</option>
                  </select>
                </div>
                <div class="form-group">
                  <!-- Nombre del producto -->
                  <label for="txtProductoM" class="col-sm-2 control-label">Nombre Producto:</label>
                   <div class="input-group col-sm-9">
                     <span class="input-group-addon"><i class="fas fa-utensils"></i></span>
                     <input type="text" id="txtProductoM" class="form-control" maxlength="45" placeholder="Ej: Almuerzo especial del dia">
                   </div>
                </div>
                <div class="form-group">
                  <!-- Precio del producto -->
                  <label for="txtPrecioProductoM" class="col-sm-2 control-label">Precio Producto:</label>
                   <div class="input-group col-sm-9">
                     <span class="input-group-addon"><i class="fas fa-dollar-sign"></i></span>
                     <input type="text" id="txtPrecioProductoM" class="form-control"  onkeypress="return valida(event)" maxlength="8" placeholder="Ej: $12000">
                   </div>
                </div>
              </form>                
              </div>
              <!-- Footer de la ventana -->
              <div class="modal-footer">
                <button type="button" id='cActualizar' onclick="actualizarProducto(this.value)" class="btn btn-warning">Actulizar</button>
              </div>  
            </div>
          </div>
        </div>
        <!-- /Modificar Pedidos -->          
          <!-- /Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
        </section>
        <!-- /.Left col (Formularios de izquierda)-->
    </div>