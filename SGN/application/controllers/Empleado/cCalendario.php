<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cCalendario extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
	}

	//Retorno de vistas
  public function index(){
  	if ($this->session->userdata('tipo_usuario')==false) {
  	  redirect('cLogin');
  	}else{
        $dato['titulo']="Empleados";
        $dato['path']="Empleado/cMenu";
        $dato['tipoUser']=$this->session->userdata('tipo_usuario');
        $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
        //... 
        $this->load->view('Layout/Header1',$dato);
        $this->load->view('Layout/MenuLateral');
        $this->load->view('Empleados/calendario');
        $this->load->view('Layout/Footer');
        $this->load->view('Layout/clausulas');  
  	}
  }
}
 ?>