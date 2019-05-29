<?php 
# Esta tarea programada se va a ejecutar todos los días a las 4:35 PM y a las 11:30 PM.

# Consultar todos los operarios que tengan una 

$conexion = conexion();

$operarios = $conexion->query("SELECT a.documento FROM asistencia a WHERE a.inicio IS NOT null AND a.fin IS null GROUP BY a.documento");

destruir_conexion($conexion);


foreach ($operarios as $operario) {
	
	$conexion = conexion();

	$conexion->query("CALL SI_PA_CierreDeAsistenciaAbiertas('{$operario["documento"]}');");

	destruir_conexion($conexion);

}


function conexion()
{
	$conexion = new mysqli('localhost','JuanMarulanda','SaAFjmXlMRvppyqW','sgn') or die("Error: " + mysql_error());	

	return $conexion;
}

function destruir_conexion($conexion)
{
	$conexion->close();
}


 ?>