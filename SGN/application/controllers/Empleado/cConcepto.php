<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cConcepto extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mConcepto');
	}
// Retorno de vistas
	public function index()
	{
		# code...
	}
//Metodos
   public function consultarConceptos()
   {
 	 $res=$this->mConcepto->consultarConceptosM();

 	 echo json_encode($res);
   } 
}

 ?>