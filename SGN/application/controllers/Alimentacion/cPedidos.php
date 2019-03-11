<?php 
/**
* 
*/
class cPedidos extends CI_Controller
{
	function __construct()
	{
		parent::__construct();
		$this->load->model('Alimentacion/mPedidos');
	}
//Retorno de vista princuipal
	public function index()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
			redirect('cLogin');
		}else{
		    $this->load->view('Alimentacion/Pedidos.php');
        $this->load->view('Layout/clausulas');
		    // $this->session->sess_destroy();
		}
	}

	public function pedidos()
	{
		if ($this->session->userdata('tipo_usuario')==false) {
			redirect('cLogin');
		}else{
			$this->load->view('Alimentacion/getorPedidos.php');
      $this->load->view('Layout/clausulas'); 
			 // $this->session->sess_destroy();
		}
	}
	public function pedidos1()
	{	
		if ($this->session->userdata('tipo_usuario')==false) {
			redirect('cLogin');
		}else{
    //...
    $dato['titulo']="Alimentacion";
    $dato['path']="cAlimentacion";
    $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
    $dato['tipoUser']=$this->session->userdata('tipo_usuario'); 
    //... 
		$this->load->view('Layout/Header1',$dato);
		$this->load->view('Layout/MenuLateral');
		$this->load->view('Alimentacion/pedidos1.php');
		$this->load->view('Layout/Footer');
    $this->load->view('Layout/clausulas');
		}
	}
//Retorno de vistas


