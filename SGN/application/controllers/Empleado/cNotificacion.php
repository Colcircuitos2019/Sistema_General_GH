<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class cNotificacion extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mNotificacion');
	}

	public function consultarNotificacionesUsuario()//Pendiente por terminar el desarrollo
	{//Hasta acá se llego el 01/10/2018-----
		$rol=$this->input->post('rol');//Esto se debe sacar de la variable global
		$vista=$this->input->post('view');//Esto se debe sacar de la variable global
		// ...
		$notificaciones= $this->mNotificacion->consultarNotificacionesUsuarioM($rol);
		// ...
		echo json_encode($notificaciones);
	}

	public function cambiarEstadoNotificaciones()
	{
		$id=$this->input->post('user');

		$res= $this->mNotificacion->cambiarEstadoNotificacionesM($id);

		echo json_encode($res);
	}

	public function cantidadNotificacionesNuevas()
	{
		$id=$this->input->post('user');

		$res= $this->mNotificacion->cantidadNotificacionesNuevasM($id);

		echo json_encode($res);
	}

	public function consultarPersonasNotificacion()
	{
		$info['fecha']=$this->input->post('fecha');
		$info['tipo']=$this->input->post('tipo');

		$res= $this->mNotificacion->consultarPersonasNotificacionM($info);

		echo json_encode($res);
	}
	// 
	// El enviar notificaciones por correo electronico esta en la carpeta de cron, ya que no se permitia ejecutar el framework para ejecutar una tarea programada.
}

 ?>