//Variables
var $documentoE = $('#doc');
var $tabla1 = $('#tblAsistenciaDia');
var $tabla2 = $('#tabla');
var $tabla3 = $('#tablaM');
var $tabla5 = $('#tblAsistenciaDesayunoDia');
var $tabla6 = $('#tblAsistenciaAlmuerzoDia');
var $tabla4 = $('#tblAsistenciaFecha');
var $fecha1 = $('#fechaI');
var $fecha2 = $('#fechaF');
// var $tabla5 = $('#detalleHora');
var $horasNormales = $('#hNormales');
var $horasExtras = $('#hExtras');
var $horasAceptadas = $('#hAceptadas');
var $horasRechazadas = $('#hRechazadas');
var $divHorasTrabajadas = $('#horasTotales');
var $textDecrip = $('#hDescrip');
// ...
var $tituloModal = $('#tituloD');
var $btnAsistencia = $('#editarAsistencia');
var $btnModificarAsistencia = $('#modificarAsistencia');
// 
$(document).ready(function() {
    //DateTimePiker
    $('.fh-date').datepicker({
        format: "yyyy-mm-dd",
        language: "es",
        multidate: false
    });
    // Tabla primaria
    $('#tblAsistencia').DataTable();
    //Tabla de reposte
    // Consultar asistencias por empleado
    $('#btnAsistenciaPorEmpleado').click(function() {

        if ($('#doc').val() != '') {

            consultarAsistenciaEmpleado(0, $('#doc').val(), '', 0, 0, 0);

        } else {

            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'Debes ingresar un numero de documento',
                showConfirmButton: false,
                timer: 2500
            });

        }

    });

    $('#buscarAsistenciaFecha').click(function(event) {

        if ($fecha1.val() != '' || $fecha2.val() != '') {

            consultarAsistenciaRangoFechas();

        } else {

            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'Tienes que ingresar minimo una fecha.',
                showConfirmButton: false,
                timer: 2500
            });

        }

    });

    $('.timepicker').timepicker({
        minuteStep: 1,
        template: 'modal',
        appendWidgetTo: 'body',
        showSeconds: true,
        showMeridian: false,
        defaultTime: false
    });

    // Consultar Asistencias por dia
    consultarAsistenciasDia();

    // ...
    consultarHoraSalidaTiempoExtra();

    //Se ejecutara un segundo despues que la pagina haya cargado por completo.
    setInterval('consultarAsistenciasDia()', 15000); //Se actualiza cada 15s

    //Actualizar las asistencias diarias
    $('#ActualizarD').click(function(event) {
        consultarAsistenciasDia();
    });

    // 
    $('#tblAsistenciaEmpleadoDia').click(function(event) {
        console.log($('#tblAsistenciaEmpleadoDia').pague());
    });

    // ...
    $btnAsistencia.click(function(event) {
        switch (Number($(this).val())) {
            case 2:
                // asistencia diaria
                consultarAsistenciaEmpleado(2, $(this).data('documento'), '', 1, 0);
                break;
            case 1:
                // Asistencias pasadas
                consultarAsistenciaEmpleado(1, $(this).data('documento'), $(this).data('fecha'), 1, $btnAsistencia.data('idAsistencia'));
                break;
        }
    });
    // ...
    $btnModificarAsistencia.click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se modificaran los tiempo de la asitencia",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                modificarAsistenciasEmpleado($(this).data('documento'), $(this).data('fecha'));
            }
        });
    });
    // ...
    $('#exportarAsistenciasEmpleado').click(function(event) {
        event.preventDefault();
        if ($fecha1.val() != '' && $fecha2.val() != '') {

            window.open(baseurl + 'Empleado/cAsistencia/reporte_Asistencia_operarios?fechaInicio=' + $fecha1.val() + '&fechaFin=' + $fecha2.val(), '_blank');
        
        } else {
        
            swal('Alerta!', 'Deben ingresar un rango de fecha obligatoriamente', 'warning');
        
        }
    });
});

