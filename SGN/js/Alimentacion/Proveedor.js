
//Variables globales del documento
var tipo = '';
var mensaje = '';
var titulo = '';
var con = 0;
var valor;
var idDetalle = 0;
var nombre;
var telefono;
var es;
var $divTable = $('#divTable');
// Principales
var $nombre = $('#txtNombreP');
var $telefono = $('#txtelefonoC');
var $email = $('#txtEmail');
// Modales
var $nombreM = $('#txtNombrePM');
var $telefonoM = $('#txtelefonoCM');
var $emailM = $('#txtEmailM');
var $D = $('#D');
var $A = $('#A');
// 
$(document).ready(function() {
    consultarProveedores();
    // setTimeout(function() { //Soluciona el problema del llamado del plugin
    // }, 100);
    //Documento modelo===========================================
    $(document).on('submit', '#FormProveedor', function(event) {
        event.preventDefault();
        //Validacion
        registrarModificarProveedor(0);
    });
    //Documento modelo===========================================
    $('#modificar').on('show.bs.modal', function(e) {
        //Faltan la validacion que no permita mostrar el modal cuando el boton este desactivado
    });
});
//Funciones
//=============================================================================
function registrarModificarProveedor(id) {
    if ((id == 0 ? $nombre : $nombreM).val() != '' && (id == 0 ? $telefono : $telefonoM).val() != '' && (id == 0 ? $('input:radio[name=evento]:checked') : $('input:radio[name=eventoM]:checked')).val()) { //&& (id==0?$email.val():$emailM.val()) 
        $.ajax({ //Buscar informacion en metodo
            url: baseurl + 'Alimentacion/cProveedor/registrarModificarProveedor',
            type: 'POST',
            dataType: 'json',
            data: {
                iddetalle: id,
                nombre: (id == 0 ? $nombre : $nombreM).val(),
                telefono: (id == 0 ? $telefono : $telefonoM).val(),
                evento: (id == 0 ? $('input:radio[name=evento]:checked') : $('input:radio[name=eventoM]:checked')).val(),
                email: (id == 0 ? $email : $emailM).val()
            },
        }).done(function(resul) {
            if (resul) {
                $('#modificar').modal('hide');
                tipo = 'success';
                mensaje = (id == 0 ? 'El Proveedor fue registrado exitosamente' : 'El proveedor fue modificado exitosamente');
                titulo = 'Realizado';
                (id == 0 ? $nombre : $nombreM).val(''); //Vacia campos de registro
                (id == 0 ? $telefono : $telefonoM).val(''); //
                (id == 0 ? $nombre : $nombreM).parent().removeClass('has-error');
                (id == 0 ? $telefono : $telefonoM).parent().removeClass('has-error');
                (id == 0 ? $nombre : $nombreM).parent().removeClass('has-success');
                (id == 0 ? $telefono : $telefonoM).parent().removeClass('has-success');
            } else {
                //Mensaje de error
                tipo = 'error';
                mensaje = (id == 0 ? 'El Proveedor no  pudo ser registrado' : 'El proveedor no pudo ser modificado.');
                titulo = 'Error';
            }
            //Mostrar el mensaje en pantalla
            swal({
                position: 'center',
                type: tipo,
                title: titulo,
                text: mensaje,
                showConfirmButton: false,
                timer: 2500
            });
            consultarProveedores(); //Consulta todos los proveedores en general
        }).fail(function() {
            console.log("error");
        });
    } else {
        //Validacion de campos vacios=================================
        validarCampos($nombre, $telefono);
    }
}

function valida(e) { //Validar que el input solo permita caracteres numericos
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

function clasificarEvento(evento) {
    if (evento == 1) {
        return mensaje = '<span><small class="label bg-blue">Desayuno</small></span>';
    } else {
        return mensaje = '<span><small class="label bg-yellow">Almuerzo</small></span>';
    }
}
//Retornair item estado
function clasificarEstado(estado) { //Clasifica el estado de cada proveedor
    if (estado == 1) {
        return mensaje = '<span><small class="label bg-green">Activo</small></span>';
    } else {
        return mensaje = '<span><small class="label bg-red">Inactivo</small></span>';
    }
}

function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger btn-xs" onclick="validarEliminacion(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="validarEliminacion(this.value)"><span><i class="fas fa-check"></i> Activar';
    }
}

