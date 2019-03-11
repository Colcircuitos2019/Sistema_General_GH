<?php 
// Esto puede estar pendiente a cambios cuando el sistema permita horarios de un día para otro

$conexion= conexion();

$operarios=$conexion->query("CALL SE_PA_ConsultarOperariosEstadoInicialAsistencia()");//Consulta a los empleados y su estado de asistencia y la hora en que llego en su ultimo evento laboral del día en cuerzo.

cerrarConexion($conexion);

foreach ($operarios as $operario) {
	//...
	if ($operario['asistencia']==1 && $operario['horaLlegada']==null) {
		//...
		$conexion = conexion();

		$conexion->query("CALL SE_PA_CambiarEstadoDeAsistenciaOperarioInicial('{$operario['documento']}')");
		//...
		cerrarConexion($conexion);
	}
}


//Establecer conexion con la base de datos
function conexion()
{
	$con= new mysqli("localhost","root","SaAFjmXlMRvppyqW","sgn") or die("La conexion no se puedo establecer"+ mysql_error());

	return $con;
}

//Destruir la conexion con la base de datos
function cerrarConexion($conexion){

 	$conexion->close();

}

 ?>