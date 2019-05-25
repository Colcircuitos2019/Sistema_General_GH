BEGIN

/*Tareas 
1- Colocar un horario por defecto de 6 am a 6 pm para sabados domingos y festivos.
2- Cierre de las asistencias por defecto.
3- Que el administrador pueda parametrizar horarios para los sabados domingos y festivos.
4- Crear un modulo donde el administrador pueda ingresar los tiempos teoricos  - semanal.
5- realizar la correcta liquidacion de tiempos trabajado por cada operarios.
*/
#PsicodelicoSpice
#Global#Esta es la version de control de asistencia mediante contraseña
#Falta integrar la configuracion de horario que va a tener cada empleado...Pendiente
#El evento de desayuno o almuerzo se cerraran cuando se vuelva a colocar la huella(contraseña) 5 minutos despues te la domo inicial del evento.
#Los tiempos de los eventos no se pueden cambiar mientras alguna persona este en ejecucion de algune evento.
#El sistema generara alerta de las personas que lleguen tarde del cualquier evento(Laboral, Desayuno o almuerzo). (El evento laboral ya lo genera, pendiente generar el de los eventos desayuno y almuerzo).
#El sistema cerrar automaticamente las asistencias que pasen el tiempo de cada evento(Laboral, Desayuno o Almuerzo)Esto no esta desarrollado...
#Por el momento no se va a tener en cuenta los permisos.(Pendiente realizar)
#Falta implementar la toma de tiempo cuando hay un permiso (Existen tres tipos de permiso, uno de ingreso tarde, otro de salida temprano y otro de salida y regreso laboral.).
#Validar que si no sale al desayuno o almuerzo en los horarios establecidos para estos eventos, tome en cuenta el siguiente enveto (de desayuno tome almuerzo o del almuerzo tome la salida) y colocar un estado a ese evento de no asistido.
DECLARE doc varchar(13);
DECLARE idAsistencia int;
DECLARE fecha_inicio_asistencia varchar(10);
DECLARE fecha_fin_asistencia varchar(10);
DECLARE estadoA tinyint(1);
DECLARE horaInicioEvento varchar(20); #hora de inicio de algun event
DECLARE horaFinEvento varchar(20); #hora fin de algun evento
DECLARE horaD varchar(20); #Hora de inicio del evento Desayuno o almuerzo
DECLARE tiempo varchar(10); #Tiempo total laborado el día de hoy.
DECLARE permiso tinyint(1);
DECLARE multiplesEventos tinyint(1);
DECLARE cantidad_eventos_que_aplican tinyint(1);
#Buscamos el documendo de la perzona a la cual pertenece la huella (rol =1 =Operario), (estado=1=activado), huellas...
#SET doc=(SELECT e.documento FROM empleado e WHERE e.huella1=huella OR e.huella2=huella OR e.huella3=huella AND e.estado=1 AND e.idRol=1);
#Consultar documento del empelado por la contrasela que tiene asociada cada empleado para realizar diferentes acciones dentro de la empresa.
SET doc=(SELECT e.documento FROM empleado e WHERE e.contraseña COLLATE utf8_bin = contra AND e.estado=1 AND e.idRol=1);
#preguntamos si existe alguien con esa huella, si existe alguien con la huella que inserte el registro, si no no va a realizar la inserción.
#Pendiente por catualizar esta forma de contar las asistencias.
SET multiplesEventos = (SELECT SI_FU_ArreglarProblemaBugAsistenciaMultiplesEventos(doc));#->Se encarga de eliminar los registros duplicados del mismo evento (Desayuno, Almuerzo o laboral) en dado caso de que existan.

