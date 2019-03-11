//variables
var $hora1 = $('#timepicker1');
var $hora2 = $('#timepicker2');
var $hora3 = $('#timepicker3');
var $hora4 = $('#timepicker4');
var $buton = $('#sendInfo');
// 
$(document).ready(function() {
    //Consultar Configuracion de restricciones
    $.post(baseurl + 'Alimentacion/cRestriccion/consultarConfiguracion', function(dato) {
        /*optional stuff to do after success */
        valor = JSON.parse(dato);
        //console.log(valor.hora_inicio_pedidos);
        $hora1.val(valor.hora_inicio_pedidos);
        $hora2.val(valor.hora_fin_pedidos);
        $hora3.val(valor.hora_inicio_siguiente_dia);
        $hora4.val(valor.hora_fin_siguiente_dia);
        $buton.data('identificador', valor.idRestriccion);
    });
    //Fin de la consulta de configuracion
    //Modificar la restriccion de pedidios
    $buton.click(function(event) {
        //Evento del boton
        event.preventDefault();
        // Validacion de confirmación
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se gurdara el horario para realizar los pedidos.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                $.ajax({
                    url: baseurl + 'Alimentacion/cRestriccion/modificarConfiguracion',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        hora1: generarHoraValida($hora1.val()),
                        hora2: generarHoraValida($hora2.val()),
                        hora3: generarHoraValida($hora3.val()),
                        hora4: generarHoraValida($hora4.val()),
                        id: $buton.data('identificador')
                    },
                }).done(function(dato) {
                    if (dato == 1) {
                        swal({
                            position: 'center',
                            type: 'success',
                            title: 'Realizado!',
                            text: 'Las horas de restriccion de pedidos fueron modificadas.',
                            showConfirmButton: false,
                            timer: 2500
                        });
                    } else {
                        swal({
                            position: 'center',
                            type: 'error',
                            title: 'Alerta!',
                            text: 'Las horas de restriccion no estan bien especificadas.',
                            showConfirmButton: false,
                            timer: 2500
                        });
                    }
                }).fail(function() {
                    console.log("error");
                });
            }
        });
    });
    //Fin de la modificacion
    function generarHoraValida(hora) {
        var partes = hora.split(':');
        var res = (partes[0].length == 1 ? '0' : '') + partes[0] + ':' + partes[1] + ':' + partes[2];
        return res;
    }
});