//Metodos	
	public function consultarFechaPedido()
	{
		$res=$this->mPedidos->consultarfechaM();

		echo json_encode($res);
	}

    public function validarUsuario()
    {	
    	//Validar que el usuario y la contraseña coniciden
		$info['documento']=$this->input->post('documento');
		$info['password']= base64_encode($this->input->post('password'));
		$idP=$this->input->post('idP');

		$res = $this->mPedidos->validarUsuarioM($info,$idP);

		echo $res;
    }

	public function registrarModificarPedido()
	{
		//Registrar el pedio
		$info['documento']=$this->input->post('documento');	
		$info['total']=$this->input->post('total');
		$info['op']=$this->input->post('op');
		$info['idP']=$this->input->post('idP');
    $info['fecha']=$this->input->post('fecha');

		$res = $this->mPedidos->registrarModificarPedidoM($info);

		echo $res;
	}

	public function registrarModificarLineasDetalle()
	{
		$info['cantidad']=$this->input->post('cantidad');	
		$info['idPedido']=$this->input->post('idPedido');
		$info['idProducto']=$this->input->post('idProducto');
		$info['idMomento']=$this->input->post('idMomento');
		$info['precio']=$this->input->post('precio');

		$info['op']=$this->input->post('op');
		$info['idL']=$this->input->post('idL');


		$res = $this->mPedidos->registrarModificarLineasDetalleM($info);

		echo $res;
	}

	public function consultarPedidos()
	{
		$info['documento']=$this->input->post('documento');
		$info['op']=$this->input->post('op');

		$res= $this->mPedidos->consultarPedidosM($info);

		echo json_encode($res);
	}

	public function validarPedidoPorDia()
	{
		$doc=$this->input->post('documento');
		$res= $this->mPedidos->validarPedidoPorDiaM($doc);

		echo $res;
	}

	public function eliminarPedido()
	{
	 	$id=$this->input->post('idPedido');

	 	$res=$this->mPedidos->eliminarPedidoM($id);

	 	echo $res;
	}

  public function tiempoActualizacionPedido()
  {
    $id=$this->input->post('idPedido');

    $res=$this->mPedidos->tiempoActualizacionPedidoM($id);

    echo $res;
  }

	public function consultarDetallePedido()
	{
		$id=$this->input->post('idP');

		$res= $this->mPedidos->consultarDetallePedidoM($id);

		echo json_encode($res);
	}

	public function EliminarLineaPedido()
	{
		$id['idPedido']=$this->input->post('idP');
		$id['idLineaP']=$this->input->post('idL');

		$res= $this->mPedidos->EliminarLineaPedidoM($id);

		echo $res;
	}

	public function restriccionPedidos()
	{
		$res=$this->mPedidos->restriccionPedidosM();

		echo $res;
	}

	public function consultarCantidadProductosProveedor()
	{
    $idP=$this->input->post('idProveedor');

		$res=$this->mPedidos->consultarCantidadProductosProveedorM($idP);
		
		echo json_encode($res);
	}

	public function resporteConsumoPorEmpleado()
	{
	    $info['fechaI']=$this->input->post('fechaI');
		$info['fechaF']=$this->input->post('fechaF');

		$res= $this->mPedidos->resporteConsumoPorEmpleadoM($info);

		echo json_encode($res);
	}

	public function reporteConsumoPorProveedor()
	{
	    $info['fechaL']=$this->input->post('fechaL');

		$res= $this->mPedidos->reporteConsumoPorProveedorM($info);

		echo json_encode($res);
	}

   public function reporteLiquidacionPRoveedorDia()
  {

  	$fecha=$this->input->get('fecha');

 	print_r($fecha);
    // $res= $this->mEmpleado->reporteEmpleadosM();  

    
    // $arr=json_encode($res);//Convertimos el resulset en un string formato json

    // $this->excelLiquidacionPRoveedorDia(json_decode($arr));//Enviamos el json de nuevo pero lo transformamos en un array de json para facilitar su lectura

  }
	public function rangoFechas($fecha1,$fecha2)
  	{
  		$res=$this->mPedidos->rangoFechasM($fecha1,$fecha2);

  		return $res;
  	}

  	public function reporteExcelLiquidacion($fecha)
  	{
  		$res= $this->mPedidos->excelLiquidacionRangoFechasM($fecha);

  		return $res;
  	}

  	public function totalInfoPedidoFecha($fecha)
  	{
  		$res= $this->mPedidos->totalInfoPedidoFechaM($fecha);

  		return $res;
  	}

    public function liquidacionEmpledoFechas()
    {
      $info['documento']=$this->input->post('documento');
      $info['fechaI']=$this->input->post('fechaI');
      $info['fechaF']=$this->input->post('fechaF');

      $res=$this->mPedidos->liquidacionEmpledoFechasM($info);

      echo json_encode($res);
    }

    public function excelLiquidacionRangoFechas()
    { 

      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

      $objPHPExcel= new PHPExcel();

      $objPHPExcel->getProperties()->setCreator("");
      $objPHPExcel->getProperties()->setLastModifiedBy("");
      $objPHPExcel->getProperties()->setTitle("");
      $objPHPExcel->getProperties()->setSubject("");
      $objPHPExcel->getProperties()->setDescription("");


      $objPHPExcel->setActiveSheetIndex(0);

    //  $estilo = array( 
    //    'borders' => array(
    //      'outline' => array(
    //        'style' => PHPExcel_Style_Border::BORDER_THIN
    //      )
    //    )
    //  );

    // $objPHPExcel->getActiveSheet()->getStyle('A2')->applyFromArray($estilo);//Se encarga de colocar el border de las celdas
     
    // Variables get 
    $fechas['fecha1']= (string)$_GET['fechaI'];
    $fechas['fecha2']= (string)$_GET['fechaF'];
    // $fechas['fecha2']=$this->input->post('fechaF');
    // Consulta todos las fechas por las cuales va a consultar para realizar el reporte. 
    $datos= $this->rangoFechas($fechas['fecha1'],$fechas['fecha2']);

    $fecha=0;
    // $i=2;
    $j=4;
    // $fila=5;
    $accion=0;
    // $cont=0;
    // Recorre el json de las fechas// row1=Fechas, row=Pedidos realizados
    foreach ($datos as $row1) {
    	// Validacion para saber cada cuanto colocar la fecha
    	if ($fecha==0) {
    	  //Fecha 
          $objPHPExcel->getActiveSheet()->SetCellValue('A'.($j-2),'Fecha');
          $objPHPExcel->getActiveSheet()->getStyle('A'.($j-2))->getFont()->setBold(true);//Se encarga de colocar el tipo de letra den negrilla
          // $i++;
          $objPHPExcel->getActiveSheet()->SetCellValue('A'.($j-1), $row1->fechasP);//Fecha Que se realizo el pedido
          // $i++;
          // Hora de pedido
          $objPHPExcel->getActiveSheet()->SetCellValue('A'.$j,'Hora');
          $objPHPExcel->getActiveSheet()->getStyle('A'.$j)->getFont()->setBold(true);
          // Nombre de la empresa a la que pertenece el empleados
          $objPHPExcel->getActiveSheet()->SetCellValue('B'.$j,'Empresa');
          $objPHPExcel->getActiveSheet()->getStyle('B'.$j)->getFont()->setBold(true);
          // Numero de documento
          $objPHPExcel->getActiveSheet()->SetCellValue('C'.$j,'Numero Documento');
          $objPHPExcel->getActiveSheet()->getStyle('C'.$j)->getFont()->setBold(true);
          // Nombre del empleado.
          $objPHPExcel->getActiveSheet()->SetCellValue('D'.$j,'Nombre Empleado');
          $objPHPExcel->getActiveSheet()->getStyle('D'.$j)->getFont()->setBold(true);
          // Precio total del pedido
          $objPHPExcel->getActiveSheet()->SetCellValue('E'.$j,'Valor');
          $objPHPExcel->getActiveSheet()->getStyle('E'.$j)->getFont()->setBold(true);
          $j++;
          // $cont++;
    	  $fecha=1;
    	}
    	// Recorre los pedidos que se realizaron en la fecha ingresada.
    	$data= $this->reporteExcelLiquidacion($row1->fechasP);
    	// Listado de pedidos
    	foreach ($data as $row) {
    		// Hora de declaración del pedido
    		$objPHPExcel->getActiveSheet()->SetCellValue('A'.$j,$row->hora);
    		// Nombre de la empresa a la que pertenece el empleado
    		$objPHPExcel->getActiveSheet()->SetCellValue('B'.$j,$row->nombre);//Empresa
    		// Numero de documento
            $objPHPExcel->getActiveSheet()->SetCellValue('C'.$j,$row->documento);
            // Nombre del empleado
            $objPHPExcel->getActiveSheet()->SetCellValue('D'.$j,strtoupper($row->nombre1).' '.strtoupper($row->nombre2).' '.strtoupper($row->apellido1).' '.strtoupper($row->apellido2));
            // Precio total del pedido realizado por el empleado.
            $objPHPExcel->getActiveSheet()->SetCellValue('E'.$j,$row->valor);
            $j++;
            // $fila++;
            // $cont++;    
    	}
    	// Consultar Total Proveedores
    	$dataFin= $this->totalInfoPedidoFecha($row1->fechasP);
    	// 
    	foreach ($dataFin as $row) {
    		if ($accion==0) {
    			// Etiqueta del total
    			$objPHPExcel->getActiveSheet()->SetCellValue('D'.$j,'Total');
    			$objPHPExcel->getActiveSheet()->getStyle('D'.$j)->getFont()->setBold(true);
    			// Precio Total Pedidos
    			$objPHPExcel->getActiveSheet()->SetCellValue('E'.$j,$row->totalP);
    			$objPHPExcel->getActiveSheet()->getStyle('E'.$j)->getFont()->setBold(true);
    			// Incrementos
    			$j++;
    			$accion=1;
    			// $fila++;
    		}	

    		    //Etiqueta del proveedor  
    			$objPHPExcel->getActiveSheet()->SetCellValue('C'.$j,'Productos pedidos: '.$row->ProductosC);
    			$objPHPExcel->getActiveSheet()->SetCellValue('D'.$j,$row->proveedor);
    			$objPHPExcel->getActiveSheet()->getStyle('D'.$j)->getFont()->setBold(true);
    			// Valor a pagar por cada proveedor
    			$objPHPExcel->getActiveSheet()->SetCellValue('E'.$j,$row->total);
    			$objPHPExcel->getActiveSheet()->getStyle('E'.$j)->getFont()->setBold(true);
          $j++;
    	}    	
    	// Reiniciar variables
    	$fecha=0;
    	// $i=($i+$j);
      	$j=($j+4);//Espacios
      	// $fila+=4;
    	$accion=0;
      }

    $filiname="ReporteLiquidacion-".date("Y-m-d h:i:s").'xlsx';
    $objPHPExcel->getActiveSheet()->setTitle("Empelados");

    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Diposition: attachment;filiname="'.$filiname.'"');
    header('Cache-Control: max-age=0');

    $write= PHPExcel_IOFactory::createWriter($objPHPExcel,'Excel2007');
    $write->save('php://output');

    exit;

    }
