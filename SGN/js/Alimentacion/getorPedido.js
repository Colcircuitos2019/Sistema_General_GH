//Variables
var $cuerpoP = $('#cuerpoP');
var $cargador = $('.loading');
var $cuerpoEnvios = $('#cuerpoEnvios');
var $proveedor = $('#proveedores');
// 
$cargador.hide();
$(document).ready(function() {
    // Tool Tips de toda la pagina
    $('[data-toggle="tooltip"]').tooltip();
    // Consulta todos los predidos realizados y sus respectivos detalles para el día cursado.
    consultarPedidos();
    // Evento Click
    $('#btnActualizar').click(function(event) {
        consultarPedidos();
    });
    // Evento click
    $('#btnEnviarPedidos').click(function(event) {
        enviarCorreosElectronicosPedidos();
    });
    // Consultar proveedores
    consultarProveedores();
    // Generar el PDF
    $proveedor.change(function() {
        // Crea una nueva ventana y me enruta a la direccion
        window.open(baseurl + 'Alimentacion/cPedidos/reportePedidosProveedorPDF?id=' + $(this).val() + '&nom=' + $('#proveedores option:selected').text(), '_blank'); //Crea una nueva ventana en blanco
        //Cambia el estado de los pedidos realizados el dias de hoy...
        $.post(baseurl + 'Alimentacion/cPedidos/cambiarEstadoPedido', function(data) {
            console.log(data);
        });
    });
});
//Se encarga de enviar la informacion a la vista principal para editar el pedido
function consultarLineasDetalle(id) {
    var $cuerpo = $('#cuerpo');
    // var precio = $cuerpo.find('tr').find('td').eq(3).data('precio');
    //Poner titulo de la accion
    $('#titulo').html("<b>Pedido del empleado: </b>" + $cuerpo.find('tr[value="' + id + '"]').find('td').eq(2).text());
    //Se encarga de consultar el  pedido del empleado
    $.post(baseurl + 'Alimentacion/cPedidos/consultarDetallePedido', { //Busqueda del pedido
        idP: Number(id)
    }, function(pedido) {
        $cuerpoP.empty();
        //Encodar a json
        var result = JSON.parse(pedido);
        //Ubicar informacion detalle del pedido
        $.each(result, function(index, item) {
            //El data eliminar se utiliza para saber que productos se van a eliminar cuando se modifique el pedido, para eso el data-eliminar tiene que ser =1
            $cuerpoP.append('<tr>' + '<td>' + item.proveedor + '</td>' + '<td>' + item.nombre + '</td>' + '<td>' + item.cantidad + '</td>' + '<td>' + item.total1 + '</td>' + '<td>' + (item.idMomento == 1 ? 'Desayuno' : 'Almuerzo') + '</td>' + '</tr>');
        });
        $('#detallePedido').modal('show');
    });
}
//Se encarga de consultar todos los pedidos del día.
function consultarPedidos() {
    var $tabla = $('#tabla');
    $tabla.empty();
    $tabla.html('<table id="tblPedidos" class="display">' + '<thead id="cabeza">' + '<th scope="col">N°P</th>' + '<th scope="col">Documento</th>' + '<th scope="col">Empleado</th>' + '<th scope="col">Hora</th>' + '<th scope="col">Total</th>' + '<th scope="col">Ver</th>' + '</thead>' + '<tbody id="cuerpo">' + '</tbody>' + '</table>');
    var $cuerpo = $('#cuerpo');
    var filas = 0;
    $cuerpo.empty(); //Limpiamos la tabla
    $.post(baseurl + 'Alimentacion/cPedidos/consultarPedidos', {
        documento: 0,
        op: 1 //Consultar pedidos por fecha de hoy
    }, function(data) {
        result = JSON.parse(data);
        //Informacion
        $.each(result, function(index, row) {
            filas++;
            $cuerpo.append('<tr value="' + row.idPedido + '">' + ' <td>' + row.idPedido + '</td>' + '<td>' + row.documento + '</td>' + '<td>' + row.nombre1 + ' ' + row.nombre2 + ' ' + row.apellido1 + ' ' + row.apellido2 + '</td>' + '<td>' + row.hora + '</td>' + '<td>' + row.total1 + '</td>' + '<td>' + '<button value="' + row.idPedido + '" type="button" onclick="consultarLineasDetalle(this.value)" class="btn btn-success "><span><i class="fas fa-eye"></i> ver' + '</span></button>' + '</td>' + '</tr>');
        });
        $('#tblPedidos').DataTable({
            "bStateSave": true,
            "iCookieDuration": 60,
            "language": {
                "sProcessing": "Procesando...",
                "sLengthMenu": "Mostrar _MENU_ Registros",
                "sZeroRecords": "No se encontraron resultados",
                "sEmptyTable": "Ningún dato disponible en esta tabla",
                "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
                "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
                "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
                "sInfoPostFix": "",
                "sSearch": "Buscar:",
                "sUrl": "",
                "sInfoThousands": ",",
                "sLoadingRecords": "Cargando...",
                "oPaginate": {
                    "sFirst": "Primero",
                    "sLast": "Último",
                    "sNext": "Siguiente",
                    "sPrevious": "Anterior"
                },
                "oAria": {
                    "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
                    "sSortDescending": ": Activar para ordenar la columna de manera descendente"
                }
            }
        });
        consultarCantidadProductos();
    });
}
// Se encarga de consultar la candidas de productos de cada proveedor que se van a realizar en el día cursado.
function consultarCantidadProductos() {
    var $tablaP = $('#tablaP');
    $tablaP.empty();
    $tablaP.html('<table id="tblProductosP" class="display">' + '<thead>' + '<th>Proveedor</th>' + '<th>Producto</th>' + '<th>Cantidad</th>' + '<th>Momento</th>' + '</thead>' + '<tbody id="Cuerpo1">' + '</tbody>' + '</table>');
    var $cuerpoP = $('#Cuerpo1');
    $.post(baseurl + 'Alimentacion/cPedidos/consultarCantidadProductosProveedor', {
        idProveedor: 0
    }, function(data) {
        var result = JSON.parse(data); //Se transforma el dato en formato json
        $.each(result, function(index, row) {
            $cuerpoP.append('<tr>' + '<td>' + row.proveedor + '</td>' + '<td>' + row.producto + '</td>' + '<td>' + row.cantidad + '</td>' + '<td>' + (row.idMomento == 1 ? 'Desayuno' : 'Almuerzo') + '</td>' + '</tr>');
        });
        $('#tblProductosP').DataTable({
            "language": {
                "sProcessing": "Procesando...",
                "sLengthMenu": "Mostrar _MENU_ Registros",
                "sZeroRecords": "No se encontraron resultados",
                "sEmptyTable": "Ningún dato disponible en esta tabla",
                "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
                "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
                "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
                "sInfoPostFix": "",
                "sSearch": "Buscar:",
                "sUrl": "",
                "sInfoThousands": ",",
                "sLoadingRecords": "Cargando...",
                "oPaginate": {
                    "sFirst": "Primero",
                    "sLast": "Último",
                    "sNext": "Siguiente",
                    "sPrevious": "Anterior"
                },
                "oAria": {
                    "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
                    "sSortDescending": ": Activar para ordenar la columna de manera descendente"
                }
            }
        });
    });
}
// Se encarga de consultar todos los proveedores
function consultarProveedores() {
    //Consulta de proveedores disponibles
    $.post(baseurl + 'Alimentacion/cProveedor/consultarProveedores', {
        op: 3
    }, function(data) {
        var resulSet = JSON.parse(data);
        $proveedor.empty();
        $proveedor.html('<option value="0">Seleccione...</option>');
        $.each(resulSet, function(resulSet, row) {
            if (row.estado == 1) {
                $proveedor.append('<option value="' + row.idProveedor + '">' + row.nombre + '</option>');
            }
        });
        $proveedor.selectpicker('refresh');
    });
    //Consulta de proveedores disponibles -- fin --
}
// Se encarga de inviar correos electronicos de los pedidos realizados por los empleados a los proveedores.
function enviarCorreosElectronicosPedidos() {
    swal({ //Mensaje de confirmacion para realizar la accion.
        title: '¿Estas seguro?',
        text: "Se enviara correo de los pedidos realizados el día de hoy a los proveedores.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            $('#detalleEnvioPedidos').modal('show');
            $cargador.show();
            $.post(baseurl + 'Alimentacion/cPedidos/enviarCorreroPedidosProveedor', function(data) {
                // 
                var v = JSON.parse(data);
                var st;
                $cuerpoEnvios.empty();
                $.each(v, function(index, item) {
                    st = item.split(';');
                    // console.log(st);
                    $cuerpoEnvios.append('<tr>' + '<td>' + st[0] + '</td>' + clasificarEstadoEnvioPedido(st[1]) + '</tr>');
                });
                $cargador.hide();
                //Se cambia el estado del pedido a realizado 
                $.post(baseurl + 'Alimentacion/cPedidos/cambiarEstadoPedido', function(data) {
                    console.log(data);
                });
            });
        }
    });
}
// 
function clasificarEstadoEnvioPedido($valor) {
    switch ($valor) { //
        case '0':
            return '<td class="btn"> El mensaje no pudo ser enviado.</td>';
            break;
        case '1':
            return '<td class="btn"> El mensaje pudo ser enviado correctamente.</td>';
            break;
        case '2':
            return '<td class="btn"> A este proveedor ya se le envio correo el día de hoy.</td>';
            break;
    }
}