<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cProductos extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Alimentacion/mProducto');
	}


	public function registrarModificarProducto()
	{	
		 $info['idProducto']=$this->input->post('idPrdo');		
		 $info['nombre']=$this->input->post('nombre');
		 $info['precio']=$this->input->post('precio');
		 $info['estado']=true;
		 $info['idProveedor']=$this->input->post('idProveedor');

		 $op=$this->input->post('action');

		 $res=$this->mProducto->registrarModificarProductosM($op,$info);

		 echo json_encode($res);
    }

    public function consultarProductos()
    {	
    	$op=$this->input->post('op');//Opcion de consultar por id o sin id (1 o 2);
    	$idProveedor=$this->input->post('idProveedor');
    	//Consultar todos los productos	
    	$res=$this->mProducto->consultarProductosM($op,$idProveedor);	

    	echo json_encode($res);
    }
    public function eliminarProducto()
    {
		// $infoP['estado']= $this->input->post('estado')=='Activo'?0:1;
		$id= $this->input->post('iddetalle');

		$res= $this->mProducto->eliminarProductosM($id);

		echo json_encode($res);
    }
}

 ?>