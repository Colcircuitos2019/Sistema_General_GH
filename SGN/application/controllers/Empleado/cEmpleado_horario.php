<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cEmpleado_horario extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mEmpleado_horario');
	}
	// ...
	public function registrarModificarEmpleadoHorario()
	{
		$info['ID']= $this->input->post('idD');
		$info['documento']= $this->input->post('documento');
		$info['configuracion']= $this->input->post('con');
		$info['inicial']= $this->input->post('diaI');
		$info['fin']= $this->input->post('diaF');

		$res= $this->mEmpleado_horario->registrarModificarEmpleadoHorarioM($info);

		echo $res;
	}

	public function consultarEmpleadoHorario()
	{
		$doc= $this->input->post('documento');
		$id= $this->input->post('id');

		$res= $this->mEmpleado_horario->consultarEmpleadoHorarioM($doc,$id);

		echo json_encode($res);
	}

	public function cambiarEstadoEmpleadoHorario()
	{
		$info['ID']= $this->input->post('idD');
		$info['documento']= $this->input->post('documento');

		$res= $this->mEmpleado_horario->cambiarEstadoEmpleadoHorarioM($info);

		echo $res;
	}

	public function consultarNombreEmpelado()
	{
		$doc= $this->input->post('documento');

		$res= $this->mEmpleado_horario->consultarNombreEmpeladoM($doc);

		echo $res;
	}

	public function validarExistencia()
	{
		# code...
	}

}

 ?>