<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * 
 */
class cFichaE extends CI_Controller
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->model('Empleado/mFichaSDG');
	}
// Retorno de vista de Ficha socioDemografica.
	public function index() //Vista que va a ser visualizada por el gestor humano
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
           	$this->load->view('Empleados/FichaSDG/fichaE');
           	$this->load->view('Layout/Footer');
           	$this->load->view('Layout/clausulas');  
		}
	}

	// public function vistaEmpleado() //Vista que va a ser vista por el empleado. //Esto ya no se va a utilizar
	// {
	// 	if ($this->session->userdata('tipo_usuario')==5) {
 //           $this->load->view('Layout/Header2');
	// 	   $this->load->view('Empleados/FichaSDG/fichaE');
	// 	   $this->load->view('Layout/Footer');
	// 	   $this->load->view('Layout/clausulas');  
	// 	}else{
	// 		redirect('cLogin');
	// 	}
	// }
// Funciones de la clase
	public function registrarModificarEstadoEmpresarial()
	{
		$ID=$this->input->post('ID');//Ide de la ficha SDG
		$estados=$this->input->post('estados');
		$i=0;
		$cont;
		// Recorrer los estados y registrarlos o modificarlos.
		//No se puede permitir registrar más de un estado empresarial vigente...
		foreach ((Array)$estados as $estado) {
			// -.-.-
			$info['IDEstadoE']=$estado['idEstadoE'];//ID del estado.
			$info['estadoE']=$estado['estadoE'];//Estado empresarial. 1= Retirado y 2=vigente
			$info['rotacion']=$estado['idRotacion'];//Indice de rotacion.
			$info['motivo']=$estado['idMotivo'];//ID del motivo de renuncia.
			$info['empresa']=$estado['idEmpresa'];//ID de la empresa contratante.
			$info['fechaR']=$estado['fechaR'];//Fecha de retiro del empleado.
			$info['fechaI']=$estado['fechaI'];//Fecha de ingreso del empleado.
			$info['descripcion']=$estado['des'];//Campo de descripcion del retiro del empleado.
			$info['impacto']=$estado['impacto'];//Impacto que genera la persona en la empresa por su renuncia o abandono de trabajo
			$info['estado']=1;//Este estado se va a remplazar porque no es necesario.
			$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
			// -.-.-
			$res= $this->mFichaSDG->registrarModificarEstadoEmpresarialM($ID,$info);
			//...
			$cont[$i]=$estado['estadoE'];
			$i++;
		}

		// Cambiar el estado del empleado a desactivado siempre y cuando todos los estados empresariales sean retirados=1, y si existe a si sea un unico estado que sea vigente entonces automaticamente el estado del empelado va a pasar a activo...
		$this->load->model('Empleado/mEmpleado');
		
		//...
		if (in_array("2",$cont)) {
			//Activar el estado del empleado
			$this->mEmpleado->cambiarEstadoEmpleadoM($ID,1);
		}else{
			//Desactivar el estado del empleado
			$this->mEmpleado->cambiarEstadoEmpleadoM($ID,0);
		}

		//Cambiar la empresa a la que pertenece el empleado dependiento del ultimo estado empresarial que tenga.
		$this->mEmpleado->cambiarEmpresaEmpleadoM($ID,$estados[count($estados)-1]['idEmpresa']);

		echo $res;
	}

	public function consultarInformacionEstadoEmpresarial()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarEstadosEmpresarialesM($doc);

		echo json_encode($res);
	}

	public function registrarModificarEstudios()
	{
		$info['IDF']=$this->input->post('ID');
		$info['idEstudios']=$this->input->post('idEstudios');
		$info['tituloP']=$this->input->post('tituloP');
		$info['espes']=$this->input->post('espes');
		$info['idEstudiando']=$this->input->post('idEstudiando');
		$info['nombreCarrera']=$this->input->post('nameCarrera');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res= $this->mFichaSDG->registrarModificarEstudiosM($info);

		echo $res;
	}

	public function consultarInfoEstudios()
	{
	   $doc=$this->input->post('documento');

	   $res=$this->mFichaSDG->consultarInfoEstudiosM($doc);

	   echo json_encode($res);	
	}

	public function registrarModificarInfoLaboral()
	{
		$info['IDF']=$this->input->post('ID');
		$info['idHorario']=$this->input->post('idHorario');
		$info['idArea']=$this->input->post('idArea');
		$info['idTipoContraro']=$this->input->post('idTipoContraro');
		$info['idCargo']=$this->input->post('idCargo');
		$info['recursoH']=$this->input->post('recursoH');
		$info['fechaVC']=$this->input->post('fechaVC');
		$info['atinguedad']=$this->input->post('atinguedad');
		$info['CC']=$this->input->post('CC');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res= $this->mFichaSDG->registrarModificarInfoLaboralM($info);

		echo $res;
	}

	public function consultarInfoLaboral()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarInfoLaboralM($doc);

		echo json_encode($res);
	}

	public function registrarModificarOtraInformacion()
	{
		$info['IDF']=$this->input->post('ID');
		$info['TCamida']=$this->input->post('TCamida');
		$info['TPantalon']=$this->input->post('TPantalon');
		$info['Tzapatos']=$this->input->post('Tzapatos');
		$info['VCursoAlturas']=$this->input->post('VCursoAlturas');
		$info['RquierecursoAlturas']=$this->input->post('RquierecursoAlturas');
		$info['PBrigadaEmergencia']=$this->input->post('PBrigadaEmergencia');
		$info['AlgunComite']=$this->input->post('AlgunComite');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res= $this->mFichaSDG->registrarModificarOtraInformacion($info);

		echo $res;
	}


	public function consultarOtraInformacion()
	{
	  $doc=$this->input->post('documento');

	  $res=$this->mFichaSDG->consultarOtraInformacionM($doc);

	  echo json_encode($res);
	}

	public function registrarModificarInfoSalud()
	{
		$info['IDF']=$this->input->post('ID');
		$info['fuma']=$this->input->post('fuma');
		$info['alcohol']=$this->input->post('alcohol');
		$info['desE']=$this->input->post('desE');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res= $this->mFichaSDG->registrarModificarInfoSaludM($info);

		echo $res;
	}

	public function consultarInfoSalud()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarInfoSaludM($doc);

		echo json_encode($res);
	}

	// Esta funcion queda pendiente hasta hacer el controlador de registrar o modificar informacion personal.
	public function registrarModificarActividadesInfoPersonal()
	{	
		$IDF= $this->input->post('idF');
		$actividad= $this->input->post('act');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
		// ...
		$res=$this->mFichaSDG->registrarModificarActividadesInfoPersonalM($IDF,$actividad,$info);
		//...
	 	echo $res;
	}

	public function consultarActividadesInfoPesonal()
	{
		$id=$this->input->post('idP');

		$res=$this->mFichaSDG->consultarActividadesInfoPersonalM($id);

		echo json_encode($res);
	}

	public function registrarModificarInfoPersonal()
	{
		
		$id= $this->input->post('IDF');
		$info['direccion'] = $this->input->post('direc');
		$info['comuna'] = $this->input->post('comuna');
		$info['municipio'] = $this->input->post('municipio');
		$info['estrato'] = $this->input->post('estrato');
		$info['barrio'] = $this->input->post('barrio');
		$info['casoEM'] = $this->input->post('casoEM');
		$info['telefono'] = $this->input->post('tel');
		$info['parentezco'] = $this->input->post('parentezco');
		$info['idTipoV'] = $this->input->post('idTipoV');
		$info['altura'] = $this->input->post('altura');
		$info['peso'] = $this->input->post('peso');
		$info['otra'] = $this->input->post('otraAC');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res= $this->mFichaSDG->registrarModificarInfoPersonalM($id,$info);

		echo $res;
	}

	public function consultarInfoPersonal()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarInfoPersonalM($doc);

		echo json_encode($res);
	}

	public function registrarModificarPersonasVive()
	{
		$info['op']=$this->input->post('op');
		$info['nombreC']=$this->input->post('nombre');
		$info['idParT']=$this->input->post('idParT');
		$info['celular']=$this->input->post('celular');
		$info['fechaN']=$this->input->post('fechaN');
		$info['viveCon']=$this->input->post('viveCon');
		$info['idPersonal']=$this->input->post('idPersonal');
		$info['cantidad']=$this->input->post('cantidad');
		$info['idPersona']=$this->input->post('idPE');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res=$this->mFichaSDG->registrarModificarPersonasViveM($info);

		echo $res;
	}

	public function eliminarPersonaVive()
	{
		$info['id'] = $this->input->post('id');
		$info['idPersonal'] = $this->input->post('idPer');
		$info['isParentezco'] = $this->input->post('idPare');

		$res= $this->mFichaSDG->eliminarPersonaViveM($info);

		echo $res;
	}

	public function consultarPersonasViveInfoPersonal()
	{
	  $id=$this->input->post('idP');

	  $res=$this->mFichaSDG->consultarPersonasViveInfoPersonalM($id);

	  echo json_encode($res);
	}

	public function registrarModificarInfoSecundariaBasica()
	{
		$info['ID']=$this->input->post('ID');
		$info['estadoC']=$this->input->post('idEstadoC');
		$info['fechaN']=$this->input->post('fechaN');
		$info['lugarN']=$this->input->post('lugarN');
		$info['tipoS']=$this->input->post('tipoS');
		$info['telF']=$this->input->post('telF');
		$info['cel']=$this->input->post('cel');
		$info['EPS']=$this->input->post('EPS');
		$info['AFP']=$this->input->post('AFP');
		$info['CC']=$this->input->post('CC');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res=$this->mFichaSDG->registrarModificarInfoSegundariaM($info);

		echo $res;
	}

	public function consultarInfoSecundariaBasica()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarInfoSecundariaBasicaM($doc);

		echo json_encode($res);
	}

	public function registrarModificarInfoSalarial()
	{
		$info['ID']=$this->input->post('ID');
		$info['idsalarioP']=$this->input->post('idsalarioP');
		$info['idClaM']=$this->input->post('idClaM');
		$info['salarioB']=$this->input->post('salarioB');
		$info['total']=$this->input->post('total');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel

		$res=$this->mFichaSDG->registrarModificarInfoSalarialM($info);

		echo $res;
	}

	public function consultarInfoSalarial()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarInfoSalarialM($doc);

		echo json_encode($res);	

	}

	public function registrarModificarInfoSAuxilios()//Pendiente por pasar la informacion de accion
	{//
		$id=$this->input->post('idS');

		$auxilios=$this->input->post('auxilios');
		$auxDelite=$this->input->post('auxDel');

		// Registrar o modificar auxilios
		// if (count($auxilios)>0) { 
		    $info['accion']=0;
		    foreach((Array)$auxilios as $aux) {
		    	// echo ($aux['idAux']);
		    	if ($aux['idAux']!=null) {
		    		$res=$this->mFichaSDG->registrarModificarInfoSAuxiliosM($id,$aux['idAux'],$aux['monto'],$info);
		    	}
		    }
		// }
		// Cambiar estado de los auxilio que ya no va a recibir el empleado.
		// if (count($auxDelite)>0) {
			foreach ((Array)$auxDelite as $auxD) {
				if ($auxD['idAuxD']!=null) {
				$res=$this->mFichaSDG->cambiarEstadoAuxilioM($id,$auxD['idAuxD']);//Los auxilios con estado 1 son los vigentes y los que tienen estado 0 son los que el empleado recibio en algun momento de su trayecto laboral.
				}
			}
		// }
		// ...
		echo $res;
	}

	public function consultarAuxilios()
	{
		$doc=$this->input->post('documento');

		$res=$this->mFichaSDG->consultarAuxiliosM($doc);

		echo json_encode($res);
	}

	public function registrarFichaSDG()
	{
		$info['documento']=$this->input->post('doc');
		$info['idSalarial']=$this->input->post('idSalarial');
		$info['idLaboral']=$this->input->post('idLaboral');
		$info['idEstudio']=$this->input->post('idEstudio');
		$info['idSecundariaB']=$this->input->post('idSecundariaB');
		$info['idPersonal']=$this->input->post('idPersonal');
		$info['idSauld']=$this->input->post('idSauld');
		$info['idOtros']=$this->input->post('idOtros');
		$info['accion']=0;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel		

		$res=$this->mFichaSDG->registrarFichaSDGM($info);

		echo $res;
	}
