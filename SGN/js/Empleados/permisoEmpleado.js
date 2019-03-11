// SE_FU_ValidacionPermisosEmpleadosAsistencia Modificar cuando se termine este modulo
// Variables
var $fechaSolicitud = $('#fechaSolicitud');
var $fechaPermiso = $('#fechaPermiso');
var $solicitantes = $('#solicitante');
var $concepto = $('#concepto');
var $momento = $('#momento');
var $descripcion = $('#descripcion');
var $hora = $('#horaPermiso');
var $btnRealizar = $('#realizarP');
var $btnConsultar = $('#consultarPer');
var $documento = $('#documento');
var $documentoP = $('#documentoPermiso');
var $password = $('#pwd');
var $content = $('#otrasCausas');
// Modal's
var $modalRealizar = $('#ConfirmarPermiso');
var $modalConsultar = $('#consultarPermisosE');
var $btnTerminarPermiso = $('#terminarPermiso');
var $btnConsultarPermisos = $('#conPermiso');
var $tblPermisosModal = $('#tblPermisosEmpleado');
$content.toggle(1);
// ...
$(document).ready(function() {
    // Consultar Empleados solicitantes de permiso...
    consultarEmpleados();
    // Consultar conceptos de los permisos...
    consultarConceptos($concepto,0);
    // Consultar Fecha de solicitud del permiso
    consultarFechaSolicitudPermisos();
    //Cuando se seleccione el concepto de otra causa mostrara el campo de descripcion obligatorio.
    $concepto.change(function(event) {
        if ($(this).val() == 7) {
            $content.toggle(400);
        } else {
            $content.hide(450);
        }
    });
    // Inicializar timepiker
    $('.tiempos').timepicker({
        minuteStep: 5,
        showInputs: false,
        disableFocus: true
    });
    //Mostrar modals-----------------------------------------------------------------------------
    // Modal de realizar permiso
    $btnRealizar.click(function(event) {
    	if ($fechaPermiso.val()!='' && $concepto.find('option:selected').val()!=0 && $momento.find('option:selected').val()!=0 && $hora.val()!='') {
    		$modalRealizar.modal('show');
    	}else{
	        swal('Alerta!','Falta algun campo por diligenciar.','warning');
    	}
    });
    //Limpiar Modal
    $modalRealizar.on('hidden.bs.modal', function(event) {
        $documento.val('');
        $password.val('');
    });
    // Modal de consultar permisos
    $btnConsultar.click(function(event) {
        $modalConsultar.modal('show');
    });
    // Acciones de la vista permisos de los empleados
    $btnConsultarPermisos.click(function(event) {
    	if ($documentoP.val()!='') {
    		$.post(baseurl + 'Empleado/cPermiso/consultarPermisoEmpelado', {
    		    documento: $documentoP.val()
    		}, function(data) {
    		    var result = JSON.parse(data);
    		    // Crear Tabla
    		    $tblPermisosModal.empty();
    		    // html de la Tabla se empelados
    		    $tblPermisosModal.html('<table class="display" id="EmpeladosPermiso">' + 
    		    							'<thead id="cabeza">' + 
    		    								'<th>Nombre</th>' + 
    		    								'<th>Fecha Permiso</th>' + 
    		    								'<th>Concepto</th>' + 
    		    								'<th>Momento</th>' + 
    		    								'<th>Desde</th>' +
    		    								'<th>Estado</th>' +
    		    							'</thead>' + 
    		    							'<tbody id="cuerpo">' + 
    		    							'</tbody>' + '</table>');
    		    var $cuerpo = $('#cuerpo');
    		    $.each(result, function(index, row) {
    		        $cuerpo.append('<tr>' + 
    		        					'<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + 
    		        					'<td>' + row.fecha_permiso+ '</td>' + 
    		        					'<td>' + row.concepto + '</td>' + 
    		        					'<td>' + row.momento + '</td>' + 
    		        					'<td>' + row.desde + '</td>' + 
    		        					'<td>' + tagEstado(row.estado) + '</td>' + '</tr>');
    		    });
    		    // Inicializacion de data table
    		    $('#EmpeladosPermiso').DataTable();
    		});
    	}else{
    		swal('Alerta!','Por favor ingresa un documento.','warnign');
    	}
    });
    // Validar que los campos obligatorios esten completos
    $btnTerminarPermiso.click(function(event) {
        if ($documento.val() != '' && $password.val() != '') {
            if ($documento.val() == $solicitantes.find('option:selected').val()) {
                swal({ //Mensaje de confirmacion para realizar la accion.
                    title: '¿Estas seguro?',
                    text: "Se registrara el permiso...",
                    type: 'info',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Si'
                }).then((result) => {
                    if (result.value) {
                        // Validar lka existencia del usuario.
                        $.post(baseurl + 'Empleado/cPermiso/validarUsuario', {
                            documento: $documento.val(),
                            password: $password.val()
                        }, function(data) {
                            if (data == 1) {
                                var fechaFormato = formatoFecha($fechaPermiso.val());
                                // Valida que la fecha del permiso ingresada no sea menor a la fecha actual del sistema.
                                $.post(baseurl + 'Empleado/cPermiso/validarFechaPermiso', {
                                    fecha: fechaFormato
                                }, function(data) {
                                    if (data == 1) {
                                        // Valida que no tenga ningun permiso registrado para esa fecha
                                        $.post(baseurl + 'Empleado/cPermiso/validarExistenciaPermisoFecha', {
                                            doc: $documento.val(),
                                            fecha: fechaFormato
                                        }, function(data) {
                                            if (data == 0) {
                                                // Registrar la informacion del permiso
                                                $.post(baseurl + 'Empleado/cPermiso/registrarPermisosEmpleado', {
                                                    idP: 0,
                                                    documento: $solicitantes.find('option:selected').val(),
                                                    fechaPermiso: fechaFormato,
                                                    concepto: $concepto.find('option:selected').val(),
                                                    momento: $momento.find('option:selected').val(),
                                                    horaDesde: convertidorHoraFormato24($hora.val()),
                                                    des: $descripcion.val()
                                                }, function(data) {
                                                    //... 
                                                    if (data == 1) {
                                                        estadoInicialFormulario();
                                                        setTimeout(function(argument) {
                                                            $modalRealizar.modal('hide');
                                                            swal('Realizado!', 'El permiso fue registrado correctamente.', 'success');
                                                        }, 300);
                                                    } else {
                                                        swal('Alerta!', 'Ocurrio un error al momento de ejecutar esta acción.', 'error');
                                                    }
                                                    //...
                                                });
                                            } else {
                                                swal('Alerta!', 'Ya tienes un permiso registrado para este día.', 'warning');
                                            }
                                        });
                                    } else {
                                        swal('Alerta!', 'La fecha del permiso no puede ser menos a la fecha de hoy.', 'warning');
                                    }
                                });
                            } else {
                                swal('Alerta!', 'El ususario o la contraseña son incorrectos.', 'error');
                            }
                        });
                    }
                });
            } else {
                swal('Alerta!', 'El usuario no corresponde al documento de identidad ingresado.', 'warning');
            }
        } else {
            swal('Alerta!', 'Falta algun campo por diligenciar.', 'warning');
        }
    });
});