function estadoBoton(estado) {
    if (estado == 1) {
        return 'active';
    } else {
        return 'disabled';
    }
}
//==================================================================================
function consultarProveedores() {
    //Consulta de proveedores disponibles
    $.post(baseurl + 'Alimentacion/cProveedor/consultarProveedores', {
        op: 3
    }, function(data) {
        var resulSet = JSON.parse(data);
        $divTable.empty();
        $divTable.html('<table class="display" id="tblProveedor">' + '<thead id=' + 'Cabeza' + '>' + '<tr>' + '<th scope="col">Nº</th>' + '<th scope="col">Nombre</th>' + '<th scope="col">telefono</th>' + '<th scope="col">E-mail</th>' + '<th scope="col">Evento</th>' + '<th scope="col">Estado</th>' + '<th scope="col">Acciones</th>' + '</tr>' + '</thead>' + '<tbody id="Cuerpo">' + '</tbody>' + '</table>');
        var $table = $('#tblProveedor');
        $.each(resulSet, function(resulSet, row) {
            // if (row.estado == 1) {
                $table.append('<tr id=' + row.idProveedor + '>' + '<th scope="row">' + row.idProveedor + '</th>' + '<td>' + row.nombre + '</td>' + '<td>' + row.telefono + '</td>' + '<td>' + (row.email != null ? row.email : '') + '</td>' + '<td>' + clasificarEvento(row.evento) + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button data-permiso="'+row.estado+'" value="' + row.idProveedor + ';' + row.nombre + ';' + row.telefono + ';' + row.evento + ';' + (row.email != null ? row.email : '') + '" onclick="llenarCamposModificar(this.value)"  type="button" class="btn btn-primary btn-xs ' + estadoBoton(row.estado) + '" data-toggle="modal"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button type="button"  value=' + row.idProveedor + ' ' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
            // }
        });
        $table.DataTable({
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
    });
    //Consulta de proveedores disponibles -- fin --
}
//============================================================
function validarEliminacion(fila) {
    eliminarProveedor(fila);
}
//============================================================
function llenarCamposModificar(valor,estado) {
    var vector = valor.split(';');
    // Nombre del proveedor
    $nombreM.val(vector[1]);
    // Telefono del proveedor
    $telefonoM.val(vector[2]);
    // Email
    $emailM.val(vector[4]);
    // Evento
    if (vector[3] == 1) {
        $D.prop('checked', true);
    } else {
        $A.prop('checked', true);
    }
    // Boton de actualizar
    $('#cActualizar').attr('value', vector[0]);
    //Modal-show 
    // $res= $componente.data('permiso');
    console.log(estado);
    $('#modificar').modal('show');
}

function eliminarProveedor(idP) {
    swal({
        title: '¿Estas seguro?',
        text: 'Se cambiara el estado del proveedor',
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            // idDetalle = $('#Cuerpo').find('tr').eq(fila).find('th').eq(0).text();
            $.post(baseurl + 'Alimentacion/cProveedor/eliminarProveedorC', {
                iddetalle: idP
            }, function(res) {
                if (res) {
                    swal('Exito!', 'El cambio de estado fue realizado correctamente.', 'success')
                    consultarProveedores();
                }
            });
        }
    });
}

function validarCampos($nombre, $tele) {
    //Nombre del proveedor
    valor = $nombre.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        //if(!$nombre.parent().attr('class').hasClass('has-error')){
        $nombre.parent().addClass('has-error');
    } else if (!isNaN(valor)) {
        //if(!$nombre.parent().classList.contains('has-error')){
        $nombre.parent().addClass('has-error');
    } else {
        //if(!$nombre.parent().classList.contains('has-success')){
        $nombre.parent().addClass('has-success');
        $nombre.parent().removeClass('has-error');
    }
    //Telefono del proveedor
    valor = $tele.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        //if(!$nombre.parent().attr('class').hasClass('has-error')){
        $tele.parent().addClass('has-error');
    } else if (isNaN(valor)) {
        //if(!$nombre.parent().classList.contains('has-error')){
        $tele.parent().addClass('has-error');
    } else {
        //if(!$nombre.parent().classList.contains('has-success')){
        $tele.parent().addClass('has-success');
        $tele.parent().removeClass('has-error');
    }
    // Evento
}