//
    public function excelLiquidacionProveedorRangoFechas()
    {
      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

      $objPHPExcel= new PHPExcel();

      $objPHPExcel->getProperties()->setCreator("");
      $objPHPExcel->getProperties()->setLastModifiedBy("");
      $objPHPExcel->getProperties()->setTitle("");
      $objPHPExcel->getProperties()->setSubject("");
      $objPHPExcel->getProperties()->setDescription("");


      $objPHPExcel->setActiveSheetIndex(0);

      // Variables get 
      $fechas['fecha1']= (string)$_GET['fechaI'];
      $fechas['fecha2']= (string)$_GET['fechaF'];
      // Fecha de inicio
      $objPHPExcel->getActiveSheet()->SetCellValue('A'.(2),'ID Pedido');
      $objPHPExcel->getActiveSheet()->getStyle('A'.(2))->getFont()->setBold(true);
      // Fecha de Fin
      $objPHPExcel->getActiveSheet()->SetCellValue('B'.(2),'Fecha Pedido');
      $objPHPExcel->getActiveSheet()->getStyle('B'.(2))->getFont()->setBold(true);
      // Headers
      // Numero de documento
      $objPHPExcel->getActiveSheet()->SetCellValue('C'.(2),'Documento');
      $objPHPExcel->getActiveSheet()->getStyle('C'.(2))->getFont()->setBold(true);
      // Nombre del empleado
      $objPHPExcel->getActiveSheet()->SetCellValue('D'.(2),'Nombre empleado');
      $objPHPExcel->getActiveSheet()->getStyle('D'.(2))->getFont()->setBold(true);
      // Empresa
      $objPHPExcel->getActiveSheet()->SetCellValue('E'.(2),'Empresa');
      $objPHPExcel->getActiveSheet()->getStyle('E'.(2))->getFont()->setBold(true);
      // Proveedor
      $objPHPExcel->getActiveSheet()->SetCellValue('F'.(2),'Proveedor');
      $objPHPExcel->getActiveSheet()->getStyle('F'.(2))->getFont()->setBold(true);
      // Total
      $objPHPExcel->getActiveSheet()->SetCellValue('G'.(2),'Precio Total');
      $objPHPExcel->getActiveSheet()->getStyle('G'.(2))->getFont()->setBold(true);
      // 
      // Finde headers
      // Consulta los empleados que se les liquidara en esas fechas.
      $datos= $this->mPedidos->liquidarEmpleadoProveedorRangoFechasM($fechas['fecha1'],$fechas['fecha2']);
      $i =3;
      $total=0;
      foreach ($datos as $row) {
        $objPHPExcel->getActiveSheet()->SetCellValue('A'.$i,$row->idPedido);
        $objPHPExcel->getActiveSheet()->SetCellValue('B'.$i,$row->solofecha);
        $objPHPExcel->getActiveSheet()->SetCellValue('C'.$i,$row->documento);
        $objPHPExcel->getActiveSheet()->SetCellValue('D'.$i,$row->nombre);
        $objPHPExcel->getActiveSheet()->SetCellValue('E'.$i,$row->empresa);
        $objPHPExcel->getActiveSheet()->SetCellValue('F'.$i,$row->proveedor);
        $objPHPExcel->getActiveSheet()->SetCellValue('G'.$i,$row->precio);// total
        $i++;
        $total+=$row->precio;
      }

      $objPHPExcel->getActiveSheet()->SetCellValue('G'.($i),$total);

      $filiname="LiquidacionProveedorEmpleadoRangoFechas-".date("Y-m-d h:i:s").'xlsx';
      $objPHPExcel->getActiveSheet()->setTitle("Empleados-Proveedor");

      header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      header('Content-Diposition: attachment;filiname="'.$filiname.'"');
      header('Cache-Control: max-age=0');

      $write= PHPExcel_IOFactory::createWriter($objPHPExcel,'Excel2007');
      $write->save('php://output');

      exit;

    }

    public function excelLiquidacionEmpleadoRangoFechas()
    { 

      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

      $objPHPExcel= new PHPExcel();

      $objPHPExcel->getProperties()->setCreator("");
      $objPHPExcel->getProperties()->setLastModifiedBy("");
      $objPHPExcel->getProperties()->setTitle("");
      $objPHPExcel->getProperties()->setSubject("");
      $objPHPExcel->getProperties()->setDescription("");


      $objPHPExcel->setActiveSheetIndex(0);

    // $objPHPExcel->getActiveSheet()->getStyle('A2')->applyFromArray($estilo);//Se encarga de colocar el border de las celdas
     
    // Variables get 
    $fechas['fecha1']= (string)$_GET['fechaI'];
    $fechas['fecha2']= (string)$_GET['fechaF'];
    // Fecha de inicio
    $objPHPExcel->getActiveSheet()->SetCellValue('A'.(2),'Fecha Inicio');
    $objPHPExcel->getActiveSheet()->getStyle('A'.(2))->getFont()->setBold(true);
    $objPHPExcel->getActiveSheet()->SetCellValue('A'.(3), $fechas['fecha1']);
    // Fecha de Fin
    $objPHPExcel->getActiveSheet()->SetCellValue('D'.(2),'Fecha Fin');
    $objPHPExcel->getActiveSheet()->getStyle('D'.(2))->getFont()->setBold(true);
    $objPHPExcel->getActiveSheet()->SetCellValue('D'.(3), $fechas['fecha2']);
    // Headers
    // Numero de documento
    $objPHPExcel->getActiveSheet()->SetCellValue('A'.(4),'Documento');
    $objPHPExcel->getActiveSheet()->getStyle('A'.(4))->getFont()->setBold(true);
    // Nombre del empleado
    $objPHPExcel->getActiveSheet()->SetCellValue('B'.(4),'Nombre empelado');
    $objPHPExcel->getActiveSheet()->getStyle('B'.(4))->getFont()->setBold(true);
    // nombre de la empresa
    $objPHPExcel->getActiveSheet()->SetCellValue('C'.(4),'Empresa');
    $objPHPExcel->getActiveSheet()->getStyle('C'.(4))->getFont()->setBold(true);
    // Deducido
    $objPHPExcel->getActiveSheet()->SetCellValue('D'.(4),'Deducido');
    $objPHPExcel->getActiveSheet()->getStyle('D'.(4))->getFont()->setBold(true);
    // Finde headers
    // Consulta los empleados que se les liquidara en esas fechas.
    $datos= $this->mPedidos->liquidarEmpleadoRangoFechasM($fechas['fecha1'],$fechas['fecha2']);
    $i =5;
    $total=0;
    foreach ($datos as $row) {
      // Cuerpo del documento.
      $objPHPExcel->getActiveSheet()->SetCellValue('A'.($i),$row->documento);
      $objPHPExcel->getActiveSheet()->SetCellValue('B'.($i),strtoupper($row->nombre1).' '.strtoupper($row->nombre2).' '.strtoupper($row->apellido1).' '.strtoupper($row->apellido2));
      $objPHPExcel->getActiveSheet()->SetCellValue('C'.($i),$row->nombre);
      $objPHPExcel->getActiveSheet()->SetCellValue('D'.($i),$row->total);//$row->devengado
      $total+=$row->total;
      $i++;
    }
    //Valor total
    $objPHPExcel->getActiveSheet()->SetCellValue('D'.($i), $total);

    //Este agregar formato de numero a la celda no funciono<-------
    // $objPHPExcel->getActiveSheet()->getStyle('G3:G'.($i))->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_CURRENCY_USD_SIMPLE);

    $filiname="LiquidacionRangoFechas-".date("Y-m-d h:i:s").'xlsx';
    $objPHPExcel->getActiveSheet()->setTitle("Empelados");

    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Diposition: attachment;filiname="'.$filiname.'"');
    header('Cache-Control: max-age=0');

    $write= PHPExcel_IOFactory::createWriter($objPHPExcel,'Excel2007');
    $write->save('php://output');

    exit;

    } 
