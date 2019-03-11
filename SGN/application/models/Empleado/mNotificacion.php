<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mNotificacion extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
// Se encarga de consultar las notificaciones del usuario logiado.
	public function consultarNotificacionesUsuarioM($rol)
	{
		$query= $this->db->query("CALL SE_PA_NotificacionesDeUsuario({$rol});");

		$r= $query->result();

		return $r;
	}
// Se encarga de cambiar el estado de las notificaciones a leido.
	public function cambiarEstadoNotificacionesM($id)
	{
		$query= $this->db->query("CALL SE_PA_CambiarEstadoNotificaciones({$id});");

		$r= $query->row();

		return $r->respuesta;
	}
// Se encarga de consultar la cantidad de notificaciones nuevas por cada usuario.
	public function cantidadNotificacionesNuevasM($id)
	{
		$query= $this->db->query("CALL SE_PA_CantidadNotificacionesNuevas({$id});");

		$r= $query->row();

		return $r->respuesta;
	}
// Se encarga de consultar las personas implicadas en esas notificaciones.
	public function consultarPersonasNotificacionM($info)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarDetalleNotificacion('{$info['fecha']}', {$info['tipo']});");

		$r= $query->result();

		return $r;			
	}
}
 ?>