// Variables
var $btnAccion= $('#accion');
var $selectEmpleado= $('#empleado option:checked');
var $fechaI= $('#fechaI');
var $fechaF= $('#fechaF');
var $valorTotal= $('#valorT');
var $valorEmpresa= $('#valorEmpr');
var $valorEPS= $('#valorEPS');
var $valorARL= $('#valorARL');
var $selectDiagnostico= $('#diagnostico option:checked');
var $dias= $('#diasIncapacidad');
var $descripcion= $('#descripccion');
var $tipoInc= $('#tipoIncapacidad');
var $enfermedadInc= $('#enfermedad');
var $diaInicio= $('#diaInicio');
var $diaFin= $('#diaFin');

// Calcular los valor nuevamente que se van a guardar en la base de datos...Esta pendiente

$(document).ready(function($) {
	// ...
	$btnAccion.click(function(event) {//Registrar
		if (validarFormulario()) {
			// ...
		swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: 'Se '+($btnAccion.val()==0?'Registrar':'Modificara')+' la informacion del empleado.',
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
        	if (result.value) {
        		// ...
        			$.post(baseurl+'Empleado/cIncapacidades/registrarModificarIncapacidades',
        			 {
        			 	accion: $btnAccion.val(),
        			 	idIncapacidad: $btnAccion.data('idinc'),
        			 	empleado: $('#empleado option:checked').val(),
        			 	fechaI: formatoFecha($fechaI.val()),
        			 	fechaF: formatoFecha($fechaF.val()),
        			 	valorEPS: $valorEPS.val(),
        			 	valorARL: $valorARL.val(),
        			 	valorEmpresa: $valorEmpresa.val(),
        			 	valorTotal: $valorTotal.val(),//Calcular nuevamenete el valor total en vez de agarrarlo de esta variable
        			 	diagnostico: $('#diagnostico option:checked').val(),
        			 	dias: $dias.val(),
        			 	descripcion: $descripcion.val(),
        			 	idTipoI: $tipoInc.children('option:selected').val(),
        			 	idEnf: $enfermedadInc.children('option:selected').val()
        			 }
        			 , function(data) {
        				// ...
        				if (data==1) {
        					cunsultarIncapacidades(0);
        					swal('Realizado!',('La la accion de '+($btnAccion.val()==0?'Registrar':'Modificar')+' fue realizada correctamente.'),'success');
        					limpiarFormulario();
        				}
        				// ...
        			});
        	}
        });
	  }
	});
	// ...
	$('.fecha').change(function(event) {
		($(this).data('input')==1?$diaInicio:$diaFin).val(calcularDiaDeSemana(this.value));
	});
	// Consultar Incapacidades ...
	cunsultarIncapacidades(0);
	// ...
	// Limpiar...
	$('#limpiar').click(function(event) {
		limpiarFormulario();
	});
	// ...
});

//Validar que el input solo permita caracteres numericos
function valida(e,component) {
    tecla = (document.all) ? e.keyCode : e.which;
    //Tecla de retroceso para borrar, siempre la permite
    if (tecla == 8) {//|| tecla==46
        return true;
    }
    // Patron de entrada, en este caso solo acepta numeros
    patron = /[0-9]/;
    tecla_final = String.fromCharCode(tecla);
    // if (patron.test(tecla_final)==true) {
    // 	$(component).val(new Intl.NumberFormat().format(($(component).val().replace('.','').replace(',','')+tecla_final)));
    // 	return false;
    // }
    return patron.test(tecla_final);
}

function diferencia(element,elementS,valor) {
	$(elementS).val(new Intl.NumberFormat().format((valor-(($(element).val()==''?0:$(element).val())))));
}

