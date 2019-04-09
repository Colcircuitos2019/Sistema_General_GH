<?php //Esta pendiente por trabajar------
// echo var_dump(defined('BASEPATH'));
// if (defined('BASEPATH')) {//Validar si el servicio es consola o navegdor
  $fechaActual=getdate();
  $conectar= conexion();
  /*Consultar hora de envio*/
  // $proveedores= $conectar->query("CALL SA_PA_ValidarRestriccionTiempos();"); //Aun no hay necesidad de implementarlo
  // ...
  /*Consultar Correos electronicos de proveedores*/
  $query= $conectar->query("CALL SA_PA_ConsultarCorreosProveedor();");
  // ...
  // Cerrar conexion
  cerrarConexion($conectar);
  // ...
  require('PHPMail/archivosformulario/class.phpmailer.php'); // Requiere PHPMAILER para poder enviar el formulario desde el SMTP de google/**/
  // ...
  foreach ($query as $row) {
  	$conectar= conexion();
  	// ... Valida que el día actual que se este cruzando no se vuelvan a enviar más correos
  	$idProveedor=$row['idProveedor'];
  	$envioDiario= $conectar->query("CALL SA_PA_ValidarEnvioPedidosDiario(".$idProveedor.");");
      // ...
  	if ($fila= mysqli_fetch_row($envioDiario)) {//Trae la respuesta del procedimiento almacenado
  		// var_dump($fila);
  		if ($fila[0]==1) {
  			// Enviar el correo
  			$mail= new PHPMailer();
  			// auxiliargestionhumana@colcircuitos.com <- Correo actual de donde se va ir los pedidos diarios
  			$mail->From ='auxiliargestionhumana@colcircuitos.com';//aracelly.ospina@colcircuitos.com || auxiliar.facturacion@colcircuitos.com
  			$mail->FromName='Auxiliar Gestión Humana';//Arracelly Ospina || Auxiliar Facturación
  			$mail->AddAddress($row['email']);
  			// 
  			$mail->WordWrap= 50;
  			$mail->isHTML(true);
  			$mail->Subject ="Colcircuitos S.A.S Pedidos del dia $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]";
  			// Cerrar conexion
  			cerrarConexion($conectar);
  			// ...
  			//Establecer conexión base de datos nuevamente
  			$conectar= conexion();

  			// Consultar pedidos del dia...
  			$pedidos= $conectar->query("CALL SA_PA_CantidadProductosProveedorDia(".$idProveedor.");");
  			// ...
  			// Cerrar conexion
  			cerrarConexion($conectar);
  			// ...
  			//Establecer conexión base de datos nuevamente...
  			$conectar= conexion();
  			
  			// Consultar pedidos por empleado...
  			$empleadoP= $conectar->query("CALL SA_PA_ReportePedidosPorempleadoProveedor(".$idProveedor.");");
  			// 
  			$mensaje= generarMensajeProveedor($pedidos,$empleadoP);
  			// 
  			$mail->Body = ($mensaje!=''?$mensaje:'El día de hoy no se realizaron pedidos para su establecimiento.');
  			// Protocol Text Mail Simple
  			$mail->IsSMTP(); 
  			$mail->Host = "ssl://smtp.gmail.com:465";  // Servidor de Salida. 465 es uno de los puertos que usa Google para su servidor SMTP
  			$mail->SMTPAuth = true; 
  			$mail->Username = "auxiliargestionhumana@colcircuitos.com";  // Correo Electrónico aracelly.ospina@colcircuitos.com, liliana.restrepo@colcircuitos.com
  			$mail->Password = "mail.col75"; // Contraseña del correo mail.col2, Mail.col01+, 

  			if ($mail->Send()) {
  				// Cerrar conexion
  				cerrarConexion($conectar);

  				//Establecer conexión base de datos nuevamente...
  				$conectar= conexion();
  				// 
  				$conectar->query("CALL SA_PA_RegistrarFechaEnvioCorreoPedidos(".$idProveedor.");");

  				// Cerrar conexion
  				cerrarConexion($conectar);
  			}
  		}
  	}
  }
  // ...
