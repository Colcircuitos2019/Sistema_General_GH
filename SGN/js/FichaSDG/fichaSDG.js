// Variables Relacionadas Con el modal!!
var $solicitante=$('#solicitante');
var $btnEmpleados= $('#btnEmpleados');
var $modalEmpelado=$('#empleados');
var $btnEnviarInfo= $('#enviarE');
// ...
// Variables Relacionada con los campos de informacion del empleado del formulario.
var $CedulaE=$('#txtCedula'); 
var $PrimerN=$('#txtPrimerNombre'); 
var $SegundoN=$('#txtSegundoNombre'); 
var $PrimerA=$('#txtPrimerApellido'); 
var $SegundoA=$('#txtSegundopellido');
var $generoE=$('#genero');
var $btnAccion=$('#accionCRUD'); 

// Variables de la informacion del estado empresarial
var $idEstadoEmpresarial= $('#idEstadoL');
var $fechaRetiro= $('#fechaRT');
var $fechaIngresoEmpresa= $('#fechaIT');
var $EstadoE= $('#estadoSDG');
var $Vinculacion= $('#cbxVinculacion');
var $motivo=$('#motivoE');
var $rotacion= $('#indRotacion');
var $obsRetiro= $('#descripR');
var $empresas= $('#empresas');
var $grupoBTN= $('#grupoBtn');
var $addButton= $('#newButtons');
var $saveButton= $('#guardarEstado');
var $deletButton= $('#deletButtons');
var $antiguedadE= $('#tiempoAntiguedad');
var vEstadosEm=[];

// Variables de la informacion salarial
var $cbxPromedioSalario = $('#promSalarial');
var $cbxClasificadionM = $('#clasiMega');
var $salarioBase= $('#salarioBasico');
var $cbxAuxilios = $('#auxilios');
var $total= $('#salTotal');
var $canAuxilios= $('#monstosAux');

//Variables de la informacion de los estudios
var $cbxEstudios = $('#gradoEscolaridad');
var $tituloProfecional = $('#tituloProfecional');
var $tituloEspecializacion = $('#especializacion');
var $estudiaA= $('#EstudiosActuales');
var $cbxEstudiando= $('#gradoEstudiando');
var $nameCarrer=$('#nameCarrera');


// Variables de la informacion laboral
var $cbxHorarioT = $('#horaTrabajo');
var $cbxAreaTrabajo = $('#areaTrabajo');
var $cbxCargoL = $('#cargo');
var $cbxTipoContrato = $('#tipoContrato');
var $fechaVC= $('#fechaVC');
var $recursoH= $('#recursoH');
var $empresaContratante = $('#empresaCont');
var $clasificacionC= $('#clasificacionContable');
// var $fechaIngreso= $('#fechaIngreso');

// Variables de la informacion secundaria basica
var $cbxEstadoCivil = $('#estadoCivil');
var $fechaNacimientoE = $('#fechaNacimiento');
var $Lugarnacimiengo = $('#lugarNaci');
var $tipoSangre = $('#tipoSangre');
var $telefonoFijo = $('#telefonoFijo');
var $telefonoCelular = $('#telefonoCelular');
var $cbxEPS = $('#EPS');
var $cbxAFP = $('#AFP');

// Variables de la informacion de la salud
var $fuma = $('#fumar');
var $NCigarrillos = $('#NCigarrillos');
var $bebidasACL = $('#alcoholicas');
var $cbxFrevuenciaB = $('#frecuenciaAlcohol');
var $AnteUnaEmergencia = $('#AntEmergencia');

//Variables de la informacion personal
var $cbxActividadesTiempoLibre = $('#actividadesLibres');
var $otrasActividades = $('#otraActividad');
// Otras partes de la direccion
var $cbxOpt1 = $('#opt1');//Select
var $opt2 = $('#opt2');//
var $opt3 = $('#opt3');//
var $opt4 = $('#opt4');//
var $cbxOpt5 = $('#opt5');//Select
var $opt6 = $('#opt6');//
// ...
var $barrio = $('#barrio');
var $comuna = $('#comuna');
var $cbxMunicipio = $('#municipio');
var $estrato = $('#estrato');
var $email = $('#mail');
var $madre = $('#madre');
var $padre = $('#padre');
var $compañeroP = $('#compañeroP');
var $nombreAcompañante = $('#acompañanteName');
var $celularAcompañante = $('#celularAcompañante');
var $abuelos = $('#abuelos');
var $tios = $('#tios');
var $hermanos = $('#hermanos');
var $otros = $('#otros');
var $hijos = $('#hijos');
var $hijastros = $('#hijastro');
var $personaEmergencia = $('#personaEmergencia');
var $tipoVivienda = $('#tipoVivienda');
var $parentezco = $('#CasoEParentezco');
var $altura = $('#altura');
var $peso = $('#peso');
var $telEm= $('#telefonoEM');

// Variables de otra informacion
var $TCamisa = $('#tallaCamisa');
var $TPantalon = $('#tallaPantalon');
var $Tzapatos = $('#tallaZapatos');
var $VCursoAlturas = $('#vigenciAlturas');
var $RquierecursoAlturas = $('#RequiereCursoAlturas');
var $PBrigadaEmergencia = $('#pertenceBrigada');
var $AlgunComite = $('#AlgunComite');
// 
var idEstudios=0;
var idLaboral=0;
var idSalud=0;
var idInfoOtra=0;
var idPersonal=0;
var idSecundariaB=0;
var idSalarial=0;
// 
var IDsActividades=[];//Este vecto me va ayudar a la hora de modificar identificar que actividad nueva se añadio o se quito de la lista multiple.
var IDPersonasVive=[];//Este vector me va a permitir cargar los id de todas las personas con las que vive.
var TextAux=[];
var $generarPDF= $('#pdf');
var $exportarXLSX = $('#exportar');
// DOM
$(document).ready(function() {
    
    $generarPDF.click(function(event) {
       window.open(baseurl+'FichaSDG/cFichaE/reporteFichaSDGEmpleado?doc='+$CedulaE.val());
    });

    $exportarXLSX.click(function(event) {
       window.open(baseurl+'FichaSDG/cFichaE/exportarXLSX1');
    });

    window.onbeforeunload= preguntarAntesDeSalir;

    function preguntarAntesDeSalir() {
        return "¿Seguro que quierese salir?";
    }

     $motivo.change(function(event) {//Renuncia y abandono de trabajo nunca se pueden modificar su ID para la funcion de este sistema de información
        if ($(this).children('option:selected').val()==1 || $(this).children('option:selected').val()==4) {
            $('#impacto').show('slow');
        }else{
            $('#impacto').hide('slow');
        }
     });

    $('#formImportar').submit(function(event) {
        event.preventDefault();
        $.ajax({
            url: baseurl+'FichaSDG/cFichaE/importarXLSX',
            type: 'POST',
            data: new FormData(this),
            cache:false,
            contentType: false,
            processData: false,
            beforeSend:function () {
                $('#formImportar').append('<img src="'+baseurl+'img/loader-small.gif" alt="loading"/>');
            }
        }).fail(function(data) {
            // Al importar el documento ocurrio un error
           console.log(data);
           $('#formImportar').children('img').remove();
           $('#formImportar').children('img').remove();
           swal('Alerta','No se pudo cargar el documento','warning',{buttons:false,timer:2000});
           // 
        }).done(function (data) {
            $('#file').val('');
            // console.log(data);
            $('#formImportar').children('img').remove();
            if (data==-1) {
                swal('Alerta','No se pudo cargar el documento','warning',{buttons:false,timer:2000});
            }else{
                swal('Realizado','El documento excel fue cargado correctamente','success',{buttons:false,timer:2000});
            }
        });     
    });    
    // ...
    // Se encarga de consultar la informacion pertinente para cada combo box de información.
    informacionComboBox();
    // ...
    // Boton de consultar empleados...
    $btnEmpleados.click(function(event) {
        consultarEmpleados($(this).val(),0);
        $modalEmpelado.modal('show');
    });
    // ...

    // Boton de enviar informacion del empleado...
    $btnEnviarInfo.click(function(event) {
        var res= $('#solicitante option:checked').val();
        // var dataE= $('#solicitante option:checked').data('existenciaF');
        // console.log(doc);
        limpiarCamposTexto();
        limpiarFormularioEstadoEmpresarial(0);
        var v= res.split(';');
        //0 = Documento y 1=Existencia de la FSDG
        if (Number(v[0])==0) {
            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'Por favor seleccione a un empleado...',
                showConfirmButton: false,
                timer: 2500
            });
        }else{
          // Documento del empleado Y Existencia de la FSDG  
          consultarEmpleados(v[0], v[1]);
          $btnAccion.removeAttr('disabled');  
        }   
    });
    // ...

    // Boton de registrar o modificar ficha
    $btnAccion.click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: 'Se '+($(this).val()==0?'Registrar':'Modificara')+' la informacion del empleado.',
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {//Si el usuario desea realizar la accion
                // ...
                // registrarModificarEstadoEmpresarial(1);
                // Validacion de los campos del formulario...
                if (validacionDeCamposFormulario()==1) {
                    registrarModificarFSDG($(this).val());//0 para registrar, otro numero para actualziar el estado existente
                }else{
                  //Mensaje de alerta!!!
                  swal('Alerta!','Falta algun campo obligatorio por diligenciar.','warning'); 
                }
            }
        });     
    });
    //...
    $estudiaA.click(function(event) {
        if ($(this).prop('checked')==true) {
            $cbxEstudiando.attr('disabled', false);
            $nameCarrer.attr('disabled', false);
        }else{
            $cbxEstudiando.attr('disabled', true);
            $cbxEstudiando.children('option:checked').removeProp('selected');
            $cbxEstudiando.children('option[value="0"]').prop('selected',true);
            $cbxEstudiando.parent('div').removeClass('has-error');
            $nameCarrer.attr('disabled', true);
            $nameCarrer.parent('div').removeClass('has-error');
            $nameCarrer.val('');
        }
    });
    // Boton de limpiar formulario
    $('#limpiarCRUD').click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: 'Se limpiara todo el formulario y no podra devolverse.',
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {   
               limpiarCamposTexto();
            }
        });
    });
    //...

    //Boton checkbox de Hijos
    $hijos.click(function(event) {
        if ($(this).prop('checked')==false) {
            retirarHermanosROW(1);
        }
    });
    //...

    //Boton checkbox de Hijos
    $hijastros.click(function(event) {
        if ($(this).prop('checked')==false) {
            retirarHermanosROW(2);
        }
    });
    //... 

    // Tooltips de los labels
    // Arreglar el problema de los tooltip con el desplazamiento de los componenetes.
    $('[data-toggles="tooltip"]').tooltip();//Hasta acá se llego el dia 14/08/2018
    //... 
    //... 
    $cbxAuxilios.change(function(event) {
        // console.log($(this).find('option:checked').last());
        agregarCampoMontoAuxilio($(this).val());
        // Remover elementos
        setTimeout(function () {
            $cbxAuxilios.find('option').each(function(index, item) {
                // ...
                    if ($(item).data('chek')==1 && $(item).prop('selected')==false) {
                        // ...
                       $canAuxilios.children('div[id="'+$(item).val()+'"]').hide(200, function() {
                            $(this).remove();
                            // Calcular neuvamente el salario
                            $total.val(calcularSalarioTotal(0));
                        });
                    } 
            });
        },100);
    });
    //... 
    //...
    $EstadoE.change(function(event) {
        clasificarCamposEstadoEmpresarial($EstadoE.children('option:selected').val());
    }); 
    //... 
    //...
    $addButton.click(function(event) {
        // agregarBotonEstadoEmpresarial();//El id es del ultimo boton que se genere
        limpiarFormularioEstadoEmpresarial(0);
        $(this).attr('disabled',true);
    }); 
    //...
    $saveButton.click(function(event) {
        guardarCambioEstadoEmpresarial();
    });
    // 
    $deletButton.click(function(event) {
        eliminarBotonEstadoEmpresarial();
    });
});

