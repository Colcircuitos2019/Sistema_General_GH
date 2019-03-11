 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-clock"></i>
        Asistencias
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
          <!-- Div 1-->
          <style type="text/css">
            .amarillo{
             background-color: #ffbb33;
            }
            .morado{
             background-color: #9933CC;
            }

            .inputAsistencia{
              text-align: center;
              width: 65%;
            }
          </style>
          <div class="box box-primary">
            <div class="box-header">
              <i class="fab fa-algolia"></i>
              <h3 class="box-title"> Asistencias Diaria </h3>
                          <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>

            <!-- Cuerpo -->
            <div class="box-body">
            <!-- Tabla -->
            <!-- Primera fila -->
<!--            <div class="form-group">
                  <div class="col-sm-5">
                    <select class="form-control selectpicker" id="pro" data-live-search="true">
                      <option value="0" >Seleccione...</option>
                    </select>                    
                  </div>
                  <div class="col-sm-3">
                    <button class="btn btn-primary">Buscar</button>
                  </div>
                </div>   -->              
            <!-- Primera fila-->
            <!-- Tabla de todos los empelados -->
            <div class="col-sm-12">
              <div class="form-group">
                <div class="table-responsive" id="tblAsistenciaDia">
                 <!-- Tabla -->
                </div>
                <div class="col-sm-12">
                  <!-- <button type="button" class="btn btn-primary" name="Actualizar" id="ActualizarD"><span>Actualizar</span></button> -->
                </div>          
              </div>              
            </div>
            <!--  -->
            </div>
            <!-- /Cuerpo -->
            <div class="box-footer">
              <div class="col-sm-5">
                <label>Reporte: </label>
                <select class="selectpicker show-tick form-control" id="reportePisos" onchange="generarReportePorPisoPDF(this)">
                    <option value="0">Seleccione...</option>
                    <option value="1">Piso 1</option>
                    <option value="2">Piso 2</option>
                    <option value="3">Piso 3</option>
                    <option value="4">Piso 4</option>
                    <option value="5">Piso 5</option>
                </select>
              </div>
              <a class="pull-right" href="<?= base_url();?>Empleado/cAsistencia/generarPDFAsistencias" target="_blank">Generar PDF Asistencias</a>
            </div>
          </div>
          <!-- /Div 1-->
                    <div class="box box-primary">
                      <div class="box-header">
                        <i class="fab fa-algolia"></i>
                        <h3 class="box-title"> Asistencias Diaria Desayuno</h3>
                                    <!-- Minimizar -->
                        <div class="pull-right box-tools">
                          <button type="button" class="btn btn-box-tool" data-widget="collapse">
                            <i class="fa fa-minus"></i>
                          </button>
                        </div>
                      </div>
                      <!-- Cuerpo -->
                      <div class="box-body">
                      <!-- Tabla -->
                      <div class="col-sm-12">
                        <div class="form-group">
                          <div class="table-responsive" id="tblAsistenciaDesayunoDia">
                           <!-- Tabla -->
                          </div>
                          <div class="col-sm-12">
                            
                          </div>          
                        </div>              
                      </div>
                      <!--  -->
                      </div>
                      <!-- /Cuerpo -->
                      <div class="box-footer">
                        <div class="pull-right">
                          <button type="button" class="btn btn-primary" onclick="consultarAsistenciaEventoDia(2);"><span><i class="fas fa-sync-alt"></i></span></button>
                        </div>
                      </div>
                    </div>
          <!-- /Div 1-->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fab fa-algolia"></i>
              <h3 class="box-title"> Asistencias Diaria Almuerzo</h3>
              <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
            <!-- Tabla -->
            <div class="col-sm-12">
              <div class="form-group">
                <div class="table-responsive" id="tblAsistenciaAlmuerzoDia">
                 <!-- Tabla -->
                </div>
                <div class="col-sm-12">
                  
                </div>          
              </div>              
            </div>
            <!--  -->
            </div>
            <!-- /Cuerpo -->
            <div class="box-footer">
              <div class="pull-right">
                <button type="button" class="btn btn-primary" onclick="consultarAsistenciaEventoDia(3);"><span><i class="fas fa-sync-alt"></i></span></button>
              </div>
            </div>
          </div>
          <!-- Div 2 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-user"></i>
              <h3 class="box-title"> Asistencia por empleado</h3>
              <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
            <!-- Cuerpo -->
            <div class="box-body">
            <!-- Tabla -->
            <!-- Primera fila -->
