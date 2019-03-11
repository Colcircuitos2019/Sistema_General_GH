<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mPermiso extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
        $this->load->database();
	}
// Metodos
    public function validarUsuarioM($info)
    {   
        // Valida la existencia del usuario.
        $query= $this->db->query("CALL SA_PA_ValidarUsuario('{$info['documento']}', '{$info['password']}');");

        $result= $query->row();
        //Si retorna  un 1 es porque la persona si ingreso los datos correctos y si retorna un 0 es porque la persona no ingreso los datos correctos o no existe.
        return $result->respuesta;
    }

    public function registrarModificarPermisosEmpeladoM($info)
    {
        $query= $this->db->query("CALL SE_PA_RegistrarModificarPermisoEmpleado({$info['idPermiso']},'{$info['documento']}','{$info['fechaP']}',{$info['concepto']},{$info['momento']},'{$info['horaDesde']}','{$info['des']}');");

        $r=$query->row();

        return $r->respuesta;
    }

    //Se encarga de consultar los permisos de los empleado a los facilitadores o a los mismos empleados. 
    public function consultarPermisoEmpeladoM($doc){

        $query= $this->db->query("CALL SE_PA_ConsultarPermisosEmpleado('{$doc}');");

        $r=$query->result();

        return $r;
    }

    public function consultarPermisoEmpleadoEditarM($id){

        $query= $this->db->query("CALL SE_PA_ConsultarPermisoEmpleadoEditar({$id});");

        $r=$query->result();

        return $r;
    }

    // Se encarga de cambiar el estado(Pendeiten, Aceptado, Rechazado y Terminado) del permiso del empleado.
    public function cambiarEstadoPermisoEmpleadoM($info)
    {
        $query= $this->db->query("SELECT SE_FU_CambiarEstadoPermisoEmpleado({$info['permiso']},{$info['estado']}, {$info['usuario']}) as respuesta;");

        $r=$query->row();

        return $r->respuesta;
    }

    // Se encarga de consultar los permisos de los empleados por un rango de fechas o una fecha en especifico.
    public function consultarPermisoEmpleadoRangoFechasM($info)
    {
        $query= $this->db->query("CALL SE_PA_ConsultarPermisosPorRangoFechas('{$info['fechaI']}','{$info['fechaF']}','{$info['doc']}');");

        $r=$query->result();

        return $r;
    }
    
//Se encarga de validar que la hora del permiso si sea la adecuada para el tipo de permiso. 
    public function ValidarHorasDelPermisoM($cod,$hora,$idH)
    {
       $query= $this->db->query("CALL SE_PA_ValidarHoraCodigoPermisoEmpleado('{$cod}', '{$hora}',{$idH});");

      $r=$query->row();

      return $r->respuesta;       
    }
