// variables cache
var $tablaAsistencias = $('#tablaA');
var $empleado= $('#empleados');
var $fechaI= $('#fechaI');
var $fechaF= $('#fechaF');
var $btnBuscarH= $('#btnBuscarHistorial');
// ----
var $horasNormales= $('#hNormales');
var $horasExtras = $('#hExtras');
var $horasAceptadas= $('#hAceptadas');
var $horasRechazadas= $('#hRechazadas');
var $textDecrip= $('#hDescrip');
var $tabla2= $('#tablaM');
var $cuerpoTablaH= $('#cuerpoHorario');
// ...
var documento='';
var fecha1='';
var fecha2='';
// ...
var tiempo=0;
var tarde=0;
var noAsistio=0;

$(document).ready(function() {
	// Consultar historial
	$btnBuscarH.click(function(event) {
		if ((($fechaI.val()!='' && $fechaF.val()!='') || $fechaI.val()!='') && $empleado.find('option:selected').val()>0) {
            documento=$empleado.find('option:selected').val();
            fecha1=formatoFecha($fechaI.val());
            fecha2=($fechaF.val()!=''?formatoFecha($fechaF.val()):'');
            // ...
			consultarAsistenciaRangoFechas();
            consultarCantidadEstadoEvento();
		}else{
			swal('Alerta','Llena los campos obligatorios','warning',{buttons:false,timer:2000});
		}
	});
    // 
    /**/
    $('.buttonsD').click(function(event) {
        // console.log(documento);
        consultarEventos($(this).val());
    });
    /**/
});
// ...
function consultarEventos(evento) {
    $.post(baseurl+'Empleado/cHistorial/consultarEventos', 
        {
            documento: documento,
            fechaI: fecha1,
            fechaF: fecha2,
            evento: evento//Puede ser el evento de desayuno el el evento del almuerzo
        }, function(data) {
            // ...
            var result= JSON.parse(data);
        // Esconder componente del modal
        $('#horasTotales').hide();
        // Cargar tabla...
        cargartablaDetallesEventos(result);
        // Mostrar tabla
        $('#detalleAsistencias').modal('show');
    });
}

function calcularPorcentajeasistencias() {
    // ...
    var total= (tiempo+tarde+noAsistio); 
    //BAR CHART
    $('#bar-chart').empty();
    // ...
    var bar = new Morris.Bar({
      element: 'bar-chart',
      resize: true,
      data: [
        {y: 'a Tiempo', a: Math.ceil(((tiempo*100)/total))},
        {y: 'Tarde', a: Math.ceil(((tarde*100)/total))},
        {y: 'No asistio', a: Math.ceil(((noAsistio*100)/total))}
      ],
      // Llegadas a tiempo, llegadas tardes, No asistio
      barColors: ['#3860F5'],
      xkey: 'y',
      ykeys: ['a'],
      labels: ['Porcentaje'],
      hideHover: 'auto'
    });
     tiempo=0;
     tarde=0;
     noAsistio=0;
     consultarHorarioInfolaboral();
    // ...
}

