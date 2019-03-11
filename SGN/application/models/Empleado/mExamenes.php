<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class mExamenes extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	public function registrarModificarEliminarCRUDM($info)
	{
		$query= $this->db->query("CALL SE_PA_RegistrarModificarEliminarExamenesMedicos({$info['idExamen']},'{$info['documento']}',{$info['tipoExamen']},'{$info['OtroExamen']}','{$info['Motivo']}','{$info['FechaPlazo']}','{$info['FechaRetorno']}');");

		$res=$query->row();

		return $res->respuesta;
	}

	public function consultarExamenesM($id)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarExamenesMedicos({$id});");

		$res=$query->result();

		return $res;
	}

	public function eliminarExamenEmpleadoM($idEx)
	{
		$query= $this->db->query("CALL SE_PA_EliminarExamenEmpleado({$idEx});");

		$res=$query->row();

		return $res->respuesta;
	}
}
 ?>