function clasificarCamposEstadoEmpresarial(valor) {
    if (valor==1) {//Retirado
        $motivo.attr('disabled',false);
        $fechaRetiro.attr('disabled', false);
        $obsRetiro.attr('disabled', false);
        $rotacion.attr('disabled', false);
    }else{//Vigente
        $motivo.attr('disabled',true);
        $fechaRetiro.attr('disabled', true);
        $obsRetiro.attr('disabled', true);
        $rotacion.attr('disabled', true);
    }
}

function estadoInicialEstadoEmpresarial() {
    $motivo.attr('disabled',true);
    $fechaRetiro.attr('disabled', true);
    $obsRetiro.attr('disabled', true);
    $rotacion.attr('disabled', true);
}

function informacionComboBox() {
        limpiarCombos(); //Limpia la informacion de los comboBox
        // Se repetira 13 veces porque son 13 CBX que se deben llenar con información
        for (var i = 1; i <= 15; i++) {
            consultarTodosDetallesCBX(i);
            if (i==13) {
                // Solo aplica para las Actividades en el tiempo libre!!
                setTimeout(function () {
                    $cbxAuxilios.selectpicker('refresh');
                    $cbxActividadesTiempoLibre.selectpicker('refresh');
                },1000);
            }
        }
        // Consultar Empresas
        $.post(baseurl + 'Empleado/cEmpresa/buscarEmpresas', {}, function(dato) {
            //Traemos la informacion de respuesta
            var c = JSON.parse(dato);
            //alert(dato);
            $empresas.empty();
            $empresas.append("<option value='0'>Seleccione...</option>");
            $.each(c, function(i, item) { //recorremos todo el result que se convirtio a json
                $empresas.append("<option value=" + item.idEmpresa + ">" + item.nombre + "</option>");
            });
        });
}
// ...
function consultarTodosDetallesCBX(i) {
        $.post(baseurl + 'FichaSDG/cConfiguracionFicha/consultarInformacion', {
            op: 0, //Hace referencia a que se debe consultar la informacion que no tenga un esta de desactivado.
            info: i //Esta variable hace referencia a la informacion que se debe consultar
        }, function(data) {
            // Informacion
            var result = JSON.parse(data);
            // Forma de recorrer la informacion...
            $.each(result, function(index, row) {
                // Enrutamiendo del ComboBox al cual pertenece la informacion...
                switch (i) {
                    case 1:
                        // Salario
                        $cbxPromedioSalario.append('<option value="' + row.idPromedio_salario + '">' + row.nombre + '</option>');
                        break;
                    case 2:
                        // Clasificacion Mega
                        $cbxClasificadionM.append('<option value="' + row.idClasificacion_mega + '">' + row.clasificacion + '</option>');
                        break;
                    case 3:
                        // Auxiliar
                        $cbxAuxilios.append('<option value="' + row.idTipo_auxilio + '">' + row.auxilio + '</option>');
                        TextAux.push({'nombre':row.auxilio,'id':row.idTipo_auxilio});
                        break;
                    case 4:
                        // Estado civil
                        $cbxEstadoCivil.append('<option value="' + row.idEstado_civil + '">' + row.nombre_estado + '</option>');
                        break;
                    case 5:
                        // EPS
                        $cbxEPS.append('<option value="'+row.idEPS +'">'+row.nombre+'</option>');
                        break;
                    case 6:
                        // AFP
                        $cbxAFP.append('<option value="'+row.idAFP+'">'+row.nombre+'</option>');
                        break;
                    case 7:
                        // Cargos laborales
                        $cbxCargoL.append('<option value="'+row.idCargo+'">'+row.cargo+'</option>');
                        break;
                    case 8:
                        // Horario de Trabajo
                        $cbxHorarioT.append('<option value="'+row.idHorario_trabajo+'">'+row.horario+'</option>');
                        break;
                    case 9:
                        // Área de trabajo
                        $cbxAreaTrabajo.append('<option value="'+row.idArea_trabajo+'">'+row.area+'</option>');
                        break;
                    case 10:
                        // Área de trabajo
                        $cbxTipoContrato.append('<option value="'+row.idTipo_contrato+'">'+row.contrato+'</option>');
                        break;
                    case 11:
                        // Grado de escolaridad
                        $cbxEstudios.append('<option value="'+row.idGrado_escolaridad+'">'+row.grado+'</option>');
                        // Estudios curzando actualmente
                        $cbxEstudiando.append('<option value="'+row.idGrado_escolaridad+'">'+row.grado+'</option>');
                        break;
                    case 12:
                        // Actividades en el tiempo libre
                        $cbxActividadesTiempoLibre.append('<option value="'+row.idActividad+'">'+row.nombre+'</option>');
                        break;
                    case 13:
                        // Municipios
                        $cbxMunicipio.append('<option value="'+row.idMunicipio+'">'+row.nombre+'</option>');
                        break;
                    case 14:
                        // Motivos de renuncia 
                        $motivo.append('<option value="'+row.idMotivo+'">'+row.nombre+'</option>');
                        break;
                    case 15:
                        // Clasificacion contable
                        $clasificacionC.append('<option value="'+row.idClasificacion_contable+'">'+row.clasificacion+'</option>');
                        break;    
                }
            });
            // ...
        });
}  

function limpiarCombos() {
    $cbxPromedioSalario.empty();
    $cbxPromedioSalario.append('<option value="0">Selecione...</option>');
    $cbxClasificadionM.empty();
    $cbxClasificadionM.append('<option value="0">Selecione...</option>');
    $cbxAuxilios.empty();
    $clasificacionC.empty();
    $clasificacionC.append('<option value="0">Selecione...</option>');
    $motivo.empty();
    $motivo.append('<option value="0">Selecione...</option>');
    // $cbxAuxilios.append('<option value="0">Selecione...</option>');
    $cbxEstudios.empty();
    $cbxEstudios.append('<option value="0">Selecione...</option>');
    $cbxEstudiando.empty();
    $cbxEstudiando.append('<option value="0">Selecione...</option>');
    $cbxEstudiando.attr('disabled',true);
    $nameCarrer.attr('disabled',true);
    $cbxHorarioT.empty();
    $cbxHorarioT.append('<option value="0">Selecione...</option>');
    $cbxAreaTrabajo.empty();
    $cbxAreaTrabajo.append('<option value="0">Selecione...</option>');
    $cbxCargoL.empty();
    $cbxCargoL.append('<option value="0">Selecione...</option>');
    $cbxTipoContrato.empty();
    $cbxTipoContrato.append('<option value="0">Selecione...</option>');
    $cbxEstadoCivil.empty();
    $cbxEstadoCivil.append('<option value="0">Selecione...</option>');
    $cbxEPS.empty();
    $cbxEPS.append('<option value="0">Selecione...</option>');
    $cbxAFP.empty();
    $cbxAFP.append('<option value="0">Selecione...</option>');
    $cbxActividadesTiempoLibre.empty();
    // cbxActividadesTiempoLibre.append('<option value="0">Selecione...</option>');
    $cbxMunicipio.empty();
    $cbxMunicipio.append('<option value="0">Selecione...</option>');
}

function agregarCampoMontoAuxilio(idAuxS) {
    var res;
    var v=[];
    var texto;
    // ...
    $canAuxilios.children('div').each(function(index, item) {
        // Elementos que existen dentro del elemento.
        v.push($(item).attr('id'));
    });
    // Agregar elementos
    idAuxS.forEach(function (element) {//ID's de los auxilios seleccionados
        res=true;
        // Validar existencia
        v.forEach(function (elemento1) {//div del contenedor de los montos
            if (element==elemento1) {
                // ...
                res=false;
                // ...
            }
        });
        // ...
        if (res) {
             for (var i = 0; i < TextAux.length; i++) {
                 if (TextAux[i].id==element) {
                    texto= TextAux[i].nombre;
                    break;
                 }
             }       
            // Se añade una variable data para validar la eliminacion posterior de los elemntos.
            $cbxAuxilios.find('option[value="'+element+'"]').data('chek', 1);
            $canAuxilios.append(componenteAuxilio(element,texto,''));
        }
    });
}

function componenteAuxilio(id,texto,monto) {
    return '<div class="row" id="'+id+'">'+
                                    '<label for="montoAux"><strong>*</strong>'+texto+'</label>'+
                                    '<div class="input-group">'+
                                      '<span class="input-group-addon">$</span>'+
                                      '<input type="text" value="'+monto+'" class="form-control" name="montoAux" maxlength="20" onkeypress="return valida(event);" onkeyup="calcularSalarioTotal(1);">'+
                                    '</div>'+
                                  '<br></div>';
}

//Validar que el input solo permita caracteres numericos
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

function calcularSalarioTotal(op) {
    var valor=0;
    // Suma de salario basico
    valor+=Number($salarioBase.val());
    // Suma de lo auxilios
    $canAuxilios.children('div').each(function(index, item) {
        // Elementos que existen dentro del elemento.
        valor+=Number($(item).find('input[name="montoAux"]').val());
    });
    if (op==0) {   
      // Retornar el monto total del salario
      return new Intl.NumberFormat().format(valor);
      // Intl.NumberFormat Clase propia de js
    }else{
        $total.val(new Intl.NumberFormat().format(valor));
    }
}

