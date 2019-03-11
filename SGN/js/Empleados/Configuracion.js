// Variables
var $name = $('#nameHorario');
var $HIL = $('#HIL');
var $HFL = $('#HFL');
var $HID = $('#HID');
var $HFD = $('#HFD');
var $HIA = $('#HIA');
var $HFA = $('#HFA');
var $TD = $('#TD');
var $TA = $('#TA');
var $boton = $('#btnAcccion');
var $div = $('#tablaHorarios');
var con = 0;
var respuesta = true;
// Consulta las configuracion de los horarios de los eventos laborales
consultarConfiguracion(0);
// Cuando el DOM este cargado por completo el time piker se aplicara a los inputs
$(document).ready(function() {
    //Cargar libreria del time piker
    $('.timepicker').timepicker({
        minuteStep: 1,
        template: 'modal',
        appendWidgetTo: 'body',
        showSeconds: true,
        showMeridian: false,
        defaultTime: false
    });
    // Cuando se haga click en el boton de modificar configuracion
    $boton.click(function(event) {
        registrarModificarConfiguracion();
    });
    // ...
    $('#limpiarF').click(function(event) {
        limpiarFormulario();
    });
});
// Consulta una unica configuracion
function consultarConfiguracion(idH) {
    $.post(baseurl + 'Empleado/cConfiguracion/consultarConfiguracion',{ID: idH},function(data) {
        var result = JSON.parse(data);
        // console.log(result);
        if (idH==0) {//General
            var result = JSON.parse(data);
            // ...
            $div.empty();
            $div.html('<table class="display" id="horarios">' + 
                         '<thead id="cabeza">' + 
                           '<th>Nombre</th>' + 
                           '<th>Estado</th>' + 
                           '<th>Acciones</th>' +
                         '</thead>' + 
                         '<tbody id="cuerpoU">' + 
                         '</tbody>' + 
                     '</table>');
            // ...
            $.each(result, function(index, row) {
                $('#cuerpoU').append('<tr>' + 
                                        '<td>' + row.nombre + '</td>' + 
                                        '<td>' + clasificarEstado(row.estado) + '</td>' +
                                        '<td>' + 
                                            '<button value="' + row.idConfiguracion + '" onclick="consultarConfiguracion(this.value)"  type="button" class="btn btn-primary btn-xs"><span><i class="far fa-edit"></i>Editar</span></button></p>' + 
                                            '<button value="' + row.idConfiguracion + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
            });
            // ...
            $('#horarios').DataTable({
                "language": {
                "sProcessing":     "Procesando...",
                "sLengthMenu":     "Mostrar _MENU_ Registros",
                "sZeroRecords":    "No se encontraron resultados",
                "sEmptyTable":     "Ningún dato disponible en esta tabla",
                "sInfo":           "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
                "sInfoEmpty":      "Mostrando registros del 0 al 0 de un total de 0 registros",
                "sInfoFiltered":   "(filtrado de un total de _MAX_ registros)",
                "sInfoPostFix":    "",
                "sSearch":         "Buscar:",
                "sUrl":            "",
                "sInfoThousands":  ",",
                "sLoadingRecords": "Cargando...",
                "oPaginate": {
                  "sFirst":    "Primero",
                  "sLast":     "Último",
                  "sNext":     "Siguiente",
                  "sPrevious": "Anterior"
                },
                "oAria": {
                  "sSortAscending":  ": Activar para ordenar la columna de manera ascendente",
                  "sSortDescending": ": Activar para ordenar la columna de manera descendente"
                }
              }
            });
        }else{//Especifica
            $.each(result, function(index, row) {
                $HIL.val(row.hora_ingreso_empresa);
                $HFL.val(row.hora_salida_empresa);
                $HID.val(row.hora_inicio_desayuno);
                $HFD.val(row.hora_fin_desayuno);
                $HIA.val(row.hora_inicio_almuerzo);
                $HFA.val(row.hora_fin_almuerzo);
                $TD.val(row.tiempo_desayuno);
                $TA.val(row.tiempo_almuerzo);
                $name.val(row.nombre);
                $boton.val(row.idConfiguracion);
                $boton.text('Actualizar');
            });
            // ...
            $('html, body').animate({
                scrollTop: 0
            },'slow');
        }
    });
}

function clasificarEstado(estado) { //Clasifica el estado de cada proveedor
    if (estado == 1) {
        return '<span><small class="label bg-green">Activo</small></span>';
    } else {
        return '<span><small class="label bg-red">Inactivo</small></span>';
    }
}

//Retornair item estado
function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger tamaño" onclick="cambiarEstadoHorarioEmpleado(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="cambiarEstadoHorarioEmpleado(this.value)"><span><i class="fas fa-check"></i> Activar';
    }
}

function limpiarFormulario() {
    $HIL.val('');
    $HFL.val('');
    $HID.val('');
    $HFD.val('');
    $HIA.val('');
    $HFA.val('');
    $TD.val('');
    $TA.val('');
    $name.val('');
    $boton.val('0');
    $boton.text('Registrar');
}

function cambiarEstadoHorarioEmpleado(id) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: 'Se cambiara el estado el horario de trabajo',
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            $.post(baseurl+'Empleado/cConfiguracion/cambiarEstadoHorarioConfiguracion', {ID: id}, function(data) {
                if (data==1) {
                    swal('Alerta','Se cambio el estado de la configuracion correctamente','success');
                    consultarConfiguracion(0);
                }else{
                    // Mensaje de alerta...
                }
            });
        }
    });
}

