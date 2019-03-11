 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-users"></i>
        Empleado
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
              <h3 class="box-title">Formulario Empleado</h3>
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
    .tamaño{
      font-size: 10px;
      padding: 3px;
    }

    .nom>div>input{
      text-transform: capitalize;
    }
    
  </style>
<!-- Cuerpo -->
<div class="box-body">
  <div class="col-sm-12">
<form class="form-horizontal">
  <!-- Documento -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="documento"><strong>*</strong>Documento:</label>
        <div class="col-sm-10">
            <input type="text" class="form-control" maxlength="13" id="documento" placeholder="Documento" onkeypress="return valida(event)" onkeyup="validarPorCampo(this.id)">
        </div>
    </div>
    <!-- Fecha de expedicion y lugar de expedicion -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="fechaEX"><strong>*</strong>Fecha de expedición:</label>
        <div class="col-sm-4">
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
            <input type="text" class="form-control" maxlength="13" id="fechaEX" placeholder="Fecha de expedicion DD-MM-YYYY" onkeypress="" onkeyup="validarPorCampo(this.id)">
          </div>
        </div>
        <label class="control-label col-sm-2" for="lugarEX"><strong>*</strong>Lugar de expedición:</label>
        <div class="col-sm-4">       
            <input type="text" class="form-control" maxlength="13" id="lugarEX" placeholder="Lugar de expedición" onkeypress="" onkeyup="validarPorCampo(this.id)">
        </div>
    </div>
    <!-- Nombres -->
    <div class="form-group nom">
        <label class="control-label col-sm-2" for="nombre1"><strong>*</strong>Primer nombre:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="nombre1" placeholder="Primer nombre" onkeypress="return soloLetras(event)">
        </div>
                <label class="control-label col-sm-2" for="nombre2">Segundo nombre:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="nombre2" placeholder="Segundo nombre" onkeypress="return soloLetras(event)">
        </div>
    </div>
    <!-- Apellidos -->
    <div class="form-group nom">
        <label class="control-label col-sm-2" for="apellido1"><strong>*</strong>Primer apellido:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="apellido1" placeholder="Primer apellido" onkeypress="return soloLetras(event)">
        </div>
        <label class="control-label col-sm-2" for="apellido2">Segundo apellido:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="apellido2" placeholder="Segundo apellido" onkeypress="return soloLetras(event)">
        </div>
    </div>
    <!-- Huellas ID -->
    <div class="form-group">
      <label class="control-label col-sm-2"><strong>*</strong>Huellas</label>
        <div class="col-sm-3">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-hand-point-up"></i></span>
             <input type="text" class="form-control" onkeyup="validarPorCampo(this.id)" id="huella1"  placeholder="huella 1" value="0" onkeypress="return valida(event)">
          </div> 
        </div>
        <div class="col-sm-3">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-hand-point-up"></i></span>
             <input type="text" class="form-control" onkeyup="validarPorCampo(this.id)" id="huella2" placeholder="huella 2" value="0" onkeypress="return valida(event)">
          </div> 
        </div>
        <div class="col-sm-3">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-hand-point-up"></i></span>
             <input type="text" class="form-control" onkeyup="validarPorCampo(this.id)" id="huella3" placeholder="huella 3" value="0" onkeypress="return valida(event)">
          </div> 
        </div>
    </div>
        <div class="form-group">
        <label class="control-label col-sm-2" for="contraseña1"><strong>*</strong>Constraseña:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="4" onkeyup="validarPorCampo(this.id)" class="form-control" id="contraseña1" placeholder="contraseña">
        </div>
        <label class="control-label col-sm-2" for="contraseña2"><strong>*</strong>Confirmar:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="4" onkeyup="validarPorCampo(this.id)" class="form-control" id="contraseña2" placeholder="contraseña">
        </div>
    </div>
