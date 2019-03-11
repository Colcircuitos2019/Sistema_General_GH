var $tableResponsive = $('#tblExamenesEmpleados');
// ...
var $empleados=$('#empelados');
var $inputRadios=$('#radiosTipo');
var $otroExamen=$('#otroExamen');
var $motivo=$('#textMotivo');
var $fechaPlazo=$('#plazoFecha');
var $fechaRetorno=$('#fechaRetorno');
var $btnRealizaraccion=$('#accion');
var $btnLimpiar=$('#limpiar');
// ...
// DOM
$(document).ready(function() {
    // Boton de realizar acción 
    $btnRealizaraccion.on('click', function() {
        event.preventDefault();
        var op = $(this).val();
        // 
        if (validarFormularioExamenes()) {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "Se " + (op == 0 ? 'Registrar' : 'Modificara') + 'los examenes medicos.',
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {
                    //Registrar o modificar empresa
                    registrarModificarEliminarCRUD(Number($(this).val()), 1);
                }
            });
        }
    });
    // Consultar todas las empresas registradas en el sistema de informacion
    consultarInformacion(0);
    // Limpiar formulario (Dejarlo en el estado inicial)
    $btnLimpiar.click(function() {
        limpiarEstadoInicial();
    });
});

function validarFormularioExamenes() {
    var res=true;
  //Empelados 
  if ($empleados.children('option:selected').val()==0) {
    $empleados.parent('div').parent('div').addClass('has-error');
    res=false;
  }else{
    $empleados.parent('div').parent('div').removeClass('has-error');
  }
  //Inputs Radio 
  if ($inputRadios.find('input:radio:checked').val()==undefined) {
    $inputRadios.parent('div').addClass('has-error');
    res=false;
  }else{
    $inputRadios.parent('div').removeClass('has-error');
  }
  //Motivo de los examenes
  if ($motivo.val()=='') {
    $motivo.parent('div').addClass('has-error');
    res=false;
  }else{
    $motivo.parent('div').removeClass('has-error');
  }
  //Fecha de plazo
  if ($fechaPlazo.val()=='') {
    $fechaPlazo.parent('div').addClass('has-error');
    res=false;
  }else{
    $fechaPlazo.parent('div').removeClass('has-error');
  }
  //Fecha de Retorno
  if ($fechaRetorno.val()=='') {
    $fechaRetorno.parent('div').addClass('has-error');
    res=false;
  }else{
    $fechaRetorno.parent('div').removeClass('has-error');
  }
  return res;
}
//Se encarga de registrar o modificar las empresas
function registrarModificarEliminarCRUD(idE, estado) {
    $.ajax({
        url: baseurl + 'Empleado/cExamenes/registrarModificarEliminarCRUD',
        type: 'POST',
        dataType: 'json',
        data: {
            idEX: idE,
            empleado: $empleados.children('option:selected').val(),
            tipoEX: $inputRadios.find('input:radio:checked').val(),
            otroEX: $otroExamen.val(),
            motivo: $motivo.val(),
            fechaP: formatoFecha($fechaPlazo.val()),
            fechaR: formatoFecha($fechaRetorno.val())
        },
    }).done(function(valor) {
        if (estado == 1) { //Registro de nuevos examenes medicos.
            swal('Realizado', 'La acción registrar fue realizada correctamente.', 'success');
        } else { //Modificacion de los examenes medicos.
            swal('Realizado', 'La acción modificar fue realizada correctamente.', 'success');
        }
        consultarInformacion(0);
        limpiarEstadoInicial();
    }).fail(function() {
        swal('Alerta!', 'Ocurrio un error en el procedimiento.', 'error');
    });
}
// Se encarga de consultar todas las empresas que estan registradas en el sistema de informacion
function consultarInformacion(idEX) {
    // ...
    $.post(baseurl + 'Empleado/cExamenes/consultarExamenes', {
        idExam: idEX  //Que Procedimiento almacenado se llama
    }, function(data) {
        var result = JSON.parse(data);
        if (idEX==0) {
            $tableResponsive.empty();
            $tableResponsive.html('<table class="display" id="generalTable">' + 
                                    '<thead>' + 
                                      '<th>Documento</th>' + 
                                      '<th>Nombre empleado</th>' + 
                                      '<th>Fecha carta</th>' + 
                                      '<th>Fecha Plazo</th>' + 
                                      '<th>Fecha Retorno</th>' + 
                                      '<th>Acciones</th>' + 
                                    '</thead>' +
                                    '<tbody id="cuerpoE">' + 

                                    '</tbody>' + 
                                 '</table>');
            var $cuerpoP = $('#cuerpoE');
            $.each(result, function(index, row) {

                $cuerpoP.append('<tr>' + 
                                   '<td>' + row.documento + '</td>' + 
                                   '<td>' + row.nombre1+' '+row.nombre2+' '+row.apellido1+' '+row.apellido2+ '</td>' + 
                                   '<td>' + row.fechaCarta + '</td>' + 
                                   '<td>' + row.fechaPlazo + '</td>' + 
                                   '<td>' + row.fechaRetorno + '</td>' + 
                                   '<td>' + 
                                     '<button value="' + row.idexamenes_Medicos + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + 
                                     '<button value="' + row.idexamenes_Medicos + '" type="button" class="btn btn-danger tamaño btn-xs" onclick="eliminarExamenEmpelado(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar</span></button>' + 
                                   '</td>' + 
                                '</tr>');
                //... 
            });
            // 
            $('#generalTable').DataTable();
        }else{
            // Enviar informacion vista
            $.each(result,function(index, row) {
                $empleados.children('option[value="'+row.documento+'"]').prop('selected',true);
                $empleados.selectpicker('refresh');
                $inputRadios.find('input[type="radio"]').eq(Number(row.tipoExamenes)-1).prop('checked',true);
                $otroExamen.val(row.otroExamen);
                $motivo.val(row.motivo);
                $fechaPlazo.val(row.fechaPlazo);
                $fechaRetorno.val(row.fechaRetorno);
                $btnRealizaraccion.val(row.idexamenes_Medicos);
                $btnRealizaraccion.text('Modificar');
                $btnRealizaraccion.addClass('btn-warning');
                $empleados.attr('disabled', 'true');
            });
        }
    });
}

