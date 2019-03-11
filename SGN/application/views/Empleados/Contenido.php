 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-desktop"></i>
        Información Principal Empleados 
        <small>Desktop</small>
      </h1>
      <ol class="breadcrumb">
        <li><a href="#"><i class="fas fa-desktop"></i> Home</a></li>
        <li class="active">Dashboard</li>
      </ol>
    </section>
    <!-- /Content Header (Page header) -->

<section class="content">
	<div class="row">
    <!-- ./col -->
    <div class="col-lg-3 col-xs-6">
      <!-- small box -->
      <div class="small-box bg-yellow">
        <div class="inner">
          <h3 id="empleados"></h3>

          <p>Empleados</p>
        </div>
        <div class="icon">
          <i class="ion ion-person-add"></i>
        </div>
        <a href="#" class="small-box-footer"></a>
      </div>
    </div>
          <!-- ./col -->
          <div class="col-lg-3 col-xs-6">
            <!-- small box -->
            <div class="small-box bg-green">
              <div class="inner">
                <h3 id="incapacidades"><sup style="font-size: 20px"></sup></h3>

                <p>Incapacidades</p>
              </div>
              <div class="icon">
                <i class="ion ion-stats-bars"></i>
              </div>
              <a href="#" class="small-box-footer"></a>
            </div>
          </div>
          <!-- ./col -->
          <div class="col-lg-3 col-xs-6">
            <!-- small box -->
            <div class="small-box bg-aqua">
              <div class="inner">
                <h3 id="FSDG"></h3>

                <p>Fichas Sociodemograficas</p>
              </div>
              <div class="icon">
                <i class="ion ion-bag"></i>
              </div>
              <a href="#" class="small-box-footer"></a>
            </div>
          </div>
          <!-- ./col -->
          <div class="col-lg-3 col-xs-6">
            <!-- small box -->
            <div class="small-box bg-red">
              <div class="inner">
                <h3 id="permisos"></h3>

                <p>Permisos</p>
              </div>
              <div class="icon">
                <i class="ion ion-pie-graph"></i>
              </div>
              <a href="#" class="small-box-footer"></a>
            </div>
          </div>
          <!-- ./col -->
  </div>
  <script type="text/javascript">
    var base='<?php echo base_url();?>';
    //...
    consultarCantidadEmpleadosSistema();
    //...
    //...
    consultarCantidadIncapacidadesSistema();
    //...
    //...
    consultarCantidadFSDGSistema();
    //...
    //...
    consultarCantidadPermisosSstema();
    //...
    //Consultar numero de empleados que existen en el sistema de informaciíon
    function consultarCantidadEmpleadosSistema() {
        $.post(base+'Empleado/cMenu/cantidadEmpleados', function(data) {
          console.log(data);
          $('#empleados').text(data);
        });
    }

    // Consulta el numero de incapacidades registradas en el sistema de información.
    function consultarCantidadIncapacidadesSistema() {
      $.post(base+'Empleado/cMenu/cantidadIncapacidades', function(data) {
        console.log(data);
        $('#incapacidades').text(data);
      });
    }

    // Consultar cantidad de fichas Sociodemografico que hacen parte del sistema de información.
    function consultarCantidadFSDGSistema() {
      $.post(base+'Empleado/cMenu/cantidadFSDG', function(data) {
        console.log(data);
        $('#FSDG').text(data);
      });
    }

    // Consulta la cantidad de permisos que hacen parte del sistema de información.
    function consultarCantidadPermisosSstema() {
      $.post(base+'Empleado/cMenu/cantidadPermisos', function(data) {
        console.log(data);
        $('#permisos').text(data);
      });
    }

  </script>