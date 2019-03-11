// Variables
var $numCantidad = $('#newN1');
var $numCantidadCalendar = $('#cantidadCalendario');
var $modalNotificaciones = $('#notificacion');
var $tituloM = $('#tituloM');
var $tablaPersona = $('#tblPersonas');
// DOM cargado
$(document).ready(function() {
    // Consultar cantidad de notificaciones nuevas
    consultarCantidadNotificacionesNuevasUsuario();
    // poner mensajes como leidos
    $('#notificaciones').click(function(event) {
        //Consultar Notificaciones
        if (!$('#notificaciones').hasClass('open')) {
            consultarNotificacionesUsuario();
            cambiarEstadoNotificacionesUsuario();
        }
    });
    // Mostrar detalle de la notificacion clikiada
    $('.notificar').click(function(event) {
        console.log($(this).data('idNoti'));
    });
    // 
    setInterval('consultarCantidadNotificacionesNuevasUsuario()', 60000); //Cada un minuto
    // $('.note').click(function(event) {
    //     console.log('Si ingreso a las notificaciones');
    // });
    cantidadNotificacionesCalendarioDia();
    //...
    $('#showAll').click(function(event) {
        // $('#notificaciones').addClass('active');
        consultarNotificacionesUsuario();
    });
});
// Metodos
// Notificaciones de los diferentes tipos de usuario.
function consultarCantidadNotificacionesNuevasUsuario() {
    $.post(baseurl + 'Empleado/cNotificacion/cantidadNotificacionesNuevas', {
        user: usuario // Variable global (session)
    }, function(data) {
        var cantidad = JSON.parse(data);
        $numCantidad.append(cantidad == 0 ? '' : '<span class="label label-warning" id="numeroNot">' + cantidad + '</span>');
    });
}

function cambiarEstadoNotificacionesUsuario() {
    // poner mensajes como leidos
    if ($('#numeroNot').length == 1) {
        $.post(baseurl + 'Empleado/cNotificacion/cambiarEstadoNotificaciones', {
            user: usuario //Variable global (session)
        }, function(data) {
            var detalle = JSON.parse(data);
            if (detalle == 1) {
                if ($('consultarDetalleNotificaciones')) {
                    $('#numeroNot').remove();
                }
            }
        });
    }
}

function esF12(e) {
    tecla = (document.all) ? e.keyCode : e.which;
    var res=true;
    if (tecla == 123) {
        // document.f1.submit();
        res=false;
    }
    return res;
}

function consultarNotificacionesUsuario() {
    // Variables
    var $menu = $('#cuerpoNotificaciones');
    var mensaje = '';
    var cantidadN = 0;
    var $subNumCantidad = $('#newN2');
    // 
    $.post(baseurl + 'Empleado/cNotificacion/consultarNotificacionesUsuario', {
        rol: usuario, //Variable global (session)
        view: 1
    }, function(data) {
        //
        // console.log($('#cabeza'));
        $('#cabeza').remove();
        var result = JSON.parse(data);
        $.each(result, function(index, row) {
            // mensaje += '<li>' + '<a data-idNoti="' + row.idNotificacion + '">' + '<i class="fa fa-user text-red"></i> ' + row.comentario + '</a>' + '</li>';
            mensaje += '<li>' + '<a onclick="mostrarNotificacion(' + row.idNotificacion + ",'" + row.origen1 + "'," + row.idTipo_notificacion + ');" ' + (row.leido == 0 ? 'style="background-color: #F4F4F4;"' : '') + ' data-idNoti="' + row.idNotificacion + '">' + '<i class="' + clasificarTipoNotificacion(row.idTipo_notificacion) + '" style="color: '+clasificarColorIcono(row.idTipo_notificacion)+'"></i> ' + row.comentario + //(row.leido==0?'<label>'+ row.comentario +'</label>': row.comentario)
                (row.leido == 0 ? '<small class="label bg-blue" style="float: right;">Nuevo</small><br>' : '') + '<small style="float: right;"><i class="far fa-clock"></i> ' + row.fecha + '</small>' + '</a>' + '</li>';
        });
        $menu.empty();
        $menu.html(mensaje == '' ? '<li>' + '<a href="#detalleNoti">' + '<i class="fa fa-comment-dots"></i> No tienes ninguna notificacion</a>' + '</li>' : mensaje);
        //
        $subNumCantidad.prepend('<li id="cabeza" class="header">' + (cantidadN == 0 ? ('No tienes notificaciones nuevas') : (cantidadN == 1 ? 'Tienes ' + cantidadN + ' notificacion nueva' : 'Tienes ' + cantidadN + ' notificaciones')) + '</li>')
    });
}

