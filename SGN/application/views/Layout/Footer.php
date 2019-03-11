      </section>
    <!-- Main content -->
  </div>
<!-- /.content wrapper-->
<!-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> -->
    <footer class="main-footer">
    <div class="pull-right hidden-xs">
      <b>Version</b> 1.0
    </div>
    <strong>Copyright &copy;.</strong> Clasulas de privacidad <button type="button" id="btnClausulas" style="background: none; outline: none; border-radius: 10px;"><i class="fas fa-question-circle" style="cursor: hand;" id=""></i></button>
  </footer>
<div class="modal fade" id="notificacion">
   <div class="modal-dialog modal-lg">
     <div class="modal-content">
      <!-- Cabeza -->
      <div class="modal-header">
        <button type="button"  class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h2 id="tituloM">Notificación</h2>
      </div>
      <!-- Cuerpo -->
       <div class="modal-body">
         <div class="table-responsive" id="tblPersonas">
           
         </div>
       </div>
       <!-- Footer -->
       <div class="modal-footer">
         
       </div>
     </div>
   </div>
</div>

<style>

html, body{
  text-transform: capitalize;
}

.tooltip {
    position: relative;
    display: inline-block;
    border-bottom: 1px dotted black;
}

.tooltip .tooltiptext {
    visibility: hidden;
    width: 120px;
    background-color: #555;
    color: #fff;
    text-align: center;
    border-radius: 6px;
    padding: 5px 0;
    position: absolute;
    z-index: 1;
    bottom: 125%;
    left: 50%;
    margin-left: -60px;
    opacity: 0;
    transition: opacity 0.3s;
}

.tooltip .tooltiptext::after {
    content: "";
    position: absolute;
    top: 100%;
    left: 50%;
    margin-left: -5px;
    border-width: 5px;
    border-style: solid;
    border-color: #555 transparent transparent transparent;
}

.tooltip:hover .tooltiptext {
    visibility: visible;
    opacity: 1;
}

label strong{
    color: #FD0303;
}

.tamaño{
   font-size: 10px;
   padding: 3px;
}
</style>

<!-- jQuery UI 1.11.4 -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/jquery-ui/jquery-ui.min.js"></script>
<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
<script>
  $.widget.bridge('uibutton', $.ui.button);
</script>
<!-- Bootstrap 3.3.7 -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
<!-- Morris.js charts -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/raphael/raphael.min.js"></script>
<script src="<?= base_url(); ?>assets/Librerias/bower_components/morris.js/morris.min.js"></script>
<!-- Sparkline -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/jquery-sparkline/dist/jquery.sparkline.min.js"></script>
<!-- jvectormap -->
<script src="<?= base_url(); ?>assets/Librerias/plugins/jvectormap/jquery-jvectormap-1.2.2.min.js"></script>
<script src="<?= base_url(); ?>assets/Librerias/plugins/jvectormap/jquery-jvectormap-world-mill-en.js"></script>
<!-- jQuery Knob Chart -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/jquery-knob/dist/jquery.knob.min.js"></script>
<!-- daterangepicker -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/moment/min/moment.min.js"></script>
<script src="<?= base_url(); ?>assets/Librerias/bower_components/bootstrap-daterangepicker/daterangepicker.js"></script>
<!-- datepicker -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js"></script>
<!-- Bootstrap WYSIHTML5 -->
<script src="<?= base_url(); ?>assets/Librerias/plugins/bootstrap-wysihtml5/bootstrap3-wysihtml5.all.min.js"></script>
<!-- Slimscroll -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/jquery-slimscroll/jquery.slimscroll.min.js"></script>
<!-- Chart JS -->
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.js"></script> -->
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.4.0/Chart.min.js"></script> -->
<!-- <script src="<?php //echo base_url();?>assets/charts/Chart.Bubble.js"></script> -->
<!-- FastClick -->
<script src="<?= base_url(); ?>assets/Librerias/bower_components/fastclick/lib/fastclick.js"></script>
<!-- AdminLTE App -->
<script src="<?= base_url(); ?>assets/Librerias/dist/js/adminlte.min.js"></script>
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->
<script src="<?= base_url(); ?>assets/Librerias/dist/js/pages/dashboard.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="<?= base_url(); ?>assets/Librerias/dist/js/demo.js"></script>
<!-- Mis librerias adicionales ===================================================================================================== -->
<script src="<?= base_url(); ?>js/general.js"></script>
<!--Sweet Alert Library  <script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>-->
<script src="<?= base_url(); ?>js/sweetalert2.all.js"></script>
<!-- Font Awesome -->
<script src="<?= base_url(); ?>img/js/fontawesome-all.js"></script>
<!--  -->
<!-- Moment js -->
<!-- fullCalendar -->
<!-- <script src="<?php //echo base_url();?>assets/bower_components/moment/moment.js"></script>
<script src="<?php //echo base_url();?>assets/bower_components/fullcalendar/dist/fullcalendar.min.js"></script>
 -->
 <style type="text/css">
   .swal2-popup .swal2-content {
       justify-content: center;
       margin: 0;
       padding: 0;
       color: #545454;
       font-size: 1.4em;
       font-weight: 300;
       line-height: normal;
       word-wrap: break-word;
   }
 </style>
 <!-- Base url -->
