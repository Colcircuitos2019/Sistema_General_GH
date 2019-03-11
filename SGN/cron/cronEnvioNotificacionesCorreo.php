<?php
  $fechaActual=getdate();
  $conectar= conexion();
  // ...
  $dia="$fechaActual[mday]";
  $mes="$fechaActual[mon]";
  $año="$fechaActual[year]";
  /*Consultar hora de envio*/
  // ...
  /*Consultar personar que llegaron tarda al evento laboral en el día en curso*/
  $query= $conectar->query("CALL SE_PA_ConsultarDetalleNotificacion('$año-$mes-$dia',1);");
  // ...
  $tabla="";
  // ...
  $tabla= generarCuerpoMensaje($query,$tabla,1);//Consultar Cumpleaños -
  // Cerrar conexion
  cerrarConexion($conectar);
  // -------------------------------------------------------------------------------------------------------
  $conectar= conexion();

  $query= $conectar->query("CALL SE_PA_ConsultarDetalleNotificacion('$año-$mes-$dia',2);");
  // ...
  $tabla= generarCuerpoMensaje($query,$tabla,2);//Consultar Aniversarios-
  // echo $tabla;

  cerrarConexion($conectar);
  // -------------------------------------------------------------------------------------------------------
  $conectar= conexion();

  $query= $conectar->query("CALL SE_PA_ConsultarDetalleNotificacion('$año-$mes-$dia',3);");
  // ...
  $tabla= generarCuerpoMensaje($query,$tabla,3);//Consultar Contratos proximos a vencer-
  // echo $tabla;

  cerrarConexion($conectar);
  // -------------------------------------------------------------------------------------------------------
  $conectar= conexion();

  $query= $conectar->query("CALL SE_PA_ConsultarDetalleNotificacion('$año-$mes-$dia',4);");
  // ...
  $tabla= generarCuerpoMensaje($query,$tabla,4);//Consultar llegadas tarde -
  // echo $tabla;

  cerrarConexion($conectar);
  // -------------------------------------------------------------------------------------------------------
  $conectar= conexion();

  $query= $conectar->query("CALL SE_PA_ConsultarDetalleNotificacion('$año-$mes-$dia',5);");
  // ...
  $tabla= generarCuerpoMensaje($query,$tabla,5);//Consultar Nuevos empleados
  // echo $tabla;

  cerrarConexion($conectar);
  // -------------------------------------------------------------------------------------------------------
  // $conectar= conexion();//Pendiente por el desarrollo

  // $query= $conectar->query("CALL SE_PA_ConsultarDetalleNotificacion('$año-$mes-$dia',5);");
  // // ...
  // $tabla= generarCuerpoMensaje($query,$tabla,6);//Consultar Personas que tienen permiso para el día de hoy
  // // echo $tabla;

  // cerrarConexion($conectar);
  // -------------------------------------------------------------------------------------------------------

  // ...
  if ($tabla!='') {
    require('PHPMail/archivosformulario/class.phpmailer.php'); // Requiere PHPMAILER para poder enviar el formulario desde el SMTP de google/**/

    // Consultar correos de los usuarios del sistema que sean facilitadores y gestores humanos
    $conectar= conexion();

    $ususarios= $conectar->query("SELECT u.email FROM usuario u WHERE (u.idTipo_usuario=5 OR u.idTipo_usuario=6) AND u.estado=1 AND u.email!='-';");
    // ...
    cerrarConexion($conectar);
    // ...
    // echo $tabla;
    foreach ($ususarios as $ususario) {//Hacer validacion de envio diarios de los correo, pendiente
      //...
      $correos= explode(";",$ususario['email']);

      for($i = 0; $i < count($correos); $i++){
        // Enviar el correo
        $mail= new PHPMailer();
        // 
        $mail->From ='juan.marulanda@colcircuitos.com';
        $mail->FromName='Asistencia Empleados';
        $mail->AddAddress($correos[$i]);
        // 
        $mail->WordWrap= 50;
        $mail->isHTML(true);
        $mail->Subject ="Colcircuitos S.A.S Notificaciones $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]";
        // ...
        $mail->Body = ($tabla);
        // Protocol Text Mail Simple
        $mail->IsSMTP(); 
        $mail->Host = "ssl://smtp.gmail.com:465";  // Servidor de Salida. 465 es uno de los puertos que usa Google para su servidor SMTP
        $mail->SMTPAuth = true; 
        $mail->Username = "juan.marulanda@colcircuitos.com";  // Correo Electrónico
        $mail->Password = "mail.col79"; // Contraseña del correo

        // if ($mail->Send()) {
        //   echo "Correo enviado";
        // }else{
        //   echo "No envio";
        // }
        $mail->Send();
        // echo $tabla;
      }  
    } 
  }
  // ...
