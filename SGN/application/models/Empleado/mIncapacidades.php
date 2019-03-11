<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class mIncapacidades extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

	public function registrarModificarIncapacidadesM($info)
	{
		$query=$this->db->query("CALL SE_PA_RegistrarModificarIncapacidades({$info['accion']},'{$info['empleado']}','{$info['fechaI']}','{$info['fechaF']}','{$info['dias']}','{$info['valorT']}','{$info['diagnostico']}','{$info['descripcion']}',{$info['inc']}, {$info['idTipoIncapacidad']}, {$info['idEnfermedad']},'{$info['valorEPS']}', '{$info['valorEmpresa']}','{$info['valorARL']}');");

		$res= $query->row();

		return $res->respuesta;
	}

	public function IncapacidadesM($id)
	{
		$query=$this->db->query("CALL SE_PA_ConsultarIncapacidades({$id});");
		$res=$query->result();

		return $res;
	}

	public function modificarReintregoIncapacidadM($info)
	{
		$query=$this->db->query("CALL SE_PA_ModificarReintegroIncapacidad({$info['idInc']},'{$info['Reintegro']}','{$info['diferencia']}');");

		$res=$query->row();

		return $res->respuesta;
	}

	public function eliminarIncapacidadM($id)
	{
		$query=$this->db->query("CALL SE_PA_EliminarIncapacidad({$id});");

		$res=$query->row();

		return $res->respuesta;
	}

	public function incapacidadesParaExcelM()
	{
		$query=$this->db->query("CALL SE_PA_ReporteIncapacidades();");

		$res=$query->result();

		return $res;
	}

	public function incapacidadesEmpleadosRangoFechasM($info)
	{
		$query=$this->db->query("CALL PA_SE_ConsultarIncapacidadesEmpleadoRangoFecha('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}');");

		$res=$query->result();

		return $res;
	}
	// Se encarga de consultar la cantidad total de inecapacidades que hacen parte del sistema de información
	public function cantidadIncapacidadesM()
	{
		$this->db->select("COUNT(*) as cantidad");
		$this->db->from("incapacidad");

		return $this->db->get()->row();
	}
}
 ?>