//  Variables
var $user = $('#user');
var $contra1 = $('#contraseña1');
var $contra2 = $('#contraseña2');
var $tipo = $('#tipoUsuario');
var $userM = $('#userM');
var $contra1M = $('#contraseña1M');
var $contra2M = $('#contraseña2M');
var $tipoM = $('#tipoUsuarioM');
var $div = $('#tblTableUsuarios');
var $actualizar = $('#modificarM');
var $email = $('#email');
var $emailM = $('#emailM');
// DOM
$(document).ready(function() {
    //Consultar Usuarios
    consultarUsuarios(0);
    // Consultar lista de tipos de usuarios
    consultarTiposUsuarios($tipo, 0);
    $('#Enviar').click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Registraras un nuevo usuario.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                registrarModificarUsuario(0); //0 registrar 1 modificar
                consultarUsuarios(0);
            }
        });
    });
    // Modificar Usuario
    $('#modificarM').click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se modificara el usuario.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                registrarModificarUsuario(1); //0 registrar 1 modificar
                consultarUsuarios(0);
            }
        });
    });

    // Actualizar el listado de los usuarios
    $('#consulta2').click(function() {
        consultarUsuarios(0);
    });
});
// Funciones
function consultarTiposUsuarios($componente, op) {
    $.post(baseurl + 'Empleado/cUsuario/consultarTiposUsuarios', function(data) {
        var result = JSON.parse(data);
        // console.log(result);
        $componente.empty();
        $componente.append('<option value="0">Seleccione...</option>');
        $.each(result, function(index, row) {
            $componente.append('<option value="' + row.idTipo_usuario + '">' + row.nombre + '</option>');
        });
        if (op != 0) {
            $("#tipoUsuarioM option[value=" + op + "]").attr("selected", true);
        }
    });
}

function registrarModificarUsuario(op) {
    // Validar campos y contraseña
    // Validar que el nombre de usuario no exista
    var inputs;
    if (op == 0) {
        inputs = [$user, $contra1, $contra2, $('#tipoUsuario > option:selected'), 0];
    } else {
        inputs = [$userM, $contra1M, $contra2M, $('#tipoUsuarioM > option:selected'), 1];
    }
    // Validar todos los campos en general
    if (validarCampos(inputs)) {
        // Validar que las contraseñas si coinciden
        if (validarContra(op)) { //Las contraseñas coinciden
            $.post(baseurl + 'Empleado/cUsuario/validarUsuariorepetido', {
                nombre: (op == 0 ? $user.val() : $userM.val())
            }, function(data) {
                var res = JSON.parse(data);
                if ((op == 0 ? res == 1 : true)) {
                    var idTipo;
                    idTipo = (op == 0 ? $('#tipoUsuario > option:selected') : $('#tipoUsuarioM > option:selected')).val();
                    // Registrar o modificar dependiendo de la accion(op)
                    $.post(baseurl + 'Empleado/cUsuario/registrarModificarUsuarios', {
                        idU: (op == 0 ? 0 : $actualizar.data('tipo')),
                        usuario: (op == 0 ? $user.val() : $userM.val()),
                        cont: (op == 0 ? $contra1.val() : $contra1M.val()),
                        correo: (op == 0 ? $email.val() : $emailM.val()),
                        idT: idTipo,
                        accion: op
                    }, function(data) {
                        // 
                        var res = JSON.parse(data);
                        if (res == 1) {
                            // consultarUsuarios(0);
                            estadoInicial(op);
                            if (op == 1) {
                                $('#modificarUsuario').modal('toggle');
                            }
                            setTimeout(function () {
                                swal({
                                  position: 'center',
                                  type: 'success',
                                  title: 'Realizado',
                                  text: (op == 0 ? 'El usuario fue registrado corectamente.' : 'El usuario fue modificado corectamente.')
                                  // showConfirmButton: false,
                                  // timer: 2500
                                });
                            },400);
                        } else {
                            swal({
                                position: 'center',
                                type: 'error',
                                title: 'Alerta!',
                                text: 'La acción no pudo ser realizada.'
                                // showConfirmButton: false,
                                // timer: 2500
                            });
                        }
                    });
                } else {
                    swal({
                        position: 'center',
                        type: 'warning',
                        title: 'Alerta!',
                        text: 'El nombre de usuario ya existe, por favor intente con otro nombre.'
                        // showConfirmButton: false,
                        // timer: 2500
                    });
                }
            });
        } else { //Las contraseñas no coinciden
            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'Las contraseñas no coinciden.'
                // showConfirmButton: false,
                // timer: 2500
            });
        }
    }
}