// Funciones...
// ...
function conexion(){//Iniciar la conexion con la base de datos
	$conexion= new mysqli("localhost","root","SaAFjmXlMRvppyqW","sgn") or die('No se pudo conectar: '.mysql_error());
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

function generarCuerpoMensaje($empleados,$mensaje,$idTipoN)
{
  $cont=0;
  // ...
  foreach ($empleados as $empleado) {
    // ...
    if ($cont==0) {
      $mensaje.="<table BORDER CELLPADDING=10 CELLSPACING=0>
                  <thead>
                  <tr>
                    <th COLSPAN=6>".clasificarNotificacion($idTipoN)."</th>
                  </tr>
                   ".clasificarHeaderTabla($idTipoN)."
                  </thead>
                  <tbody>";
      $cont=1;
    }
    // ...
    switch (number_format($idTipoN)) {
      case 1://Cumpleaños
        $mensaje.="<tr>
                    <td ALIGN=center>".$empleado['documento']."</td>
                    <td ALIGN=center>".$empleado['nombre1'].' '.$empleado['nombre2'].' '.$empleado['apellido1'].' '.$empleado['apellido2'].' '."</td>
                    <td ALIGN=center>".$empleado['empresa']."</td>
                    <td ALIGN=center>Piso-".$empleado['genero']."</td>
                    <td ALIGN=center>".($empleado['idRol']==1?"Producción":"Administrativo")."</td>
                    <td ALIGN=center>".$empleado['edad']."</td>
                  </tr>"; 
        break;
      case 2://Aniversario  
      case 3://Contrato
      case 5://Nuevos usuarios
        $mensaje.="<tr>
                    <td ALIGN=center>".$empleado['documento']."</td>
                    <td ALIGN=center>".$empleado['nombre1'].' '.$empleado['nombre2'].' '.$empleado['apellido1'].' '.$empleado['apellido2'].' '."</td>
                    <td ALIGN=center>".$empleado['empresa']."</td>
                    <td ALIGN=center>Piso-".$empleado['genero']."</td>
                    <td ALIGN=center>".($empleado['idRol']==1?"Producción":"Administrativo")."</td>
                    <td ALIGN=center>".$empleado['piso']."</td>
                  </tr>";              
        break;
      case 4://Llegadas Tarde
      $mensaje.="<tr>
                  <td ALIGN=center>".$empleado['documento']."</td>
                  <td ALIGN=center>".$empleado['nombre1'].' '.$empleado['nombre2'].' '.$empleado['apellido1'].' '.$empleado['apellido2'].' '."</td>
                  <td ALIGN=center>".$empleado['empresa']."</td>
                  <td ALIGN=center>Piso-".$empleado['piso']."</td>
                  <td ALIGN=center>".$empleado['hora_inicio']."</td>
                  <td ALIGN=center>".$empleado['tiempoLlegadaTarde']."</td>
                </tr>"; 
        break;
    }                  
  }
  // ...
  if($cont==1){
    $mensaje.="</tbody></table><br><br><br>";
  }

  return $mensaje;
}


function clasificarNotificacion($idNotificacion)
{
  $mensaje="";
  switch (number_format($idNotificacion)) {
    case 1://Cumpleaños
      $mensaje="Cumpleaños del día";
      break;
    case 2://Aniversario
      $mensaje="Aniversario del día";
      break;  
    case 3://Contrato
      $mensaje="Contrato proximos a vencer";
      break;
    case 5://Nuevos Empleados
      $mensaje="Nuevos Empleados";
      break;
    case 4://Llegadas Tarde
      $mensaje="Llegadas tardes";
      break;
  }
  return $mensaje;
}

function clasificarHeaderTabla($idNotificacion)
{
  $mensaje="";
  switch (number_format($idNotificacion)) {
    case 1://Cumpleaños
      $mensaje="<th>Documento</th>
                   <th>Nombre</th>
                   <th>Empresa</th>
                   <th>Genero</th>
                   <th>Rol</th>
                   <th>Años</th>";
      break;
    case 2://Aniversario  
    case 3://Contrato
    case 5://Nuevos usuarios
      $mensaje="<th>Documento</th>
                   <th>Nombre</th>
                   <th>Empresa</th>
                   <th>Genero</th>
                   <th>Rol</th>
                   <th>Piso</th>";
      break;
    case 4://Llegadas Tarde
      $mensaje="<th>Documento</th>
                   <th>Nombre</th>
                   <th>Empresa</th>
                   <th>Piso</th>
                   <th>Ingreso</th>
                   <th>Tiempo Tarde</th>";
      break;
  }
  return $mensaje;
}
 ?>
