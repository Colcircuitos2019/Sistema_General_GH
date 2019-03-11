 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-address-book"></i>
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
  </style>
<!--===========================================================================-->       
          <!-- Div 1 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Generador de códigos</h3>
              <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" onc class="btn btn-box-tool" data-widget="collapse">
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
        <div class="table-responsive" id="tblEmpleadosPermiso">
         <!-- Tabla --> 
        </div>
      </div>
    </div>
    <div class="box-footer">
      <!-- <div class="pull-right">
        <button type="button" class="btn btn-primary" id="btnActualizar">Actualizar</button>
      </div> -->
</div>
</form>
</div>
</div>

<!-- /Cuerpo -->
</div>
<!-- /Div 1 -->
          <!-- Div 2 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Codigos-<small>Permisos</small></h3>
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
        <div class="table-responsive" id="tblCodigosPermisos">
          <!-- Tabla -->
        </div>
      </div>
    </div>
    <div class="box-footer">
      <!-- <div class="pull-right">
        <button type="button" class="btn btn-primary" id="btnActualizarC">Actualizar</button>
      </div> -->
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
              <div class="col-sm-3">
                <button type="button" class="btn btn-primary" id="btnConsultarFechas">Buscar</button>
              </div>
                 <br>
<form class="form-horizontal">
    <!-- Horario Almuerzo-->
    <div class="form-group">
      <div class="col-lg-12">
        <br>
        <div class="table-responsive" id="tblCodigosPermisosFechas">
          <!-- Tabla -->
        </div>
      </div>
    </div>
    <div class="box-footer">
      <div class="pull-right">
        
      </div>
</div>
</form>
</div>
</div>
<!-- /Cuerpo -->
</div>
<!-- Modals -->
<div class="modal fade">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Detalle Permiso</h2>
      </div>
      <!-- Cuerpos -->
      <div class="modal body">
        
      </div>
      <!-- Pie -->
      <div class="modal footer">
        
      </div>
    </div>
  </div>
</div>
        </section>
<!-- Modificar Permiso -->
<div class="modal fade" id="visualizarPermiso">
    <div class="modal-dialog">
        <div class="modal-content">
            <!-- Cabeza -->
            <div class="modal-header">
              <button type="button" aria-hidden="true" class="close" data-dismiss="modal">&times;</button>
              <h2 id="hPermiso"></h2>
            </div>
            <!-- Cuerpo -->
            <div class="modal-body">
                <!-- Primera fila -->
                <div class="row">
                    <!-- Código -->
                    <div class="col-sm-4">
                        <label style="width: 100%; text-align: center;">Código:</label>
                        <h2 style="width: 100%; height: 60%; text-align: center; border-bottom: solid 0.5px;" id="code">Código</h2>
                    </div>
                    <!-- Fecha solicitud -->
                    <div class="col-sm-4">
                        <label>Fecha Solicitud:</label>
                        <input type="text" id="fechaSM" name="fechaM" class="form-control" readonly="true">
                    </div>
                    <!-- Fecha Permiso -->
                    <div class="col-sm-4">
                        <label>Fecha Permiso:</label>
                        <!-- <input type="text" id="fechaPM" name="fechaP" class="form-control"> -->
                            <input class="form-control" id="fechaPM" type="text" readonly="true">
                            </input>   
                    </div>
                </div>
                <!-- Segunda fila -->
                <br>
                <div class="row">
<!--                     <div class="col-sm-6">
                        <label>Solicitante</label>
                        <br>
                        <input type="text" name="Solicitante" class="form-control" readonly="true">
                    </div> -->
                    <div class="col-sm-8">
                        <label>Concepto:</label>
                        <br>
                        <input type="text" name="" class="form-control" id="conceptoM" readonly="true">
                        <!-- <input type="text" id="conceptoM" name="Solicitante" class="form-control"> -->
                    </div>
                    <div class="col-sm-4">
                        <label>Momento:</label>
                        <br>
                        <h4 id="momentoN">Salida temprano</h4>
                    </div>
                </div>
                <!-- Tercera fila -->
                <br>
                <div class="row">
                    <!-- Hora desde que va ha ser el permiso -->
                    <div class="col-sm-5">
                        <label>Hora Desde:</label>
                        <!-- <input type="text" id="horaDM" name="fechaM" class="form-control"> -->
                               <input id="horaDM" type="text" class="form-control" readonly="true">
                    </div>
                    <!-- Espacio -->
                    <div class="col-sm-2">
                        
                    </div>
                    <!-- Hasta -->
                    <div class="col-sm-5">
                        <label>Hora Hasta:</label>
                        <input type="text" id="horaHM" name="fechaP" class="form-control" readonly="true"> 
                    </div>
                </div>
                <br>
                <!-- Cuarta fila -->
                <div class="row">
                  <div class="col-sm-4"></div>

                  <div class="col-sm-4">
                    <label>Hora Hasta:</label>
                    <input type="text" id="horaHM" name="fechaP" class="form-control" readonly="true">
                  </div>

                  <div class="col-sm-4"></div>
                </div>
                <!-- Quinta Fila -->
                <div class="row" id="descripcionM">
                    <div class="col-sm-12">
                        <label>Descripción:</label>
                        <br>
                        <textarea id="descripM" class="form-control" style="height: 10em;" readonly="true"></textarea>
                    </div>
                </div>
            </div>
            <!-- Footer -->
            <div class="modal-footer">
                <!-- <button class="btn btn-warning" type="button" name="" id="btnActualizar">Actualizar</button> -->
            </div>
        </div>
    </div>
</div>