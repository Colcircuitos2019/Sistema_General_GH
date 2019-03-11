//Todo este código se puede optimizar y experimentar implementando ES6 
//Variables
var id;
var $selecProducto = $('#pro'); //Principal
var $selecProductoM = $('#Upro');
var $selectProveedor = $('.proveedores'); //Todos los combos de proveedores
// var $radioD = $('D'); //Boton radio principal
// var $radioA = $('A'); //Boton radio principal
var $tabla = $('#tblLineas'); //Tabla de pedidos priencipal y unica
var $cuerpo = $('#cuerpo'); //tBody de la tabla
var con = 0; //Variable contadora de identificadores de posición(rows)
var $canti = $('#cant');
var $totalPrecio = $('#Total');
var $actualizar = $('#btnActualizar');
var $pedir = $('#Pedir');
var $user = $('#usr');
var $pass = $('#pwd');
var $btnRealizar = $('#realizar');
var $titulo = $('#titulo');
var $confirmar = $('#Confirmar');
var eliminarL = [];
var i = 0;
var idPedido;
var $sel = $('#selProveedor');
var $selM = $('#selProveedorM');
var $btnLiquidacion = $('#btnLiquidacion');
var $documentoLiquidacion = $('#documentoL');
var $fechaILiquidacion = $('#fechaInicioL');
var $fechaFLiquidacion = $('#fechaFinL');
var $divTableLiquidacion = $('#tablaDeLiquidacion');
//Inputs
var name;
var idP;
var cantidad;
var evento;
var precioUnitario;
var idProveedor;
var idProducto;
//Dom
$(document).ready(function() { //El DOM
    // $('#tblConsultarProductos').DataTable();
    //Cargar la fecha de pedidos===============================================================================================================
    $.post(baseurl + 'Alimentacion/cPedidos/consultarFechaPedido', function(data) {
        var fecha = JSON.parse(data);
        $('#FechaP').text(fecha);
    });
    //Cargar Combo de proveedores==============================================================================================================
    // consultarProveedores($('#selProveedor'));
    // $('#D').click(function(event) {
    //     console.log('Si se clickio');
    // });
    //Cuando se cambie el proveedor===============================================================================================================
    $('#selProveedor ').change(function() {
        $('#selProveedor option:selected').each(function() {
            id = $('#selProveedor').val();
        });
        consultarProductosProveedor(id, $selecProducto, 1, 0); //Procedimiento de cargar el combobox
    });
    //Se ejecuta cuando de haga un cambio en el selector de proveedores de el modal "Modificar pedido"
    $('#selProveedorM2').change(function() {
        $('#selProveedorM2 option:selected').each(function() {
            id = $('#selProveedorM2').val();
        });
        consultarProductosProveedor(id, $('#cuerpoM'), 2, 0); //Procedimiento de cargar la tabla
    });
    //Se ejecuta cuando de haga un cambio en el selector de proveedores de el modal "Modificar pedido"
    $('#selProveedorM1').change(function() {
        $('#selProveedorM1 option:selected').each(function() {
            id = $('#selProveedorM1').val();
        });
        consultarProductosProveedor(id, $selecProductoM, 1, 0); //Procedimiento de cargar el combobox
    });
    //Cuando se haga click en el boton "Agregar"
    $('#Agregar').click(function(event) {
        event.preventDefault();
        //Metodo para agregar linea de pedido
        agregarLineaProducto();
    });
    //Cuando se haga click en el actualizar pedido
    $actualizar.click(function(event) {
        if ($('#selProveedorM1 option:selected').val() > 0 && $('#Upro option:selected').val() > 0 && $('input:radio[name="optradioM"]:checked').val() != undefined && $('#Ucant').val() > 0 && $('#Ucant').val() != '') {
            actualizarLineaPedido($(this).val()); //Posicion de la fila a modificar
        } else {
            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'Todos los campos son obligatorios.',
                showConfirmButton: false,
                timer: 2500
            });
        }
    });
    //Realizar el pedido
    $pedir.click(function(event) {
        tipoAccion($(this).val());
    });
    //Consultar pedidos}
    $('#formConsultarP').submit(function(event) {
        event.preventDefault();
        consultarPedidos($('#docP').val());
    });
    //Al cerrar la ventana de confirmacion vuelve el valor al estado inicial 
    $('#cerrarConfirmar').click(function(event) {
        $pedir.val('0');
    });
    //Se encarga de limpiar los campos cuando se cierre el modal (Consultar Pedidos)
    $('#consultarPedidos').on('hidden.bs.modal', function() {
        limpiarConsultarPedidos($('#cuerpoP'));
    });
    $('#Confirmar').on('hidden.bs.modal', function() {
        $user.val('');
        $pass.val('');
    });
    $('#productosModal').click(function(event) {
        $('#Productos').modal('show');
        consultarProveedores($('#selProveedorM2'), 0, 2);
    });
    //Se encarga de limpiar el formulario principal
    $('#Limpiar').click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Limpiara por completo el formulario.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                EstadoIniciarl();
            }
        });
    });
    //Se encarga de mostrar el modal siempre y cuando el cuerpo de la tabla este con una linea de producto
    $('#realizarP').click(function() { //
        //Validar las restricciones de pedidos (rango de horas)
        $.post(baseurl + 'Alimentacion/cPedidos/restriccionPedidos', function(res) {
            if (res == 1) { //Si la hora del pedio esta dentro del rango de la restricción va a realizar cualquier accion (Registrar, Modificar o Eliminar)
                if ($cuerpo.children().length > 0) { //Si existe una linea de producto en el cuerpo de la tabla
                    //Muestra el model
                    $confirmar.modal('show');
                } else { //Si noe xiste
                    swal({
                        position: 'center',
                        type: 'warning',
                        title: 'Alerta!',
                        text: 'Para realizar un pedido se necesita tener minimo una linea de pedido.',
                        showConfirmButton: false,
                        timer: 2500
                    });
                }
            } else {
                swal({
                    position: 'center',
                    type: 'warning',
                    title: 'Alerta!',
                    text: 'No es hora de gestionar pedidios.',
                    showConfirmButton: false,
                    timer: 2500
                });
            }
        });
    });
    //Hace que el navegador pregunte antes de salir o recargar la pagina
    window.onbeforeunload = preguntarAntesDeSalir;
    function preguntarAntesDeSalir() {
        return "¿Seguro que quierese salir?";
    }
    //Fin de pregunta del navegador
    // Se encarga de realizar la peticion al controlador de realizar la liquidación correspondiente
    $btnLiquidacion.click(function(event) {
        var existePedido = 0;
        var valorTotal = 0;
        // Valida que los campos oblicatorios esten diligenciados correctamente
        if ($documentoLiquidacion.val() != '' && $fechaILiquidacion.val() != '' && $fechaFLiquidacion.val() != '') {
            $.post(baseurl + 'Alimentacion/cPedidos/liquidacionEmpledoFechas', {
                documento: $documentoLiquidacion.val(),
                fechaI: formatoFecha($fechaILiquidacion.val()),
                fechaF: formatoFecha($fechaFLiquidacion.val())
            }, function(data) {
                var result = JSON.parse(data);
                //
                $divTableLiquidacion.empty();
                $divTableLiquidacion.html('<table class="display" id="tblLiquidacionE">' + '<thead>' + '<th>Fecha</th>' + '<th>Hora</th>' + '<th>Valor</th>' + '</thead>' + '<tbody id="cuerpoLiqui">' + '</tbody>' + '</table>');
                var $cuerpoL = $('#cuerpoLiqui');
                $.each(result, function(index, row) {
                    existePedido++;
                    if (existePedido == 1) {
                        // Colocar nombre de la persona y empresa
                        $('#nombreLiquidado').text(row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + ' ');
                        $('#empresaLiquidado').text(row.nombre);
                    }
                    // Monto total
                    valorTotal += Number(row.valor);
                    $cuerpoL.append('<tr>' + '<td>' + row.fecha + '</td>' + '<td>' + row.hora + '</td>' + '<td>' + convertirNumeroMonedaPesos(row.valor) + '</td>' + '</tr>');
                });
                $('#montoLiquidacion').text(convertirNumeroMonedaPesos(String(valorTotal)));
                $('#tblLiquidacionE').DataTable();
            });
        } else {
            swal('Alerta!', 'Falta algun campo por diligenciar.', 'warning');
        }
    });
    // Vaciar el modal de liquidación
    $('#LiquidacionM').on('hidden.bs.modal', function(event) {
        $divTableLiquidacion.empty();
        $('#montoLiquidacion').text('');
        $('#nombreLiquidado').text('');
        $('#empresaLiquidado').text('');
        $documentoLiquidacion.val('');
        $fechaILiquidacion.val('');
        $fechaFLiquidacion.val('');
    });
    // 
    $('#Productos').on('hidden.bs.modal', function() {
        $('#cuerpoM').empty();        
    });
});
//Fin del DOM
//Metodos =======================================================================================================================================================
function convertirNumeroMonedaPesos(numero) {
    var res = 0;
    switch (String(numero).length) {
        case 6:
            res = 3; //STR de tres digitos
            break;
        case 5:
            res = 2; //STR de dos digitos
            break;
        case 4:
            res = 1; //STR de un digitos
            break;
        case 3:
            return '$' + String(numero); //Retorna directamente
            break;
    }
    var num1 = String(numero).substr(0, res);
    return '$' + num1 + '.' + String(numero).substr(res);
}

