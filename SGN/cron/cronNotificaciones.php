<?php 
// Esta funcion se ejecutara todos los días a las 6:30 AM para crear las notificaciones del día de las personas que cumplean años, que tienen un contrato proximo a vencer

$conexion=conexion(); //Establecer conexión con la base de datos

// Consultar ususarios tipo gestores humanos....
$ususarios= $conexion->query("SELECT u.idUsuario FROM usuario u WHERE u.idTipo_usuario=5");


// Cerrar conexion
cerrarConexion($conexion);

foreach ($ususarios as $ususario) {
	$conexion=conexion(); //Establecer conexión con la base de datos

	// Registrar notificaciones del día de hoy!!
	$conexion->query("CALL PA_GenerarNotificacionesDelDia(".$ususario['idUsuario'].");");

	// var_dump($ususario['idUsuario']);
	// Cerrar conexion
	cerrarConexion($conexion);
}


function conexion(){//Iniciar la conexion con la base de datos
	$conexion= new mysqli("localhost","root","SaAFjmXlMRvppyqW","sgn") or die('No se pudo conectar: '.mysql_error());
	/*Verificar conexion*/
	if ($conexion->connect_errno) {
		printf("Error al conectar: %s\n",$conexion->connect_error);
		exit();
	}
	return 	$conexion;
}

function cerrarConexion($conexion)
{
	$conexion->close();
}

 ?>