function agregarMasInputHijos(componente,op) {
    var padre= $(componente).parents('div.row').eq(0);
    // Retirar el boton de más de esta fila.
    $(componente).hide('350');
    //Agregar El nuevo formulario para el nuevo hijo---
    $(componente).parents('div.row').eq(0).after(inputsDeHijos(op,0));
    // console.log(padre);
    // $(componente).parents('div.row').eq(0).children('div').last().data('idPersonaV', 'value');
}
function inputsDeHijos(op,dato) {
    // 1 = hijos 2= Hijastros
    // Dato me trae el ID de la persona con la que vive. '+(dato!=0?"data-idPersonaV="+dato+"":'')+'
    var mensaje =('<div class="row hermano" name="hermano">'+
                                  '<br><!-- Columna 1 -->'+
                                  '<div class="col-sm-2 col-xs-4">'+
                                  '</div>'+
                                  '<!-- Acordeon columna 2-->'+
                                  '<div class="col-sm-5 col-xs-10">'+
                                    '<div class="col">'+
                                        '<div>'+
                                          '<div class="card card-body">'+
                                            '<!-- <label>Nombre</label> -->'+
                                            '<input type="text" name="nameHijo" class="form-control" style="text-transform: capitalize;" placeholder="'+(op==1?'*Nombre completo del hijo':'*Nombre completo hijastro')+'">'+
                                          '</div>'+
                                        '</div>'+
                                    '</div>'+
                                    '<div class="col">'+
                                      '<div>'+
                                        '<div class="card card-body">'+
                                          '<!-- <label>Nombre</label> -->'+
                                          '<div class="input-group date">'+
                                            '<div class="input-group-addon">'+
                                              '<i class="fa fa-calendar"></i>'+
                                            '</div>'+
                                            '<input type="text" class="form-control pull-right" placeholder="F.N dd-mm-yyyy" name="fechaNH">'+
                                          '</div>'+
                                        '</div>'+
                                      '</div>'+
                                    '</div>'+
                                  '</div>'+
                                  '<!-- Columna 3 -->'+
                                  '<div class="col-sm-4">'+
                                    '<div class="col">'+
                                      '<div>'+
                                        '<div class="card card-body">'+
                                          '<!-- <label>Nombre</label> -->'+
                                            '<div class="checkbox">'+
                                              '<!-- Madre -->'+
                                              '<label style="font-size: 1em">'+
                                                  '<input type="checkbox" value="madre" checked>'+
                                                  '<span class="cr"><i class="cr-icon fa fa-check"></i></span>'+
                                                  'Vive con el ?'+
                                              '</label>'+
                                            '</div>'+
                                            '<div class="pull-right">'+
                                              '<label class="btn btn-default accionHijos" name="masH"  onclick="agregarMasInputHijos(this,'+op+');"><span><i class="fas fa-plus"></i></span></label>'+
                                              '&nbsp;'+
                                              '<label class="btn btn-default accionHijos" name="menosH"  onclick="retirarInputsHijo(this,'+op+');"><span><i class="fas fa-minus"></i></span></label>'+
                                            '</div>'+
                                          '</div>'+
                                        '</div>'+
                                      '</div>'+
                                    '</div>'+
                                '</div>');
    // if (dato!=0) {
    //     $(mensaje).find('div').data('idPersonaV',dato);
    // }
    return mensaje;
}
// Se encarga de retirar el componente del formulario del Hijo o Hijastro
function retirarInputsHijo(componente,op) {
    // console.log($(componente).parents());
    // Validar que la posicion del boton no este en el medio de los elementos hermanos
     if (($(componente).parents('div#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children().length)==($(componente).parents('div.row').eq(0).index())+1) {
        // Mostrar el boton de agregar del componente anterior
        $(componente).parents('div.row').eq(0).prev().find('label').show('slow');
     }
    // ...
    // Se encarga de cargar las id de los hijos o hijastros que se van a eliminar de la base de datos
    if ($(componente).parents('div.row').eq(0).data('idPersonaV')!=undefined) {
        IDPersonasVive.push($(componente).parents('div.row').eq(0).data('idPersonaV'));
    }
    // ...
    //  Retirar el boton de más de esta fila.
    $(componente).parents('div.row').eq(0).hide('slow', function() {
        $(this).remove();
    });
}
// Se encarga de retirar los elementos hermanos(ROW) del contenedor del formulario de despliegue de los hijos.
function retirarHermanosROW(op) {
    $('div#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children('div[name="hermano"]').hide('slow', function() {
        $(this).remove();
    });
    $('#'+(op==1?'masHijos':'masHijastros')).show();
    // console.log($('div#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children('div[name="hermano"]'));
}

// Consulta todos los empleados de la empresa con un estado Activo
function consultarEmpleados(doc, exis) {
    $.post(baseurl + 'Empleado/cEmpleado/consultarEmpleados', {
        doc: doc
    }, function(data) {
        var result = JSON.parse(data);
        $solicitante.empty();
        $solicitante.append('<option value="0" >Seleccione...</option>'); //
        // console.log(result);
        $.each(result, function(index, row) {
            if (doc=='') {
                // Llenar el select de los empleados
                $solicitante.append('<option '+(row.FichaSDG==1?'data-icon="far fa-file" style="color:green;"':'')+' data-subtext="' + row.documento + '" value="' + row.documento+';'+row.FichaSDG + '"><strong>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</strong></option>');
            }else{
                // Enviar la informacion a la vista
                enviarInformacionVentanaFichaSDG(row,exis);
            }
        });
        //
        if (doc=='') {
            $solicitante.selectpicker('refresh');
        } 
    });
}

function enviarInformacionVentanaFichaSDG(row, exis) {
    // console.log(row);
    $modalEmpelado.modal('hide');
    // Pasar los valores al formulario 
    $CedulaE.val(row.documento); 
    $PrimerN.val(row.nombre1);
    $SegundoN.val(row.nombre2);
    $PrimerA.val(row.apellido1); 
    $SegundoA.val(row.apellido2);
    $generoE.val((row.genero==1?'Masculino':'Femenino'));
    // Validar la existencia de la ficha SDG del empleado
    $btnAccion.val(0);
    $email.val(row.correo);
    $empresaContratante.val(row.nombre);
    // console.log(row);
    validarExistenciaFichaSDG(exis,row.documento,row.idFicha_SD); 
}
// 
function validarExistenciaFichaSDG(exis,doc,idF) {
    // console.log(exis);
    // Valida si la existencia es verdadera.
    if (exis==1) {
        // Consultar la FSDG--Pendiente--
        consultarInformacionFichaSDG(doc);
        $generarPDF.show('slow');
        // $btnAccion.removeClass('btn-info');
        $btnAccion.val(idF);
        // $btnAccion.addClass('btn-warning');
        $btnAccion.text('Modificar');
    } 
}
// CRUD de la Ficha SDG--------------------------------------------------------------------------------------------------------------
// ...
// Consultar Información de la ficha SDG de un empleado.>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
function consultarInformacionFichaSDG(doc) {
    // Actualizar la informacion de los comboBox
    informacionComboBox();
    // Accion 1
    // consultarInformacionSalarial(doc);
    consultarEstadosEmpresariales(doc);
}

// Consultar estados esmpresariales
function consultarEstadosEmpresariales(doc) {//Pendiente posicionar informacion en el formulario.
    $.post(baseurl+'FichaSDG/cFichaE/consultarInformacionEstadoEmpresarial', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   
         // console.log(result);
         $.each(result, function(index, row) {
              vEstadosEm.push({"idEstadoE": row.idEstado_empresarial,// Es el id del estado empresarial
                         "estadoE": row.estado_e,//id del estado empresarial (Retirado vigente)
                         "idRotacion":row.idIndicador_rotacion,
                         "idMotivo": row.idMotivo,
                         "idEmpresa": row.idEmpresa,
                         "fechaR": formatoFecha(row.fecha_retiro),
                         "fechaI": formatoFecha(row.fecha_ingreso),
                         "antiguedad": row.antiguedad,//Calcular antiguiedad desde la base de datos
                         "des": row.observacion_retiro,
                         "impacto": row.impacto
                     });
         });
         // console.log('Este es el mismo vector pero ya almacenado en el lado del cliente');
         $grupoBTN.empty();
         // Colocacion de los botones de estados empresariales
         $.each(vEstadosEm,function(index, item) {
            $grupoBTN.append('<button type="button" class="btn btn-info" value="0" onclick="posicionDelBotonSeleccionado(this)">'+($grupoBTN.children('button').length+1)+'</button>');
         });
         // Accion ?
         setTimeout(function () {
            consultarInformacionSalarial(doc); 
         },20);
    });
}