function consultarHorarioInfolaboral() {
 $.post(baseurl+'Empleado/cHistorial/totalHorasTrabajadasNormales', 
    {
        documento: documento,
        fechaI: fecha1,
        fechaF: fecha2,
        evento: 1, //1 horas norales trabajadas, 2 horas extras trabajadas (aceptadas)
        estado: 1
    }, function(data) {
     // ...
     // console.log(data);
     $cuerpoTablaH.empty();
     // Numero de horas totales normales trabajadas por el empleado
    $cuerpoTablaH.append('<tr>'+
                                  '<td align="center">Horas Trabajadas Normales</td>'+
                                  '<td align="center">'+data+'</td>'+
                               '</tr>');
     // Total Horas Extras
    $.post(baseurl+'Empleado/cHistorial/totalHorasTrabajadasNormales', 
        {
            documento: documento,
            fechaI: fecha1,
            fechaF: fecha2,
            evento: 2, //1 horas norales trabajadas, 2 horas extras trabajadas (aceptadas)
            estado: 2
        }, function(data) {
            $cuerpoTablaH.append('<tr>'+
                                         '<td align="center">Total Horas Extras</td>'+
                                         '<td align="center">'+data+'</td>'+
                                      '</tr>');
            //Horas Extrar Trabajadas (Aprobadas)
            $.post(baseurl+'Empleado/cHistorial/consultarHorasExtrasAceptadasYRechazadas', 
               {
                   documento: documento,
                   fechaI: fecha1,
                   fechaF: fecha2,
                   accion: 1, // 1 Horas Extras Aceptadas 2 Horas Extras Rechazadas
               }, function(data) {
                $cuerpoTablaH.append('<tr>'+
                                             '<td align="center">Horas Extrar Trabajadas (Aprobadas)</td>'+
                                             '<td align="center">'+data+'</td>'+
                                          '</tr>');
                //Horas Extrar Trabajadas (Rechazadas)
                $.post(baseurl+'Empleado/cHistorial/consultarHorasExtrasAceptadasYRechazadas', 
                   {
                       documento: documento,
                       fechaI: fecha1,
                       fechaF: fecha2,
                       accion: 2, // 1 Horas Extras Aceptadas 2 Horas Extras Rechazadas
                   }, function(data) {
                    $cuerpoTablaH.append('<tr>'+
                                                 '<td align="center">Horas Extrar Trabajadas (rechazadas)</td>'+
                                                 '<td align="center">'+data+'</td>'+
                                              '</tr>');
                    // Horas extrar por aprobar
                    $.post(baseurl+'Empleado/cHistorial/totalHorasTrabajadasNormales', 
                       {
                           documento: documento,
                           fechaI: fecha1,
                           fechaF: fecha2,
                           evento: 2, //1 horas norales trabajadas, 2 horas extras trabajadas (aceptadas)
                           estado: 0
                       }, function(data) {
                        $cuerpoTablaH.append('<tr>'+
                                                     '<td align="center">Horas Extrar por aceptar</td>'+
                                                     '<td align="center">'+data+'</td>'+
                                                  '</tr>');
                        // Consultar tiempo total de desayuno por el empleado y los rangos de fecha
                        consultarTiempoAsistenciasDesayunoOAlmuerzo();
                       });
                      // ...
                    });
                  //... 
               });
            // ...
        });
    // ...
 });
}

function consultarTiempoAsistenciasDesayunoOAlmuerzo() {
    // ... Se tiene que tener en cuenta los diferentes horarios que puede tener el empleados, por ende puede cambiar el tiempo asignado para el desayuno//Esto es para cuando se calcula el tiempo teorico del desayuno, lo mismo aplica para el almuerzo.
    $.post(baseurl+'Empleado/cHistorial/consultarTiemposEventosDesayunoOAlmuerzo', //Realizar una mejora a la hora de calcular el tiempo total de desayuno
        {
            documento: documento,
            fechaI: fecha1,
            fechaF: fecha2,
            evento: 2 //2 Evento del desayuno y 3 Evento del almuerzo
        }, function(data) {
        // Tiempo total empleado en desayuno por el empleado en el rango de fecha o una fecha en especifico... 
        $cuerpoTablaH.append('<tr>'+
                                     '<td align="center">Tiempo total empleado en Desayuno</td>'+
                                     '<td align="center">'+data+'</td>'+
                                  '</tr>');
        // ...
        $.post(baseurl+'Empleado/cHistorial/consultarTiemposEventosDesayunoOAlmuerzo', //Realizar una mejora a la hora de calcular el tiempo total del almeurzo 
            {
                documento: documento,
                fechaI: fecha1,
                fechaF: fecha2,
                evento: 3 //2 Evento del desayuno y 3 Evento del almuerzo
            }, function(data) {
                $cuerpoTablaH.append('<tr>'+
                                             '<td align="center">Tiempo total empleado en Almuerzo</td>'+
                                             '<td align="center">'+data+'</td>'+
                                          '</tr>');
                // Se encarga de consultar el tiempo
                tiempototalConsumidoEnPermisos();//Este pendiente solucionar el procedimiento almacenado
            });
    });
    // ...
}

