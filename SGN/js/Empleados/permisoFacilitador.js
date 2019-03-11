// Variables
var $tablaPermisos = $('#tblPermisosEmpelado');
var $tablaPermisosFecha = $('#tblPermisosEmpeladoFecha');
var $btnActualizarPermisos = $('#btnActualizarInfoPermiso');
var $btnConsultarPermisoFecha = $('#btnConsultarFechas');
var $editarModal = $('#visualizarPermiso');

// Formulario editar permiso
var $clasificado = $('#clasificado');
var $fechaSolicitud = $('#fechaSolicitud');
var $fechaPermiso = $('#fechaPermiso');
var $concepto = $('#concepto');
var $desde = $('#desde');
var $momento = $('#momento');
var $hasta = $('#hasta');
var $numeroHoras = $('#numeroHoras');
var $descripcion = $('#descripcion');
// 
var $fechaInicioPermiso = $('#fechaI');
var $fechaFinPermiso = $('#fechaF');

$(document).ready(function() {
// Consulta los permisos de los empleados
consultarPermisosEmpelados();

// 
setInterval('consultarPermisosEmpelados()',20000);//Se actualiza cada 20 segundos

// Consultar Permisos por rango de fechas
$btnConsultarPermisoFecha.click(function(event) {
	if ($fechaInicioPermiso.val()!='') {
		$.post(baseurl+'Empleado/cPermiso/consultarPermisoEmpleadoRangoFechas', 
			{
				fechaI: formatoFecha($fechaInicioPermiso.val()),
				fechaF:  ($fechaFinPermiso.val()!=''?formatoFecha($fechaFinPermiso.val()):''),
				documento: ''
			}, function(data){
			var result = JSON.parse(data);
			// ...
			crearTablaPermisos($tablaPermisosFecha,result,0);
		});
	}else{
		swal('Alerta!','Debe seleccionar minimo una fecha.','warning');
	}
});

// Modificar información del permiso 
$btnActualizarPermisos.click(function(event) {//Falta realizar la validacion de campos
	if ($fechaPermiso.val()!='' && $concepto.find('option:selected').val()!=0 && $momento.find('option:selected').val()!=0 && $desde.val()!='') {
		swal({ //Mensaje de confirmacion para realizar la accion.
		    title: '¿Estas seguro?',
		    text: "Se actualizara la información de este permiso.",
		    type: 'warning',
		    showCancelButton: true,
		    confirmButtonColor: '#3085d6',
		    cancelButtonColor: '#d33',
		    confirmButtonText: 'Si'
		}).then((result) => {
			if (result.value) {
				var fechaPermiso= formatoFecha($fechaPermiso.val()); 
				// Valida que la fecha del permiso ingresada no sea menor a la fecha actual del sistema.
				$.post(baseurl + 'Empleado/cPermiso/validarFechaPermiso', {
				    fecha: fechaPermiso
				}, function(data) {
					// Valida que no tenga ningun permiso registrado para esa fecha
					if (data==1) {
						$.post(baseurl+'Empleado/cPermiso/registrarPermisosEmpleado', 
							{
								idP: $btnActualizarPermisos.val(),
								documento: '',
								fechaPermiso: fechaPermiso,
								concepto: $concepto.find('option:selected').val(),
								momento: $momento.find('option:selected').val(),
								horaDesde: generarHoraValida($desde.val()),
								des: $descripcion.val()
							}, function(data) {
								if (data==1) {
									// ...
									estadoInicialFormulario();
									$editarModal.modal('hide');
									setTimeout(function () {
										swal('Realizado!','El permiso fue modificado correctamente.','success');
									},400);
								}else{
									swal('Alerta!','Ocurrio un error en la ejecucion de la acción.','error');
								}
						});				
					}else{
						swal('Alerta!', 'La fecha del permiso no puede ser menos a la fecha de hoy.', 'warning');
					}
				});
			}
		});
	}else{
		swal('Alerta!','Falta algun campo por diligenciar.','warning');
	}
}); 

// Time picker
$('.timepicker').timepicker({
    minuteStep: 1,
    template: 'modal',
    appendWidgetTo: 'body',
    showSeconds: true,
    showMeridian: false,
    defaultTime: false
});
// ...
});

// ...
function generarHoraValida(hora) {
    var partes = hora.split(':');
    var res = (partes[0].length == 1 ? '0' : '') + partes[0] + ':' + partes[1] + ':' + partes[2];
    return res;
}

function consultarPermisosEmpelados() {
    $.post(baseurl + 'Empleado/cPermiso/consultarPermisoEmpelado', {
        documento: ''
    }, function(data) {
        var result = JSON.parse(data);
        // ...
        crearTablaPermisos($tablaPermisos,result,1);
    });
}

