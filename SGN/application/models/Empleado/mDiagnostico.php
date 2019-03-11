<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
  * 
  */
 class mDiagnostico extends CI_Model
 {
 	
 	function __construct()
 	{
 		parent::__construct();
 		$this->load->database();
 	}

 	public function registrarModificarDiagnosticoM($info)
 	{	
 		$query= $this->db->query("CALL SE_PA_RegistrarModificarEstadoDiagnostico('{$info['idDiagnostico']}','{$info['diagnostico']}',{$info['op']});");

 		$result=$query->row();

    $this->db->close();
    
 		return $result->respuesta;
 	}

 	public function ConsultarDiagnosticosM($estado)
 	{
 		$query= $this->db->query("CALL SE_PA_ConsultarDiagnosticos({$estado});");

 		$result=$query->result();

 		$this->db->close();

 		return $result;
  	}

  	public function validarExistenciaCodM($cod)
  	{
  		$this->db->select('*');
  		$this->db->from('diagnostico');
  		$this->db->where('idDiagnostico',$cod);

  		$query= $this->db->get();

      $this->db->close();

  		if ($query->num_rows()==1) {
  			return false;
  		}else{
  			return true;
  		}
  	}
 } ?>