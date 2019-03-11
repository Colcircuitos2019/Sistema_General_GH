 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Configuracion
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
        <section class="col-lg-12 connectedSortable">
          <!-- Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
          <!-- Div 1-->
          <div class="box box-info">
            <div class="box-header">
              <i class="fa fa-envelope"></i>
              <h3 class="box-title">Restriccion de tiempo de pedidos</h3>
              <!-- btn X -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
              <!-- /.btn X -->
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
              <!-- form Persona -->
              <form action="<?php echo base_url();?>cCiudad/registrarCiudad" method="POST" class="form-horizontal" id="formCiudad">
                <!-- input Nombres -->
                <div class="form-group">
                  <label for="timepicker1" class="col-sm-3 control-label">Hora inicio:</label>
                  <div class="col-sm-7">
                      <div class="input-group bootstrap-timepicker timepicker">
                       <input id="timepicker1" type="text" maxlength="8" class="form-control input-small timepicker">
                         <span class="input-group-addon">
                            <i class="glyphicon glyphicon-time"></i>
                         </span>
                      </div>
                  </div>
                </div>
                <div class="form-group">
                  <label for="timepicker2" class="col-sm-3 control-label">Hora fin:</label>
                  <div class="col-sm-7">
                      <div class="input-group bootstrap-timepicker timepicker">
                       <input id="timepicker2" type="text" maxlength="" class="form-control input-small timepicker">
                         <span class="input-group-addon">
                            <i class="glyphicon glyphicon-time"></i>
                         </span>
                      </div>
                  </div>
                </div>
                <div class="form-group">
                  <label for="timepicker3" class="col-sm-3 control-label">Hora inicio pedido siguiente día:</label>
                  <div class="col-sm-7">
                      <div class="input-group bootstrap-timepicker timepicker">
                       <input id="timepicker3" type="text" maxlength="" class="form-control input-small timepicker">
                         <span class="input-group-addon">
                            <i class="glyphicon glyphicon-time"></i>
                         </span>
                      </div>
                  </div>
                </div>
                <div class="form-group">
                  <label for="timepicker4" class="col-sm-3 control-label">Hora fin pedido siguiente día:</label>
                  <div class="col-sm-7">
                      <div class="input-group bootstrap-timepicker timepicker">
                       <input id="timepicker4" type="text" maxlength="" class="form-control input-small timepicker">
                         <span class="input-group-addon">
                            <i class="glyphicon glyphicon-time"></i>
                         </span>
                      </div>
                  </div>
                </div>
                <!-- input submit -->
                 <div class="box-footer clearfix">
                   <button type="button" class="pull-right btn btn-info" id="sendInfo">Modificar
                   <i class="fa fa-arrow-circle-right"></i></button>
                 </div>
              </form>
             <!-- Script -->
            <script type="text/javascript">
            $('.timepicker').timepicker({
                minuteStep: 1,
                template: 'modal',
                appendWidgetTo: 'body',
                showSeconds: true,
                showMeridian: false,
                defaultTime: false
            });
           </script>
             <!-- /Script -->
              <!-- /form Persona -->
            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- /Div 1-->
          <!-- /Formulario de Registrar Persona XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-->
        </section>
        <!-- /.Left col (Formularios de izquierda)-->
    </div>