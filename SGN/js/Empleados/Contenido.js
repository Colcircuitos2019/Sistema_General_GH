var $tabla = $('#tableExtras');
var $horasEmpleado;
$(document).ready(function() {
    // ...
    // Consulta los empleados que aun tienen horas pendientes por aprobar
    consultarEmpleadosConHorasExtrasAprobar();
    // Click en el boton de realizar cambios
    $('#btnRealizarA').click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se gestionara las horas extras de los empleados.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                // console.log('Se actualizara');
                // aceptarDenegarHorasExtras();
                if (validarTablaC()) {
                    // Falta marcar los campos que no tienen informacion pero son obligatorios.
                    aceptarDenegarHorasExtras();//SE realiza la debida gestion.
                    // console.log('Registro');
                    // $('#31').addClass('has-error');
                }else{
                    swal('Alerta!','Falta algun campo por diligenciar.','warning');
                }
            }
        });
    });
    // 
    $('#guardarMensaje').click(function(event) {
        $horasEmpleado.data('descrip', $('#description').val());
        // 
        $('#description').val('');
        $('#MensajeD').modal('hide');
    });
});

function aceptarDenegarHorasExtras() {
    $('#cuerpo').find('tr').each(function(index, item) {
        //0=documento, 1=fecha de las horas extrar, 2=id de las horas laboradas
        var empleadoH = $(this).data('empleado').split(';');
        // Algun boton presionado? 
        if ($(this).find('td').eq(0).find('input:radio[name=' + empleadoH[2] + ']:checked').val() != undefined) {
            var des = null;
            var horaA, horaR;
            // Pregunta si el boton seleccionado tiene el valor 2=Denegado
            // if ($(this).find('td').eq(0).find('input:radio:checked').val() == 2) {
            //     des = $(this).find('td').eq(9).find('textarea').val();
            // }
            des = $(this).find('td').eq(8).find('textarea').val();
            //Horas aceptadas
            horaA = $(this).find('td').eq(6).find('input').val();
            // Horas rechazadas
            horaR = $(this).find('td').eq(7).find('input').val();
            // 
            enviarInformacionActualizarHorasExtras(empleadoH[0], empleadoH[1], des, empleadoH[2], horaA, horaR);
        }
    });
}
// Se encarga de aceptar o denegar las horas extras de los empelados.
function enviarInformacionActualizarHorasExtras(documento, fecha, description, idH, horasA, horasR) {
    $.post(baseurl + 'Empleado/cAsistencia/aceptarHorasExtrarEmpleado', {
        documento: documento,
        fecha: fecha,
        des: description,
        index: idH,
        aceptadas: horasA,
        rechazadas: horasR
    }, function(data) {
        // console.log(data);
        if (data == 1) {
            // Se encarga de consultar a los empelados que tienen horas extras nuevamente.
            swal('Listo!', 'Se gestiono las horas laborales.', 'success');
            consultarEmpleadosConHorasExtrasAprobar();
        }
    });
}

