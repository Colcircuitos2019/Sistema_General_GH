//Variables
//Vista principale
var $documento = $('#documento');
var $fechaEx= $('#fechaEX');
var $lugarEx= $('#lugarEX');
var $primerN = $('#nombre1');
var $segundoN = $('#nombre2');
var $primerA = $('#apellido1');
var $segundoA = $('#apellido2');
var $huella1 = $('#huella1');
var $huella2 = $('#huella2');
var $huella3 = $('#huella3');
var $contra1 = $('#contraseña1');
var $contra2 = $('#contraseña2');
var $correo = $('#correo');
var $cuerpo = $('#cuerpo');
var $manufactura = $('#manufactura');
//Vista secundaria editar
var $documentoM = $('#documentoM');
var $fechaExM= $('#fechaEXM');
var $lugarExM= $('#lugarEXM');
var $primerNM = $('#nombre1M');
var $segundoNM = $('#nombre2M');
var $primerAM = $('#apellido1M');
var $segundoAM = $('#apellido2M');
var $huella1M = $('#huella1M');
var $huella2M = $('#huella2M');
var $huella3M = $('#huella3M');
var $contra1M = $('#contraseña1M');
var $contra2M = $('#contraseña2M');
var $correoM = $('#correoM');
var $manufacturaM = $('#manufacturaM');
//Se ejecuta cuando carga la pagina
consultarEmpresas($('#Empresas'));
$(document).ready(function() {
    // ...
    //Importar empleados
    $('#formImportarE').submit(function(event) {
        event.preventDefault();
        $.ajax({
            url: baseurl+'Empleado/cEmpleado/importarEmpelados',
            type: 'POST',
            data: new FormData(this),
            cache:false,
            contentType:false,
            processData: false,
            beforeSend:function () {
                $('#formImportarE').append('<img src="'+baseurl+'img/loader-small.gif" alt="loading"/>');
            }
        })
        .done(function(data) {
            // console.log(data);
            $('#formImportarE').children('img').remove();
            // console.log("success");
            if (data==1) {
                swal('Realizado','Se importo correctamente el documento','success',{buttons:false, timer:2000});
                $('#file').val('');
                consultarEmpelados('');
            }else{
                swal('Alerta','Error en el importar documento','warning',{buttons:false, timer:2000});
            }
        })
        .fail(function() {
            $('#formImportarE').children('img').remove();
            swal('Alerta',"Ocurrio un error al tratar de importar el documento, porfavor revise el formato del xlsx o intentelo nuevamente.",'error',{button:false, timer:2000});
            // console.log("error");
        });
    });
    //Consultar empleados
    consultarEmpelados('');
    // Registrar Empleado
    $('#Enviar').click(function(event) {
        registrarModificarEmpelados(0); //Registrar empleados
    });
    //Modificar Empleado
    $('#cActualizar').click(function(event) {
        registrarModificarEmpelados(1);
    });
    //Hace que el navegador pregunte antes de salir o recargar la pagina
    window.onbeforeunload = preguntarAntesDeSalir;

    function preguntarAntesDeSalir() {
        return "¿Seguro que quierese salir?";
    }
    //Comsultar roles de los empleados
    consultarRoles($('#Roles'));

});
// Se encarga de consultar todos los roles que se maneja en la empresa
function consultarRoles($componente) {
    $.post(baseurl + 'Empleado/cEmpleado/consultarRoles', {}, function(dato) {
        //Traemos la informacion de respuesta
        var c = JSON.parse(dato);
        //alert(dato);
        $componente.empty();
        $componente.append("<option value='0'>Seleccione...</option>");
        $.each(c, function(i, item) { //recorremos todo el result que se convirtio a json
            $componente.append("<option value=" + item.idRol + ">" + item.nombre + "</option>");
        });
    });
}
// Modifica o registra a un empleado
function registrarModificarEmpelados(op) {//(op==0)=Registrar, (op==1)=Modificar
    //Validacion de confirmación de acción.
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: op == 0 ? "Se registrara un empleado nuevo al sistema" : "Se modificara la informacion de este empleado.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            //Se valida que los campos obligatorios no esten vacios
            //Asignacion de valores al array
            var $inputs;
            if (op == 0) {//Registrar
                // Faltan las huellas
                $inputs = [$documento, $primerN, $primerA, $('input:radio[name=genero]:checked'), $('#Empresas > option:selected'), $huella1, $huella2, $huella3, $('#Roles > option:selected'), $('#Pisos option:selected'),$fechaEx,$lugarEx,$correo];
            } else { //Modificar
                // faltan las huellas
                $inputs = [$documentoM, $primerNM, $primerAM, $('input:radio[name=generoM]:checked'), $('#EmpresasM > option:selected'), $huella1M, $huella2M, $huella3M, $('#RolesM > option:selected'), $('#PisosM option:selected'),$fechaExM,$lugarExM,$correoM];
            }
            if (validarCampos($inputs)) {
                //Validacion de los campos de contraseña vacios
                if ((op == 0 ? $contra1.val() : $contra1M.val()) != '' && (op == 0 ? $contra2.val() : $contra2M.val()) != '') {
                    //Validacion de conparacion y longitud de la contraseña
                    if ((op == 0 ? $contra1.val() : $contra1M.val()) == (op == 0 ? $contra2.val() : $contra2M.val()) && ((op == 0 ? $contra1.val() : $contra1M.val()).length == 4) && ((op == 0 ? $contra2.val().length : $contra2M.val().length) == 4)) { //Cuatro caracteres de maximo
                        // Falta la validacion de huellas cuando el rol del empelado es operario
                        // Validacion de existencia de documento
                        $.post(baseurl + 'Empleado/cEmpleado/validarDocumento', {
                            documento: op == 0 ? $documento.val() : $documentoM.val()
                        }, function(data) {
                            if (op == 0) { //Registrar
                                //Validacion de la respuesta del servido
                                if (data == 0) {
                                    accionARealizar(op);
                                } else { //Cuendo el documento ya existe
                                    swal({
                                        position: 'center',
                                        type: 'warning',
                                        title: 'Alerta!',
                                        text: 'Este usuario ya esta registrado',
                                        showConfirmButton: false,
                                        timer: 2500
                                    });
                                }
                            } else { //Modificar
                                //Validacion de la respuesta del servidor
                                if (data == 1) {
                                    accionARealizar(op);
                                } else { //Cuendo el documento no existe
                                    swal({
                                        position: 'center',
                                        type: 'warning',
                                        title: 'Alerta!',
                                        text: 'Este usuario no existe',
                                        showConfirmButton: false,
                                        timer: 2500
                                    });
                                }
                            }
                        });
                    } else { //Cuendo las contraseñas no coinciden o estan erroneas
                        alert('Las contraseñas no coinciden.');
                    }
                } else { //Cuendo la contraseña esta vacia
                    alert('La contraseña es necesaria');
                }
            } else {
                var $inputs;
                if (op == 0) { //Registrar
                    $inputs = [$documento, $primerN, $primerA, $huella1, $huella2, $huella3, $contra1, $contra2,$fechaEx,$lugarEx,$correo,$('#Pisos')];
                } else { //Modificar
                    $inputs = [$documentoM, $primerNM, $primerAM, $huella1M, $huella2M, $huella3M, $contra1M, $contra2M,$fechaExM,$lugarExM,$correoM,$('#PisosM')];
                }
                // Se encarga de marcar los campos qeu faltan por diligenciar
                marcarCamposVacios($inputs);
                swal({
                    position: 'center',
                    type: 'warning',
                    title: 'Alerta!',
                    text: 'Falta algun campo obligatorio por diligenciar',
                    showConfirmButton: false,
                    timer: 2500
                });
            }
        }
    });
}

