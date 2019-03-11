<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mUsuario extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	// metodos
	public function consultarTiposUsuariosM()
	{
		$query=$this->db->query('CAll SE_PA_ConsultarTiposUsuario();');

		$r=$query->result();

		return $r;
	}

	public function registrarModificarUsuariosM($info,$op)
    {
  
 	$query=$this->db->query("CAll SE_PA_RegistrarModificarUsuarios({$info['idU']}, '{$info['usuario']}', '{$info['contra']}', {$info['idTipo']}, {$op},'{$info['correo']}');");

	$r=$query->row();

	return $r->respuesta;
  	
    }

    public function consultarUsuariosM($id)
    {
		$query=$this->db->query("CAll SE_PA_ConsultarUsuarios({$id});");

		$r=$query->result();

		return $r;  	  
    }

    public function validarUsuariorepetidoM($user)
    {
  	    $query=$this->db->query("CAll SE_PA_ValidarUsuario('{$user}');");

		$r=$query->row();

		return $r->respuesta; 
    }

    public function eliminarUsuarioM($id)
    {
    	$query= $this->db->query("CALL SE_CambiarEstadoUsuario({$id});");

    	$r= $query->row();

    	return $r->respuesta;
    }
  
}
 ?>