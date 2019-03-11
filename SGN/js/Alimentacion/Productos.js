//Variables
var $boton;
var mensaje;
var titulo;
var tipo;
var id = 0;
var con = 0;
var $selec1 = $('#selectProveedor');
var $selec2 = $('#selectProveedorM');
var $divTable=$('#tblTable');
consultarProveedores($selec1, 0,0);
//=============================================================================
$(document).ready(function() {
    //$("#txtPrecioProducto").keyup(function() {
    //  this.value = parseFloat(this.value.replace(/,/g, "")).toFixed(2).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    //});
    consultarProductos();
    //
    // setTimeout(function() { //Soluciona el problema del llamado del plugin
    //     $('#tblProducto').DataTable();
    // }, 100);
    $('#selectProveedor').change(function() {
        $('#selectProveedor option:selected').each(function() {
            id = $('#selectProveedor').val();
        });
    });
    var $nombreP = $('#txtProducto');
    var $precio = $('#txtPrecioProducto');
    //Boton de registrar productos
    $('#sendInfoProducto').click(function(event) {
        event.preventDefault();
        if ($nombreP.val() != '' && $precio.val() != '' && id != 0) {
            $.ajax({
                url: baseurl + 'Alimentacion/cProductos/registrarModificarProducto',
                type: 'POST',
                dataType: 'json',
                data: {
                    action: 0,
                    nombre: $nombreP.val(),
                    precio: $precio.val(),
                    idProveedor: id
                },
            }).done(function(respuesta) {
                //console.log(respuesta);
                if (respuesta) { //Se registro correctamente el producto
                    mensaje = 'El producto fue registrado correctamente!';
                    titulo = 'Exitos!';
                    tipo = 'success';
                    consultarProductos();
                } else { //no se registro correctamente el producto
                    mensaje = 'El producto no pudo ser registrado!';
                    titulo = 'Error!';
                    tipo = 'error';
                }
                swal({
                    position: 'center',
                    type: tipo,
                    title: titulo,
                    text: mensaje,
                    showConfirmButton: false,
                    timer: 2500
                });
                //Se limpian los campos
                $nombreP.val('');
                $precio.val('');
                $('#selectProveedor > option[value="0"]').attr('selected', 'selected');
                $nombreP.parent().removeClass('has-error');
                $precio.parent().removeClass('has-error');
                $nombreP.parent().removeClass('has-success');
                $precio.parent().removeClass('has-success');
                id = 0;
            }).fail(function(error) {
                console.log(error);
            });
        } else {
            //Mostrar mensaje
            validarCampos($nombreP, $precio);
        }
    });
});

function formato(pesos) {
    var num = '';
    if (pesos.indexOf('$') != -1) {
        num = pesos.substring(1);
    } else {
        num = pesos;
    }
    var r = num.split(',');
    var res = '';
    $.each(r, function(num, item) {
        res += item;
    });
    return res;
}
//Eliminar producto
function eliminarProducto(idP) {
    // es = $('#modificarProducto').find('tr').eq(fila).find('td').eq(2).find('span').text();
    // //console.log(es);
    // if (es == 'Activo') {
    //     mensaje = 'Se cambiara el estado del producto a inactivo y no se podra incluir este producto en los pedidos';
    // } else {
    //     mensaje = 'Se reactivara el estado del producto y se podra volver agragar en los pedidos';
    // }
    swal({
        title: '¿Estas seguro?',
        text: 'Se cambiara el estado del producto',
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            // idDetalle = $('#modificarProducto').find('tr').eq(fila).find('th').eq(0).text();
            //console.log(idDetalle);
            $.post(baseurl + 'Alimentacion/cProductos/eliminarProducto', {
                iddetalle: Number(idP)
            }, function(res) {
                if (res) {
                    swal('Exito!', 'El cambio de estado fue realizado correctamente.', 'success')
                    consultarProductos();
                }
            });
        }
    });
}
//Modificar producctos
function actualizarProducto(idP) {//Id Producto
    var idM;
    var $nombrePM = $('#txtProductoM');
    var $precioM = $('#txtPrecioProductoM');
    // idProveedor
    $('#selectProveedorM option:selected').each(function() {
        idM = $('#selectProveedorM').val();
    });
    swal({
        title: '¿Estas seguro?',
        text: 'Se actualizara la información de este producto',
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si'
    }).then((result) => {
        if (result.value) {
            $.ajax({
                url: baseurl + 'Alimentacion/cProductos/registrarModificarProducto',
                type: 'POST',
                dataType: 'json',
                data: {
                    action: 1,
                    nombre: $nombrePM.val(),
                    precio: formato($precioM.val()),
                    idProveedor: idM,
                    idPrdo: idP
                },
            }).done(function(resultado) {
                //console.log(resultado);
                //formato(resultado.precio);
                if (resultado) {
                    //Esconder modal
                    $('#modificar').modal('toggle');
                    //Mensaje de confirmacion de actividad
                    swal({
                        position: 'center',
                        type: 'success',
                        title: 'Relizado!',
                        text: 'El productor fue modificado',
                        showConfirmButton: false,
                        timer: 2500
                    });
                    consultarProductos();
                }
            }).fail(function(error) {
                console.log(error);
            });
        }
    });
}

