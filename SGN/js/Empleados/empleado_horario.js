// Horarios configuración
var $horarioEmpleadoM = $('#horario_configuracion');
var $btnAgregar = $('#btnAgregarHorario');
var $limpiarForm = $('#limpiarForm');
var $cbxDiaInicio = $('#diaInicio');
var $cbxDiaFin = $('#diaFin');
var $tblHorariosEmpleado= $('#tblEmpeladoHorario');
// ....
$(document).ready(function() {
	// 
	$btnAgregar.click(function(event) {
		if (validarCamposObligatorios()) {
			registrarModificarHorarioEmpleado($(this).val(),$(this).data('id'));
		}else{
			// Mensaje de alerta
			swal('Alerta!','Falta algun campo obligatorio por diligenciar.','warning');
		}
	});
	// Evento del modal hidden.bs.modal Pendiente
	$('#empleadoHorario').on('hidden.bs.modal', function(event) {
		limpiarCampos();
	});
	//Limpiar
	$limpiarForm.click(function(event) {
		limpiarCampos();
	}); 
});

function validarCamposObligatorios() {
	var res = true;
	//Horario
	if ($horarioEmpleadoM.find('option:selected').val()==0) {
	    res = false;
	    $horarioEmpleadoM.parent('div').addClass('has-error');
	}else{
		$horarioEmpleadoM.parent('div').removeClass('has-error');
	}
	// Dia inicio de horario
	if ($cbxDiaInicio.find('option:selected').val()==-1) {
	    res = false;
	    $cbxDiaInicio.parent('div').addClass('has-error');
	}else{
		$cbxDiaInicio.parent('div').removeClass('has-error');
	}
	return res;
}

// ...
function mostrarModarHorariosConfiguracion(idEmp) {
    $btnAgregar.val(idEmp);
    consultarHorariosEmpleados(idEmp);
    consultarConfiguracionesHorario();
    $('#empleadoHorario').modal('show');
}
// ...
// Se encarga de consultar la configuracion de los horarios que la empresa tiene registrados para viancular a los empleados
function consultarConfiguracionesHorario() {
    $.post(baseurl+'Empleado/cConfiguracion/consultarConfiguracion',{ID: -1}, function(data) {
        var result=JSON.parse(data);
        // ...
        $horarioEmpleadoM.empty();
        $horarioEmpleadoM.append('<option value="0">Seleccione...</option>');
        // ...
        $.each(result, function(index, confi) {
            // Select de configuraciones de horarios.
            $horarioEmpleadoM.append('<option value="'+confi.idConfiguracion+'">'+confi.nombre+'</option>');
        });
    });
}

function registrarModificarHorarioEmpleado(doc,id) {
	swal({ //Mensaje de confirmacion para realizar la accion.
	    title: '¿Estas seguro?',
	    text: id == 0 ? "Se registrara un empleado nuevo al sistema" : "Se modificara la informacion de este empleado.",
	    type: 'warning',
	    showCancelButton: true,
	    confirmButtonColor: '#3085d6',
	    cancelButtonColor: '#d33',
	    confirmButtonText: 'Si'
	}).then((result) => {
		if (result.value) {
			$.post(baseurl+'Empleado/cEmpleado_horario/registrarModificarEmpleadoHorario',
			 {
			 	idD: Number(id),
			 	documento: doc,
			 	con: $horarioEmpleadoM.find('option:selected').val(),
			 	diaI: $cbxDiaInicio.find('option:selected').val(),
			 	diaF: $cbxDiaFin.find('option:selected').val()
			 }, function(data) {
				// ...
				if (data==1) {
					swal('Realizado!','La accion fue realizada correctamente.','success',{buttons:false, timer:2000});
				    limpiarCampos();
					consultarHorariosEmpleados(doc);
				}else{
				    swal('Error!','Ocurrio un error en la ejecución.','error',{buttons:false, timer:2000});	
				}
			});
		}
	});
}