function accionARealizar(op) {
    var id;
    var genero;
    var idRol;
    var pisos;
    if (op == 0) {//Registrar
        // Genero
        genero = $('input:radio[name=genero]:checked').val();
        // Empresas
        $('#Empresas option:selected').each(function() {
            id = $('#Empresas').val();
        });
        // Roles
        $('#Roles option:selected').each(function() {
            idRol = $('#Roles').val();
        });
        // Piso
        $('#Pisos option:selected').each(function() {
            pisos = $('#Pisos').val();
        });        
    } else { //Modificar
        // Genero modal
        genero = $('input:radio[name=generoM]:checked').val();
        // Empresas modal
        $('#EmpresasM option:selected').each(function() {
            id = $('#EmpresasM').val();
        });
        // Roles modal
        $('#RolesM option:selected').each(function() {
            idRol = $('#RolesM').val();
        });
        // Piso modal
        $('#PisosM option:selected').each(function() {
            pisos = $('#PisosM').val();
        });
    }
    $.post(baseurl+'Empleado/cEmpleado/validarExistenciaContra', {doc: (op == 0 ? $documento.val() : $documentoM.val()),contra: (op == 0 ? $contra1.val() : $contra1M.val())}, function(data) {
        if (data==1) {//LA contraseña ya existe
            swal('Alerta','La contraseña ingresada no es validad, por favor intenta con otra contraseña.','warning');
        }else{//La contraseña no existe
            // Acción...
            $.post(baseurl + 'Empleado/cEmpleado/insertarModificarEmpleado', {
                documento: op == 0 ? $documento.val() : $documentoM.val(),
                nombre1: op == 0 ? $primerN.val() : $primerNM.val(),
                nombre2: op == 0 ? $segundoN.val() : $segundoNM.val(),
                apellido1: op == 0 ? $primerA.val() : $primerAM.val(),
                apellido2: op == 0 ? $segundoA.val() : $segundoAM.val(),
                genero: String(genero),
                huella1: String(op == 0 ? $huella1.val() : $huella1M.val()),
                huella2: String(op == 0 ? $huella2.val() : $huella2M.val()),
                huella3: String(op == 0 ? $huella3.val() : $huella3M.val()),
                correo: op == 0 ? $correo.val() : $correoM.val(),
                contra: op == 0 ? $contra1.val() : $contra1M.val(),//Problemas con la contraseña
                idEmpresa: Number(id),
                fechaExpedi: op == 0 ? $fechaEx.val() : $fechaExM.val(),
                lugarExpedi: op == 0 ? $lugarEx.val() : $lugarExM.val(),
                accion: op,
                rol: String(Number(idRol)),
                piso: pisos,
                manufactura: op == 0 ? $('#manufactura option:selected').val():$('#manufacturaM option:selected').val()
            }, function(data) {
                //Validacion de la respuesta del servidor
                setTimeout(function () {
                    if (data) {
                        limpiarComponentes(op);
                        if (op == 1) {
                            $('#modificar').modal('toggle');
                        }
                        setTimeout(function () {
                            swal({
                                position: 'center',
                                type: 'success',
                                title: 'Listo!',
                                timer:2000,
                                text: op == 0 ? 'El empleado fue registrado correctamente' : 'El empleado fue modificado exitosamente.'
                            });

                        },600);
                        consultarEmpelados('');
                    } else {
                        swal({
                            position: 'center',
                            type: 'error',
                            title: 'Alerta!',
                            text: 'El empleado no pudo ser registrado.'
                        });
                    }
                },200);
            });
        }
    });
}

