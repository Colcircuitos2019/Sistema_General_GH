 <!-- Contenido del Wrapper. Contiene las paginas-->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <i class="fas fa-history"></i>&nbsp;Historial de asistencias
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

            .diagramas-donuht{
              height: 200px;
              position: relative;
              border: solid #C2C0C0 1px;
              border-radius: 3px;
            } 
          </style>
          <!-- Primera fila -->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-users"></i>
              <h3 class="box-title"> Historial </h3>
                          <!-- Minimizar -->
              <div class="pull-right box-tools">
              </div>
            </div>

            <!-- Cuerpo -->
            <div class="box-body">
            <!--  -->
            <div class="col-sm-12">
              <!-- Empleados -->
             <div class="col-sm-4">
              <label for="empleados"><strong>*</strong> Empleados</label>
               <select class="form-control selectpicker" id="empleados" data-live-search="true">
               <option value="0" data-subtext="" >Seleccione...</option>
               <?php
                 foreach ($empleados as $empleado) {
                   echo "<option value=\"".$empleado->documento."\" data-subtext=\"".$empleado->documento."\" >".$empleado->nombre1.' '.$empleado->nombre2.' '.$empleado->apellido1.' '.$empleado->apellido2."</option>";
                 } 
                ?>
               </select>
             </div>         
             <!-- Fecha de inicio -->
             <div class="col-sm-3">
               <label for="fechaI"> <strong>*</strong> Fecha de inicio</label>
               <div class="input-group date fh-date" >
                 <input type="text" id="fechaI"  class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
               </div>
             </div> 
             <!-- Fecha de fin  -->
             <div class="col-sm-3">
               <label for="fechaF">Fecha de fin</label>
               <div class="input-group date fh-date" >
                 <input type="text" id="fechaF"  class="form-control" readonly="readonly"><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
               </div>
             </div>
             <!-- Botton de busqueda -->
             <div class="col-sm-2">
              <br>
               <button class="btn btn-primary" id="btnBuscarHistorial" name="">Buscar</button>
             </div>    
            </div>
            <!--  -->
            </div>
            <div class="box-footer">
              
            </div>
            <!-- /Cuerpo -->
          </div>
          <!-- Segunda fila-->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-briefcase"></i>
              <h3 class="box-title"> Asistencias</h3>
                          <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>

            <!-- Cuerpo -->
            <div class="box-body">
              <div class="table-responsive" id="tablaA">
                
              </div>
            </div>
            <!-- footer -->
            <div class="box-footer">
              
            </div>
          </div>
          <!-- tercera fila-->
          <div class="box box-primary">
            <div class="box-header">
              <i class="fas fa-chart-bar"></i>
              <h3 class="box-title"> Diagrama de asistencias</h3>
                          <!-- Minimizar -->
              <div class="pull-right box-tools">
                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                  <i class="fa fa-minus"></i>
                </button>
              </div>
            </div>
            <br>
            <!-- Cuerpo -->
            <div class="box-body">
              <!-- Primera fila -->
              <div class="row">
                <!-- Eventos laborales -->
                <div class="col-sm-4">
                  <label>Evento laboral:</label>
                  <div class="chart diagramas-donuht" id="sales-chart"></div>
                </div>
                <!-- Eventos desayuno -->
                <div class="col-sm-4">
                  <label>Evento Desayuno:</label>
                  <div class="chart diagramas-donuht" id="sales-chart1"></div>
                  <button class="btn btn-primary btn-xs pull-right buttonsD" value="2">Detalle</button>
                </div>
                <!-- Evento Almuerzo -->
                <div class="col-sm-4">
                  <label>Evento Almuerzo:</label>
                  <div class="chart diagramas-donuht" id="sales-chart2"></div>
                  <button class="btn btn-primary btn-xs pull-right buttonsD" value="3">Detalle</button>
                </div>
              </div>
              <!-- Regunda fila -->
              <div class="row">
                <div class="col-sm-6">
                  <!-- Todos los eventos -->
                  <label>Porcentaje total eventos</label>
                  <div class="chart diagramas-donuht" id="">
                    <div class="chart" id="bar-chart" style="height: 200px;"></div>
                  </div>
                </div>
                <!--  -->
                <div class="col-sm-6">
                  <label>Lectores utilizados</label>
                  <div class="diagramas-donuht" id="sales-chart3">
                    <!--  -->
                  </div>