function validarContra(op) {
    if ((op == 0 ? $contra1 : $contra1M).val() === (op == 0 ? $contra2 : $contra2M).val()) {
        return true;
    } else {
        return false;
    }
}

function validarCampos($arr) {
    // Nombre de usuario
    var respuesta = true;
    var valor = $arr[0].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[0].parent().addClass('has-error');
        respuesta = false;
    } else {
        $arr[0].parent().addClass('has-success');
        $arr[0].parent().removeClass('has-error');
    }
    //Constraseña 1
    valor = $arr[1].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[1].parent().addClass('has-error');
        respuesta = false;
    } else {
        $arr[1].parent().addClass('has-success');
        $arr[1].parent().removeClass('has-error');
    }
    //Constraseña 2
    valor = $arr[2].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[2].parent().addClass('has-error');
        respuesta = false;
    } else {
        $arr[2].parent().addClass('has-success');
        $arr[2].parent().removeClass('has-error');
    }
    if ($arr[3].val() == 0) {
        ($arr[4] == 0 ? $tipo : $tipoM).parent().addClass('has-error');
        respuesta = false;
    }
    return respuesta;
}
//Verificar Por campo
function validarPorCampo(id) {
    var valor = $('#' + id).val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $('#' + id).parent().addClass('has-error');
    } else {
        $('#' + id).parent().addClass('has-success');
        $('#' + id).parent().removeClass('has-error');
    }
    // console.log(id);
}

function estadoInicial(op) {
    $user.val('');
    $contra1.val('');
    $contra2.val('');
    //Nombre de usuario
    (op == 0 ? $user : $userM).parent().removeClass('has-error');
    (op == 0 ? $user : $userM).parent().removeClass('has-success');
    //contraseñas
    (op == 0 ? $contra1 : $contra1M).parent().removeClass('has-error');
    (op == 0 ? $contra1 : $contra1M).parent().removeClass('has-success');
    (op == 0 ? $contra2 : $contra2M).parent().removeClass('has-error');
    (op == 0 ? $contra2 : $contra2M).parent().removeClass('has-success');
    // ...
}

function consultarUsuarios(id) {
    $.post(baseurl + 'Empleado/cUsuario/consultarUsuarios', {
        clave: id
    }, function(data) {
        var result = JSON.parse(data);
        $div.empty();
        $div.html('<table class="display" id="Usuarios">' + '<thead id="cabeza">' + '<th>N°</th>' + '<th>Usuarios</th>' +'<th>E-mail</th>'+ '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoU">' + '</tbody>' + '</table>');
        $.each(result, function(index, row) {
            $('#cuerpoU').append('<tr id="' + row.idUsuario + '" data-contra="' + row.contra + '" data-tipo="' + row.idTipo_usuario + '">' + '<td>' + row.idUsuario + '</td>' + '<td>' + row.usur + '</td>' + '<td>' + row.email + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idUsuario + '" onclick="mostrarModal(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button value="' + row.idUsuario + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
        });
        $('#Usuarios').DataTable({
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
}
//Retornair item estado
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
        return 'class="btn btn-danger tamaño" onclick="eliminarUsuario(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="eliminarUsuario(this.value)"><span><i class="fas fa-check"></i> Activar';
    }
}

function mostrarModal(id) {
    consultarUsuariosTabla(id);
    $('#modificarUsuario').modal('show');
}

function consultarUsuariosTabla(id) {
    var row = $('#' + id);
    //Contraseña
    $.post(baseurl+'Empleado/cEmpleado/desEncryptar', {contra: row.data('contra')}, function(data) {
       $contra1M.val(data);
       $contra2M.val(data);
    });
    //Nombre de suario
    $userM.val(row.children().eq(1).text());
    //Tipo de usuario
    consultarTiposUsuarios($tipoM, row.data('tipo'));
    // Correo electronico del usuario
    $emailM.val(row.children().eq(2).text());
    // Identificador en el boton
    $actualizar.data('tipo', id);
}

function eliminarUsuario(id) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se cambiara el estado del usuario.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            $.post(baseurl + 'Empleado/cUsuario/eliminarUsuario', {
                idU: id
            }, function(data) {
                // var result = JSON.parse(data);
                if (data) {//result==1
                    consultarUsuarios(0);
                    swal({
                        position: 'center',
                        type: 'success',
                        title: 'Realizado',
                        text: 'El usuario fue cambiado de estado correctamente.',
                        showConfirmButton: false,
                        timer: 2500
                    });
                }
            });
        }
    });
}