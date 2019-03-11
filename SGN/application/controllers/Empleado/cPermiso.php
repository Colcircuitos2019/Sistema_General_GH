<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cPermiso extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mPermiso');

	}
// Retorno de vistas
    // Vista de registro de los permisos. (La ven los empleados)
    public function index()
    { 
		    $this->load->view('Empleados/Permisos');  
    }   
    // Vista de generacion de permisos para poder registrar los permisos (La ven los facilitadores)
    public function index1()
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
        $this->load->view('Empleados/Facilitador/Permisos');
        $this->load->view('Layout/Footer');
        $this->load->view('Layout/clausulas'); 
      } 
    }
    // Vista de vizualizacion de todos los ususario gestores humanos
    public function permisos()
    {
      if ($this->session->userdata('tipo_usuario')==false) {
        redirect('cLogin');
      }else{
        $dato['titulo']="Empleados";
        $dato['path']="Empleado/cMenu";
        $dato['tipoUser']=$this->session->userdata('tipo_usuario');
        $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');;
        //... 
        $this->load->view('Layout/Header1',$dato);
        $this->load->view('Layout/MenuLateral');
        $this->load->view('Empleados/Facilitador/Permisos');
        $this->load->view('Layout/Footer');
        $this->load->view('Layout/clausulas'); 
      } 
    }
// Metodos

    public function validarUsuario()
    { 
      //Validar que el usuario y la contraseña coniciden
    $info['documento']=$this->input->post('documento');
    $info['password']=base64_encode($this->input->post('password'));
    // $idP=$this->input->post('cod');

    $res = $this->mPermiso->validarUsuarioM($info);

    echo $res;
    }

    public function registrarPermisosEmpleado()
    {
      $info['documento'] =$this->input->post('documento');
      $info['fechaP'] =$this->input->post('fechaPermiso');
      $info['concepto'] =$this->input->post('concepto');
      $info['momento'] =$this->input->post('momento');
      $info['horaDesde'] =$this->input->post('horaDesde');
      $info['des'] =$this->input->post('des');
      $info['idPermiso'] =$this->input->post('idP');

      $res=$this->mPermiso->registrarModificarPermisosEmpeladoM($info);

      echo $res;

    }

    public function consultarPermisoEmpelado()
    {
      $doc=$this->input->post('documento');

      $result= $this->mPermiso->consultarPermisoEmpeladoM($doc);

      echo json_encode($result);
    }

    public function consultarPermisoEmpleadoEditar()
    {
       $id=$this->input->post('idP');

       $result= $this->mPermiso->consultarPermisoEmpleadoEditarM($id);

       echo json_encode($result);
    }

    public function cambiarEstadoPermisoEmpleado()
    {
      $info['permiso']=$this->input->post('idP');
      $info['estado']=$this->input->post('estado');
      $info['usuario']=$this->session->userdata('idUser');

      $res= $this->mPermiso->cambiarEstadoPermisoEmpleadoM($info);

      echo $res;
    }

    public function consultarPermisoEmpleadoRangoFechas()
    {
      $info['fechaI']=$this->input->post('fechaI');
      $info['fechaF']=$this->input->post('fechaF');
      $info['doc']=$this->input->post('documento');

      $res= $this->mPermiso->consultarPermisoEmpleadoRangoFechasM($info);

      echo json_encode($res);
    }

    public function registrarModificarPermiso()
    {
      $info['documento']=$this->input->post('documento');
      $info['cod']=$this->input->post('cod');
      $info['fechaP']=$this->input->post('fechaP');
      $info['concepto']=$this->input->post('concepto');
      $info['desde']=$this->input->post('desde');
      $info['des']=$this->input->post('des');
      $info['accion']=$this->input->post('acc');

      $res= $this->mPermiso->registrarModificarPermisoM($info);

      echo json_encode($res);
    }

    public function validarFechaPermiso()
    {
      $fecha= $this->input->post('fecha');

      $res=$this->mPermiso->validarFechaPermisoM($fecha);

      echo $res;
    }

    public function ValidarHorasDelPermiso()
    {
      $cod=$this->input->post('cod');
      $hora=$this->input->post('hora');
      $idH=$this->input->post('horario');

      $res=$this->mPermiso->ValidarHorasDelPermisoM($cod,$hora,$idH);

      echo $res;
    }

    public function consultarPermisoEmpleado()
    {
      $doc=$this->input->post('documento');
      $cod=$this->input->post('codigo');
      $fecha=$this->input->post('fecha');
      // Se encarga de consultar la fecha de hoy por si es que no se le asigno ningun valor a esta variable
      if ($fecha=='') {
        $fecha= $this->consultarFechaHoy();
        // var_dump($fecha);
      }elseif ($fecha=='-1') {
        $fecha='';      
      }

      $res=$this->mPermiso->consultarPermisoEmpleadoM($doc,$cod,$fecha);

      echo json_encode($res);      
    }

    public function validarHorarioEmpledoPermiso()
    {
      // ....
    }

    public function validarExistenciaPermisoFecha()
    {
      $info['documento']=$this->input->post('doc');
      $info['fecha']=$this->input->post('fecha');

      $res= $this->mPermiso->validarExistenciaPermisoFechaM($info);

      echo $res;
    }

    public function consultarFechaHoy()
    {
      $res=$this->mPermiso->consultarFechaHoyM();

      return $res;
    }
}

 // public function validarCodigo()
 // {
 //     $codigo=$this->input->post('code');

 //     $res=$this->mPermiso->validarCodigoM($codigo);

 //     echo json_encode($res);
 // }

 // public function validarCodigoPermiso()
 // {
 //     $codigo=$this->input->post('cod');
 //     $doc=$this->input->post('documento');

 //     $res=$this->mPermiso->validarCodigoPermisoM($codigo, $doc);

 //     echo json_encode($res);
 // }

 // public function registrarCodigoPermiso()
 // {
 //     $info['codigo']=$this->input->post('code');
 //     $info['documento']=$this->input->post('doc');
 //     $info['momento']=$this->input->post('mom');
 //     $info['usuario']=$this->input->post('user');

 //     $res=$this->mPermiso->registrarCodigoPermisoM($info);

 //     echo  json_encode($res);
 // }