<script type="text/javascript">
    var baseurl= '<?php echo base_url();?>';
    var usuario= '<?php echo $this->session->userdata('idUser'); ?>';
    var tipo_usuario= '<?php echo $this->session->userdata('tipo_usuario'); ?>';

    var dateToday = new Date();
     //DateTimePiker
     $('.fh-date').datepicker({
       format: "dd-mm-yyyy",
       numberOfMonths: 3,
       showButtonPanel: true,
       minDate: 0//Validar que no permita el ingreso de fechas anteriores.
       // todayBtn: "linked"
    });
     // ...
     function calcularDiaDeSemana(fecha) {
      var fecha = fecha.split('-');
         var dias=["Domingo", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"];
         var dt = new Date(fecha[1]+' '+fecha[0]+', '+fecha[2]);
         var text = dias[dt.getUTCDay()];
         // ...
         return text;
     }
     //...
     $('#btnClausulas').click(function(event) {
       $('#modalClausulas').modal('show');
     });
     // ...
</script>
<!--<script src="<?php //echo base_url();?>boostrap/boostrapTabla/bootstrap.min.js"></script>-->
<!--  -->
<?php if($this->uri->segment(3)=='proveedor'){ ?>
<!-- Funcionalidades de la vista proveedores  -->
<script src="<?= base_url(); ?>js/Alimentacion/Proveedor.js"></script>
<?php }?>

<?php if($this->uri->segment(3)=='Producto'){ ?>
<!-- Funcionalidades de la vista de productos -->
<script src="<?= base_url(); ?>js/Alimentacion/Productos.js" ></script>
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js"></script> -->
<?php }?>
</body>

<?php if($this->uri->segment(3)=='configuracion'){ ?>
<!-- Funcionalidades de la vista de configuracion (restricciones) -->
<script src="<?= base_url(); ?>js/Alimentacion/Configuracion.js"></script>
<?php }?>

<?php if($this->uri->segment(3)=='pedidos1'){ ?>
<!-- Reporte de los pedidos -->
<script src="<?= base_url(); ?>js/Alimentacion/pedidos1.js"></script>
<!-- js datapiker -->
<script src="<?= base_url(); ?>boostrap/bootstrapdataPiker/js/bootstrap-datepicker.min.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cAsistencia'){ ?>
<!-- Funcionalidades de la vista de asistencia-->
<script src="<?= base_url(); ?>js/Empleados/Asistencia.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cMenu' && $this->session->userdata('tipo_usuario')==6){ ?>
<!-- Menu principal de el logion-->
<script src="<?= base_url(); ?>js/Empleados/Contenido.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cEmpleado' || $this->session->userdata('tipo_usuario')==7){ ?>
<!-- Funcionalidades de la vista de empleados-->
<script src="<?= base_url(); ?>js/Empleados/Empleado.js"></script>
<script src="<?= base_url(); ?>js/Empleados/empleado_horario.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cUsuario'){ ?>
<!-- Funcionalidades de la vista de usuarios-->
<script src="<?= base_url(); ?>js/Empleados/Usuario.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cCalendario'){ ?>
<!-- Funcionalidades de la vista del calendario-->
<script src="<?= base_url(); ?>js/Empleados/Calendario.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cConfiguracion'){ ?>
<!-- Funcionalidades de la vista de configuracion-->
<script src="<?= base_url(); ?>js/Empleados/Configuracion.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cPermiso'){ ?>
<!-- Funcionalidades de la vista de Permiso admin --> 
<script src="<?= base_url(); ?>js/Empleados/permisosCompartido.js"></script> 
<script src="<?= base_url(); ?>js/Empleados/permisoFacilitador.js"></script>
<?php }?>

<?php if($this->uri->segment(2)=='cFichaE'){ ?>
<!-- Funcionalidades de la vista de Permiso admin -->  
<script src="<?= base_url(); ?>js/FichaSDG/fichaSDG.js"></script>
<?php }?>

<!-- Funcionalidades de la vista de  Incapacidades-->
<?php if ($this->uri->segment(2)=='cIncapacidades') {?>
<script src="<?= base_url(); ?>js/Empleados/Incapacidades.js"></script>
<?php } ?>

<!-- Funcionalidades de la vista de  examenes-->
<?php if ($this->uri->segment(2)=='cExamenes') {?>
<script src="<?= base_url(); ?>js/FichaSDG/examenesM.js"></script>
<?php } ?>

<!-- Funcionalidades de la vista de  Historial-->
<?php if ($this->uri->segment(2)=='cHistorial') {?>
<script src="<?= base_url(); ?>js/Empleados/historial.js"></script>
<?php } ?>

<!-- Funcionalidades de la vista Dia Festivos-->
<?php if ($this->uri->segment(2)=='cDiaFestivo') {?>
<script src="<?= base_url(); ?>js/Empleados/diasFestivos.js"></script>
<?php } ?>


<!-- Funcionalidades de la vista de configuracion>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>-->
<?php if($this->uri->segment(2)=='cEmpresa'){ ?>
<!-- Funcionalidades de vista Empresa -->  
<script src="<?= base_url(); ?>js/FichaSDG/empresa.js"></script>
<?php }?>

<?php if ($this->uri->segment(3)=='salario'){ ?>
<!-- Funcionalidades de la vista salarios -->  
<script type="text/javascript">var vista=1;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='clasificacionMega'){ ?>
<!-- Funcionalidades de la vista Clasificacion mega -->  
<script type="text/javascript">var vista=2;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='auxilio'){ ?>
<!-- Funcionalidades de la vista Auxilio -->  
<script type="text/javascript">var vista=3;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='estadoCivil') {?>
<!--  Funcionalidades de la vista de estado civil -->  
<script type="text/javascript">var vista=4;</script>
<?php } ?> 

<?php if ($this->uri->segment(3)=='eps') {?>
<!--  Funcionalidades de la vista de EPS -->
<script type="text/javascript">var vista=5;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='afp') {?>
<!--  Funcionalidades de la vista de  AFP-->
<script type="text/javascript">var vista=6;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='cargo') {?>
<!--  Funcionalidades de la vista de  Cargo-->
<script type="text/javascript">var vista=7;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='horarioLaboral') {?>
<!--  Funcionalidades de la vista de  Horario de trabajo-->
<script type="text/javascript">var vista=8;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='areaLaboral') {?>
<!--  Funcionalidades de la vista de Areas Laborales-->
<script type="text/javascript">var vista=9;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='tipoContrato') {?>
<!--  Funcionalidades de la vista de Tipo de Contrato-->
<script type="text/javascript">var vista=10;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='gradoEscolaridad') {?>
<!--  Funcionalidades de la vista de Grado de escolarida-->
<script type="text/javascript">var vista=11;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='actividades') {?>
<!--  Funcionalidades de la vista de Actividades en tiempo libre-->
<script type="text/javascript">var vista=12;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='municipios') {?>
<!--  Funcionalidades de la vista de Municipios-->
<script type="text/javascript">var vista=13;</script>
<?php } ?>

<?php if ($this->uri->segment(3)=='clasificacionContable') {?>
<!--  Funcionalidades de la vista de Clasificacion contable-->
<script type="text/javascript">var vista=15;</script>
<?php } ?>

<?php if ($this->uri->segment(2)=='cDiagnostico') {?>
<!--  Funcionalidades de la vista de diagnostico-->
<!-- <script type="text/javascript">var vista=14;</script> -->
<script src="<?= base_url(); ?>js/Empleados/Diagnostico.js"></script>
<?php } ?>


<?php if($this->uri->segment(2)=='cConfiguracionFicha'){ ?>
<!-- Funcionalidades de la vista de configuracion-->  
<script src="<?= base_url(); ?>js/FichaSDG/generalA.js"></script>
<?php }?> 
<!-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> -->
</body>

</html>