function mostrarNotificacion(idNoti, fecha, tipoN) {
    $tituloM.html('Notificación: <b>' + clasificarTextoNotificacion(tipoN) + ' del ' + fecha + '</b>');
    consultarPersonasNotificacion(fecha, tipoN);
    $modalNotificaciones.modal('toggle');
}

// Se encarga de consultar los permisos que hay en una fecha especifica. Esto queda pendiente por desarrollar.
function consultarPermisosEmpleadosDia(fecha) {
    $.post(baseurl+'Empleado/cPermiso/consultarPermisoEmpleado', //Pendiente!!!!!!!
        {
            documento: '',
            codigo: '',
            fecha: fecha
        }, function(data) {
        // ...
        var i=0;
        var result=JSON.parse(data);
        // ...
        $tablaPermisosEmpleado.empty();
        $tablaPermisosEmpleado.html('<table class="display" id="tblPE">' + '<thead id="cabezaE">' + '<th>Código</th>' + '<th>Fecha Solicitud</th>' + '<th>Fecha Permiso</th>' + '<th>Desde</th>' + '<th>Momento</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
        var $cuerpo = $('#cuerpoE');
        // ...
        $.each(result, function(index, row) {
            $cuerpo.append('<tr>' + '<td>' + '<span><small class="estadoE">' + row.Codigo + '</small></span>' + '</td>' + '<td>' + row.fecha_solicitud + '</td>' + '<td>' + row.fecha_permiso + '</td>' + '<td>' + row.desde12 + '</td>' + '<td>' + row.momento + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + (row.estado==2?'':'<button value="' + row.idPermiso + '" onclick="realizarAccion(1,this.value,\'' + row.Codigo + '\',\'' + doc + '\',\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '\')"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button value="' + row.idPermiso + '" onclick="realizarAccion(2,this.value,\'' + row.Codigo + '\')"  type="button" class="btn btn-danger tamaño"><span><i class="fas fa-trash-alt"></i>Eliminar</span></button>') + '</td>' + '</tr>');
            i=1;
        });
        // ...
        if (i==1) {
            $('#seccionPermiso').show();
        }else{
            $('#seccionPermiso').hide();
        }
    });
}

function consultarPersonasNotificacion(fecha, tipoN) {
    $.post(baseurl + 'Empleado/cNotificacion/consultarPersonasNotificacion', {
        fecha: fecha,
        tipo: tipoN
    }, function(data) {
        // Falta organizar la tabla para que permita colocar las otras diferentes tipos de notificaciones.
        var result = JSON.parse(data);
        // console.log(data);
        $tablaPersona.empty();
        switch (Number(tipoN)) {
            case 1: //Cumpelaños
                $tablaPersona.html('<table class="display" id="tblNotificaciones">' + '<thead id="CabezaN">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Empresa</th>' + '<th>Genero</th>' + '<th>Rol</th>' + '<th>Edad</th>'+ '</thead>' + '<tbody id="cuerpoTblN">' + '</tbody>' + '</table>');
                break;
            case 5: //Empleados Nuevos
            case 3: //Contrato    
            case 2: //Aniversario
                $tablaPersona.html('<table class="display" id="tblNotificaciones">' + '<thead id="CabezaN">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Empresa</th>' + '<th>Genero</th>' + '<th>Rol</th>' + '</thead>' + '<tbody id="cuerpoTblN">' + '</tbody>' + '</table>');
                break;
            case 4: //Llegadas tarde
                $tablaPersona.html('<table class="display" id="tblNotificaciones">' + '<thead id="CabezaN">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Empresa</th>' + '<th>Hora Ingreso</th>' + '<th>Tiempo</th>' + '<th>Estado</th>'+ '<th>Horario</th>' + '</thead>' + '<tbody id="cuerpoTblN">' + '</tbody>' + '</table>');
                break;
        }
        // ...
        var $cuerpoN = $('#cuerpoTblN');
        // ...
        $.each(result, function(index, row) {
            switch (Number(tipoN)) {
                case 1: //Cumpelaños
                    $cuerpoN.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.empresa + '</td>' + '<td>' + (Number(row.genero)==1?'Masculino':'Femenino') + '</td>' + '<td>' + (Number(row.idRol)==1?'Producción':'Administrativo') + '</td>'+ '<td>' + row.edad + '</td>' + '</tr>');
                    break;
                case 5: //Empleados Nuevos
                case 3: //Contrato 
                case 2: //Aniversario
                    $cuerpoN.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.empresa + '</td>' + '<td>' + (Number(row.genero)==1?'Masculino':'Femenino') + '</td>' + '<td>' + (Number(row.idRol)==1?'Producción':'Administrativo') + '</td>' + '</tr>');
                    break;
                case 4: //Llegadas tarde
                    $cuerpoN.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.empresa + '</td>' + '<td>' + row.hora_inicio + '</td>' + '<td>' + row.tiempoLlegadaTarde + '</td>' + '<td>' + clasificarAsistencia(row.estado) + '</td>' + '<td>' + row.asistencianame + '</td>' + '</tr>');
                    break;
            }   
        });
        $('#tblNotificaciones').DataTable();
    });
}