function convertirMonedaPesosNumero(moneda) {
    if (moneda.length == 1) {
        return 0; //Para ningun precio
    } else {
        var num = String(moneda).substr(1);
        if (num.length == 3) { //Para precio de tres dijitos
            return num;
        } else { //Para precio de más de tres dijitos
            var cuerpo = num.split('.');
            return cuerpo[0] + cuerpo[1];
        }
    }
}

function consultarProveedores($selec, cargo, ac) {
    $.post(baseurl + 'Alimentacion/cProveedor/consultarProveedores', {
        op: ac
    }, function(data) {
        var resulSet = JSON.parse(data);
        $selec.empty();
        $selec.html('<option value="0">Seleccione...</option>');
        $.each(resulSet, function(resulSet, row) {
            if (row.estado == 1) {
                $selec.each(function() {
                    $(this).append('<option value="' + row.idProveedor + '">' + row.nombre + '</option>');
                    if (cargo == 3) {
                        //Seleccionar proveedor de la vista modificar pedido
                        $('select[name=subProveedor]').val(idProveedor);
                    }
                });
            }
        });
        // Todo esto se puede simplificar con un operador ternario...
        // if (cargo == 0) {
        //     $selecProducto.empty();
        //     $selecProducto.html('<option value="0">Seleccione...</option>');
        //     // $selecProducto.selectpicker('refresh');
        // } else if (cargo == 1) {
        //     $selecProductoM.empty();
        //     $selecProductoM.html('<option value="0">Seleccione...</option>');
        //     // $selecProductoM.selectpicker('refresh');
        // }
        $selec.selectpicker('refresh');
    });
}
//Sen encarga de buscar el pedido que el empleado realizo en el dia
function consultarPedidos(doc) {
    var $cuerpo = $('#cuerpoP');
    var filas = 0;
    $cuerpo.empty(); //Limpiamos la tabla
    $.post(baseurl + 'Alimentacion/cPedidos/consultarPedidos', {
        documento: doc,
        op: '0' //Consultar Pedido Por documento
    }, function(data) {
        result = JSON.parse(data);
        //Informacion
        $.each(result, function(index, row) {
            filas++;
            $cuerpo.append('<tr>' + '<td>' + row.idPedido + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + '</td>' + '<td>' + row.hora + '</td>' + '<td data-precio="' + row.total + '">' + row.total1 + '</td>' + '<td>' + (row.estado == 0 ? '<button value="1" onclick="modificarAccionBoton(this.value)"  type="button" class="btn btn-primary tamaño editar"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button value="2" type="button"  class="btn btn-danger tamaño eliminar" onclick="modificarAccionBoton(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar' + '</span></button>' : '<button type="button" class="btn btn-success">Realizado</button>') + '</td>' + '</tr>');
        });
        //Mostrar mensaje
        if (filas == 0) {
            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'El empleado no tiene ningun pedido realizado hoy.',
                showConfirmButton: false,
                timer: 2500
            });
        }
    });
}