// Funciones para el envio de correos electronicos a los proveedores.
    public function consultarCorreosProveedor()
    {
      $r= $this->mPedidos->consultarCorreosProveedoresM();

      return $r;
    }

// 
    public function generarReportePorProoveedor($idP)
    {
        $res=$this->mPedidos->consultarCantidadProductosProveedorM($idP);
    
        $r= json_encode($res);

        return json_decode($r);
    }
// 
    public function validarHoraEnvioMensajes()
    {
      $res=$this->mPedidos->restriccionPedidosM();

      return $res;
    }
// 
    public function validarEnviosDiarios($idP)
    {
      $res=$this->mPedidos->validarEnviosDiariosM($idP);

      return $res;
    }
// 
    public function cambiarEstadoPedido()
    {
      $res=$this->mPedidos->cambiarEstadoPedidoM();

      return $res;
    }
    public function generarMensajeProveedor($pedidos,$empleados)
    {
      // Variables
      $total=0;
      $fechaActual=getdate();
      $existe=0;
      $mensaje=''; 
      // Header
      $mensaje.="<TABLE BORDER CELLPADDING=10 CELLSPACING=0>
                       <tr>
                         <th COLSPAN=4>Pedidos del: $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]</th>
                       </tr>
                       <tr>
                         <th>Producto</th>
                         <th>Momento</th>
                         <th>Cantidad</th>
                         <th>Precio</th>
                       </tr>";
        //body 
        foreach ($pedidos as $row1) {
            //Cabeza de la tabla
            $existe++;
            $mensaje.='<tr>
                        <td>'.$row1->producto.'</td>
                        <td>'.($row1->momento==1?'Desayuno':'Almuerzo').'</td>
                        <td>'.$row1->cantidad.'</td>
                        <td>'.$row1->valor.'</td>
                      </tr>';
            //Consultar Detalles pedido, id del proveedor y id del pedido
            // $detalles= $this->consultarDetallePorProveedorPedido($row->idProveedor,$row1->idPedido);
            $total+=$row1->subValor;
            // $op=0;
          }
          // Footer
          $mensaje.='<tr>
                        <th COLSPAN=3 ALIGN=center> Precio Total</th>
                        <td ALIGN=center>'.$this->convertirNumeroAPesos($total).'</td>
                      </tr></TABLE>';
          //Pedidos por empleado para cada proveedor.
           $mensaje.="<br><br><TABLE BORDER CELLPADDING=10 CELLSPACING=0>
                       <tr>
                         <th COLSPAN=4>Pedidos por empleado del: $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]</th>
                       </tr>
                       <tr>
                         <th>Producto</th>
                         <th>Momento</th>
                         <th>Cantidad</th>
                         <th>Empleado</th>
                       </tr>";           
           foreach ($empleados as $row) {
             $mensaje.='<tr>
                        <td>'.$row->producto.'</td>
                        <td>'.($row->momento==1?'Desayuno':'Almuerzo').'</td>
                        <td>'.$row->cantidad.'</td>
                        <td>'.$row->nombre1.' '.$row->nombre2.' '.$row->apellido1.' '.$row->apellido2 .'</td>
                      </tr>';
           }
           $mensaje.='</TABLE>';

        return ($existe>=1?$mensaje:'');                
    }