function generarReportePorPisoPDF(elemento) {
    // console.log(elemento);
    if ($(elemento).find('option:selected').val() != 0) {
        // console.log('Cambio');
        window.open(baseurl + 'Empleado/cAsistencia/generarPDFAsistencias?piso=' + $(elemento).find('option:selected').val(), '_blank');
    }
}

function consultarHoraSalidaTiempoExtra() {

    $.post(baseurl+'Empleado/cConfiguracion/consultarHoraSalidaTiempoExtra', function(data, textStatus, xhr) {

        $('#HoraSalidaTiempoExtra').val(data);

    });

}

function gestionarHoraSalidaTiempoExtra() {
     
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se actualizara la hora de salida del tiempo extra.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {

        if (result) {

            $.post(baseurl+'Empleado/cConfiguracion/gestionarHoraSalidaTiempoExtra', 
                {
                    hora: $('#HoraSalidaTiempoExtra').val()
                }, function(data, textStatus, xhr) {

                    swal('Realizado!','El horario fue modificado.','success',{timer: 2000, button: false});

            });

        }

    });    

}

// 
function consultarAsistenciaRangoFechas() { //Tipo de busqueda, Documento y Fecha
    // debugger;
    $.post(baseurl + 'Empleado/cAsistencia/asistenciasPorFechas', {
        fecha1: ($fecha1.val() != '' ? formatoFecha($fecha1.val()) : ''),
        fecha2: ($fecha2.val() != '' ? formatoFecha($fecha2.val()) : ''),
        documento: ''
    }, function(data) {
        //Cast a json
        var result = JSON.parse(data);
        // Limpiar la tabla
        $tabla4.empty();
        $tabla4.html('<table class="display" id="tblFechas">' + '<thead id="Cabeza">' + '<th>ID</th>' + '<th>¿Tiempo extra?</th>' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Evento</th>' + '<th>Fecha Inicio</th>' + '<th>Hora inicio</th>' + '<th>Fecha fin</th>' + '<th>Hora fin</th>' + '<th>Estado</th>' + '<th>Detalle</th>' + '</thead>' + '<tbody id="cuerpoF">' + '</tbody>' + '</table>');
        // Agregar la informacion a la tabla
        $.each(result, function(index, row) {
            $('#cuerpoF').append('<tr>' + '<th>' + row.idAsistencia + '</th>' + 
                                          // '<td>' + row.tiempo_extra + '</td>' +
                                          '<td><div class="checkbox">'+
                                              '<label style="font-size: 1.2em">'+
                                              '<input type="checkbox" disabled '+(row.tiempo_extra == 1?"checked":"")+' >'+
                                              '<span class="cr"><i class="cr-icon fa fa-check"></i></span>'+  
                                              '</label>'+
                                          '</div></td>' +
                                          '<td>' + row.documento + '</td>' + 
                                          '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + '</td>' + 
                                          '<td>' + clasificarEvento(row.idTipo_evento) + '</td>' + 
                                          '<td>' + row.fecha_inicio + '</td>' + 
                                          '<td>' + row.hora_inicio + '</td>' + 
                                          '<td>' + row.fecha_fin + '</td>' + 
                                          '<td>' + row.hora_fin + '</td>' + 
                                          '<td>' + clasificarAsistencia(row.idEstado_asistencia) + '</td>' +
                                          '<td>' +
                                             '<button value="' + row.documento + ';' + row.fecha_inicio + '" type="button" onclick="mostrarDetalle(this.value,\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ','+ row.idAsistencia +'\','+row.idAsistencia+')" class="btn btn-success "><span><i class="fas fa-eye"></i> ver' + '</span></button></td>' + '</tr>');
        });
        //Formato del data table
        $('#tblFechas').DataTable();
    });
}
// Consulta las horas laborales trabajadas por dia
function consultarHorasTrabajadasDia(idAsistencia) {
    $.post(baseurl + 'Empleado/cAsistencia/consultarHorasTrabajadasDia', {
        idAsistencia: idAsistencia
    }, function(data) {
        var result = JSON.parse(data);
        $horasNormales.val(0);
        $horasExtras.val(0);
        $horasExtras.val(0);
        $horasAceptadas.val(0);
        $horasRechazadas.val(0);
        $textDecrip.val('');
        $.each(result, function(index, row) {
            // Validar que tipo de horas son, horas normales o horas extras
            switch(Number(row.idEvento_laboral)){
                case 1: // Horas trabajadas normales
                    $horasNormales.val(row.numero_horas);    
                    break;
                case 2: // Horas trabajadas extra
                    $horasExtras.val(row.numero_horas);
                    $horasAceptadas.val(row.horas_aceptadas);
                    $horasRechazadas.val(row.horas_rechazadas);
                    $textDecrip.val(row.descripcion);                    
                    break;
            }
        });
    });
}
//Se encarga de modificar la información de las asistencias de los empleados manualmente unicamente por el usuario encargado 
function modificarAsistenciasEmpleado(doc, fecha) { //
    // ...
    var v = [];
    var horaInicio = '';
    var horaFin = '';
    $tabla3.find('tbody tr').each(function(index, row) {
        // Validar que la hora fin ingresada sea mayor a la hora de inicio ingresada manualmente
        horaInicio = $.trim($(row).find('td').eq(1).find('input').val());
        horaFin = $.trim($(row).find('td').eq(3).find('input').val());
        v.push({
            'idAsistencia': $(row).find('th').first().text(), //ID Asistencia
            'HoraInicio': horaInicio, //Input hora inicio asistencia
            'HoraFin': horaFin, //Input hora fin asistencia
            'Evento': $(row).find('td').eq(0).find('span').data('idevento'), // Evento de la asistencia
            'Horario': $(row).find('th').first().data('idhorario')
        });
    });
    // ...
    $.post(baseurl + 'Empleado/cAsistencia/modificarAsistenciaEmpleadoManual', {
        info: v,
        documento: doc
    }, function(data) {

        if (data == 1) {
           
            swal('Realizado!', 'La asistencia fue modificada correctamente.', 'success');

            $tituloModal.find('small').hide('slow', function() {

                $(this).remove();

            });
            // 
            switch (Number($btnAsistencia.val())) {
                case 2:
                    // asistencia diaria
                    consultarAsistenciaEmpleado(2, $btnAsistencia.data('documento'), '', 0, 0);
                    break;
                case 1:
                    // Asistencias pasadas
                    consultarAsistenciaEmpleado(1, $btnAsistencia.data('documento'), $btnAsistencia.data('fecha'), 0, $btnAsistencia.data('idAsistencia'));
                    break;
            }

        } else {

            swal('Error!', 'Ocurrio un error en la ejecuación e esta acción', 'error');
        
        }
    });
    // ...
}
// Se encarga de consultar los permisos que hay en una fecha especifica por empledo
function consultarPermisosEmpleadosDia(doc, fecha) {
    $.post(baseurl + 'Empleado/cPermiso/consultarPermisoEmpleado', {
        documento: doc,
        codigo: '',
        fecha: fecha
    }, function(data) {
        // ...
        var i = 0;
        var result = JSON.parse(data);
        // ...
        $('#PermisosDiaAsistencia').empty();
        $('#PermisosDiaAsistencia').html('<table class="display" id="tblPEA">' + '<thead id="cabezaE">' + '<th>Clasificado Por:</th>' + '<th>Fecha Solicitud</th>' + '<th>Fecha Permiso</th>' + '<th>Desde</th>' + '<th>Hasta</th>' + '<th>Momento</th>' + '<th>Estado</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
        var $cuerpo = $('#cuerpoE');
        // ...
        $.each(result, function(index, row) {
            $cuerpo.append('<tr>' + '<td>' + row.usuario + '</td>' + '<td>' + row.fecha_solicitud + '</td>' + '<td>' + row.fecha_permiso + '</td>' + '<td>' + row.desde + '</td>' + '<td>' + (row.hasta == null ? '-' : row.hasta) + '</td>' + '<td>' + row.momento + '</td>' + '<td>' + tagEstado(row.estado) + '</td>' + '</tr>');
            i = 1;
        });
        // ...
        if (i == 1) {
            $('#seccionPermisoP').show();
            $('#tblPEA').DataTable();
        } else {
            $('#seccionPermisoP').hide('100');;
        }
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
        case 4: //Permiso
            mensaje = '<span><small class="label bg-orange">Ejecución</small></span>';
            break;
        case 0: //Pendiente
            mensaje = '<span><small class="label bg-yellow">Pendiente</small></span>';
            break;
    }
    return mensaje;
}
//... Pendiente actualizar
function consultarAsistenciaEmpleado(i, doc, fecha, accion, idAsistencia) { //Tipo de busqueda, Documento, Fecha, acccion (Pendiente modificar)
    var op = 0;
    var des = 0;
    $.post(baseurl + 'Empleado/cAsistencia/asistenciaPorEmpleado', {
        documento: doc,
        op: i,
        fec: fecha,
        idAsistencia: idAsistencia
    }, function(data) {
        // Cast a json
        var result = JSON.parse(data);
        // Limpiar la tabla
        // $tabla5.empty();
        (i == 0 ? $tabla2 : $tabla3).empty();
        (i == 0 ? $tabla2 : $tabla3).html('<table class="display"' + (i == 0 ? 'id="tblAsistenciaEmpleado"' : 'id="tblAsistenciaEmpleadoM"') + '>' +
                                            '<thead id="Cabeza">' + 
                                                '<th>ID</th>' + 
                                                (i == 0 ? '<th>¿Tiempo extra?</th>':'') + 
                                                (i == 0 ? '<th>Documento</th>':'') + 
                                                (i == 0 ? '<th>Nombre</th>' : '') + 
                                                '<th>Evento</th>' + 
                                                '<th>Inicio Evento</th>' +
                                                (i == 0 ? '' : '<th>LectorI</th>') + 
                                                '<th>Fin Evento</th>' + 
                                                (i == 0 ? '' : '<th>LectorF</th>') + 
                                                '<th>Estado</th>' +
                                                (i != 0 ? '<th>Tiempo</th>' : '') + 
                                                (i == 0 ? '<th>Detalle</th>' : '') + 
                                            '</thead>' + 
                                                '<tbody ' + (i == 0 ? 'id="cuerpo"' : 'id="cuerpoM"') + '>' + 
                                                '</tbody>' + 
                                        '</table>');
        // Agregar la informacion a la tabla
        $.each(result, function(index, row) {

            if (op == 0 && (i == 1 || i == 2)) {
                // consultarHorasRealizadosEmpleadoFecha(row.documento, row.fecha_inicio);
                if (i == 1) {
                    consultarHorasTrabajadasDia(row.idAsistencia);
                    $divHorasTrabajadas.show();
                } else if (i == 2) {
                    $divHorasTrabajadas.hide();
                }
                op++;
            }
            // ...
            if (des == 0) {
                $btnAsistencia.data('fecha', row.inicio);
                $btnModificarAsistencia.data('fecha', row.inicio);
                des = 1;
            }
            // ...
            (i == 0 ? $('#cuerpo') : $('#cuerpoM')).append('<tr>' + 
                                                                '<th data-idhorario="' + row.idConfiguracion + '">' + row.idAsistencia + '</th>' + 
                                                                (i == 0 ? '<td><div class="checkbox">'+
                                                                                '<label style="font-size: 1.2em">'+
                                                                                '<input type="checkbox" disabled '+(row.tiempo_extra == 1?"checked":"")+' >'+
                                                                                '<span class="cr"><i class="cr-icon fa fa-check"></i></span>'+  
                                                                                '</label>'+
                                                                            '</div></td>' : '') + 
                                                                (i == 0 ? '<td>' + row.documento + '</td>' : '') + 
                                                                (i == 0 ? '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + '</td>' : '') + 
                                                                '<td>' + clasificarEvento(row.idTipo_evento) + '</td>' + 
                                                                '<td>' + (accion == 0 ? row.inicio : '<input class="from-control inputAsistencia" maxlength="20" type="text" value="' + row.inicio + '">') + '</td>' + 
                                                                (i == 0 ? '' : '<td>' + row.lectorI + '</td>') + 
                                                                '<td>' + (accion == 0 ? (row.fin == null ? '-' : row.fin) : (row.fin == null ? '-' : '<input class="from-control inputAsistencia" maxlength="20" type="text" value="' + (row.fin == null ? '' : row.fin) + '">')) + '</td>' +
                                                                (i == 0 ? '' : '<td>' + (row.lectorF == null ? '-' : row.lectorF) + '</td>') + 
                                                                '<td>' + clasificarAsistencia(row.idEstado_asistencia) + '</td>' + 
                                                                (i != 0 ? '<td>' + (row.horas == null ? '-' : row.horas) + '</td>' : '') + 
                                                                (i == 0 ? '<td>' + '<button value="' + row.documento + ';' + row.inicio + '" type="button" onclick="mostrarDetalle(this.value,\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + '\','+row.idAsistencia+')" class="btn btn-success"><span><i class="fas fa-eye"></i> ver' + '</span></button></td>' : '') + 
                                                            '</tr>');
        });
        // ...
        if (i > 0 && accion == 0) {
            $btnAsistencia.data('documento', doc);
            $btnModificarAsistencia.data('documento', doc);
            $btnAsistencia.val(i);
        }
        // ...
        if (accion == 0) {
            $btnModificarAsistencia.hide();
        } else {
            if ($tituloModal.find('small').length == 0) {
                $tituloModal.append(' <small>Editando</small>');
            }
            $btnModificarAsistencia.show();
        }
        // ...
        // Formato del data table
        (i == 0 ? $('#tblAsistenciaEmpleado') : $('#tblAsistenciaEmpleadoM')).DataTable(configDataTable());
        // console.log(result);
        if (i == 1 || i == 2) {
            $('#detalleAsistencias').modal('show');
        }
    });
}
// 
function cerrarEventosLaboral(doc) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se cerrara el evento.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            $.post(baseurl + 'Empleado/cAsistencia/CerrarAsistencia', {
                documento: doc
            }, function(data) {
                if (data == 1) {
                    swal({
                        position: 'center',
                        type: 'success',
                        title: 'Listo!',
                        text: '.',
                        showConfirmButton: false,
                        timer: 2500
                    });
                    consultarAsistenciasDia();
                } else {
                    swal({
                        position: 'center',
                        type: 'error',
                        title: 'Listo!',
                        text: 'Error al ejecutar la petición.',
                        showConfirmButton: false,
                        timer: 2500
                    });
                }
            });
            // console.log(doc);
        }
    });
}
// 
function mostrarDetalle(doc, nombre, idAsistencia) {
    var info = doc.split(';');
    $tituloModal.text('Detalle Asistencia:  ' + nombre);
    consultarAsistenciaEmpleado(1, info[0], info[1], 0, idAsistencia); //...Ultimo argumento es la accion
    $btnAsistencia.data('idAsistencia', idAsistencia)
    consultarPermisosEmpleadosDia(info[0], formatoFecha(info[1]));
}