// Se encarga de consultar toda la informacion salarial del empleado.
function consultarInformacionSalarial(doc) {
    $.post(baseurl+'FichaSDG/cFichaE/consultarInfoSalarial', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
              $salarioBase.val(row.salario_basico);
              // $total.val(row.total);
              $('#promSalarial option[value="'+ row.idPromedio_salario +'"]').prop('selected', true);
              $('#clasiMega option[value="'+ row.idClasificacion_mega +'"]').prop('selected',true);
              // $cbxAuxilios = $('#auxTransporte');
         });
         // accion 2
         setTimeout(function () {
            consultarInfoSAuxilio(doc); 
         },20);
    });


}
// 
function consultarInfoSAuxilio(doc) {
   $.post(baseurl+'FichaSDG/cFichaE/consultarAuxilios', 
       {
           documento: doc
       }, function(data) {
        var result= JSON.parse(data);   
        $canAuxilios.empty();
        $canAuxilios.data('modi',1);
        // ...
        $.each(result, function(index, row) {
            // ---
            if (row.estado==1) {//Estado del auxilio es activo
                // Componentes de los auxilio
                $canAuxilios.append(componenteAuxilio(row.idTipo_auxilio,row.auxilio,row.monto));
                // ComboBox
                $cbxAuxilios.find('option[value="'+row.idTipo_auxilio+'"]').prop('selected',true);
                $cbxAuxilios.find('option[value="'+row.idTipo_auxilio+'"]').data('chek', 1);
            }else{
                // Pendiente como mostrar los auxilios que el empleado recibio en algun momento de su estadia en la empresa.
            }
            // ---
        });
        calcularSalarioTotal(1);
        $cbxAuxilios.selectpicker('refresh');
        // accion 2
        setTimeout(function () {
          consultarInformacionEstudios(doc);   
        },20);
   });
}
// Se encarga de consultar toda la informacion de los estudios de los empleados de la empresa.
function consultarInformacionEstudios(doc) {
    $.post(baseurl+'FichaSDG/cFichaE/consultarInfoEstudios', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            $('#gradoEscolaridad option[value="'+ row.idGrado_escolaridad +'"]').attr('selected',true);
            $tituloProfecional.val(row.titulo_profecional);
            $tituloEspecializacion.val(row.titulo_especializacion);
            if (row.titulo_estudios_actuales!=null) {
                $('#gradoEstudiando option[value="'+ row.titulo_estudios_actuales +'"]').attr('selected',true);
                $estudiaA.prop('checked', row.titulo_estudios_actuales==0?false:true);
                $nameCarrer.val(row.nombre_carrera);
                $cbxEstudiando.attr('disabled', false);
                $nameCarrer.attr('disabled', false);
            }
         });
         // Accion 3
         setTimeout(function () {
             consultarInformacionLaboral(doc);
         },20);
    });
}
// Se encarga de consultar toda la informacion laboral de los empleados de la empresa.
function consultarInformacionLaboral(doc) {
    $.post(baseurl+'FichaSDG/cFichaE/consultarInfoLaboral', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   
         // ...
         $.each(result, function(index, row) {
            // Variables de la informacion laboral
            $('#horaTrabajo option[value="'+ row.idHorario_trabajo +'"]').attr('selected',true);
            $('#areaTrabajo option[value="'+ row.idArea_trabajo +'"]').attr('selected',true);
            $('#cargo option[value="'+ row.idCargo +'"]').attr('selected',true);
            $('#tipoContrato option[value="'+ row.idTipo_contrato +'"]').attr('selected',true);
            $fechaVC.val(row.fecha_vencimiento_contrato);
            $recursoH.prop('checked',(row.recurso_humano==1?true:false));
            $clasificacionC.children('option[value="'+row.idClasificacion_contable+'"]').attr('selected',true);
            // $fechaIngreso.val(row.fecha_ingreso);
            // $antiguedadE.val(row.antiguedad);
         });
         // Accion 4
         setTimeout(function () {
             consultarInformacionSecundariaBasica(doc);
         },20);
    });
}
// Se encarga de consultar toda la informacion secundaria basica de los empleados de la empresa.
function consultarInformacionSecundariaBasica(doc) {
    $.post(baseurl+'FichaSDG/cFichaE/consultarInfoSecundariaBasica', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            $('#estadoCivil option[value="'+ row.idEstado_civil +'"]').prop('selected',true);
            $fechaNacimientoE.val(row.fecha_nacimiento);
            $Lugarnacimiengo.val(row.lugar_nacimiento);//Ese es un input tipo text
            $('#tipoSangre').children('option').prop('selected');
            $('#tipoSangre option[value="'+ row.idTipo_sangre +'"]').prop('selected',true);
            $telefonoFijo.val(row.tel_fijo);
            $telefonoCelular.val(row.celular);
            $('#EPS option[value="'+ row.idEPS +'"]').prop('selected',true);
            $('#AFP option[value="'+ row.idAFP +'"]').prop('selected',true);
         });
        // Accion 5
        setTimeout(function () {
            consultarInformacionSalud(doc); 
         },20);
    });
}
// Se encarga de consultar toda la informacion se salud de los empleados de la empresa.
function consultarInformacionSalud(doc) {//Revisar los checkBox de esta vista.
    $.post(baseurl+'FichaSDG/cFichaE/consultarInfoSalud', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            // CheckBox de Fumar
            if (row.fuma > 0) {
                $fuma.prop('checked',true);
                // Numero de cigarrillos
                $NCigarrillos.val(row.fuma);
            }else{
                $fuma.prop('checked',false);
            }
            // CheckBox de alcohol
            if (row.alcohol!='0') {
                $bebidasACL.prop('checked', true);
                $cbxFrevuenciaB.children('option').removeProp('selected');
                $('#frecuenciaAlcohol option:contains('+row.alcohol+')').prop('selected',true);
            }else{
               $bebidasACL.prop('checked', false);
               $cbxFrevuenciaB.children('option').removeProp('selected');
               $('#frecuenciaAlcohol option[value="0"]').prop('selected',true); 
            }
            // Tener en cuenta alguna consicion, estado, compuesto, alergias a tener en cuenta para poderla atender en cado de emergencia.
            $AnteUnaEmergencia.val(row.descripccion_emergencia);
         });
        // Accion 6
        setTimeout(function () {
            consultarOtraInformacion(doc); 
        },20);
    });
}
// Se encarga de consultar toda la informacion Personal de los empleados de la empresa.
function consultarInformacionPersonal(doc) {
    $.post(baseurl+'FichaSDG/cFichaE/consultarInfoPersonal', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            // ...
            idPersonal= row.idPersonal;
            // ...
            var v=row.direccion.split(';');
            // $direccionC.val(row.direccion);
            $cbxOpt1.children('option:contains("'+v[0]+'")').prop('selected', true);//Select
            $opt2.val(v[1]);//
            $opt3.val(v[2]);//
            $opt4.val(v[3]);//
            $cbxOpt5.children('option:contains("'+v[4]+'")').prop('selected',true);
            $opt6.val(v[5]);
            // 
            $barrio.val(row.barrio);
            $comuna.val(row.comuna);
            $cbxMunicipio.find('option').removeAttr('selected');
            $('#municipio option[value="'+row.idMunicipio+'"]').attr('selected', true);;
            $estrato.val(row.estrato);
            $personaEmergencia.val(row.caso_emergencia);
            $tipoVivienda.children('option').removeProp('selected');
            $parentezco.children('option').removeProp('selected');
            $('#tipoVivienda option[value="'+row.idTipo_vivienda+'"]').prop('selected',true);
            $('#CasoEParentezco option[value="'+row.parentezco+'"]').prop('selected',true);
            $altura.val(row.altura);
            $peso.val(row.peso);
            $telEm.val(row.tel);
            $otrasActividades.val(row.otraActividad);
         });
        // Accion 7
        // Informacion complementaria!! Actividades que realiza en el tiempo libre.
        setTimeout(function () {
             consultarActividadesInfoPersonal();
        },35);
    });
}

// Se encarga de consultar las actividades que realizar el empleado en sus tiempos libres para complementar la informacion personal.
function consultarActividadesInfoPersonal() {
    // 
    $.post(baseurl+'FichaSDG/cFichaE/consultarActividadesInfoPesonal', 
        {
            idP: Number(idPersonal)
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            // ...
            IDsActividades.push(row.idActividades);
            $('#actividadesLibres option[value="'+row.idActividades+'"]').attr('selected',true);
            // ...
         });
         $cbxActividadesTiempoLibre.selectpicker('refresh');
         // console.log(IDsActividades);
        // Accion 8
        setTimeout(function () {
             consultarPersonasViveInfoPersonal();
        },100);
    });    
}

function consultarPersonasViveInfoPersonal() {
    var  hijosC=0;
    var  hijastros=0;
    // La informacion del parentezco no se puede modificar.
    $.post(baseurl+'FichaSDG/cFichaE/consultarPersonasViveInfoPersonal', 
        {
            idP: Number(idPersonal)
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            // ...
            // IDPersonasVive.push(row.idPersonas_vive);//Identificador de la persona con las que vive
            // Esta informacion es en otra consulta...
            switch(Number(row.idParentezco)){
                case 1://Madre
                case 2://Padre
                   if (Number(row.cantidad)==1) {
                     (row.idParentezco=='1'?$madre:$padre).prop('checked', true);
                     (row.idParentezco=='1'?$madre:$padre).data("idPersonaV", row.idPersonas_vive);
                   }else{
                     (row.idParentezco=='1'?$madre:$padre).prop('checked', false);
                     // (row.idParentezco=='1'?$madre:$padre).data('idPersonaV', row.idPersonas_vive);
                   }
                   break;
                case 3://Acompañante
                   $('#rowAcompañante').data("idPersonaV", row.idPersonas_vive);//En el div
                   $compañeroP.prop('checked',true);
                   $('.acor').collapse('show');
                   $nombreAcompañante.val(row.nombreC);
                   $celularAcompañante.val(row.celular) 
                   break;
                case 4://Abuelos
                   $abuelos.val(row.cantidad);
                   $abuelos.data("idPersonaV", row.idPersonas_vive);//En el componenete
                   break;
                case 5://Tios
                   $tios.val(row.cantidad);
                   $tios.data("idPersonaV", row.idPersonas_vive);//En el componenete
                   break;//Hermanos
                case 6:
                   $hermanos.val(row.cantidad);
                   $hermanos.data("idPersonaV", row.idPersonas_vive);//En el componenete
                   break;
                case 7://Otros
                   $otros.val(row.cantidad);
                   $otros.data("idPersonaV", row.idPersonas_vive);//En el componenete
                   break;
                case 8://Hijos
                hijosC++;//En el div
                // IDPersonasVive.push(row.idPersonas_vive);
                colocarHConsultados(hijosC,1,[row.nombreC,row.fecha_nacimiento,row.vive_empleado,row.idPersonas_vive]);
                   break;
                case 9://Hijastros
                hijastros++;//En el div
                // IDPersonasVive.push(row.idPersonas_vive);
                colocarHConsultados(hijastros,2,[row.nombreC,row.fecha_nacimiento,row.vive_empleado,row.idPersonas_vive]);
                   break;
            }
            // ...
         });
         $cbxActividadesTiempoLibre.selectpicker('refresh');
        // Accion 9
    });
}

function colocarHConsultados(hCont,op,array) {
    // OP= 1 hijos o 2=Hijastros
    if (hCont==1) {
        //Muestra todos los hijos
        $('.acordeon'+op).collapse('show');
        //selecciona el checkbox de hijos
        (op==1?$hijos:$hijastros).prop('checked', true);
            $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children('div').first().data("idPersonaV",array[3]);
        }else{
             //Se añade los desplegables necesarios dependiendo de la cantidad de hijos que tenga 
            $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).append(inputsDeHijos(op,array[3]));                         
        }
        // ...
        $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children('div').last().data("idPersonaV",array[3]);
        // Falta ocultar los botones de más Hijastros o hijos en cada fila si tiene más de un hijo. Pendiente---
        // ...
        $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children().last().children('div').eq(1).find('input[name="nameHijo"]').val(array[0]);//Nombre completo.
        $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children().last().children('div').eq(1).find('input[name="fechaNH"]').val(array[1]);//Fecha de nacimiento.
        $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children().last().children('div').eq(2).find('input[type="checkbox"]').prop('checked',(array[2]==1?true:false));//Vive con el empleado.
}

// Se encarga de consultar toda la informacion Personal de los empleados de la empresa.
function consultarOtraInformacion(doc) {
    $.post(baseurl+'FichaSDG/cFichaE/consultarOtraInformacion', 
        {
            documento: doc
        }, function(data) {
         var result= JSON.parse(data);   

         $.each(result, function(index, row) {
            // ...
            $TCamisa.val(row.talla_camisa);
            $TPantalon.val(row.talla_pantalon);
            $Tzapatos.val(row.talla_zapatos);
            $VCursoAlturas.val(row.vigencia_curso_alturas);
            $PBrigadaEmergencia.prop('checked',(row.brigadas==1?true:false));//Revisar los Checked de los combo box
            $AlgunComite.prop('checked',(row.comites==1?true:false));
            $RquierecursoAlturas.prop('checked',(row.necesitaCALT==1?true:false));
         });
         // Accion 9
         setTimeout(function () {
             consultarInformacionPersonal(doc);
         },20);
    });
}

// Registrar Información de la Ficha SDG de un empleado.>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function registrarModificarFSDG(IDF) {
// ...
//Accion 1
// registrarModificarEstadoEmpresarial(Number(IDF));
registrarModificarInfoEstudios(Number(IDF));
// 
// ...
}

