<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mEmpleado extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
// Se encarga de registrar o modificar los datos del empleado dependiendo de los parametros que reciba.
  // Al registrar los empleados por importacion de documento XLSX se va a tomar en cuenta
 public function registrar_Modificar_EmpleadoM($datos,$op)
 {	
    $query= $this->db->query("SELECT EXISTS(SELECT * FROM empleado e where e.documento='{$datos['documento']}') AS respuesta");

    $res= $query->row();

 	    // mysqli_next_result($this->db->conn_id);//Soluciona el problema con del DB_Driver de codeigneiter.
 	    // El false es para que no escape como un string el query
        // var_dump($datos['idEmpresa']);
        if ($res->respuesta==0) {
            //Registrar
              $datos = $this->organizarInfoEmpleado($datos);
              // Fecha de ingreso a la empresa
              $query= $this->db->query("SELECT CURDATE() as fechaA;");

              $res= $query->row();

              $datos['fecha_registro']= $res->fechaA;
                   // ...
              // El false es para que no escape como un string el query
              $this->db->insert('Empleado',$datos,false);//
              //
              if($this->db->insert_id()!=0){
                  $this->db->close();
                  return false;
              }else{
                  $ususarios=$this->db->query("SELECT u.idUsuario FROM usuario u WHERE (u.idTipo_usuario=5 OR u.idTipo_usuario=6) AND u.estado=1;");

                  foreach ($ususarios->result() as $ususario) {
                            $this->db->query("CALL PA_SE_GenerarNotificacionEmpleadoNuevo({$ususario->idUsuario});");   
                  }
                  // ...
                  $this->db->close();
                  return true;
              }
        }else{//
          //Modificar
            $datos = $this->organizarInfoEmpleado($datos);
            // ...
            // var_dump();
            $query=$this->db->query("CALL SE_PA_ModificarEmpleados('{$datos['documento']}', '{$datos['nombre1']}', '{$datos['nombre2']}', '{$datos['apellido1']}', '{$datos['apellido2']}', {$datos['genero']}, {$datos['huella1']}, {$datos['huella2']}, {$datos['huella3']}, '{$datos['correo']}', '{$datos['contraseña']}', {$datos['idEmpresa']}, {$datos['idRol']}, '{$datos['piso']}','{$datos['fecha_expedicion']}','{$datos['lugar_expedicion']}', {$datos['idManufactura']}, {$datos['estado']});");
            $r=$query->row();
            //      
            $this->db->close();

            return $r->respuesta;
        }

 }

public function organizarInfoEmpleado($datos=[])
{
  //Cambiar el nombre de la empresa por el identificador de la empresa
  if (!(is_numeric($datos['idEmpresa']))) {
      $query= $this->db->query("SELECT e.idEmpresa FROM empresa e WHERE e.nombre='{$datos['idEmpresa']}'");

      $res= $query->row();

      $datos['idEmpresa']=$res->idEmpresa;
  }
  //Cambiar el nombre del área de trabajo por el identificador del área
  if (!(is_numeric($datos['idManufactura'])) && ($datos['idManufactura']!=null)) {
      $query= $this->db->query("SELECT a.idArea_trabajo FROM area_trabajo a WHERE LOWER(a.area) = LOWER('{$datos['idManufactura']}')");

      $res= $query->row();

      $datos['idManufactura']=$res->idArea_trabajo;
  }
  //Si el campo es null cambiar por un 0
  if ($datos['idManufactura']==null) {
      $datos['idManufactura']=0;   
  }

  return $datos;
}

 // public function actualizaCM($info)
 // {
 //        $query=$this->db->query("CALL Actualizarcontras('{$info['documento']}', '{$info['contra']}');");

 //        $r=$query->row();
 //        //      
 //        $this->db->close();

 //        return $r->respuesta;  
 // }
// Se encarga de validar la existencia de la misma contraseña. La contraseña de los empleados no puede ser la mismo porque a su vez la contraseña va funcionar de identificador para el sistema de asistencia de los empleados.
public function validarExistenciaContraM($info)
{
    $query=$this->db->query("CALL SE_PA_ValidarExistenciaContraseña('{$info['contra']}','{$info['documento']}');");
    $res=$query->row();
    $this->db->close();
    return $res->respuesta;
}

// Valida el documento que no exista dentro de la base de datos
 public function validarDocumentoEmpleado($doc)
 {
 	# code...validacion de numero de documento del empleado
 	$query=$this->db->query("CALL SE_PA_validarDocumentoExistente('{$doc}');");
 	$res=$query->row();
 	$res=$res->respuesta;
    $this->db->close();
 	return $res;
 }
// Se encarga de validar que las huellas del operario no se repitan.
 public function validarHuellasEmpleado($huellas)
 {
 	# code... validacion de huellas del empleado
 	mysqli_next_result($this->db->conn_id);//Esta linea me soluciona el problema del store procedure de multiples parametros.
 	$query=$this->db->query("CALL SE_PA_validarHuellasExistentes({$huellas['huella1']}, {$huellas['huella2']}, {$huellas['huella3']});");//El Framework me genera un problema: "Commands out of sync; you can't run this command now"
 	$res=$query->row();
 	$res=$res->respuesta;
 	//var_dump($res);
 	return  $res;

 }
// Consulta el total de empleados en general que tiene la empresa acutualmente.
 public function consultarEmpleadosM($doc)
 {
    $query= $this->db->query("CALL SE_PA_ConsultarEmpelados('{$doc}');");
	
 	$r=$query->result();

    $this->db->close();

 	return $r;    
 }
// Cambia de estado de los empleados y ya no pueden volver a realizar nunguna actividad con los sistemas que interactuan
 public function eliminarEmpleadoM($doc)
 {
    $query= $this->db->query("CALL SE_PA_EliminarEmpleado('{$doc}');");

    $r=$query->row();

    return $r->respuesta;
 }
 //Funciona de la misma forma pero para otro procesimiento
 public function cambiarEstadoEmpleadoM($id,$estado)
 {
 	$query= $this->db->query("CALL SE_PA_CambiarEstadoEmpleado({$id}, {$estado});");

 	$r=$query->row();

    $this->db->close();

 	return $r->respuesta;
 }

 public function cambiarEmpresaEmpleadoM($idF,$idEm)
 {
    $query= $this->db->query("CALL SE_PA_CambiarEmpresaEmpleado({$idF}, {$idEm});");

    $r=$query->row();

    $this->db->close();

    return $r->respuesta;
    // return $idEm;
 }

// Consulta los roles disponibles para los empleados
public function consultarRolesM()
{
    $query=$this->db->query("CALL SE_PA_ConsultarRoles();");

    $r=$query->result();

 	return $r;
}
// Se encarga de consultar todos los empelados y saber quien tiene y no permiso
public function consultarEmpleadosPermisoM()
{
    $query=$this->db->query("CALL SE_PA_ConsultarEmpleadosPermiso();");

    $r=$query->result();

    return $r;
}
// Se encarga de traer la información que se va a mostrar en el reporte de los empleados. 
public function reporteEmpleadosM()
{
    $query=$this->db->query('CALL SE_PA_ReporteEmpelado();');

    $r=$query->result();

    return $r;
}

// Se encarga de consultar la cantidad total de los empleados que hacen parte del sistema de información
public function cantidadEmpleadosM()
{
    $this->db->select("COUNT(*) as cantidad");
    $this->db->from("empleado");

    return $this->db->get()->row();
}
}

 ?>