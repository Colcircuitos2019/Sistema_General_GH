var $nombreAuxilio = $('#AuxilioN');
var $tableResponsive = $('#tblResponsive');
var $btnRealizaraccion = $('#EnviarA');
var $btnLimpiar=$('#limpiarFormulario');
// DOM
$(document).ready(function() {
    // Boton de realizar acción 
    $btnRealizaraccion.on('click', function() {
        event.preventDefault();
        var op = $(this).val();
        // 
        if ($nombreAuxilio.val() != '') {
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
                    $nombreAuxilio.parent('div').removeClass('has-error');
                    registrarModificarEstadoAuxilio(Number($(this).val()), 2);
                }
            });
        } else {
            if (!($nombreAuxilio.parent('div').hasClass('has-error'))) {
                $nombreAuxilio.parent('div').addClass('has-error');
            }
        }
    });
    // Consultar todas las empresas registradas en el sistema de informacion
    consultarAuxilio();
    // Limpiar formulario (Dejarlo en el estado inicial)
    $btnLimpiar.click(function() {
    	limpiarEstadoInicial();
    });
});
//Se encarga de registrar o modificar las empresas
function registrarModificarEstadoAuxilio(idE, estado) {
    $.ajax({
        url: baseurl + 'FichaSDG/cConfiguracionFicha/registrarModificarEstadoCRUD',
        type: 'POST',
        dataType: 'json',
        data: {
            idEm: String(idE),
            nombre: $nombreAuxilio.val(),
            estadoE: String(estado),
            info: 3 //Auxilio
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
                consultarAuxilio();
                limpiarEstadoInicial();
            }
        }
        // console.log("success");
    }).fail(function() {
        swal('Alerta!', 'Ocurrio un error en el procedimiento.', 'error');
    });
}
// Se encarga de consultar todas las empresas que estan registradas en el sistema de informacion
function consultarAuxilio() {
    // 
    $.post(baseurl + 'FichaSDG/cConfiguracionFicha/consultarInformacion',{
        op: 1, //Se encarga designar la accion de consultar todos los salarios sin importar el estado.
        info: 3 //Auxilio
    }, function(data) {
        var result = JSON.parse(data);
        $tableResponsive.empty();
        $tableResponsive.html('<table class="display" id="tblSalarios">' + '<thead>' + '<th>ID</th>' + '<th>Nombre Auxilio</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
        var $cuerpoP = $('#cuerpoE');
        $.each(result, function(index, row) {
            $cuerpoP.append('<tr>' + '<td>' + row.idTipo_auxilio + '</td>' + '<td>' + row.auxilio + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idTipo_auxilio + ';' + row.auxilio + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idTipo_auxilio + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
        });
        // 
        $('#tblSalarios').DataTable();
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
    $nombreAuxilio.parent('div').removeClass('has-error');
    $btnRealizaraccion.val(datos[0]);
    $nombreAuxilio.val(datos[1]);
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
            registrarModificarEstadoAuxilio(idEmpresa, 1);
            // Se puede ver la forma de remplazar por el por un queune de jQuery.
            setTimeout(function() {
                consultarAuxilio();
            }, 100);
            // 
            limpiarEstadoInicial();
        }
    });
}

function limpiarEstadoInicial() {
    $nombreAuxilio.val('');
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