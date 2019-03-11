<?php 
/**
* 
*/
class cRestriccion extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Alimentacion/mRestriccion');
	}

	public function consultarConfiguracion()
	{
		$res=$this->mRestriccion->consultarConfiguracionM();

		echo json_encode($res);
	}

	public function modificarConfiguracion(){

		$info['hora1']=$this->input->post('hora1');
		$info['hora2']=$this->input->post('hora2');
		$info['hora3']=$this->input->post('hora3');
		$info['hora4']=$this->input->post('hora4');

		$id=$this->input->post('id');

		$res=$this->mRestriccion->modificarConfiguracionM($info);

		echo json_encode($res);
	}


}

 ?>