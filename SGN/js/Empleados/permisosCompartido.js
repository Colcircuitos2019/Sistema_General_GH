// Consultar Todos los conceptos que puede tener un permiso
function consultarConceptos(elemento,idPermiso, accion) {
    $.post(baseurl + 'Empleado/cConcepto/consultarConceptos', function(data) {
        var result = JSON.parse(data);
        $(elemento).empty();
        $(elemento).append('<option value="0" >Seleccione...</option>');
        $.each(result, function(index, row) {
            $(elemento).append('<option value="' + row.idConcepto + '">' + row.concepto + '</option>');
        });
        $(elemento).selectpicker('refresh');
        // ...
        if (idPermiso>0) {
        	consultarInformacionPermisoEmpleado(idPermiso,accion);
        }
    });
}

// Se encarga de convertir una hora de formato de 12 horas a un formato de 24.
function convertidorHoraFormato24(hora) {
    var v = hora.split(' '); //Se separa la hora del AM o PM
    var tiempo;
    var v1 = v[0].split(':'); //Se separan las horas de los minutos
    if (hora.indexOf("PM") > -1) {
        if (v1[0] == '12') { //Aun sigue en formato de 12 horas
            return v[0] + ':00'; //Retorna las 12 del medio día
        } else {
            switch (Number(v1[0])) { //Hora del permiso en formato de 12 horas
                case 1:
                    tiempo = '13:' + v1[1] + ':00';
                    break;
                case 2:
                    tiempo = '14:' + v1[1] + ':00';
                    break;
                case 3:
                    tiempo = '15:' + v1[1] + ':00';
                    break;
                case 4:
                    tiempo = '16:' + v1[1] + ':00';
                    break;
                case 5:
                    tiempo = '17:' + v1[1] + ':00';
                    break;
                case 6:
                    tiempo = '18:' + v1[1] + ':00';
                    break;
                case 7:
                    tiempo = '19:' + v1[1] + ':00';
                    break;
                case 8:
                    tiempo = '20:' + v1[1] + ':00';
                    break;
                case 9:
                    tiempo = '21:' + v1[1] + ':00';
                    break;
                case 10:
                    tiempo = '22:' + v1[1] + ':00';
                    break;
                case 11:
                    tiempo = '23:' + v1[1] + ':00';
                    break;
                case 12:
                    tiempo = '00:' + v1[1] + ':00';
                    break;
            }
            return tiempo;
        }
    } else {
        if (v1[0] == '12') { //Son las 12 AM
            return '00:00:00';
        } else {
            return (v1[0].length == 1 ? '0' : '') + v[0];
        }
    }
}

//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}