<?php 
/**
* 
*/
class mRestriccion extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	public function consultarConfiguracionM(){
		
		$this->db->select('*');
		$this->db->from('restriccion');

		$r= $this->db->get();

		return $r->row();
	}

	public function modificarConfiguracionM($info){//Falta el modificar restriccion
	//Validacion de que la hora no sea mayor la de inicio que la de fin
 	mysqli_next_result($this->db->conn_id);//Esta linea me soluciona el problema del store procedure de multiples parametros.
 	$query=$this->db->query("CALL SA_PA_ValidarTiemposRestriccion('{$info['hora1']}', '{$info['hora2']}', '{$info['hora3']}', '{$info['hora4']}');");//El rpocedimiento me va a validar que la hora numero 1 no sea mayor que la hora numero2
 	// mysqli_next_result($this->db->conn_id);
 	$res=$query->row();
 	$res=$res->respuesta;
 	if($res){
 		mysqli_next_result($this->db->conn_id);
 		//Actualiza la configuracion
 	    $query=$this->db->query("CALL SA_PA_ModificarRestriccion('{$info['hora1']}', '{$info['hora2']}', '{$info['hora3']}', '{$info['hora4']}');"); 
		// $this->db->where('idRestriccion',1);
		// $this->db->update('restriccion',$info);
 		$r=$query->row();
		//$r= $this->db->get();

		return $r->respuesta;
 	}else{
 		//No se actualiza por que las horas noconcuerdan
 		return 0;
 	}

	}

}

 ?>