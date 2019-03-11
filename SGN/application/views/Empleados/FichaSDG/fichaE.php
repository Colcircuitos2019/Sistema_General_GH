 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-file-medical"></i>
        Ficha Sociodemografica
        <small>Desktop</small>
      </h1>
<!--  <ol class="breadcrumb">
        <li><a href="#"><i class="fas fa-desktop"></i> Home</a></li>
        <li class="active">Dashboard</li>
      </ol> -->
    </section>
    <style type="text/css">
      strong>label{
        color: red;
      }
    </style>
    <!-- /Content Header (Page header) -->
<section class="content">
  <div class="row">
<section class="col-lg-12 connectedSortable">
<!--=======================================================================================-->   
          <!-- Primera fila -->
          <div class="row">
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
                <!-- Información principal basica -->
                <div class="row">
                  <div class="col-sm-12">
                    <!-- Cedula -->
                    <div class="col-sm-2">
                      <label for="txtCedula">Cedula</label>
                      <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-address-card"></i></span>
                        <input value="" type="text" name="cedula" class="form-control" id="txtCedula" readonly="true" style="text-align: center; font-weight: bold;">
                      </div>
                    </div>
                    <!-- Primer nombre -->
                    <div class="col-sm-2">
                      <label for="txtPrimerNombre">Primer Nombre</label>
                      <input value="" type="text" name="PrimerNombre" class="form-control" id="txtPrimerNombre" readonly="true" style="text-align: center; text-transform: capitalize;">
                    </div>
                    <!-- Segundo Nombre -->
                    <div class="col-sm-2">
                      <label for="txtSegundoNombre">Segundo Nombre</label>
                      <input value="" type="text" name="SegundoNombre" class="form-control" id="txtSegundoNombre" readonly="true" style="text-align: center; text-transform: capitalize;">
                    </div>
                    <!-- Primer apellido -->
                    <div class="col-sm-2">
                      <label for="txtPrimerApellido">Primer Apellido</label>
                      <input value="" type="text" name="PrimerApellido" class="form-control" id="txtPrimerApellido" readonly="true" style="text-align: center; text-transform: capitalize;">
                    </div>
                    <!-- Segundo apellido -->
                    <div class="col-sm-2">
                      <label for="txtSegundopellido">Segundo Apellido</label>
                      <input value="" type="text" name="SegundoApellido" class="form-control" id="txtSegundopellido" readonly="true" style="text-align: center; text-transform: capitalize;">
                    </div>
                    <!-- Genero -->
                    <div class="col-sm-2">
                      <label for="genero">Genero</label>
                      <input value="" type="text" name="Genero" class="form-control" id="genero" readonly="true" style="text-align: center; text-transform: capitalize;">
                    </div>
                  </div>
                </div>
              </div>
              <!-- /Cuerpo -->
              <div class="box-footer">
                <div class="col-sm-6 col-xs-12">
                  <div class="col-sm-4">
                    <label  type="button" value="0" class="btn btn-info" data-toggle="modal" id="btnEmpleados"><span><i class="fas fa-user"></i></span> &nbsp;Empleados</label>
                    &nbsp;
                    <a type="button" id="exportar">Exportar...</a>
                  </div>
                  <div class="col-sm-4">
                      <form id="formImportar" method="POST" enctype="multipart/form-data">
                        <input type="file" name="fichasSDG" id="file" required="true" accept=".xls, .xlsx">
                        <button type="submit" name="Importar" id="importar">importar</button>&nbsp;&nbsp;
                      </form>
                  </div>     
                </div>

                <div class="col-sm-6 col-xs-12">
                  <div class="col-sm-3">
                    <!--  -->
                  </div>
                  <div class="col-sm-3">
                    <!--  -->
                    <a type="button" id="pdf" hidden="true">Generar PDF...</a>
                  </div>
                  <div class="col-sm-3 col-xs-6">
                    <label  type="button" value="0" class="btn btn-info pull-right" data-toggle="modal" id="limpiarCRUD"><span><i class="fas fa-trash-alt"></i></span> &nbsp;Limpiar</label>&nbsp;  
                  </div>
                  <div class="col-sm-3 col-xs-6">
                    <!-- El icono de este boton me cambia cuando el boton recibe algun tipo de cambio de las propiedades -->
                    <button disabled="false" type="button" value="0" class="btn btn-info pull-right" data-toggle="modal" id="accionCRUD"><span><i class="fas fa-save"></i></span> &nbsp;Registrar</button>  
                  </div>
                </div>
                <!--  -->
              </div>
            </div>
          </div>
          <!-- Segunda fila -->
          <div class="row">
            <!-- Estado empresarial -->
            <div class="col-sm-6">
              <div class="box box-info">
                <div class="box-header">
                  <i class="fas fa-signal"></i>
                  <h3 class="box-title"> Estado Empresarial</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Información el estado empresarial -->
                <div class="box-body">
                  <!-- Primera fila -->
                  <div class="row">
                    <!-- ID de fecha SDG -->
                    <div class="col-sm-3">
                      <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-sort-numeric-up"></i></span>
                        <input value="0" type="text" class="form-control" id="idEstadoL" style="text-align: center; font-weight: bold;" readonly="true">
                      </div>
                    </div>
                    <!-- Estado -->
                    <div class="col-sm-5">
                      <label for="estadoSDG"><strong>*</strong>Estado</label>
                      <select class="form-control" id="estadoSDG">
                        <option value="0">Seleccione...</option>
                        <option value="1">Retirado</option>
                        <option value="2">Vigente</option>
                      </select>
                    </div>
                    <!-- Fecha de retiro -->
                    <div class="col-sm-4">
                      <label for="indRotacion"><strong>*</strong>IND Rotación</label>
                       <select class="form-control" id="indRotacion" disabled="true">
                        <option value="0">Seleccione...</option>
                        <option value="1">Deseada</option>
                        <option value="2">No Deseada</option>
                        <option value="3">N/A</option>
                      </select>
                    </div>
                  </div>
                  <!-- Segunda fila -->
                  <br>
                  <div class="row" hidden="true" id="impacto">
                    <div class="col-sm-2 col-xs-12">
                      <label class="pull-right color"><STRONG>*</STRONG>Impacto:</label>
                    </div>
                    <div id="contenedorIm">
                      <div class="col-sm-3 col-xs-12">
                        <input type="radio" value="1" name="impacto">&nbsp;<label class="color">Bajo impacto</label>
                      </div>
                      <div class="col-sm-4 col-xs-12">
                        <input type="radio" value="2" name="impacto">&nbsp;<label class="color">Sin impacto</label>
                      </div>
                      <div class="col-sm-3 col-xs-12">
                        <input type="radio" value="3" name="impacto">&nbsp;<label class="color">Alto impacto</label>
                      </div>
                    </div>
                  </div>
                  <br>
                  <div class="row">
                    <!-- Motivo -->
                    <div class="col-sm-6">
                      <label for="motivoE"><strong>*</strong>Motivo</label>
                      <select class="form-control" id="motivoE" disabled="true">
                        <!-- Contenido -->
                      </select>
                    </div>
                    <!-- Indicador de rotación -->
                    <div class="col-sm-6">
                      <label for="empresas"><strong>*</strong>Empresa</label>
                      <!-- <input type="text" class="form-control pull-right" id="fechaRT" readonly="true"> -->
                      <select id="empresas" class="form-control" name="cbxEmpresas">
                        <option value="0">Seleccione...</option>
                      </select>
                    </div>
                  </div>
                  <br>
                  <!-- Fila tres -->
                  <div class="row">
                    <div class="col-sm-4">
                      <label for="fechaIT"><strong>*</strong>Fecha de ingreso</label>
                      <div class="input-group date fh-date">
                        <div class="input-group-addon">
                          <i class="fa fa-calendar"></i>
                        </div>
                        <input type="text" class="form-control pull-right" id="fechaIT" placeholder="DD-MM-YYYY" readonly="true">
                      </div>
                    </div>
                    <div class="col-sm-4">
                      <label for="fechaRT">Fecha de retiro</label>
                      <div class="input-group date fh-date">
                        <div class="input-group-addon">
                          <i class="fa fa-calendar"></i>
                        </div>
                        <input type="text" class="form-control pull-right" id="fechaRT" placeholder="DD-MM-YYYY" readonly="true" disabled="true">
                      </div>
                    </div>
                    <div class="col-sm-4">
                      <label for="tiempoAntiguedad">Antigüedad </label>
                      <input type="text" class="form-control pull-right" id="tiempoAntiguedad" maxlength="25" readonly="true">
                    </div>
                  </div>
                  <br>
                  <!-- Fila 4 -->
                  <div class="row">
                    <div class="col-sm-12">
                      <label for="descripR">Observacion de retiro:</label>
                      <br>
                      <textarea style="width: 100%; height: 7.3em;" id="descripR" disabled="true"></textarea>
                    </div>
                  </div>
                </div>
                <!-- /Cuerpo -->
                <div class="box-footer">
                  <div class="row">
                    <div class="col-sm-6">
                      <div class="btn-group" id="grupoBtn">
                      </div>
                    </div>
                    <div class="col-sm-6">
                      <div class="btn-group">
                        <button type="button" value="0" class="btn btn-primary btn-xs" id="newButtons" disabled="true"><span><i class="fas fa-plus-square"></i></span> Nuevo</button>
                        <button type="button" value="1" class="btn btn-success btn-xs" id="guardarEstado"><span><i class="fas fa-save"></i></span> Guardar</button>
                        <button type="button" value="2" class="btn btn-danger btn-xs" id="deletButtons" disabled="true">Eliminar <span><i class="fas fa-trash-alt"></i></span></button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <!-- Columna 2 -->
            <div class="col-sm-6">
              <!-- Salarial -->
              <div class="box box-info">
                <div class="box-header">
                  <i class="fas fa-hand-holding-usd"></i>
                  <h3 class="box-title"> Información salarial</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Información Salarial. -->
                <div class="box-body">
                  <!-- Primera fila -->
                  <div class="row">
                    <!-- Promedio salarial incluye auxilio de transporte-->
                    <div class="col-sm-5">
                      <label for="promSalarial">Promedio salario</label>
                      <select class="form-control" id="promSalarial" style="position: static;">
                      <!-- Contenido -->
                      </select>
                    </div>
                    <!-- Clasificacion mega -->
                    <div class="col-sm-3">
                      <label for="clasiMega">Cla.Mega</label>
                      <select class="form-control" id="clasiMega">
                        <!-- Constenido -->
                      </select>
                    </div>
                    <!-- Salario basico -->
                    <div class="col-sm-4">
                      <label for="salarioBasico"><strong>*</strong>Salario Basico</label>
                      <div class="input-group">
                        <span class="input-group-addon">$</span>
                        <input type="text" class="form-control" id="salarioBasico" maxlength="20" onkeypress="return valida(event);" onkeyup="calcularSalarioTotal();">
                        <!-- <span class="input-group-addon">.00</span> -->
                      </div>
                    </div>
                  </div>
                  <br>
                  <!-- Segunda fila -->
                  <div class="row">
                    <!-- Auxilio de transporte -->
                    <div class="col-sm-4">
                      <label for="auxilios">Auxilios</label>
                      <!-- Este va a ser un select de seleccion multiple -->

                      <select onchange="" class="selectpicker form-control" multiple data-selected-text-format="count" id="auxilios">
                        <!-- <option value="0">Seleccione...</option>
                        <option value="1">Transporte</option> -->
                      </select>
                    </div>
                    <!-- Auxilios -->
                    <div class="col-sm-4" id="monstosAux">

                    </div>
                    <!-- Salario total -->
                    <div class="col-sm-4">
                      <label for="salTotal">Total</label>
                      <div class="input-group">
                        <span class="input-group-addon">$</span>
                        <input type="text" class="form-control" value="0" id="salTotal" autocomplete="false" readonly="false">
                        <!-- <span class="input-group-addon">.00</span> -->
                      </div>
                    </div>
                  </div>
                </div>
                <!-- /Cuerpo -->
                <div class="box-footer">
                  <!--  -->
                </div>
              </div>
              <!-- Informacion de estudios -->
              <div class="box box-info">
                  <div class="box-header">
                    <i class="fas fa-graduation-cap"></i>
                    <h3 class="box-title">Estudios</h3>
                    <!-- Minimizar -->
                    <div class="pull-right box-tools">
                      <button type="button" class="btn btn-box-tool" data-widget="collapse">
                        <i class="fa fa-minus"></i>
                      </button>
                    </div>
                  </div>
                  <!-- Cuerpo -->
                  <div class="box-body">
                    <!-- Primera fila -->
                    <div class="row">
                    <!-- Grado de escolaridad -->
                      <div class="col-sm-4">
                        <label for="gradoEscolaridad"><strong>*</strong>Grado de escolaridad</label>
                        <select class="form-control" name="" id="gradoEscolaridad">
                          <!-- <option value="0">selecione...</option>
                          <option value="1">Bachiller</option>
                          <option value="2">Técnico</option>
                          <option value="3">Tecnólogo</option>
                          <option value="4">Profesional</option>
                          <option value="5">Profesional con especialización</option>
                          <option value="5">Profesional con maestría</option> -->
                        </select>
                      </div>
                      <!-- Titulo profecional -->
                      <div class="col-sm-4">
                        <label for="tituloProfecional">Titulo profesional</label>
                        <input type="text" name="tituloP" id="tituloProfecional" class="form-control" style="text-align: center;"maxlength="50">
                      </div>
                      <!-- Titulo Especialización -->
                      <div class="col-sm-4">
                        <label for="especializacion">Titulo Especialización</label>
                        <input type="text" name="tituloEs" id="especializacion" class="form-control" style="text-align: center;" maxlength="50">
                      </div>
                    </div>
                    <br>
                    <!-- Segunda fila -->
                    <div class="row">
                      <!-- Primera columna -->
                      <div class="col-sm-3">
                        <label>Estudia actualmente</label>
                        <br>
                        <div class="col-sm-1"></div>
                        <div class="col-sm-2">
                          <div class="checkbox">
                            <label style="font-size: 1em;">
                                <input type="checkbox" value="" id="EstudiosActuales">
                                <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                            </label>
                          </div>
                        </div>
                        <div class="col-sm-9"></div>
                      </div>
                      <!-- segunda columna -->
                      <div class="col-sm-9">
                        <div class="col-sm-6 col-xs-12">
                          <!--  -->
                          <label for="gradoEstudiando"><strong>*</strong>Titulo de estudio</label>
                          <select class="form-control" name="" id="gradoEstudiando" disabled="true">
                            <!-- <option value="0">selecione...</option>
                            <option value="1">Bachiller</option>
                            <option value="2">Técnico</option>
                            <option value="3">Tecnólogo</option>
                            <option value="4">Profesional</option>
                            <option value="5">Profesional con especialización</option>
                            <option value="5">Profesional con maestría</option> -->
                          </select>
                        </div>
                        <div class="col-sm-6 col-xs-12">
                          <label for="especializacion"><strong>*</strong>Nombre de la carrera</label>
                          <input type="text" name="tituloEs" id="nameCarrera" class="form-control" style="text-align: center;" maxlength="50" disabled="true">
                        </div>
                      </div>
                    </div>
                  </div>
                  <!-- Footer -->
                  <div class="box-footer">
                    
                  </div>
              </div>
              </div>
          </div>
          <!-- Tercera fila -->
          <div class="row">
            <!-- Información Laboral -->
            <div class="col-sm-12">
              <div class="box box-info">
                <div class="box-header">
                  <i class="fas fa-briefcase"></i>
                  <h3 class="box-title"> Información Laboral</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Cuerpo -->
                <div class="box-body">
                  <!-- Primera fila -->
                  <div class="row">
                    <!--  -->
                    <div class="col-sm-12">
                      <!-- Horario de trabajo -->
                      <div class="col-sm-4">
                        <label for="horaTrabajo"><strong>*</strong>Horario de trabajo</label>
                        <select class="form-control" id="horaTrabajo">
                          <!-- <option value="0">Seleccione...</option>
                          <option value="1">6 am a 4:30 pm</option>
                          <option value="2">7 am a 5:30 pm</option>
                          <option value="3">7:30 am a 6:00 pm</option> -->
                        </select>
                      </div>
                      <div class="col-sm-4">
                      <!-- Tipo de contrato -->
                      <label for="tipoContrato"><strong>*</strong>Tipo de contrato</label>
                      <select class="form-control" id="tipoContrato">
                        <!-- <option value="0">Seleccione...</option>
                        <option value="1">Fijo a 3 meses</option>
                        <option value="2">En misión</option>
                        <option value="3">Indefinido</option>
                        <option value="4">Aprendiz</option>
                        <option value="5">Practica</option> -->
                      </select>
                      </div>
                      <!-- Cargo -->
                      <div class="col-sm-4">
                        <label for="cargo"><strong>*</strong>Cargo</label>
                        <select class="form-control" id="cargo">
                          <!-- <option value="0">Seleccione...</option>
                          <option value="1">APRENDIZ</option> -->
                        </select>
                      </div>
                    </div>
                  </div>
                  <br>
                  <!-- Segunda fila -->
                  <div class="row">
                    <div class="col-sm-12">
                      <!-- Tiene recurso humano acargo -->
                      <div class="col-sm-2" align="center">
                        <label for="recursoH">Personal a cargo</label>
                        <br>
                        <div class="checkbox">
                          <label style="font-size: 1em">
                              <input type="checkbox" value="1" id="recursoH">
                              <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                          </label>
                        </div>
                      </div>
                      <!-- Fecha vencimiento contrato -->
                      <div class="col-sm-3">
                        <label for="fechaVC">Fecha de vencimiento contrato</label>
                        <div class="input-group date fh-date">
                          <div class="input-group-addon">
                            <i class="fa fa-calendar"></i>
                          </div>
                          <input type="text" class="form-control pull-right" id="fechaVC" readonly="true" placeholder="DD-MM-YYYY">
                        </div>
                        <button class="btn btn-primary btn-xs pull-right" id="limpiarFecha" onclick="limpiarFechaVencimientocontrato();">R</button>
                      </div>
                      <!-- Empresa contratante -->
                      <div class="col-sm-7">
                        <label for="empresaCont">Empresa Contratante</label>
                        <div class="input-group">
                          <input type="text" class="form-control" id="empresaCont"readonly="true">
                          <label class="input-group-addon"><i class=""></i></label>
                        </div>
                      </div>
                    </div>
                  </div>
                  <br>
                  <div class="row">
                    <!-- Area de trabajo -->
                    <div class="col-sm-4">
                      <label for="areaTrabajo"><strong>*</strong>Área de trabajo</label>
                      <select class="form-control" id="areaTrabajo">  
                        <!-- Contenido -->
                      </select>
                    </div>
                    <div class="col-sm-4"></div>
                    <!-- Clasificacion contable -->
                    <div class="col-sm-4">
                      <label for="areaTrabajo"><strong>*</strong>Clasificación contable</label>
                      <select class="form-control" id="clasificacionContable">
                        <!-- Contenido -->
                      </select>
                    </div>
                  </div>
                  <br>
                </div>
              </div>
            </div>
          </div>
          <!-- Cuarta fila -->
          <div class="row">
            <!-- Información secundaria basica -->
            <div class="col-sm-6">
              <div class="box box-info">
                <div class="box-header">
                  <i class="fas fa-user-circle"></i>
                  <h3 class="box-title">Información secundaria basica</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Cuerpo -->
                <div class="box-body">
                  <!-- primera fila -->
                  <div class="row">
                    <!-- Estado civil -->
                    <div class="col-sm-4">
                      <label for="estadoCivil"><strong>*</strong>Estado civil</label>
                      <select class="form-control" name="" id="estadoCivil">
                        <option value="0">selecione...</option>
                        <option value="1">Casado</option>
                        <option value="2">Soltero</option>
                        <option value="3">Viudo</option>
                        <option value="4">Unión Libre</option>
                        <option value="5">Separado</option>
                      </select>
                    </div>
                    <!-- Fecha de nacimiento -->
                    <div class="col-sm-4">
                      <label for="fechaNacimiento"><strong>*</strong>Fecha de nacimiento</label>
                      <div class="input-group date">
                        <div class="input-group-addon">
                          <i class="fa fa-calendar"></i>
                        </div>
                        <input type="text" class="form-control pull-right" id="fechaNacimiento" placeholder="DD-MM-YYYY">
                      </div>
                    </div>
                    <!-- Lugar de nacimiento -->
                    <div class="col-sm-4">
                      <label for="lugarNaci"><strong>*</strong>Lugar de nacimiento</label>
                      <input type="text" name="" id="lugarNaci" class="form-control" maxlength="50">
                      <!-- <select class="form-control" name="" id="lugarNaci">
                        <option value="0">selecione...</option>
                        <option value="1">Itague</option>
                        <option value="2">otro</option>
                      </select> -->
                      <!-- <input type="text" name="lugarN" id="lugarNaci" class="form-control"> -->
                    </div>
                  </div>
                  <br>
                  <!-- segundo fila -->
                  <div class="row">
                    <!-- Tipo de sangre -->
                    <div class="col-sm-3">
                      <label for="tipoSangre"><strong>*</strong>Tipo de sangre</label>
                      <select name="" id="tipoSangre" class="form-control">
                        <option value="0">Seleccione...</option>
                        <option value="1">O+</option>
                        <option value="2">O-</option>
                        <option value="3">AB+</option>
                        <option value="4">AB-</option>
                        <option value="5">A+</option>
                        <option value="6">A-</option>
                        <option value="7">B+</option>
                        <option value="8">B-</option>
                      </select>
                    </div>
                    <!-- Telefono fijo -->
                    <div class="col-sm-4">
                      <label for="telefonoFijo">Telefono fijo</label>
                      <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-phone"></i></span>
                        <input type="text" name="telefonoF" id="telefonoFijo" class="form-control" style="text-align: center;" maxlength="7">
                      </div>
                    </div>
                    <!-- Telefono celular -->
                    <div class="col-sm-4">
                      <label for="telefonoCelular">Telefono celular</label>
                      <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-mobile-alt"></i></span>
                        <input type="text" name="telefonoF" id="telefonoCelular" class="form-control" style="text-align: center;" maxlength="10">
                      </div>
                    </div>

                  </div>
                  <br>
                  <!-- Tercera fila -->
                  <div class="row">
                    <!-- EPS -->
                    <div class="col-sm-5">
                      <label for="EPS"><strong>*</strong>EPS</label>
                      <select name="" id="EPS" class="form-control">
                        <option value="0">Seleccione...</option>
                        <option value="1">Savia salud</option>
                      </select>
                    </div>
                    <!-- EPS -->
                    <div class="col-sm-5">
                      <label for="AFP"><strong>*</strong>AFP</label>
                      <select name="" id="AFP" class="form-control">
                        <option value="0">Seleccione...</option>
                        <option value="1">Porvenir</option>
                      </select>
                    </div>
                  </div><br>
                  <!-- Cuarta fila -->
                  <div class="row">
                    <!-- Altura -->
                    <div class="col-sm-3">
                      <label for="altura">Altura</label>
                      <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-text-height"></i></span>
                        <input type="text" name="" class="form-control" id="altura" placeholder="1.70 mts" value="" style="text-align: center;" maxlength="4">
                      </div>
                    </div>
                    <!-- Peso -->
                    <div class="col-sm-3">
                      <label for="peso">Peso</label>
                      <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-balance-scale"></i></span>
                        <input type="number" name="" class="form-control" id="peso" placeholder="80 kg" value="" min="0" maxlength="3">
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <!-- Informacion de salud -->
            <div class="col-sm-6">
              <div class="box box-info">
                <div class="box-header">
                  <i class="fas fa-syringe"></i>
                  <h3 class="box-title">Salud</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Cuerpo -->
                <div class="box-body">
                  <!-- Primera fila -->
                  <div class="row">
                    <!-- Fuma -->
                    <div class="col-sm-3" align="center">
                      <label for="fumar">Fuma?</label>
                      <div class="checkbox">
                        <label style="font-size: 1em">
                            <input type="checkbox" value="fuma" id="fumar">
                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>  
                        </label>
                      </div>
                    </div>
                    <!-- Cuantos cigarrillos al dia -->
                    <div class="col-sm-3">
                      <label for="NCigarrillos"># cigarrillos día</label>
                      <input value="" type="number" name="cuantosCigarrillos" class="form-control" id="NCigarrillos" min="1" max="200" style="text-align: center;" maxlength="3">
                    </div>
                    <!-- Consume Bebidas alcoholicas -->
                    <div class="col-sm-3" align="center">
                      <label for="fumar">Bebidas alcoholicas</label>
                      <div class="checkbox">
                        <label style="font-size: 1em">
                            <input type="checkbox" id="alcoholicas">
                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>  
                        </label>
                      </div>
                    </div>
                    <!-- Cuantos cigarrillos al dia -->
                    <div class="col-sm-3">
                      <label for="frecuenciaAlcohol">Frecuencia</label>
                      <select name="" id="frecuenciaAlcohol" class="form-control">
                        <option value="0">Selecione...</option>
                        <option value="1">DIARIO</option>
                        <option value="2">SEMANAL</option>
                        <option value="3">QUINCENAL</option>
                        <option value="4">MENSUAL</option>
                        <option value="5">RARA VEZ</option>
                      </select>
                    </div>
                  </div>
                  <br>
                  <!-- Segunda fila -->
                  <div class="row">
                    <div class="col-sm-12">
                      <label>ANTE UNA EMERGENCIA, EN CASO DE REQUERIR SER ATENDIDO POR LA BRIGADA O UNA EPS TIENE ALGUNA CONDICION ESPECIAL?</label>
                      <textarea name="anteUnaEmergencia" id="AntEmergencia"  placeholder="(toma medicamentos permanentes, enfermedades, llevar a un sitio especial, otro)"style="height: 9.5em; width: 100%;" maxlength="300"></textarea>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <!-- Quinta fila -->
          <div class="row">
            <!-- Información personal-->
            <div class="col-sm-12">
              <div class="box box-info">
                <div class="box-header">
                  <i class="far fa-user"></i>
                  <h3 class="box-title">Información Personal</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Cuerpo -->
                <div class="box-body">
                  <!-- Primera fila -->
                  <div class="row">
                    <!-- Actividades tiempo libre -->
                    <div class="col-sm-4">
                      <label for="actividadesLibres">Actividades tiempo libre</label><br>
                      <!-- Ese es un select multiple... -->
                      <select class="selectpicker form-control" multiple data-selected-text-format="count" id="actividadesLibres">
                        <!-- Contenido -->
                      </select>
                    </div>
                    <div class="col-sm-8">
                      <label>Otra actividad:</label>
                      <div class="input-group">
                        <span class="input-group-addon">
                          <i class="far fa-clock"></i>
                        </span>
                        <input id="otraActividad" class="form-control" type="text" maxlength="45" placeholder="Artes marciales, Aprender otro idioma...etc"></input>
                      </div>
                    </div>
                  </div>
                  <br>
                  <!-- -.-.-.- -->
                  <div class="row">
                  <div class="col-sm-1">
                    <label for="direccion" class="pull-right">Dirección:</label>
                  </div> 
                    <!-- Direccion -->
                    <div class="col-sm-5">
                        <div class="row">
                          <div class="col-sm-2" style="padding: 0 0 0 0;">
                            <select class="form-control" id="opt1">
                              <option value="0">-</option>
                              <option value="1">CR</option>
                              <option value="2">CL</option>
                              <option value="3">AV</option>
                              <option value="4">DG</option>
                              <option value="5">CIR</option>
                              <option value="6">TV</option>
                            </select>
                          </div>
                          <!--  -->
                          <div class="col-sm-2" style="padding: 0 0 0 0;">
                            <input type="text" name="" class="form-control" id="opt2" style="text-transform: uppercase;">
                          </div>
                          <!--  -->
                          <div class="col-sm-2" style="padding: 0 0 0 0;">
                            <input type="text" name="" class="form-control" placeholder="#" id="opt3" style="text-transform: uppercase;">
                          </div>
                          <!--  -->
                          <div class="col-sm-2" style="padding: 0 0 0 0;">
                            <input type="text" name="" class="form-control" placeholder="-" id="opt4" style="text-transform: uppercase;">
                          </div>
                          <!--  -->
                          <div class="col-sm-2" style="padding: 0 0 0 0;">
                            <select class="form-control" id="opt5">
                              <option value="0">-</option>
                              <option value="1">CA</option>
                              <option value="2">AP</option>
                              <option value="3">BD</option>
                              <option value="4">IN</option>
                            </select>
                          </div>
                          <!--  -->
                          <div class="col-sm-2" style="padding: 0 0 0 0;">
                            <input type="text" name="" class="form-control" placeholder="-" style="text-transform: uppercase;" id="opt6">
                          </div>
                        </div>
                        <!--  -->
                    </div>
                    <!-- Barrio -->
                    <div class="col-sm-2">
                      <label for="barrio" class="pull-right">Barrio:</label>
                    </div>
                    <div class="col-sm-4">
                      <input type="text" id="barrio" class="form-control pull-left" placeholder="Guayabal" maxlength="20">
                    </div>
                  </div><br>
                  <!-- Segunda fila -->
                  <div class="row">
                    <!-- Comuna -->
                    <div class="col-sm-1">
                      <label for="comuna">Comuna</label>
                      <input type="number" id="comuna" class="form-control" min="0" max="20" placeholder="60" maxlength="2">
                    </div>
                    <!-- Municipio -->
                    <div class="col-sm-4">
                      <label for="municipio"><strong>*</strong>Municipio</label>
                      <select class="form-control" name="" id="municipio">
                      <!--  -->
                      </select>
                    </div>
                    <!-- Estado socio economico(Estrato) -->
                    <div class="col-sm-1">
                      <label for="estrato">Estrato</label>
                      <input type="number" name="estratoE" id="estrato" class="form-control" min="1" max="6" placeholder="2" maxlength="1">
                    </div>
                    <!-- Mail -->
                    <div class="col-sm-6">
                      <label for="mail">E-mail</label>
                      <div class="input-group">
                        <input type="text" name="mail" id="mail" class="form-control" placeholder="" maxlength="50" readonly="true">
                        <span class="input-group-addon"><i class="fas fa-at"></i></span>
                      </div>
                    </div>
                  </div>
                  <br>
                  <!-- Tercera fila -->
                  <div class="row">
                    <!-- Personas con las que vive -->
                    <div class="col-sm-12">
                      <label>Personas con las que vive</label>
                      <br>
                      <!-- Primera columna -->
                      <div class="col-sm-6" style="border: solid #C9C9C9 1px; border-radius: 3.5px">
                        <label>Parentesco</label>
                        <!-- Fila 1 -->
                        <div class="row">
                          <!-- Primera columna -->
                          <div class="col-sm-7">
                            <!-- Parentesco -->
                            <div class="checkbox">
                              <!-- Madre -->
                              <label style="font-size: 1em">
                                  <input type="checkbox" value="" id="madre">
                                  <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                  Madre
                              </label>
                              <!-- Padre -->
                              <label style="font-size: 1em">
                                  <input type="checkbox" value="" id="padre">
                                  <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                  Padre
                              </label>
                              <!-- Hesmanos -->
                              <!-- <label style="font-size: 1em; font-weight:lighter;">Hermanos&nbsp;</label> -->
                              <!-- <input type="number" name="" min="0" max="20" style="width: 3em; text-align: center;"> -->
                            </div>
                            <!-- </label> -->
                          </div>
                        </div>
                        <!-- Fila dos -->
                        <div class="row" id="rowAcompañante">
                          <!-- Compañero(Novio/a, Esposo/a)-->
                          <div class="col-sm-5">
                            <!--  -->
                               <div class="checkbox">
                                 <label style="font-size: 1em">
                                     <input type="checkbox" value="" id="compañeroP" data-toggle="collapse" data-target=".multi-collapse" aria-expanded="false" aria-controls="multiCollapseExample1 multiCollapseExample2">
                                     <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                     Compañero(Novio/a, Esposo/a)
                                 </label>
                               </div>
                               <!-- Informacion de despliegue del acompañante -->                        
                          </div>
                          <!-- Segunda columna -->
                          <div class="col-sm-4">
                            <div class="col">
                                <div class="collapse multi-collapse acor" id="multiCollapseExample1">
                                  <div class="card card-body">
                                    <!-- <label>Nombre</label> -->
                                    <input type="text" name="nombreAC" id="acompañanteName" class="form-control" placeholder="*Nombre acompañante">
                                  </div>
                                </div>
                            </div> 
                          </div>
                          <!-- Tercera columna -->
                          <div class="col-sm-3">
                          <div class="col">
                              <div class="collapse multi-collapse acor" id="multiCollapseExample2">
                                <div class="card card-body">
                                  <!-- <label>Nombre</label> -->
                                  <input type="text" name="celularAC" id="celularAcompañante" class="form-control" placeholder="*Celular">
                                </div>
                              </div>
                          </div>  
                          </div>
                        </div>
                        <br>
                        <!-- Tercera fila -->
                        <div class="row">
                          <!-- Abuelos -->
                          <div class="col-sm-3 col-xs-6" align="center">
                            <label style="font-size: 1em; font-weight:lighter;">Abuelos</label>
                            <input value="0" type="number" name="" min="0" max="10" maxlength="2" id="abuelos" style="width: 3em; text-align: center;">
                          </div>
                          <!-- Tios -->
                          <div class="col-sm-3 col-xs-6" align="center">
                            <label style="font-size: 1em; font-weight:lighter;">Tios</label>
                            <input value="0" type="number" name="" min="0" max="10" maxlength="2" id="tios" style="width: 3em; text-align: center;">
                          </div>
                          <!-- Hermanos -->
                          <div class="col-sm-3 col-xs-6" align="center">
                            <label style="font-size: 1em; font-weight:lighter;">Hermanos</label>
                            <input value="0" type="number" name="" min="0" max="10" maxlength="2" id="hermanos" style="width: 3em; text-align: center;">
                          </div>
                          <!-- Otros -->
                          <div class="col-sm-3 col-xs-6" align="center">
                            <label style="font-size: 1em; font-weight:lighter;">Otros</label>
                            <input value="0" type="number" name="" min="0" max="10" maxlength="2" id="otros" style="width: 3em; text-align: center;">
                          </div>
                        </div>
                        <br>
                        <!-- Cuarta fila -->
                      <div id="CantidadDeHijos">
                        <div class="row" id="HijosRow">
                          <!-- Columna 1 -->
                          <div class="col-sm-2 col-xs-4">
                            <!--  -->
                            <div class="checkbox">
                              <label style="font-size: 1em">
                                  <input type="checkbox" value="" id="hijos" data-toggle="collapse" data-target=".multi-collapse1" aria-expanded="false" aria-controls="despliegueHijo1 despliegueHijo2 despliegueHijo3 despliegueHijo4">
                                  <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                  Hijos
                              </label>
                            </div>
                            <!--  -->
                          </div>
                          <!-- Acordeon columna 2-->
                          <div class="col-sm-5 col-xs-10">
                            <div class="col">
                                <div class="collapse multi-collapse1 acordeon1" id="despliegueHijo1">
                                  <div class="card card-body">
                                    <!-- <label>Nombre</label> -->
                                    <input type="text" name="nameHijo" id="" class="form-control limpiarC" placeholder="*Nombre completo del hijo" style="text-transform: capitalize;">
                                  </div>
                                </div>
                            </div>
                            <div class="col">
                              <div class="collapse multi-collapse1 acordeon1" id="despliegueHijo2">
                                <div class="card card-body">
                                  <!-- <label>Nombre</label> -->
                                  <div class="input-group date">
                                    <div class="input-group-addon">
                                      <i class="fa fa-calendar"></i>
                                    </div>
                                    <input type="text" class="form-control pull-right limpiarC" id="" placeholder="F.N dd-mm-yyyy" name="fechaNH">
                                  </div>
                                </div>
                              </div>
                            </div>
                            <!--  -->
                          </div>
                          <!-- Columna 3 -->
                          <div class="col-sm-4">
                            <div class="col">
                              <div class="collapse multi-collapse1 acordeon1" id="despliegueHijo3">
                                <div class="card card-body">
                                  <!-- <label>Nombre</label> -->
                                    <div class="checkbox">
                                      <!-- Madre -->
                                      <label style="font-size: 1em">
                                          <input type="checkbox" value="" id="" checked>
                                          <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                          Vive con el ?
                                      </label>
                                    </div>
                                    <div class="pull-right">
                                      <label class="btn btn-default" id="masHijos" onclick="agregarMasInputHijos(this,1);"><span><i class="fas fa-plus"></i></span></label>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                        </div>
                      </div>
                      <br>
                        <!-- Quienta -->
                        <!-- Informacion sobre los hijos e hijastros -->
                      <div id="CantidadDeHijastros">
                        <div class="row" id="HijastrosRow">
                          <!-- Falta colocar los hijos e hijastros y sus respectivos menu de despliegue -->
                          <!-- Columna 1 -->
                          <div class="col-sm-2 col-xs-4">
                            <!--  -->
                            <div class="checkbox">
                              <label style="font-size: 1em">
                                  <input type="checkbox" value="" id="hijastro" data-toggle="collapse" data-target=".multi-collapse2" aria-expanded="false" aria-controls="despliegueHijastro1 despliegueHijastro2 despliegueHijastro3">
                                  <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                  Hijastro
                              </label>
                            </div>
                            <!--  -->
                          </div>
                          <!-- Acordeon columna 2-->
                          <div class="col-sm-5 col-xs-10">
                            <div class="col">
                                <div class="collapse multi-collapse2 acordeon2" id="despliegueHijastro1">
                                  <div class="card card-body">
                                    <!-- <label>Nombre</label> -->
                                    <input type="text" name="nameHijo" id="" class="form-control limpiarC" style="text-transform: capitalize;" placeholder="*Nombre completo hijastro">
                                  </div>
                                </div>
                            </div>
                            <div class="col">
                              <div class="collapse multi-collapse2 acordeon2" id="despliegueHijastro2">
                                <div class="card card-body">
                                  <!-- <label>Nombre</label> -->
                                  <div class="input-group date">
                                    <div class="input-group-addon">
                                      <i class="fa fa-calendar"></i>
                                    </div>
                                    <input type="text" class="form-control pull-right limpiarC" id="" placeholder="F.N dd-mm-yyyy" name="fechaNH">
                                  </div>
                                </div>
                              </div>
                            </div>
                            <!--  -->
                          </div>
                          <!-- Columna 3 -->
                          <div class="col-sm-4">
                            <div class="col">
                              <div class="collapse multi-collapse2 acordeon2" id="despliegueHijastro3">
                                <div class="card card-body">
                                  <!-- <label>Nombre</label> -->
                                    <div class="checkbox">
                                      <!-- Madre -->
                                      <label style="font-size: 1em">
                                          <input type="checkbox" value="" id="" checked>
                                          <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                          Vive con el ?
                                      </label>
                                    </div>
                                    <div class="pull-right">
                                      <label class="btn btn-default" name="masHijastros" onclick="agregarMasInputHijos(this,2);"><span><i class="fas fa-plus"></i></span></label>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                        </div>
                      </div>
                        <!-- /Informacion sobre los hijos e hijastros -->
                        <br>
                      </div>
                      <!-- Segunda columna -->
                      <div class="col-sm-6">
                        <!-- Priemera fila -->
                        <div class="row">
                          <!-- Tipo de vivienda -->
                          <div class="col-sm-6">
                            <label for="tipoVivienda"><strong>*</strong>Tipo de vivienda</label>
                            <select name="" id="tipoVivienda" class="form-control">
                              <option value="0">Seleccione...</option>
                              <option value="1">Propia</option>
                              <option value="2">Familiar</option>
                              <option value="3">Alquilada</option>
                            </select>
                          </div>
                        </div><br>
                        <div class="row">
                          <!-- Persona de contacto en caso de emergencia -->
                          <div class="col-sm-7">
                            <label for="personaEmergencia">Persona de contacto en caso de emergencia</label>
                            <div class="input-group">
                              <span class="input-group-addon"><i class="fas fa-user-plus"></i></span>
                              <input type="text" name="" class="form-control" id="personaEmergencia" maxlength="50">
                            </div>
                          </div>
                          <!-- Parentesco -->
                          <div class="col-sm-5">
                            <label for="CasoEParentezco">Parentesco</label>
                            <select name="" id="CasoEParentezco" class="form-control">
                              <option value="0">Seleccione...</option>
                              <option value="1">Madre</option>
                              <option value="2">Padre</option>
                              <option value="3">Hermano/a</option>
                              <option value="4">Novio/a, esposo/a</option>
                              <option value="5">Abuelo/a</option>
                              <option value="6">Tio/a</option>
                              <option value="7">Hijo/a</option>
                              <option value="8">Hijastro/a</option>
                              <option value="9">Otro</option>
                            </select>
                          </div>
                        </div>
                        <br>
                        <div class="row">
                          <div class="col-sm-12">
                            <label for="telefonoEM">Telefono</label>
                            <div class="input-group">
                              <span class="input-group-addon">
                                <i class="fas fa-phone"></i>
                              </span>
                              <input type="text" name="telefono" class="form-control" id="telefonoEM" maxlength="10">
                            </div>
                          </div>
                        </div>
                        <br>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <!-- sexta fila  -->
          <div class="row">
            <div class="col-sm-12">
              <div class="box box-info">
                <div class="box-header">
                  <i class="fas fa-user"></i>
                  <h3 class="box-title"> otra información</h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                    <button type="button" class="btn btn-box-tool" data-widget="collapse">
                      <i class="fa fa-minus"></i>
                    </button>
                  </div>
                </div>
                <!-- Cuerpo -->
                <div class="box-body">
                  <!-- Otra información -->
                  <div class="row">
                    <!-- Talla Camisa -->
                    <div class="col-sm-1">
                      <label for="tallaCamisa">T Camisa</label>
                      <input type="text" maxlength="3" name="tallaCamisa" id="tallaCamisa" class="form-control" style="text-align: center;">
                    </div>
                    <!-- Talla Pantalon -->
                    <div class="col-sm-1">
                      <label for="tallaPantalon">T Pantalon</label>
                      <input type="number" min="0" max="50" name="tallaPantalon" id="tallaPantalon" class="form-control" style="text-align: center;">
                    </div>
                    <!-- Talla Zapatos -->
                    <div class="col-sm-1">
                      <label for="tallaZapatos">T Zapatos</label>
                      <input type="number" min="0" max="50" name="tallaZapatos" id="tallaZapatos" class="form-control" style="text-align: center;">
                    </div>
                    <!-- Vigencia curso de alturas -->
                    <div class="col-sm-2">
                      <label for="vigenciAlturas">Vigencia curso de alturas</label>
                      <!-- <input type="text" name="vigenciAlturas" id="vigenciAlturas" class="form-control"> -->
                      <div class="input-group date fh-date">
                        <div class="input-group-addon">
                          <i class="fa fa-calendar"></i>
                        </div>
                        <input type="text" class="form-control pull-right" id="vigenciAlturas" placeholder="DD-MM-YYYY" readonly="true">
                      </div>
                    </div>
                    <!-- Requiere o tiene el curso de altura -->
                    <div class="col-sm-2">
                      <label for="RequiereCursoAlturas">Requiere o tiene el curso de altura</label>
                      <div class="checkbox">
                        <!-- -->
                        <label style="font-size: 1em">
                            <input type="checkbox" value="" id="RequiereCursoAlturas">
                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                        </label>
                      </div>
                    </div>
                    <!-- HA PERTENECIDO A UNA BRIGADA DE EMERGENCIA -->
                    <div class="col-sm-2">
                      <label for="pertenceBrigada">Ha pertenecido a una brigada de emergencia?</label>
                      <div class="checkbox">
                        <!-- -->
                        <label style="font-size: 1em">
                            <input type="checkbox" value="" id="pertenceBrigada">
                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                        </label>
                      </div>
                    </div>
                    <!-- HA PERTENECIDO A ALGUN COMITÉ DE LAS EMPRESAS -->
                    <div class="col-sm-2">
                      <label for="AlgunComite">Ha estado en algun comité de las empresas?</label>
                      <div class="checkbox">
                        <!-- -->
                        <label style="font-size: 1em">
                            <input type="checkbox" value="" id="AlgunComite">
                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                        </label>
                      </div>
                    </div>
                  </div>
                  </div>
                </div>
              </div>
            </div>
          <!--  -->
        </section>
