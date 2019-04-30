<?php 
if (!defined('BASEPATH')) exit('No direct script access allowed');  
 
require_once 'dompdf/autoload.inc.php';

use Dompdf\Dompdf;

class PDFConsolidadoLiquidacion extends Dompdf
{
	public function __construct()
	{
		 parent::__construct();
	}

	public function header()
	{
		$fechaAcctual = getdate();

			return '<div><p>Medellín '.$fechaAcctual["mday"].' de '.$fechaAcctual["month"].' de '.$fechaAcctual["year"].'</p></div>
					<br>
					<br>
					<br>
					<br>
					<br>
					<div>señores</div>
					<br>
					<br>
					<br>
					<div><b>DAR AYUDA TEMPORAL S.A.</b></div>
					<br>
					<br>
					<br>
					<div>Medellín</div>
					<br>
					<br>
					<br>
					<br>
					<br>';
	}

	public function body($variables)
	{
		
		return '<div><p>Yo <b>'.$variables["nombre"].'</b>, identificado con cedula de ciudadanía No. <b>'.$variables["documento"].'</b>, empleado en misión de la empresa COLCIRCUITOS S.A.S, me permito autorizar para que de mi salario se descuente el valor quincenal de <b>'.$variables["liquidacion"].'</b>, por concepto de préstamo hecho por la empresa usuaria hasta completar el valor de <b>'.$variables["liquidacion"].'</b>.</p></div>
			<div><p>De igual forma autorizo para que en caso de retiro de la empresa, se descuente de mis prestaciones sociales los saldos que a la fecha adeude a la empresa usuaria.</p></div>
			<br>
			<br>
			<br>
			<br>
			<div><p>Atentamente,</p></div>
			<br>
			<br>
			<br>
			<br>
			<div><p><b>'.$variables["nombre"].'</b></p></div>
			<br><br>
			<div><p>CC.<b>'.$variables["documento"].'</b> de _____________________________</p></div>
			<div class="saltopagina"></div>';

	}

}

?>