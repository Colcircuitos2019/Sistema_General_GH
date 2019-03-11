 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="far fa-address-book"></i>
        Incapacidades
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

  .centradotext{
   text-align: center;
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
              <div class="box-body no-padding">
                  <!-- Contenido -->
                   <div id="incapacidades">
                    <!-- Primera fila -->
                    <div class="row">
                      <!-- Primera columna -->
                      <div class="col-sm-6">
                        <label><strong>*</strong>Empleado</label>
                          <select  class="form-control selectpicker" name="empleado" data-live-search="true" id="empleado" onchange="calcularDiferenciasFechas()">
                            <option value="0">Seleccione...</option>
                            <?php foreach ($empleados as $row) {
                              // ...
                              echo '<option value="'.$row->documento.'" data-subtext="'.$row->documento.'" data-salariob="'.$row->salario_basico.'">'.$row->nombre1.' '.$row->nombre2.' '.$row->apellido1.' '.$row->apellido2.'</option>';
                              // ...
                            }?>
                            <!-- <option value="1"></option>
                            <option value="2"></option> -->
                          </select>
                        <span><i class=""></i></span>
                      </div>
                      <!-- Segunda columna -->
                      <div class="col-sm-6">
                        <!-- Primera columna -->
                        <div class="col-sm-6">
                          <label for="fechaI"><strong>*</strong>Fecha de incapacidad</label>
                          <div class="input-group date fh-date">
                            <div class="input-group-addon">
                              <i class="fa fa-calendar"></i>
                            </div>
                            <input type="text" class="form-control pull-right fecha" data-input="1" id="fechaI" placeholder="DD-MM-YYYY" maxlength="10" onchange="calcularDiferenciasFechas();" readonly="true">
                          </div>
                        </div>
                        <!-- Segunda columna -->
                        <div class="col-sm-6">
                          <label for="fechaF"><strong>*</strong>Fecha fin de incapacidad</label>
                          <div class="input-group date fh-date">
                            <div class="input-group-addon">
                              <i class="fa fa-calendar"></i>
                            </div>
                            <input type="text" class="form-control pull-right fecha" data-input="2" id="fechaF" placeholder="DD-MM-YYYY" maxlength="10" onchange ="calcularDiferenciasFechas();" readonly="true">
                          </div>
                        </div>
                      </div>
                    </div>
                    <br>
                    <!-- Segunda fila -->
                    <div class="row">
                      <!-- Primera columna -->
                      <div class="col-sm-2">
                        <label for="valorEPS">Valor a cargo de la EPS</label>
                        <div class="input-group">
                          <span class="input-group-addon"><i class="fas fa-dollar-sign"></i></span>
                          <input type="text" name="valorEPS" id="valorEPS" class="form-control" style="text-align: center;" maxlength="13" readonly="true">
                        </div>
                      </div>
                      <!-- Segunda columna -->
                      <div class="col-sm-2">
                        <label for="valorEmpr">Valor a cargo de la empresa</label>
                        <div class="input-group">
                          <span class="input-group-addon"><i class="fas fa-dollar-sign"></i></span>
                          <input type="text" name="valorTotal" id="valorEmpr" class="form-control" style="text-align: center;" maxlength="13" readonly="true">
                        </div>
                      </div>
                      <!-- tercera columna -->
                      <div class="col-sm-2">
                        <label for="valorARL">Valor a cargo de el ARL</label>
                        <div class="input-group">
                          <span class="input-group-addon"><i class="fas fa-dollar-sign"></i></span>
                          <input type="text" name="valorTotal" id="valorARL" class="form-control" style="text-align: center;" maxlength="13" readonly="true">
                        </div>
                      </div>
                      <!-- Tercera columna -->
                      <div class="col-sm-6">
                        <!-- Primera columna -->
                        <div class="col-sm-6">
                          <label for="diagnostico">Día inicio de la incapacidad</label>
                          <input type="text" name="diaInicio" id="diaInicio" readonly="true" class="form-control">
                        </div>
                        <!-- Segunda columna -->
                        <div class="col-sm-6">
                          <label for="diasIncapacidad">Día fin de la incapacidad</label>
                          <input type="text" name="dias" id="diaFin" class="form-control" style="text-align: center;" maxlength="4" readonly="false">
                        </div>
                      </div>
                    </div>
                    <br>
                    <!-- Tercera fila -->
                    <div class="row">
                      <!-- Primera columna -->
                      <div class="col-sm-6">
                        <label for="valorT" id="labelPrecioTotal">Precio total incapacidad</label>
                        <input type="text" name="valorT" id="valorT" readonly="true" class="form-control" style="text-align: center">
                        <br>
                        <!-- Segundo columna -->
                        <div class="col-sm-12">
                          <label for="descripccion">Descripcción</label>
                          <textarea class="form-control" id="descripccion" maxlength="100" style="height: 5em;"></textarea>
                        </div>
                      </div>
                      <!-- Tercero columna -->
                      <div class="col-sm-6">
                        <div class="row">
                          <!-- Primera columna -->
                          <div class="col-sm-9">
                            <label for="diagnostico"><strong>*</strong>Diagnostico</label>
                            <select class="form-control selectpicker" name="" id="diagnostico" data-live-search="true">
                              <option value="0">Seleccione...</option>
                              <?php foreach ($diagnosticos as $row) {
                               echo "<option value=".$row->idDiagnostico." data-subtext=".$row->idDiagnostico.">".$row->diagnostico."</option>";
                              } ?>
                            </select>
                          </div>
                          <!-- Segunda columna -->
                          <div class="col-sm-3">
                            <label for="diasIncapacidad">Dias</label>
                            <input type="text" name="dias" id="diasIncapacidad" class="form-control" style="text-align: center;" maxlength="4" readonly="false">
                          </div>
                        </div>
                        <br>
                        <div class="input-group">
                          <div class="col-sm-6">
                            <label><strong>*</strong>Tipo de incapacidad:</label>
                            <select name="TipoIncapacidad" id="tipoIncapacidad" class="form-control" onchange="calcularDiferenciasFechas();">
                              <option value="0">Seleccione...</option>
                              <option value="1">General</option>
                              <option value="2">Trabajo</option>
                              <option value="3">licencia M/P</option>
                            </select>
                          </div>
                          <div class="col-sm-6">
                            <label><strong>*</strong>Clasificación:</label>
                            <select name="EnfermedadI" id="enfermedad" class="form-control">
                              <option value="0">Seleccione...</option>
                              <option value="1">Inicial</option>
                              <option value="2">Prorroga</option>
                            </select>
                          </div>
                        </div>
                      </div>
                    </div>
                    <!--  -->
                   </div>                   
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
                      <a href="<?php echo base_url();?>Empleado/cIncapacidades/descargarIncapacidadesExcel" target="_black">Incapacidades Excel...</a>
                    </div>
                  </div>
                  <!-- Columna 2 -->
                  <div class="col-sm-1">
                    <button class="btn btn-info pull-right" data-idinc="0" id="limpiar">Limpiar</button>
                  </div>
                  <!-- Columna 3 -->
                  <div class="col-sm-1">
                    <button class="btn btn-info pull-right" value="0" data-idinc="0" id="accion">Realizar</button>
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
            <h3 class="box-title">Incapacidades</h3>
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
                <div class="table-responsive" id="tblIncapacidades">
                  
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