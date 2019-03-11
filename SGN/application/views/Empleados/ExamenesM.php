 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Examenes medicos
        <small>Desktop</small>
      </h1>

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
<!-- <?php //var_dump($empleados);?> -->
    <!-- /Content Header (Page header) -->
<section class="content">
  <div class="row">
<section class="col-lg-12 connectedSortable">
<!--===========================================================================-->       
        <!-- Div 1 -->
          <div class="box box-primary">
            <!-- Cabeza -->
            <div class="box-header">
              <i class="fas fa-file-medical"></i>
              <h3 class="box-title">Formulario</h3>
              <!-- Minimizar -->
                <div class="pull-right box-tools">
                  <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
              <div class="row">
                <div class="col-sm-12">
                  <!--  -->
                  <div class="col-sm-6">
                    <!--  -->
                    <label for=""><strong>*</strong> Empleado</label>
                    <select id="empelados" class="form-control selectpicker" data-live-search="true">
                      <option value="0">Seleccione...</option>
                      <?php 
                      foreach ($empleados as $empleado) {
                        // Hasta acá se llego el 26/09/2018
                        echo '<option value="'.$empleado->documento.'" data-subtext="'.$empleado->documento.'">'.$empleado->nombre1.' '.$empleado->nombre2.' '.$empleado->apellido1.' '.$empleado->apellido2.'</option>';
                      }
                       ?>
                    </select>
                  </div>
                  <div class="col-sm-3">
                    <div>
                    <label><strong>*</strong> Tipo de examenes</label>
                    <form id="radiosTipo">
                      <label class="radio-inline">
                        <input type="radio" name="optradio" value="1">ExI
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="optradio" value="2">ExP
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="optradio" value="3">Otros
                      </label>
                    </form>  
                    </div>
                  </div>
                  <div class="col-sm-3">
                    <label>¿Cual Otro examen?</label>
                    <input type="text" name="otroExamen" id="otroExamen" class="form-control" placeholder="Examen de los ojos">
                  </div>
                  <!--  -->
                </div>
                <!--  -->
              </div>
              <br>
              <div class="row">
                <!--  -->
                <div class="col-sm-5">
                    <label><strong>*</strong> Motivo</label>
                    <div>
                      <textarea maxlength="250" id="textMotivo" style="width: 100%; height: 100px;"></textarea>
                    </div>
                </div>
                <div class="col-sm-6">
                  <div class="col-sm-6">
                    <label for="plazoFecha"><strong>*</strong> Fecha plazo</label>
                    <div class="input-group date fh-date">
                      <div class="input-group-addon">
                        <i class="fa fa-calendar"></i>
                      </div>
                      <input type="text" class="form-control pull-right" id="plazoFecha" readonly="true" placeholder="DD/MM/YYYY">
                    </div>
                  </div>
                  <div class="col-sm-6">
                    <label for="fechaRetorno"> Fecha de retorno</label>
                    <div class="input-group date fh-date">
                      <div class="input-group-addon">
                        <i class="fa fa-calendar"></i>
                      </div>
                      <input type="text" class="form-control pull-right" id="fechaRetorno" readonly="true" placeholder="DD/MM/YYYY">
                    </div>
                  </div>
                </div>
                <!--  -->
                <!-- <div class="col-sm-3">
                  <label>C.Uabilidad</label>
                     <textarea maxlength="250" style="width: 250px;"></textarea>
                </div> -->
              </div>
            </div>
            <!-- Pie -->
            <div class="box-footer">
              <div class="row">
                <div class="col-sm-12">
                  <!-- Columna 1 -->
                  <div class="col-sm-10">
                    <!-- Vacio -->
                    <div class="col-sm-3">
                      <!-- <a href="<?php //echo base_url();?>Empleado/cIncapacidades/descargarIncapacidadesExcel" target="_black">Incapacidades Excel...</a> -->
                    </div>
                  </div>
                  <!-- Columna 2 -->
                  <div class="col-sm-6">
                    <div class="col-sm-4">
                     <!--  <form id="Empleado" enctype="maletar/data-form" method="POST">
                        <input type="file" name="" id="">
                        <button class="" id="" name=""></button>
                      </form> -->
                      <a href="<?= base_url();?>Empleado/cExamenes/exportarDocumentoXLSX" target="_blank">Exportar excel...</a>
                    </div>
                  </div>
                  <div class="col-sm-6">
                    <div class="col-sm-3"></div>
                    <div class="col-sm-3"></div>
                    <div class="col-sm-3">
                      <button class="btn btn-info pull-right" data-idinc="0" id="limpiar">Limpiar</button>
                    </div>
                    <!-- Columna 3 -->
                    <div class="col-sm-3">
                      <button class="btn btn-info pull-right" value="0" data-idinc="0" id="accion">Realizar</button>
                    </div> 
                  </div>
                </div>
              </div>
              <!-- <button class="btn btn-primary" id="consultarDetallesEmpleado">Incapacidades</button> -->
            </div>
          </div>
        <!-- /Div 1 -->
        <!-- ... -->
        <!-- Div 2 -->
        <div class="box box-primary">
          <!-- Cabeza -->
          <div class="box-header">
            <i class="fas fa-file-medical"></i>
            <h3 class="box-title">Examenes</h3>
            <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                <i class="fa fa-minus"></i>
              </button>
            </div>
          </div>
          <!-- Cuerpo -->
          <div class="box-body">
            <!--  -->
            <div class="row">
              <div class="col-sm-12">
                <div class="table-responsive" id="tblExamenesEmpleados">
                  <!-- Tabla se los examenes medicos -->
                </div>
              </div>
            </div>
          </div>
          <!-- Pie -->
          <div class="box-footer">
            <!-- <button class="btn btn-info pull-right" id="accion">Realizar</button> -->
            <!-- <button class="btn btn-primary" id="consultarDetallesEmpleado">Incapacidades</button> -->
          </div>
        </div>
        <!-- /Div 2 -->

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