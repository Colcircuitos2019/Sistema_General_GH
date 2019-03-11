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
class mConfiguracionFicha extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

 	 	//Se encarga de registrar, modificar la informacion de X tabla dependiendo de la variable info.
 	 	public function registrarModificarCRUDM($info)
 	 	{
 	 		// Que tabla va a resultar alterada... 
 	 		switch($info['info']){
 	 			  case 1:
 	 				// Se encarga de registrar o modificar los salarios que van hacer parte del sistema de información
 	 			    $query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoSalario({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
          case 2:
 	 				// Se encarga de registrar o modificar las Clasificaciones Megas que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoClasificacionMega({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				     break;
          case 3:
 	 				// Se encarga de registrar o modificar los auxilios que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoAuxilio({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
          case 4:
 	 				// Se encarga de registrar o modificar los estado civiles que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoEstadoCivil({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
          case 5:
 	 				// Se encarga de registrar o modificar las EPS que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoEPS({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 6:
 	 				// Se encarga de registrar o modificar las AFP que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoAFP({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 7:
 	 				// Se encarga de registrar o modificar los Cargos que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoCargo({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 8:
 	 				// Se encarga de registrar o modificar los Horario de trabajo que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoHorariotrabajo({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 9:
 	 				// Se encarga de registrar o modificar los Áreas de trabajo que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoAreasTrabajo({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 10:
 	 				// Se encarga de registrar o modificar los Tipo de contrato que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoTipoContrato({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				     break;
 	 			  case 11:
 	 				// Se encarga de registrar o modificar los Tipo de contrato que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoGradoEscolaridad({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 12:
 	 				// Se encarga de registrar o modificar las actividades en el tiempo que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoActividadTiempoLibre({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
 	 			  case 13:
 	 				// Se encarga de registrar o modificar los Municipios que van hacer parte del sistema de información
                	$query=$this->db->query("CALL SE_PA_RegistrarModificarEstadoMunicipio({$info['idE']},'{$info['nombre']}',{$info['estado']});");
 	 				      break;
          case 14:
          // Se encarga de registrar o modificar los motivos de renuncia que van hacer parte del sistema de información--pendinte
                    $query=$this->db->query("CALL ({$info['idE']},'{$info['nombre']}',{$info['estado']});");
                  break;
                break;
          case 15:
          // Se encarga de registrar o modificar las clasificaciones contables que van hacer parte del sistema de información
                  $query=$this->db->query("CALL SE_PA_RegistrarModificarClasificacionContable({$info['idE']},'{$info['nombre']}',{$info['estado']});");
                break;                
 	 		}

 	 	  $res=$query->row();

 	 	  return $res->respuesta;
 	 	}
 	 	// Se encarga de consultar la informacion de X tabla, dependiendo de la variable info..
 	 	public function consultarInformacionM($op,$info)
 	 	{	
 	 		// Que tabla va a resultar alterada... 
 	 		switch($info){
 	 			case 1:
 	 			    // Se encarga de registrar o modificar los salarios que van hacer parte del sistema de información 
 	 				$query=$this->db->query("CALL SE_PA_ConsultarSalarios({$op});");
 	 				break;
                case 2:
                    // Se encarga de consultar las Clasificaciones Megas que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
 	 				$query=$this->db->query("CALL SE_PA_ConsultarClasificacionMega({$op});");
 	 				break;
                case 3:
                	// Se encarga de consultar los auxilios que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
 	 				$query=$this->db->query("CALL SE_PA_ConsultarTipoAxulio({$op});");
 	 				break;
                case 4:
                	// Se encarga de consultar los estado civiles que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
 	 				$query=$this->db->query("CALL SE_PA_ConsultarEstadoCivil({$op});");
 	 				break;
                case 5:
 	 				// Se encarga de consultar las EPS que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarEPS({$op});");
 	 				break;
 	 			case 6:
 	 				// Se encarga de consultar las AFP que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarAFP({$op});");
 	 				break;
 	 			case 7:
 	 				// Se encarga de consultar los Cargos que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarCargo({$op});");
 	 				break;
 	 			case 8:
 	 				// Se encarga de consultar los Horario de trabajo que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarHorarioLaboral({$op});");
 	 				break;
  	 			case 9:
 	 				// Se encarga de consultar las Áreas de trabajo que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarAreasLaborales({$op});");
 	 				break;
 	 			case 10:
 	 				// Se encarga de consultar los Tipo de contrato que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarTipoContrato({$op});");
 	 				break;
 	 			case 11:
 	 				// Se encarga de consultar los Grados de escolaridad que estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarGradoEscolaridad({$op});");
 	 				break;
 	 			case 12:
 	 				// Se encarga de consultar las actividades en el tiempo libre estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarActividadesTiempoLibre({$op});");
 	 				break;
 	 			case 13:
 	 				// Se encarga de consultar los Municipio estan almacenedas en el sistema de informacion sin importar el estado que tengan.
                	$query=$this->db->query("CALL SE_PA_ConsultarMunicipios({$op});");
 	 				break;
        case 14:
          // Se encarga de consultar todos los motivos de renuncia que tiene la empresa
                $query=$this->db->query("CALL SE_PA_ConsultarMotivos({$op});");
          break;
        case 15: 
          // Se encarga de consultar todos las clasificaciones contables realizadas en el sistema.
                $query=$this->db->query("CALL SE_PA_ConsultarClasificacionContable({$op});");
            break; 
 	 		}

 	 		$res=$query->result();

      $this->db->close();

 	 		return $res;
 	 	}	  	  
}

 ?>