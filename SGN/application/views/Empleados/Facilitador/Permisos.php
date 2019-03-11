 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Permiso
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
    <style type="text/css">
    label strong{
      color: #FD0303;
    }
  .tamaño{
  font-size: 10px;
   padding: 3px;
 }

 #visualizarPermiso input[type="text"]{
    text-align: center;
 }
  </style>
<!--===========================================================================-->       
<!-- /Div 1 -->
          <!-- Div 2 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Permisos Empleados</h3>
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
<form class="form-horizontal">
    <!-- Horario Almuerzo-->
    <div class="form-group">
      <div class="col-lg-12">
        <div class="table-responsive" id="tblPermisosEmpelado">
          <!-- Tabla -->
        </div>
      </div>
    </div>
    <div class="box-footer">
      <div class="pull-right">
        <!-- <button type="button" class="btn btn-primary" id="btnActualizar">Actualizar</button> -->
      </div>
</div>
</form>
</div>
</div>
<!-- /Cuerpo -->
</div>
          <!-- Div 3 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Permisos rango de fechas</h3>
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
                <!-- Colum 1 -->
                <div class="col-sm-3">
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
<form class="form-horizontal">
    <!-- Horario Almuerzo-->
    <div class="form-group">
      <div class="col-lg-12">
        <br>
        <div class="table-responsive" id="tblPermisosEmpeladoFecha">
          <!-- Tabla -->
        </div>
      </div>
    </div>
    <div class="box-footer">
      <div class="pull-right">
        <button type="button"  class="btn btn-primary" id="btnConsultarFechas">Consultar</button>
      </div>
</div>
</form>
</div>
</div>
<!-- /Cuerpo -->
</div>

<!-- Modals -->
<!-- Preguntar momento. -->
<div class="modal fade" id="momentoPermiso">
  <div class="modal-dialog">
    <div class="modal-content">
      <!-- Header -->
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h2>¿Que quieres hacer?<small> El permiso es para:</small></h2>
      </div>
      <!-- Cuerpo -->
      <div class="modal-body">
        <div class="row">
          <!-- Boton 1 Salida temprano-->
          <div class="col-sm-4" align="center">
            <button type="button" value="1" class="btn btn-primary" id="btn1" onclick="registrarCodigoEmpleadoPermiso(this.value);">Salida Temprano.</button>
          </div><!-- Boton 2 Salida y llegada -->
          <div class="col-sm-4" align="center">
            <button type="button" value="2" class="btn btn-primary" id="btn2" onclick="registrarCodigoEmpleadoPermiso(this.value);">Salida y Llegada</button>
          </div><!-- Boton 3  Llegada tarde-->
          <div class="col-sm-4" align="center">
            <button type="button" value="3" class="btn btn-primary" id="btn3" onclick="registrarCodigoEmpleadoPermiso(this.value);">Llegada tarde.</button>
          </div>
        </div>
      </div>
      <!-- Footer -->
      <div class="modal-footer">

      </div>
    </div>
  </div>
</div>
        </section>
        <!-- Preguntar momento. -->
        <div class="modal fade" id="mostrarCodigo">
          <div class="modal-dialog">
            <div class="modal-content">
              <!-- Header -->
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h1 style="text-align: center;">El código es:</h1>
                <h2 id="mostrarC" style=" text-align: center;"></h2>
              </div>
              <!-- Footer -->
<!-- '<td>' + row.usuario + '</td>' -->
            </div>
          </div>
        </div>
        <!-- Modificar Permiso -->
<div class="modal fade" id="visualizarPermiso">
    <div class="modal-dialog">
        <div class="modal-content">
            <!-- Cabeza -->
            <div class="modal-header">
              <button type="button" aria-hidden="true" class="close" data-dismiss="modal">&times;</button>
              <h3 id="hPermiso">Permiso: </h3>
            </div>
            <!-- Cuerpo -->
            <div class="modal-body">
                <!-- Primera fila -->
                <div class="row">
                    <!-- Clasificado por -->
                    <div class="col-sm-6">
                      <label>Clasificado Por:</label>
                      <input type="text" id="clasificado" name="generadoPor" class="form-control" readonly="true">
                    </div>
                    <!-- Fecha solicitud -->
                    <div class="col-sm-6">
                        <label>Fecha Solicitud:</label>
                        <input type="text" id="fechaSolicitud" name="fechaM" class="form-control" readonly="true">
                    </div>
                </div>
                <br>
                <div class="row">
                  <!-- Fecha Permiso -->
                  <div class="col-sm-6">
                    <label for="">Fecha Permiso:</label>
                    <div class="input-group date fh-date" >
                      <input type="text" id="fechaPermiso" class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                    </div>              
                  </div>
                  <!-- Concepto permiso -->
                  <div class="col-sm-6">
                      <label>Concepto:</label>
                      <br>
                      <select class="form-control selectpicker" data-size="8" id="concepto" data-live-search="true">
                        <option value="0" >Seleccione...</option>
                      </select> 
                  </div>
                </div>
                <!-- Segunda fila -->
                <br>
                <div class="row">
                  <!-- Hora desde que va ha ser el permiso -->
                  <div class="col-sm-6">
                      <label>Hora Desde:</label>
                      <!-- <input type="text" id="horaDM" name="fechaM" class="form-control"> -->
                        <div class="input-group bootstrap-timepicker timepicker">
                           <span class="input-group-addon">
                            <i class="glyphicon glyphicon-time"></i>
                          </span>
                          <input id="desde" type="text" maxlength="8" class="form-control input-small timepicker">
                        </div>
                  </div>
                  <!-- Momento del permso -->
                    <div class="col-sm-6">
                        <label>Momento:</label>
                        <br>
                        <select class="form-control selectpicker" data-size="8" id="momento" data-live-search="true">
                        <!-- Selector buscar de productos -->
                        <option value="0">Seleccione...</option>
                        <option value="1">Salida Temprano</option>
                        <option value="2">Ingreso Tarde</option>
                        <option value="3">Salida e Ingreso</option>
                        </select> 
                    </div>
                </div>
                <!-- Tercera fila -->
                <br>
                <div class="row">
                    <!-- Hasta -->
                    <div class="col-sm-6">
                        <label>Hora Hasta:</label>
                        <div class="input-group">
                           <span class="input-group-addon">
                            <i class="glyphicon glyphicon-time"></i>
                          </span>
                          <input id="hasta" type="text" maxlength="8" class="form-control input-small" readonly="true">
                        </div>
                    </div>
                    <!-- Numero de horas del permiso -->
                    <div class="col-sm-6">
                      <label>Numero de horas:</label>
                      <div class="input-group">
                         <span class="input-group-addon">
                          <i class="glyphicon glyphicon-time"></i>
                        </span>
                        <input id="numeroHoras" type="text" maxlength="8" class="form-control input-small" readonly="true">
                      </div>
                    </div>
                </div>
                <br>
                <!-- Cuarta Fila -->
                <div class="row" id="descripcionM">
                    <div class="col-sm-12">
                        <label>Descripción:</label>
                        <br>
                        <textarea id="descripcion" class="form-control" maxlength="100" style="height: 5em;"></textarea>
                    </div>
                </div>
            </div>
            <!-- Footer -->
            <div class="modal-footer">
                <button class="btn btn-warning pull-right" type="button" name="" id="btnActualizarInfoPermiso">Actualizar</button>
            </div>
        </div>
    </div>
</div>