function modificarAccionBoton(value) { //0=RealizarPedido && 1=Editar && 2=Eliminar
    $pedir.val(value);
    if (value != 1) {
        if (value == 2) {
            $.post(baseurl + 'Alimentacion/cPedidos/restriccionPedidos', function(res) {
                if (res == 1) {
                    $confirmar.modal('show');
                } else {
                    swal({
                        position: 'center',
                        type: 'warning',
                        title: 'Alerta!',
                        text: 'No es hora de gestionar pedidos',
                        showConfirmButton: false,
                        timer: 2500
                    });
                }
            });
        } else {
            $confirmar.modal('show');
        }
    } else {
        $('#consultarPedidos').modal('toggle'); //Se esconde el modal de consultar pedidos
        enviarEditarPedido();
    }
}
//Se encarga de definir que accion va a realizar al precionar el boton Terminar Pedido(0=RealizarPedido && 1=Editar && 2=Eliminar)
function tipoAccion(op) {
    switch (Number(op)) {
        case 0:
            realizarPedido();
            break;
        case 1:
            editarPedido();
            break;
        case 2:
            eliminarPedido();
            break;
    }
}
//Se encarga de eliminar el pedido
function eliminarPedido() {
    var $cuerpos = $('#cuerpoP');
    var idPedido = $cuerpos.find('tr').find('td').eq(0).text();
    //validacíon de confirmacíon de accíon
    if ($user.val().trim() != '' && $pass.val().trim() != '') {
        //Validar datos usuario
        $.post(baseurl + 'Alimentacion/cPedidos/validarUsuario', {
            documento: $user.val(),
            password: $pass.val(),
            idP: Number(idPedido)
        }, function(res) {
            //Eliminar Pedido
            if (res == 1) {
                $('#consultarPedidos').modal('toggle'); //Se esconde el modal de consultar pedidos
                $('#Confirmar').modal('toggle');
                swal({ //Mensaje de confirmacion para realizar la accion.
                    title: '¿Estas seguro?',
                    text: "Se eliminara el pedido por completo.",
                    type: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Si'
                }).then((result) => {
                    //Se valida si se acpeta la eliminacion
                    if (result.value) {
                        $.post(baseurl + 'Alimentacion/cPedidos/eliminarPedido', {
                            idPedido: Number(idPedido) //Identificador del pedido
                        }, function(data) {
                            if (data == 1) { //Mensaje de confirmacion de la accion ejecutada.
                                //Accion realizada carrectamente
                                //estadoInicial
                                swal({
                                    position: 'center',
                                    type: 'success',
                                    title: 'Realizado!',
                                    text: 'El Pedido fue eliminado correctamente',
                                    showConfirmButton: false,
                                    timer: 2500
                                });
                                EstadoIniciarl();
                            } else {
                                //Mensaje de alerta
                                swal({
                                    position: 'center',
                                    type: 'error',
                                    title: 'Alerta!',
                                    text: 'El Pedido no pudo ser eliminado.',
                                    showConfirmButton: false,
                                    timer: 2500
                                });
                            }
                        });
                    }
                });
            } else {
                swal({
                    position: 'center',
                    type: 'error',
                    title: 'Alerta!',
                    text: 'El usuario o la contraseña son incorrectos, por favor intente nuevamente.',
                    showConfirmButton: false,
                    timer: 2500
                });
            }
        });
    } else {
        //Mostrar los campos que faltan //Pendiente
        camposPendientesConfirmacion();
    }
}
//Se encarga de enviar la informacion a la vista principal para editar el pedido
function enviarEditarPedido() {
    con = 0;
    var $cuerpos = $('#cuerpoP');
    idPedido = $cuerpos.find('tr').find('td').eq(0).text();
    var precio = convertirNumeroMonedaPesos($cuerpos.find('tr').find('td').eq(3).data('precio'));
    //Poner titulo de la accion
    $titulo.text('Pedido de:' + $cuerpos.find('tr').find('td').eq(1).text());
    //Se encarga de consultar el  pedido del empleado
    $.post(baseurl + 'Alimentacion/cPedidos/consultarDetallePedido', { //Busqueda del pedido
        idP: Number(idPedido)
    }, function(pedido) {
        $cuerpo.empty();
        //Encodar a json
        var result = JSON.parse(pedido);
        //Ubicar informacion detalle del pedido
        $.each(result, function(index, item) {
            //El data eliminar se utiliza para saber que productos se van a eliminar cuando se modifique el pedido, para eso el data-eliminar tiene que ser =1
            $tabla.children('#cuerpo').append('<tr>' + '<td data-pedido="' + item.idLineas_pedido + '" data-proveedor="' + item.idProveedor + '"  data-producto="' + item.idProducto + '"' + '"  data-evento="' + item.idMomento + '">' + item.nombre + '</td>' + '<td>' + item.cantidad + '</td>' + '<td>' + convertirNumeroMonedaPesos(item.precio) + '</td>' + '<td>' + (item.idMomento == 1 ? 'Desayuno' : 'Almuerzo') + '</td>' + '<td>' + '<button data-target="#modificar" value=' + con + ' onclick="enviarInformacionVistaM(this.value)"  type="button" class="btn btn-primary tamaño editar" data-toggle="modal"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button data-eliminar="' + 1 + '" type="button"  value=' + con + ' class="btn btn-danger tamaño eliminar" onclick="eliminarLineaPedido(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar' + '</span></button>' + '</td>' + '</tr>');
            con++;
        });
        con = 0;
        $totalPrecio.text(precio);
    });
}

