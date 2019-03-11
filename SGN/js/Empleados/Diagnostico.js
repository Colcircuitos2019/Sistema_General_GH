var $codDiagnostico = $('#codD');
var $Diagnostico = $('#diagnostico');
var $tableResponsive = $('#tblResponsive');
var $btnRealizaraccion = $('#EnviarA');
var $btnLimpiar = $('#limpiarFormulario');
// DOM
$(document).ready(function() {

    // Importar documento excel .XLXS
    $('#formImportarDiagnostico').submit(function(event) {
        event.preventDefault();
        $.ajax({
            url: baseurl+'Empleado/cDiagnostico/importarDiagnostico',
            type: 'POST',
            data: new FormData(this),
            cache: false,
            contentType: false,
            processData:false,
            beforeSend:function () {
                $('#formImportarDiagnostico').append('<img src="'+baseurl+'img/loader-small.gif" alt="loading"/>');
            }
        })
        .done(function(data) {
            console.log(data);
            console.log("success");
            $('#formImportarDiagnostico').children('img').remove();
            swal('Alerta','No se pudo cargar el documento','warning',{buttons:false,timer:2000});
        })
        .fail(function(data) {
            console.log(data);
            console.log("error");
            $('#formImportarDiagnostico').children('img').remove();
            swal('Alerta','No se pudo cargar el documento','warning',{buttons:false,timer:2000});
        });
    });

    // Boton de realizar acción 
    $btnRealizaraccion.on('click', function() {
        event.preventDefault();
        var op = $(this).val();
        // 
        if ($codDiagnostico.val() != '' && $Diagnostico.val() != '') {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "Se " + (op == 0 ? 'Registrar' : 'Modificara') + " el Diagnostico.",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {
                    $.post(baseurl+'Empleado/cDiagnostico/validarExistenciaCod', {idD: $codDiagnostico.val()}, function(data) {
                        if (data==($btnRealizaraccion.val()==0?true:false)) {
                            //Registrar o modificar empresa
                            $codDiagnostico.parent('div').removeClass('has-error');
                            $Diagnostico.parent('div').removeClass('has-error');
                            registrarModificarEstadoDiagnostico($codDiagnostico.val(),($btnRealizaraccion.val()==0?1:2));
                        }else{
                            swal('Alerta!', 'El código de diagnostico ya existe.','warning');
                        }
                    });
                }
            });
        } else {
            // Codigo
            if (!($codDiagnostico.parent('div').hasClass('has-error')) && $codDiagnostico.val()=='') {
                $codDiagnostico.parent('div').addClass('has-error');
            }
            // Diagnostico
            if (!($Diagnostico.parent('div').hasClass('has-error')) && $Diagnostico.val()=='') {
                $Diagnostico.parent('div').addClass('has-error');
            }
        }
    });
    // Consultar todas las empresas registradas en el sistema de informacion
    consultarDiagnostico();
    // Limpiar formulario (Dejarlo en el estado inicial)
    $btnLimpiar.click(function() {
        limpiarEstadoInicial();
    });

});
//Se encarga de registrar o modificar las empresas
function registrarModificarEstadoDiagnostico(idE, op) {
    $.ajax({
        url: baseurl + 'Empleado/cDiagnostico/registrarModificarDiagnostico',
        type: 'POST',
        dataType: 'json',
        data: {
            idD: idE,
            nombre: $Diagnostico.val(),
            op: op
        },
    }).done(function(valor) {
        // 
        switch(valor){
            case 1:
                swal('Realizado', 'La acción registrar fue realizada correctamente.', 'success');
                break;
            case 2:
                swal('Realizado', 'La acción modificar fue realizada correctamente.', 'success');
                break;
            case 3:
                swal('Realizado', 'La acción cambio de estado fue realizada correctamente.', 'success');
                break;        
        }
        limpiarEstadoInicial();
        consultarDiagnostico();
        // console.log("success");
    }).fail(function() {
        swal('Alerta!', 'Ocurrio un error en el procedimiento.', 'error');
    });
}
// Se encarga de consultar todas las empresas que estan registradas en el sistema de informacion
function consultarDiagnostico() {
    // 
    $.post(baseurl + 'Empleado/cDiagnostico/ConsultarDiagnosticos',{
        estado: 0
    }, function(data) {
        var result = JSON.parse(data);
        $tableResponsive.empty();
        $tableResponsive.html('<table class="display" id="tblDiagnostico">' + '<thead>' + '<th>ID</th>' + '<th>Nombre Empresa</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
        var $cuerpoP = $('#cuerpoE');
        $.each(result, function(index, row) {
            $cuerpoP.append('<tr>' + '<td>' + row.idDiagnostico + '</td>' + '<td>' + row.diagnostico + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idDiagnostico + ';' + row.diagnostico + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idDiagnostico + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
        });
        // 
        $('#tblDiagnostico').DataTable();
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
    $Diagnostico.parent('div').removeClass('has-error');
    $btnRealizaraccion.val(datos[0]);
    $codDiagnostico.attr('disabled',true);
    $codDiagnostico.val(datos[0]);
    $Diagnostico.val(datos[1]);
}

function cambiarEstadoDiagnostico(idDiagnostico) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se cambiara el estado del diagnostico.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            //Registrar o modificar empresa
            registrarModificarEstadoDiagnostico(idDiagnostico, 3);
            // 
            setTimeout(function() {
                consultarDiagnostico();
            }, 100);
            // 
            limpiarEstadoInicial();
        }
    });
}

function limpiarEstadoInicial() {
    $codDiagnostico.val('');
    $Diagnostico.val('');
    $btnRealizaraccion.val(0);
    $codDiagnostico.attr('disabled',false);
    $btnRealizaraccion.text('Enviar');
    $btnRealizaraccion.removeClass('btn-warning');
    $btnRealizaraccion.addClass('btn-primary');
}
//Retornair item estado
function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger tamaño btn-xs" onclick="cambiarEstadoDiagnostico(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="cambiarEstadoDiagnostico(this.value)"><span><i class="fas fa-check"></i> Activar';
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