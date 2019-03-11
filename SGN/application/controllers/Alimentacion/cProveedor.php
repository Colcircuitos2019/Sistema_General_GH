<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cProveedor extends CI_Controller
{
	
	function __construct() {
		parent::__construct();
		$this->load->model('Alimentacion/mProveedor');
	}

//============================== Metodos
	//Resgistrar o modificar proveedor	
	public function registrarModificarProveedor()
	{	
		$infoP['idProveedor']=$this->input->post('iddetalle');
		$infoP['nombre']=$this->input->post('nombre');
		$infoP['telefono']=$this->input->post('telefono');
		$infoP['estado']=1;
		$infoP['evento']=$this->input->post('evento');
		$infoP['email']=$this->input->post('email');

		$res= $this->mProveedor->registrarModificarProveedorM($infoP);

		echo json_encode($res);
	}
	//Consultar Proveedores
	public function consultarProveedores()
	{	
		$op=$this->input->post('op');

		$info= $this->mProveedor->consultarProveedoresM($op);

		echo json_encode($info);
	}
	//Eliminar proveedores(Cambiar el estado)
	public function eliminarProveedorC()
	{
		$id= $this->input->post('iddetalle');

		$res= $this->mProveedor->eliminarProveedorM($id);

		echo json_encode($res);
	}
}
?>