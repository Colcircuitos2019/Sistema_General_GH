 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-calendar-plus"></i>
        Calendario
        <small>Desktop</small>
      </h1>
<!--       <ol class="breadcrumb">
        <li><a href="#"><i class="fas fa-desktop"></i> Home</a></li>
        <li class="active">Dashboard</li>
      </ol> -->
    </section>
    <style>

  body {
    padding: 0;
    font-family: "Lucida Grande",Helvetica,Arial,Verdana,sans-serif;
    font-size: 14px;
  }

  #calendar1 {
    max-width: 1200px;
    margin: 0 auto;
  }

</style>
    <!-- /Content Header (Page header) -->
<section class="content">
  <div class="row">
<section class="col-lg-12 connectedSortable">
<!--===========================================================================-->       
        <!-- Div 1 -->
          <div class="box box-primary">
            <!-- Cabeza -->
            <div class="box-header">
              <i class="fas fa-calendar-alt"></i>
              <h3 class="box-title">Calendario Empresarial</h3>
              <!-- Minimizar -->
                <div class="pull-right box-tools">
                  <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
              <div class="box-body no-padding">
                <!-- THE CALENDAR -->
                <div class="col-sm-12" style="border: 0.3px solid #DDDDDD;">
                  <div id="calendar1" ></div>
              
                  </div>                  
                </div>
            </div>
            <!-- Pie -->
            <div class="box-footer">
              
            </div>
          </div>
        <!-- /Div 1 -->
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
        <label class="control-label col-sm-2">Nombre:</label>
        <div class="col-sm-10">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-user-plus"></i></span>
             <input type="text" id="userM" autocomplete="off" class="form-control" maxlength="45" onkeyup="return validarPorCampo(this.id);" placeholder="Nombre de usuario">
          </div> 
        </div>
    </div>
        <!-- Contraseñas -->
    <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Constraseña:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="20" autocomplete="off" onkeyup="return validarPorCampo(this.id);" class="form-control" id="contraseña1M" placeholder="contraseña">
            <input type="checkbox" onchange="document.getElementById('contraseña1M').type = this.checked ? 'text' : 'password'"> Ver Contraseña
        </div>
        <label class="control-label col-sm-2"><strong>*</strong>Confirmar:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="20" autocomplete="off" onkeyup="return validarPorCampo(this.id);" class="form-control" id="contraseña2M" placeholder="contraseña">
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