<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cAlimentacion extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
	}

	public function index()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
		   redirect('cLogin');
		}else{
		//...
		   $dato['titulo']="Alimentacion";
		   $dato['path']="Alimentacion/cAlimentacion";
		   $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		   $dato['tipoUser']=$this->session->userdata('tipo_usuario');
		//...
		   $this->load->view('Layout/Header1',$dato);
		   $this->load->view('Layout/Menulateral');
		   $this->load->view('Alimentacion/Contenido');
		   $this->load->view('Layout/Footer');
		   $this->load->view('Layout/clausulas');
		}
	}

	public function proveedor()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
		  redirect('cLogin');
		}else{
		//...
		   $dato['titulo']="Alimentacion";
		   $dato['path']="cAlimentacion";
		   $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		   $dato['tipoUser']=$this->session->userdata('tipo_usuario');
		//...	
		  $this->load->view('Layout/Header1',$dato);
		  $this->load->view('Layout/Menulateral');
		  $this->load->view('Alimentacion/Proveedor');
		  $this->load->view('Layout/Footer');
		  $this->load->view('Layout/clausulas');		
		}
	}

	public function producto()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
		  redirect('cLogin');
		}else{
		//...
		   $dato['titulo']="Alimentacion";
		   $dato['path']="cAlimentacion";
		   $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		   $dato['tipoUser']=$this->session->userdata('tipo_usuario');
		//...
		  $this->load->view('Layout/Header1',$dato);
		  $this->load->view('Layout/MenuLateral');
		  $this->load->view('Alimentacion/producto');
		  $this->load->view('Layout/Footer');
		  $this->load->view('Layout/clausulas');	
		}
	}

	public function configuracion()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
		  redirect('cLogin');
		}else{
		//...
		   $dato['titulo']="Alimentacion";
		   $dato['path']="cAlimentacion";
		   $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		   $dato['tipoUser']=$this->session->userdata('tipo_usuario');
		//...
		  $this->load->view('Layout/Header1',$dato);
		  $this->load->view('Layout/MenuLateral');
		  $this->load->view('Alimentacion/configuracion');
		  $this->load->view('Layout/Footer');
		  $this->load->view('Layout/clausulas');		
		}
	}
}

?>