function consultarProveedores($selector, op,idPro) {
    //Consulta de proveedores disponibles
    $.post(baseurl + 'Alimentacion/cProveedor/consultarProveedores', {
        op: 2
    }, function(data) {
        var resulSet = JSON.parse(data);
        $selector.empty();
        $selector.html('<option value="0">Seleccione...</option>');
        $.each(resulSet, function(resulSet, row) {
            if (row.estado == 1) {
                $selector.append('<option value="' + row.idProveedor + '">' + row.nombre + '</option>');
                // .append('<option value="' + row.idProveedor + '">' + row.nombre + '</option>');
            }
        });
        // Colocacion de los datos
        if (op == 1) {
            //Nombre del proveedor(Identificador)
            // dato = $('#modificarProducto').find('tr').eq(valor).find('td').eq(3).data('id');
            $('#selectProveedorM > option[value="' + idPro + '"]').attr('selected', 'selected');
        }
    });
    //Consulta de proveedores disponibles -- fin --
}
//Llenar los campos del modal
function llenarCamposModificar(valor) {
    // row.idProducto + ';' + row.nombre + ';' + row.precio + ';' + row.idproveedor
    var vector = valor.split(';');
    // ConsultarPRoveedores
    consultarProveedores($selec2, 1, vector[3]);
    //Id del producto
    // var idDetalle = $('#modificarProducto').find('tr').eq(valor).find('th').eq(0).text();
    //Nombre del producto
    // var dato = $('#modificarProducto').find('tr').eq(valor).find('td').eq(0).text();
    $('#txtProductoM').val(vector[1]);
    //Precio del producto
    // dato = $('#modificarProducto').find('tr').eq(valor).find('td').eq(1).text();
    $('#txtPrecioProductoM').val(vector[2]);
    //Nombre del proveedor(Identificador)
    // dato = $('#modificarProducto').find('tr').eq(valor).find('td').eq(3).data('id');
    // $('#selectProveedorM > option[value="' + vector[3] + '"]').attr('selected', 'selected');
    //console.log(dato);
    $('#cActualizar').attr('value', vector[0]);
}
//Funciones de la clase
function consultarProductos() {
    $.post(baseurl + 'Alimentacion/cProductos/consultarProductos', {
        op: 1,
        idProveedor: 0
    }, function(data) {
        var result = JSON.parse(data);
        //console.log(result);
        $divTable.empty();
        $divTable.html('<table id="tblProducto" class="display">'+
                '<thead>' + '<tr>' +
                 '<th>#</th>' + 
                 '<th>Nombre</th>' + 
                 '<th>Precio</th>' + 
                 '<th>estado</th>' + 
                 '<th>proveedor</th>' +
                 '<th>Acciones</th>' + 
                 '</thead>' + 
                 '<tbody id="modificarProducto">'+

                 '</tbody>'+
              '</table>');
        var $tabla = $('#tblProducto');
        $tabla.html('<thead>' + '<tr>' + '<th>#</th>' + '<th>Nombre</th>' + '<th>Precio</th>' + '<th>estado</th>' + '<th>proveedor</th>' + '<th>Acciones</th>' + '</tr>' + '</thead>' + '<tbody id="modificarProducto">');
        $.each(result, function(base, row) {
            $tabla.append('<tr id="' + row.idProducto + '">' + '<th>' + row.idProducto + '</th>' + '<td>' + row.nombre + '</td>' + '<td>' + row.precio + '</td>' + '<td>' + clasificarEstado(row.estado) + '</td>' + '<td data-id="' + row.idproveedor + '">' + row.proveedor + '</td>' + '<td>' + '<button data-target="#modificar" value="' + row.idProducto + ';' + row.nombre + ';' + row.precio + ';' + row.idproveedor + '" onclick="llenarCamposModificar(this.value)"  type="button" class="btn btn-primary btn-xs" data-toggle="modal"><span><i class="far fa-edit"></i>Editar</span></button></p>' + '<button type="button"  value=' + row.idProducto + ' ' + clasificarBoton(row.estado) + '</span></button>' + '</td>' + '</tr>');
            // con++;
        });
        $tabla.DataTable({
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
        // con = 0;
        // $tabla.append('</tbody>');
    });
}
//Retornair item estado
function clasificarBoton(estado) { //Clasifica si es boton de activar o eliminar para cada proveedor
    if (estado == 1) {
        return 'class="btn btn-danger btn-xs" onclick="eliminarProducto(this.value)"><span><i class="fas fa-trash-alt"></i> Eliminar';
    } else {
        return 'class="btn btn-success btn-xs" onclick="eliminarProducto(this.value)"><span><i class="fas fa-check"></i> Activar';
    }
}
//Retornair item estado
function clasificarEstado(estado) { //Clasifica el estado de cada proveedor
    if (estado == 1) {
        return mensaje = '<span><small class="label bg-green">Activo</small></span>';
    } else {
        return mensaje = '<span><small class="label bg-red">Inactivo</small></span>';
    }
}
//=============================================================================
function valida(e) { //Validar que el input solo permita caracteres numericos
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

function validarCampos($nombre, $precio) {
    //Nombre del proveedor
    valor = $nombre.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        //if(!$nombre.parent().attr('class').hasClass('has-error')){
        $nombre.parent().addClass('has-error');
    } else if (!isNaN(valor)) {
        //if(!$nombre.parent().classList.contains('has-error')){
        $nombre.parent().addClass('has-error');
    } else {
        //if(!$nombre.parent().classList.contains('has-success')){
        $nombre.parent().addClass('has-success');
        $nombre.parent().removeClass('has-error');
    }
    //Telefono del proveedor
    valor = $precio.val();
    if (valor == null || valor.length == 0 || /^\s+$/.test(valor)) {
        //if(!$nombre.parent().attr('class').hasClass('has-error')){
        $precio.parent().addClass('has-error');
    } else if (isNaN(valor)) {
        //if(!$nombre.parent().classList.contains('has-error')){
        $precio.parent().addClass('has-error');
    } else {
        //if(!$nombre.parent().classList.contains('has-success')){
        $precio.parent().addClass('has-success');
        $precio.parent().removeClass('has-error');
    }
}