<!-- Modals============================================================ -->
<!-- ... -->
<!-- /Modals -->  
    </div>
    <style type="text/css">

    /*#masHijos:hover{
      height: 1px;
    }*/
      .checkbox label:after, 
      .radio label:after {
          content: '';
          display: table;
          clear: both;
      }

      .checkbox .cr,
      .radio .cr {
          position: relative;
          display: inline-block;
          border: 1px solid #a9a9a9;
          border-radius: .25em;
          width: 1.3em;
          height: 1.3em;
          float: left;
          margin-right: .5em;
      }

      .radio .cr {
          border-radius: 50%;
      }

      .checkbox .cr .cr-icon,
      .radio .cr .cr-icon {
          position: absolute;
          font-size: .8em;
          line-height: 0;
          top: 20%;
          left: 20%;
      }

      .radio .cr .cr-icon {
          margin-left: 0.04em;
      }

      .checkbox label input[type="checkbox"],
      .radio label input[type="radio"] {
          display: none;
      }

      .checkbox label input[type="checkbox"] + .cr > .cr-icon,
      .radio label input[type="radio"] + .cr > .cr-icon {
          transform: scale(3) rotateZ(-20deg);
          opacity: 0;
          transition: all .3s ease-in;
      }

      .checkbox label input[type="checkbox"]:checked + .cr > .cr-icon,
      .radio label input[type="radio"]:checked + .cr > .cr-icon {
          transform: scale(1) rotateZ(0deg);
          opacity: 1;
      }

      .checkbox label input[type="checkbox"]:disabled + .cr,
      .radio label input[type="radio"]:disabled + .cr {
          opacity: .5;
      }
    </style>