// 
	public function reporteFichaSDGEmpleado()
	{
	  //Captura de la variable GET 
	  $documento=$_GET['doc'];
	  // Llamado de la libreria
	  $this->load->library('PDFFSDG');
	  $this->load->model('Empleado/mEmpleado');
	  // Creacion del PDF
	  /*
	   * Se crea un objeto de la clase Pdf, recuerda que la clase Pdf
	   * heredó todos las variables y métodos de fpdf
	   */
	  $this->pdf = new pdffsdg();
	  // Agregamos una página
	  $this->pdf->AddPage();
	  // Define el alias para el número de página que se imprimirá en el pie
	  $this->pdf->AliasNbPages();
	  /* Se define el titulo, márgenes izquierdo, derecho y
	   * el color de relleno predeterminado
	   */
	  $this->pdf->SetTitle("FSDG");
	  $this->pdf->SetLeftMargin(10);
	  $this->pdf->SetRightMargin(10);
	  $this->pdf->SetFillColor(186, 201, 0);
	   // Inicio de la tabla 1
	  // Se define el formato de fuente: Arial, negritas, tamaño 12
	  $this->pdf->SetFont('Arial', 'B', 10);
	  /*
	   * TITULOS DE COLUMNAS de los productos que se pidieron a ese proveedor
	   *
	   * $this->pdf->Cell(Ancho, Alto,texto,borde,posición,alineación,relleno);
	   */
	  // Cabeza de la tabla de pedidos por producto y por proveedor
	  $empleado= $this->mEmpleado->consultarEmpleadosM($documento);
	  // 
	  $this->pdf->Ln(7);//salto de linea
	  foreach ($empleado as $row) {
	    $this->pdf->Cell(60,7,utf8_decode(' Documento:  '.$row->documento),0,0,'L','0');//Numero de documento
	    $this->pdf->Cell(100,7,utf8_decode(' Nombre Empleado:  '.$row->nombre1.' '.$row->nombre2.' '.$row->apellido1.' '.$row->apellido2),0,0,'L','0');//Nombre del empleado
	    $this->pdf->Cell(40,7,utf8_decode(' Sexo:  '.($row->genero==1?'Masculino':'Femenino')),0,0,'L','0');//Genero del empleado
	    $this->pdf->Ln(9);//salto de linea
	    $this->pdf->Cell(100,7,utf8_decode('Correo:  '.$row->correo),0,0,'C','0');//Numero de documento
	    $this->pdf->Cell(90,7,utf8_decode('Piso de ubicación:  '.$row->piso),0,0,'C','0');//Numero de documento
	    $this->pdf->Ln(9);//salto de linea
	    $this->pdf->Cell(95,7,utf8_decode('Empresa:  '.$row->nombre),0,0,'C','0');//Numero de documento
	    $this->pdf->Cell(95,7,utf8_decode('Estado:  '.($row->estado==1?'Activo':'Inactivo')),0,0,'C','0');//Numero de documento
	  }

	  $this->pdf->Ln(14);//salto de linea
	  // $this->pdf->SetFont('Arial', 'B', 12);
	  // ------------------------------------------------------------------------------------------------------------->
	  // Modulo de informacion salarial
	  $this->pdf->Cell(190,7,utf8_decode('Información Salarial'),1,0,'C','1');//Header de informacion salarial
	  // 
	  $this->pdf->Ln(7);//Realiza un salto de linia de un alto de 7 px
	  $this->pdf->SetFont('Arial', 'B', 9);//Sub titulos
	  $this->pdf->Cell(80,7,'Promedio',0,0,'C','0');
	  $this->pdf->Cell(30,7,utf8_decode('Clasificación'),0,0,'C','0');
	  $this->pdf->Cell(80,7,utf8_decode('Salario basico'),0,0,'C','0');
	  $this->pdf->Ln(7);
	  // Consulta de la informacion salarial
	  $salarial=$this->mFichaSDG->consultarInfoSalarialM($documento);
	  // ...
	  $this->pdf->SetFont('Arial', '', 9);
	  // ...
	  $total="";
	  foreach ($salarial as $row) {//Leer información
	  	$this->pdf->Cell(80,7,utf8_decode($row->nombre),0,0,'C','0');
	  	$this->pdf->Cell(30,7,utf8_decode($row->clasificacion),0,0,'C','0');
	  	$this->pdf->Cell(80,7,utf8_decode($row->salario_baseico_formato),0,0,'C','0');
	  	$total=$row->totalFormato;
	  }
	  // Consultar informacion salarial>Auxilios
	  $cantidadAuxilios=$this->mFichaSDG->consultarCantidadAuxiliosM($documento);
	  // ...
	  if ($cantidadAuxilios>0) {
	  	$this->pdf->Ln(14);//Salto de linea
	  	$this->pdf->SetFont('Arial', 'B', 12);//Letra para titulos
	  	// Eqiqueta de auxilios
	  	$this->pdf->Cell(80,(7*$cantidadAuxilios),utf8_decode('Auxilios'),1,0,'C','1');//Header de auxilios
	  	// ...
	    $auxilios=$this->mFichaSDG->consultarAuxiliosM($documento);
	    // ...
	    $i=0;
	    $this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	    foreach ($auxilios as $row) {//Leer información
	  	  if ($row->estado==1) {
	  	  	if ($i>0) {
	  	  	 $this->pdf->Cell(80,7,'',0,0,'C','0');
	  	  	}
	  	  	$this->pdf->Cell(55,7,utf8_decode($row->auxilio.'  ->'),0,0,'C','0');//Nombre del auxilio
	  		 $this->pdf->Cell(55,7,utf8_decode($row->mondoFormato),0,0,'C','0');//Monto del auxilio
	  	  	$this->pdf->Ln(7);
	  	  	$i++;
	  	  }
	    }	
	  }else{
	  	$this->pdf->Ln(7);
	  }
	  // $this->pdf->Ln(7);//Salto de linea
	  $this->pdf->SetFont('Arial', 'B', 12);//Letra para titulos
	  $this->pdf->Cell(130,7,'Total:     ',0,0,'R','0');
	  $this->pdf->Cell(60,7,$total,1,0,'C','0');
	  $this->pdf->Ln(21);//Salto de linea
	  // ------------------------------------------------------------------------------------------------------------>
	  // Informacion de estudios
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  // 
	  $this->pdf->Cell(190,7,utf8_decode('Información Estudios'),1,0,'C','1');//Header de informacion  de estudios
	  $this->pdf->Ln(7);//Salto de linea
	  // 
	  $this->pdf->SetFont('Arial', 'B', 9);//Sub titulos
	  $this->pdf->Cell(33,7,utf8_decode('Grado escolaridad'),0,0,'C','0');//Nombre del grado de escolaridad
	  $this->pdf->Cell(74,7,utf8_decode('Titulo Profesional'),0,0,'C','0');//Titulo profecional
	  $this->pdf->Cell(83,7,utf8_decode('Titulo Especialización'),0,0,'C','0');//Titulo especializacion
	  // Consultar informacion de estudios
	  $estudios=$this->mFichaSDG->consultarInfoEstudiosM($documento);
	  // 
	  $this->pdf->SetFont('Arial', '', 9);//Informacion
	  $this->pdf->Ln(7);//Salto de linea
	  foreach ($estudios as $row) {//Leer información
	  	$this->pdf->Cell(33,7,utf8_decode($row->grado),0,0,'C','0');//Nombre del grado de escolaridad
	  	$this->pdf->Cell(74,7,utf8_decode($row->titulo_profecional),0,0,'C','0');//Titulo profecional
	  	$this->pdf->Cell(83,7,utf8_decode($row->titulo_especializacion),0,0,'C','0');//Titulo especializacion
	  	$this->pdf->Ln(14);//Salto de linea
	  	$this->pdf->SetFont('Arial', 'B', 12);//Informacion
	  	$this->pdf->Cell(190,7,utf8_decode('Estudios actuales'),1,0,'C','1');//Header de informacion salarial
	  	$this->pdf->SetFont('Arial', 'B', 9);//Informacion
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(33,7,utf8_decode('Estudia Actualmente?'),0,0,'C','0');//Nombre del grado de escolaridad
	  	$this->pdf->Cell(74,7,utf8_decode('Profesión que estudia'),0,0,'C','0');//Titulo profecional
	  	$this->pdf->Cell(83,7,utf8_decode('Nombre de la carrera'),0,0,'C','0');//Titulo especializacion
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->SetFont('Arial', '', 9);//Informacion
	  	$this->pdf->Cell(33,7,($row->titulo_estudios_actuales>0?'SI':'NO'),0,0,'C','0');//Nombre del grado de escolaridad
	  	$this->pdf->Cell(74,7,utf8_decode($row->estudios_actuales),0,0,'C','0');//Titulo profecional
	  	$this->pdf->Cell(83,7,utf8_decode($row->nombre_carrera),0,0,'C','0');//Titulo especializacion
	  }
	  // ------------------------------------------------------------------------------------------------------------>
	  $this->pdf->Ln(21);//Salto de linea
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo

	  $this->pdf->Cell(190,7,utf8_decode('Información Laboral'),1,0,'C','1');//Header de informacion laboral
	  $this->pdf->Ln(9);//Salto de linea
	  // Informacion laboral
	  $laboral= $this->mFichaSDG->consultarInfoLaboralM($documento);

	  $this->pdf->SetFont('Arial', 'B', 9);//Titulo
	  foreach ($laboral as $row) {
	  	$this->pdf->Cell(63,7,utf8_decode('Horario de trabajo'),1,0,'C','1');//Horario laboral
	  	$this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	$this->pdf->Cell(63,7,utf8_decode($row->horario),0,0,'L','0');
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(63,7,utf8_decode('Área de trabajo'),1,0,'C','1');//Area de trabajo
	  	$this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	$this->pdf->Cell(63,7,utf8_decode($row->area),0,0,'L','0');
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(63,7,utf8_decode('Cargo'),1,0,'C','1');//cargo empresarial
	  	$this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	$this->pdf->Cell(63,7,utf8_decode($row->cargo),0,0,'L','0');
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(63,7,utf8_decode('Personal a cargo'),1,0,'C','1');// Recursos humanos
	  	$this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	$this->pdf->Cell(63,7,($row->recurso_humano==1?'SI':'NO'),0,0,'L','0');
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(63,7,utf8_decode('Tipo de contraro'),1,0,'C','1');// Tipo de contrato
	  	$this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	$this->pdf->Cell(63,7,utf8_decode($row->contrato),0,0,'L','0');
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(63,7,utf8_decode('Fecha vencimiento contrato'),1,0,'C','1');//Fecha de contrato
	  	$this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	$this->pdf->Cell(63,7,utf8_decode($row->fecha_vencimiento_contrato),0,0,'L','0');
	  	$this->pdf->Ln(7);//Salto de linea
	  	// $this->pdf->Cell(63,7,utf8_decode('Fecha de ingreso'),1,0,'C','1');//Fecha de ingreso
	  	// $this->pdf->Cell(64,7,'---------------------------------->',0,0,'C','0');
	  	// $this->pdf->Cell(63,7,utf8_decode($row->fecha_ingreso),0,0,'L','0');
	  	// $this->pdf->Ln(7);//Salto de linea
	  }
	  // ------------------------------------------------------------------------------------------------------------------->
	  $this->pdf->Ln(50);//Salto de linea
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  $this->pdf->Cell(190,7,utf8_decode('Información Secundaria basica'),1,0,'C','1');//Header de informacion secundaria basica
	  // Informacion secundaria basica
	  $secundariaB= $this->mFichaSDG->consultarInfoSecundariaBasicaM($documento);
	  // var_dump($secundariaB);
	  $this->pdf->SetFont('Arial', '', 9);//Titulo
	  $this->pdf->Ln(7);//Salto de linea
	  foreach ($secundariaB as $row) {
	  	$this->pdf->Cell(95,7,utf8_decode('Estado Civil: '.$row->nombre_estado),1,0,'C','0');//Estado civil
	  	$this->pdf->Cell(95,7,utf8_decode('Fecha de nacimiento: '.$row->fecha_nacimiento),1,0,'C','0');//Fecha de nacimiento
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(95,7,utf8_decode('Tipo de sangre: '.$row->sangre),1,0,'C','0');//Tipo de sangre
	  	$this->pdf->Cell(95,7,utf8_decode('Lugar de nacimiento: '.$row->lugar_nacimiento),1,0,'C','0');//Lugar de nacimiento
	  	$this->pdf->Ln(7);//Salto de linea
	  	$this->pdf->Cell(95,7,utf8_decode('Telefono Fijo: '.$row->tel_fijo),1,0,'C','0');//Telefono fijo
	  	$this->pdf->Cell(95,7,utf8_decode('Telefono celular: '.$row->celular),1,0,'C','0');//Telefono celular
	  	$this->pdf->Ln(7);//Salto de lineas
	  	$this->pdf->Cell(95,7,utf8_decode('EPS: '.$row->eps),1,0,'C','0');//Eps
	  	$this->pdf->Cell(95,7,utf8_decode('AFP: '.$row->afp),1,0,'C','0');//Afp
	  }
	  $this->pdf->Ln(14);//Salto de linea
	  // ------------------------------------------------------------------------------------------------------------------->
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  $this->pdf->Cell(190,7,utf8_decode('Información de salud'),1,0,'C','1');//Header de informacion de salud
	  // Consultar informacion salud
	  $salud=$this->mFichaSDG->consultarInfoSaludM($documento);
	  // ...
	  $this->pdf->SetFont('Arial', '', 9);//Titulo
	  $this->pdf->Ln(8);//Salto de linea
	  foreach ($salud as $row) {
	  	// 
	  	$this->pdf->Cell(95,7,utf8_decode('Cigarrillos consumo por día: '.$row->fuma),0,0,'C','0');//
	  	$this->pdf->Cell(95,7,utf8_decode('Frecuencia de alcohol: '.($row->alcohol=='0'?'N/A':$row->alcohol)),0,0,'C','0');//
	  	$this->pdf->Ln(8);//Salto de linea
	  	$this->pdf->SetFont('Arial', 'B', 9);//Titulo
	  	$this->pdf->Cell(190,7,utf8_decode('Ante una emergencia, en caso de requerir ser atendido por la brigada o una EPS tiiene alguna condición especial: '),0,0,'L','0');//
	  	$this->pdf->Ln(6);//Salto de linea
	  	$this->pdf->SetFont('Arial','',9);
	  	$this->pdf->Cell(190,7,utf8_decode($row->descripccion_emergencia),0,0,'L','0');//
	  }
	  $this->pdf->Ln(14);//Salto de linea
	  // -------------------------------------------------------------------------------------------------------------------->
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  $this->pdf->Cell(190,7,utf8_decode('Información Personal'),1,0,'C','1');//Header de informacion de personal
	  // Consultar informacion personal
	  $personal= $this->mFichaSDG->consultarInfoPersonalM($documento);
	  $this->pdf->SetFont('Arial','B',9);
	  $this->pdf->Ln(9);//Salto de linea
	  $idPersonal=0;
	  foreach ($personal as $row) {
	  	  	$this->pdf->Cell(30,7,utf8_decode('Direccion: '),0,0,'C','1');//Direccion	
	  	  	$this->pdf->Cell(160,7,utf8_decode($row->direc),0,0,'C','0');//
	  	  	$this->pdf->Ln(9);//Salto de linea
	  	  	$this->pdf->Cell(25,7,utf8_decode('Barrio: '),0,0,'C','1');//Barrio	
	  	  	$this->pdf->Cell(70,7,utf8_decode($row->barrio),0,0,'L','0');//
	  	  	$this->pdf->Cell(25,7,utf8_decode('Comuna: '),0,0,'C','1');//Comuna
	  	  	$this->pdf->Cell(70,7,utf8_decode($row->comuna),0,0,'L','0');//
	  	  	$this->pdf->Ln(9);//Salto de linea
	  	  	$this->pdf->Cell(30,7,utf8_decode('Estrato: '),0,0,'C','1');//Estrato	
	  	  	$this->pdf->Cell(25,7,utf8_decode($row->estrato),0,0,'L','0');//
	  	  	$this->pdf->Cell(25,7,utf8_decode('Municipio: '),0,0,'C','1');//Municipio	
	  	  	$this->pdf->Cell(50,7,utf8_decode($row->municipio),0,0,'L','0');//
	  	  	$this->pdf->Cell(25,7,utf8_decode('vivienda: '),0,0,'C','1');//Vivienda	
	  	  	$this->pdf->Cell(35,7,utf8_decode($row->vivienda),0,0,'L','0');//
	  	  	$this->pdf->Ln(9);//Salto de linea
	  	  	$this->pdf->Cell(50,7,utf8_decode('En caso de emergencia: '),0,0,'C','1');//Persona en caso de emergencia.	
	  	  	$this->pdf->Cell(70,7,utf8_decode($row->caso_emergencia),0,0,'L','0');//
	  	  	$this->pdf->Cell(25,7,utf8_decode('Parentesco:'),0,0,'C','1');//Parentesco de la persona en caso de emergencia.
	  	  	$this->pdf->Cell(45,7,utf8_decode($row->nombre),0,0,'L','0');//
	  	  	$this->pdf->Ln(9);//Salto de linea
	  	  	$this->pdf->Cell(25,7,utf8_decode('Telefono:'),0,0,'C','!');//Telefono de la persona en caso de emergencia
	  	  	$this->pdf->Cell(30,7,utf8_decode($row->tel),0,0,'L','0');//
	  	  	$this->pdf->Cell(30,7,utf8_decode('Altura:'),0,0,'C','1');//Altura
	  	  	$this->pdf->Cell(30,7,utf8_decode($row->altura.' Mts'),0,0,'L','0');//
	  	  	$this->pdf->Cell(30,7,utf8_decode('Peso:'),0,0,'C','1');//Peso
	  	  	$this->pdf->Cell(30,7,utf8_decode($row->peso.' Kg'),0,0,'L','0');//
	  	  	$this->pdf->Ln(18);//Salto de linea
	  	  	$idPersonal= $row->idPersonal;
	  }
	  // Personas con las que vive
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  $this->pdf->Cell(190,7,utf8_decode('Personas con las que vive'),1,0,'C','1');//Header de informacion de personal
	  $this->pdf->Ln(9);//Salto de linea
	  // Consultar personas con las que vive
	  $PersonaVive=$this->mFichaSDG->consultarPersonasViveInfoPersonalM($idPersonal);

	  foreach ($PersonaVive as $row) {
	  	$this->pdf->SetFont('Arial', 'B', 9);//Letra para informacion
	  	switch ($row->idParentezco) {
	  		case 1: //Madre
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode('SI'),1,0,'C','0');//Texto
	  			break;
	  		case 2://Padre
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode('SI'),1,0,'C','0');//Texto
	  			break;
	  		case 3://Acompañante
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode($row->nombreC),1,0,'L','0');//Texto
	  			$this->pdf->Cell(8,7,'',0,0,'L','0');//Espacion entre columanas
	  			$this->pdf->SetFont('Arial', 'B', 9);
	  			$this->pdf->Cell(27,7,utf8_decode('Telefono'),1,0,'C','1');//Texto
	  			$this->pdf->SetFont('Arial', '', 9);
	  			$this->pdf->Cell(50,7,utf8_decode($row->celular),1,0,'L','0');//Texto
	  			break;
	  		case 4://Abuelos
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode($row->cantidad),1,0,'C','0');//Texto
	  			break;
	  		case 5://Tios
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode($row->cantidad),1,0,'C','0');//Texto
	  			break;
	  		case 6://hermanos
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode($row->cantidad),1,0,'C','0');//Texto
	  			break;
	  		case 7://Otros
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(50,7,utf8_decode($row->cantidad),1,0,'C','0');//Texto
	  			break;
	  		case 8://Hijos
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(60,7,utf8_decode($row->nombreC),1,0,'L','0');//Texto
	  			$this->pdf->Cell(8,7,'',0,0,'L','0');//Espacion entre columanas
	  			$this->pdf->SetFont('Arial', 'B', 9);
	  			$this->pdf->Cell(30,7,utf8_decode('Fecha nacimiento'),1,0,'C','1');//Texto
	  			$this->pdf->SetFont('Arial', '', 9);
	  			$this->pdf->Cell(50,7,utf8_decode($row->fecha_nacimiento),1,0,'L','0');//Texto
	  			break;
	  		case 9://Hijastros
	  			$this->pdf->Cell(27,7,utf8_decode($row->nombre),1,0,'C','1');//Parentezco
	  			$this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  			$this->pdf->Cell(60,7,utf8_decode($row->nombreC),1,0,'L','0');//Texto
	  			$this->pdf->Cell(8,7,'',0,0,'L','0');//Espacion entre columanas
	  			$this->pdf->SetFont('Arial', 'B', 9);
	  			$this->pdf->Cell(30,7,utf8_decode('Fecha nacimiento'),1,0,'C','1');//Texto
	  			$this->pdf->SetFont('Arial', '', 9);
	  			$this->pdf->Cell(50,7,utf8_decode($row->fecha_nacimiento),1,0,'L','0');//Texto
	  			break;
	  	}
	  		$this->pdf->Ln(9);//Salto de linea
	  }

	  $this->pdf->Ln(18);//Salto de linea
	  $this->pdf->SetFont('Arial', 'B', 9);//Letra para informacion
	  // --------------------------------------------------------------------------------------------------------------------->
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  $this->pdf->Cell(190,7,utf8_decode('Actividades en tiempo libre'),1,0,'C','1');//Header de informacion de personal
	  $this->pdf->Ln(9);//Salto de linea
	  // Consultar informacion de actividades realizadas en el tiempo libre
	  $actividades=$this->mFichaSDG->consultarActividadesInfoPersonalM($idPersonal);
	  $con=1;
	  $this->pdf->SetFont('Arial', '', 9);//Letra para informacion
	  foreach ($actividades as $row) {
	  	$this->pdf->Cell(95,7,utf8_decode($row->nombre),1,0,'C','0');//Actividad realizada
	  	if ($con%2==0) {//Cada dos columnas en cada fila va a realizar un salto de linea obligatorio
	  		$this->pdf->Ln(9);//Salto de linea
	  	}
	  	$con++;
	  }
	  $this->pdf->Ln(18);//Salto de linea
	  // --------------------------------------------------------------------------------------------------------------------->
	  $this->pdf->SetFont('Arial', 'B', 12);//Titulo
	  $this->pdf->Cell(190,7,utf8_decode('Otra información'),1,0,'C','1');//Header de informacion de personal
	  // Consultar otra información de los empleados
	  $otro=$this->mFichaSDG->consultarOtraInformacionM($documento);
	  $this->pdf->SetFont('Arial', 'B', 9);//Titulo
	  $this->pdf->Ln(9);//Salto de linea
	  foreach ($otro as $row) {
	  	$this->pdf->Cell(25,7,utf8_decode('Talla camisa'),1,0,'C','1');//
	  	$this->pdf->Cell(25,7,utf8_decode($row->talla_camisa),1,0,'C','0');//Talla de la camisa del empleado
	  	$this->pdf->Cell(8,7,'',0,0,'C','0');//espacio en blanco entre columnas
	  	$this->pdf->Cell(25,7,utf8_decode('Talla pantalon'),1,0,'C','1');//
	  	$this->pdf->Cell(25,7,utf8_decode($row->talla_pantalon),1,0,'C','0');//Talla del pantalon del empleado
	  	$this->pdf->Cell(8,7,'',0,0,'C','0');//espacio en blanco entre columnas
	  	$this->pdf->Cell(25,7,utf8_decode('Talla zapatos'),1,0,'C','1');//
	  	$this->pdf->Cell(25,7,utf8_decode($row->talla_zapatos),1,0,'C','0');//Talla de los zapatos del empleado
	    $this->pdf->Ln(9);//Salto de linea
	    $this->pdf->Cell(50,7,utf8_decode('Vigencia curso alturas'),1,0,'C','1');//
	    $this->pdf->Cell(35,7,utf8_decode($row->vigencia_curso_alturas),1,0,'C','0');//vigencia del curso de alturas
	    $this->pdf->Ln(9);//Salto de linea
	    $this->pdf->Cell(80,7,utf8_decode('¿Requiere o tiene el curso de alturas?'),1,0,'C','1');//
	    $this->pdf->Cell(35,7,utf8_decode($row->necesitaCALT==1?'SI':'NO'),1,0,'C','0');//Require o tiene el curso de alturas
	    $this->pdf->Ln(9);//Salto de linea
	    $this->pdf->Cell(80,7,utf8_decode('¿Ha pertenecido a una brigada de emergencia?'),1,0,'C','1');//
	    $this->pdf->Cell(35,7,utf8_decode($row->brigadas==1?'SI':'NO'),1,0,'C','0');//Pertenece o pertenecio a una brigada de emergencia?
	    $this->pdf->Ln(9);//Salto de linea
	    $this->pdf->Cell(80,7,utf8_decode('¿Ha estado en algun comite de las empresas?'),1,0,'C','1');//
	    $this->pdf->Cell(35,7,utf8_decode($row->comites==1?'SI':'NO'),1,0,'C','0');//Ha estado en algun comite de las empresas.
	  }
	  /*
	   * Se manda el pdf al navegador
	   *
	   * $this->pdf->Output(nombredelarchivo, destino);
	   *
	   * I = Muestra el pdf en el navegador
	   * D = Envia el pdf para descarga
	   *
	   */
	  $this->pdf->Output(utf8_decode('Ficha SocioDemoGrafica').".pdf", 'I');
	}

	public function formatoFecha($fecha)//Esta función ya no es necesaria... 
	{
		$v=explode('-',$fecha);
		//...
		if (sizeof($v)==3) {
			return $v[2].'-'.$v[1].'-'.$v[0];
		}else{
			return "0000-00-00";
		}
		
	}

	public function importarXLSX()//Este importar documentos excel esta funcionando peo sin validaciones
	{	
		$this->load->model('Empleado/mEmpleado');

		require_once(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
		$empleado;
		$idFichaSDG=[];
		$conPersona=0;
		// $cont=0;
		// $dato1;
		// $dato2;
		$dato="";
		// $ingreso=0;
		header("Content-Type: text/html;charset=utf-8");
		if (isset($_FILES["fichasSDG"]["name"])) {
			$path= $_FILES["fichasSDG"]['tmp_name'];
			$object= PHPExcel_IOFactory::load($path);
			foreach ($object->getWorksheetIterator() as $workSheet) {
				$highestRow = $workSheet->getHighestRow();
				$highestColumn= $workSheet->getHighestColumn();
				// ...
				// $cont++; 
				// Validacion del formato del excel
				$ingreso=1;
				// $dato= $workSheet->getCellByColumnAndRow(1,2)->getValue();
				// $dato="Hola mundo";
				// echo $workSheet->getCellByColumnAndRow(1,2)->getValue();
				if ($workSheet->getCellByColumnAndRow(1,2)->getValue()=='*Documento:' && $workSheet->getCellByColumnAndRow(182,2)->getValue()=='Observación retiro' && $workSheet->getCellByColumnAndRow(129,2)->getValue()=='Estado Empresarial') {
						for ($row=3; $row<=$highestRow; $row++) {
						    $ingreso=1;
							#Recorrer Excel
							// *Salario Basico:
							if ($workSheet->getCellByColumnAndRow(9,$row)->getValue()!=null || $workSheet->getCellByColumnAndRow(9,$row)->getValue()!='') {//Si este campo de salario base es nulo significa que el empelado no tiene una ficha SDG a registrar
								if ($this->mEmpleado->validarDocumentoEmpleado($workSheet->getCellByColumnAndRow(1,$row)->getValue())) {//Validar existencia del documento
									// Realizar la respectiva validacion de campos del excel...
										// Datos basicos del empleado
										$empleado['documento']=$workSheet->getCellByColumnAndRow(1,$row)->getValue();
										$empleado['nombre_empleado']=$workSheet->getCellByColumnAndRow(2,$row)->getValue();
										$empleado['sexo']=$workSheet->getCellByColumnAndRow(3,$row)->getValue();
										$empleado['correo']=$workSheet->getCellByColumnAndRow(4,$row)->getValue();
										$empleado['empresa']=$workSheet->getCellByColumnAndRow(5,$row)->getValue();
										$empleado['estado']=$workSheet->getCellByColumnAndRow(6,$row)->getValue();
										// Informacion salarial
										$salarial['PromedioS']=$workSheet->getCellByColumnAndRow(7,$row)->getValue();
										$salarial['ClasificacionM']=($workSheet->getCellByColumnAndRow(8,$row)->getValue()==''?0:$workSheet->getCellByColumnAndRow(8,$row)->getValue());
										$salarial['SalarioB']=str_replace('$','',(str_replace(',','',$workSheet->getCellByColumnAndRow(9,$row)->getValue())));
										// Sumar total auxilios
										$montoAuxilio=0;
										for ($i=0; $i < 6; $i++) { 
											if ($workSheet->getCellByColumnAndRow((11+$i),2)->getValue()!=null) {
												if ($workSheet->getCellByColumnAndRow((11+$i),$row)->getValue()!=null) {
														// ... Monto total de los auxilios que se le brindan al empleado ejm: 88211
													if (str_replace('$','',str_replace('.','',str_replace(',','',$workSheet->getCellByColumnAndRow((11+$i),$row)->getValue())))>0) {
														# code...
													      $montoAuxilio+=str_replace('$','',str_replace('.','',str_replace(',','',$workSheet->getCellByColumnAndRow((11+$i),$row)->getValue())));
													}
													// 
												}
											}
										}
										$salarial['totalS']=($montoAuxilio+((int)str_replace('$','',(str_replace(',','',$workSheet->getCellByColumnAndRow(9,$row)->getValue())))));
										$salarial['documento']=$empleado['documento'];
										$salarial['accion']=1;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel	
										$idFichaSDG['idSalarial']=$this->mFichaSDG->registrarModificarInfoSalarialM($salarial);
										// Auxilios validaciones de los campos nulos esta pendiente ->Registras y actualizar los auxilios de las personas esta pendiente
										$auxilios['accion']=1;
										$auxilios['idSalarial']=(Int)$idFichaSDG['idSalarial'];
										// var_dump($auxilios['idSalarial']);
										$auxilios['documento']=$empleado['documento'];
										for ($i=0; $i < 6; $i++) { 
											if ($workSheet->getCellByColumnAndRow((11+$i),2)->getValue()!=null) {
												$auxilios['contenido']=$workSheet->getCellByColumnAndRow((11+$i),2)->getValue().';'.str_replace('$','',str_replace('.','',str_replace(',','',$workSheet->getCellByColumnAndRow((11+$i),$row)->getValue())));
												// ...
												$this->mFichaSDG->registrarModificarInfoSAuxiliosM(0,0,0,$auxilios);
												// ...	
											}
										}
									    // Informacion de estudios
									    $estudios['documento']=$empleado['documento'];
									    $estudios['grado_Escolaridad']=($workSheet->getCellByColumnAndRow(17,$row)->getValue());
									    $estudios['TituloP']=($workSheet->getCellByColumnAndRow(18,$row)->getValue());
									    $estudios['Especializacion']=($workSheet->getCellByColumnAndRow(19,$row)->getValue());
									    $estudios['estudiaA']=($workSheet->getCellByColumnAndRow(20,$row)->getValue());
									    $estudios['que_estudia']=($workSheet->getCellByColumnAndRow(21,$row)->getValue());
									    $estudios['Titulo_del_Estudio']=($workSheet->getCellByColumnAndRow(22,$row)->getValue());
									    $estudios['accion']=1;
									    // var_dump($estudios);
									    // Registrar o actualizar estudios
									    $idFichaSDG['idEstudio']=$this->mFichaSDG->registrarModificarEstudiosM($estudios);
									    // Informacion laboral
									    $laboral['horario']=$workSheet->getCellByColumnAndRow(23,$row)->getValue();
									    $laboral['contrato']=$workSheet->getCellByColumnAndRow(24,$row)->getValue();
									    $laboral['cargo']=$workSheet->getCellByColumnAndRow(25,$row)->getValue();
									    $laboral['personal_aCargo']=$workSheet->getCellByColumnAndRow(26,$row)->getValue();
									    //$laboral['fecha_vencimiento_contrato']=($workSheet->getCellByColumnAndRow(27,$row)->getValue()!=''?$this->formatoFecha($workSheet->getCellByColumnAndRow(27,$row)->getValue()):"0000-00-00");
									    //$laboral['fecha_vencimiento_contrato']=($workSheet->getCellByColumnAndRow(27,$row)->getValue()!=''?date("Y-m-d", PHPExcel_Shared_Date::ExcelToPHP($workSheet->getCellByColumnAndRow(27,$row)->getValue())):"0000-00-00");
									    // $dato=$workSheet->getCellByColumnAndRow(27,$row)->getValue()=="";
									    // $dato="Hola mundo";
									    // echo $dato;
									    //... 
									    $laboral['fecha_vencimiento_contrato']=($workSheet->getCellByColumnAndRow(27,$row)->getFormattedValue()==''?'':$this->formatoFecha($workSheet->getCellByColumnAndRow(27,$row)->getFormattedValue()));
									    $laboral['area_trabajo']=$workSheet->getCellByColumnAndRow(28,$row)->getValue();
									    $laboral['clasificacion_contable']=$workSheet->getCellByColumnAndRow(29,$row)->getValue();
									    $laboral['documento']=$empleado['documento'];
									    $laboral['accion']=1;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
									    // Registrar Registrar o actualizar informacion laboral
									    $idFichaSDG['idLaboral']=$this->mFichaSDG->registrarModificarInfoLaboralM($laboral);
									    // Informacion secundaria basica
									    $secundaria['estadoCivil']=$workSheet->getCellByColumnAndRow(30,$row)->getValue();
									    //$secundaria['fecha_Nacimiento']=($workSheet->getCellByColumnAndRow(31,$row)->getValue()!=''?$this->formatoFecha($workSheet->getCellByColumnAndRow(31,$row)->getValue()):"0000-00-00");
									    // var_dump($this->formatoFecha($workSheet->getCellByColumnAndRow(31,$row)->getValue()));
									    $secundaria['fecha_Nacimiento']=($workSheet->getCellByColumnAndRow(31,$row)->getFormattedValue()==''?'':$this->formatoFecha($workSheet->getCellByColumnAndRow(31,$row)->getFormattedValue()));
									    //var_dump(date("Y-m-d", PHPExcel_Shared_Date::ExcelToPHP($secundaria['fecha_Nacimiento'])));
									    $secundaria['lugar_Nacimiento']=$workSheet->getCellByColumnAndRow(32,$row)->getValue();
									    $secundaria['tipoSangre']=$workSheet->getCellByColumnAndRow(33,$row)->getValue();
									    $secundaria['telefono_Fijo']=$workSheet->getCellByColumnAndRow(34,$row)->getValue();
									    $secundaria['telefono_celular']=$workSheet->getCellByColumnAndRow(35,$row)->getValue();
									    $secundaria['EPS']=$workSheet->getCellByColumnAndRow(36,$row)->getValue();
									    $secundaria['AFP']=$workSheet->getCellByColumnAndRow(37,$row)->getValue();
									    $personal['altura']=$workSheet->getCellByColumnAndRow(38,$row)->getValue();
									    $personal['peso']=$workSheet->getCellByColumnAndRow(39,$row)->getValue();//El peso no lo esta registrando ni actualizando
									    $secundaria['documento']=$empleado['documento'];
									    $secundaria['accion']=1;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
									    // Registrar Registrar o actualizar informacion secundaria basica
									    $idFichaSDG['idSecundariaB']=$this->mFichaSDG->registrarModificarInfoSegundariaM($secundaria);
									    // Informacion de salud
									    $salud['cigarrillos']=$workSheet->getCellByColumnAndRow(40,$row)->getValue();
									    $salud['alcohol']=$workSheet->getCellByColumnAndRow(41,$row)->getValue();
									    $salud['ante_una_emergencia']=$workSheet->getCellByColumnAndRow(42,$row)->getValue();
									    $salud['documento']=$empleado['documento'];
									    $salud['accion']=1;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
									    //Registrar actualizar informacion de salud del empleado
									    $idFichaSDG['idSauld']=$this->mFichaSDG->registrarModificarInfoSaludM($salud);
									    // Informacion personal
									    $personal['direccion']=str_replace(' ',';',$workSheet->getCellByColumnAndRow(43,$row)->getValue());
									    $personal['barrio']=$workSheet->getCellByColumnAndRow(44,$row)->getValue();
									    $personal['comuna']=$workSheet->getCellByColumnAndRow(45,$row)->getValue();
									    $personal['municipio']=$workSheet->getCellByColumnAndRow(46,$row)->getValue();
									    $personal['estrato']=$workSheet->getCellByColumnAndRow(47,$row)->getValue();
									    $personal['pesona_emergencia']=$workSheet->getCellByColumnAndRow(48,$row)->getValue();
									    $personal['parentezco']=$workSheet->getCellByColumnAndRow(49,$row)->getValue();
									    $personal['telefono']=$workSheet->getCellByColumnAndRow(50,$row)->getValue();
									    $personal['tipo_vivienda']=$workSheet->getCellByColumnAndRow(51,$row)->getValue();
									    $personal['otras_Actividades']=$workSheet->getCellByColumnAndRow(52,$row)->getValue();
									    $personal['documento']=$empleado['documento'];
									    $personal['accion']=1;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
									    // Registrar o modificar informacion personal del empleado
									    $idFichaSDG['idPersonal']=$this->mFichaSDG->registrarModificarInfoPersonalM(0,$personal);

									    // Actividades en tiempo libre Validacion de los campos nulos esta pendiente
									    $k= array("BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO");//Catorce actividades de pueden realizar
									    $actividades=[];
									    $accion['accion']=1;
									    $accion['idPersonal']=$idFichaSDG['idPersonal'];
									    for ($i=0; $i <14; $i++) {
									    	if ($workSheet->getCellByColumnAndRow((53+$i),2)->getValue()!=null) {
									    		// ...
									    		if (strtoupper($workSheet->getCellByColumnAndRow((53+$i),$row)->getValue())=="SI") {
									    			$actividad=$workSheet->getCellByColumnAndRow((53+$i),2)->getValue().';'.$workSheet->getCellByColumnAndRow((53+$i),$row)->getValue();
									    			// ...
									    			$this->mFichaSDG->registrarModificarActividadesInfoPersonalM($empleado['documento'],$actividad,$accion);
									    		}
									    	}
									    }
									    // Personas con las que vive
									    // $documento,$nombre,$idParentezco,$celular,$fechaN,$viveE,$cantidad,$dato,$idPersonal
									    // Madre
									    $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',1,'','','0',1,$workSheet->getCellByColumnAndRow(67,$row)->getValue(),$accion['idPersonal']));
									    // Padre
									    $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',2,'','','0',1,$workSheet->getCellByColumnAndRow(68,$row)->getValue(),$accion['idPersonal']));
									    // // Acompañante indice 0=nombre y 1= telefono
									    if ($workSheet->getCellByColumnAndRow(69,$row)->getValue()!='') {
									    	// ...
									    	$datosA= explode('-',$workSheet->getCellByColumnAndRow(69,$row)->getValue());
									    	// ...
									    	// var_dump($datosA);
					                        $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],$datosA[0],3,$datosA[1],'','0',1,'1',$accion['idPersonal']));
									    }else{
									    	// ...
									    	$this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',3,'','','0',1,'',$accion['idPersonal']));
									    }
									    // // Abuelos
									    $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',4,'','','0',$workSheet->getCellByColumnAndRow(70,$row)->getValue(),$workSheet->getCellByColumnAndRow(70,$row)->getValue(),$accion['idPersonal']));

									    // // Tios
									    $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',5,'','','0',$workSheet->getCellByColumnAndRow(71,$row)->getValue(),$workSheet->getCellByColumnAndRow(71,$row)->getValue(),$accion['idPersonal']));

									    // // Hermanos
									    $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',6,'','','0',$workSheet->getCellByColumnAndRow(72,$row)->getValue(),$workSheet->getCellByColumnAndRow(72,$row)->getValue(),$accion['idPersonal']));

									    // otros
									    $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],'',7,'','','0',$workSheet->getCellByColumnAndRow(73,$row)->getValue(),$workSheet->getCellByColumnAndRow(73,$row)->getValue(),$accion['idPersonal']));

									    // Solo se registrara los hijos a las personas que apenas se les va a registrar una ficha SDG
									    // si la ficha SDG ya esta registrada no se podra registrar los hijos en el sistema de información
									    $existeFicha= $this->mFichaSDG->consultarIDFichasSDG($empleado['documento']);
									    // Hijos se puede hacer en un ciclo for para recorrer los 6 hijos 74 -98
									    if ($existeFicha=='') {
									    	$hijos=0;
									    	for ($i=0; $i < 6; $i++) {
									    		$hijo['name_hijo']=$workSheet->getCellByColumnAndRow((74+$hijos),$row)->getValue();
									    		$hijo['fecha_nacimietno_hijo']=($workSheet->getCellByColumnAndRow(75+$hijos,$row)->getFormattedValue()==''?'':$this->formatoFecha($workSheet->getCellByColumnAndRow(75+$hijos,$row)->getFormattedValue()));
									    		$hijo['vive_empleado_hijo']=($workSheet->getCellByColumnAndRow((76+$hijos),$row)->getValue()=='SI'?1:0);
									    		// ...
									    	    if ($hijo['name_hijo']!='' && $hijo['fecha_nacimietno_hijo']!='') {
									    	    	// Registrar Hijos
									    	    	$this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],$hijo['name_hijo'],8,'',$hijo['fecha_nacimietno_hijo'],$hijo['vive_empleado_hijo'],1,'1',$accion['idPersonal']));
									    	    } 
									  			// ...
									    		$hijos+=4;	
									    	}
									    }
									    // Esto se puede optimizar en un solo block de código
									    // //Hijastros de pueden hacer con un ciclo for para recorrer los 6 hijastros de 99 - 121
									    // Si la ficha SDG ya esta registrada no se podra registrar los hijastros en el sistema de información
									      if ($existeFicha=='') {
									      	$hijos=0;
									      	for ($i=0; $i < 6; $i++) {
									      		$hijo['name_hijo']=$workSheet->getCellByColumnAndRow((98+$hijos),$row)->getValue();
									      		$hijo['fecha_nacimietno_hijo']=($workSheet->getCellByColumnAndRow(100+$hijos,$row)->getFormattedValue()==''?'':$this->formatoFecha($workSheet->getCellByColumnAndRow(100+$hijos,$row)->getFormattedValue()));
									      		$hijo['vive_empleado_hijo']=($workSheet->getCellByColumnAndRow((100+$hijos),$row)->getValue()=='SI'?1:0);
									      		// ...
									      	    if ($hijo['name_hijo']!=null && $hijo['fecha_nacimietno_hijo']!=null) {
									      	    	// Registrar Hijos
									      	    	$res= $this->mFichaSDG->registrarModificarPersonasViveM($this->generarContenidoModeloFamiliares($empleado['documento'],$hijo['name_hijo'],9,'',$hijo['fecha_nacimietno_hijo'],$hijo['vive_empleado_hijo'],1,'1',$accion['idPersonal']));
									      	    } 
									    		// ...
									      		$hijos+=4;	
									      	}
									      }
									    // ...
									    // Otra informacion del empleado
									    $otraInfo['talla_camisa']=$workSheet->getCellByColumnAndRow(122,$row)->getValue();
									    $otraInfo['talla_pantalon']=$workSheet->getCellByColumnAndRow(123,$row)->getValue();
									    $otraInfo['talla_zapatos']=$workSheet->getCellByColumnAndRow(124,$row)->getValue();
									    $otraInfo['vigencia_curso_alturas']=$workSheet->getCellByColumnAndRow(125,$row)->getValue();
									    $otraInfo['RequiereCursoA']=$workSheet->getCellByColumnAndRow(126,$row)->getValue()=='SI'?1:0;
									    $otraInfo['perteneceCurso']=$workSheet->getCellByColumnAndRow(127,$row)->getValue()=='SI'?1:0;
									    $otraInfo['comites']=$workSheet->getCellByColumnAndRow(128,$row)->getValue()=='SI'?1:0;
									    $otraInfo['documento']=$empleado['documento'];
									    $otraInfo['accion']=1;//esta variable me ayuda a saber por que medio van a ser registrado la FSDG por medio de la vista o por medio de un Excel
									    // Registrar o modificar otra informacion del empleado
									    $idFichaSDG['idOtros']=$this->mFichaSDG->registrarModificarOtraInformacion($otraInfo);

									    // Registrar la fichas SDG del empleado...
									    $idFichaSDG['documento']=$empleado['documento'];
									    $estadoEmp['existe']= $existeFicha;
									    $ficha=$this->mFichaSDG->registrarFichaSDGM($idFichaSDG);
									    $es=0;
									    $estadoEmp['accion']=1;
									    // Si la ficha SDG ya esta registrada en el sistema de información no se pueden registrar los estados empresariales
									    // si la ficha SDG no esta registrada en el sistema de informacion se podra registrar todos lo estados empresariales.
									    // var_dump($existeFicha);
									    //...
									    // if ($existeFicha!='') {
									    	for ($i=0; $i < 5; $i++) { //Pendiente la validacion de campos de los estados empresariales, cuales son obligatorios
									    		  // Estados empresariales esto se puede hacer en un ciclo for para recorrer los 5 estados de 129 - 156
									    			// var_dump($workSheet->getCellByColumnAndRow((129+$es),$row)->getValue());

									    			if ($workSheet->getCellByColumnAndRow((129+$es),$row)->getValue()!='') {
									    				$estadoEmp['idEsatoE']=($workSheet->getCellByColumnAndRow((129+$es),$row)->getValue()=='Vigente'?2:1);
									    				$estadoEmp['rotacion']=$workSheet->getCellByColumnAndRow((130+$es),$row)->getValue();
									    				$estadoEmp['motivo']=$workSheet->getCellByColumnAndRow((131+$es),$row)->getValue();
									    				// -.-.
									    				$estadoEmp['impacto']=0;
									    				for ($j=0; $j < 3; $j++) {
									    					# ... 132 - 133 -134
									    					if ($workSheet->getCellByColumnAndRow((132+$es+$j),$row)->getValue()) {
									    						// ...
									    						$estadoEmp['impacto']=$j+1;
									    						// ...
									    					}
									    				    #...
									    				}
									    				// -.-.-
									    				$estadoEmp['empresa']=$workSheet->getCellByColumnAndRow((135+$es),$row)->getValue(); 
									    				//$estadoEmp['fechaI']=($workSheet->getCellByColumnAndRow((136+$es),$row)->getValue()!=''?$this->formatoFecha($workSheet->getCellByColumnAndRow((136+$es),$row)->getValue()):"0000-00-00");
														//$estadoEmp['fechaI']=($workSheet->getCellByColumnAndRow((136+$es),$row)->getValue()!=''?date("Y-m-d", PHPExcel_Shared_Date::ExcelToPHP($workSheet->getCellByColumnAndRow((136+$es),$row)->getValue())):"0000-00-00");
														// var_dump($workSheet->getCellByColumnAndRow(136+$es,$row)->getFormattedValue());
														//...
														$estadoEmp['fechaI']=($workSheet->getCellByColumnAndRow(136+$es,$row)->getFormattedValue()==''?'':$this->formatoFecha($workSheet->getCellByColumnAndRow(136+$es,$row)->getFormattedValue()));
									    				//$estadoEmp['fechaR']=($workSheet->getCellByColumnAndRow((137+$es),$row)->getValue()!=''?$this->formatoFecha($workSheet->getCellByColumnAndRow((137+$es),$row)->getValue()):"0000-00-00");
									    				// var_dump($workSheet->getCellByColumnAndRow(137+$es,$row)->getFormattedValue());
									    				//...
									    				$estadoEmp['fechaR']=($workSheet->getCellByColumnAndRow(137+$es,$row)->getFormattedValue()==''?'':$this->formatoFecha($workSheet->getCellByColumnAndRow(137+$es,$row)->getFormattedValue()));
														//$estadoEmp['fechaR']=date("Y-m-d",PHPExcel_Shared_Date::ExcelToPHP($workSheet->getCellByColumnAndRow((137+$es),$row)->getValue()));
									    				$estadoEmp['descripcion']=$workSheet->getCellByColumnAndRow((139+$es),$row)->getValue();
									    				$estadoEmp['estado']=1;
									    			    // var_dump($estadoEmp);
									    			    $retirar= $this->mFichaSDG->registrarModificarEstadoEmpresarialM($ficha,$estadoEmp);
									    			    //
									    			    // var_dump($retirar);
									    			    // ...
									    			    if ($retirar==-1) {
									    			    	// Salir del ciclo que registra lo estado empresariales
									    			    	break;
									    			    }
									    			}
									    			$es+=11;
									    	}
									    // }
									    //var_dump($empleado['nombre_empleado']);
									//...
								}else{
									$conPersona++;
								}
							} 
						}
				}else{
					// echo $dato1.' '.$dato2;
					// echo -1;
					break;
				}
			}
			//var_dump($conPersona);
		}

		echo ($ingreso==1?json_encode($idFichaSDG):-1);
		// echo $dato;
	}

	public function generarContenidoModeloFamiliares($documento,$nombre,$idParentezco,$celular,$fechaN,$viveE,$cantidad,$dato,$idPersonal)
	{	
		$info['idPersonal']=$idPersonal;
		$info['documento']=$documento;
		$info['accion']=1;
		$info['nombreC']=$nombre;
		$info['idParentezcos']=$idParentezco;
		$info['celular']=$celular;
		$info['fechaN']=$fechaN;
		$info['viveE']=$viveE;
		$info['cantidad']=$cantidad;
		$info['dato']=$dato;//Este valor siempre tiene que ser numerico

		return $info;
	}

	public function exportarXLSX1()
	{
					$this->load->model('Empleado/mEmpleado');

					header("Content-Type: text/html;charset=utf-8");

		            require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
				    require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

				    $objExcelPHP= new PHPExcel();

				    $objExcelPHP->getProperties()->setCreator("");
				    $objExcelPHP->getProperties()->setLastModifiedBy("");
				    $objExcelPHP->getProperties()->setTitle("");
				    $objExcelPHP->getProperties()->setSubject("");
				    $objExcelPHP->getProperties()->setDescription("");

				    $objExcelPHP->setActiveSheetIndex(0);

				    $empleados= $this->mEmpleado->consultarEmpleadosM('');

				    $estilo = array( 
				      'borders' => array(
				        'outline' => array(
				          'style' => PHPExcel_Style_Border::BORDER_THIN
				        )
				      )
				    );
				    // 
				    $cont=2;
				    // ...
				    $objExcelPHP->getActiveSheet()->getStyle('B1:GB2')->getFont()->setBold(true);
				    // Empleado
				    $objExcelPHP->getActiveSheet()->setCellValue('B1', 'Empleados');
				    // $objExcelPHP->getActiveSheet()->mergeCells('B1:G1');
				    // Numero de Documentos...
				    $objExcelPHP->getActiveSheet()->setCellValue('B2', '*Documento:');
				    // Nombre del empleado
				    $objExcelPHP->getActiveSheet()->setCellValue('C2', '*Nombre completo:');
				    // Sexo
				    $objExcelPHP->getActiveSheet()->setCellValue('D2', '*Sexo:');
				    // Correo
				    $objExcelPHP->getActiveSheet()->setCellValue('E2', '*Correo:');
				    // Piso de ubicación
				    $objExcelPHP->getActiveSheet()->setCellValue('F2', '*Empresa:');
				    // Estado
				    $objExcelPHP->getActiveSheet()->setCellValue('G2', 'Estado:');
				    // $objExcelPHP->getActiveSheet()->getStyle('B1:G2')->applyFromArray($estilo);

				    // Informacion salarial
				    $objExcelPHP->getActiveSheet()->setCellValue('H1', 'Información Salarial');
				    // $objExcelPHP->getActiveSheet()->mergeCells('H1:K1');
				    // Promedio salarial
				    $objExcelPHP->getActiveSheet()->setCellValue('H2', 'Promedio salarial:');
				    // Clasificación mega
				    $objExcelPHP->getActiveSheet()->setCellValue('I2', 'Clasificación mega:');					
				    // Calario basico monto
					$objExcelPHP->getActiveSheet()->setCellValue('J2', '*Salario Basico:');
				    // Total
					$objExcelPHP->getActiveSheet()->setCellValue('K2', 'Total:');
					// $objExcelPHP->getActiveSheet()->getStyle('H1:K2')->applyFromArray($estilo);
				    // Auxilios
				    $this->load->model('Empleado/FichaSDG/mConfiguracionFicha');
				    $objExcelPHP->getActiveSheet()->setCellValue('L1', 'Auxilios');
				    // $objExcelPHP->getActiveSheet()->mergeCells('L1:Q1');
				    // Consultar auxilios
				    $tiposAuxilio= $this->mConfiguracionFicha->consultarInformacionM(1,3);
				    // 
				    $v= array("L","M","N","O","P","Q");
				    $v1=[];
				    // 
				    $indice=0;	
				    foreach ($tiposAuxilio as $tipo) {
				    	// ...
				    	$objExcelPHP->getActiveSheet()->setCellValue($v[$indice].$cont, $tipo->auxilio);
				    	$v1[$tipo->auxilio]=$v[$indice];
				    	$indice++;
				    }
				    // $objExcelPHP->getActiveSheet()->getStyle('L1:Q2')->applyFromArray($estilo);
				    // Estudios
				    $objExcelPHP->getActiveSheet()->setCellValue('R1', 'Información Estudios');
				    // $objExcelPHP->getActiveSheet()->mergeCells('R1:W1');
				    // Grado de escolaridad...
				    $objExcelPHP->getActiveSheet()->setCellValue('R2', '*Grado de escolaridad:');
				    // Titulo profecional
				    $objExcelPHP->getActiveSheet()->setCellValue('S2', 'Titulo profesional');
				    // Titulo especialización
				    $objExcelPHP->getActiveSheet()->setCellValue('T2', 'Titulo especialización');
				    // Estudia actualmente?
				    $objExcelPHP->getActiveSheet()->setCellValue('U2', 'Estudia actualmente?');
				    // Titulo de estudio
				    $objExcelPHP->getActiveSheet()->setCellValue('V2', '¿Qué estudia?');
				    // Nombre de la carrera
				    $objExcelPHP->getActiveSheet()->setCellValue('W2', 'nombre de la carrera');
				    // $objExcelPHP->getActiveSheet()->getStyle('R1:W2')->applyFromArray($estilo);
				    // ...
				    // Información Laboral
				    $objExcelPHP->getActiveSheet()->setCellValue('X1', 'Información Laboral');
				    // $objExcelPHP->getActiveSheet()->mergeCells('HX:AD1');
				   // Horario de trabajo
				   $objExcelPHP->getActiveSheet()->setCellValue('X2', '*Horario de trabajo:');
				   // Tipo de contrato 
				   $objExcelPHP->getActiveSheet()->setCellValue('Y2', '*Tipo de contrato:');
				   // Cargo a desempeñar
				   $objExcelPHP->getActiveSheet()->setCellValue('Z2', '*Cargo a desempeñar:');
				   // Personal a cargo
				   $objExcelPHP->getActiveSheet()->setCellValue('AA2', 'Personal a cargo:');
				   // Fecha de vencimiento de contrato
				   $objExcelPHP->getActiveSheet()->setCellValue('AB2', 'Fecha de vencimiento de contrato:');
				   // Área de trabajo
				   $objExcelPHP->getActiveSheet()->setCellValue('AC2', '*Área de trabajo:');
				   // Clasificación contable
				   $objExcelPHP->getActiveSheet()->setCellValue('AD2', '*Clasificacion contable:');
				   // $objExcelPHP->getActiveSheet()->getStyle('X1:AD2')->applyFromArray($estilo);
				   // Información secundaria basica
				   $objExcelPHP->getActiveSheet()->setCellValue('AE1', 'Información Secundaria Basica');
				    // $objExcelPHP->getActiveSheet()->mergeCells('AE1:AN1');
				   // Estado civil
				   $objExcelPHP->getActiveSheet()->setCellValue('AE2', '*Estado civil');
				   // Fecha de nacimiento
				   $objExcelPHP->getActiveSheet()->setCellValue('AF2', '*Fecha de nacimiento:');
				   // Lugar de nacimiento
				   $objExcelPHP->getActiveSheet()->setCellValue('AG2', '*Lugar de nacimiento:');
				   // Tipo de sangre
				   $objExcelPHP->getActiveSheet()->setCellValue('AH2', '*Tipo de sangre:');
				   // Telefono fijo
				   $objExcelPHP->getActiveSheet()->setCellValue('AI2', 'Telefono fijo');
				   // Telefono celular
				   $objExcelPHP->getActiveSheet()->setCellValue('AJ2', 'Telefono celular:');
				   // EPS
				   $objExcelPHP->getActiveSheet()->setCellValue('AK2', '*EPS:');
				   // AFP
				   $objExcelPHP->getActiveSheet()->setCellValue('AL2', '*AFP:');
				   // Talla del empleado
				   $objExcelPHP->getActiveSheet()->setCellValue('AM2', 'Talla:');
				   // Peso del empleado
				   $objExcelPHP->getActiveSheet()->setCellValue('AN2', 'Peso:');
				   // $objExcelPHP->getActiveSheet()->getStyle('AE1:AN2')->applyFromArray($estilo);
				   // Salud
				   $objExcelPHP->getActiveSheet()->setCellValue('AO1', 'Información de Salud');
				   // $objExcelPHP->getActiveSheet()->mergeCells('AO1:AQ1');
				   // Consumo de cigarrillos por día
				   $objExcelPHP->getActiveSheet()->setCellValue('AO2', '# cigarrillos día:');
				   // Frecuencia con la que consume alcohol
				   $objExcelPHP->getActiveSheet()->setCellValue('AP2', 'Frecuencia toma de alcohol');
				   // ANTE UNA EMERGENCIA, EN CASO DE REQUERIR SER ATENDIDO POR LA BRIGADA O UNA EPS TIENE ALGUNA CONDICION ESPECIAL?
				   $objExcelPHP->getActiveSheet()->setCellValue('AQ2', 'ANTE UNA EMERGENCIA, EN CASO DE REQUERIR SER ATENDIDO POR LA BRIGADA O UNA EPS TIENE ALGUNA CONDICION ESPECIAL?');
				   // $objExcelPHP->getActiveSheet()->getStyle('AO1:AQ2')->applyFromArray($estilo);
				   // Informacion personal
				   $objExcelPHP->getActiveSheet()->setCellValue('AR1', 'Información Personal');
				   // $objExcelPHP->getActiveSheet()->mergeCells('AR1:BA1');
				   // Direecion de la casa donde vive
				   $objExcelPHP->getActiveSheet()->setCellValue('AR2', 'Dirección');
				   // Barrio
				   $objExcelPHP->getActiveSheet()->setCellValue('AS2', '*Barrio');
				   // Comuna
				   $objExcelPHP->getActiveSheet()->setCellValue('AT2', 'Comuna');
				   // Municipio
				   $objExcelPHP->getActiveSheet()->setCellValue('AU2', '*Municipio');
				   // Estrato
				   $objExcelPHP->getActiveSheet()->setCellValue('AV2', 'Estrato');
				   // Persona a contactar en caso de emergencia
				   $objExcelPHP->getActiveSheet()->setCellValue('AW2', '*Persona de contacto en caso de emergencia');
				   // Parentezco
				   $objExcelPHP->getActiveSheet()->setCellValue('AX2', '*Parentezco');
				   // Telefono
				   $objExcelPHP->getActiveSheet()->setCellValue('AY2', '*Telefono');
				   // Tipo de vivienda
				   $objExcelPHP->getActiveSheet()->setCellValue('AZ2', '*Tipo de vivienda');
				   // Otras actividades que realiza en el tiempo libre
				   $objExcelPHP->getActiveSheet()->setCellValue('BA2', 'Otras actividades que realiza');
				   // $objExcelPHP->getActiveSheet()->getStyle('AR1:BA2')->applyFromArray($estilo);
				   // ...
				   $objExcelPHP->getActiveSheet()->setCellValue('BB1', 'Actividades en tiempos libres');
				   // $objExcelPHP->getActiveSheet()->mergeCells('BB1:BO1');
				   // Consulta las actividade de tiempo libre
				   $tipoActividades= $this->mConfiguracionFicha->consultarInformacionM(1,12);
				   // 
				   $k= array("BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO");
				   $k1=[];
				   // 
				   $indice=0;	
				   foreach ($tipoActividades as $tipo) {
				   	// ...
				   	    $objExcelPHP->getActiveSheet()->setCellValue($k[$indice].$cont, $tipo->nombre);
				     	$k1[$tipo->nombre]=$k[$indice];
				   	    $indice++;
				   }
				   // $objExcelPHP->getActiveSheet()->getStyle('BB1:BO2')->applyFromArray($estilo);
				   //...
				   $objExcelPHP->getActiveSheet()->setCellValue('BP1', 'Personas con las que vive');
				   // $objExcelPHP->getActiveSheet()->mergeCells('BP1:BV1');
				   //ConsultarPersonas con las que vive (Madre, Padre, Acompañante, Abuelos, Tios, Hermanos,Otros) Los hijos 
				   $parent= array("Madre"=>"BP","Padre"=>"BQ","Comprometido/a"=>"BR","Abuelos"=>"BS","Tios"=>"BT","Hermanos"=>"BU","Otros"=>"BV");
				   // Madre
				   $objExcelPHP->getActiveSheet()->setCellValue('BP2', 'Madre');
				   // Padre
				   $objExcelPHP->getActiveSheet()->setCellValue('BQ2', 'Padre');
				   // Acompañante
				   $objExcelPHP->getActiveSheet()->setCellValue('BR2', 'Comprometido/a');
				   // Abuelos
				   $objExcelPHP->getActiveSheet()->setCellValue('BS2', 'Abuelos');
				   // Tios
				   $objExcelPHP->getActiveSheet()->setCellValue('BT2', 'Tios');
				   // Hermanos
				   $objExcelPHP->getActiveSheet()->setCellValue('BU2', 'Hermano');
				   // Otros
				   $objExcelPHP->getActiveSheet()->setCellValue('BV2', 'Otros');
				   // 
				   // $objExcelPHP->getActiveSheet()->getStyle('BP1:BV2')->applyFromArray($estilo);
				   // Esta disponible para colocar 6 hijos
				  $objExcelPHP->getActiveSheet()->setCellValue('BW1', 'Hijos');
				  $hijos = array('BW','BX','BY','BZ','CA','CB','CC','CD','CE','CF','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP','CQ','CR','CS','CT');
				  $conHijos=-1;
 				  for ($i=0; $i < 6; $i++) {
				  	$objExcelPHP->getActiveSheet()->setCellValue($hijos[(++$conHijos)].'2', 'Nombre');
				  	$objExcelPHP->getActiveSheet()->setCellValue($hijos[(++$conHijos)].'2', 'Fecha nacimiento');
				  	$objExcelPHP->getActiveSheet()->setCellValue($hijos[(++$conHijos)].'2', 'Vive empleado?');
				  	$objExcelPHP->getActiveSheet()->setCellValue($hijos[(++$conHijos)].'2', 'Edad');
				  }
				  // Esta disponible para colocar 6 hijastros
				  $objExcelPHP->getActiveSheet()->setCellValue('CU1', 'Hijastros'); 
				  $hijastros = array('CU','CV','CW','CX','CY','CZ','DA','DB','DC','DD','DE','DF','DG','DH','DI','DJ','DK','DL','DM','DN','DO','DP','DQ','DR');
				  $conHijastros=-1;
				  for ($i=0; $i < 6; $i++) {
				    $objExcelPHP->getActiveSheet()->setCellValue($hijastros[(++$conHijastros)].'2', 'Nombre');
				    $objExcelPHP->getActiveSheet()->setCellValue($hijastros[(++$conHijastros)].'2', 'Fecha nacimiento');
				    $objExcelPHP->getActiveSheet()->setCellValue($hijastros[(++$conHijastros)].'2', 'Vive empleado?');
				    $objExcelPHP->getActiveSheet()->setCellValue($hijastros[(++$conHijastros)].'2', 'Edad');
				  }
				  // Otra información
				  $objExcelPHP->getActiveSheet()->setCellValue('DS1', 'Otra informacion');
				  // Talla camisa
				  $objExcelPHP->getActiveSheet()->setCellValue('DS2', 'Talla camisa');
				  // Talla pantalon
				  $objExcelPHP->getActiveSheet()->setCellValue('DT2', 'Talla Pantalon');
				  // Talla de zapatos
				  $objExcelPHP->getActiveSheet()->setCellValue('DU2', 'Talla zapatos');
				  // Vigencia curso de alturas
				  $objExcelPHP->getActiveSheet()->setCellValue('DV2', 'Vigencia curso de alturas');
				  // Rquiere o tiene el curso de alturas
				  $objExcelPHP->getActiveSheet()->setCellValue('DW2', 'Requiere o tiene el curso de alturas');
				  // Ha pertenecido a una brigada de emergencia
				  $objExcelPHP->getActiveSheet()->setCellValue('DX2', 'Ha pertenecido a una brigada de emergencia');
				  // Ha estado en algun comité de las empresas
				  $objExcelPHP->getActiveSheet()->setCellValue('DY2', 'Ha estado en algún comité de las empresas');
				  // Informacion de los estados empresariales
				  // Esta disponible para colocar 5 estados
				  $objExcelPHP->getActiveSheet()->setCellValue('DZ1', 'Estados empresariales'); 
				  $estadoEmpresariales = array('DZ','EA','EB','EC','ED','EE','EF','EG','EH','EI','EJ','EK','EL','EM','EN','EO','EP','EQ','ER','ES','ET','EU','EV','EW','EX','EY','EZ','FA','FB','FC','FD','FE','FF','FG','FH','FI','FJ','FK','FL','FM','FN','FO','FP','FQ','FR','FS','FT','FU','FV','FW','FX','FY','FX','FZ','GA','GB');
				  $estadosE=-1;
				  for ($i=0; $i < 5; $i++) {//Pendiente-->
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Estado Empresarial');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'IDC Rotacion');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Motivo');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Bajo impacto');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Sin impacto');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Alto impacto');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Empresa');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Fecha ingreso');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Fecha de retiro');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Antiguedad');
				    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].'2', 'Observación retiro');
				  }
				  // Otra información

