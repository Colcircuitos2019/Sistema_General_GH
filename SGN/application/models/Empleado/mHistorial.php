<?php 
/**
 * Tener en cuenta que el dia cruzado no se esta tomando en cuenta a la hora de sacar el historial de asistencia del empleado.
 */
class mHistorial extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
	// Consulta la diferente cantidad de estados de los eventos laboral, desayuno o almuerzo por cada empleado, un rango de fecha o una fecha en especifico...
	public function consultarCantidadEstadosEventosM($info)
	{
		$query=$this->db->query("CALL SE_PA_ConsultarCantidadEventos('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}',{$info['evento']})");

		$res= $query->row();

		$this->db->close();

		return $res;
	}
	// Consulta todo los estados de los eventos que tuvo un empleado dentro de un rango de fecha o una fecha en espeecifica...
	public function consultarEventosM($info)
	{
		$query=$this->db->query("CALL SE_PA_ConsultarEventosDA('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}',{$info['evento']})");

		$res= $query->result();

		$this->db->close();

		return $res;
	}
	// Se encarga de consultar todas las horas trabajadas normales o extras por  un empleado dentro de un rango de fecha o una fecha en esfecifica...
	public function totalHorasTrabajadasNormalesM($info)
	{
		$query=$this->db->query("CALL SE_PA_HorasTrabajadasNormalesOExtras('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}',{$info['evento']},{$info['estado']})");

		$res= $query->result();

		$this->db->close();

		return $res;
	}
	// Se encarga de consultar las horas extras aceptadas o rechazadas por cada empleado en un rango de fechas...
	public function consultarHorasExtrasAceptadasYRechazadasM($info)
	{
		$query=$this->db->query("CALL SE_PA_ConsultarHorasExtrasAceptasORechazadas('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}',{$info['accion']})");

		$res= $query->result();

		$this->db->close();

		return $res;
	}

	// Se encarga de consultar todos los tiempos de las asistencia de desayuno o almuerzo que un empleado tuvo dentro de un rango de fecha o una fecha en especifico...
	public function consultarTiemposEventosDesayunoOAlmuerzoM($info)
	{
		$query=$this->db->query("CALL SE_PA_ConsultarAsistenciasDesayunoOAlmuerzo('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}',{$info['evento']})");

		$res= $query->result();

		$this->db->close();

		return $res;
	}
	// Se encarga de sumar dos horas y retornarme el resultado de la funcion...
	public function sumarTiemposHorasLaboralesM($info)
	{
		$query=$this->db->query("SELECT SE_FU_SumarHorasTrabajo('{$info['horaT']}','{$info['horaS']}') AS total");

		$res= $query->row();

		$this->db->close();

		return $res->total;
	}
	// Esto no  se puede desarrollar, solo por el simeplre hecho de que no se puede saber con certeza que día es festivo y cual no, esto arrojaria un dato con valor erroneo.
	public function horariosPropuestosEmpresaM($info)#Esto queda pendiente por desarrollar
	{
		$query=$this->db->query("CALL SE_PA_TiempoEventosPropuestosEmpresa('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}',{$info['evento']})");

		$res= $query->result();

		$this->db->close();

		return $res;
	}
	// Se encarga de consultar los lectores que utilizo el empleado para marcar la asistencia (inicia o final de evento) y suscantidad de usos que tivo, por un rango de fechas.
	public function cantidadUsoLectoresM($info)
	{
		$query=$this->db->query("CALL SE_PA_CantidadUsoLector('{$info['documento']}',{$info['evento']},'{$info['fechaI']}','{$info['fechaF']}')");

		$res= $query->result();

		$this->db->close();

		return $res;
	}

	// Se encarga de consultar el tiempo que se tomo en total por los permisos
	public function tiempoTotalEmpleadoPermisoM($info)
	{
		$query=$this->db->query("CALL SE_PA_ConsultarTiempoPermisosEmpleadosConsumido('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}')");

		$res= $query->result();

		$this->db->close();

		return $res;
	}

	// Se encarga de contar los días que debio trabajar un empleado en un rango de fechas.
	public function consultarCantidadDiasTrabajadosM($info)
	{
		$query=$this->db->query("SELECT SE_FU_ContarDíasDeTrabajo('{$info['fechaI']}','{$info['fechaF']}') as dias");

		$res= $query->row();

		$this->db->close();

		return $res->dias;
	}



}
 ?>