// Se encarga de consultar los permisos por empleado. por el documento y el codigo del permiso o por una fecha en especifico del permiso
    public function consultarPermisoEmpleadoM($doc,$cod,$fecha)
    {
      $query= $this->db->query("CALL SE_PA_ConsultarPermisoEmpleado('{$doc}', '{$cod}', '{$fecha}');");

      $r=$query->result();

      return $r;    
    }
    // Se encarga de consultar la cantidad total de los permisos que hacen parte del sistema de información.
    public function cantidadPermisosM()
    {
        $this->db->select("COUNT(*) as cantidad");
        $this->db->from("permiso");

        return $this->db->get()->row();
    }
    // Se encarga de validar que la fecha ingresada para el permiso no sea menos a la fecha del sistema actualemente.
    public function validarFechaPermisoM($fecha)
    {
       $query= $this->db->query("SELECT IF(('{$fecha}'>=CURDATE()),1,0) AS respuesta;");

        $r=$query->row();

        return $r->respuesta; 
    }

    public function validarExistenciaPermisoFechaM($info)
    {
        $query= $this->db->query("SELECT EXISTS(SELECT * FROM permiso p WHERE p.fecha_permiso='{$info['fecha']}' AND  p.documento='{$info['documento']}') AS respuesta");

        $r=$query->row();

        return $r->respuesta; 
    }

    public function consultarFechaHoyM()
    {
        $query= $this->db->query("SELECT CURDATE() as fecha;");

        $r=$query->row();

        $this->db->close();

         return $r->fecha;
    }
  
}
    // Se encarga de validar que no exista otro codigo de permiso.
    // public function validarCodigoM($cod)
    // {
    //     $query= $this->db->query("CALL SE_PA_VAlidarCodigoPermisoEmpleado('{$cod}');");

    //     $r=$query->row();

    //     return $r->respuesta;
    // }
    // Se encarga de validar el codigo y traer el documento de la eprsona que realizo ese permiso.
    // public function validarCodigoPermisoM($cod,$doc)
    // {
    //     $query= $this->db->query("CALL SE_PA_ValidarCodigoP('{$cod}', '{$doc}');");

    //     $r=$query->row();

    //     return $r->respuesta;
    // }
    // Se encarga de registrar el codigo para que el empleado pueda realizar el permiso o compensatorio
    // public function registrarCodigoPermisoM($info)
    // {
    //     $query= $this->db->query("CALL SE_PA_RegistrarCodigoEmpleadoPermiso('{$info['codigo']}', '{$info['documento']}', {$info['momento']}, '{$info['usuario']}');");

    //     $r=$query->row();

    //     return $r->respuesta;
    // }
    //0= Se encargara de eliminar el codigo del permiso por ende tambien va eliminar el permiso del empleado (eliminar las dos cosas, el codigo y el permiso solo lo puede hacer el facilitador).
    // 1= se encarga de eliminar el permiso del empleado, esto solo lo puede realizar el empleado.
    // public function eliminarCodigoPermisoM($cod,$accion)
    // {
    //     $query=$this->db->query("CALL SE_PA_EliminarCodigoPermiso({$accion},'{$cod}');");

    //     $r=$query->row();

    //     return $r->respuesta;
    // }
    // Se encargara de consultar todos los codigos de los permisos que estan vigentes.
    // public function consultarCodigosPermisosM()
    // {
    //     $query=$this->db->query("CALL SE_PA_ConsultarEmpleadosCodigo();");

    //     return $query->result();
    // }
    // Se encarga de consultar los codigos de permisos por rango de fechas
    // public function consultarCodigosPermisosFechasM($fechas)
    // {
        
    //     $query=$this->db->query("CALL SE_PA_ConsultarCodigosPermisoFechas('{$fechas['fecha1']}', '{$fechas['fecha2']}');");

    //     return $query->result();
    // }
    // Se encarga de gestionar lo permisos que realizan los empleados
    // public function registrarModificarPermisoM($info)//Se puede modificar para el nuevo modulo de permisos
    // {
    //   //  mysqli_next_result($this->db->conn_id);  

    //   $query=$this->db->query("CALL SE_PA_RegistrarModificarPermiso('{$info['documento']}', '{$info['cod']}', '{$info['fechaP']}', {$info['concepto']}, '{$info['desde']}', '{$info['des']}', {$info['accion']});");

    //   $r= $query->row();

    //   return $r->respuesta;
    // // return $info;
    // }
// Se encarga de validar la existencia de algun permiso generado con ese código.
    // public function validarExistenciaPermisoCodigoM($cod)
    // {
    //   $query=$this->db->query("CALL SE_PA_ValidarExistenciaPermisoCodigo('{$cod}');");

    //   $r= $query->row();

    //   return $r->respuesta;
    // }
//Se encarga de validar si el empleado ya registro un permiso con ese codigo. 
    // public function validarExistenciaPermisoEmpleadoM($cod)
    // {
    //   $query= $this->db->query("CALL SE_PA_ValidarExistenciaPermisoEmpelado('{$cod}');");

    //   $r=$query->row();

    //   return $r->respuesta;
    // }
// Se encarga de validar que codigo del permiso no tenga más de una semana de haberlo generado.
    // public function validarTiempoCodigoPermisoM($cod)
    // {
    //   $query= $this->db->query("CALL SE_PA_ValidarTiempoCreacionCodigo('{$cod}');");

    //   $r=$query->row();

    //   return $r->respuesta;         
    // }
// Se encarga de eliminar el permiso de un empelado por el codigo y id del permiso.
    // public function eliminarPermisoEmpleadoM($cod,$idP)
    // {
    //   $query= $this->db->query("CALL SE_PA_EliminarPermisoEmpleado('{$cod}', {$idP});");

    //   $r=$query->row();

    //   return $r->respuesta;   
    // }
// Se encarga de consultar los permiso de un empleado por un rango de fechas o por una fecha.
    // public function consultarPermisosRangoDeFechasM($info)
    // {
    //  $query= $this->db->query("CALL SE_PA_ConsultarPermisosEmpleadoRangoFechas('{$info['documento']}', '{$info['fecha1']}', '{$info['fecha2']}');");

    //  $r=$query->result();

    //  return $r; 
    // } 
 ?>

