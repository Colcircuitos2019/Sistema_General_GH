<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class cExamenes extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mExamenes');
	}

	public function index()
	{	
		$this->load->model('Empleado/mEmpleado');

		$datos['empleados']=$this->mEmpleado->consultarEmpleadosM('');

		if ($this->session->userdata('tipo_usuario')==false) {
		  redirect('cLogin');
		}else{
			$dato['titulo']="Empleados";
			$dato['path']="Empleado/cMenu";
			$dato['tipoUser']=$this->session->userdata('tipo_usuario');
			$dato['tipoUserName']=$this->session->userdata('tipo_usuario_name');
		  	//... 
		  	$this->load->view('Layout/Header1',$dato);
		  	$this->load->view('Layout/MenuLateral');
		  	$this->load->view('Empleados/ExamenesM',$datos);
		  	$this->load->view('Layout/Footer');
		  	$this->load->view('Layout/clausulas');  	
		}
	}

	public function registrarModificarEliminarCRUD()
	{
	 	$info['idExamen']= $this->input->post('idEX');
	 	$info['documento']= $this->input->post('empleado');
	 	$info['tipoExamen']= $this->input->post('tipoEX');
	 	$info['OtroExamen']= $this->input->post('otroEX');
	 	$info['Motivo']= $this->input->post('motivo');
	 	$info['FechaPlazo']= $this->input->post('fechaP');
	 	$info['FechaRetorno']= $this->input->post('fechaR');
	 	$info['Estado']= $this->input->post('estado');

	 	$res= $this->mExamenes->registrarModificarEliminarCRUDM	($info);

	 	echo $res;
	}

	public function consultarExamenes()
	{
		$idEx= $this->input->post('idExam');

		$result=$this->mExamenes->consultarExamenesM($idEx);

		echo json_encode($result);
	}

	public function eliminarExamenEmpelado()
	{
		$idEx= $this->input->post('idEX');

		$res=$this->mExamenes->eliminarExamenEmpleadoM($idEx);

		echo $res;
	}

	public function exportarDocumentoXLSX()
	{
		require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
		require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

		$objExcelPHP= new PHPExcel();

		$objExcelPHP->getProperties()->setCreator("");
		$objExcelPHP->getProperties()->setLastModifiedBy("");
		$objExcelPHP->getProperties()->setTitle("");
		$objExcelPHP->getProperties()->setSubject("");
		$objExcelPHP->getProperties()->setDescription("");

		$objExcelPHP->setActiveSheetIndex(0);

		// Consultar Examenes medicos
		$examenes=$this->mExamenes->consultarExamenesM(0);

		$estilo = array( 
		      'borders' => array(
		        'outline' => array(
		          'style' => PHPExcel_Style_Border::BORDER_THIN
		        )
		      )
		    );

		$objExcelPHP->getActiveSheet()->setCellValue('A1', 'Numero Documento');
		$objExcelPHP->getActiveSheet()->setCellValue('B1', 'Nombre del empleado');
		$objExcelPHP->getActiveSheet()->setCellValue('C1', 'Fecha de la carta');
		$objExcelPHP->getActiveSheet()->setCellValue('D1', 'Fecha de plazo');
		$objExcelPHP->getActiveSheet()->setCellValue('E1', 'Tipo de examenes');
		$objExcelPHP->getActiveSheet()->setCellValue('F1', 'Otros examenes');
		$objExcelPHP->getActiveSheet()->setCellValue('G1', 'Fecha de retorno');
		$objExcelPHP->getActiveSheet()->setCellValue('H1', 'Motivo');

		$cont=2;

		foreach ($examenes as $examen) {
			$objExcelPHP->getActiveSheet()->setCellValue('A'.$cont, $examen->documento);
			$objExcelPHP->getActiveSheet()->setCellValue('B'.$cont, $examen->nombre1.' '.$examen->nombre2.' '.$examen->apellido1.' '.$examen->apellido2);
			$objExcelPHP->getActiveSheet()->setCellValue('C'.$cont, $examen->fechaCarta);
			$objExcelPHP->getActiveSheet()->setCellValue('D'.$cont, $examen->fechaPlazo);
			$tipoe=$examen->tipoExamenes;
			$objExcelPHP->getActiveSheet()->setCellValue('E'.$cont, ($tipoe==1?'Examenes ingreso':($tipoe==1?'Examenes Periodicos':'Otros Examenes')));
			$objExcelPHP->getActiveSheet()->setCellValue('F'.$cont, $examen->otroExamen);
			$objExcelPHP->getActiveSheet()->setCellValue('G'.$cont, $examen->fechaRetorno);
			$objExcelPHP->getActiveSheet()->setCellValue('H'.$cont, $examen->motivo);
			$cont++;
		}

		$fileName= "Examenes".date("Y-m-d h:i:s").'xlsx';
		$objExcelPHP->getActiveSheet()->setTitle('Examenes Empleados');

		header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
		header('Content-Diposition: attachment;filiname="'.$fileName.'"');
		header('Cache-Control: max-age=0');

		$write= PHPExcel_IOFactory::createWriter($objExcelPHP,'Excel2007');
		$write->save('php://output');
	}
}
 ?>