<!--            <div class="form-group">
                  <div class="col-sm-5">
                    <select class="form-control selectpicker" id="pro" data-live-search="true">
                      <option value="0" >Seleccione...</option>
                    </select>                    
                  </div>
                  <div class="col-sm-3">
                    <button class="btn btn-primary">Buscar</button>
                  </div>
                </div>   -->              
            <!-- Primera fila-->
            <!-- Tabla de consultar asistencias por empelado-->
            <div class="col-sm-12">
              <div class="form-group">
                <!-- Input de documento -->
                <div class="col-sm-5">
                  <input class="form-control" type="text" name="documento" id="doc" onkeypress="return valida(event)" placeholder="Documento">
                </div>
                <!-- Input de button -->
                <div class="col-sm-5">
                  <button class="btn btn-primary" id="btnAsistenciaPorEmpleado"><span>Buscar</span></button>
                </div>
                <br><br>
                <!-- Table de informacion -->
                <div class="col-sm-12">
                  <br>
                  <div class="table-responsive" id="tabla">
                  <!-- Tabla -->
                  </div>             
                </div>          
              </div>              
            </div>

            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- Div 2 -->
          <!-- Div 3 -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-calendar-alt"></i>
              <h3 class="box-title"> Asistencias por rango de fechas</h3>
                          <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>

            <!-- Cuerpo -->
            <div class="box-body">
            <!-- Tabla -->
            <!-- Primera fila -->
            <!--<div class="form-group">
                  <div class="col-sm-5">
                    <select class="form-control selectpicker" id="pro" data-live-search="true">
                      <option value="0" >Seleccione...</option>
                    </select>                    
                  </div>
                  <div class="col-sm-3">
                    <button class="btn btn-primary">Buscar</button>
                  </div>
                </div>   -->              
            <!-- Primera fila-->
            <!-- Tabla de todos los empelados -->
            <div class="col-sm-12">
              <div class="form-group">
                    <div class="col-sm-3">
                      <label for="">Fecha de inicio</label>
                      <div class="input-group date fh-date" >
                        <input type="text" id="fechaI"  class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                      </div>              
                    </div>
                    <div class="col-sm-3">
                      <label for="">Fecha de fin</label>
                      <div class="input-group date fh-date" >
                        <input type="text" id="fechaF"  class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                      </div>              
                    </div>
                    <br>
                    <div class="col-sm-4">
                      <button type="button" id="buscarAsistenciaFecha" class="btn btn-primary">
                        Buscar
                      </button>&nbsp;
                      <a class="pull-right" id="exportarDocumentoTiempos">Exportar Tiempo Trabajado</a>             
                    </div>
                    <br>
              <div class="col-sm-12">
                <br>
                <div class="table-responsive" id="tblAsistenciaFecha">
                <!-- Tabla -->
                </div>                   
              </div>            
              </div>              
            </div>

            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- /Div 3-->
        </section>