// Gestionar Estudios
function registrarModificarInfoEstudios(IDF) {//Funciona 1
 // ...
 $.post(baseurl+'FichaSDG/cFichaE/registrarModificarEstudios', 
    {
        ID: IDF,
        idEstudios: $('#gradoEscolaridad option:checked').val(),
        tituloP: $tituloProfecional.val(),
        espes: $tituloEspecializacion.val(),
        idEstudiando: $('#gradoEstudiando option:checked').val(),
        nameCarrera: $nameCarrer.val()
    }, function(data) {
        if (data>=1) {
            idEstudios=data;
            // Accion 2
            registrarModificarInfoLaboral(IDF);
        }
 });
 // ...
}

// Gestionar Informacion Laboral
function registrarModificarInfoLaboral(IDF) {//Funciona 2
    //...
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarInfoLAboral', 
        {
            ID: IDF,
            idHorario: $('#horaTrabajo option:checked').val(),
            idArea: $('#areaTrabajo option:checked').val(),
            idTipoContraro: $('#tipoContrato option:checked').val(),
            idCargo: $('#cargo option:checked').val(),
            recursoH: ($recursoH.prop('checked')==true?'1':'0'),
            fechaVC: formatoFecha($fechaVC.val()),
            atinguedad: $antiguedadE.val(),
            CC: $clasificacionC.children('option:selected').val()
        }
        , function(data, textStatus, xhr) {
            if (data>=1) {
                idLaboral=data;
                // Accion 3
                registrarModificarInfoSalud(IDF);
            }
    });
    //...
}

// Gestionar Salud
function registrarModificarInfoSalud(IDF) {//Funciona 3
// ...
$.post(baseurl+'FichaSDG/cFichaE/registrarModificarInfoSalud', 
    {
        ID: IDF,
        fuma: ($fuma.prop('checked')==true?$NCigarrillos.val():''),
        alcohol: ($bebidasACL.prop('checked')==true?$('#frecuenciaAlcohol option:checked').text():'0'),
        desE: $AnteUnaEmergencia.val()
    }, function(data, textStatus, xhr) {
    if (data>=1) {
        idSalud=data;
        // Accion 4
        registrarModificarOtraInfo(IDF);
    }
});
// ...
}

// Gestionar Otra Informacion
function registrarModificarOtraInfo(IDF) {//Funciona 4
// ...
$.post(baseurl+'FichaSDG/cFichaE/registrarModificarOtraInformacion', 
    {
        ID: IDF,
        TCamida: $TCamisa.val(),
        TPantalon: $TPantalon.val(),
        Tzapatos: $Tzapatos.val(),
        VCursoAlturas: $VCursoAlturas.val(),
        RquierecursoAlturas: $RquierecursoAlturas.prop('checked'),
        PBrigadaEmergencia: $PBrigadaEmergencia.prop('checked'),
        AlgunComite: $AlgunComite.prop('checked')
    }, function(data, textStatus, xhr) {
    if (data>=1) {
        idInfoOtra=data;
        // Accion 5
        registrarModificarInfoSecundariaBasica(IDF);
    }
});
// ...
}

// Gestionar Informacion Secundaria Basica
function registrarModificarInfoSecundariaBasica(IDF) {// Funciona 5
    // ...
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarInfoSecundariaBasica',
     {
        ID: IDF,
        idEstadoC: $('#estadoCivil option:checked').val(),
        fechaN: formatoFecha($fechaNacimientoE.val()),
        lugarN: $Lugarnacimiengo.val(),
        tipoS: $('#tipoSangre option:selected').val(),
        telF: $telefonoFijo.val(),
        cel: $telefonoCelular.val(),
        EPS: $('#EPS option:checked').val(),
        AFP: $('#AFP option:checked').val()
     }, function(data) {
        idSecundariaB=data;
        // console.log(data);
        // Accion 6
        registrarModificarInfoSalarial(IDF);
    });
    // ...    
}

// Gestionar Informacion Salarial
function registrarModificarInfoSalarial(IDF) { //Funcion 6
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarInfoSalarial', 
        {
           ID: IDF,
           idsalarioP: $('#promSalarial option:selected').val(),
           idClaM: $('#clasiMega option:selected').val(),
           salarioB: $salarioBase.val(),
           total: calcularSalarioTotal(0)
        }, function(data) {
            idSalarial=data;
            // Accion 7
            registrarModificarAuxilios(IDF);
            // 
    });    
}

function registrarModificarAuxilios(IDF) {
    var aux=[];
    var auxDelete=[];
    // Montos de los auxilio seleccionados
    $canAuxilios.children('div').each(function(index, item) {
        // Elementos que existen dentro del elemento.
        aux.push({"idAux":$(item).attr('id'),"monto":$(item).find('input[name="montoAux"]').val()});
    });
    // Auxilios a cambiar estado.
    if ($canAuxilios.data('modi')==1) {
        $cbxAuxilios.children('option').each(function(index, item) {
            if ($(item).prop('selected')==false) {
                auxDelete.push({"idAuxD":$(item).val()});
            }
        });
    }
    // ...
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarInfoSAuxilios', 
        {
            idS: idSalarial,
            auxilios: aux,
            auxDel: auxDelete
        }, function(data) {
           // Accion 7
           registrarModificarInfoPersonal(IDF);
    });
}

// Gestionar Informacion Personal
function registrarModificarInfoPersonal(IDF) { //Funcion 7
    // ...
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarInfoPersonal', 
        {
            // Hasta acá se llego el 24/08/2018-- Pendiente terminar.---
            IDF: IDF,
            direc:  $cbxOpt1.children('option:selected').text()+';'+$opt2.val()+';'+$opt3.val()+';'+$opt4.val()+';'+$cbxOpt5.children('option:selected').text()+';'+$opt6.val(),
            comuna: $comuna.val(),
            municipio: $('#municipio option:selected').val(),
            estrato: $estrato.val(),
            barrio: $barrio.val(),
            casoEM: $personaEmergencia.val(),
            tel: $telEm.val(),
            parentezco: $('#CasoEParentezco option:selected').val(),
            idTipoV: $('#tipoVivienda option:selected').val(),
            altura: $altura.val(),
            peso: $peso.val(),
            otraAC: $otrasActividades.val()
    }, function(data) {
        idPersonal= data;
        // Actividades tiempo libre!!
        // Esta informacion se registra depues de que se registre la informacion personal.
        // Al consultar la informacionde las actividades al tiempo libre traer hacer una copia del vector ID de las actividades al tiempo libre!
        var actividades=[];
        $('#actividadesLibres option:selected').each(function(index, item) {
            actividades.push($(item).val());
        });
        // Validar que actividades se pueden borrar y cuales se pueden registrar.
        if (IDF!=0) {
            // actividades=[];
            actividades=validarActividadesAccion(actividades);
        }
        // Registrar o modificar siempre y cuando las actividades sean mayor a 0.
        if (actividades.length>0) {
          // ...
          // Tener en cuenta que si una actividad en tiempo libre no esta seleccionada esta parte del codigo no se va a ejecutar...Pendiente para la solucion de la falla.
          var cont=0;
          $.each(actividades,function(index, item) {//Recorre todos los elementos seleccionados de las actividades en tiempo libre.
             $.post(baseurl+'FichaSDG/cFichaE/registrarModificarActividadesInfoPersonal', 
               {
                   idF: idPersonal, //Este el el ID de la información Personal 
                   act: item //Vector con todos los id de las actividades.
               }, function(data) {
                // ...
                cont++;
                if (actividades.length==cont) {
                    registrarModificarPersonasViveInfoPersonal(idPersonal,IDF);//Segundo parametro es la opcion de registra o modificar
                }
                // ...
             }); 
          });
        }else{
          registrarModificarPersonasViveInfoPersonal(idPersonal,IDF);//Segundo parametro es la opcion de registra o modificar    
        }
        // registrarModificarPersonasViveInfoPersonal(idPersonal,0);
    });
    // ...
}
// Se encarga de validarme las diferencia de las actividades para saber con cuales tengo que interactuar y a posteriori saber cual se puede registrar y cual se puede eliminar
function validarActividadesAccion(actividades) {
    IDsActividades;//IDs Actividade que fueron registradas
    // Validar cual vecotr es más grande
    var vVectores=[];
    if (IDsActividades.length>actividades.length) {
        vVectores.push(IDsActividades);
        vVectores.push(actividades);
    }else{
        vVectores.push(actividades);
        vVectores.push(IDsActividades);
    }
    // -...
    var vAccion=[];//IDs Actividades que ya existen.
    var va=0;
    for (var i = 0; i<vVectores[0].length; i++) {//El vector mas grande siempre tiene que ir fuera el anidamiento.
        // 
        for (var j = 0; j<vVectores[1].length; j++) {//El vector más pequeño tine que ir anidado.
             //
             if (vVectores[0][i]==vVectores[1][j]) {
                // actividades[j]=0;
                va=1;
                break;
             } 
        }
        if (va!=1) {
           vAccion.push(vVectores[0][i]); 
        }
        va=0;
    }
    return vAccion;
}

