<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mEmpresa extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
// Se encarga de consultar todas las empresas que esten con estado vigente.
    public function getEmpresas()
	{
		$this->db->select('idEmpresa,nombre');
		$this->db->from('empresa');
		$this->db->where('estado',1);

		$result= $this->db->get();
		return $r=$result->result();
	}
// Se encarga de registrar o modificar la empresas que van hacer parte del sistema de información
	public function registrarModificarEstadoEmpresaM($info)
	{

		$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoEmpresas({$info['idEmpresa']},'{$info['nombreEmpresa']}',{$info['estadoEmpresa']});");

		$res=$query->row();

		return $res->respuesta;
	}
// Se encarga de consultar las empresas que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
	public function consultarEmpresasM($op)
 	{
 		$query=$this->db->query("CALL SE_PA_ConsultarEmpresas({$op});");

 		$res=$query->result();

 		return $res;
 	}
}

 ?>