function cantidadNotificacionesCalendarioDia() {//Esta pendiente por desarrollar....
    $.post(baseurl + 'Empleado/cNotificacion/cantidadNotificacionesNuevas', {
        user: usuario // Variable global (session)
    }, function(data) {
        var cantidad = JSON.parse(data);
        $numCantidadCalendar.append(cantidad == 0 ? '' : '<span class="label label-warning" id="numeroNot">' + cantidad + '</span>');
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

function clasificarTextoNotificacion(tipo) {
    switch (Number(tipo)) {
        case 1: //Cumpelaños
            return 'Cumpleaños';
            break;
        case 2: //Aniversario
            return 'Aniversario';
            break;
        case 3: //Contrato
            return 'Contrato';
            break;
        case 4: //Llegadas tarde
            return 'Llegadas tarde';
            break;
        case 5: //Empleados Nuevos
            return 'Empleados Nuevos';
            break;
    }
}

function clasificarColorIcono(tipo) {
    switch (Number(tipo)) {
        case 1: //Cumpelaños
            return '#D5CD00';
            break;
        case 2: //Aniversario
            return '#11D108';
            break;
        case 3: //Contrato
            return '#0361FE';
            break;
        case 4: //Llegadas tarde
            return '#EA0707';
            break;
        case 5: //Nuevos empleados
            return '#037413';
            break;    
    }
}

function clasificarTipoNotificacion(tipo) {
    switch (Number(tipo)) {
        case 1: //Cumpelaños
            return 'fas fa-birthday-cake';
            break;
        case 2: //Aniversario
            return 'fas fa-universal-access';
            break;
        case 3: //Contrato
            return 'far fa-file';
            break;
        case 4: //Llegadas tarde
            return 'fa fa-user';
            break;
        case 5: //Nuevos empelados
            return 'fas fa-users';
            break;    
    }
}

function consultarDetalleNotificaciones() {
    console.log('entro');
}
