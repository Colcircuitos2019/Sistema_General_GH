    // Variables
    var $fechaSolicitud = $('#fechaSolicitud');
    var $solicitantes = $('#solicitante');
    var $concepto = $('#concepto');
    var $otrasCaudad = $('#descripcion');
    var $content = $('#otrasCausas');
    var $codigo = $('#codigo');
    var $btnValidar = $('#ValidarCP');
    var $btnTerminarP = $('#Pedir');
    var $pass = $('#pwd');
    var codigoP = '';
    var $ConsultarPermiso = $('#conPermiso');
    var $documentoE = $('#documentoE');
    // Variables del formulario
    var $fechaPermiso = $('#fechaPermiso');
    var $solicitante = $('#solicitante');
    var $Concepto = $('#concepto');
    var $desde = $('#timepicker3');
    var $momento = $('#momento');
    var $descripcion = $('#descripcion');
    var $tablaPermisosEmpleado = $('#tblPermisosEmpleado');
    // 
    // Variables del modal
    var $fechaSolicitudM = $('#fechaSM');
    var $fechaPermisoM = $('#fechaPM');
    var $solicitanteM = $('#hPermiso');
    var $conceptoM = $('#conceptoM');
    var $horarDesde = $('#horaDM');
    var $horaHasta = $('#horaHM');
    var $descripcionM = $('#descripM');
    var $codigoPermiso = $('#code');
    var $contenctM= $('#descripcionM');
    // Modals
    var $confirmar = $('#Confirmar');
    var $consultarPermisol = $('#consultarPermisos');
    var $confirmarCode = $('#ConfirmarCodigo');
    var $btnActualizarP= $('#btnActualizar');
    var $modificarPermiso= $('#modificarPermiso');
    // Esconder descripcion
    $content.toggle(1);
    // $contenctM.toggle(1);
    //DOM
    $(document).ready(function() {
        //Cargar la fecha actual en la que se va a registrar un permiso=================
        $.post(baseurl + 'Alimentacion/cPedidos/consultarFechaPedido', function(data) {
            var fecha = JSON.parse(data);
            $fechaSolicitud.text(fecha);
        });
        // Consulta todos los solicitantes
        consultarEmpleados();
        // Consultar conceptos de permisos
        consultarConceptos(1);
        //Cuando se seleccione el concepto de otra causa mostrara el campo de descripcion obligatorio.
        $concepto.change(function(event) {
            if ($(this).val() == 7) {
                $content.toggle(400);
            } else {
                $content.hide(450);
            }
        });
        // Click en el boton validar permiso.
        $btnValidar.click(function() {
            if ($codigo.val() != '' && $codigo.val().length == 5) {
                validarCodigoPermiso($codigo.val(), $(this).val());
            } else {
                // Mostrar mensaje de que falta algun campo por diligenciar.
                // swal();
            }
        });
        // Click en el boton terminar permiso.
        $btnTerminarP.click(function(event) {
            if ($pass.val() != '' && $pass.val().length == 4) {
                validarUsuario($btnTerminarP.val());
            } else {
                // Mostrar mensaje de alerta al ingresar la contraseña
                swal('Alerta!', 'La contraseña no es valida.', 'warning');
            }
        });
        // Clcik en el boton realizar
        $('#realizarP').click(function(event) {
            // Validar que los campos obligatorios no esten vacios.
            if($fechaPermiso.val()!='' && $('#solicitante option:selected').val() > 0 && $('#concepto').val() > 0 && $desde.val()!=''){
                $confirmarCode.modal('show');
            }else{
                // Mostrar mensaje de alerta de campos faltante.
                swal('Alerta!','Falta algun campo por diligenciar.','warning');
            }
        });
        // Combo box de solicitante
        $solicitante.change(function(event) {
            $btnValidar.val($(this).val());
        });
        // Cargar Time Piker
        $('.tiempos').timepicker({
            minuteStep: 5,
            showInputs: false,
            disableFocus: true
        });
        //Consultar Permiso
        $ConsultarPermiso.click(function(event) {
            consultarPermisoEmpleado($documentoE.val(), '', 1);
        });
        // Cuando se oculte el modal de consultar el permiso.
        $consultarPermisol.on('hidden.bs.modal', function(event) {
            $tablaPermisosEmpleado.empty();
            $documentoE.val('');
        });
        // Click en el boton actualizar del modal modificar permiso.
        $btnActualizarP.click(function() {
            $btnTerminarP.val($btnActualizarP.val());
            $confirmar.modal('show');
        });
        // Cuando se cierre el modal
        $confirmar.on('hidden.bs.modal', function(event) {
            $documentoE.val('');
        });
    });
    // Fin del DOM
    // Vista Administrativa========================================================================================================================================
    // Vista de administracion de permisos (Facilitador, Gestor humano)
    function consultarEmpleadosPermisos() {
        $.post(baseurl + 'Empleado/cEmpleado/consultarEmpleadosPermiso', function(data) {
            var result = JSON.parse(data);
            // Crear tabla
            $('#tblEmpleadosPermiso').empty();
            // html de la Tabla se empelados
            $('#tblEmpleadosPermiso').html('<table class="display" id="EmpeladosPermiso">' + '<thead id="cabeza">' + '<th>Documento</th>' + '<th>Nombre</th>' + '<th>Rol</th>' + '<th>Genero</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpo">' + '</tbody>' + '</table>');
            var $cuerpo = $('#cuerpo');
            $.each(result, function(index, row) {
                $cuerpo.append('<tr>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + clasificarRol(row.idRol) + '</td>' + '<td>' + calsificarGenero(row.genero) + '</td>' + '<td>' + '<button value="' + row.documento + '" onclick="mostrarModal(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button value="' + row.documento + '" type="button"' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
            });
            // Inicializacion de data table
            $('#Empelados').DataTable();
        });
    }
    // Clasificar tipo de rol
    function clasificarRol(rol) {
        if (rol == 1) {
            return '<span><small class="label bg-blue">Operario</small></span>'; //Operario
        } else {
            return '<span><small class="label bg-yellow">Administrativo</small></span>'; //Administrativo
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
    // Fin vista Administrativa====================================================================================================================================
    // Vista de gestion de permisos(Empelados)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    function consultarPermisoEmpleado(doc, cod, accion) {
        $.post(baseurl + 'Empleado/cPermiso/consultarPermisoEmpleado', {
            documento: doc,
            codigo: cod,
            fecha: '-1'
        }, function(data) {
            var result = JSON.parse(data);
            // 
            if (accion == 1) { //Cargar tabla de permisos del empleado.
                // debugger;
                // console.log(result);
                $tablaPermisosEmpleado.empty();
                $tablaPermisosEmpleado.html('<table class="display" id="tblPE">' + '<thead id="cabezaE">' + '<th>Código</th>' + '<th>Fecha Solicitud</th>' + '<th>Fecha Permiso</th>' + '<th>Desde</th>' + '<th>Momento</th>' + '<th>Estado</th>' + '<th>Acciones</th>' + '</thead>' + '<tbody id="cuerpoE">' + '</tbody>' + '</table>');
                var $cuerpo = $('#cuerpoE');
                $.each(result, function(index, row) {
                    $cuerpo.append('<tr>' + '<td>' + '<span><small class="estadoE">' + row.Codigo + '</small></span>' + '</td>' + '<td>' + row.fecha_solicitud + '</td>' + '<td>' + row.fecha_permiso + '</td>' + '<td>' + row.desde12 + '</td>' + '<td>' + row.momento + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td>' + (row.estado==2?'':'<button value="' + row.idPermiso + '" onclick="realizarAccion(1,this.value,\'' + row.Codigo + '\',\'' + doc + '\',\'' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '\')"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button value="' + row.idPermiso + '" onclick="realizarAccion(2,this.value,\'' + row.Codigo + '\')"  type="button" class="btn btn-danger tamaño"><span><i class="fas fa-trash-alt"></i>Eliminar</span></button>') + '</td>' + '</tr>');
                });
                // 
                $('#tblPE').DataTable();
                // 
            } else if (accion == 2) { 
            //Cargar modal de modificar. y mostrar datos del permiso
                $.each(result, function(index, row) {
                    consultarConceptos(2);
                    $fechaSolicitudM.val(row.fecha_solicitud);
                    $fechaPermisoM.val(row.fecha_permiso);
                    setTimeout(function() {
                        $('select[name=subConcepto]').val(row.idConcepto);
                        $conceptoM.selectpicker('refresh');
                    }, 100);
                    $horarDesde.val(row.desde12);
                    // $horaHasta=row.;
                    $('#momentoN').text(row.momento);
                    $codigoPermiso.text(cod);
                    $btnActualizarP.val(row.documento+';2;'+cod);//Modificar
                    $descripcionM.val(row.descripcion);
                });
            }
        });
    }
    // Que accion se va a realizar 1= editar, 2=Eliminar
    function realizarAccion(accion, idPermiso, codigo, documento, nombre) {
        // debugger;
        if (accion == 1) { //Editar permiso
            //
            $solicitanteM.text('Permiso de:  ' + nombre);
            consultarPermisoEmpleado(documento, codigo, 2);
            //
            $modificarPermiso.modal('show');
            // 
        } else if (accion == 2) { //Eliminar permiso
            eliminarPermisoEmpleado(codigo, idPermiso);
        }
    }
    // Se encarga de eliminar solo el permiso del empleado.
    function eliminarPermisoEmpleado(cod, idPermiso) {
        // debugger;
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se eliminara el permiso del empleado.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                $.post(baseurl + 'Empleado/cPermiso/eliminarPermisoEmpleado', {
                    codigo: cod,
                    permiso: idPermiso
                }, function(data) {
                    if (data == 1) {
                        swal('Realizado!', 'El permiso fue eliminado correctamente.', 'success');
                        $consultarPermisol.modal('hide');
                    }
                });
            }
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

    // Consultar Todos los conceptos que puede tener un permiso
    function consultarConceptos(op) {
        $.post(baseurl + 'Empleado/cConcepto/consultarConceptos', function(data) {
            var result = JSON.parse(data);
            (op == 1 ? $concepto : $conceptoM).empty();
            (op == 1 ? $concepto : $conceptoM).append('<option value="0" >Seleccione...</option>');
            $.each(result, function(index, row) {
                (op == 1 ? $concepto : $conceptoM).append('<option value="' + row.idConcepto + '">' + row.concepto + '</option>');
            });
            (op == 1 ? $concepto : $conceptoM).selectpicker('refresh');
        });
    }

    // Se encarga de registrar el permiso del empleado.
    function registrarModificarPermisoEmpleado(codigo, doc, accion) { //Falta el modificar
        // 
        var tiempo = convertidorHoraFormato24((accion==1?$desde:$horarDesde).val());
        // 
        // Hay tres tipos de evento de horario 1=salida temprano, 2= llegada tarde y 3=salida e ingreso.//Falta uno
        $.post(baseurl+'Empleado/cPermiso/validarFechaPermiso', {fecha:  formatoFecha(String((accion==1?$fechaPermiso:$fechaPermisoM).val()))}, function(data) {//Validar que la fecha del permiso no sea menor a la fecha actual.
            if (data==1) {
                // Validar que no exista otro permiso para esta misma fecha del mismo empleado
                $.post(baseurl+'Empleado/cPermiso/validarExistenciaPermisoFecha', 
                    {
                        doc: doc,
                        fecha: formatoFecha(String((accion==1?$fechaPermiso:$fechaPermisoM).val()))
                    }, function(data) {
                    if (data==0) {
                        $.post(baseurl+'Empleado/cAsistencia/horarioEmpleadoAsistenciaPermiso', //Horario del día en curso
                            {documento: doc}, function(data) {
                                if (data>0) {//Si existe el id del horario
                                    $.post(baseurl + 'Empleado/cPermiso/ValidarHorasDelPermiso', {  //Falta mandar el id del horario del empleado
                                        cod: codigo,
                                        hora: tiempo,
                                        horario: data
                                    }, function(data) {
                                        // debugger;   
                                        if (data == 1) {
                                            // 1=registrar y 2 =modificar
                                            $.post(baseurl + 'Empleado/cPermiso/registrarModificarPermiso', {//seleccionarIDHorarioEmpelado
                                                documento: doc,
                                                cod: codigo,
                                                fechaP: formatoFecha(String((accion==1?$fechaPermiso:$fechaPermisoM).val())),
                                                concepto: Number((accion==1?$('#concepto option:checked'):$('#conceptoM option:checked')).val()),
                                                desde: tiempo,
                                                des: (accion==1?$descripcion:$descripcionM).val(),
                                                acc: accion
                                            }, function(data) {
                                                // ...
                                                if (JSON.parse(data) == 1) {
                                                    swal('Realizado!', 'El permiso fue '+(accion==1?'registrado':'modificado')+' exitosamente', 'success');
                                                    $modificarPermiso.modal('hide');
                                                    $consultarPermisol.modal('hide');
                                                    $confirmar.modal('hide');
                                                    estadoInicial();
                                                }
                                            });
                                        } else {
                                            // El mensaje, el tiempo que ingreso para el permiso no es valido.
                                            swal('Alerta!', 'La hora que selecciono para el permiso no es valido.', 'error');
                                        }
                                    });
                                }else{
                                    // Mensaje de alerta
                                    swal('Alerta!', 'El empleado no tiene un horario asignado.', 'warning');
                                }
                            }); 
                    }else{
                        swal('Alerta!','Ya tienes un permiso para esta fecha.','warning');
                    }
                });
            }else{
                swal('Alerta!','No puede ingresar una fecha menor al día actual.','warning');
            }
        });
    }

    // se encarga de validar que el código del permiso exista.
    function validarCodigoPermiso(codPermiso, doc) {
        $.post(baseurl + 'Empleado/cPermiso/validarCodigoPermiso', {
            cod: codPermiso,
            documento: doc
        }, function(data) {
            var doc = JSON.parse(data);
            if (doc != 0) {
                // Validar que no exista ningun permiso con este codigo.
                $.post(baseurl + 'Empleado/cPermiso/validarExistenciaPermisoEmpleado', {
                    codigo: codPermiso
                }, function(data) {
                    // No existe ninguno permiso con este código.
                    if (data == 1) {
                        // debugger;
                        // Se encarga de validar que el codigo del permiso no tenga más de una semana de haberlo generado para poder registrarlo.
                        $.post(baseurl + 'Empleado/cPermiso/validarTiempoCodigoPermiso', {
                            cod: codPermiso
                        }, function(data) {
                            // El código aun tiene fecha valida.
                            if (data == 1) {
                                // Mostrar mensaje de confirmación.
                                $confirmarCode.modal('hide');
                                $btnTerminarP.val(doc+';1;'+codPermiso);
                                // codigoP = codPermiso;
                                $confirmar.modal('show');
                            } else {
                                // Mensaje, El código esta vencido, porfavor dirijase a donde su facilitador encargado para renaudar la fecha.
                                swal("Alerta!", 'Este codígo ya esta vencido, por favor diríjase a donde su facilitador para reactivarlo.', "warning");
                            }
                        });
                    } else {
                        // Mensaje de que la persona ya posee un permiso registrado y que no puede registrar más.
                        swal("Alerta!", 'Ya tiene un permiso registrado, no puede registrar más.', "warning");
                    }
                });
            } else {
                // Mensaje de que esta persona no tiene un codigo de permiso generado.
                swal("Alerta!", 'Esta Persona no coincide con el código del permiso', "error");
            }
        });
    }
    //Retornair item estado
    function clasificarEstado(estado) {//Clasifica el estado de cada proveedor
        if (estado == 1) {
            return '<span><small class="|">Activo</small></span>';
        } else if(estado == 2) {
            return '<span><small class="codigoP">Terminado</small></span>';
        }
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
                return (v1[0].length == 1 ? '0' : '')+ v[0];
            }
        }
    }
    // Se encarga de convertir la hora en el formato admitido por el timepicker
    // function formatoHora(hora) {
    //     // body...
    // }
    // Se encarga de volver al estado inicial el formulario.
    function estadoInicial() {
        $fechaPermiso.val('');
        $descripcion.val('');
        consultarConceptos(1);
        consultarEmpleados();
    }

    function validarUsuario(info) {
        var v= info.split(';');//Documento;Acción 1=Registrar y 2=Modificar.
        // v[0]=Documento, v[1]=Accion, v[2]=Codigo
        // debugger;
        $.post(baseurl + 'Empleado/cPermiso/validarUsuario', {
            documento: v[0],//Documento
            password: $pass.val()
        }, function(res) {
            if (res == 1) {
                registrarModificarPermisoEmpleado(v[2], v[0], v[1]);//Codigo Permiso-Documento-Acción
            } else {
                swal('Alerta!', 'La contraseña es incorrecta o el empleado no existe, porfavor intentelo nuevamente.', 'error');
            }
        });
    }
    //Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
    function formatoFecha(fecha) {
        var v = fecha.split('-');
        return v[2] + '-' + v[1] + '-' + v[0];
    }
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<