function editarPedido() {
    var j = 0;
    //validacíon de confirmacíon de accíon
    if ($user.val().trim() != '' && $pass.val().trim() != '') {
        //Validar datos usuario
        $.post(baseurl + 'Alimentacion/cPedidos/validarUsuario', {
            documento: $user.val(),
            password: $pass.val(),
            idP: Number(idPedido)
        }, function(res) {
            //Editar Linea de pedido
            if (res == 1) {
                //Elimina todas las lineas de pedido que estan dentro del vector
                if (eliminarL.length > 0) {
                    //Se elimina y se modifica
                    $.each(eliminarL, function(index, item) {
                        $.post(baseurl + 'Alimentacion/cPedidos/EliminarLineaPedido', {
                            idP: Number(idPedido),
                            idL: item
                        }, function(data) {
                            if (data == 1) { //Si la respuesta del servidor es true
                                j++;
                                if (eliminarL.length == j) {
                                    //Modificar pedido
                                    procesoRegistroModificacionDetallesPedido();
                                }
                            }
                        });
                    });
                } else {
                    //Solo se modifica las lineas de pedido
                    procesoRegistroModificacionDetallesPedido();
                }
            } else {
                swal({
                    position: 'center',
                    type: 'error',
                    title: 'Alerta!',
                    text: 'El usuario o la contraseña son incorrectos, por favor intente nuevamente.',
                    showConfirmButton: false,
                    timer: 2500
                });
            }
        });
    } else {
        //Mostrar los campos que faltan de la confirmacion
        camposPendientesConfirmacion();
    }
}

