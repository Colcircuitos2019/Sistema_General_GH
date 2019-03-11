<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class cIncapacidades extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mIncapacidades');
	}

	public function index()
	{	
        if ($this->session->userdata('tipo_usuario')==false) {
          redirect('cLogin');
        }else{
            //...
            $dato['titulo']="Empleados";
            $dato['path']="Empleado/cMenu";
            $dato['tipoUser']=$this->session->userdata('tipo_usuario');
            $dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');;        
            //...
            $datos['diagnosticos']= $this->consultarDiagnosticosInc();
            $datos['empleados']= $this->consultarEmpleadosInc();
            //... 
            $this->load->view('Layout/Header1',$dato);
            $this->load->view('Layout/MenuLateral');
            $this->load->view('Empleados/Incapacidades',$datos);
            $this->load->view('Layout/Footer');
            $this->load->view('Layout/clausulas'); 
        }
	}

	public function consultarIncapacidades()
	{
		$id=$this->input->post('idInc');

		$res=$this->mIncapacidades->IncapacidadesM($id);

		echo json_encode($res);
	}

	public function consultarEmpleadosInc()
	{
		$this->load->model('Empleado/mEmpleado');

		return $this->mEmpleado->consultarEmpleadosM('-1');//Consulta solo los empleados que tengas una ficha SDG previamente registrada
	}

    public function incapacidadesEmpleadosRangoFechas()
    {
        $info['documento']= $this->input->post('documento');
        $info['fechaI']= $this->input->post('fechaI');
        $info['fechaF']= $this->input->post('fechaF');

        $result=$this->mIncapacidades->incapacidadesEmpleadosRangoFechasM($info);

        echo json_encode($result);
    }

	public function consultarDiagnosticosInc()
	{
		$this->load->model('Empleado/mDiagnostico');

		return $this->mDiagnostico->ConsultarDiagnosticosM(0);
	}

	public function registrarModificarIncapacidades()
	{
		$info['accion']= $this->input->post('accion');
		$info['inc']= $this->input->post('idIncapacidad');
		$info['empleado']= $this->input->post('empleado');
		$info['fechaI']= $this->input->post('fechaI');
		$info['fechaF']= $this->input->post('fechaF');
        $info['valorEPS']= $this->input->post('valorEPS');
        $info['valorARL']= $this->input->post('valorARL');
        $info['valorEmpresa']= $this->input->post('valorEmpresa');
		$info['valorT']= $this->input->post('valorTotal');
		$info['diagnostico']= $this->input->post('diagnostico');
		$info['dias']= $this->input->post('dias');
		$info['descripcion']= $this->input->post('descripcion');
		$info['idTipoIncapacidad']= $this->input->post('idTipoI');
        $info['idEnfermedad']= $this->input->post('idEnf');
		$info['Diferencia']= $this->input->post('diff');

		$res= $this->mIncapacidades->registrarModificarIncapacidadesM($info);

		echo $res;
	}

    public function modificarReintregoIncapacidad()
    {
       $info['idInc']= $this->input->post('idI');
       $info['Reintegro']= $this->input->post('reintegro');
       $info['diferencia']= $this->input->post('diferencia');

       $res= $this->mIncapacidades->modificarReintregoIncapacidadM($info);

       echo $res;
    }

	public function eliminarIncapacidad()
	{
		$id=$this->input->post('idInc');

		$res= $this->mIncapacidades->eliminarIncapacidadM($id);

		echo $res;
	}

	public function incapacidadesParaExcel()
	{
		return $this->mIncapacidades->incapacidadesParaExcelM();
	}

	public function descargarIncapacidadesExcel()
	{
		require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
        require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

        $objExcel= new PHPExcel();
        
        $objExcel->getProperties()->setCreator("");
        $objExcel->getProperties()->setLastModifiedBy("");
        $objExcel->getProperties()->setTitle("");
        $objExcel->getProperties()->setSubject("");
        $objExcel->getProperties()->setDescription("");

        $objExcel->setActiveSheetIndex(0);

        $datos=$this->incapacidadesParaExcel();

        $estilo = array( 
          'borders' => array(
            'outline' => array(
              'style' => PHPExcel_Style_Border::BORDER_THIN
            )
          )
        );
        // Numero de documento
        $objExcel->getActiveSheet()->setCellValue('B2','Documento');
        // Empleado
        $objExcel->getActiveSheet()->setCellValue('C2','Nombre empleado');
        // Empresa
        $objExcel->getActiveSheet()->setCellValue('D2','Empresa');
        // Diagnostico
        $objExcel->getActiveSheet()->setCellValue('E2','Diagnostico');
        // Valor que responde la empresa
        $objExcel->getActiveSheet()->setCellValue('F2','Valor de empresa');
        // Valor que responde la EPS
        $objExcel->getActiveSheet()->setCellValue('G2','Valor de EPS');
        // Valor que responde el ARL
        $objExcel->getActiveSheet()->setCellValue('H2','Valor de ARL');
        // Valor Total del descuento
        $objExcel->getActiveSheet()->setCellValue('I2','Total');
        // Valor total Pagado por EPS o ARL
        $objExcel->getActiveSheet()->setCellValue('J2','Reintegro');
        // Valor de Diferencia por la EPS o ARL
        $objExcel->getActiveSheet()->setCellValue('K2','Diferencia');
        // Fecha de incapacidad
        $objExcel->getActiveSheet()->setCellValue('L2','Fecha de incapacidad');
        // Dia incapacidad
        $objExcel->getActiveSheet()->setCellValue('M2','Día incapacidad');
        // Fecha fin de incapacidad
        $objExcel->getActiveSheet()->setCellValue('N2','Fecha fin de incapacidad');
        // Dia incapacidad
        $objExcel->getActiveSheet()->setCellValue('O2','Día incapacidad');
        // Dias de incapacidad
        $objExcel->getActiveSheet()->setCellValue('P2','Dias');
        // Tipo Incapacidad
        $objExcel->getActiveSheet()->setCellValue('Q2','Tipo de incapacidad');
        // Enfermedad
        $objExcel->getActiveSheet()->setCellValue('R2','Clasificación');
        // Quien cubre la incapacidad
        $objExcel->getActiveSheet()->setCellValue('S2','Quien cubre la incapacidad');
        // Descripcion 
        $objExcel->getActiveSheet()->setCellValue('T2','Descripción');
        // Negrilla todo el header de la tabla
        $objExcel->getActiveSheet()->getStyle('B2:T2')->getFont()->setBold(true);
        // 
        $i=3;
        foreach ($datos as $row) {
        	$objExcel->getActiveSheet()->setCellValue('B'.$i,$row->documento);
        	// Empleado
        	$objExcel->getActiveSheet()->setCellValue('C'.$i,$row->nombre1.' '.$row->nombre2.' '.$row->apellido1.' '.$row->apellido2.' ');
        	// Empresa
        	$objExcel->getActiveSheet()->setCellValue('D'.$i,$row->nombre);
        	// Diagnostico
        	$objExcel->getActiveSheet()->setCellValue('E'.$i,$row->diagnostico);
            // Valor de la empresa
            $objExcel->getActiveSheet()->setCellValue('F'.$i, ($row->valor_empresa==''?'-':"$".$row->valor_empresa));
            // Valor de la EPS
            $objExcel->getActiveSheet()->setCellValue('G'.$i,($row->valor_eps==''?'-':"$".$row->valor_eps));
            // Valor del ARL
            $objExcel->getActiveSheet()->setCellValue('H'.$i,($row->valor_arl==''?'-':"$".$row->valor_arl));
        	// Valor total del descuento
        	$objExcel->getActiveSheet()->setCellValue('I'.$i,"$".$row->valor_descuento);
            // Valor Total del reintegro
            $objExcel->getActiveSheet()->setCellValue('J'.$i,($row->reintegro==''?'-':"$".$row->reintegro));
            // Valor total de diferencia
            $objExcel->getActiveSheet()->setCellValue('K'.$i,($row->diferencia==''?'-':"$".$row->diferencia));
        	// Fecha de incapacidad
            $objExcel->getActiveSheet()->setCellValue('L'.$i,$row->fecha_incapacidad);
            // Dia semana de la fecha de incapacidad
        	$objExcel->getActiveSheet()->setCellValue('M'.$i,$this->diaDeLaSemana($row->diaSemanaI));
        	// Fecha fin de incapacidad
            $objExcel->getActiveSheet()->setCellValue('N'.$i,$row->fecha_fin_incapacidad);
            // Dia semana de fecha fin de la incapacidad
        	$objExcel->getActiveSheet()->setCellValue('O'.$i,$this->diaDeLaSemana($row->diaSemanaF));
        	// Dias de incapacidad
        	$objExcel->getActiveSheet()->setCellValue('P'.$i,$row->dias);
        	// Tipo Incapacidad
        	$objExcel->getActiveSheet()->setCellValue('Q'.$i,($row->idTipoIncapacidad==1?'General':($row->idTipoIncapacidad==2?'Trabajo':'Licencia M/P')));
        	// Enfermedad
        	$objExcel->getActiveSheet()->setCellValue('R'.$i,($row->idEnfermedad==1?'Inicial':'Prorroga'));
            // Descripción
            $objExcel->getActiveSheet()->setCellValue('T'.$i,$row->descripcion);
            //  Quien cubre la incapacidad
            switch ($row->idTipoIncapacidad) {
                case 1:
                    if ($row->dias<=2) {
                       // Lo cubre todo la empresa
                       $objExcel->getActiveSheet()->setCellValue('S'.$i,'La empresa');
                    }else if($row->dias>=3){
                       // Lo cubre una parte la empresa y otra la EPS
                       $objExcel->getActiveSheet()->setCellValue('S'.$i,'La empresa y la EPS');
                    }
                    break;
                case 2:
                    // Lo cubre la ARL por completo
                    $objExcel->getActiveSheet()->setCellValue('S'.$i,'La ARL');
                    break;
                case 3:
                    // Lo cubre la EPS por completo
                    $objExcel->getActiveSheet()->setCellValue('S'.$i,'La EPS');
                    break;    
            }

        	$i++;//Incremento
        }

        $objExcel->getActiveSheet()->getStyle('B2:T'.($i-1))->applyFromArray($estilo);

        $fileName= "Reporte_Incapacidades".date("Y-m-d h:i:s").'xlsx';
        $objExcel->getActiveSheet()->setTitle('Incapacidades');

        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Diposition: attachment;filiname="'.$fileName.'"');
        header('Cache-Control: max-age=0');

        $write= PHPExcel_IOFactory::createWriter($objExcel,'Excel2007');
        $write->save('php://output');

	}

    public function diaDeLaSemana($dia)
    {
        $diaSeman='';
        switch (number_format($dia)) {
            case 1: //Lunes Monday
                $diaSeman='Lunes';
                break;
            case 2:// Martes Tuesday
                $diaSeman='Martes';
                break;
            case 3://Miercoles Wednesday
                $diaSeman='Miercoles';
                break;
            case 4://Jueves Thursday
                $diaSeman='Jueves';
                break;
            case 5://viernes Friday
                $diaSeman='Viernes';
                break;
            case 6: //Sabado Saturday
                $diaSeman='Sabado';
                break;
            case 0: //Domingo Sunday
                $diaSeman='Domingo';
                break;
        }
        return $diaSeman;
    }
}

 ?>
