 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-cogs"></i>
        Horarios de trabajo
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
              <h3 class="box-title">Formulario Configuracion</h3>
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
  </style>
<!-- Cuerpo -->
<div class="box-body">
  <div class="col-sm-12">
<form class="form-horizontal">
  <!-- Horario laboral -->
  <div class="form-group">
    <div class="col-sm-3">
      <label class="pull-right"><strong>*</strong>Nombre Horario:</label>
    </div>
    <div class="col-sm-9">
      <input type="text" name="nameHorario" class="form-control" id="nameHorario" maxlength="60">
    </div>
  </div>
    <div class="form-group">
        <label class="control-label col-sm-3"><strong>*</strong>Hora de ingreso laboral:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="HIL" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
        <label class="control-label col-sm-3"><strong>*</strong>Hora de salida laboral:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="HFL" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
      </div><br>
    <!-- Horario desayuno -->
    <div class="form-group">
        <label class="control-label col-sm-3"><strong>*</strong>Hora inicio desayuno:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="HID" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
        <label class="control-label col-sm-3"><strong>*</strong>Hora fin desayuno:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="HFD" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
    </div><br>
    <!-- Horario Almuerzo-->
    <div class="form-group">
        <label class="control-label col-sm-3"><strong>*</strong>Hora inicio Almuerzo:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="HIA" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
        <label class="control-label col-sm-3"><strong>*</strong>Hora fin Almuerzo:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="HFA" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
    </div><br>
    <!-- Horario Almuerzo-->
    <div class="form-group">
        <label class="control-label col-sm-3"><strong>*</strong>Tiempo de desayuno:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="TD" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
        <label class="control-label col-sm-3"><strong>*</strong>Tiempo de Almuerzo:</label>
        <div class="col-sm-3">
          <div class="input-group bootstrap-timepicker timepicker">
             <input id="TA" type="text" maxlength="8" class="form-control input-small timepicker">
             <span class="input-group-addon">
              <i class="glyphicon glyphicon-time"></i>
            </span>
          </div>
        </div>
    </div><br>
    <div class="box-footer">
      <div class="pull-right">
        <button type="button" class="btn btn-primary" id="limpiarF">Limpiar</button>
        <button type="button" class="btn btn-primary" value="0" id="btnAcccion">Registrar</button>
      </div>
</div>
</form>
</div>
</div>
<!-- /Cuerpo -->
</div>
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Horarios de trabajo</h3>
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
  </style>
<!-- Cuerpo -->
<div class="box-body">
  <div class="col-sm-12">
    <div class="table-responsive" id="tablaHorarios">
      
    </div>
  </div>
</div>
<!-- /Cuerpo -->
</div>
          <!-- Div 1 -->
        </section>