// Cuerpo del excel>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<
				    $cont++;
				    foreach ($empleados as $empleado) {
				    	// Numero de Documentos...
				    	$objExcelPHP->getActiveSheet()->setCellValue('B'.$cont, $empleado->documento);
				    	// Nombre del empleado
				    	// var_dump(($empleado->nombre1!=''?ucwords(strtolower($empleado->nombre1)):'').' '.($empleado->nombre2!=''?ucwords(strtolower($empleado->nombre2)):'').' '.($empleado->apellido1!=''?ucwords(strtolower($empleado->apellido1)):'').' '.($empleado->apellido2!=''?ucwords(strtolower($empleado->apellido2)):''));
				    	// ...
				    	$objExcelPHP->getActiveSheet()->setCellValue('C'.$cont, ($empleado->nombre1!=''?ucwords(($empleado->nombre1)):'').' '.($empleado->nombre2!=''?ucwords(($empleado->nombre2)):'').' '.($empleado->apellido1!=''?ucwords(($empleado->apellido1)):'').' '.($empleado->apellido2!=''?ucwords(($empleado->apellido2)):''));
				    	// Sexo
				    	$objExcelPHP->getActiveSheet()->setCellValue('D'.$cont, ($empleado->genero==1?'Masculino':'Femenino'));
				    	// Correo
				    	$objExcelPHP->getActiveSheet()->setCellValue('E'.$cont, $empleado->correo);
				    	// Piso de ubicación
				    	$objExcelPHP->getActiveSheet()->setCellValue('F'.$cont, $empleado->nombre);
				    	// Estado
				    	$objExcelPHP->getActiveSheet()->setCellValue('G'.$cont, ($empleado->estado==1?'Activo':'Desactivado'));
				    	// Consultar Informacion salarial
				    	$estadoSalarial=$this->mFichaSDG->consultarInfoSalarialM($empleado->documento);
				    	// ...
				    	foreach ($estadoSalarial as $salaria) {
				    		// Promedio salarial
				    		$objExcelPHP->getActiveSheet()->setCellValue('H'.$cont, $salaria->nombre);
				    		// Clasificacion Mega
				    		$objExcelPHP->getActiveSheet()->setCellValue('I'.$cont, ($salaria->clasificacion=='0'?'':$salaria->clasificacion));
				    		// Salario Basico
				    		$objExcelPHP->getActiveSheet()->setCellValue('J'.$cont, $salaria->salario_baseico_formato);
				    		// Salario Total
				    		$objExcelPHP->getActiveSheet()->setCellValue('K'.$cont, $salaria->totalFormato);
				    	}
				    	// ...
				    	// Consultar auxilios
				    	$Auxilios= $this->mFichaSDG->consultarAuxiliosM($empleado->documento);
				    	// ...
				    	// $contAu=0;
				    	foreach ($Auxilios as $auxilio) {
				    		// Monto del auxilio
				    		$objExcelPHP->getActiveSheet()->setCellValue(($v1[$auxilio->auxilio].$cont), $auxilio->mondoFormato);
				    	}
				    	// ...
				    	//Consultar Estudios
				    	$estudios= $this->mFichaSDG->consultarInfoEstudiosM($empleado->documento);
				    	// ...
				    	foreach ($estudios as $estudio) {
				    		// Estudios alcanzados
				    		// Grado maximo de escolaridad alcanzada
				    		$objExcelPHP->getActiveSheet()->setCellValue('R'.$cont, $estudio->grado);
				    		// Titulo profesional
				    		$objExcelPHP->getActiveSheet()->setCellValue('S'.$cont, $estudio->titulo_profecional);
				    		// Titulo de especializacion
				    		$objExcelPHP->getActiveSheet()->setCellValue('T'.$cont, $estudio->titulo_especializacion);
				    		// Estudios actuales
				    		// ...
				    		// Estudia actualmente
				    		$objExcelPHP->getActiveSheet()->setCellValue('U'.$cont, ($estudio->titulo_estudios_actuales==0?'NO':'SI'));
				    		// Que estudia actualmente
				    		$objExcelPHP->getActiveSheet()->setCellValue('V'.$cont, $estudio->estudios_actuales);
				    		// Nombre de la carrera que estudia actualmente
				    		$objExcelPHP->getActiveSheet()->setCellValue('W'.$cont, $estudio->nombre_carrera);
				    	}
				    	// ...
				    	// Consultar informacionlaboral
				    	$laboral=$this->mFichaSDG->consultarInfoLaboralM($empleado->documento);
				    	// ...
				    	foreach ($laboral as $labor) {//Inicio for
				    		// Horario de trabajo
				    		$objExcelPHP->getActiveSheet()->setCellValue('X'.$cont, $labor->horario);
				    		// Tipo de contrato
				    		$objExcelPHP->getActiveSheet()->setCellValue('Y'.$cont, $labor->contrato);
				    		// Tipo de contrato
				    		$objExcelPHP->getActiveSheet()->setCellValue('Z'.$cont, $labor->cargo);
				    		//	Tiene personal a cargo
				    		$objExcelPHP->getActiveSheet()->setCellValue('AA'.$cont, ($labor->recurso_humano==1?'SI':'NO'));
				    		// Fecha vencimiento del contrato
				    		$objExcelPHP->getActiveSheet()->setCellValue('AB'.$cont, $labor->fecha_vencimiento_contrato);
				    		// área de trabajo
				    		$objExcelPHP->getActiveSheet()->setCellValue('AC'.$cont, $labor->area);
				    		// clasificacion contable
				    		$objExcelPHP->getActiveSheet()->setCellValue('AD'.$cont, $labor->clasificacion);
				    	}
				    	// ...
				    	// Consultar información secundaria basica
				    	$secundariaB= $this->mFichaSDG->consultarInfoSecundariaBasicaM($empleado->documento);
				    	// ...
				    	foreach ($secundariaB as $segundo) {
				    		// Estado civil
				    		$objExcelPHP->getActiveSheet()->setCellValue('AE'.$cont, $segundo->nombre_estado);
				    		// Fecha de nacimiento
				    		$objExcelPHP->getActiveSheet()->setCellValue('AF'.$cont, $segundo->fecha_nacimiento);
				    		// Lugar de nacimiento
				    		$objExcelPHP->getActiveSheet()->setCellValue('AG'.$cont, $segundo->lugar_nacimiento);
				    		// Tipo de sangre
				    		$objExcelPHP->getActiveSheet()->setCellValue('AH'.$cont, $segundo->sangre);
				    		// Telefono fijo
				    		$objExcelPHP->getActiveSheet()->setCellValue('AI'.$cont, $segundo->tel_fijo);
				    		// Celular
				    		$objExcelPHP->getActiveSheet()->setCellValue('AJ'.$cont, $segundo->celular);
				    		// EPS
				    		$objExcelPHP->getActiveSheet()->setCellValue('AK'.$cont, $segundo->eps);
				    		// AFP
				    		$objExcelPHP->getActiveSheet()->setCellValue('AL'.$cont, $segundo->afp);
				    		// EL peso y la talla se montaran desde la información personal
				    	}
				    	// ...
				    	// Consultar informacion de salud
				    	$saludes= $this->mFichaSDG->consultarInfoSaludM($empleado->documento);
				    	// ...
				    	foreach ($saludes as $salud) {
				    		// Numero de cigarrillos fumados por dia
				    		$objExcelPHP->getActiveSheet()->setCellValue('AO'.$cont, ($salud->fuma>0?$salud->fuma:'0'));
				    		// Consumo de Bevidas alcoholicas
				    		$objExcelPHP->getActiveSheet()->setCellValue('AP'.$cont, ($salud->alcohol=='0'?'':$salud->alcohol));
				    		// Descripcion en caso de emergencia
				    		$objExcelPHP->getActiveSheet()->setCellValue('AQ'.$cont, $salud->descripccion_emergencia);
				    	}
				    	// ...
				    	// Consultar informacion personal
				    	$personal= $this->mFichaSDG->consultarInfoPersonalM($empleado->documento);
				    	// ...
				    	$idPersona=0;
				    	foreach ($personal as $persona) {
				    		// IDPErsonal
				    		$idPersona=$persona->idPersonal;
				    		// Direccion
				    		$objExcelPHP->getActiveSheet()->setCellValue('AR'.$cont, $persona->direc);
				    		// Barrio
				    		$objExcelPHP->getActiveSheet()->setCellValue('AS'.$cont, $persona->barrio);
				    		// Comuna
				    		$objExcelPHP->getActiveSheet()->setCellValue('AT'.$cont, $persona->comuna);
				    		// Municipio
				    		$objExcelPHP->getActiveSheet()->setCellValue('AU'.$cont, $persona->municipio);
				    		// Estrato
				    		$objExcelPHP->getActiveSheet()->setCellValue('AV'.$cont, $persona->estrato);
				    		// Persona en caso de emergencia
				    		$objExcelPHP->getActiveSheet()->setCellValue('AW'.$cont, $persona->caso_emergencia);
				    		$mensaje='';
				    		switch ($persona->parentezco) {
				    			case 1:
				    				$mensaje='Madre';
				    				break;
				    			case 2:
				    				$mensaje='Padre';
				    				break;
				    			case 3:
				    				$mensaje='Hermano/a';
				    				break;
				    			case 4:
				    				$mensaje='Novio/a, esposo/a';
				    				break;
				    			case 5:
				    				$mensaje='Abuelo/a';
				    				break;
				    			case 6:
				    				$mensaje='Tio/a';
				    				break;
				    			case 7:
				    				$mensaje='Hijo/a';
				    				break;
				    			case 8:
				    				$mensaje='Hijastro/a';
				    				break;
				    			case 9:
				    				$mensaje='Otro';
				    				break;	
				    		}
				    		// Parentezco
				    		$objExcelPHP->getActiveSheet()->setCellValue('AX'.$cont, $mensaje);
				    		// Telefono
				    		$objExcelPHP->getActiveSheet()->setCellValue('AY'.$cont, $persona->tel);
				    		// Tipo de vivienda
				    		$objExcelPHP->getActiveSheet()->setCellValue('AZ'.$cont, $persona->vivienda);
				    		// Otras actividades que realiza en tiempo libre
				    		$objExcelPHP->getActiveSheet()->setCellValue('BA'.$cont, $persona->otraActividad);
				    		// Altura
				    		$objExcelPHP->getActiveSheet()->setCellValue('AM'.$cont, $persona->altura);
				    		// Peso
				    		$objExcelPHP->getActiveSheet()->setCellValue('AN'.$cont, $persona->peso);
				    	}
				    	// ...
				    	// Actividades que realiza en el tiempo libre
				    	$actividadesTiempo= $this->mFichaSDG->consultarActividadesInfoPersonalM($idPersona);
				    	// ...
				    	foreach ($actividadesTiempo as $actividad) {
				    		// Actividad que realiza
				    		$objExcelPHP->getActiveSheet()->setCellValue(($k1[$actividad->nombre].$cont), 'SI');
				    	}
				    	// Personas con las que vive...
				    	$personasVives= $this->mFichaSDG->consultarPersonasViveInfoPersonalM($idPersona);
				    	$conHijos=-1;
				    	$conHijastros=-1;
				    	// $parent
				    	foreach ($personasVives as $persona) {
				    		// 
				    		switch($persona->idParentezco){
				    			case 1://Madre
				    			case 2: //Padre
				    				$objExcelPHP->getActiveSheet()->setCellValue(($parent[$persona->nombre].$cont), 'SI');
				    				break;
				    			case 3://Acompañante
				    				$objExcelPHP->getActiveSheet()->setCellValue(($parent[utf8_decode($persona->nombre)].$cont), $persona->nombreC.' - '.$persona->celular);
				    					break;	
				    			case 4://Abuelos
				    			case 5: //Tios
				    			case 6: //Hermanos
				    			case 7: //Otros
				    				$objExcelPHP->getActiveSheet()->setCellValue(($parent[$persona->nombre].$cont), $persona->cantidad);
				    				break;
				    			case 8://Hijos
				    				$objExcelPHP->getActiveSheet()->setCellValue(($hijos[(++$conHijos)].$cont), $persona->nombreC);
				    				$objExcelPHP->getActiveSheet()->setCellValue(($hijos[(++$conHijos)].$cont), $persona->fecha_nacimiento);
				    				$objExcelPHP->getActiveSheet()->setCellValue(($hijos[(++$conHijos)].$cont), ($persona->vive_empleado==1?'SI':'NO'));
				    				$objExcelPHP->getActiveSheet()->setCellValue(($hijos[(++$conHijos)].$cont), $persona->edad);
				    				break;
				    			case 9://Hijastros 
				    			    $objExcelPHP->getActiveSheet()->setCellValue(($hijastros[(++$conHijastros)].$cont), $persona->nombreC);
				    			    $objExcelPHP->getActiveSheet()->setCellValue(($hijastros[(++$conHijastros)].$cont), $persona->fecha_nacimiento);
				    			    $objExcelPHP->getActiveSheet()->setCellValue(($hijastros[(++$conHijastros)].$cont), ($persona->vive_empleado==1?'SI':'NO'));
				    			    $objExcelPHP->getActiveSheet()->setCellValue(($hijastros[(++$conHijastros)].$cont), $persona->edad);
				    				// es lo mismo  que lo de arriba solo que hace la referencia de posición desde otro vector
				    				break;	
				    		}
				    	}
				    	// Otra informacion de los empleados
				    	// De la DS -  DY
				    	$otraInfo= $this->mFichaSDG->consultarOtraInformacionM($empleado->documento);
				    	// Hasta acá se llego el 17/09/2018
				    	foreach ($otraInfo as $otra) {
				    		// Talla camisa
				    		$objExcelPHP->getActiveSheet()->setCellValue('DS'.$cont, $otra->talla_camisa);
				    		// Talla pantalon
				    		$objExcelPHP->getActiveSheet()->setCellValue('DT'.$cont, $otra->talla_pantalon);
				    		// Talla de zapatos
				    		$objExcelPHP->getActiveSheet()->setCellValue('DU'.$cont, $otra->talla_zapatos);
				    		// Vigencia curso de alturas
				    		$objExcelPHP->getActiveSheet()->setCellValue('DV'.$cont, $otra->vigencia_curso_alturas);
				    		// Rquiere o tiene el curso de alturas
				    		$objExcelPHP->getActiveSheet()->setCellValue('DW'.$cont, $otra->brigadas==1?'SI':'NO');
				    		// Ha pertenecido a una brigada de emergencia
				    		$objExcelPHP->getActiveSheet()->setCellValue('DX'.$cont, $otra->comites==1?'SI':'NO');
				    		// Ha estado en algun comité de las empresas
				    		$objExcelPHP->getActiveSheet()->setCellValue('DY'.$cont, $otra->necesitaCALT==1?'SI':'NO');
				    	}
				    	// Estados empresariales
				    	// Consulta de estados empresariales
				    	$empresariales=$this->mFichaSDG->consultarEstadosEmpresarialesM($empleado->documento);
				    	// 
				    	$estadoEmpresariales = array('DZ','EA','EB','EC','ED','EE','EF','EG','EH','EI','EJ','EK','EL','EM','EN','EO','EP','EQ','ER','ES','ET','EU','EV','EW','EX','EY','EZ','FA','FB','FC','FD','FE','FF','FG','FH','FI','FJ','FK','FL','FM','FN','FO','FP','FQ','FR','FS','FT','FU','FV','FW','FX','FY','FX','FZ','GA','GB');
				    $estadosE=-1;
				    foreach ($empresariales as $esta) {
				  	    $objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->estado_e==1?'Retirado':'Vigente');
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->idIndicador_rotacion==1?'Deseada':($esta->idIndicador_rotacion==2?'No deseado':($esta->idIndicador_rotacion==3?'N/A':'')));
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->motivo);
				  	  	$aux=0;
				  	  	$mensaje='';
				  	  	switch ($esta->impacto) {
				  	  		case 1:
				  	  			$aux=0;
				  	  			$mensaje='X';
				  	  			break;
				  	  		case 2:
				  	  			$aux=1;
				  	  			$mensaje='X';
				  	  				break;
				  	  		case 3:
				  	  			$aux=2;
				  	  			$mensaje='X';
				  	  			break;	
				  	  	}
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[((++$estadosE)+$aux)].$cont, $mensaje);
				  	  	// Nivelar
				  	  	for ($i=0; $i <=1; $i++) { 
				  	  		++$estadosE;
				  	  	}
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->nombre);
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->fecha_ingreso);
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->fecha_retiro);
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->antiguedad);
				  	  	$objExcelPHP->getActiveSheet()->setCellValue($estadoEmpresariales[(++$estadosE)].$cont, $esta->observacion_retiro);
				    }
				    	$cont++;
				    }

				    $fileName= "FSDGs".date("Y-m-d h:i:s").'xlsx';
				    $objExcelPHP->getActiveSheet()->setTitle('Fichas SDG');

				    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
				    header('Content-Diposition: attachment;filiname="'.$fileName.'"');
				    header('Cache-Control: max-age=0');

				    $write= PHPExcel_IOFactory::createWriter($objExcelPHP,'Excel2007');
				    $write->save('php://output');
	}


	public function exportarXLSX()
	{	
			$this->load->model('Empleado/mEmpleado');

            require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel.php');
		    require(APPPATH.'third_party/PHPExcel-1.8/Classes/PHPExcel/Writer/Excel2007.php');

		    $objExcelPHP= new PHPExcel();

		    $objExcelPHP->getProperties()->setCreator("");
		    $objExcelPHP->getProperties()->setLastModifiedBy("");
		    $objExcelPHP->getProperties()->setTitle("");
		    $objExcelPHP->getProperties()->setSubject("");
		    $objExcelPHP->getProperties()->setDescription("");

		    $objExcelPHP->setActiveSheetIndex(0);

		    $empleados= $this->mEmpleado->consultarEmpleadosM('');

		    $estilo = array( 
		      'borders' => array(
		        'outline' => array(
		          'style' => PHPExcel_Style_Border::BORDER_THIN
		        )
		      )
		    );

		    $cont=2;

		    foreach ($empleados as $empleado) {
		    	$i=0;
		    	$j=1;
		    	$k=1;
		    	// Numero de Documentos...
		    	$objExcelPHP->getActiveSheet()->setCellValue('B'.$cont, 'Documento:');
		    	$objExcelPHP->getActiveSheet()->setCellValue('C'.$cont, $empleado->documento);
		    	// Nombre del empleado
		    	$objExcelPHP->getActiveSheet()->setCellValue('B'.($cont+1), 'Nombre completo:');
		    	$objExcelPHP->getActiveSheet()->setCellValue('C'.($cont+1), $empleado->nombre1.' '.$empleado->nombre2.' '.$empleado->apellido1.' '.$empleado->apellido2);
		    	// Sexo
		    	$objExcelPHP->getActiveSheet()->setCellValue('B'.($cont+2), 'Sexo:');
		    	$objExcelPHP->getActiveSheet()->setCellValue('C'.($cont+2), ($empleado->genero==1?'Masculino':'Femenino'));
		    	// Correo
		    	$objExcelPHP->getActiveSheet()->setCellValue('B'.($cont+3), 'Correo:');
		    	$objExcelPHP->getActiveSheet()->setCellValue('C'.($cont+3), $empleado->correo);
		    	// Piso de ubicación
		    	$objExcelPHP->getActiveSheet()->setCellValue('B'.($cont+4), 'Empresa:');
		    	$objExcelPHP->getActiveSheet()->setCellValue('C'.($cont+4), $empleado->nombre);
		    	// Estado
		    	$objExcelPHP->getActiveSheet()->setCellValue('B'.($cont+5), 'Estado:');
		    	$objExcelPHP->getActiveSheet()->setCellValue('C'.($cont+5), ($empleado->estado==1?'Activo':'Desactivado'));
		    	$objExcelPHP->getActiveSheet()->getStyle('B'.$cont.':C'.($cont+5))->applyFromArray($estilo);
		    	// ...
		    	if($empleado->FichaSDG==1){//Tiene una ficha SDG Previamente registrada
		    		// Informacion Salarial
		    		$objExcelPHP->getActiveSheet()->mergeCells('D'.($cont-1).':G'.($cont-1));
		    		$objExcelPHP->getActiveSheet()->setCellValue('D'.($cont-1), 'Información Salarial');
		    		$objExcelPHP->getActiveSheet()->getStyle('D'.($cont-1))->getFont()->setBold(true);
		    		// ...
		    				    	// Consulta de la informacion salarial del empleado.
		    				    	$estadoSalarial=$this->mFichaSDG->consultarInfoSalarialM($empleado->documento);
		    				    	// ...
		    		                foreach ($estadoSalarial as $salaria){
		    				    	   // Promedio salarial
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('D'.$cont, 'Promedio Salarial');
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('D'.($cont+1), $salaria->nombre);
		    				    	   $objExcelPHP->getActiveSheet()->getStyle('D'.$cont)->getFont()->setBold(true);
		    				    	   // Clasificacion Mega
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('E'.$cont, 'CL.Mega');
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('E'.($cont+1), $salaria->clasificacion);
		    				    	   $objExcelPHP->getActiveSheet()->getStyle('E'.$cont)->getFont()->setBold(true);
		    				    	   // Salario Basico
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('F'.$cont, 'Salario basico');
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('F'.($cont+1), $salaria->salario_baseico_formato);
		    				    	   $objExcelPHP->getActiveSheet()->getStyle('F'.$cont)->getFont()->setBold(true);
		    				    	   // Salario Total
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('G'.$cont, 'Salario Total');
		    				    	   $objExcelPHP->getActiveSheet()->setCellValue('G'.($cont+1), $salaria->totalFormato);
		    				    	   $objExcelPHP->getActiveSheet()->getStyle('G'.$cont)->getFont()->setBold(true);	
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('D'.($cont-1).':G'.($cont+5))->applyFromArray($estilo);
		    				    	// ...
		    				    	// Informacion de los auxilios
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('H'.($cont-1).':J'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('H'.($cont-1), 'Información de auxilios');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('H'.($cont-1))->getFont()->setBold(true);
		    				    	// Consulta de los auxilios del empleado.
		    				    	$Auxilios= $this->mFichaSDG->consultarAuxiliosM($empleado->documento);
		    				    	//...
		    				    	foreach ($Auxilios as $auxilio) {
		    				    		// Nombre del auxilio
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('H'.$cont, 'Nombre');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('H'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('H'.($cont+1), $auxilio->auxilio);
		    				    		// Monto del auxilio
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('I'.$cont, 'Monto');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('I'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('I'.($cont+1), $auxilio->mondoFormato);
		    				    		// Estado del auxilio
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('J'.$cont, 'Estado');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('J'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('J'.($cont+1), ($auxilio->estado==1?'Vigente':'No vigente'));
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('H'.($cont-1).':J'.($cont+5))->applyFromArray($estilo);
		    				    	// ...
		    				    	// Informacion de los estudios
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('K'.($cont-1).':M'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('K'.($cont-1), 'Información Estudios');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('K'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar estudios empleado
		    				    	$estudios= $this->mFichaSDG->consultarInfoEstudiosM($empleado->documento);
		    				    	// ...
		    				    	foreach ($estudios as $estudio) {
		    				    		// Estudios alcanzados
		    				    		// Grado maximo de escolaridad alcanzada
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('K'.$cont, 'Estudios');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('K'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('K'.($cont+1), $estudio->grado);
		    				    		// Titulo profesional
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('L'.$cont, 'Titulo');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('L'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('L'.($cont+1), $estudio->titulo_profecional);
		    				    		// Titulo de especializacion
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('M'.$cont, 'Especializacion');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('M'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('M'.($cont+1), $estudio->titulo_especializacion);
		    				    		// Estudios actuales
		    				    		// ...
		    				    		// Estudia actualmente
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('K'.($cont+3), '¿Estudia actualmente?');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('K'.($cont+3))->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('K'.($cont+4), ($estudio->titulo_estudios_actuales==0?'NO':'SI'));
		    				    		// Que estudia actualmente
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('L'.($cont+3), '¿Que estudia?');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('L'.($cont+3))->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('L'.($cont+4), $estudio->estudios_actuales);
		    				    		// Nombre de la carrera que estudia actualmente
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('M'.($cont+3), 'Nombre de la carrera');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('M'.($cont+3))->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('M'.($cont+4), $estudio->nombre_carrera);
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('K'.($cont-1).':M'.($cont+5))->applyFromArray($estilo);
		    				    	// ...
		    				    	// Información Laboral
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('N'.($cont-1).':T'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('N'.($cont-1), 'Información Laboral');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('N'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar informacion laboral
		    				    	$laboral=$this->mFichaSDG->consultarInfoLaboralM($empleado->documento);
		    				    	// ...
		    				    	foreach ($laboral as $labor) {//Inicio for
		    				    		// Horario de trabajo
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('N'.$cont, 'Horario');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('N'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('N'.($cont+1), $labor->horario);
		    				    		// área de trabajo
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('O'.$cont, 'Área trabajo');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('O'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('O'.($cont+1), $labor->area);
		    				    		// Cargo
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('P'.$cont, 'Cargo');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('P'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('P'.($cont+1), $labor->cargo);
		    				    		//	Tiene personal a cargo
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('Q'.$cont, 'Personal a cargo');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('Q'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('Q'.($cont+1), ($labor->recurso_humano==1?'SI':'NO'));
		    				    		// Tipo de contrato
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('R'.$cont, 'Tipo de contrato');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('R'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('R'.($cont+1), $labor->contrato);
		    				    		// Fecha vencimiento del contrato
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('S'.$cont, 'Fecha fin contrato');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('S'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('S'.($cont+1), $labor->fecha_vencimiento_contrato);
		    				    		// Fecha de ingreso
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('T'.$cont, 'Fecha de ingreso');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('T'.$cont)->getFont()->setBold(true);
		    				    		// $objExcelPHP->getActiveSheet()->setCellValue('T'.($cont+1), $labor->fecha_ingreso);
		    				    	}//Fin for
		    				    	$objExcelPHP->getActiveSheet()->getStyle('N'.($cont-1).':T'.($cont+5))->applyFromArray($estilo);
		    				    	//Informacion secundaria basica
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('U'.($cont-1).':AB'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('U'.($cont-1), 'Información Secundaria basica');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('U'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar información
		    				    	$secundariaB= $this->mFichaSDG->consultarInfoSecundariaBasicaM($empleado->documento);
		    				    	// ...
		    				    	foreach ($secundariaB as $segundo) {
		    				    		// Estado civil
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('U'.$cont, 'Estado Civil');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('U'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('U'.($cont+1), $segundo->nombre_estado);
		    				    		// Fecha de nacimiento
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('V'.$cont, 'Fecha de nacimiento');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('V'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('V'.($cont+1), $segundo->fecha_nacimiento);
		    				    		// Lugar de nacimiento
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('W'.$cont, 'Lugar de nacimiento');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('W'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('W'.($cont+1), $segundo->lugar_nacimiento);
		    				    		// Telefono fijo
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('X'.$cont, 'Telefono fijo');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('X'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('X'.($cont+1), $segundo->tel_fijo);
		    				    		// Celular
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('Y'.$cont, 'Celular');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('Y'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('Y'.($cont+1), $segundo->celular);
		    				    		// Tipo de sangre
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('Z'.$cont, 'Tipo de sangre');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('Z'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('Z'.($cont+1), $segundo->sangre);
		    				    		// EPS
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AA'.$cont, 'EPS');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AA'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AA'.($cont+1), $segundo->eps);
		    				    		// AFP
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AB'.$cont, 'AFV');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AB'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AB'.($cont+1), $segundo->afp);
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('U'.($cont-1).':AB'.($cont+5))->applyFromArray($estilo);
		    				    	// ...
		    				    	// Información de salud
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('AC'.($cont-1).':AF'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('AC'.($cont-1), 'Información salud');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AC'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar informacion de salud
		    				    	$saludes= $this->mFichaSDG->consultarInfoSaludM($empleado->documento);
		    				    	// ...
		    				    	foreach ($saludes as $salud) {
		    				    		// Fuma?
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AC'.$cont, 'Fuma?');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AC'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AC'.($cont+1), ($salud->fuma>0?'SI':'NO'));
		    				    		// Numero de cigarrillos fumados por dia
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AD'.$cont, '# cigarrillos consumo día?');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AD'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AD'.($cont+1), ($salud->fuma>0?$salud->fuma:'0'));
		    				    		// Consumo de Bevidas alcoholicas
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AE'.$cont, 'Consume alcohol?');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AE'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AE'.($cont+1), $salud->alcohol);
		    				    		// Descripcion en caso de emergencia
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AF'.$cont, 'En caso de emergencia');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AF'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AF'.($cont+1), $salud->descripccion_emergencia);
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AC'.($cont-1).':AF'.($cont+5))->applyFromArray($estilo);
		    				    	// Información Personal
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('AG'.($cont-1).':AQ'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('AG'.($cont-1), 'Información Personal');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AG'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar informacion personal
		    				    	$personal= $this->mFichaSDG->consultarInfoPersonalM($empleado->documento);
		    				    	// ...
		    				    	$idPersona=0;
		    				    	foreach ($personal as $persona) {
		    				    		// IDPErsonal
		    				    		$idPersona=$persona->idPersonal;
		    				    		// Direccion
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AG'.$cont, 'Direccion');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AG'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AG'.($cont+1), $persona->direc);
		    				    		// Barrio
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AH'.$cont, 'Barrio');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AH'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AH'.($cont+1), $persona->barrio);
		    				    		// Comuna
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AI'.$cont, 'Comuna');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AI'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AI'.($cont+1), $persona->comuna);
		    				    		// Municipio
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AJ'.$cont, 'Municipio');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AJ'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AJ'.($cont+1), $persona->municipio);
		    				    		// Estrato
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AK'.$cont, 'Estrato');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AK'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AK'.($cont+1), $persona->estrato);
		    				    		// Persona en caso de emergencia
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AL'.$cont, 'Persona en caso de emergencia');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AL'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AL'.($cont+1), $persona->caso_emergencia);
		    				    		// Parentezco
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AM'.$cont, 'Parentezco');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AM'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AM'.($cont+1), $persona->parentezco);
		    				    		// Telefono
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AN'.$cont, 'Telefono');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AN'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AN'.($cont+1), $persona->tel);
		    				    		// Tipo de vivienda
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AO'.$cont, 'Tipo de vivienda');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AO'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AO'.($cont+1), $persona->vivienda);
		    				    		// Altura
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AP'.$cont, 'Altura (mts)');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AP'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AP'.($cont+1), $persona->altura.' mts');
		    				    		// Peso
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AQ'.$cont, 'Peso (Kg)');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AQ'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AQ'.($cont+1), $persona->peso.' Kg');
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AG'.($cont-1).':AQ'.($cont+5))->applyFromArray($estilo);
		    				    	// Información Personal>Actividades
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('AR'.($cont-1), 'Actividades realizadas en tiempo libre');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AR'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar Actividades
		    				    	$actividades= $this->mFichaSDG->consultarActividadesInfoPersonalM($idPersona);
		    				    	// ...
		    				    	$op=1;
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('AR'.$cont, 'Acividad');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AR'.$cont)->getFont()->setBold(true);
		    				    	foreach ($actividades as $actividad) {
		    				    		// Nombre de la actividad realizada
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AR'.($cont+$op++), $actividad->nombre);
		    				    		$i++;
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AR'.($cont-1).':AR'.($cont+5+($i>5?$i-5:0)))->applyFromArray($estilo);
		    				    	// 
		    				    	// Información De las personas con las que vive
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('AS'.($cont-1).':AX'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('AS'.($cont-1), 'Personas con las que vive');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AS'.($cont-1))->getFont()->setBold(true);
		    				    	// ...
		    				    	// Consultar Personas con las que vive
		    				    	$personasVives=$this->mFichaSDG->consultarPersonasViveInfoPersonalM($idPersona);
		    				    	// ...
		    				    	// Parentezco
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AS'.$cont, 'Parentezco');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AS'.$cont)->getFont()->setBold(true);
		    				    	// Nombre
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AT'.$cont, 'Nombre');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AT'.$cont)->getFont()->setBold(true);
		    				    	// Fecha de nacimiento
		    				    	    $objExcelPHP->getActiveSheet()->setCellValue('AU'.$cont, 'Fecha de nacimiento');
		    				    	    $objExcelPHP->getActiveSheet()->getStyle('AU'.$cont)->getFont()->setBold(true);
		    				    	// Celular
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AV'.$cont, 'Celular');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AV'.$cont)->getFont()->setBold(true);
		    				    	//	Vive con el empleado
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AW'.$cont, 'Vive con el empleado?');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AW'.$cont)->getFont()->setBold(true);
		    				    	//	Cantidad
		    				    	    $objExcelPHP->getActiveSheet()->setCellValue('AX'.$cont, 'Cantidad');
		    				    	    $objExcelPHP->getActiveSheet()->getStyle('AX'.$cont)->getFont()->setBold(true);
		    				    	// ...
		    				    	foreach ($personasVives as $persona) {//Inicio for
		    				    		// Parentezco
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AS'.($cont+$j), $persona->nombre);
		    				    		// Nombre
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AT'.($cont+$j), $persona->nombreC);
		    				    		// Fecha de nacimiento
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AU'.($cont+$j), ($persona->fecha_nacimiento=='00-00-0000'?'':$persona->fecha_nacimiento));
		    				    		// Celular
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AV'.($cont+$j), $persona->celular);
		    				    		//	Vive con el empleado
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AW'.($cont+$j), ($persona->idParentezco==8?($persona->vive_empleado==1?'SI':'NO'):''));
		    				    		//	Cantidad
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AX'.($cont+$j), ($persona->cantidad));
		    				    		$j++;
		    				    	}//Fin for
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AS'.($cont-1).':AX'.($cont+4+($j>5?$j-5:0)))->applyFromArray($estilo);
		    				    	// Otra información
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('AY'.($cont-1).':BE'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('AY'.($cont-1), 'Otra información');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AY'.($cont-1))->getFont()->setBold(true);
		    				    	// Consultar informacion personal
		    				    	$otraInformacion= $this->mFichaSDG->consultarOtraInformacionM($empleado->documento);
		    				    	// ...
		    				    	foreach ($otraInformacion as $otra) {
		    				    		// Talla de la camida
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AY'.$cont, 'Talla de camisa');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AY'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AY'.($cont+1), $otra->talla_camisa);
		    				    		// Talla de pantalon
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AZ'.$cont, 'Talla de pantalon');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('AZ'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('AZ'.($cont+1), $otra->talla_pantalon);
		    				    		// Talla de zapatos
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BA'.$cont, 'Comuna');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BA'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BA'.($cont+1), $otra->talla_zapatos);
		    				    		// Vigencia curso de alturas
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BB'.$cont, 'Vigencia curso de alturas');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BB'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BB'.($cont+1), $otra->vigencia_curso_alturas);
		    				    		// Brigadas?
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BC'.$cont, 'Brigadas');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BC'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BC'.($cont+1), ($otra->brigadas==1?'SI':'NO'));
		    				    		// Comites
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BD'.$cont, 'Comite');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BD'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BD'.($cont+1), ($otra->comites==1?'SI':'NO'));
		    				    		// Necesita C.ALT
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BE'.$cont, 'Necesita C.ALT');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BE'.$cont)->getFont()->setBold(true);
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BE'.($cont+1), ($otra->necesitaCALT==1?'SI':'NO'));
		    				    	}
		    				    	$objExcelPHP->getActiveSheet()->getStyle('AY'.($cont-1).':BE'.($cont+5))->applyFromArray($estilo);
		    				    	// ...
		    				    	// Información del estado empresarial
		    				    	$objExcelPHP->getActiveSheet()->mergeCells('BF'.($cont-1).':BM'.($cont-1));
		    				    	$objExcelPHP->getActiveSheet()->setCellValue('BF'.($cont-1), 'Estados Empresariales');
		    				    	$objExcelPHP->getActiveSheet()->getStyle('BF'.($cont-1))->getFont()->setBold(true);
		    				    	// ...
		    				    	// Consultar de los estado empresariales
		    				    	$estadosE=$this->mFichaSDG->consultarEstadosEmpresarialesM($empleado->documento);
		    				    	// ...
		    				    	// Estado empresarial (Vigente o retirado)
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BF'.$cont, 'Estado empresarial');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BF'.$cont)->getFont()->setBold(true);
		    				    	// fecha de ingreso
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BG'.$cont, 'Fecha de ingreso');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BG'.$cont)->getFont()->setBold(true);
		    				    	// Fecha de retiro
		    				    	    $objExcelPHP->getActiveSheet()->setCellValue('BH'.$cont, 'Fecha de retiro');
		    				    	    $objExcelPHP->getActiveSheet()->getStyle('BH'.$cont)->getFont()->setBold(true);
		    				    	// motivo del retiro
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BI'.$cont, 'Motivo de retiro');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BI'.$cont)->getFont()->setBold(true);
		    				    	//	Indicador de rotaciòn
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BJ'.$cont, 'Indicador de rotaciòn');
		    				    		$objExcelPHP->getActiveSheet()->getStyle('BJ'.$cont)->getFont()->setBold(true);
		    				    	//	Empresa a la que pertenece o pertenecio
		    				    	    $objExcelPHP->getActiveSheet()->setCellValue('BK'.$cont, 'Empresa');
		    				    	    $objExcelPHP->getActiveSheet()->getStyle('BK'.$cont)->getFont()->setBold(true);
		    				    	//	Antiguedad
		    				    	    $objExcelPHP->getActiveSheet()->setCellValue('BL'.$cont, 'Antiguedad');
		    				    	    $objExcelPHP->getActiveSheet()->getStyle('BL'.$cont)->getFont()->setBold(true);
		    				    	//	Antiguedad
		    				    	    $objExcelPHP->getActiveSheet()->setCellValue('BM'.$cont, 'Observaciòn de retiro');
		    				    	    $objExcelPHP->getActiveSheet()->getStyle('BM'.$cont)->getFont()->setBold(true);         
		    				    	// ...
		    				    	foreach ($estadosE as $estado) {//Inicio for
		    				    		// Estado empresarial (Vigente o retirado)
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BF'.($cont+$k), ($estado->estado_e==1?'Retirado':'Vigente'));
		    				    		// fecha de ingreso
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BG'.($cont+$k), $estado->fecha_ingreso);
		    				    		// Fecha de retiro
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BH'.($cont+$k), ($estado->fecha_retiro=='00-00-0000'?'':$estado->fecha_retiro));
		    				    		// Motivo de retiro
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BI'.($cont+$k), ($estado->motivo!='NULL'?$estado->motivo:''));
		    				    		//	Indicador de rotacion
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BJ'.($cont+$k), ($estado->idIndicador_rotacion==1?'Deseado':'No Deseado'));
		    				    		//	Empresa
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BK'.($cont+$k), ($estado->nombre));
		    				    		//	Antiguedad
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BL'.($cont+$k), ($estado->antiguedad));
		    				    		//	Observacion de retiro
		    				    		$objExcelPHP->getActiveSheet()->setCellValue('BM'.($cont+$k), ($estado->observacion_retiro));
		    				    		$k++;
		    				    	}//Fin for
		    				    	$objExcelPHP->getActiveSheet()->getStyle('BF'.($cont-1).':BM'.($cont+4+($k>5?$k-5:0)))->applyFromArray($estilo);
		    				    	// $objExcelPHP->getActiveSheet()->getStyle('N'.($cont-1).':T'.($cont+5))->applyFromArray($estilo);
		    	}
		    	// Siguiente empleado...
		    	$cont+=8+($i>5?$i-5:0)+($j>5?$j-5:0)+($k>5?$k-5:0);
		    }
		    $objExcelPHP->getActiveSheet()->getStyle('B2:B'.$cont)->getFont()->setBold(true);


		    $fileName= "FSDGs".date("Y-m-d h:i:s").'xlsx';
		    $objExcelPHP->getActiveSheet()->setTitle('Fichas SDG');

		    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
		    header('Content-Diposition: attachment;filiname="'.$fileName.'"');
		    header('Cache-Control: max-age=0');

		    $write= PHPExcel_IOFactory::createWriter($objExcelPHP,'Excel2007');
		    $write->save('php://output');
	}

}
?>