<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cMenu extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
	}
// Gestor humano
	public function index(){ //$this->load->view('login.php');
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
        switch ($dato['tipoUser']) {
          case 5://Gestor humano
            $this->load->view('Empleados/Contenido');
            break;
          case 6://Facilitador
            $this->load->view('Empleados/Facilitador/Contenido');
            break;
          case 7://Lider de producción
            $this->load->model('Empleado/FichaSDG/mConfiguracionFicha');
            $info2['manufacturas']=$this->mConfiguracionFicha->consultarInformacionM(2,9);
            $this->load->view('Empleados/Empleado',$info2);
            break;  
        }
        // if ($dato['tipoUser']==5) {
        //   //Gestor Humano
        //   $this->load->view('Empleados/Contenido');
        // }else{
        //   //Facilitador
        //   // $this->load->view('Empleados/Facilitador/Contenido');
        // }
        $this->load->view('Layout/Footer');
        $this->load->view('Layout/clausulas'); 
      }
    }
    // -.........
    public function cantidadEmpleados()
    {
      $this->load->model('Empleado/mEmpleado');
      $cantidad=$this->mEmpleado->cantidadEmpleadosM();
      echo $cantidad->cantidad;
    }

    public function cantidadIncapacidades()
    {
      $this->load->model('Empleado/mIncapacidades');
      $cantidad=$this->mIncapacidades->cantidadIncapacidadesM();
      echo $cantidad->cantidad;
    }

    public function cantidadFSDG()
    {
      $this->load->model('Empleado/mFichaSDG');
      $cantidad=$this->mFichaSDG->cantidadFSDGM();
      echo $cantidad->cantidad;
    }

    public function cantidadPermisos()
    {
      $this->load->model("Empleado/mPermiso");
      $cantidad=$this->mPermiso->cantidadPermisosM();
      // var_dump($cantidad);
      echo $cantidad->cantidad;
    }
}

 ?>