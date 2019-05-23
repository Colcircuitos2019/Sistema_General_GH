<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* SE
*/
class mAsistencia extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
	//Metodos
	//Consulta todas las asistencias de algun empleado
	public function asistenciaPorEmpleadoM($doc, $op, $fecha, $idAsistencia)
	{
		$query=$this->db->query("CALL SE_PA_AsistenciaPorEmpleado('{$doc}', {$op}, '{$fecha}', {$idAsistencia});");
		
		$r=$query->result();

		return $r;
	}
	//Consultar El estado de los empleados, si es que esta presente o ausente de la empresa
	public function asistenciasDiariasM($piso)
	{
		$query=$this->db->query("CALL SE_PA_AsistenciasDiarias({$piso});");

		$r=$query->result();

		return $r;		
	} 

    //Se encarga de gestionar la asistencia que va a tener tiempo extra...
    public function gestionTiempoExtraAsistenciaM($idAsistencia)
    {
        $query=$this->db->query("CALL SI_PA_GestionDeTiempoExtraAsistencias({$idAsistencia});");

        $r=$query->row();

        return $r->respuesta;      
    }

// Se encarga de consultar las asistencias por fecha
    public function asistenciasPorFechasM($info)
    {
    	$query=$this->db->query("CALL SE_PA_AsistenciaPorFechas('{$info['Fecha1']}', '{$info['Fecha2']}','{$info['doc']}');");
		$r=$query->result();

		return $r;	
    }
// Se encarga de consultar la hora del servidor en formato HH:II:SS R
    public function horaServidorM()
    {
        $query= $this->db->query("SELECT TIME_FORMAT(now(),'%r') as hora");
        $hora=$query->row();

        return $hora->hora;
    }

// se encarga de consultar la diferencia entre la hora de inicio y fin de los eventos.
  //   public function consultarHorasEmpleadoFechaM($info)
  //   {
  //   	$query=$this->db->query("CALL SI_PA_TotalHorasTrabajasEmpleado('{$info['documento']}', '{$info['fecha']}');");

		// $r=$query->result();

		// return $r;	
  //   }

    public function consultarAsistenciaEventoDiaM($event)
    {
        $query= $this->db->query("CALL SI_PA_ConsultarAsistenciaeventosDia({$event});");

        $r=$query->result();

        return $r;
    }

    //...
    public function consultarPermisoEquipo($ip)
    {
        $query= $this->db->query("SELECT SE_FU_LectorPisoAsistencia('{$ip}') as respuesta;");

        $r=$query->row();

        return $r->respuesta;
    }
    // Se encarga de registrar la asistencia de los empleados mediente la contraseña
    // En la variable lector por el momento se va almacenar la ip del dispositivo de donde se accedio al sistema de información
    public function registrarAsistenciaM($info)
    {

        $query=$this->db->query("CALL SI_PA_RegistrarAsistenciaContraseña('{$info['contra']}',SE_FU_LectorPisoAsistencia('{$info['lector']}'),{$info['idHorario']});");

		$r=$query->row();

		return $r;  	
    }
    // Se encarga de modificar la informacion de las asistencias de los empleados
    public function modificarAsistenciaEmpleadoManualM($info)
    {
        $query=$this->db->query("SELECT SE_FU_ModificarAsistencaEmpleado({$info['idAsistencia']},'{$info['HoraInicio']}','{$info['HoraFin']}',{$info['Evento']}) as respuesta;");

        $r=$query->row();

        $this->db->close();

        return $r->respuesta;         
    }
    // Se encarga de actualizar las horas normales trabajadas o horas extras trabajadas en las asistencias.
    public function actualizarTiempoTotalLaboradoDiaM($info)
    {
        // $info['idHorario'], 2, $info['fechaInicio'], $info['fechaFin'], $info['idAsistencia']}
        $query=$this->db->query("CALL SI_PA_CalcularRegistrarHorasTrabajadas({$info['idHorario']}, 2, '{$info['fechaInicio']}', '{$info['fechaFin']}', {$info['idAsistencia']});"); // ID Horario, accion, fechaInicio, FechaFin, idAsistencia.

        $r=$query->row();

        $this->db->close();

        return 1; 
    }

    public function consultarTipoAsistenciaM($doc)
    {
        $query=$this->db->query("CALL SI_PA_ConsultarTipoAlerta('{$doc}');");

		$r=$query->result();

		return $r;   	
    }

    // Consulta las horas trabajadas por empleado y dia.
    public function consultarHorasTrabajadasDiaM($idAsistencia)
    {
    	$query=$this->db->query("CALL SI_PA_ConsultarHorasDeTrabajo({$idAsistencia});");

		$r=$query->result();

		return $r;	
    }

    public function consultarEmpleadosConHorasExtrasAprobarM()
    {
    	$query=$this->db->query("CALL SI_PA_ConsultarHorasExtrasAprobar();");

		$r=$query->result();

		return $r;	
    }

    public function aceptarHorasExtrarEmpleadoM($info)
    {
        $query=$this->db->query("CALL SI_PA_ActualizarEstadoHorasExtras('{$info['documento']}', '{$info['fecha']}', '{$info['descripcion']}', {$info['index']}, '{$info['horasA']}', '{$info['horasR']}');");

		$r=$query->row();

		return $r->respuesta;		
    }

    // Se encarga de cerrar la asistencia de los empleados de forma manual
    public function CerrarAsistenciaM($doc,$idH)
    {
    	$query=$this->db->query("SELECT SI_FU_CerrarAsistenciaEmpleado('{$doc}', {$idH}) as respuesta;");

		$r=$query->row();

		return $r->respuesta;
    }

    public function diferenciaDeHorasM($tiempo,$hora)
    {
        $query=$this->db->query("SELECT TIMEDIFF('{$tiempo}', '{$hora}') as respuesta;");

        $r=$query->row();

        return $r->respuesta;
    }

    public function consultarDocumentoEmpleadosM()
    {
        $query=$this->db->query("SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2,em.nombre AS empresa FROM empleado e JOIN empresa em ON e.idEmpresa=em.idEmpresa WHERE e.idRol=1 AND e.estado=1;");
        
        $r=$query->result();

        $this->db->close();

        return $r;  
    }

    /*
    Errores comunes en los programadores junior
     1- Código Limpio
     2- Comentario utiles
     3- Aceptar fallar
     4- Terminal o Linea de comandos
     5- Git - Control de versiones (Aprender más git)
     6- Crear proyectos personales desafiantes
     7- Terminarlos (Los proyectos)
     8- Entiende el por qué.
     9- Enamorarte de un lenguaje.
     10- Enamorarte de pensar* como programador 
    */
    // public function consultarEmpleadosPiso($piso)
    // {
    // 	# code...
    // }
    // if (tiempo.length==3) {//Validar que tenga las horas los minutos y los segundos
    //     for (var i = 0; i < tiempo.length; i++) {//Validar que cada unidad de tiempo venga en pares
    //        if (item.length==2) {
    //            if (Number(item)>=0) {// Validar que el numero ingresado no sea un numero negativo
    //                // Validar que ninguno unidad se pase de más de 59
    //                if (!(Number(item)<=59)) {
    //                    return true;
    //                }
    //                // 
    //                if (index==3) {
    //                    return false;
    //                }
    //            }else{
    //                return true;
    //            }
    //        }else{
    //            return true;
    //        }  
    //      } 
    // }else{
    //     return true;
    // }
// 
}


 ?>