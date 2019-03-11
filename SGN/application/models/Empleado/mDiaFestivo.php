<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class mDiaFestivo extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
		// $this->load->model('Empleado/mDiaFestivo');
	}
	// Retorno de views 
	 public function index(){
	 	if ($this->session->userdata('tipo_usuario')==false) {
	 	  redirect('cLogin');
	 	}else{
			    $info['tipoUser']= number_format($this->session->userdata('tipo_usuario'));
	       //... 
	       $this->load->view('Layout/Header1',$info);
	       $this->load->view('Empleados/MenuEmpleados');
	       $this->load->view('Empleados/calendario');
	       $this->load->view('Layout/Footer'); 
	 	}
	 }

	// Metodos
	public function registrarModificarDiaFestivoM($info)
	 {
	 	$query= $this->db->query("CALL SE_PA_RegistrarModificarDiaFestivo({$info['idD']}, '{$info['nombre']}', '{$info['fecha']}');");

	 	$res= $query->row();

	 	return $res->respuesta;
	 }

	public function consultarDiasFestivosM($idD)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarDiasFestivos({$idD});");

		$res= $query->result();

		return $res;
	}

	public function cambiarEstadoDiaFestivoM($id)
	{
		$query= $this->db->query("CALL SE_PA_CambiarEstadoDiaFestivo({$id});");

		$res= $query->row();

		return $res->respuesta;
	}

	public function validarFechaFestivaM($fecha)// Formato DD-MM-YYYY
	{
		$query= $this->db->query("SELECT EXISTS(SELECT * FROM dias_festivos d WHERE d.fecha_dia='{$fecha}') AS respuesta");

		$res= $query->row();

		return $res->respuesta;
	}
} ?>