function enviarInformacionFormulario(idEx) {
    // Moverme al principio de la pagina. Pendiente
    $('html, body').animate({
        scrollTop: 0
    }, 'slow');
    consultarInformacion(idEx);
    // ...
}

function eliminarExamenEmpelado(ID) {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se eliminara la informacion del examen de este empleado",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            //Registrar o modificar empresa
            $.post(baseurl+'Empleado/cExamenes/eliminarExamenEmpelado', {idEX: ID}, function(data) {
                if (data==1) {
                    swal('Realizado','El Examen fue eliminado correctamente','success');
                    // Se puede ver la forma de remplazar por el por un queune de jQuery.
                    setTimeout(function() {
                        consultarInformacion(0);
                    }, 100);
                    // 
                    limpiarEstadoInicial();
                }else{
                    swal('Alerta','ocurrio un error a la hora de eliminar','danger');
                }
            });
        }
    });
}

function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}

function limpiarEstadoInicial() {
    $empleados.children('option[value="0"]').prop('selected',true);
    $empleados.removeAttr('disabled');
    $empleados.selectpicker('refresh');
    $inputRadios.find('input[type="radio"]').prop('checked',false);
    $otroExamen.val('');
    $motivo.val('');
    $fechaPlazo.val('');
    $fechaRetorno.val('');
    $btnRealizaraccion.val('0');
    $empleados.parent('div').removeClass('has-error');
    $inputRadios.parent('div').removeClass('has-error');
    $motivo.parent('div').removeClass('has-error');
    $fechaPlazo.parent('div').removeClass('has-error');
    $fechaRetorno.parent('div').removeClass('has-error');
    $btnRealizaraccion.text('Registrar');
    $btnRealizaraccion.removeClass('btn-warning');
}
