<?php 
/**
* 
*/
class mPedidos extends CI_model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}

//Metodos
//Pedidos===============================================================	
	public function consultarfechaM()
	{
		$query=$this->db->query('select DATE_FORMAT(now(),"%d/%m/%Y") as fecha');
		
        $result= $query->row();

		return $result->fecha;	
	}
// Valida la existencia del usuario.
	public function validarUsuarioM($info,$idP)
    {	
    	$query='';
    	// var_dump($info);
    	if ($idP==0) {
     	//Validar que el usuario y la contraseña coniciden
		  $query= $this->db->query("CALL SA_PA_ValidarUsuario('{$info['documento']}', '{$info['password']}');");  		
    	}else{
    	// Valida que el usuario si sea el dueño de ese pedido.
    	  $query=$this->db->query("CALL SA_PA_ValidarUsuarioPedido('{$info['documento']}', '{$info['password']}', $idP);");
    	}

		$result= $query->row();
		//Si retorna  un 1 es porque la persona si ingreso los datos correctos y si retorna un 0 es porque la persona no ingreso los datos correctos o no existe.
		return $result->respuesta;
    }

    //Se encarga de registrar el pedido
	public function registrarModificarPedidoM($info)
	{
		// mysqli_next_result($this->db->conn_id);//Esta linea me soluciona el problema del store procedure de multiples parametros.
		if ($info['op']==0) {
			//Registrar
		    $query=$this->db->query("CALL SA_PA_RegistrarPedido({$info['documento']}, {$info['total']});");
		}else{
			//Modificar
		    $query=$this->db->query("CALL SA_PA_ModificarPedido({$info['total']}, {$info['idP']}, '{$info['fecha']}');");
		}


		$result= $query->row();
		
		return $result->respuesta;
		// return $info;
	}

	//Se encarga de enviar la informacion a la base de datos de las lineas de los pedidos
	public function registrarModificarLineasDetalleM($info)
	{
		//mysqli_next_result($this->db->conn_id);//Esta linea me soluciona el problema del store procedure de multiples parametros.
		//0 es igual a registrar 1 es igual a modificar
        $query=$this->db->query("CALL SA_PA_RegistrarModificarLineasDePedido({$info['cantidad']}, {$info['idPedido']}, {$info['idProducto']}, {$info['idMomento']}, {$info['precio']}, {$info['op']}, {$info['idL']});");

		$result= $query->row();
		
		return $result->respuesta;
	}
	//Consulta el pedido que hizo el empleado por día.
	public function consultarPedidosM($info)
	{
		//SELECT p.idPedido,e.nombre1,e.nombre2,TIME_FORMAT(p.fecha_pedido,'%h:%m:%s') as hora,CONCAT("$",FORMAT(p.total, 0)) as total FROM pedido p JOIN empleado e ON p.documento=e.documento WHERE DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')= DATE_FORMAT(now(),'%d-%m-%Y')
		$query= $this->db->query("CALL SA_PA_ConsultarPedidos({$info['documento']}, {$info['op']});");

        $r= $query->result();

   		return $r;
	}

	//Valida antes de registrar un pedido el empelado no haya realizado un pedido el mismo día (El empelado solo puede realizar un pedido por día).
	public function validarPedidoPorDiaM($doc)
	{
		$query= $this->db->query("CALL SA_PA_ValidarPedidoPorDia('{$doc}');");

		$r= $query->row();

		return $r->respuesta;
	}
    // Se encarga de consultar la diferencia de dias entre la fecha actual y la fecha en que se realizo el pedido para saber si se puede modificar el pedido.
	public function tiempoActualizacionPedidoM($id)
	{
		$query= $this->db->query("CALL SA_PA_ValidarTiempoDeActualizacion({$id});");

		$r= $query->row();

		return $r->respuesta;
	}

	//Advertencia!!! (Solo se eliminaran si estan dentro del rango de horas de pedidos y si la fecha del pedido es la de hoy)
	public function eliminarPedidoM($id)
	{
		$query= $this->db->query("CALL SA_PA_EliminarPedido({$id})");

		$r=$query->row();

		return $r->respuesta;
	}
	//Se encarga de consultar todas las lineas de pedido de un peido realizado
	public function consultarDetallePedidoM($id)
	{
		$query= $this->db->query("CALL SA_PA_ConsultarLineasDetalle({$id})");

		$r=$query->result();

		return $r;
	}
	//Se encarga de eliminar la linea de pedido
	public function EliminarLineaPedidoM($id)
	{
		$query= $this->db->query("CALL SA_PA_EliminarLineaDePedido({$id['idPedido']}, {$id['idLineaP']})");

		$r=$query->row();

		return $r->respuesta;
	}

	public function restriccionPedidosM()
	{
		$query= $this->db->query("CALL SA_PA_ValidarRestriccionTiempos();");

		$r=$query->row();

		$this->db->close();

		return $r->respuesta;
	}
	//Se encarga de consultar el total de productos encargado por el dia.
	public function consultarCantidadProductosProveedorM($idP)
	{	
		// mysqli_next_result($this->db->conn_id);

		$query= $this->db->query("CALL SA_PA_CantidadProductosProveedorDia({$idP})");

		$r=$query->result();

		$this->db->close();

		return $r;
	}
	// Se encarga de consultar el total de lineas de pedidos por empleado y rango de fechas, todos estos datos son obligatorios.
	public function liquidacionEmpledoFechasM($info)
	{
		// mysqli_next_result($this->db->conn_id);

		$query= $this->db->query("CALL SA_PA_LiquidacionPedidosPorEmpeladoYFechas('{$info['documento']}','{$info['fechaI']}','{$info['fechaF']}')");

		$r=$query->result();

		return $r;
	}	