// ...
// Se encarga de consultar las empresas disponibles
function consultarEmpresas($componente) {
    $.post(baseurl + 'Empleado/cEmpresa/buscarEmpresas', {}, function(dato) {
        //Traemos la informacion de respuesta
        var c = JSON.parse(dato);
        //alert(dato);
        $componente.empty();
        $componente.append("<option value='0'>Seleccione...</option>");
        $.each(c, function(i, item) { //recorremos todo el result que se convirtio a json
            $componente.append("<option value=" + item.idEmpresa + ">" + item.nombre + "</option>");
        });
    });
}
//Mostrar el modal para editar el empleado
function mostrarModal($doc) {
    consultarEmpelados($doc);
    $('#modificar').modal('show');
}
//Se consultar todos los empleados en general
function consultarEmpelados($doc) {
    $.post(baseurl + 'Empleado/cEmpleado/consultarEmpleados', {
        doc: $doc
    }, function(data) {
        var result = JSON.parse(data);
        if ($doc == '') {
            $('#tblTable').empty();
            // html de la Tabla se empelados
            $('#tblTable').html('<table class="display" id="Empelados">' + '<thead id="cabeza">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Rol</th>' + '<th>Piso</th>' + '<th>Genero</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpo">' + '</tbody>' + '</table>');
            var $cuerpo = $('#cuerpo');
            $.each(result, function(index, row) {
                $cuerpo.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + clasificarRol(row.idRol) + '</td>' + '<td>Piso-' + row.piso + '</td>' + '<td>' + calsificarGenero(row.genero) + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + '<button value="' + row.documento + '" onclick="mostrarModal(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button value="' + row.documento + '" type="button"' + clasificarBoton(row.estado,1,0) + '</span></button>' + (row.idRol==1?(row.asistencia==0?'&nbsp;<button value="' + row.documento + '" type="button" class="btn btn-warning btn-xs" onclick="mostrarModarHorariosConfiguracion(this.value);"><span><i class="far fa-clock"></i> Horario</span></button>':''):'') + '</td>' + '</tr>');
            });
            // Inicializacion de data table
            $('#Empelados').DataTable({
            "bStateSave": true,
            "iCookieDuration":60,
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
        } else {
            // Pisos
            $("#PisosM option").removeAttr('selected');
            // 
            consultarEmpresas($('#EmpresasM'));
            consultarRoles($('#RolesM'));
            $.each(result, function(index, row) {
                // console.log(row.idEmpresa);
                $documentoM.val(row.documento);
                $fechaExM.val(row.fecha_expedicion);
                $lugarExM.val(row.lugar_expedicion);
                $primerNM.val(row.nombre1);
                $segundoNM.val(row.nombre2);
                $primerAM.val(row.apellido1);
                $segundoAM.val(row.apellido2);
                $huella1M.val(row.huella1);
                $huella2M.val(row.huella2);
                $huella3M.val(row.huella3);
                desencryptar(row.contraseña);
                $correoM.val(row.correo);
                if (row.genero == 1) {
                    $('#M').prop('checked', true);
                } else {
                    $('#F').prop('checked', true);
                }
                //Empresa
                setTimeout(function() {
                    //Empresas
                    $("#EmpresasM option[value=" + row.idEmpresa + "]").attr("selected", true);
                    //Roles
                    $("#RolesM option[value=" + row.idRol + "]").attr("selected", true);
                }, 200);
                //Pisos
                $("#PisosM option[value="+row.piso+"]").attr('selected', true);
                //Manufactura
                // debugger;
                $("#manufacturaM option").removeAttr('selected');
                $("#manufacturaM option[value="+(row.idManufactura!=undefined?row.idManufactura:0)+"]").attr('selected', true);
            });
        }
    });
}
function desencryptar(code) {
    $.post(baseurl+'Empleado/cEmpleado/desEncryptar', {contra:code}, function(data) {
       $contra1M.val(data);//Des encryptar
       $contra2M.val(data);//Des encryptar 
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
function clasificarBoton(estado,op,doc) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger tamaño" onclick="'+(op==1?'eliminarEmpleados(this.value);':'cambiarEstadoHorarioEmpleado(this.value,\''+doc+'\');')+'"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="'+(op==1?'eliminarEmpleados(this.value);':'cambiarEstadoHorarioEmpleado(this.value,\''+doc+'\');')+'"><span><i class="fas fa-check"></i> Activar';
    }
}
// Clasificar tipo de ro
function clasificarRol(rol) {
    if (rol == 1) {
        return '<span><small class="label bg-blue">Operario</small></span>';//Operario
    } else {
        return '<span><small class="label bg-yellow">Administrativo</small></span>';//Administrativo
    }
}
//Retorna el tipo de genero que es el empleado
function calsificarGenero(genero) {
    if (genero == 1) {
        return 'Masculino';
    } else {
        return 'Femenino';
    }
}
//Funcion para eliminar
function eliminarEmpleados(documento) {
    // console.log(documento);
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se cambiara el estado del empleado.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            $.post(baseurl + 'Empleado/cEmpleado/eliminarEmpleado', {
                docu: documento
            }, function(data) {
                if (data) {
                    consultarEmpelados('');
                    swal({
                        position: 'center',
                        type: 'success',
                        title: 'Realizado',
                        text: 'El empleado fue cambiado de estado correctamente.',
                        showConfirmButton: false,
                        timer: 2500
                    });
                }
            });
        }
    });
}
//Valida que solo se ingresen valores numericos
function valida(e) {
    tecla = (document.all) ? e.keyCode : e.which;
    //Tecla de retroceso para borrar, siempre la permite
    if (tecla == 8) {
        return true;
    }
    // Patron de entrada, en este caso solo acepta numeros
    patron = /[0-9]/;
    tecla_final = String.fromCharCode(tecla);
    return patron.test(tecla_final);
}
//Valida que se ingresen solo valores alfabeticos
function soloLetras(e) {
    key = e.keyCode || e.which;
    tecla = String.fromCharCode(key).toLowerCase();
    letras = " áéíóúabcdefghijklmnñopqrstuvwxyz";
    especiales = "8-37-39-46";
    tecla_especial = false
    for (var i in especiales) {
        if (key == especiales[i]) {
            tecla_especial = true;
            break;
        }
    }
    if (letras.indexOf(tecla) == -1 && !tecla_especial) {
        return false;
    }
}
//Liempa los inputo y lo deja en estado inicial de registro
function limpiarComponentes(op) {
    (op == 0 ? $documento : $documentoM).val('');
    (op == 0 ? $fechaEx : $fechaExM).val('');
    (op == 0 ? $lugarEx : $lugarExM).val('');
    (op == 0 ? $primerN : $primerNM).val('');
    (op == 0 ? $segundoN : $segundoNM).val('');
    (op == 0 ? $primerA : $primerAM).val('');
    (op == 0 ? $segundoA : $segundoAM).val('');
    (op == 0 ? $correo : $correoM).val('');
    (op == 0 ? $contra1 : $contra1M).val('');
    (op == 0 ? $contra2 : $contra2M).val('');
    //Retirar clases has-error
    (op == 0 ? $documento : $documentoM).parent().removeClass('has-error');
    (op == 0 ? $documento : $documentoM).parent().removeClass('has-success');
    (op == 0 ? $fechaEx : $fechaExM).parent().removeClass('has-error');
    (op == 0 ? $fechaEx : $fechaExM).parent().removeClass('has-success');
    (op == 0 ? $lugarEx : $lugarExM).parent().removeClass('has-error');
    (op == 0 ? $lugarEx : $lugarExM).parent().removeClass('has-success');
    (op == 0 ? $documento : $documentoM).parent().removeClass('has-success');
    (op == 0 ? $documento : $documentoM).parent().removeClass('has-success');
    (op == 0 ? $primerN : $primerNM).parent().removeClass('has-error');
    (op == 0 ? $primerN : $primerNM).parent().removeClass('has-success');
    (op == 0 ? $segundoN : $segundoNM).parent().removeClass('has-error');
    (op == 0 ? $segundoN : $segundoNM).parent().removeClass('has-success');
    (op == 0 ? $primerA : $primerAM).parent().removeClass('has-error');
    (op == 0 ? $primerA : $primerAM).parent().removeClass('has-success');
    (op == 0 ? $segundoA : $segundoAM).parent().removeClass('has-error');
    (op == 0 ? $segundoA : $segundoAM).parent().removeClass('has-success');
    (op == 0 ? $correo : $correoM).parent().removeClass('has-error');
    (op == 0 ? $correo : $correoM).parent().removeClass('has-success');
    (op == 0 ? $contra1 : $contra1M).parent().removeClass('has-error');
    (op == 0 ? $contra1 : $contra1M).parent().removeClass('has-success');
    (op == 0 ? $contra2 : $contra2M).parent().removeClass('has-error');
    (op == 0 ? $contra2 : $contra2M).parent().removeClass('has-success');
    (op == 0 ? $huella1 : $huella1M).parent().removeClass('has-error');
    (op == 0 ? $huella1 : $huella1M).parent().removeClass('has-success');
    (op == 0 ? $huella2 : $huella2M).parent().removeClass('has-error');
    (op == 0 ? $huella2 : $huella2M).parent().removeClass('has-success');
    (op == 0 ? $huella3 : $huella3M).parent().removeClass('has-error');
    (op == 0 ? $huella3 : $huella3M).parent().removeClass('has-success');
    $('input[type="radio"]').prop("checked", false);
}
//Valida que los campos obligatorio tengan algun contenido
function validarCampos($arr) {
    var res = true;
    //Numero de documento
    var valor = $arr[0].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res = false;
    }
    //Primer nombre
    valor = $arr[1].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res = false;
    }
    //Primer apellido
    valor = $arr[2].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res = false;
    }
    //Genero
    if ($arr[3].val() === undefined) {
        res = false;
    }
    //Empresa
    if ($arr[4].val() == 0) {
        res = false;
    }
    // Huella1
    valor = $arr[5].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res = false;
    }
    // Huella2
    valor = $arr[6].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res = false;
    }
    // Huella3
    valor = $arr[7].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res = false;
    }
    //Roles
    if ($arr[8].val() == 0) {
        res = false;
    }
    //Piso
    if ($arr[9].val() == 0) {
        res = false;
    }
    // fecha de expedicion
    valor = $arr[10].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res=false;
    }
    // Lugar de expedicion
    valor = $arr[11].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res=false;
    }
    // Validar correo electonico
    valor = $arr[12].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        res=false;
    }

    return res;
}
// 
function generarReporte() {
    $.post(baseurl + 'Empleado/cEmpleado/generarExcelEmpleados', {}, function(data, textStatus, xhr) {
        console.log(xhr);
    });
}
// 
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

