<?php 
/**
* 
*/
//error_reporting(E_ALL);//Reporting de errores//Eliminar cuando se termine el desarrollo
//ini_set('display_errors', 1);

class cLogin extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('mLogin');
	}


//Retorno de vistas============================
	public function index()
	{
		$this->session->sess_destroy();
		$this->load->view('login.php');
		$this->load->view('Layout/clausulas'); 
	}

//Metodos======================================

	public function iniciarSession()//Esto funcionaria mejor directamente con php
	{
	   $datos['ususario']= $this->input->post('usu');
	   $datos['contraseña']= base64_encode($this->input->post('cont'));

	   //var_dump($datos);
	   $res= $this->mLogin->iniciarSessionM($datos);

	   echo json_encode($res);
	   //var_dump($res);
	   //echo json_encode($res);
	}

	public function iniciarSession1()//Este esta pendiente por implementar 
	{
	   // $datos['ususario']= $this->input->post('username');
	   // $datos['contraseña']= $this->input->post('pass');
	   $datos['ususario']= $_POST['username'];
	   $datos['contraseña']= $_POST['pass'];

	   // isset($datos['ususario'])
	   if ($datos['ususario']!='' && $datos['contraseña']!='') {

	   	   $res= $this->mLogin->iniciarSessionM($datos);
	   	   // Enrutamiento de la información
	   	       			if ($res!=0) {
	   	       			 switch($res) {
	   	                         case 2:
	   	                            //Empelado (Vista de pedidos)
	   	                            redirect('Alimentacion/cPedidos');				
	   	                             break;
	   	                         case 3:
	   	                            //Gestos de alimentacion (Vista de administracion de pedidos)
	   	                            redirect('Alimentacion/cAlimentacion');					
	   	                            // window.location.href = base_url()+'Alimentacion/cAlimentacion';
	   	                             break;
	   	                         case 4:
	   	                            //Gestos pedidos (Vista de listado de todos los pedidos)
	   	                            redirect('Alimentacion/cPedidos/pedidos');				
	   	                            // window.location.href = base_url()+'Alimentacion/cPedidos/pedidos';
	   	                             break;
	   	                         case 5:
	   	                         case 6:
	   	                            //Gestor Humano
	   	                            redirect('Empleado/cMenu');					
	   	                            // window.location.href = base_url()+'Empleado/cMenu';
	   	                             break;
	   	                         case 7:
	   	                         	//Lider de produccion
	   	                         	  redirect('Empleado/cMenu');
	   	                         	break;    
	   	                         // case 6:
	   	                            //Facilitador
	   	                            // redirect('Empleado/cMenu');					
	   	                            // window.location.href = base_url()+'Empleado/cMenu';//Faltan vistas
	   	                             // break;
	   	                       }
	   	   	    		}else{
	   	   	    		echo "swal({
	   	   			            type: 'error',
	   	                           title: 'Incorrecto',
	   	                           text: 'El usuario o la contraseña son incorrectos, porfavor intente nuevamente.',
	   	                           timer: 3000,
	   	                       });";
	   	   	    		}
	   }
	}

	public function cerrarSession()
	{	
		//Se destruye la variable de session y de redirecciona al login.
		// $this->output->set_header("Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
		// $this->output->set_header("Pragma: no-cache");
		// header('Cache-Control: no-cache, no-store, must-revalidate');
        // header('Pragma: no-cache');
        
		$this->session->sess_destroy();
		redirect('cLogin');
	}
}

 ?>