//Reportes=================================================================	
	//Se encarga de consultar el consumo de los empleados por día
	public function resporteConsumoPorEmpleadoM($info)
	{

		// mysqli_next_result($this->db->conn_id);

		$query = $this->db->query("CALL SA_PA_ReporteConsumoEmpleadoDia('{$info['fechaI']}', '{$info['fechaF']}');");

		$r=$query->result();

		return $r;
	}

	//Se encarga de consultar el consumo de proveedor por día.
	public function reporteConsumoPorProveedorM($info)
	{
		// mysqli_next_result($this->db->conn_id);

		$query = $this->db->query("CALL SA_PA_ReporteConsumoProveedorDia('{$info['fechaL']}');");

		$r=$query->result();

		return $r;
	}
// Se encarga de consultar la liquidacion por fecha al proveedor
	public function excelLiquidacionRangoFechasM($fecha)
	{
		mysqli_next_result($this->db->conn_id);//Es necesaria para esta funcion

		$query = $this->db->query("CALL SA_PA_ReporteLiquidacionProveedorDia('{$fecha}');");
		// Se encarga de traer todas las fechas que se realizaron pedidos.
		// SA_PA_FechasReposteLiquidacionProveedorDia
		// Reutilizacion del procedimiento
		// SA_PA_ReporteConsumoProveedorDia
		$r=$query->result();

		$res=json_encode($r);

		// $this->db->close();

		return json_decode($res);
	}
    // Se encarga de consultar las fechas donde se realizaron pedidos
	public function rangoFechasM($fechas1, $fecha2)
	{	
		// mysqli_next_result($this->db->conn_id);

		$query = $this->db->query("CALL SA_PA_FechasReposteLiquidacionProveedorDia('{$fechas1}', '{$fecha2}');");

		$r=$query->result();

		$res=json_encode($r);


		return json_decode($res);		
	}
	// Se encarga de consultar la liquidacion de los empelados por rango de fechas
	public function liquidarEmpleadoRangoFechasM($fechas1, $fecha2)
	{	
		// mysqli_next_result($this->db->conn_id);

		$query = $this->db->query("CALL SA_PA_LiquidacionEmpleadoPorFechas('{$fechas1}', '{$fecha2}');");

		$r=$query->result();

		$res=json_encode($r);

		return json_decode($res);		
	}
	// Se encarga de consultar la liquidacion de los pedidos por proveedor realizado por cada empleado.
	public function liquidarEmpleadoProveedorRangoFechasM($fechas1, $fecha2)
	{	
		// mysqli_next_result($this->db->conn_id);

		$query = $this->db->query("CALL SA_PA_LiquidacionProveedorEmpleadoRangoFecha('{$fechas1}', '{$fecha2}');");

		$r=$query->result();

		$res=json_encode($r);

		return json_decode($res);		
	}	
	// Se encarga de consultar la informacion total por cada proveedor
	public function totalInfoPedidoFechaM($info)
	{
		mysqli_next_result($this->db->conn_id);//Son necesarios para esta funcion

		$query = $this->db->query("CALL SA_PA_ReporteConsumoProveedorDia('{$info}');");
		
		$r=$query->result();

		$res=json_encode($r);

		return json_decode($res);
	}
	// Se encarga de consultar todos los correos electronicos de los proveedores
	public function consultarCorreosProveedoresM()
	{
	  // mysqli_next_result($this->db->conn_id);

	  $query = $this->db->query("CALL SA_PA_ConsultarCorreosProveedor();");

	  $r=$query->result();

	  $res=json_encode($r);

	  $this->db->close();

      return json_decode($res);
	}
	// Consulta el detalle de pedido de cada empleado por proveedor.
	public function consultarDetallePorProveedorM($idPro,$idP)
    {
      // mysqli_next_result($this->db->conn_id);

      $query = $this->db->query("CALL SA_PA_ConsultarLineasDetallePorProveedor({$idPro}, {$idP});");

	  $r=$query->result();

	  $res=json_encode($r);

      return json_decode($res);
    }