// Gestionar Informacion Personal > Personas con las que vive
function registrarModificarPersonasViveInfoPersonal(ID,IDF) {
    var nombreC,fechaN,viveE;//Estas variables se utilizan para el registro del despliegue de los hijos
    // Madre
    var op=0;
    if ($madre.prop('checked')==true) {
        if ($madre.data('idPersonaV')==undefined) {
            postAccionVive('',1,'','',0,ID,1,0,0);//Registrar
        }
        // console.log(1);
    }else if ($madre.data('idPersonaV')!=undefined) {
        // console.log('Se va a eliminar esta acción...');
        eliminarPersonaVive($madre.data('idPersonaV'),0,0);//Eliminar
    }
    // Padre
    if ($padre.prop('checked')==true) {
        if ($padre.data('idPersonaV')==undefined) {
            postAccionVive('',2,'','',0,ID,1,0,0);//Registrar
        }
    }else if ($padre.data('idPersonaV')!=undefined) {
        // console.log('Se va a eliminar esta acción...');
        eliminarPersonaVive($padre.data('idPersonaV'),0,0);//Eliminar
    }
    // Acompañante
    if ($compañeroP.prop('checked')==true) {
        $('#rowAcompañante').data('idPersonaV')!=undefined?op=1:op=0;//Registrar y Modificar
        // ...
        postAccionVive($nombreAcompañante.val(),3,$celularAcompañante.val(),'',0,ID,1,op,(op==0?0:$('#rowAcompañante').data('idPersonaV')));
        op=0;//Estado inicial
    }else if($('#rowAcompañante').data('idPersonaV')!=undefined){
        // console.log('Se va a eliminar esta acción...');
        eliminarPersonaVive($('#rowAcompañante').data('idPersonaV'),0,0);//Eliminar
    }

    // Hijos
    if ($hijos.prop('checked')==true) {
        // ...
        repartirHijosEHijastros(ID,8);
        // ...
    }else if($('#CantidadDeHijos').children('div').first().data('idPersonaV')!=undefined){
        // Eliminara todos los hijos...
        eliminarPersonaVive(0,ID,8);//Eliminara todos la hijos de esta persona
    }

    // Hijastros
    if ($hijastros.prop('checked')==true) {
    //...
    repartirHijosEHijastros(ID,9);
    //... 
    }else if($('#CantidadDeHijastros').children('div').first().data('idPersonaV')!=undefined){
        // Eliminara todos los hijastros...
        eliminarPersonaVive(0,ID,9);//Eliminara todos los hijastros de esta persona.
    }
    // ...
    // Se encarga de eliminar los hijos que fueron seleccionados para eliminar
    $.each(IDPersonasVive,function(index, item) {
        eliminarPersonaVive(item,0,0);//Eliminar
    });
    // ...
    // Validar que accion se va a realziar
    $abuelos.data('idPersonaV')!=undefined?op=1:op=0;//Registrar y Modificar Abuelos
    // Abuelos
    postAccionVive('',4,'','',0,ID,$abuelos.val(),op,($abuelos.data('idPersonaV')==undefined?0:$abuelos.data('idPersonaV')));
    // ...
    $tios.data('idPersonaV')!=undefined?op=1:op=0;//Registrar y Modificar Tios
    // Tios
    postAccionVive('',5,'','',0,ID,$tios.val(),op,($tios.data('idPersonaV')==undefined?0:$tios.data('idPersonaV')));
    // ...
    $hermanos.data('idPersonaV')!=undefined?op=1:op=0;//Registrar y Modificar Hermanos
    // Hermanos 
    postAccionVive('',6,'','',0,ID,$hermanos.val(),op,($hermanos.data('idPersonaV')==undefined?0:$hermanos.data('idPersonaV')));
    // ...
    $otros.data('idPersonaV')!=undefined?op=1:op=0;//Registrar y Modificar Otros
    // Otros
    postAccionVive('',7,'','',0,ID,$otros.val(),op,($otros.data('idPersonaV')==undefined?0:$otros.data('idPersonaV')));
    // console.log(6);
    if (IDF==0) {
        registrarFichaSDG(IDF);//Registro de todos los ID de la informacion complementaria de la ficha SDG
    }else{
        registrarModificarEstadoEmpresarial(IDF);
        swal('Realizado!','La modificacion de la informacion fue realizada correctamente.','success');
    }
    // ...
}
// 
function repartirHijosEHijastros(ID,accion) {
    var nombreC,fechaN,viveE;//Estas variables se utilizan para el registro del despliegue de los hijos
    $('#'+(accion==8?'CantidadDeHijos':'CantidadDeHijastros')).children('div').each(function(index, item) {
        // console.log($(item).children('div').eq(1).find('input[name="nombreAC"]').val());//Nombre
        nombreC=$(item).children('div').eq(1).find('input[name="nameHijo"]').val();
        // console.log($(item).children('div').eq(1).find('input[name="fechaNH"]').val());// Fecha de nacimiento
        fechaN=$(item).children('div').eq(1).find('input[name="fechaNH"]').val();
        // console.log($(item).children('div').eq(2).find('input[type="checkbox"]').prop('checked'));// Vive con el empleado
        viveE=$(item).children('div').eq(2).find('input[type="checkbox"]').prop('checked');
        // console.log($(item).children('div').eq(2));
        $(item).data('idPersonaV')!=undefined?op=1:op=0;//Registrar y Modificar Hijos
        postAccionVive(nombreC,accion,'',formatoFecha(fechaN),viveE,ID,1,op,($(item).data('idPersonaV')!=undefined?$(item).data('idPersonaV'):0));
        // Validacion para saber que se eliminar y que no
    });
}

// Gestionar la informacion de las personas con las que vive.
function postAccionVive(nombreC,idParT,celular,fechaN,vive_empleado,idPersonal,cantidad,op,idPersonas) {
   // if (idParT!=8 && idParT!=9) {
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarPersonasVive', 
        {
           op: op,
           nombre:nombreC,
           idParT: idParT,
           celular: celular,
           fechaN: fechaN,
           viveCon:vive_empleado,
           idPersonal: idPersonal,
           cantidad:cantidad,
           idPE: idPersonas
        }, function(data) {
        // En esta parte no se realiza ninguna aaccion a desencadenar. ni un retorno
    });
   // }
}

// Se encarga de eliminar la informacion de las personas con las que vive.
function eliminarPersonaVive(idPersonaV,idPersonal,idParentezco) {
    $.post(baseurl+'FichaSDG/cFichaE/eliminarPersonaVive', {
        id: idPersonaV,
        idPer:idPersonal,
        idPare:idParentezco
    }, function(data) {
        // console.log(data);
        // En esta parte no se realizar ninguna acción
    });
    
}

// Se encarga de registrar todos los ID de todos los fragmentos de informacion registrados anteriormente en una tabla para asi poder terminar con la gestion del registro de la ficha sociodemografica...
function registrarFichaSDG() {
   $.post(baseurl+'FichaSDG/cFichaE/registrarFichaSDG', 
       {
         doc: $CedulaE.val(),
         idSalarial: idSalarial,
         idLaboral: idLaboral,
         idEstudio: idEstudios,
         idSecundariaB: idSecundariaB,
         idPersonal: idPersonal,
         idSauld: idSalud,
         idOtros: idInfoOtra
       }, function(data) {
        // ...
        registrarModificarEstadoEmpresarial(data);
       // Para este sweet alert se va a realizar un alerta de progreso que se mostrara apenas se termine de ejecutar todo los metodos POST AJAX.
          swal('Realizado!','La ficha SDG fue registrada correctamente.','success');
       // registrarModificarEstadoEmpresarial();
   }); 
}

// Gestionar estado Empresarial
function registrarModificarEstadoEmpresarial(IDF) {
    // ...
    $.post(baseurl+'FichaSDG/cFichaE/registrarModificarEstadoEmpresarial',
     {
        ID: IDF, //ID de la ficha SDG
        estados: vEstadosEm
     }, function(data) {
        // 
        // console.log(data);
        limpiarCamposTexto();//Por el momento va acá
        // 
    });
    // ...
}

// Me trae la posicion(indice) de la informacion almacenada en el vector
function posicionDelBotonSeleccionado(elemento) {
    // Consultar informacion del vector
    limpiarFormularioEstadoEmpresarial(0);
    if (vEstadosEm.length>=($(elemento).index()+1)) {
        $saveButton.attr('disabled',false);
        consultarInformacionEstadoEmpresarialArray(Number($(elemento).index()));
        $(elemento).addClass('btn-warning');
        $(elemento).val(1);
        $deletButton.attr('disabled',false);
        $addButton.attr('disabled',false);
    }else{//Esto nunca se esta utilizando
        if (($(elemento).index()+1)>1) {
            $deletButton.attr('disabled',false);
            $saveButton.attr('disabled',false);
        }
    }
}
// Se encarga de traer la informacion y posicionarla en el formulario deacuerdo al indice(pos) que le pasen 
function consultarInformacionEstadoEmpresarialArray(pos) {
    /*Validar el estado del estado empresarial*/
    clasificarCamposEstadoEmpresarial(vEstadosEm[pos]['estadoE']);//Clasificar campos activos
    $idEstadoEmpresarial.val(vEstadosEm[pos]['idEstadoE']);
    $EstadoE.children('option[value="'+vEstadosEm[pos]['estadoE']+'"]').prop('selected', true);
    $rotacion.children('option[value="'+vEstadosEm[pos]['idRotacion']+'"]').prop('selected', true);
    $motivo.children('option[value="'+vEstadosEm[pos]['idMotivo']+'"]').prop('selected', true);
    $empresas.children('option[value="'+vEstadosEm[pos]['idEmpresa']+'"]').prop('selected', true);
    $fechaRetiro.val(vEstadosEm[pos]['fechaR']==''?'':formatoFecha(vEstadosEm[pos]['fechaR']));
    $fechaIngresoEmpresa.val(vEstadosEm[pos]['fechaI']==''?'':formatoFecha(vEstadosEm[pos]['fechaI']));
    $antiguedadE.val(vEstadosEm[pos]['antiguedad']);
    $obsRetiro.val(vEstadosEm[pos]['des']);
    console.log(vEstadosEm[pos]['impacto']);
    if (vEstadosEm[pos]['idMotivo']==1 || vEstadosEm[pos]['idMotivo']==4) {
      $('#impacto').show('fast');
      $('#impacto').find('input:radio[name="impacto"][value="'+vEstadosEm[pos]['impacto']+'"]').prop('checked',true);
    }
}

function guardarCambioEstadoEmpresarial() {
    // Validar el formulario
    if (validarCamposFormularioEstadoEmpresarial()) {
        // Guardar informacion del estado empresarial.
        var pos= infoEstadoEmpresarial($grupoBTN.children('button[value="1"]').index());
        // ...
        if($grupoBTN.children('button[value="1"]').length==0 || $grupoBTN.children('button').length==0){//Si hay un boton seleccionado significa que se va a modificar la información
            // ...
            $grupoBTN.append('<button type="button" class="btn btn-warning" value="1" onclick="posicionDelBotonSeleccionado(this)">'+($grupoBTN.children('button').length+1)+'</button>');
            // ...
            $grupoBTN.children('button').last().val(1);//$grupoBTN.children('button').length
            // ...
            $deletButton.attr('disabled',false);
        }
        // $saveButton.attr('disabled', false);
        $addButton.attr('disabled', false);
    }
}

// Se encarga de registrar o actualizar la informacion en formato json
function infoEstadoEmpresarial(pos) {
    if (vEstadosEm[pos]!=undefined) {
        // ID del estado con el que se encuentra en la empresa.
        vEstadosEm[pos]['estadoE']= $EstadoE.children('option:selected').val();
        // ID del indice de rotacion
        vEstadosEm[pos]['idRotacion']= $rotacion.children('option:selected').val();
        // ID del motivo de renuncia
        vEstadosEm[pos]['idMotivo']= $motivo.children('option:selected').val();
        // ID de la empresa a la que pertenece el estado empresarial.
        vEstadosEm[pos]['idEmpresa']= $empresas.children('option:selected').val();
        // Fecha de retiro
        vEstadosEm[pos]['fechaR']= $fechaRetiro.val()!=''?formatoFecha($fechaRetiro.val()):'';
        // Fecha de ingreso
        vEstadosEm[pos]['fechaI']= $fechaIngresoEmpresa.val()!=''?formatoFecha($fechaIngresoEmpresa.val()):'';
        // Antiguedad en la empresa.(Esto se guardara en la base de datos siempre y cuando el estado sea retirado, de resto se actualizara con la fecha del sistema).
        vEstadosEm[pos]['antiguedad']= $antiguedadE.val();
        // Descripcion del retiro
        vEstadosEm[pos]['des']= $obsRetiro.val();
        // Impacto
        vEstadosEm[pos]['impacto']= $('input:radio[name="impacto"]:checked').val()==undefined?0:$('input:radio[name="impacto"]:checked').val();
        // console.log(vEstadosEm);
    }else{
        // Registrar la informacion en el vector>>>>>>>>>>>>>>>>>>>>>>>
        // Informacion de un estado empresarial almacenada en un vector
        vEstadosEm.push({"idEstadoE": 0,// Es el id del estado empresarial
                         "estadoE": $EstadoE.children('option:selected').val(),//id del estado empresarial (Retirado vigente)
                         "idRotacion":$rotacion.children('option:selected').val(),
                         "idMotivo": $motivo.children('option:selected').val(),
                         "idEmpresa": $empresas.children('option:selected').val(),
                         "fechaR": $fechaRetiro.val()!=''?formatoFecha($fechaRetiro.val()):'',
                         "fechaI": $fechaIngresoEmpresa.val()!=''?formatoFecha($fechaIngresoEmpresa.val()):'',
                         "antiguedad": $antiguedadE.val(),
                         "des": $obsRetiro.val(),
                         "impacto": $('input:radio[name="impacto"]:checked').val()==undefined?0:$('input:radio[name="impacto"]:checked').val()
                     });
        // console.log(vEstadosEm);
    }
    /*..*/
    return vEstadosEm.length;
}

