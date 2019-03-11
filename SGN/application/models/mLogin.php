<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
error_reporting(E_ALL);//Reporting de errores//Eliminar cuando se termine el desarrollo
ini_set('display_errors', 1);
class mLogin extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

public function iniciarSessionM($datos)
{	
		$query= $this->db->query("CALL PA_loginSistema('{$datos['ususario']}', '{$datos['contraseña']}');");

	    // $this->db->select('idTipo_usuario');
		// $this->db->from('usuario');
		// $this->db->where('nombre',$datos['ususario']);
		// $this->db->where('contraseña',$datos['contraseña']);
		
		// $resulSet= $this->db->get();
		$result= $query->row();

		// if($resulSet->num_rows()==1){
		// 	$r= $resulSet->row();
		// 	//======================================================
		// 	$user_session=array('tipo_usuario' => $r->idTipo_usuario);	
		// 	//======================================================
		// 	$this->session->set_userdata($user_session);
		// 	return $r->idTipo_usuario;
		// }else{
		// 	return 0;
		// }
		$res=$result->respuesta;
		if ($res!=0) {
			$id=$result->usuario;
			$name=$result->nombre;
			$user_session=array('tipo_usuario' => $res, 'tipo_usuario_name'=> $name, 'idUser'=> $id);	
		// 	//======================================================
			$this->session->set_userdata($user_session);

			return $res;
		}else{
			return 0;
		}
	/*mysqli_next_result($this->db->conn_id);//Soluciona el problema con del DB_Driver de codeigneiter.


	$query=$this->db->query("CALL PA_Inicio_Session({$datos['ususario']}, {$datos['contraseña']});");
	$res=$query->row();
 	$res=$res->respuesta;

 	var_dump($res);//Error 500 (Error de envio de informacion mediante el metodo post)*/
}


}
?>