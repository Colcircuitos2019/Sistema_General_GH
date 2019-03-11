var $nombreEmpresa = $('#empresaN');
var $tableResponsive = $('#tblResponsive');
var $btnRealizaraccion = $('#EnviarA');
var $btnLimpiar = $('#limpiarFormulario');
// DOM
$(document).ready(function() {
    // Boton de realizar acción 
    $btnRealizaraccion.on('click', function() {
        event.preventDefault();
        var op = $(this).val();
        // 
        if ($nombreEmpresa.val() != '') {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "Se " + (op == 0 ? 'Registrar' : 'Modificara') + " la empresa.",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {
                    //Registrar o modificar empresa
                    $nombreEmpresa.parent('div').removeClass('has-error');
                    registrarModificarEstadoEmpresa(Number($(this).val()), 2);
                }
            });
        } else {
            if (!($nombreEmpresa.parent('div').hasClass('has-error'))) {
                $nombreEmpresa.parent('div').addClass('has-error');
            }
        }
    });
    // Consultar todas las empresas registradas en el sistema de informacion
    consultarEmpresas();
    // Limpiar formulario (Dejarlo en el estado inicial)
    $btnLimpiar.click(function() {
        limpiarEstadoInicial();
    });
});
//Se encarga de registrar o modificar las empresas
function registrarModificarEstadoEmpresa(idE, estado) {
    $.ajax({
        url: baseurl + 'Empleado/cEmpresa/registrarModificarEstadoEmpresa',
        type: 'POST',
        dataType: 'json',
        data: {
            idEm: String(idE),
            nombre: $nombreEmpresa.val(),
            estadoE: String(estado)
        },
    }).done(function(valor) {
        if (valor == 1) {
            if (estado == 0 || estado == 1) { //Cambio de estado de la empresa.
                swal('Realizado', 'La acción cambio de estado fue realizada correctamente.', 'success');
            } else {
                if (idE == 0) { //Registro de nueva empresa.
                    swal('Realizado', 'La acción registrar fue realizada correctamente.', 'success');
                } else { //Modificacion de empresa.
                    swal('Realizado', 'La acción modificar fue realizada correctamente.', 'success');
                }
                consultarEmpresas();
                limpiarEstadoInicial();
            }
        }
        // console.log("success");
    }).fail(function() {
        swal('Alerta!', 'Ocurrio un error en el procedimiento.', 'error');
    });
}
// Se encarga de consultar todas las empresas que estan registradas en el sistema de informacion
function consultarEmpresas() {
    // 
    $.post(baseurl + 'Empleado/cEmpresa/consultarEmpresas',{
        op: 1
    }, function(data) {
        var result = JSON.parse(data);
        $tableResponsive.empty();
        $tableResponsive.html('<table class="display" id="tblEmpresas">' + '<thead>' + '<th>ID</th>' + '<th>Nombre Empresa</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
        var $cuerpoP = $('#cuerpoE');
        $.each(result, function(index, row) {
            $cuerpoP.append('<tr>' + '<td>' + row.idEmpresa + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idEmpresa + ';' + row.nombre + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idEmpresa + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
        });
        // 
        $('#tblEmpresas').DataTable();
    });
}

function enviarInformacionFormulario(info) {
    // Moverme al principio de la pagina.
    $('html, body').animate({
        scrollTop: 0
    }, 'slow');
    var datos = info.split(';');
    $btnRealizaraccion.text('Modificar');
    $btnRealizaraccion.addClass('btn-warning');
    $nombreEmpresa.parent('div').removeClass('has-error');
    $btnRealizaraccion.val(datos[0]);
    $nombreEmpresa.val(datos[1]);
}

function cambiarEstadoEmpresa(idEmpresa) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se cambiara el estado de esta empresa la empresa.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            //Registrar o modificar empresa
            registrarModificarEstadoEmpresa(idEmpresa, 1);
            // 
            setTimeout(function() {
                consultarEmpresas();
            }, 100);
            // 
            limpiarEstadoInicial();
        }
    });
}

function limpiarEstadoInicial() {
    $nombreEmpresa.val('');
    $btnRealizaraccion.val(0);
    $btnRealizaraccion.text('Enviar');
    $btnRealizaraccion.removeClass('btn-warning');
    $btnRealizaraccion.addClass('btn-primary');
}
//Retornair item estado
function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger tamaño btn-xs" onclick="cambiarEstadoEmpresa(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="cambiarEstadoEmpresa(this.value)"><span><i class="fas fa-check"></i> Activar';
    }
}
//Retornair item estado
function clasificarEstado(estado) { //Clasifica el estado de cada proveedor
    if (estado == 1) {
        return '<span><small class="label bg-green">Activo</small></span>';
    } else {
        return '<span><small class="label bg-red">Inactivo</small></span>';
    }
}