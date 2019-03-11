<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class cHistorial extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mHistorial');
	}

	public function index()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
		  redirect('cLogin');
		}else{
		  $this->load->model('Empleado/mEmpleado');
		  // ...
		  $datos['empleados']=$this->mEmpleado->consultarEmpleadosM(-2);
		  //...
		  $dato['titulo']="Empleados";
		  $dato['path']="Empleado/cMenu";
		  $dato['tipoUser']=$this->session->userdata('tipo_usuario');
		  $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		  //... 
		  $this->load->view('Layout/Header1',$dato);
		  //...
		  if (number_format($this->session->userdata('tipo_usuario'))==6) {
		  //Facilitador
		  	$this->load->view('Layout/MenuLateral',$datos);
		  }else{
		  //Gestor humano
		  	$this->load->view('Layout/MenuLateral',$datos);
		  }
		  $this->load->view('Empleados/historial');
		  $this->load->view('Layout/Footer');
		  $this->load->view('Layout/clausulas'); 	
		}
	}

	
	public function consultarCantidadEstadosEventos()
	{
		$info['documento']= $this->input->post('documento');	
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['evento']= $this->input->post('evento');	

		$res= $this->mHistorial->consultarCantidadEstadosEventosM($info);

		echo json_encode($res);
	}

	public function consultarEventos()
	{
		$info['documento']= $this->input->post('documento');	
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['evento']= $this->input->post('evento');	

		$res= $this->mHistorial->consultarEventosM($info);

		echo json_encode($res);
	}

	public function totalHorasTrabajadasNormales()
	{
		$info['documento']= $this->input->post('documento');
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['evento']= $this->input->post('evento');// 1= Horas trabajadas Normales o 2=Horas trabajadas extras
		$info['estado']= $this->input->post('estado');// 1= Horas aprovadas o 0= Horas no aprobadas

		$nHoras= $this->mHistorial->totalHorasTrabajadasNormalesM($info);
		//
		echo $this->sumarHorasLaborales($nHoras);
		// echo json_encode($res);
	}

	public function consultarHorasExtrasAceptadasYRechazadas()
	{
		$info['documento']= $this->input->post('documento');
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['accion']= $this->input->post('accion');// 1= Horas extras aprobadas o 2=Horas extras rechazadas

		$nHoras= $this->mHistorial->consultarHorasExtrasAceptadasYRechazadasM($info);
		//
		echo $this->sumarHorasLaborales($nHoras);
		// echo json_encode($res);
	}

	public function consultarTiemposEventosDesayunoOAlmuerzo()
	{
		$info['documento']= $this->input->post('documento');
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['evento']= $this->input->post('evento');// 1= Horas trabajadas Normales o 2=Horas trabajadas extras

		$nHoras= $this->mHistorial->consultarTiemposEventosDesayunoOAlmuerzoM($info);
		//
		echo $this->sumarHorasLaborales($nHoras);

	}
/*Queda pendendientes por desarrollas esta funcion de calculcar el tiempo pre definido de labor de los empleados...*/
	public function horariosPropuestosEmpresa()
	{
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['accion']= $this->input->post('accion');// 1= Horas trabajadas Normales o 2=Horas trabajadas extras

		$nHoras= $this->mHistorial->horariosPropuestosEmpresaM($info);

		echo $this->SumarHrasLaboralesPropuestaEmpresa($nHoras);
	}

	public function SumarHrasLaboralesPropuestaEmpresa($result)
	{
		$total='00:00:00';
		foreach ($result as $hora) {
			for ($i=0; $i < $hora->numeroM; $i++) { 
			$info['horaT']=$total;
			$info['horaS']=$hora->tiempo;
			// ...
			$total=$this->mHistorial->sumarTiemposHorasLaboralesM($info);
			}
		}
		return $total;
	}

	public function sumarHorasLaborales($horas)//Calcular total de horas trabajadas (Normales o extra laborales)...
	{
		$total='00:00:00';
		// ...
		foreach ($horas as $hora) {
			// ...
			$info['horaT']=$total;
			$info['horaS']=$hora->numero_horas;
			// ...
			$total=$this->mHistorial->sumarTiemposHorasLaboralesM($info);
			// ...
		}
		// ...
		return $total;
	}

	public function cantidadUsoLectores()
	{
		$vLector=[];

		$info['documento']= $this->input->post('documento');
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	
		$info['evento']= 1;// 1= LectorI  2= LectorF
		// Lectores inicio de evento
		$lectores= $this->mHistorial->cantidadUsoLectoresM($info);
		// var_dump($lectores);
		// var_dump(isset($vLector["Lector"]));
		foreach ($lectores as $lector) {
			$vLector["Lector".$lector->lector]=$lector->cantidad;
		}

		$info['evento']= 2;// 1= LectorI  2= LectorF

		//Lectores fin de evento
		$lectores= $this->mHistorial->cantidadUsoLectoresM($info);
		// var_dump($lectores);
		foreach ($lectores as $lector) {
			if (count($vLector)==0) {
				$vLector["Lector".$lector->lector]=$lector->cantidad;
			}else{
				if(isset($vLector["Lector".$lector->lector])){//true existe el indice en el vector
					$vLector["Lector".$lector->lector]=($vLector["Lector".$lector->lector]+$lector->cantidad);
				}else{//No existe el indice en el vector
					$vLector["Lector".$lector->lector]=$lector->cantidad;
				}
			}
		}

		
		echo json_encode($vLector);
	}

	public function consultarCantidadDiasTrabajados()//Pendiente por desarrollar
	{
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');

		$cont= $this->mHistorial->consultarCantidadDiasTrabajadosM($info);

		echo $cont;
	}

	public function tiempoTotalEmpleadoPermiso()
	{
		$info['documento']= $this->input->post('documento');
		$info['fechaI']= $this->input->post('fechaI');	
		$info['fechaF']= $this->input->post('fechaF');	

		$result= $this->mHistorial->tiempoTotalEmpleadoPermisoM($info);

		$total=$this->sumarHorasLaborales($result);

		echo $total;
	}
}
 ?>