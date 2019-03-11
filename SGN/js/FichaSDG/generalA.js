var $inputTXT;
var $tableResponsive = $('#tblResponsive');
var $btnRealizaraccion = $('#EnviarA');
var $btnLimpiar = $('#limpiarFormulario');
var nombreVista;
var nombreColumna;
/*vista es una variable global que se encuentra en el footer.*/
switch (vista) {
    case 1:
        // Salario
        nombreVista = ' Salario';
        // Variables inputName
        $inputTXT = $('#salarioN');
        break;
    case 2:
        // Clasificacion Mega
        nombreVista = ' Clasificacion Mega';
        // Variables inputName
        $inputTXT = $('#clasificacionMegaN');
        break;
    case 3:
        // Auxiliar
        nombreVista = ' Auxiliar';
        // Variables inputName
        $inputTXT = $('#AuxilioN');
        break;
    case 4:
        // Estado civil
        nombreVista = ' Estado Civil';
        // Variables inputName
        $inputTXT = $('#estadoCivilN');
        break;
    case 5:
        // EPS
        nombreVista = ' EPS';
        // Variables inputName
        $inputTXT = $('#EPSN');
        break;
    case 6:
        // EPS
        nombreVista = ' AFP';
        // Variables inputName
        $inputTXT = $('#AFPN');
        break;
    case 7:
        // Cargo Laboral
        nombreVista = ' Cargos Laborales';
        // Variables inputName
        $inputTXT = $('#CargoN');
        break;
    case 8:
        // Horario Laboral
        nombreVista = ' Horario de trabajo';
        // Variables inputName
        $inputTXT = $('#horarioLaboralN');
        break;
    case 9:
        // Área de trabajo
        nombreVista = ' Área de trabajo';
        // Variables inputName
        $inputTXT = $('#areaLaboralN');
        break;
    case 10:
        // Tipo de Contrato
        nombreVista = ' Tipo de Contrato';
        // Variables inputName
        $inputTXT = $('#TipoContratoN');
        break;
    case 11:
        // Grado de escolaridad
        nombreVista = ' Grado de Escolaridad';
        // Variables inputName
        $inputTXT = $('#gradoEscolaridadN');
        break;
    case 12:
        // Actividades en tiempo Libre
        nombreVista = ' Actividad de Tiempo Libre';
        // Variables inputName
        $inputTXT = $('#aTiempoLibreN');
        break;
    case 13:
        // Actividades en tiempo Libre
        nombreVista = ' Municipios';
        // Variables inputName
        $inputTXT = $('#municipioN');
        break;
    case 15:
        // Clasificacion menga
        nombreVista = ' Clasificación Contable';
        // Variables inputName
        $inputTXT = $('#clasificacionContable');
        break;      
}
// DOM
$(document).ready(function() {
    // Boton de realizar acción 
    $btnRealizaraccion.on('click', function() {
        event.preventDefault();
        var op = $(this).val();
        // 
        if ($inputTXT.val() != '') {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "Se " + (op == 0 ? 'Registrar' : 'Modificara') + nombreVista,
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {
                    //Registrar o modificar empresa
                    $inputTXT.parent('div').removeClass('has-error');
                    registrarModificarEstadoCRUD(Number($(this).val()), 2);
                }
            });
        } else {
            if (!($inputTXT.parent('div').hasClass('has-error'))) {
                $inputTXT.parent('div').addClass('has-error');
            }
        }
    });
    // Consultar todas las empresas registradas en el sistema de informacion
    consultarInformacion();
    // Limpiar formulario (Dejarlo en el estado inicial)
    $btnLimpiar.click(function() {
        limpiarEstadoInicial();
    });
});
//Se encarga de registrar o modificar las empresas
function registrarModificarEstadoCRUD(idE, estado) {
    $.ajax({
        url: baseurl + 'FichaSDG/cConfiguracionFicha/registrarModificarEstadoCRUD',
        type: 'POST',
        dataType: 'json',
        data: {
            idEm: idE,
            nombre: $inputTXT.val(),
            estadoE: String(estado),
            info: vista //Que Procedimiento almacenado se llama
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
                consultarInformacion();
                limpiarEstadoInicial();
            }
        }
        // console.log("success");
    }).fail(function() {
        swal('Alerta!', 'Ocurrio un error en el procedimiento.', 'error');
    });
}
// Se encarga de consultar todas las empresas que estan registradas en el sistema de informacion
function consultarInformacion() {
    // 
    $.post(baseurl + 'FichaSDG/cConfiguracionFicha/consultarInformacion', {
        op: 1, //Se encarga designar la accion de consultar todos los salarios sin importar el estado.
        info: vista //Que Procedimiento almacenado se llama
    }, function(data) {
        var result = JSON.parse(data);
        $tableResponsive.empty();
        $tableResponsive.html('<table class="display" id="generalTable">' + '<thead>' + '<th>ID</th>' + '<th>' + nombreVista + '</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
        var $cuerpoP = $('#cuerpoE');
        $.each(result, function(index, row) {
            switch (vista) {
                case 1:
                    // Salario
                    mensaje = '<tr>' + '<td>' + row.idPromedio_salario + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idPromedio_salario + ';' + row.nombre + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idPromedio_salario + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 2:
                    // Clasificacion Mega
                    mensaje = '<tr>' + '<td>' + row.idClasificacion_mega + '</td>' + '<td>' + row.clasificacion + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idClasificacion_mega + ';' + row.clasificacion + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idClasificacion_mega + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 3:
                    // Auxiliar
                    mensaje = '<tr>' + '<td>' + row.idTipo_auxilio + '</td>' + '<td>' + row.auxilio + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idTipo_auxilio + ';' + row.auxilio + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idTipo_auxilio + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 4:
                    // Estado civil
                    mensaje = '<tr>' + '<td>' + row.idEstado_civil + '</td>' + '<td>' + row.nombre_estado + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idEstado_civil + ';' + row.nombre_estado + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idEstado_civil + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 5:
                    // EPS
                    mensaje = '<tr>' + '<td>' + row.idEPS + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idEPS + ';' + row.nombre + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idEPS + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 6:
                    // AFP
                    mensaje = '<tr>' + '<td>' + row.idAFP + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idAFP + ';' + row.nombre + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idAFP + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 7:
                    // Cargos laborales
                    mensaje = '<tr>' + '<td>' + row.idCargo + '</td>' + '<td>' + row.cargo + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idCargo + ';' + row.cargo + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idCargo + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 8:
                    // Horario de Trabajo
                    mensaje = '<tr>' + '<td>' + row.idHorario_trabajo + '</td>' + '<td>' + row.horario + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idHorario_trabajo + ';' + row.horario + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idHorario_trabajo + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 9:
                    // Área de trabajo
                    mensaje = '<tr>' + '<td>' + row.idArea_trabajo + '</td>' + '<td>' + row.area + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idArea_trabajo + ';' + row.area + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idArea_trabajo + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 10:
                    // Tipo de contrato
                    mensaje = '<tr>' + '<td>' + row.idTipo_contrato + '</td>' + '<td>' + row.contrato + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idTipo_contrato + ';' + row.contrato + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idTipo_contrato + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 11:
                    // Grado de escolaridad
                    mensaje = '<tr>' + '<td>' + row.idGrado_escolaridad + '</td>' + '<td>' + row.grado + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idGrado_escolaridad + ';' + row.grado + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idGrado_escolaridad + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 12:
                    // Actividades en el tiempo libre
                    mensaje = '<tr>' + '<td>' + row.idActividad + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idActividad + ';' + row.nombre + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idActividad + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 13:
                    // Municipios
                    mensaje = '<tr>' + '<td>' + row.idMunicipio + '</td>' + '<td>' + row.nombre + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idMunicipio + ';' + row.clasificacion + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idClasificacion_contable + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;
                case 15:
                    // Clasificacion contable
                    mensaje = '<tr>' + '<td>' + row.idClasificacion_contable + '</td>' + '<td>' + row.clasificacion + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.idClasificacion_contable + ';' + row.clasificacion + '" onclick="enviarInformacionFormulario(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"' + (row.estado == 0 ? 'disabled="true"' : '') + '></i>Editar</span></button></p>' + '<button value="' + row.idClasificacion_contable + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>';
                    break;    
            }
            //... 
            $cuerpoP.append(mensaje);
            //... 
        });
        // 
        $('#generalTable').DataTable();
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
    $inputTXT.parent('div').removeClass('has-error');
    $btnRealizaraccion.val(datos[0]);
    $inputTXT.val(datos[1]);
}

function cambiarEstadoE(ID) {
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
            registrarModificarEstadoCRUD(ID, 1);
            // Se puede ver la forma de remplazar por el por un queune de jQuery.
            setTimeout(function() {
                consultarInformacion();
            }, 100);
            // 
            limpiarEstadoInicial();
        }
    });
}

function limpiarEstadoInicial() {
    $inputTXT.val('');
    $btnRealizaraccion.val(0);
    $btnRealizaraccion.text('Enviar');
    $btnRealizaraccion.removeClass('btn-warning');
    $btnRealizaraccion.addClass('btn-primary');
}
//Retornair item estado
function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger tamaño btn-xs" onclick="cambiarEstadoE(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="cambiarEstadoE(this.value)"><span><i class="fas fa-check"></i> Activar';
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