function tiempototalConsumidoEnPermisos() {//Se encarga de consultar el tiempo total consumido en permisos
$.post(baseurl+'Empleado/cHistorial/tiempoTotalEmpleadoPermiso', 
  {
    documento: documento,
    fechaI: fecha1,
    fechaF: fecha2
  }, function(data) {
  $cuerpoTablaH.append('<tr>'+
                          '<td align="center">Tiempo total de Permiso/s</td>'+
                          '<td align="center">'+data+'</td>'+
                      '</tr>');
  contarDiasTotalesDeTrabajo();
});
}

// .......................................
function contarDiasTotalesDeTrabajo() {//Pendiente desarrollarla despues de que terminde de realizar
  $.post(baseurl+'Empleado/cHistorial/consultarCantidadDiasTrabajados', 
    {
      fechaI: fecha1,
      fechaF: fecha2
    }, function(data) {
    // Pendiente... Comming soon
  });
}



function consultarIncapacidadesEmpleadoRangoFechas() {
  $.post(baseurl+'Empleado/cIncapacidades/incapacidadesEmpleadosRangoFechas', 
    {
      documento: documento,
      fechaI: fecha1,
      fechaF: fecha2
    }, function(data) {
      var result= JSON.parse(data);
      // ...
      // $.post(baseurl+'', {param1: 'value1'}, function(data, textStatus, xhr) {
      //   /*optional stuff to do after success */
      // });
      $('#incapacidades').empty();
      $('#incapacidades').html('<table class="display" id="empleado">'+
                                   '<thead>'+
                                      '<th>Fecha Incapacidad</th>'+
                                      '<th>Tipo de incapacidad</th>'+
                                      '<th>Dias</th>'+
                                      // '<th>Detalles</th>'+
                                   '</thead>'+
                                   '<tbody id="cuerpoInc">'+
                                   '</tbody>'+ 
                                '</table>');
      $.each(result, function(index, row) {
         $('#cuerpoInc').append('<tr>'+
                                    '<td>'+row.fecha_incapacidad+'</td>'+
                                    '<td>'+clasificarTipoIncapacidad(row.idTipoIncapacidad)+'</td>'+
                                    '<td>'+row.dias+'</td>'+
                                    // '<td>'+'<button class="btn btn-success"><span><i class="fas fa-eye"></i></span>Ver</button>'+'</td>'+
                                '</tr>');
      });
      $('#empleado').dataTable(configuracionDataTable());
  });
}

function consultarPermisosEmpleadoRangoFecha() {
    $.post(baseurl+'Empleado/cPermiso/consultarPermisoEmpleadoRangoFechas', 
      {
        documento: documento,//Variable global
        fechaI: fecha1,
        fechaF: fecha2
      }, function(data) {
        var result= JSON.parse(data);
        // ...
        $('#spacePermisos').empty();
        $('#spacePermisos').html('<table class="display" id="permisos">'+
                                     '<thead>'+
                                        '<th>Clasificado Por:</th>'+
                                        '<th>Fecha Solicitud</th>'+
                                        '<th>Fecha Permiso</th>'+
                                        '<th>Horas</th>'+
                                        '<th>Estado</th>'+
                                        // '<th>Detalles</th>'+
                                     '</thead>'+
                                     '<tbody id="cuerpoPer">'+
                                     '</tbody>'+ 
                                  '</table>');
        // ...
        $.each(result, function(index, row) {
           $('#cuerpoPer').append('<tr>'+
                                      '<td>'+row.usuario+'</td>'+
                                      '<td>'+row.fecha_solicitud+'</td>'+
                                      '<td>'+row.fecha_permiso+'</td>'+
                                      '<td>'+row.numero_horas+'</td>'+
                                      '<td>'+tagEstado(row.estado)+'</td>'+
                                      // '<td>'+'<button class="btn btn-success"><span><i class="fas fa-eye"></i></span>Ver</button>'+'</td>'+
                                  '</tr>');
        });
        // ...
        $('#permisos').dataTable(configuracionDataTable());
    });
}