// 
    public function convertirNumeroAPesos($valor)//no hay necesidad de convertir Strign el Int
    { 
      $res=0;
      switch (strlen($valor)) {
        case 6:
          $res=3;//STR de tres digitos
          break;
        case 5:
          $res=2;//STR de dos digitos
          break;
        case 4:
          $res=1;//STR de un digitos
          break;
        case 3:
          return '$'.$valor;//Retorna directamente
          break;
      }
      // Se va a separar la cadena para insertar el punto de miles.
      $num1=substr($valor,0,$res);//Primer parte del numero
      return '$'.$num1.'.'.substr($valor,$res);//se arma el numero con el punto de mil y se retorna.
    }

// Correos de los proveedores Diego=aracelly.ospina@colcircuitos.com
    // Almeurzos= edwingalvis360@gmail.com
    // Panaderia= deleitatexpress@hotmail.com
    public function enviarCorreroPedidosProveedor()
    {   
        $hora=$this->validarHoraEnvioMensajes();
        // 
        if ($hora==0) {
            // Consultar Correos Proveedor
            $correos= $this->consultarCorreosProveedor();
           // 
           require(APPPATH.'third_party/PHPMail/archivosformulario/class.phpmailer.php'); // Requiere PHPMAILER para poder enviar el formulario desde el SMTP de google
           //
           $con=1;
           $mensaje;
           $respuesta=0;
           $i=0;
           $envios;
           $fechaActual=getdate(); 
           // Recorres la informacion de los proveedores.
      foreach ($correos as $row) {
             // 
             //se valida que el pedido fue enviado al proveedor en el dia en curso.
            if ($this->validarEnviosDiarios($row->idProveedor)) {
              // Cuando no existe el envio de los pedidos al proveedor
              $mail = new PHPMailer();

              $mail->From     = 'auxiliargestionhumana@colcircuitos.com';//'aracelly.ospina@colcircuitos.com'
              $mail->FromName = 'Auxiliar Gestión Humana'; 
              $mail->AddAddress($row->email); // Dirección a la que llegaran los mensajes.
              // 
              // Aquí van los datos que apareceran en el correo que reciba   
              $mail->WordWrap = 50; 
              $mail->IsHTML(true);     
              $mail->Subject  =  "Colcircuitos S.A.S Pedidos del dia $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year]"; // Asunto del mensaje. El asundo no me reconoce las tildes ni la consonante ñ en el asunto.
              //Generando el cuerpo del mensaje
              // Consulta de numero de los pedidos
              // $pedidos=$this->consultarNumeroPedidosPorProveedor($row->idProveedor);//Trae el numero del pedido y el nombre del empleado que realizo el pedido el dia en curso.
              $pedidos=$this->generarReportePorProoveedor($row->idProveedor);
              // ...
              $empleadoP=$this->mPedidos->ConsultarPedidosPorEmpeladoProveedor($row->idProveedor);
              // ...
              $mensaje='';
              // $con++;
              // Genera el cuerpo del mensaje
              $mensaje=$this->generarMensajeProveedor($pedidos,$empleadoP); 
              // 
              //Cuerpo del mensaje
              $mail->Body = ($mensaje!=''?$mensaje:'El día de hoy no se realizaron pedidos para su establecimiento.');
              // $existe=0;
              // $total=0;
              // Datos del servidor SMTP, podemos usar el de Google, Outlook, etc...
              $mail->IsSMTP(); 
              $mail->Host = "ssl://smtp.gmail.com:465";  // Servidor de Salida. 465 es uno de los puertos que usa Google para su servidor SMTP
              $mail->SMTPAuth = true; 
              $mail->Username = "auxiliargestionhumana@colcircuitos.com";  // Correo Electrónico
              $mail->Password = "mail.col75"; // Contraseña del correo
              //Enviar el mensaje 1=El mensaje fue enviado, 0=El mensaje no fue enviado, 2=Ya exisia el envio del mensaje.
              if ($mail->Send()){
               // 
                  $r= $this->mPedidos->registrarEnvioCorreoProveedor($row->idProveedor);
               // 
                  $envios[$i]=$row->nombre.';1';
                  $i++;
               // 
               }else{
               // 
                $envios[$i]=$row->nombre.';0';
                $i++;
              }
            }else{
              // Cuando ya se le envio el pedido al proveedor.
                $envios[$i]=$row->nombre.';2';
                $i++;
            }
       // 
      }
      echo json_encode($envios);//gettype para conocer el tipo de dato de la variable
        }else{//Cuando no es hora de enviar el permiso se va a enviar un mensaje de alerta
          // 
          echo json_encode('Aún no se pueden enviar los correos a los proveedores por que todavia es hora de realizar pedidos.');
        }   
  }

  public function reportePedidosProveedorPDF()
  {
    // Variables
    $total=0;
    // 
    // ID del proveedor a generar el reporte
    // $idProveedor=$this->input->post('idPeroveedor');
    $idProveedor=$_GET['id'];
    // Nombre proveedor
    // $nombreP=$this->input->post('nomProveedor');
    $nombreP=$_GET['nom'];
    // Se carga la libreria fpdf
    $this->load->library('PDFPedidos');

    // $this->PDF->setData($parmetrs);
 
    // Creacion del PDF
 
    /*
     * Se crea un objeto de la clase Pdf, recuerda que la clase Pdf
     * heredó todos las variables y métodos de fpdf
     */
    $this->pdf = new PdfPedidos();
    // Variables
    // $this->pdf->setDataPedidos(1);
    // Agregamos una página
    $this->pdf->AddPage();
    // Define el alias para el número de página que se imprimirá en el pie
    $this->pdf->AliasNbPages();
 
    /* Se define el titulo, márgenes izquierdo, derecho y
     * el color de relleno predeterminado
     */
    $this->pdf->SetTitle("Lista de pedido");
    $this->pdf->SetLeftMargin(10);
    $this->pdf->SetRightMargin(10);
    $this->pdf->SetFillColor(200,200,200);
     // Inicio de la tabla 1
    // Se define el formato de fuente: Arial, negritas, tamaño 9
    $this->pdf->SetFont('Arial', 'B', 9);
    /*
     * TITULOS DE COLUMNAS de los productos que se pidieron a ese proveedor
     *
     * $this->pdf->Cell(Ancho, Alto,texto,borde,posición,alineación,relleno);
     */
    // Cabeza de la tabla de pedidos por producto y por proveedor
    $this->pdf->Cell(115,7,'Producto',1,0,'C','1');
    $this->pdf->Cell(25,7,'Momento',1,0,'C','1');
    $this->pdf->Cell(18,7,'Cantidad',1,0,'C','1');
    $this->pdf->Cell(35,7,'Precio',1,0,'C','1');
    $this->pdf->Ln(7);//Realiza un salto de linia de un alto de 7

    $pedidos=$this->generarReportePorProoveedor($idProveedor);
    // ...
    // $empleadoP=$this->mPedidos->ConsultarPedidosPorEmpeladoProveedor();
    // Cuerpo de de pedidos por producto y por proveedor
    foreach ($pedidos as $row) {
      // se imprime el numero actual y despues se incrementa el valor de $x en uno
      $this->pdf->Cell(115,7,utf8_decode($row->producto),1,0,'C');
      $this->pdf->Cell(25,7,($row->momento==1?'Desayuno':'Almuerzo'),1,0,'C');
      $this->pdf->Cell(18,7,$row->cantidad,1,0,'C');
      $this->pdf->Cell(35,7,$row->valor,1,0,'C');
      $this->pdf->Ln(7);//Realiza un salto de linia de un alto de 7
      $total+=$row->subValor;
    }
    // Precio total del pedido
    $this->pdf->Cell(158,7,'Precio Total',1,0,'C');
    $this->pdf->Cell(35,7,$this->convertirNumeroAPesos($total),1,0,'C');
    // Fin de la tabla 1
    // Dos saltos de linea
    $this->pdf->Ln(7);
    $this->pdf->Ln(7);
    // Inicio tabla numero 2
    $this->pdf->Cell(90,7,'Producto',1,0,'C','1');
    $this->pdf->Cell(25,7,'Momento',1,0,'C','1');
    $this->pdf->Cell(18,7,'Cantidad',1,0,'C','1');
    $this->pdf->Cell(60,7,'Empleado',1,0,'C','1');
    $this->pdf->Ln(7);//Realiza un salto de linia de un alto de 7

    $empleadoP=$this->mPedidos->ConsultarPedidosPorEmpeladoProveedor($idProveedor);
    // Cuerpo de de pedidos por producto y por proveedor
    foreach ($empleadoP as $row) {
      // se imprime el numero actual y despues se incrementa el valor de $x en uno
      $this->pdf->Cell(90,7,utf8_decode($row->producto),1,0,'C');
      $this->pdf->Cell(25,7,($row->momento==1?'Desayuno':'Almuerzo'),1,0,'C');
      $this->pdf->Cell(18,7,$row->cantidad,1,0,'C');
      $this->pdf->Cell(60,7,utf8_decode($row->nombre1.' '.$row->nombre2.' '.$row->apellido1.' '.$row->apellido2),1,0,'C');
      $this->pdf->Ln(7);//Realiza un salto de linia de un alto de 7
      // $total+=$row->subValor;
    }
    // Fin tabla numero 2
    /*
     * Se manda el pdf al navegador
     *
     * $this->pdf->Output(nombredelarchivo, destino);
     *
     * I = Muestra el pdf en el navegador
     * D = Envia el pdf para descarga
     *
     */
    $this->pdf->Output(utf8_decode($nombreP).".pdf", 'I');
  }

  // border: solid;
  // background-color: rgb(255, 255, 255);
  public function listaPedidosConfirmar()
  {
    $Pedidos= $this->mPedidos->ConsultarPedidosPorEmpeladoProveedor(0);
    $count=0;
    $tabla='
    <style type="css/text">
      table td{
        text-transform: capitalize;
      }
    </style>
            <TABLE BORDER CELLPADDING=5 CELLSPACING=0>
                <tr>
                 <th align="left";>Empleado</th>
                 <th align="left">Momento</th>
                 <th align="left">Producto</th>
                 <th align="center">Cantidad</th>
                 <th align="left">Nombre de quien recibe</th>
                </tr>';
                $op=0;
    foreach ($Pedidos as $linea) {
      $tabla.='<tr>'.
                '<td>'.$linea->nombre1.' '.$linea->nombre2.' '.$linea->apellido1.' '.$linea->apellido2.'</td>'.
                '<td>'.($linea->momento==1?'Desayuno':'Almuerzo').'</td>'.
                '<td>'.$linea->producto.'</td>'.
                '<td align="center">'.$linea->cantidad.'</td>'.
                '<td></td>'.
              '</tr>';
              $op++;
    }
    $tabla.='</table>';
    // $cant= $this->mPedidos->cantidadLineasPedidoEmpleadoM($lineas->documento);
    // $this->listadoConfirmacionPDF($tabla); 
    echo $tabla;
    // var_dump($tabla); 
  }

  public function listadoConfirmacionPDF($tabla)//Esta funcion esta sin utilizar
  {
        $data = [];

        $hoy = date("dmyhis");

            //load the view and saved it into $html variable
            // $html ='Hola mundo';

            //this the the PDF filename that user will get to download
            $pdfFilePath = "cipdf_.pdf";
     
            //load mPDF library
            $this->load->library('M_pdf');
            // include(APPPATH.'third_party\mpdf\mpdf.php');

            $mpdf = new mPDF(); 

            //generate the PDF from the given html
            $mpdf->SetTitle('Listado de confirmación');
            $mpdf->WriteHTML($tabla);

            //download it.
            $mpdf->Output($pdfFilePath, "D");
     
  }

} //Fin de la clase

