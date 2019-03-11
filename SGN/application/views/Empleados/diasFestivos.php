 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <span><i class="fas fa-cogs"></i></span>&nbsp;Configuración Días Festivos
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
              <i class="fas fa-gift"></i>
              <h3 class="box-title">Formulario de Dias Festivos</h3>
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
<form class="form-horizontal" id="diasFestivosForm">
  <!--  -->
  <div class="form-group">
      <label class="control-label col-sm-2" for="nombreDia"><strong>*</strong>Nombre:</label>
      <div class="col-sm-5">
        <div class="input-group">
           <span class="input-group-addon"><i class="fas fa-gift"></i></i></span>
           <input type="text" id="nombreDia" autocomplete="off" class="form-control" maxlength="60" placeholder="Acción del día festivo">
        </div> 
      </div>
      <label class="control-label col-sm-1" for="diagnostico"><strong>*</strong>Fecha:</label>
      <div class="col-sm-3">
        <!-- <label for="vigenciAlturas">Vigencia curso de alturas</label> -->
        <!-- <input type="text" name="vigenciAlturas" id="vigenciAlturas" class="form-control"> -->
        <div class="input-group date fh-date">
          <div class="input-group-addon">
            <i class="fa fa-calendar"></i>
          </div>
          <input type="text" class="form-control pull-right" id="fechaDia" placeholder="DD-MM-YYYY" readonly="true">
        </div>
      </div>
  </div> 
  <!--  -->      
</form>

<!-- <a href="<?php //echo base_url(); ?>cEmpleado/reporteEmpleados" target="_blank">Descargar excel</a>  -->
</div>
</div>
<div class="box-footer">
  <!--  -->
  <div class="row">
    <div class="col-sm-12">
      <div class="pull-right">
        <button type="button" class="btn btn-info" id="limpiarFormulario" value="0">Limpiar</button>
        <button type="button" class="btn btn-primary" id="EnviarA" value="0">Registrar</button>
      </div>      
    </div>
  </div>
</div>
<!-- /Cuerpo -->
</div>

<div class="box box-info">
  <div class="box-header">
    <i class="fas fa-user"></i>
    <h3 class="box-title"> Empleado <small>Información principal basica.</small></h3>
    <!-- Minimizar -->
    <div class="pull-right box-tools">
      <!-- <button type="button" class="btn btn-box-tool" data-widget="collapse"> -->
        <!-- <i class="fa fa-minus"></i> -->
      <!-- </button> -->
    </div>
  </div>
  <!-- Cuerpo -->
  <div class="box-body">
    <div class="row">
      <div class="col-sm-12">
        <div class="table_responsive" id="DiasFestivos">
          <!-- -.-.-.-. -->
        </div>
      </div>
    </div>
  </div>
  <!-- /Cuerpo -->
  <!-- Footer -->
  <div class="box-footer">
    
  </div>
  <!-- /footer -->
</div>
        <!-- Div 1 -->
        </section>