function tagEstado(estado) {
    var mensaje = '';
    switch (Number(estado)) {
        case 1: //Aprobado
            mensaje = '<span><small class="label bg-blue">Aprobado</small></span>';
            break;
        case 2: //Rechazado
            mensaje = '<span><small class="label bg-red">Rechazado</small></span>';
            break;
        case 3: //Terminado
            mensaje = '<span><small class="label bg-green">Terminado</small></span>';
            break;
        case 0: //Pendiente
            mensaje = '<span><small class="label bg-yellow">Pendiente</small></span>';
            break;
    }
    return mensaje;
}

function clasificarTipoIncapacidad(idTipo) {
  var mensaje='';
  switch(Number(idTipo)){
    case 1://General
      mensaje='General';
      break;
    case 2://Trabajo
      mensaje='Trabajo';
      break;
    case 3://Licencia M/P
      mensaje='Licencia M/P';
      break;
  }
  return mensaje;
}

function consultarCantidadEstadoEvento() {
    // ...
        $.post(baseurl+'Empleado/cHistorial/consultarCantidadEstadosEventos', 
            {
                documento: $empleado.find('option:selected').val(),
                fechaI: fecha1,
                fechaF: fecha2,
                evento: 1 //Evento laboral
            }, function(data) {
            // ...
            var result= JSON.parse(data);
            // console.log(result);
                 cantidadEstadoEventos(result,1);
            // ...
            $.post(baseurl+'Empleado/cHistorial/consultarCantidadEstadosEventos', 
                {
                    documento: $empleado.find('option:selected').val(),
                    fechaI: fecha1,
                    fechaF: fecha2,
                    evento: 2 //Evento Desayuno
                }, function(data) {
                // ...
                var result= JSON.parse(data);
                // console.log(result);
                     cantidadEstadoEventos(result,2);
                // ....
                $.post(baseurl+'Empleado/cHistorial/consultarCantidadEstadosEventos', 
                    {
                        documento: $empleado.find('option:selected').val(),
                        fechaI: fecha1,
                        fechaF: fecha2,
                        evento: 3 //Evento Almuerzo
                    }, function(data) {
                    // ...
                    var result= JSON.parse(data);
                    // console.log(result);
                         cantidadEstadoEventos(result,3);
                         calcularPorcentajeasistencias();
                         cantidadUsoLectoresAsistencia();
                         consultarIncapacidadesEmpleadoRangoFechas();
                         consultarPermisosEmpleadoRangoFecha();
                });
            });
        });
    // ...
}

function cantidadEstadoEventos(row,evento) {
//evento= Esta variable va hacer referencia a los diferentes eventos del sistema (Laboral, Desayuno, Almuerzo).
    // ...
    var elemento= (evento==1?'sales-chart':(evento==2?'sales-chart1':'sales-chart2'));
        //DONUT CHART
        if (evento==1) {//Evetnto laboral
            // var datos=array();
            var donut = new Morris.Donut({
              element: elemento,
              resize: true,
              colors: ["#f56954", "#00a65a"],
              data: [
                {label: "Llegadas tardes", value: row.tarde},
                {label: "Llegadas a tiempo", value: row.aTiempo}
              ],
              hideHover: 'auto'
            });
            // ...
            tiempo+=Number(row.aTiempo);
            tarde+=Number(row.tarde);
        }else{//Evento de desayuno y de almuerzo
            var donut = new Morris.Donut({
              element: elemento,
              resize: true,
              colors: ["#f56954", "#00a65a",'#E0DD18'],
              data: [
                {label: "Llegadas tardes", value: row.tarde},
                {label: "Llegadas a tiempo", value: row.aTiempo},
                {label: "No asisitio", value: row.noAsistio}
              ],
              hideHover: 'auto'
            });
            tiempo+=Number(row.aTiempo);
            tarde+=Number(row.tarde);
            noAsistio+=Number(row.noAsistio);
        }
    // 
}