<!-- Modal de la vista -->
    <div class="modal fade" id="empleados">
      <div class="modal-dialog">
        <div class="modal-content">
          <!-- Cabeza -->
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h2>Empleados</h2>
          </div>
          <!-- Cuerpo -->
          <div class="modal-body">
            <div class="row">
              <div class="col-sm-12">
                <label for="pro"><STRONG>*</STRONG>Empleado:</label>
                <select class="form-control selectpicker" id="solicitante" data-live-search="true">
                <!-- Selector buscar de productos -->
                <option value="0" >Seleccione...</option>
                </select> 
              </div>
            </div>
          </div>
          <!-- Pie -->
          <div class="modal-footer">
            <button type="button" id="enviarE" class="btn btn-primary">Enviar</button>
          </div>
        </div>
      </div>
    </div>
          <!-- <div class="row"> -->
            <!-- <div class="box box-info"> -->
              <!-- <div class="box-header"> -->
                <!-- <i class="fas fa-user"></i> -->
                <!-- <h3 class="box-title"> Empleado <small>Información principal basica.</small></h3> -->
                <!-- Minimizar -->
                <!-- <div class="pull-right box-tools"> -->
                  <!-- <button type="button" class="btn btn-box-tool" data-widget="collapse"> -->
                    <!-- <i class="fa fa-minus"></i> -->
                  <!-- </button> -->
                <!-- </div> -->
              <!-- </div> -->
              <!-- Cuerpo -->
              <!-- <div class="box-body"> -->
                <!-- Información principal basica -->
                <!-- <div class="row"> -->
                  <!--  -->
                <!-- </div> -->
              <!-- </div> -->
            <!-- </div> -->
          <!-- </div> -->