// Anterior forma de enviar correos
// public function consultarCorreosProveedor()
//     {
//       $r= $this->mPedidos->consultarCorreosProveedoresM();

//       return $r;
//     }

//     public function consultarNumeroPedidosPorProveedor($idP)
//     {
//       $r= $this->mPedidos->consultarNumeroPedidosPorProveedorM($idP);

//       return $r;      
//     }

//     public function consultarDetallePorProveedorPedido($id1,$id2)
//     {
//       $r= $this->mPedidos->consultarDetallePorProveedorM($id1,$id2);

//       return $r; 
//     }

//     public function enviarCorreroPedidosProveedor()
//     {
//         // Consultar Correos Proveedor
//         $correos= $this->consultarCorreosProveedor();
//         //
//         $total=0;
//         $fechaActual=getdate(); 
//         // 
//         require(APPPATH.'third_party/PHPMail/archivosformulario/class.phpmailer.php'); // Requiere PHPMAILER para poder enviar el formulario desde el SMTP de google
//         //
//         $con=1;
//         $existe=0;
//         $mensaje;
//         $respuesta=0;
//         // Recorres la informacion de los proveedores.
//         foreach ($correos as $row) {
//         $mail = new PHPMailer();

//         $mail->From     = 'jdmarulanda0@misena.edu.co';
//         $mail->FromName = 'Juan David Marulanda'; 
//         $mail->AddAddress($row->email); // Dirección a la que llegaran los mensajes.
//         // 
//         // Aquí van los datos que apareceran en el correo que reciba   
//         $mail->WordWrap = 50; 
//         $mail->IsHTML(true);     
//         $mail->Subject  =  "Colcircuitos S.A.S Pedidos del dia $fechaActual[mday] de $fechaActual[mon] del $fechaActual[year] proveedor: ".$con; // Asunto del mensaje. El asundo no me reconoce las tildes ni la consonante ñ en el asunto.
//           //Generando el cuerpo del mensaje
//           // Consulta de numero de los pedidos
//           $pedidos=$this->consultarNumeroPedidosPorProveedor($row->idProveedor);//Trae el numero del pedido y el nombre del empleado que realizo el pedido el dia en curso.
//           // ...
//           $mensaje='';
//           $con++;
//           foreach ($pedidos as $row1) {
//             //Cabeza de la tabla
//             $existe++;
//             $mensaje.='<TABLE BORDER CELLPADDING=10 CELLSPACING=0>
//                        <tr>
//                          <th COLSPAN=2>N°P '.$row1->idPedido.'</th>
//                          <th COLSPAN=2>'.$row1->nombre1.' '.$row1->nombre2.' '.$row1->apellido1.' '.$row1->apellido2.' '.'</th>
//                        </tr>
//                        <tr>
//                          <th>Producto</th>
//                         <th>Cantidad</th> 
//                          <th COLSPAN=2>Precio</th>
//                        </tr>';
//             //Consultar Detalles pedido, id del proveedor y id del pedido
//             $detalles= $this->consultarDetallePorProveedorPedido($row->idProveedor,$row1->idPedido);
//             $total=0;
//             $op=0;
//             foreach ($detalles as $row2) {
//               //detalles del pedido por empleado.
//               //Cuerpo de la tabla
//               $mensaje.='  <tr>
//                              <td ALIGN=center>'.$row2->nombre.'</td>
//                              <td ALIGN=center>'.$row2->cantidad.'</td> 
//                              <td ALIGN=center COLSPAN=2>'.$row2->precioV.'</td>
//                            </tr>';
//                           if ($op==0) {
//                              $total=$row2->total;
//                              $op=1;
//                           }  
//             }
//             //Pie de la tabla
//             $mensaje.='<tr> 
//                          <th COLSPAN=3>Total</th>
//                          <th >'.$total.'</th>
//                        </tr>
//                      </TABLE><br><br>';
//           }
//       //Cuerpo del mensaje
//        $mail->Body = ($existe>=1?$mensaje:'El día de hoy no se realizaron pedidos para su establecimiento.');
//        $existe=0;
//        // Datos del servidor SMTP, podemos usar el de Google, Outlook, etc...
//        $mail->IsSMTP(); 
//        $mail->Host = "ssl://smtp.gmail.com:465";  // Servidor de Salida. 465 es uno de los puertos que usa Google para su servidor SMTP
//        $mail->SMTPAuth = true; 
//        $mail->Username = "juan.marulanda@colcircuitos.com";  // Correo Electrónico
//        $mail->Password = "mail.col79"; // Contraseña del correo          
//         //Enviar el mensaje
//     if ($mail->Send()){

//     $respuesta=1;
//     $r= $this->mPedidos->registrarEnvioCorreoProveedor($row->idProveedor);
//     }else{

//       $respuesta=0;
//     }
//     // 
//     }
//     if ($existe>0) {
//       echo 1;
//     }
//   }


?>