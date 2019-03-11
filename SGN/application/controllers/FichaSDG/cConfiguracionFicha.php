<?php 
/**
 * 
 */
/*
Numero de accion de la vista CRUD
   Salario=1
   ClasificacionMega=2
   auxilio=3
   estadocivil=4
   EPS=5
   AFP=6
   Cargo laboral=7
   Horario Laboral=8
   Areas de Trabajo=9
   tipo de Contrato= 10	
   Grado de escolaridad= 11	
   Actividades en tiempo libre=12
   Municipio=13
*/
class cConfiguracionFicha extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/FichaSDG/mConfiguracionFicha');
	}
// Retorno de vistas configuracion de la ficha sociodemografica. 
	
	public function salario()//Vista de salario
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/salarios');
        $this->piepagina(); 
	}

	public function clasificacionMega()//Vista de clasificacion mega
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/clasificacionMega');
        $this->piepagina(); 
	}

	public function clasificacionContable()//Vista de clasificacion contable
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/clasificacionContable');
        $this->piepagina(); 
	}

	public function auxilio()//Vista de auxilio
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/auxilio');
        $this->piepagina(); 
	}

	public function estadoCivil()//Vista de estado civil
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/estadoCivil');
        $this->piepagina(); 
	}

	public function eps()//Vista de eps
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/eps');
        $this->piepagina(); 
	}	

	public function afp()//Vista de afp
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/afp');
        $this->piepagina(); 
	}

	public function cargo()//Vista de Cargos
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/cargo');
        $this->piepagina(); 
	}

	public function horarioLaboral()//Vista de horario laboral
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/horariolaboral');
        $this->piepagina(); 
	}

	public function areaLaboral()//Vista de Area Laboral
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/areasTrabajo');
        $this->piepagina(); 
	}

	public function tipoContrato()//Vista de Tipo de contratos
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/tipoContrato');
        $this->piepagina(); 
	}

	public function gradoEscolaridad()//Vista de Grado de escolaridad
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/gradoEscolaridad');
        $this->piepagina();
	}

	public function actividades()//Vista de Actividades en el tiempo libre
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/ATiempoLibre');
        $this->piepagina(); 
	}

	public function municipios()//Vista de Actividades en el tiempo libre
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/municipios');
        $this->piepagina(); 
	}

	public function diagnostico()
	{
		$this->encabezado();
        $this->load->view('Empleados/FichaSDG/Configuracion/Diagnostico');
        $this->piepagina(); 
	}

	public function encabezado()
	{
		$dato['titulo']="Empleados";
		$dato['path']="Empleado/cMenu";
		$dato['tipoUser']=$this->session->userdata('tipo_usuario');
		$dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		//... 
		$this->load->view('Layout/Header1',$dato);
		$this->load->view('Layout/MenuLateral');
	}

	public function piepagina()
	{
		$this->load->view('Layout/Footer');
		$this->load->view('Layout/clausulas'); 
	}

//Funciones de las vistas de configuracion de la ficha SDG
   
    //Es una funcion general que va a servir para muchos CRUD de la configuracion de la ficha SDG
    public function registrarModificarEstadoCRUD()
    {
    	$info['idE']=$this->input->post('idEm');
		$info['nombre']=$this->input->post('nombre');
		$info['estado']=$this->input->post('estadoE');
		$info['info']=$this->input->post('info');
		// var_dump($info);

		$res=$this->mConfiguracionFicha->registrarModificarCRUDM($info);

		echo json_decode($res);
    }
    //Consulta la informacion de diferentes CRUD
    public function consultarInformacion()
    { 	
        $op=$this->input->post('op');//si va a buscar por un campo en especifico o es una consulta general
        $info=$this->input->post('info');//Para saber que informacion de que tabla se va a consultar.

		$res=$this->mConfiguracionFicha->consultarInformacionM($op,$info);

		echo json_encode($res);
    }    
}
?>