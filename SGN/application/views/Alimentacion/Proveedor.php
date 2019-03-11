 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Proveedor
        <small>Desktop</small>
      </h1>
<!--       <ol class="breadcrumb">
        <li><a href="#"><i class="fas fa-desktop"></i> Home</a></li>
        <li class="active">Dashboard</li>
      </ol> -->
    </section>
    <!-- /Content Header (Page header) -->
<section class="content">
	<div class="row">
		<!-- Left col (Formularios de la izquierda) -->
        <section class="col-sm-12 connectedSortable">
          <!-- Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
          <!-- Div 1-->
          <div class="box box-success">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Formulario Proveedor</h3>
              <!-- btn X -->
<!--               <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div> -->
              <!-- /.btn X -->
            </div>
            <!-- Cuerpo -->
            <div>
              <!-- form Persona -->
              <form  method="POST" class="form-horizontal" id="FormProveedor">
                <!-- input Nombres -->
                <div class="form-group">
                  <label for="txtNombreP" class="col-sm-3 control-label"><b>*
                  </b>Nombre Proveedor:</label>
                  <div class="col-sm-8">
                    <input type="text"  maxlength="45" class="form-control" id="txtNombreP" placeholder="Eje: Roberto">
                  </div>
                </div>
                <!-- Telefono del proveedro -->
                <div class="form-group">
                  <label for="txtelefonoC" class="col-sm-3 control-label"><b>*
                  </b>Telefono:</label>
                  <div class="col-sm-8">
                    <input type="text" maxlength="11" class="form-control" id="txtelefonoC" onkeypress="return valida(event)" placeholder="Eje: 2528099">
                  </div>
                </div>
                <!-- Evento -->
                <div class="form-group">
                <label for="inputEmail3" class="col-sm-4 control-label"></label>        
                  <div class="col-sm-2">
                    <!-- Desayuno -->
                    <label><input type="radio" name="evento" value="1"> Desayuno</label>
                  </div>
                  <div class="col-sm-2">
                  <!-- Almuerzo -->
                  <label><input type="radio" name="evento" value="2"> Almuerzo</label>                    
                  </div>
                </div>
                <!-- Email del proveedor -->
                <div class="form-group">
                  <label for="inputEmail3" class="col-sm-3 control-label" for="txtEmail"><b>*
                  </b>Email:</label>
                  <div class="col-sm-8">
                    <input type="email"   maxlength="60" class="form-control" id="txtEmail" placeholder="Eje: jmarulanda@hotmail.com">
                  </div>
                </div>
                <!-- input submit -->
                 <div class="box-footer clearfix">
                   <button type="submit" class="pull-right btn btn-success" id="sendProveedor">Registrar
                   <i class="fa fa-arrow-circle-right"></i></button>
                 </div>
              </form>
              <!-- /form Persona -->
            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- /Div 1-->
          <!-- /Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
        </section>
        <!-- /.Left col (Formularios de izquierda)-->
          <section class="col-lg-12 connectedSortable">
          <!-- Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
<!--===========================================================================-->
    <!-- Left col (Formularios de la izquierda inferiro) -->          
          <!-- Div 1-->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Proveedores</h3>
                          <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>

            <!-- Cuerpo -->
            <div class="box-body">
            <!-- Tabla -->
              <div class="form-group">
               <div class="table-responsive" id="divTable">
                <!-- <table class="display" id="tblProveedor">
                 </table> -->
               </div>          
              </div>
            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- /Div 1-->
          <!-- /Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
        </section>
<!-- Modals -->
        <!-- Modificar Pedido -->
        <div class="modal fade" id="modificar">
          <div class="modal-dialog">
            <div class="modal-content">
              <!-- Header de la ventana -->
              <div class="modal-header">
                <button type="button"  class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2>Modificar Proveedor</h2>      
              </div>
              <!-- Body de la ventana -->
              <div class="modal-body">
                  <!-- Proveedores-->
              <form  method="POST" class="form-horizontal" id="FormProveedorM">
                <!-- input Nombres -->
                <div class="form-group">
                  <label for="txtNombrePM" class="col-sm-3 control-label"><b>*</b>Nombre Proveedor:</label>
                  <div class="col-sm-9">
                    <input type="text" class="form-control" id="txtNombrePM" placeholder="Eje: Roberto">
                  </div>
                </div>
                <!-- Telefono del proveedor -->
                <div class="form-group">
                  <label for="txtelefonoCM" class="col-sm-3 control-label"><b>*</b>Telefono:</label>
                  <div class="col-sm-9">
                    <input type="text" name="numpiso" class="form-control" id="txtelefonoCM" onkeypress="return valida(event)"  placeholder="Eje: 2528099">
                  </div>
                </div>
                <!-- Evento -->
                <div class="form-group">
                <label for="inputEmail3" class="col-sm-4 control-label"></label>        
                  <div class="col-sm-3">
                    <!-- Desayuno -->
                    <label><input type="radio" name="eventoM" value="1" id="D"> Desayuno</label>
                  </div>
                  <div class="col-sm-3">
                  <!-- Almuerzo -->
                  <label><input type="radio" name="eventoM" value="2" id="A"> Almuerzo</label>                    
                  </div>
                </div>
                <!-- Email del proveedor -->
                <div class="form-group">
                  <label for="txtEmailM" class="col-sm-3 control-label"><b>*
                  </b>Email:</label>
                  <div class="col-sm-9">
                    <input type="email"   maxlength="60" class="form-control" id="txtEmailM" placeholder="Eje: jmarulanda@hotmail.com">
                  </div>
                </div>
              </form>                  
              </div>
              <!-- Footer de la ventana -->
              <div class="modal-footer">
                <button type="button" id='cActualizar' onclick="registrarModificarProveedor(this.value)" class="btn btn-warning">Actulizar</button>
              </div>  
            </div>
          </div>
        </div>
        <!-- /Modificar Pedidos -->
<!-- /Modals -->  

    </div>