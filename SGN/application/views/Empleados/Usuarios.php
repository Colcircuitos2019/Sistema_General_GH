 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-user-plus"></i>
        Usuarios
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
<section class="col-lg-12 connectedSortable">
<!--===========================================================================-->       
        <!-- Div 1 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Formulario Usarios</h3>
              <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
  <style type="text/css">
    label strong{
      color: #FD0303;
    }
    .tamaño{
  font-size: 10px;
   padding: 3px;
   }
  </style>
<!-- Cuerpo -->
<div class="box-body">
  <div class="col-sm-12">
<form class="form-horizontal">
    <div class="form-group">
        <label class="control-label col-sm-2" for="user"><strong>*</strong>Nombre:</label>
        <div class="col-sm-10">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-user-plus"></i></span>
             <input type="text" onkeyup="return validarPorCampo(this.id);" id="user" autocomplete="off" class="form-control" maxlength="45" placeholder="Nombre de usuario">
          </div> 
        </div>
    </div>
        <!-- Contraseñas -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="contraseña1"><strong>*</strong>Constraseña:</label>
        <div class="col-sm-4">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-unlock-alt"></i></span>
             <input type="password" maxlength="20" onkeyup="return validarPorCampo(this.id);" autocomplete="off" class="form-control" id="contraseña1" placeholder="contraseña">
          </div> 
        </div>
        <label class="control-label col-sm-2" for="contraseña2"><strong>*</strong>Confirmar:</label>
        <div class="col-sm-4">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-unlock-alt"></i></span>
             <input type="password" maxlength="20" onkeyup="return validarPorCampo(this.id);" autocomplete="off" class="form-control" id="contraseña2" placeholder="contraseña">             
          </div> 
        </div>
    </div>
    <!-- Email -->
    <div class="form-group">
      <label class="control-label col-sm-2"><strong>*</strong>E-mail:</label>
      <div class="col-sm-10">
        <div class="input-group">
          <span class="input-group-addon">
            <i class="far fa-envelope"></i>
          </span>
          <input type="email" name="correo" id="email" class="form-control" placeholder="gestionhumana@colcircuitos.com" maxlength="200">
        </div>
      </div>
    </div>
    <!-- Tipo de ususario -->
      <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Tipo de usuario:</label>
        <div class="col-sm-10">
          <select id="tipoUsuario" class="form-control" name="cbxEmpresas">
            <option value="0">Seleccione...</option>
          </select>
        </div>
    </div>        
</form>
<!-- <a href="<?php //echo base_url(); ?>cEmpleado/reporteEmpleados" target="_blank">Descargar excel</a>     -->
</div>
</div>
<div class="box-footer">
        <div class="pull-right">
          <input type="button" class="btn btn-primary" id="Enviar" value="Registrar">
        </div>
</div>
<!-- /Cuerpo -->
</div>
        <!-- Div 1 -->
         <!-- Div 2 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Usuarios</h3>
              <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
            <div class="col-sm-12">
              <div class="table-responsive">
              <div class="form-group" id="tblTableUsuarios">
                <!--  -->
              </div>                 
              </div>             
            </div>

            </div>
            <div class="box-footer">
              <button type="button" class="btn btn-primary pull-right" id="consulta2">Actualizar</button>
            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- Div 2 -->
        </section>

<!-- Modals============================================================ -->
        <!-- Modificar Pedido -->
        <div class="modal fade" id="modificarUsuario">
          <div class="modal-dialog">
            <div class="modal-content">
              <!-- Header de la ventana -->
              <div class="modal-header">
                <button type="button"  class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2>Modificar Usuario</h2>      
              </div>
              <!-- Body de la ventana -->
              <div class="modal-body">
              <!-- Tipos de usuario -->
              <form class="form-horizontal">
    <div class="form-group">
        <label class="control-label col-sm-2" for="userM">Nombre:</label>
        <div class="col-sm-10">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-user-plus"></i></span>
             <input type="text" id="userM" autocomplete="off" class="form-control" maxlength="45" onkeyup="return validarPorCampo(this.id);" placeholder="Nombre de usuario">
          </div> 
        </div>
    </div>
    <!-- Contraseñas -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="contraseña1M"><strong>*</strong>Constraseña:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="20" autocomplete="off" onkeyup="return validarPorCampo(this.id);" class="form-control" id="contraseña1M" placeholder="contraseña">
            <input type="checkbox" onchange="document.getElementById('contraseña1M').type = this.checked ? 'text' : 'password'"> Ver Contraseña
        </div>
        <label class="control-label col-sm-2" for="contraseña2M"><strong>*</strong>Confirmar:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="20" autocomplete="off" onkeyup="return validarPorCampo(this.id);" class="form-control" id="contraseña2M" placeholder="contraseña">
        </div>
    </div>
    <div class="form-group">
      <label class="control-label col-sm-2"><strong>*</strong>E-mail:</label>
      <div class="col-sm-10">
        <div class="input-group">
          <spa class="input-group-addon"><i class="far fa-envelope"></i></spa>
          <input type="email" name="correo" id="emailM" class="form-control" placeholder="gestionhumana@colcircuitos.com" maxlength="200">
        </div>
      </div>
    </div>
      <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Tipo de usuario:</label>
        <div class="col-sm-10">
          <select id="tipoUsuarioM" class="form-control" name="cbxEmpresas">
            <option value="0">Seleccione...</option>
          </select>
        </div>
    </div>        
</form>
            </div>
            <div class="modal-footer">
              <input type="button" class="btn btn-warning" id="modificarM" value="Actualizar">
            </div>
          </div>
        </div>
        <!-- /Modificar Pedidos -->
<!-- /Modals -->  
    </div>