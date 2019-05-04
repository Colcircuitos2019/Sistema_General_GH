<?php 

/**
* 
*/
class cAsistencia extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
    $this->load->model('Empleado/mAsistencia');
	}

//Retorno de vistas 
  public function index()
  {
      if ($this->session->userdata('tipo_usuario')==false) {
        redirect('cLogin');
      }else{
        $dato['titulo']="Empleados";
        $dato['path']="Empleado/cMenu";
        $dato['tipoUser']=$this->session->userdata('tipo_usuario');
        $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
        //... 
        $this->load->view('Layout/Header1',$dato);
        if ( $dato['tipoUser']==5) {//Gestor humano
          $this->load->view('Layout/MenuLateral');
        }else{//Facilitador
          $this->load->view('Layout/MenuLateral');
        }
        $this->load->view('Empleados/asistencia');
        $this->load->view('Layout/Footer');
        $this->load->view('Layout/clausulas'); 
      }
  }

  public function asistencias()
  {
    //Se valida que en el dispositivo donde se va abrir la pagina tenga permisos en la base de datos
    $res= $this->mAsistencia->consultarPermisoEquipo($_SERVER['REMOTE_ADDR']);
    //...
    if ($res!='0') {
     $this->load->view('asistencia');
    }else{
      echo "<!DOCTYPE html>
      <html>
      <head>
        <title>Acceso denegado</title>
        <link href=\"<?php echo base_url();?>assets/login/images/icons/favicon.ico\" rel=\"icon\" type=\"image/png\"/>
      </head>
      <body style='padding=5em;'>
        <h1>No tienes permiso de ingresar a esta pagina, Sorry ;)</h1>
      </body>
      </html>";
    }
  }