#Condicional de documento.------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------7
#Validar si dejo una asistencias abierta, si es así entonce se va a cerrar y liquidar por defecto a la hora de salida del horario laboral.
IF doc!='' THEN

  SET idHorario = (SELECT SI_FU_ClasificacionHorario(idHorario));
  
  #se valida que la en el día no tenga más de un evento laboral, si lo tiene no se puede volver a registrar el dia actual otro evento de esos.-----------------------------------------------------------------------------------------------------------------8
  SET permiso = (SELECT SE_FU_ValidacionPermisosEmpleadosAsistencia(doc, idHorario));#Validacion de existencia de permiso para el día de hoy.
  
  IF permiso = -1 or permiso = 2 THEN # Va a continuar con la toma de los eventos normalmente

    #... en vez de validar la fecha, validamos la ultima asistencia junto al intervalo de hora del horario
    IF ((SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento = doc AND a.idTipo_evento=1 AND a.fin IS NOT null AND a.inicio IS NOT null AND TIME_FORMAT(TIMEDIFF(now(), a.fin),'%H:%i:%s') <= '04:00:00') is not null) = 0  THEN
      
      #Validar cierre de asistencia del día anterior.
      CALL SI_PA_CierreDeAsistenciaAbiertas(doc);

      #validamos si existe una asistenca de tipo laboral dentro del horario estipulado---------------------------------------------------------------------------------------------------------------------------------------------------------------6
      IF ((SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.inicio is not null AND a.fin IS null) is not null) = 1 THEN 
        #Validacion de cuantos eventos tiene en un dia de evento normal.-------------------------------------------------------------------------------------------------------------------------5
        
        SET idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.inicio is not null AND a.fin is null AND a.estado = 1);
        SET idHorario = (SELECT a.idConfiguracion FROM asistencia a WHERE a.idAsistencia=idAsistencia);

        #validar si el horario que tiene el empleado es diurna o nocturno. ->(La hora de inicio laboral es mayor a la hora de fin laboral)
        #Esto se tiene que realizar para todos los eventos---
        IF (SELECT c.hora_ingreso_empresa FROM configuracion c WHERE c.idConfiguracion = idHorario) >= (SELECT c.hora_salida_empresa FROM configuracion c WHERE c.idConfiguracion = idHorario) THEN
        #Horario Nocturno

          SET fecha_fin_asistencia = (SELECT DATE_ADD(a.inicio, INTERVAL 1 DAY) FROM asistencia a WHERE a.idAsistencia = idAsistencia);

        ELSE
        #Horario Diurna.

          SET fecha_fin_asistencia = (SELECT DATE_FORMAT(a.inicio, '%Y-%m-%d') FROM asistencia a WHERE a.idAsistencia = idAsistencia);

        END IF;

        #Validacion la cantidad de eventos disponibles en el día...
        SET cantidad_eventos_que_aplican = (SELECT SI_FU_CantidadEventosQueAplicanHorario(idHorario));

        SET fecha_inicio_asistencia = (SELECT DATE_FORMAT(a.inicio, '%Y-%m-%d') FROM asistencia a WHERE a.idAsistencia = idAsistencia);

        #validamos la existencia de los eventos que no se lograron asistir y se generan con un estado de no asistio.
        CALL SI_PA_ValidacionEventosNoAsistidos(doc, lector, idHorario, fecha_inicio_asistencia, fecha_fin_asistencia); # Pendiente actualizar

        #Valida que la cantidad de eventos que se programaron en el horario si se cumplan con la cantidad de eventos que se activaron.
        -- IF (SELECT COUNT(*) FROM (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE (a.idTipo_evento = 2 OR a.idTipo_evento = 3) AND a.documento=doc AND (DATE_FORMAT(a.inicio, '%Y-%m-%d') BETWEEN fecha_inicio_asistencia AND fecha_fin_asistencia) AND a.fin is NOT null GROUP BY a.idTipo_evento) AS idEventos) = cantidad_eventos_que_aplican THEN
        IF (SELECT COUNT(*) FROM (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE (a.idTipo_evento = 2 OR a.idTipo_evento = 3) AND a.documento = doc AND a.idAsistencia > (SELECT MAX(asi.idAsistencia) FROM asistencia asi WHERE asi.idTipo_evento =1 AND asi.documento = a.documento) AND a.fin is NOT null GROUP BY a.idTipo_evento) AS idEventos) = cantidad_eventos_que_aplican THEN

         -- IF  (SELECT SI_FU_ValidacionCierreAsistencia(idHorario)) = 1  THEN # Si se puede cerrar la asistencia? # Actualizar -> pendiente

             #La hora del sistema menos la hora de inicio del ultimo evento tiene que ser igual o mayor a 5 minutos para poder cerrar la asistencia. 
             # or (SELECT SI_FU_ValidacionCierreAsistencia(idHorario)) = 1
            IF ((SELECT TIME_FORMAT(TIMEDIFF(now(), asi.inicio), '%H:%i:%s') FROM asistencia asi WHERE asi.idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.inicio is not null AND a.fin is null)) >= '00:30:00') THEN

              #Cierra el evento de asistencia Laboral!!!
              UPDATE asistencia a SET a.fin = now(), a.lectorF = lector, a.estado = 0 WHERE a.documento = doc AND a.idAsistencia = idAsistencia AND a.idConfiguracion = idHorario;
              
              #valida la existencia de un permiso de tiempo extra...
              IF EXISTS(SELECT * FROM tiempo_extra t WHERE t.idAsistencia = idAsistencia) THEN

                UPDATE tiempo_extra t SET t.hora_fin_tiempo_extra = (SELECT ht.hora FROM hora_salida_tiempo_extra ht WHERE ht.idhora_salida_tiempo_extra = 1)  WHERE t.idAsistencia = idAsistencia;

              END IF;


              SET horaInicioEvento = (SELECT a.inicio FROM asistencia a WHERE a.idAsistencia = idAsistencia);
              SET horaFinEvento = (SELECT a.fin FROM asistencia a WHERE a.idAsistencia = idAsistencia);
              # ...
              SET tiempo = (SELECT TIMEDIFF(horaFinEvento, horaInicioEvento));
              # ...
              UPDATE asistencia a SET a.tiempo = tiempo WHERE a.idAsistencia = idAsistencia;
              # ...
              CALL SI_PA_CalcularRegistrarHorasTrabajadas(idHorario, 1, horaInicioEvento, horaFinEvento, idAsistencia);# Actualizar
              #...

             END IF;
         -- END IF;
        ELSE    

          #valida lo otros eventos de la asistencia (Desayuno y almuerzo)
          CALL SI_PA_GestionEventosAlmuerzoDesayuno(doc, lector, idHorario, fecha_inicio_asistencia, fecha_fin_asistencia);# Actualizar -> Pendiente

        END IF;

      #Validacion de cuantos eventos tiene en un dia de evento normal.-------------------------------------------------------------------------------------------------------------------------5    
      ELSE

        SET idHorario = (SELECT SI_FU_ClasificacionHorario(idHorario));

        SET horaInicioEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_ingreso_empresa) FROM configuracion c WHERE c.estado = 1 AND c.idConfiguracion = idHorario LIMIT 1);

        # Validar que solo permita el ingreso a las personas 15 minutos antes de su horario laboral
        IF (TIMEDIFF(horaInicioEvento, now()) <= '00:15:00') OR (TIMEDIFF(horaInicioEvento, now()) <= '00:00:00') THEN
        #...
        
          #Asistencia de tipo evento Laboral
          INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `inicio`, `fin`, `idEstado_asistencia`, `estado`, `lectorI`,`idConfiguracion`) VALUES (doc, 1, now(), null, 1, 1, lector, idHorario);
          
          -- UPDATE empleado e SET e.asistencia=1 WHERE e.documento=doc;#acutualizar el estado del empleado en la empresa 1=Presente
       
          #Clasificaion del tipo de estado de la asistencia
          SET idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento = doc AND a.idTipo_evento = 1 AND a.inicio is not null AND a.fin is null);
          SET horaInicioEvento = (SELECT a.inicio FROM asistencia a WHERE a.idAsistencia = idAsistencia);
          SET horaFinEvento='0000-00-00 00:00:00'; # Al clasificar el estado de la asistencia laboral no se va a tomar en cuenta esta variable.

          # Validacion de seleccion de estado dependiento si tiene un permiso para el día de hoy de llegada tarde
          IF permiso=2 THEN

            SET estadoA=1;

          ELSE

            SET estadoA = (SELECT SI_FU_ClasificacionEstadoAsistencia(1, horaInicioEvento, horaFinEvento, idHorario));#Estado de la asistencia para el igreso laboral

          END IF;

          #Actualizar el estado del operario que registro la asistencia laboral.
          UPDATE asistencia a SET a.idEstado_asistencia= estadoA  WHERE a.idAsistencia = idAsistencia;

          IF estadoA = 2 THEN

            CALL SI_PA_GeneradorDeAlertas();#Genera la alerta de llegada tarde de los empleados

          END IF;

        ELSE
        
          SET doc=-2;
        #...
        END IF;
      #
      END IF; 
       #validamos si existe una asistenca de tipo laboral fin---------------------------------------------------------------------------------------------------------------------------------------------------------------6
    END IF;# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------8
  
  #Fin validacion permiso 

  ELSE # Permiso es de tipo Salida e Ingreso

    -- pendiente revisar (integracion con el modulo de permiso)

    SET idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento = 1 AND a.inicio is not null AND a.fin is null AND a.estado = 1);
    SET idHorario = (SELECT a.idConfiguracion FROM asistencia a WHERE a.idAsistencia=idAsistencia);

    IF (SELECT c.hora_inicio_desayuno FROM configuracion c WHERE c.idConfiguracion = idHorario) > '00:00:00' THEN


      IF (SELECT SI_FU_ValidarHoraMayor(idHorario, 2)) = 1 THEN
      # Horario Nocturno

        SET horaInicioEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_inicio_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario); 
        SET horaFinEvento = (SELECT CONCAT(DATE_ADD(CURDATE(), INTERVAL 1 DAY), ' ', c.hora_fin_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);  

      ELSE
      #Horario Diurna

        SET horaInicioEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_inicio_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);  
        SET horaFinEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_fin_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);  

      END IF;


      IF EXISTS(SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento = 2 AND a.inicio is not null AND a.fin is null AND a.estado = 1) THEN

        #Cerrar evento de desayuno
        CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 2, lector, idHorario, 1, horaInicioEvento, horaFinEvento);#Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo Pendientes

      END IF;

    END IF;


    IF (SELECT c.hora_inicio_almuerzo FROM configuracion c WHERE c.idConfiguracion = idHorario) > '00:00:00' THEN


      IF (SELECT SI_FU_ValidarHoraMayor(idHorario, 3)) = 1 THEN
      # Horario Nocturno

        SET horaInicioEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_inicio_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario); 
        SET horaFinEvento = (SELECT CONCAT(DATE_ADD(CURDATE(), INTERVAL 1 DAY), ' ', c.hora_fin_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);  

      ELSE
      #Horario Diurna

        SET horaInicioEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_inicio_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);  
        SET horaFinEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_fin_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);  

      END IF;

      IF EXISTS(SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento = 3 AND a.inicio is not null AND a.fin is null AND a.estado = 1) THEN

        #Cerrar evento de Almuerzo
        CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 3, lector, idHorario, 1, horaInicioEvento, horaFinEvento);#Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo. Pendiente

      END IF;

    END IF;


    # Hasta acá se llego el 25/05/2019 -> Pendiente pasar al procedimiento almacenado y probarlo...

    #...
    #SET doc = permiso;

  END IF;

#....
END IF;
#Condicional de documento.--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------7
    #Retornar el numero de documento de la persona perteneciente a la huella dactilar.
    -- SELECT doc AS documento;
    SELECT doc as documento, (SELECT CONCAT(LOWER(e.nombre1), ' ',LOWER(e.nombre2), ' ',LOWER(e.apellido1), ' ',LOWER(e.apellido2)) FROM empleado e WHERE e.documento = doc) as nombre;
END
#MTIzNA==

/*Pendientes 

-Revisar el calcular horas trabajadas diarias cuando se edita los tiempos de asistencia de los empleados, ya que este no esta calculando las horas cuando el horario tiene menos de 3 eventos.


*/