/* public function eliminarCodigoPermiso()
 {
   // Codigo del permiso
   $cod=$this->input->post('cod');
   // Accion a realizar
   $accion=$this->input->post('accion');

   $res=$this->mPermiso->eliminarCodigoPermisoM($cod,$accion);

   echo  $res;
 }*/

 // public function consultarCodigosPermisos()
 // {
 //    $res=$this->mPermiso->consultarCodigosPermisosM();

 //    echo  json_encode($res);
 // }

 // public function consultarPermisosRangoDeFechas()
 // {

 //   $info['documento']=$this->input->post('documento');
 //   $info['fecha1']=$this->input->post('fechaI');
 //   $info['fecha2']=$this->input->post('fechaF');

 //   $result=$this->mPermiso->consultarPermisosRangoDeFechasM($info);

 //   echo  json_encode($result);
 // }

 // public function consultarCodigosPermisosFechas()
 // {
 //     $fechas['fecha1']=$this->input->post('fecha1');
 //     $fechas['fecha2']=$this->input->post('fecha2');

 //    $res=$this->mPermiso->consultarCodigosPermisosFechasM($fechas);

 //    echo  json_encode($res);
 // }
 // public function validarExistenciaPermisoEmpleado()
 // {
 //   $cod= $this->input->post('codigo');

 //   $res=$this->mPermiso->validarExistenciaPermisoEmpleadoM($cod);

 //   echo $res;
 // }
 // public function eliminarPermisoEmpleado()
 // {
 //   $cod=$this->input->post('codigo');
 //   $idP=$this->input->post('permiso');

 //   $res=$this->mPermiso->eliminarPermisoEmpleadoM($cod,$idP);

 //   echo $res;
 // }
 // public function validarTiempoCodigoPermiso()
 // {
 //   $cod=$this->input->post('cod');

 //   $res=$this->mPermiso->validarTiempoCodigoPermisoM($cod);

 //   echo $res;
 // }
 ?>