function crearTablaPermisos($espaceTabla,result,accion) {
	// Crear Tabla
	$espaceTabla.empty();
	// html de la Tabla se empelados
	$espaceTabla.html('<table class="display" id="'+(accion==1?'EmpleadoPermiso':'EmpleadoFechaPermiso')+'">' + '<thead>' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Fecha Permiso</th>'+ '<th>Usuario</th>' + '<th>Concepto</th>' + '<th>Momento</th>' + '<th>Desde</th>' + '<th>Estado</th>'+ '<th>Clasificar</th>'+ '<th>Acción</th>' + '</thead>' + '<tbody id="'+(accion==1?'cuerpoP':'cuerpoF')+'">' + '</tbody>' + '</table>');
	var $cuerpo = $('#'+(accion==1?'cuerpoP':'cuerpoF'));
	$.each(result, function(index, row) {
            $cuerpo.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.fecha_permiso + '</td>' + '<td>'+(row.usuario!=null?row.usuario:'')+'</td>' + '<td>' + row.concepto + '</td>' + '<td>' + row.momento + '</td>' + '<td>' + row.desde + '</td>' + '<td>' + tagEstado(row.estado) + '</td>'+
             '<td>' + ((row.estado==3 || row.estado==4)?'':'<select data-idpermiso="'+row.idPermiso+'"class="form-control" onchange="cambiarEstadoPermisoEmpleado(this);">'+
 						'<option value="0">Pendiente</option>'+
 						'<option value="1">Aprobar</option>'+
 						'<option value="2">Rechazar</option>'+
					'</select>')
 					+ '</td>'+'<td>'+((row.estado==3 || row.estado==4)?'<button type="button" value="'+row.idPermiso+'" class="btn btn-success btn-xs"  onclick="mostrarModalEditar(this.value,\''+row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2+'\',0);"><span><i class="fas fa-eye"></i></span> Ver</button>':'<button type="button" value="'+row.idPermiso+'" onclick="mostrarModalEditar(this.value,\''+row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2+'\',1);" class="btn btn-primary btn-xs"><span><i class="fas fa-edit"></i></span> Editar</button>')+'</td>' + '</tr>');
            // Seleccionar el estado que tiene.
            $('#'+(accion==1?'EmpleadoPermiso':'EmpleadoFechaPermiso')+' tbody tr td select').last().find('option[value="'+row.estado+'"]').prop('selected', true);	// body...
	});
	// Inicializacion de datatable
	$('#'+(accion==1?'EmpleadoPermiso':'EmpleadoFechaPermiso')).DataTable();
}

function mostrarModalEditar(idPermiso,nombre,accion) {
	$editarModal.modal('show');
	consultarConceptos($('#concepto'),idPermiso,accion);
	// ...
	$('#hPermiso').html('Permiso: <b>'+nombre+'</b> <small>Editar</small>');
	// ...
}

function consultarInformacionPermisoEmpleado(idPermiso,accion) {
	// Consultar Informacion del permiso para editarlo
	$.post(baseurl+'Empleado/cPermiso/consultarPermisoEmpleadoEditar', {idP: idPermiso}, function(data) {
		var result= JSON.parse(data);
		// ...
		$.each(result, function(index, row) {
			$clasificado.val(row.usuario);
			$fechaSolicitud.val(row.fecha_solicitud);
			$fechaPermiso.val(row.fecha_permiso);
			$concepto.find('option[value="'+row.idConcepto+'"]').prop('selected',true);
			$concepto.selectpicker('refresh');
			$desde.val(row.desde);
			$momento.find('option').removeProp('selected');
			$momento.find('option[value="'+row.idHorario_permiso+'"]').prop('selected',true);
			$momento.selectpicker('refresh');
			$hasta.val(row.hasta);
			$numeroHoras.val(row.numero_horas);
			$descripcion .val(row.descripcion);
			$btnActualizarPermisos.val(row.idPermiso);
			$btnActualizarPermisos.data('documento',row.documento);
		});
		// 
		if (accion==0) {
			$btnActualizarPermisos.hide();
		}else{
			$btnActualizarPermisos.show();
		}
	});
}

function cambiarEstadoPermisoEmpleado(element) {
	// console.log(element);
	swal({ //Mensaje de confirmacion para realizar la accion.
	    title: '¿Estas seguro?',
	    text: "Se cambiara el estado de este permiso",
	    type: 'warning',
	    showCancelButton: true,
	    confirmButtonColor: '#3085d6',
	    cancelButtonColor: '#d33',
	    confirmButtonText: 'Si'
	}).then((result) => {
		if (result.value) {
			// Cambiar el estado del permiso del empleado.
			$.post(baseurl+'Empleado/cPermiso/cambiarEstadoPermisoEmpleado', 
				{
					idP: $(element).data('idpermiso'),
					estado: $(element).find('option:selected').val()
				}, function(data) {
				if (data==1) {
					swal('Realizado!','El estado del permiso fue cambiado correctamente.','success');
					consultarPermisosEmpelados();
				}else{
					swal('Alerta!','Ocurrio un error en la ejecucion de la acción.','error');
				}
			});
		}
	});
}

function estadoInicialFormulario() {
	// Consulta los permisos de los empleados
	consultarPermisosEmpelados();
	//...
	$clasificado.val();
	$fechaSolicitud.val();
	$fechaPermiso.val();
	$concepto.val();
	$desde.val();
	$momento.val();
	$hasta.val();
	$numeroHoras.val();
	$descripcion.val();
}

function tagEstado(estado) {
    var mensaje = '';
    switch (Number(estado)) {
        case 1: //Aprobado
            mensaje = '<span><small class="label bg-blue">Aprobado</small></span>';
            break;
        case 2: //Rechazado
            mensaje = '<span><small class="label bg-red">Rechazado</small></span>';
            break;
        case 3: //Terminado
            mensaje = '<span><small class="label bg-green">Terminado</small></span>';
            break;
        case 4: //Ejecucion
            mensaje = '<span><small class="label bg-orange">Ejecución</small></span>';
            break;
        case 0: //Pendiente
            mensaje = '<span><small class="label bg-yellow">Pendiente</small></span>';
            break;
    }
    return mensaje;
}