<!-- Modals============================================================ -->
        <!-- Detalle asistencia -->
        <div class="modal fade" id="detalleAsistencias">
          <div class="modal-dialog modal-lg">
            <div class="modal-content">
              <!-- Header de la ventana -->
              <div class="modal-header">
                <button type="button"  class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h2 id="tituloD">Detalle Asistencia</h2>      
              </div>
              <!-- Body de la ventana -->
              <div class="modal-body">
              <!-- Asistencias -->
              <!-- Fila 1 -->
                <div class="table-responsive" id="tablaM">
                  <!-- Tabla de detalle de asistencia -->
                </div>
                <br>
                <!-- Fila 2 -->
                <div class="row" id="horasTotales" style=" margin: 3px;">
                  <!-- Columna 1 -->
                  <div class="col-sm-4">
                    <label>Horas Trabajadas</label>
                    <input class="form-control" type="text" name="horasTrabajadasNormales" id="hNormales" disabled="true" align="center">
                  </div>
                  <!-- Columna 2 -->
                  <div class="col-sm-4" style="height: 100%;">
                   <!-- ... -->
                   <div class="col-sm-12">
                     <!-- style="width: 1em; height: 1.5em;" -->
                     <label>Descripción:</label>
                     <textarea style="width: 100%; height: 100%;" id="hDescrip"></textarea>
                   </div>
                   <!-- ... -->
                  </div>
                  <!-- Columna 3 -->
                  <div class="col-sm-4">
                    <!-- Fila 1 -->
                     <div class="row">
                       <div class="col-sm-12">
                         <label>Horas Extras</label>
                         <input class="form-control" type="text" name="horasTrabajadasExtras" id="hExtras" disabled="true" align="center">
                       </div>
                     </div>
                    <!-- Fila 2 -->
                    <br>
                     <div class="row">
                        <!-- Columna 1 -->
                        <div class="col-sm-6">
                          <label>Horas Aceptadas</label>
                          <input class="form-control" type="text" name="horasTrabajadasNormales" id="hAceptadas" disabled="true" align="center">
                        </div>
                        <!-- Columna 2 -->
                        <div class="col-sm-6">
                          <label>Horas Rechazadas</label>
                          <input class="form-control" type="text" name="horasTrabajadasNormales" id="hRechazadas" disabled="true" align="center">
                        </div>
                    </div>
                  </div>
                  <!-- Columna 3 fin -->
                </div>
                <!-- Modulo del permiso del día -->
                <div class="row" id="seccionPermisoP">
                  <div class="col-sm-12">
                    <h2>Permisos</h2>
                    <div class="table-responsive" id="PermisosDiaAsistencia">
                      <!-- Cuerpo de la tabla -->
                    </div>
                  </div>
                </div>
                <!--  -->
              <!-- Footer de la ventana -->
              <div class="modal-footer">
                <!-- value 1= modal asistencia diaria, 2 modal asistencia empleado dias anteriores -->
                <button type="button" class="btn btn-primary pull-left" id="editarAsistencia" value="1"><span><i class="fas fa-edit"></i></span> Editar</button>
                <button type="button" class="btn btn-warning pull-right" id="modificarAsistencia"><span><i class="fas fa-check"></i></span> Modificar</button>
              </div>
              </div>  
            </div>
          </div>
        </div>
        <!-- /Modificar Pedidos -->
<!-- /Modals --> 
    </div>

<!-- <div class="contain">
  <h2>Empelados</h2>
  <form class="formulario">
    <table>
      <tr>
        <td><label><strong>*</strong> Documento:</label></td>
        <td><input type="text" id="documento" placeholder="ejm:98113053240"></td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Primer nombre:</label></td>
        <td><input type="text" id="nombre1" placeholder="Juan"></td>
      </tr>
      <tr>
        <td><label>Segundo nombre</label></td>
        <td><input type="text" id="nombre2" placeholder="David"></td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Primer Apellido</label></td>
        <td><input type="text" id="apellido1" placeholder="Marulanda"></td>
      </tr>
      <tr>
        <td><label>Segundo Apellido:</label></td>
        <td><input type="text" id="apellido2" placeholder="Paniagua"></td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Genero:</label></td>
        <td>
          <input type="radio" name="genero" value="1">Masculino
          <input type="radio" name="genero" value="0">Femenino
        </td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Huella 1:</label></td>
        <td>
          <input value="0" type="text" id="huella1" placeholder="1">
        </td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Huella 2:</label></td>
        <td>
          <input value="0" type="text" id="huella2" placeholder=2>
        </td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Huella 3:</label></td>
        <td>
          <input value="0" type="text" id="huella3" placeholder="3">
        </td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Contraseña:</label></td>
        <td><input type="password" maxlength="4" id="contraseña1"></td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Confirmacion:</label></td>
        <td><input type="password" maxlength="4" id="contraseña2"></td>
      </tr>
      <tr>
        <td><label>Correo:</label></td>
        <td><input type="email" id="correo" placeholder="jdmarulanda0@gmail.com"></td>
      </tr>
      <tr>
        <td><label><strong>*</strong>Empresa Contratante:</label></td>
        <td>
          <select id="Empresas" name="cbxEmpresas">

          <option value="0">Seleeccionar</option>
              </select>
        </td>
      </tr>

      <tr>
        <td><input type="button" value="Enviar" name="enviar" id="Enviar"></td>
      </tr>
      
    </table>
  </form>
</div> -->