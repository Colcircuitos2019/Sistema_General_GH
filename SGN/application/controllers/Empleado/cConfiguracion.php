<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* This is a page configuracion horarios
*/
class cConfiguracion extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mConfiguracion');
	}
//Retorno de vistas
	public function index()
	{
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
			$this->load->view('Empleados/Configuracion');
			$this->load->view('Layout/Footer');
			$this->load->view('Layout/clausulas'); 
		} 
	}
//Metodos

	public function consultarConfiguracion()
	{
		$id= $this->input->post('ID');	
		$res=$this->mConfiguracion->consultarConfiguracionM($id);
		echo json_encode($res);
	}

	public function validarHoras()
	{
		$horas['hora1']=$this->input->post('hora1');
		$horas['hora2']=$this->input->post('hora2');

		$res=$this->mConfiguracion->validarHorasM($horas);

		echo $res;
	}

	public function actualizarConfiguracion()
	{
		$horas['HIL']= $this->input->post('HIL');
		$horas['HFL']= $this->input->post('HFL');
		$horas['HID']= $this->input->post('HID');
		$horas['HFD']= $this->input->post('HFD');
		$horas['HIA']= $this->input->post('HIA');
		$horas['HFA']= $this->input->post('HFA');
		$horas['TD']= $this->input->post('TD');
		$horas['TA']= $this->input->post('TA');
		$horas['ID']= $this->input->post('ID');
		$horas['nombre']= $this->input->post('nombre');

		$res=$this->mConfiguracion->registrarActualizarConfiguracionM($horas);

		echo $res;
		
	}

	public function cambiarEstadoHorarioConfiguracion()
	{
		$id= $this->input->post('ID');

		$res= $this->mConfiguracion->cambiarEstadoHorarioConfiguracionM($id);

		echo $res;
	}

}
 ?>