function procesoRegistroModificacionDetallesPedido() {
    var k = 0;
    $.post(baseurl + 'Alimentacion/cPedidos/registrarModificarPedido', { //Se registra o se modifica el pedido
        documento: String($user.val()),
        // Este total se va a calcular directamente desde la base de datos.
        total: String(convertirMonedaPesosNumero($totalPrecio.text())),//Hacer una forma de calcular el total de una manera más segura...
        op: 1, //Se encarga de modificar el pedido
        idP: Number(idPedido), //Variable global
        fecha: ''
    }, function(res) {
        if (res) {
            //Modificar detalle de pedido
            k = $cuerpo.find('tr').length; //Longitud de la cantidad de vectores que contiene la tabla.
            registrarModificarDetallePedido(k, Number(idPedido));
        }
    });
}
//Se encarga de limpiar los campos del modal de consultar pedidos al salir del modal
function limpiarConsultarPedidos($cuerpo) {
    $cuerpo.empty();
    $('#docP').val('');
}

function camposPendientesConfirmacion() { //Pendiente
    var valor = $user;
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        //if(!$nombre.parent().attr('class').hasClass('has-error')){
        $user.parent().addClass('has-error');
    } else if (!isNaN(valor)) {
        $user.parent().addClass('has-error');
    } else {
        $user.parent().addClass('has-success');
        $user.parent().removeClass('has-error');
    }
    valor = $pass.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        //if(!$nombre.parent().attr('class').hasClass('has-error')){
        $pass.parent().addClass('has-error');
    } else if (!isNaN(valor)) {
        $pass.parent().addClass('has-error');
    } else {
        $pass.parent().addClass('has-success');
        $pass.parent().removeClass('has-error');
    }
}
//Consulta todos los proveedores en general
function consultarProductosProveedor(id, $selector, cargar, producto) {
    //Consulta los productos)================================================================================================================
    if (id != 0) {
        $.post(baseurl + 'Alimentacion/cProductos/consultarProductos', {
            op: 2,
            idProveedor: id
        }, function(data) {
            //Se convierte la información en formato json
            var result = JSON.parse(data);
            //Se inicializa el selector
            limpiarSelectInicial($selector, cargar);
            //Se ingresan las option en el selector
            $.each(result, function(res, row) {
                if (cargar == 1 || cargar == 3) { //se carga el combo box principal de productos
                    $selector.append('<option data-prec="' + row.valor + '" data-subtext="' + row.precio + '" value="' + row.idProducto + '">' + row.nombre + '</option>');
                    if (cargar == 3) {
                        $('select[name=subProducto]').val(producto);
                    }
                    $selector.selectpicker('refresh'); //Actualizar el combobox con la clase spikers 
                } else { //Se carga la tabla de ptoductos del modal
                    $selector.append('<tr>' + '<td>' + row.nombre + '</td>' + '<td>' + row.precio + '</td>' + '</tr>');
                }
            });
        });
    } else {
        //Se inicializa el selector
        limpiarSelectInicial($selector, cargar);
        $selector.selectpicker('refresh'); //Actualizar el combobox con la clase spikers
    }
}
//Procedimiento para limpiar cualquier selector 
function limpiarSelectInicial($component, cargar) {
    $component.empty();
    //console.log(cargar);
    if (cargar == 1 || cargar == 3) {
        $component.append('<option value="0">Seleccione...</option>');
        $component.selectpicker('refresh'); //Actualizar el combobox con la clase spikers
    }
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

function validarCamporFormularioPedido() {
    swal({
        position: 'center',
        type: 'warning',
        title: 'Alerta!',
        text: 'Falta algún campo por diligenciar para poder agregar la linea.',
        showConfirmButton: false,
        timer: 2500,
    });
}
//Se encarga de agregar una linea de pedido a la tabla de pedido
function agregarLineaProducto() {
    //Validacion de los campos (Ningun campo puede estar vacio)
    if ($canti.val() != '' && $('#selProveedor').val().trim() != '0' && $('#pro').val().trim() != '0' && $('input:radio[name=optradio]:checked').val()) {
        //Identificador del proveedor
        $('#selProveedor option:selected').each(function() {
            idProveedor = $('#selProveedor').val();
        });
        //Nombre del producto
        name = $('#pro option:selected').text();
        //Id del producto
        $('#pro option:selected').each(function() {
            idP = $('#pro').val();
        });
        //Cantidad
        cantidad = $canti.val();
        //Tipo de evento
        evento = $('input:radio[name=optradio]:checked').val();
        // Validar que no exista el mismo producto del mismo proveedor y del mismo memento
        var res = encontrarProductosIguales(idP, idProveedor, evento);
        //Precio unitario
        precioUnitario = $('#pro option:selected').data('prec');
        if (res == -1) { //Cuando la linea de pedido del mismo producto no existe
            //Se agrega los componentes a la tabla
            // cuando el data eliminar del boton eliminar es =0 es porque no va a realizar la accion de eliminar cuando se modifique un pedido
            $tabla.children('#cuerpo').append('<tr>' + '<td data-proveedor="' + idProveedor + '"  data-producto="' + idP + '" data-evento="' + evento + '">' + name + '</td>' + '<td>' + cantidad + '</td>' + '<td>' + convertirNumeroMonedaPesos(cantidad * precioUnitario) + '</td>' + '<td>' + (evento == 1 ? 'Desayuno' : 'Almuerzo') + '</td>' + '<td>' + '<button data-target="#modificar" value=' + con + ' onclick="enviarInformacionVistaM(this.value)"  type="button" class="btn btn-primary tamaño editar" data-toggle="modal"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button data-eliminar="' + 0 + '" type="button"  value=' + con + ' class="btn btn-danger tamaño eliminar" onclick="eliminarLineaPedido(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar' + '</span></button>' + '</td>' + '</tr>');
            con++;
        } else { //Cuando la linea de pedido con el mismo producto ya existes
            //Actualizar Cantidad
            var rowp = $tabla.children('#cuerpo').find('tr').eq(res).find('td').eq(1);
            var cantiA = (Number(rowp.text()) + Number(cantidad));
            rowp.text("" + cantiA + "");
            //Actualizar Precio
            rowp = $tabla.children('#cuerpo').find('tr').eq(res).find('td').eq(2);
            var precio = convertirNumeroMonedaPesos((Number(convertirMonedaPesosNumero(rowp.text()))) + (Number(cantidad) * Number(precioUnitario)));
            rowp.text("" + precio + "");
            // console.log(precio);
        }
        precioTotalPedido(1, (cantidad * precioUnitario)); //Uno significa sumar
        limpiarCampos();
    } else {
        //Cuando un campo esta vacio va a mostrar cual esta vacio
        validarCamporFormularioPedido();
    }
}
//Se encarga de validar que si ya existe una linea del mismo producto solo modifiquie las cantidades.
function encontrarProductosIguales(idProducto, idProveedor, idEvento) {
    var res = -1; //Si es false es porque se puede ingresar otra fila a la tabla de pedidos
    //Si res true significa que no se puede ingresar otra fila a la tabla y lo que se tiene que hacer es modificar la cantidad el precio y el momento.
    $tabla.children('#cuerpo').find('tr').each(function(con) {
        if ($(this).find('td').eq(0).data('proveedor') == idProveedor && $(this).find('td').eq(0).data('producto') == idProducto && $(this).find('td').eq(0).data('evento') == idEvento) {
            res = con;
            //console.log(res);
            return res;
        }
    });
    return res;
}
//Calcular precio total de los productos
function precioTotalPedido($op, $precio) {
    var precioTotal = 0;
    if ($op == 1) { //se suma el precio al total
        PrecioTotal = (Number(convertirMonedaPesosNumero($totalPrecio.text())) + $precio);
    } else { //Se resta el precio al total
        PrecioTotal = (Number(convertirMonedaPesosNumero($totalPrecio.text())) - $precio);
    }
    // $totalPrecio.parent('div').data('total',PrecioTotal);
    $totalPrecio.text("" + convertirNumeroMonedaPesos(PrecioTotal) + "");
}
//Enviar informacion a la vista para modificar
function enviarInformacionVistaM(pos) {
    // Evento de busqueda
    var eve = 0;
    //Momento...
    if ($cuerpo.find('tr').eq(pos).find('td').eq(3).text() == 'Desayuno') {
        $('#UD').prop('checked', true);
        eve = 1;
    } else {
        $('#UA').prop('checked', true);
        eve = 2;
    }
    //Identificador del proveedor
    consultarProveedores($('#selProveedorM1'), 3, eve);
    idProveedor = $cuerpo.find('tr').eq(pos).find('td').eq(0).data('proveedor'); //Nombre del producto
    // Seleccionar el producto de la vista modificar pedido
    idProducto = $cuerpo.find('tr').eq(pos).find('td').eq(0).data('producto'); //Nombre del producto
    //Consultar productos del proveedor
    consultarProductosProveedor(idProveedor, $selecProductoM, 3, idProducto);
    //Cantidad...
    $('#Ucant').val($cuerpo.find('tr').eq(pos).find('td').eq(1).text());
    //Posicion de la linea a actualizar
    $actualizar.val(pos);
}
//Limpiara todos los campos del formulario (Los dejara en el estado inicial)
function limpiarCampos() {
    //Combo de productos
    $selecProducto.empty();
    $selecProducto.html('<option value="0">Seleccione...</option>');
    $selecProducto.selectpicker('refresh');
    //Combo de proveedor
    $sel.empty();
    $sel.html('<option value="0">Seleccione...</option>');
    $sel.selectpicker('refresh');
    //Cantidad
    $('#cant').val('');
    //Momento
    $('input[type="radio"]').prop('checked', false);
}
//Limpiar tabla y campos
function EstadoIniciarl() {
    //Se limpia la tabla
    $cuerpo.empty();
    //Combo de proveedores
    limpiarSelectInicial($('#selProveedor'), 1);
    limpiarSelectInicial($('#selProveedorM1'), 1);
    limpiarSelectInicial($('#selProveedorM2'), 1);
    //Limpiar combo de productos
    limpiarSelectInicial($('#pro'), 1);
    //Cantidad
    $canti.val('');
    //Consultar proveedores
    // consultarProveedores($('#selProveedor'));
    //Precio total
    $('#D').prop('checked', false);
    $('#A').prop('checked', false);
    $totalPrecio.text('0');
    $pedir.val('0'); ///
    con = 0;
    idPedido = '';
    eliminarL = [];
    i = 0;
    $titulo.text('pedidos');
}
//Se elimina la linea de pedidos que no quiere ser realizada
function eliminarLineaPedido(pos) {
    swal({
        title: '¿Estas seguro?',
        text: "se suprimira de la table de lineas de pedidos",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) { //Actualizamos el estado de la posicion de cada linea de producto
            //...
            //Si es = a 1 se eliminara del pedido cuando se modifique y si es igual a 0 no va hacer absolutamente nada
            if ($cuerpo.find('tr').find('td').find('button.eliminar').eq(pos).data('eliminar') == 1) {
                eliminarL[i] = $cuerpo.find('tr').eq(pos).find('td').eq(0).data('pedido');
                i++; //Esta variable se tiene que inciarlizar despues que se modifique el pedido
            }
            //...
            con = 0;
            //Botones de editar
            precioTotalPedido(2, Number(convertirMonedaPesosNumero($cuerpo.find('tr').eq(pos).find('td').eq(2).text())));
            $cuerpo.find('tr').eq(pos).remove();
            $cuerpo.find('tr').find('td').find('button.editar').each(function() {
                $(this).val(con);
                //console.log($(this).val());
                con++;
            });
            con = 0;
            //Botones de eliminar
            $cuerpo.find('tr').find('td').find('button.eliminar').each(function() {
                $(this).val(con);
                //console.log($(this).val());
                con++;
            });
            con = 0;
            swal('Eliminado!', 'La linea de pedido fue eliminada.', 'success');
        }
    });
}
//Validar Realizacion de pedido
function realizarPedido() {
    // variables
    var $user = $('#usr');
    var $pass = $('#pwd');
    var i = 0;
    var docu = $user.val();
    $.post(baseurl + 'Alimentacion/cPedidos/restriccionPedidos', function(res) {
        if (res == 1) {
            swal({
                title: '¿Estas seguro?',
                text: "Realizara el pedido para el día de hoy",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                //Falta validacion de rango de horas para realizar pedidos
                if (result.value) { //Validacion que el usuario este deacuerdo con la accion que se va a realizar
                    //Validar que los campos esten llenos
                    if ($user.val().trim() != '' && $pass.val().trim() != '') { //Se encarga de validar que los campos si tengan contenido
                        //Validar datos usuario
                        $.post(baseurl + 'Alimentacion/cPedidos/validarUsuario', { //Se valida la existencia del usuario y este activo
                            documento: docu,
                            password: $pass.val(),
                            idP: 0
                        }, function(res) {
                            if (res == 1) {
                                //Validacion de pedidos por día (El empleado solo puede registrar un pedido por día)
                                $.post(baseurl + 'Alimentacion/cPedidos/validarPedidoPorDia', {
                                    documento: $('#usr').val()
                                }, function(dato) {
                                    if (dato == 1) {
                                        //Resgistrar pedido
                                        $.post(baseurl + 'Alimentacion/cPedidos/registrarModificarPedido', { //Se registra o se modifica el pedido
                                            documento: String($user.val()),
                                            total: String(convertirMonedaPesosNumero($totalPrecio.text())),
                                            op: 0, //Se encarga de decir que es un registrar
                                            idP: 0,
                                            fecha: ''
                                        }, function(idPedidoP) {
                                            //Detalle del pedido
                                            if (idPedidoP > 0) {
                                                //Recorrer la tabla
                                                i = $cuerpo.find('tr').length; //Longitud de la cantidad de vectores que contiene la tabla.
                                                registrarModificarDetallePedido(i, idPedidoP); //Se encarga de registrar
                                            }
                                        }); //Fin del registro de pedido
                                    } else {
                                        // Oculta el panel de confirmación
                                        $confirmar.modal('toggle');
                                        //Mensaje de alerta
                                        swal({
                                            position: 'center',
                                            type: 'warning',
                                            title: 'Alerta!',
                                            text: 'El ususario ya tiene un pedido por el día de hoy.',
                                            showConfirmButton: false,
                                            timer: 2500
                                        });
                                    }
                                });
                            } else {
                                swal({
                                    position: 'center',
                                    type: 'error',
                                    title: 'Alerta!',
                                    text: 'El usuario o la contraseña son incorrectos, por favor intente nuevamente.',
                                    showConfirmButton: false,
                                    timer: 2500
                                });
                            }
                        }); //Fin de validacion de usuario
                    } else {
                        //Avisar que falta algun campo por diligenciar
                        validarCamporFormularioPedido();
                    } //Fin Se encarga de validar que los campos si tengan contenido
                } //Fin Validacion que el usuario este deacuerdo con la accion que se va a realizar
            });
        } else {
            // Ocualtar el modal
            $confirmar.modal('toggle');
            // Mensaje de advertencia 
            swal({
                position: 'center',
                type: 'warning',
                title: 'Alerta!',
                text: 'No es hora de gestionar pedidos',
                showConfirmButton: false,
                timer: 2500
            });
        }
    });
}

