<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Se encarga de eliminar toda la informacion de la base de datos de la ficha SDG...
 SE_PA_LimpiarBaseDatosFichasSDG
 */
class mFichaSDG extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
// Funciones de la clase

	// Se encarga de registrar o modificar la informacion empresarial de los empleados dependiendo de la informacion que se le mande.
	public function registrarModificarEstadoEmpresarialM($ID,$info)
	{		
		if ($info['accion']==0) {

			$query= $this->db->query("CALL SE_PA_RegistrarModificarEstadoEmpresarial({$ID},'{$info['fechaR']}', '{$info['fechaI']}', {$info['motivo']}, {$info['rotacion']}, {$info['estado']}, '{$info['descripcion']}', {$info['empresa']}, {$info['IDEstadoE']},'{$info['estadoE']}',{$info['impacto']});");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{
			if ($info['existe']=='') {

				// Consultar el ID del motivo de la renuncia
				if ($info['motivo']!='') {
					$query= $this->db->query("SELECT m.idMotivo FROM motivo m WHERE m.nombre='{$info['motivo']}'");

					$res= $query->row();

					$info['motivo']= $res->idMotivo;
				}else{
					$info['motivo']=0;
				}
				// Indice de rotacion
				switch ($info['rotacion']) {
					case '':
						$info['rotacion']=0;
						break;
					case 'Deseada':
						$info['rotacion']=1;
						break;
					case 'No Deseada':
						$info['rotacion']=2;
						break;
					case 'N/A':
						$info['rotacion']=3;
						break;
				}
				// if ($info['rotacion']=='') {
				// 	$info['rotacion']=0;
				// }else if($info['rotacion']=='Deseada'){
				// 	$info['rotacion']=1;
				// }else{
				// 	$info['rotacion']=2;
				// }

				// Consultar el ID de la empresa contratante del empleado
				$query= $this->db->query("SELECT e.idEmpresa FROM empresa e WHERE e.nombre='{$info['empresa']}'");

				$res= $query->row();

				$info['empresa']= $res->idEmpresa;

				// Registrar estado empresarial-> pendiente por agregar el impacto
				$query= $this->db->query("CALL SE_PA_RegistrarModificarEstadoEmpresarial({$ID},'{$info['fechaR']}', '{$info['fechaI']}', {$info['motivo']}, {$info['rotacion']}, {$info['estado']}, '{$info['descripcion']}', {$info['empresa']}, 0,'{$info['idEsatoE']}',{$info['impacto']});");

				$res= $query->row();

				$this->db->close();

				return $res->respuesta;
			}else{
				return -1;
			}
		}
	}

	public function consultarEstadosEmpresarialesM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarEstadoEmpresariales('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}
	// Se encarga de registrar o modificar la informacion de los estudios de los empleado en la ficha SDG
	public function registrarModificarEstudiosM($info)
	{	
		if ($info['accion']==0) {//Registro por la vista
			$query= $this->db->query("CALL SE_PA_RegistrarModificarEstudios({$info['IDF']},{$info['idEstudios']},'{$info['tituloP']}','{$info['espes']}','{$info['idEstudiando']}','{$info['nombreCarrera']}');");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;	
		}else{//Registro por el importe de un excel
			// Consultar el id de la informacion de los estudios
			// $idEstudios= $this->consultarIDModulo($info['documento'], 'idEstudios');
			// $idEstudios= ($idEstudios==''?0:$idEstudios);
			$idEstudios= $this->consultarIDFichasSDG($info['documento']);
			$idEstudios= ($idEstudios==''?0:$idEstudios);
			// Consultar el ID de los grado de escolaridad
			$query=$this->db->query("SELECT g.idGrado_escolaridad FROM grado_escolaridad g WHERE g.grado='{$info['grado_Escolaridad']}';");

			$idGEC=$query->row();

			$resIDGEC= $idGEC->idGrado_escolaridad;
			// Consulta del siguiente grado de escolaridad si estudia
			if ($info['estudiaA']=="SI") {
				$query=$this->db->query("SELECT g.idGrado_escolaridad FROM grado_escolaridad g WHERE g.grado='{$info['que_estudia']}';");

				$idQueEstudia= $query->row();

				$info['que_estudia']=$idQueEstudia->idGrado_escolaridad;
			}else{
				$info['que_estudia']=0;
				$info['Titulo_del_Estudio']='';
			}
			// Registrar o modificar la informacion de estudios
			$query= $this->db->query("CALL SE_PA_RegistrarModificarEstudios({$idEstudios},{$resIDGEC},'{$info['TituloP']}','{$info['Especializacion']}','{$info['que_estudia']}','{$info['Titulo_del_Estudio']}');");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}
	}
	// Se encarga de consultar la información de los estudies por cada empleado.
	public function consultarInfoEstudiosM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarInfoEstudios('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	// Se encarga de registrar modificar la informacion Laboral de los empleados que tiene ficha SDG
	public function registrarModificarInfoLaboralM($info)
	{
		if ($info['accion']==0) {
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoLaboral({$info['IDF']}, {$info['idHorario']},{$info['idArea']},{$info['idCargo']}, {$info['recursoH']}, {$info['idTipoContraro']}, '{$info['fechaVC']}', {$info['CC']});");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{
			// Consultar el id de la informacion laboral
			// $idLaboral= $this->consultarIDModulo($info['documento'], 'idLaboral');
			// $idLaboral= ($idLaboral==''?0:$idLaboral);

			$idLaboral= $this->consultarIDFichasSDG($info['documento']);
			$idLaboral= ($idLaboral==''?0:$idLaboral);

			// Consultar el ID del horario laboral
			$query=$this->db->query("SELECT h.idHorario_trabajo FROM horario_trabajo h WHERE h.horario='{$info['horario']}';");

			$idLab=$query->row();

			$lb['idHorario']=$idLab->idHorario_trabajo;

			// Consulta el ID del contrato laboral
			$query=$this->db->query("SELECT t.idTipo_contrato FROM tipo_contrato t WHERE t.contrato='{$info['contrato']}';");

			$idLab=$query->row();

			$lb['idContrato']=$idLab->idTipo_contrato;

			// Consulta el ID del cargo laboral
			$query=$this->db->query("SELECT c.idCargo FROM cargo c WHERE c.cargo='{$info['cargo']}';");

			$idLab=$query->row();

			$lb['idCargo']=$idLab->idCargo;

			// El empleado tiene personal a cargo
		    $info['personal_aCargo']=($info['personal_aCargo']=='SI'?'1':'0');

		    // Consultar área de trabajo del empleado
		    $query=$this->db->query("SELECT a.idArea_trabajo FROM area_trabajo a WHERE a.area='{$info['area_trabajo']}';");

		    $idLab=$query->row();

		    $lb['idArea']=$idLab->idArea_trabajo;

		    // Consultar clasificacion contable del empleado
		    $query=$this->db->query("SELECT c.idClasificacion_contable FROM clasificacion_contable c WHERE c.clasificacion='{$info['clasificacion_contable']}';");

		    $idLab=$query->row();

		    $lb['idClasificacioncontable']=$idLab->idClasificacion_contable;

			// Registrar o modificar la informacion de estudios
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoLaboral({$idLaboral}, {$lb['idHorario']},{$lb['idArea']},{$lb['idCargo']}, {$info['personal_aCargo']}, {$lb['idContrato']}, '{$info['fecha_vencimiento_contrato']}', {$lb['idClasificacioncontable']});");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}
	}

	public function consultarInfoLaboralM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarInfoLAboral('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	// Se encarga de registrar o modificar la informacion alternativa (Otra informacion de cada persona).
	public function registrarModificarOtraInformacion($info)
	{	

		if ($info['accion']==0) {
			$query= $this->db->query("CALL SE_PA_RegistrarModificarOtraInfo({$info['IDF']},'{$info['TCamida']}','{$info['TPantalon']}', '{$info['Tzapatos']}', '{$info['VCursoAlturas']}',{$info['PBrigadaEmergencia']}, {$info['AlgunComite']}, {$info['RquierecursoAlturas']});");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{
			// Consultar el ID de la otra informacion del empleado
			// $idOtros= $this->consultarIDModulo($info['documento'], 'idOtros');
			// $idOtros= ($idOtros==''?0:$idOtros);
			$idOtros= $this->consultarIDFichasSDG($info['documento']);
			$idOtros= ($idOtros==''?0:$idOtros);

			// Registrar o modificar la otra información del empleado
			$query= $this->db->query("CALL SE_PA_RegistrarModificarOtraInfo({$idOtros},'{$info['talla_camisa']}','{$info['talla_pantalon']}', '{$info['talla_zapatos']}', '{$info['vigencia_curso_alturas']}',{$info['perteneceCurso']}, {$info['comites']}, {$info['RequiereCursoA']});");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}
	}
	// Se encarga de consultar toda la información que es dispensable para el operario.
	public function consultarOtraInformacionM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarOtraInformacion('{$doc}')");
			
		$res= $query->result();

		$this->db->close();

		return $res;
	}

	// Se encarga de registrar op modificar la informacion de la salud de cada empleado.
	public function registrarModificarInfoSaludM($info)
	{
		if ($info['accion']==0) {
			    $query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSalud({$info['IDF']},'{$info['fuma']}', '{$info['alcohol']}','{$info['desE']}');");

				$res= $query->row();

				$this->db->close();

				return $res->respuesta;	
		}else{
			// Consultar el ID de la informacion de salud del empleado
			// $idSalud= $this->consultarIDModulo($info['documento'], 'idSalud');
			// $idSalud= ($idSalud==''?0:$idSalud);
            $idSalud= $this->consultarIDFichasSDG($info['documento']);
			$idSalud= ($idSalud==''?0:$idSalud);

			// Registrar o actualizar informacion de salud del empleado
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSalud({$idSalud},'{$info['cigarrillos']}', '{$info['alcohol']}','{$info['ante_una_emergencia']}');");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}	
	}
	// Se encarga de consultar la informacion de salud de los empleados registrados en el sistema por medio de la cedula.
	public function consultarInfoSaludM($doc)
	{
	 	$query= $this->db->query("CALL SE_PA_ConsultarInfoSalud('{$doc}')");
	 		
	 	$res= $query->result();

	 	$this->db->close();
	 	return $res;
	}

	// Se encarga de registrar o modificar la informacion de actividades del tiempo libre del modulo de información personal.
	public function registrarModificarActividadesInfoPersonalM($id,$activ,$info)
	{	
		if ($info['accion']==0) {
		    $query= $this->db->query("CALL SE_PA_RegistrarModificarActividadesInfoPersonal({$id},{$activ});");
			
			$res= $query->row();

			$this->db->close();

			return $res->respuesta;	
		}else{
			// Consultar ID de la info personal del empleado}
			// $idPersonal= $this->consultarIDModulo($id, 'idPersonal');
			// $idPersonal= ($idPersonal==''?0:$idPersonal);
			$v=explode(';',$activ);// incice 0 nombre de la actividad, indice 1 si aplica o no (SI o null)
			// Consultar el id de la actividad realizada en el tiempo libre
			$query= $this->db->query("SELECT a.idActividad FROM actividad a WHERE a.nombre='{$v[0]}'");

			$res= $query->row();

			$idActividad= $res->idActividad;
			// 
			$accion= ($v[1]==''?0:1);
			// var_dump($accion);
			//
			$query= $this->db->query("CALL SA_PA_RegistrarModificarActividadesImportacion({$info['idPersonal']},{$idActividad},{$accion});");
			// 
			$res= $query->row();
			// 
			$this->db->close();
			// 
			return $res->respuesta;	 
		}
	}

	//Se encarga de consultar la información de las actividades que realiza el empleado en tiempos libres por el id de la informacion personal.  
	public function consultarActividadesInfoPersonalM($id)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarActividadesInfoPersonal('{$id}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	// Se encarga de registrar o modificar la informacion personal de las personas.
	public function registrarModificarInfoPersonalM($id,$info)
	{	
		if ($info['accion']==0) {
			$query=$this->db->query("CALL SE_PA_RegistrarModificarInfoPersonal({$id},'{$info['direccion']}','{$info['barrio']}','{$info['comuna']}', {$info['municipio']}, '{$info['estrato']}', '{$info['casoEM']}', '{$info['telefono']}', '{$info['parentezco']}', {$info['idTipoV']}, '{$info['altura']}', '{$info['peso']}', '{$info['otra']}');");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{
			// Consultar ID de la info personal del empleado}
			// $idPersonal= $this->consultarIDModulo($info['documento'], 'idPersonal');
			// $idPersonal= ($idPersonal==''?0:$idPersonal);
			$idPersonal= $this->consultarIDFichasSDG($info['documento']);	
			$idPersonal= ($idPersonal==''?0:$idPersonal);

			// Consultar el ID del municipio
			$query=$this->db->query("SELECT m.idMunicipio FROM municipio m WHERE m.nombre='{$info['municipio']}';");

			$idM=$query->row();

			$lb['idMunicipio']=$idM->idMunicipio;

			// Consultar el ID del tipo de vivienda del empleado
			$query=$this->db->query("SELECT t.idTipo_vivienda FROM tipo_vivienda t WHERE t.nombre='{$info['tipo_vivienda']}';");

			$idM=$query->row();

			$lb['idTipo_Vivienda']=$idM->idTipo_vivienda;

			if ($info['parentezco']!='') {
				// Consultar el ID del parentezco
				// $query=$this->db->query("SELECT p.idParentezco FROM parentezco p WHERE p.nombre='{$info['parentezco']}';");

				// if ($query->num_rows()>0) {
				// 	$idM=$query->row();
				// 	$lb['parentezco']=$idM->idParentezco;
				// }else{
				// 	$lb['parentezco']=0;
				// }
				switch (strtolower($info['parentezco'])) {
					case 'madre':
						$lb['parentezco']=1;
						break;
							$lb['parentezco']=1;
							break;
						case 'padre':
							$lb['parentezco']=2;
							break;
						case 'hermano/a':
							$lb['parentezco']=3;
							break;
						case 'novio/a, esposo/a':
							$lb['parentezco']=4;
							break;
						case 'abuelo/a':
							$lb['parentezco']=5;
							break;
						case 'tio/a':
							$lb['parentezco']=6;
							break;
						case 'hijo/a':
							$lb['parentezco']=7;
							break;
						case 'hijastro/a':
							$lb['parentezco']=8;
							break;
						case 'otro':
							$lb['parentezco']=9;
							break;
					default:
					   $lb['parentezco']=0;
						break;	
				}
			}else{
				$lb['parentezco']=0;
			}
			
			// Registrar modificar informacion personal del empleado
			$query=$this->db->query("CALL SE_PA_RegistrarModificarInfoPersonal({$idPersonal},'{$info['direccion']}','{$info['barrio']}','{$info['comuna']}', {$lb['idMunicipio']}, '{$info['estrato']}', '{$info['pesona_emergencia']}', '{$info['telefono']}', '{$lb['parentezco']}', {$lb['idTipo_Vivienda']}, '{$info['altura']}', '{$info['peso']}', '{$info['otras_Actividades']}');");

			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}
	}
	// Se encarga de consultar la informacion personal de los empleados registrados en el sistema de informacion por medio del documento de identidad.
	public function consultarInfoPersonalM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarIndoPersonal('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	// Se encarga de registra la información de las personas que vive que hace parte la informacion personal de la persona.
	public function registrarModificarPersonasViveM($info)
	{	
		if ($info['accion']==0) {
			$query= $this->db->query("CALL SE_RegistrarModificarInformacionPersonasVive({$info['op']},'{$info['nombreC']}',{$info['idParT']},'{$info['celular']}','{$info['fechaN']}',{$info['viveCon']},{$info['idPersonal']},'{$info['cantidad']}', {$info['idPersona']});");
				
			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{
			// Consultar ID de informacion personal
			// $idPersonal= $this->consultarIDModulo($info['documento'], 'idPersonal');
			// $idPersonal= ($idPersonal==''?0:$idPersonal);
			// var_dump($idPersonal);//

			$idPersonaVive='';
			if ($info['idParentezcos']!=8 && $info['idParentezcos']!=9) {
				// Validar la existencia del id de la persona con la que vive
				$query=$this->db->query("SELECT EXISTS(SELECT p.idPersonas_vive FROM personas_vive p WHERE p.idPersonal='{$info['idPersonal']}' AND p.idParentezco='{$info['idParentezcos']}') AS respuesta");
				// ...
				$resP= $query->row();

			 	if ($resP->respuesta==1) {
			 		// Consultar ID de las persona con la que vive
			 		$query=$this->db->query("SELECT p.idPersonas_vive FROM personas_vive p WHERE p.idPersonal='{$info['idPersonal']}' AND p.idParentezco='{$info['idParentezcos']}'");
			 		// ...
			 		$resP= $query->row();
			 		// ...
			 		$idPersonaVive=$resP->idPersonas_vive;//Se genera un problema acá en esta parte del código
			 	}else{
			 		$idPersonaVive='';
			 	}		
			}
			// ...
			if ($info['dato']!='') {
				// Registrar o modificar la persona con la que vive
				$op= ($idPersonaVive!=''?'1':'0');
				$idPersonaVive= ($idPersonaVive!=''?$idPersonaVive:0);
				// ...
				$query= $this->db->query("CALL SE_RegistrarModificarInformacionPersonasVive({$op},'{$info['nombreC']}',{$info['idParentezcos']},'{$info['celular']}','{$info['fechaN']}',{$info['viveE']},{$info['idPersonal']},'{$info['cantidad']}', {$idPersonaVive});");
					
				$res= $query->row();

				$this->db->close();

				return $res->respuesta;

			}else if($info['idPersonal']!=''){
				// Eliminar persona con la que vive de la base de datos
				if ($idPersonaVive!='') {
					$query= $this->db->query("CALL SE_PA_EliminarPersonaVive({$idPersonaVive},{$info['idPersonal']},{$info['idParentezcos']});");
						
					$res= $query->row();

					$this->db->close();

					return $res->respuesta;
				}else{
					return 0;
				}
			}
		}
	}
	// Se encarga de registrar eliminarlas lineas de las personas que no existen.
	public function eliminarPersonaViveM($info)
	{
	   $query= $this->db->query("CALL SE_PA_EliminarPersonaVive({$info['id']},{$info['idPersonal']},{$info['isParentezco']});");
	   	
	   $res= $query->row();

	   return $res->respuesta;
	}

	public function consultarPersonasViveInfoPersonalM($id)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarPersonasViveInfoPersonal('{$id}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	// Se encarga de registra la infromacion secundaria basica de los empleados que hacen parte de la empresa.
	public function registrarModificarInfoSegundariaM($info)
	{	
		if ($info['accion']==0) {
		  $query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSecundaria({$info['ID']},{$info['estadoC']}, '{$info['fechaN']}', '{$info['lugarN']}', {$info['tipoS']}, '{$info['telF']}', '{$info['cel']}', {$info['EPS']}, {$info['AFP']});");
			
		  $res= $query->row();

		  $this->db->close();

		  return $res->respuesta;	
		}else{
			$idSecundaria= $this->consultarIDFichasSDG($info['documento']);
			$idSecundaria= ($idSecundaria==''?0:$idSecundaria);
			// Consultar id del estado civil
			$query= $this->db->query("SELECT e.idEstado_civil FROM estado_civil e WHERE e.nombre_estado='{$info['estadoCivil']}'");

			$res= $query->row();

			$sb['idEstadoCivil']= $res->idEstado_civil;

			// Consultar id del tipo de sangre
			$query= $this->db->query("SELECT t.idTipo_sangre FROM tipo_sangre t WHERE t.nombre='{$info['tipoSangre']}'");

			$res= $query->row();
			$sb['idTipoSangre']= $res->idTipo_sangre;

			// Consultar id de la eps del empleado
			$query= $this->db->query("SELECT e.idEPS FROM eps e WHERE e.nombre='{$info['EPS']}'");

			$res= $query->row();
			$sb['idEPS']= $res->idEPS;

			// Consultar id de la afp del empleado
			$query= $this->db->query("SELECT a.idAFP FROM afp a WHERE a.nombre='{$info['AFP']}'");

			$res= $query->row();
			$sb['idAFP']= $res->idAFP;
			// Registrar o modificar informacion secundaria basica
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSecundaria({$idSecundaria},{$sb['idEstadoCivil']}, '{$info['fecha_Nacimiento']}', '{$info['lugar_Nacimiento']}', {$sb['idTipoSangre']}, '{$info['telefono_Fijo']}', '{$info['telefono_celular']}', {$sb['idEPS']}, {$sb['idAFP']});");
			
			$res= $query->row();

			$this->db->close();

			return $res->respuesta;

		}
	}

	public function consultarInfoSecundariaBasicaM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarInfoSecundariaBasica('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	// Se encarga de registra la infromacion salarial de los empleados que hacen parte de los empleados.
	public function registrarModificarInfoSalarialM($info)
	{
		if ($info['accion']==0) {//Registrar por la vista
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSalarial({$info['ID']}, {$info['idsalarioP']}, {$info['idClaM']}, '{$info['salarioB']}', '{$info['total']}');");
				
			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{//Registrar por medio de un Excel
			// Consultar id Salarial del empleado
			// $idSalarial= $this->consultarIDModulo($info['documento'], 'idSalarial');
			// $idSalarial= ($idSalarial==''?0:$idSalarial);
			$idSalarial= $this->consultarIDFichasSDG($info['documento']);
			$idSalarial= ($idSalarial==''?0:$idSalarial);
			// var_dump($idSalarial);
			if ($info['PromedioS']!='') {
				// Promedio salarial
				$query= $this->db->query("SELECT p.idPromedio_salario FROM promedio_salario p WHERE p.nombre='{$info['PromedioS']}'");
				// ...
				$idPS= $query->row();
				// ...
				$info['PromedioS']=$idPS->idPromedio_salario;
			}else{
				$info['PromedioS']=0;
			}
			// 
			// Clasificacion mega
			if ($info['ClasificacionM']!='') {
				$query= $this->db->query("SELECT c.idClasificacion_mega FROM clasificacion_mega c WHERE c.clasificacion='{$info['ClasificacionM']}'");

			    $idC= $query->row();
			    // ...
			    $info['ClasificacionM']=$idC->idClasificacion_mega;
			}else{
				$info['ClasificacionM']=0;
			}

			// Registrar información salarial
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSalarial({$idSalarial}, {$info['PromedioS']}, {$info['ClasificacionM']}, '{$info['SalarioB']}', '{$info['totalS']}');");
				
			$res= $query->row();

			$this->db->close();
			 // var_dump($res->respuesta);
			return $res->respuesta;
		}
	}
	// Se encarga de consultar la información salaria de la ficha SDG por Empleado.
	public function consultarInfoSalarialM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarInfoSalarial('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		
		return $res;
	}

	// se encarga de registrar los auxilios que posee cada empleado en sistema de informacion (Esta informacion hace parte de la informacion salarial).
	public function registrarModificarInfoSAuxiliosM($idS,$idAux,$monto,$info)
	{	
		if ($info['accion']==0) {
			$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSalarialAuxilios({$idS},{$idAux},'{$monto}')");
				
			$res= $query->row();

			$this->db->close();

			return $res->respuesta;
		}else{
			// Consultar id Salarial del empleado
			// $idSalarial= $this->consultarIDModulo($info['documento'], 'idSalarial');
			// $idSalarial= ($idSalarial==''?0:$idSalarial);//El id salarial tiene que salir positivo
			$v=[];
			$v=explode(';',$info['contenido']);//Indice 0= Nombre del auxilio y 1=monto total del auxilio
			// ... 
			$query= $this->db->query("SELECT a.idTipo_auxilio FROM tipo_auxilio a WHERE a.auxilio='{$v[0]}' AND a.estado=1");
			// ...
			$res=$query->row();
			// 
			$idAux= $res->idTipo_auxilio;

			if ($v[1]!='') {
				// Registrar o modificar auxilio
				$query= $this->db->query("CALL SE_PA_RegistrarModificarInfoSalarialAuxilios({$info['idSalarial']},{$idAux},'{$v[1]}');");
					
				$res= $query->row();
			}else{
				// Cambiar estado
				$query= $this->db->query("CALL SE_PA_cambiarEstadoAuxilios({$info['idSalarial']},{$idAux})");
					
				$res= $query->row();
			}
			$this->db->close();

			return $res->respuesta;
		}
	}

	// Se encarga de cambiar el estado de los auxilios a los que el empleado ya no se le va a brindar accesso.
	public function cambiarEstadoAuxilioM($idS,$idAux)
	{
		$query= $this->db->query("CALL SE_PA_cambiarEstadoAuxilios({$idS},{$idAux})");
			
		$res= $query->row();

		$this->db->close();

		return $res->respuesta;
	}

	// Se encarga de consultar los auxilio que recibe el empleado.
	public function consultarAuxiliosM($doc)
	{
		$query= $this->db->query("CALL SE_PA_ConsultarInfoSAuxilios('{$doc}')");
			
		$res= $query->result();

		$this->db->close();
		return $res;
	}

	public function consultarCantidadAuxiliosM($doc)
	{	
		$query= $this->db->query("CALL SE_PA_ContarCantidadAuxilios('{$doc}');");

		$res=$query->row();

		$this->db->close();
		return $res->cantidad;
	}

	// Se encarga de registrar los ID de toda la informacion complementaria de la ficha SDG acabada de registrar convergiendo todos los ID en una tabla general.
	public function registrarFichaSDGM($info)
	{
		$query= $this->db->query("CALL SE_PA_RegistrarFichaSDG({$info['documento']},{$info['idSalarial']},{$info['idLaboral']},{$info['idEstudio']},{$info['idSecundariaB']},{$info['idPersonal']},{$info['idSauld']},{$info['idOtros']});");
			
		$res= $query->row();

		$this->db->close();

		return $res->respuesta;
	}

	public function consultarIDModulo($documento,$idBuscar)//Hasta acá se llego el 14/09/2018
	{	
		// validar existencia de la ficha SDG
		$query= $this->db->query("SELECT EXISTS(SELECT * FROM ficha_sd f WHERE f.documento='{$documento}') AS respuesta");

		$res= $query->row();

		if ($res->respuesta==1) {
			// Consultar id de la informacion salarial
			$query= $this->db->query("SELECT s.".$idBuscar." FROM ficha_sd s WHERE s.documento='{$documento}'");

			$res= $query->row();
			// var_dump($res->$idBuscar);
			return $res->$idBuscar;
		}else{
			return '';
		}
	}

	public function consultarIDFichasSDG($doc)
	{
		$query= $this->db->query("SELECT EXISTS(SELECT * FROM ficha_sd f WHERE f.documento='{$doc}') AS respuesta");

		$res= $query->row();

		if ($res->respuesta==1) {
			// Consultar id de la informacion salarial
			$query= $this->db->query("SELECT f.idFicha_SD FROM ficha_sd f WHERE f.documento='{$doc}'");

			$res= $query->row();
			// var_dump($res->$idBuscar);
			return $res->idFicha_SD;
		}else{
			return '';
		}
	}
	// Se encarga de consultar la cantidad todal de las FSDG que hacen parte del sistema de información.
	public function cantidadFSDGM()
	{
		$this->db->select("COUNT(*) as cantidad");
		$this->db->from("ficha_sd");

		return $this->db->get()->row();
	}
}
?>