function cantidadUsoLectoresAsistencia() {
 $.post(baseurl+'Empleado/cHistorial/cantidadUsoLectores',
    {
       documento: documento,
       fechaI: fecha1,
       fechaF: fecha2 
    }, function(data) {
        // ...
        var result= JSON.parse(data);
        var datos= new Array();
        $.each(result, function(index, item) {
             // console.log(index, item);
             datos.push({label: index, value: item});
        });
        // ...
        $('#sales-chart3').empty();
        // Generar Diagrama
        var donut = new Morris.Donut({
              element: 'sales-chart3',
              resize: true,
              colors: ["#f56954", "#00a65a",'#E0DD18','#E58A1E','#DD20FF','#45EAFE','#959595'],
              data: datos,
              hideHover: 'auto'
            });
    });   
}

function mostrarConsultarDetalleUsoLectores() {
    $('#detalleLectores').modal('show');
}


function consultarAsistenciaRangoFechas() { //Tipo de busqueda, Documento y Fechasucking
    // debugger;
    $.post(baseurl + 'Empleado/cAsistencia/asistenciasPorFechas', {
        fecha1: ($fechaI.val() != '' ? formatoFecha($fechaI.val()) : ''),
        fecha2: ($fechaF.val() != '' ? formatoFecha($fechaF.val()) : ''),
        documento: $empleado.find('option:selected').val()
    }, function(data) {
        //Cast a json
        var result = JSON.parse(data);
        // Limpiar la tabla
        $tablaAsistencias.empty();
        $tablaAsistencias.html('<table class="display" id="tblFechasA">' + '<thead id="Cabeza">' + '<th>ID</th>' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Evento</th>' + '<th>Fecha Inicio</th>' + '<th>Hora inicio</th>' + '<th>Fecha fin</th>' + '<th>Hora fin</th>' + '<th>Estado</th>' + '<th>Detalle</th>' + '</thead>' + '<tbody id="cuerpoF">' + '</tbody>' + '</table>');
        // Agregar la informacion a la tabla
        $.each(result, function(index, row) {
            $('#cuerpoF').append('<tr>' + '<th>' + row.idAsistencia + '</th>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + '</td>' + '<td>' + clasificarEvento(row.idTipo_evento) + '</td>' + '<td>' + row.fecha_inicio + '</td>' + '<td>' + row.hora_inicio + '</td>' + '<td>' + row.fecha_fin + '</td>' + '<td>' + row.hora_fin + '</td>' + '<td>' + clasificarAsistencia(row.idEstado_asistencia) + '</td>' + '<td>' + '<button value="' + row.documento + ';' + row.fecha_inicio + '" type="button" onclick="mostrarDetalle(this.value,\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + '\')" class="btn btn-success "><span><i class="fas fa-eye"></i> ver' + '</span></button></td>' + '</tr>');
        });
        //Formato del data table
        $('#tblFechasA').DataTable();
        // ...
    });
}

function mostrarDetalle(doc, nombre) {
    var info = doc.split(';');
    document.getElementById('tituloD').innerHTML = 'Detalle Asistencia:  ' + nombre;
    consultarAsistenciaEmpleado(1, info[0], info[1]);
}

function consultarAsistenciaEmpleado(i, doc, fecha) { //Tipo de busqueda, Documento y Fecha
    var op = 0;
    $.post(baseurl + 'Empleado/cAsistencia/asistenciaPorEmpleado', {
        documento: doc,
        op: i,
        fec: fecha
    }, function(data) {
        // Cast a json
        var result = JSON.parse(data);
        // cargar tabla detalles
        cargartablaDetallesEventos(result);
        // ...
        // Mostar elementos del modal
        $('#horasTotales').show();
        // Consultar horas trabajadass
        consultarHorasTrabajadasDia(doc,fecha);
        // console.log(result);
        $('#detalleAsistencias').modal('show');
    });
}

function cargartablaDetallesEventos(result) {
    // Limpiar tabla
    $tabla2.empty();
    $tabla2.html('<table class="display" id="tblAsistenciaEmpleado">' + 
                    '<thead id="Cabeza">' + 
                       '<th>ID</th>' + 
                       '<th>Evento</th>' + 
                       '<th>Fecha Inicio</th>' + 
                       '<th>Hora inicio</th>' +
                       '<th>LectorI</th>'+ 
                       '<th>Fecha fin</th>' + 
                       '<th>Hora fin</th>' + 
                       '<th>LectorF</th>' + 
                       '<th>Estado</th>' + 
                       '<th>Tiempo</th>' +
                    '</thead>' + 
                    '<tbody id="cuerpoM">' +

                    '</tbody>' +
                 '</table>');
    // Agregar la informacion a la tabla
    $.each(result, function(index, row) {
        // 
        $('#cuerpoM').append('<tr>' + 
                               '<th>' + row.idAsistencia + '</th>' + 
                               '<td>' + clasificarEvento(row.idTipo_evento) + '</td>' + 
                               '<td>' + row.fecha_inicio + '</td>' + 
                               '<td>' + row.hora_inicio + '</td>' + 
                               '<td>' + row.lectorI + '</td>' + 
                               '<td>' + (row.fecha_fin == null ? '-' : row.fecha_fin) + '</td>' + 
                               '<td>' + (row.hora_fin == null ? '-' : row.hora_fin + '</td>') + 
                               '<td>' + (row.lectorF == null ? '-' : row.lectorF) + '</td>' + 
                               '<td>' + clasificarAsistencia(row.idEstado_asistencia) + '</td>' + 
                               '<td>' + (row.horas == null ? '-' : row.horas) + '</td>' + 
                            '</tr>');
    });
    // Formato del data table
    $('#tblAsistenciaEmpleado').DataTable(configuracionDataTable());
}


function configuracionDataTable() {
  return {
        "language": {
            "sProcessing": "Procesando...",
            "sLengthMenu": "Mostrar _MENU_ Registros",
            "sZeroRecords": "No se encontraron resultados",
            "sEmptyTable": "Ningún dato disponible en esta tabla",
            "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
            "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
            "sInfoPostFix": "",
            "sSearch": "Buscar:",
            "sUrl": "",
            "sInfoThousands": ",",
            "sLoadingRecords": "Cargando...",
            "oPaginate": {
                "sFirst": "Primero",
                "sLast": "Último",
                "sNext": "Siguiente",
                "sPrevious": "Anterior"
            },
            "oAria": {
                "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
                "sSortDescending": ": Activar para ordenar la columna de manera descendente"
            }
        }
    };
}
function consultarHorasTrabajadasDia(doc, fecha) {
    $.post(baseurl + 'Empleado/cAsistencia/consultarHorasTrabajadasDia', {
        documento: doc,
        fecha: fecha
    }, function(data) {
        var result = JSON.parse(data);
        $horasNormales.val(0);
        $horasExtras.val(0);
        $horasAceptadas.val(0);
        $horasRechazadas.val(0);
        $textDecrip.val('');
        $.each(result, function(index, row) {
            // Validar que tipo de horas son, horas normales o horas extras
            if (row.idEvento_laboral == 1) {
                $horasNormales.val(row.numero_horas);
            } else if (row.idEvento_laboral == 2) {
                $horasExtras.val(row.numero_horas);
                $horasAceptadas.val(row.horas_aceptadas);
                $horasRechazadas.val(row.horas_rechazadas);
                $textDecrip.val(row.descripcion);
            }
        });
    });
}

function clasificarAsistencia(estado) {
    if (estado == 1) {
        return '<span><small class="label bg-green">A Tiempo</small></span>';
    } else if (estado == 2) {
        return '<span><small class="label bg-red">Tarde</small></span>';
    } else if (estado == 3) {
        return '<span><small class="label bg-yellow">No asistio</small></span>';
    }
}

function clasificarEvento(evento) {
    if (evento == 1) { //Laboral
        return '<span><small class="label bg-blue">Laboral</small></span>';
    } else if (evento == 2) { //Desayuno
        return '<span><small class="label amarillo">Desayuno</small></span>';
    } else if (evento == 3) { //Almuerzo
        return '<span><small class="label morado">Almuerzo</small></span>';
    }
}

function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}