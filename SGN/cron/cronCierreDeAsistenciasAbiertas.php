<?php 

# Consultar todos los operarios que tengan una 

$conexion = conexion();

$operarios = $conexion->query("SELECT a.documento FROM asistencia a WHERE a.inicio IS NOT null AND a.fin IS null GROUP BY a.documento");

destruir_conexion($conexion);


foreach ($operarios as $operario) {
	
	$conexion = conexion();

	var_dump($operario);

	// $conexion->query("CALL SI_PA_CierreDeAsistenciaAbiertas({$operario["documento"]});");

	destruir_conexion($conexion);

}


function conexion()
{
	$conexion = new mysqli('localhost:33066','root','SaAFjmXlMRvppyqW','sgn') or die("Error: " + mysql_error());	

	return $conexion;
}

function destruir_conexion($conexion)
{
	$conexion->close();
}


 ?>