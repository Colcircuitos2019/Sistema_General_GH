<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mConfiguracion extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
//Metodos
	// Se encarga de consultar solo una configuracion de horarios de eventos
	public function consultarConfiguracionM($id)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarConfiguracion({$id});");

		return $query->result();
	}
	// Se encarga de validar que la hora numero 1 no sea mayor que la hora numero 2 
	public function validarHorasM($horas)
	{
		$query=$this->db->query("CALL SE_PA_ValidarHorasConfiguracion('{$horas['hora1']}', '{$horas['hora2']}')");

		$res=$query->row();

		return $res->respuesta;
	}

	public function registrarActualizarConfiguracionM($horas)
	{
		$query=$this->db->query("CALL SE_PA_ActualizarConfiguracion('{$horas['HIL']}', '{$horas['HFL']}', '{$horas['HID']}', '{$horas['HFD']}', '{$horas['HIA']}', '{$horas['HFA']}', '{$horas['TD']}', '{$horas['TA']}', {$horas['ID']}, '{$horas['nombre']}');");
		$res=$query->row();

		return $res->respuesta;
	}

	public function cambiarEstadoHorarioConfiguracionM($id)
	{
		$query=$this->db->query("CALL SE_PA_CambiarEstadoConfiguracionHorarioEmpleado({$id});");
		
		$res=$query->row();

		return $res->respuesta;
	}

}
 ?>