// Se encarga de consultar los empleados que tiene horas extras sin aprobar.
function consultarEmpleadosConHorasExtrasAprobar() {
    // var op = 0;
    $.post(baseurl + 'Empleado/cAsistencia/consultarEmpleadosConHorasExtrasAprobar', function(data) {
        //Cast a json
        var result = JSON.parse(data);
        // Limpiar la tabla
        $tabla.empty();
        $tabla.html('<table class="display" id="tblHorasExtrarA">' + '<thead id="Cabeza">' + '<th>Acción</th>' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Empresa</th>' + '<th>Fecha</th>' + '<th>N°horas</th>' + '<th>N°Aceptadas</th>' + '<th>N°Rechazadas</th>' + '<th>Descripción</th>' + '</thead>' + '<tbody id="cuerpo">' + '</tbody>' + '</table>');
        // Agregar la informacion a la tabla
        $.each(result, function(index, row) {
            // ToolTip data-toggle="tooltip" data-placement="bottom" title="Hooray!"
            $('#cuerpo').append('<tr name="' + row.idH_laboral + '" data-empleado="' + row.documento + ';' + row.fecha_laboral + ';' + row.idH_laboral + '">' + 
                '<td>' + '<div class="checkbox">' + '<label><input name="' + row.idH_laboral + '" type="radio" value="1" onclick="accionAceptarODenegarHoras(this.value,\'' + row.idH_laboral + '\',\'' + row.numero_horas + '\');"> <span><small class="label bg-green">Aceptar</small></span></label>' + '</div>' + '<div class="checkbox">' + '<label><input name="' + row.idH_laboral + '" type="radio" value="2" onclick="accionAceptarODenegarHoras(this.value,\'' + row.idH_laboral + '\',\'' + row.numero_horas + '\');"> <span><small class="label bg-red">Denegar</small></span></label>' + '</div>' + '</td>' + //onclick= validarSeleccionBoton(name)
                '<td>' + row.documento + '</td>' + 
                '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + 
                '<td>' + row.nombre + '</td>' + 
                '<td>' + row.fecha_laboral + '</td>' + 
                '<td>' + row.numero_horas + '</td>' + 
                '<td>' + 
                  '<div class="bootstrap-timepicker timepicker">'+
                    '<input class="1 timepicker" data-tiempo="'+row.numero_horas+'" onkeyup="diferenciaHoras('+row.idH_laboral+')" type="text" maxlength="8" style="width:60px; " disabled>'+
                  '</div>'+ '</td>' + 
                '<td>' + '<div><input class="1 inputs" id="' + row.idH_laboral + '" type="text" disabled></div>' + '</td>' + 
                '<td>' + '<textarea disabled></textarea>' + '</td>' + 
            '</tr>');
            //onkeypress="return valida(event,\'' + row.numero_horas + '\',this.value,\'' + row.idH_laboral + '\')"
            // onkeyup="retroceso(event,this.value,\'' + row.numero_horas + '\',\'' + row.idH_laboral + '\');"
        });
        //Formato del data table
        $('#tblHorasExtrarA').DataTable();
        // 
        $('[data-toggle="tooltip"]').tooltip();
        // 
        // Time picker
        // $('.timepicker').timepicker({
        //     minuteStep: 1,
        //     template: 'modal',
        //     appendWidgetTo: 'body',
        //     showSeconds: true,
        //     showMeridian: false,
        //     defaultTime: false
        // });
    });
}
// Se encarga de validar la tabla y que todo este en orden antes de realizar la acción de realizar.
function validarTablaC() { //Esta validacion queda pendiente.
    // Todos los compoennetes tr de la tabla.
    var filas = $('#cuerpo').find('tr');
    // Se recorre todas las filas de la tabla con jQuery.
    for (var i = 0; i < filas.length; i++) {
        // Se valida que boton aceptar o denegar este seleccionado.
        if ($(filas[i]).find('td').eq(0).find('input[type=radio]:checked').val() != undefined) {
            // Si las horas son aceptadas, por defecto tienen que ser aceptadas todas, si son denegadas por defecto van a ser rechazadas todas y tiene que llevar una descrpcion y si ninguna de las dos no es seleccionada significa que no a realizar ninguna accion por el momento con esas horas extras.
            //Aceptadas...
            if ($(filas[i]).find('td').eq(0).find('input[type=radio]:checked').val() == 1) { 
                //Las horas no pueden ser vacion, pero la descripcion si lo puede ser. 
                if (!($(filas[i]).find('td').eq(6).find('input').val() != '')) {
                    return false;
                }
            // Denegadas...
            } else { 
                // Las horas por defecto tienen que ser 00:00:00.
                if (!($(filas[i]).find('td').eq(6).find('input').val() != '')) {
                    return false;
                }
                // La Descripción no puede ser vacia.
                if (!($(filas[i]).find('td').eq(8).find('textarea').val() != '')) {
                    return false;
                }
            }
            // ...
            // Validar formato de los input de hora
            if (validarFormatoHorasIngresadas($(filas[i]).find('td').eq(6).find('input').val())) {//Horas Aceptadas 
                return false;
            }
            // Validar formato de los input de hora
            if (validarFormatoHorasIngresadas($(filas[i]).find('td').eq(7).find('input').val())) {//Horas Rechazadas
                return false;
            }

        }
    }
    // Si todo pasa sin ningun problema al recorrer la tabla, la funcion retornara una true validando que si se puede realizar la dicha gestion.
    return true;
}

function diferenciaHoras(idHoras) {
    var horasR= $('input[id="'+idHoras+'"]');
    var tiempo= $('input[id="'+idHoras+'"]').parents('td').parent('tr').find('td').eq(6).find('input').data('tiempo');
    var horasA= $('input[id="'+idHoras+'"]').parents('td').parent('tr').find('td').eq(6).find('input').val();
    // ...
    if (!(validarFormatoHorasIngresadas(tiempo)) && !(validarFormatoHorasIngresadas(horasA))) {
        $.post(baseurl+'Empleado/cAsistencia/diferenciaDeHoras', 
            {
                tiempo: tiempo,
                horasA: horasA
            }, function(data) {
            /*optional stuff to do after success */
            horasR.val(data);
        });
    } 
    // ...
}

// Se encarga de validar que el formato de horas:minutos:segundos sea el correcto
function validarFormatoHorasIngresadas(hora) {
    var tiempo= hora.split(':');
    // ...
    if (tiempo.length==3) {//Validar que tenga las horas los minutos y los segundos
        for (var i = 0; i < tiempo.length; i++) {//Validar que cada unidad de tiempo venga en pares
           if (tiempo[i].length==2) {
               if (Number(tiempo[i])>=0) {// Validar que el numero ingresado no sea un numero negativo
                   // Validar que ninguno unidad se pase de más de 59
                   if (!(Number(tiempo[i])<=59)) {
                       return true;
                   }
                   // ...
                    if (i==2) {
                       return false;
                    }
               }else{
                   return true;
               }
           }else{
               return true;
           }  
         } 
    }else{
        return true;
    }
    // ...
}

// El funcionamiento de este procedimiento es definir que hara cuando se clikee el boton aceptar o rechazar de cada fila.
function accionAceptarODenegarHoras(accion, idInput, totalHoras) {
    var $cuerpoTbl = $('#cuerpo');
    // Remover el atributo disabled del text area
    $cuerpoTbl.find('tr[name="' + idInput + '"]').find('td').eq(8).find('textarea').removeAttr('disabled');
    switch (Number(accion)) {
        case 1: //Aceptar
            $('#' + idInput).val('00:00:00');
            $cuerpoTbl.find('tr[name="' + idInput + '"]').find('td').eq(6).find('input').val(totalHoras);
            $cuerpoTbl.find('tr[name="' + idInput + '"]').find('td').eq(6).find('input').removeAttr('disabled');
            break;
        case 2: //Denegar
            $('#' + idInput).val(totalHoras);
            $cuerpoTbl.find('tr[name="' + idInput + '"]').find('td').eq(6).find('input').val('00:00:00');
            $cuerpoTbl.find('tr[name="' + idInput + '"]').find('td').eq(7).find('input').val(totalHoras);
            $cuerpoTbl.find('tr[name="' + idInput + '"]').find('td').eq(6).find('input').attr('disabled', 'true');
            break;
    }
    // console.log(accion, idInput);
}
//Valida que solo se ingresen valores numericos
function valida(e, nHoras, value, idR) { //Evento tecla, Numero de horas total, Numero de horas ingresadas, ID componente horas rechazadas.
    // Se valida que el input no tenga más de 4 caracteres
    if (value.length < 4) {
        // Optenemos el valor en ASCII.
        tecla = (document.all) ? e.keyCode : e.which;
        // Nuevo valor ingresado.
        patron = /[0-9]/;
        var newValor = String.fromCharCode(tecla);
        // El valor ingresado es numerico o es un punto?
        if (patron.test(newValor) || newValor == '.') {
            //Tecla de retroceso para borrar, siempre la permite
            if (tecla == 8) {
                // 8 es el código ASCII del la tecla retroceder.
                return true;
            } else {
                //
                // return patron.test(tecla_final);
                if (value.length == 0 && newValor == '.') {
                    return false;
                } else {
                    // si el proximo valor es un punto lo aceptamos
                    if (newValor == '.') {
                        return true;
                    } else { //si el proximo valor no es un punto.
                        var valor = value + newValor;
                        // El valor viejo es menos que a las nuevas horas ingresadas
                        if (Number(valor) <= Number(nHoras)) {
                            //Componente de horas rechazadas, Total numero de horas y horas ingresadas
                            $('#' + idR).val(restarNumeroHoras(Number(nHoras), Number(valor)));
                            return true;
                        } else {
                            // 
                            return false;
                        }
                    }
                }
            }
        } else {
            // Cuando es un valor alfabetico.
            return false;
        }
    } else {
        // Cuando la longitud de la cadena es mayor que 4
        return false;
    }
    // $(this).val();
    // // Patron de entrada, en este caso solo acepta numeros
}

// function restriccionTeclas(event) {
//     // ID de la tecla
//     tecla = (document.all) ? event.keyCode : event.which;
//     // 
//     console.log(tecla);
// }

// Se encarga de hacer la resta entre el numero de horas y horas aceptas, esto da lugar a calcular las horas rechazadas.
function restarNumeroHoras(nHoras, nHAceptadas) {
    return (nHoras - nHAceptadas).toFixed(2); //Esta funcion de javascript me arregla es error al calcular los decimales.
}
// ...

function retroceso(e, value, nHoras, idR) {
    // console.log(value + ' ' + nHoras);
    tecla = (document.all) ? e.keyCode : e.which;
    //Tecla de retroceso para borrar, siempre la permite
    if (tecla == 8 || tecla == 46) { //Tecla retroceso y suprimir
        //Setear el valor retornado 
        $('#' + idR).val(restarNumeroHoras(Number(nHoras), Number(value)));
    }
}