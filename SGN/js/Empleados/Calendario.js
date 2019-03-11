$(document).ready(function() { //Pendiente terminar el desarrollo--------
    $.post(baseurl + 'Empleado/cNotificacion/consultarNotificacionesUsuario', {
        rol: 7,
        view: 2
    }, function(dataObjJSON) {
        // console.log(data);
        // var result= JSON.parse((dataObjJSON.slice(0,dataObjJSON.length-2)));
        var result= JSON.parse(dataObjJSON);
        var $notificaciones= new Array();
        $.each(result, function(index, item) {
             $notificaciones.push({title: item.comentario  ,start: item.origen1 ,color: clasificacrColorAsistencia(item.idTipo_notificacion)});
        });
        // ...
        $('#calendar1').fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            defaultDate: new Date(),
            navLinks: true, // can click day/week names to navigate views
            editable: true,
            eventLimit: true, // allow "more" link when too many events
            events: $notificaciones
        });
    });
});

function clasificacrColorAsistencia(tipoAsis) {
    var color ='';
    switch(Number(tipoAsis)){
        case 1://Cumpleaños
            color='#D5CD00';
            break;
        case 2://Aniversario
            color='#11D108';
            break;
        case 3://Contrato 
            color='#0361FE';           
            break;
        case 4://Llegadas tarder
            color='#EA0707';
            break;    
    }
    return color;
}
//             {
//                 title: 'Llegadas tarde',
//                 start: '2018-07-04'
//             }, {
//                 title: 'Cumpleaños',
//                 start: '2018-07-04',
//                 // end: '2018-06-10'
//             }, {
//                 id: 999,
//                 title: 'Repeating Event',
//                 start: '2018-07-05T16:00:00'
//             }, {
//                 id: 999,
//                 title: 'Repeating Event',
//                 start: '2018-03-16T16:00:00'
//             }, {
//                 title: 'Conference',
//                 start: '2018-03-11',
//                 end: '2018-03-13'
//             }, {
//                 title: 'Meeting',
//                 start: '2018-03-12T10:30:00',
//                 end: '2018-03-12T12:30:00'
//             }, {
//                 title: 'Lunch',
//                 start: '2018-03-12T12:00:00'
//             }, {
//                 title: 'Meeting',
//                 start: '2018-03-12T14:30:00'
//             }, {
//                 title: 'Happy Hour',
//                 start: '2018-03-12T17:30:00'
//             }, {
//                 title: 'Dinner',
//                 start: '2018-03-12T20:00:00'
//             }, {
//                 title: 'Birthday Party',
//                 start: '2018-03-13T07:00:00'
//             }, {
//                 title: 'Click for Google',
//                 url: 'http://google.com/',
//                 start: '2018-03-28'
//             }