function eliminarBotonEstadoEmpresarial() {
    // Los Estados empresariales aun no se eliminan de la base de datos... (El eliminar en realidad es un cambio de estado).
    var indice= $grupoBTN.children('button[value="1"]').index();
        //...
        $grupoBTN.children('button[value="1"]').hide('slow', function() {
            $(this).remove();
            // Botones estado por defecto
            $saveButton.attr('disabled', false);
            $deletButton.attr('disabled', true);
            if ($grupoBTN.children('button').length==0) {
                $addButton.attr('disabled', true);
            }else{
                $addButton.attr('disabled', false);
            }
            vEstadosEm.splice(indice,1);//Esta funcion se encarga de retirarme un indice del vector
            // Actualizar texto de cada boton
            $grupoBTN.children('button').each(function(index, item) {
                 // Texto
                 $(item).text(index+1);
             });
            // Limpiar formulario
            limpiarFormularioEstadoEmpresarial(0);
            // Si el estado empresarial es retirado no se puede eliminar y si solo se puede tener un estado vigente.
        });
}

function validarCamposFormularioEstadoEmpresarial() {
    var res=true;

    // Estado empresarial 
    if ($EstadoE.children('option:selected').val()==0) {
        $EstadoE.parent('div').addClass('has-error');
        res=false;
    } else{
        $EstadoE.parent('div').removeClass('has-error');
    }
    // Validar que campos se van a validar
    if ($EstadoE.children('option:selected').val()==1) {
        //Retirado
        // Motivo de retiro
        if ($motivo.children('option:selected').val()==0) {
            $motivo.parent('div').addClass('has-error');
            res=false;
        } else{
            $motivo.parent('div').removeClass('has-error');
            if ($motivo.children('option:selected').val()==1 || $motivo.children('option:selected').val()==4) {
                // Impacto
                if ($('input:radio[name="impacto"]:checked').val()==undefined) {
                    // $('#impacto').find('input').parent('div').addClass('has-error');
                    $('.color').css('color', 'red');
                    res=false;
                }else{
                    // $('#impacto').find('input').parent('div').removeClass('has-error');
                    $('.color').css('color', 'black');
                }
            }
        }
        // Fecha de retiro
        if ($fechaRetiro.val()=='') {
            $fechaRetiro.parent('div').addClass('has-error');
            res=false;
        }else{
            $fechaRetiro.parent('div').removeClass('has-error');
        }
        // 
        // Indicide de rotacion
        if ($rotacion.children('option:selected').val()==0) {
            $rotacion.parent('div').addClass('has-error');
            res=false;
        } else{
            $rotacion.parent('div').removeClass('has-error');
        }
    }

    // Fecha de ingreso
    if ($fechaIngresoEmpresa.val()=='') {
        $fechaIngresoEmpresa.parent('div').addClass('has-error');
        res=false;
    }else{
        $fechaIngresoEmpresa.parent('div').removeClass('has-error');
    }
    //Empresa
    if ($empresas.children('option:selected').val()==0) {
        $empresas.parent('div').addClass('has-error');
        res=false;
    } else{
        $empresas.parent('div').removeClass('has-error');
    }

    return res;
}
// ...

