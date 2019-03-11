var $nombreDia = $('#nombreDia');
var $fechaDia = $('#fechaDia');
var $tableResponsive = $('#DiasFestivos');
var $btnRealizaraccion = $('#EnviarA');
var $btnLimpiar = $('#limpiarFormulario');
// DOM
$(document).ready(function() {

    // // Importar documento excel .XLXS Pendiente por implementar
    // $('#formImportarDiagnostico').submit(function(event) {
    //     event.preventDefault();
    //     $.ajax({
    //         url: baseurl+'Empleado/cDiagnostico/importarDiagnostico',
    //         type: 'POST',
    //         data: new FormData(this),
    //         cache: false,
    //         contentType: false,
    //         processData:false,
    //         beforeSend:function () {
    //             $('#formImportarDiagnostico').append('<img src="'+baseurl+'img/loader-small.gif" alt="loading"/>');
    //         }
    //     })
    //     .done(function(data) {
    //         console.log(data);
    //         console.log("success");
    //         $('#formImportarDiagnostico').children('img').remove();
    //         swal('Alerta','No se pudo cargar el documento','warning',{buttons:false,timer:2000});
    //     })
    //     .fail(function(data) {
    //         console.log(data);
    //         console.log("error");
    //         $('#formImportarDiagnostico').children('img').remove();
    //         swal('Alerta','No se pudo cargar el documento','warning',{buttons:false,timer:2000});
    //     });
    // });

    // Boton de realizar acción 
    $btnRealizaraccion.on('click', function() {
        event.preventDefault();
        var op = $(this).val();
        // 
        if ($nombreDia.val() != '' && $fechaDia.val() != '') {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "Se " + (op == 0 ? 'Registrar' : 'Modificara') + " el día festivo.",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {//Validar que el dia festivo no sea un sabado o un domingo con "calcularDiaDeSemana" Pendiente
                    var diaS= calcularDiaDeSemana($fechaDia.val());
                    if (diaS!='Domingo') {// Los sabados pueden ser festivos && diaS!='Sabado'
                        var idFestivo=$btnRealizaraccion.val();
                        // Existencia de la fecha del día festivo
                        $.post(baseurl+'Empleado/cDiaFestivo/validarFechaFestiva', {fechaF: formatoFecha($fechaDia.val())}, function(data) {
                            if ((data==0 && (idFestivo==0 || idFestivo>0)) || (data==1 && idFestivo>0)) {
                                //Registrar o modificar empresa
                                $nombreDia.parent('div').removeClass('has-error');
                                $fechaDia.parent('div').removeClass('has-error');
                                registrarModificarDiaFestivo($fechaDia.val(),$nombreDia.val(),$btnRealizaraccion.val());
                            }else if(data==1){
                                swal('Alerta!', 'El  de diagnostico ya existe.','warning');
                            }
                        });
                    }else{
                        swal('Alerta','No puedes registrar un día festivo un '+diaS,'warning',{buttons:false,timer:2000});
                    }
                }
            });
        } else {
            // Codigo
            if (!($nombreDia.parent('div').hasClass('has-error')) && $nombreDia.val()=='') {
                $nombreDia.parent('div').addClass('has-error');
            }
            // Diagnostico
            if (!($fechaDia.parent('div').hasClass('has-error')) && $fechaDia.val()=='') {
                $fechaDia.parent('div').addClass('has-error');
            }
        }
    });
    // Consultar todas las empresas registradas en el sistema de informacion
    consultarDiasFestivos(0);
    // Limpiar formulario (Dejarlo en el estado inicial)
    $btnLimpiar.click(function() {
        estadoInicial();
    });

});
//Se encarga de registrar o modificar las empresas
function registrarModificarDiaFestivo(fecha,nombre, idD) {
    $.ajax({
        url: baseurl + 'Empleado/cDiaFestivo/registrarModificarDiaFestivo',
        type: 'POST',
        data: {
            idD: idD,
            fecha: formatoFecha($fechaDia.val()),
            nombre: $nombreDia.val()
        },
    }).done(function(valor) {
        // 
        if (valor==1) {
            // Registro o modifico
            swal('Realizado','El día festivo fue '+(idD!=0?'Actualizado':'Registrado')+' correctamente.','success',{buttons:false, timer:2000});
        }else{
            swal('Alerta','Ocurrio un error el la peticion de la base de datos','error',{buttons:false, timer:2000});
        }
        estadoInicial();
        consultarDiasFestivos(0);
        // console.log("success");
    }).fail(function() {
        swal('Alerta!', 'Ocurrio un error en el procedimiento.', 'error');
    });
}
// Se encarga de consultar todas las empresas que estan registradas en el sistema de informacion
function consultarDiasFestivos(idD) {
    // 
    $.post(baseurl + 'Empleado/cDiaFestivo/consultarDiasFestivos',{
        idD: idD
    }, function(data) {
        var result = JSON.parse(data);
        if (idD==0) {
            $tableResponsive.empty();
            $tableResponsive.html('<table class="display" id="tblDiasF">' + '<thead>' + '<th>ID</th>' + '<th>Nombre</th>' + '<th>Fecha</th>' + '<th>Estado</th>' + '<th>Acciones</th>'+'</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
            var $cuerpoP = $('#cuerpoE');
            $.each(result, function(index, row) {
                $cuerpoP.append('<tr>' + '<td>' + row.iddias_festivos + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + row.fecha_dia + '</td>'+ '<td>' + clasificarEstado(row.estado) + '</td>'  + '<td>' + (row.acciones==0?'<button value="' + row.iddias_festivos + '" onclick="consultarDiasFestivos(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.iddias_festivos + '" type="button"' + clasificarBoton(row.estado) + '</span></button>':'<label class="label bg-green">Terminado</label>') + '</td>' + '</tr>');
            });
            // 
            $('#tblDiasF').DataTable();
        }else{
            enviarInformacionFormulario(result);
        }
    });
}

function enviarInformacionFormulario(info) {
    // Moverme al principio de la pagina.
    $('html, body').animate({
        scrollTop: 0
    }, 'slow');
    // var datos = info.split(';');
    $btnRealizaraccion.text('Modificar');
    $btnRealizaraccion.addClass('btn-warning');
    $fechaDia.parent('div').removeClass('has-error');

    $.each(info, function(index, row) {
        $btnRealizaraccion.val(row.iddias_festivos);
        $nombreDia.val(row.nombre);
        $fechaDia.val(row.fecha_dia);
    });
}

function cambiarEstadoDiafestivo(idDia) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se cambiara el estado del día festivo.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            //Registrar o modificar empresa
            $.post(baseurl+'Empleado/cDiaFestivo/cambiarEstadoDiaFestivo', {idD: idDia}, function(data) {
               // ...
               if (data==1) {//Realizado correctamente
                swal('Realizado','Se cambio el estado del día festivo correctamente.','success');
                // ...
                setTimeout(function() {
                    consultarDiasFestivos(0);
                }, 100);
                // ...
                estadoInicial();
               }else if (data==2){//Error en la ejecución
                swal('Alerta','Ya no se puede modificar este día festivo.','warning',{buttons:false,timer:2000});
               }else{
                swal('Error','Problema en la ejecución.','error',{buttons:false,timer:2000});
               } 
            });
        }
    });
}

function estadoInicial() {
    $nombreDia.val('');
    $fechaDia.val('');
    $btnRealizaraccion.val(0);
    $btnRealizaraccion.text('Enviar');
    $btnRealizaraccion.removeClass('btn-warning');
    $btnRealizaraccion.addClass('btn-primary');
}
//Retornair item estado
function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger tamaño btn-xs" onclick="cambiarEstadoDiafestivo(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="cambiarEstadoDiafestivo(this.value)"><span><i class="fas fa-check"></i> Activar';
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
// Formato a la fecha de YYYY-MM-DD
function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}