<!--                   <button class="btn btn-primary btn-xs pull-right" onclick="mostrarConsultarDetalleUsoLectores();">Detalle</button>
 -->                </div>
              </div>
              <br>
              <!-- tercera fila -->
              <div class="row">
                <div class="col-sm-6">
                <label>Horario laboral</label>
                <br>
                  <div class="table-responsive">
                    <table class="table table-striped">
                      <thead>
                          <tr>
                            <!-- <th scope="col">#</th> -->
                            <th scope="col" width="50%" align="center">Historial de tiempos</th>
                            <th scope="col" align="center">Tiempo (Horas)</th>
                          </tr>
                        </thead>
                        <tbody id="cuerpoHorario">
                        <!-- Cuerpo de los tiempos del empleado -->
                        </tbody>
                    </table>
                  </div>
                </div>
             <!-- Esto queda pendiente por desarrollar -->
              <div class="col-sm-6">
                <label>Tiempo que debe tener el empleado</label>
                <br>
                  <div class="table-responsive">
                    <table class="table table-striped">
                      <thead>
                          <tr>
                            <th scope="col">#</th>
                            <th scope="col" width="50%" align="center">Historial de tiempos</th>
                            <th scope="col" align="center">Tiempo (Horas)</th>
                          </tr>
                        </thead>
                        <tbody id="cuerpoHorarioEmpresa">
                          <tr>
                            <th scope="row">1</th>
                            <td align="center">Horas Normales que debe trabajar</td>
                            <td align="center">120</td>
                          </tr>
                          <tr>
                            <th scope="row">1</th>
                            <td align="center">Horas Normales que debe</td>
                            <td align="center">120</td>
                          </tr>
                          <tr>
                            <th scope="row">2</th>
                            <td align="center">Tiempo que debe tener de desayuno</td>
                            <td align="center">50</td>
                          </tr>
                          <tr>
                            <th scope="row">3</th>
                            <td align="center">Tiempo que debe tener de almuerzo</td>
                            <td align="center">5</td>
                          </tr>
                        </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
            <!-- footer -->
            <div class="box-footer">
              
            </div>
          </div>
          <!-- Cuarta fila -->
          <div class="row">
            <div class="col-sm-5">
              <div class="box box-primary">
                <div class="box-header">
                  <i class="fas fa-file-medical"></i>
                  <h3 class="box-title"> Incapacidades </h3>
                  <!-- Minimizar -->
                  <div class="pull-right box-tools">
                  </div>
                </div>

                <!-- Cuerpo -->
                <div class="box-body">
                <!--  -->
                  <div class="col-sm-12">
                   <div class="table-responsive" id="incapacidades">
                    
                   </div>
                  </div>  
                <!--  -->
                </div>

                <div class="box-footer">
                  
                </div>
                <!-- /Cuerpo -->
              </div>
            </div>
            <div class="col-sm-7">
             <div class="box box-primary">
               <div class="box-header">
                 <i class="fas fa-people-carry"></i>
                 <h3 class="box-title"> Permisos </h3>
                  <!-- Minimizar -->
                 <div class="pull-right box-tools">
                 </div>
               </div>

               <!-- Cuerpo -->
               <div class="box-body">
               <!--  -->
                <div class="col-sm-12">
                  <div class="table-responsive" id="spacePermisos">
                   
                  </div>
                </div>  
               <!--  -->
               </div>
               <div class="box-footer">
                 
               </div>
               <!-- /Cuerpo -->
             </div> 
            </div>
          </div>
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
          <!--  --> 
        <!-- Footer de la ventana -->
        <div class="modal-footer">
          <!-- <button type="button" class="btn btn-primary"></button> -->
        </div>
        </div>  
      </div>
    </div>
  </div>
  <!-- Modal detalle de uso de los lectores -->
  <div class="modal fade" id="detalleLectores">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <button class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h1>Uso de Lectores</h1>
        </div>
        <div class="modal-body">
          <div class="row">
            
          </div>
        </div>
        <modal class="footer">
          
        </modal>
      </div>
    </div>
  </div>

        </section>

    </div>