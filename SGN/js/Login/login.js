$(document).ready(function () {//

	$(document).on('submit', '#iniciar', function(event) {
		event.preventDefault();
		if($('#user').val()!='' && $('#contraseña').val()!=''){
		//Ajax
     		$.ajax({
     			url: baseurl+'cLogin/iniciarSession',
     			type: 'POST',
     			dataType: 'json',
     			data: {usu: $('#user').val(),cont: $('#contraseña').val()},
     		})
		    .done(function(respuesta) {
			//alert(respuesta);
			var tipo= JSON.parse(respuesta);
    			if (tipo!=0) {
    			 switch(tipo) {
                      case 2:
                         //Empelado (Vista de pedidos)				
                         window.location.href = baseurl+'Alimentacion/cPedidos';
                          break;
                      case 3:
                         //Gestos de alimentacion (Vista de administracion de pedidos)				
                         window.location.href = baseurl+'Alimentacion/cAlimentacion';
                          break;
                      case 4:
                         //Gestos pedidos (Vista de listado de todos los pedidos)			
                         window.location.href = baseurl+'Alimentacion/cPedidos/pedidos';
                          break;
                      case 5:
                         //Gestor Humano				
                         window.location.href = baseurl+'Empleado/cMenu';
                          break;
                      case 6:
                         //Facilitador        
                         window.location.href = baseurl+'Empleado/cMenu';
                          break;
                      case 7:
                         //Lider de produccion				
                         window.location.href = baseurl+'Empleado/cMenu';
                          break;                                                                                                         
                    }
	    		}else{
	    			swal({
			            type: 'error',
                        title: 'Incorrecto',
                        text: 'El usuario o la contraseña son incorrectos, porfavor intente nuevamente.',
                        timer: 3000,
                    });
	    		}
	    	})
		   .fail(function(error) {
			  //alert(error);
			  console.log(error.responseText);
		   });			
		}else{

    }
	});
})

function nobackbutton(){

   window.location.hash="no-back-button";

   window.location.hash="Again-No-back-button" //chrome

   window.onhashchange=function(){window.location.hash="no-back-button";}

}