//Consulta los numero de los pedidos que tiene minimamente un producto del proveedor.
    public function consultarNumeroPedidosPorProveedorM($idP)
    {
    	// mysqli_next_result($this->db->conn_id);

      $query = $this->db->query("CALL SA_PA_ConsultarNumeroPedidoPorProveedor({$idP});");

	  $r=$query->result();

	  $res=json_encode($r);

      return json_decode($res);
    }
//Se encarga de registrar el registro de que si se envio satisfactoriamente el correo.
    public function registrarEnvioCorreoProveedor($idP)
    {	
    	mysqli_next_result($this->db->conn_id);

    	$query= $this->db->query("CALL SA_PA_RegistrarFechaEnvioCorreoPedidos({$idP});");

		$r=$query->row();

		$this->db->close();

		return $r->respuesta;
    }
//Se encarga de validar si el correo fue enviado si o no el dia de hoy al proveedro con los pedidos correspondientes al dia cruzado.
    public function validarEnviosDiariosM($idP)
    {
        // mysqli_next_result($this->db->conn_id);

    	$query= $this->db->query("CALL SA_PA_ValidarEnvioPedidosDiario({$idP});");

		$r=$query->row();

		$this->db->close();

		return $r->respuesta;
    }
//Se encarga de consultar los pedidos del dia cruzado por proveedor y empleado.    
    public function ConsultarPedidosPorEmpeladoProveedor($idP)
    {
    	// mysqli_next_result($this->db->conn_id);

		$query = $this->db->query("CALL SA_PA_ReportePedidosPorempleadoProveedor({$idP});");

		$r=$query->result();

		$res=json_encode($r);

		return json_decode($res);
    }
    // Se encarga de consultar la cantidad de pedidos pedidos por cada empleado.
    public function cantidadLineasPedidoEmpleadoM($doc)//Esta funcion ya no se esta utilizando---
    {
        	$query= $this->db->query("CALL SA_PA_CambiarEstadoPedido('{$doc}');");

    		$r=$query->row();

    		return $r->rowsConect;	    	
    }
    // Se encarga de marcar que el pedido del empleado fue realizado correctamente.
    public function cambiarEstadoPedidoM()
    {
    	// mysqli_next_result($this->db->conn_id);

    	$query= $this->db->query("CALL SA_PA_CambiarEstadoPedido();");

		$r=$query->row();

		return $r->respuesta;
    }
    // <!-- Consulta de pedido -->
// <!-- SELECT p.idPedido,DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y') AS solofecha,p.documento,em.nombre AS empresa,prv.nombre AS proveedor,UPPER(e.nombre1) ,UPPER(e.nombre2),UPPER(e.apellido1),UPPER(e.apellido2),CONCAT("$",FORMAT(lp.precio, 0)) as total FROM proveedor prv JOIN producto pro ON prv.idProveedor=pro.idProveedor JOIN lineas_pedido lp ON pro.idProducto=lp.idProducto JOIN pedido p ON lp.idPedido=p.idPedido JOIN empleado e ON p.documento=e.documento JOIN empresa em ON em.idEmpresa=e.idEmpresa WHERE p.fecha_pedido BETWEEN '2018-07-01' AND ADDDATE('2018-07-31', INTERVAL 1 DAY) ORDER BY p.idPedido LIMIT 600 -->

}
 ?>
