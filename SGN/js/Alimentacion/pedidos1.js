//Variables
var $cuerpoP = $('#cuerpoP');
var $cabezaP = $('#cabeza');
var $fechaI = $('#fechaI');
var $fechaF = $('#fechaF');
var $selectM = $('#selProveedorM1');
var $selectP = $('#Upro');
var $soloFecha = $('#fechaPedido');
var $btnALinea = $('#btnActualizarL');
var $btnACompleto = $('#btnActualizarC');
var $precioTotal = $('#Total');
var cantidad;
var eliminarL = [];
var cont = 0;
var $btnEliminarPedido = $('#eliminarPedido');
var $modalDetalle = $('#detallePedido');
// 
$(document).ready(function() {
    //DateTimePiker
    $('.fh-date').datepicker({
        format: "dd-mm-yyyy",
        language: "es",
        multidate: false
    });
    //Evento del boton buscar liquidacion por empleados
    $('#Buscar2').on('click', function(event) {
        event.preventDefault();
        // console.log($('#fechaI').val());
        consultarPedidosReporte();
    });
    //Evento del boton buscar liquidacion por proveedor
    $('#Buscar1').on('click', function(event) {
        event.preventDefault();
        // console.log($('#fechaI').val());
        consultarLiquidacionProveedorDia();
    });
    // Evento click del link 1
    $('#linkF1').click(function(event) {
        generarReportesDePedidos(1);
    });
    // Evento de click del link 2 optimizar código
    $('#linkF2').click(function(event) {
        if ($fechaI.val() != '' && $fechaF.val() != '') {
            generarReportesDePedidos(2);
        } else {
            swal('Alerta!', 'Ingrese las dos fechas porfavor para poder generar el reporte.', 'warning');
        }
    });
    // Evento de click del link 3
    $('#linkF3').click(function(event) {
        if ($fechaI.val() != '' && $fechaF.val() != '') {
            generarReportesDePedidos(3);
        } else {
            swal('Alerta!', 'Ingrese las dos fechas porfavor para poder generar el reporte.', 'warning');
        }
    });
    // Cuando se le realice algun cambio al proveedor seleccionado
    $selectM.change(function(event) {
        // Consultar nuevamente los productos del nuevo proveedor seleccionado
        consultarProductosProveedor($('#selProveedorM1 option:selected').val(), 0);
    });
    // Actualizar linea de pedido
    $btnALinea.click(function(event) {
        actualizarLineaPedido($btnALinea.val());
    });
    // Guardar los cambios en la base de datos
    $btnACompleto.click(function(event) {
        //Validacion que la tabla tenga minimo una columna, si no lo reinviara a eliminar pedido.
        if ($cuerpoP.find('tr').length == 0) {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "No puedes guardar un pedido sin ninguna linea de pedido. Deseas eliminar el pedido completo?",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {
                    eliminarPedido($btnEliminarPedido.val());
                }
            });
        } else {
            swal({ //Mensaje de confirmacion para realizar la accion.
                title: '¿Estas seguro?',
                text: "Se guardaran los cambios que se realizaron en este pedido.",
                type: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si'
            }).then((result) => {
                if (result.value) {
                    editarPedido($btnACompleto.val());
                }
            });
        }
    });
    // Cuando se oculte el modal de modificar pedido
    $modalDetalle.on('hidden.bs.modal', function() {
        eliminarL = [];
        // console.log('Se limpio el vector de eliminar lineas');
    });
    // 
    $btnEliminarPedido.click(function(event) {
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se eliminara este pedido por completo.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                eliminarPedido($(this).val());
            }
        });
    });
});
// Methodos===================================================================================================================
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
    return '$' + num1 + ',' + String(numero).substr(res);
}

function convertirMonedaPesosNumero(moneda) {
    if (moneda.length == 1) {
        return 0;
    } else {
        var num = String(moneda).substr(1);
        var cuerpo = num.split(',');
        if (cuerpo.length==1) {
            return cuerpo[0];
        }else{
            return cuerpo[0] + cuerpo[1];
        }
    }
}
//Se encarga de darle un formato estandar a la fecha que es YYYY-MM-DD
function formatoFecha(fecha) {
    var v= fecha.split('-');
    return v[2]+'-'+v[1]+'-'+v[0];
}