// }else{
//   echo("there is no server request");
// }
// Funciones...
// ...
function conexion(){//Iniciar la conexion con la base de datos
	$conexion= new mysqli("localhost:33066","root","SaAFjmXlMRvppyqW","sgn") or die('No se pudo conectar: '.mysql_error());
	/*Verificar conexion*/
	if ($conexion->connect_errno) {
		printf("Error al conectar: %s\n",$conexion->connect_error);
		exit();
	}
	return 	$conexion;
}
// Cerrar la conexion
function cerrarConexion($conexion)
{
	$conexion->close();
}
// 
function generarMensajeProveedor($pedidos,$empleados)
{
  // Variables
  $total=0;
  $existe=0;
  $fechaActual=getdate();
  $mensaje=''; 
  // Header
  $mensaje.="<TABLE BORDER CELLPADDING=10 CELLSPACING=0>
                   <tr>
                     <th COLSPAN=4>Pedidos del: $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]</th>
                   </tr>
                   <tr>
                     <th>Producto</th>
                     <th>Momento</th>
                     <th>Cantidad</th>
                     <th>Precio</th>
                   </tr>";
    //body 
    foreach ($pedidos as $row1) {
        //Cabeza de la tabla
        $existe++;
        $mensaje.='<tr>
                    <td>'.$row1['producto'].'</td>
                    <td>'.($row1['momento']==1?'Desayuno':'Almuerzo').'</td>
                    <td>'.$row1['cantidad'].'</td>
                    <td>'.$row1['valor'].'</td>
                  </tr>';
        //Consultar Detalles pedido, id del proveedor y id del pedido
        // $detalles= $this->consultarDetallePorProveedorPedido($row->idProveedor,$row1->idPedido);
        $total+=$row1['subValor'];
        // $op=0;
      }
      // Footer
      $mensaje.='<tr>
                    <th COLSPAN=3 ALIGN=center> Precio Total</th>
                    <td ALIGN=center>'.convertirNumeroAPesos($total).'</td>
                  </tr></TABLE>';
      //Pedidos por empleado para cada proveedor.
       $mensaje.="<br><br><TABLE BORDER CELLPADDING=10 CELLSPACING=0>
                   <tr>
                     <th COLSPAN=4>Pedidos por empleado del: $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]</th>
                   </tr>
                   <tr>
                     <th>Producto</th>
                     <th>Momento</th>
                     <th>Cantidad</th>
                     <th>Empleado</th>
                   </tr>";           
       foreach ($empleados as $row) {
         $mensaje.='<tr>
                    <td>'.$row['producto'].'</td>
                    <td>'.($row['momento']==1?'Desayuno':'Almuerzo').'</td>
                    <td>'.$row['cantidad'].'</td>
                    <td>'.utf8_decode(($row['nombre1'].' '.$row['nombre2'].' '.$row['apellido1'].' '.$row['apellido2'])).'</td>
                  </tr>';
       }
       $mensaje.='</TABLE>';

    return ($existe>=1?$mensaje:'');                
}

function convertirNumeroAPesos($valor)//no hay necesidad de convertir Strign el Int
{ 
  $res=0;
  switch (strlen($valor)) {
    case 6:
      	$res=3;//STR de tres digitos
      break;
    case 5:
      	$res=2;//STR de dos digitos
      break;
    case 4:
      	$res=1;//STR de un digitos
      break;
    case 3:
      	return '$'.$valor;//Retorna directamente
      break;
  }
  
  $num1=substr($valor,0,$res);//Primer parte del numero
  return '$'.$num1.'.'.substr($valor,$res);//se arma el numero con el punto de mil y se retorna.
}
 ?>
