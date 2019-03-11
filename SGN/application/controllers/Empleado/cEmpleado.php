<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
 /**
 * 
 */
 class cEmpleado extends CI_Controller 
 {
 	
 	function __construct()
 	{
 		    parent::__construct();
 		    $this->load->model('Empleado/mEmpleado');
 	}


//retorno de vistas
 	public function index()
 	{   //$this->load->view('login.php');
    if ($this->session->userdata('tipo_usuario')==false) {
      redirect('cLogin');
    }else{
        $dato['titulo']="Empleados";
        $dato['path']="Empleado/cMenu";
        $dato['tipoUser']=$this->session->userdata('tipo_usuario');
        $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
        //...
        $this->load->model('Empleado/FichaSDG/mConfiguracionFicha');
        $info2['manufacturas']=$this->mConfiguracionFicha->consultarInformacionM(2,9);
        //... 
        $this->load->view('Layout/Header1',$dato);
        $this->load->view('Layout/MenuLateral');
        $this->load->view('Empleados/Empleado',$info2);
        $this->load->view('Layout/Footer');
        $this->load->view('Layout/clausulas');  
    }  
 	}

//Metodos
    public function validarDocumento()
    {
        $datos['documento']=$this->input->post('documento');

        $op=$this->mEmpleado->validarDocumentoEmpleado($datos['documento']);

        echo $op;//False= Se puede registrar, True=No se puede registrar
    }
// Esta funcion esta pendiente por utilizar, se implementara cuando se implemente lo de las huellas
    public function validarHuellas()
    {
            $huellas['huella1']=$this->input->post('huella1');
            $huellas['huella2']=$this->input->post('huella2');
            $huellas['huella3']=$this->input->post('huella3');
            $op=$this->mEmpleado->validarHuellasEmpleado($huellas);

            echo $op;
    }

    public function actualizaC()
    {
      $empelados= $this->mEmpleado->consultarEmpleadosM('');

      foreach ($empelados as $empleado) {
        // ...
        $info['documento']=$empleado->documento;
        $info['contra']=base64_encode($empleado->contra);
        // ...
        $this->mEmpleado->actualizaCM($info);
        // ...
      } 
       echo 1;
    }

    public function validarExistenciaContra()
    {
      $info['documento']= $this->input->post('doc');
      $info['contra']= base64_encode($this->input->post('contra'));

      $res=$this->mEmpleado->validarExistenciaContraM($info);

      echo $res;
    }

//Retorno de procedimientos o funciones
    public function insertarModificarEmpleado(){
      //La restriccion de campos unicos en la base de datos de la tabla empleados va a ser removida momentaniamente mientras se registran los datos de cada persona
    	//registro o modificacion
        // existe se sigue con el registro del empleado
                $datos['documento']=$this->input->post('documento');
 		    		    $datos['nombre1']=$this->input->post('nombre1');
 		            $datos['nombre2']=$this->input->post('nombre2');
 		            $datos['apellido1']=$this->input->post('apellido1');
 		            $datos['apellido2']=$this->input->post('apellido2');
 		            $datos['genero']=$this->input->post('genero');
 		            $datos['huella1']=$this->input->post('huella1');
 		            $datos['huella2']=$this->input->post('huella2');
 		            $datos['huella3']=$this->input->post('huella3');
 		            $datos['correo']=$this->input->post('correo');
 		            $datos['contraseña']=base64_encode($this->input->post('contra'));
 		            $datos['idEmpresa']=$this->input->post('idEmpresa');
                $datos['idRol']=$this->input->post('rol');
                $datos['piso']=$this->input->post('piso');
                $datos['fecha_expedicion']=$this->input->post('fechaExpedi');
                $datos['lugar_expedicion']=$this->input->post('lugarExpedi');
                $datos['idManufactura']= $this->input->post('manufactura');
                $datos['estado']= -1;
                // $datos['fecha_registro']='(SELECT CURDATE())';
                $op=$this->input->post('accion');
 		            //Ejecucion de la funcion de registro
 		            $res= $this->mEmpleado->registrar_Modificar_EmpleadoM($datos,$op);

 		            echo $res;
                // echo base64_encode($this->input->post('contra'));
 	}

    public function consultarEmpleados()
    {
        $doc=$this->input->post('doc');

        $res= $this->mEmpleado->consultarEmpleadosM($doc);

        echo json_encode($res);
    }

    public function consultarEmpleadosPermiso()
    {

        $res= $this->mEmpleado->consultarEmpleadosPermisoM();

        echo json_encode($res);
    }

    public function eliminarEmpleado()
    {
        $doc=$this->input->post('docu');

        $res= $this->mEmpleado->eliminarEmpleadoM($doc);

        echo $res;
    }
// Se encarga de generar un reporte de todos los empelados de la empresa.
  public function reporteEmpelados()
  {
    $res= $this->mEmpleado->reporteEmpleadosM();  

    
    $arr=json_encode($res);//Convertimos el resulset en un string formato json

    $this->excelEmpleados(json_decode($arr));//Enviamos el json de nuevo pero lo transformamos en un array de json para facilitar su lectura

  }

    public function excelEmpleados($datos)
    { 
      // echo "<pre>";
      // print_r($datos);
      // echo "</pre>";
      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
      require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

      $objPHPExcel= new PHPExcel();

      $objPHPExcel->getProperties()->setCreator("");
      $objPHPExcel->getProperties()->setLastModifiedBy("");
      $objPHPExcel->getProperties()->setTitle("");
      $objPHPExcel->getProperties()->setSubject("");
      $objPHPExcel->getProperties()->setDescription("");


      $objPHPExcel->setActiveSheetIndex(0);

    $objPHPExcel->getActiveSheet()->SetCellValue('A2','Documento');
    $objPHPExcel->getActiveSheet()->SetCellValue('B2','Fecha de expedición');
    $objPHPExcel->getActiveSheet()->SetCellValue('C2','Lugar de expedición');
    $objPHPExcel->getActiveSheet()->SetCellValue('D2','Nombre 1');
    $objPHPExcel->getActiveSheet()->SetCellValue('E2','Nombre 2');
    $objPHPExcel->getActiveSheet()->SetCellValue('F2','Apellido 1');
    $objPHPExcel->getActiveSheet()->SetCellValue('G2','Apellido 2');
    $objPHPExcel->getActiveSheet()->SetCellValue('H2','Genero');
    $objPHPExcel->getActiveSheet()->SetCellValue('I2','Correro');
    $objPHPExcel->getActiveSheet()->SetCellValue('J2','Empresa');
    $objPHPExcel->getActiveSheet()->SetCellValue('K2','Rol');
    $objPHPExcel->getActiveSheet()->SetCellValue('L2','Estado');        
    $objPHPExcel->getActiveSheet()->SetCellValue('M2','Piso');        
    $objPHPExcel->getActiveSheet()->SetCellValue('N2','Manufactura');        

    $i=3;

    foreach ($datos as $row) {
        $objPHPExcel->getActiveSheet()->SetCellValue('A'.$i, $row->documento);
        $objPHPExcel->getActiveSheet()->SetCellValue('B'.$i, $row->fecha_expedicion);
        $objPHPExcel->getActiveSheet()->SetCellValue('C'.$i, $row->lugar_expedicion);
        $objPHPExcel->getActiveSheet()->SetCellValue('D'.$i, $row->Primer_Nombre);
        $objPHPExcel->getActiveSheet()->SetCellValue('E'.$i, $row->Segundo_Nombre);
        $objPHPExcel->getActiveSheet()->SetCellValue('F'.$i,$row->Primer_Apellido);
        $objPHPExcel->getActiveSheet()->SetCellValue('G'.$i,$row->Segundo_Apellido);
        $objPHPExcel->getActiveSheet()->SetCellValue('H'.$i,$row->genero);
        $objPHPExcel->getActiveSheet()->SetCellValue('I'.$i,$row->correo);
        $objPHPExcel->getActiveSheet()->SetCellValue('J'.$i,$row->empresa);
        $objPHPExcel->getActiveSheet()->SetCellValue('K'.$i,$row->rol);
        $objPHPExcel->getActiveSheet()->SetCellValue('L'.$i,$row->Estado);   
        $objPHPExcel->getActiveSheet()->SetCellValue('M'.$i,$row->piso);   
        $objPHPExcel->getActiveSheet()->SetCellValue('N'.$i,$row->manufactura);   
       $i++;      
      }

    $filiname="ReporteEmpelados-".date("Y-m-d h:i:s").'xlsx';
    $objPHPExcel->getActiveSheet()->setTitle("Empelados");
    //Configuracion para la descarga
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Diposition: attachment;filiname="'.$filiname.'"');
    header('Cache-Control: max-age=0');

    $write= PHPExcel_IOFactory::createWriter($objPHPExcel,'Excel2007');
    $write->save('php://output');

    exit;

    }

    public function desEncryptar()
    {
      $contra= $this->input->post('contra');

      echo base64_decode($contra);
    }

  // public function generarExcelEmpleados()
  //   {
  // $this->excel->setActiveSheetIndex(0);
  // //name the worksheet
  // $this->excel->getActiveSheet()->setTitle('Informe');
  // //set cell A1 content with some text
  // $this->excel->getActiveSheet()->setCellValue('A1','Celda1');
  // // $this->excel->getActiveSheet()->getStyle('A1')->getFont()->setBold(true);
  // // $this->excel->getActiveSheet()->getStyle('A1')->getFont()->setSize(10);
  
  // $filename="nombre.xls"; //save our workbook as this file name
  // header("Content-type: application/vnd-ms-excel; charset=iso-8859-1"); //mime type
  // header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
  // header('Cache-Control: max-age=0'); //no cache
  //       // $this->excel->setActiveSheetIndex(0);
  //       // $this->excel->getActiveSheet()->setTitle('test worksheet');
  //       // $this->excel->getActiveSheet()->setCellValue('A1', 'Un poco de texto');
  //       // $this->excel->getActiveSheet()->getStyle('A1')->getFont()->setSize(20);
  //       // $this->excel->getActiveSheet()->getStyle('A1')->getFont()->setBold(true);
  //       // $this->excel->getActiveSheet()->mergeCells('A1:D1');
 
  //       // header('Content-Type: application/vnd.ms-excel');
  //       // header('Content-Disposition: attachment;filename="nombredelfichero.xlsx"');
  //       // header('Cache-Control: max-age=0'); //no cache
  //       // $objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');
  //       // // Forzamos a la descarga
  //       // $objWriter->save('php://output');        
  //      // $res= $this->mEmpleado->consultarEmpleadosM('');
  //      // $fila=2;

  //      //  $objPHPExcel= new PHPExcel();
  //      //  $objPHPExcel->getProperties->setCreator('Codigos de Programacion');
  //      //  $objPHPExcel->setActiveSheetIndex(0);
  //      //  $objPHPExcel->getActiveSheer()->setTitle("Empleados");
  //      //  //Encabezados
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('A1','Documento');
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('B1','Primer nombre');
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('C1','Segundo nombre');
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('D1','Primer apellido');
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('E1','Segundo apellido');
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('F1','Genero');
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('G1','Estado');

  //      //  while ($row=$re->fetch_assoc()) {
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('A'.$fila,$row['documento']);
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('B'.$fila,$row['nombre1']);
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('C'.$fila,$row['nombre2']);
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('D'.$fila,$row['apellido1']);
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('E'.$fila,$row['apellido2']);
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('F'.$fila,$row['genero']);
  //      //  $objPHPExcel->getActiveSheet()->setCellValue('G'.$fila,$row['estado']);

  //      //  $fila++;
  //      //  }
  //      //  header("content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
  //      //  header('Content-Disposition: attachment;filename="Empelados.xlsx"');
  //      //  header('Cache-Control:max-age=0');

  //      //  $objWriter=new PHPExcel_Writer_Excel12007($objPHPExcel);
  //      //  $objWriter->save('php://output');

  //   }
    
    public function importarEmpelados()
    {
      require_once(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
      $v=array();
      $i=0;
      header("Content-Type: text/html;charset=utf-8");
      if (isset($_FILES['empleado']['name'])) {
        $path= $_FILES['empleado']['tmp_name'];
        $object= PHPExcel_IOFactory::load($path);

        foreach ($object->getWorksheetIterator() as $workSheet) {
          $highestRow = $workSheet->getHighestRow();
          $highestColumn= $workSheet->getHighestColumn();
          if ($workSheet->getCellByColumnAndRow(0,2)->getValue()=='Documento' && $workSheet->getCellByColumnAndRow(12,2)->getValue()=='Piso') {
            $i=1;
            for ($row=3; $row <=$highestRow; $row++) { 
              $empleado['documento']= $workSheet->getCellByColumnAndRow(0,$row)->getValue();
              $empleado['fecha_expedicion']= ($workSheet->getCellByColumnAndRow(1,$row)->getFormattedValue()==null?'':$workSheet->getCellByColumnAndRow(1,$row)->getFormattedValue());
              $empleado['lugar_expedicion']= ($workSheet->getCellByColumnAndRow(2,$row)->getValue()==null?'':$workSheet->getCellByColumnAndRow(2,$row)->getValue());
              $empleado['nombre1']= $workSheet->getCellByColumnAndRow(3,$row)->getValue();
              $empleado['nombre2']= $workSheet->getCellByColumnAndRow(4,$row)->getValue();
              $empleado['apellido1']= $workSheet->getCellByColumnAndRow(5,$row)->getValue();
              $empleado['apellido2']= $workSheet->getCellByColumnAndRow(6,$row)->getValue();
              $genero=$workSheet->getCellByColumnAndRow(7,$row)->getValue();
              $empleado['genero']= ($genero=='Femenino'?0:1);
              $empleado['correo']= $workSheet->getCellByColumnAndRow(8,$row)->getValue();
              $empleado['idEmpresa']= $workSheet->getCellByColumnAndRow(9,$row)->getValue();
              // var_dump(is_string($empleado['idEmpresa']));
              $empleado['huella1']= 0;
              $empleado['huella2']= 0;
              $empleado['huella3']= 0;
              // $empleado['contraseña']= $this->contraseñaAleatoria();
              $empleado['contraseña']="";
              $Rol= $workSheet->getCellByColumnAndRow(10,$row)->getValue();
              $empleado['idRol']= ($Rol=='Administrativo'?2:1);
              $estado= $workSheet->getCellByColumnAndRow(11,$row)->getValue();
              $empleado['estado']= ($estado=='Activo'?1:0);
              $empleado['piso']= $workSheet->getCellByColumnAndRow(12,$row)->getValue();
              $empleado['fecha_registro']= 'CURDATE()';
              $empleado['idManufactura']= $workSheet->getCellByColumnAndRow(13,$row)->getValue();
              // ...
              // array_push($v,$empleado);
              $this->mEmpleado->registrar_Modificar_EmpleadoM($empleado,0);
            }
          }else{
            $i=0;
          }
        }
        // echo var_dump($v);
      }
      echo $i;
    }

    public function consultarRoles()
    {
      $res=$this->mEmpleado->consultarRolesM();

      echo json_encode($res);
    }

    public function reporteEmpleados()
    {
      $result=$this->mEmpleado->reporteEmpleadosM();
      $this->export_excel->to_excel($result,'Lista_Empleados');

    }

    public function contraseñaAleatoria()
    {
       $pass=substr(md5(microtime()), 1, 4);
       return $pass;
    }

 }
 	
 
 ?>