function registrarModificarDetallePedido(logitud, idPedidoP) {
    var j = 0;
    // console.log($(this).find('td').eq(0).data('pedido') === undefined ? 0 : 1);
    //Tipo de accion a realizar(registrar(0) o modificar(1)), la longitud de la tabla, id del pedido a modificar
    $cuerpo.find('tr').each(function() {
        //Registrar detalle del pedido
        $.post(baseurl + 'Alimentacion/cPedidos/registrarModificarLineasDetalle', {
            idPedido: idPedidoP,
            cantidad: $(this).find('td').eq(1).text(), //Cantidad
            idProducto: String($(this).find('td').eq(0).data('producto')), //IdProducto
            idMomento: String($(this).find('td').eq(3).text() == 'Desayuno' ? '1' : '2'), //Momento
            precio: convertirMonedaPesosNumero($(this).find('td').eq(2).text()), //Precio
            op: $(this).find('td').eq(0).data('pedido') === undefined ? '0' : '1', //0 registrar 1 modifica
            idL: $(this).find('td').eq(0).data('pedido') === undefined ? '0' : String($(this).find('td').eq(0).data('pedido'))
        }, function(dato) {
            //Variable para el mensaje de confirmacion
            if (dato > 0) {
                j++;
                // console.log(j);
                if (logitud == j) { // Si la cantidad de v(i) es igual a la cantidad de vectores recorridos(j) entonces mostrara el mensaje.
                    //Mensaje de confirmacion
                    EstadoIniciarl(); //Lleva a los componenetes de la pagina principal al estado inicial de carga
                    $('#Confirmar').modal('toggle');
                    setTimeout(()=>swal('Realizado!', 'El pedido fue realizado correctamente.', 'success'),500)//Funtion de flecha ES6
                    //... 
                    $user.val('');
                    $pass.val('');
                }
            }
        }); //Fin de registro del detalle del pedio}
    }); //Fin del recorrido de la tabla
}
//Actualizar informacion de la tabla
function actualizarLineaPedido(pos) {
    //Nombre del producto
    $cuerpo.find('tr').eq(pos).find('td').eq(0).text($('#Upro option:selected').text());
    // ID del nuevo producto
    $cuerpo.find('tr').eq(pos).find('td').eq(0).data('producto', $('#Upro option:selected').val());
    //Cantidad 
    cantidad = $('#Ucant').val();
    //Actualizar la cantidad de la linea de pedido
    $cuerpo.find('tr').eq(pos).find('td').eq(1).text(cantidad);
    //Precio unitario
    precioUnitario = $('#Upro option:selected').data('prec');
    //Restar el precio total el antiguio valor de la linea de pedidos
    precioTotalPedido(2, Number(convertirMonedaPesosNumero($cuerpo.find('tr').eq(pos).find('td').eq(2).text()))); //Precio antiguo
    //Actualizar El precio
    var nuevoPrecio = Number(cantidad) * Number(precioUnitario);
    $cuerpo.find('tr').eq(pos).find('td').eq(2).text(convertirNumeroMonedaPesos(nuevoPrecio));
    //Sumar el nuevo precio al precio global del pedido
    precioTotalPedido(1, nuevoPrecio);
    //Actualizar Momento
    evento = $('input:radio[name=optradioM]:checked').val();
    $cuerpo.find('tr').eq(pos).find('td').eq(3).text(evento == 1 ? 'Desayuno' : 'Almuerzo');
    //Cierre del modal
    $('#modificar').modal('toggle');
    //Mensaje de confirmación de la modificación
    swal({
        position: 'center',
        type: 'success',
        title: 'Realizado!',
        text: 'La linea de pedido fue modificada exitosamente',
        showConfirmButton: false,
        timer: 2000
    });
}
//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) {
    var v = fecha.split('-');
    return v[2] + '-' + v[1] + '-' + v[0];
}