function limpiarFormularioEstadoEmpresarial(accion) {
    $idEstadoEmpresarial.val('');
    $idEstadoEmpresarial.parent('div').removeClass('has-error');
    $fechaRetiro.val('');
    $fechaRetiro.parent('div').removeClass('has-error');
    $fechaIngresoEmpresa.parent('div').removeClass('has-error');
    $fechaIngresoEmpresa.val('');
    $EstadoE.children('option:selected').removeProp('selected');
    $EstadoE.children('option[value="0"]').prop('selected',true);
    $EstadoE.parent('div').removeClass('has-error');
    $motivo.children('option:selected').removeProp('selected');
    $motivo.children('option[value="0"]').prop('selected',true);
    $motivo.parent('div').removeClass('has-error');
    $rotacion.children('option:selected').removeProp('selected');
    $rotacion.children('option[value="0"]').prop('selected',true);
    $rotacion.parent('div').removeClass('has-error');
    $obsRetiro.val('');
    $empresas.children('option:selected').removeProp('selected');
    $empresas.children('option[value="0"]').prop('selected',true);
    $empresas.parent('div').removeClass('has-error');
    $antiguedadE.val('');
    $grupoBTN.children('button').val(0);
    $grupoBTN.children('button').removeClass('btn-warning');
    $grupoBTN.children('button').addClass('btn-info');
    $deletButton.attr('disabled',true);
    $('#impacto').hide('fast');
    $('#impacto').find('input:radio').prop('checked',false);
    $('#impacto').find('input:radio').removeProp('checked');

    if (accion==1) {
        $grupoBTN.empty();
        $addButton.attr('disabled', true);
    }
    estadoInicialEstadoEmpresarial();
}
function limpiarFechaVencimientocontrato() {
    $fechaVC.val('');
}
// ...
function limpiarCamposTexto() {//Falta remover los atributos data-.removeAttr('data-idPersonaV');
    $generarPDF.hide('slow');
    // Informacion de estado empresarial
    vEstadosEm=[];
    limpiarFormularioEstadoEmpresarial(1);
    // Informacion del empleado
    $CedulaE.val('');
    $PrimerN.val(''); 
    $SegundoN.val('');
    $PrimerA.val('');
    $SegundoA.val('');
    $generoE.val('');
    $btnAccion.val(0);
    $btnAccion.attr('disabled', true);
    // Informacion De Estudios
    $tituloProfecional.val('');
    $tituloEspecializacion.val('');
    $estudiaA.prop('checked',false);
    $estudiaA.removeProp('checked');
    $nameCarrer.val('');
    // Informacion Laboral
    $recursoH.prop('checked',false);
    $recursoH.removeProp('checked');
    $fechaVC.val('');
    $antiguedadE.val('');
    $empresaContratante.val('');
    // Informacion de salud
    $fuma.prop('checked',false);
    $fuma.removeProp('checked');
    $bebidasACL.prop('checked',false);
    $bebidasACL.removeProp('checked');
    $NCigarrillos.val('');
    $AnteUnaEmergencia.val('');
    $cbxFrevuenciaB.children('option[value="0"]').prop('selected',true);
    //Otra información
     $TCamisa.val('');
     $TPantalon.val('');
     $Tzapatos.val('');
     $VCursoAlturas.val('');
     $RquierecursoAlturas.prop('checked', false);
     $RquierecursoAlturas.removeProp('checked');
     $PBrigadaEmergencia.prop('checked', false);
     $PBrigadaEmergencia.removeProp('checked');
     $AlgunComite.prop('checked', false);
     $AlgunComite.removeProp('checked');
     // Informacion Personal
     IDPersonasVive=[];
     $otrasActividades.val('');
     // Partes de la direccion
     $cbxOpt1.children('option').removeProp('selected');//Select
     $cbxOpt1.children('option[value="0"]').prop('selected',true);//Select
     $opt2.val('');//
     $opt3.val('');//
     $opt4.val('');//
     $cbxOpt5.children('option').removeProp('selected');
     $cbxOpt5.children('option[value="0"]').prop('selected',true);
     $opt6.val('');
     // ---
     $barrio.val('');
     $comuna.val('');
     $email.val('');
     $estrato.val('');
     $compañeroP.prop('checked',false);
     $compañeroP.removeProp('checked');
     $('#rowAcompañante').removeData('idPersonaV');
     $('.acor').collapse('hide');
     $madre.prop('checked',false);
     $madre.removeProp('checked');
     $madre.removeData('idPersonaV');
     $padre.prop('checked',false);
     $padre.removeProp('checked');
     $padre.removeData('idPersonaV');
     $nombreAcompañante.val('');
     $celularAcompañante.val('');
     $abuelos.val('0');
     $tios.val('0');
     $hermanos.val('0');
     $otros.val('0');
     $hijos.prop('checked',false);
     $hijos.removeProp('checked');
     $('.acordeon1').collapse('hide');
     $hijastros.prop('checked',false);
     $hijastros.removeProp('checked');
     $('.acordeon2').collapse('hide');
     $('div.hermano').remove();
     $personaEmergencia.val('');
     $('#HijosRow').removeData('idPersonaV');
     $('#HijastrosRow').removeData('idPersonaV');
     $('.limpiarC').val('');
     $tipoVivienda.children('option[value="0"]').prop('selected',true);
     $parentezco.children('option[value="0"]').prop('selected',true);
     $altura.val('');
     $peso.val('');
     $telEm.val('');
     $email.val('');
     $abuelos.removeData('idPersonaV');
     $tios.removeData('idPersonaV');
     $hermanos.removeData('idPersonaV');
     $otros.removeData('idPersonaV');
     //Informacion secundaria 
     $fechaNacimientoE.val('');
     $Lugarnacimiengo.val('');
     $tipoSangre.children('option').removeProp('selected');
     $tipoSangre.children('option[value="0"]').prop('selected',true);
     $telefonoFijo.val('');
     $telefonoCelular.val('');
     // Informacion salarial
     $salarioBase.val('');
     $total.val('0');
     TextAux=[];
     $canAuxilios.removeData('modi');
     $canAuxilios.children('div').hide('slow', function() {
         $(this).remove();
     });
     // Inicializar las variables para el registro de la ficha SDG
     idEstudios=0;
     idLaboral=0;
     idSalud=0;
     idInfoOtra=0;
     idPersonal=0;
     idSecundariaB=0;
     idSalarial=0;
     IDsActividades=[];
     // Actualizar la informacion de los comboBox
     informacionComboBox();
     // Limpiar campos de la informacion personal
     $btnAccion.removeClass('btn-warning');
     $btnAccion.addClass('btn-info');
     $btnAccion.text('Registrar');
     // Limpiar campos de otra informacion
     $Vinculacion.removeAttr('checked');
     // Retirar Clases sobrantes
     retirarClaseErrorElementos();
}
// 
function validacionDeCamposFormulario() {
    var respuesta=1;
    // Informacion del estado empresarial.
    if (vEstadosEm.length==0) {
        respuesta=0;
        $idEstadoEmpresarial.parent('div').addClass('has-error');
    }else{
        $idEstadoEmpresarial.parent('div').removeClass('has-error');
    }
    // validar información salarial
    // Salario Basico
    if ($salarioBase.val()=='') {
        $salarioBase.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $salarioBase.parent('div').removeClass('has-error');
    }
    // Salario Total
    if ($total.val()=='') {
        $total.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $total.parent('div').removeClass('has-error');
    }
    // Promedio salarial
    // if ($('#promSalarial option:selected').val()==0) {
    //     $cbxPromedioSalario.parent('div').addClass('has-error');
    //     respuesta=0;
    // }else{
    //     $cbxPromedioSalario.parent('div').removeClass('has-error');
    // }
    // Auxilios-----
    $canAuxilios.children('div.row').each(function(index, item) {
        if ($(item).find('input[name="montoAux"]').val()=='') {
            $(item).find('input[name="montoAux"]').parent('div').addClass('has-error');
            respuesta=0;
        }else{
             $(item).find('input[name="montoAux"]').parent('div').removeClass('has-error');
        }
    });
    // Clasificacion Mega
    // if ($('#clasiMega option:selected').val()==0) {
    //     $cbxClasificadionM.parent('div').addClass('has-error');
    //     respuesta=0;
    // }else{
    //     $cbxClasificadionM.parent('div').removeClass('has-error');
    // }
    // ...
    // Estudios
    // Grado de escolaridad
    if ($('#gradoEscolaridad option:selected').val()==0) {
        $cbxEstudios.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxEstudios.parent('div').removeClass('has-error');
    }
    // Estudios actuales
    if ($estudiaA.prop('checked')==true) {
        // Que se esta estuciando
        if ($cbxEstudiando.children('option:selected').val()==0) {
            $cbxEstudiando.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $cbxEstudiando.parent('div').removeClass('has-error');
        }
        //Que carrera esta estudiando
        if ($nameCarrer.val()=='') {
            $nameCarrer.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $nameCarrer.parent('div').removeClass('has-error');
        } 
    }
    // ...
    // Estado Laboral
    // Horario de trabajo
    if ($('#horaTrabajo option:selected').val()==0) {
        $cbxHorarioT.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxHorarioT.parent('div').removeClass('has-error');
    }
    // Área de trabajo
    if ($('#areaTrabajo option:selected').val()==0) {
        $cbxAreaTrabajo.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxAreaTrabajo.parent('div').removeClass('has-error');
    }
    // Cargo
    if ($('#cargo option:selected').val()==0) {
        $cbxCargoL.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxCargoL.parent('div').removeClass('has-error');
    }
    // Tipo de contrato
    if ($('#tipoContrato option:selected').val()==0) {
        $cbxTipoContrato.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxTipoContrato.parent('div').removeClass('has-error');
    }
    // ...
    // Informacion secundaria basica
    // Estado civil
    if ($('#estadoCivil option:selected').val()==0) {
        $cbxEstadoCivil.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxEstadoCivil.parent('div').removeClass('has-error');
    }
    // Fecha de nacimiento
    if ($fechaNacimientoE.val()=='') {
        $fechaNacimientoE.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        validarFormatoFecha($fechaNacimientoE.val());
        $fechaNacimientoE.parent('div').removeClass('has-error');
    }
    // Lugar de nacimiento
    if ($Lugarnacimiengo.val()=='') {//Por el momento es un cbx y es obligatorio
        $Lugarnacimiengo.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $Lugarnacimiengo.parent('div').removeClass('has-error');
    }
    // Tipo de sangre
    if ($('#tipoSangre option:selected').val()==0) {
        $tipoSangre.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $tipoSangre.parent('div').removeClass('has-error');
    }
    // EPS
    if ($('#EPS option:selected').val()==0) {
        $cbxEPS.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxEPS.parent('div').removeClass('has-error');
    }
    // AFP
    if ($('#AFP option:selected').val()==0) {
        $cbxAFP.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxAFP.parent('div').removeClass('has-error');
    }
    // Validacion de telefonos (Obligatoriamente debe existir un celular como minimo)
    if ($telefonoFijo.val()=='' && $telefonoCelular.val()=='') {
        $telefonoFijo.parent('div').addClass('has-error');
        $telefonoCelular.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $telefonoFijo.parent('div').removeClass('has-error');
        $telefonoCelular.parent('div').removeClass('has-error');
    }
    // ...
    // Informacion de salud
    // Funa??
    if ($fuma.prop('checked')==true) {
        // Numero de cigarrillos
        if ($NCigarrillos.val()=='') {
            $NCigarrillos.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $NCigarrillos.parent('div').removeClass('has-error');
        }
        //
    }else{
        $NCigarrillos.parent('div').removeClass('has-error');
    }
    // Consume licor?
    if ($bebidasACL.prop('checked')==true) {
        if ($cbxFrevuenciaB.children('option:selected').val()==0) {
            $cbxFrevuenciaB.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $cbxFrevuenciaB.parent('div').removeClass('has-error');
        }
    }else{
        $cbxFrevuenciaB.parent('div').removeClass('has-error');
    }
    // ...
    // Informacion Personal
    // Municipio
    if ($('#municipio option:selected').val()==0) {
        $cbxMunicipio.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $cbxMunicipio.parent('div').removeClass('has-error');
    }
    // Tipo de vivienda
    if ($('#tipoVivienda option:selected').val()==0) {
        $tipoVivienda.parent('div').addClass('has-error');
        respuesta=0;
    }else{
        $tipoVivienda.parent('div').removeClass('has-error');
    }
    // Acompañante (Por defecto los familiares: abuelos, tios, hermanos, otros por defecto van a ser 0)
    if ($compañeroP.prop('checked')==true) {
        // Nombre del acompañante
        if ($nombreAcompañante.val()=='') {
            $nombreAcompañante.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $nombreAcompañante.parent('div').removeClass('has-error');
        }
        // Celular del acompañanate
        if ($celularAcompañante.val()=='') {
            $celularAcompañante.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $celularAcompañante.parent('div').removeClass('has-error');
        }
    }
    // Hijos
    if ($hijos.prop('checked')==true) {
        respuesta=validarHijosOHijastros(1,respuesta);
    }
    // Hijastros
    if ($hijastros.prop('checked')==true) {
        respuesta=validarHijosOHijastros(2,respuesta);
    }
    // Persona en caso de emergencia, si cualquiera de estos campos es diligenciado entonces por defecto los demas son obligatorios
    if ($personaEmergencia.val()!='' || $parentezco.children('option:selected').val()!=0 || $telEm.children('option:selected').val()) {
        // Nombre de la persona en caso de emergencia
        if ($personaEmergencia.val()=='') {
            $personaEmergencia.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $personaEmergencia.parent('div').removeClass('has-error');
        }
        // Parentezco de la persona en caso de emergencia
        if ($parentezco.children('option:selected').val()==0) {
            $parentezco.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $parentezco.parent('div').removeClass('has-error');
        }
        // Telefono de la persona en caso de emergencia
        if ($telEm.val()=='') {
            $telEm.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $telEm.parent('div').removeClass('has-error');
        }
    }

    return respuesta;
}

function validarFormatoFecha(campo) {
      var RegExPattern = /^\d{1,2}\/\d{1,2}\/\d{2,4}$/;
      if ((campo.match(RegExPattern)) && (campo!='')) {
            return true;
      } else {
            return false;
      }
}

function validarHijosOHijastros(op, respuesta) {
    var $element;
    $('#'+(op==1?'CantidadDeHijos':'CantidadDeHijastros')).children('div').each(function(index, item) {
        // Nombre del hijo X
        $element=$(item).children('div').eq(1).find('input[name="nameHijo"]');
        // ...
        if ($element.val()=='') {
            // ...
            $element.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $element.parent('div').removeClass('has-error');
        }
        $element=$(item).children('div').eq(1).find('input[name="fechaNH"]');
        // Fecha de nacimiento del hijo X
        if ($element.val()=='') {
            // ...
            $element.parent('div').addClass('has-error');
            respuesta=0;
        }else{
            $element.parent('div').removeClass('has-error');
        }
    });
    return respuesta;
}

function retirarClaseErrorElementos() {
    //Información salarial 
    $salarioBase.parent('div').removeClass('has-error');
    $total.parent('div').removeClass('has-error');
    $cbxPromedioSalario.parent('div').removeClass('has-error');
    $cbxClasificadionM.parent('div').removeClass('has-error');
    // Información sobre los estudios
    $cbxEstudios.parent('div').removeClass('has-error');
    // Información laboral
    $cbxHorarioT.parent('div').removeClass('has-error');
    $cbxAreaTrabajo.parent('div').removeClass('has-error');
    $cbxCargoL.parent('div').removeClass('has-error');
    $cbxTipoContrato.parent('div').removeClass('has-error');
    // Información secundaria basica
    $cbxEstadoCivil.parent('div').removeClass('has-error');
    $fechaNacimientoE.parent('div').removeClass('has-error');
    $Lugarnacimiengo.parent('div').removeClass('has-error');
    $tipoSangre.parent('div').removeClass('has-error');
    $cbxEPS.parent('div').removeClass('has-error');
    $cbxAFP.parent('div').removeClass('has-error');
    // Informacion Personal
    $cbxMunicipio.parent('div').removeClass('has-error');
    $tipoVivienda.parent('div').removeClass('has-error');
    $nombreAcompañante.parent('div').removeClass('has-error');
    $personaEmergencia.parent('div').removeClass('has-error');
    $parentezco.parent('div').removeClass('has-error');
    $telEm.parent('div').removeClass('has-error');
    $('.limpiarC').parent('div').removeClass('has-error');
}

//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}

// Fin del CRUD Ficha SDG--------------------------------------------------------

// Local Storage
// $("#btnDescargar").click(function () {
// var Datos = JSON.parse(getLocalStorage("busquedaDatosTotal"));
// var jsonArr = [];
// $.each(Datos, function (index, value) {
// jsonArr.push({
// ÚLTIMO_ESTADO: value.UltimoEstadoStr,
// FECHA_DE_INGRESO: value.FechaIngresoStr,
// SKU: value.SKU,
// UBICACIÓN: value.Ubicacion,
// MARCA: value.Marca,
// DESCRIPCIÓN: value.Descripcion,
// COLOR: value.Color,
// MES: value.Mes,
// DISPONIBLE: value.Disponible,
// PRÉSTAMO: value.Prestamo
// });
// });

// alasql('SELECT * INTO XLSX("Búsqueda.xlsx",{headers:true}) FROM ?', [jsonArr]);
// });