function marcarCamposVacios($arr) {
    // Numero de documento
    var valor = $arr[0].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[0].parent().addClass('has-error');
    } else {
        $arr[0].parent().addClass('has-success');
        $arr[0].parent().removeClass('has-error');
    }
    //Primer Nombre
    valor = $arr[1].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[1].parent().addClass('has-error');
    } else {
        $arr[1].parent().addClass('has-success');
        $arr[1].parent().removeClass('has-error');
    }
    // Primer apellido
    valor = $arr[2].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[2].parent().addClass('has-error');
    } else {
        $arr[2].parent().addClass('has-success');
        $arr[2].parent().removeClass('has-error');
    }
    // Huella 1
    valor = $arr[3].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[3].parent().addClass('has-error');
    } else {
        $arr[3].parent().addClass('has-success');
        $arr[3].parent().removeClass('has-error');
    }
    // Huella 2
    valor = $arr[4].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[4].parent().addClass('has-error');
    } else {
        $arr[4].parent().addClass('has-success');
        $arr[4].parent().removeClass('has-error');
    }
    // Huella 3
    valor = $arr[5].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[5].parent().addClass('has-error');
    } else {
        $arr[5].parent().addClass('has-success');
        $arr[5].parent().removeClass('has-error');
    }
    // Contraseña 1
    valor = $arr[6].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[6].parent().addClass('has-error');
    } else {
        $arr[6].parent().addClass('has-success');
        $arr[6].parent().removeClass('has-error');
    }
    // Contraseña 2
    valor = $arr[7].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[7].parent().addClass('has-error');
    } else {
        $arr[7].parent().addClass('has-success');
        $arr[7].parent().removeClass('has-error');
    }
    // Fecha de expedicion
    valor = $arr[8].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[8].parent().addClass('has-error');
    } else {
        $arr[8].parent().addClass('has-success');
        $arr[8].parent().removeClass('has-error');
    }
    // Lugar de expedicion
    valor = $arr[9].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[9].parent().addClass('has-error');
    } else {
        $arr[9].parent().addClass('has-success');
        $arr[9].parent().removeClass('has-error');
    }
    //Correo electronico
    valor = $arr[10].val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        $arr[10].parent().addClass('has-error');
    } else {
        $arr[10].parent().addClass('has-success');
        $arr[10].parent().removeClass('has-error');
    }
    // Piso 
    valor = $arr[11].children('option:selected').val();
    if (valor==0) {
        $arr[11].parent().addClass('has-error');
    } else {
        $arr[11].parent().addClass('has-success');
        $arr[11].parent().removeClass('has-error');
    }
}