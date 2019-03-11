// Variables
var $tablaEPermiso = $('#tblEmpleadosPermiso');
var $tablaCodigo = $('#tblCodigosPermisos');
var $tablaCodigoFechas = $('#tblCodigosPermisosFechas');
var estado = true;
var $fecha1 = $('#fechaI');
var $fecha2 = $('#fechaF');
var informacionP;
// Variables del modal de visualizar.
var $fechaSolicitudM = $('#fechaSM');
var $fechaPermisoM = $('#fechaPM');
var $solicitanteM = $('#hPermiso');
var $conceptoM = $('#conceptoM');
var $horarDesde = $('#horaDM');
var $horaHasta = $('#horaHM');
var $descripcionM = $('#descripM');
var $codigoPermiso = $('#code');
var $contenctM = $('#descripcionM');
var $numHoras = $('#numHoras');
/* Notas: 
   1) El empleado solo puede tener un codigo generado por día*/
$(document).ready(function() {
    // Inicializar los datapiker
    $('.fh-date').datepicker({
        format: "dd-mm-yyyy",
        language: "es",
        multidate: false
    });
    // Consultamos todos los empleados de permisos.
    consultarEmpleadosPermisos();
    setInterval('consultarEmpleadosPermisos()', 10000);
    // Consultamos todos los codigos generados de cada empelado
    consultarPermisoCodigo();
    setInterval('consultarPermisoCodigo()', 10000);
    // Consultar Permisos empleados por rango de fechas
    $('#btnConsultarFechas').click(function(event) {
        consultarPermisosPorFechas();
    });
});
// Vista de administracion de permisos (Facilitador, Gestor humano)
function consultarEmpleadosPermisos() {
    $.post(baseurl + 'Empleado/cEmpleado/consultarEmpleadosPermiso', function(data) {
        var result = JSON.parse(data);
        // Crear tabla
        $tablaEPermiso.empty();
        // html de la Tabla se empelados
        $tablaEPermiso.html('<table class="display" id="EmpeladosPermiso">' + '<thead id="cabeza">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Rol</th>' + '<th>Genero</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpo">' + '</tbody>' + '</table>');
        var $cuerpo = $('#cuerpo');
        $.each(result, function(index, row) {
            $cuerpo.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + clasificarRol(row.idRol) + '</td>' + '<td>' + calsificarGenero(row.genero) + '</td>' + '<td>' + clasificarBoton(row.permiso, row.documento, row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2) + '</td>' + '</tr>');
        });
        // Inicializacion de data table
        $('#EmpeladosPermiso').DataTable({
            "bStateSave": true,
            "iCookieDuration": 60
        });
    });
}
// Se encargara de buscar los codigos de los permisos que aun esten vigentes
function consultarPermisoCodigo() {
    $.post(baseurl + 'Empleado/cPermiso/consultarCodigosPermisos', function(data) {
        var result = JSON.parse(data);
        // Crear tabla
        $tablaCodigo.empty();
        // html de la Tabla se empelados
        $tablaCodigo.html('<table class="display" id="CodigosPermiso">' + '<thead id="cabezaC">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Generado</th>' + '<th>Código</th>' + '<th>Usuario</th>' + '<th>Fecha Permiso</th>'+ '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoC">' + '</tbody>' + '</table>');
        var $cuerpo = $('#cuerpoC');
        $.each(result, function(index, row) {
            $cuerpo.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.generado + '</td>' + '<td>' + '<span><small class="label bg-blue">' + row.Codigo + '<td>' + row.usuario + '</td>' + '</small></span>' + '</td>' +'<td>' + (row.fecha_permiso != null ? row.fecha_permiso : '') + '</td>' + '<td>' + clasificarEstadoCodigosPermiso(row.estado) + '</td>' + '<td>' + (row.estado==2?'':'<button value="' + row.Codigo + '" type="button"' + 'class="btn btn-danger tamaño" onclick="eliminarCodigoPermiso(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar' + '</span></button></p>') + '<button value="' + row.Codigo + '" type="button"' + 'class="btn btn-success btn-xs" onclick="verDetallePermiso(this.value,\'' + row.documento + '\',\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '\')" ' + clasificarBotonDetalle(row.detalleP) + '><span><i class="fas fa-check"></i> Ver' + '</span></button>' + '</td>' + '</tr>');
        });
        // Inicializacion de data table
        $('#CodigosPermiso').DataTable({
            "bStateSave": true,
            "iCookieDuration": 60
        });
    });
}
// Se encarga de retornarme las etiquetas con el estado que tiene el código
function clasificarEstadoCodigosPermiso(estado) {
    var tag='';
    if (estado== null) {
       tag='<span><small class="label bg-blue">Pendiente</small></span>';
    }else{
        switch(Number(estado)){
            case 1:
            tag='<span><small class="label bg-yellow">Registrado</small></span>';
                break;
            case 2:
            tag='<span><small class="label bg-green">Ejecutado</small></span>';
                break;
        }
    }
    return tag;
}

