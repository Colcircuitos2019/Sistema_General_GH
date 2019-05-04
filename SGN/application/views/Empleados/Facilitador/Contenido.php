
<style type="text/css">
  .tamaño{
   font-size: 10px;
   padding: 3px;
 }

 .inputs{
  width: 70px;
 }

 .form-group input[type="checkbox"] {
     display: none;
 }

 .form-group input[type="checkbox"] + .btn-group > label span {
     width: 20px;
 }

 .form-group input[type="checkbox"] + .btn-group > label span:first-child {
     display: none;
 }
 .form-group input[type="checkbox"] + .btn-group > label span:last-child {
     display: inline-block;   
 }

 .form-group input[type="checkbox"]:checked + .btn-group > label span:first-child {
     display: inline-block;
 }
 .form-group input[type="checkbox"]:checked + .btn-group > label span:last-child {
     display: none;   
 }

</style>
 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
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
  <section class="col-lg-6 connectedSortable">
  <!--===========================================================================-->       
  <!-- Div 1 -->
  <div class="box box-primary">
     <div class="box-header">
      <i class="fas fa-wrench"></i>
      <h3 class="box-title">Configuración Horario</h3>
      <!-- Minimizar -->
      <div class="pull-right box-tools">
        <button type="button" class="btn btn-box-tool" data-widget="collapse">
        </button>
      </div>
    </div>
    <!-- Cuerpo -->
    <div class="box-body">
      <div class="row">
        <!-- Material unchecked -->
        <div class="col-md-6 col-sm-12">
          <div class="[ form-group ]">
            <input type="checkbox" name="fancy-checkbox-default" id="fancy-checkbox-default" autocomplete="off"/>
            <div class="[ btn-group ]">
              <label for="fancy-checkbox-default" class="[ btn btn-default ]">
                <span class="[ glyphicon glyphicon-ok ]"></span>
                <span> </span>
              </label>
              <label for="fancy-checkbox-default" class="[ btn btn-default active ]"><!--Quitar el Capitalize de toda la pagina HTML-->
                ¿Hoy hay horas extras?
              </label>
            </div>
          </div>
        </div>
        <div class="col-md-6 col-sm-12">
          <label for="horaFinHorasExtra">Hora de finalización</label>
          <input type="text" name="horario" class="form-group timepicker" data-tiempo="01:02:00" maxlength="8" id="horaFinHorasExtra">
        </div>
      </div>
    </div>
    <!-- Footer -->
    <div class="box-footer" id="butonA">
      <!--  -->
      <div class="pull-right">
        <button type="button" class="btn btn-primary" id="btnRealizarA">Aceptar</button>
      </div>
    </div>
  </div>
  <!-- Div 1 -->
  </section>
</div>

<div class="row">
<section class="col-lg-12 connectedSortable">
<!--===========================================================================-->       
<!-- Div 1 -->
<div class="box box-primary">
   <div class="box-header">
    <i class="fas fa-people-carry"></i>
    <h3 class="box-title">Empleados Horas extras</h3>
    <!-- Minimizar -->
    <div class="pull-right box-tools">
      <button type="button" class="btn btn-box-tool" data-widget="collapse">
        <i class="fa fa-minus"></i>
      </button>
    </div>
  </div>
  <!-- Cuerpo -->
  <div class="box-body">
    <div class="table-responsive">
      <div class="col-sm-12" id="tableExtras">
      <!-- ... -->
      <!-- ... -->
      </div>
    </div>
  </div>
  <!-- Footer -->
  <div class="box-footer" id="butonA">
    <!--  -->
    <div class="pull-right">
      <button type="button" class="btn btn-primary" id="btnRealizarA">Realizar</button>
    </div>
  </div>
</div>
<!-- Div 1 -->
</section>
        
</div>

<!-- Modals============================================================ -->
<div class="modal fade" id="MensajeD">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button onclick="" type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h2>¿Por qué no aceptaras las horas extras de este empleado.?</h2>
      </div>
      <div class="modal-body">
        <div class="row">
          <div class="col-sm-12">
            <label><strong>*</strong>Descripción:</label><br>
            <textarea style="width: 100%; height: 6em;" maxlength="100" id="description"></textarea>
          </div>    
        </div>
      </div>
      <div class="modal-footer">

            <button type="button" class="btn btn-primary" id="guardarMensaje">Listo</button>

      </div>
    </div>
  </div>
</div>