// 
function mostrarDetalleDiario(doc, nombre) {
    $tituloModal.text('Detalle Asistencia:  ' + nombre);
    consultarAsistenciaEmpleado(2, doc, '', 0, 0);
    consultarPermisosEmpleadosDia(doc, '');
    $('#detalleAsistencias').modal('show');
}

function gestionTiempoExtraAsistencia(idAsistencia) {
    $.post(baseurl+'Empleado/cAsistencia/gestionTiempoExtraAsistencia', 
        {
            idAsistencia: idAsistencia
        }, function(data, textStatus, xhr) {

            console.log(data);

    });
}

// Consulta todos los empleados que son operarios y su estado (ausente, presente)
function consultarAsistenciasDia() {
    // var op = 0;
    $.post(baseurl + 'Empleado/cAsistencia/asistenciasDiarias', {
        documento: $documentoE.val()
    }, function(data) {
        //Cast a json
        var result = JSON.parse(data);
        // Limpiar la tabla
        $tabla1.empty();
        $tabla1.html('<table class="display" id="tblAsistenciaEmpleadoDia">' +
                        '<thead id="Cabeza">' + 
                            '<th>¿Tiempo Extra?</th>' + 
                            '<th>Documento</th>' + 
                            '<th>Nombre</th>' + 
                            '<th>Localización</th>' + 
                            '<th>Estado</th>' + 
                            '<th>Hora llegada</th>' + 
                            '<th>Hora salida</th>' + 
                            '<th>Accion</th>' + 
                        '</thead>' +
                        '<tbody id="cuerpoDia">' +
                        '</tbody>' + 
                    '</table>');
        // Agregar la informacion a la tabla
        $.each(result, function(index, row) {
            //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //Se puede cerrar una asistencia si el empleado esta de permiso Salida e ingreso? Preguntar
            $('#cuerpoDia').append('<tr>' + 
                                    // '<td for="'+row.documento+'" alaing="center"><input type="checkbox" value="" id="'+row.documento+'"></td>' + 
                                    '<td aling="center"> <div class="checkbox">'+
                                        '<label style="font-size: 1.2em">'+
                                            '<input type="checkbox" '+(row.tiempoExtra==1?"checked":"")+' '+ (row.asistencia == 1?"onchange=\"gestionTiempoExtraAsistencia(this.value)\"":"disabled")+' value="'+(row.idAsistencia != null?row.idAsistencia:"")+'">'+
                                            '<span class="cr"><i class="cr-icon fa fa-check"></i></span>'+  
                                        '</label>'+
                                    '</div></td>' + 
                                    '<td>' + row.documento + '</td>' + 
                                    '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + 
                                    '<td>' + 'Piso-' + row.piso + '</td>' + 
                                    '<td>' + clasificarStatus(row.asistencia) + '</td>' +
                                    '<td>' + (row.horaLlegada === null ? "-" : row.horaLlegada) + '</td>' +
                                    '<td>' + (row.horaSalida === null ? "-" : row.horaSalida) + '</td>' + 
                                    '<td>' + '<button value="' + row.documento + '" type="button" onclick="mostrarDetalleDiario(this.value,\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '\')" class="btn btn-success"' + (row.asistencia == 0 ? 'disabled' : '') + '><span><i class="fas fa-eye"></i> ver' + '</span></button>' + '&nbsp;&nbsp;' + (row.asistencia == 1 ? ('<button value="' + row.documento + '" type="button" onclick="cerrarEventosLaboral(this.value);" class="btn btn-danger"><span><i class="fas fa-times-circle"></i> Cerrar' + '</span></button>') : ('')) + '</td>' + '</tr>');
        });
        //Formato del data table
        $('#tblAsistenciaEmpleadoDia').DataTable(configDataTable());
        // console.log(result);
    });
}
//Retornar la configuracion para la funcion DataTable
function configDataTable() {
    return {
        "bStateSave": true,
        "iCookieDuration": 60,
        "language": {
            "sProcessing": "Procesando...",
            "sZeroRecords": "No se encontraron resultados",
            "sLengthMenu": "Mostrar _MENU_ Registros",
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
// Consultar Asistencias del evento de desayuno
function consultarAsistenciaEventoDia(evento) {//tabla eventos desayunos del dia=2 & tabla eventos almuerzo del dia=3
    //...
    $.post(baseurl + 'Empleado/cAsistencia/consultarAsistenciaEventoDia', {
        event: evento
    }, function(data) {
        var result = JSON.parse(data);
        // Limpiar la tabla
        (evento==2?$tabla5:$tabla6).empty();
        (evento==2?$tabla5:$tabla6).html('<table class="display" id="tblEventosOp'+evento+'">' +
                        '<thead id="Cabeza">' + 
                            '<th>Documento</th>' + 
                            '<th>Nombre</th>' + 
                            '<th>Fecha Inicio</th>' + 
                            '<th>Lector I</th>' + 
                            '<th>Fecha Fin</th>' + 
                            '<th>Lector F</th>' + 
                            '<th>Estado</th>' + 
                            '<th>Tiempo</th>' + 
                        '</thead>' + 
                    '<tbody id="cuerpoEvento'+evento+'">' + 
                    '</tbody>' + 
                    '</table>');
        // Agregar la informacion a la tabla
        $.each(result, function(index, row) {
            // debugger;
            if (row.idAsistencia != null) {

                // e.documento, e.nombre1,e.nombre2,e.apellido1,e.apellido2,a.fecha_inicio,a.hora_inicio,a.lectorI,a.fecha_fin,a.hora_fin,a.lectorF,a.idEstado_asistencia,a.tiempo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //Se puede cerrar una asistencia si el empleado esta de permiso Salida e ingreso? Preguntar
                $('#cuerpoEvento' + evento).append('<tr>' + 
                                     '<td>' + row.documento + '</td>' +
                                     '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + 
                                     '<td>' + row.inicio + '</td>' + 
                                     '<td>' + row.lectorI+ '</td>' + 
                                     '<td>' + (row.fin == null?'-':row.fin)+ '</td>' + 
                                     '<td>' + (row.lectorF == null?'-':row.lectorF) + '</td>' + 
                                     '<td>' + clasificarAsistencia(row.idEstado_asistencia) + '</td>' + 
                                     '<td>' + (row.tiempo == null?'-':row.tiempo) + '</td>' + 
                                   '</tr>');
            }
        });
        //Formato del data table
        $('#tblEventosOp'+evento).DataTable(configDataTable());
    });
    //...
}
//Se encarga de decir si el empleado esta presente o ausente
function clasificarStatus(estatus) {
    switch (Number(estatus)) {
        case 0: //Ausente
            return '<span><small class="label bg-red">Ausente</small></span>';
            break;
        case 1: //Presente
            return '<span><small class="label bg-green">Presente</small></span>';
            break;
        case 2: //De permiso
            return '<span><small class="label bg-orange">Permiso</small></span>';
            break;
    }
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
        return '<span data-idevento="1"><small class="label bg-blue">Laboral</small></span>';
    } else if (evento == 2) { //Desayuno
        return '<span data-idevento="2"><small class="label amarillo">Desayuno</small></span>';
    } else if (evento == 3) { //Almuerzo
        return '<span data-idevento="3"><small class="label morado">Almuerzo</small></span>';
    }
}
//Valida que solo se ingresen valores numericos
function valida(e) {
    tecla = (document.all) ? e.keyCode : e.which;
    //Tecla de retroceso para borrar, siempre la permite
    if (tecla == 8) {
        return true;
    }
    // Patron de entrada, en este caso solo acepta numeros
    patron = /[0-9]/;
    tecla_final = String.fromCharCode(tecla);
    return patron.test(tecla_final);
}
//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) { // esto se va a eliminar por que ya no se necesita...
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}