function consultarHorariosEmpleados(doc) {
	$.post(baseurl+'Empleado/cEmpleado_horario/consultarNombreEmpelado', {documento: doc}, function(name) {//Nombre empleado
		// ...
		$('#nameEmpleado').text(name);
		// ...
			$.post(baseurl+'Empleado/cEmpleado_horario/consultarEmpleadoHorario', {documento: doc, id:0}, function(data) {
				// ...
				var result= JSON.parse(data);
				// ...
				$tblHorariosEmpleado.empty();
				// 
				$tblHorariosEmpleado.html('<table class="display" id="horarioEmpledoTable">' + 
					                         '<thead id="cabeza">' + 
					                            '<th>Horario</th>' + 
					                            '<th>Fecha Inicio</th>' + 
					                            '<th>Fecha Fin</th>' + 
					                            '<th>Día Inicio</th>' + 
					                            '<th>Día Fin</th>' + 
					                            '<th>Estado</th>' + 
					                            '<th>Acciones</th>' + 
					                          '</thead>' + '<tbody id="cuerpoHE">' + '</tbody>' + '</table>');
				// ...
				var $cuerpo = $('#cuerpoHE');
				var i=0;
				// ...
				$.each(result, function(index, row) {
					// ...
					$cuerpo.append('<tr>'+
									'<td>'+row.nombre+'</td>'+
									'<td>'+row.fechaInicio+'</td>'+
									'<td>'+(row.fechaFin==null?'-':row.fechaFin)+'</td>'+
									'<td>'+diaSemanaHorario(row.diaInicio)+'</td>'+
									'<td>'+diaSemanaHorario(row.diaFin)+'</td>'+
									'<td>'+clasificarEstado(row.estado)+'</td>'+
									'<td>'+ 
									    '<button value="' + row.idEmpleado_horario + '" onclick="enviarInfoDetalleHorarioEmpleado(this.value,\''+doc+'\')"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button>'+
									    '&nbsp;<button value="' + row.idEmpleado_horario + '" type="button"' + clasificarBoton(row.estado,0,doc) + '</span></button>'+
									'</td>'+
								  '</tr>');
				});
				// ...
				$('#horarioEmpledoTable').DataTable({
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
			});
	});
}

function diaSemanaHorario(dia) {
	if (dia!=-1) {
	 	var dias=["Domingo", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"];
		return dias[dia];
	}else{
		return '-';
	}
}

function cambiarEstadoHorarioEmpleado(idHE,doc) {
	swal({ //Mensaje de confirmacion para realizar la accion.
	    title: '¿Estas seguro?',
	    text: "Se cambiara el estado del horario del empleado.",
	    type: 'warning',
	    showCancelButton: true,
	    confirmButtonColor: '#3085d6',
	    cancelButtonColor: '#d33',
	    confirmButtonText: 'Si'
	}).then((result) => {
		if (result.value) {
			$.post(baseurl+'Empleado/cEmpleado_horario/cambiarEstadoEmpleadoHorario',
			 {
			 	idD: idHE,
			 	documento: doc
			 }, function(data, textStatus, xhr) {
				if (data==1) {
					swal('Realizado!','Se cambio el estado del horario del empleado.','success',{buttons:false,timer:2000});
					consultarHorariosEmpleados(doc);
				}else{
					swal('Alerta','Error al realizar esta acción.','error',{buttons:false,timer:2000});
				}
			});
		}
	});
}

function enviarInfoDetalleHorarioEmpleado(idD,documento) {
	$.post(baseurl+'Empleado/cEmpleado_horario/consultarEmpleadoHorario', {documento: documento, id:idD}, function(data) {
		/*optional stuff to do after success */
		var result=JSON.parse(data);
		// console.log(data);
		$cbxDiaInicio.find('option').removeProp('selected');
		$cbxDiaFin.find('option').removeProp('selected');
		$horarioEmpleadoM.find('option').removeProp('selected');
		// ...
		$btnAgregar.addClass('btn-warning');
		$btnAgregar.data('id', idD);
		$btnAgregar.find('div').text('Actualizar');
		// ...
		$.each(result, function(index, row) {
			$horarioEmpleadoM.find('option[value="'+row.idConfiguracion+'"]').prop('selected',true);
			$cbxDiaInicio.find('option[value="'+row.diaInicio+'"]').prop('selected',true);
			$cbxDiaFin.find('option[value="'+row.diaFin+'"]').prop('selected',true);
		});
	});
}

function limpiarCampos() {
	$cbxDiaInicio.find('option').removeProp('selected');
	$cbxDiaFin.find('option').removeProp('selected');
	$horarioEmpleadoM.find('option').removeProp('selected');
	consultarConfiguracionesHorario();
	$btnAgregar.removeClass('btn-warning');
	$btnAgregar.data('id', 0);
	$btnAgregar.find('div').text('Agregar');
    $cbxDiaInicio.find('option[value="-1"]').prop('selected',true);
    $cbxDiaFin.find('option[value="-1"]').prop('selected',true);
    $cbxDiaInicio.find('option[value="-1"]').removeProp('selected');
    $cbxDiaFin.find('option[value="-1"]').removeProp('selected');
    $horarioEmpleadoM.parent('div').removeClass('has-error');
    $cbxDiaInicio.parent('div').removeClass('has-error');
}