//Se encarga de consultar todos los pedidos del día.
function consultarPedidosReporte() {
    var $tabla = $('#tabla');
    $tabla.empty();
    $tabla.html('<table id="tblPedidos" class="display">' + '<thead id="cabeza">' + '<th scope="col">N°P</th>' + '<th scope="col">Documento</th>' + '<th scope="col">Empresa</th>' + '<th scope="col">Empleado</th>' + '<th scope="col">Fecha hora</th>' + '<th scope="col">Total</th>' + '<th scope="col">Ver</th>' + '</thead>' + '<tbody id="cuerpo">' + '</tbody>' + '</table>');
    var $cuerpo = $('#cuerpo');
    var filas = 0;
    $cuerpo.empty(); //Limpiamos la tabla
    $.post(baseurl + 'Alimentacion/cPedidos/resporteConsumoPorEmpleado', {
        fechaI: formatoFecha(String($fechaI.val())),
        fechaF: formatoFecha(String($fechaF.val())) //Consultar pedidos por fecha de hoy
    }, function(data) {
        //console.log(data);
        result = JSON.parse(data);
        //Informacion
        $.each(result, function(index, row) {
            filas++;
            $cuerpo.append('<tr value="' + row.idPedido + '">' + ' <td>' + row.idPedido + '</td>' + '<td>' + row.documento + '</td>' + '<td>' + row.empresa + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.fecha + '</td>' + '<td>' + row.total1 + '</td>' + '<td>' + '<button value="' + row.idPedido + ';' + row.solofecha + ';' + row.documento + '" type="button" onclick="consultarLineasDetalle(this.value)" class="btn btn-success "><span><i class="fas fa-eye"></i> ver' + '</span></button>' + '</td>' + '</tr>');
        });
        $('#tblPedidos').DataTable({
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
}
//Se encarga de enviar la informacion a la vista principal para editar el pedido
function consultarLineasDetalle(id) {
    var info = id.split(';'); // 0= id del pedido, 1= fecha del pedido
    var $cuerpo = $('#cuerpo');
    var permiso;
    $btnEliminarPedido.val(info[0]);
    // var precio = $cuerpo.find('tr').find('td').eq(3).data('precio');
    //Poner titulo de la accion
    $.post(baseurl + 'Alimentacion/cPedidos/tiempoActualizacionPedido', {
        idPedido: info[0]
    }, function(data) {
        permiso = data; //Validacion de edición.
        $('#titulo').html("<b>Pedido del empleado: </b>" + $cuerpo.find('tr[value="' + info[0] + '"]').find('td').eq(3).text());
        // Poner el encabezado a la tabla detalle
        $cabezaP.empty();
        $cabezaP.html('<th scope="col">Proveedor</th>' + '<th scope="col">Producto</th>' + '<th scope="col">Cantidad</th>' + '<th scope="col">Precio</th>' + '<th scope="col">Momento</th>' + (permiso >= 1 ? '' : '<th scope="col">Acción</th>'));
        //Se encarga de consultar el  pedido del empleado
        $.post(baseurl + 'Alimentacion/cPedidos/consultarDetallePedido', { //Busqueda del pedido
            idP: Number(info[0])
        }, function(pedido) {
            $cuerpoP.empty();
            //Encodar a json
            var result = JSON.parse(pedido);
            //Ubicar informacion detalle del pedido
            $.each(result, function(index, item) {
                //El data eliminar se utiliza para saber que productos se van a eliminar cuando se modifique el pedido, para eso el data-eliminar tiene que ser =1
                $cuerpoP.append('<tr value="' + item.idLineas_pedido + '">' + '<td data-idproveedor="' + item.idProveedor + '" data-lineap="' + item.idLineas_pedido + '">' + item.proveedor + '</td>' + '<td data-idproducto="' + item.idProducto + '">' + item.nombre + '</td>' + '<td>' + item.cantidad + '</td>' + '<td data-idmomento="' + item.idMomento + '">' + item.total1 + '</td>' + '<td>' + (item.idMomento == 1 ? 'Desayuno' : 'Almuerzo') + '</td>' + (permiso >= 1 ? '' : '<td>' + '<button value="1" type="button" onclick="modificarAccionBoton(this.value,' + item.idLineas_pedido + ')" class="btn btn-primary accion"><span><i class="far fa-edit"></i> Editar' + '</span></button>' + '&nbsp' + '<button value="2" data-idLinea="' + item.idLineas_pedido + '" type="button"  class="btn btn-danger accion" onclick="modificarAccionBoton(this.value,' + item.idLineas_pedido + ')"><span><i class="fas fa-trash-alt"></i> Eliminar' + '</span></button>' + '</td>' + '</tr>'));
            });
            // Fecha del pedido
            $soloFecha.val(info[1]);
            // Id del pedido en el boton a actualizar
            $btnACompleto.val(info[0] + ';' + info[2]); //Id del pedido;Numero de documento
            // Precio total
            $precioTotal.text($cuerpo.find('tr[value="' + info[0] + '"]').find('td').eq(5).text());
            // $precioTotal.data('valorN');
            $modalDetalle.modal('show');
            if (permiso >= 1) {
                $btnACompleto.hide();
                $btnEliminarPedido.hide();
                // $soloFecha;
            } else {
                $btnACompleto.show();
                $btnEliminarPedido.show();
                // $soloFecha
            }
        });
    });
}

function eliminarPedido(id) {
    $.post(baseurl + 'Alimentacion/cPedidos/eliminarPedido', {
        idPedido: id //Identificador del pedido
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
            $modalDetalle.modal('toggle');
            consultarPedidosReporte();
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

function consultarLiquidacionProveedorDia() {
    var $tabla = $('#tabla1');
    $tabla.empty();
    $tabla.html('<table id="tblProveedor" class="display">' + '<thead>' + '<th>Fecha</th>' + '<th>Proveedor</th>' + '<th>Liquidación</th>' + '</thead>' + '<tbody id="cuerpoL">' + '</tbody>' + '</table>');
    var $cuerpo = $('#cuerpoL');
    var filas = 0;
    $cuerpo.empty(); //Limpiamos la tabla
    $.post(baseurl + 'Alimentacion/cPedidos/reporteConsumoPorProveedor', {
        fechaL: String($('#fechaL').val())
    }, function(data) {
        //console.log(data);
        result = JSON.parse(data);
        //Informacion
        $.each(result, function(index, row) {
            filas++;
            $cuerpo.append('<tr>' + ' <td>' + row.fecha + '</td>' + '<td>' + row.proveedor + '</td>' + '<td>' + row.total + '</td>' + '</tr>');
        });
        $('#tblProveedor').DataTable({
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
}

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

function modificarAccionBoton(accion, idLinea) {
    // console.log(dato);
    if (accion == 1) {
        // Mostrar modal para modificar
        $btnALinea.val(idLinea);
        var idProvedor = $cuerpoP.find('tr[value=' + idLinea + ']').find('td').eq(0).data('idproveedor');
        var idProducto = $cuerpoP.find('tr[value=' + idLinea + ']').find('td').eq(1).data('idproducto');
        var cantidad = $cuerpoP.find('tr[value=' + idLinea + ']').find('td').eq(2).text();
        var momento = $cuerpoP.find('tr[value=' + idLinea + ']').find('td').eq(4).data('idmomento');
        colocarInformacionPedidoModal(idProvedor, idProducto, momento, cantidad);
        $('#modificar').modal('toggle');
    } else if (accion == 2) {
        // Mostras ventana confirmación para modificar
        swal({ //Mensaje de confirmacion para realizar la accion.
            title: '¿Estas seguro?',
            text: "Se eliminara esta linea de pedido.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Si'
        }).then((result) => {
            if (result.value) {
                // Sustraer del precio total
                precioTotalPedido(2, Number(convertirMonedaPesosNumero($cuerpoP.find('tr[value=' + idLinea + ']').find('td').eq(3).text())));
                $cuerpoP.find('tr[value=' + idLinea + ']').remove();
                eliminarL[cont] = idLinea;
                cont++;
            }
        });
    }
}

function editarPedido(idP) {
    var j = 0;
    var info = idP.split(';');
    //Editar Linea de pedido
    //Elimina todas las lineas de pedido que estan dentro del vector
    if (eliminarL.length > 0) {
        //Se elimina y se modifica
        $.each(eliminarL, function(index, item) {
            $.post(baseurl + 'Alimentacion/cPedidos/EliminarLineaPedido', {
                idP: Number(info[0]),
                idL: item
            }, function(data) {
                if (data == 1) { //Si la respuesta del servidor es true
                    j++;
                    if (eliminarL.length == j) {
                        //Modificar pedido
                        procesoRegistroModificacionDetallesPedido(info[0], info[1]); //Id pedido; Numero de documento
                    }
                }
            });
        });
    } else {
        //Solo se modifica las lineas de pedido
        procesoRegistroModificacionDetallesPedido(info[0], info[1]); //Id pedido; Numero de documento
    }
}

function procesoRegistroModificacionDetallesPedido(idP, user) {
    var k = 0;
    $.post(baseurl + 'Alimentacion/cPedidos/registrarModificarPedido', { //Se registra o se modifica el pedido
        documento: String(user),
        total: String(convertirMonedaPesosNumero($precioTotal.text())),
        op: 1, //Se encarga de modificar el pedido
        idP: Number(idP), //Variable global
        fecha: convertDateFormat($soloFecha.val()) + ' 12:00:00' //Al registrar la hora me toma el valor incorrecto.
    }, function(res) {
        if (res) {
            //Modificar detalle de pedido
            k = $cuerpoP.find('tr').length; //Longitud de la cantidad de vectores que contiene la tabla.
            registrarModificarDetallePedido(k, Number(idP));
        }
    });
}
// Se encarfa de dar formato a la fecha.
function convertDateFormat(string) {
    var info = string.split('-');
    return info[2] + '-' + info[1] + '-' + info[0];
}

function registrarModificarDetallePedido(logitud, idPedidoP) {
    var j = 0;
    // console.log($(this).find('td').eq(0).data('pedido') === undefined ? 0 : 1);
    //Tipo de accion a realizar(registrar(0) o modificar(1)), la longitud de la tabla, id del pedido a modificar
    $cuerpoP.find('tr').each(function() {
        //Registrar detalle del pedido
        $.post(baseurl + 'Alimentacion/cPedidos/registrarModificarLineasDetalle', {
            idPedido: idPedidoP,
            cantidad: $(this).find('td').eq(2).text(), //Cantidad
            idProducto: String($(this).find('td').eq(1).data('idproducto')), //IdProducto
            idMomento: String($(this).find('td').eq(4).text() == 'Desayuno' ? '1' : '2'), //Momento
            precio: convertirMonedaPesosNumero($(this).find('td').eq(3).text()), //Precio
            op: '1', // 1 modifica
            idL: String($(this).find('td').eq(0).data('lineap'))
        }, function(dato) {
            //Variable para el mensaje de confirmacion
            if (dato > 0) {
                j++;
                // console.log(j);
                if (logitud == j) { // Si la cantidad de v(i) es igual a la cantidad de vectores recorridos(j) entonces mostrara el mensaje.
                    //Mensaje de confirmacion
                    // EstadoIniciarl(); //Lleva a los componenetes de la pagina principal al estado inicial de carga
                    $modalDetalle.modal('toggle');
                    swal('Realizado!', 'El pedido fue realizado correctamente.', 'success');
                    // $user.val('');
                    // $pass.val('');
                }
            }
        }); //Fin de registro del detalle del pedio}
    }); //Fin del recorrido de la tabla
    consultarPedidosReporte();
}

function colocarInformacionPedidoModal(idProvedor, idProducto, momento, cantidad) {
    // Consultar Proveedores
    consultarProveedores(idProvedor);
    // Consultar
    consultarProductosProveedor(idProvedor, idProducto);
    // Momento
    (momento == 1 ? $('#UD') : $('#UA')).prop('checked', true);
    // Cantidad del producto
    $('#Ucant').val(cantidad);
}

function consultarProveedores(id) {
    $.post(baseurl + 'Alimentacion/cProveedor/consultarProveedores', {
        op: 2
    }, function(data) {
        var resulSet = JSON.parse(data);
        $selectM.empty();
        $selectM.html('<option value="0">Seleccione...</option>');
        $.each(resulSet, function(resulSet, row) {
            $selectM.append('<option value="' + row.idProveedor + '">' + row.nombre + '</option>');
        });
        $('select[name="subProveedor"]').val(id);
        // $selecProducto.empty();
        // $selecProducto.html('<option value="0">Seleccione...</option>');
        // $selecProducto.selectpicker('refresh');
        $selectM.selectpicker('refresh');
    });
}
//Actualizar informacion de la tabla-----
function actualizarLineaPedido(id) {
    // Nombre del proveedor
    $cuerpoP.find('tr[value=' + id + ']').find('td').eq(0).text($('#selProveedorM1 option:selected').text());
    // Id del proveedor
    $cuerpoP.find('tr[value="' + id + '"]').find('td').eq(0).data('idproveedor', $('#selProveedorM1 option:selected').val());
    //Nombre del producto
    $cuerpoP.find('tr[value=' + id + ']').find('td').eq(1).text($('#Upro option:selected').text());
    // ID del nuevo producto
    $cuerpoP.find('tr[value="' + id + '"]').find('td').eq(1).data('idproducto', $('#Upro option:selected').val());
    // Cantidad pedida
    cantidad = $('#Ucant').val();
    //Actualizar la cantidad de la linea de pedido
    $cuerpoP.find('tr[value="' + id + '"]').find('td').eq(2).text(cantidad);
    //Precio unitario
    precioUnitario = $('#Upro option:selected').data('prec');
    //Restar el precio total el antiguio valor de la linea de pedidos
    precioTotalPedido(2, Number(convertirMonedaPesosNumero($cuerpoP.find('tr[value="' + id + '"]').find('td').eq(3).text()))); //Precio antiguo
    //Actualizar El precio
    var nuevoPrecio = Number(cantidad) * Number(precioUnitario);
    $cuerpoP.find('tr[value="' + id + '"]').find('td').eq(3).text(convertirNumeroMonedaPesos(nuevoPrecio));
    //Sumar el nuevo precio al precio global del pedido
    precioTotalPedido(1, nuevoPrecio);
    //Actualizar Momento
    evento = $('input:radio[name=optradioM]:checked').val();
    $cuerpoP.find('tr[value="' + id + '"]').find('td').eq(4).text(evento == 1 ? 'Desayuno' : 'Almuerzo');
    $cuerpoP.find('tr[value="' + id + '"]').find('td').eq(4).data('idmomento', evento);
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
//Calcular precio total de los productos
function precioTotalPedido($op, $precio) {
    var precioTotal = 0;
    if ($op == 1) { //se suma el precio al total
        PrecioTotal = (Number(convertirMonedaPesosNumero($precioTotal.text())) + $precio);
    } else { //Se resta el precio al total
        PrecioTotal = (Number(convertirMonedaPesosNumero($precioTotal.text())) - $precio);
    }
    // $totalPrecio.parent('div').data('total',PrecioTotal);
    $precioTotal.text("" + convertirNumeroMonedaPesos(PrecioTotal) + "");
}

function consultarProductosProveedor(id, producto) {
    //Consulta los productos)================================================================================================================
    if (id != 0) {
        $.post(baseurl + 'Alimentacion/cProductos/consultarProductos', {
            op: 2,
            idProveedor: id
        }, function(data) {
            // Productos
            //Se convierte la información en formato json
            var result = JSON.parse(data);
            //Se inicializa el selector
            $selectP.empty();
            $selectP.html('<option value="0">Seleccione...</option>');
            //Se ingresan las option en el selector
            $.each(result, function(res, row) {
                //se carga el combo box principal de productos
                $selectP.append('<option data-prec="' + row.valor + '" data-subtext="' + row.precio + '" value="' + row.idProducto + '">' + row.nombre + '</option>');
            });
            $('select[name=subProducto]').val(producto);
            $selectP.selectpicker('refresh'); //Actualizar el combobox con la clase spikers
        });
    } else {
        //Se inicializa el selector
        $selectP.empty();
        $selectP.html('<option value="0">Seleccione...</option>');
        $selectP.selectpicker('refresh'); //Actualizar el combobox con la clase spikers
    }
}

function generarReportesDePedidos(op) {
    switch(op){
        case 1://Link 1
        window.location.href = baseurl + "Alimentacion/cPedidos/excelLiquidacionRangoFechas?fechaI=" + formatoFecha($fechaI.val()) + "&fechaF=" + formatoFecha($fechaF.val()) + "";
            break;
        case 2://Link 2
        window.location.href = baseurl + "Alimentacion/cPedidos/excelLiquidacionEmpleadoRangoFechas?fechaI=" + formatoFecha($fechaI.val()) + "&fechaF=" + formatoFecha($fechaF.val()) + "";
            break;
        case 3://Link 3
        window.location.href = baseurl + "Alimentacion/cPedidos/excelLiquidacionProveedorRangoFechas?fechaI=" + formatoFecha($fechaI.val()) + "&fechaF=" + formatoFecha($fechaF.val()) + "";
            break;
    }
}
// $("#btnDescargar").click(function() {
//     var Datos = JSON.parse(getLocalStorage("busquedaDatosTotal"));
//     var jsonArr = [];
//     $.each(Datos, function(index, value) {
//         jsonArr.push({
//             ÚLTIMO_ESTADO: value.UltimoEstadoStr,
//             FECHA_DE_INGRESO: value.FechaIngresoStr,
//             SKU: value.SKU,
//             UBICACIÓN: value.Ubicacion,
//             MARCA: value.Marca,
//             DESCRIPCIÓN: value.Descripcion,
//             COLOR: value.Color,
//             MES: value.Mes,
//             DISPONIBLE: value.Disponible,
//             PRÉSTAMO: value.Prestamo
//         });
//     });
//     alasql('SELECT * INTO XLSX("Búsqueda.xlsx",{headers:true}) FROM ?', [jsonArr]);
// // });
//                                 swal({
//                                     position: 'center',
//                                     type: 'warning',
//                                     title: 'Alerta!',
//                                     text: 'El ususario ya tiene un pedido por el día de hoy.',
//                                     showConfirmButton: false,
//                                     timer: 2500
//                                 // });