function tagEstado(estado) {
	var mensaje='';
	switch(Number(estado)){
		case 1://Aprobado
			mensaje='<span><small class="btn btn-primary tamañoEstado">Aprobado</small></span>';
			break;
		case 2://Rechazado
			mensaje='<span><small class="btn btn-danger tamañoEstado">Rechazado</small></span>';
			break;
		case 3://Terminado
			mensaje='<span><small class="btn btn-success tamañoEstado">Terminado</small></span>';
			break;
		case 0://Pendiente
			mensaje='<span><small class="btn btn-warning tamañoEstado">Pendiente</small></span>';
			break;
	}
	return mensaje;
}

function estadoInicialFormulario() {
    // Consultar Empleados solicitantes de permiso...
    consultarEmpleados();
    // Consultar conceptos de los permisos...
    consultarConceptos($concepto,0);
    // Consultar Fecha de solicitud del permiso
    consultarFechaSolicitudPermisos();
    // Limpiar campos
    $fechaPermiso.val('');
    $descripcion.val('');
    $content.hide();
}
// Consulta la fecha del sistema
function consultarFechaSolicitudPermisos() {
    $.post(baseurl + 'Alimentacion/cPedidos/consultarFechaPedido', function(data) {
        var fecha = JSON.parse(data);
        $fechaSolicitud.text(fecha);
    });
}
// Consulta todos los empleados de la empresa con un estado Activo
function consultarEmpleados() {
    $.post(baseurl + 'Empleado/cEmpleado/consultarEmpleados', {
        doc: ''
    }, function(data) {
        var result = JSON.parse(data);
        $solicitantes.empty();
        $solicitantes.append('<option value="0" >Seleccione...</option>'); //
        // console.log(result);
        $.each(result, function(index, row) {
            $solicitantes.append('<option data-subtext="' + row.documento + '" value="' + row.documento + '">' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</option>');
        });
        $solicitantes.selectpicker('refresh');
    });
}