function cunsultarIncapacidades(id) {
	$.post(baseurl+'Empleado/cIncapacidades/consultarIncapacidades', 
		{
			idInc: id
		}, function(data) {
		var result= JSON.parse(data);
		// 
		if (id!=0) {
			// Consultar informacion de una persona en especifico
			enviarInformacionFormulario(result);
		}else{
					$('#tblIncapacidades').empty();
					$('#tblIncapacidades').html('<table class="display" id="tablaIncapacidades">'+
			                    '<thead id="cabeza">'+
			                      '<th>Documento</th>'+
			                      '<th>Empleado</th>'+
			                      '<th>TipoINC</th>'+
			                      '<th>Valor Descuento</th>'+
			                      '<th>Reintegro (EPS o ARL)</th>'+
			                      '<th>Diferencia</th>'+
			                      '<th>Dìas</th>'+
			                      '<th>Fecha Incapcidad</th>'+
			                      '<th>Acción</th>'+
			                    '</thead>'+
			                    '<tbody id="cuerpoI">'+
			                      
			                    '</tbody>'+
			                  '</table>');
			// Consultar usuarios en genarl
					$.each(result,function(index, row) {
						var descuento=seleccionarValorTotalReintegro(row);
						$('#cuerpoI').append('<tr>'+
			                               '<td>'+row.documento+'</td>'+
			                               '<td>'+row.nombre1+' '+row.nombre2+' '+row.apellido1+' '+row.apellido2+'</td>'+
			                               '<td data-idD="'+row.idTipoIncapacidad+'">'+(row.idTipoIncapacidad==1?'General':(row.idTipoIncapacidad==2?'Trabajo':'Licencia M/P'))+'</td>'+
			                               '<td>'+'$'+descuento+'</td>'+
			                               '<td>'+retornoInputs(1,row.idTipoIncapacidad,row.dias,descuento,0,row.reintegro)+'</td>'+
			                               '<td>'+retornoInputs(2,row.idTipoIncapacidad,row.dias,descuento,row.idIncapacidad,row.diferencia)+'</td>'+
			                               '<td>'+row.dias+'</td>'+
			                               '<td>'+row.fecha_incapacidad+'</td>'+
			                               '<td>'+'<button class="btn btn-success btn-xs" onclick="cunsultarIncapacidades(this.value);" value="'+row.idIncapacidad+'"><i class="fas fa-eye"></i><span></span>&nbsp;Ver</button>&nbsp;'+
			                               '<button class="btn btn-danger btn-xs" onclick="eliminarIncapacidad(this.value)" value="'+row.idIncapacidad+'"><i class="fas fa-trash-alt"></i><span></span>&nbsp;Eliminar</button>'+'</td>'+
			                             '</tr>');
					});
					// 
					$('#tablaIncapacidades').DataTable({
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
		}
	});
}

function seleccionarValorTotalReintegro(row) {
	var descuento='';
	switch(Number(row.idTipoIncapacidad)){
		case 1://general
			if (Number(row.dias)<=2) {
				descuento=row.valor_empresa;
			}else if(Number(row.dias)>2){
				descuento=row.valor_eps;
			}
		   break;
		case 2://Trabajo
			descuento=row.valor_arl;	
		    break;
		case 3://Licencia
			descuento=row.valor_eps;	
		    break;
	}
	return descuento;
}

function guardarReintegro(element) {
	// ...
	swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: 'Se actualizara el valor del reintegro y su diferencia',
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
        	if (result.value) {
        	  $.post(baseurl+'Empleado/cIncapacidades/modificarReintregoIncapacidad', 
        		{
        			idI: $(element).val(),
        			reintegro: $(element).parent('td').prev().find('input').val(),
        			diferencia: $(element).parent('td').find('input').val()
        		}, function(data) {
        		    if (data=='1') {
        			  // console.log('Realizado correctamente');
        			  swal('Realizado!','La acción fue ejecutada correctamente.s','success');
        		    }else{
        		    	swal('alerta!','Error al ejecutar la acción...','error');
        			  // console.log('Error en el reintegro');
        		    }
        		});
        	}	
        });
}

function retornoInputs(input,idTipoI,dias,descuento,idIncapacidad,valor) {
	var input1='<input type="text" value="'+(input==1?valor:'')+'" class="form-control centradotext" name="valorPagado" onkeypress="return valida(event,this)" onkeyup="diferencia(this,$(this).parent(\'td\').next().find(\'input\'),'+(descuento.replace('.',''))+');" placeholder="0" maxlength="11">';
	var input2='<input type="text" value="'+(input==2?valor:'')+'" readonly="true" class="form-control centradotext" name="diferencia" placeholder="0" maxlength="11"><button value="'+idIncapacidad+'" onclick="guardarReintegro(this)" type="button" class="btn btn-success btn-xs">Guardar</button>';
	// ...
	// switch(Number(idTipoI)){
	// 	case 1: 
	// 		if (dias>2) {
	// 			return (input==1?input1:input2);
	// 		}else{
	// 			return '';
	// 		}
	// 		break;
	// 	case 2:
	// 	case 3:
	// 	  return (input==1?input1:input2);
	// 		break;	
	// 	default:
	// 	  return '';
	// 		break;	
	// }
	 return (input==1?input1:input2);
}

function eliminarIncapacidad(id) {
		swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: 'Se eliminara esta incapacidad del empleado.',
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
        	// ...
        	if (result.value) {
        		$.post(baseurl+'Empleado/cIncapacidades/eliminarIncapacidad', 
        			{
        				idInc: id
        			}, function(data) {
        			if (data==1) {
        				swal('Realizado!','La incapacidad fue eliminada correctamente','success');
        				cunsultarIncapacidades(0);
        				limpiarFormulario();
        			}
        		});
        	}
        	// ...
        });
}

