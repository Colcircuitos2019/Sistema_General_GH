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
  <style type="text/css">
    .tamaño{
     font-size: 10px;
     padding: 3px;
   }

   .inputs{
    width: 70px;
   }
  </style>
<!-- Cuerpo -->
<div class="box-body">
  <div class="table-responsive">
    <div class="col-sm-12" id="tableExtras">
     <!-- ... -->
     <!-- ... -->
    </div>
  </div>
</div>
<div class="box-footer" id="butonA">
  <!--  -->
  <div class="pull-right">
        <button type="button" class="btn btn-primary" id="btnRealizarA">Realizar</button>
      </div>
</div>
<!-- /Cuerpo -->
</div>
        <!-- Div 1 -->
        </section>

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

        
    </div>