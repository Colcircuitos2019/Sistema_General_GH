<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mConfiguracion extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
//Metodos
	// Se encarga de consultar solo una configuracion de horarios de eventos
	public function consultarConfiguracionM($id)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarConfiguracion({$id});");

		return $query->result();
	}
	// Se encarga de validar que la hora numero 1 no sea mayor que la hora numero 2 
	public function validarHorasM($horas)
	{
		$query=$this->db->query("CALL SE_PA_ValidarHorasConfiguracion('{$horas['hora1']}', '{$horas['hora2']}')");

		$res=$query->row();

		return $res->respuesta;
	}

	public function registrarActualizarConfiguracionM($horas)
	{
		$query=$this->db->query("CALL SE_PA_ActualizarConfiguracion('{$horas['HIL']}', '{$horas['HFL']}', '{$horas['HID']}', '{$horas['HFD']}', '{$horas['HIA']}', '{$horas['HFA']}', '{$horas['TD']}', '{$horas['TA']}', {$horas['ID']}, '{$horas['nombre']}', {$horas['tipo_horario']});");
		$res=$query->row();

		return $res->respuesta;
	}

	public function cambiarEstadoHorarioConfiguracionM($id)
	{
		$query=$this->db->query("CALL SE_PA_CambiarEstadoConfiguracionHorarioEmpleado({$id});");
		
		$res=$query->row();

		return $res->respuesta;
	}

	public function consultarTiemposTeoricosM()
	{
		$query= $this->db->query("SELECT t.tiempo_laboral, t.tiempo_desayuno, t.tiempo_almuerzo FROM tiempo_teorico_semanal t WHERE t.idtiempo_teorico_semanal = 1;");

		$res = $query->row();

		return $res;
	}

	public function consultarHoraSalidaTiempoExtraM()
	{
		$query= $this->db->query("SELECT t.hora FROM hora_salida_tiempo_extra t WHERE t.idhora_salida_tiempo_extra=1;");

		$res = $query->row();

		return $res->hora;
	}

	public function actualizarTiemposteoricosM($tiempos)
	{
		$query= $this->db->query("UPDATE tiempo_teorico_semanal t SET t.tiempo_laboral = '{$tiempos['laboral']}', t.tiempo_desayuno = '{$tiempos['desayuno']}', t.tiempo_almuerzo = '{$tiempos['almuerzo']}'  WHERE t.idtiempo_teorico_semanal = 1;");

		return 1;	
	}

	public function gestionarHoraSalidaTiempoExtraM($hora)
	{
		$query= $this->db->query("UPDATE hora_salida_tiempo_extra t SET t.hora = '{$hora}' WHERE t.idhora_salida_tiempo_extra=1;");

		return 1;	
	}

}
 ?>