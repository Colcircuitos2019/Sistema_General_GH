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
		$horas=null;

		$horas['hora1']=$this->input->post('hora1');
		$horas['hora2']=$this->input->post('hora2');

		if(($horas['hora1'] == "00:00:00" || $horas['hora2'] == "00:00:00") && $this->input->post('accion') == 2){

			echo true;

		}else{

			$res=$this->mConfiguracion->validarHorasM($horas);

			echo $res;

		}	
		
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
		$horas['tipo_horario']= $this->input->post('tipo_horario');

		$res=$this->mConfiguracion->registrarActualizarConfiguracionM($horas);

		echo $res;
		
	}

	public function cambiarEstadoHorarioConfiguracion()
	{
		$id= $this->input->post('ID');

		$res= $this->mConfiguracion->cambiarEstadoHorarioConfiguracionM($id);

		echo $res;
	}

	public function consultarTiemposTeoricos()
	{
		$res= $this->mConfiguracion->consultarTiemposTeoricosM();

		echo json_encode($res);
	}

	public function actualizarTiemposteoricos()
	{
		$tiempos['laboral'] = $this->input->post("tiempo_laboral");
		$tiempos['desayuno'] = $this->input->post("tiempo_desayuno");
		$tiempos['almuerzo'] = $this->input->post("tiempo_almuerzo");
	
		$res= $this->mConfiguracion->actualizarTiemposteoricosM($tiempos);

		echo json_encode($res);
	}

	public function consultarHoraSalidaTiempoExtra()
	{
		$hora= $this->mConfiguracion->consultarHoraSalidaTiempoExtraM();

		echo $hora;
	}

	public function gestionarHoraSalidaTiempoExtra()
	{
		$hora = $this->input->post("hora");

		$res= $this->mConfiguracion->gestionarHoraSalidaTiempoExtraM($hora);

		echo $res;

	}

}
 ?>