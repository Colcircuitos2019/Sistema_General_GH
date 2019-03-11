<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class cDiagnostico extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mDiagnostico');
	}

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
		   	$this->load->view('Layout/MenuLateral');
		   	$this->load->view('Empleados/Diagnostico');
		   	$this->load->view('Layout/Footer');
		   	$this->load->view('Layout/clausulas'); 
		}
	}

	public function registrarModificarDiagnostico()
	{
		$info['idDiagnostico']=$this->input->post('idD');
		$info['diagnostico']=$this->input->post('nombre');
		$info['op']=$this->input->post('op');

		$res= $this->mDiagnostico->registrarModificarDiagnosticoM($info);

		echo $res;
	}

	public function ConsultarDiagnosticos()
	{
		$estado= $this->input->post('estado');

		$res=$this->mDiagnostico->ConsultarDiagnosticosM($estado);

		echo json_encode($res);
	}

	public function validarExistenciaCod()
	{
		$cod= $this->input->post('idD');

		$res=$this->mDiagnostico->validarExistenciaCodM($cod);

		// var_dump($res);

		echo $res;
	}
	// public function cambiarEstadoDiagnostico()
	// {
	// 	# code...
	// }

	public function importarDiagnostico()//Esto esta pendiente por discutir, por que la verdad es demaciada informacion que no se va a utilziar
	{	
		require_once(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
		$v = array();
		header("Content-Type: text/html;charset=utf-8");
		$path= $_FILES["diagnosticos"]['tmp_name'];
		$object= PHPExcel_IOFactory::load($path);
		foreach ($object->getWorksheetIterator() as $workSheet) {
			$highestRow = $workSheet->getHighestRow();
			$highestColumn= $workSheet->getHighestColumn();
			for ($row=0; $row <=$highestRow; $row++) { 
				// $workSheet->getCellByColumnAndRow(0,$row)->getValue();
				if ($workSheet->getCellByColumnAndRow(0,$row)->getValue()!='' && strlen($workSheet->getCellByColumnAndRow(0,$row)->getValue())==4) {
					// array_push($v, $workSheet->getCellByColumnAndRow(0,$row)->getValue());
					$info['idDiagnostico']=$workSheet->getCellByColumnAndRow(0,$row)->getValue();
					$info['diagnostico']=$workSheet->getCellByColumnAndRow(2,$row)->getValue();

					$res= $this->mDiagnostico->validarExistenciaCodM($info['idDiagnostico']);
					// array_push($v, ($res==true?1:2));
					$info['op']=($res==true?1:2);

					$idD= $this->mDiagnostico->registrarModificarDiagnosticoM($info);

					array_push($v,$idD);
				}
			}
		}
		var_dump($v);
		echo 1;
	}
	
} ?>