function registrarModificarConfiguracion() {
    // console.log(generarHoraValida("12:00:00"));
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: ($boton.val()!=0?'Se modificara este horario':'Se registrara un nuevo horario.'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            if (validarCamposVacios()) {
                //validar que la hora inicial no sea mayor que la hora final de cualquiera de los tres eventos(laboral, desayuno y almuerzo).
                //1=Laboral 2=Desayuno y 3=Almuerzo
                $.post(baseurl + 'Empleado/cConfiguracion/validarHoras', {
                    hora1: generarHoraValida($HIL.val()),
                    hora2: generarHoraValida($HFL.val())
                }, function(data) {
                    marcarCampoIncorrecto(data, 1);
                    $.post(baseurl + 'Empleado/cConfiguracion/validarHoras', {
                        hora1: generarHoraValida($HID.val()),
                        hora2: generarHoraValida($HFD.val())
                    }, function(data) {
                        marcarCampoIncorrecto(data, 2);
                        $.post(baseurl + 'Empleado/cConfiguracion/validarHoras', {
                            hora1: generarHoraValida($HIA.val()),
                            hora2: generarHoraValida($HFA.val())
                        }, function(data) {
                            marcarCampoIncorrecto(data, 3);
                            if (respuesta) {
                                // console.log('Todos los campos estan validos');
                                registrarActualizarConfiguracion();
                            }
                        });
                    });
                });
            }
        }
    });
}

function registrarActualizarConfiguracion() {
    $.post(baseurl + 'Empleado/cConfiguracion/actualizarConfiguracion', {
        HIL: $HIL.val(),
        HFL: $HFL.val(),
        HID: $HID.val(),
        HFD: $HFD.val(),
        HIA: $HIA.val(),
        HFA: $HFA.val(),
        TD: $TD.val(),
        TA: $TA.val(),
        ID: $boton.val(),
        nombre: $name.val()
    }, function(res) {
        if (res==1) {
            swal({
                position: 'center',
                type: 'success',
                title: 'Realizado',
                text: 'La configuracion fue '+($boton.val()==0?'registrada':'actualizada')+' correctamente.',
                showConfirmButton: false,
                timer: 2500
            });
            // Consulta general de los horarios laborales
            consultarConfiguracion(0);
            limpiarFormulario();
        } else {
            // Mensaje de alerta...
        }
    });
}

function generarHoraValida(hora) {
    var partes = hora.split(':');
    var res = (partes[0].length == 1 ? '0' : '') + partes[0] + ':' + partes[1] + ':' + partes[2];
    return res;
}

function marcarCampoIncorrecto(data, op) {
    // con++;
    if (!(data == 1)) {
        respuesta = false;
        if (op == 1) { //Horas laborales
            $HIL.parent().addClass('has-error');
            $HFL.parent().addClass('has-error');
        } else if (op == 2) { //Horas de desayuno
            $HID.parent().addClass('has-error');
            $HFD.parent().addClass('has-error');
        } else if (op == 3) { //Hoaras de almuerzo
            $HIA.parent().addClass('has-error');
            $HFA.parent().addClass('has-error');
        }
    }
    // console.log(op);
}

function validarCamposVacios() {
    var res = true;
    // Nombre del horario
    var valor = $name.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $name.parent().addClass('has-error');
        res = false;
    } else {
        $name.parent().addClass('has-success');
        $name.parent().removeClass('has-error');
    }
    //Horas de ingreso laboral
    var valor = $HIL.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $HIL.parent().addClass('has-error');
        res = false;
    } else {
        $HIL.parent().addClass('has-success');
        $HIL.parent().removeClass('has-error');
    }
    //Hora de salida laboral
    valor = $HFL.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $HFL.parent().addClass('has-error');
        res = false;
    } else {
        $HFL.parent().addClass('has-success');
        $HFL.parent().removeClass('has-error');
    }
    //Hora de inicio de desayuno
    valor = $HID.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $HID.parent().addClass('has-error');
        res = false;
    } else {
        $HID.parent().addClass('has-success');
        $HID.parent().removeClass('has-error');
    }
    // Hora de fin de desayuno
    valor = $HFD.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $HFD.parent().addClass('has-error');
        res = false;
    } else {
        $HFD.parent().addClass('has-success');
        $HFD.parent().removeClass('has-error');
    }
    // Hora de incio de almuerzo
    valor = $HIA.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $HIA.parent().addClass('has-error');
        res = false;
    } else {
        $HIA.parent().addClass('has-success');
        $HIA.parent().removeClass('has-error');
    }
    // Hora de fin de almuerzo
    valor = $HFA.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $HFA.parent().addClass('has-error');
        res = false;
    } else {
        $HFA.parent().addClass('has-success');
        $HFA.parent().removeClass('has-error');
    }
    // Tiempo de desayuno
    valor = $TD.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $TD.parent().addClass('has-error');
        res = false;
    } else {
        $TD.parent().addClass('has-success');
        $TD.parent().removeClass('has-error');
    }
    // Tiempo de almuerzo
    valor = $TA.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $TA.parent().addClass('has-error');
        res = false;
    } else {
        $TA.parent().addClass('has-success');
        $TA.parent().removeClass('has-error');
    }
    return res;
}