<!-- Genero -->
    <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong> Genero:</label>
        <div class="col-sm-2">
            <label class="radio-inline">
                <input type="radio" name="genero" value="1"> Maculino
            </label>
        </div>
        <div class="col-sm-2">
            <label class="radio-inline">
                <input type="radio" name="genero" value="0"> Femenino
            </label>
        </div>
        <label class="control-label col-sm-2"><strong>*</strong>Rol:</label>
        <div class="col-sm-4">
          <select id="Roles" class="form-control" name="cbxEmpresas">
            <option value="0">Seleccione...</option>
          </select>
        </div>
    </div>
      <div class="form-group">
        <label class="control-label col-sm-2" for="correo"><strong>*</strong>Email:</label>
        <div class="col-sm-10">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-envelope"></i></span>
             <input type="email" id="correo" class="form-control" placeholder="Email">
          </div> 
        </div>
    </div>
      <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Empresa Contratante:</label>
        <div class="col-sm-10">
          <select id="Empresas" class="form-control" name="cbxEmpresas">
            <option value="0">Seleccione...</option>
          </select>
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2" for="Pisos"><strong>*</strong>Piso:</label>
        <div class="col-sm-3">
          <select id="Pisos" class="form-control" name="cbxPiso">
            <option value="0">Seleccione...</option>
            <option value="1">Piso 1</option>
            <option value="2">Piso 2</option>
            <option value="3">Piso 3</option>
            <option value="4">Piso 4</option>
            <option value="5">Piso 5</option>
          </select>
        </div>
        <label class="control-label col-sm-2" for="manufactura">Manufactura:</label>
        <div class="col-sm-5">
          <select id="manufactura" class="form-control">
            <option value="0">Seleccione...</option>
            <!-- Pendiente por desarrollar -->
            <?php foreach($manufacturas as $manu) {
                  echo '<option value="'.$manu->idArea_trabajo.'">'.$manu->area.'</option>';
                }
            ?>
          </select>
        </div>
    </div>      
    <div class="form-group">
        <div class="col-sm-2"></div>
        <div class="col-sm-6">
          <input type="button" class="btn btn-primary" id="Enviar" value="Registrar">
        </div>
    </form>    
        <div class="col-sm-4 pull-right">
          <form id="formImportarE" method="POST" enctype="multipart/form-data">
            <input type="file" name="empleado" id="file" required="true" accept=".xls, .xlsx">
            <button type="submit" name="Importar" id="importar">importar</button>&nbsp;&nbsp;
          </form>
        </div>
    </div>
    <a href="<?php echo base_url(); ?>Empleado/cEmpleado/reporteEmpelados" target="_blank">Empleados Excel...</a>    
</div>
</div>
<!-- /Cuerpo -->
</div>
          <!-- Div 1 -->
         <!-- Div 2 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-people-carry"></i>
              <h3 class="box-title">Empleados</h3>
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
              <div class="table-responsive">
              <div class="form-group" id="tblTable">
<!--                   <table class="table table-spraide display" id="Empelados">
                    <thead id="cabeza">
                      <th>Documento</th>
                      <th>Nombre</th>
                      <th>Genero</th>
                      <th>Estado</th>
                      <th>Acciones</th>
                    </thead>
                    <tbody id="cuerpo">

                    </tbody>
                  </table>   -->      
              </div>                 
              </div>             
            </div>

            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- Div 2 -->
        </section>

