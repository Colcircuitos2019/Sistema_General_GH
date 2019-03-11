<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mEmpleado_horario extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
	// ...
	public function registrarModificarEmpleadoHorarioM($info)
	{
		$query= $this->db->query("CALL SE_PA_RegistrarModificarEmpleadoHorario({$info['ID']},'{$info['documento']}',{$info['configuracion']},{$info['inicial']},{$info['fin']});");

		$result=$query->row();

		return $result->respuesta;
	}

	public function consultarEmpleadoHorarioM($doc,$id)
	{
	 	$query= $this->db->query("CALL SE_PA_ConsultarHorarioEmpleado('{$doc}',{$id});");

	 	$result=$query->result();

	 	return $result;
	}

	public function cambiarEstadoEmpleadoHorarioM($info)
	{
		$query= $this->db->query("CALL SE_PA_CambiarEstadoHorarioEmpleado({$info['ID']},'{$info['documento']}');");

		$result=$query->row();

		return $result->respuesta;
	}

	public function consultarNombreEmpeladoM($doc)
	{
		$query= $this->db->query("SELECT CONCAT(e.nombre1,' ',e.nombre2,' ',e.apellido1,' ',e.apellido2) AS nombre FROM empleado e WHERE e.documento='{$doc}'");

		$result=$query->row();

		return $result->nombre;
	}

	public function consultarDiasHorarioEmpleadoM($dato,$accion)
	{
		if ($accion==1) {//Conulta el empleado por la contraseña
			$query= $this->db->query("SELECT e.idConfiguracion,e.diaInicio,e.diaFin FROM empleado_horario e WHERE e.documento=(SELECT em.documento FROM empleado em WHERE em.contraseña='{$dato}') AND e.estado=1;");
		}elseif($accion==0){//Consulta el empleado por el numero de documento de identidad
			$query= $this->db->query("SELECT e.idConfiguracion,e.diaInicio,e.diaFin FROM empleado_horario e WHERE e.documento='{$dato}' AND e.estado=1;");
		}
		
		$result=$query->result();

		$this->db->close();

		return $result;
	}

	public function diaEnCursoM()
	{
		$query= $this->db->query("SELECT DATE_FORMAT(CURDATE(),'%w') AS diaSemana;");

		$result=$query->row();

		$this->db->close();

		return $result->diaSemana;
	}

	// public function consultarIDConfiguracionEmpleadoHorarioM($info)
	// {
	// 	$query= $this->db->query("CALL ();");

	// 	$result=$query->row();

	// 	$this->db->close();

	// 	return $result->respuesta;
	// }

}

 ?>