//Metodos
  public function asistenciaPorEmpleado()
  {
    $doc=$this->input->post('documento');
    $op=$this->input->post('op');
    $fecha=$this->input->post('fec');

    $res= $this->mAsistencia->asistenciaPorEmpleadoM($doc,$op,$fecha);

    echo json_encode($res);
  }

  public function horaServidor()
  {
    $hora= $this->mAsistencia->horaServidorM();

    echo json_encode($hora);
  }

  public function asistenciasDiarias()
  {
    $res= $this->mAsistencia->asistenciasDiariasM(0);

    echo json_encode($res);
  }

  public function asistenciasPorFechas()
  {
    $info['Fecha1']=$this->input->post('fecha1');
    $info['Fecha2']=$this->input->post('fecha2');
    $info['doc']=$this->input->post('documento');

    $res=$this->mAsistencia->asistenciasPorFechasM($info);

    echo json_encode($res);
  }

  public function consultarAsistenciaEventoDia()
  {
    $event = $this->input->post("event");

    $result = $this->mAsistencia->consultarAsistenciaEventoDiaM($event);

    echo json_encode($result);
  }

  public function registrarAsistenciaEmpleado()
  {
    $info['contra']=base64_encode($this->input->post('contra'));
    $info['lector']=$_SERVER['REMOTE_ADDR'];// ID del cliente que ingreso a la URL

    // $idHorario=$this->seleccionarIDHorarioEmpelado($info['contra'],1);//Consultar horario del empleado por contraseña unica.
    $idHorario=$this->seleccionarIDHorarioEmpeladoPrueba($info['contra'], 1);//Consultar horario del empleado por contraseña unica.

    if ($idHorario > 0) {

      $info['idHorario']=$idHorario;
      // 
      $documento=$this->mAsistencia->registrarAsistenciaM($info);
      // 
      echo $documento;

    }else{

      echo "-1";

    }
    
  }

  public function modificarAsistenciaEmpleadoManual()
  {
    $v= $this->input->post('info');
    $documento=$this->input->post('documento');
    // ...
    $i=0;
    $horario=0;
    $fecha='';
    $respuesta;
    // ...
    foreach ($v as $asistencia) {
      $respuesta= $this->mAsistencia->modificarAsistenciaEmpleadoManualM($asistencia);
      // ...
      if ($horario==0) {
          $horario=$asistencia['Horario'];//Se asigna el horario...
      }
      // ...
      if ($asistencia['Evento']==1 && $asistencia['HoraFin']!='') {//Evento laboral
          $fecha=$asistencia['HoraFin'];//Cuando sea un evento laboral      
      }
      // ...
      if ($asistencia['HoraInicio']!='' && $asistencia['HoraFin']!='') {
       $i++;//Si al final de recorrer el ciclo esta variable es igual a 3, se calculara el tiempo total laborado...
      }
      // ...
    }
    // ...
    if ($i==3) {//Se va actualizar el tiempo total laboral.
      $respuesta=$this->mAsistencia->actualizarTiempoTotalLaboradoDiaM($documento,$horario,$fecha);
      // var_dump($fecha);
    }
    // var_dump($v);
    echo $respuesta;
  }

  // ...
  public function horarioEmpleadoAsistenciaPermiso()
  {
    $doc=$this->input->post('documento');

    // echo $this->seleccionarIDHorarioEmpelado($doc,0);
    echo $this->seleccionarIDHorarioEmpeladoPrueba($doc,0);
  }

  //... 
  public function diferenciaDeHoras()
  {
    $tiempo=$this->input->post('tiempo');
    $horasA=$this->input->post('horasA');

    echo $this->mAsistencia->diferenciaDeHorasM($tiempo,$horasA);
  }

  // Antes de ejecutar la toma de tiempo se debe ejecutar el buscador del horario que es pertinente para el día en curso.
  public function seleccionarIDHorarioEmpelado($contra,$accion)// Por el momento esta funcion no se va a utilizar
  {
    // accion=1 Consultar por contraseña del empleado
    // accion=0 consulta por el documento del empleado
    $this->load->model('Empleado/mEmpleado_horario');
    //horarios del empleado seleccionado
    $horarios= $this->mEmpleado_horario->consultarDiasHorarioEmpleadoM($contra,$accion);
    // Indice para reiniciar la lectura del vector cuando termine la longitud
    $indice=0;
    $subIndice=0;
    $subIndice2=0;
    // Indice del dia de la semana en curso el cual se va a validar para saber que horario se selecciona.
    $diaCurso= $this->mEmpleado_horario->diaEnCursoM();
    // Vector donde van los indices de los días que fueron seleccionados
    $vEH = array();
    // ...
    $respuesta=0;
    // ...
    foreach ($horarios as $horario) {//Simplificar el proceso de seleeccion del horario del día
      // ...
      if (($horario->diaInicio == $horario->diaFin)) {//Cuando el dia de inicio y fin son iguales

        $respuesta = $horario->idConfiguracion;
        break;

      }elseif ($horario->diaInicio >=0 && $horario->diaFin <= 6 && ($horario->diaFin > $horario->diaInicio)) {
        // echo "2------";
        for ($i = $horario->diaInicio; $i <=$horario->diaFin; $i++) {

          if ($i==$diaCurso) {

            $respuesta=$horario->idConfiguracion;
            break;

          }

        }
      }elseif($horario->diaInicio > $horario->diaFin){//Cuando el dia de inicio es mayor que el día de fin
        // ...
        for ($i=0; $i < 7; $i++) {

          if ($subIndice == 0) {

            $indice = number_format(($horario->diaInicio));
            $subIndice = 1;

          }else{

            $indice++;

          }
          // ...
          if ($indice == $horario->diaFin) {

            array_push($vEH,$indice);
            break;

          }else{

            if ($indice <= 6) {

              array_push($vEH,$indice);

            }else{

              if ($subIndice2==0) {

                $indice=0;
                $subIndice2=1;

              }

              array_push($vEH,$indice);

            }

          }

        }
        // ...
        for ($i=0; $i < count($vEH); $i++) {

          if ($diaCurso == $vEH[$i]) {

            $respuesta=$horario->idConfiguracion;
            break;

          }

        }
        // ...
      } 
    }

    #echo $respuesta;

    return $respuesta;
  }

  // Antes de ejecutar la toma de tiempo se debe ejecutar el buscador del horario que es pertinente para el día en curso.
  public function seleccionarIDHorarioEmpeladoPrueba($contra,$accion)
  {

    // $contra = $_GET['contra'];
    // $accion = $_GET['accion'];
    // accion=1 Consultar por contraseña del empleado
    // accion=0 consulta por el documento del empleado
    $this->load->model('Empleado/mEmpleado_horario');
    //horarios del empleado seleccionado
    $horarios= $this->mEmpleado_horario->consultarDiasHorarioEmpleadoM($contra,$accion);
    // Indice para reiniciar la lectura del vector cuando termine la longitud
    $indice=0;
    $subIndice=0;
    $subIndice2=0;
    // Indice del dia de la semana en curso el cual se va a validar para saber que horario se selecciona.
    $diaCurso = (int)$this->mEmpleado_horario->diaEnCursoM();
    // $diaCurso = 6;
    // Vector donde van los indices de los días que fueron seleccionados
    $vEH = array();
    // ...
    $respuesta=0;
    // ...
    foreach ($horarios as $horario) {//Simplificar el proceso de seleeccion del horario del día
      // ...
      // echo json_encode($horario);
      // echo "<br>";
      // // var_dump(((int)$horario->diaFin));
      // ...
      if (($horario->diaInicio == $horario->diaFin)) {//Cuando el dia de inicio y fin son iguales

        // echo "1";
        $respuesta = $horario->idConfiguracion;
        break;

      }elseif (($diaCurso >= ((int)$horario->diaInicio) && $diaCurso <= ((int)$horario->diaFin)) ||
                ($diaCurso == ((int)$horario->diaInicio) && ((int)$horario->diaFin)) == -1) {// El día en curso esta entre los días estipulados del horario...

        // echo "2";
        $respuesta = $horario->idConfiguracion;
        break;

      }

/*      elseif($horario->diaInicio > $horario->diaFin){//Cuando el dia de inicio es mayor que el día de fin // Por el momento no se va a utilizar esta forma de seleecionar horarios -> Pendiente
        // echo "3";
        // ...
        for ($i=0; $i < 7; $i++) {

          if ($subIndice == 0) {

            $indice = ((int)$horario->diaInicio);
            $subIndice = 1;

          }else{

            $indice++;

          }
          // ...
          if ($indice == $horario->diaFin) {

            array_push($vEH, $indice);
            break;

          }else{

            if ($indice <= 6) {

              array_push($vEH, $indice);

            }else{

              if ($subIndice2==0) {

                $indice=0;
                $subIndice2=1;

              }

              array_push($vEH, $indice);

            }

          }

        }
        // ...
        for ($i=0; $i < count($vEH); $i++) {

          if ($diaCurso == $vEH[$i]) {

            $respuesta = $horario->idConfiguracion;
            break;

          }

        }
        break;
        // ...
      } */

    }

    // echo "<br>";
    // echo $respuesta;

    return $respuesta;
  }

  public function consultarTipoAsistencia()
  {
    $documento= $this->input->post('doc');

    $res= $this->mAsistencia->consultarTipoAsistenciaM($documento);

    echo json_encode($res);
  }

  public function consultarHorasTrabajadasDia()
  {
    $info['documento']=$this->input->post('documento');
    $info['fecha']=$this->input->post('fecha');

    $res=$this->mAsistencia->consultarHorasTrabajadasDiaM($info);

    echo json_encode($res); 
  }

  public function consultarEmpleadosConHorasExtrasAprobar()
  {
    $res=$this->mAsistencia->consultarEmpleadosConHorasExtrasAprobarM();

    echo json_encode($res); 
  }

  public function aceptarHorasExtrarEmpleado()
  {
    $info['documento']=$this->input->post('documento');
    $info['fecha']=$this->input->post('fecha');
    $info['descripcion']=$this->input->post('des');
    $info['index']=$this->input->post('index');
    $info['horasA']=$this->input->post('aceptadas');
    $info['horasR']=$this->input->post('rechazadas');

    $res=$this->mAsistencia->aceptarHorasExtrarEmpleadoM($info);

    echo $res;
  }

  public function CerrarAsistencia()
  {
    $doc=$this->input->post('documento');

    $idHorario=$this->seleccionarIDHorarioEmpelado($doc,0);//Consultar Empleado Por Documento de identidad.

    var_dump($idHorario);

    if ($idHorario>0) {
      // ...
      $res= $this->mAsistencia->CerrarAsistenciaM($doc,$idHorario);

      echo $res;
    }else{
      echo "-1";//No tiene un horario asignado
    }
  }

  public function generarPDFAsistencias()
  {
    //Captura de la variable GET 
    // $documento=$_GET['doc'];
    // Llamado de la libreria
    $this->load->library('PDFA');
    $this->load->model('Empleado/mEmpleado');
    // Creacion del PDF
    /*
     * Se crea un objeto de la clase Pdf, recuerda que la clase Pdf
     * heredó todos las variables y métodos de fpdf
     */
    $this->pdf = new pdfa();
    // Agregamos una página
    $this->pdf->AddPage();
    // Define el alias para el número de página que se imprimirá en el pie
    $this->pdf->AliasNbPages();
    /* Se define el titulo, márgenes izquierdo, derecho y
     * el color de relleno predeterminado
     */
    $this->pdf->SetTitle("Asistencias");
    $this->pdf->SetLeftMargin(10);
    $this->pdf->SetRightMargin(10);
    $this->pdf->SetFillColor(130, 130, 130);
     // Inicio de la tabla 1
    // Se define el formato de fuente: Arial, negritas, tamaño 12
    $this->pdf->SetFont('Arial', 'B', 10);
    /*
     *
     *
     * $this->pdf->Cell(Ancho, Alto,texto,borde,posición,alineación,relleno);
     */
    $piso=0;
    // var_dump(isset($_GET['piso']));
    if (isset($_GET['piso'])) {
      $piso=$_GET['piso'];
    }
    // Cabeza de la tabla de pedidos por producto y por proveedor
    $empleados=$this->mAsistencia->asistenciasDiariasM($piso);
    // 
    $this->pdf->Cell(35,7,'Documento',1,0,'C','1');//Numero de documento
    $this->pdf->Cell(80,7,'Nombre Empleado',1,0,'C','1');//Nombre del empleado
    $this->pdf->Cell(50,7,'Asistencia',1,0,'C','1');//Asistencia
    $this->pdf->Cell(20,7,'Piso',1,0,'C','1');//Piso
    $this->pdf->Ln(9);//salto de linea
    $count=0;
    // ...
    foreach ($empleados as $row) {
      $this->pdf->Cell(35,7,utf8_decode($row->documento),0,0,'L','0');//Numero de documento
      $this->pdf->Cell(80,7,ucfirst(strtolower(utf8_decode($row->nombre1.' '.$row->nombre2.' '.$row->apellido1.' '.$row->apellido2))),0,0,'L','0');//Nombre del empleado
      if (number_format($row->asistencia)==1) {
         $this->pdf->SetFillColor(0, 168, 0);//Verde
      }else{
         $this->pdf->SetFillColor(251, 0, 0);//Rojo
      }
      $this->pdf->Cell(50,7,($row->asistencia=='1'?'Presente':'Ausente'),0,0,'C','1');//Asistencia
      $this->pdf->Cell(20,7,utf8_decode($row->piso),0,0,'C','0');//Piso
      $this->pdf->Ln(8);
      $count++;
    }
    $this->pdf->Ln(5);
    // Totalizar los empleados
    $this->pdf->Cell(130,7,'Total Empleados: '.$count,0,0,'C','0');//Total empleados

    /*
     * Se manda el pdf al navegador
     *
     * $this->pdf->Output(nombredelarchivo, destino);
     *
     * I = Muestra el pdf en el navegador
     * D = Envia el pdf para descarga
     *
     */
    $this->pdf->Output(utf8_decode('Asistencia Empleados').".pdf", 'I');
  }

    public function generarLiquidacionTiempos()
    {
      $this->load->model('Empleado/mHistorial');

          // Se inicializa la hoja de Excel
          require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
          require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

          $objExcel= new PHPExcel();
          
          $objExcel->getProperties()->setCreator("");
          $objExcel->getProperties()->setLastModifiedBy("");
          $objExcel->getProperties()->setTitle("");
          $objExcel->getProperties()->setSubject("");
          $objExcel->getProperties()->setDescription("");

          $objExcel->setActiveSheetIndex(0);

          $estilo = array( 
            'borders' => array(
              'outline' => array(
                'style' => PHPExcel_Style_Border::BORDER_THIN
              )
            )
          );
        // ...
        // Obtener las fechas------------------------------------------>

        $info['fechaI']=$_GET['fecha1'];
        $info['fechaF']=$_GET['fecha2'];

        // Header del Excel-------------------------------------------->

        // Fecha Inicio
        $objExcel->getActiveSheet()->setCellValue('B2','Fecha Inicio');
        // Fecha de Fin
        $objExcel->getActiveSheet()->setCellValue('C2','Fecha Fin');
        // Fecha Inicio 
        $objExcel->getActiveSheet()->setCellValue('B3',$info['fechaI']);
        // Fecha de Fin
        $objExcel->getActiveSheet()->setCellValue('C3',$info['fechaF']);
        // Numero de documento
        $objExcel->getActiveSheet()->setCellValue('B4','Documento');
        // Empleado
        $objExcel->getActiveSheet()->setCellValue('C4','Nombre empleado');
        // Empresa
        $objExcel->getActiveSheet()->setCellValue('D4','Empresa');
        // Tiempo Total trabajado
        $objExcel->getActiveSheet()->setCellValue('E4','Tiempo Total Trabajado');
        // Negrilla todo el header de la tabla
        // $objExcel->getActiveSheet()->getStyle('B2:')->getFont()->setBold(true);
        // 
        $info['evento']= 1;// 1= Horas trabajadas Normales o 2=Horas trabajadas extras
        $info['estado']= 1;// 1= Horas aprovadas o 0= Horas no aprobadas

      // Consultar todos los empleados
      $empleados= $this->mAsistencia->consultarDocumentoEmpleadosM();

      $i=5;

      foreach ($empleados as $empleado) {//Se van a sumar las horas normales trabajadas y las horas extras
        //Documento
        $objExcel->getActiveSheet()->setCellValue('B'.$i,$empleado->documento);
        // Empleado
        $objExcel->getActiveSheet()->setCellValue('C'.$i,$empleado->nombre1.' '.$empleado->nombre2.' '.$empleado->apellido1.' '.$empleado->apellido2);
        // Empresa
        $objExcel->getActiveSheet()->setCellValue('D'.$i,$empleado->empresa);

        // ...
          $info['documento']= $empleado->documento; 
          // Consutal total de horas trabajadas normales
          $nHoras= $this->mHistorial->totalHorasTrabajadasNormalesM($info);
          // Sumar tiempo total horas normales trabajas
          $totalTiempoNormal= $this->sumarHorasLaborales($nHoras);
          // var_dump($totalTiempoNormal);
          // ...
          // Consutal total de horas trabajadas extras
          $info['evento']= 2;
          // ...
          $nHoras= $this->mHistorial->totalHorasTrabajadasNormalesM($info);
          // Sumar tiempo total horas normales trabajas
          $totalTiempoExtra= $this->sumarHorasLaborales($nHoras);
          // var_dump($totalTiempoExtra);
          // ...
          $horas['horaT']=$totalTiempoNormal;
          $horas['horaS']=$totalTiempoExtra;
          // ...
          $totalTiempo=$this->mHistorial->sumarTiemposHorasLaboralesM($horas);
          $info['evento']= 1;// 1= Horas trabajadas Normales o 2=Horas trabajadas extras
          // Tiempo Total trabajado
          $objExcel->getActiveSheet()->setCellValue('E'.$i,$totalTiempo);
          // Ingremento de posición de la fila
          $i++;
      }
      // Footer de la configuracion del excel
      $objExcel->getActiveSheet()->getStyle('B2:E'.($i-1))->applyFromArray($estilo);

      $fileName= "Reporte Tiempo Laboral".date("Y-m-d h:i:s").'xlsx';
      $objExcel->getActiveSheet()->setTitle('Horas Laborales');

      header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      header('Content-Diposition: attachment;filiname="'.$fileName.'"');
      header('Cache-Control: max-age=0');

      $write= PHPExcel_IOFactory::createWriter($objExcel,'Excel2007');
      $write->save('php://output');
   
    }

    public function sumarHorasLaborales($horas)//Calcular total de horas trabajadas (Normales o extra laborales)...
    {
      $total='00:00:00';
      // ...
      foreach ($horas as $hora) {
        // ...
        $info['horaT']=$total;
        $info['horaS']=$hora->numero_horas;
        // ...
        $total=$this->mHistorial->sumarTiemposHorasLaboralesM($info);
        // ...
      }
      // ...
      return $total;
    }

}