<!-- Modals============================================================ -->
        <!-- Modificar Pedido -->
        <div class="modal fade" id="modificar">
          <div class="modal-dialog">
            <div class="modal-content">
              <!-- Header de la ventana -->
              <div class="modal-header">
                <button type="button"  class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2>Modificar Empleado</h2>      
              </div>
              <!-- Body de la ventana -->
              <div class="modal-body">
              <!-- Empleados -->
              <form class="form-horizontal">
  <!-- Documento -->
    <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Documento:</label>
        <div class="col-sm-10">
            <input type="text" class="form-control" maxlength="13" id="documentoM" placeholder="Documento" disabled="true">
        </div>
    </div>
    <!-- Fecha de expedicion y lugar de expedicion -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="fechaEXM"><strong>*</strong>Fecha de expedición:</label>
        <div class="col-sm-4">
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
            <input type="text" class="form-control" maxlength="10" id="fechaEXM" placeholder="DD-MM-YYYY" onkeypress="" onkeyup="validarPorCampo(this.id)">
          </div>
        </div>
        <label class="control-label col-sm-2" for="lugarEXM"><strong>*</strong>Lugar de expedición:</label>
        <div class="col-sm-4">       
            <input type="text" class="form-control" maxlength="50" id="lugarEXM" placeholder="Lugar de expedición" onkeypress="" onkeyup="validarPorCampo(this.id)">
        </div>
    </div>
    <!-- Nombres -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="nombre1M"><strong>*</strong>Primer nombre:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="nombre1M" placeholder="Primer nombre" onkeypress="return soloLetras(event)">
        </div>
                <label class="control-label col-sm-2" for="nombre2M">Segundo nombre:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="nombre2M" placeholder="Segundo nombre" onkeypress="return soloLetras(event)">
        </div>
    </div>
    <!-- Apellidos -->
    <div class="form-group">
        <label class="control-label col-sm-2" for="apellido1M"><strong>*</strong>Primer apellido:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="apellido1M" placeholder="Primer apellido" onkeypress="return soloLetras(event)">
        </div>
        <label class="control-label col-sm-2" for="apellido2M">Segundo apellido:</label>
        <div class="col-sm-4">
            <input type="text" class="form-control" maxlength="45" onkeyup="validarPorCampo(this.id)" id="apellido2M" placeholder="Segundo apellido" onkeypress="return soloLetras(event)">
        </div>
    </div>
    <!-- Huellas ID -->
    <div class="form-group">
      <label class="control-label col-sm-2"><strong>*</strong>Huellas</label>
        <div class="col-sm-3">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-hand-point-up"></i></span>
             <input type="text" class="form-control" onkeyup="validarPorCampo(this.id)" id="huella1M"  placeholder="huella 1" value="0" onkeypress="return valida(event)">
          </div> 
        </div>
        <div class="col-sm-3">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-hand-point-up"></i></span>
             <input type="text" class="form-control" onkeyup="validarPorCampo(this.id)" id="huella2M" placeholder="huella 2" value="0" onkeypress="return valida(event)">
          </div> 
        </div>
        <div class="col-sm-3">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-hand-point-up"></i></span>
             <input type="text" class="form-control" onkeyup="validarPorCampo(this.id)" id="huella3M" placeholder="huella 3" value="0" onkeypress="return valida(event)">
          </div> 
        </div>
    </div>
        <div class="form-group">
        <label class="control-label col-sm-2" for="contraseña1M"><strong>*</strong>Constraseña:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="4" onkeyup="validarPorCampo(this.id)" class="form-control" id="contraseña1M" placeholder="contraseña">
            <input type="checkbox" onchange="document.getElementById('contraseña1M').type = this.checked ? 'text' : 'password'"> Ver Contraseña
        </div>
        <label class="control-label col-sm-2" for="contraseña2M"><strong>*</strong>Confirmar:</label>
        <div class="col-sm-4">
            <input type="password" maxlength="4" onkeyup="validarPorCampo(this.id)" class="form-control" id="contraseña2M" placeholder="contraseña">
        </div>
    </div>
