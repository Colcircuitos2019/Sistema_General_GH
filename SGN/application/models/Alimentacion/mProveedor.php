<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mProveedor extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
//=========================== Metodos


   public function registrarModificarProveedorM($info){
	
	    mysqli_next_result($this->db->conn_id);//Soluciona el problema     con del DB_Driver de codeigneiter.

      $query=$this->db->query("CALL SA_PA_RegistrarModificarProveedor({$info['idProveedor']}, '{$info['nombre']}', '{$info['telefono']}', {$info['estado']}, {$info['evento']}, '{$info['email']}');");

      $res= $query->row();

     	// if ($id==0) {//si el id es 0 va a registrar
      //   $this->db->insert('proveedor',$info);
      //   if($this->db->insert_id()!=0){
      //     return true;
      //   }else{
      //     return false;
      //   }        
      // }else{//Si no es igual a 0 va actualizar
      //   $this->db->where('idProveedor',$id);
      //   $this->db->update('proveedor',$info);

        return $res->respuesta;
      // }
   }

   public function consultarProveedoresM($op)
   {
      if ($op==2 || $op==3) {
       $this->db->select('*');
       $this->db->from('proveedor');
      }else{
        $this->db->select('*');
        $this->db->from('proveedor');
        $this->db->where('evento',1);
      }

   		$r= $this->db->get();

   		return $r->result();
   }

   public function eliminarProveedorM($id)
   {
      $query=$this->db->query("CALL SA_PA_CambiarEstadoProveedor({$id});");

      $res= $query->row();

      return $res->respuesta;
   }

}

 ?>