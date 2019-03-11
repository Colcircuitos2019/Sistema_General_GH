<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
* 
*/
class mProducto extends CI_Model
{
	
	function __construct()
	{
		parent::__construct();
		$this->load->database();
	}
//=========================== Metodos
   public function registrarModificarProductosM($id,$info){

     	if ($id==0) {//si el id es 0 va a registrar el productos
        $this->db->insert('producto',$info);
        if ($this->db->insert_id()!=0) {
          return true;
        }else{
          return false;
        }
      }else{//Si no es igual a 0 va actualizar
        $this->db->where('idProducto',$info['idProducto']);
        $datos['nombre']=$info['nombre'];
        $datos['precio']=$info['precio'];
        $datos['idProveedor']=$info['idProveedor'];

        $this->db->update('producto',$datos);

        return true;
      }
   }

   public function consultarProductosM($op,$idPro)
   {  
      if($op==1){
      //Consulta todos los productos
         $this->db->select('p.idProducto,p.nombre,CONCAT("$",FORMAT('.'p.precio'.', 0)) as precio,p.estado,pr.nombre as proveedor,p.idProveedor as idproveedor',false);
         $this->db->from('producto p');
         $this->db->join('proveedor pr','p.idProveedor=pr.idProveedor');
         $this->db->where('pr.estado',1);   
      }else{
        //Consulta los productos por proveedor
      $this->db->select('p.idProducto,p.nombre,p.precio as valor,CONCAT("$",FORMAT('.'p.precio'.', 0)) as precio',false);
      $this->db->from('producto p');
      $this->db->join('proveedor pr','p.idProveedor=pr.idProveedor');
      $this->db->where('pr.idProveedor',$idPro);
      $this->db->where('p.estado',1);      
      }

   		$r= $this->db->get();

   		return $r->result();
   }

   public function eliminarProductosM($id)
   {
     mysqli_next_result($this->db->conn_id);

     $query= $this->db->query("CALL SA_PA_CambiarEstadoProducto({$id});");

     $res=$query->row();

     // $this->db->where('idProducto',$id);
     // $this->db->update('producto',$estado);

     return $res->respuesta;
   }

}

 ?>