// Se encargara de consultar todos los pedidos dependiendo de un rango de fechas.
function consultarPermisosPorFechas() {
    $.post(baseurl + 'Empleado/cPermiso/consultarCodigosPermisosFechas', {
        fecha1: formatoFecha($fecha1.val()),
        fecha2: formatoFecha($fecha2.val())
    }, function(data) {
        var result = JSON.parse(data);
        // Crear tabla
        $tablaCodigoFechas.empty();
        // html de la Tabla se empelados
        $tablaCodigoFechas.html('<table class="display" id="PermisosFecha">' + '<thead id="cabezaF">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Generado</th>' + '<th>Codigo</th>' + '<th>Fecha Permiso</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoF">' + '</tbody>' + '</table>');
        var $cuerpo = $('#cuerpoF');
        $.each(result, function(index, row) {
            $cuerpo.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.generado + '</td>' + '<td>' + '<span><small class="label bg-blue">' + row.Codigo + '</small></span>' + '</td>' + '<td>' + (row.fecha_permiso != null ? row.fecha_permiso : '-') + '</td>' + '<td>' + clasificarEstadoPermiso(row.estado) + '</td>' + '<td>' + '<button value="' + row.Codigo + '" type="button"' + 'class="btn btn-success btn-xs" onclick="verDetallePermiso(this.value,\'' + row.documento + '\',\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '\')" ' + clasificarBotonDetalle(row.detalleP) + '><span><i class="fas fa-check"></i> Ver' + '</span></button>' + '</td>' + '</tr>');
        });
        // Inicializacion de data table
        $('#PermisosFecha').DataTable();
    });
}
// Se encarga de mostrar el detalle del permiso. Solo se puede visualizar la información más no modificar. 
function verDetallePermiso(cod, doc, nombre) {
    $.post(baseurl + 'Empleado/cPermiso/consultarPermisoEmpleado', {
        documento: doc,
        codigo: cod,
        fecha:'-1'
    }, function(data) {
        //c onsole.log(data);
        var result = JSON.parse(data);
        //Cargar modal de modificar.
        $.each(result, function(index, row) {
            // consultarConceptos(2);
            $fechaSolicitudM.val(row.fecha_solicitud);
            $fechaPermisoM.val(row.fecha_permiso);
            $solicitanteM.text('Detalle: ' + nombre);
            // 
            $conceptoM.val(row.concepto);
            $horarDesde.val(row.desde12);
            $horaHasta.val(row.hasta);
            $numHoras.val(row.numero_horas);
            $('#momentoN').text(row.momento);
            $codigoPermiso.text(cod);
            // $btnActualizarP.val(row.documento + ';2;' + cod); //Modificar
            $descripcionM.val(row.descripcion);
            $('#generadoPor').val(row.usuario);
            $('#visualizarPermiso').modal('show');
        });
    });
}
// 
// Se encarga de registrar el codigo que va a permitir registrar el los permisos de los empleados 
function registrarCodigoEmpleadoPermiso(momento) {
    info = informacionP.split(';');
    // console.log(momento);
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Generara código para: " + info[1],
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            estado = true;
            var codigo;
            // while (estado) {
            codigo = generadorCodigo();
            // Se encarga de validar el codigo que se va a registrar.
            $.post(baseurl + 'Empleado/cPermiso/validarCodigo', {
                code: codigo
            }, function(data) {
                // 
                var result = JSON.parse(data);
                // 
                while (estado) {
                    if (result == 1) {
                        // Salir del ciclo
                        estado = false;
                        // Validacion de que el dica actual no exista otro codigo   
                        // Cuendo el codigo no exista se va a permitir registrar el codigo
                        $.post(baseurl + 'Empleado/cPermiso/registrarCodigoPermiso', {
                            code: codigo, //Codigo generado aleatoriamente
                            doc: info[0], //Numero de documento
                            mom: momento, //Momento en que se va a efectuar el permiso
                            user: usuario //Variable global del DOM(Esta en la vista del footer).
                        }, function(data) {
                            result = JSON.parse(data);
                            if (result == 1) {
                                // 
                                consultarEmpleadosPermisos();
                                // 
                                consultarPermisoCodigo();
                                // Mensaje... El codigo fue registrado correctamente
                                // swal("Realizado!", 'El código generado es:' + codigo, "success");
                                $('#momentoPermiso').modal('hide');
                                // $('#mostrarCodigo').modal('show');
                                // $('#mostrarC').text(codigo);
                                setTimeout(function () {
                                    swal('El codigo es: '+codigo,'','success');
                                },500);
                                //  
                            } else {
                                // Mensaje... El codigo no pudo ser registrado
                                swal("Alerta!", "You clicked the button!", "error");
                            }
                        });
                    } else {
                        codigo = generadorCodigo();
                    }
                }
            });
        }
    });
}
// Eseta funcion se encargara de eliminar el codigo del permiso y por ende se eliminara simultanemente el permiso
function eliminarCodigoPermiso(codigo) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se eliminara simultaneamente con el permiso si es que ya se genero.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            // console.log(codigo);
            $.post(baseurl + 'Empleado/cPermiso/eliminarCodigoPermiso', {
                cod: String(codigo),
                accion: 0
            }, function(data) {
                // console.log(data);
                // 
                consultarEmpleadosPermisos();
                // 
                consultarPermisoCodigo();
                // 
                swal("Realizado!", 'El código fue eliminado correctamente.', "success");
            });
        }
    });
}
// 
function clasificarBotonDetalle(estado) {
    if (estado == 1) {
        return '';
    } else {
        return 'disabled';
    }
}
// Clasificar tipo de rol
function clasificarRol(rol) {
    if (rol == 1) {
        return '<span><small class="label bg-blue">Operario</small></span>'; //Operario
    } else {
        return '<span><small class="label bg-yellow">Administrativo</small></span>'; //Administrativo
    }
}
// Clasificar del tipo del estado del permiso.
function clasificarEstadoPermiso(rol) {
    if (rol == 1) {
        return '<span><small class="label bg-yellow">Activo</small></span>'; //Operario
    } else {
        return '<span><small class="label bg-green">Terminado</small></span>'; //Administrativo
    }
}
//Retorna el tipo de genero que es el empleado
function calsificarGenero(genero) {
    if (genero == 1) {
        return 'Masculino';
    } else {
        return 'Femenino';
    }
}
// Se encarga de mostrar el modal de los momentos disponibles para el permiso.
function mostrarModalMomentos(info) {
    informacionP = info;
    $('#momentoPermiso').modal('show');
}
// Clasifica que botones va a llevar el listado de generador de códigos. 
function clasificarBoton(permiso, doc, nombre) {
    if (permiso == 0) {
        return '<button onclick="mostrarModalMomentos(this.value)" value="' + doc + ';' + nombre + '" type="button" class="btn btn-primary">Generar</button>';
    } else {
        return '<button value="' + doc + '" type="button" class="btn btn-danger" disabled>Generar</button>';
    }
}
// Se encargara de generar un codigo aleatorio de una longitud de 5 caracteres alfanumericos
function generadorCodigo() {
    var caracteres = "abcdefghijkmnpqrtuvwxyzABCDEFGHJKMNPQRTUVWXYZ2346789";
    var contra = "";
    for (i = 0; i < 5; i++) contra += caracteres.charAt(Math.floor(Math.random() * caracteres.length));
    return contra;
}
//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}