<!-- Genero -->
    <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong> Genero:</label>
        <div class="col-sm-2">
            <label class="radio-inline">
                <input type="radio" id="M" name="generoM" value="1"> Maculino
            </label>
        </div>
        <div class="col-sm-2">
            <label class="radio-inline">
                <input type="radio" id="F" name="generoM" value="0"> Femenino
            </label>
        </div>
        <label class="control-label col-sm-2"><strong>*</strong>Rol:</label>
        <div class="col-sm-4">
          <select id="RolesM" class="form-control" name="cbxEmpresas">
            <option value="0">Seleccione...</option>
          </select>
        </div>
    </div>
      <div class="form-group">
        <label class="control-label col-sm-2" for="correoM"><strong>*</strong>Email:</label>
        <div class="col-sm-10">
          <div class="input-group">
             <span class="input-group-addon"><i class="fas fa-envelope"></i></span>
             <input type="email" id="correoM" class="form-control" placeholder="Email">
          </div> 
        </div>
    </div>
      <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Empresa Contratante:</label>
        <div class="col-sm-10">
          <select id="EmpresasM" class="form-control" name="cbxEmpresasM">
            <option value="0">Seleccione...</option>
          </select>
        </div>
    </div>
    <div class="form-group">
        <label class="control-label col-sm-2"><strong>*</strong>Piso:</label>
        <div class="col-sm-3">
          <select id="PisosM" class="form-control" name="cbxPisoM">
            <option value="0">Seleccione...</option>
            <option value="1">Piso 1</option>
            <option value="2">Piso 2</option>
            <option value="3">Piso 3</option>
            <option value="4">Piso 4</option>
            <option value="5">Piso 5</option>
          </select>
        </div>
        <!-- ... -->
        <label class="control-label col-sm-2" for="manufacturaM">Manufactura:</label>
        <div class="col-sm-5">
          <select id="manufacturaM" class="form-control">
            <option value="0">Seleccione...</option>
            <!-- Pendiente por desarrollar -->
            <?php foreach($manufacturas as $manu) {
                  echo '<option value="'.$manu->idArea_trabajo.'">'.$manu->area.'</option>';
                }
            ?>
          </select>
        </div>
    </div>         
<!--<div class="form-group">
        <div class="col-sm-10 pull-right">
          <input type="button" class="btn btn-primary" id="EnviarM" value="Registrar">
        </div>
    </div> -->
</form>    
              </div>
              <!-- Footer de la ventana -->
              <div class="modal-footer">
                <button type="button" id='cActualizar' class="btn btn-warning">Actulizar</button>
              </div>  
            </div>
          </div>
        </div>
<!-- Horarios Empleados -->
  <div class="modal fade" id="empleadoHorario">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3>Horario Empleado: <small id="nameEmpleado"></small></h3>
        </div>
        <div class="modal-body">
          <!-- Primera fila -->
          <div class="row">
            <div class="col-sm-9">
              <label><strong>*</strong> Horario Empleado:</label>
              <select id="horario_configuracion" class="form-control" name="cbxPisoM">

              </select>
            </div>
            <div class="col-sm-3">
              <br>
              <button type="button" id="btnAgregarHorario" data-id="0" value="0" class="btn btn-primary btn-sm"><span><i class="fas fa-plus-circle"></i></span><div>Agregar</div></button>
              &nbsp;
              <button type="button" id="limpiarForm" data-id="0" value="0" class="btn btn-info btn-sm"><span><i class="fas fa-eraser"></i></span><div>Limpiar</div></button>
            </div>
          </div>
          <br>
          <!-- Segunda fila -->
          <div class="row">
            <div class="col-sm-6">
              <label><strong>*</strong>Día Inicio:</label>
              <select id="diaInicio" class="form-control" name="cbxPisoM">
                <option value="-1">Seleccione...</option>
                <option value="0">Domingo</option>
                <option value="1">Lunes</option>
                <option value="2">Martes</option>
                <option value="3">Miercoles</option>
                <option value="4">Jueves</option>
                <option value="5">Viernes</option>
                <option value="6">Sabado</option>
              </select>
            </div>
            <div class="col-sm-6">
              <label>Día Fin:</label>
              <select id="diaFin" class="form-control" name="cbxPisoM">
                <option value="-1">Seleccione...</option>
                <option value="0">Domingo</option>
                <option value="1">Lunes</option>
                <option value="2">Martes</option>
                <option value="3">Miercoles</option>
                <option value="4">Jueves</option>
                <option value="5">Viernes</option>
                <option value="6">Sabado</option>
              </select>
            </div>
          </div>
          <br>
          <!-- tercera fila -->
          <div class="row">
            <div class="col-sm-12">
              <div class="table-responsive" id="tblEmpeladoHorario">
              <!-- .-.-.-. -->
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          
        </div>
      </div>
    </div>
  </div>      
        <!-- /Modificar Pedidos -->
<!-- /Modals -->  
    </div>