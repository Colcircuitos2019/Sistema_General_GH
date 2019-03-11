<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mConcepto extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
	// Se encarga de consultar todos los conceptos
	public function consultarConceptosM()
    {
 	  $query=$this->db->query("CALL SE_PA_ConsultarConceptosPermiso();");
 	  $r=$query->result();

 	  return $r;
    } 
}

 ?>