function enviarInformacionFormulario(result) {
	$.each(result,function(index, item) {
		$btnAccion.val(1);
		$btnAccion.data('idinc',item.idIncapacidad);
		$btnAccion.text('Modificar');
		$('#empleado option[value="'+item.documento+'"]').prop('selected',true);
		$('#empleado').selectpicker('refresh');
		$fechaI.val(item.fecha_incapacidad);
		$fechaF.val(item.fecha_fin_incapacidad);
		$valorTotal.val(item.valor_descuento);
		$valorEmpresa.val(item.valor_empresa);
		$valorEPS.val(item.valor_eps);
		$valorARL.val(item.valor_arl);
		$('#diagnostico option[value="'+item.idDiagnostico+'"]').prop('selected',true);
		$('#diagnostico').selectpicker('refresh');
		$dias.val(item.dias);
		$descripcion.val(item.descripcion);
		$tipoInc.children('option[value="'+item.idTipoIncapacidad+'"]').prop('selected',true);
		// Etiquetas
		switch(Number(item.idTipoIncapacidad)){
			case 1:
			$('#valorCargo').text('Valor a cargo de la EPS');
			$('#ValorEmpresa').text('Valor a cargo de la empresa');
			$('#labelPrecioTotal').text('Precio total incapacidad');
				break;
			case 2:
			case 3:
			  if (Number(item.idTipoIncapacidad)==3) {//La cubre la EPS
			  	$('#valorCargo').text('Valor a cargo de la EPS');
			  	$('#ValorEmpresa').text('Valor a cargo de la empresa');
			  }else{//La cubre el ARL
			  	$('#valorCargo').text('');
			  	$('#ValorEmpresa').text('');
			  }
			$('#labelPrecioTotal').text('Precio total incapacidad la cuabre '+(item.idTipoIncapacidad==2?'el ARL':'la EPS'));
				break;
		}
		$enfermedadInc.children('option[value="'+item.idEnfermedad+'"]').prop('selected',true);
		$('html, body').animate({scrollTop: 0}, 'slow');
		// ...
		 $diaInicio.val(calcularDiaDeSemana(item.fecha_incapacidad));//Fecha de inicio
		 $diaFin.val(calcularDiaDeSemana(item.fecha_fin_incapacidad));//Fecha fin
	});
}

function carcularDescuentoIncapacidad(dias,tipoINC) {
	var salarioBase= $('#empleado').children('option:selected').data('salariob');
	var result;
	var total=0;
	// Limpiar campos
	$valorTotal.val('');
	$valorEmpresa.val('');
	$valorEPS.val('');
	$valorARL.val('');
	// 
	switch(Number(tipoINC)){
		case 1://Incapacidad general lo cubre la EPS y la empresa dependiendo de los días de incapacidad
		// Headers de los inputs EPS y empresa
		$('#valorCargo').text('Valor a cargo de la EPS');
		$('#ValorEmpresa').text('Valor a cargo de la empresa');
		$('#labelPrecioTotal').text('Precio total incapacidad');
		if (dias<=2 && dias>=0) {
			//Valor que cubre la empresa y total
			result=(salarioBase/30)*dias;
			$valorTotal.val(new Intl.NumberFormat().format(result));
			$valorEmpresa.val(new Intl.NumberFormat().format(result));
		}else if (dias > 2){
			// Valor que cubre la empresa------------------------------------------>
			result=(salarioBase/30)*2;//SubValor que cubre la empresa
			total+=result;
			result=((salarioBase/30)*((dias-2)*0.3333));//Valor que cubre la empresa
			total+=result;
			$valorEmpresa.val(new Intl.NumberFormat().format(total));
			result=0;
			// Valor que cubre la EPS---------------------------------------------->
			result=((salarioBase/30)*((dias-2)*0.6667));//Valor que cubre la empresa
			total+=result;
			$valorEPS.val(new Intl.NumberFormat().format(result));
			// Valor total--------------------------------------------------------->
			// valor que cubre la empresa+ valor que cuebre la eps
			$valorTotal.val(new Intl.NumberFormat().format(total));
		}
			break;
		case 2://Lo cuebre completamente el ARL
		case 3://Lo cubre por completo la EPS
			// ...
			result=(salarioBase/30)*dias;
			$valorTotal.val(new Intl.NumberFormat().format(result));
			// ...
			if (Number(tipoINC)==3) {//La EPS
				$('#valorCargo').text('Valor a cargo de la EPS');
				$('#ValorEmpresa').text('Valor a cargo de la empresa');
				$valorEPS.val(new Intl.NumberFormat().format(result));
			}else{//El ARL
				$('#valorCargo').text('');
				$('#ValorEmpresa').text('');
				$valorARL.val(new Intl.NumberFormat().format(result));
			}
			// Heders del ARL o EPS
			$('#labelPrecioTotal').text('Precio total incapacidad la cuabre '+(tipoINC==2?'el ARL':'la EPS'));
			// ...
			break;
	}
	// 
}

