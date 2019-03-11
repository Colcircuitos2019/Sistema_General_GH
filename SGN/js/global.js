// Funciones globales que va a implementar todo el sistema de informacion...

// ...
//Validar que el input solo permita caracteres numericos
function validaTechaF12(e) {
    var res= true;
    tecla = (document.all) ? e.keyCode : e.which;
    //Tecla de retroceso para borrar, siempre la permite
    // console.log(tecla);
    // console.log(tecla);
    if (tecla==123) {//Tecla F12
    	res=false;
    }
    // ...
    return res;
}
// ...