function calcularDiferenciasFechas() {//Calcular esto antes de registrar tambien
	var diferencia;
	// ...
	if ($fechaI.val()!='' && $fechaI.val().length==10 &&$fechaF.val()!='' && $fechaF.val().length==10) {
		// Uso de la libreria moment js
		diferencia=(moment(formatoFecha($fechaF.val())).diff(moment(formatoFecha($fechaI.val())),'days'))+1;
		if ($('#empleado').children('option:selected').val()>0 && $tipoInc.find('option:selected').val()>0) {
			carcularDescuentoIncapacidad(diferencia,$tipoInc.find('option:selected').val());
		}else{
		  $valorTotal.val('');
		  $valorEPS.val('');
		  $valorEmpresa.val('');	
		}
	}else{
		diferencia='';
		$valorTotal.val('');
		$valorEPS.val('');
		$valorEmpresa.val('');
	}
	$dias.val(diferencia);
}

function limpiarFormulario() {
	$btnAccion.val(0);
	$btnAccion.data('idinc',0);
	$btnAccion.text('Realizar');
	$('#empleado').children().removeAttr('selected');
	$('#empleado option[value="0"]').attr('selected',true);
	$('#empleado').selectpicker('refresh');
	$fechaI.val('');
	$fechaF.val('');
	$valorTotal.val('');
	$valorEmpresa.val('');
	$valorEPS.val('');
	$valorARL.val('');
	$('#diagnostico').children().removeAttr('selected');
	$('#diagnostico option[value="0"]').attr('selected',true);
	$('#diagnostico').selectpicker('refresh');
	$dias.val('');
	$descripcion.val();
	$('#empleado').parent().parent().removeClass('has-error');
	$fechaI.parent().removeClass('has-error');
	$fechaF.parent().removeClass('has-error');
	$valorTotal.parent().removeClass('has-error');
	$('#diagnostico').parent().parent().removeClass('has-error');
	$dias.parent().removeClass('has-error');
	$tipoInc.parent().removeClass('has-error');
	$tipoInc.children('option[value="0"]').prop('selected',true);
	$enfermedadInc.parent().removeClass('has-error');
	$enfermedadInc.children('option[value="0"]').prop('selected',true);
	$diaFin.val('');
	$diaInicio.val('');
	$('#valorCargo').text('Valor a cargo de la EPS');
	$('#ValorEmpresa').text('Valor a cargo de la empresa');
	$('#labelPrecioTotal').text('Precio total incapacidad');
}

function validarFormulario() {
	var res=true;
	// Empleados
	if ($('#empleado option:checked').val()==0) {
		$('#empleado').parent().parent().addClass('has-error');
		res=false;
	}else{
		$('#empleado').parent().parent().removeClass('has-error');
	}
	// Fecha de inicio de la incapacidad
	if ($fechaI.val()=='') {
		$fechaI.parent().addClass('has-error');
		res=false;
	}else{
		$fechaI.parent().removeClass('has-error');
	}
	// Fecha de fin de la incapacidad
	if ($fechaF.val()=='') {
		$fechaF.parent().addClass('has-error');
		res=false;
	}else{
		$fechaF.parent().removeClass('has-error');
	}
	// Valor total a descontar por la incapacidad
	if ($valorTotal.val()=='') {
		$valorTotal.parent().addClass('has-error');
		res=false;
	}else{
		$valorTotal.parent().removeClass('has-error');
	}
	// Diagnostico
	if ($('#diagnostico option:checked').val()==0) {
		$('#diagnostico').parent().parent().addClass('has-error');
		res=false;
	}else{
		$('#diagnostico').parent().parent().removeClass('has-error');
	}
	// Dias de la incapacidad
	if ($dias.val()=='') {
		$dias.parent().addClass('has-error');
		res=false;
	}else{
		$dias.parent().removeClass('has-error');
	}
	// Tipo de incapacidad
	if ($tipoInc.children('option:selected').val()==0) {
		$tipoInc.parent().addClass('has-error');
		res=false;
	}else{
		$tipoInc.parent().removeClass('has-error');
	}
	// Enfermedad
	if ($enfermedadInc.children('option:selected').val()==0) {
		$enfermedadInc.parent().addClass('has-error');
		res=false;
	}else{
		$enfermedadInc.parent().removeClass('has-error');
	} 

	return res;
}

//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}