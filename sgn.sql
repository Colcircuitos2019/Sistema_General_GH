-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:33066
-- Tiempo de generación: 16-05-2019 a las 17:50:46
-- Versión del servidor: 10.1.29-MariaDB
-- Versión de PHP: 7.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sgn`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizarcontras` (IN `doc` VARCHAR(13), IN `contra` VARCHAR(50))  NO SQL
BEGIN

UPDATE empleado e SET e.contraseña=contra WHERE e.documento=doc;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_ConsultarEmpleadosColtime` (IN `doc` VARCHAR(20), IN `name` VARCHAR(50))  NO SQL
BEGIN

IF doc!='' AND name='' THEN
#Consultar por numero de documento
SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2 FROM empleado e WHERE e.documento LIKE CONCAT(doc,'%') AND e.idRol=1;
#...
ELSE
  IF doc='' AND name!='' THEN
	#Consultar por nombre del empleado AND (e.nombre1 LIKE CONCAT('%',name,'%') OR e.nombre2 LIKE CONCAT('%',name,'%') OR e.apellido1 LIKE CONCAT('%',name,'%') OR e.apellido2 LIKE CONCAT('%',name,'%'))
SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2 FROM empleado e WHERE e.idRol=1 AND CONCAT(e.nombre1,' ',e.nombre2,' ',e.apellido1,' ',e.apellido2) LIKE CONCAT('%',name,'%');
  ELSE  
	#Consultar en general
SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2 FROM empleado e WHERE e.idRol=1;
  END IF;
#...
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_EliminarEstadoEmpresarial` (IN `idEstadoEmpresarial` INT)  NO SQL
BEGIN

	DELETE FROM estado_empresarial WHERE idEstado_empresarial = idEstadoEmpresarial;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_GenerarNotificacionesDelDia` (IN `idUser` INT)  NO SQL
BEGIN

DECLARE canCumple int;
DECLARE canAniversario int;
DECLARE canVencimiento int;
#...
#notificaciones de cumpleaños( Cuenta cuantas personas esta cumpliendo años el dia de hoy).
SET canCumple= (SELECT COUNT(*) FROM secundaria_basica s JOIN ficha_sd f ON s.idSecundaria_basica=f.idSecundaria_basica JOIN empleado e ON f.documento=e.documento WHERE DATE_FORMAT(s.fecha_nacimiento,'%d-%m')=DATE_FORMAT(CURDATE(),'%d-%m')) AND e.estado=1;
#validacion...
IF canCumple>0 THEN
    #... Existe ...
    IF !EXISTS(SELECT * FROM notificacion n WHERE DATE_FORMAT(n.fecha,'%Y-%m-%d')=CURDATE() AND n.idTipo_notificacion=1 AND n.idUsuario=idUser) THEN
    #Solo se les registra a los gestores humanos
    	INSERT INTO `notificacion`(`fecha`, `comentario`, `leido`, `idUsuario`, `idTipo_notificacion`) VALUES (now(),CONCAT('Hoy esta/n cumpliendo años ',canCumple,' persona/s'),0,idUser,1);
    END IF;
END IF;

#Notificacion de aniversario (Cuenta cuantas personas estan cumpliendo un año o más vinculados a la empresa...)
#por el momento se va a calcular el aniversario por el estado activo y la fecha en que se registro el empleado...
SET canAniversario= (SELECT COUNT(*) FROM empleado e WHERE DATE_FORMAT(e.fecha_registro,'%d-%m')=DATE_FORMAT(CURDATE(),'%d-%m') AND DATE_FORMAT(CURDATE(),'%Y')>DATE_FORMAT(e.fecha_registro,'%Y') AND e.estado =1);
#validacion...
IF canAniversario>0 THEN
    #... Existe ...
    IF !EXISTS(SELECT * FROM notificacion n WHERE DATE_FORMAT(n.fecha,'%Y-%m-%d')=CURDATE() AND n.idTipo_notificacion=2 AND n.idUsuario=idUser) THEN
    #Solo se les registra a los gestores humanos
    	INSERT INTO `notificacion`(`fecha`, `comentario`, `leido`, `idUsuario`, `idTipo_notificacion`) VALUES (now(),CONCAT('Hoy es el aniversario de ',canAniversario,' persona/s en la empresa'),0,idUser,2);
    END IF;
END IF;

#notificacion del vencimiento de contrato de los empleados (Esta notificacion le llega unicamente al gestor humano)
SET canVencimiento=(SELECT COUNT(*) FROM laboral l JOIN ficha_sd f ON l.idLaboral=f.idLaboral JOIN empleado e ON f.documento=e.documento WHERE DATEDIFF(CURDATE(),l.fecha_vencimiento_contrato)=45 AND l.idTipo_contrato=1 AND e.estado=1);
#validacion...
IF canVencimiento>0 THEN
	#...
	IF !EXISTS(SELECT * FROM notificacion n WHERE DATE_FORMAT(n.fecha,'%Y-%m-%d')=CURDATE() AND n.idTipo_notificacion=3 AND n.idUsuario=idUser) THEN
      #Solo se les registra a los gestores humanos
	  INSERT INTO `notificacion`(`fecha`, `comentario`, `leido`, `idUsuario`, `idTipo_notificacion`) VALUES (now(),CONCAT(canAniversario,' Contratos proximos a vencer...'),0,idUser,3);
    END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_Inicio_Session` (IN `user` VARCHAR(45), IN `contra` VARCHAR(20))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM usuario u WHERE u.nombre=user AND u.contraseña=contra) THEN

SELECT u.idTipo_usuario FROM usuario u WHERE u.nombre= user AND u.contraseña=contra;

ELSE

SELECT 0;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_loginSistema` (IN `nom` VARCHAR(45), IN `cont` VARCHAR(100))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM usuario u WHERE u.nombre  COLLATE utf8_bin =nom AND  u.contraseña  COLLATE utf8_bin=cont AND u.estado=1) THEN
#cuando existe retorna el tipo de usuario que es
SELECT u.idTipo_usuario AS respuesta, u.idUsuario AS usuario, t.nombre FROM usuario u JOIN tipo_usuario t ON u.idTipo_usuario=t.idTipo_usuario WHERE u.nombre  COLLATE utf8_bin =nom AND  u.contraseña  COLLATE utf8_bin=cont;

ELSE
#Cuando no existe retorna el tipo de usuario que no existe
SELECT 0 AS respuesta;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_SE_ConsultarIncapacidadesEmpleadoRangoFecha` (IN `documento` VARCHAR(20), IN `fecha1` VARCHAR(10), IN `fecha2` VARCHAR(10))  NO SQL
BEGIN

IF fecha1!='' AND fecha2!='' THEN
#Consultar por rango de fechas
	SELECT i.fecha_incapacidad,i.idTipoIncapacidad,i.dias FROM incapacidad i WHERE i.documento=documento AND (i.fecha_incapacidad BETWEEN fecha1 AND fecha2); 
ELSE
#consultar por una fecha
	SELECT i.fecha_incapacidad,i.idTipoIncapacidad,i.dias FROM incapacidad i WHERE i.documento=documento AND i.fecha_incapacidad=fecha1; 
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PA_SE_GenerarNotificacionEmpleadoNuevo` (IN `idUser` INT)  NO SQL
BEGIN
DECLARE cant int;
SET cant=(SELECT COUNT(*) FROM empleado e WHERE e.fecha_registro=CURDATE());
#...
IF EXISTS(SELECT * FROM notificacion n WHERE n.idTipo_notificacion=5 AND DATE_FORMAT(n.fecha,'%Y-%m-%d')=CURDATE() AND n.idUsuario=idUser) THEN
#Actualizar
 UPDATE notificacion n SET n.comentario=CONCAT(cant,' nuevo/s Empleado/s'), n.leido=0 WHERE n.idTipo_notificacion=5 AND DATE_FORMAT(n.fecha,'%Y-%m-%d')=CURDATE();
ELSE
#Registrar
  INSERT INTO `notificacion`(`fecha`, `comentario`, `leido`, `idUsuario`, `idTipo_notificacion`) VALUES (now(),CONCAT(cant,' nuevo/s Empleado/s'),0,idUser,5);
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prueba` (IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN

SET @DiaSemana     = 7; -- 7 domingo, 1 lunes
SET @Minimo        = CASE WHEN DAYOFWEEK(fechaI)-1 = 0 THEN 7 ELSE DAYOFWEEK(fechaI)-1 END;
#
SELECT datediff(fechaF, fechaI) DIV 7 + (CASE WHEN @Minimo = @DiaSemana THEN 1 ELSE 0 END);


END$$

CREATE DEFINER=`` PROCEDURE `prueba1` (IN `contra` VARCHAR(20), IN `lector` TINYINT(1), IN `idHorario` TINYINT(1))  NO SQL
BEGIN

    IF EXISTS(SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento='1216727816' AND a.idTipo_evento=1 AND a.fecha_fin IS NOT null AND a.fecha_inicio IS NOT null AND a.fecha_inicio >= CURDATE())  THEN
    	
        SELECT "Existe";
    
    ELSE
    
    	SELECT "No existe";
        
    END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_CambiarEstadoPedido` ()  NO SQL
BEGIN

# 0 = el pedido no se a realizado y 1= el pedido se ha realizado.
UPDATE pedido SET estado=1 WHERE DATE_FORMAT(fecha_pedido,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');

SELECT true as respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_CambiarEstadoProducto` (IN `id` INT)  NO SQL
BEGIN
DECLARE estado tinyint(1);

IF EXISTS(SELECT * FROM producto p WHERE p.idProducto=id AND p.estado=1) THEN

SET estado=0;

ELSE

SET estado=1;

END IF;

UPDATE producto p SET p.estado=estado WHERE p.idProducto=id;

SELECT true AS respuesta;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_CambiarEstadoProveedor` (IN `id` INT)  NO SQL
BEGIN
DECLARE estado tinyint(1);

IF EXISTS(SELECT * FROM proveedor p WHERE p.idProveedor=id AND p.estado=1) THEN

SET estado=0;

ELSE

SET estado=1;

END IF;

UPDATE proveedor p SET p.estado=estado WHERE p.idProveedor=id;

SELECT true AS respuesta;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_CantidadProductosProveedorDia` (IN `idP` INT)  NO SQL
BEGIN

IF idP=0 THEN
#busqueda para los pedidos de los proveedores por el día.
SELECT pr.nombre AS proveedor,p.nombre AS producto,sum(l.cantidad) AS cantidad,l.idMomento FROM pedido pd JOIN lineas_pedido l ON pd.idPedido=l.idPedido JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pr ON p.idProveedor=pr.idProveedor WHERE DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') GROUP BY p.idProducto,l.idMomento;

ELSE
#Busqueda para el reporte que se envia o se imprime a cada proveedor.
SELECT p.nombre AS producto,sum(l.cantidad) AS cantidad,l.idMomento AS momento,CONCAT('$',FORMAT(SUM(l.precio),0)) AS valor,SUM(l.precio) AS subValor FROM pedido pd JOIN lineas_pedido l ON pd.idPedido=l.idPedido JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pr ON p.idProveedor=pr.idProveedor WHERE DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND pr.idProveedor=idP GROUP BY p.idProducto,l.idMomento;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ConsultarCorreosProveedor` ()  NO SQL
BEGIN


SELECT p.idProveedor,p.nombre,p.email FROM proveedor p WHERE p.email!='' AND p.email is NOT null;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ConsultarLineasDetalle` (IN `id` INT)  NO SQL
BEGIN

SELECT l.idLineas_pedido,p.idProducto,p.nombre,p.idProveedor,pd.nombre as proveedor,l.precio,CONCAT("$",FORMAT(l.precio, 0)) as total1,l.idMomento,l.cantidad FROM lineas_pedido l JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pd ON p.idProveedor=pd.idProveedor WHERE l.idPedido=id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ConsultarLineasDetallePorProveedor` (IN `idPro` INT, IN `idp` INT)  NO SQL
BEGIN

SELECT pr.nombre,CONCAT('$',FORMAT(l.precio,0)) AS precioV,l.cantidad,l.precio,CONCAT('$',FORMAT((SELECT SUM(lp.precio) FROM lineas_pedido lp JOIN producto pro on lp.idProducto=pro.idProducto WHERE lp.idPedido=idp AND pro.idProveedor=idPro),0)) AS total FROM empleado e JOIN pedido p ON e.documento=p.documento JOIN lineas_pedido l ON p.idPedido=l.idPedido JOIN producto pr ON l.idProducto=pr.idProducto WHERE pr.idProveedor=idPro AND p.idPedido=idp AND DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')='07-06-2018' ORDER BY p.idPedido ASC;
#(SELECT SUM(lp.precio) FROM lineas_pedido lp JOIN producto pro on lp.idProducto=pro.idProducto WHERE lp.idPedido=idp AND pr.idProveedor=idPro) AS total

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ConsultarNumeroPedidoPorProveedor` (IN `idP` INT)  NO SQL
BEGIN

SELECT DISTINCT(l.idPedido),e.nombre1,e.nombre2,e.apellido1,e.apellido2 FROM empleado e JOIN pedido p ON e.documento=p.documento JOIN lineas_pedido l ON p.idPedido=l.idPedido JOIN producto pr ON l.idProducto=pr.idProducto WHERE pr.idProveedor=idP AND DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')= '07-06-2018' ORDER BY p.idPedido ASC;
#DATE_FORMAT(now(),'%d-%m-%Y')

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ConsultarPedidos` (IN `doc` VARCHAR(20), IN `op` TINYINT)  NO SQL
BEGIN
#DECLARE per tinyint(1);
#Valida que el estado de los tiempos si sean los correctos.
#SET per= (SELECT SA_FU_ValidarRestriccionTiempo());
#
IF op=0 THEN
#consultar por documento.
SELECT p.idPedido,e.nombre1,e.nombre2,e.apellido1,e.apellido2,DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y  %r') as hora,CONCAT("$",FORMAT(p.total, 0)) as total1,p.total,p.estado FROM pedido p JOIN empleado e ON p.documento=e.documento WHERE p.fecha_pedido BETWEEN DATE_FORMAT(now(),'%Y-%m-%d') AND  DATE_FORMAT(ADDDATE(now(), INTERVAL 1 DAY),'%Y-%m-%d') AND e.documento=doc;
ELSE
#Consultar en general
SELECT p.documento,p.idPedido,e.nombre1,e.nombre2,e.apellido1,e.apellido2,TIME_FORMAT(p.fecha_pedido,'%h:%i %p') as hora,CONCAT("$",FORMAT(p.total, 0)) as total1,p.total FROM pedido p JOIN empleado e ON p.documento=e.documento WHERE DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')= DATE_FORMAT(now(),'%d-%m-%Y');

END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_EliminarLineaDePedido` (IN `idP` INT, IN `idL` INT)  NO SQL
BEGIN

DELETE FROM lineas_pedido WHERE idLineas_pedido=idL AND idPedido=idP;

SELECT 1 as respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_EliminarPedido` (IN `id` INT)  NO SQL
BEGIN

#Se elimina primero el detalle del pedido
DELETE FROM lineas_pedido where idPedido=id;

#Se elimina el pedido
DELETE FROM pedido WHERE idPedido=id;

SELECT true as respuesta;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_FechasReposteLiquidacionProveedorDia` (IN `fechaI` VARCHAR(13), IN `fechaF` VARCHAR(13))  NO SQL
BEGIN

SELECT DISTINCT(DATE_FORMAT(p.fecha_pedido,'%Y-%m-%d')) AS fechasP FROM pedido p WHERE p.fecha_pedido BETWEEN fechaI AND ADDDATE(fechaF, INTERVAL 1 DAY) AND p.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_Formato_Liquidacion_temporal` (IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN

SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2, CONCAT('$', FORMAT(SUM(p.total), 0)) AS liquidacion FROM empleado e JOIN pedido p ON e.documento = p.documento WHERE e.idEmpresa = 3 AND DATE_FORMAT(p.fecha_pedido, '%Y-%m-%d') BETWEEN fechaI AND fechaF GROUP BY e.documento;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_LiquidacionEmpleadoPorFechas` (IN `fechaI` VARCHAR(13), IN `fechaF` VARCHAR(13))  NO SQL
BEGIN

SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,em.nombre,FORMAT(SUM(p.total),0) as devengado,p.total FROM empleado e RIGHT JOIN pedido p ON e.documento=p.documento JOIN empresa em ON e.idEmpresa=em.idEmpresa WHERE p.fecha_pedido BETWEEN fechaI AND ADDDATE(fechaF, INTERVAL 1 DAY) GROUP BY e.documento ORDER BY p.idPedido;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_LiquidacionPedidoProveedorRangoFecha` (IN `idProveedor` INT, IN `fecha` VARCHAR(10))  NO SQL
BEGIN

SELECT DATE_FORMAT(pd.fecha_pedido,'%d/%m/%Y') AS fecha_pedido,p.nombre AS producto,sum(l.cantidad) AS cantidad,l.idMomento AS momento,CONCAT('$',FORMAT(SUM(l.precio),0)) AS valor, SUM(l.precio) AS subValor FROM pedido pd JOIN lineas_pedido l ON pd.idPedido=l.idPedido JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pr ON p.idProveedor=pr.idProveedor WHERE DATE_FORMAT(pd.fecha_pedido, '%Y-%m-%d') = fecha AND pr.idProveedor=idProveedor GROUP BY p.idProducto,l.idMomento;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_LiquidacionPedidosPorEmpeladoYFechas` (IN `doc` VARCHAR(20), IN `fechaI` VARCHAR(15), IN `fechaF` VARCHAR(15))  NO SQL
BEGIN

SELECT DATE_FORMAT(p.fecha_pedido,'%Y-%m-%d') AS fecha,DATE_FORMAT(p.fecha_pedido,'%r') AS hora,em.nombre,e.nombre1,e.nombre2,e.apellido1,e.apellido2,p.total AS valor FROM empresa em JOIN empleado e ON em.idEmpresa=e.idEmpresa JOIN pedido p ON e.documento=p.documento JOIN lineas_pedido lp ON p.idPedido=lp.idPedido JOIN producto pr ON lp.idProducto=pr.idProducto JOIN proveedor pro ON pr.idProveedor=pro.idProveedor WHERE p.fecha_pedido BETWEEN fechaI AND ADDDATE(fechaF, INTERVAL 1 DAY) AND e.documento=doc  GROUP BY p.idPedido ORDER BY p.fecha_pedido;
#DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y') AS fecha
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_LiquidacionProveedorEmpleadoRangoFecha` (IN `fecha1` VARCHAR(13), IN `fecha2` VARCHAR(13))  NO SQL
BEGIN

SELECT p.idPedido,DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y') AS solofecha,p.documento,em.nombre AS empresa,prv.nombre AS proveedor,CONCAT(UPPER(e.nombre1) ,' ',UPPER(e.nombre2),' ',UPPER(e.apellido1),' ',UPPER(e.apellido2))AS nombre,CONCAT("$",FORMAT(lp.precio, 0)) as total, lp.precio FROM proveedor prv JOIN producto pro ON prv.idProveedor=pro.idProveedor JOIN lineas_pedido lp ON pro.idProducto=lp.idProducto JOIN pedido p ON lp.idPedido=p.idPedido JOIN empleado e ON p.documento=e.documento JOIN empresa em ON em.idEmpresa=e.idEmpresa WHERE p.fecha_pedido BETWEEN fecha1 AND ADDDATE(fecha2, INTERVAL 1 DAY) ORDER BY p.idPedido;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ModificarPedido` (IN `total` INT, IN `idP` INT, IN `fecha` VARCHAR(25))  NO SQL
BEGIN

DECLARE dias tinyint(1);

IF fecha='' THEN
#el sistema pone la fecha
SET dias=(SELECT SA_FU_CantidadDiasASumar());

#Actualizar
UPDATE pedido p SET p.fecha_pedido=ADDDATE(now(),INTERVAL dias DAY), p.total=total WHERE p.idPedido=idP;
ELSE
#el administrador coloca la fecha.
UPDATE pedido p SET p.fecha_pedido=fecha, p.total=total WHERE p.idPedido=idP;
END IF;


SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ModificarRestriccion` (IN `hora1` VARCHAR(45), IN `hora2` VARCHAR(45), IN `hora3` VARCHAR(45), IN `hora4` VARCHAR(45))  NO SQL
BEGIN

UPDATE `restriccion` SET `hora_inicio_pedidos`=hora1,`hora_fin_pedidos`=hora2,`hora_inicio_siguiente_dia`=hora3,`hora_fin_siguiente_dia`=hora4 WHERE `idRestriccion`=1;

SELECT true as respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_RangoFechasLiquidacionProveedor` (IN `idProveedor` INT, IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN

SELECT DISTINCT(DATE_FORMAT(p.fecha_pedido, '%Y-%m-%d')) AS fecha, CONCAT('$',FORMAT(SUM(lp.precio), 0)) AS valor_fecha FROM pedido p JOIN lineas_pedido lp ON p.idPedido=lp.idPedido JOIN producto pro ON lp.idProducto=pro.idProducto JOIN proveedor pv ON pro.idProveedor=pv.idProveedor WHERE DATE_FORMAT(p.fecha_pedido, '%Y-%m-%d') BETWEEN fechaI AND DATE_ADD(fechaF, INTERVAL 1 DAY) AND pv.idProveedor=idProveedor GROUP BY DATE_FORMAT(p.fecha_pedido, '%Y-%m-%d');

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_RegistrarFechaEnvioCorreoPedidos` (IN `idP` INT)  NO SQL
BEGIN

INSERT INTO `envio_pedido`(`fecha_envio`, `idProveedor`) VALUES (now(),idP);

SELECT true AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_RegistrarModificarActividadesImportacion` (IN `ID` INT, IN `idA` INT, IN `accion` INT)  NO SQL
BEGIN
DECLARE idI int;
#...
IF EXISTS(SELECT * FROM actividades_timpo_libre a WHERE a.idPersonal=ID AND a.idActividades=idA) THEN
#Eliminar actividad
SET idI= (SELECT a.idActividades_timpo_libre FROM actividades_timpo_libre a WHERE a.idPersonal=ID AND a.idActividades=idA);
#...	
	IF accion=0 THEN
     DELETE FROM actividades_timpo_libre WHERE idActividades_timpo_libre=idI;
    END IF;
#...
ELSE
#registrar
  IF accion=1 THEN
   INSERT INTO actividades_timpo_libre(`idPersonal`, `idActividades`) VALUES(ID,idA);
  END IF;   
END IF;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_RegistrarModificarLineasDePedido` (IN `cantidad` VARCHAR(2), IN `idPe` INT, IN `idPro` INT, IN `idMo` INT, IN `precio` VARCHAR(8), IN `op` TINYINT, IN `idL` INT)  NO SQL
BEGIN

IF op=0 THEN
#resigtrar
INSERT INTO `lineas_pedido`(`cantidad`, `idPedido`, `idProducto`, `idMomento`, `precio`) VALUES (cantidad,idPe,idPro,idMo,precio);

(SELECT MAX(l.idLineas_pedido) as respuesta FROM lineas_pedido l);
ELSE
#modificar
UPDATE `lineas_pedido` SET `cantidad`=cantidad ,`idProducto`=idPro,`idMomento`=idMo,`precio`=precio WHERE `idLineas_pedido`=idL AND `idPedido`=idPe;

SELECT 1 AS respuesta;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_RegistrarModificarProveedor` (IN `idP` INT, IN `nombre` VARCHAR(45), IN `telefono` VARCHAR(11), IN `estado` TINYINT(1), IN `evento` TINYINT(1), IN `email` VARCHAR(60))  NO SQL
BEGIN
#Si el identificador del proveedor es igual a 0, la accion que se va a desencadenar es la de registrar proveedor.
IF idP=0 THEN

INSERT INTO `proveedor`(`nombre`, `telefono`, `estado`, `evento`, `email`) VALUES (nombre,telefono,estado,evento,email);

ELSE#Si no se va a realizar la de modificar proveedor.

UPDATE `proveedor` SET `nombre`=nombre,`telefono`=telefono,`evento`=evento,`email`=email WHERE `idProveedor`=idP;

END IF;

SELECT true AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_RegistrarPedido` (IN `doc` VARCHAR(20), IN `total` VARCHAR(8))  NO SQL
BEGIN

DECLARE dias tinyint(1);

SET dias=(SELECT SA_FU_CantidadDiasASumar());

#Registrar
INSERT INTO `pedido`(`documento`, `fecha_pedido`, `total`) VALUES (doc,ADDDATE(now(),INTERVAL dias DAY),total);

SELECT MAX(p.idPedido) AS respuesta FROM pedido p;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ReporteConsumoEmpleadoDia` (IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN
DECLARE res INT;
#consulta pendiente
IF fechaI!='' AND fechaF=0 THEN
#
SELECT  DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y') AS solofecha,DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y %h:%i %p') AS fecha,p.documento,em.nombre as empresa,p.idPedido,e.nombre1,e.nombre2,e.apellido1,e.apellido2,TIME_FORMAT(p.fecha_pedido,'%h:%i %p') as hora,CONCAT("$",FORMAT(p.total, 0)) as total1,p.total FROM pedido p LEFT JOIN empleado e ON p.documento=e.documento LEFT JOIN empresa em ON em.idEmpresa=e.idEmpresa WHERE  DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')=  DATE_FORMAT(fechaI,'%d-%m-%Y');
#
ELSE
  #SELECT (DATE_FORMAT(fechaF,'%Y-%m-%D') > DATE_FORMAT(fechaI,'%Y-%m-%d'));
  #SET subFI=(SELECT fechaI);
  #SET subFF=(SELECT fechaF);
  #SELECT subFI,subFF;
  SET res= (SELECT DATEDIFF(fechaF,fechaI));
  #SELECT res;
  #
  IF res>0 THEN
  SELECT DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y') AS solofecha,DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y %h:%i %p') AS fecha,p.documento,em.nombre AS empresa,p.idPedido,e.nombre1,e.nombre2,e.apellido1,e.apellido2,TIME_FORMAT(p.fecha_pedido,'%h:%i %p') as hora,CONCAT("$",FORMAT(p.total, 0)) as total1,p.total FROM pedido p JOIN empleado e ON p.documento=e.documento JOIN empresa em ON em.idEmpresa=e.idEmpresa WHERE p.fecha_pedido BETWEEN fechaI AND ADDDATE(fechaF, INTERVAL 1 DAY);
  #
  #SELECT 1;
  END IF;
END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ReporteConsumoProveedorDia` (IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN

IF fechaI != '' AND fechaF='' THEN
#Consultar unicamente por una fecha
SELECT DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y') as fecha,pr.nombre AS proveedor, CONCAT('$',FORMAT(SUM(l.precio),0))AS total, (SELECT CONCAT('$',FORMAT(sum(p.total),0)) FROM pedido p WHERE DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')=fechaI) AS totalP,SUM(l.cantidad) AS ProductosC FROM proveedor pr join producto p on pr.idProveedor=p.idProveedor JOIN lineas_pedido l ON p.idProducto=l.idProducto JOIN pedido pd ON l.idPedido=pd.idPedido WHERE DATE_FORMAT(pd.fecha_pedido,'%Y-%m-%d')=fechaI GROUP BY pr.idProveedor, (DATE_FORMAT(pd.fecha_pedido,'%Y-%m-%d'));

ELSE
#Consultar por rangos de fechas
SELECT DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y') as fecha,pr.nombre AS proveedor, CONCAT('$',FORMAT(SUM(l.precio),0))AS total, (SELECT CONCAT('$',FORMAT(sum(p.total),0)) FROM pedido p WHERE DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')BETWEEN fechaI AND fechaF) AS totalP, SUM(l.cantidad) AS ProductosC FROM proveedor pr join producto p on pr.idProveedor=p.idProveedor JOIN lineas_pedido l ON p.idProducto=l.idProducto JOIN pedido pd ON l.idPedido=pd.idPedido WHERE DATE_FORMAT(pd.fecha_pedido,'%Y-%m-%d') BETWEEN fechaI AND fechaF GROUP BY pr.idProveedor, (DATE_FORMAT(pd.fecha_pedido,'%Y-%m-%d'));

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ReporteLiquidacionProveedorDia` (IN `fechaL` VARCHAR(10))  NO SQL
BEGIN
#esta Pendiente por trabajar
SELECT DATE_FORMAT(p.fecha_pedido,'%r') AS hora,em.nombre,e.nombre1,e.nombre2,e.apellido1,e.apellido2,e.documento,CONCAT('$',FORMAT(p.total,0)) AS valor FROM empresa em JOIN empleado e ON em.idEmpresa=e.idEmpresa JOIN pedido p ON e.documento=p.documento JOIN lineas_pedido lp ON p.idPedido=lp.idPedido JOIN producto pr ON lp.idProducto=pr.idProducto JOIN proveedor pro ON pr.idProveedor=pro.idProveedor WHERE DATE_FORMAT(p.fecha_pedido,'%Y-%m-%d')=fechaL  GROUP BY p.idPedido;

#SELECT DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y') as fecha,pr.nombre AS proveedor, CONCAT('$',FORMAT(SUM(l.precio),0))AS total FROM proveedor pr join producto p on pr.idProveedor=p.idProveedor JOIN lineas_pedido l ON p.idProducto=l.idProducto JOIN pedido pd ON l.idPedido=pd.idPedido WHERE DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y')=fechaL GROUP BY pr.idProveedor;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ReportePedidosPorempleadoProveedor` (IN `idP` INT)  NO SQL
BEGIN

IF idP!=0 THEN
#-----Pedidos solo por proveedor----
SELECT em.documento,p.nombre AS producto,l.cantidad AS cantidad,l.idMomento AS momento, em.nombre1, em.nombre2,em.apellido1,em.apellido2 FROM empleado em join pedido pd on em.documento=pd.documento JOIN lineas_pedido l ON pd.idPedido=l.idPedido JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pr ON p.idProveedor=pr.idProveedor WHERE DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND pr.idProveedor=idP GROUP BY em.documento,l.idLineas_pedido;
#-----
ELSE
#-----Todos los pedidos en general----
SELECT p.nombre AS producto,l.cantidad AS cantidad,l.idMomento AS momento, em.nombre1, em.nombre2,em.apellido1,em.apellido2 FROM empleado em join pedido pd on em.documento=pd.documento JOIN lineas_pedido l ON pd.idPedido=l.idPedido JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pr ON p.idProveedor=pr.idProveedor WHERE DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') GROUP BY em.documento,l.idLineas_pedido;
#-----
END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarEnvioPedidosDiario` (IN `idP` INT)  NO SQL
BEGIN

IF EXISTS(SELECT * FROM envio_pedido en WHERE en.idProveedor=idP AND DATE_FORMAT(en.fecha_envio,'%d-%m-%Y')= DATE_FORMAT(now(),'%d-%m-%Y')) THEN
#cuando existe el envio del pedido al proveedor del dia presente.

SELECT false AS respuesta;

ELSE
#Cuano no existe el envio del correo al proveedor el dia presente.

SELECT true AS respuesta;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarPedidoPorDia` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

DECLARE dias tinyint(1);

SET dias=(SELECT SA_FU_CantidadDiasASumar());

IF EXISTS(SELECT * FROM pedido p WHERE p.documento= doc AND DATE_FORMAT(p.fecha_pedido,'%d-%m-%Y')= DATE_FORMAT(ADDDATE(now(),INTERVAL dias DAY),'%d-%m-%Y')) THEN

  SELECT false as respuesta;

ELSE

  SELECT true as respuesta;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarRestriccionTiempos` ()  NO SQL
BEGIN
#horas de restriccion para el pedido de hoy.
DECLARE horaI time;
DECLARE horaF time;
#horas para hacer el pedido para el dia siguiente.
DECLARE horaIS time;
DECLARE horaFS time;
#hora del sistema.
DECLARE horaA time;

#Hora de inicio de pedidos hoy
SET horaI=(SELECT r.hora_inicio_pedidos FROM restriccion r WHERE r.idRestriccion=1);
#Hora de fin de pedidos hoy
SET horaF=(SELECT r.hora_fin_pedidos FROM restriccion r WHERE r.idRestriccion=1);
#Hora de inicio de pedidos mañana
SET horaIS=(SELECT r.hora_inicio_siguiente_dia FROM restriccion r WHERE r.idRestriccion=1);
#Hora de fin de pedidos mañana
SET horaFS=(SELECT r.hora_fin_siguiente_dia FROM restriccion r WHERE r.idRestriccion=1);

#hora actual del pedido
SET horaA=(SELECT now());
#SELECT horaI, horaA, horaF;
#validacion

IF ((horaA>=horaI AND horaA<=horaF) OR (horaA>=horaIS AND horaA<=horaFS)) THEN
#se puede gestionar el pedido
SELECT true as respuesta;

ELSE
#No se puede gestionar los pedidos
SELECT false as respuesta;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarTiempoDeActualizacion` (IN `idP` INT)  NO SQL
BEGIN
#Se encarga de consultar la diferencia de dias para saber si se puede modificar o no.
(SELECT DATEDIFF(now(),p.fecha_pedido) AS respuesta FROM pedido p WHERE p.idPedido=idP);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarTiemposRestriccion` (IN `hora1` VARCHAR(45), IN `hora2` VARCHAR(45), IN `hora3` VARCHAR(45), IN `hora4` VARCHAR(45))  NO SQL
BEGIN

IF (SELECT hora2 > hora1) AND (SELECT hora4 > hora3) THEN
 SELECT 1 AS respuesta;
ELSE
 SELECT 0 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarUsuario` (IN `doc` VARCHAR(13), IN `con` VARCHAR(50))  NO SQL
BEGIN

select EXISTS(select * from empleado e WHERE e.documento=doc AND e.contraseña COLLATE utf8_bin=con AND e.estado=1) AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SA_PA_ValidarUsuarioPedido` (IN `doc` VARCHAR(20), IN `con` VARCHAR(10), IN `idP` INT)  NO SQL
BEGIN

select EXISTS(select * from empleado e JOIN pedido p ON e.documento=p.documento WHERE e.documento=doc AND e.contraseña COLLATE utf8_bin=con AND p.idPedido=idP AND e.estado=1) AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_CambiarEstadoUsuario` (IN `id` INT)  NO SQL
BEGIN
DECLARE estado tinyint(1);

IF EXISTS(SELECT * FROM usuario u WHERE u.idUsuario=id AND u.estado=1) THEN

SET estado=0;

ELSE

SET estado=1;

END IF;

UPDATE usuario u SET u.estado=estado WHERE u.idUsuario=id;

SELECT true AS respuesta;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ActualizarConfiguracion` (IN `HIL` VARCHAR(8), IN `HFL` VARCHAR(8), IN `HID` VARCHAR(8), IN `HFD` VARCHAR(8), IN `HIA` VARCHAR(8), IN `HFA` VARCHAR(8), IN `TD` VARCHAR(8), IN `TA` VARCHAR(8), IN `id` TINYINT(1), IN `nombre` VARCHAR(60))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion=id) THEN
#Ya existe la configuracion del horario de trabajo
UPDATE `configuracion` SET `hora_ingreso_empresa`=HIL,`hora_salida_empresa`=HFL,`hora_inicio_desayuno`=HID,`hora_fin_desayuno`=HFD,`hora_inicio_almuerzo`=HIA,`hora_fin_almuerzo`=HFA,`tiempo_desayuno`=TD,`tiempo_almuerzo`=TA, `nombre`=nombre WHERE `idConfiguracion`=id;
ELSE
#No existe el horario
INSERT INTO `configuracion`(`nombre`, `hora_ingreso_empresa`, `hora_salida_empresa`, `hora_inicio_desayuno`, `hora_fin_desayuno`, `hora_inicio_almuerzo`, `hora_fin_almuerzo`, `tiempo_desayuno`, `tiempo_almuerzo`, `estado`) VALUES (nombre,HIL,HFL,HID,HFD,HIA,HFA,TD,TA,1);
END IF;

SELECT true AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_AsistenciaPorEmpleado` (IN `doc` VARCHAR(20), IN `op` INT, IN `fecha` VARCHAR(13))  NO SQL
BEGIN

IF op=0 THEN
	#consutar evento laboral
	SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.inicio AS inicioOriginal,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.hora_fin,'%r') AS hora_fin,a.hora_fin AS finOriginal,a.idEstado_asistencia,a.estado,a.lectorI,a.lectorF,a.idConfiguracion FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE now()>DATE_FORMAT(a.inicio,'%d-%m-%Y') AND e.documento=doc AND a.idTipo_evento=1 AND e.idRol=1 AND a.estado=0;
ELSE
 	IF op=1 THEN
 		#consultar los eventos diferentes al laboral
		SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,a.hora_fin AS finOriginal,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.hora_inicio,'%r') AS hora_inicio,a.hora_inicio AS inicioOriginal,a.idEstado_asistencia,a.estado, a.tiempo AS horas,a.lectorI,a.lectorF,a.idConfiguracion FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE fecha=DATE_FORMAT(a.inicio,'%d-%m-%Y') AND e.documento=doc AND e.idRol=1;
 	ELSE
		#consultar los eventos de el dia de hoy
		SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,a.hora_fin AS finOriginal,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.hora_inicio,'%r') AS hora_inicio,a.hora_inicio AS inicioOriginal,a.idEstado_asistencia,a.estado,a.tiempo AS horas,a.lectorI,a.lectorF,a.idConfiguracion FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE DATE_FORMAT(now(),'%d-%m-%Y')=DATE_FORMAT(a.inicio,'%d-%m-%Y') AND e.documento=doc AND e.idRol=1;
 	END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_AsistenciaPorFechas` (IN `fecha1` VARCHAR(13), IN `fecha2` VARCHAR(13), IN `doc` VARCHAR(20))  NO SQL
BEGIN

IF doc='' THEN
#Consultar solo por rango de fechas ADDDATE(fecha2,INTERVAL 1 DAY)
	IF fecha1!='' AND fecha2!='' THEN
    #
    SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE (DATE_FORMAT(a.inicio, '%Y-%m-%d')  BETWEEN fecha1 AND fecha2) AND e.idRol=1 AND a.idTipo_evento=1 AND (a.estado=0 OR a.fin IS null);
    #
    #SELECT 1;
  ELSE
      IF fecha1!='' AND fecha2='' THEN
      #
          SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE DATE_FORMAT(a.inicio, '%Y-%m-%d') =fecha1 AND e.idRol=1 AND a.idTipo_evento=1 AND (a.estado=0 OR a.fin IS null);
          #
          #SELECT 2;
      ELSE
        IF fecha2!='' AND fecha1='' THEN
        #
          SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE DATE_FORMAT(a.inicio, '%Y-%m-%d') =fecha2 AND e.idRol=1 AND a.idTipo_evento=1 AND (a.estado=0 OR a.fin IS null);
        #
        #SELECT 3;
        END IF;
      END IF;
  END IF;
ELSE
#Consultar por rango de fechas y documento
IF fecha1!='' AND fecha2!='' THEN

#
SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE (DATE_FORMAT(a.inicio, '%Y-%m-%d')  BETWEEN fecha1 AND ADDDATE(fecha2,INTERVAL 1 DAY)) AND e.idRol=1 AND a.idTipo_evento=1 AND a.estado=0 AND a.documento=doc;
#
#SELECT 1;
ELSE
  IF fecha1!='' AND fecha2='' THEN
  #
  SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE DATE_FORMAT(a.inicio, '%Y-%m-%d') =fecha1 AND e.idRol=1 AND a.idTipo_evento=1 AND a.estado=0 AND a.documento=doc;
  #
  #SELECT 2;
  ELSE
    IF fecha2!='' AND fecha1='' THEN
    #
      SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE DATE_FORMAT(a.inicio, '%Y-%m-%d') =fecha2 AND e.idRol=1 AND a.idTipo_evento=1 AND a.estado=0 AND a.documento=doc;
    #
   #SELECT 3;
    END IF;
  END IF;
END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_AsistenciasDiarias` (IN `piso` INT)  NO SQL
BEGIN

IF piso=0 THEN
    #Consulta general
    #SELECT e.documento, LOWER(e.nombre1) AS nombre1,LOWER(e.nombre2) AS nombre2,LOWER(e.apellido1) AS apellido1,LOWER(e.apellido2) AS apellido2,e.asistencia,e.piso FROM empleado e WHERE e.idRol=1 AND e.estado=1;
    SELECT e.documento, LOWER(e.nombre1) AS nombre1,LOWER(e.nombre2) AS nombre2,LOWER(e.apellido1) AS apellido1,LOWER(e.apellido2) AS apellido2,e.asistencia,e.piso, (SELECT a1.inicio FROM asistencia a1 WHERE a1.idAsistencia= (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=e.documento AND a.idTipo_evento=1 AND a.inicio=CURDATE() LIMIT 1)) AS horaLlegada, (SELECT a1.fin FROM asistencia a1 WHERE a1.idAsistencia= (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=e.documento AND a.idTipo_evento=1 AND a.inicio=CURDATE() LIMIT 1)) AS horaSalida FROM empleado e WHERE e.idRol=1 AND e.estado=1;
ELSE
    #Consulta por piso
    SELECT e.documento, LOWER(e.nombre1) AS nombre1,LOWER(e.nombre2) AS nombre2,LOWER(e.apellido1) AS apellido1,LOWER(e.apellido2) AS apellido2,e.asistencia,e.piso, (SELECT a1.inicio FROM asistencia a1 WHERE a1.idAsistencia= (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=e.documento AND a.idTipo_evento=1 AND a.inicio=CURDATE() LIMIT 1)) AS horaLlegada FROM empleado e WHERE e.idRol=1 AND e.estado=1 AND e.piso=piso;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEmpresaEmpleado` (IN `idFicha` INT, IN `idEm` INT)  NO SQL
BEGIN

UPDATE empleado e SET e.idEmpresa=idEm WHERE e.documento= (SELECT f.documento FROM ficha_sd f WHERE f.idFicha_SD=idFicha LIMIT 1);

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_cambiarEstadoAuxilios` (IN `idSal` INT, IN `idAux` INT)  NO SQL
BEGIN
DECLARE idA int;
SET idA=(SELECT MAX(sub.idAuxilio) FROM auxilio sub WHERE sub.idTipo_auxilio=idAux AND sub.idSalarial=idSal);
# se encarga de cambiar el estado de los auxilios que el empleado se le esta brindando por parte de la empresa.
UPDATE auxilio a SET a.estado=0 WHERE a.idSalarial=idSal AND a.idTipo_auxilio=idAux AND a.idAuxilio=idA;
#...
SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEstadoConfiguracionHorarioEmpleado` (IN `id` INT)  NO SQL
BEGIN

IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion=id AND c.estado=1) THEN
#Cambiar estado inactivo
UPDATE configuracion c SET c.estado=0 WHERE c.idConfiguracion=id;
ELSE
#cambiar estado activo
UPDATE configuracion c SET c.estado=1 WHERE c.idConfiguracion=id;
END IF;

SELECT true as respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEstadoDeAsistenciaOperarioInicial` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

UPDATE empleado e SET e.asistencia=0 WHERE e.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEstadoDiaFestivo` (IN `idD` INT)  NO SQL
BEGIN
#No se puede desactivar los estados de los días festivos que ya cumplieron la fecha.
IF EXISTS(SELECT * FROM dias_festivos d WHERE d.fecha_dia>CURDATE()) THEN
IF EXISTS(SELECT * FROM dias_festivos d WHERE d.estado=1 AND d.iddias_festivos=idD) THEN
#Cambiar el estado a desactivado o liminar.
	UPDATE dias_festivos d SET d.estado=0 WHERE d.iddias_festivos=idD;
ELSE
#CambiarEl estado a activo.
	UPDATE dias_festivos d SET d.estado=1 WHERE d.iddias_festivos=idD;
END IF;

SELECT 1 as respuesta;
ELSE
#No se puede modificar el estado por que ya caduco esa fecha.
SELECT 2 as respuesta;
END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEstadoEmpleado` (IN `idFicha` INT, IN `estado` TINYINT(1))  NO SQL
BEGIN

UPDATE empleado e SET e.estado=estado WHERE e.documento=(SELECT f.documento FROM ficha_sd f WHERE f.idFicha_SD=idFicha);

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEstadoHorarioEmpleado` (IN `id` INT, IN `documento` VARCHAR(20))  NO SQL
BEGIN
DECLARE estado tinyint(1);
#...
IF EXISTS(SELECT * FROM empleado_horario e WHERE e.idEmpleado_horario=id AND e.documento=documento) THEN
#Empleado
	IF EXISTS(SELECT * FROM empleado_horario e WHERE e.idEmpleado_horario=id AND e.documento=documento AND e.estado=1) THEN
    #Cambiar estado a inactivo
    	SET estado=0;
    ELSE
    #Cambiar estado a activo
    	SET estado=1;
    END IF;
    #...
    UPDATE empleado_horario e SET e.estado= estado WHERE e.documento=documento AND e.idEmpleado_horario=id;
    #...
    SELECT 1 as respuesta; 
#//
ELSE
SELECT 0 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CambiarEstadoNotificaciones` (IN `id` INT)  NO SQL
BEGIN

UPDATE notificacion n SET n.leido=1 WHERE n.idUsuario=id;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CantidadDePedidosDiarios` (IN `doc` VARCHAR(20))  NO SQL
BEGIN
#----
SELECT COUNT(l.idLineas_pedido) AS rowsConect FROM empleado em join pedido pd on em.documento=pd.documento JOIN lineas_pedido l ON pd.idPedido=l.idPedido JOIN producto p on l.idProducto=p.idProducto JOIN proveedor pr ON p.idProveedor=pr.idProveedor WHERE DATE_FORMAT(pd.fecha_pedido,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND em.documento=doc;
#----
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CantidadNotificacionesNuevas` (IN `rol` INT)  NO SQL
BEGIN

SELECT COUNT(*) AS respuesta FROM notificacion n WHERE n.idUsuario= rol AND n.leido=0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_CantidadUsoLector` (IN `doc` VARCHAR(20), IN `evento` TINYINT(1), IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN

#SELECT a.lectorI,COUNT(a.lectorI) AS cantidadI, a.lectorF,COUNT(a.lectorF) as cantidadF FROM asistencia a WHERE a.lectorI is not null AND a.lectorF is not null AND a.documento='1216727816' GROUP BY a.lectorI,a.lectorF

IF fechaI!='' AND fechaF!='' THEN#Consulta uso de lectores por rango de fechas
 IF evento=1 THEN#Inicio de toma de tiempo asistencia
  #...
  SELECT a.lectorI AS lector,COUNT(a.lectorI) AS cantidad FROM asistencia a WHERE a.lectorI is not null AND a.lectorF is not null AND a.documento=doc AND (a.fecha_inicio BETWEEN fechaI AND fechaF) AND a.lectorI!=0 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)) GROUP BY a.lectorI ORDER BY COUNT(a.lectorI) DESC;
  #...
 ELSE#Fin de toma de tiempo de asistencia
  #...
  SELECT a.lectorF AS lector,COUNT(a.lectorF) AS cantidad FROM asistencia a WHERE a.lectorI is not null AND a.lectorF is not null AND a.documento=doc AND (a.fecha_inicio BETWEEN fechaI AND fechaF) AND a.lectorF!=0 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)) GROUP BY a.lectorF ORDER BY COUNT(a.lectorF) DESC;
  #...
 END IF;
ELSE#Consulta uso de lectores por una fecha en especifico.
 IF evento=1 THEN#Inicio de toma de tiempo asistencia
  #...
  SELECT a.lectorI AS lector,COUNT(a.lectorI) AS cantidad FROM asistencia a WHERE a.lectorI is not null AND a.lectorF is not null AND a.documento=doc AND a.fecha_inicio=fechaI AND a.lectorI!=0 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)) GROUP BY a.lectorI ORDER BY COUNT(a.lectorI) DESC;
  #...
 ELSE#Fin de toma de tiempo de asistencia
  #...
  SELECT a.lectorF AS lector,COUNT(a.lectorF) AS cantidad FROM asistencia a WHERE a.lectorI is not null AND a.lectorF is not null AND a.documento=doc AND a.fecha_inicio=fechaI AND a.lectorF!=0 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)) GROUP BY a.lectorF ORDER BY COUNT(a.lectorF) DESC;
  #...
 END IF;
END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarActividadesInfoPersonal` (IN `idPer` INT)  NO SQL
BEGIN

SELECT a.idActividades_timpo_libre,a.idActividades,ac.nombre FROM actividades_timpo_libre a JOIN actividad ac ON a.idActividades=ac.idActividad WHERE a.idPersonal=idPer;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarActividadesTiempoLibre` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM actividad;
ELSE
#
  SELECT * FROM actividad WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarAFP` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM afp;
ELSE
#
  SELECT * FROM afp WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarAreasLaborales` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM area_trabajo;
ELSE
#
  SELECT * FROM area_trabajo WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarAsistenciasDesayunoOAlmuerzo` (IN `doc` INT(13), IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10), IN `evento` TINYINT(1))  NO SQL
BEGIN

IF fechaI!='' AND fechaF!='' THEN
#Rango de fecha
SELECT a.tiempo as numero_horas FROM asistencia a WHERE a.documento=doc AND (a.fecha_inicio BETWEEN fechaI AND fechaF) AND a.idTipo_evento=evento AND a.fecha_fin is NOT null AND a.fecha_inicio!=CURDATE(); 
ELSE
 IF fechaI!='' AND fechaF='' THEN
 #Por una fecha
 SELECT a.tiempo as numero_horas FROM asistencia a WHERE a.documento=doc AND a.fecha_inicio=fechaI AND a.idTipo_evento=evento AND a.fecha_fin is NOT null AND a.fecha_inicio!=CURDATE();
 END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarCantidadEventos` (IN `doc` VARCHAR(20), IN `fecha1` VARCHAR(10), IN `fecha2` VARCHAR(10), IN `evento` TINYINT(1))  NO SQL
BEGIN
#variables
DECLARE aTiempo int;
DECLARE tarde int;
DECLARE noAsistio int;

#Cantidad de llegadas a tiempo y temprano del evento laboral por rango de fechas y empleado.
IF fecha1!='' AND fecha2!='' THEN
#Consulta por rango de fechas
#Llegadas a tiempo...
set aTiempo=(SELECT COUNT(*) AS cantidadA FROM asistencia a WHERE a.documento=doc AND (a.fecha_inicio BETWEEN fecha1 AND fecha2) AND a.idTipo_evento=evento AND a.estado=0 AND a.idEstado_asistencia=1 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)));
#llegadas tardes...
set tarde=(SELECT COUNT(*) AS cantidadT FROM asistencia a WHERE a.documento=doc AND (a.fecha_inicio BETWEEN fecha1 AND fecha2) AND a.idTipo_evento=evento AND a.estado=0 AND a.idEstado_asistencia=2 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)));
#No asistio al evento...
set noAsistio=(SELECT COUNT(*) AS cantidadN FROM asistencia a WHERE a.documento=doc AND (a.fecha_inicio BETWEEN fecha1 AND fecha2) AND a.idTipo_evento=evento AND a.estado=0 AND a.idEstado_asistencia=3 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)));
ELSE
#consultar por una fecha
 IF fecha1!='' and fecha2='' THEN
 #Llegadas a tiempo...
set aTiempo=(SELECT COUNT(*) AS cantidadA FROM asistencia a WHERE a.documento=doc AND a.fecha_inicio=fecha1 AND a.idTipo_evento=evento AND a.estado=0 AND a.idEstado_asistencia=1 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)));
#llegadas tardes...
set tarde=(SELECT COUNT(*) AS cantidadT FROM asistencia a WHERE a.documento=doc AND a.fecha_inicio=fecha1 AND a.idTipo_evento=evento AND a.estado=0 AND a.idEstado_asistencia=2 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)));
#No asistio al evento...
set noAsistio=(SELECT COUNT(*) AS cantidadN FROM asistencia a WHERE a.documento=doc AND a.fecha_inicio=fecha1 AND a.idTipo_evento=evento AND a.estado=0 AND a.idEstado_asistencia=3 AND (EXISTS(SELECT * FROM asistencia asis WHERE asis.fecha_inicio=a.fecha_inicio AND asis.fecha_fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1)));
 END IF;
END IF;

SELECT aTiempo,tarde,noAsistio,evento;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarCargo` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM cargo;
ELSE
#
  SELECT * FROM cargo WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarClasificacionContable` (IN `op` INT)  NO SQL
BEGIN
#Se encarga de consultar todos las clasificaciones contables
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#Consulta general
SELECT * FROM clasificacion_contable;

ELSE
#Consulta por estado =1
SELECT * FROM clasificacion_contable cc WHERE cc.estado=1;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarClasificacionMega` (IN `op` TINYINT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
SELECT * FROM clasificacion_mega;
ELSE
#
SELECT * FROM clasificacion_mega WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarConceptosPermiso` ()  NO SQL
BEGIN
#Consulta todos los conceptos que puede tener un permiso
SELECT * FROM concepto c WHERE c.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarConfiguracion` (IN `id` INT)  NO SQL
BEGIN

IF id=0 THEN
#General
SELECT c.idConfiguracion, c.nombre, c.estado FROM configuracion c;
ELSE
 IF id>0 THEN
  #Especifico
  SELECT * FROM configuracion c WHERE c.idConfiguracion=id;
 ELSE
  #General activos
  SELECT c.idConfiguracion, c.nombre, c.estado FROM configuracion c WHERE c.estado=1;
 END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarDetalleNotificacion` (IN `fecha` VARCHAR(15), IN `tipo` INT)  NO SQL
BEGIN

IF tipo=1 THEN#Cumpleaños

SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,e.genero,em.nombre AS empresa,e.idRol,TIMESTAMPDIFF(YEAR,sb.fecha_nacimiento,fecha) AS edad FROM secundaria_basica sb JOIN ficha_sd fs ON sb.idSecundaria_basica=fs.idSecundaria_basica JOIN empleado e ON fs.documento=e.documento JOIN empresa em ON e.idEmpresa=em.idEmpresa WHERE DATE_FORMAT(sb.fecha_nacimiento,'%d-%m')=DATE_FORMAT(fecha,'%d-%m') AND e.estado=1;

ELSE
  IF tipo=2 THEN#Aniversario
  #Esta notificcion puede estas fija a cambios
  SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,e.genero,em.nombre AS empresa,e.idRol,e.piso FROM empleado e JOIN empresa em ON e.idEmpresa=em.idEmpresa WHERE DATE_FORMAT(e.fecha_registro,'%d-%m')=DATE_FORMAT(fecha,'%d-%m') AND DATE_FORMAT(fecha,'%Y')>DATE_FORMAT(e.fecha_registro,'%Y') AND e.estado=1;
  
  ELSE
    IF tipo=3 THEN#Contrato
    #Consulta los contratos proximos a vencer
     SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,e.genero,em.nombre AS empresa,e.idRol,e.piso FROM laboral l JOIN ficha_sd fs ON l.idLaboral=fs.idLaboral JOIN empleado e ON fs.documento=e.documento JOIN empresa em ON e.idEmpresa=em.idEmpresa WHERE DATEDIFF(fecha,l.fecha_vencimiento_contrato)=45 AND l.idTipo_contrato=1 AND e.estado=1;
    
    ELSE
      IF tipo=4 THEN#llegadas tarde
      #consulta los empleados que llegaron tarde al evento laboral.
       SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,em.nombre AS empresa, a.idEstado_asistencia AS estado, TIME_FORMAT(a.inicio,'%r') AS hora_inicio, TIMEDIFF(a.inicio,(SELECT c.hora_ingreso_empresa FROM configuracion c WHERE c.idConfiguracion=a.idConfiguracion LIMIT 1)) as tiempoLlegadaTarde,e.piso,(SELECT c.nombre FROM configuracion c WHERE c.idConfiguracion=a.idConfiguracion LIMIT 1) AS asistencianame FROM empresa em join empleado e ON em.idEmpresa=e.idEmpresa JOIN asistencia a ON e.documento=a.documento WHERE a.idEstado_asistencia=2 AND DATE_FORMAT(a.inicio,'%Y-%m-%s') = fecha AND a.idTipo_evento=1 AND e.estado=1;
       ELSE
        IF tipo=5 THEN#Nuevos empleados
         SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,e.genero,em.nombre AS empresa,e.idRol,e.piso FROM empleado e JOIN empresa em ON e.idEmpresa=em.idEmpresa WHERE e.fecha_registro=fecha AND e.estado=1;
        END IF;
      END IF;
    END IF;
  END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarDiagnosticos` (IN `estado` TINYINT(1))  NO SQL
BEGIN

IF estado=0 THEN
#Consulta todos los Diagnosticos siendo indiferente con el estado que poseé el registro.
SELECT * FROM diagnostico;
ELSE
#Consulta todos lo Diagnostico que tenga un estado activo(1)
SELECT * FROM diagnostico d WHERE d.estado=estado;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarDiasFestivos` (IN `id` INT)  NO SQL
BEGIN

IF id=0 THEN
#Consultar en general
SELECT d.iddias_festivos,d.nombre,DATE_FORMAT(d.fecha_dia,'%d-%m-%Y') AS fecha_dia,d.estado,(CURDATE()>d.fecha_dia) AS acciones FROM dias_festivos d;
ELSE
#Consultar por un id
SELECT d.iddias_festivos,d.nombre,DATE_FORMAT(d.fecha_dia,'%d-%m-%Y') AS fecha_dia,d.estado FROM dias_festivos d WHERE d.iddias_festivos=id;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEmpelados` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

IF doc='-1' THEN

#Consultar Empleados que tengan ficha SDG

SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2,s.salario_basico FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN salarial s ON f.idSalarial=s.idSalarial ORDER BY e.apellido1 ASC;

ELSE

#otros....
IF doc='-2' THEN
#Consulta los empleados que tiene un rol de ususario de producción=1
 SELECT e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2 FROM empleado e WHERE e.idRol=1;
 
ELSE

IF doc='' THEN

#Consulta general

SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2,e.genero,e.estado,e.idRol,e.piso,e.contraseña AS contra, EXISTS(SELECT * FROM ficha_sd f WHERE f.documento=e.documento) AS FichaSDG, e.correo,em.nombre,e.asistencia FROM empleado e JOIN empresa em ON e.idEmpresa=em.idEmpresa ORDER BY e.apellido1 ASC;

ELSE

#Consulta por empleado

SELECT e.documento,LOWER(e.nombre1) as nombre1,LOWER(e.nombre2) as nombre2,LOWER(e.apellido1) as apellido1,LOWER(e.apellido2) as apellido2,e.genero,e.genero,e.huella1,e.huella2,e.huella3,e.correo,e.contraseña,em.nombre,e.estado,e.idRol,e.asistencia,e.piso,e.fecha_expedicion,e.lugar_expedicion,f.idFicha_SD,e.idEmpresa,e.idManufactura FROM empresa em JOIN empleado e ON em.idEmpresa=e.idEmpresa LEFT JOIN ficha_sd f ON e.documento=f.documento WHERE e.documento=doc;

END IF;

END IF;

END IF;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEmpleadosPermiso` ()  NO SQL
BEGIN

SELECT e.documento,e.nombre1,e.nombre2,e.apellido1, e.apellido2,e.genero,e.estado,e.idRol,(EXISTS(SELECT * FROM codigo_permiso c WHERE DATE_FORMAT(c.fecha,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND c.documento=e.documento)) AS permiso FROM empleado e WHERE e.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEmpresas` (IN `op` TINYINT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
SELECT * FROM empresa;
ELSE
#
SELECT * FROM empresa WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEPS` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM eps;
ELSE
#
  SELECT * FROM eps WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEstadoCivil` (IN `op` TINYINT(1))  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM estado_civil;
ELSE
#
  SELECT * FROM estado_civil WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEstadoEmpresariales` (IN `doc` VARCHAR(20))  NO SQL
BEGIN
DECLARE idF int;

SET idF=(SELECT f.idFicha_SD FROM ficha_sd f WHERE f.documento=doc LIMIT 1);

SELECT es.idEstado_empresarial,es.idFicha_SD,es.estado_e,DATE_FORMAT(es.fecha_retiro,'%d-%m-%Y') AS fecha_retiro,DATE_FORMAT(es.fecha_ingreso,'%d-%m-%Y') AS fecha_ingreso,es.idMotivo,(SELECT m.nombre FROM motivo m WHERE m.idMotivo=es.idMotivo) AS motivo ,es.idIndicador_rotacion,es.observacion_retiro,es.idEmpresa,ep.nombre,SE_FU_TiempoDeAntiguedadEmpleado(es.fecha_ingreso,IF(es.fecha_retiro='0000:00:00','',es.fecha_retiro)) AS antiguedad,es.impacto,DATE_FORMAT(es.fecha_ingreso,"%d") AS dia,DATE_FORMAT(es.fecha_ingreso,"%m") AS mes,DATE_FORMAT(es.fecha_ingreso,"%Y") AS año FROM estado_empresarial es LEFT JOIN empresa ep ON es.idEmpresa=ep.idEmpresa WHERE es.idFicha_SD=idF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarEventosDA` (IN `doc` VARCHAR(20), IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10), IN `evento` TINYINT(1))  NO SQL
BEGIN
#...
IF fechaI!='' AND fechaF!='' THEN
#Consultar po rango de fechas
 #consultar los eventos diferentes al laboral
SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS hora_fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado, a.tiempo AS horas,a.lectorI,a.lectorF FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE (a.inicio BETWEEN fechaI AND fechaF) AND e.documento=doc AND a.idTipo_evento=evento AND a.estado=0 AND e.idRol=1 AND (EXISTS(SELECT * FROM asistencia asis WHERE DATE_FORMAT(asis.inicio,'%Y-%m-%d')=DATE_FORMAT(a.inicio,'%Y-%m-%d') AND asis.fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1));
ELSE
#consultar por fecha 
 #consultar los eventos diferentes al laboral
SELECT a.idAsistencia,a.documento,e.nombre1,e.nombre2,e.apellido1,a.idTipo_evento,DATE_FORMAT(a.inicio,'%d-%m-%Y') AS fecha_inicio,TIME_FORMAT(a.fin,'%r') AS fin,DATE_FORMAT(a.fin,'%d-%m-%Y') AS fecha_fin,TIME_FORMAT(a.inicio,'%r') AS hora_inicio,a.idEstado_asistencia,a.estado, a.tiempo AS horas,a.lectorI,a.lectorF FROM asistencia a LEFT JOIN empleado e ON a.documento=e.documento WHERE a.inicio=fechaI AND e.documento=doc AND a.idTipo_evento=evento AND a.estado=0 AND e.idRol=1 AND (EXISTS(SELECT * FROM asistencia asis WHERE DATE_FORMAT(asis.inicio,'%Y-%m-%d') = DATE_FORMAT(a.inicio,'%Y-%m-%d') AND asis.fin is NOT null AND asis.estado=0 AND asis.idTipo_evento=1));
END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarExamenesMedicos` (IN `idE` INT)  NO SQL
BEGIN
#Queda pendiente buscar los examenes por rango de fecha

IF idE>0 THEN
#Consultar el examen por el ID
SELECT e.idexamenes_Medicos,e.documento,em.nombre1,em.nombre2,em.apellido1,em.apellido2,DATE_FORMAT(e.fechaCarta,'%d-%m-%Y') AS fechacarta,DATE_FORMAT(e.fechaPlazo,'%d-%m-%Y') AS fechaPlazo ,e.tipoExamenes,e.otroExamen,DATE_FORMAT(e.fechaRetorno,'%d-%m-%Y') AS fechaRetorno,e.motivo FROM examenes_medicos e JOIN empleado em ON e.documento=em.documento WHERE e.idexamenes_Medicos=idE;

ELSE
#Consultar examenes en general
SELECT e.idexamenes_Medicos,e.documento,em.nombre1,em.nombre2,em.apellido1,em.apellido2,DATE_FORMAT(e.fechaCarta,'%d-%m-%Y') as fechaCarta ,DATE_FORMAT(e.fechaPlazo,'%d-%m-%Y') as fechaPlazo,e.tipoExamenes,e.otroExamen,DATE_FORMAT(e.fechaRetorno,'%d-%m-%Y') as fechaRetorno ,e.motivo FROM examenes_medicos e JOIN empleado em ON e.documento=em.documento;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarGradoEscolaridad` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM grado_escolaridad;
ELSE
#
  SELECT * FROM grado_escolaridad WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarHorarioEmpleado` (IN `doc` VARCHAR(13), IN `id` INT)  NO SQL
BEGIN
#selecciona todos los horarios que tiene vinculado el empleado
IF id=0 THEN
#Consulta general de Horarios de empleado
SELECT e.idEmpleado_horario,c.nombre,e.diaInicio,e.diaFin,DATE_FORMAT(e.fechaInicio,'%d-%m-%Y') as fechaInicio,DATE_FORMAT(e.fechaFin,'%d-%m-%Y') AS fechaFin,e.estado FROM empleado_horario e JOIN configuracion c on e.idConfiguracion=c.idConfiguracion WHERE e.documento=doc;
ELSE
#Consulta especifica de un horario de un empelado
SELECT e.idConfiguracion,e.diaInicio,e.diaFin FROM empleado_horario e WHERE e.documento=doc AND e.idEmpleado_horario=id;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarHorarioLaboral` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM horario_trabajo;
ELSE
#
  SELECT * FROM horario_trabajo WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarHorasExtrasAceptasORechazadas` (IN `doc` VARCHAR(13), IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10), IN `accion` TINYINT(1))  NO SQL
BEGIN
#...
IF fechaI!='' AND fechaF!='' THEN
#Rango de fechas
  IF accion=1 THEN# Horas Extras Aceptadas
    SELECT h.horas_aceptadas as numero_horas FROM h_laboral h WHERE h.documento=doc AND (h.fecha_laboral BETWEEN fechaI AND fechaF) AND h.idEvento_laboral=2 and h.Estado=1;
  ELSE#Horas extras Rechazadas
    SELECT h.horas_rechazadas as numero_horas FROM h_laboral h WHERE h.documento=doc AND (h.fecha_laboral BETWEEN fechaI AND fechaF) AND h.idEvento_laboral=2 and h.Estado=1;
  END IF;
ELSE
  IF fechaI!='' AND fechaF='' THEN
  #Consultar por una fecha
    IF accion=1 THEN# Horas Extras Aceptadas
  	  SELECT h.horas_aceptadas as numero_horas FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=fechaI AND h.idEvento_laboral=2 and h.Estado=1;
    ELSE #Horas Extras Rechazadas
      SELECT h.horas_rechazadas as numero_horas FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=fechaI AND h.idEvento_laboral=2 and h.Estado=1;
    END IF;
  END IF;
END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarIncapacidades` (IN `id` INT)  NO SQL
BEGIN

IF id!=0 THEN
#consultar por ID de incapacidad
SELECT i.idIncapacidad,e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,d.idDiagnostico,d.diagnostico,i.valor_descuento,(DATEDIFF(i.fecha_fin_incapacidad,i.fecha_incapacidad)+1) AS dias,DATE_FORMAT(i.fecha_incapacidad,'%d-%m-%Y') AS fecha_incapacidad,DATE_FORMAT(i.fecha_fin_incapacidad,'%d-%m-%Y') AS fecha_fin_incapacidad,i.descripcion,i.idTipoIncapacidad,i.idEnfermedad,i.valor_eps,i.valor_empresa,i.valor_arl FROM empleado e JOIN incapacidad i ON e.documento=i.documento JOIN diagnostico d ON i.Diagnostico_idDiagnostico=d.idDiagnostico WHERE i.idIncapacidad=id;
ELSE
#Consultar incapacidades general
SELECT i.idIncapacidad,e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,d.idDiagnostico,d.diagnostico,i.valor_descuento,(DATEDIFF(i.fecha_fin_incapacidad,i.fecha_incapacidad)+1) AS dias,DATE_FORMAT(i.fecha_incapacidad,'%d-%m-%Y') AS fecha_incapacidad,i.idTipoIncapacidad,i.reintegro,i.diferencia,i.valor_eps,i.valor_empresa,i.valor_arl FROM empleado e JOIN incapacidad i ON e.documento=i.documento JOIN diagnostico d ON i.Diagnostico_idDiagnostico=d.idDiagnostico;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarIndoPersonal` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

#SELECT p.idPersonal,p.direccion,REPLACE(p.direccion,';',' ') AS direc,p.barrio,p.comuna,p.idMunicipio,m.nombre AS municipio,p.estrato,p.caso_emergencia,p.tel,p.parentezco,pt.nombre,p.idTipo_vivienda,t.nombre AS vivienda,p.altura,p.peso FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN personal p ON f.idPersonal=p.idPersonal JOIN municipio m ON p.idMunicipio=m.idMunicipio JOIN tipo_vivienda t ON p.idTipo_vivienda=t.idTipo_vivienda JOIN parentezco pt ON pt.idParentezco=p.parentezco  WHERE e.documento=doc;

SELECT p.idPersonal,p.direccion,UPPER(REPLACE(p.direccion,';',' ')) AS direc,p.barrio,p.comuna,p.idMunicipio,m.nombre AS municipio,p.estrato,p.caso_emergencia,p.tel,p.parentezco,(SELECT pt.nombre FROM parentezco pt WHERE pt.idParentezco=p.parentezco) AS nombre,p.idTipo_vivienda,t.nombre AS vivienda,p.altura,p.peso,p.otraActividad FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN personal p ON f.idPersonal=p.idPersonal JOIN municipio m ON p.idMunicipio=m.idMunicipio JOIN tipo_vivienda t ON p.idTipo_vivienda=t.idTipo_vivienda WHERE e.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarInfoEstudios` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

SELECT es.idEstudios,es.idGrado_escolaridad,ge.grado,es.titulo_profecional,es.titulo_especializacion,es.titulo_estudios_actuales,(SELECT g.grado FROM grado_escolaridad g where g.idGrado_escolaridad=es.titulo_estudios_actuales) as estudios_actuales,es.nombre_carrera  FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN estudios es ON f.idEstudios=es.idEstudios JOIN grado_escolaridad ge ON es.idGrado_escolaridad=ge.idGrado_escolaridad  WHERE e.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarInfoLaboral` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

SELECT l.idLaboral,l.idHorario_trabajo,h.horario,l.idArea_trabajo,art.area,l.idCargo,c.cargo,l.recurso_humano,l.idTipo_contrato,tc.contrato,DATE_FORMAT(l.fecha_vencimiento_contrato,'%d-%m-%Y') AS fecha_vencimiento_contrato,l.antiguedad,l.idClasificacion_contable,cc.clasificacion FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN laboral l ON f.idLaboral=l.idLaboral JOIN horario_trabajo h ON l.idHorario_trabajo=h.idHorario_trabajo JOIN cargo c ON l.idCargo=c.idCargo JOIN area_trabajo art ON l.idArea_trabajo=art.idArea_trabajo JOIN tipo_contrato tc ON l.idTipo_contrato=tc.idTipo_contrato JOIN clasificacion_contable cc ON l.idClasificacion_contable=cc.idClasificacion_contable WHERE e.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarInfoSalarial` (IN `doc` VARCHAR(20))  NO SQL
BEGIN



SELECT s.idSalarial,s.idPromedio_salario,(SELECT ps.nombre FROM promedio_salario ps WHERE ps.idPromedio_salario=s.idPromedio_salario) AS nombre,s.idClasificacion_mega,(SELECT clm.clasificacion FROM clasificacion_mega clm WHERE clm.idClasificacion_mega=s.idClasificacion_mega) AS clasificacion ,s.salario_basico,CONCAT('$',FORMAT(s.salario_basico,00)) AS salario_baseico_formato,s.total,CONCAT('$',s.total) AS totalFormato FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN salarial s ON f.idSalarial=s.idSalarial WHERE e.documento=doc;

#SELECT s.idSalarial,s.idPromedio_salario,ps.nombre,s.idClasificacion_mega,clm.clasificacion,s.salario_basico,CONCAT('$',FORMAT(s.salario_basico,00)) AS salario_baseico_formato,s.total,CONCAT('$',s.total) AS totalFormato FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN salarial s ON f.idSalarial=s.idSalarial JOIN promedio_salario ps ON s.idPromedio_salario=ps.idPromedio_salario JOIN clasificacion_mega clm ON s.idClasificacion_mega=clm.idClasificacion_mega WHERE e.documento=doc;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarInfoSalud` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

SELECT s.idSalud,s.fuma,s.alcohol,s.descripccion_emergencia  FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN salud s ON f.idSalud=s.idSalud WHERE e.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarInfoSAuxilios` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

SELECT ta.idTipo_auxilio,ta.auxilio,a.monto,CONCAT('$',FORMAT(a.monto,00)) AS mondoFormato,a.estado FROM ficha_sd f RIGHT JOIN salarial s ON f.idSalarial=s.idSalarial RIGHT JOIN auxilio a ON s.idSalarial=a.idSalarial JOIN tipo_auxilio ta ON a.idTipo_auxilio=ta.idTipo_auxilio WHERE f.documento=doc AND a.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarInfoSecundariaBasica` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

SELECT s.idSecundaria_basica,s.idEstado_civil,es.nombre_estado,DATE_FORMAT(s.fecha_nacimiento,'%d-%m-%Y') AS fecha_nacimiento,s.lugar_nacimiento,s.tel_fijo,s.celular,s.idTipo_sangre,ts.nombre AS sangre,s.idEPS,eps.nombre AS eps,s.idAFP,afp.nombre AS afp FROM empleado e JOIN ficha_sd f ON e.documento=f.documento JOIN secundaria_basica s ON f.idSecundaria_basica=s.idSecundaria_basica JOIN estado_civil es ON s.idEstado_civil=es.idEstado_civil JOIN tipo_sangre ts ON s.idTipo_sangre=ts.idTipo_sangre JOIN eps ON s.idEPS=eps.idEPS JOIN afp ON s.idAFP=afp.idAFP WHERE e.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarMotivos` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#Consulta general
SELECT * FROM motivo;

ELSE
#consulta por estado
SELECT * FROM motivo m WHERE m.estado=1;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarMunicipios` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM municipio;
ELSE
#
  SELECT * FROM municipio WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarOperariosEstadoInicialAsistencia` ()  NO SQL
BEGIN

SELECT e.documento,e.asistencia, (SELECT a1.inicio FROM asistencia a1 WHERE a1.idAsistencia= (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=e.documento AND a.idTipo_evento=1 AND DATE_FORMAT(a.inicio,'%Y-%m-%d')=CURDATE() LIMIT 1)) AS horaLlegada FROM empleado e WHERE e.idRol=1 AND e.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarOtraInformacion` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

SELECT o.idOtros,o.talla_camisa,o.talla_pantalon,o.talla_zapatos,o.vigencia_curso_alturas,o.brigadas,o.comites,o.necesitaCALT, o.locker FROM ficha_sd f JOIN otros o ON f.idOtros=o.idOtros WHERE f.documento=doc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarPermisoEmpleado` (IN `doc` VARCHAR(20), IN `cod` VARCHAR(5), IN `fecha` VARCHAR(15))  NO SQL
BEGIN

IF doc!='' AND fecha!='' THEN
#Se encarga de consultar todos los permisos de los empleados por una fecha en especifica.
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario)AS usuario,em.documento,p.idPermiso,DATE_FORMAT(p.fecha_solicitud,'%d-%m-%Y') as fecha_solicitud,DATE_FORMAT(p.fecha_permiso,'%d-%m-%Y') as fecha_permiso,c.concepto, p.descripcion,p.desde,TIME_FORMAT(p.desde,'%r') AS desde12, p.hasta,p.numero_horas,p.estado,hp.momento,em.nombre1,em.nombre2,em.apellido1,em.apellido2 FROM concepto c JOIN permiso p ON c.idConcepto=p.idConcepto LEFT join horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso JOIN empleado em ON p.documento=em.documento WHERE p.fecha_permiso=fecha AND p.documento=doc;
#select 1 as respuesta;
ELSE
IF doc!='' AND cod='' THEN
#se encarga de consultar el permiso de los empleados por el documento.
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario)AS usuario,em.documento,p.idPermiso,DATE_FORMAT(p.fecha_solicitud,'%d-%m-%Y') as fecha_solicitud,DATE_FORMAT(p.fecha_permiso,'%d-%m-%Y') as fecha_permiso,c.concepto, p.descripcion,p.desde,TIME_FORMAT(p.desde,'%r') AS desde12, p.hasta,p.numero_horas,p.estado,cp.Codigo,hp.momento,em.nombre1,em.nombre2,em.apellido1,em.apellido2,u.nombre AS usuario FROM concepto c JOIN permiso p ON c.idConcepto=p.idConcepto JOIN codigo_permiso cp ON p.Codigo=cp.Codigo LEFT join horario_permiso hp ON cp.idHorario_permiso=hp.idHorario_permiso JOIN empleado em ON cp.documento=em.documento JOIN usuario u ON cp.idUsuario=u.idUsuario WHERE cp.documento=doc;
#select 1 as respuesta;
ELSE
#se encarga de consultar el permiso de los empleados por el documento y el codigo del permiso.
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario)AS usuario,cp.documento,p.idPermiso,DATE_FORMAT(p.fecha_solicitud,'%d-%m-%Y') as fecha_solicitud,DATE_FORMAT(p.fecha_permiso,'%d-%m-%Y') as fecha_permiso,c.concepto,c.idConcepto, p.descripcion,p.desde,TIME_FORMAT(p.desde,'%r') AS desde12, p.hasta,p.numero_horas,p.estado,cp.Codigo,hp.momento,u.nombre AS usuario FROM concepto c JOIN permiso p ON c.idConcepto=p.idConcepto JOIN codigo_permiso cp ON p.Codigo=cp.Codigo LEFT join horario_permiso hp ON cp.idHorario_permiso=hp.idHorario_permiso JOIN usuario u ON cp.idUsuario=u.idUsuario WHERE cp.documento=doc AND DATEDIFF(DATE_FORMAT(now(),'%Y-%m-%d'),DATE_FORMAT(cp.fecha,'%Y-%m-%d'))<7 AND cp.Codigo COLLATE utf8_bin= cod;
#select 2 as respuesta;
END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarPermisoEmpleadoEditar` (IN `idP` INT)  NO SQL
BEGIN

SELECT p.documento,p.idPermiso,p.fecha_solicitud,DATE_FORMAT(p.fecha_permiso,'%d-%m-%Y') as fecha_permiso,p.idConcepto,p.descripcion,p.desde,p.hasta,p.numero_horas,p.idHorario_permiso,(SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario) AS usuario FROM permiso p WHERE p.idPermiso=idP;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarPermisosEmpleado` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

IF doc!='' THEN#Consulta por documento
SELECT e.nombre1,e.nombre2,e.apellido1,e.apellido2,p.fecha_permiso,c.concepto,hp.momento,DATE_FORMAT(p.desde,'%r') AS desde,p.estado FROM permiso p JOIN empleado e ON p.documento=e.documento JOIN concepto c ON p.idConcepto=c.idConcepto JOIN horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso WHERE p.documento=doc AND DATEDIFF(CURDATE(),p.fecha_permiso)<7;
ELSE
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario) AS usuario,p.idPermiso,p.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,p.fecha_permiso,c.concepto,hp.momento,DATE_FORMAT(p.desde,'%r') AS desde,p.estado FROM permiso p JOIN empleado e ON p.documento=e.documento JOIN concepto c ON p.idConcepto=c.idConcepto JOIN horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso WHERE DATEDIFF(CURDATE(),p.fecha_permiso)<7;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarPermisosPorRangoFechas` (IN `fechaI` VARCHAR(11), IN `fechaF` VARCHAR(11), IN `doc` VARCHAR(20))  NO SQL
BEGIN

IF doc!='' THEN#Consultar por rango de fecha o fecha y por el documento. 
IF (fechaI!='' AND fechaF!='') THEN
#Consultar por rango de fechas
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario) AS usuario,p.idPermiso,p.fecha_permiso,p.fecha_solicitud,c.concepto,p.estado,p.numero_horas FROM permiso p LEFT JOIN empleado e ON p.documento=e.documento LEFT JOIN concepto c ON p.idConcepto=c.idConcepto LEFT JOIN horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso WHERE (p.fecha_permiso BETWEEN fechaI AND fechaF) AND p.documento=doc;
ELSE
#Consultar Por una fecha en especifico.
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario) AS usuario,p.idPermiso,p.fecha_permiso,p.fecha_solicitud,c.concepto,p.estado,p.numero_horas FROM permiso p JOIN empleado e ON p.documento=e.documento JOIN concepto c ON p.idConcepto=c.idConcepto JOIN horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso WHERE p.fecha_permiso=fechaI AND p.documento=doc;
END IF;
ELSE#Consultar solo por las fechas
IF (fechaI!='' AND fechaF!='') THEN
#Consultar por rango de fechas
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario) AS usuario,p.idPermiso,e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,p.fecha_permiso,c.concepto,hp.momento,DATE_FORMAT(p.desde,'%r') AS desde,p.estado FROM permiso p LEFT JOIN empleado e ON p.documento=e.documento LEFT JOIN concepto c ON p.idConcepto=c.idConcepto LEFT JOIN horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso WHERE (p.fecha_permiso BETWEEN fechaI AND fechaF);
ELSE
#Consultar Por una fecha en especifico.
SELECT (SELECT u.nombre FROM usuario u WHERE u.idUsuario=p.idUsuario) AS usuario,p.idPermiso,e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,p.fecha_permiso,c.concepto,hp.momento,DATE_FORMAT(p.desde,'%r') AS desde,p.estado FROM permiso p JOIN empleado e ON p.documento=e.documento JOIN concepto c ON p.idConcepto=c.idConcepto JOIN horario_permiso hp ON p.idHorario_permiso=hp.idHorario_permiso WHERE p.fecha_permiso=fechaI;
END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarPersonasViveInfoPersonal` (IN `id` INT)  NO SQL
BEGIN

SELECT p.idPersonas_vive,p.nombreC,p.idParentezco,pt.nombre,p.celular,DATE_FORMAT(p.fecha_nacimiento,'%d-%m-%Y') AS fecha_nacimiento,p.vive_empleado,p.cantidad,TIMESTAMPDIFF(year,p.fecha_nacimiento, CURDATE()) AS edad FROM personas_vive p JOIN parentezco pt ON p.idParentezco=pt.idParentezco WHERE p.idPersonal=id ORDER BY p.idParentezco ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarRoles` ()  NO SQL
BEGIN

SELECT r.idRol,r.nombre FROM rol r WHERE r.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarSalarios` (IN `op` TINYINT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
SELECT * FROM promedio_salario;
ELSE
#
SELECT * FROM promedio_salario WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarTiempoPermisosEmpleadosConsumido` (IN `doc` VARCHAR(13), IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10))  NO SQL
BEGIN

IF fechaI!='' and fechaF='' THEN
#Consultar Por una fecha

SELECT p.numero_horas FROM permiso p WHERE p.fecha_permiso=fechaI  AND p.documento=doc;

ELSE
#consultar por un rango de fechas

SELECT p.numero_horas FROM permiso p WHERE (p.fecha_permiso BETWEEN fechaI AND fechaF) AND p.documento=doc;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarTipoAxulio` (IN `op` TINYINT(1))  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM tipo_auxilio ORDER BY idTipo_auxilio ASC;
ELSE
#
  SELECT * FROM tipo_auxilio WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarTipoContrato` (IN `op` INT)  NO SQL
BEGIN
# 1=Consultar Todos independiente el estado, 2=Consultar Todos lo qe tenga estado activo;
IF op=1 THEN
#
  SELECT * FROM tipo_contrato;
ELSE
#
  SELECT * FROM tipo_contrato WHERE estado=1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarTiposUsuario` ()  NO SQL
BEGIN

SELECT * FROM tipo_usuario;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ConsultarUsuarios` (IN `id` INT)  NO SQL
BEGIN

IF id!=0 THEN
#Consulta por identificador
SELECT u.idUsuario,u.nombre AS usur,u.contraseña AS contra,u.estado,t.idTipo_usuario,t.nombre,u.email FROM usuario u JOIN tipo_usuario t ON u.idTipo_usuario=t.idTipo_usuario WHERE u.idUsuario=id;

else
#consulta en general
SELECT u.idUsuario,u.nombre AS usur,u.contraseña AS contra,u.estado,t.idTipo_usuario,t.nombre,u.email FROM usuario u JOIN tipo_usuario t ON u.idTipo_usuario=t.idTipo_usuario;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ContarCantidadAuxilios` (IN `doc` VARCHAR(13))  NO SQL
BEGIN

SELECT COUNT(a.idAuxilio) AS cantidad FROM ficha_sd f RIGHT JOIN salarial s ON f.idSalarial=s.idSalarial RIGHT JOIN auxilio a ON s.idSalarial=a.idSalarial JOIN tipo_auxilio ta ON a.idTipo_auxilio=ta.idTipo_auxilio WHERE f.documento=doc AND a.estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_EliminarEmpleado` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

DECLARE c int;

SET c=(SELECT e.estado FROM empleado e WHERE e.documento=doc);

IF c=1 THEN

UPDATE empleado e SET e.estado=0 WHERE e.documento=doc;

ELSE

UPDATE empleado e SET e.estado=1 WHERE e.documento=doc;

END IF;

SELECT true AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_EliminarExamenEmpleado` (IN `idE` INT)  NO SQL
BEGIN

DELETE FROM examenes_medicos WHERE idexamenes_Medicos=idE;

SELECT 1 as respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_EliminarIncapacidad` (IN `id` INT)  NO SQL
BEGIN
#Eliminar incapacidad empelado por id de incapacidad
DELETE FROM incapacidad WHERE idIncapacidad=id;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_EliminarPersonaVive` (IN `id` INT, IN `idPer` INT, IN `idParen` INT)  NO SQL
BEGIN

IF id!=0 THEN
#Se encarga de eliminar el registro de las personas con las que vive mediante el id
DELETE FROM personas_vive WHERE idPersonas_vive=id;
ELSE
#se enrcargara de eliminar los registro por las columnas de idPersonal e idPArentezco(Esto se implementara más que todo para los hijos e hijastros)
DELETE FROM personas_vive WHERE idPersonal=idPer AND idParentezco=idParen;
END IF;
#...
SELECT 1 AS respuesta;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_HorasTrabajadasNormalesOExtras` (IN `doc` VARCHAR(13), IN `fechaI` VARCHAR(10), IN `fechaF` VARCHAR(10), IN `evento` TINYINT(1), IN `estado` TINYINT(1))  NO SQL
BEGIN
#...
IF fechaI!='' AND fechaF!='' THEN
#Consultar por rango de fechas
 IF estado=2 THEN
 #No consulta por el estado
 SELECT h.numero_horas FROM h_laboral h WHERE h.documento=doc AND (h.fecha_laboral BETWEEN fechaI AND fechaF) AND h.idEvento_laboral=evento;
 ELSE
 #Consulta por el estado
 SELECT h.numero_horas FROM h_laboral h WHERE h.documento=doc AND (h.fecha_laboral BETWEEN fechaI AND fechaF) AND h.idEvento_laboral=evento and h.Estado=estado;
 END IF;
ELSE
 IF fechaI!='' AND fechaF='' THEN
 #Consultar por una fecha
  IF estado=2 THEN
  #No consulta por el estado
 	SELECT h.numero_horas FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=fechaI AND h.idEvento_laboral=evento;
  ELSE
  #Consulta por el estado
 	SELECT h.numero_horas FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=fechaI AND h.idEvento_laboral=evento and h.Estado=estado;
  END IF;
 END IF;
END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_LimpiarBaseDatosFichasSDG` ()  NO SQL
BEGIN

#Eliminar info tabla ficha SDG

DELETE FROM ficha_sd;

#Eliminar info de tabla otros

DELETE FROM otros;

#Eliminar info de tabla salud

DELETE FROM salud;

#Eliminar info de la tabla personas_vive

DELETE FROM personas_vive;

#Eliminar info de la tabla actividades_tiempo_libre

DELETE FROM actividades_timpo_libre;

#Eliminar info de la tabla Personal

DELETE FROM personal;

#Eliminar info de la tabla estudios

DELETE FROM estudios;

#Eliminar infor de la tabla laboral

DELETE FROM laboral;

#Eliminar info de la tabla salarial

DELETE FROM salarial;

#Eliminar info de la tabla secundaria_basica

DELETE FROM secundaria_basica;

#Eliminar info de la tabla de estado empresariales

DELETE FROM estado_empresarial;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ModificarEmpleados` (IN `doc` VARCHAR(20), IN `nom1` VARCHAR(45), IN `nom2` VARCHAR(45), IN `apelli1` VARCHAR(45), IN `apelli2` VARCHAR(45), IN `genero` TINYINT(1), IN `huella1` INT, IN `huella2` INT, IN `huella3` INT, IN `correo` VARCHAR(50), IN `contra` VARCHAR(50), IN `idE` TINYINT, IN `idR` TINYINT, IN `piso` VARCHAR(1), IN `fechaEx` VARCHAR(10), IN `lugarEx` VARCHAR(50), IN `idM` TINYINT, IN `estado` TINYINT(1))  NO SQL
BEGIN

IF contra!='' THEN
#Modifica la contraseña
UPDATE `empleado` e SET `nombre1`=nom1,`nombre2`=nom2,`apellido1`=apelli1,`apellido2`=apelli2,`genero`=genero,`huella1`=huella1,`huella2`=huella2,`huella3`=huella3,`correo`=correo,`contraseña`=contra,`idEmpresa`=idE, `idRol`=idR, `piso`=piso, `fecha_expedicion`=fechaEx,`lugar_expedicion`=lugarEx,`idManufactura`=idM WHERE `documento`=doc;
ELSE
#No modifica la contraseña
UPDATE `empleado` SET `nombre1`=nom1,`nombre2`=nom2,`apellido1`=apelli1,`apellido2`=apelli2,`genero`=genero,`huella1`=huella1,`huella2`=huella2,`huella3`=huella3,`correo`=correo,`idEmpresa`=idE, `idRol`=idR, `piso`=piso, `fecha_expedicion`=fechaEx,`lugar_expedicion`=lugarEx,`idManufactura`=idM WHERE `documento`=doc;
END IF;

#Modificar el estado de los empleados
IF estado!=-1 THEN

UPDATE empleado e SET e.estado=estado WHERE e.documento=doc; 

END IF;

SELECT true AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ModificarReintegroIncapacidad` (IN `idI` INT, IN `reintegro` VARCHAR(11), IN `diferencia` VARCHAR(11))  NO SQL
BEGIN
#Se encarga de actualizar el reintegro y la diferencia de la incapacidades donde la EPS o ARL cubre cierta parte o todo el valor de la incapacidad
UPDATE incapacidad i SET i.reintegro=reintegro, i.diferencia=diferencia WHERE i.idIncapacidad=idI;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_NotificacionesDeUsuario` (IN `rol` INT)  NO SQL
BEGIN
#calcular tiempo de la notificacion
DECLARE tiempo datetime;
#
#SET tiempo=(SELECT fecha FROM notificacion WHERE idUsuario=rol);
#
SELECT n.idNotificacion,SE_FU_TiempoDeNotificacion(n.fecha) AS fecha,DATE_FORMAT(n.fecha,'%d-%m-%Y') AS origen,DATE_FORMAT(n.fecha,'%Y-%m-%d') AS origen1, n.comentario, n.idTipo_notificacion, n.leido FROM notificacion n WHERE n.idUsuario= rol order BY n.fecha DESC LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarFichaSDG` (IN `doc` VARCHAR(20), IN `idSalarial` INT, IN `idLaboral` INT, IN `idEstudio` INT, IN `idSecundariaB` INT, IN `idPersonal` INT, IN `idSalud` INT, IN `idOtros` INT)  NO SQL
BEGIN

IF EXISTS(SELECT * FROM ficha_sd f WHERE f.documento=doc) THEN#Si existe la ficha SDG
#Selecciona el ID de la ficha SDG del empleado
SELECT f.idFicha_SD AS respuesta FROM ficha_sd f WHERE f.documento=doc;
#...
ELSE
#solo se registrara porque una ficha solo puede tener toda informacion una vez (Cardinalidad de 1 a 1 a todas la tablas implicadas).
INSERT INTO `ficha_sd`(`documento`, `idSalarial`, `idLaboral`, `idEstudios`, `idSecundaria_basica`, `idPersonal`, `idSalud`, `idOtros`) VALUES (doc,idSalarial,idLaboral,idEstudio,idSecundariaB,idPersonal,idSalud,idOtros);
#...
SELECT MAX(f.idFicha_SD) AS respuesta FROM ficha_sd f;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarActividadesInfoPersonal` (IN `ID` INT, IN `idA` TINYINT(3))  NO SQL
BEGIN
DECLARE idI int;
#...
IF EXISTS(SELECT * FROM actividades_timpo_libre a WHERE a.idPersonal=ID AND a.idActividades=idA) THEN
#Eliminar actividad
SET idI= (SELECT a.idActividades_timpo_libre FROM actividades_timpo_libre a WHERE a.idPersonal=ID AND a.idActividades=idA);
#...	
     DELETE FROM actividades_timpo_libre WHERE idActividades_timpo_libre=idI;
#...
ELSE
#registrar
   INSERT INTO actividades_timpo_libre(`idPersonal`, `idActividades`) VALUES(ID,idA);   
END IF;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarClasificacionContable` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de la clasificacion contable
IF estado=2 THEN
# registrar o modificar clasificacion contable
  IF idE=0 THEN
  #Registrar clasificacion contable
   INSERT INTO clasificacion_contable(clasificacion,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar clasificacion contable
   UPDATE clasificacion_contable e SET e.clasificacion=nombreE WHERE e.idClasificacion_contable=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la clasificacion contable
 IF EXISTS(SELECT * FROM clasificacion_contable e WHERE e.idClasificacion_contable=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE clasificacion_contable e SET e.estado=0 WHERE e.idClasificacion_contable=idE;
 ELSE
 #activa el estado
  UPDATE clasificacion_contable e SET e.estado=1 WHERE e.idClasificacion_contable=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarDiaFestivo` (IN `id` INT, IN `nombre` VARCHAR(60), IN `fecha` VARCHAR(13))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM dias_festivos d WHERE d.iddias_festivos=id) THEN
#Actualizar
UPDATE `dias_festivos` SET `nombre`=nombre,`fecha_dia`=fecha WHERE `iddias_festivos`=id;
ELSE
#Registrar
INSERT INTO `dias_festivos`(`nombre`, `fecha_dia`, `estado`) VALUES (nombre,fecha,1);
END IF;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEliminarExamenesMedicos` (IN `idE` INT, IN `documento` VARCHAR(20), IN `tipoExamen` INT, IN `otroExamen` VARCHAR(45), IN `motivo` VARCHAR(250), IN `fechaplazo` VARCHAR(15), IN `fechaRetorno` VARCHAR(15))  NO SQL
BEGIN
#variable de retorno
DECLARE res int;#Registrar=1,Modificar=2

#Modificar o Registrar
	IF EXISTS(SELECT * FROM examenes_medicos e WHERE e.idexamenes_Medicos=idE AND e.documento=documento LIMIT 1) THEN
      UPDATE examenes_medicos e SET e.fechaCarta=now(), e.tipoExamenes=tipoExamen,e.otroExamen=otroExamen, e.fechaPlazo=fechaplazo, e.fechaRetorno=fechaRetorno, e.motivo=motivo WHERE e.idexamenes_Medicos= idE AND e.documento=documento;
      SET res=2;
    ELSE
    INSERT INTO `examenes_medicos`(`documento`, `fechaCarta`, `fechaPlazo`, `tipoExamenes`, `otroExamen`, `fechaRetorno`, `motivo`) VALUES (documento,now(),fechaplazo,tipoExamen,otroExamen,fechaRetorno,motivo);
    SET res=1;
   END IF;

SELECT res AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEmpleadoHorario` (IN `idD` INT, IN `documento` VARCHAR(20), IN `idConfig` TINYINT(1), IN `diaInicio` TINYINT(1), IN `diaFin` TINYINT(1))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM empleado_horario e WHERE e.idEmpleado_horario=idD) THEN
#Modificar Horario Empleado
UPDATE `empleado_horario` SET `idConfiguracion`=idConfig,`diaInicio`=diaInicio,`diaFin`=diaFin WHERE `idEmpleado_horario`=idD;

ELSE
#Registrar Horario Empelado
INSERT INTO `empleado_horario`(`documento`, `idConfiguracion`, `diaInicio`, `diaFin`,`fechaInicio`) VALUES (documento,idConfig,diaInicio,diaFin,CURDATE());

END IF;

#Respuesta
SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoActividadTiempoLibre` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de AFP
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO actividad(nombre,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE actividad e SET e.nombre=nombreE WHERE e.idActividad=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM actividad e WHERE e.idActividad=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE actividad e SET e.estado=0 WHERE e.idActividad=idE;
 ELSE
 #activa el estado
  UPDATE actividad e SET e.estado=1 WHERE e.idActividad=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoAFP` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de AFP
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO afp(nombre,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE afp e SET e.nombre=nombreE WHERE e.idAFP=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM afp e WHERE e.idAFP=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE afp e SET e.estado=0 WHERE e.idAFP=idE;
 ELSE
 #activa el estado
  UPDATE afp e SET e.estado=1 WHERE e.idAFP=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoAreasTrabajo` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de Cargo
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO area_trabajo(area,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE area_trabajo e SET e.area=nombreE WHERE e.idArea_trabajo=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM area_trabajo e WHERE e.idArea_trabajo=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE area_trabajo e SET e.estado=0 WHERE e.idArea_trabajo=idE;
 ELSE
 #activa el estado
  UPDATE area_trabajo e SET e.estado=1 WHERE e.idArea_trabajo=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoAuxilio` (IN `idE` TINYINT(3), IN `auxilioE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de auxilio
IF estado=2 THEN
# registrar o modificar clasificacion mega
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO tipo_auxilio(auxilio,estado) values(auxilioE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar clasificacion mega
   UPDATE tipo_auxilio e SET e.auxilio=auxilioE WHERE e.idTipo_auxilio=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la clasificacion mega
 IF EXISTS(SELECT * FROM tipo_auxilio e WHERE e.idTipo_auxilio=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE tipo_auxilio e SET e.estado=0 WHERE e.idTipo_auxilio=idE;
 ELSE
 #activa el estado
  UPDATE tipo_auxilio e SET e.estado=1 WHERE e.idTipo_auxilio=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoCargo` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(60), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de Cargo
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO cargo(cargo,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE cargo e SET e.cargo=nombreE WHERE e.idCargo=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM cargo e WHERE e.idCargo=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE cargo e SET e.estado=0 WHERE e.idCargo=idE;
 ELSE
 #activa el estado
  UPDATE cargo e SET e.estado=1 WHERE e.idCargo=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoClasificacionMega` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(3), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado del clasificacion mega
IF estado=2 THEN
# registrar o modificar clasificacion mega
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO clasificacion_mega(clasificacion,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar clasificacion mega
   UPDATE clasificacion_mega e SET e.clasificacion=nombreE WHERE e.idClasificacion_mega=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la clasificacion mega
 IF EXISTS(SELECT * FROM clasificacion_mega e WHERE e.idClasificacion_mega=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE clasificacion_mega e SET e.estado=0 WHERE e.idClasificacion_mega=idE;
 ELSE
 #activa el estado
  UPDATE clasificacion_mega e SET e.estado=1 WHERE e.idClasificacion_mega=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoDiagnostico` (IN `cod` VARCHAR(4), IN `diagnostico` VARCHAR(50), IN `op` INT)  NO SQL
BEGIN
#1 resgistrar 2=Modificar y 3=cambiar estado
IF op=1 THEN
#Registrar
INSERT INTO diagnostico(idDiagnostico,diagnostico) VALUES (cod,diagnostico);
ELSE
  IF op=2 THEN
  #Modificar
  	UPDATE diagnostico d SET d.diagnostico=diagnostico WHERE d.idDiagnostico=cod;
  ELSE
  #Cambiar estado
    IF EXISTS(SELECT * FROM diagnostico d WHERE d.estado=1 AND d.idDiagnostico=cod) THEN
      #Desactivar
      UPDATE diagnostico d SET d.estado=0 WHERE d.idDiagnostico=cod;
    ELSE
      #Activar
      UPDATE diagnostico d SET d.estado=1 WHERE d.idDiagnostico=cod;
    END IF;
  END IF;
END IF;
#Retorno
SELECT op AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoEmpresarial` (IN `IDFicha` INT, IN `fechaR` VARCHAR(13), IN `fechaI` VARCHAR(13), IN `idMotivo` TINYINT(3), IN `idIndRota` TINYINT(1), IN `estado` TINYINT(1), IN `observacion` VARCHAR(250), IN `idEmpresa` INT, IN `idEsatoE` INT, IN `estadoE` VARCHAR(1), IN `impacto` TINYINT(1))  NO SQL
BEGIN

#op=0 registrar o op=1 modificar
IF idEsatoE=0 THEN
#Registrar
INSERT INTO `estado_empresarial`(`idFicha_SD`, `estado_e`, `fecha_retiro`, `fecha_ingreso`, `idMotivo`, `idIndicador_rotacion`, `observacion_retiro`, `estado`, `idEmpresa`,`impacto`) VALUES (IDFicha,estadoE,fechaR,fechaI,idMotivo,idIndRota,observacion,estado,idEmpresa,impacto);
#...
SELECT 1 AS respuesta;
ELSE
#Modificar
#SELECT 1;
UPDATE `estado_empresarial` SET `estado_e`=estadoE,`fecha_retiro`=fechaR,`fecha_ingreso`=fechaI,`idMotivo`=idMotivo,`idIndicador_rotacion`=idIndRota,`observacion_retiro`=observacion,`estado`=estado,`idEmpresa`=idEmpresa, `impacto`=impacto WHERE `idEstado_empresarial`=idEsatoE AND `idFicha_SD`=IDFicha;
#...
SELECT 2 AS respuesta;
END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoEmpresas` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(25), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de la empresa
IF estado=2 THEN
# registrar o modificar empresa
  IF idE=0 THEN
  #Registrar empresa
   INSERT INTO empresa(nombre,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar empresa
   UPDATE empresa e SET e.nombre=nombreE WHERE e.idEmpresa=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la empresa
 IF EXISTS(SELECT * FROM empresa e WHERE e.idEmpresa=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE empresa e SET e.estado=0 WHERE e.idEmpresa=idE;
 ELSE
 #activa el estado
  UPDATE empresa e SET e.estado=1 WHERE e.idEmpresa=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoEPS` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de auxilio
IF estado=2 THEN
# registrar o modificar clasificacion mega
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO eps(nombre,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar clasificacion mega
   UPDATE eps e SET e.nombre=nombreE WHERE e.idEPS=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la clasificacion mega
 IF EXISTS(SELECT * FROM eps e WHERE e.idEPS=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE eps e SET e.estado=0 WHERE e.idEPS=idE;
 ELSE
 #activa el estado
  UPDATE eps e SET e.estado=1 WHERE e.idEPS=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoEstadoCivil` (IN `idE` TINYINT(3), IN `ECivil` VARCHAR(20), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de auxilio
IF estado=2 THEN
# registrar o modificar clasificacion mega
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO estado_civil(nombre_estado,estado) values(ECivil,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar clasificacion mega
   UPDATE estado_civil e SET e.nombre_estado=ECivil WHERE e.idEstado_civil=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la clasificacion mega
 IF EXISTS(SELECT * FROM estado_civil e WHERE e.idEstado_civil=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE estado_civil e SET e.estado=0 WHERE e.idEstado_civil=idE;
 ELSE
 #activa el estado
  UPDATE estado_civil e SET e.estado=1 WHERE e.idEstado_civil=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoGradoEscolaridad` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de AFP
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO grado_escolaridad(grado,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE grado_escolaridad e SET e.grado=nombreE WHERE e.idGrado_escolaridad=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM grado_escolaridad e WHERE e.idGrado_escolaridad=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE grado_escolaridad e SET e.estado=0 WHERE e.idGrado_escolaridad=idE;
 ELSE
 #activa el estado
  UPDATE grado_escolaridad e SET e.estado=1 WHERE e.idGrado_escolaridad=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoHorariotrabajo` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(20), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de Cargo
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO horario_trabajo(horario,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE horario_trabajo e SET e.horario=nombreE WHERE e.idHorario_trabajo=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM horario_trabajo e WHERE e.idHorario_trabajo=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE horario_trabajo e SET e.estado=0 WHERE e.idHorario_trabajo=idE;
 ELSE
 #activa el estado
  UPDATE horario_trabajo e SET e.estado=1 WHERE e.idHorario_trabajo=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoMunicipio` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(25), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de municipio
IF estado=2 THEN
# registrar o modificar municipio
  IF idE=0 THEN
  #Registrar municipio
   INSERT INTO municipio(nombre,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar municipio
   UPDATE municipio e SET e.nombre=nombreE WHERE e.idMunicipio=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado del municipio
 IF EXISTS(SELECT * FROM municipio e WHERE e.idMunicipio=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE municipio e SET e.estado=0 WHERE e.idMunicipio=idE;
 ELSE
 #activa el estado
  UPDATE municipio e SET e.estado=1 WHERE e.idMunicipio=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoSalario` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado del salario
IF estado=2 THEN
# registrar o modificar salario
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO promedio_salario(nombre,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar salario
   UPDATE promedio_salario e SET e.nombre=nombreE WHERE e.idPromedio_salario=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la salario
 IF EXISTS(SELECT * FROM promedio_salario e WHERE e.idPromedio_salario=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE promedio_salario e SET e.estado=0 WHERE e.idPromedio_Salario=idE;
 ELSE
 #activa el estado
  UPDATE promedio_salario e SET e.estado=1 WHERE e.idPromedio_Salario=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstadoTipoContrato` (IN `idE` TINYINT(3), IN `nombreE` VARCHAR(45), IN `estado` TINYINT(1))  NO SQL
BEGIN
#si el estado es 2 significa que no se va a cambiar el estado de AFP
IF estado=2 THEN
# registrar o modificar AFP
  IF idE=0 THEN
  #Registrar salario
   INSERT INTO tipo_contrato(contrato,estado) values(nombreE,1);
   SELECT 1 AS respuesta;
  ELSE
  #Modificar AFP
   UPDATE tipo_contrato e SET e.contrato=nombreE WHERE e.idTipo_contrato=idE;
   SELECT 1 AS respuesta;
  END IF;
ELSE
#modificar estado de la AFP
 IF EXISTS(SELECT * FROM tipo_contrato e WHERE e.idTipo_contrato=idE AND e.estado=1)  THEN
 #Desactiva el estado
  UPDATE tipo_contrato e SET e.estado=0 WHERE e.idTipo_contrato=idE;
 ELSE
 #activa el estado
  UPDATE tipo_contrato e SET e.estado=1 WHERE e.idTipo_contrato=idE;
 END IF;
 #...
 SELECT 1 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarEstudios` (IN `ID` INT, IN `idGrado` INT, IN `titulo` VARCHAR(50), IN `espec` VARCHAR(50), IN `idEstu` VARCHAR(1), IN `nombreC` VARCHAR(50))  NO SQL
BEGIN

DECLARE idE int;
IF ID=0 THEN
#Se registrara la informacion de escolaridad.
INSERT INTO estudios(`idGrado_escolaridad`, `titulo_profecional`, `titulo_especializacion`,`titulo_estudios_actuales`, `nombre_carrera`) VALUES(idGrado,titulo,espec,idEstu,nombreC);
#...
SELECT MAX(e.idEstudios) AS respuesta FROM estudios e;
ELSE
#Se modificara la informacion de la escolaridad.
SET idE=(SELECT e.idEstudios FROM ficha_sd f JOIN estudios e ON f.idEstudios=e.idEstudios WHERE f.idFicha_SD=ID LIMIT 1);
#...
UPDATE estudios e SET e.idGrado_escolaridad=idGrado, e.titulo_profecional=titulo, e.titulo_especializacion=espec,e.titulo_estudios_actuales=idEstu,e.nombre_carrera=nombreC WHERE e.idEstudios=idE;

SELECT idE AS respuesta;
#...
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarIncapacidades` (IN `accion` TINYINT(1), IN `doc` VARCHAR(20), IN `fechaI` VARCHAR(15), IN `fechaF` VARCHAR(15), IN `dias` VARCHAR(4), IN `valorT` VARCHAR(13), IN `diagnostico` VARCHAR(4), IN `descrip` VARCHAR(100), IN `idIncap` INT, IN `idTipoIncapa` INT, IN `idEnfermedad` INT, IN `valorEPS` VARCHAR(13), IN `valorEmpresa` VARCHAR(13), IN `valorARL` VARCHAR(13))  NO SQL
BEGIN
#Registrar la informacion
IF accion=0 THEN

INSERT INTO `incapacidad`(`documento`, `fecha_incapacidad`, `fecha_fin_incapacidad`, `dias`, `valor_descuento`, `Diagnostico_idDiagnostico`, `descripcion`,`idTipoIncapacidad`,`idEnfermedad`,`valor_eps`,`valor_empresa`,`valor_arl`) VALUES (doc,fechaI,fechaF,(SELECT DATEDIFF(fechaF,fechaI)+1),valorT,diagnostico,descrip,idTipoIncapa,idEnfermedad,valorEPS,valorEmpresa,valorARL);

ELSE
#Modificar la informacion

UPDATE `incapacidad` SET `documento`=doc,`fecha_incapacidad`=fechaI,`fecha_fin_incapacidad`=fechaF,`dias`=(DATEDIFF(fechaF,fechaI)+1),`valor_descuento`=valorT,`Diagnostico_idDiagnostico`=diagnostico,`descripcion`=descrip,`idTipoIncapacidad`=idTipoIncapa,`idEnfermedad`=idEnfermedad, `valor_eps`=valorEPS,`valor_empresa`=valorEmpresa, `valor_arl`=valorARL WHERE `idIncapacidad`=idIncap;

END IF;

#Retorno

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarInfoLaboral` (IN `ID` SMALLINT, IN `idHorario` TINYINT(3), IN `idAreaT` TINYINT(3), IN `idCargo` TINYINT(3), IN `recursoH` TINYINT(1), IN `idTipoC` TINYINT(3), IN `fechaVC` VARCHAR(13), IN `cc` TINYINT)  NO SQL
BEGIN
DECLARE idL int;
#Si el ID es igual a 0 se registrara la informacion si no entonces se modificara la informacion
IF ID=0 THEN
#Registrar la informacion laboral del empleado
INSERT INTO laboral(`idHorario_trabajo`, `idArea_trabajo`, `idCargo`, `recurso_humano`, `idTipo_contrato`, `fecha_vencimiento_contrato`,`idClasificacion_contable`) value(idHorario,idAreaT,idCargo,recursoH,idTipoC,fechaVC,cc);
#...
SELECT MAX(l.idLaboral) AS respuesta FROM laboral l;
ELSE
#Modificar la informacion laboral del empleado
SET idL =(SELECT f.idLaboral FROM ficha_sd f WHERE f.idFicha_SD=ID LIMIT 1);
#...
UPDATE laboral l SET l.idHorario_trabajo=idHorario, l.idArea_trabajo=idAreaT, l.idCargo=idCargo, l.recurso_humano=recursoH, l.idTipo_contrato=idTipoC, l.fecha_vencimiento_contrato=fechaVC, l.idClasificacion_contable=cc WHERE l.idLaboral=idL;
#...
SELECT idL AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarInfoPersonal` (IN `id` INT, IN `direccion` VARCHAR(70), IN `barrio` VARCHAR(20), IN `comuna` VARCHAR(2), IN `idMun` TINYINT(3), IN `estrato` VARCHAR(1), IN `caso_E` VARCHAR(50), IN `tel` VARCHAR(10), IN `parentezco` VARCHAR(20), IN `idTV` TINYINT(3), IN `altura` VARCHAR(4), IN `peso` VARCHAR(4), IN `otrA` VARCHAR(100))  NO SQL
BEGIN
DECLARE idP int;
IF id=0 THEN
#Registrar
INSERT INTO `personal`(`direccion`, `barrio`, `comuna`, `idMunicipio`, `estrato`, `caso_emergencia`, `tel`, `parentezco`, `idTipo_vivienda`, `altura`, `peso`,`otraActividad`) VALUES (direccion,barrio,comuna,idMun,estrato,caso_E,tel,parentezco,idTV,altura,peso,otrA);
#...
SELECT MAX(p.idPersonal) AS respuesta FROM personal p;
#...
ELSE
SET idP=(SELECT f.idPersonal FROM ficha_sd f WHERE f.idFicha_SD=ID);
#Modificar
UPDATE `personal` SET `direccion`=direccion,`barrio`=barrio,`comuna`=comuna,`idMunicipio`= idMun,`estrato`=estrato,`caso_emergencia`=caso_E,`tel`=tel,`parentezco`=parentezco,`idTipo_vivienda`=idTV,`altura`=altura,`peso`=peso, `otraActividad`=otrA WHERE `idPersonal`= idP;
#Pendiente hacer la selecion del ID para poder actualizar la informacion de actividades a tiempo libre y personas con las que vive posteriormente de realizar esta acción.
SELECT idP AS respuesta;
#...
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarInfoSalarial` (IN `ID` INT, IN `idPS` INT, IN `idCM` INT, IN `salairoB` VARCHAR(20), IN `total` VARCHAR(20))  NO SQL
BEGIN

DECLARE idE int;
#se valida que el ID sea igual a 0 para saber si se puede registrar o modificar la informacion secundaria basica.
IF ID=0 THEN
#Registrar
INSERT INTO `salarial`(`idPromedio_salario`, `idClasificacion_mega`, `salario_basico`, `total`) VALUES (idPS,idCM,salairoB,total);
#...
SELECT MAX(s.idSalarial) AS respuesta FROM salarial s;
ELSE
#Modificar
SET idE=(SELECT s.idSalarial FROM ficha_sd f JOIN salarial s ON f.idSalarial=s.idSalarial WHERE f.idFicha_SD=ID LIMIT 1);
#...
UPDATE `salarial` SET `idPromedio_salario`=idPS,`idClasificacion_mega`=idCM,`salario_basico`=salairoB,`total`=total WHERE `idSalarial`=idE;
#...
SELECT idE AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarInfoSalarialAuxilios` (IN `idSalarial` INT, IN `idAux` INT, IN `monto` VARCHAR(10))  NO SQL
BEGIN
DECLARE idA int;
#validar la existencia de ese auxilio para esa persona
IF EXISTS(SELECT * FROM auxilio a WHERE a.idSalarial=idSalarial AND a.idTipo_auxilio=idAux AND a.estado=1) THEN
#Si el auxilio existe se va a modificar el monto del auxilio
SET idA=(SELECT MAX(sub.idAuxilio) FROM auxilio sub WHERE sub.idTipo_auxilio=idAux AND sub.idSalarial=idSalarial);
UPDATE `auxilio` SET `monto`=monto WHERE `idSalarial`= idSalarial AND `idTipo_auxilio`=idAux AND `idAuxilio`=idA;
#...
ELSE
#Si el auxilio no existe se registrara el auxilio 
INSERT INTO `auxilio`(`idTipo_auxilio`,`monto`, `idSalarial`) VALUES (idAux,monto,idSalarial);
#...
END IF;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarInfoSalud` (IN `ID` INT, IN `nFuma` VARCHAR(3), IN `fAlcohol` VARCHAR(15), IN `descrip` VARCHAR(300))  NO SQL
BEGIN
DECLARE idS INT;
#Si el ID es igual a 0 este se encargara de registrar la informacion de salud del empleado.
IF ID=0 THEN
#Registrar informacion de salud
INSERT INTO salud(`fuma`, `alcohol`, `descripccion_emergencia`) VALUES(nFuma,fAlcohol,descrip);
#...
SELECT MAX(s.idSalud)AS respuesta FROM salud s;
#...
ELSE
SET idS=(SELECT f.idSalud FROM ficha_sd f  WHERE f.idFicha_SD=ID);
#Modificar informacion de salud
UPDATE salud s SET s.fuma=nFuma, s.alcohol=fAlcohol, s.descripccion_emergencia=descrip WHERE s.idSalud=idS;
#...
SELECT idS AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarInfoSecundaria` (IN `ID` INT, IN `estadoC` TINYINT(3), IN `fechaN` VARCHAR(13), IN `lugarN` VARCHAR(50), IN `tipoS` TINYINT(1), IN `telF` VARCHAR(7), IN `cel` VARCHAR(10), IN `idEps` TINYINT(3), IN `idAfp` TINYINT(3))  NO SQL
BEGIN

DECLARE idE int;
#se valida que el ID sea igual a 0 para saber si se puede registrar o modificar la informacion secundaria basica.
IF ID=0 THEN
#Registrar
INSERT INTO `secundaria_basica`(`idEstado_civil`, `fecha_nacimiento`, `lugar_nacimiento`, `tel_fijo`, `celular`, `idTipo_sangre`, `idEPS`, `idAFP`) VALUES (estadoC,fechaN,lugarN,telF,cel,tipoS,idEps,idAfp);
#...
SELECT MAX(s.idSecundaria_basica) AS respuesta FROM secundaria_basica s;
ELSE
#Modificar
SET idE=(SELECT f.idSecundaria_basica FROM ficha_sd f WHERE f.idFicha_SD=ID);
#...
UPDATE `secundaria_basica` SET `idEstado_civil`=estadoC,`fecha_nacimiento`=fechaN,`lugar_nacimiento`=lugarN,`tel_fijo`=telF,`celular`=cel,`idTipo_sangre`=tipoS,`idEPS`=idEps,`idAFP`=idAfp WHERE `idSecundaria_basica`=idE;

SELECT idE AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarOtraInfo` (IN `ID` INT, IN `Tcamisa` VARCHAR(4), IN `Tpantalon` VARCHAR(2), IN `Tzapatos` VARCHAR(2), IN `CAlturas` VARCHAR(20), IN `brigada` TINYINT(1), IN `comite` TINYINT(1), IN `CALTN` TINYINT(1), IN `locker` VARCHAR(3))  NO SQL
BEGIN
DECLARE idO INT;
#Si el ID es igual a 0 significa que va a registrar mientras que si es no es 0 significa que va a ser modificado.
IF ID=0 THEN
#Registrar otra informacion
INSERT INTO otros(`talla_camisa`, `talla_pantalon`, `talla_zapatos`, `vigencia_curso_alturas`, `brigadas`, `comites`, `necesitaCALT`, `locker`) VALUES(Tcamisa, Tpantalon, Tzapatos, CAlturas, brigada, comite, CALTN, locker);
#...
SELECT MAX(o.idOtros) AS respuesta FROM otros o;
ELSE
SET idO=(SELECT f.idOtros FROM ficha_sd f WHERE f.idFicha_SD=ID LIMIT 1);
#Modificar otra informacion
UPDATE otros o SET o.talla_camisa=Tcamisa, o.talla_pantalon=Tpantalon, o.talla_zapatos=Tzapatos, o.vigencia_curso_alturas=CAlturas,o.brigadas=brigada, o.comites=comite, o.necesitaCALT=CALTN, o.locker=locker WHERE o.idOtros=idO;
#...
SELECT idO AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarPermisoEmpleado` (IN `idP` INT, IN `documento` VARCHAR(20), IN `fechaP` VARCHAR(10), IN `concepto` TINYINT(2), IN `momento` TINYINT(1), IN `hora` VARCHAR(8), IN `des` VARCHAR(100))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM permiso p WHERE p.idPermiso=idP) THEN
#Actualiza la informacion del permiso
UPDATE `permiso` SET `idConcepto`=concepto,`descripcion`=des,`desde`=hora,`idHorario_permiso`=momento, `fecha_permiso`=fechaP WHERE `idPermiso`=idP;
ELSE
#Registra un nuevo permiso para el empleado.
INSERT INTO `permiso`(`documento`, `fecha_solicitud`, `fecha_permiso`, `idConcepto`, `descripcion`, `desde`, `estado`, `idHorario_permiso`) VALUES (documento,now(),fechaP,concepto,des,hora,0,momento);
END IF;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_RegistrarModificarUsuarios` (IN `idU` INT, IN `usu` VARCHAR(45), IN `contra` VARCHAR(50), IN `idT` INT, IN `op` INT, IN `email` VARCHAR(200))  NO SQL
BEGIN

IF op=0 THEN
#insertar
INSERT INTO `usuario`(`nombre`, `contraseña`, `idTipo_usuario`,`email`) VALUES (usu,contra,idT,email);

SELECT 1 AS respuesta;

ELSE
#modificar
UPDATE `usuario` SET `nombre`=usu,`contraseña`=contra,`idTipo_usuario`=idT, `email`=email WHERE `idUsuario`=idU;

SELECT 1 AS respuesta;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ReporteEmpelado` ()  NO SQL
BEGIN

SELECT e.documento, e.nombre1 AS Primer_Nombre, e.nombre2 AS Segundo_Nombre, e.apellido1 AS Primer_Apellido, e.apellido2 AS Segundo_Apellido,  (CASE 
    WHEN e.genero = 1 THEN "Masculino"
    WHEN e.genero = 0 THEN "Femenino"
  END) AS genero,e.correo,em.nombre AS empresa,r.nombre AS rol,(CASE 
    WHEN e.estado = 1 THEN "Activo"
    WHEN e.estado = 0 THEN "Inactivo"
  END) AS Estado,e.piso,e.fecha_expedicion,e.lugar_expedicion,(SELECT a.area FROM area_trabajo a WHERE a.idArea_trabajo=e.idManufactura) AS manufactura FROM empleado e JOIN empresa em ON e.idEmpresa=em.idEmpresa JOIN rol r ON e.idRol=r.idRol;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ReporteIncapacidades` ()  NO SQL
BEGIN

SELECT e.documento, e.nombre1,e.nombre2,e.apellido1,e.apellido2,em.nombre,CONCAT(d.idDiagnostico,'-',d.diagnostico) AS diagnostico,i.valor_eps,i.valor_arl,i.valor_empresa,i.valor_descuento,i.fecha_incapacidad,DATE_FORMAT(i.fecha_incapacidad,'%w') AS diaSemanaI,i.fecha_fin_incapacidad,DATE_FORMAT(i.fecha_fin_incapacidad,'%w') AS diaSemanaF,(DATEDIFF(i.fecha_fin_incapacidad,i.fecha_incapacidad)+1) as dias,i.idTipoIncapacidad,i.idEnfermedad,i.descripcion,FORMAT(i.reintegro,00) AS reintegro,i.diferencia FROM diagnostico d JOIN incapacidad i ON d.idDiagnostico=i.Diagnostico_idDiagnostico JOIN empleado e ON i.documento=e.documento JOIN empresa em on e.idEmpresa=em.idEmpresa;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_TiempoEventosPropuestosEmpresa` (IN `fechaI` VARCHAR(13), IN `fechaF` VARCHAR(13), IN `evento` INT)  NO SQL
BEGIN#Esto queda pendiente por desarrollar
#...
IF evento=1 THEN#Horas normales trabajadas
 SELECT 1;
ELSE
  IF evento=2 THEN#Tiempo de desayuno
  SELECT 2;
  ELSE
  	IF evento=3 THEN#Tiempo de almuerzo
    SELECT 3;
  	END IF;
  END IF;
END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_validarDocumentoExistente` (IN `doc` VARCHAR(20))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM empleado e WHERE e.documento=doc) THEN
SELECT true as respuesta;
ELSE
SELECT false as respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ValidarExistenciaContraseña` (IN `contra` VARCHAR(20), IN `doc` VARCHAR(20))  NO SQL
BEGIN

#validar existencia empleado
IF EXISTS(SELECT * FROM empleado e WHERE e.documento=doc) THEN
#Existe el empleado
  IF EXISTS(SELECT * FROM empleado e WHERE e.contraseña COLLATE utf8_bin=contra AND e.documento!=doc) THEN
  # existe la contraseña
    SELECT 1 AS respuesta;
  ELSE
  #No existe la contraseña
    SELECT 0 AS respuesta;
  END IF;
ELSE
#No existe el empleado
  IF EXISTS(SELECT * FROM empleado e WHERE e.contraseña COLLATE utf8_bin=contra) THEN
  # existe la contraseña
    SELECT 1 AS respuesta;
  ELSE
  #No existe la contraseña
    SELECT 0 AS respuesta;
  END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ValidarExistenciaPermisoCodigo` (IN `cod` VARCHAR(5))  NO SQL
BEGIN
#existe algun permiso con el codigo generado.
IF EXISTS(SELECT * FROM permiso p WHERE p.Codigo COLLATE utf8_bin='RzBkG') THEN
#si esxiste
SELECT false AS respuesta;

ELSE
#no existe
SELECT true AS respuesta;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ValidarHoraCodigoPermisoEmpleado` (IN `cod` VARCHAR(5), IN `horaE` VARCHAR(10), IN `idHorario` TINYINT(1))  NO SQL
BEGIN

#DECLARE evento tinyint(1);# tipo del horario del permiso 1= Salida temprano, 2=Llegada tarde y 3 salida e ingreso.
DECLARE horaI varchar(10);#Horario de inicio laboral.
DECLARE horaF varchar(10);#Horario del fin laboral.
#
#Evento con el cual se registro este código.
#SET evento=(SELECT c.idHorario_permiso FROM codigo_permiso c WHERE c.Codigo COLLATE utf8_bin= cod);
#Hora de inicio laboral de la empresa.
SET horaI =(SELECT c.hora_ingreso_empresa FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
#Hora de fin laboral de la empresa.
SET horaF =(SELECT c.hora_salida_empresa FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
#
#SELECT horaI,HoraF;
#SELECT horaE BETWEEN horaI AND horaF;

IF (SELECT horaE BETWEEN horaI AND horaF)=1 THEN
	#La hora es valida.
    SELECT 1 AS respuesta;
ELSE
	#la hora no es valida.
    SELECT 0 AS respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ValidarHorasConfiguracion` (IN `hora1` VARCHAR(13), IN `hora2` VARCHAR(13))  NO SQL
BEGIN
#DECLARE horaU varchar(13);
#DECLARE horaD varchar(13);

#SET horaU=(SELECT TIME_FORMAT(hora1,'%h:%i:%s'));
#SET horaD=(SELECT TIME_FORMAT(hora2,'%h:%i:%s'));
#SELECT horaU, horaD;
IF hora1< hora2 THEN
#cuando la hora numero 1 sea menor que la numero 2
SELECT true AS respuesta;

ELSE
#cuando la hora numero 2 sea menor que la numero 1
SELECT false AS respuesta;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_validarHuellasExistentes` (IN `huella1` INT, IN `huella2` INT, IN `huella3` INT)  NO SQL
BEGIN

IF EXISTS(SELECT * FROM empleado e WHERE (e.huella1=huella1 OR e.huella1=huella2 OR e.huella1=huella3) OR (e.huella2=huella1 OR e.huella2=huella2 OR e.huella3=huella3) OR (e.huella3=huella1 OR e.huella3=huella2 OR e.huella3=huella3)) THEN
SELECT true as respuesta;
ELSE
SELECT false as respuesta;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ValidarUsuario` (IN `us` VARCHAR(45))  NO SQL
BEGIN

IF EXISTS(SELECT * FROM usuario u WHERE u.nombre=us) THEN
#cuendo existe retorna un false
SELECT  false AS respuesta;
#
ELSE
#Cuando el usuario no existe se retorna un true
SELECT  true AS respuesta;
#
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_PA_ValidarUsuarioPermiso` (IN `doc` VARCHAR(20), IN `con` VARCHAR(10), IN `cod` VARCHAR(5))  NO SQL
BEGIN

select EXISTS(select * from empleado e JOIN codigo_permiso c ON e.documento=c.documento WHERE e.documento=doc AND e.contraseña=con AND e.estado=1 AND c.Codigo COLLATE utf8_bin=cod) AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SE_RegistrarModificarInformacionPersonasVive` (IN `op` TINYINT(1), IN `nombreC` VARCHAR(50), IN `idPT` INT, IN `celular` VARCHAR(10), IN `fechaN` VARCHAR(13), IN `viveEm` TINYINT(1), IN `idPersonal` SMALLINT, IN `cantidad` VARCHAR(3), IN `idPersonas` INT)  NO SQL
BEGIN
DECLARE idPV int;
#Si la opcion es igual a 0 se va a registrar si es igual a 1 se va a modificar.
IF op=0 THEN
#Registrar
INSERT INTO `personas_vive`(`nombreC`, `idParentezco`, `celular`, `fecha_nacimiento`, `vive_empleado`, `idPersonal`, `cantidad`) VALUES (nombreC,idPT,celular,fechaN,viveEm,idPersonal,cantidad);
ELSE
#Modificar
UPDATE `personas_vive` SET `nombreC`=nombreC,`celular`=celular,`fecha_nacimiento`=fechaN,`vive_empleado`=viveEm,`cantidad`=cantidad WHERE `idPersonas_vive`= idPersonas;
END IF;
#...
SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ActualizarEstadoHorasExtras` (IN `doc` VARCHAR(13), IN `fecha` VARCHAR(15), IN `des` VARCHAR(100), IN `id` INT, IN `hAcep` VARCHAR(8), IN `hRech` VARCHAR(8))  NO SQL
BEGIN

UPDATE h_laboral h SET h.Estado=1, h.descripcion=des, h.horas_aceptadas=hAcep, h.horas_rechazadas=hRech WHERE h.documento = doc AND DATE_FORMAT(h.fecha_laboral,'%d-%m-%Y')=fecha AND h.idEvento_laboral=2 AND h.idH_laboral=id;

SELECT 1 AS respuesta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_CalcularRegistrarHorasTrabajadas` (IN `doc` VARCHAR(13), IN `idHorario` TINYINT(1), IN `fechaAsitencia` VARCHAR(20), IN `accion` TINYINT(1))  NO SQL
BEGIN#pendiente por realizar revision de registros....
#Función para clasificar el tipo de evento de horas laborales "SE_FU_ClasificarEventoHorasTrabajadas" Por ahora no se va a implementar
#Preguntar si se redondea los tiempos más de horas normales trabajadas.
#...
DECLARE horaFinLaboral time;
DECLARE horasTrabajadas time;
DECLARE horasExtras time;
DECLARE tiempo time;
DECLARE estadoEvento tinyint(1);
#Validar que las horas laborales del dia en curso no esten registradas para poder hacer el calculo
IF !(EXISTS(SELECT * FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d'))) OR (accion=2) THEN # Acciones 1=Automatico 2=Manual

  #...
  SET horasTrabajadas=(SELECT a.tiempo FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(fechaAsitencia,'%d-%m-%Y') AND a.idTipo_evento=1);#Horas trabajadas sin substraerl los tiempos de descanso.
  
  #Aplica el desayuno?
  IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_desayuno > '00:00:00') THEN

    #Tiempo del desayuno
    SET tiempo=(SELECT a.tiempo FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(fechaAsitencia,'%d-%m-%Y') AND a.idTipo_evento=2);#tiempo del desayuno.

    #se resta el tiempo del desayuno.
    SET horasTrabajadas=(SUBTIME(horasTrabajadas,tiempo));

  END IF;

  #Aplica el almuerzo?
  IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_almuerzo > '00:00:00') THEN

    #Tiempo del almuerzo.
    SET tiempo=(SELECT a.tiempo FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(fechaAsitencia,'%d-%m-%Y') AND a.idTipo_evento=3);#Tiempo del almuerzo.

    #Se resta el tiempo del almuerzo y este es el tiempo total trabajado normal. (Normalmente se trabajan 9.5(09:30:00) horas diarias).
    SET horasTrabajadas=(SUBTIME(horasTrabajadas,tiempo));

  END IF;
  
  #...
  SET horaFinLaboral=(SELECT c.hora_salida_empresa FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
  #se tiene que validar que la hora del fin laboral de la persona sea mayor a la hora laboral extablecida para saber si se selecciona la hora fin del empleado o la hora establecida de la empresa.
  
  #...
  #Las horas totales trabajadas son mayores al total de horas laborales establecidos por día (9 horas y media por dia, por el momento. esto puede estar suceptible a cambios). 
  # Tiempo estipulado de labor diaria.
  SET tiempo=(SELECT SI_FU_TiempoPredeterminadoDeTrabajoDiario(idHorario));
  #...
  IF (horasTrabajadas)>(tiempo) THEN# si mi hora laboral es mayor que el horario establecido de la empresa se considera horas extrar. falta preguntar un rango de tiempo para considerar horas extras.#Valida la cantidad de horas extras 
    #...
    #Horas extras
    SET horasExtras=(SELECT TIMEDIFF(horasTrabajadas,tiempo));
    #...
      #Existen las horas normales para esta fecha ya registradas?
      IF EXISTS(SELECT * FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND h.idEvento_laboral=1) THEN # Actualizar

        UPDATE h_laboral h SET h.numero_horas=(SELECT SUBTIME(horasTrabajadas,horasExtras)), h.horas_aceptadas=(SELECT SUBTIME(horasTrabajadas,horasExtras)) WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND h.idEvento_laboral=1;
      
      ELSE #Registrar

        # Se ingresa esta información a la base de datos. Horas trabajadas normales. Clasificar recargo horas
        INSERT INTO `h_laboral`(`documento`, `idEvento_laboral`, `fecha_laboral`, `numero_horas`, `Estado`, `horas_aceptadas`, `horas_rechazadas`) VALUES (doc,1,fechaAsitencia,SUBTIME(horasTrabajadas,horasExtras),1,TIME_FORMAT(SUBTIME(horasTrabajadas,horasExtras),'%H:%i:%s'),'0');

      END IF;
      #...
      #Las horas trabajadas de la persona tienen que ser mayor a las horas totales trabajadas propuestas por la empresa.
      IF (horasTrabajadas > tiempo)  THEN
      #Se hace la diferencia de horas y el resultado tiene que ser mayor de 10 minutos para que cuente como horas extrar
      #...
      #Si las horas extra horario son mayores a 10 minutos se toma en cuenta las horas extra laborales.
        IF horasExtras>'00:10:00' THEN
        #Validar Existencia horas extras registradas.
          IF EXISTS(SELECT * FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND h.idEvento_laboral=2) THEN # Actualizar

            UPDATE h_laboral h SET h.numero_horas=(SELECT SE_FU_RedondiarTiempo(horasExtras)), h.horas_aceptadas=0, h.Estado=0,h.horas_rechazadas=0 WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND h.idEvento_laboral=2;

          ELSE#Registrar                                                                                                        
            
            # Se ingresa esta informacion a la base de datos. Horas Extras.
            INSERT INTO `h_laboral`(`documento`, `idEvento_laboral`, `fecha_laboral`, `numero_horas`, `Estado`) VALUES (doc,2,fechaAsitencia,(SELECT SE_FU_RedondiarTiempo(horasExtras)),0);

          END IF;

        ELSE # Eliminar Horas extras si es que existen

          DELETE FROM h_laboral  WHERE documento=doc AND fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND idEvento_laboral=2;

        END IF;
      END IF;
  #...
  ELSE
    #...Eliminar horas extras si es que tiene...

    IF EXISTS(SELECT * FROM h_laboral h WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND h.idEvento_laboral=1) THEN # Actualizar

      UPDATE h_laboral h SET h.numero_horas=horasTrabajadas, h.horas_aceptadas=horasTrabajadas WHERE h.documento=doc AND h.fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND h.idEvento_laboral=1;

    ELSE # Registrar

      #Consultar evento de horas laborales
      #Se ingresa esta informacion a la base de datos. Horas trebajadas normales.
      INSERT INTO `h_laboral`(`documento`, `idEvento_laboral`, `fecha_laboral`, `numero_horas`, `Estado`, `horas_aceptadas`, `horas_rechazadas`) VALUES (doc,1,DATE_FORMAT(fechaAsitencia,'%Y-%m-%d'),horasTrabajadas,1,horasTrabajadas,'0');

    END IF;
    
    #...Eliminar horas extras si es que tiene...
    DELETE FROM h_laboral  WHERE documento=doc AND fecha_laboral=DATE_FORMAT(fechaAsitencia,'%Y-%m-%d') AND idEvento_laboral=2;
    #...
  END IF;

END IF;
#...
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_CierreEventosAsistenciaOperarios` (IN `doc` VARCHAR(20), IN `evento` TINYINT(1), IN `lector` INT, IN `idHorario` INT, IN `accion` INT, IN `horaInicioEvento` VARCHAR(20), IN `horaFinEvento` VARCHAR(20))  NO SQL
BEGIN
#accion me sirve para saber si tengo en cuenta los 5 minutos o no para cerrar la toma de tiempo
#Este procedimiento solo va a funcionar con los eventos de desayuno y almuerzo.
#Desayuno=2 y Almuerzo=3
#
DECLARE estadoA tinyint(1);#estado del evento
DECLARE horaInicioEjecucionEvento varchar(20); #hora de inicio de algun evento
DECLARE horaFinEjecucionEvento varchar(20); #hora fin de algun evento
DECLARE tiempoEvento varchar(10);#Tiempo total del evento

#se consulta la hora de incio del evento de desayuno o almuerzo 
SET horaInicioEjecucionEvento = (SELECT a.inicio FROM asistencia a WHERE a.documento=doc AND (a.inicio BETWEEN horaInicioEvento AND horaFinEvento ) AND a.idTipo_evento=evento);
#...
#Para poder cerrar un evento(desayuno o almuerzo) tienen que haber transcurrido más de 5 minutos despues de la marcación de la asistencia del evento.
IF ( TIMEDIFF(now(), horaInicioEjecucionEvento) > '00:05:00' OR accion = 1 ) THEN
    
    #Se cierra la sistencia del evento
    UPDATE asistencia a SET a.fin = now() WHERE a.documento=doc AND a.idTipo_evento = evento AND (a.inicio BETWEEN horaInicioEvento AND horaFinEvento);
    
    #Se consulta la hora de fin del evento de (desayuno/almuerzo) 
    SET horaFinEjecucionEvento=(SELECT a.fin FROM asistencia a WHERE a.documento=doc AND (a.inicio BETWEEN horaInicioEvento AND horaFinEvento) AND a.idTipo_evento=evento);
    
    #Se clasifica el tipo de estado del evento.
    SET estadoA=(SELECT SI_FU_ClasificacionEstadoAsistencia(evento, horaInicioEjecucionEvento, horaFinEjecucionEvento, idHorario)); #Pendiente actualizar esta función

    #Clasificación del evento
    IF evento=2 THEN # Desayuno

      SET tiempoEvento = (SELECT c.tiempo_desayuno FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);

    ELSE # Almuerzo

      SET tiempoEvento = (SELECT c.tiempo_almuerzo FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);

    END IF;

    # El tiempo de la asistencia del evento (Desayuno/Almuerzo) es mayor al tiempo estimado para este?
    IF TIMEDIFF(horaFinEjecucionEvento, horaInicioEjecucionEvento) > tiempoEvento THEN
       
       #Tiempo que se gasto el empleado en este evento (Desayuno/Almuerzo)
       SET tiempoEvento = (SELECT TIMEDIFF(horaFinEjecucionEvento, horaInicioEjecucionEvento));

    END IF;


#se actualzia la asistencia del evento
UPDATE asistencia a SET a.idEstado_asistencia = estadoA, a.estado = 0, a.lectorF = lector, a.tiempo = tiempoEvento WHERE a.documento = doc AND a.idTipo_evento = evento AND (a.inicio BETWEEN horaInicioEvento AND horaFinEvento);

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ConsultarAsistenciaeventosDia` (IN `evento` INT)  NO SQL
BEGIN

SELECT e.documento, e.nombre1,e.nombre2,e.apellido1,e.apellido2,DATE_FORMAT(a.inicio, '%d-%m-%Y') AS fecha_inicio,DATE_FORMAT(a.inicio, '%d-%m-%Y') AS hora_inicio,a.lectorI,DATE_FORMAT(a.fin, '%d-%m-%Y') AS fecha_fin,DATE_FORMAT(a.fin, '%d-%m-%Y') AS hora_fin,a.lectorF,a.idEstado_asistencia,a.tiempo FROM asistencia a JOIN empleado e ON a.documento=e.documento WHERE DATE_FORMAT(a.inicio, '%Y-%m-%d')=CURDATE() AND a.idTipo_evento=evento;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ConsultarHorasDeTrabajo` (IN `doc` VARCHAR(13), IN `fecha` VARCHAR(25))  NO SQL
BEGIN

SELECT h.idEvento_laboral,h.numero_horas AS numero_horas, h.horas_aceptadas, h.horas_rechazadas,h.descripcion FROM h_laboral h WHERE h.documento=doc AND DATE_FORMAT(h.fecha_laboral,'%d-%m-%Y')=fecha AND h.Estado=1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ConsultarHorasExtrasAprobar` ()  NO SQL
BEGIN

SELECT h.idH_laboral,e.documento,e.nombre1,e.nombre2,e.apellido1,e.apellido2,em.nombre,DATE_FORMAT(h.fecha_laboral,'%d-%m-%Y') AS fecha_laboral,TIME_FORMAT(h.numero_horas, '%H:%i:%S') AS numero_horas FROM empresa em JOIN empleado e ON em.idEmpresa=e.idEmpresa JOIN h_laboral h ON e.documento=h.documento WHERE h.Estado=0 AND h.idEvento_laboral=2;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ConsultarTipoAlerta` (IN `documento` VARCHAR(20))  NO SQL
BEGIN

IF (SELECT ac.fin FROM asistencia ac WHERE ac.idTipo_evento = 1 AND DATE_FORMAT(ac.inicio, '%Y-%m-%d') = CURDATE() AND ac.documento = documento) IS null THEN
	#No existe la asistencia tipo laboral
	SELECT asi.idTipo_evento,asi.idEstado_asistencia,(SELECT IF(asi.fin IS null,0,1)) AS inicioFinEvento FROM asistencia asi WHERE asi.idAsistencia=(SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=documento AND DATE_FORMAT(a.inicio, '%Y-%m-%d') = CURDATE());
	#...
ELSE
	#Existe la asistencia de tipo laboral
	SELECT asi.idTipo_evento,asi.idEstado_asistencia,(SELECT IF(asi.fin IS null,0,1)) AS inicioFinEvento FROM asistencia asi WHERE asi.idAsistencia=(SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=documento AND a.idTipo_evento=1 AND DATE_FORMAT(a.inicio, '%Y-%m-%d') = CURDATE());
	#...
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_GeneradorDeAlertas` ()  NO SQL
BEGIN
DECLARE users tinyint;
#Consultar Cantidad de usuarios que llegaron tarde
SET users=(SELECT COUNT(*) FROM empleado e LEFT JOIN asistencia a ON e.documento=a.documento WHERE a.idTipo_evento=1 AND a.idEstado_asistencia=2 AND DATE_FORMAT(a.inicio,'%Y-%m%-d') = CURDATE());

#De cualquer alerta solo podra existir una diaria.
IF EXISTS(SELECT * FROM notificacion n WHERE DATE_FORMAT(n.fecha,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND n.idTipo_notificacion=4) THEN
#actualizarn
#Obtener el id del usuario al que va dirigido Reglamento del curriculo que se sigue cuando un operario llega tarde
UPDATE notificacion n  SET `comentario`=CONCAT('El dia de hoy ',users,' llego/aron tarde...'),`leido`=0 WHERE DATE_FORMAT(n.fecha,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND n.idTipo_notificacion=4;
ELSE
#Registrar
#Mensaje versatir dependiendo de la cantidad de usuarios
INSERT INTO `notificacion`(`fecha`, `comentario`, `leido`, `idUsuario`, `idTipo_notificacion`) VALUES (now(),CONCAT('El dia de hoy ',users,' llego/aron tarde...'),0,7,4);

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_GestionEventosAlmuerzoDesayuno` (IN `doc` INT, IN `lector` INT, IN `idHorario` INT, IN `fechaInicioAsistencia` VARCHAR(20), IN `fechaFinAsistencia` VARCHAR(20))  NO SQL
BEGIN
#SI_PA_ValidacionExistenciaEventosQueAplican -> Ya no existe
DECLARE respuesta tinyint(1);
DECLARE fechaInicioAsistencia_copia varchar(20);
DECLARE fechaFinAsistencia_copia varchar(20);

#Aplica el vento del desayuno?
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_desayuno > '00:00:00') THEN

	IF (SELECT SI_FU_ValidarHoraMayor(idHorario, 2)) = 1 THEN
	# Horario Nocturno

		SET fechaInicioAsistencia_copia = (SELECT CONCAT(fechaInicioAsistencia, ' ', c.hora_inicio_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);	
		SET fechaFinAsistencia_copia = (SELECT CONCAT(fechaFinAsistencia, ' ', c.hora_fin_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);	

	ELSE
	#Horario Diurna

		SET fechaInicioAsistencia_copia = (SELECT CONCAT(fechaFinAsistencia, ' ', c.hora_inicio_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);	
		SET fechaFinAsistencia_copia = (SELECT CONCAT(fechaFinAsistencia, ' ', c.hora_fin_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);	

	END IF;

  	IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND (a.inicio BETWEEN fechaInicioAsistencia_copia AND fechaFinAsistencia_copia)  AND a.fin is null AND a.idTipo_evento=2) THEN
  		#Existe el desayuno

  		#Valida si la asistencia se encuentra en ejecucion o ya termino
  		IF (SELECT COUNT(*) FROM (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento = doc AND (a.inicio BETWEEN fechaInicioAsistencia_copia AND fechaFinAsistencia) AND a.fin is null AND a.idTipo_evento = 2) AS avento) = 1 THEN
  		  
  	 		CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 2, lector, idHorario, 0, fechaInicioAsistencia_copia, fechaFinAsistencia_copia);#Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo Pendiente
  	  
  		END IF;
  
  	ELSE
  		IF !EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND (a.inicio BETWEEN fechaInicioAsistencia_copia AND fechaFinAsistencia_copia) AND a.idTipo_evento=2) THEN
  		
  			#No existe el evento del desayuno
  			CALL SI_PA_RegistroEventoAsistencia(doc, 2, lector, idHorario, fechaInicioAsistencia_copia, fechaFinAsistencia_copia);

  		END IF;

 	END IF;

END IF;

#Aplica el evento del almuerzo?
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_almuerzo > '00:00:00') THEN
   

	IF (SELECT SI_FU_ValidarHoraMayor(idHorario, 3)) = 1 THEN
	# Horario Nocturno

		SET fechaInicioAsistencia_copia = (SELECT CONCAT(fechaInicioAsistencia, ' ', c.hora_inicio_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);	
  		SET fechaFinAsistencia_copia = (SELECT CONCAT(fechaFinAsistencia, ' ', c.hora_fin_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);	

	ELSE
	#Horario Diurna

		SET fechaInicioAsistencia_copia = (SELECT CONCAT(fechaFinAsistencia, ' ', c.hora_inicio_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);	
		SET fechaFinAsistencia_copia = (SELECT CONCAT(fechaFinAsistencia, ' ', c.hora_fin_almuerzo) FROM configuracion c WHERE c.idConfiguracion = idHorario);	

	END IF;

  	IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND (a.inicio BETWEEN fechaInicioAsistencia_copia AND fechaFinAsistencia_copia) AND a.fin is null AND a.idTipo_evento = 3) THEN
  		#Existe el almuerzo

  		#Valida si la asistencia se encuentra en ejecucion o ya termino
  		IF (SELECT COUNT(*) FROM (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento = doc AND (a.inicio BETWEEN fechaInicioAsistencia_copia AND fechaFinAsistencia) AND a.fin is null AND a.idTipo_evento = 3) AS avento) = 1 THEN
    
    		CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 3, lector, idHorario, 0, fechaInicioAsistencia_copia, fechaFinAsistencia_copia);#Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo Pendiente
    
  		END IF;
  
	ELSE

  		IF !EXISTS(SELECT * FROM asistencia a WHERE a.documento = doc AND (a.inicio BETWEEN fechaInicioAsistencia_copia AND fechaFinAsistencia_copia) AND a.idTipo_evento = 3) THEN

  			#No existe el evento del almuerzo
  			CALL SI_PA_RegistroEventoAsistencia(doc, 3, lector, idHorario, fechaInicioAsistencia_copia, fechaFinAsistencia_copia);

		END IF;

  	END IF;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ProcedimientoEventosNoAsistidos` (IN `doc` INT, IN `lector` TINYINT(2), IN `idHorario` TINYINT(2), IN `evento` TINYINT(1), IN `fechaInicio` VARCHAR(10), IN `fechaFin` VARCHAR(10))  NO SQL
BEGIN

DECLARE horaF time;#Hora de fin del evento (Desayuno/Almuerzo)
DECLARE respuesta int;
DECLARE tiempoEvento varchar(8);

  #Se consulta de fin del evento (Desayuno/Almuerzo)
  IF evento = 2 THEN
  #Desayuno
  	SET horaF=(SELECT c.hora_fin_desayuno FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
  ELSE
  #Almuerzo
  	SET horaF=(SELECT c.hora_fin_almuerzo FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
  END IF;

  #...
  #la hora del sistema es mayor que la hora final del evento (Desayuno/Almuerzo)
  IF now() > horaF THEN
  
    IF !EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.inicio,'%Y-%m-%d') =CURDATE() AND DATE_FORMAT(a.fin,'%Y-%m-%d') = CURDATE() AND a.idTipo_evento=evento) THEN
    
    # se valida si existe una asistencia abierta. 
      IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.inicio,'%Y-%m-%d') = CURDATE() AND a.fin IS null AND a.idTipo_evento=evento) THEN
      
        #se actualiza el evento (Desayuno/Almuerzo)
        UPDATE asistencia a SET a.fin = now(), a.idEstado_asistencia = 2, a.estado = 0, a.lectorF = lector WHERE a.documento = doc AND a.idTipo_evento = evento AND DATE_FORMAT(a.inicio,'%Y-%m-%d') = CURDATE();
        
        #Se calculara el tiempo que corresponde al evento (Desayuno/Almuerzo).
        SET respuesta=(SELECT SI_FU_ClasificarElTiempoCorrecto(doc, evento));
        
      ELSE
        #se registra el evento (Desayuno/Almuerzo)
        IF evento = 2 THEN
  		#Desayuno
        	SET tiempoEvento = (SELECT c.tiempo_desayuno FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
        ELSE
        #Almuerzo
        	SET tiempoEvento = (SELECT c.tiempo_almuerzo FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
        END IF;
        
        #No asistio al evento
        INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `inicio`, `fin`,`idEstado_asistencia`, `estado`, `lectorF`, `tiempo`,`idConfiguracion`) VALUES (doc, evento, now(), now(), 3, 0, 0, tiempoEvento, idHorario);
      END IF;
    END IF;
  END IF;
  #  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_RegistrarAsistencia` (IN `huella` INT, IN `lector` INT)  NO SQL
BEGIN#Global
#El evento de desayuno o almuerzo se cerraran cuando se vuelva a colocar la huella 5 minutos despues te la domo inicial.
#Los tiempos de los eventos no se pueden cambir mientras alguna persona este en ejecucion de algune evento.
#El sistema generara alerta de las personas que lleguen tarde del cualquier evento(Laboral, Desayuno o almuerzo). (El evento laboral ya lo genera)
#El sistema cerrar automaticamente las asistencias que pasen el tiempo de cada evento(Laboral, Desayuno o Almuerzo)
#Por el momento no se va a tener en cuenta los permisos.
#Falta implementar la toma de tiempo cuando hay un permiso (Existen dos tipos de permiso, uno de ingreso tarde y otro de salida temprano).
#Validar que si no sale al desayuno le tome en cuenta el siguiente enveto (de desayuno tome almuerzo o del almuerzo tome la salida).
DECLARE doc varchar(13);
DECLARE estadoA tinyint(1);
DECLARE horaI time; #hora de inicio de algun event
DECLARE horaF time; #hora fin de algun evento
DECLARE horaD time;#Hora de inicio del evento Desayuno o almuerzo
DECLARE tiempo varchar(10); #Tiempo total laborado el día de hoy. 
#Buscamos el documendo de la perzona a la cual pertenece la huella (rol =1 =Operario), (estado=1=activado), huellas... 
SET doc=(SELECT e.documento FROM empleado e WHERE e.huella1=huella OR e.huella2=huella OR e.huella3=huella AND e.estado=1 AND e.idRol=1);
#preguntamos si existe alguien con esa huella, si existe alguien con la huella que inserte el registro, si no no va a realizar la inserción.

#Condicional de documento.------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------7
IF doc!='' THEN
   #se valida que la en el día no tenga más de un evento laboral, si lo tiene no se puede volver a registrar el dia actual otro evento de esos.-----------------------------------------------------------------------------------------------------------------8
   IF !EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=1 AND DATE_FORMAT(a.fecha_fin,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y'))  THEN
   #validamos si existe una asistenca de tipo laboral---------------------------------------------------------------------------------------------------------------------------------------------------------------6
      IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.fecha_fin is null AND a.hora_fin is null AND a.idTipo_evento=1) THEN 
       #Validacion de cuantos eventos tiene en un dia de evento normal.-------------------------------------------------------------------------------------------------------------------------5
	   #validamos la existencia de los eventos que no se lograron asistir y se generan.    
	   CALL SI_PA_ValidacionEventosNoAsistidos(doc, lector);
	     IF (SELECT COUNT(*) FROM asistencia a WHERE (a.idTipo_evento=2 OR a.idTipo_evento=3) AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.hora_fin is NOT null)=2 THEN #Por lo general puede tener dos eventos cuando trabaja un dia completo pero tambien hay que tener en cuenta que puede tener menos.
              #Validacion de que el ultimo evento de descanso(Almuerzo) tenga menos de 10 minutos más del evento del almeurzo.
			   SET horaI=(SELECT c.hora_fin_almuerzo FROM configuracion c WHERE c.estado=1 LIMIT 1);
			   SET horaF=(SELECT a.hora_fin FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=3);
			   #...
			   #
			   #TIMEDIFF(TIME_FORMAT(now(),'%H:%i:%s'),horaF)>'00:10:00' //valida que el tiempo final del evento del almuerzo sea mayor a 10 minutos para poder realizar el cierre.
			   IF  (TIMEDIFF(TIME_FORMAT(now(),'%H:%i:%s'),horaI)>'00:10:00')=1  THEN # Si termine de almorzar despues del horario del evento y han pasado más de 10 minutos, entonces procedo a cerrar el evento laboral.
			   		   #...
		              #cierra el evento de asistencia Laboral!!!
			          #...
					  select 1;
			          #
 	                  UPDATE asistencia a SET a.fecha_fin=now(), a.hora_fin=now(), a.lectorF=lector, a.estado=0, a.tiempo=tiempo WHERE a.documento=doc AND a.idTipo_evento=1 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
                      #acutualizar el estado del empleado en la empresa a 0=ausente
		              UPDATE empleado e SET e.asistencia=0 WHERE e.documento=doc;
			          #
			          #
                      SET horaI=(SELECT a.hora_inicio FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=1);
                      SET horaF=(SELECT a.hora_fin FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=1);
                      #
			          SET tiempo= (SELECT TIMEDIFF(horaF,horaI));
			          #select tiempo;
			          #
                      UPDATE asistencia a SET a.tiempo=tiempo WHERE a.documento=doc AND a.idTipo_evento=1 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
                      #...
			            CALL SI_PA_CalcularRegistrarHorasTrabajadas(doc,horaF);
                      #...
			   END IF;
			   #...
         ELSE
            #valida las otras asistencia (Desayuno y almuerzo)
            #validamos si tiene alguna asistencia de Desayuno--------------------------------------------------------------------------------------------------------------------------------4
             IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=2) THEN 
                   # Valida si cierra la toma de tiempo o busca la siguiente asistencia---------------------------------------------------------------------------------------------3
                  IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.fecha_fin is null AND a.hora_fin is null AND a.idTipo_evento=2) THEN 
                       # cierra la toma de tiempo  Desayuno!!!
 	                   #  
			           #Cierre del evento  de desayuno
			  	       #...
			  		      CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 2, lector);
                      #...
                   ELSE 
   	                  #Se valida si tiene alguna asistencia del evento de Almuerzo--------------------------------------------2
                     IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.fecha_fin is null AND a.hora_fin is null AND a.idTipo_evento=3) THEN 
   		                 #
			             #Cierra la toma de tiempo  Almuerzo!!!
                         #...
			  	            CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 3, lector);
                         #...
                     ELSE
                         #...
			  	         #Asistencia de tipo evento Almuerzo---------1 
			 			      CALL SI_PA_RegistroEventoAsistencia(doc, 3, lector);
			  	         #/Asistencia de tipo evento Almuerzo----------1
                         #...
                     END IF;
			      #//Se valida si tiene alguna asistencia del evento de Almuerzo fin---------------------------------------2
             END IF;
             # //Valida si cierra la toma de tiempo o busca la siguiente asistencia fin---------------------------------------------------------------------------------3
             ELSE
              #... 
              #asistencia de tipo evento Desayuno
	              CALL SI_PA_RegistroEventoAsistencia(doc, 2 , lector);
	          #asistencia de tipo evento Desayuno
              #...	 
            END IF;
        #validamos si tiene alguna asistencia de Desayuno---------------------------------------------------------------------------------------------------------------------------------4
       END IF;
 #Validacion de cuantos eventos tiene en un dia de evento normal.-------------------------------------------------------------------------------------------------------------------------5    
ELSE 
        #Asistencia de tipo evento Laboral<<<<<
        INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `fecha_inicio`, `hora_inicio`, `fecha_fin`, `hora_fin`,`idEstado_asistencia`, `estado`, `lectorI`) VALUES (doc,1,now(),now(),null,null,1,1,lector);
        UPDATE empleado e SET e.asistencia=1 WHERE e.documento=doc;#acutualizar el estado del empleado en la empresa 1=Presente
        #Clasificaion del tipo de estado de la asistencia
        SET horaI=(SELECT a.hora_inicio FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=1);
        SET horaF='00:01:00';#no la va a tomar en cuenta
        SET estadoA=(SELECT SI_FU_ClasificacionEstadoAsistencia(1,horaI,horaF));#Estado de la asistencia para el igreso laboral
	    #...
		#Actualizar el estado del operario que registro la asistencia laboral.
	    UPDATE asistencia a SET a.idEstado_asistencia= estadoA  WHERE a.documento=doc AND a.idTipo_evento=1 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
	    #
		IF estadoA=2 THEN
	        CALL SI_PA_GeneradorDeAlertas();
	    END IF;
		#
	  END IF; 
       #validamos si existe una asistenca de tipo laboral fin---------------------------------------------------------------------------------------------------------------------------------------------------------------6
   END IF;# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------8
END IF;
#Condicional de documento.--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------7
      	  #Retornar el numero de documento de la persona perteneciente a la huella dactilar.
		 SELECT doc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_RegistrarAsistenciaContraseña` (IN `contra` VARCHAR(20), IN `lector` INT, IN `idHorario` TINYINT(2))  NO SQL
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
SET doc=(SELECT e.documento FROM empleado e WHERE e.contraseña COLLATE utf8_bin=contra AND e.estado=1 AND e.idRol=1);
#preguntamos si existe alguien con esa huella, si existe alguien con la huella que inserte el registro, si no no va a realizar la inserción.
#Pendiente por catualizar esta forma de contar las asistencias.
SET multiplesEventos = (SELECT SI_FU_ArreglarProblemaBugAsistenciaMultiplesEventos(doc));#->Se encarga de eliminar los registros duplicados del mismo evento (Desayuno, Almuerzo o laboral) en dado caso de que existan.
#Condicional de documento.------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------7
#Validar si dejo una asistencias abierta, si es así entonce se va a cerrar y liquidar por defecto a la hora de salida del horario laboral.
IF doc!='' THEN

  #se valida que la en el día no tenga más de un evento laboral, si lo tiene no se puede volver a registrar el dia actual otro evento de esos.-----------------------------------------------------------------------------------------------------------------8
  SET permiso=(SELECT SE_FU_ValidacionPermisosEmpleadosAsistencia(doc, idHorario));#Validacion de existencia de permiso para el día de hoy.
  
  IF permiso=-1 or permiso=2 THEN # Va a continuar con la toma de los eventos normalmente

    #... en vez de validar la fecha, validamos la ultima asistencia junto al intervalo de hora del horario

    #IF EXISTS(SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.fecha_fin IS NOT null AND a.fecha_inicio IS NOT null AND a.fecha_inicio = CURDATE() OR a.fecha_inicio = SUBDATE(CURDATE(), INTERVAL 1 DAY))  THEN
    IF ((SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.fin IS NOT null AND a.inicio IS NOT null AND TIME_FORMAT(TIMEDIFF(now(), a.fin),'%H:%i:%s') <= '08:00:00') is not null) = 0  THEN
    
      #validamos si existe una asistenca de tipo laboral---------------------------------------------------------------------------------------------------------------------------------------------------------------6
      IF ((SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.inicio is not null AND a.fin IS null) is not null) = 1 THEN 
        #Validacion de cuantos eventos tiene en un dia de evento normal.-------------------------------------------------------------------------------------------------------------------------5
        
        SET idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.inicio is not null AND a.fin is null AND a.fin IS null);
        SET idHorario = (SELECT a.idConfiguracion FROM asistencia a WHERE a.idAsistencia=idAsistencia);

        #validar si el horario que tiene el empleado es diurna o nocturno. ->(La hora de inicio laboral es mayor a la hora de fin laboral)
        IF (SELECT c.hora_ingreso_empresa FROM configuracion c WHERE c.idConfiguracion = idHorario) >= (SELECT c.hora_salida_empresa FROM configuracion c WHERE c.idConfiguracion = idHorario) THEN
        #Horario Nocturno

          SET fecha_fin_asistencia = (SELECT DATE_ADD(a.inicio, INTERVAL 1 DAY) FROM asistencia a WHERE a.idAsistencia = idAsistencia);

        ELSE
        #Horario Diurna.

          SET fecha_fin_asistencia = (SELECT DATE_FORMAT(a.inicio, '%Y-%m-%d') FROM asistencia a WHERE a.idAsistencia = idAsistencia);
        -- #Validacion la cantidad de eventos disponibles en el día...
        -- SET cantidad_eventos_que_aplican = (SELECT SI_FU_CantidadEventosQueAplicanHorario(idHorario));

        END IF;

        #Validacion la cantidad de eventos disponibles en el día...
        SET cantidad_eventos_que_aplican = (SELECT SI_FU_CantidadEventosQueAplicanHorario(idHorario));

        SET fecha_inicio_asistencia = (SELECT DATE_FORMAT(a.inicio, '%Y-%m-%d') FROM asistencia a WHERE a.idAsistencia = idAsistencia);

        #validamos la existencia de los eventos que no se lograron asistir y se generan con un estado de no asistio.
        #CALL SI_PA_ValidacionEventosNoAsistidos(doc, lector, idHorario, fecha_inicio_asistencia, fecha_fin_asistencia); # Pendiente actualizar

        #Valida que la cantidad de eventos que se programaron en el horario si se cumplan con la cantidad de eventos que se activaron.
        IF (SELECT COUNT(*) FROM (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE (a.idTipo_evento = 2 OR a.idTipo_evento = 3) AND a.documento=doc AND (DATE_FORMAT(a.inicio, '%Y-%m-%d') BETWEEN fecha_inicio_asistencia AND fecha_fin_asistencia) AND a.fin is NOT null GROUP BY a.idTipo_evento) AS idEventos) = cantidad_eventos_que_aplican THEN

         -- IF  (SELECT SI_FU_ValidacionCierreAsistencia(idHorario)) = 1  THEN # Si se puede cerrar la asistencia? # Actualizar -> pendiente
             #...
             #La hora del sistema tiene que ser 05 minutos igual o mayor a la diferencia del tiempo actual con el de la ultima asistencia.
            IF ((SELECT TIME_FORMAT(TIMEDIFF(now(), asi.fin), '%H:%i:%s') FROM asistencia asi WHERE asi.idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.inicio is not null AND a.fin is not null)) >= '00:05:00') or (SELECT SI_FU_ValidacionCierreAsistencia(idHorario)) = 1 THEN ## La funcion puede ir o no

              #cierra el evento de asistencia Laboral!!!
              UPDATE asistencia a SET a.fin = now(), a.lectorF = lector, a.estado = 0 WHERE a.documento = doc AND a.idAsistencia = idAsistencia AND a.idConfiguracion = idHorario;
              
              #acutualizar el estado del empleado en la empresa a 0=ausente
              UPDATE empleado e SET e.asistencia=0 WHERE e.documento=doc;

              SET horaInicioEvento = (SELECT a.inicio FROM asistencia a WHERE a.idAsistencia = idAsistencia);
              SET horaFinEvento = (SELECT a.fin FROM asistencia a WHERE a.idAsistencia = idAsistencia);
              # ...
              SET tiempo = (SELECT TIMEDIFF(horaFinEvento, horaInicioEvento));
              # ...
              UPDATE asistencia a SET a.tiempo = tiempo WHERE a.idAsistencia = idAsistencia;
              # ...
              CALL SI_PA_CalcularRegistrarHorasTrabajadas(doc, idHorario, now(), 1);# Actualizar -> Pendiente
              #...

             END IF;
         -- END IF;
        ELSE    

          #valida lo otros eventos de la asistencia (Desayuno y almuerzo)
          CALL SI_PA_GestionEventosAlmuerzoDesayuno(doc, lector, idHorario, fecha_inicio_asistencia, fecha_fin_asistencia);# Actualizar -> Pendiente

        END IF;

      #Validacion de cuantos eventos tiene en un dia de evento normal.-------------------------------------------------------------------------------------------------------------------------5    
      ELSE

        SET horaInicioEvento = (SELECT CONCAT(CURDATE(), ' ', c.hora_ingreso_empresa) FROM configuracion c WHERE c.estado = 1 AND c.idConfiguracion = idHorario LIMIT 1);

        # Validar que solo permita el ingreso a las personas 15 minutos antes de su horario laboral
        IF (TIMEDIFF(horaInicioEvento, now()) <= '00:15:00') OR (TIMEDIFF(horaInicioEvento, now()) <= '00:00:00') THEN
        #...
        
          #Asistencia de tipo evento Laboral
          INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `inicio`, `fin`, `idEstado_asistencia`, `estado`, `lectorI`,`idConfiguracion`) VALUES (doc, 1, now(), null, 1, 1, lector, idHorario);
          
          UPDATE empleado e SET e.asistencia=1 WHERE e.documento=doc;#acutualizar el estado del empleado en la empresa 1=Presente
       
          #Clasificaion del tipo de estado de la asistencia
          SET idAsistencia = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND a.idTipo_evento=1 AND a.inicio is not null AND a.fin is null);
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

    # Esto esta pendiente por actualizar...
    /* Validar si la persona tiene un evento abierto, si es asi cerrar el evento, si no pues no hacer nada*/
    -- SET fecha_inicio_asistencia = (SELECT CONCAT(fechaInicioAsistencia, ' ', c.hora_inicio_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario); 
    -- SET fechaFinAsistencia = (SELECT CONCAT(fechaInicioAsistencia, ' ', c.hora_fin_desayuno) FROM configuracion c WHERE c.idConfiguracion = idHorario);

    -- IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND (a.inicio BETWEEN fechaInicioAsistencia AND fechaFinAsistencia) AND a.fin is NOT null AND a.idTipo_evento=3) THEN

    -- END IF;

    #Cerrar evento de desayuno
    CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 2, lector, idHorario, 1);#Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo Pendiente

    #Cerrar evento de Almuerzo
    CALL SI_PA_CierreEventosAsistenciaOperarios(doc, 3, lector, idHorario, 1);#Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo. Pendiente

    #...
    SET doc = permiso;

  END IF;

#....
END IF;
#Condicional de documento.--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------7
    #Retornar el numero de documento de la persona perteneciente a la huella dactilar.
    SELECT doc AS documento;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_RegistroEventoAsistencia` (IN `doc` INT, IN `evento` INT, IN `lector` INT, IN `idHorario` INT, IN `fechaInicioEvento` VARCHAR(20), IN `fechaFinEvento` VARCHAR(20))  NO SQL
BEGIN

  IF (now() BETWEEN fechaInicioEvento AND fechaFinEvento) THEN
    #
    INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `inicio`, `fin`, `idEstado_asistencia`, `estado`, `lectorI`,`idConfiguracion`) VALUES (doc, evento, now(), null, 1, 1, lector, idHorario);
    #
  END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_TotalHorasTrabajasEmpleado` (IN `doc` VARCHAR(20), IN `fecha` VARCHAR(25))  NO SQL
BEGIN

IF fecha!='' THEN
#
SELECT a.idAsistencia,a.idTipo_evento,TIMEDIFF(a.fin, a.inicio) AS horas FROM asistencia a WHERE DATE_FORMAT(a.inicio,'%d-%m-%Y')=fecha AND  DATE_FORMAT(a.fin,'%d-%m-%Y')=fecha AND a.documento=doc;
#
ELSE
#
SELECT a.idAsistencia,a.idTipo_evento,TIMEDIFF(a.fin, a.inicio) AS horas FROM asistencia a WHERE DATE_FORMAT(a.inicio,'%Y-%m-%d')=CURDATE() AND  DATE_FORMAT(a.fin,'%Y-%m-%d')=CURDATE() AND a.documento=doc;
#
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SI_PA_ValidacionEventosNoAsistidos` (IN `doc` VARCHAR(20), IN `lector` TINYINT, IN `idHorario` TINYINT(1), IN `fechaInicio` VARCHAR(10), IN `fechaFin` VARCHAR(10))  NO SQL
BEGIN
#
DECLARE horaF time;#Hora de fin del evento (Desayuno/Almuerzo)
DECLARE respuesta int;
#
#Aplica el Desayuno
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_desayuno > '00:00:00') THEN

  CALL SI_PA_ProcedimientoEventosNoAsistidos(doc, lector, idHorario, 2);
	
END IF;

#Aplica el Almuerzo
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_almuerzo > '00:00:00') THEN

  CALL SI_PA_ProcedimientoEventosNoAsistidos(doc, lector, idHorario, 3);


END IF;


END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `SA_FU_CantidadDiasASumar` () RETURNS TINYINT(1) NO SQL
BEGIN

#horas del pedido.
DECLARE horaI time;
DECLARE horaF time;
#cantidad de dias a sumar
DECLARE dias tinyint(1);
#setear variables
#Hora de inicio de pedidos hoy
SET horaI=(SELECT r.hora_inicio_pedidos FROM restriccion r WHERE r.idRestriccion=1);
#Hora de fin de pedidos hoy
SET horaF=(SELECT r.hora_fin_pedidos FROM restriccion r WHERE r.idRestriccion=1);
###################
IF (SELECT now() BETWEEN horaI AND horaF) THEN
#se valida el pedido de hoy.
 SET dias=0;#La cantidad de dias a sumar.
ELSE
#se valida el pedido de mañana.
 SET dias=1;# la cantidad de dias a sumar.
END IF;

RETURN dias;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SA_FU_ValidarRestriccionTiempo` () RETURNS TINYINT(1) NO SQL
BEGIN
DECLARE horaI time;
DECLARE horaF time;
DECLARE horaA time;
#Hora de inicio de pedidos
SET horaI=(SELECT r.hora_inicio_pedidos FROM restriccion r WHERE r.idRestriccion=1);
#Hora de fin de pedidos
SET horaF=(SELECT r.hora_fin_pedidos FROM restriccion r WHERE r.idRestriccion=1);
#hora actual del pedido
SET horaA=(SELECT now());
#SELECT horaI, horaA, horaF;
#validacion
IF (horaA>=horaI AND horaA<=horaF) THEN
#se puede gestionar el pedido
RETURN true;

ELSE
#No se puede gestionar los pedidos
RETURN false;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_CalcularNumeroHorasPermisoEmpleados` (`doc` VARCHAR(13), `idHorario` TINYINT(1), `tipoP` TINYINT(1), `desde` VARCHAR(10)) RETURNS TINYINT(1) NO SQL
BEGIN

DECLARE horaFlaboral varchar(10);
DECLARE horaIlaboral varchar(10);
DECLARE resultado varchar(10);
DECLARE idPermiso int;
#...
SET idPermiso=(SELECT p.idPermiso FROM permiso p WHERE p.fecha_permiso=CURDATE() AND p.documento=doc AND p.idHorario_permiso=tipoP LIMIT 1);
#...
IF tipoP=1 THEN#Salida temprano
#Hora de salida de la empresa...
SET horaFlaboral=(SELECT c.hora_salida_empresa FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
#...
#Preguntar si ha este resultado se le restan las horas del almuerzo y desayuno. dependiendo del evento que no se haya presentado.
SET resultado=(SELECT TIMEDIFF(horaFlaboral,desde));
#Actualizar numero de horas del permiso del empleado.
UPDATE permiso p SET p.numero_horas=resultado,p.hasta=horaFlaboral,p.estado=3 WHERE p.idPermiso=idPermiso;
#...
#SELECT resultado AS diferencia;
RETURN 1;
#...
ELSE
	#...
	IF tipoP=2 THEN#Legada tarde
    
      SET horaIlaboral= (SELECT c.hora_ingreso_empresa FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1);
    
      SET resultado=(SELECT TIMEDIFF(DATE_FORMAT(now(),'%H:%i:%S'),horaIlaboral));
      #Actualizar numero de horas del permiso del empleado.
      UPDATE permiso p SET p.numero_horas=resultado,p.hasta=DATE_FORMAT(now(),'%H:%i:%S'),p.desde=horaIlaboral,p.estado=3 WHERE p.idPermiso=idPermiso;
      #...
      #SELECT resultado AS diferencia;
      RETURN 2;
    #...
    ELSE
    #...
    	IF tipoP=3 THEN#Salida y Llegada Pendiente por el desarrollo
        #...
          SET horaIlaboral= (SELECT p.desde FROM permiso p WHERE p.documento=doc AND p.fecha_permiso=CURDATE() AND p.idHorario_permiso=3);#Hora desde que salio del permiso
          SET resultado=(SELECT TIMEDIFF(desde,horaIlaboral));
          #Desde= Hasta
          #horaILaboral=Desde
          #Actualizar numero de horas del permiso del empleado.
          UPDATE permiso p SET p.numero_horas=resultado,p.hasta=desde,p.estado=3 WHERE p.idPermiso=idPermiso;
        #...
        #SELECT 3;
        RETURN 3;
        
        END IF;
        #...
    END IF;
	#...
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_CambiarEstadoPermisoEmpleado` (`idP` INT, `estado` TINYINT(1), `idUser` INT) RETURNS TINYINT(1) NO SQL
BEGIN

UPDATE permiso p SET p.estado=estado,p.idUsuario=idUser WHERE p.idPermiso=idP;

RETURN 1;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_ClasificarEventoHorasTrabajadas` (`hora` VARCHAR(20), `tiempo` VARCHAR(10), `tipoR` INT) RETURNS TINYINT(1) NO SQL
BEGIN

IF tipoR=1 THEN#Regargo de horas normales, recargo nocturno o recargo festivo 

  IF EXISTS(SELECT * FROM dias_festivos d WHERE d.fecha_dia=DATE_FORMAT(hora,'%Y-%m-%d')) || (SELECT DAYOFWEEK(DATE_FORMAT(hora,'%Y-%m-%d'))=1)  THEN #Validar si esta fecha es un día festivo o domingo(Pendiente domingo)
  	RETURN 6; #Recargo Festivo
  ELSE#No es un día festivo
  	IF DATE_FORMAT(hora,'%H:%i:%S')>'22:00:00' OR DATE_FORMAT(hora,'%H:%i:%S')<'06:00:00' THEN #Es recargo nocturno si las horas sobrepasan las 10 de la noche, Pendiente realizarlo correctamente
    	RETURN 5;
    ELSE
    	RETURN 1;
    END IF;
  END IF;
ELSE#Recargo de horas extras diurna, horas extras nocturna, horas extra festivas

	IF EXISTS(SELECT * FROM dias_festivos d WHERE d.fecha_dia=DATE_FORMAT(hora,'%Y-%m-%d')) || (SELECT DAYOFWEEK(DATE_FORMAT(hora,'%Y-%m-%d'))=1) THEN#Validar si esta fecha es un día festivo o domingo
    	RETURN 7;
    ELSE
    
    	RETURN 0; #Pendiente las horas extras
    
    END IF;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_ContarDíasDeTrabajo` (`fechaI` VARCHAR(10), `fechaF` VARCHAR(10)) RETURNS INT(11) NO SQL
BEGIN
DECLARE cant int;
DECLARE cantFestivos int;
DECLARE cantDomingos int;
#DECLARE cantFestivosTrabajados int;

IF fechaI!='' AND fechaF='' THEN
#Retorna unicamente 1
RETURN 1;
ELSE
#retorna la cantidad de días que hay en cada fecha
SET cant= (SELECT TIMESTAMPDIFF(DAY, fechaI,fechaF));
#
#Restar Días festivos
SET cantFestivos=(SELECT COUNT(*) FROM dias_festivos d WHERE (d.fecha_dia BETWEEN fechaI AND fechaF) AND d.estado=1);
#...
SET cant=(cant-cantFestivos);
#
#Contar cantidad de domingos
SET @DiaSemana     = 7; -- 7 domingo, 1 lunes
SET @Minimo        = CASE WHEN DAYOFWEEK(fechaI)-1 = 0 THEN 7 ELSE DAYOFWEEK(fechaI)-1 END;
#
SET cantDomingos=(SELECT datediff(fechaF, fechaI) DIV 7 + (CASE WHEN @Minimo = @DiaSemana THEN 1 ELSE 0 END));
#...
SET cant=(cant-cantDomingos);
#...
#Consultar Si el empleado trabajo un día festivo...Pendiente por realizar el teorico.
#SET cantFestivosTrabajados=(SELECT COUNT(*) FROM asistencia a WHERE (a.fecha_inicio BETWEEN fechaI AND fechaF) AND a.fecha_inicio in(SELECT d.fecha_dia FROM dias_festivos d WHERE (d.fecha_dia BETWEEN fechaI AND fechaF) AND d.estado=1) AND a.idTipo_evento=1);
#Consultar cuantos domingos se trabajaron.

RETURN CANT;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_LectorPisoAsistencia` (`ip` VARCHAR(15)) RETURNS VARCHAR(2) CHARSET latin1 NO SQL
BEGIN
DECLARE piso varchar(2);

IF EXISTS(SELECT * FROM tablet_piso t WHERE t.direccion=ip) THEN
#Seleccion piso de la direccion ip
SET piso=(SELECT t.piso FROM tablet_piso t WHERE t.direccion=ip LIMIT 1);
#...
RETURN piso;
#...
ELSE
#...retorna el piso 0 por defecto
RETURN '0';
#...
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_ModificarAsistencaEmpleado` (`ida` INT, `horaInicio` VARCHAR(20), `horaFin` VARCHAR(20), `evento` TINYINT(1)) RETURNS TINYINT(1) NO SQL
BEGIN
#DECLARE tiempoT varchar(8);
DECLARE tiempoEvento varchar(8);
DECLARE estadoA tinyint(1);

#Clasificar estado
SET estadoA=(SELECT SI_FU_ClasificacionEstadoAsistencia(evento,(SELECT DATE_FORMAT(horaInicio,'%H:%i:%S')),(SELECT DATE_FORMAT(horaFin,'%H:%i:%S')),(SELECT a.idConfiguracion FROM asistencia a WHERE a.idAsistencia=ida LIMIT 1)));#Tiene que hacer obligatoriamente la modificacion por diferencia de fechas completas no solo por horas.

IF horaInicio!='' AND horaFin!='' THEN

IF evento=2 or evento=3 THEN#Desayuno o almuerzo
  #...
  IF evento=2 THEN #Desayuno
   SET tiempoEvento=(SELECT c.tiempo_desayuno FROM configuracion c WHERE c.idConfiguracion=(SELECT a.idConfiguracion FROM asistencia a WHERE a.idAsistencia=ida LIMIT 1) AND c.estado=1 LIMIT 1);
  ELSE #Almuerzo
  	SET tiempoEvento=(SELECT c.tiempo_almuerzo FROM configuracion c WHERE c.idConfiguracion=(SELECT a.idConfiguracion FROM asistencia a WHERE a.idAsistencia=ida LIMIT 1) AND c.estado=1 LIMIT 1);
  END IF;
  #...
  IF TIMEDIFF(horaFin,horaInicio)>tiempoEvento THEN
     #Tiempo que se gasto el empleado en este evento de desayuno
     SET tiempoEvento=(SELECT TIMEDIFF(horaFin,horaInicio)); #Esto se tiene que hacer con las fechas de los días en que se realizo la toma de tiempo
  END IF;
ELSE#Evento laboral
 #Realiza la diferencia de tiempo.
 SET tiempoEvento= (SELECT TIMEDIFF(horaFin,horaInicio));
END IF;
#...
UPDATE asistencia a SET a.hora_inicio=(SELECT DATE_FORMAT(horaInicio,'%H:%i:%S')), a.hora_fin=(SELECT DATE_FORMAT(horaFin,'%H:%i:%S')), a.fecha_inicio=(SELECT DATE_FORMAT(horaInicio,'%Y-%m-%d')), a.fecha_fin= (SELECT DATE_FORMAT(horaFin,'%Y-%m-%d')), a.tiempo=tiempoEvento,a.idEstado_asistencia=estadoA WHERE a.idAsistencia=ida AND a.idTipo_evento=evento;
#...
ELSE
#No realiza la diferencia de tiempo.
UPDATE asistencia a SET a.hora_inicio=(SELECT DATE_FORMAT(horaInicio,'%H:%i:%S')), a.fecha_inicio=(SELECT DATE_FORMAT(horaInicio,'%Y-%m-%d')),a.fecha_fin=null,a.hora_fin=null,a.tiempo=null,a.lectorF=null,a.idEstado_asistencia=estadoA WHERE a.idAsistencia=ida AND a.idTipo_evento=evento;
#...
END IF; 

RETURN 1;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_RedondiarTiempo` (`tiempo` VARCHAR(8)) RETURNS VARCHAR(8) CHARSET latin1 NO SQL
BEGIN

WHILE (TIME_FORMAT(tiempo,'%S')!='00') DO

SET tiempo= (SELECT ADDTIME(tiempo,"1"));

END WHILE;

RETURN tiempo;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_SumarHorasTrabajo` (`horaT` VARCHAR(10), `horaS` VARCHAR(10)) RETURNS VARCHAR(10) CHARSET latin1 NO SQL
BEGIN

RETURN (SELECT ADDTIME(horaT,horaS));

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_TiempoDeAntiguedadEmpleado` (`fechaI` VARCHAR(13), `fechaR` VARCHAR(13)) RETURNS VARCHAR(20) CHARSET latin1 NO SQL
BEGIN
#variables
DECLARE tiempo int;
DECLARE cont int;
DECLARE mensaje varchar(50);
DECLARE dateFin varchar(13);
#...
SET dateFin= IF(fechaR='',curdate(),fechaR);
#...
SET cont=0;
#...
SET tiempo=CAST(DATEDIFF(dateFin,fechaI) AS int);

  IF tiempo>=0 AND tiempo<=30 THEN
  	#Va a retornar por dias
   RETURN CONCAT(tiempo,' Días');
  ELSE
    #retorna en meses
    IF tiempo>30 and tiempo <365 THEN
    #Va a retornar los meses
      #RETURN CONCAT(timestampdiff(MONTH,fechaI,curdate()),' Mes/es');
      WHILE tiempo>=30 DO
        SET tiempo=tiempo-30;
        SET cont=cont+1;
      END WHILE;
      #...
        RETURN CONCAT(cont,' Mes/es y ',tiempo,'Día/s');
    ELSE
    #retorno de años con meses
    # Años...
      WHILE tiempo>=365 DO
      	SET tiempo=tiempo-365;
        SET cont=cont+1;
      END WHILE;
      #...
      SET mensaje= CONCAT(cont,' Año/s y ');
      SET cont=0;
      # Meses...
      	WHILE tiempo>=30 DO
         SET tiempo=tiempo-30;
         SET cont=cont+1;
        END WHILE;
        #...
        RETURN CONCAT(mensaje,cont,' Mes/es');
    END IF;
  END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_TiempoDeNotificacion` (`fecha` VARCHAR(25)) RETURNS VARCHAR(15) CHARSET latin1 NO SQL
BEGIN

DECLARE tiempo varchar(15);
#diferencia de los tiempos
SET tiempo=(SELECT TIMEDIFF(now(),fecha));
#
#SELECT DATEDIFF(now(),fecha);
#SELECT tiempo;
IF (SELECT((SELECT TIME_FORMAT(tiempo,'%H:%i:%s')) > '00:00:00' AND (SELECT TIME_FORMAT(tiempo,'%H:%i:%s')) < '00:60:00'))=1 THEN
#Retorno de minutos
    return CONCAT(TIME_FORMAT(tiempo,'%i'),' min');#retorna los minutos
ELSE
#Retorno de horas
  IF (SELECT((SELECT TIME_FORMAT(tiempo,'%H')) > 0 AND (SELECT TIME_FORMAT(tiempo,'%H')) < 24))=1 THEN
  #Retornar las horas
  	return CONCAT(TIME_FORMAT(tiempo,'%H'),'h');
  ELSE
    IF (SELECT ((SELECT DATEDIFF(now(),fecha))>=1) AND ((SELECT DATEDIFF(now(),fecha))<=3)=1) THEN
    #Retorna en días
      return CONCAT(DATEDIFF(now(),fecha),' Dia/s');
    ELSE
    #Retorna la fecha de la notificación.
      return DATE_FORMAT(fecha,'%d-%m-%Y');
    END IF;
  END IF;
END IF;
#
#RETURN tiempo;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SE_FU_ValidacionPermisosEmpleadosAsistencia` (`doc` VARCHAR(13), `idHorario` TINYINT(1)) RETURNS TINYINT(1) NO SQL
BEGIN
DECLARE horarioP int;
DECLARE desde varchar(8);
DECLARE respuesta int;
#...
SET horarioP=(SELECT p.idHorario_permiso FROM permiso p WHERE p.fecha_permiso=CURDATE() AND p.documento=doc AND (p.estado=1 OR p.estado=4) LIMIT 1);#Modificar esto cuando el modulo de permisos este terminado
#Se valida la existencia se un permiso para el día de hoy
IF horarioP IS NOT null THEN
#Clasificar el tipo de permiso
SET desde=(SELECT p.desde FROM permiso p  WHERE p.fecha_permiso=CURDATE() AND p.documento=doc LIMIT 1);

IF horarioP=1 THEN#Salida temprano>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Para que esto se pueda ejecutar sin ningun inconveniente debe tener previamente registrado como minimo el evento laboral, si no lo va mandar inmediatamente a registrar...
 	IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.inicio,'%Y-%m-%d')= CURDATE() AND a.fin is null AND a.hora_fin is null AND a.idTipo_evento=1) THEN
    #...
    	IF DATE_FORMAT(now(),'%H:%i:%S')>=desde THEN#Pendiente calcular numero de horas del permiso
        	
           SET respuesta=(SELECT SE_FU_CalcularNumeroHorasPermisoEmpleados(doc,idHorario,1,DATE_FORMAT(now(),'%H:%i:%S')));#Calcular numero de horas del permiso
            
           return(SELECT SI_FU_CerrarAsistenciaEmpleado(doc,idHorario));#Cerro el evento laboral
           #SELECT 1 as respuesta;
        ELSE 
           #SELECT -1 as respuesta;#Puede seguir con el registro de los eventos
           RETURN -1;
        END IF;
      	#...
     ELSE
      #SELECT -1 as respuesta;#Puede seguir con el registro de los eventos
      RETURN -1;
    END IF;
ELSE
  IF horarioP=2 THEN #Ingreso tarde>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 	#SELECT 2;
    SET respuesta=(SELECT SE_FU_CalcularNumeroHorasPermisoEmpleados(doc,idHorario,2,DATE_FORMAT(now(),'%H:%i:%S')));#Calcular numero de horas del permiso
    RETURN 2;#Retorna un 2 para colocar que ingreso a tiempo del evento laboral.
  ELSE
 	IF horarioP=3 THEN#Salida y llegada>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        #Validar el estado del empleado si es en "presente" o en "permiso"
        #Asistencias 0=Ausente, 1=presente y 2=Permiso
      #...
      IF DATE_FORMAT(now(),'%H:%i:%S')>=desde THEN#Ejecuta las acciones del permiso
      	 IF EXISTS(SELECT * FROM empleado e WHERE e.documento=doc AND e.estado=1 AND e.asistencia=2) THEN
         #Si existe la asistencia de permiso es por que ya va ingresar del permiso
            #...
            IF EXISTS(SELECT * FROM empleado e WHERE e.documento=doc AND e.estado=1 AND e.asistencia=2) THEN#El Empelado estaba de permiso
            	IF TIMEDIFF(DATE_FORMAT(now(),'%H:%i:%S'),desde)>'00:10:00' THEN#Despues de registrado la asistencia tiene que pasar más de 10 minutos para poder ingresar del permiso
               		UPDATE empleado e SET e.asistencia=1 WHERE e.documento=doc;#Se actualiza el estado de en "permiso" a "presente"
               		#Calcular numero de horas del permiso
                	SET respuesta=(SELECT SE_FU_CalcularNumeroHorasPermisoEmpleados(doc,idHorario,3,DATE_FORMAT(now(),'%H:%i:%S')));
                	#NOTA: Tener en cuenta que este tiempo se le va a descontar del tiempo total laborado en el día al empleado.
            	 	return 4;
                ELSE
                  	#retorna la Salida del permiso
                  	RETURN 3;
                END IF;
            ELSE
            #El empleado ya no estaba de permiso
            	return 2;
            END IF; 
        ELSE#Si no existe la asistencia de permiso es por que va a salir del permiso.
        	UPDATE empleado e SET e.asistencia=2 WHERE e.documento=doc;#Se actualiza el estado de "presente" a en "permiso"
            #Se actualiza la hora desde del permiso para calcular el tiempo del permiso con mayor precisión y el estado del permiso a en ejecucion=4.
            UPDATE permiso p SET p.desde=now(), p.estado=4 WHERE p.documento=doc AND p.fecha_permiso=CURDATE() AND p.idHorario_permiso=3;
            RETURN 3;
        END IF;
      ELSE
      	#Retorna -1
      	RETURN -1;
      END IF;
        #...
    END IF;#Pendiente el compensatorio, Puede que se implemente o no se implemente.
    #...
  END IF;
 #...
END IF;
#...
ELSE
#Retornar un verdadero
#SELECT -1 AS respuesta;
RETURN -1;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_ArreglarProblemaBugAsistenciaMultiplesEventos` (`doc` VARCHAR(20)) RETURNS TINYINT(1) NO SQL
BEGIN

DECLARE idAsistenciaEmpleado int;
DECLARE idTipoEventoEmpleado tinyint;

SET idAsistenciaEmpleado = (SELECT MAX(a.idAsistencia) FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.inicio, '%Y-%m-%d') = CURDATE() GROUP BY a.idTipo_evento HAVING COUNT(a.idTipo_evento)>=2);

IF (idAsistenciaEmpleado IS NOT null) THEN

  SET idTipoEventoEmpleado = (SELECT a.idTipo_evento FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.inicio, '%Y-%m-%d') = CURDATE() GROUP BY a.idTipo_evento HAVING COUNT(a.idTipo_evento)>=2);

  DELETE FROM asistencia WHERE idAsistencia != idAsistenciaEmpleado AND idTipo_evento = idTipoEventoEmpleado AND documento = doc AND DATE_FORMAT(inicio, '%Y-%m-%d') = CURDATE();

END IF;

RETURN 1;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_CantidadEventosQueAplicanHorario` (`idHorario` TINYINT(1)) RETURNS INT(1) NO SQL
BEGIN

DECLARE cantidad_eventos_validos tinyint(1);

SET cantidad_eventos_validos = 0;

#Aplica el almuerzo en este horario
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_desayuno > '00:00:00') THEN

  SET cantidad_eventos_validos = 1;

END IF;

#Aplica el almuerzo en este horario
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_almuerzo > '00:00:00') THEN

  SET cantidad_eventos_validos = (cantidad_eventos_validos + 1);

END IF;

RETURN cantidad_eventos_validos;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_CerrarAsistenciaEmpleado` (`doc` VARCHAR(13), `idHorario` INT) RETURNS TINYINT(1) NO SQL
BEGIN

DECLARE horaI time; #hora de inicio de algun event
DECLARE horaF time; #hora fin de algun evento
DECLARE tiempo varchar(10);

#Validar si aplica el evento del desayuno para el horario del operario
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_desayuno > '00:00:00') THEN

#Validacion de la existencia del evento de desayuno.
  IF !EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND DATE_FORMAT(a.fecha_fin,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=2) THEN
    # se valida si existe una asistencia abierta. 
       IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.fecha_fin IS null AND a.hora_fin IS null AND a.idTipo_evento=2) THEN
       #se actualiza el evento de desayuno
           UPDATE asistencia a SET a.fecha_fin=now(),a.hora_fin=now(),a.idEstado_asistencia=2, a.estado=0,a.lectorF=0, a.tiempo=(SELECT c.tiempo_desayuno FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1) WHERE a.documento=doc AND a.idTipo_evento=2 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
           #SELECT 4;
       ELSE
          #se registra el evento del desayuno
          INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `fecha_inicio`, `hora_inicio`, `fecha_fin`, `hora_fin`,`idEstado_asistencia`, `estado`, `tiempo`, `lectorF`,`idConfiguracion`) VALUES (doc,2,now(),now(),now(),now(),3,0,(SELECT c.tiempo_desayuno FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1),0,idHorario);
          #SELECT 3;
       END IF;
  END IF;

END IF;
  
#Validar si aplica el evento del Almuerzo para el horario del operario
IF EXISTS(SELECT * FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.hora_inicio_almuerzo > '00:00:00') THEN

#Validacion de la existencia del evento de almuerzo.
  IF !EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND DATE_FORMAT(a.fecha_fin,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=3) THEN
     #
        IF EXISTS(SELECT * FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.fecha_fin IS null AND a.hora_fin IS null AND a.idTipo_evento=3) THEN
        # se actualiza el evento de almuerzo
             UPDATE asistencia a SET a.fecha_fin=now(),a.hora_fin=now(),a.idEstado_asistencia=2, a.estado=0, a.lectorF=0, a.tiempo=(SELECT c.tiempo_almuerzo FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1) WHERE a.documento=doc AND a.idTipo_evento=3 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
             #SELECT 2;
        ELSE
         # se registra el evento de almuerzo
             INSERT INTO `asistencia`(`documento`, `idTipo_evento`, `fecha_inicio`, `hora_inicio`, `fecha_fin`, `hora_fin`,`idEstado_asistencia`, `estado`, `tiempo`, `lectorF`,`idConfiguracion`) VALUES (doc,3,now(),now(),now(),now(),3,0,(SELECT c.tiempo_almuerzo FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 LIMIT 1),0,idHorario);
             #SELECT 1;
        END IF;
  END IF;

END IF;
  
  #Cierre del evento laboral.
  UPDATE asistencia a SET a.fecha_fin=now(),a.hora_fin=now(),a.lectorF=0, a.estado=0 WHERE a.documento=doc AND a.idTipo_evento=1 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
  #
  UPDATE empleado e SET e.asistencia=0 WHERE e.documento=doc;
  #
  SET horaI=(SELECT a.hora_inicio FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=1);
  SET horaF=(SELECT a.hora_fin FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y') AND a.idTipo_evento=1);
  #
  SET tiempo=(SELECT TIMEDIFF(horaF,horaI));

  UPDATE asistencia a SET a.tiempo=(SELECT TIMEDIFF(horaF,horaI)) WHERE a.documento=doc AND a.idTipo_evento=1 AND DATE_FORMAT(a.fecha_inicio,'%d-%m-%Y')=DATE_FORMAT(now(),'%d-%m-%Y');
  #
  CALL SI_PA_CalcularRegistrarHorasTrabajadas(doc,idhorario,now(),1);


RETURN 1;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_ClasificacionEstadoAsistencia` (`evento` TINYINT(1), `fechaInicioEvento` VARCHAR(20), `fechaFinEvento` VARCHAR(20), `idHorario` INT) RETURNS TINYINT(1) NO SQL
BEGIN

DECLARE horaBase varchar(20);
DECLARE diferencia time;

IF evento = 1 THEN #Evento laboral
SET horaBase = (SELECT CONCAT(DATE_FORMAT(fechaInicioEvento, '%Y-%m-%d'), ' ', c.hora_ingreso_empresa) FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.estado=1 LIMIT 1);#Hora de ingreso laboral
#...
  IF (fechaInicioEvento) <= (horaBase) THEN

	 RETURN 1; # Estado -> A tiempo

  ELSE

   RETURN 2;  #Estado -> Tarde

  END IF;
#...
ELSE

 IF evento=2 THEN #Evento Desayuno

 	SET horaBase=(SELECT c.tiempo_desayuno FROM configuracion c WHERE c.idConfiguracion = idHorario AND c.estado = 1 limit 1);#Tiempo de desayuno

 ELSE

  IF evento=3 THEN #Evento Almuerzo

  	SET horaBase=(SELECT c.tiempo_almuerzo FROM configuracion c WHERE c.idConfiguracion=idHorario AND c.estado=1 limit 1);#Tiempo de desayuno

  END IF;
 END IF; 
END IF;

IF (evento = 3) OR (evento=2) THEN

  SET diferencia= (SELECT TIMEDIFF(fechaFinEvento, fechaInicioEvento));

  IF (diferencia) <= (horaBase) THEN

    RETURN 1; # Estado -> A tiempo

  ELSE

    RETURN 2; # Estado -> Tarede

  END IF;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_ClasificarElTiempoCorrecto` (`doc` VARCHAR(13), `evento` TINYINT) RETURNS TINYINT(1) NO SQL
BEGIN

DECLARE horaI time;#Hora de inicio del evento Desayuno=2 o almuerzo=3
DECLARE horaF time;#Hora de fin del evento Desayuno o almuerzo
DECLARE horaE time;#Tiempo del evento.
#...
#hora de inicio del evento.
SET horaI= (SELECT a.inicio FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.inicio,'%Y-%m-%d')= CURDATE() AND a.idTipo_evento=evento LIMIT 1);
#hora de fin del evento.
SET horaF= (SELECT a.fin FROM asistencia a WHERE a.documento=doc AND DATE_FORMAT(a.fin,'%Y-%m-%d')= CURDATE() AND a.idTipo_evento=evento LIMIT 1);
#Tiempo del evento
IF evento=2 THEN
#Desayuno
  SET horaE=(SELECT c.tiempo_desayuno FROM configuracion C WHERE C.estado=1 LIMIT 1);
ELSE
#Almuerzo
  SET horaE=(SELECT c.tiempo_almuerzo FROM configuracion C WHERE C.estado=1 LIMIT 1);
END IF;
#...
#SELECT TIMEDIFF(horaF,horaI),horaI,horaF;
#...
#Si la diferencia de tiempos es mayor al tiempo definido por el evento, se registra el desface del tiempo y si el tiempo es menor que al tiempo definido para el evento se registra el tiempo del evento.
IF TIMEDIFF(horaF, horaI) > horaE THEN
  #se sobre paso del tiempo especificado del evento.
  SET horaE=(SELECT TIMEDIFF(horaF, horaI));

END IF;
#...
#Se actualizar el tiempo de la asistencia.
UPDATE asistencia a SET a.tiempo=horaE WHERE a.documento=doc AND a.idTipo_evento = evento AND DATE_FORMAT(a.inicio,'%Y-%m-%d')= CURDATE();

RETURN 1;#procedimiento ejecutado correctamente.

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_TiempoPredeterminadoDeTrabajoDiario` (`idHorario` TINYINT(1)) RETURNS VARCHAR(8) CHARSET latin1 NO SQL
BEGIN
# se encarga de retornar el tiempo total que se tiene que trabajar diariamente para las personas de producción.
DECLARE horaL varchar(8);

SET horaL =(SELECT SUBTIME(SUBTIME(TIMEDIFF(c.hora_salida_empresa,c.hora_ingreso_empresa),c.tiempo_desayuno),c.tiempo_almuerzo) FROM configuracion c WHERE c.estado=1 AND c.idConfiguracion=idHorario LIMIT 1);

RETURN horaL;


END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_ValidacionCierreAsistencia` (`idHorario` TINYINT(2)) RETURNS TINYINT(1) NO SQL
BEGIN
DECLARE horaFinEvento varchar(8);
DECLARE horaInicioEvento varchar(8);

SET horaInicioEvento = (SELECT c.hora_inicio_almuerzo FROM configuracion c WHERE c.estado=1 AND c.idConfiguracion=idHorario LIMIT 1);
SET horaFinEvento = (SELECT c.hora_fin_almuerzo FROM configuracion c WHERE c.estado=1 AND c.idConfiguracion=idHorario LIMIT 1);


IF horaInicioEvento = '00:00:00' OR horaFinEvento = '00:00:00' THEN
#No aplica el evento del almuerzo

SET horaInicioEvento = (SELECT c.hora_inicio_desayuno FROM configuracion c WHERE c.estado=1 AND c.idConfiguracion=idHorario LIMIT 1);
SET horaFinEvento = (SELECT c.hora_fin_desayuno FROM configuracion c WHERE c.estado=1 AND c.idConfiguracion=idHorario LIMIT 1);

  IF horaInicioEvento = '00:00:00' OR horaFinEvento THEN

    RETURN 1;#Si se puede cerrar la asistencia.

  ELSE

  IF (TIMEDIFF(TIME_FORMAT(now(),'%H:%i:%s'), horaFinEvento) > '00:10:00') = 1 THEN #Ya pasaron mas de 10 minutos despues de la hora del almuerzo?
    
      RETURN 1; 
    
    ELSE
    
      RETURN 0;
    
    END IF;

  END IF;

ELSE
#Si aplica el evento del almuerzo

  IF (TIMEDIFF(TIME_FORMAT(now(),'%H:%i:%s'), horaFinEvento) > '00:10:00') = 1 THEN #Ya pasaron mas de 10 minutos despues de la hora del almuerzo?
    
      RETURN 1; 
    
    ELSE
    
      RETURN 0;
    
    END IF;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SI_FU_ValidarHoraMayor` (`idHorario` INT, `idEvento` INT) RETURNS TINYINT(1) NO SQL
BEGIN

IF idEvento = 2 THEN # Desayuno

	IF (SELECT c.hora_inicio_desayuno FROM configuracion c WHERE c.idConfiguracion = idHorario) >= (SELECT c.hora_fin_desayuno FROM configuracion c WHERE c.idConfiguracion = idHorario) THEN
        #Horario Nocturno
        	RETURN 1;
        ELSE
        #Horario Diurna.
        	RETURN 0;
	END IF;

ELSE # Almuerzo

	IF (SELECT c.hora_inicio_almuerzo FROM configuracion c WHERE c.idConfiguracion = idHorario) >= (SELECT c.hora_fin_almuerzo FROM configuracion c WHERE c.idConfiguracion = idHorario) THEN
        #Horario Nocturno
        	RETURN 1;
        ELSE
        #Horario Diurna.
        	RETURN 0;
	END IF;

END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividad`
--

CREATE TABLE `actividad` (
  `idActividad` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `actividad`
--

INSERT INTO `actividad` (`idActividad`, `nombre`, `estado`) VALUES
(1, 'Deporte', 1),
(2, 'Arte (Pintura, Baile, Música, otros)', 1),
(3, 'Manualidades', 1),
(4, 'Labores Domésticos', 1),
(5, 'Otro trabajo', 1),
(6, 'Estudio', 1),
(7, 'Lectura', 1),
(8, 'Espacio de Familia', 1),
(9, 'Mascotas', 1),
(11, 'Televisión - Cine', 1),
(12, 'Viajar', 1),
(13, 'Vida espiritual - Espacios religiosos', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividades_timpo_libre`
--

CREATE TABLE `actividades_timpo_libre` (
  `idActividades_timpo_libre` int(11) NOT NULL,
  `idPersonal` smallint(6) NOT NULL,
  `idActividades` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `actividades_timpo_libre`
--

INSERT INTO `actividades_timpo_libre` (`idActividades_timpo_libre`, `idPersonal`, `idActividades`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 7),
(4, 1, 8),
(5, 1, 11),
(6, 1, 12),
(7, 1, 13),
(8, 2, 1),
(9, 2, 4),
(10, 2, 7),
(11, 2, 8),
(12, 2, 9),
(13, 2, 11),
(14, 2, 12),
(15, 2, 13),
(16, 3, 2),
(17, 3, 4),
(18, 3, 7),
(19, 3, 8),
(20, 3, 9),
(21, 3, 11),
(22, 3, 13),
(23, 4, 2),
(24, 4, 4),
(25, 4, 7),
(26, 4, 8),
(27, 4, 9),
(28, 4, 11),
(29, 4, 13),
(30, 5, 1),
(31, 5, 3),
(32, 5, 4),
(33, 5, 7),
(34, 5, 9),
(35, 5, 11),
(36, 5, 12),
(37, 5, 13),
(38, 6, 4),
(39, 6, 7),
(40, 6, 8),
(41, 6, 9),
(42, 6, 11),
(43, 6, 12),
(44, 6, 13),
(45, 7, 1),
(46, 7, 2),
(47, 7, 4),
(48, 7, 7),
(49, 7, 8),
(50, 7, 9),
(51, 7, 11),
(52, 7, 12),
(53, 7, 13),
(54, 8, 2),
(55, 8, 3),
(56, 8, 4),
(57, 8, 8),
(58, 8, 12),
(59, 8, 13),
(60, 9, 1),
(61, 9, 4),
(62, 9, 7),
(63, 9, 8),
(64, 9, 9),
(65, 9, 11),
(66, 9, 13),
(67, 10, 2),
(68, 10, 4),
(69, 10, 7),
(70, 10, 8),
(71, 10, 9),
(72, 10, 11),
(73, 10, 13),
(74, 11, 1),
(75, 11, 4),
(76, 11, 7),
(77, 11, 8),
(78, 11, 9),
(79, 11, 12),
(80, 11, 13),
(81, 12, 1),
(82, 12, 2),
(83, 12, 4),
(84, 12, 7),
(85, 12, 8),
(86, 12, 9),
(87, 12, 11),
(88, 12, 12),
(89, 12, 13),
(90, 13, 1),
(91, 13, 2),
(92, 13, 3),
(93, 13, 4),
(94, 13, 7),
(95, 13, 8),
(96, 13, 11),
(97, 13, 12),
(98, 13, 13),
(99, 14, 4),
(100, 14, 7),
(101, 14, 8),
(102, 14, 11),
(103, 14, 13),
(104, 15, 1),
(105, 15, 2),
(106, 15, 4),
(107, 15, 8),
(108, 15, 11),
(109, 15, 13),
(110, 16, 2),
(111, 16, 4),
(112, 16, 7),
(113, 16, 8),
(114, 16, 11),
(115, 16, 12),
(116, 16, 13),
(117, 17, 1),
(118, 17, 7),
(119, 17, 8),
(120, 17, 11),
(121, 17, 12),
(122, 17, 13),
(123, 18, 3),
(124, 18, 4),
(125, 18, 7),
(126, 18, 8),
(127, 18, 11),
(128, 18, 12),
(129, 18, 13),
(130, 19, 2),
(131, 19, 3),
(132, 19, 4),
(133, 19, 7),
(134, 19, 8),
(135, 19, 9),
(136, 19, 11),
(137, 19, 12),
(138, 19, 13),
(139, 20, 2),
(140, 20, 3),
(141, 20, 4),
(142, 20, 5),
(143, 20, 7),
(144, 20, 8),
(145, 20, 9),
(146, 20, 11),
(147, 20, 12),
(148, 20, 13),
(149, 21, 1),
(150, 21, 2),
(151, 21, 4),
(152, 21, 7),
(153, 21, 8),
(154, 21, 11),
(155, 21, 12),
(156, 21, 13),
(157, 22, 1),
(158, 22, 3),
(159, 22, 7),
(160, 22, 8),
(161, 22, 11),
(162, 22, 12),
(163, 22, 13),
(164, 23, 1),
(165, 23, 2),
(166, 23, 4),
(167, 23, 7),
(168, 23, 8),
(169, 23, 11),
(170, 23, 12),
(171, 23, 13),
(172, 24, 1),
(173, 24, 2),
(174, 24, 4),
(175, 24, 12),
(176, 24, 13),
(177, 25, 4),
(178, 25, 7),
(179, 25, 8),
(180, 25, 11),
(181, 25, 13),
(182, 26, 1),
(183, 26, 2),
(184, 26, 4),
(185, 26, 7),
(186, 26, 8),
(187, 26, 11),
(188, 26, 12),
(189, 26, 13),
(190, 27, 2),
(191, 27, 4),
(192, 27, 8),
(193, 27, 11),
(194, 27, 13),
(195, 28, 3),
(196, 28, 7),
(197, 28, 8),
(198, 28, 11),
(199, 28, 12),
(200, 28, 13),
(201, 29, 4),
(202, 29, 7),
(203, 29, 8),
(204, 29, 11),
(205, 29, 13),
(206, 30, 2),
(207, 30, 4),
(208, 30, 7),
(209, 30, 8),
(210, 30, 9),
(211, 30, 11),
(212, 30, 12),
(213, 30, 13),
(214, 31, 1),
(215, 31, 2),
(216, 31, 4),
(217, 31, 7),
(218, 31, 8),
(219, 31, 13),
(220, 32, 1),
(221, 32, 2),
(222, 32, 3),
(223, 32, 4),
(224, 32, 7),
(225, 32, 8),
(226, 32, 9),
(227, 32, 11),
(228, 32, 13),
(229, 33, 1),
(230, 33, 4),
(231, 33, 7),
(232, 33, 8),
(233, 33, 11),
(234, 33, 12),
(235, 33, 13),
(236, 34, 1),
(237, 34, 2),
(238, 34, 7),
(239, 35, 1),
(240, 35, 4),
(241, 35, 5),
(242, 35, 11),
(243, 35, 12),
(244, 35, 13),
(245, 36, 1),
(246, 36, 2),
(247, 36, 3),
(248, 36, 4),
(249, 36, 7),
(250, 36, 8),
(251, 36, 9),
(252, 36, 11),
(253, 36, 12),
(254, 36, 13),
(255, 37, 3),
(256, 37, 4),
(257, 37, 8),
(258, 37, 9),
(259, 37, 11),
(260, 37, 13),
(261, 38, 4),
(262, 38, 5),
(263, 38, 8),
(264, 38, 11),
(265, 38, 13),
(266, 39, 4),
(267, 39, 7),
(268, 39, 8),
(269, 39, 11),
(270, 39, 12),
(271, 39, 13),
(272, 40, 4),
(273, 40, 8),
(274, 40, 9),
(275, 40, 11),
(276, 40, 12),
(277, 40, 13),
(278, 41, 4),
(279, 41, 8),
(280, 41, 9),
(281, 41, 11),
(282, 41, 13),
(283, 42, 2),
(284, 42, 4),
(285, 42, 7),
(286, 42, 8),
(287, 42, 9),
(288, 42, 11),
(289, 42, 12),
(290, 42, 13),
(291, 43, 1),
(292, 43, 4),
(293, 43, 7),
(294, 43, 8),
(295, 43, 9),
(296, 43, 11),
(297, 43, 12),
(298, 43, 13),
(299, 44, 4),
(300, 44, 7),
(301, 44, 8),
(302, 44, 9),
(303, 44, 11),
(304, 44, 13),
(305, 45, 1),
(306, 45, 4),
(307, 45, 7),
(308, 45, 8),
(309, 45, 11),
(310, 45, 12),
(311, 45, 13),
(312, 46, 2),
(313, 46, 4),
(314, 46, 7),
(315, 46, 8),
(316, 46, 13),
(317, 47, 2),
(318, 47, 4),
(319, 47, 8),
(320, 47, 11),
(321, 47, 13),
(322, 48, 2),
(323, 48, 4),
(324, 48, 8),
(325, 48, 9),
(326, 48, 11),
(327, 48, 12),
(328, 48, 13),
(329, 49, 2),
(330, 49, 3),
(331, 49, 4),
(332, 49, 7),
(333, 49, 8),
(334, 49, 9),
(335, 49, 11),
(336, 49, 13),
(337, 50, 1),
(338, 50, 4),
(339, 50, 7),
(340, 50, 8),
(341, 50, 11),
(342, 50, 12),
(343, 50, 13),
(344, 51, 4),
(345, 51, 7),
(346, 51, 8),
(347, 51, 9),
(348, 51, 11),
(349, 51, 12),
(350, 51, 13),
(351, 52, 1),
(352, 52, 4),
(353, 52, 7),
(354, 52, 8),
(355, 52, 11),
(356, 52, 12),
(357, 52, 13),
(358, 53, 1),
(359, 53, 2),
(360, 53, 4),
(361, 53, 7),
(362, 53, 8),
(363, 53, 13),
(364, 54, 1),
(365, 54, 2),
(366, 54, 4),
(367, 54, 8),
(368, 54, 11),
(369, 54, 13),
(370, 55, 1),
(371, 55, 2),
(372, 55, 4),
(373, 55, 5),
(374, 55, 8),
(375, 55, 11),
(376, 55, 12),
(377, 55, 13),
(378, 56, 2),
(379, 56, 4),
(380, 56, 5),
(381, 56, 7),
(382, 56, 8),
(383, 56, 9),
(384, 56, 11),
(385, 56, 12),
(386, 56, 13),
(387, 57, 1),
(388, 57, 2),
(389, 57, 4),
(390, 57, 7),
(391, 57, 8),
(392, 57, 11),
(393, 57, 12),
(394, 57, 13),
(395, 58, 1),
(396, 58, 2),
(397, 58, 7),
(398, 58, 8),
(399, 58, 9),
(400, 58, 11),
(401, 58, 12),
(402, 58, 13),
(403, 59, 1),
(404, 59, 4),
(405, 59, 7),
(406, 59, 8),
(407, 59, 9),
(408, 59, 11),
(409, 59, 12),
(410, 59, 13),
(411, 60, 1),
(412, 60, 4),
(413, 60, 7),
(414, 60, 8),
(415, 60, 9),
(416, 60, 11),
(417, 60, 12),
(418, 60, 13),
(419, 61, 1),
(420, 61, 7),
(421, 61, 9),
(422, 61, 11),
(423, 61, 13),
(424, 62, 2),
(425, 62, 3),
(426, 62, 4),
(427, 62, 7),
(428, 62, 8),
(429, 62, 9),
(430, 62, 11),
(431, 62, 12),
(432, 63, 2),
(433, 63, 4),
(434, 63, 7),
(435, 63, 8),
(436, 63, 11),
(437, 63, 12),
(438, 63, 13),
(439, 64, 1),
(440, 64, 4),
(441, 64, 7),
(442, 64, 8),
(443, 64, 12),
(444, 64, 13),
(445, 65, 2),
(446, 65, 3),
(447, 65, 4),
(448, 65, 7),
(449, 65, 8),
(450, 65, 9),
(451, 65, 11),
(452, 65, 13),
(453, 66, 1),
(454, 66, 2),
(455, 66, 4),
(456, 66, 7),
(457, 66, 8),
(458, 66, 11),
(459, 66, 13),
(460, 67, 1),
(461, 67, 2),
(462, 67, 3),
(463, 67, 4),
(464, 67, 7),
(465, 67, 8),
(466, 67, 9),
(467, 67, 11),
(468, 67, 12),
(469, 67, 13),
(470, 68, 2),
(471, 68, 4),
(472, 68, 7),
(473, 68, 8),
(474, 68, 9),
(475, 68, 11),
(476, 68, 12),
(477, 69, 1),
(478, 69, 4),
(479, 69, 7),
(480, 69, 8),
(481, 69, 9),
(482, 69, 11),
(483, 69, 13),
(484, 70, 2),
(485, 70, 3),
(486, 70, 4),
(487, 70, 7),
(488, 70, 8),
(489, 70, 9),
(490, 70, 11),
(491, 70, 13),
(492, 71, 4),
(493, 71, 7),
(494, 71, 8),
(495, 71, 9),
(496, 71, 11),
(497, 71, 13),
(498, 72, 1),
(499, 72, 4),
(500, 72, 7),
(501, 72, 8),
(502, 72, 11),
(503, 72, 12),
(504, 72, 13),
(505, 73, 1),
(506, 73, 2),
(507, 73, 4),
(508, 73, 7),
(509, 73, 8),
(510, 73, 11),
(511, 73, 12),
(512, 73, 13),
(513, 74, 2),
(514, 74, 3),
(515, 74, 4),
(516, 74, 7),
(517, 74, 8),
(518, 74, 11),
(519, 74, 13),
(520, 75, 1),
(521, 75, 2),
(522, 75, 3),
(523, 75, 4),
(524, 75, 5),
(525, 75, 8),
(526, 75, 11),
(527, 75, 12),
(528, 75, 13),
(529, 76, 1),
(530, 76, 4),
(531, 76, 7),
(532, 76, 8),
(533, 76, 11),
(534, 76, 13),
(535, 77, 1),
(536, 77, 4),
(537, 77, 7),
(538, 77, 8),
(539, 77, 9),
(540, 77, 11),
(541, 77, 12),
(542, 77, 13),
(543, 78, 2),
(544, 78, 4),
(545, 78, 7),
(546, 78, 8),
(547, 78, 9),
(548, 78, 11),
(549, 78, 13),
(550, 79, 1),
(551, 79, 4),
(552, 79, 7),
(553, 79, 8),
(554, 79, 11),
(555, 79, 12),
(556, 79, 13),
(557, 80, 1),
(558, 80, 3),
(559, 80, 4),
(560, 80, 5),
(561, 80, 7),
(562, 80, 8),
(563, 80, 11),
(564, 80, 13),
(565, 81, 1),
(566, 81, 4),
(567, 81, 7),
(568, 81, 8),
(569, 81, 12),
(570, 81, 13),
(571, 82, 2),
(572, 82, 3),
(573, 82, 4),
(574, 82, 7),
(575, 82, 8),
(576, 82, 9),
(577, 82, 11),
(578, 82, 12),
(579, 82, 13),
(580, 83, 1),
(581, 83, 4),
(582, 83, 7),
(583, 83, 8),
(584, 84, 1),
(585, 84, 4),
(586, 84, 7),
(587, 84, 8),
(588, 84, 11),
(589, 84, 12),
(590, 84, 13),
(591, 85, 1),
(592, 85, 2),
(593, 85, 5),
(594, 85, 7),
(595, 85, 8),
(596, 85, 11),
(597, 85, 12),
(598, 85, 13),
(599, 86, 1),
(600, 86, 4),
(601, 86, 7),
(602, 86, 8),
(603, 86, 9),
(604, 86, 11),
(605, 86, 12),
(606, 86, 13),
(607, 87, 1),
(608, 87, 7),
(609, 87, 8),
(610, 87, 11),
(611, 87, 12),
(612, 87, 13),
(613, 88, 4),
(614, 88, 7),
(615, 88, 8),
(616, 88, 11),
(617, 88, 12),
(618, 89, 1),
(619, 89, 2),
(620, 89, 4),
(621, 89, 5),
(622, 89, 7),
(623, 89, 8),
(624, 89, 9),
(625, 89, 11),
(626, 89, 12),
(627, 89, 13),
(628, 90, 3),
(629, 90, 4),
(630, 90, 5),
(631, 90, 7),
(632, 90, 8),
(633, 90, 11),
(634, 90, 12),
(635, 91, 1),
(636, 91, 4),
(637, 91, 7),
(638, 91, 8),
(639, 91, 11),
(640, 91, 12),
(641, 92, 1),
(642, 92, 8),
(643, 92, 12),
(644, 92, 11),
(645, 94, 1),
(646, 94, 12),
(647, 94, 11),
(648, 94, 8),
(649, 95, 11),
(650, 95, 7),
(651, 95, 6),
(652, 95, 1),
(653, 96, 6),
(654, 96, 7),
(655, 96, 5),
(656, 96, 1),
(657, 96, 8),
(658, 96, 9),
(659, 96, 11),
(660, 96, 12),
(661, 96, 13),
(662, 97, 1),
(663, 97, 4),
(664, 97, 5),
(665, 97, 7),
(666, 97, 8),
(667, 97, 13),
(668, 98, 3),
(669, 98, 8),
(670, 34, 6),
(671, 101, 1),
(672, 102, 6),
(673, 103, 12),
(674, 104, 4),
(675, 104, 3),
(676, 105, 4),
(677, 105, 6),
(678, 105, 12),
(679, 105, 7),
(680, 106, 7),
(681, 106, 1),
(682, 106, 2),
(683, 107, 8),
(684, 107, 1),
(685, 107, 13),
(686, 107, 7),
(687, 108, 7),
(688, 108, 13),
(689, 108, 8),
(690, 109, 3),
(691, 109, 13),
(692, 109, 8),
(693, 110, 1),
(694, 110, 9),
(695, 111, 8),
(696, 111, 11),
(697, 111, 12),
(698, 112, 1),
(699, 113, 9),
(700, 113, 2),
(701, 113, 11),
(702, 113, 8),
(703, 114, 12),
(704, 114, 1),
(705, 114, 11),
(706, 114, 5),
(707, 115, 8),
(708, 115, 11),
(709, 115, 7),
(710, 115, 4),
(711, 115, 12),
(712, 116, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `afp`
--

CREATE TABLE `afp` (
  `idAFP` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `afp`
--

INSERT INTO `afp` (`idAFP`, `nombre`, `estado`) VALUES
(1, 'Porvenir', 1),
(2, 'Colfondos', 1),
(3, 'Old Mutual', 1),
(4, 'Protección', 1),
(5, 'Rentabilidad Mínima Obligatoria', 1),
(6, 'N/A', 1),
(7, 'Colpensiones ', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area_trabajo`
--

CREATE TABLE `area_trabajo` (
  `idArea_trabajo` tinyint(4) NOT NULL,
  `area` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `area_trabajo`
--

INSERT INTO `area_trabajo` (`idArea_trabajo`, `area`, `estado`) VALUES
(1, 'INVEST - DERROLLO E INNOVACION', 0),
(2, 'COLCIRCUITOS ADMON', 0),
(3, 'COLCIRCUITOS VENTAS', 0),
(4, 'COLCIRCUITOS MOD', 0),
(5, 'COLCIRCUITOS MO INDIRECTA', 0),
(6, 'APRENDIZ', 0),
(7, 'Ensamble Automatico', 1),
(8, 'Gestión Humana', 1),
(9, 'Comunicaciones', 1),
(10, 'Compras', 1),
(11, 'Sistemas de información', 1),
(12, 'Gerencia', 1),
(13, 'Contabilidad', 1),
(14, 'Comercial interno', 1),
(15, 'Comercial externo', 1),
(16, 'Servicios generales', 1),
(17, 'Mantenimiento', 1),
(18, 'Tecrea', 1),
(19, 'Gestión Técnica', 1),
(20, 'Control calidad integración', 1),
(21, 'Ensamble manual', 1),
(22, 'Empaque', 1),
(23, 'Almacén', 1),
(24, 'Perforado', 1),
(25, 'Teclados', 1),
(26, 'Control calidad FE', 1),
(27, 'Químicos', 1),
(28, 'Screen', 1),
(29, 'Recepción ', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia`
--

CREATE TABLE `asistencia` (
  `idAsistencia` int(11) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `idTipo_evento` tinyint(4) NOT NULL,
  `inicio` varchar(20) NOT NULL,
  `fin` varchar(20) DEFAULT NULL,
  `idEstado_asistencia` tinyint(4) NOT NULL,
  `estado` tinyint(1) NOT NULL,
  `lectorI` tinyint(1) NOT NULL,
  `lectorF` tinyint(1) DEFAULT NULL,
  `tiempo` varchar(10) DEFAULT NULL,
  `idConfiguracion` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `asistencia`
--

INSERT INTO `asistencia` (`idAsistencia`, `documento`, `idTipo_evento`, `inicio`, `fin`, `idEstado_asistencia`, `estado`, `lectorI`, `lectorF`, `tiempo`, `idConfiguracion`) VALUES
(23, '1216727816', 1, '2019-05-15 19:05:16', '2019-05-16 10:46:06', 2, 0, 2, 2, '15:40:50', 4),
(33, '1216727816', 2, '2019-05-16 06:17:21', '2019-05-16 06:31:07', 1, 0, 2, 2, '00:20:00', 4),
(34, '1216727816', 3, '2019-05-16 10:31:21', '2019-05-16 10:39:13', 1, 0, 2, 2, '00:40:00', 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auxilio`
--

CREATE TABLE `auxilio` (
  `idAuxilio` int(11) NOT NULL,
  `idTipo_auxilio` tinyint(4) NOT NULL,
  `monto` varchar(10) NOT NULL,
  `idSalarial` smallint(6) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `auxilio`
--

INSERT INTO `auxilio` (`idAuxilio`, `idTipo_auxilio`, `monto`, `idSalarial`, `estado`) VALUES
(1, 1, '97032', 1, 1),
(2, 3, '60000', 1, 1),
(3, 1, '97032', 2, 1),
(4, 3, '200000', 2, 1),
(5, 1, '97032', 4, 1),
(6, 1, '88211', 6, 1),
(7, 3, '200000', 6, 1),
(8, 1, '97032', 8, 1),
(9, 3, '90000', 8, 1),
(10, 1, '97032', 9, 1),
(11, 3, '80000', 10, 1),
(12, 1, '97032', 11, 1),
(13, 1, '97032', 12, 1),
(14, 1, '97032', 13, 1),
(15, 3, '300000', 14, 1),
(16, 1, '97032', 16, 1),
(17, 1, '97032', 17, 1),
(18, 3, '125073', 17, 1),
(19, 1, '97032', 19, 1),
(20, 3, '100000', 19, 1),
(21, 1, '97032', 20, 1),
(22, 1, '97032', 21, 1),
(23, 1, '97032', 22, 1),
(24, 3, '60000', 22, 1),
(25, 1, '97032', 23, 1),
(26, 3, '60000', 23, 1),
(27, 1, '97032', 24, 1),
(28, 3, '60000', 24, 1),
(29, 3, '200000', 25, 1),
(30, 1, '97032', 27, 1),
(31, 1, '97032', 28, 1),
(32, 1, '97032', 29, 1),
(33, 3, '60000', 29, 1),
(34, 1, '97032', 30, 1),
(35, 3, '200000', 30, 1),
(36, 1, '97032', 31, 1),
(37, 1, '97032', 32, 1),
(38, 3, '200000', 32, 1),
(39, 1, '97032', 33, 1),
(40, 3, '120000', 33, 1),
(41, 1, '97032', 35, 1),
(42, 3, '60000', 35, 1),
(43, 1, '97032', 36, 1),
(44, 3, '250000', 36, 1),
(45, 1, '97032', 37, 1),
(46, 3, '60000', 37, 1),
(47, 1, '97032', 38, 1),
(48, 1, '97032', 40, 1),
(49, 3, '60000', 40, 1),
(50, 1, '97032', 41, 1),
(51, 1, '97032', 42, 1),
(52, 1, '97032', 43, 1),
(53, 3, '60000', 43, 1),
(54, 1, '97032', 44, 1),
(55, 3, '130000', 44, 1),
(56, 1, '97032', 46, 1),
(57, 3, '60000', 46, 1),
(58, 1, '97032', 47, 1),
(59, 3, '100000', 47, 1),
(60, 1, '97032', 48, 1),
(61, 1, '97032', 49, 1),
(62, 3, '180000', 49, 1),
(63, 1, '97032', 51, 1),
(64, 1, '97032', 52, 1),
(65, 3, '140000', 52, 1),
(66, 1, '97032', 53, 1),
(67, 3, '250000', 53, 1),
(68, 1, '97032', 54, 1),
(69, 3, '250000', 54, 1),
(70, 1, '97032', 56, 1),
(71, 1, '97032', 57, 1),
(72, 3, '200000', 57, 1),
(73, 1, '97032', 58, 1),
(74, 3, '200000', 58, 1),
(75, 1, '97032', 59, 1),
(76, 1, '97032', 60, 1),
(77, 1, '97032', 61, 1),
(78, 3, '60000', 61, 1),
(79, 1, '97032', 62, 1),
(80, 1, '97032', 65, 1),
(81, 1, '97032', 67, 1),
(82, 1, '97032', 68, 1),
(83, 3, '40000', 68, 1),
(84, 1, '97032', 73, 1),
(85, 1, '97032', 75, 1),
(86, 1, '97032', 77, 1),
(87, 3, '60000', 77, 1),
(88, 1, '97032', 79, 1),
(89, 1, '97032', 80, 1),
(90, 1, '97032', 82, 1),
(91, 1, '97032', 83, 1),
(92, 3, '200000', 83, 1),
(93, 1, '97032', 84, 1),
(94, 1, '97032', 85, 1),
(95, 3, '250000', 85, 1),
(96, 1, '97032', 86, 1),
(97, 3, '250000', 86, 1),
(98, 3, '800000', 88, 1),
(99, 1, '97032', 89, 1),
(100, 3, '250000', 89, 1),
(101, 3, '500000', 90, 1),
(102, 3, '200000', 92, 1),
(103, 3, '500000', 93, 1),
(104, 1, '97032', 94, 1),
(105, 3, '230000', 94, 1),
(106, 1, '97032', 95, 1),
(107, 3, '400000', 96, 1),
(108, 3, '250000', 97, 1),
(109, 1, '97032', 74, 0),
(110, 1, '97032', 98, 1),
(111, 1, '97032', 69, 0),
(112, 1, '97032', 100, 0),
(113, 3, '1500000', 100, 1),
(114, 1, '97032', 101, 1),
(115, 1, '97032', 102, 1),
(116, 3, '200000', 102, 1),
(117, 1, '97032', 55, 1),
(118, 1, '97032', 103, 1),
(119, 1, '97032', 104, 1),
(120, 1, '88211', 70, 1),
(121, 1, '97032', 106, 1),
(122, 3, '40000', 106, 1),
(123, 1, '97032', 109, 1),
(124, 3, '600000', 109, 1),
(125, 1, '97032', 110, 1),
(126, 3, '1400000', 111, 1),
(127, 1, '97032', 112, 1),
(128, 1, '97032', 113, 1),
(129, 1, '97032', 114, 1),
(130, 1, '97032', 5, 1),
(131, 1, '97032', 34, 1),
(132, 1, '97032', 7, 1),
(133, 1, '97032', 3, 1),
(134, 3, '60000', 56, 1),
(135, 3, '500000', 50, 1),
(136, 2, '200000', 50, 1),
(137, 2, '200000', 109, 1),
(138, 1, '97032', 115, 1),
(139, 1, '97032', 116, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cargo`
--

CREATE TABLE `cargo` (
  `idCargo` tinyint(4) NOT NULL,
  `cargo` varchar(60) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `cargo`
--

INSERT INTO `cargo` (`idCargo`, `cargo`, `estado`) VALUES
(1, 'GERENTE', 1),
(2, 'LÍDER DE PRODUCCIÓN', 1),
(3, 'LÍDER DE INGENIERÍA', 1),
(4, 'LÍDER ADMINISTRATIVO Y FINANCIERO', 1),
(5, 'COORDINADOR COMERCIAL', 1),
(6, 'COORDINADOR ADMINISTRATIVO Y FINANCIERO', 1),
(7, 'COORDINADOR DE CONTABILIDAD', 1),
(8, 'FACILITADOR DE INTEGRACIÓN', 1),
(9, 'FACILITADOR DE CIRCUITOS', 1),
(10, 'FACILITADOR DE TECLADOS', 1),
(11, 'FACILITADOR DE MANTENIMIENTO', 1),
(12, 'FACILITADOR DE GESTIÓN TÉCNICA', 1),
(13, 'FACILITADOR DE INGENIERÍA', 1),
(14, 'FACILITADOR DE PROCESOS', 1),
(15, 'FACILITADOR DE COMPRAS', 1),
(16, 'FACILITADOR DE COMPRAS Y COMERCIO INTERNACIONAL', 1),
(17, 'FACILITADOR DE ALMACÉN', 1),
(18, 'FACILITADOR DE CONTABILIDAD', 1),
(19, 'FACILITADOR DE DISEÑO ELECTRONICO', 1),
(20, 'FACILITADOR COMERCIAL INTERNO', 1),
(21, 'FACILITADOR COMERCIAL EXTERNO', 1),
(22, 'FACILITADOR COMUNICACIONES', 1),
(23, 'FACILITADOR DE CONTROL CALIDAD', 1),
(24, 'FACILITADOR DE GESTION HUMANA Y SST', 1),
(25, 'AUXILIAR DE COMUNICACIONES', 1),
(26, 'AUXILIAR DE MEJORA CONTINUA', 1),
(27, 'AUXILIAR DE CONTABILIDAD', 1),
(28, 'AUXILIAR DE PRODUCCIÓN', 1),
(29, 'AUXILIAR DE FACTURACIÓN', 1),
(30, 'AUXILIAR DE GESTIÓN TÉCNICA', 1),
(31, 'AUXILIAR COMERCIAL', 1),
(32, 'AUXILIAR DE CONTROL CALIDAD', 1),
(33, 'AUXILIAR DE GH Y SST', 1),
(34, 'AUXILIAR DE MANTENIMIENTO', 1),
(35, 'OPERARIO DE PRODUCCIÓN', 1),
(36, 'OPERARIO DE SERVICIOS GENERALES', 1),
(37, 'OPERARIO MENSAJERO', 1),
(38, 'INGENIERO DE DESARROLLO', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clasificacion_contable`
--

CREATE TABLE `clasificacion_contable` (
  `idClasificacion_contable` tinyint(4) NOT NULL,
  `clasificacion` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `clasificacion_contable`
--

INSERT INTO `clasificacion_contable` (`idClasificacion_contable`, `clasificacion`, `estado`) VALUES
(1, 'INVEST - DERROLLO E INNOVACION', 1),
(2, 'COLCIRCUITOS ADMON', 1),
(3, 'COLCIRCUITOS VENTAS', 1),
(4, 'COLCIRCUITOS MOD', 1),
(5, 'COLCIRCUITOS MO INDIRECTA', 1),
(6, 'APRENDIZ', 1),
(7, 'N/A', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clasificacion_mega`
--

CREATE TABLE `clasificacion_mega` (
  `idClasificacion_mega` tinyint(4) NOT NULL,
  `clasificacion` varchar(3) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `clasificacion_mega`
--

INSERT INTO `clasificacion_mega` (`idClasificacion_mega`, `clasificacion`, `estado`) VALUES
(1, 'A', 1),
(2, 'A2', 1),
(3, 'B', 1),
(4, 'B1', 1),
(5, 'B2', 1),
(6, 'C', 1),
(7, 'C1', 1),
(8, 'C2', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `concepto`
--

CREATE TABLE `concepto` (
  `idConcepto` tinyint(4) NOT NULL,
  `concepto` varchar(20) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `concepto`
--

INSERT INTO `concepto` (`idConcepto`, `concepto`, `estado`) VALUES
(1, 'Cita Medica', 1),
(2, 'Estudio', 1),
(3, 'Diligencia Hijos', 1),
(4, 'Compensatorio', 1),
(5, 'Legales', 1),
(6, 'Calamidad Domestica', 1),
(7, 'Otras causas', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `idConfiguracion` tinyint(4) NOT NULL,
  `nombre` varchar(60) NOT NULL DEFAULT '-',
  `hora_ingreso_empresa` time NOT NULL,
  `hora_salida_empresa` time NOT NULL,
  `hora_inicio_desayuno` time NOT NULL,
  `hora_fin_desayuno` time NOT NULL,
  `hora_inicio_almuerzo` time NOT NULL,
  `hora_fin_almuerzo` time NOT NULL,
  `tiempo_desayuno` time NOT NULL,
  `tiempo_almuerzo` time NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`idConfiguracion`, `nombre`, `hora_ingreso_empresa`, `hora_salida_empresa`, `hora_inicio_desayuno`, `hora_fin_desayuno`, `hora_inicio_almuerzo`, `hora_fin_almuerzo`, `tiempo_desayuno`, `tiempo_almuerzo`, `estado`) VALUES
(1, 'Primer horario laboral', '06:00:00', '16:30:00', '08:20:00', '09:31:00', '09:35:00', '13:15:00', '00:20:00', '00:40:00', 1),
(2, 'Segundo horario laboral', '10:55:00', '20:00:00', '11:00:00', '14:00:00', '17:00:00', '19:00:00', '00:15:00', '00:40:00', 1),
(3, 'Horario de los sabados', '06:00:00', '12:00:00', '08:30:00', '09:30:00', '10:00:00', '10:00:02', '00:15:00', '00:00:00', 1),
(4, 'Prueba de desarrollo', '19:00:00', '11:30:00', '06:30:00', '09:30:00', '10:30:00', '12:00:00', '00:20:00', '00:40:00', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `diagnostico`
--

CREATE TABLE `diagnostico` (
  `idDiagnostico` varchar(4) NOT NULL,
  `diagnostico` varchar(120) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `diagnostico`
--

INSERT INTO `diagnostico` (`idDiagnostico`, `diagnostico`, `estado`) VALUES
('A000', 'hushuzy', 0),
('A060', 'DISENTERIA AMEBIANA AGUDA', 1),
('A083', 'OTRAS ENTERITIS VIRALES', 1),
('A09X', 'DIARREA Y GASTROENTERITIS DE PRESUNTO ORIGEN INFEC', 1),
('B349', 'INFECCION VIRAL, NO ESPECIFICADA', 1),
('G439', 'MIGRAÑA, NO ESPECIFICADA', 1),
('G442', 'CEFALEA DEBIDA A TENSION', 1),
('G448', 'OTROS SINDROMES DE CEFALEA ESPECIFICADOS', 1),
('H000', 'ORZUELO Y OTRAS INFLAMACIONES PROFUNDAS DEL PARPAD', 1),
('J00X', 'RINOFARINGITIS AGUDA (RESFRIADO COMUN)', 1),
('J012', 'SINUSITIS ETMOIDAL AGUDA', 1),
('J019', 'SINUSITIS AGUDA, NO ESPECIFICADA', 1),
('K103', 'ALVEOLITIS DEL MAXILAR', 1),
('K30X', 'DISPEPSIA', 1),
('K529', 'COLITIS Y GASTROENTERITIS NO INFECCIOSAS, NO ESPEC', 1),
('K589', 'SINDROME DEL COLON IRRITABLE SIN DIARREA', 1),
('L028', 'ABSCESO CUTANEO, FURUNCULO Y ANTRAX DE OTROS SITIO', 1),
('L031', 'CELULITIS DE OTRAS PARTES DE LOS MIEMBROS', 1),
('M238', 'OTROS TRASTORNOS INTERNOS DE LA RODILLA', 1),
('M239', 'TRASTORNOS INTERNO DE LA RODILLA, NO ESPECIFICADO', 1),
('M255', 'DOLOR EN ARTICULACION', 1),
('M624', 'CONTRACTURA MUSCULAR', 1),
('N390', 'INFECCION DE VIAS URINARIAS, SITIO NO ESPECIFICADO', 1),
('O16X', 'HIPERTENSION MATERNA, NO ESPECIFICADA', 1),
('O231', 'INFECCION DE LA VEJIGA URINARIA EN EL EMBARAZO', 1),
('O233', 'INFECCION DE OTRAS PARTES DE LAS VIAS URINARIAS EN', 1),
('O268', 'OTRAS COMPLICACIONES ESPECIFICADAS RELACIONADAS CO', 1),
('O800', 'PARTO UNICO ESPONTANEO, PRESENTACION CEFALICA DE V', 1),
('R102', ' DOLOR PELVICO Y PERINEAL', 1),
('R104', 'OTROS DOLORES ABDOMINALES Y LOS NO ESPECIFICADOS', 1),
('R42X', 'MAREO Y DESVANECIMIENTO', 1),
('R509', 'FIEBRE, NO ESPECIFICADA', 1),
('R51X', 'CEFALEA', 1),
('R520', 'DOLOR AGUDO', 1),
('S341', 'OTRO TRAUMATISMO DE LA MEDULA ESPINAL LUMBAR', 1),
('S834', 'ESGUINCES Y TORCEDURAS QUE COMPROMETEN LOS LIGAMEN', 1),
('S835', 'ESGUINCES Y TORCEDURAS QUE COMPROMETEN EL LIGAMENT', 1),
('S836', 'ESGUINCES Y TORCEDURAS DE OTRAS PARTES Y LAS NO ES', 1),
('T07X', 'TRAUMATISMOS MULTIPLES, NO ESPECIFICADOS', 1),
('T110', 'TRAUMATISMOS SUPERFICIAL DE MIEMBRO SUPERIOR, NIVE', 1),
('Z048', 'EXAMEN Y OBSERVACION POR OTRAS RAZONES ESPECIFICAD', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dias_festivos`
--

CREATE TABLE `dias_festivos` (
  `iddias_festivos` int(11) NOT NULL,
  `nombre` varchar(60) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL,
  `fecha_dia` date NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `dias_festivos`
--

INSERT INTO `dias_festivos` (`iddias_festivos`, `nombre`, `fecha_dia`, `estado`) VALUES
(2, 'Primer día de reyes', '2018-10-08', 1),
(3, 'Segundo día de reyes', '2018-10-09', 1),
(4, 'Día de todos los santos', '2018-11-05', 1),
(5, 'Independencia de Cartagena', '2018-11-12', 1),
(6, 'Inmaculada concepción', '2018-12-08', 1),
(7, 'Navidad', '2018-12-25', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

CREATE TABLE `empleado` (
  `documento` varchar(20) NOT NULL,
  `nombre1` varchar(45) NOT NULL,
  `nombre2` varchar(45) DEFAULT NULL,
  `apellido1` varchar(45) NOT NULL,
  `apellido2` varchar(45) DEFAULT NULL,
  `genero` tinyint(4) NOT NULL,
  `huella1` smallint(6) DEFAULT NULL,
  `huella2` smallint(6) DEFAULT NULL,
  `huella3` smallint(6) DEFAULT NULL,
  `correo` varchar(50) DEFAULT NULL,
  `contraseña` varchar(50) NOT NULL,
  `idEmpresa` tinyint(4) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `idRol` tinyint(4) DEFAULT '2',
  `asistencia` tinyint(1) NOT NULL DEFAULT '0',
  `piso` varchar(1) NOT NULL DEFAULT '4',
  `fecha_expedicion` varchar(10) NOT NULL DEFAULT '',
  `lugar_expedicion` varchar(50) NOT NULL DEFAULT '',
  `fecha_registro` date NOT NULL,
  `idManufactura` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empleado`
--

INSERT INTO `empleado` (`documento`, `nombre1`, `nombre2`, `apellido1`, `apellido2`, `genero`, `huella1`, `huella2`, `huella3`, `correo`, `contraseña`, `idEmpresa`, `estado`, `idRol`, `asistencia`, `piso`, `fecha_expedicion`, `lugar_expedicion`, `fecha_registro`, `idManufactura`) VALUES
('1000633612', 'daniel', '', 'grajales', 'bernal', 1, 0, 0, 0, 'danigb24@gmail.com', 'MDIyNA==', 1, 1, 2, 0, '2', '26/01/2018', 'Rio Negro', '2019-03-26', 9),
('1001545147', 'alex', 'alfonso', 'ospina', 'fonnegra', 1, 0, 0, 0, 'alexfonnegra04@gmail.com', 'OTk5OQ==', 1, 1, 1, 1, '2', '12-2-2015', 'Gomez plata', '2018-12-17', 0),
('1006887114', 'Luiggy ', 'Jose ', 'Jimenez', 'Montes ', 1, 0, 0, 0, 'ljosejimenez@uniguajira.edu.co', 'MTMwMQ==', 1, 0, 1, 1, '4', '19/01/2009', 'Maicao', '2018-08-29', 0),
('1007110815', 'Nedis', 'Omaris', 'Chavarria', '', 0, 0, 0, 0, 'sarachavarria020@gmail.com', 'MDExOQ==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1007310520', 'beatriz ', 'elena ', 'beltrán ', 'bedoya ', 0, 0, 0, 0, 'beatrizbeltranbedoya123@hotmail.com', 'MTcwMg==', 1, 0, 1, 1, '5', '2000-01-01', 'Pendiente', '2018-08-29', 0),
('1013537192', 'santiago ', '', 'villa', 'torres', 1, 0, 0, 0, 'santiagovillat@gmail.com', 'c3Z0NQ==', 1, 1, 1, 1, '4', '12/12/2010', 'medellin', '2018-08-29', 17),
('1017125039', 'erika', 'yojana', 'jaramillo', 'zapata', 0, 0, 0, 0, 'erikaz12@hotmail.com', 'MDkxMw==', 3, 1, 1, 1, '5', '2000-01-01', 'Pendiente', '2018-08-29', 0),
('1017132272', 'Elizabeth ', '', 'Pulgarin', 'Álvarez ', 0, 0, 0, 0, 'elizabethlero@outlook.com', 'MjE3NA==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1017137065', 'john', 'jairo', 'lopez', 'colorado', 1, 0, 0, 0, 'johnbis86@hotmail.com', 'MTAxMg==', 2, 0, 1, 0, '4', '13/09/1986', 'Medellin', '2018-08-29', 0),
('1017147712', 'Jorge', 'Alejandro', 'Arias', 'Guerrero', 1, 0, 0, 0, 'fonealejo88@hotmail.com', 'ODg5OQ==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('1017156424', 'Yazmin ', 'Andrea', 'Galeano ', 'Castañeda', 0, 0, 0, 0, 'yazmin1987@gmail.com', 'MTk4Nw==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1017168135', 'Yenifer ', 'Andrea ', 'Jimenez ', 'Montoya', 0, 0, 0, 0, 'andreitajimenez16@hotmail.com', 'MTQ3Mg==', 3, 0, 1, 0, '4', '16/04/2006', 'MEDELLIN', '2018-08-29', 0),
('1017171421', 'Yuliana', '', 'Gómez', 'Roldán', 0, 0, 0, 0, 'yulianagomezroldan@gmail', 'MDcwMg==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1017179570', 'ISABEL', 'CRISTINA', 'ARENAS', 'CORTÉS', 0, 0, 0, 0, 's _hun_ly@hotmail.com', 'UEFTQQ==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1017180882', 'Sandra ', 'Yorley', 'Rincón ', 'Cifuentes ', 0, 0, 0, 0, 'sandritalamejor.22@gmail.com', 'MjAyMg==', 2, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1017187557', 'CATALINA', '', 'TABORDA', '', 0, 0, 0, 0, 'cata-labien@hotmail.com', 'MTIxOA==', 3, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('1017197869', 'Ximena', 'Catalina', 'Hinestroza', 'Ortega', 0, 0, 0, 0, 'otracata@gmail.com', 'c2duMQ==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('1017208475', 'mariana', '', 'cortés', 'ramirez', 0, 0, 0, 0, 'mariana.cortes@colcircuitos.com', 'MDYwMg==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('1017212362', 'Sindy', 'Johanna', 'Cano', 'Rojas', 0, 0, 0, 0, 'sindycanorojas@gmail.com', 'MjIwNw==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1017216447', 'luis ', 'andres', 'arboleda', 'higuita', 1, 0, 0, 0, 'luis.andreslds@hotmail.com', 'MzE3OQ==', 3, 0, 1, 1, '4', '17/03/1993', 'Medellín', '2018-08-29', 0),
('1017219391', 'juan ', 'guillermo', 'sucerquia', 'velle', 1, 0, 0, 0, 'juanguillermo1994@hotmail.com', 'anU5NA==', 1, 1, 1, 0, '4', '23/05/2013', 'Medellin', '2018-08-29', 21),
('1017225857', 'Sebastian', '', 'López', 'Camacho', 1, 0, 0, 0, 'lopex08@hotmail.com', 'NTM4NA==', 3, 1, 1, 1, '4', '11/12/2012', 'Medellin ', '2018-08-29', 0),
('1017239142', 'Jaime', 'Omeiber', 'Velasquez', 'Madrid', 1, 0, 0, 0, 'jaimemadrid640@gmail.com', 'OTE0Mg==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1017240253', 'Julian ', '', 'Rivera', 'Rojas', 1, 0, 0, 0, 'julianr.rojas@hotmail.com', 'MjM3MQ==', 2, 0, 2, 0, '4', '06/10/2014', 'Medellin', '2018-08-29', 0),
('1020430141', 'Miguel', 'Alberto', 'Salazar', 'Loaiza', 1, 0, 0, 0, 'miguelbettoo@gmail.com', 'MDYxNQ==', 3, 0, 1, 0, '4', '04/04/1990', 'Bello', '2018-08-29', 0),
('1020432053', 'Natalia', '', 'Molina', 'Giraldo', 0, 0, 0, 0, 'natissm17@gmail.com', 'MTcyOA==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1020446405', 'carolina', '', 'gómez ', 'gómez ', 0, 0, 0, 0, 'carolinagomez9112@gmail.com', 'MTIwMg==', 5, 1, 2, 0, '2', '12/03/1993', 'Mmedellín', '2018-08-29', 0),
('1020457057', 'daniela', 'alejandra ', 'salazar', ' loaiza', 0, 0, 0, 0, 'daniela19942009@hotmail.es', 'MTgxOA==', 1, 1, 1, 1, '4', '12/12/2012', 'MEDELLIN', '2018-08-29', 0),
('1020464577', 'sara', 'maria', 'aguirre', 'salazar', 0, 0, 0, 0, 'saraaguirres1994@gmail.com', 'NjI3OA==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1020479554', 'Sebastian', '', 'Gallego', 'Perez', 1, 0, 0, 0, 'gallegosebastian11042014@gmail.com', 'Nzg3NA==', 1, 1, 1, 0, '4', '', '', '2018-08-29', 0),
('1022096414', 'manuel', '', 'posada ', 'calderon', 1, 0, 0, 0, 'manuel3811@hotmail.com', 'MjAxMA==', 4, 1, 2, 0, '2', '28/06/2010', 'Antioquia', '2018-08-29', 0),
('1025632', 'Carlos', 'Ramiro', 'Gómez', 'Perez', 1, 0, 0, 0, '', 'MTIyNQ==', 3, 0, 1, 0, '4', '21/05/2014', 'Medellín', '2018-08-29', 0),
('1026157576', 'BRAYAN', '', 'RESTREPO', 'COSSIO', 1, 0, 0, 0, 'brayan_97r@hotmail.com', 'MDM4OA==', 3, 0, 1, 0, '1', '', '', '2018-08-29', 0),
('1028009266', 'Leanis', 'Natalia', 'Cordoba', 'Teran', 0, 0, 0, 0, 'leanis.cordoba@colcircuitos.com', 'MjQxNQ==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('1028016893', 'alejandra', '', 'usuga', 'rivera', 0, 0, 0, 0, 'aleja.2503@hotmail.com', 'MjUwMw==', 1, 1, 2, 0, '2', '01/06/2010', 'MEDELLIN', '2018-08-29', 0),
('1035232892', 'LUISA', 'FERNANDA', 'GAVIRIA', 'SUAREZ', 0, 0, 0, 0, 'fgaviria46@gmail.com', 'MTExNw==', 3, 0, 2, 0, '4', '04/08/2014', 'BARBOSA', '2018-08-29', 0),
('1035427628', 'Jesús ', 'Alberto', 'Giraldo', 'Echevarría ', 1, 0, 0, 0, 'jgiraldo42@gmail.com', 'MjAwMw==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1035879778', 'wilmar', '', 'palacios', 'castaño', 1, 0, 0, 0, 'WILMARPALACIOS98@GMAIL.COM', 'NTY3OA==', 1, 0, 1, 0, '4', '12/05/2017', 'Girardota', '2018-08-29', 0),
('1035915735', 'Leidy', 'Tatiana', 'Jaramillo', 'Zapata', 0, 0, 0, 0, 'tatianajz-1601@hotmail.com', 'NzQyNA==', 1, 1, 1, 0, '4', '', '', '2018-08-29', 0),
('1036598684', 'lina ', 'marcela ', 'galeano ', 'morales ', 0, 0, 0, 0, 'lmgm1230@gmail.com', 'MDIyNw==', 1, 1, 1, 1, '5', '01/04/2004', 'ITAGUI', '2018-08-29', 0),
('1036601013', 'lady', 'johanna', 'puerta', 'acevedo', 0, 0, 0, 0, 'leidypuerta173@gmail.com', 'MTgwMg==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1036609702', 'Liliana', 'Andrea', 'Rendon', 'Caicedo', 0, 0, 0, 0, 'lianrendon@gmail.com', 'MTkzMg==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1036612156', 'jhonatan ', '', 'gómez ', 'cano ', 1, 0, 0, 0, 'jhonatan', 'MTcxMg==', 3, 0, 1, 0, '4', '21/12/2005', 'Itagui', '2018-08-29', 0),
('1036622270', 'LINA ', 'JOHANNA', 'YEPES', 'RIOS', 0, 0, 0, 0, 'Linayepesrios2403@gmail.com', 'TElOQQ==', 3, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('1036625052', 'carlos', 'alberto', 'rodriguez', 'pulgarin', 1, 0, 0, 0, 'albertico2319@gmail.com', 'NTI3OA==', 1, 1, 1, 1, '4', '10-08-2007', 'itagui', '2019-01-28', 0),
('1036625105', 'Deisy', 'Johana', 'Alvarez', 'Toro', 0, 0, 0, 0, 'dejoalto@gmail.com', 'Mjc5Mw==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('1036629003', 'evelin ', 'andrea', 'cano', 'muñoz', 0, 0, 0, 0, 'evelincano1989@gmail.com', 'MTEwOQ==', 1, 1, 1, 0, '1', '15/02/2009', 'Envigado', '2018-08-29', 21),
('1036634996', 'Simón', 'David', 'Muñetones', 'Morales', 1, 0, 0, 0, 'simon.munetones@tecrea.com.co', 'MDgxMg==', 4, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1036650501', 'Daniela', '', 'Giraldo', 'Arias', 0, 0, 0, 0, 'danigir29@hotmail.com', 'MDEyOQ==', 1, 1, 2, 0, '1', '06-02-2012', 'Itagui', '2019-02-05', 0),
('1036651097', 'cristian ', 'camilo', 'molina', 'bernal', 1, 0, 0, 0, 'cristianmolinab121@gmail.com', 'OTMxMg==', 1, 1, 1, 1, '4', '20-03-2000', 'itagui', '2018-08-29', 0),
('1036680551', 'Laura', '', 'Hernandez', 'Caicedo', 0, 0, 0, 0, 'laurahc812@gmail.com', 'MDcxNQ==', 3, 0, 1, 1, '4', '26/02/2016', 'Itagui', '2018-08-29', 0),
('1037581069', 'Humberto', '', 'Urrego', 'Pino', 1, 0, 0, 0, 'hurpi87@hotmail.com', 'aHUxNQ==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1037587834', 'heidy', 'jhoana', 'marulanda', 'restrepo', 0, 0, 0, 0, 'jhoana0425@hotmail.com', 'NzgzNA==', 1, 1, 1, 1, '4', '02/08/2000', 'Envigado', '2018-08-29', 0),
('1037606721', 'luis', 'manuel', 'ochoa', 'henao', 1, 0, 0, 0, 'luisma78910@gmail.com', 'bG05MA==', 1, 1, 2, 0, '4', '20-03-2000', 'medellin', '2018-08-29', 0),
('1037616343', 'julian', '', 'bustamante ', 'narvaez ', 1, 0, 0, 0, 'thejbte@gmail.com', 'Mjg3OQ==', 4, 1, 2, 0, '3', '16-01-2000', 'Medellin', '2019-02-01', 0),
('1037631569', 'Julian', 'Esteban', 'Ramirez', 'Lopez', 1, 0, 0, 0, 'julian-2365@hotmail.com', 'MTEwNA==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1037949573', 'yuliana ', 'marcela ', 'jaramillo', 'zapata ', 0, 0, 0, 0, 'yulianamarcelaj@gmail.com', 'c2Fsbw==', 3, 1, 1, 1, '1', '16/01/2015', 'San Carlos ', '2018-08-29', 0),
('1037949696', 'lady', 'geraldyn', 'gonzalez', 'ceballos', 0, 0, 0, 0, 'geral16gonza@gmail.com', 'MjQwOA==', 1, 1, 1, 1, '5', '11/12/2013', 'MEDELLIN', '2018-08-29', 0),
('1039049115', 'ruben', 'dario', 'quirama', 'lopez', 1, 0, 0, 0, 'rubenkra@outlook.es', 'MTk5MQ==', 1, 1, 1, 1, '5', '2000-01_01', 'Pendiente', '2018-08-29', 0),
('1039447684', 'Maria', 'Vanessa', 'García ', 'Gaviria', 0, 0, 0, 0, 'mariva2710@gmail.com', 'dmFuZQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1039457744', 'esteban', 'luis', 'hernández ', 'meza', 1, 0, 0, 0, 'estebanluishernandezmeza@gmail.com', 'MTMwMg==', 3, 0, 1, 0, '4', '11-11-1998', 'medellin', '2018-08-29', 0),
('1039464479', 'Camila', '', 'Aristizábal', 'Gómez', 0, 0, 0, 0, 'camila.aristizabal@tecrea.com.co', 'MTcwNQ==', 4, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1040044905', 'josé ', 'daniel', 'grajales', 'carmona', 1, 0, 0, 0, 'josegraja@hotmail.com', 'MTAxOA==', 1, 1, 1, 0, '4', '11-11-1998', 'La ceja', '2018-08-29', 0),
('1040757557', 'kevin ', 'daniel', 'meneses', 'ceballos', 1, 0, 0, 0, 'daniel271098@hotmail.com', 'MjcxMA==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1041151150', 'juan', 'pablo', 'vélez', 'arroyave', 1, 0, 0, 0, 'velezarroyave@gmail.com', 'MjYxMw==', 1, 0, 1, 0, '4', '16/08/1897', 'MEDELLIN', '2018-08-29', 0),
('1044915764', 'JACKSON', '', 'AVILA', 'PAEZ', 1, 0, 0, 0, 'jackpower@hotmail.es', 'MjAxNg==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1046913982', 'ELIZABETH', '', 'URIBE', 'CEBALLOS', 0, 0, 0, 0, 'elizabethuribe033@hotmail.es', 'MjIyMw==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('1053769411', 'Carlos', 'Mario', 'Marin', 'Londoño', 1, 0, 0, 0, 'mario9411@hotmail.com', 'OTQxMQ==', 2, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1066743123', 'Oscar', 'De Jesús ', 'Causil', 'Montiel', 1, 0, 0, 0, 'oscarcmwork@hotmail.com', 'NzMxMA==', 2, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1077453248', 'arnold', 'david', 'chala', 'rivas', 1, 0, 0, 0, 'arnoldvip@hotmail.com', 'MDQwOQ==', 1, 1, 1, 1, '5', '12/12/2011', 'MEDELLIN', '2018-08-29', 0),
('1078579715', 'maiber', 'david', 'gonzalez ', 'mercado', 1, 0, 0, 0, 'mader145@HOTMAI.com', 'MDMxNQ==', 1, 0, 2, 0, '4', '14/05/1989', 'MEDELLIN', '2018-08-29', 0),
('1090523316', 'faiber', 'omar', 'atuesta', 'garcia', 1, 0, 0, 0, 'faiberatuesta@gmail.com', 'MTAxMw==', 1, 1, 1, 0, '4', '13/10/1998', 'Cucuta', '2018-08-29', 0),
('1095791547', 'diego', 'armando', 'lopez', 'moreno', 1, 0, 0, 0, 'bukacats@hotmail.com', 'ODYxOQ==', 1, 1, 1, 1, '1', '2000-01-10', 'Pendiente', '2018-08-29', 0),
('1096238261', 'Kelly', 'María', 'Villazón', 'Ramírez', 0, 0, 0, 0, 'kellyvillazon1@gmail.com', 'MTUzMQ==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('1125779563', 'JOSE', 'FERNANDO', 'ARBOLEDA', 'RAMIREZ', 1, 0, 0, 0, 'josefernando870@gmail.com', 'MDk4Nw==', 4, 1, 2, 0, '3', '', '', '2018-08-29', 0),
('1128266934', 'Jhon', 'Fredy', 'Velez', 'Londoño', 1, 0, 0, 0, 'fredy.velez@colcircuitos.com', 'MDkyNA==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1128267430', 'Carolina', '', 'Betancur', 'Zapata', 0, 0, 0, 0, 'carolina.betancur@colcircuitos.com', 'MTk4Ng==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1128390700', 'alexander ', 'de jesús ', 'osorio', 'quintero', 1, 0, 0, 0, 'alex-8881@hotmail.com', 'ODg4OA==', 1, 0, 1, 1, '1', '2000-01-01', 'Pendiente', '2018-08-29', 0),
('1128405581', 'jorge', 'luis', 'velasquez', 'rendon', 1, 0, 0, 0, 'jorgeluisvelasquez1987@gmail.com', 'MDcxNw==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1128422071', 'Daniel', 'Francisco', 'Calderon', 'Lebro', 1, 0, 0, 0, 'lebro.daniel@gmail.com', 'MTgwNw==', 2, 0, 1, 0, '4', '25/07/2007', 'Medellín ', '2018-08-29', 0),
('1128430240', 'Christian', 'Camilo', 'Lara', 'Villa', 1, 0, 0, 0, 'km1lo8958@gmail.com', 'MTQxMg==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1128447453', 'Monica', 'Alejandra', 'Madrid ', 'Munera', 0, 0, 0, 0, 'monikmadrid67@gmail.com', 'MjEyOA==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1128450516', 'carolina', '', 'salinas', 'restrepo', 0, 0, 0, 0, 'palacio.2125@hotmail.com', 'MTI4OQ==', 2, 0, 1, 0, '4', '23/08/2007', 'MEDELLIN', '2018-08-29', 0),
('1129045994', 'Jadder', 'Andres', 'Manyoma', 'Moreno', 1, 0, 0, 0, 'andres_elchikomoreno@hotmail.com', 'MjgwMQ==', 1, 0, 1, 0, '4', '28/01/1997', 'Unión Panamericana ', '2018-08-29', 0),
('1143366120', 'MARTIN ', '', 'PEREZ', 'BELLO', 1, 0, 0, 0, 'martinperez0421@gmail.com', 'MDQyMQ==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1143991147', 'estefania ', '', 'lopez', 'beltran', 0, 0, 0, 0, 'stefaniialopez.dylan.123@gmail.com', 'MTE0Mw==', 1, 1, 1, 1, '5', '2000-01-01', 'Pendiente', '2018-08-29', 0),
('1152195364', 'Susana ', '', 'Escobar ', 'Alearcón', 0, 0, 0, 0, 'susana.escobar@hotmail.es', 'NTM5Mg==', 5, 1, 2, 0, '2', '05-04-2010', 'Medellín', '2019-04-22', 9),
('1152206404', 'CAROLINA ', 'MARIA ', 'GOMEZ ', 'PEREZ', 0, 0, 0, 0, 'carogomez_94@hotmail.com', 'NTA2MA==', 4, 1, 2, 0, '3', '25/10/2012', 'MEDELLIN', '2019-01-11', 0),
('1152210828', 'Paula', 'Andrea', 'Herrera', 'Alvarez', 0, 0, 0, 0, 'pau3018@hotmail.com', 'MTk5NQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('1152450553', 'juan', 'pablo', 'gonzalez', 'castrillon', 1, 0, 0, 0, 'jpgc17@hotmail.com', 'MzI0OQ==', 1, 1, 1, 1, '4', '12-12-2000', 'Medellín', '2018-08-29', 0),
('1152697088', 'diana', 'marcela', 'patiño', 'cardona', 0, 0, 0, 0, 'diana.patino@colcircuitos.com', 'OTQyMg==', 1, 1, 2, 0, '4', '27/11/2012', 'Medellin', '2018-08-29', 0),
('1152701919', 'ANDERSON', '', 'ASPRILLA ', 'AGUILAR', 1, 0, 0, 0, 'ANDERSON-ASPRILLA@HOTMAIL.COM', 'MTQxNA==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('1214721942', 'KELLY', 'DIANETH', 'GAVIRIA', 'TOBÓN', 0, 0, 0, 0, 'kelly1993gaviria@hotmail.com', 'MTIxNw==', 3, 0, 1, 0, '1', '', '', '2018-08-29', 0),
('1214723132', 'yundry', 'tatiana', 'gomez', 'yagari', 0, 0, 0, 0, 'tatisgomez3017@gmail.com', 'MTk5Mg==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1214734202', 'Paula ', 'Marcela ', 'Noreña ', 'Jimenez ', 0, 0, 0, 0, 'paulita.1301@hotmail.com', 'MDcyMQ==', 3, 1, 2, 0, '2', '21/05/2014', 'Medellin', '2018-11-07', 0),
('1216714526', 'Juan', '', 'Miranda', 'Aristizabal', 1, 0, 0, 0, 'juansma1004@hotmail.com', 'MTAwNA==', 3, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('1216714539', 'Maria ', 'Alejandra', 'Zuluaga', 'Rivera', 0, 0, 0, 0, 'alejandra.zuluaga@colciercuitos.com', 'MTIxNg==', 1, 1, 2, 0, '2', '27/12/2011', 'MEDELLIN', '2018-08-29', 0),
('1216716458', 'sebastian', '', 'ramirez', 'corral', 1, 0, 0, 0, 'sebastos7d@gmail.com', 'ODg3OA==', 1, 1, 1, 1, '4', '03/09/2012', 'Medellín', '2018-08-29', 0),
('1216718503', 'Kelly', 'Jhoana', 'Zapata', 'Hoyos', 0, 0, 0, 0, 'kelly-08-@hotmail.com', 'MjgwOA==', 3, 0, 1, 0, '1', '29/08/2013', 'Medellin', '2018-08-29', 0),
('1216727816', 'juan', 'david', 'marulanda', 'paniagua', 1, 0, 0, 0, 'jdmarulanda0@gmail.com', 'MTIzNA==', 1, 1, 1, 0, '2', '2016-12-14', 'Medellin', '2018-11-02', 11),
('15489896', 'ludimer', 'de jesus', 'urrego', 'durango', 1, 0, 0, 0, 'luguilugui82@outloock.es', 'MTU0OA==', 1, 1, 1, 1, '5', '05/02/1999', 'Urrao', '2018-08-29', 0),
('15489917', 'Aicardo', 'Alexander', 'Montoya', 'Perez', 1, 0, 0, 0, 'alexmontoyap@yahoo.es', 'ODI1Nw==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('15515649', 'Andres', 'Felipe', 'Tobon', 'Gonzalez', 1, 0, 0, 0, 'atobongonzalez@gmail.com', 'MjgxMg==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('21424773', 'beatriz', 'elena', 'urrego', 'montes', 0, 0, 0, 0, 'bety-manuelita@hotmail.com', 'MDUwNQ==', 1, 1, 1, 0, '4', '', '', '2018-08-29', 0),
('23917651', 'Dianneli', 'Patricia', 'Duran', 'Torres', 0, 0, 0, 0, 'dianneliduran22@gmail.com', 'MjIwMw==', 3, 1, 1, 0, '4', '05/04/2013', 'Venezuela ', '2018-08-29', 0),
('26201420', 'Carmen', 'Milagro', 'Alvarez', 'Estrada', 0, 0, 0, 0, 'carmen15-17@hotmail.com', 'MTUxNw==', 1, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('32242675', 'Liliana', 'Maria', 'Restrepo', 'Ortíz', 0, 0, 0, 0, 'liliana.restrepo@colcircuitos.com', 'MjQxMg==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('32353491', 'janeth', 'viviana ', 'agudelo', 'zapata', 0, 0, 0, 0, 'janevia_0802@yahoo.es', 'NTUwOA==', 5, 1, 1, 1, '5', '2000-01-01', 'Pendiente', '2018-08-29', 0),
('42702332', 'mary', 'ladis', 'sanchez', 'sepulveda', 0, 0, 0, 0, 'maryladiz1501@gmail.com', 'MTYwMg==', 1, 1, 1, 1, '4', '20-03-2000', 'medellin', '2018-08-29', 0),
('43161988', 'Yudi ', 'Andrea', 'Espinal ', 'López', 0, 0, 0, 0, 'yudyandreaespinal@hotmail.com', 'MDcxMA==', 5, 1, 2, 0, '1', '09/12/1995', 'Itagui', '2019-02-18', 13),
('43189198', 'Doreley', '', 'Garcia', '', 0, 0, 0, 0, 'garciadoreley@gimail.com', 'ODA4MA==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('43263856', 'Paula ', 'Andrea', 'Lopez', 'Gutierrez', 0, 0, 0, 0, 'paulalopez.tdingenieria@gmail.com', 'MjAxNw==', 1, 1, 2, 0, '4', '19/03/1999', 'Medellín', '2019-01-25', 0),
('43265824', 'alexandra', 'maria', 'palacio', 'ramirez', 0, 0, 0, 0, 'alexandra.814@hotmail.com', 'MDgxNA==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('43271378', 'Aracelly', '', 'Ospina', 'Rodriguez', 0, 0, 0, 0, 'aracellyospina@gmail.com', 'MjMwOQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('43288005', 'erika', 'natalia', 'ossa', 'ossa', 0, 0, 0, 0, 'naty0ossa@gmail.com', 'MTMyNw==', 1, 1, 1, 1, '1', '2000-01-01', 'Pendiente', '2018-08-29', 0),
('43342456', 'MARIA', 'EUYENITH', 'DURANGO', 'LARREA', 0, 0, 0, 0, 'mdurangolar@uniminuto.edu.co', 'NTU0NA==', 3, 0, 1, 0, '4', '24/01/1987', 'Urrao', '2018-08-29', 0),
('43542658', 'Rosalba ', '', 'Morales', 'Arenas ', 0, 0, 0, 0, 'equilibrio_rma@yahoo.es', 'NDM1NA==', 1, 1, 1, 1, '4', '14/12/1989', 'Medellin', '2018-12-11', 0),
('43583398', 'VIVIANA', '', 'ECHAVARRIA', 'MACHADO', 0, 0, 0, 0, 'viviana@grupoinvertronica.com', 'NzQwMQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('43596807', 'SANDRA ', 'EUGENIA', 'ZULUAGA', 'CARDONA', 0, 0, 0, 0, 'sandrazuluagacardona@gmail.com', 'MDMyMg==', 1, 1, 2, 0, '2', '', '', '2018-08-29', 0),
('43605625', 'nora', '', 'sanchez', 'rivera', 0, 0, 0, 0, 'norasanchezr1808@gmail.com', 'OTcxNw==', 1, 1, 1, 1, '4', '20-03-1993', 'medellin', '2018-08-29', 0),
('43745709', 'DIANA ', '', 'GALLEGO', 'ALVAREZ ', 0, 0, 0, 0, 'dianagallego@hotmail.com', 'MDk0MQ==', 4, 0, 2, 0, '2', '', '', '2018-08-29', 0),
('43749878', 'Gloria', 'Liliana', 'Vélez', 'Pérez', 0, 0, 0, 0, 'administrativa@colcircuitos.com', 'NzQ1OQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('43834287', 'ISABEL', 'CRISTINA', 'BERMUDEZ', 'ACEVEDO', 0, 0, 0, 0, 'acre_isabel@hotmail.com', 'ODU1Ng==', 3, 0, 1, 0, '5', '10/12/1994', 'ITAGUI', '2018-08-29', 0),
('43841319', 'Monica', 'Alexandra ', 'Usma', 'Zapata', 0, 0, 0, 0, 'monicausmazapata@hotmail.com', 'MTIyMQ==', 1, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('43866346', 'sandra ', 'milena ', 'vasquez ', 'villegas ', 0, 0, 0, 0, 'sandravas79@hotmail.com', 'MDIwNQ==', 1, 1, 1, 1, '5', '03/09/1997', 'Envigado', '2018-11-13', 0),
('43975208', 'gloria', 'amparo', 'jaramillo', 'zapata', 0, 0, 0, 0, 'gloria.jaramillo@colcircuitos.com', 'MDUyNQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('44006996', 'juliana', '', 'silva', 'rodelo', 0, 0, 0, 0, 'silvarodelojuliana@gmail.com', 'MDA4NQ==', 3, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('53146320', 'Jackeline ', '', 'Pulgarin', 'Bohorquez', 0, 0, 0, 0, 'jackeline.pulgarin@grupoinvertronica.com', 'bWFpbA==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('54253320', 'elvia', '', 'valoyes', 'cordoba', 0, 0, 0, 0, 'liyimen234@hotmail.com', 'MjgyMw==', 1, 1, 2, 0, '4', '20-03-1987', 'Quibdo', '2018-08-29', 0),
('71055289', 'Jaime ', 'Alberto ', 'Bedoya', 'Garces', 1, 0, 0, 0, 'jaibega25@hotmail.com', 'MWEyYg==', 1, 1, 2, 0, '3', '04-07-2002', 'Betulia', '2019-01-31', 0),
('71267825', 'Manuel', 'Yamid', 'Tangarife', 'Estrada', 1, 0, 0, 0, 'manuelyamid@hotmail.com', 'MzUzNQ==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('71268332', 'Adimaro', '', 'Montoya', 'Toro', 1, 0, 0, 0, 'adimaro.montoya@colcircuitos.com', 'MDIyOQ==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('71387038', 'juan', 'diego', 'villa', 'rojas', 1, 0, 0, 0, 'juandiego317_@hotmail.com', 'MDMxNw==', 2, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('71709575', 'mauricio', '', 'gómez ', 'vera', 1, 0, 0, 0, 'mauriciogomezvera@gmail.com', 'MjUxNg==', 4, 1, 2, 0, '3', '02-09-1987', 'Medellín', '2019-02-06', 18),
('71752141', 'jose', 'sebastian', 'gonzalez', 'sanchez', 1, 0, 0, 0, 'josepsebastian171@yahoo.com', 'MTQ5Mg==', 3, 0, 1, 0, '4', '31/03/1993', 'MEDELLIN', '2018-08-29', 0),
('71759957', 'walter', 'marcelo', 'ramos', 'rueda', 1, 0, 0, 0, 'mr.walter27@gmail.com', 'd3A0Mg==', 3, 0, 1, 0, '4', '20-06-1994', 'medellin', '2018-08-29', 0),
('71765000', 'julio', 'cesar ', 'galeano', 'madrid', 1, 0, 0, 0, 'juio.galeano@colcircuitos.com', 'MTAxMQ==', 1, 1, 2, 0, '3', '12-01-1995', 'Medellín', '2019-02-04', 0),
('71774995', 'Gabriel', 'Jaime', 'Velez', 'Perez', 1, 0, 0, 0, 'gabriel@colcircuitos.com', 'NTQzMw==', 1, 1, 2, 0, '2', '17-09-1995', 'Medellin', '2019-02-06', 12),
('760579', 'higinio', 'alejandro', 'duarte', 'marquez', 1, 0, 0, 0, 'higinio.alejandro@gmail.com', 'MTg2Mg==', 1, 1, 1, 1, '4', '12-01-2000', 'Medellín', '2018-08-29', 0),
('78758797', 'Rafael', 'Eduardo', 'Herrera', 'Mangones', 1, 0, 0, 0, 'rafael.herreram@tecrea.com.co', 'MTk4MA==', 4, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('80145967', 'jonathan', 'alvaro ', 'rojas ', 'beltran ', 1, 0, 0, 0, 'jonathanrb3@hotmail.com', 'ODkzMw==', 3, 1, 1, 1, '4', '10/01/2003', 'Bogotá', '2018-08-29', 0),
('8102064', 'Adrian ', 'Felipe', 'Hernandez', 'Uribe', 1, 0, 0, 0, 'adrian.hernandez@colcircuitos.com', 'NzQ2MQ==', 1, 0, 2, 0, '2', '11/01/2002', 'Medellín', '2019-01-30', 0),
('8106761', 'andres', 'felipe', 'berrio', 'cataño', 1, 0, 0, 0, 'andres.berrio@tecrea.com.co', 'NzU0OA==', 4, 0, 2, 0, '4', '13/06/1895', 'Medellin', '2018-08-29', 0),
('8344177', 'FABIAN', 'aRNULFO', 'VELÉZ', 'MUÑOZ', 1, 0, 0, 0, 'fabianvm@hotmail.com', 'MDYyMQ==', 1, 1, 2, 0, '2', '21/06/1969', 'Envigado', '2019-03-07', 17),
('8355460', 'Juan ', 'Camilo ', 'Herrera ', 'Pineda', 1, 0, 0, 0, 'camherrera837@hotmail.com', 'MTAxMA==', 4, 1, 2, 0, '3', '15/11/2001', 'Envigado', '2018-08-29', 0),
('8433778', 'Fredy', 'Alejandro', 'Montoya', 'Isaza', 1, 0, 0, 0, 'complotminitk@hotmail.com', 'NTcxOQ==', 1, 1, 1, 1, '4', '', '', '2018-08-29', 0),
('9008773200219', 'Sara ', 'Maria ', 'Daboi', 'Ramirez', 0, 0, 0, 0, 'saradaboin@hotmail.com', 'MTMwOQ==', 3, 0, 1, 0, '1', '15/08/2017', 'Medellin', '2018-08-29', 0),
('91279058', 'FABIO', '', 'CUBILLOS', 'VALENCIA', 1, 0, 0, 0, 'gerencia@tecrea.com.co', 'NTkxNQ==', 4, 0, 2, 0, '4', '', '', '2018-08-29', 0),
('955297213061995', 'Maria', 'Angelica', 'Medina', 'Valencia', 0, 0, 0, 0, 'angelicamvalencia22@gmail.com', 'MDMwMg==', 4, 1, 2, 0, '3', '28-12-2018', 'Medellin', '2019-05-02', 0),
('98558437', 'Fabian ', 'Fernando ', 'Vélez', 'Pérez', 1, 0, 0, 0, 'fernando@colcircuitos.com', 'MTQyMg==', 1, 1, 2, 0, '2', '30/07/1990', 'Envigado', '2019-03-13', 12),
('98668402', 'andres', 'felipe', 'graciano', 'pareja', 1, 0, 0, 0, 'andresgp.c2c3@gmail.com', 'ODQwMg==', 1, 1, 1, 1, '1', '1998-01-01', 'Pendiente', '2018-08-29', 0),
('98699433', 'andres', 'camilo', 'buitrago', 'gomez', 1, 0, 0, 0, 'andres.buitrago@colcircuitos.com', 'MjYwOA==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('98713751', 'Luis', 'Alberto', 'Marín', 'Castañeda', 1, 0, 0, 0, 'betbela@gmail.com', 'ODUxNQ==', 2, 0, 1, 0, '4', '', '', '2018-08-29', 0),
('98765201', 'Edisson', 'Andres', 'Barahona', 'Castrillon', 1, 0, 0, 0, 'edisson.barahona@hotmail.com', 'NTE5Mw==', 1, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('98766299', 'Juan ', 'Camilo', 'Gomez', 'Cadavid', 1, 0, 0, 0, 'camilo.gomez@tecrea.com.co', 'cGVjaA==', 4, 1, 2, 0, '4', '', '', '2018-08-29', 0),
('98772784', 'Anderson', 'Estevenson ', 'Tangarife ', 'Palacio', 1, 0, 0, 0, 'palacio.2125@hotmail.com', 'MjEyNQ==', 3, 1, 1, 1, '4', '09-01-2004', 'Medellín', '2018-08-29', 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado_horario`
--

CREATE TABLE `empleado_horario` (
  `idEmpleado_horario` int(11) NOT NULL,
  `documento` varchar(20) CHARACTER SET utf8 NOT NULL,
  `idConfiguracion` tinyint(4) NOT NULL,
  `diaInicio` tinyint(1) NOT NULL,
  `diaFin` tinyint(1) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaInicio` date NOT NULL,
  `fechaFin` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `empleado_horario`
--

INSERT INTO `empleado_horario` (`idEmpleado_horario`, `documento`, `idConfiguracion`, `diaInicio`, `diaFin`, `estado`, `fechaInicio`, `fechaFin`) VALUES
(19, '1216727816', 4, 1, 5, 1, '2018-10-24', NULL),
(20, '1216727816', 2, 5, -1, 0, '2018-10-25', NULL),
(21, '1039457744', 1, 1, 6, 1, '2018-10-29', NULL),
(22, '43265824', 1, 1, 5, 1, '2018-11-09', NULL),
(23, '1037587834', 1, 1, 5, 1, '2018-11-09', NULL),
(24, '43605625', 1, 1, 5, 1, '2018-11-09', NULL),
(25, '1046913982', 1, 1, 5, 1, '2018-11-09', NULL),
(26, '1037949573', 1, 1, 5, 1, '2018-11-09', NULL),
(27, '1017216447', 1, 1, 5, 1, '2018-11-09', NULL),
(28, '1216714526', 1, 1, 5, 1, '2018-11-09', NULL),
(29, '1129045994', 1, 1, 5, 1, '2018-11-09', NULL),
(30, '1037631569', 1, 1, 5, 1, '2018-11-09', NULL),
(31, '71752141', 1, 1, 5, 1, '2018-11-09', NULL),
(32, '1037581069', 1, 1, 5, 1, '2018-11-09', NULL),
(33, '1006887114', 1, 1, 5, 1, '2018-11-09', NULL),
(34, '1128450516', 1, 1, 5, 1, '2018-11-09', NULL),
(35, '1036612156', 1, 1, 5, 1, '2018-11-09', NULL),
(36, '1017137065', 1, 1, 5, 1, '2018-11-09', NULL),
(37, '1152450553', 1, 1, 5, 1, '2018-11-09', NULL),
(38, '1096238261', 1, 1, 5, 1, '2018-11-09', NULL),
(39, '15489896', 1, 1, 5, 1, '2018-11-09', NULL),
(40, '1128405581', 1, 1, 5, 1, '2018-11-09', NULL),
(41, '98772784', 1, 1, 5, 1, '2018-11-09', NULL),
(42, '1035915735', 1, 1, 5, 0, '2018-11-13', NULL),
(43, '43866346', 1, 1, 5, 1, '2018-11-13', NULL),
(44, '1128390700', 1, 1, 5, 1, '2018-11-13', NULL),
(45, '1152701919', 1, 1, 5, 1, '2019-01-28', NULL),
(46, '1216716458', 1, 1, 5, 1, '2019-01-28', NULL),
(47, '760579', 1, 1, 5, 1, '2019-01-28', NULL),
(48, '15515649', 1, 1, 5, 1, '2019-01-28', NULL),
(49, '1013537192', 1, 1, 5, 1, '2019-01-28', NULL),
(50, '1017225857', 1, 1, 5, 1, '2019-01-28', NULL),
(51, '42702332', 1, 1, 5, 1, '2019-01-28', NULL),
(52, '1090523316', 1, 1, 5, 1, '2019-01-28', NULL),
(53, '8433778', 1, 1, 5, 1, '2019-01-28', NULL),
(54, '44006996', 1, 1, 5, 1, '2019-01-28', NULL),
(55, '1020457057', 1, 1, 5, 1, '2019-01-28', NULL),
(56, '1017187557', 1, 1, 5, 1, '2019-01-28', NULL),
(57, '1036629003', 1, 1, 5, 1, '2019-01-28', NULL),
(58, '23917651', 1, 1, 5, 1, '2019-01-28', NULL),
(59, '21424773', 1, 1, 5, 1, '2019-01-28', NULL),
(60, '43189198', 1, 1, 5, 1, '2019-01-28', NULL),
(61, '43542658', 1, 1, 5, 1, '2019-01-28', NULL),
(62, '1036625052', 1, 1, 5, 1, '2019-01-28', NULL),
(63, '1036622270', 1, 1, 5, 1, '2019-01-29', NULL),
(64, '80145967', 1, 1, 5, 1, '2019-01-30', NULL),
(65, '1036680551', 1, 1, 5, 1, '2019-02-04', NULL),
(66, '98668402', 1, 1, 5, 1, '2019-02-11', NULL),
(67, '43288005', 1, 1, 5, 1, '2019-02-11', NULL),
(68, '1017125039', 1, 1, 5, 1, '2019-02-11', NULL),
(69, '1020430141', 1, 1, 5, 1, '2019-02-12', NULL),
(70, '1143991147', 1, 1, 5, 1, '2019-02-19', NULL),
(71, '1036651097', 1, 1, 5, 1, '2019-02-19', NULL),
(72, '1039049115', 1, 1, 5, 1, '2019-02-19', NULL),
(73, '1007310520', 1, 1, 5, 1, '2019-02-19', NULL),
(74, '1036598684', 1, 1, 5, 1, '2019-02-19', NULL),
(75, '1077453248', 1, 1, 5, 1, '2019-02-19', NULL),
(76, '32353491', 1, 1, 5, 1, '2019-02-20', NULL),
(77, '1037949696', 1, 1, 5, 1, '2019-02-26', NULL),
(78, '71267825', 1, 1, 5, 1, '2019-02-28', NULL),
(79, '1001545147', 1, 1, 5, 1, '2019-03-12', NULL),
(80, '1095791547', 1, 1, 5, 1, '2019-03-27', NULL),
(81, '1095791547', 3, 6, -1, 0, '2019-04-06', NULL),
(82, '98668402', 3, 6, -1, 1, '2019-04-06', NULL),
(83, '1216727816', 4, 6, -1, 0, '2019-05-03', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `idEmpresa` tinyint(4) NOT NULL,
  `nombre` varchar(25) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`idEmpresa`, `nombre`, `estado`) VALUES
(1, 'Colcircuitos', 1),
(2, 'Soluciones Inmediatas', 1),
(3, 'Dar ayuda', 1),
(4, 'TECREA', 1),
(5, 'Invertronica', 1),
(6, 'Seguirte', 1),
(7, 'Colcircuitos - Tecrea', 1),
(8, 'Cooperativa', 1),
(9, 'Estilo empresarial', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `envio_pedido`
--

CREATE TABLE `envio_pedido` (
  `idEnvio_pedido` int(11) NOT NULL,
  `fecha_envio` datetime NOT NULL,
  `idProveedor` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `envio_pedido`
--

INSERT INTO `envio_pedido` (`idEnvio_pedido`, `fecha_envio`, `idProveedor`) VALUES
(56, '2018-06-14 12:19:04', 1),
(57, '2018-06-14 12:19:06', 2),
(58, '2018-06-14 12:19:09', 3),
(62, '2018-06-15 08:25:11', 1),
(63, '2018-06-15 08:25:14', 2),
(64, '2018-06-15 08:25:16', 3),
(65, '2018-06-18 08:02:32', 1),
(66, '2018-06-18 08:02:35', 2),
(67, '2018-06-18 08:02:38', 3),
(68, '2018-06-19 08:05:15', 1),
(69, '2018-06-19 08:05:17', 2),
(70, '2018-06-19 08:05:20', 3),
(71, '2018-06-20 08:11:01', 1),
(72, '2018-06-20 08:11:04', 2),
(73, '2018-06-20 08:11:07', 3),
(74, '2018-06-21 08:04:15', 1),
(75, '2018-06-21 08:04:18', 2),
(76, '2018-06-21 08:04:20', 3),
(77, '2018-06-22 08:02:28', 1),
(78, '2018-06-22 08:02:30', 2),
(79, '2018-06-22 08:02:33', 3),
(80, '2018-06-25 08:03:26', 1),
(81, '2018-06-25 08:03:29', 2),
(82, '2018-06-25 08:03:31', 3),
(83, '2018-06-26 08:01:34', 1),
(84, '2018-06-26 08:01:37', 2),
(85, '2018-06-26 08:01:39', 3),
(86, '2018-06-27 08:04:08', 1),
(87, '2018-06-27 08:04:11', 2),
(88, '2018-06-27 08:04:14', 3),
(89, '2018-06-28 07:54:28', 2),
(90, '2018-06-28 07:54:31', 3),
(91, '2018-06-28 08:05:33', 1),
(92, '2018-06-29 07:46:30', 2),
(93, '2018-06-29 07:46:33', 3),
(94, '2018-07-03 07:48:00', 1),
(95, '2018-07-03 07:48:02', 2),
(96, '2018-07-03 07:48:04', 3),
(97, '2018-07-04 07:49:29', 1),
(98, '2018-07-04 07:49:32', 2),
(99, '2018-07-04 07:49:34', 3),
(100, '2018-07-05 07:50:18', 1),
(101, '2018-07-05 07:50:20', 2),
(102, '2018-07-05 07:50:22', 3),
(103, '2018-07-06 07:45:38', 1),
(104, '2018-07-06 07:45:40', 2),
(105, '2018-07-06 07:45:42', 3),
(106, '2018-07-09 07:47:23', 1),
(107, '2018-07-09 07:47:27', 2),
(108, '2018-07-09 07:47:30', 3),
(109, '2018-07-10 07:47:48', 1),
(110, '2018-07-10 07:47:50', 2),
(111, '2018-07-10 07:47:52', 3),
(112, '2018-07-11 07:46:48', 1),
(113, '2018-07-11 07:46:50', 2),
(114, '2018-07-11 07:46:52', 3),
(115, '2018-07-12 07:47:01', 2),
(116, '2018-07-12 07:47:03', 3),
(117, '2018-07-12 07:48:30', 1),
(118, '2018-07-13 07:48:24', 2),
(119, '2018-07-13 07:48:27', 3),
(120, '2018-07-13 07:50:00', 1),
(121, '2018-07-16 07:47:47', 1),
(122, '2018-07-16 07:47:52', 2),
(123, '2018-07-16 07:47:56', 3),
(124, '2018-07-17 07:48:37', 1),
(125, '2018-07-17 07:48:40', 2),
(126, '2018-07-17 07:48:42', 3),
(127, '2018-07-18 07:50:02', 1),
(128, '2018-07-18 07:50:05', 2),
(129, '2018-07-18 07:50:07', 3),
(130, '2018-07-19 07:46:05', 1),
(131, '2018-07-19 07:46:07', 2),
(132, '2018-07-19 07:46:10', 3),
(133, '2018-07-23 07:48:57', 1),
(134, '2018-07-23 07:49:00', 2),
(135, '2018-07-23 07:49:02', 3),
(136, '2018-07-24 07:45:24', 1),
(137, '2018-07-24 07:45:27', 2),
(138, '2018-07-24 07:45:29', 3),
(139, '2018-07-25 07:46:20', 1),
(140, '2018-07-25 07:46:22', 2),
(141, '2018-07-25 07:46:24', 3),
(142, '2018-07-26 07:51:27', 1),
(143, '2018-07-26 07:51:30', 2),
(144, '2018-07-26 07:51:32', 3),
(145, '2018-07-27 07:48:20', 1),
(146, '2018-07-27 07:48:22', 2),
(147, '2018-07-27 07:48:24', 3),
(148, '2018-07-28 07:48:19', 1),
(149, '2018-07-28 07:48:21', 2),
(150, '2018-07-28 07:48:23', 3),
(151, '2018-07-30 07:45:57', 1),
(152, '2018-07-30 07:45:59', 2),
(153, '2018-07-30 07:46:01', 3),
(154, '2018-07-31 07:51:48', 1),
(155, '2018-07-31 07:51:50', 2),
(156, '2018-07-31 07:51:52', 3),
(157, '2018-08-01 07:50:30', 1),
(158, '2018-08-01 07:50:32', 2),
(159, '2018-08-01 07:50:34', 3),
(160, '2018-08-02 07:48:28', 1),
(161, '2018-08-02 07:48:30', 2),
(162, '2018-08-02 07:48:32', 3),
(163, '2018-08-03 07:50:33', 1),
(164, '2018-08-03 07:50:35', 2),
(165, '2018-08-03 07:50:38', 3),
(166, '2018-08-06 07:48:00', 1),
(167, '2018-08-06 07:48:01', 2),
(168, '2018-08-06 07:48:03', 3),
(169, '2018-08-08 07:46:41', 1),
(170, '2018-08-08 07:46:43', 2),
(171, '2018-08-08 07:46:45', 3),
(172, '2018-08-09 07:46:05', 1),
(173, '2018-08-09 07:46:07', 2),
(174, '2018-08-09 07:46:09', 3),
(175, '2018-08-10 07:45:29', 1),
(176, '2018-08-10 07:45:31', 2),
(177, '2018-08-10 07:45:33', 3),
(178, '2018-08-13 07:50:15', 1),
(179, '2018-08-13 07:50:18', 2),
(180, '2018-08-13 07:50:20', 3),
(181, '2018-08-14 07:55:41', 1),
(182, '2018-08-14 07:55:43', 2),
(183, '2018-08-14 07:55:45', 3),
(184, '2018-08-15 07:46:02', 1),
(185, '2018-08-15 07:46:04', 2),
(186, '2018-08-15 07:46:07', 3),
(187, '2018-08-16 07:46:35', 1),
(188, '2018-08-16 07:47:39', 3),
(189, '2018-08-17 07:47:01', 1),
(190, '2018-08-17 07:47:04', 2),
(191, '2018-08-17 07:47:06', 3),
(192, '2018-08-21 07:50:44', 1),
(193, '2018-08-21 07:50:45', 2),
(194, '2018-08-21 07:50:47', 3),
(195, '2018-08-22 07:50:28', 1),
(196, '2018-08-22 07:50:31', 2),
(197, '2018-08-22 07:50:33', 3),
(198, '2018-08-23 07:49:44', 1),
(199, '2018-08-23 07:49:49', 2),
(200, '2018-08-23 07:49:55', 3),
(201, '2018-08-24 07:47:37', 1),
(202, '2018-08-24 07:47:39', 2),
(203, '2018-08-24 07:47:41', 3),
(204, '2018-08-27 07:46:39', 1),
(205, '2018-08-27 07:46:41', 2),
(206, '2018-08-27 07:46:44', 3),
(207, '2018-08-28 07:48:31', 1),
(208, '2018-08-28 07:48:34', 2),
(209, '2018-08-28 07:48:36', 3),
(210, '2018-08-29 07:48:30', 1),
(211, '2018-08-29 07:48:32', 2),
(212, '2018-08-29 07:48:34', 3),
(213, '2018-08-30 07:50:02', 1),
(214, '2018-08-30 07:50:04', 2),
(215, '2018-08-30 07:50:06', 3),
(216, '2018-08-31 07:47:32', 1),
(217, '2018-08-31 07:47:34', 2),
(218, '2018-08-31 07:47:36', 3),
(219, '2018-09-03 07:48:24', 1),
(220, '2018-09-03 07:48:27', 2),
(221, '2018-09-03 07:48:29', 3),
(229, '2018-09-04 10:45:46', 1),
(230, '2018-09-04 10:58:02', 2),
(231, '2018-09-04 10:58:04', 3),
(232, '2018-09-05 07:47:43', 1),
(233, '2018-09-05 07:47:46', 2),
(234, '2018-09-05 07:47:48', 3),
(235, '2018-09-06 07:47:05', 1),
(236, '2018-09-06 07:47:07', 2),
(237, '2018-09-06 07:47:10', 3),
(238, '2018-09-07 07:46:26', 1),
(239, '2018-09-07 07:46:28', 2),
(240, '2018-09-07 07:46:30', 3),
(241, '2018-09-07 09:56:45', 1),
(243, '2018-09-10 07:46:52', 2),
(244, '2018-09-10 07:46:54', 3),
(246, '2018-09-10 10:15:01', 2),
(258, '2018-09-10 12:02:22', 1),
(259, '2018-09-11 07:45:18', 1),
(260, '2018-09-11 07:45:20', 2),
(261, '2018-09-11 07:45:22', 3),
(262, '2018-09-12 07:45:20', 1),
(263, '2018-09-12 07:45:23', 2),
(264, '2018-09-12 07:48:08', 3),
(265, '2018-09-13 07:45:20', 1),
(266, '2018-09-13 07:45:23', 2),
(267, '2018-09-13 07:45:25', 3),
(268, '2018-09-14 07:45:20', 1),
(269, '2018-09-14 07:45:22', 2),
(270, '2018-09-14 07:45:25', 3),
(271, '2018-09-17 07:45:19', 1),
(272, '2018-09-17 07:45:21', 2),
(273, '2018-09-17 07:45:23', 3),
(274, '2018-09-18 07:45:20', 1),
(275, '2018-09-18 07:45:22', 2),
(276, '2018-09-18 07:45:24', 3),
(277, '2018-09-19 07:45:19', 1),
(278, '2018-09-19 07:45:22', 2),
(279, '2018-09-19 07:45:24', 3),
(280, '2018-09-20 07:45:20', 1),
(281, '2018-09-20 07:45:23', 2),
(282, '2018-09-20 07:45:26', 3),
(283, '2018-09-21 07:45:20', 1),
(284, '2018-09-21 07:45:22', 2),
(285, '2018-09-21 07:45:24', 3),
(286, '2018-09-24 07:45:19', 1),
(287, '2018-09-24 07:45:22', 2),
(288, '2018-09-24 07:45:24', 3),
(289, '2018-09-25 07:45:20', 1),
(290, '2018-09-25 07:45:23', 2),
(291, '2018-09-25 07:45:25', 3),
(292, '2018-09-26 07:45:25', 1),
(293, '2018-09-26 07:45:27', 2),
(294, '2018-09-26 07:45:30', 3),
(295, '2018-09-27 07:45:29', 2),
(296, '2018-09-27 07:45:32', 3),
(297, '2018-09-27 07:47:11', 1),
(298, '2018-09-28 07:45:21', 1),
(299, '2018-09-28 07:45:23', 2),
(300, '2018-09-28 07:45:26', 3),
(301, '2018-10-01 07:45:19', 1),
(302, '2018-10-01 07:45:21', 2),
(303, '2018-10-01 07:45:23', 3),
(304, '2018-10-02 07:45:20', 1),
(305, '2018-10-02 07:45:22', 2),
(306, '2018-10-02 07:45:24', 3),
(307, '2018-10-03 07:45:19', 1),
(308, '2018-10-03 07:45:22', 2),
(309, '2018-10-03 07:45:25', 3),
(310, '2018-10-04 07:45:20', 1),
(311, '2018-10-04 07:45:34', 3),
(312, '2018-10-05 07:45:19', 1),
(313, '2018-10-05 07:45:22', 2),
(314, '2018-10-05 07:45:24', 3),
(315, '2018-10-08 07:45:20', 1),
(316, '2018-10-08 07:45:22', 2),
(317, '2018-10-08 07:45:25', 3),
(318, '2018-10-09 07:45:22', 1),
(319, '2018-10-09 07:45:25', 2),
(320, '2018-10-09 07:45:27', 3),
(321, '2018-10-10 07:45:20', 1),
(322, '2018-10-10 07:45:22', 2),
(323, '2018-10-10 07:45:25', 3),
(324, '2018-10-11 07:45:18', 1),
(325, '2018-10-11 07:45:21', 2),
(326, '2018-10-11 07:45:23', 3),
(327, '2018-10-12 07:45:22', 1),
(328, '2018-10-12 07:45:24', 2),
(329, '2018-10-12 07:45:27', 3),
(330, '2018-10-16 07:45:20', 1),
(331, '2018-10-16 07:45:22', 2),
(332, '2018-10-16 07:45:24', 3),
(333, '2018-10-17 07:45:22', 1),
(334, '2018-10-17 07:45:25', 2),
(335, '2018-10-17 07:45:27', 3),
(336, '2018-10-18 07:45:19', 1),
(337, '2018-10-18 07:45:21', 2),
(338, '2018-10-18 07:45:24', 3),
(339, '2018-10-19 07:45:19', 1),
(340, '2018-10-19 07:45:22', 2),
(341, '2018-10-19 07:45:24', 3),
(342, '2018-10-22 07:45:22', 1),
(343, '2018-10-22 07:45:24', 2),
(344, '2018-10-22 07:45:26', 3),
(345, '2018-10-23 07:53:54', 1),
(346, '2018-10-23 07:53:56', 2),
(347, '2018-10-23 07:54:00', 3),
(348, '2018-10-24 07:45:19', 1),
(349, '2018-10-24 07:45:22', 2),
(350, '2018-10-24 07:45:24', 3),
(351, '2018-10-25 07:45:19', 1),
(352, '2018-10-25 07:45:21', 2),
(353, '2018-10-25 07:45:23', 3),
(354, '2018-10-26 07:45:19', 1),
(355, '2018-10-26 07:45:21', 2),
(356, '2018-10-26 07:45:23', 3),
(357, '2018-10-29 07:45:18', 1),
(358, '2018-10-29 07:45:21', 2),
(359, '2018-10-29 07:45:23', 3),
(360, '2018-10-30 07:45:22', 1),
(361, '2018-10-30 07:45:24', 2),
(362, '2018-10-30 07:45:26', 3),
(363, '2018-10-31 07:45:19', 1),
(364, '2018-10-31 07:45:21', 2),
(365, '2018-10-31 07:45:23', 3),
(366, '2018-11-01 07:45:20', 1),
(367, '2018-11-01 07:45:22', 2),
(368, '2018-11-01 07:45:25', 3),
(369, '2018-11-02 07:45:20', 1),
(370, '2018-11-02 07:45:23', 2),
(371, '2018-11-02 07:45:25', 3),
(372, '2018-11-06 07:45:19', 1),
(373, '2018-11-06 07:45:23', 2),
(374, '2018-11-06 07:45:25', 3),
(375, '2018-11-07 07:45:20', 1),
(376, '2018-11-07 07:45:24', 2),
(377, '2018-11-07 07:45:28', 3),
(378, '2018-11-08 07:45:18', 1),
(379, '2018-11-08 07:45:21', 2),
(380, '2018-11-08 07:45:23', 3),
(381, '2018-11-09 07:45:19', 1),
(382, '2018-11-09 07:45:21', 2),
(383, '2018-11-09 07:45:23', 3),
(384, '2018-11-13 07:45:32', 1),
(385, '2018-11-13 07:45:38', 2),
(386, '2018-11-13 07:45:41', 3),
(387, '2018-11-14 07:45:20', 1),
(388, '2018-11-14 07:45:22', 2),
(389, '2018-11-14 07:45:25', 3),
(390, '2018-11-15 07:45:23', 1),
(391, '2018-11-15 07:45:30', 2),
(392, '2018-11-15 07:45:34', 3),
(393, '2018-11-16 07:45:20', 1),
(394, '2018-11-16 07:45:22', 2),
(395, '2018-11-16 07:45:24', 3),
(396, '2018-11-17 07:45:19', 1),
(397, '2018-11-17 07:45:21', 2),
(398, '2018-11-17 07:45:23', 3),
(399, '2018-11-18 07:45:19', 1),
(400, '2018-11-18 07:45:21', 2),
(401, '2018-11-18 07:45:24', 3),
(402, '2018-11-19 07:45:19', 1),
(403, '2018-11-19 07:45:22', 2),
(404, '2018-11-19 07:45:25', 3),
(405, '2018-11-20 07:45:22', 1),
(406, '2018-11-20 07:45:24', 2),
(407, '2018-11-20 07:45:26', 3),
(408, '2018-11-21 07:45:22', 1),
(409, '2018-11-21 07:45:25', 2),
(410, '2018-11-21 07:45:28', 3),
(411, '2018-11-22 07:45:19', 1),
(412, '2018-11-22 07:45:22', 2),
(413, '2018-11-22 07:45:24', 3),
(414, '2018-11-23 07:45:18', 1),
(415, '2018-11-23 07:45:21', 2),
(416, '2018-11-23 07:45:24', 3),
(417, '2018-11-24 07:45:19', 1),
(418, '2018-11-24 07:45:22', 2),
(419, '2018-11-24 07:45:25', 3),
(420, '2018-11-25 07:45:19', 1),
(421, '2018-11-25 07:45:21', 2),
(422, '2018-11-25 07:45:25', 3),
(423, '2018-11-26 07:45:19', 1),
(424, '2018-11-26 07:45:21', 2),
(425, '2018-11-26 07:45:24', 3),
(426, '2018-11-27 07:45:18', 1),
(427, '2018-11-27 07:45:21', 2),
(428, '2018-11-27 07:45:24', 3),
(429, '2018-11-28 07:45:51', 1),
(430, '2018-11-28 07:45:53', 2),
(431, '2018-11-28 07:45:58', 3),
(432, '2018-11-29 07:45:19', 1),
(433, '2018-11-29 07:45:22', 2),
(434, '2018-11-29 07:45:25', 3),
(435, '2018-11-30 07:45:19', 1),
(436, '2018-11-30 07:45:22', 2),
(437, '2018-11-30 07:45:24', 3),
(438, '2018-12-03 07:45:23', 1),
(439, '2018-12-03 07:45:29', 2),
(440, '2018-12-03 07:45:40', 3),
(441, '2018-12-04 07:45:20', 1),
(442, '2018-12-04 07:45:23', 2),
(443, '2018-12-04 07:45:26', 3),
(444, '2018-12-05 07:45:20', 1),
(445, '2018-12-05 07:45:23', 2),
(446, '2018-12-05 07:45:25', 3),
(447, '2018-12-06 07:45:20', 1),
(448, '2018-12-06 07:45:22', 2),
(449, '2018-12-06 07:45:25', 3),
(450, '2018-12-07 07:45:18', 1),
(451, '2018-12-07 07:45:21', 2),
(452, '2018-12-07 07:45:23', 3),
(453, '2018-12-10 07:45:18', 1),
(454, '2018-12-10 07:45:21', 2),
(455, '2018-12-10 07:45:23', 3),
(456, '2018-12-11 07:45:21', 1),
(457, '2018-12-11 07:45:23', 2),
(458, '2018-12-11 07:45:26', 3),
(459, '2018-12-12 07:45:19', 1),
(460, '2018-12-12 07:45:21', 2),
(461, '2018-12-12 07:45:24', 3),
(462, '2018-12-13 07:45:18', 1),
(463, '2018-12-13 07:45:21', 2),
(464, '2018-12-13 07:45:23', 3),
(465, '2018-12-14 09:26:18', 1),
(466, '2018-12-14 09:26:21', 2),
(467, '2018-12-14 09:26:23', 3),
(468, '2018-12-17 07:53:12', 1),
(469, '2018-12-17 07:53:14', 2),
(470, '2018-12-17 07:53:17', 3),
(471, '2018-12-18 07:45:18', 1),
(472, '2018-12-18 07:45:21', 2),
(473, '2018-12-18 07:45:23', 3),
(474, '2018-12-19 07:45:19', 1),
(475, '2018-12-19 07:45:21', 2),
(476, '2018-12-19 07:45:24', 3),
(477, '2018-12-20 07:45:18', 1),
(478, '2018-12-20 07:45:20', 2),
(479, '2018-12-20 07:45:23', 3),
(480, '2018-12-21 07:45:19', 1),
(481, '2018-12-21 07:45:22', 2),
(482, '2018-12-21 07:45:24', 3),
(483, '2018-12-26 07:45:18', 1),
(484, '2018-12-26 07:45:20', 2),
(485, '2018-12-26 07:45:23', 3),
(486, '2018-12-27 07:45:18', 1),
(487, '2018-12-27 07:45:21', 2),
(488, '2018-12-27 07:45:23', 3),
(489, '2018-12-28 07:45:18', 1),
(490, '2018-12-28 07:45:20', 2),
(491, '2018-12-28 07:45:22', 3),
(492, '2018-12-29 07:45:19', 1),
(493, '2018-12-29 07:45:21', 2),
(494, '2018-12-29 07:45:23', 3),
(495, '2018-12-30 07:45:18', 1),
(496, '2018-12-30 07:45:20', 2),
(497, '2018-12-30 07:45:22', 3),
(498, '2018-12-31 07:45:19', 1),
(499, '2018-12-31 07:45:21', 2),
(500, '2018-12-31 07:45:24', 3),
(501, '2019-01-01 07:45:19', 1),
(502, '2019-01-01 07:45:21', 2),
(503, '2019-01-01 07:45:23', 3),
(504, '2019-01-02 07:45:18', 1),
(505, '2019-01-02 07:45:21', 2),
(506, '2019-01-02 07:45:23', 3),
(507, '2019-01-03 07:45:19', 1),
(508, '2019-01-03 07:45:21', 2),
(509, '2019-01-03 07:45:23', 3),
(510, '2019-01-04 07:45:19', 1),
(511, '2019-01-04 07:45:21', 2),
(512, '2019-01-04 07:45:23', 3),
(513, '2019-01-08 07:46:32', 2),
(514, '2019-01-08 07:46:34', 3),
(515, '2019-01-09 07:45:21', 1),
(516, '2019-01-09 07:45:24', 2),
(517, '2019-01-09 07:45:27', 3),
(518, '2019-01-10 07:45:18', 1),
(519, '2019-01-10 07:45:20', 2),
(520, '2019-01-10 07:45:23', 3),
(521, '2019-01-11 07:45:19', 1),
(522, '2019-01-11 07:45:22', 2),
(523, '2019-01-11 07:45:25', 3),
(524, '2019-01-12 07:45:19', 1),
(525, '2019-01-12 07:45:22', 2),
(526, '2019-01-12 07:45:24', 3),
(527, '2019-01-13 07:45:18', 1),
(528, '2019-01-13 07:45:21', 2),
(529, '2019-01-13 07:45:23', 3),
(530, '2019-01-14 07:45:19', 1),
(531, '2019-01-14 07:45:22', 2),
(532, '2019-01-14 07:45:25', 3),
(533, '2019-01-15 07:45:20', 1),
(534, '2019-01-15 07:45:22', 2),
(535, '2019-01-15 07:45:24', 3),
(536, '2019-01-16 07:45:20', 1),
(537, '2019-01-16 07:45:22', 2),
(538, '2019-01-16 07:45:25', 3),
(539, '2019-01-17 07:45:19', 1),
(540, '2019-01-17 07:45:21', 2),
(541, '2019-01-17 07:45:24', 3),
(542, '2019-01-18 07:45:20', 1),
(543, '2019-01-18 07:45:23', 2),
(544, '2019-01-18 07:45:25', 3),
(545, '2019-01-21 07:45:18', 1),
(546, '2019-01-21 07:45:20', 2),
(547, '2019-01-21 07:45:23', 3),
(548, '2019-01-22 07:45:18', 1),
(549, '2019-01-22 07:45:21', 2),
(550, '2019-01-22 07:45:24', 3),
(551, '2019-01-23 07:45:19', 1),
(552, '2019-01-23 07:45:21', 2),
(553, '2019-01-23 07:45:24', 3),
(554, '2019-01-24 07:45:22', 1),
(555, '2019-01-24 07:45:25', 2),
(556, '2019-01-24 07:45:27', 3),
(557, '2019-01-25 07:45:20', 1),
(558, '2019-01-25 07:45:22', 2),
(559, '2019-01-25 07:45:25', 3),
(560, '2019-01-28 07:45:21', 1),
(561, '2019-01-28 07:45:24', 2),
(562, '2019-01-28 07:45:28', 3),
(563, '2019-01-29 07:45:20', 1),
(564, '2019-01-29 07:45:22', 2),
(565, '2019-01-29 07:45:24', 3),
(566, '2019-01-30 07:45:20', 1),
(567, '2019-01-30 07:45:22', 2),
(568, '2019-01-30 07:45:25', 3),
(569, '2019-01-31 07:45:18', 1),
(570, '2019-01-31 07:45:21', 2),
(571, '2019-01-31 07:45:23', 3),
(572, '2019-02-01 07:45:20', 1),
(573, '2019-02-01 07:45:22', 2),
(574, '2019-02-01 07:45:24', 3),
(575, '2019-02-04 07:45:20', 1),
(576, '2019-02-04 07:45:22', 2),
(577, '2019-02-04 07:45:24', 3),
(578, '2019-02-05 07:45:22', 1),
(579, '2019-02-05 07:45:25', 2),
(580, '2019-02-05 07:45:28', 3),
(581, '2019-02-06 07:45:19', 1),
(582, '2019-02-06 07:45:21', 2),
(583, '2019-02-06 07:45:23', 3),
(584, '2019-02-07 07:45:20', 1),
(585, '2019-02-07 07:45:23', 2),
(586, '2019-02-07 07:45:25', 3),
(587, '2019-02-08 07:56:37', 1),
(588, '2019-02-08 07:56:39', 2),
(589, '2019-02-08 07:56:41', 3),
(590, '2019-02-09 07:45:21', 1),
(591, '2019-02-09 07:45:24', 2),
(592, '2019-02-09 07:45:27', 3),
(593, '2019-02-10 07:45:21', 1),
(594, '2019-02-10 07:45:23', 2),
(595, '2019-02-10 07:45:25', 3),
(596, '2019-02-11 07:45:18', 1),
(597, '2019-02-11 07:45:21', 2),
(598, '2019-02-11 07:45:23', 3),
(599, '2019-02-12 07:45:18', 1),
(600, '2019-02-12 07:45:20', 2),
(601, '2019-02-12 07:45:23', 3),
(602, '2019-02-13 15:57:43', 1),
(603, '2019-02-13 15:57:45', 2),
(604, '2019-02-13 15:57:48', 3),
(605, '2019-02-14 07:45:18', 1),
(606, '2019-02-14 07:45:21', 2),
(607, '2019-02-14 07:45:23', 3),
(608, '2019-02-15 07:45:19', 1),
(609, '2019-02-15 07:45:21', 2),
(610, '2019-02-15 07:45:23', 3),
(611, '2019-02-16 07:45:18', 1),
(612, '2019-02-16 07:45:20', 2),
(613, '2019-02-16 07:45:23', 3),
(614, '2019-02-17 07:45:18', 1),
(615, '2019-02-17 07:45:20', 2),
(616, '2019-02-17 07:45:22', 3),
(617, '2019-02-18 07:45:18', 1),
(618, '2019-02-18 07:45:20', 2),
(619, '2019-02-18 07:45:22', 3),
(620, '2019-02-19 09:38:58', 1),
(621, '2019-02-19 09:39:01', 2),
(622, '2019-02-19 09:39:03', 3),
(623, '2019-02-20 07:45:20', 1),
(624, '2019-02-20 07:45:23', 2),
(625, '2019-02-20 07:45:25', 3),
(626, '2019-02-21 07:45:17', 1),
(627, '2019-02-21 07:45:19', 2),
(628, '2019-02-21 07:45:21', 3),
(629, '2019-02-22 07:45:18', 1),
(630, '2019-02-22 07:45:21', 2),
(631, '2019-02-22 07:45:23', 3),
(632, '2019-02-23 07:45:19', 1),
(633, '2019-02-23 07:45:21', 2),
(634, '2019-02-23 07:45:23', 3),
(635, '2019-02-24 07:45:18', 1),
(636, '2019-02-24 07:45:21', 2),
(637, '2019-02-24 07:45:23', 3),
(638, '2019-02-25 07:45:18', 1),
(639, '2019-02-25 07:45:20', 2),
(640, '2019-02-25 07:45:23', 3),
(641, '2019-02-26 07:45:18', 1),
(642, '2019-02-26 07:45:20', 2),
(643, '2019-02-26 07:45:22', 3),
(644, '2019-02-27 07:45:19', 1),
(645, '2019-02-27 07:45:21', 2),
(646, '2019-02-27 07:45:23', 3),
(647, '2019-02-28 07:45:19', 1),
(648, '2019-02-28 07:45:21', 2),
(649, '2019-02-28 07:45:23', 3),
(650, '2019-03-01 07:45:19', 1),
(651, '2019-03-01 07:45:21', 2),
(652, '2019-03-01 07:45:24', 3),
(653, '2019-03-02 07:45:20', 1),
(654, '2019-03-02 07:45:22', 2),
(655, '2019-03-02 07:45:24', 3),
(656, '2019-03-03 07:45:19', 1),
(657, '2019-03-03 07:45:21', 2),
(658, '2019-03-03 07:45:23', 3),
(659, '2019-03-04 07:45:18', 1),
(660, '2019-03-04 07:45:20', 2),
(661, '2019-03-04 07:45:22', 3),
(662, '2019-03-05 07:45:18', 1),
(663, '2019-03-05 07:45:20', 2),
(664, '2019-03-05 07:45:22', 3),
(665, '2019-03-06 07:45:18', 1),
(666, '2019-03-06 07:45:20', 2),
(667, '2019-03-06 07:45:22', 3),
(668, '2019-03-07 07:45:19', 1),
(669, '2019-03-07 07:45:21', 2),
(670, '2019-03-07 07:45:23', 3),
(671, '2019-03-08 07:45:19', 1),
(672, '2019-03-08 07:45:21', 2),
(673, '2019-03-08 07:45:23', 3),
(674, '2019-03-09 07:45:18', 1),
(675, '2019-03-09 07:45:20', 2),
(676, '2019-03-09 07:45:23', 3),
(677, '2019-03-10 07:45:19', 1),
(678, '2019-03-10 07:45:21', 2),
(679, '2019-03-10 07:45:23', 3),
(680, '2019-03-11 07:45:18', 1),
(681, '2019-03-11 07:45:21', 2),
(682, '2019-03-11 07:45:23', 3),
(683, '2019-03-12 07:45:19', 1),
(684, '2019-03-12 07:45:21', 2),
(685, '2019-03-12 07:45:23', 3),
(687, '2019-03-13 07:45:20', 2),
(688, '2019-03-13 07:45:22', 3),
(689, '2019-03-13 08:06:55', 1),
(690, '2019-03-14 07:45:19', 1),
(691, '2019-03-14 07:45:21', 2),
(692, '2019-03-14 07:45:24', 3),
(693, '2019-03-15 07:45:20', 1),
(694, '2019-03-15 07:45:22', 2),
(695, '2019-03-15 07:45:24', 3),
(696, '2019-03-16 07:45:21', 1),
(697, '2019-03-16 07:45:23', 2),
(698, '2019-03-16 07:45:25', 3),
(699, '2019-03-17 07:45:18', 1),
(700, '2019-03-17 07:45:20', 2),
(701, '2019-03-17 07:45:24', 3),
(702, '2019-03-18 07:45:18', 1),
(703, '2019-03-18 07:45:20', 2),
(704, '2019-03-18 07:45:22', 3),
(705, '2019-03-19 07:45:18', 1),
(706, '2019-03-19 07:45:21', 2),
(707, '2019-03-19 07:45:23', 3),
(708, '2019-03-20 07:45:21', 1),
(709, '2019-03-20 07:45:23', 2),
(710, '2019-03-20 07:45:25', 3),
(711, '2019-03-21 07:45:20', 1),
(712, '2019-03-21 07:45:22', 2),
(713, '2019-03-21 07:45:24', 3),
(714, '2019-03-22 07:45:18', 1),
(715, '2019-03-22 07:45:20', 2),
(716, '2019-03-22 07:45:22', 3),
(717, '2019-03-23 07:45:20', 1),
(718, '2019-03-23 07:45:22', 2),
(719, '2019-03-23 07:45:24', 3),
(720, '2019-03-23 07:45:26', 4),
(721, '2019-03-26 07:45:19', 1),
(722, '2019-03-26 07:45:21', 2),
(723, '2019-03-26 07:45:23', 3),
(724, '2019-03-26 07:45:25', 4),
(725, '2019-03-27 07:45:20', 1),
(726, '2019-03-27 07:45:22', 2),
(727, '2019-03-27 07:45:25', 3),
(728, '2019-03-27 07:45:27', 4),
(729, '2019-03-28 07:45:18', 1),
(730, '2019-03-28 07:45:20', 2),
(731, '2019-03-28 07:45:23', 3),
(732, '2019-03-28 07:45:27', 4),
(733, '2019-03-29 07:45:19', 1),
(734, '2019-03-29 07:45:21', 2),
(735, '2019-03-29 07:45:23', 3),
(736, '2019-03-29 07:45:25', 4),
(737, '2019-03-30 07:45:19', 1),
(738, '2019-03-30 07:45:22', 2),
(739, '2019-03-30 07:45:24', 3),
(740, '2019-03-30 07:45:26', 4),
(741, '2019-03-30 07:45:28', 5),
(742, '2019-03-31 07:45:19', 1),
(743, '2019-03-31 07:45:22', 2),
(744, '2019-03-31 07:45:24', 3),
(745, '2019-03-31 07:45:26', 4),
(746, '2019-03-31 07:45:28', 5),
(747, '2019-04-01 08:34:33', 1),
(748, '2019-04-01 08:34:36', 2),
(749, '2019-04-01 08:34:38', 3),
(750, '2019-04-01 08:34:40', 4),
(751, '2019-04-01 08:34:42', 5),
(752, '2019-04-02 07:48:49', 1),
(753, '2019-04-02 07:48:51', 2),
(754, '2019-04-02 07:48:54', 3),
(755, '2019-04-02 07:48:56', 4),
(775, '2019-04-03 11:29:07', 1),
(776, '2019-04-03 11:29:10', 2),
(777, '2019-04-03 11:29:12', 3),
(778, '2019-04-03 11:29:14', 4),
(780, '2019-04-03 11:38:53', 5),
(781, '2019-04-04 07:45:14', 1),
(782, '2019-04-04 07:45:17', 2),
(783, '2019-04-04 07:45:19', 3),
(784, '2019-04-04 07:45:21', 4),
(785, '2019-04-04 07:45:23', 5),
(786, '2019-04-05 08:01:21', 1),
(787, '2019-04-05 08:01:23', 2),
(788, '2019-04-05 08:01:26', 3),
(789, '2019-04-05 08:01:29', 4),
(790, '2019-04-05 08:01:31', 5),
(791, '2019-04-06 07:45:14', 1),
(792, '2019-04-06 07:45:16', 2),
(793, '2019-04-06 07:45:18', 3),
(794, '2019-04-06 07:45:20', 4),
(797, '2019-04-06 10:57:45', 5),
(798, '2019-04-08 07:45:13', 1),
(799, '2019-04-08 07:45:16', 2),
(800, '2019-04-08 07:45:19', 3),
(801, '2019-04-08 07:45:21', 4),
(802, '2019-04-08 07:45:23', 5),
(803, '2019-04-09 07:45:14', 1),
(804, '2019-04-09 07:45:16', 2),
(805, '2019-04-09 07:45:19', 3),
(806, '2019-04-09 07:45:21', 4),
(807, '2019-04-09 07:45:23', 5),
(808, '2019-04-10 07:45:14', 1),
(809, '2019-04-10 07:45:16', 2),
(810, '2019-04-10 07:45:18', 3),
(811, '2019-04-10 07:45:20', 4),
(812, '2019-04-10 07:45:22', 5),
(813, '2019-04-11 07:45:23', 1),
(814, '2019-04-11 07:45:25', 2),
(815, '2019-04-11 07:45:27', 3),
(816, '2019-04-11 07:45:29', 4),
(817, '2019-04-11 07:45:31', 5),
(818, '2019-04-12 07:45:13', 1),
(819, '2019-04-12 07:45:15', 2),
(820, '2019-04-12 07:45:18', 3),
(821, '2019-04-12 07:45:20', 4),
(822, '2019-04-12 07:45:22', 5),
(823, '2019-04-15 07:45:13', 1),
(824, '2019-04-15 07:45:16', 2),
(825, '2019-04-15 07:45:18', 3),
(826, '2019-04-15 07:45:20', 4),
(827, '2019-04-15 07:45:22', 5),
(828, '2019-04-16 07:45:17', 1),
(829, '2019-04-16 07:45:19', 2),
(830, '2019-04-16 07:45:22', 3),
(831, '2019-04-16 07:45:24', 4),
(832, '2019-04-16 07:45:27', 5),
(833, '2019-04-17 07:45:13', 1),
(834, '2019-04-17 07:45:15', 2),
(835, '2019-04-17 07:45:17', 3),
(836, '2019-04-17 07:45:20', 4),
(837, '2019-04-17 07:45:22', 5),
(838, '2019-04-18 07:45:14', 1),
(839, '2019-04-18 07:45:17', 2),
(840, '2019-04-18 07:45:19', 3),
(841, '2019-04-18 07:45:21', 4),
(842, '2019-04-18 07:45:24', 5),
(843, '2019-04-19 07:45:13', 1),
(844, '2019-04-19 07:45:15', 2),
(845, '2019-04-19 07:45:18', 3),
(846, '2019-04-19 07:45:20', 4),
(847, '2019-04-19 07:45:22', 5),
(848, '2019-04-22 07:45:14', 1),
(849, '2019-04-22 07:45:16', 2),
(850, '2019-04-22 07:45:19', 3),
(851, '2019-04-22 07:45:21', 4),
(852, '2019-04-22 07:45:23', 5),
(853, '2019-04-23 07:45:13', 1),
(854, '2019-04-23 07:45:16', 2),
(855, '2019-04-23 07:45:18', 3),
(856, '2019-04-23 07:45:21', 4),
(857, '2019-04-23 07:45:23', 5),
(858, '2019-04-24 07:45:05', 1),
(859, '2019-04-24 07:45:07', 2),
(860, '2019-04-24 07:45:09', 3),
(861, '2019-04-24 07:45:12', 4),
(862, '2019-04-24 07:45:14', 5),
(863, '2019-04-25 07:45:05', 1),
(864, '2019-04-25 07:45:07', 2),
(865, '2019-04-25 07:45:10', 3),
(866, '2019-04-25 07:45:12', 4),
(867, '2019-04-25 07:45:14', 5),
(868, '2019-04-26 07:45:04', 1),
(869, '2019-04-26 07:45:06', 2),
(870, '2019-04-26 07:45:08', 3),
(871, '2019-04-26 07:45:11', 4),
(872, '2019-04-26 07:45:13', 5),
(873, '2019-04-27 07:45:04', 1),
(874, '2019-04-27 07:45:06', 2),
(875, '2019-04-27 07:45:08', 3),
(876, '2019-04-27 07:45:10', 4),
(877, '2019-04-27 07:45:13', 5),
(878, '2019-04-28 07:45:05', 1),
(879, '2019-04-28 07:45:07', 2),
(880, '2019-04-28 07:45:09', 3),
(881, '2019-04-28 07:45:12', 4),
(882, '2019-04-28 07:45:14', 5),
(883, '2019-04-29 07:45:04', 1),
(884, '2019-04-29 07:45:07', 2),
(885, '2019-04-29 07:45:09', 3),
(886, '2019-04-29 07:45:11', 4),
(887, '2019-04-29 07:45:14', 5),
(888, '2019-04-30 07:45:05', 1),
(889, '2019-04-30 07:45:07', 2),
(890, '2019-04-30 07:45:09', 3),
(891, '2019-04-30 07:45:12', 4),
(892, '2019-04-30 07:45:14', 5),
(893, '2019-05-02 07:45:04', 1),
(894, '2019-05-02 07:45:06', 2),
(895, '2019-05-02 07:45:09', 3),
(896, '2019-05-02 07:45:11', 4),
(897, '2019-05-02 07:45:13', 5),
(898, '2019-05-03 07:45:04', 1),
(899, '2019-05-03 07:45:06', 2),
(900, '2019-05-03 07:45:09', 3),
(901, '2019-05-03 07:45:11', 4),
(902, '2019-05-03 07:45:13', 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eps`
--

CREATE TABLE `eps` (
  `idEPS` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `eps`
--

INSERT INTO `eps` (`idEPS`, `nombre`, `estado`) VALUES
(1, 'Suramericana', 1),
(2, 'Aliansalud', 1),
(3, 'Sánitas ', 1),
(4, 'Compensar ', 1),
(5, 'Salud Total', 1),
(6, 'Nueva EPS', 1),
(7, 'Coomeva ', 1),
(8, 'Famisanar ', 1),
(9, 'Comfenalco Valle', 1),
(10, 'SaludVida ', 1),
(11, 'Cruz Blanca', 1),
(12, 'Cafesalud ', 1),
(13, 'Coosalud EPS', 1),
(14, 'Savia Salud EPS', 1),
(15, 'Sura', 1),
(16, 'Colsanitas', 1),
(17, 'Medimas', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_asistencia`
--

CREATE TABLE `estado_asistencia` (
  `idEstado_asistencia` tinyint(4) NOT NULL,
  `nombre` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estado_asistencia`
--

INSERT INTO `estado_asistencia` (`idEstado_asistencia`, `nombre`) VALUES
(1, 'A tiempo'),
(2, 'Tarde'),
(3, 'No asistio');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_civil`
--

CREATE TABLE `estado_civil` (
  `idEstado_civil` tinyint(4) NOT NULL,
  `nombre_estado` varchar(20) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estado_civil`
--

INSERT INTO `estado_civil` (`idEstado_civil`, `nombre_estado`, `estado`) VALUES
(1, 'Soltero/a', 1),
(2, 'Casado/a', 1),
(3, 'Viudo/a', 1),
(4, 'Unión Libre', 1),
(5, 'Separado/a', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_empresarial`
--

CREATE TABLE `estado_empresarial` (
  `idEstado_empresarial` smallint(6) NOT NULL,
  `idFicha_SD` smallint(6) NOT NULL,
  `estado_e` varchar(1) NOT NULL,
  `fecha_retiro` date DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `idMotivo` tinyint(4) NOT NULL,
  `idIndicador_rotacion` tinyint(1) NOT NULL,
  `observacion_retiro` varchar(250) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL,
  `idEmpresa` tinyint(4) NOT NULL,
  `impacto` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estado_empresarial`
--

INSERT INTO `estado_empresarial` (`idEstado_empresarial`, `idFicha_SD`, `estado_e`, `fecha_retiro`, `fecha_ingreso`, `idMotivo`, `idIndicador_rotacion`, `observacion_retiro`, `estado`, `idEmpresa`, `impacto`) VALUES
(1, 1, '1', '2018-12-07', '2018-01-29', 3, 3, 'Vinculación Colcircuitos', 1, 3, 0),
(2, 1, '2', '0000-00-00', '2018-12-26', 0, 0, '', 1, 1, 0),
(3, 2, '1', '2012-11-14', '2012-05-14', 3, 3, 'Terminación de prácticas', 1, 1, 0),
(4, 2, '2', '0000-00-00', '2012-11-15', 0, 0, '', 1, 1, 0),
(5, 3, '1', '2017-12-31', '2017-01-19', 3, 3, '', 1, 2, 0),
(6, 3, '2', '0000-00-00', '2018-01-01', 0, 0, '', 1, 1, 0),
(7, 4, '1', '2018-12-04', '2018-07-17', 3, 3, '', 1, 3, 0),
(8, 4, '2', '0000-00-00', '2019-01-08', 0, 0, '', 1, 1, 0),
(9, 5, '1', '2016-02-09', '2015-08-10', 3, 3, 'Terminación de práctica', 1, 1, 0),
(10, 5, '1', '2017-01-12', '2016-02-16', 3, 3, '', 1, 2, 0),
(11, 5, '2', '0000-00-00', '2017-01-18', 0, 0, '', 1, 1, 0),
(12, 6, '1', '2014-09-04', '2014-03-05', 3, 3, 'Terminación de prácticas', 1, 1, 0),
(13, 6, '2', '2018-12-14', '2015-01-16', 0, 0, 'Terminación de contrato', 1, 1, 0),
(14, 7, '1', '2018-09-30', '2018-04-19', 3, 3, '', 1, 3, 0),
(15, 7, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 1, 0),
(16, 8, '2', '0000-00-00', '2018-01-29', 0, 0, '', 1, 1, 0),
(17, 9, '1', '2018-12-04', '2018-07-16', 3, 0, '', 1, 3, 0),
(18, 9, '2', '0000-00-00', '2019-01-08', 0, 0, '', 1, 1, 0),
(19, 10, '1', '2016-06-30', '2016-02-22', 3, 3, '', 1, 2, 0),
(20, 10, '2', '0000-00-00', '2016-07-01', 0, 0, '', 1, 1, 0),
(21, 11, '1', '2018-09-30', '2018-05-07', 3, 3, '', 1, 2, 0),
(22, 11, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 1, 0),
(23, 12, '1', '2018-05-15', '2017-10-18', 3, 3, '', 1, 3, 0),
(24, 12, '2', '0000-00-00', '2018-05-16', 0, 0, '', 1, 1, 0),
(25, 13, '1', '2018-09-30', '2018-04-16', 3, 3, '', 1, 3, 0),
(26, 13, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 1, 0),
(27, 14, '2', '0000-00-00', '2015-05-01', 0, 0, '', 1, 1, 0),
(28, 15, '1', '2018-04-30', '2017-09-18', 3, 3, '', 1, 3, 0),
(29, 15, '2', '0000-00-00', '2018-05-01', 0, 0, '', 1, 1, 0),
(30, 16, '1', '2018-10-15', '2017-11-14', 3, 3, '', 1, 3, 0),
(31, 16, '2', '0000-00-00', '2018-10-16', 0, 0, '', 1, 1, 0),
(32, 17, '1', '2016-01-15', '2015-02-10', 3, 3, '', 1, 2, 0),
(33, 17, '2', '0000-00-00', '2016-01-25', 0, 0, '', 1, 1, 0),
(34, 18, '1', '2015-07-31', '2015-01-19', 3, 3, '', 1, 2, 0),
(35, 18, '2', '0000-00-00', '2015-08-01', 0, 0, '', 1, 1, 0),
(36, 19, '2', '0000-00-00', '2017-12-06', 0, 0, '', 1, 1, 0),
(37, 20, '1', '2018-06-01', '2017-03-16', 3, 3, '', 1, 2, 0),
(38, 20, '2', '0000-00-00', '2018-06-01', 0, 0, '', 1, 1, 0),
(39, 21, '1', '2018-12-21', '2018-04-16', 3, 0, '', 1, 3, 0),
(40, 21, '2', '0000-00-00', '2019-01-08', 0, 0, '', 1, 1, 0),
(41, 22, '1', '2018-07-24', '2018-01-25', 3, 3, 'Terminación Prácticas', 1, 1, 0),
(42, 22, '2', '0000-00-00', '2018-07-25', 0, 0, '', 1, 1, 0),
(43, 23, '1', '2018-02-08', '2017-10-02', 3, 3, '', 1, 3, 0),
(44, 23, '2', '0000-00-00', '2018-02-09', 0, 0, '', 1, 1, 0),
(45, 24, '1', '2017-09-07', '2017-03-08', 3, 3, 'Terminación de prácticas', 1, 1, 0),
(46, 24, '2', '0000-00-00', '2017-09-08', 0, 0, '', 1, 1, 0),
(47, 25, '2', '0000-00-00', '2016-12-26', 0, 0, '', 1, 1, 0),
(48, 26, '2', '0000-00-00', '2016-06-13', 0, 0, '', 1, 1, 0),
(49, 27, '1', '2017-10-01', '2017-02-13', 3, 3, '', 1, 2, 0),
(50, 27, '1', '2019-02-27', '2017-10-02', 1, 2, '', 1, 1, 3),
(51, 28, '1', '2017-08-24', '2017-03-16', 3, 3, '', 1, 2, 0),
(52, 28, '2', '0000-00-00', '2017-08-25', 0, 0, '', 1, 1, 0),
(53, 29, '1', '2015-03-21', '2014-09-22', 3, 3, 'Terminación de prácticas', 1, 1, 0),
(54, 29, '2', '0000-00-00', '2015-03-23', 0, 0, '', 1, 1, 0),
(55, 30, '1', '2018-09-30', '2018-05-07', 3, 3, '', 1, 2, 0),
(56, 30, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 1, 0),
(57, 31, '1', '2018-10-16', '2018-07-24', 3, 3, 'Para realizar practicas', 1, 1, 0),
(58, 31, '2', '0000-00-00', '2018-10-17', 0, 0, '', 1, 1, 0),
(59, 32, '1', '2018-09-30', '2018-05-07', 3, 3, '', 1, 2, 0),
(60, 32, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 1, 0),
(61, 33, '1', '2017-07-09', '2017-02-23', 3, 3, '', 1, 2, 0),
(62, 33, '2', '0000-00-00', '2017-07-10', 0, 0, '', 1, 1, 0),
(64, 34, '1', '2017-12-31', '2017-06-16', 3, 3, '', 1, 1, 0),
(65, 35, '1', '2008-05-01', '2008-03-13', 3, 3, '', 1, 8, 0),
(66, 35, '2', '0000-00-00', '2008-06-01', 0, 0, '', 1, 1, 0),
(69, 36, '1', '2015-04-30', '2013-08-16', 3, 3, '', 1, 9, 0),
(70, 36, '2', '0000-00-00', '2015-05-01', 0, 0, '', 1, 1, 0),
(71, 37, '1', '2018-04-30', '2017-10-13', 3, 3, '', 1, 2, 0),
(72, 37, '2', '0000-00-00', '2018-05-01', 0, 0, '', 1, 1, 0),
(73, 38, '1', '2016-10-15', '2015-11-03', 3, 3, '', 1, 2, 0),
(74, 38, '2', '0000-00-00', '2016-10-19', 0, 0, '', 1, 1, 0),
(75, 39, '1', '2019-02-06', '2011-12-05', 2, 3, '', 1, 1, 0),
(77, 41, '1', '2017-10-01', '2017-03-23', 3, 3, '', 1, 2, 0),
(78, 41, '2', '0000-00-00', '2017-10-02', 0, 0, '', 1, 1, 0),
(79, 42, '2', '0000-00-00', '2018-10-16', 0, 0, '', 1, 1, 0),
(80, 43, '1', '2017-11-15', '2017-08-11', 3, 3, '', 1, 3, 0),
(81, 43, '2', '0000-00-00', '2017-11-16', 0, 0, '', 1, 1, 0),
(82, 44, '2', '0000-00-00', '2011-07-25', 0, 0, '', 1, 1, 0),
(83, 45, '2', '0000-00-00', '2018-08-13', 0, 0, '', 1, 1, 0),
(84, 46, '2', '0000-00-00', '2009-06-01', 0, 0, '', 1, 1, 0),
(85, 47, '1', '2015-03-15', '2014-09-22', 3, 3, '', 1, 2, 0),
(86, 47, '1', '2019-02-14', '2015-03-16', 2, 3, '', 1, 1, 0),
(87, 48, '1', '2018-12-14', '2018-05-02', 0, 0, '', 1, 2, 0),
(88, 48, '2', '0000-00-00', '2018-12-26', 0, 0, '', 1, 1, 0),
(89, 49, '2', '0000-00-00', '2009-12-15', 0, 0, '', 1, 1, 0),
(90, 50, '2', '0000-00-00', '2013-05-06', 0, 0, '', 1, 1, 0),
(91, 51, '2', '0000-00-00', '2014-09-12', 0, 0, '', 1, 1, 0),
(92, 52, '1', '2008-05-01', '2005-05-10', 3, 3, '', 1, 8, 0),
(93, 52, '2', '0000-00-00', '2009-08-01', 0, 0, '', 1, 1, 0),
(95, 53, '2', '0000-00-00', '2012-04-09', 0, 0, '', 1, 1, 0),
(96, 54, '1', '2018-05-31', '2018-03-07', 3, 3, '', 1, 2, 0),
(97, 54, '2', '0000-00-00', '2018-06-01', 0, 0, '', 1, 1, 0),
(98, 55, '1', '2017-08-20', '2017-02-23', 3, 3, '', 1, 2, 0),
(99, 55, '2', '0000-00-00', '2017-08-22', 0, 0, '', 1, 1, 0),
(100, 56, '1', '2018-09-30', '2018-05-07', 3, 3, '', 1, 2, 0),
(101, 56, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 1, 0),
(102, 57, '1', '0000-00-00', '2012-10-24', 3, 3, '', 1, 9, 0),
(103, 57, '2', '0000-00-00', '2013-05-01', 0, 0, '', 1, 1, 0),
(104, 58, '1', '2018-04-01', '2017-10-19', 3, 3, '', 1, 3, 0),
(105, 58, '2', '0000-00-00', '2018-04-02', 0, 0, '', 1, 1, 0),
(106, 59, '1', '2019-03-01', '2018-07-24', 2, 3, 'Terminación de práctica.', 1, 1, 0),
(107, 60, '1', '2018-12-21', '2018-05-15', 3, 3, '', 1, 2, 0),
(108, 60, '1', '2019-03-04', '2019-01-21', 1, 1, '', 1, 1, 1),
(109, 61, '1', '2019-02-01', '2018-02-13', 2, 3, 'Termina misión', 1, 2, 0),
(110, 62, '1', '2019-03-15', '2018-09-24', 1, 2, '', 1, 2, 3),
(111, 63, '2', '0000-00-00', '2018-03-14', 0, 0, '', 1, 2, 0),
(112, 64, '2', '0000-00-00', '2018-08-16', 0, 0, '', 1, 3, 0),
(113, 65, '1', '2019-02-19', '2018-02-20', 2, 3, 'Termina misión e inicia otra misión el 4 de marzo', 1, 3, 0),
(114, 66, '2', '0000-00-00', '2018-08-28', 0, 0, '', 1, 3, 0),
(115, 67, '2', '0000-00-00', '2018-08-28', 0, 0, '', 1, 3, 0),
(116, 68, '1', '2018-12-28', '2018-09-13', 3, 3, '', 1, 3, 0),
(117, 68, '2', '0000-00-00', '2019-01-28', 0, 0, '', 1, 3, 0),
(118, 69, '1', '2018-12-07', '2018-03-07', 2, 3, '', 1, 3, 0),
(119, 70, '1', '2018-12-17', '2018-06-12', 2, 3, '', 1, 3, 0),
(120, 71, '1', '2019-04-07', '2018-03-07', 2, 3, '', 1, 3, 0),
(121, 72, '2', '0000-00-00', '2018-04-16', 0, 0, '', 1, 3, 0),
(122, 73, '2', '0000-00-00', '2018-08-28', 0, 0, '', 1, 3, 0),
(123, 74, '1', '2019-01-25', '2018-01-29', 0, 0, '', 1, 3, 0),
(124, 75, '2', '0000-00-00', '2018-09-24', 0, 0, '', 1, 3, 0),
(125, 76, '1', '2019-02-11', '2018-06-12', 2, 3, '', 1, 3, 0),
(126, 77, '1', '2018-12-21', '2018-05-15', 0, 0, '', 1, 3, 0),
(127, 77, '2', '0000-00-00', '2019-01-08', 0, 0, '', 1, 1, 0),
(128, 78, '2', '0000-00-00', '2018-07-11', 0, 0, '', 1, 3, 0),
(129, 80, '1', '2019-04-07', '2018-04-11', 3, 3, '', 1, 3, 0),
(130, 81, '2', '0000-00-00', '2018-09-13', 0, 0, '', 1, 3, 0),
(131, 82, '2', '0000-00-00', '2018-06-12', 0, 0, '', 1, 3, 0),
(132, 83, '1', '2019-02-20', '2018-09-25', 1, 2, '', 1, 3, 3),
(133, 84, '2', '0000-00-00', '2018-07-16', 0, 0, '', 1, 4, 0),
(134, 85, '2', '0000-00-00', '2018-05-07', 0, 0, '', 1, 4, 0),
(135, 86, '2', '0000-00-00', '2018-05-07', 0, 0, '', 1, 4, 0),
(136, 87, '2', '0000-00-00', '2018-09-03', 0, 0, '', 1, 4, 0),
(137, 88, '1', '2015-03-15', '2009-03-01', 3, 3, 'Cambio de empresa', 1, 1, 0),
(138, 88, '2', '0000-00-00', '2015-03-16', 0, 0, '', 1, 4, 0),
(139, 89, '2', '0000-00-00', '2018-10-01', 0, 0, '', 1, 4, 0),
(140, 90, '1', '2015-10-31', '2013-04-15', 3, 3, '', 1, 1, 0),
(141, 90, '2', '0000-00-00', '2015-11-01', 0, 0, '', 1, 4, 0),
(142, 91, '1', '2019-04-30', '2018-01-10', 1, 2, '', 1, 1, 3),
(143, 92, '1', '2013-08-07', '2013-02-08', 3, 3, 'Terminación prácticas', 1, 1, 0),
(144, 92, '2', '0000-00-00', '2013-08-08', 0, 0, '', 1, 1, 0),
(145, 93, '2', '0000-00-00', '2009-08-18', 0, 0, '', 1, 1, 0),
(146, 94, '1', '2015-01-15', '2014-10-27', 3, 3, '', 1, 2, 0),
(147, 94, '2', '0000-00-00', '2015-01-16', 0, 0, '', 1, 1, 0),
(148, 95, '2', '0000-00-00', '2019-01-02', 0, 0, '', 1, 4, 0),
(149, 96, '2', '0000-00-00', '2017-07-31', 0, 0, '', 1, 4, 0),
(150, 74, '1', '2019-02-28', '2019-02-04', 1, 1, '', 1, 3, 1),
(151, 97, '2', '0000-00-00', '2016-07-25', 0, 0, '', 1, 1, 0),
(152, 98, '2', '0000-00-00', '2019-02-05', 0, 0, '', 1, 1, 0),
(153, 69, '1', '2019-02-27', '2019-02-06', 2, 3, '', 1, 3, 0),
(154, 99, '2', '0000-00-00', '2002-12-13', 0, 0, '', 1, 1, 0),
(155, 100, '2', '0000-00-00', '2019-01-21', 0, 0, '', 1, 4, 0),
(156, 61, '1', '2019-02-27', '2019-02-11', 2, 3, '', 1, 3, 0),
(157, 101, '2', '0000-00-00', '2019-02-18', 0, 0, '', 1, 5, 0),
(158, 102, '2', '0000-00-00', '2019-02-18', 0, 0, '', 1, 5, 0),
(159, 65, '2', '0000-00-00', '2019-03-04', 0, 0, '', 1, 3, 0),
(161, 104, '2', '0000-00-00', '2018-10-22', 0, 0, '', 1, 3, 0),
(162, 105, '1', '2019-03-31', '2017-05-16', 1, 2, '', 1, 1, 3),
(163, 106, '1', '2018-12-28', '2018-10-22', 3, 3, '', 1, 3, 0),
(164, 107, '2', '0000-00-00', '2014-10-01', 0, 0, '', 1, 1, 0),
(165, 108, '2', '0000-00-00', '2002-12-13', 0, 0, '', 1, 1, 0),
(166, 109, '1', '2008-05-01', '2007-06-13', 3, 3, '', 1, 8, 0),
(167, 110, '2', '0000-00-00', '2015-11-04', 0, 0, '', 1, 1, 0),
(168, 111, '2', '0000-00-00', '2008-06-01', 0, 0, '', 1, 1, 0),
(169, 112, '2', '0000-00-00', '2013-06-01', 0, 0, '', 1, 1, 0),
(170, 113, '2', '0000-00-00', '2019-03-26', 0, 0, '', 1, 1, 0),
(171, 114, '2', '0000-00-00', '2018-12-17', 0, 0, '', 1, 1, 0),
(172, 79, '2', '0000-00-00', '2018-11-07', 0, 0, '', 1, 3, 0),
(173, 109, '2', '0000-00-00', '2008-06-01', 0, 0, '', 1, 1, 0),
(174, 103, '1', '2018-09-02', '2017-11-09', 3, 3, '', 1, 3, 0),
(175, 103, '2', '0000-00-00', '2018-09-03', 0, 0, '', 1, 1, 0),
(176, 106, '2', '0000-00-00', '2019-01-28', 0, 0, '', 1, 3, 0),
(177, 40, '1', '2014-07-30', '2014-01-13', 3, 3, '', 1, 9, 0),
(178, 40, '2', '0000-00-00', '2014-08-01', 0, 0, '', 1, 1, 0),
(181, 34, '2', '0000-00-00', '2018-01-15', 0, 0, '', 1, 1, 0),
(183, 80, '2', '0000-00-00', '2019-04-08', 0, 0, '', 1, 5, 0),
(184, 115, '2', '0000-00-00', '2019-04-22', 0, 0, '', 1, 5, 0),
(185, 59, '2', '0000-00-00', '2019-04-22', 0, 0, '', 1, 3, 0),
(186, 116, '2', '0000-00-00', '2019-05-02', 0, 0, '', 1, 5, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estudios`
--

CREATE TABLE `estudios` (
  `idEstudios` smallint(6) NOT NULL,
  `idGrado_escolaridad` tinyint(4) NOT NULL,
  `titulo_profecional` varchar(50) DEFAULT NULL,
  `titulo_especializacion` varchar(50) DEFAULT NULL,
  `titulo_estudios_actuales` varchar(1) DEFAULT NULL,
  `nombre_carrera` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estudios`
--

INSERT INTO `estudios` (`idEstudios`, `idGrado_escolaridad`, `titulo_profecional`, `titulo_especializacion`, `titulo_estudios_actuales`, `nombre_carrera`) VALUES
(1, 3, 'Automatizacion industrial', '', '0', ''),
(2, 3, 'Electronica', '', '0', ''),
(3, 2, 'Contabilidad', '', '3', 'Contador publico'),
(4, 2, 'ASISTENCIA ADMINISTRATIVA', '', '0', ''),
(5, 2, 'Electronico', '', '5', 'Ingenieria electronica'),
(6, 3, 'Administracion de negocios y administracion public', '', '3', 'Administracion financiera'),
(7, 4, 'Negocios internacionales', '', '0', ''),
(8, 2, 'Administración en salud', '', '0', ''),
(9, 2, 'Secretariado General', '', '0', ''),
(10, 5, 'Industrial', '', '4', 'Negocios internacionales'),
(11, 1, '', '', '2', 'Contabilidad'),
(12, 1, '', '', '0', ''),
(13, 2, 'Acompañamiento en educacion infantil', '', '0', ''),
(14, 4, 'Contador publico', '', '0', ''),
(15, 3, 'Direccion en ventas ', 'Direccion en ventas ', '0', ''),
(16, 2, 'SG-SST', '', '0', ''),
(17, 1, '', '', '2', 'Electromecánica '),
(18, 3, 'Comercio internacional', 'Logistica internacional', '0', ''),
(19, 3, 'Electronica', '', '3', 'Ingenieria electronica'),
(20, 1, '', '', '0', ''),
(21, 1, 'Bachiller academico', '', '0', ''),
(22, 3, 'Electrónico', '', '0', ''),
(23, 3, 'Mecatronica', '', '0', ''),
(24, 3, 'Mantenimiento electrónico', '', '0', ''),
(25, 2, 'Administracion', '', '5', 'Ingenieria de software'),
(26, 5, 'Ingeniera productividad y calidad', '', '0', ''),
(27, 1, '', '', '0', ''),
(28, 1, 'Bachillerato academico', '', '0', ''),
(29, 2, 'Nomina y prestaciones sociales', '', '3', 'Gestion administrativa'),
(30, 3, 'Mercadeo y ventas', '', '4', 'Mercadeo y ventas'),
(31, 2, 'Electronica digital', '', '0', ''),
(32, 3, 'Automatizacion industrial', '', '0', ''),
(33, 3, 'Electromecánica', '', '0', ''),
(34, 3, 'Analista desarrollador de sistema de informacion', '', '0', ''),
(35, 1, '', '', '0', ''),
(36, 1, '', '', '0', ''),
(37, 3, 'Mantenimiento electrónico', '', '0', ''),
(38, 1, 'Bachiller academico', '', '0', ''),
(39, 2, 'Contabilidad', '', '0', ''),
(40, 1, '', '', '0', ''),
(41, 1, '', '', '0', ''),
(42, 4, 'Licenciatura educacion especial', '', '0', ''),
(43, 2, 'Mecánica Automotriz', '', '0', ''),
(44, 2, 'Electronica', '', '0', ''),
(45, 4, 'Contadora publica', '', '0', ''),
(46, 1, '', '', '0', ''),
(47, 2, 'Contabilidad', 'NIIF', '0', ''),
(48, 1, 'Bachille academico', '', '0', ''),
(49, 1, 'Bachillerato', '', '0', ''),
(50, 4, 'Negociadora internacional', '', '0', ''),
(51, 1, 'Bachiller', '', '0', ''),
(52, 1, 'Bachiller academico', '', '0', ''),
(53, 5, 'Electronico', 'Gestion en proyectos', '0', ''),
(54, 5, 'Electrónico', '', '0', ''),
(55, 1, '', '', '0', ''),
(56, 3, 'Telecomunicaciones', '', '5', 'Cisco'),
(57, 3, 'Tecnologo electronico', '', '5', 'Electronico'),
(58, 2, 'Gerenciamiento comercial', '', '3', 'Gestion empresarial'),
(59, 2, 'Electrónico', '', '0', ''),
(60, 1, 'Bachiller academico', '', '0', ''),
(61, 3, 'Mantenimiento electronico', '', '0', ''),
(62, 3, 'Electronica', '', '0', ''),
(63, 2, 'Redes y telecomunicación', '', '0', ''),
(64, 1, 'Bachiller academico', '', '0', ''),
(65, 2, 'Secretariado ejecutivo', '', '0', ''),
(66, 2, 'Mercadeo y ventas', 'Mercadeo y ventas', '0', ''),
(67, 1, 'Bachiller', '', '0', ''),
(68, 3, 'Electronica', '', '5', 'Ingenieria industrial'),
(69, 1, 'Bachiller academico', '', '0', ''),
(70, 2, 'SG-SST', '', '0', ''),
(71, 1, 'BACHILLER ACADEMICO', '', '0', ''),
(72, 1, 'N/A', '', '0', ''),
(73, 2, 'Salud y nutrición', '', '2', 'Gestión de Recursos en Plantas de Producción'),
(74, 1, 'BACHILLER ACADEMICO', '', '0', ''),
(75, 1, 'Bachiller academico', '', '0', ''),
(76, 2, 'Salud oral- Mantenimiento en motores diesel', '', '3', 'Electromecanica'),
(77, 2, 'Electrónica', '', '3', 'Electrónico'),
(78, 1, 'Bachiller Academico', '', '0', ''),
(79, 3, 'Contabilidad y finanza', '', '4', 'Contaduría Pública'),
(80, 1, 'Bachiller academico', '', '0', ''),
(81, 4, 'SG-SST', '', '4', 'SG-SST'),
(82, 1, 'Bachiller académico', '', '1', 'Académico'),
(83, 1, 'Bachiller aacademico', '', '0', ''),
(84, 5, 'Instrumentacion y control', '', '0', ''),
(85, 5, 'Electrónico', '', '0', ''),
(86, 5, 'Electrónico', '', '0', ''),
(87, 8, 'ELECTRONICA', 'Maestria', '0', ''),
(88, 3, 'Electronica', 'Sistema automatico de control', '0', ''),
(89, 5, 'Instrumentacion y control', 'Maestria', '0', ''),
(90, 8, 'Ingeniero de control', 'Maestria', '0', ''),
(91, 3, 'Tecnologo electronico', '', '0', ''),
(92, 4, 'Administrador de Empresas', '', '0', ''),
(93, 5, 'Ingeniero Electronico', '', '0', ''),
(94, 2, 'Diseñadora grafica', '', '0', ''),
(95, 5, 'Ingeniera electronica', '', '6', 'Ingenieria de proyectos'),
(96, 5, 'Electrónico', '', '6', 'Sistemas Embebidos '),
(97, 8, 'Ingeniero de producción', 'Finanzas  y negocios internacionales ', '0', ''),
(98, 1, 'Bachiller Académico', '', '4', 'Administración de empresas financieras'),
(99, 6, 'Electrónico', 'Gestion de la innovación', '0', ''),
(100, 5, 'Ingeniero Electrónico', 'Telecomunicaciones', '0', ''),
(101, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(102, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(103, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(104, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(105, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(106, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(107, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(108, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(109, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(110, 3, 'Gestión Administrativa', '', '4', 'Administración de empresas'),
(111, 3, '', '', '4', 'Profecional en DiseñoDigital y Marketing Digital'),
(112, 2, 'Sistema', '', '0', ''),
(113, 1, 'bachiller académico ', '', '0', ''),
(114, 3, 'Docente Básica ', '', '4', 'Psicología '),
(115, 2, 'Electrónica y Telecomunicaciones', '', '0', ''),
(116, 6, 'Ingeniera Industrial', 'Costos y Negocios Internacionales', '0', ''),
(117, 4, 'Comunicador Social', '', '0', ''),
(118, 5, 'Ingeniera Administrativa', '', '0', ''),
(119, 2, 'Mecanica Dental', '', '0', ''),
(120, 2, 'Mecanica Dental', '', '0', ''),
(121, 2, 'Mecanica Dental', '', '0', ''),
(122, 2, 'Mecanica Dental', '', '0', ''),
(123, 2, 'Mecanica Dental', '', '0', ''),
(124, 2, 'Mecanica Dental', '', '0', ''),
(125, 5, 'Alimentos', '', '0', ''),
(126, 1, 'Media técnica en mecánica de presión', '', '0', ''),
(127, 2, 'Tecnico en operaciòn de eventos', '', '0', ''),
(128, 1, 'Bachiller Media Tecnica en Sistemas', '', '0', ''),
(129, 4, 'Comunicadora Social Periodista', '', '0', ''),
(130, 4, 'Abogada ', '', '0', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evento_laboral`
--

CREATE TABLE `evento_laboral` (
  `idEvento_laboral` tinyint(4) NOT NULL,
  `nombre` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `evento_laboral`
--

INSERT INTO `evento_laboral` (`idEvento_laboral`, `nombre`) VALUES
(1, 'Horas Normales'),
(2, 'Horas Extras'),
(3, 'Horas Extra Diurna'),
(4, 'Horas Extras Nocturnas'),
(5, 'Recargo Nocturno'),
(6, 'Recargo Festivo'),
(7, 'Horas Extra Festivas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `examenes_medicos`
--

CREATE TABLE `examenes_medicos` (
  `idexamenes_Medicos` int(11) NOT NULL,
  `documento` varchar(20) CHARACTER SET utf8 NOT NULL,
  `fechaCarta` date NOT NULL,
  `fechaPlazo` date NOT NULL,
  `tipoExamenes` tinyint(1) NOT NULL,
  `otroExamen` varchar(70) DEFAULT NULL,
  `fechaRetorno` date DEFAULT NULL,
  `motivo` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ficha_sd`
--

CREATE TABLE `ficha_sd` (
  `idFicha_SD` smallint(6) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `idSalarial` smallint(6) NOT NULL,
  `idLaboral` smallint(6) NOT NULL,
  `idEstudios` smallint(6) NOT NULL,
  `idSecundaria_basica` smallint(6) NOT NULL,
  `idPersonal` smallint(6) NOT NULL,
  `idSalud` smallint(6) NOT NULL,
  `idOtros` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `ficha_sd`
--

INSERT INTO `ficha_sd` (`idFicha_SD`, `documento`, `idSalarial`, `idLaboral`, `idEstudios`, `idSecundaria_basica`, `idPersonal`, `idSalud`, `idOtros`) VALUES
(1, '1013537192', 1, 1, 1, 1, 1, 1, 1),
(2, '1017156424', 2, 2, 2, 2, 2, 2, 2),
(3, '1017239142', 3, 3, 3, 3, 3, 3, 3),
(4, '1020457057', 4, 4, 4, 4, 4, 4, 4),
(5, '1020479554', 5, 5, 5, 5, 5, 5, 5),
(6, '1028009266', 6, 6, 6, 6, 6, 6, 6),
(7, '1028016893', 7, 7, 7, 7, 7, 7, 7),
(8, '1035915735', 8, 8, 8, 8, 8, 8, 8),
(9, '1036598684', 9, 9, 9, 9, 9, 9, 9),
(10, '1036609702', 10, 10, 10, 10, 10, 10, 10),
(11, '1036629003', 11, 11, 11, 11, 11, 11, 11),
(12, '1036651097', 12, 12, 12, 12, 12, 12, 12),
(13, '1037587834', 13, 13, 13, 13, 13, 13, 13),
(14, '1037606721', 14, 14, 14, 14, 14, 14, 14),
(15, '1037631569', 15, 15, 15, 15, 15, 15, 15),
(16, '1037949696', 16, 16, 16, 16, 16, 16, 16),
(17, '1039049115', 17, 17, 17, 17, 17, 17, 17),
(18, '1039447684', 18, 18, 18, 18, 18, 18, 18),
(19, '1040044905', 19, 19, 19, 19, 19, 19, 19),
(20, '1046913982', 20, 20, 20, 20, 20, 20, 20),
(21, '1077453248', 21, 21, 21, 21, 21, 21, 21),
(22, '1090523316', 22, 22, 22, 22, 22, 22, 22),
(23, '1095791547', 23, 23, 23, 23, 23, 23, 23),
(24, '1096238261', 24, 24, 24, 24, 24, 24, 24),
(25, '1128266934', 25, 25, 25, 25, 25, 25, 25),
(26, '1128267430', 26, 26, 26, 26, 26, 26, 26),
(27, '1128390700', 27, 27, 27, 27, 27, 27, 27),
(28, '1143991147', 28, 28, 28, 28, 28, 28, 28),
(29, '1152210828', 29, 29, 29, 29, 29, 29, 29),
(30, '1152697088', 30, 30, 30, 30, 30, 30, 30),
(31, '1152701919', 31, 31, 31, 31, 31, 31, 31),
(32, '1216714539', 32, 32, 32, 32, 32, 32, 32),
(33, '1216716458', 33, 33, 33, 33, 33, 33, 33),
(34, '1216727816', 34, 34, 34, 34, 34, 34, 34),
(35, '15489896', 35, 35, 35, 35, 35, 35, 35),
(36, '15489917', 36, 36, 36, 36, 36, 36, 36),
(37, '15515649', 37, 37, 37, 37, 37, 37, 37),
(38, '21424773', 38, 38, 38, 38, 38, 38, 38),
(39, '32242675', 39, 39, 39, 39, 39, 39, 39),
(40, '42702332', 40, 40, 40, 40, 40, 40, 40),
(41, '43189198', 41, 41, 41, 41, 41, 41, 41),
(42, '43265824', 42, 42, 42, 42, 42, 42, 42),
(43, '43288005', 43, 43, 43, 43, 43, 43, 43),
(44, '43542658', 44, 44, 44, 44, 44, 44, 44),
(45, '43596807', 45, 45, 45, 45, 45, 45, 45),
(46, '43605625', 46, 46, 46, 46, 46, 46, 46),
(47, '43841319', 47, 47, 47, 47, 47, 47, 47),
(48, '43866346', 48, 48, 48, 48, 48, 48, 48),
(49, '43975208', 49, 49, 49, 49, 49, 49, 49),
(50, '53146320', 50, 50, 50, 50, 50, 50, 50),
(51, '54253320', 51, 51, 51, 51, 51, 51, 51),
(52, '71267825', 52, 52, 52, 52, 52, 52, 52),
(53, '71268332', 53, 53, 53, 53, 53, 53, 53),
(54, '760579', 54, 54, 54, 54, 54, 54, 54),
(55, '8433778', 55, 55, 55, 55, 55, 55, 55),
(56, '98668402', 56, 56, 56, 56, 56, 56, 56),
(57, '98699433', 57, 57, 57, 57, 57, 57, 57),
(58, '98765201', 58, 58, 58, 58, 58, 58, 58),
(59, '98772784', 59, 59, 59, 59, 59, 59, 59),
(60, '1007310520', 60, 60, 60, 60, 60, 60, 60),
(61, '1017216447', 61, 61, 61, 61, 61, 61, 61),
(62, '1017240253', 62, 62, 62, 62, 62, 62, 62),
(63, '1128450516', 63, 63, 63, 63, 63, 63, 63),
(64, '1007110815', 64, 64, 64, 64, 64, 64, 64),
(65, '1017125039', 65, 65, 65, 65, 65, 65, 65),
(66, '1017179570', 66, 66, 66, 66, 66, 66, 66),
(67, '1017187557', 67, 67, 67, 67, 67, 67, 67),
(68, '1017225857', 68, 68, 68, 68, 68, 68, 68),
(69, '1020430141', 69, 69, 69, 69, 69, 69, 69),
(70, '1020464577', 70, 70, 70, 70, 70, 70, 70),
(71, '1036601013', 71, 71, 71, 71, 71, 71, 71),
(72, '1036612156', 72, 72, 72, 72, 72, 72, 72),
(73, '1036622270', 73, 73, 73, 73, 73, 73, 73),
(74, '1036680551', 74, 74, 74, 74, 74, 74, 74),
(75, '1037949573', 75, 75, 75, 75, 75, 75, 75),
(76, '1143366120', 76, 76, 76, 76, 76, 76, 76),
(77, '1152450553', 77, 77, 77, 77, 77, 77, 77),
(78, '1214721942', 78, 78, 78, 78, 78, 78, 78),
(79, '1214734202', 79, 79, 79, 79, 79, 79, 79),
(80, '32353491', 80, 80, 80, 80, 80, 80, 80),
(81, '43342456', 81, 81, 81, 81, 81, 81, 81),
(82, '44006996', 82, 82, 82, 82, 82, 82, 82),
(83, '71759957', 83, 83, 83, 83, 83, 83, 83),
(84, '1022096414', 84, 84, 84, 84, 84, 84, 84),
(85, '1036634996', 85, 85, 85, 85, 85, 85, 85),
(86, '1039464479', 86, 86, 86, 86, 86, 86, 86),
(87, '1125779563', 87, 87, 87, 87, 87, 87, 87),
(88, '78758797', 88, 88, 88, 88, 88, 88, 88),
(89, '8355460', 89, 89, 89, 89, 89, 89, 89),
(90, '98766299', 90, 90, 90, 90, 90, 90, 90),
(91, '8102064', 91, 91, 91, 91, 91, 91, 91),
(92, '1017171421', 92, 92, 92, 92, 92, 92, 92),
(93, '71055289', 93, 93, 93, 93, 93, 93, 93),
(94, '43263856', 94, 94, 94, 94, 94, 94, 94),
(95, '1152206404', 95, 95, 95, 95, 95, 95, 95),
(96, '1037616343', 96, 96, 96, 96, 96, 96, 96),
(97, '71765000', 97, 97, 97, 97, 97, 97, 97),
(98, '1036650501', 98, 98, 98, 98, 98, 98, 98),
(99, '71774995', 99, 99, 99, 99, 99, 99, 99),
(100, '71709575', 100, 100, 100, 100, 100, 100, 100),
(101, '43161988', 101, 110, 110, 101, 101, 101, 101),
(102, '1020446405', 102, 111, 111, 102, 102, 102, 102),
(103, '1036625052', 103, 112, 112, 103, 103, 103, 103),
(104, '23917651', 104, 113, 113, 104, 104, 104, 104),
(105, '1017208475', 105, 114, 114, 105, 105, 105, 105),
(106, '80145967', 106, 115, 115, 106, 106, 106, 106),
(107, '43583398', 107, 116, 116, 107, 107, 107, 107),
(108, '98558437', 108, 117, 117, 108, 108, 108, 108),
(109, '43271378', 109, 118, 118, 109, 109, 109, 109),
(110, '1017219391', 110, 124, 124, 110, 110, 110, 110),
(111, '43749878', 111, 125, 125, 111, 111, 111, 111),
(112, '8344177', 112, 126, 126, 112, 112, 112, 112),
(113, '1000633612', 113, 127, 127, 113, 113, 113, 113),
(114, '1001545147', 114, 128, 128, 114, 114, 114, 114),
(115, '1152195364', 115, 129, 129, 115, 115, 115, 115),
(116, '955297213061995', 116, 130, 130, 116, 116, 116, 116);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grado_escolaridad`
--

CREATE TABLE `grado_escolaridad` (
  `idGrado_escolaridad` tinyint(4) NOT NULL,
  `grado` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `grado_escolaridad`
--

INSERT INTO `grado_escolaridad` (`idGrado_escolaridad`, `grado`, `estado`) VALUES
(1, 'Bachiller', 1),
(2, 'Técnico', 1),
(3, 'Tecnología', 1),
(4, 'Profesional', 1),
(5, 'Ingeniería', 1),
(6, 'Especialización', 1),
(7, 'Maestría ', 1),
(8, 'Posgrado', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario_permiso`
--

CREATE TABLE `horario_permiso` (
  `idHorario_permiso` tinyint(4) NOT NULL,
  `momento` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `horario_permiso`
--

INSERT INTO `horario_permiso` (`idHorario_permiso`, `momento`) VALUES
(1, 'Salida temprano'),
(2, 'Ingreso tarde'),
(3, 'Salida e ingreso');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario_trabajo`
--

CREATE TABLE `horario_trabajo` (
  `idHorario_trabajo` tinyint(4) NOT NULL,
  `horario` varchar(20) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `horario_trabajo`
--

INSERT INTO `horario_trabajo` (`idHorario_trabajo`, `horario`, `estado`) VALUES
(1, '6:00 AM a 4:30 PM', 1),
(2, '7:00 AM a 5:30 PM', 1),
(3, '7:30 AM a 5:30 PM', 1),
(4, '8:00 AM a 6:00 PM', 1),
(5, '6:00 AM a 5:30 PM', 1),
(6, '8:00 AM a 5:30 PM', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `h_laboral`
--

CREATE TABLE `h_laboral` (
  `idH_laboral` int(11) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `idEvento_laboral` tinyint(4) NOT NULL,
  `fecha_laboral` date NOT NULL,
  `numero_horas` varchar(8) NOT NULL,
  `Estado` tinyint(1) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `horas_aceptadas` varchar(8) DEFAULT '0',
  `horas_rechazadas` varchar(8) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `h_laboral`
--

INSERT INTO `h_laboral` (`idH_laboral`, `documento`, `idEvento_laboral`, `fecha_laboral`, `numero_horas`, `Estado`, `descripcion`, `horas_aceptadas`, `horas_rechazadas`) VALUES
(1, '1216727816', 1, '2019-05-15', '00:22:44', 1, NULL, '00:22:44', '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `incapacidad`
--

CREATE TABLE `incapacidad` (
  `idIncapacidad` int(11) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `fecha_incapacidad` date NOT NULL,
  `fecha_fin_incapacidad` date NOT NULL,
  `dias` varchar(4) NOT NULL,
  `valor_eps` varchar(13) DEFAULT NULL,
  `valor_arl` varchar(13) DEFAULT NULL,
  `valor_empresa` varchar(13) DEFAULT NULL,
  `valor_descuento` varchar(13) NOT NULL,
  `Diagnostico_idDiagnostico` varchar(4) NOT NULL,
  `descripcion` varchar(100) NOT NULL,
  `idTipoIncapacidad` tinyint(1) NOT NULL,
  `idEnfermedad` tinyint(1) NOT NULL,
  `reintegro` varchar(11) NOT NULL DEFAULT '',
  `diferencia` varchar(11) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `incapacidad`
--

INSERT INTO `incapacidad` (`idIncapacidad`, `documento`, `fecha_incapacidad`, `fecha_fin_incapacidad`, `dias`, `valor_eps`, `valor_arl`, `valor_empresa`, `valor_descuento`, `Diagnostico_idDiagnostico`, `descripcion`, `idTipoIncapacidad`, `idEnfermedad`, `reintegro`, `diferencia`) VALUES
(1, '1017187557', '2019-02-01', '2019-02-02', '2', '', '', '55.207,733', '55.207,733', 'N390', '', 1, 1, '', ''),
(2, '43265824', '2019-01-28', '2019-01-28', '1', '', '', '28.663,867', '28.663,867', 'G439', '', 1, 1, '', ''),
(3, '1022096414', '2019-01-02', '2019-01-02', '1', '', '', '50.000', '50.000', 'R509', '', 1, 1, '', '50.000'),
(4, '1152450553', '2019-02-26', '2019-02-27', '2', '', '', '63.600', '63.600', 'A09X', '', 1, 1, '', ''),
(5, '43975208', '2019-02-21', '2019-02-21', '1', '', '', '34.666,667', '34.666,667', 'R42X', '', 1, 1, '', ''),
(6, '1046913982', '2019-02-20', '2019-02-20', '1', '', '', '28.663,867', '28.663,867', 'M624', '', 1, 1, '', ''),
(7, '21424773', '2019-02-22', '2019-02-22', '1', '', '', '28.663,867', '28.663,867', 'K589', '', 1, 1, '', ''),
(8, '1036629003', '2019-02-21', '2019-02-23', '3', '19.396,859', '', '67.884,641', '87.281,5', 'R520', '', 1, 1, '27604', '-8.208'),
(9, '1152210828', '2019-02-26', '2019-02-27', '2', '', '', '64.800', '64.800', 'B349', '', 1, 1, '', ''),
(10, '1036629003', '2019-02-04', '2019-02-05', '2', '', '', '58.187,667', '58.187,667', 'G442', '', 1, 1, '', ''),
(11, '8433778', '2019-02-12', '2019-02-12', '1', '', '', '27.603,867', '27.603,867', 'K30X', '', 1, 1, '', ''),
(12, '43975208', '2019-02-01', '2019-02-01', '1', '', '', '34.666,667', '34.666,667', 'S341', '', 1, 1, '', ''),
(13, '1216714539', '2019-02-13', '2019-02-13', '1', '', '', '33.333,333', '33.333,333', 'B349', '', 1, 1, '', ''),
(14, '43189198', '2019-02-06', '2019-02-07', '2', '', '', '57.327,733', '57.327,733', 'H000', '', 1, 1, '', ''),
(15, '1036651097', '2019-02-06', '2019-02-06', '1', '', '', '29.093,833', '29.093,833', 'A09X', '', 1, 1, '', ''),
(16, '1037587834', '2019-02-08', '2019-02-08', '1', '', '', '30.416,167', '30.416,167', 'R102', '', 1, 1, '', ''),
(17, '1037949696', '2019-02-12', '2019-02-16', '5', '57.330,6', '', '85.988,734', '143.319,333', 'T07X', '', 1, 1, '82812', '-25.482'),
(18, '43189198', '2019-01-01', '2019-01-09', '9', '133.771,399', '', '124.203,401', '257.974,8', 'K103', '', 1, 1, '', ''),
(19, '43189198', '2019-01-10', '2019-01-11', '2', '', '', '57.327,733', '57.327,733', 'K103', '', 1, 2, '', ''),
(20, '43189198', '2019-01-10', '2019-01-11', '2', '', '', '57.327,733', '57.327,733', 'K103', '', 1, 2, '', ''),
(21, '23917651', '2019-02-20', '2019-02-22', '3', '18.403,498', '', '64.408,102', '82.811,6', 'J00X', '', 1, 1, '', ''),
(22, '80145967', '2019-02-11', '2019-02-12', '2', '', '', '60.856,333', '60.856,333', 'B349', '', 1, 1, '', ''),
(23, '1007310520', '2019-03-01', '2019-03-01', '1', '', '', '28.663,867', '28.663,867', 'R51X', '', 1, 1, '', ''),
(24, '1037949696', '2019-03-13', '2019-03-13', '1', '', '', '28.663,867', '28.663,867', 'A09X', '', 1, 1, '', ''),
(25, '1037949696', '2019-03-12', '2019-03-12', '1', '', '', '28.663,867', '28.663,867', 'A09X', '', 1, 1, '', ''),
(26, '1037949696', '2019-03-13', '2019-03-13', '1', '', '', '28.663,867', '28.663,867', 'A09X', '', 1, 1, '', ''),
(27, '1143991147', '2019-02-28', '2019-03-02', '3', '19.110,2', '', '66.881,4', '85.991,6', 'G448', '', 1, 1, '', ''),
(28, '1040044905', '2019-03-07', '2019-03-07', '1', '', '', '32.700', '32.700', 'J012', '', 1, 1, '', ''),
(29, '1039049115', '2019-03-11', '2019-03-11', '1', '', '', '29.530,233', '29.530,233', 'L031', '', 1, 1, '', ''),
(30, '1017219391', '2019-02-07', '2019-02-13', '7', '92.017,49', '', '101.209,577', '193.227,067', 'S836', '', 1, 2, '', ''),
(31, '1017219391', '2019-02-14', '2019-03-15', '30', '515.297,941', '', '312.818,059', '828.116', 'S835', '', 1, 2, '', ''),
(32, '43263856', '2019-03-08', '2019-03-14', '7', '109.205,46', '', '120.114,54', '229.320', 'O16X', '', 1, 1, '138019', '-28.814'),
(33, '1017219391', '2019-01-17', '2019-02-05', '20', '331.262,962', '', '220.814,371', '552.077,333', 'S835', '', 1, 2, '', ''),
(34, '43189198', '2019-03-13', '2019-03-14', '2', '', '', '57.327,733', '57.327,733', 'J019', '', 1, 1, '', ''),
(35, '32353491', '2019-03-11', '2019-03-12', '2', '', '', '55.207,733', '55.207,733', 'A083', '', 1, 1, '', ''),
(36, '1020446405', '2019-03-15', '2019-03-15', '1', '', '', '33.333,333', '33.333,333', 'R104', '', 1, 1, '', ''),
(37, '1143991147', '2019-03-14', '2019-03-16', '3', '19.110,2', '', '66.881,4', '85.991,6', 'O231', '', 1, 1, '', ''),
(38, '43271378', '2019-03-26', '2019-03-27', '2', '', '', '104.000', '104.000', 'K529', '', 1, 1, '', ''),
(39, '1039464479', '2019-03-19', '2019-03-19', '1', '', '', '52.000', '52.000', 'Z048', '', 1, 1, '', ''),
(40, '1143991147', '2019-03-26', '2019-03-27', '2', '', '', '57.327,733', '57.327,733', 'G442', '', 1, 1, '', ''),
(41, '1096238261', '2019-03-27', '2019-03-28', '2', '', '', '60.000', '60.000', 'J00X', '', 1, 1, '', ''),
(42, '21424773', '2019-03-19', '2019-03-20', '2', '', '', '57.327,733', '57.327,733', 'R104', '', 1, 1, '', ''),
(43, '43265824', '2019-03-19', '2019-03-19', '1', '', '', '28.663,867', '28.663,867', 'A09X', '', 1, 1, '', ''),
(44, '1152701919', '2019-03-22', '2019-03-22', '1', '', '', '26.041,4', '26.041,4', 'T110', '', 1, 1, '', ''),
(45, '1036598684', '2019-03-22', '2019-03-22', '1', '', '', '28.663,867', '28.663,867', 'G439', '', 1, 1, '', ''),
(46, '43263856', '2019-03-20', '2019-07-23', '126', '4.127.760', '', '', '4.127.760', 'O800', '', 3, 1, '', ''),
(47, '1017125039', '2019-03-29', '2019-03-30', '2', '', '', '55.207,733', '55.207,733', 'M239', '', 1, 1, '', ''),
(48, '1143991147', '2019-04-25', '2019-04-26', '2', '', '', '57.327,733', '57.327,733', 'O233', '', 1, 1, '', ''),
(49, '1020446405', '2019-04-05', '2019-04-05', '1', '', '', '33.333,333', '33.333,333', 'L028', '', 1, 1, '', ''),
(50, '1143991147', '2019-04-10', '2019-04-11', '2', '', '', '57.327,733', '57.327,733', 'O268', '', 1, 1, '', ''),
(51, '1036629003', '2019-04-02', '2019-04-03', '2', '', '', '58.187,667', '58.187,667', 'G442', '', 1, 1, '', ''),
(52, '1143991147', '2019-04-10', '2019-04-11', '2', '', '', '57.327,733', '57.327,733', 'O268', '', 1, 1, '', ''),
(53, '1017125039', '2019-04-04', '2019-04-23', '20', '331.262,962', '', '220.814,371', '552.077,333', 'S834', '', 1, 1, '', ''),
(54, '23917651', '2019-04-09', '2019-04-13', '5', '55.210,494', '', '82.808,84', '138.019,333', 'M238', '', 1, 2, '', ''),
(55, '23917651', '2019-04-05', '2019-04-09', '5', '55.210,494', '', '82.808,84', '138.019,333', 'M238', '', 1, 1, '', ''),
(56, '43605625', '2019-04-10', '2019-04-10', '1', '', '', '29.093,833', '29.093,833', 'A060', '', 1, 1, '', ''),
(57, '23917651', '2019-04-02', '2019-04-03', '2', '', '', '55.207,733', '55.207,733', 'M255', '', 1, 1, '', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `indicador_rotacion`
--

CREATE TABLE `indicador_rotacion` (
  `idIndicador_rotacion` tinyint(1) NOT NULL,
  `nombre` varchar(20) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `indicador_rotacion`
--

INSERT INTO `indicador_rotacion` (`idIndicador_rotacion`, `nombre`, `estado`) VALUES
(1, 'Deseada', 1),
(2, 'No deseada', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `laboral`
--

CREATE TABLE `laboral` (
  `idLaboral` smallint(6) NOT NULL,
  `idHorario_trabajo` tinyint(4) NOT NULL,
  `idArea_trabajo` tinyint(4) NOT NULL,
  `idCargo` tinyint(4) NOT NULL,
  `recurso_humano` tinyint(1) NOT NULL,
  `idTipo_contrato` tinyint(4) NOT NULL,
  `fecha_vencimiento_contrato` date DEFAULT NULL,
  `antiguedad` varchar(25) DEFAULT NULL,
  `idClasificacion_contable` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `laboral`
--

INSERT INTO `laboral` (`idLaboral`, `idHorario_trabajo`, `idArea_trabajo`, `idCargo`, `recurso_humano`, `idTipo_contrato`, `fecha_vencimiento_contrato`, `antiguedad`, `idClasificacion_contable`) VALUES
(1, 1, 20, 32, 0, 2, '0000-00-00', NULL, 7),
(2, 1, 21, 20, 1, 2, '0000-00-00', NULL, 7),
(3, 2, 13, 27, 0, 2, '0000-00-00', NULL, 7),
(4, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(5, 1, 7, 8, 1, 2, '0000-00-00', NULL, 7),
(6, 3, 15, 21, 0, 2, '2018-12-21', NULL, 7),
(7, 4, 10, 16, 0, 2, '0000-00-00', NULL, 7),
(8, 3, 8, 33, 0, 2, '0000-00-00', NULL, 7),
(9, 1, 21, 28, 0, 2, '0000-00-00', NULL, 7),
(10, 4, 10, 16, 0, 2, '0000-00-00', NULL, 7),
(11, 1, 21, 28, 0, 2, '0000-00-00', NULL, 7),
(12, 1, 27, 28, 1, 2, '0000-00-00', NULL, 7),
(13, 1, 21, 28, 1, 2, '0000-00-00', NULL, 7),
(14, 2, 13, 7, 1, 2, '0000-00-00', NULL, 7),
(15, 1, 7, 35, 0, 2, '2018-12-21', NULL, 7),
(16, 5, 20, 35, 0, 2, '0000-00-00', NULL, 7),
(17, 1, 24, 28, 0, 2, '0000-00-00', NULL, 7),
(18, 6, 10, 16, 1, 2, '0000-00-00', NULL, 7),
(19, 2, 19, 30, 0, 2, '0000-00-00', NULL, 7),
(20, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(21, 1, 27, 35, 0, 2, '0000-00-00', NULL, 7),
(22, 1, 20, 28, 0, 2, '0000-00-00', NULL, 7),
(23, 1, 7, 28, 0, 2, '0000-00-00', NULL, 7),
(24, 1, 20, 28, 0, 2, '0000-00-00', NULL, 7),
(25, 3, 18, 5, 0, 2, '0000-00-00', NULL, 7),
(26, 3, 15, 21, 0, 2, '0000-00-00', NULL, 7),
(27, 1, 26, 35, 0, 2, '0000-00-00', NULL, 7),
(28, 1, 25, 35, 0, 2, '0000-00-00', NULL, 7),
(29, 2, 23, 17, 1, 2, '0000-00-00', NULL, 7),
(30, 2, 14, 21, 0, 2, '0000-00-00', NULL, 7),
(31, 1, 20, 32, 0, 3, '0000-00-00', NULL, 7),
(32, 2, 14, 20, 0, 2, '0000-00-00', NULL, 7),
(33, 1, 20, 23, 1, 2, '0000-00-00', NULL, 7),
(34, 1, 11, 14, 0, 2, '0000-00-00', NULL, 7),
(35, 1, 27, 35, 0, 2, '0000-00-00', NULL, 7),
(36, 1, 17, 11, 1, 2, '0000-00-00', NULL, 7),
(37, 1, 20, 32, 0, 2, '0000-00-00', NULL, 7),
(38, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(39, 2, 29, 29, 0, 2, '0000-00-00', NULL, 7),
(40, 1, 21, 28, 1, 2, '0000-00-00', NULL, 7),
(41, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(42, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(43, 1, 22, 28, 1, 2, '0000-00-00', NULL, 7),
(44, 1, 21, 28, 0, 2, '0000-00-00', NULL, 7),
(45, 3, 12, 6, 1, 2, '0000-00-00', NULL, 7),
(46, 1, 21, 28, 0, 2, '0000-00-00', NULL, 7),
(47, 2, 13, 18, 0, 2, '0000-00-00', NULL, 7),
(48, 1, 28, 35, 0, 2, '0000-00-00', NULL, 7),
(49, 1, 25, 2, 1, 2, '0000-00-00', NULL, 7),
(50, 3, 15, 5, 1, 2, '0000-00-00', NULL, 7),
(51, 3, 16, 36, 0, 2, '0000-00-00', NULL, 7),
(52, 1, 23, 35, 0, 2, '0000-00-00', NULL, 7),
(53, 2, 18, 13, 0, 2, '0000-00-00', NULL, 7),
(54, 1, 20, 23, 1, 2, '0000-00-00', NULL, 7),
(55, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(56, 1, 7, 28, 0, 2, '0000-00-00', NULL, 7),
(57, 1, 19, 12, 1, 2, '0000-00-00', NULL, 7),
(58, 2, 14, 20, 0, 2, '0000-00-00', NULL, 7),
(59, 1, 7, 28, 0, 4, '0000-00-00', NULL, 7),
(60, 1, 28, 35, 0, 4, '0000-00-00', NULL, 7),
(61, 1, 20, 35, 0, 4, '0000-00-00', NULL, 7),
(62, 3, 19, 30, 0, 4, '0000-00-00', NULL, 7),
(63, 1, 21, 35, 0, 4, '2018-12-21', NULL, 7),
(64, 1, 21, 35, 0, 4, '2018-12-21', NULL, 7),
(65, 1, 25, 35, 0, 4, '0000-00-00', NULL, 7),
(66, 1, 21, 35, 0, 4, '2018-12-21', NULL, 7),
(67, 1, 21, 35, 0, 4, '0000-00-00', NULL, 7),
(68, 1, 20, 32, 0, 4, '0000-00-00', NULL, 7),
(69, 1, 21, 35, 1, 4, '2018-12-21', NULL, 7),
(70, 1, 21, 28, 1, 4, '2018-12-21', NULL, 7),
(71, 1, 21, 35, 0, 4, '0000-00-00', NULL, 7),
(72, 1, 21, 35, 0, 4, '2018-12-21', NULL, 7),
(73, 1, 21, 35, 0, 4, '0000-00-00', NULL, 7),
(74, 1, 21, 35, 0, 4, '0000-00-00', NULL, 4),
(75, 1, 21, 35, 0, 4, '0000-00-00', NULL, 7),
(76, 1, 17, 34, 0, 4, '0000-00-00', NULL, 7),
(77, 1, 20, 28, 0, 2, '0000-00-00', NULL, 7),
(78, 1, 21, 35, 0, 4, '2018-12-21', NULL, 7),
(79, 2, 13, 27, 0, 4, '0000-00-00', NULL, 7),
(80, 1, 25, 35, 0, 2, '0000-00-00', NULL, 7),
(81, 1, 21, 35, 0, 4, '2018-12-21', NULL, 7),
(82, 1, 21, 35, 0, 4, '0000-00-00', NULL, 7),
(83, 1, 23, 37, 0, 4, '0000-00-00', NULL, 7),
(84, 4, 18, 13, 0, 2, '0000-00-00', NULL, 7),
(85, 4, 18, 13, 0, 2, '0000-00-00', NULL, 7),
(86, 4, 18, 13, 0, 2, '0000-00-00', NULL, 7),
(87, 4, 18, 13, 0, 2, '0000-00-00', NULL, 7),
(88, 3, 18, 13, 0, 2, '2018-12-21', NULL, 7),
(89, 4, 18, 13, 0, 2, '0000-00-00', NULL, 7),
(90, 4, 18, 3, 1, 2, '0000-00-00', NULL, 7),
(91, 2, 15, 21, 0, 2, '0000-00-00', NULL, 2),
(92, 2, 8, 24, 1, 2, '0000-00-00', NULL, 2),
(93, 4, 18, 13, 0, 2, '0000-00-00', NULL, 2),
(94, 4, 19, 30, 0, 2, '0000-00-00', NULL, 5),
(95, 2, 18, 38, 0, 2, '0000-00-00', NULL, 5),
(96, 4, 18, 38, 0, 2, '0000-00-00', NULL, 1),
(97, 4, 12, 6, 1, 2, '0000-00-00', NULL, 2),
(98, 2, 13, 29, 0, 2, '0000-00-00', NULL, 2),
(99, 4, 12, 3, 1, 2, '0000-00-00', NULL, 2),
(100, 4, 18, 5, 1, 2, '0000-00-00', NULL, 1),
(110, 2, 13, 29, 0, 2, '0000-00-00', NULL, 7),
(111, 1, 9, 25, 0, 2, '0000-00-00', NULL, 7),
(112, 1, 20, 32, 0, 2, '0000-00-00', NULL, 7),
(113, 1, 7, 35, 0, 4, '0000-00-00', NULL, 4),
(114, 2, 9, 22, 1, 2, '0000-00-00', NULL, 7),
(115, 1, 20, 32, 0, 4, '0000-00-00', NULL, 7),
(116, 2, 12, 2, 1, 2, '0000-00-00', NULL, 7),
(117, 2, 12, 1, 1, 2, '0000-00-00', NULL, 7),
(118, 2, 18, 14, 0, 2, '0000-00-00', NULL, 2),
(124, 1, 21, 35, 0, 2, '0000-00-00', NULL, 7),
(125, 2, 12, 4, 1, 2, '0000-00-00', NULL, 2),
(126, 2, 17, 11, 0, 2, '0000-00-00', NULL, 7),
(127, 2, 9, 25, 0, 3, '0000-00-00', NULL, 6),
(128, 1, 20, 35, 0, 3, '0000-00-00', NULL, 6),
(129, 2, 9, 25, 0, 2, '0000-00-00', NULL, 7),
(130, 2, 18, 14, 0, 2, '0000-00-00', NULL, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lineas_pedido`
--

CREATE TABLE `lineas_pedido` (
  `idLineas_pedido` int(11) NOT NULL,
  `cantidad` varchar(2) NOT NULL,
  `idPedido` int(11) NOT NULL,
  `idProducto` smallint(6) NOT NULL,
  `idMomento` tinyint(4) DEFAULT NULL,
  `precio` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `lineas_pedido`
--

INSERT INTO `lineas_pedido` (`idLineas_pedido`, `cantidad`, `idPedido`, `idProducto`, `idMomento`, `precio`) VALUES
(3, '1', 2, 1, 2, '7900'),
(4, '2', 3, 10, 1, '4200'),
(5, '1', 3, 1, 2, '7900'),
(6, '1', 4, 10, 1, '2100'),
(7, '1', 5, 1, 2, '7900'),
(8, '1', 3, 18, 1, '2000'),
(9, '1', 6, 13, 1, '3000'),
(10, '1', 7, 2, 2, '2000'),
(11, '1', 8, 2, 2, '2000'),
(12, '1', 9, 4, 1, '4800'),
(13, '1', 9, 24, 1, '2000'),
(14, '1', 10, 16, 1, '2000'),
(15, '1', 11, 8, 1, '4800'),
(16, '1', 11, 18, 1, '2000'),
(17, '1', 11, 1, 2, '7900'),
(18, '1', 12, 10, 1, '2100'),
(19, '1', 13, 1, 2, '7900'),
(22, '1', 15, 3, 2, '5900'),
(23, '1', 16, 1, 2, '7900'),
(24, '1', 17, 1, 2, '7900'),
(25, '1', 18, 6, 1, '3200'),
(26, '1', 18, 29, 1, '2000'),
(27, '1', 19, 13, 1, '3000'),
(29, '1', 20, 16, 1, '2000'),
(30, '1', 20, 2, 2, '2000'),
(31, '2', 21, 6, 1, '6400'),
(32, '1', 22, 13, 1, '3000'),
(33, '1', 23, 1, 2, '7900'),
(34, '1', 23, 2, 2, '2000'),
(35, '1', 24, 17, 1, '5000'),
(36, '1', 24, 28, 1, '2000'),
(37, '1', 25, 18, 2, '2000'),
(38, '1', 25, 17, 2, '5000'),
(39, '1', 26, 6, 1, '3200'),
(40, '1', 26, 2, 2, '2000'),
(41, '1', 27, 10, 1, '2100'),
(42, '1', 27, 20, 1, '2000'),
(43, '1', 27, 3, 2, '5900'),
(44, '1', 28, 14, 1, '3000'),
(45, '1', 29, 2, 2, '2000'),
(46, '1', 30, 16, 1, '2000'),
(47, '1', 30, 28, 1, '2000'),
(48, '1', 30, 1, 2, '7900'),
(49, '1', 31, 28, 2, '2000'),
(50, '1', 32, 1, 2, '7900'),
(51, '3', 33, 10, 1, '6300'),
(52, '1', 33, 31, 1, '2000'),
(53, '1', 34, 1, 2, '7900'),
(54, '2', 35, 1, 2, '15800'),
(55, '1', 36, 1, 2, '7900'),
(56, '1', 37, 3, 2, '7900'),
(57, '1', 38, 1, 2, '7900'),
(58, '1', 39, 1, 2, '7900'),
(59, '1', 40, 1, 2, '7900'),
(60, '1', 41, 1, 2, '7900'),
(61, '1', 42, 10, 1, '2100'),
(62, '1', 42, 23, 1, '2000'),
(63, '1', 42, 3, 2, '5900'),
(64, '1', 43, 1, 2, '7900'),
(65, '1', 44, 2, 2, '2000'),
(66, '1', 45, 4, 1, '4800'),
(67, '1', 45, 28, 1, '2000'),
(68, '1', 45, 1, 2, '7900'),
(69, '1', 46, 1, 2, '7900'),
(70, '1', 47, 13, 2, '3000'),
(71, '1', 47, 1, 2, '7900'),
(72, '1', 48, 1, 2, '7900'),
(73, '1', 49, 3, 2, '5900'),
(74, '1', 50, 17, 2, '5000'),
(75, '1', 50, 31, 2, '2000'),
(76, '1', 51, 1, 2, '7900'),
(77, '1', 52, 13, 1, '3000'),
(78, '1', 53, 8, 1, '4800'),
(79, '1', 54, 11, 1, '2100'),
(80, '1', 54, 31, 1, '2000'),
(81, '1', 55, 23, 1, '2000'),
(82, '1', 55, 16, 1, '2000'),
(83, '1', 55, 1, 2, '7900'),
(84, '1', 56, 6, 1, '3200'),
(85, '1', 56, 15, 1, '2500'),
(86, '1', 57, 11, 1, '2100'),
(87, '2', 58, 11, 1, '4200'),
(88, '1', 59, 3, 2, '5900'),
(89, '1', 60, 2, 2, '2000'),
(90, '2', 61, 31, 1, '4000'),
(91, '2', 61, 4, 1, '9600'),
(92, '1', 62, 17, 1, '5000'),
(93, '1', 62, 28, 1, '2000'),
(94, '1', 63, 1, 2, '7900'),
(95, '1', 64, 8, 1, '4800'),
(96, '1', 64, 23, 1, '2000'),
(97, '1', 65, 1, 2, '7900'),
(98, '1', 66, 1, 2, '7900'),
(99, '1', 67, 1, 2, '7900'),
(100, '1', 68, 1, 2, '7900'),
(101, '1', 69, 31, 1, '2000'),
(102, '1', 69, 17, 1, '5000'),
(103, '1', 70, 2, 2, '2000'),
(104, '1', 71, 1, 2, '7900'),
(105, '1', 72, 2, 2, '2000'),
(106, '1', 73, 1, 2, '7900'),
(107, '1', 74, 1, 2, '7900'),
(108, '1', 75, 10, 1, '2100'),
(109, '1', 76, 14, 1, '4000'),
(110, '1', 77, 2, 2, '2000'),
(111, '1', 78, 8, 2, '4800'),
(112, '1', 78, 28, 2, '2000'),
(113, '1', 79, 1, 2, '7900'),
(114, '1', 80, 30, 2, '2000'),
(115, '2', 81, 9, 1, '4000'),
(116, '1', 81, 27, 1, '2000'),
(117, '1', 82, 2, 2, '2000'),
(118, '1', 83, 2, 2, '2000'),
(119, '1', 84, 1, 2, '7900'),
(120, '1', 85, 2, 2, '2000'),
(121, '1', 86, 8, 1, '4800'),
(122, '1', 86, 21, 1, '2000'),
(123, '1', 87, 10, 1, '2100'),
(124, '1', 87, 3, 2, '5900'),
(125, '1', 88, 4, 1, '4800'),
(126, '1', 88, 23, 1, '2000'),
(127, '1', 89, 1, 2, '7900'),
(128, '1', 90, 11, 1, '2100'),
(129, '1', 91, 1, 2, '7900'),
(130, '1', 92, 25, 2, '2000'),
(131, '1', 93, 13, 1, '3000'),
(132, '1', 94, 47, 1, '2800'),
(134, '1', 95, 38, 1, '2500'),
(135, '1', 95, 30, 1, '2000'),
(136, '1', 95, 1, 2, '7900'),
(137, '2', 96, 1, 2, '15800'),
(138, '1', 97, 25, 2, '2000'),
(139, '1', 98, 1, 2, '7900'),
(140, '1', 99, 1, 2, '7900'),
(141, '1', 100, 24, 2, '2000'),
(142, '1', 101, 8, 1, '4800'),
(143, '1', 101, 31, 1, '2000'),
(144, '1', 102, 1, 2, '7900'),
(145, '1', 103, 48, 1, '4000'),
(146, '2', 103, 33, 1, '2800'),
(147, '1', 94, 45, 1, '2500'),
(148, '1', 94, 33, 1, '1400'),
(149, '1', 104, 2, 2, '2000'),
(150, '1', 105, 1, 2, '7900'),
(151, '1', 106, 1, 2, '7900'),
(152, '1', 107, 13, 1, '3000'),
(153, '1', 108, 2, 2, '2000'),
(154, '1', 109, 2, 2, '2000'),
(155, '1', 110, 5, 1, '2200'),
(156, '3', 111, 34, 1, '4200'),
(157, '1', 112, 1, 2, '7900'),
(158, '1', 112, 46, 1, '2900'),
(159, '1', 113, 33, 1, '1400'),
(160, '1', 113, 38, 1, '2200'),
(161, '1', 113, 44, 1, '2500'),
(162, '1', 114, 10, 1, '2100'),
(163, '1', 114, 3, 2, '5900'),
(164, '1', 115, 38, 1, '2200'),
(165, '1', 116, 34, 1, '1400'),
(166, '1', 116, 44, 1, '2500'),
(167, '1', 116, 33, 1, '1400'),
(168, '1', 116, 1, 2, '7900'),
(169, '1', 117, 34, 1, '1400'),
(170, '1', 117, 8, 2, '4800'),
(171, '1', 117, 30, 2, '2000'),
(172, '1', 118, 1, 2, '7900'),
(173, '1', 119, 33, 1, '1400'),
(174, '1', 119, 45, 1, '2500'),
(175, '2', 120, 33, 1, '2800'),
(176, '1', 120, 36, 1, '600'),
(177, '1', 120, 45, 1, '2500'),
(178, '1', 121, 1, 2, '7900'),
(179, '1', 122, 1, 2, '7900'),
(180, '2', 123, 34, 1, '2800'),
(181, '1', 123, 44, 1, '2500'),
(182, '1', 123, 1, 2, '7900'),
(184, '1', 125, 10, 1, '2100'),
(185, '2', 125, 23, 1, '4000'),
(186, '1', 126, 48, 1, '4000'),
(187, '1', 126, 45, 1, '2500'),
(188, '1', 127, 4, 1, '4800'),
(189, '1', 127, 1, 2, '7900'),
(190, '1', 127, 22, 1, '2000'),
(191, '1', 128, 1, 2, '7900'),
(192, '1', 129, 7, 2, '5000'),
(193, '1', 130, 1, 2, '7900'),
(194, '3', 131, 46, 1, '8400'),
(195, '4', 131, 35, 1, '5600'),
(196, '3', 132, 44, 1, '7500'),
(197, '1', 133, 3, 2, '5900'),
(198, '3', 134, 48, 1, '12000'),
(199, '1', 135, 14, 1, '4000'),
(200, '2', 136, 33, 1, '2800'),
(201, '1', 137, 37, 1, '2000'),
(202, '3', 138, 33, 1, '4200'),
(203, '1', 139, 1, 2, '7900'),
(204, '1', 140, 48, 1, '4000'),
(205, '1', 141, 13, 1, '3000'),
(206, '2', 142, 33, 1, '2800'),
(207, '1', 142, 22, 2, '2000'),
(208, '1', 142, 8, 2, '4800'),
(209, '1', 143, 47, 1, '2800'),
(210, '1', 143, 44, 1, '2500'),
(211, '1', 144, 38, 1, '2500'),
(212, '1', 144, 31, 1, '2000'),
(213, '1', 144, 33, 1, '1400'),
(214, '1', 145, 44, 1, '2500'),
(215, '1', 145, 46, 1, '2800'),
(216, '1', 146, 3, 2, '5900'),
(217, '1', 146, 20, 1, '2000'),
(218, '1', 147, 3, 2, '5900'),
(219, '2', 148, 1, 2, '15800'),
(220, '1', 149, 34, 1, '1400'),
(221, '1', 149, 44, 1, '2500'),
(222, '1', 150, 2, 2, '2000'),
(223, '1', 151, 37, 1, '2000'),
(224, '1', 151, 45, 1, '2500'),
(225, '1', 152, 40, 1, '2200'),
(226, '1', 152, 1, 2, '7900'),
(227, '1', 153, 25, 2, '2000'),
(228, '3', 154, 1, 2, '23700'),
(229, '1', 155, 34, 1, '1400'),
(230, '2', 156, 33, 1, '2800'),
(231, '1', 156, 3, 2, '5900'),
(232, '1', 157, 33, 1, '1400'),
(236, '1', 160, 10, 1, '2100'),
(237, '1', 160, 3, 2, '5900'),
(238, '1', 161, 3, 2, '5900'),
(239, '1', 162, 13, 1, '3000'),
(240, '1', 162, 1, 2, '7900'),
(243, '1', 163, 1, 2, '7900'),
(244, '1', 164, 39, 1, '2200'),
(245, '1', 164, 44, 1, '2500'),
(246, '1', 164, 34, 1, '1400'),
(247, '1', 163, 45, 1, '2500'),
(248, '1', 163, 31, 1, '2000'),
(249, '3', 165, 1, 2, '23700'),
(250, '1', 166, 2, 2, '2000'),
(251, '1', 167, 2, 2, '2000'),
(252, '1', 168, 8, 2, '4800'),
(253, '1', 168, 28, 2, '2000'),
(254, '1', 169, 37, 1, '2000'),
(255, '2', 170, 43, 1, '2600'),
(256, '1', 170, 36, 1, '600'),
(257, '1', 171, 1, 2, '7900'),
(258, '1', 172, 38, 1, '2500'),
(262, '1', 177, 3, 2, '5900'),
(263, '1', 178, 8, 2, '4800'),
(264, '1', 178, 13, 1, '3000'),
(265, '1', 178, 28, 2, '2000'),
(266, '1', 179, 44, 1, '2500'),
(267, '1', 179, 38, 1, '2500'),
(268, '1', 180, 37, 1, '2000'),
(269, '2', 180, 36, 1, '1200'),
(270, '1', 180, 44, 1, '2500'),
(271, '1', 181, 7, 2, '5000'),
(272, '1', 181, 44, 1, '2500'),
(273, '1', 181, 2, 2, '2000'),
(274, '1', 182, 1, 2, '7900'),
(275, '1', 183, 37, 1, '2000'),
(276, '1', 183, 45, 1, '2500'),
(277, '1', 184, 1, 2, '7900'),
(278, '1', 185, 2, 2, '2000'),
(279, '1', 186, 2, 2, '2000'),
(280, '1', 187, 23, 2, '2000'),
(281, '1', 188, 3, 2, '5900'),
(282, '1', 189, 38, 1, '2500'),
(283, '1', 189, 31, 1, '2000'),
(284, '1', 190, 2, 2, '2000'),
(285, '1', 191, 33, 1, '1400'),
(286, '1', 191, 45, 1, '2500'),
(288, '1', 193, 1, 2, '7900'),
(289, '1', 194, 34, 1, '1400'),
(290, '1', 194, 44, 1, '2500'),
(291, '1', 194, 1, 2, '7900'),
(292, '1', 195, 1, 2, '7900'),
(293, '1', 196, 10, 1, '2100'),
(294, '1', 196, 3, 2, '5900'),
(295, '1', 197, 34, 1, '1400'),
(296, '1', 197, 33, 1, '1400'),
(297, '1', 197, 45, 1, '2500'),
(298, '2', 198, 1, 2, '15800'),
(299, '1', 199, 33, 1, '1400'),
(300, '1', 199, 17, 1, '5000'),
(301, '1', 199, 45, 1, '2500'),
(302, '1', 199, 1, 2, '7900'),
(303, '1', 199, 25, 1, '2000'),
(304, '1', 200, 3, 2, '5900'),
(305, '1', 201, 7, 2, '5000'),
(306, '1', 201, 27, 2, '2000'),
(307, '1', 202, 2, 2, '2000'),
(308, '1', 203, 8, 1, '4800'),
(309, '1', 203, 21, 1, '2000'),
(310, '1', 204, 48, 1, '4000'),
(311, '1', 205, 24, 2, '2000'),
(312, '1', 206, 31, 1, '2000'),
(313, '1', 206, 16, 1, '2000'),
(314, '1', 206, 1, 2, '7900'),
(315, '1', 207, 2, 2, '2000'),
(316, '1', 208, 9, 1, '2000'),
(317, '1', 208, 1, 2, '7900'),
(318, '2', 209, 10, 1, '4200'),
(319, '1', 209, 27, 1, '2000'),
(320, '1', 210, 2, 2, '2000'),
(321, '1', 211, 28, 2, '2000'),
(322, '1', 212, 45, 1, '2500'),
(323, '1', 212, 48, 1, '4000'),
(324, '1', 212, 3, 2, '5900'),
(325, '1', 213, 7, 1, '5000'),
(327, '1', 213, 24, 1, '2000'),
(328, '1', 214, 3, 2, '5900'),
(329, '1', 215, 1, 2, '7900'),
(330, '2', 216, 3, 2, '11800'),
(331, '1', 217, 8, 2, '4800'),
(332, '1', 217, 30, 2, '2000'),
(333, '1', 218, 10, 1, '2100'),
(334, '1', 218, 24, 1, '2000'),
(335, '1', 218, 3, 2, '5900'),
(337, '1', 220, 1, 2, '7900'),
(338, '1', 221, 1, 2, '7900'),
(339, '1', 221, 35, 1, '1400'),
(340, '1', 222, 7, 2, '5000'),
(341, '1', 223, 3, 2, '5900'),
(342, '1', 224, 3, 2, '5900'),
(343, '1', 225, 24, 2, '2000'),
(344, '1', 225, 2, 2, '2000'),
(345, '1', 226, 1, 2, '7900'),
(346, '1', 227, 1, 2, '7900'),
(347, '1', 228, 34, 1, '1400'),
(348, '1', 229, 1, 2, '7900'),
(349, '1', 230, 20, 2, '2000'),
(350, '1', 231, 23, 1, '2000'),
(351, '1', 231, 10, 1, '2100'),
(352, '1', 231, 1, 2, '7900'),
(353, '1', 231, 11, 1, '2100'),
(354, '1', 231, 22, 1, '2000'),
(355, '2', 232, 34, 1, '2800'),
(356, '1', 232, 44, 1, '2500'),
(358, '1', 233, 1, 2, '7900'),
(359, '1', 233, 7, 2, '5000'),
(360, '1', 233, 10, 1, '2100'),
(361, '1', 234, 46, 1, '2800'),
(362, '1', 234, 44, 1, '2500'),
(363, '1', 235, 4, 2, '4800'),
(364, '1', 235, 31, 2, '2000'),
(365, '1', 236, 33, 1, '1400'),
(366, '1', 236, 39, 1, '2200'),
(367, '1', 236, 44, 1, '2500'),
(368, '2', 237, 38, 1, '5000'),
(369, '1', 238, 2, 2, '2000'),
(370, '1', 239, 38, 1, '2500'),
(371, '1', 240, 48, 1, '4000'),
(372, '1', 240, 45, 1, '2500'),
(373, '1', 241, 31, 1, '2000'),
(374, '1', 241, 9, 1, '2000'),
(375, '1', 242, 41, 1, '1300'),
(376, '1', 242, 1, 2, '7900'),
(377, '1', 243, 2, 2, '2000'),
(378, '1', 244, 3, 2, '5900'),
(379, '1', 245, 28, 2, '2000'),
(380, '1', 246, 3, 2, '5900'),
(381, '1', 247, 4, 1, '4800'),
(382, '2', 247, 1, 2, '15800'),
(383, '1', 247, 31, 1, '2000'),
(384, '3', 248, 33, 1, '4200'),
(385, '1', 249, 33, 1, '1400'),
(386, '1', 249, 3, 2, '5900'),
(387, '1', 250, 2, 2, '2000'),
(388, '2', 251, 36, 1, '1200'),
(389, '1', 251, 33, 1, '1400'),
(390, '1', 252, 1, 2, '7900'),
(391, '1', 253, 9, 1, '2000'),
(392, '2', 254, 33, 1, '2800'),
(393, '1', 255, 13, 1, '3000'),
(394, '3', 256, 5, 1, '6600'),
(395, '1', 257, 3, 2, '5900'),
(396, '1', 258, 24, 2, '2000'),
(397, '1', 259, 24, 2, '2000'),
(398, '1', 260, 1, 2, '7900'),
(399, '1', 261, 46, 1, '2800'),
(400, '2', 261, 33, 1, '2800'),
(401, '1', 262, 1, 2, '7900'),
(402, '1', 263, 33, 1, '1400'),
(403, '2', 264, 33, 1, '2800'),
(404, '2', 264, 34, 1, '2800'),
(405, '1', 265, 10, 1, '2100'),
(406, '1', 266, 2, 2, '2000'),
(408, '1', 268, 1, 2, '7900'),
(409, '1', 268, 29, 1, '2000'),
(410, '1', 269, 37, 1, '2000'),
(411, '1', 269, 31, 1, '2000'),
(412, '1', 270, 1, 2, '7900'),
(413, '1', 271, 10, 1, '2100'),
(414, '1', 271, 27, 1, '2000'),
(415, '1', 271, 11, 1, '2100'),
(416, '1', 272, 1, 2, '7900'),
(417, '1', 273, 1, 2, '7900'),
(418, '1', 274, 7, 2, '5000'),
(419, '1', 274, 24, 2, '2000'),
(420, '1', 275, 8, 2, '4800'),
(421, '1', 275, 21, 2, '2000'),
(422, '1', 276, 1, 2, '7900'),
(423, '1', 277, 1, 2, '7900'),
(424, '1', 278, 33, 1, '1400'),
(425, '1', 278, 2, 2, '2000'),
(426, '1', 278, 38, 1, '2500'),
(427, '1', 279, 1, 2, '7900'),
(428, '1', 280, 1, 2, '7900'),
(429, '1', 281, 43, 1, '1300'),
(430, '1', 281, 46, 1, '2800'),
(431, '1', 282, 1, 2, '7900'),
(432, '1', 283, 2, 2, '2000'),
(433, '1', 283, 18, 2, '2000'),
(434, '1', 284, 1, 2, '7900'),
(435, '1', 285, 7, 1, '5000'),
(436, '1', 285, 4, 1, '4800'),
(437, '1', 286, 35, 1, '1400'),
(438, '1', 286, 45, 1, '2500'),
(439, '1', 286, 1, 2, '7900'),
(440, '1', 287, 3, 2, '5900'),
(441, '1', 288, 34, 1, '1400'),
(442, '1', 289, 3, 2, '5900'),
(444, '1', 290, 45, 1, '2500'),
(446, '1', 292, 2, 2, '2000'),
(447, '1', 292, 13, 1, '3000'),
(448, '1', 293, 1, 2, '7900'),
(449, '2', 294, 28, 2, '4000'),
(450, '1', 295, 7, 2, '5000'),
(451, '1', 295, 24, 2, '2000'),
(452, '1', 296, 1, 2, '7900'),
(453, '1', 297, 6, 1, '3200'),
(454, '1', 297, 23, 1, '2000'),
(455, '1', 298, 3, 2, '5900'),
(456, '1', 299, 17, 1, '5000'),
(457, '1', 299, 26, 1, '2000'),
(458, '1', 299, 1, 2, '7900'),
(459, '1', 300, 1, 2, '7900'),
(460, '1', 301, 21, 2, '2000'),
(461, '1', 301, 4, 2, '4800'),
(462, '2', 302, 11, 1, '4200'),
(463, '1', 303, 8, 1, '4800'),
(464, '1', 304, 1, 2, '7900'),
(465, '1', 305, 10, 1, '2100'),
(466, '1', 305, 3, 2, '5900'),
(467, '1', 306, 1, 2, '7900'),
(468, '1', 307, 48, 1, '4000'),
(469, '1', 308, 43, 1, '1300'),
(470, '3', 308, 46, 1, '8400'),
(471, '1', 306, 47, 1, '2900'),
(472, '1', 309, 37, 1, '2000'),
(473, '1', 309, 2, 2, '2000'),
(474, '1', 310, 1, 2, '7900'),
(475, '1', 311, 33, 2, '1400'),
(476, '1', 311, 3, 2, '5900'),
(477, '1', 312, 1, 2, '7900'),
(479, '1', 314, 45, 1, '2500'),
(480, '1', 314, 48, 1, '4000'),
(481, '1', 315, 31, 1, '2000'),
(482, '1', 315, 9, 1, '2000'),
(483, '2', 316, 36, 1, '1200'),
(484, '1', 317, 34, 1, '1400'),
(485, '1', 317, 45, 1, '2500'),
(486, '1', 318, 3, 2, '5900'),
(487, '1', 319, 13, 1, '3000'),
(488, '1', 319, 1, 2, '7900'),
(489, '1', 320, 45, 1, '2500'),
(490, '1', 320, 34, 1, '1400'),
(491, '1', 320, 24, 2, '2000'),
(492, '1', 320, 7, 2, '5000'),
(495, '1', 322, 24, 2, '2000'),
(496, '1', 323, 45, 1, '2500'),
(497, '1', 323, 37, 1, '2000'),
(498, '2', 324, 1, 2, '15800'),
(499, '1', 325, 48, 1, '4000'),
(500, '1', 326, 7, 2, '5000'),
(501, '2', 327, 34, 1, '2800'),
(502, '1', 327, 44, 1, '2500'),
(503, '1', 328, 1, 2, '7900'),
(504, '1', 329, 1, 2, '7900'),
(505, '1', 329, 34, 1, '1400'),
(506, '1', 330, 3, 2, '5900'),
(507, '1', 331, 3, 2, '5900'),
(508, '1', 332, 1, 2, '7900'),
(511, '1', 335, 34, 1, '1400'),
(512, '1', 335, 45, 1, '2500'),
(513, '1', 335, 8, 2, '4800'),
(514, '1', 335, 30, 2, '2000'),
(515, '2', 336, 10, 1, '4200'),
(516, '1', 336, 27, 1, '2000'),
(517, '1', 336, 8, 2, '4800'),
(518, '1', 337, 28, 2, '2000'),
(519, '1', 338, 13, 1, '3000'),
(520, '1', 338, 2, 2, '2000'),
(521, '1', 339, 48, 1, '4000'),
(522, '1', 339, 45, 1, '2500'),
(523, '1', 339, 21, 2, '2000'),
(524, '1', 339, 4, 2, '4800'),
(525, '1', 340, 2, 2, '2000'),
(526, '1', 341, 2, 2, '2000'),
(527, '1', 342, 3, 2, '5900'),
(528, '1', 343, 3, 2, '5900'),
(529, '1', 344, 3, 2, '5900'),
(530, '1', 345, 2, 2, '2000'),
(531, '1', 346, 1, 2, '7900'),
(532, '1', 347, 12, 1, '2500'),
(533, '1', 347, 3, 2, '5900'),
(534, '1', 347, 10, 1, '2100'),
(535, '1', 348, 1, 2, '7900'),
(536, '1', 349, 15, 1, '3000'),
(537, '1', 349, 7, 2, '5000'),
(538, '1', 350, 47, 1, '2900'),
(539, '2', 350, 33, 1, '2800'),
(540, '1', 351, 10, 1, '2100'),
(542, '1', 353, 6, 1, '3200'),
(543, '1', 354, 37, 1, '2000'),
(544, '1', 354, 1, 2, '7900'),
(549, '1', 357, 3, 2, '5900'),
(550, '1', 358, 2, 2, '2000'),
(551, '1', 359, 1, 2, '7900'),
(552, '1', 360, 6, 1, '3200'),
(553, '1', 360, 1, 2, '7900'),
(554, '1', 360, 31, 1, '2000'),
(555, '1', 361, 46, 1, '2800'),
(556, '1', 361, 41, 1, '1300'),
(557, '1', 361, 45, 1, '2500'),
(558, '1', 362, 10, 1, '2100'),
(559, '1', 362, 3, 2, '5900'),
(561, '1', 363, 1, 2, '7900'),
(562, '1', 364, 34, 1, '1400'),
(563, '1', 364, 44, 1, '2500'),
(564, '1', 365, 48, 1, '4000'),
(565, '1', 366, 37, 1, '2000'),
(566, '1', 366, 35, 1, '1400'),
(567, '1', 367, 1, 2, '7900'),
(568, '1', 368, 44, 1, '2500'),
(569, '1', 369, 45, 1, '2500'),
(570, '1', 369, 34, 1, '1400'),
(571, '1', 370, 8, 2, '4800'),
(572, '1', 370, 23, 2, '2000'),
(573, '1', 371, 1, 2, '7900'),
(574, '1', 372, 2, 2, '2000'),
(575, '1', 373, 1, 2, '7900'),
(576, '1', 374, 45, 1, '2500'),
(577, '1', 374, 33, 1, '1400'),
(578, '1', 375, 1, 2, '7900'),
(579, '1', 376, 1, 2, '7900'),
(580, '1', 377, 1, 2, '7900'),
(581, '1', 378, 2, 2, '2000'),
(582, '1', 379, 24, 2, '2000'),
(583, '1', 379, 7, 2, '5000'),
(584, '1', 380, 2, 2, '2000'),
(585, '1', 381, 10, 1, '2100'),
(586, '1', 381, 3, 2, '5900'),
(587, '1', 382, 1, 2, '7900'),
(588, '1', 383, 3, 2, '5900'),
(589, '1', 384, 37, 1, '2000'),
(590, '1', 384, 1, 2, '7900'),
(591, '1', 384, 45, 1, '2500'),
(592, '3', 385, 48, 1, '12000'),
(593, '2', 385, 7, 2, '10000'),
(594, '1', 386, 3, 2, '5900'),
(595, '1', 387, 1, 2, '7900'),
(596, '5', 388, 33, 1, '7000'),
(597, '1', 389, 15, 1, '3000'),
(598, '1', 389, 5, 1, '2200'),
(600, '1', 391, 35, 1, '1400'),
(602, '1', 393, 33, 1, '1400'),
(603, '1', 393, 17, 2, '5000'),
(608, '1', 396, 4, 1, '4800'),
(609, '1', 397, 4, 1, '4800'),
(610, '1', 397, 31, 1, '2000'),
(611, '1', 398, 9, 1, '2000'),
(612, '1', 398, 31, 1, '2000'),
(613, '1', 399, 38, 1, '2500'),
(614, '1', 399, 45, 1, '2500'),
(615, '1', 400, 46, 1, '2800'),
(616, '1', 400, 44, 1, '2500'),
(617, '1', 401, 10, 1, '2100'),
(618, '1', 401, 3, 2, '5900'),
(619, '1', 402, 2, 2, '2000'),
(620, '1', 403, 24, 2, '2000'),
(621, '1', 404, 1, 2, '7900'),
(622, '1', 405, 21, 1, '2000'),
(623, '1', 405, 3, 2, '5900'),
(624, '2', 406, 46, 1, '5600'),
(625, '1', 407, 35, 1, '1400'),
(626, '1', 407, 2, 2, '2000'),
(627, '1', 408, 34, 1, '1400'),
(628, '1', 408, 44, 1, '2500'),
(629, '2', 409, 10, 1, '4200'),
(630, '1', 409, 31, 1, '2000'),
(631, '1', 409, 23, 2, '2000'),
(632, '1', 410, 34, 1, '1400'),
(633, '1', 410, 39, 1, '2200'),
(634, '1', 411, 3, 2, '5900'),
(635, '1', 412, 1, 2, '7900'),
(636, '1', 413, 33, 1, '1400'),
(637, '1', 413, 38, 1, '2500'),
(638, '1', 414, 38, 1, '2500'),
(639, '1', 414, 2, 2, '2000'),
(640, '1', 414, 1, 2, '7900'),
(641, '2', 415, 37, 1, '4000'),
(642, '1', 415, 45, 1, '2500'),
(643, '2', 416, 12, 1, '5000'),
(644, '2', 416, 7, 2, '10000'),
(645, '1', 416, 23, 2, '2000'),
(646, '1', 417, 6, 1, '3200'),
(647, '1', 417, 15, 1, '3000'),
(648, '3', 418, 35, 1, '4200'),
(649, '1', 419, 17, 2, '5000'),
(650, '1', 419, 18, 2, '2000'),
(651, '1', 419, 13, 2, '3000'),
(652, '1', 420, 1, 2, '7900'),
(653, '1', 421, 38, 1, '2500'),
(654, '1', 421, 45, 1, '2500'),
(655, '1', 422, 2, 2, '2000'),
(656, '1', 423, 45, 1, '2500'),
(657, '1', 423, 34, 1, '1400'),
(658, '1', 424, 2, 2, '2000'),
(659, '2', 425, 33, 1, '2800'),
(660, '1', 426, 1, 2, '7900'),
(661, '1', 427, 23, 1, '2000'),
(662, '2', 427, 10, 1, '4200'),
(663, '1', 428, 2, 2, '2000'),
(664, '1', 428, 24, 2, '2000'),
(665, '1', 428, 18, 1, '2000'),
(666, '1', 429, 1, 2, '7900'),
(667, '1', 429, 13, 1, '3000'),
(668, '2', 430, 37, 1, '4000'),
(669, '1', 430, 44, 1, '2500'),
(670, '1', 430, 1, 2, '7900'),
(671, '1', 431, 3, 2, '5900'),
(672, '1', 432, 3, 2, '5900'),
(673, '2', 433, 36, 1, '1200'),
(674, '1', 434, 2, 2, '2000'),
(675, '2', 435, 33, 1, '2800'),
(676, '1', 435, 36, 1, '600'),
(677, '2', 436, 1, 2, '15800'),
(678, '1', 437, 12, 1, '2500'),
(679, '1', 437, 7, 2, '5000'),
(680, '2', 438, 45, 1, '5000'),
(681, '1', 438, 48, 1, '4000'),
(682, '1', 439, 48, 1, '4000'),
(683, '1', 440, 10, 1, '2100'),
(684, '1', 441, 39, 1, '2200'),
(685, '1', 442, 13, 1, '3000'),
(686, '1', 442, 1, 2, '7900'),
(687, '1', 443, 17, 1, '5000'),
(688, '1', 444, 1, 2, '7900'),
(689, '1', 445, 1, 2, '7900'),
(690, '1', 446, 17, 2, '5000'),
(691, '1', 446, 23, 2, '2000'),
(692, '1', 447, 1, 2, '7900'),
(693, '1', 448, 2, 2, '2000'),
(694, '1', 449, 4, 2, '4800'),
(695, '2', 449, 33, 1, '2800'),
(696, '1', 450, 10, 1, '2100'),
(697, '1', 450, 3, 2, '5900'),
(698, '1', 451, 10, 1, '2100'),
(699, '1', 451, 23, 1, '2000'),
(700, '1', 451, 9, 1, '2000'),
(701, '1', 452, 2, 2, '2000'),
(702, '1', 453, 1, 2, '7900'),
(703, '1', 454, 1, 2, '7900'),
(704, '1', 455, 1, 2, '7900'),
(705, '1', 456, 24, 2, '2000'),
(706, '1', 457, 1, 2, '7900'),
(707, '1', 458, 46, 1, '2800'),
(708, '1', 458, 44, 1, '2500'),
(709, '1', 458, 2, 2, '2000'),
(710, '1', 459, 48, 1, '4000'),
(711, '1', 459, 45, 1, '2500'),
(712, '1', 459, 1, 2, '7900'),
(713, '1', 460, 13, 1, '3000'),
(714, '1', 461, 3, 2, '5900'),
(715, '2', 462, 10, 1, '4200'),
(716, '1', 462, 18, 1, '2000'),
(717, '1', 463, 34, 1, '1400'),
(718, '1', 463, 45, 1, '2500'),
(719, '1', 464, 3, 2, '5900'),
(720, '2', 465, 9, 1, '4000'),
(721, '1', 465, 31, 1, '2000'),
(722, '1', 465, 1, 2, '7900'),
(723, '1', 466, 24, 2, '2000'),
(724, '1', 467, 37, 1, '2000'),
(725, '1', 467, 1, 2, '7900'),
(726, '1', 468, 14, 1, '4000'),
(727, '1', 469, 34, 1, '1400'),
(728, '1', 469, 44, 1, '2500'),
(729, '1', 469, 1, 2, '7900'),
(730, '1', 468, 3, 2, '5900'),
(731, '2', 470, 41, 1, '2600'),
(732, '1', 470, 2, 2, '2000'),
(733, '1', 470, 4, 2, '4800'),
(734, '1', 471, 1, 2, '7900'),
(735, '1', 472, 48, 1, '4000'),
(736, '1', 472, 25, 1, '2000'),
(737, '1', 473, 1, 2, '7900'),
(738, '1', 474, 24, 1, '2000'),
(739, '1', 474, 24, 2, '2000'),
(740, '1', 474, 2, 2, '2000'),
(741, '1', 475, 40, 1, '2200'),
(742, '1', 475, 37, 1, '2000'),
(743, '1', 476, 33, 1, '1400'),
(744, '3', 477, 33, 1, '4200'),
(745, '1', 478, 6, 1, '3200'),
(746, '2', 479, 5, 1, '4400'),
(747, '2', 479, 15, 1, '6000'),
(748, '1', 479, 3, 2, '5900'),
(749, '1', 480, 3, 2, '5900'),
(750, '1', 481, 3, 2, '5900'),
(751, '1', 481, 10, 1, '2100'),
(752, '1', 482, 1, 2, '7900'),
(753, '1', 483, 2, 2, '2000'),
(754, '1', 484, 37, 1, '2000'),
(755, '1', 484, 1, 2, '7900'),
(756, '1', 485, 33, 1, '1400'),
(757, '1', 485, 4, 2, '4800'),
(758, '1', 486, 9, 1, '2000'),
(759, '1', 487, 1, 2, '7900'),
(760, '1', 488, 1, 2, '7900'),
(761, '1', 489, 3, 2, '5900'),
(762, '1', 490, 2, 2, '2000'),
(763, '1', 491, 17, 1, '5000'),
(764, '1', 491, 26, 1, '2000'),
(765, '1', 491, 1, 2, '7900'),
(766, '1', 492, 24, 2, '2000'),
(767, '2', 493, 46, 1, '5600'),
(768, '1', 494, 48, 1, '4000'),
(769, '1', 494, 35, 1, '1400'),
(770, '2', 495, 46, 1, '5600'),
(771, '1', 496, 35, 1, '1400'),
(772, '1', 497, 4, 2, '4800'),
(773, '1', 498, 37, 1, '2000'),
(774, '1', 498, 20, 1, '2000'),
(775, '1', 499, 33, 1, '1400'),
(776, '1', 500, 12, 1, '2500'),
(777, '1', 501, 10, 1, '2100'),
(778, '1', 501, 3, 2, '5900'),
(779, '1', 502, 2, 2, '2000'),
(780, '1', 503, 24, 2, '2000'),
(781, '1', 504, 23, 1, '2000'),
(782, '1', 504, 10, 1, '2100'),
(783, '1', 505, 2, 2, '2000'),
(784, '1', 506, 1, 2, '7900'),
(785, '1', 507, 38, 1, '2500'),
(786, '1', 507, 45, 1, '2500'),
(787, '1', 507, 2, 2, '2000'),
(788, '1', 508, 7, 2, '5000'),
(789, '1', 508, 24, 2, '2000'),
(790, '1', 509, 1, 2, '7900'),
(791, '1', 510, 48, 1, '4000'),
(792, '1', 511, 34, 1, '1400'),
(793, '1', 512, 1, 2, '7900'),
(794, '1', 513, 3, 2, '5900'),
(795, '1', 514, 1, 2, '7900'),
(796, '1', 515, 2, 2, '2000'),
(797, '1', 516, 2, 2, '2000'),
(798, '1', 517, 13, 1, '3000'),
(799, '2', 517, 10, 2, '4200'),
(800, '1', 517, 28, 2, '2000'),
(801, '1', 518, 7, 2, '5000'),
(802, '1', 518, 24, 2, '2000'),
(803, '1', 519, 1, 2, '7900'),
(804, '1', 520, 38, 1, '2500'),
(805, '1', 520, 33, 1, '1400'),
(806, '1', 521, 10, 1, '2100'),
(807, '1', 521, 3, 2, '5900'),
(808, '1', 521, 24, 1, '2000'),
(809, '2', 522, 1, 2, '15800'),
(810, '2', 522, 13, 1, '6000'),
(811, '1', 523, 9, 1, '2000'),
(812, '1', 523, 20, 1, '2000'),
(813, '1', 523, 1, 2, '7900'),
(814, '1', 524, 1, 2, '7900'),
(815, '1', 525, 3, 2, '5900'),
(816, '2', 525, 13, 1, '6000'),
(817, '1', 525, 1, 2, '7900'),
(818, '2', 526, 10, 1, '4200'),
(819, '1', 526, 28, 1, '2000'),
(820, '1', 526, 1, 2, '7900'),
(821, '1', 527, 1, 2, '7900'),
(822, '1', 528, 24, 2, '2000'),
(823, '1', 528, 7, 2, '5000'),
(824, '1', 529, 3, 2, '5900'),
(825, '2', 530, 17, 1, '10000'),
(826, '1', 531, 1, 2, '7900'),
(827, '1', 532, 7, 2, '5000'),
(828, '2', 533, 1, 2, '15800'),
(829, '1', 534, 48, 1, '4000'),
(830, '1', 534, 45, 1, '2500'),
(831, '1', 534, 1, 2, '7900'),
(832, '1', 535, 39, 1, '2200'),
(833, '1', 535, 33, 1, '1400'),
(834, '2', 536, 36, 1, '1200'),
(835, '1', 537, 1, 2, '7900'),
(836, '1', 538, 45, 1, '2500'),
(837, '2', 538, 37, 1, '4000'),
(838, '1', 539, 3, 2, '5900'),
(839, '1', 540, 10, 1, '2100'),
(840, '2', 541, 34, 1, '2800'),
(841, '1', 542, 2, 2, '2000'),
(842, '1', 532, 38, 1, '2500'),
(843, '1', 532, 1, 2, '7900'),
(844, '1', 543, 3, 2, '5900'),
(846, '1', 545, 12, 1, '2500'),
(847, '1', 545, 1, 2, '7900'),
(848, '1', 546, 1, 2, '7900'),
(849, '1', 547, 2, 2, '2000'),
(850, '1', 547, 24, 2, '2000'),
(851, '1', 547, 10, 1, '2100'),
(852, '1', 548, 2, 2, '2000'),
(853, '1', 549, 3, 2, '5900'),
(854, '1', 549, 24, 1, '2000'),
(855, '1', 550, 21, 2, '2000'),
(856, '1', 551, 1, 2, '7900'),
(857, '1', 551, 2, 2, '2000'),
(858, '1', 552, 24, 2, '2000'),
(859, '1', 553, 18, 2, '2000'),
(860, '2', 554, 10, 1, '4200'),
(861, '2', 555, 33, 1, '2800'),
(862, '1', 555, 46, 1, '2800'),
(863, '1', 556, 38, 1, '2500'),
(864, '1', 556, 45, 1, '2500'),
(865, '1', 557, 10, 1, '2100'),
(866, '1', 557, 3, 2, '5900'),
(867, '1', 557, 24, 1, '2000'),
(868, '1', 558, 1, 2, '7900'),
(869, '1', 559, 34, 1, '1400'),
(870, '1', 559, 45, 1, '2500'),
(871, '1', 560, 44, 1, '2500'),
(872, '1', 560, 34, 1, '1400'),
(873, '2', 561, 48, 1, '8000'),
(874, '1', 561, 44, 1, '2500'),
(875, '1', 561, 2, 2, '2000'),
(876, '1', 561, 27, 2, '2000'),
(877, '1', 562, 24, 2, '2000'),
(878, '1', 563, 3, 2, '5900'),
(879, '1', 563, 26, 2, '2000'),
(880, '1', 564, 3, 2, '5900'),
(881, '1', 565, 2, 2, '2000'),
(882, '1', 566, 28, 2, '2000'),
(883, '1', 567, 8, 1, '4800'),
(884, '1', 567, 21, 1, '2000'),
(885, '1', 568, 8, 1, '4800'),
(886, '1', 568, 18, 1, '2000'),
(887, '1', 569, 1, 2, '7900'),
(888, '2', 569, 36, 1, '1200'),
(889, '1', 570, 1, 2, '7900'),
(891, '2', 572, 6, 2, '6400'),
(892, '1', 573, 1, 2, '7900'),
(893, '1', 574, 10, 1, '2100'),
(894, '1', 575, 48, 1, '4000'),
(895, '1', 575, 1, 2, '7900'),
(896, '1', 576, 47, 1, '2900'),
(897, '1', 577, 37, 1, '2000'),
(898, '1', 577, 45, 1, '2500'),
(900, '1', 579, 1, 2, '7900'),
(901, '1', 580, 3, 2, '5900'),
(902, '1', 581, 12, 1, '2500'),
(903, '1', 582, 1, 2, '7900'),
(904, '1', 583, 1, 2, '7900'),
(905, '1', 584, 34, 1, '1400'),
(906, '1', 584, 36, 1, '600'),
(907, '1', 584, 44, 1, '2500'),
(908, '1', 585, 24, 2, '2000'),
(909, '1', 586, 23, 1, '2000'),
(910, '2', 586, 10, 1, '4200'),
(911, '1', 586, 27, 2, '2000'),
(912, '2', 587, 1, 2, '15800'),
(913, '1', 588, 37, 1, '2000'),
(914, '1', 588, 1, 2, '7900'),
(915, '1', 588, 45, 1, '2500'),
(916, '1', 589, 2, 2, '2000'),
(917, '1', 590, 1, 2, '7900'),
(918, '1', 591, 14, 2, '4000'),
(920, '1', 592, 1, 2, '7900'),
(921, '1', 592, 31, 1, '2000'),
(922, '1', 593, 3, 2, '5900'),
(923, '2', 592, 10, 1, '4200'),
(924, '1', 594, 3, 2, '5900'),
(925, '1', 595, 4, 1, '4800'),
(926, '1', 595, 28, 1, '2000'),
(927, '1', 596, 1, 2, '7900'),
(928, '1', 597, 2, 2, '2000'),
(929, '1', 598, 10, 1, '2100'),
(930, '1', 598, 3, 2, '5900'),
(931, '1', 598, 25, 1, '2000'),
(932, '1', 599, 3, 2, '5900'),
(933, '3', 600, 33, 2, '4200'),
(934, '1', 601, 2, 2, '2000'),
(935, '1', 602, 8, 1, '4800'),
(936, '1', 603, 3, 2, '5900'),
(937, '1', 603, 33, 1, '1400'),
(938, '1', 604, 22, 2, '2000'),
(939, '1', 605, 1, 2, '7900'),
(940, '1', 606, 33, 1, '1400'),
(941, '1', 606, 34, 1, '1400'),
(942, '1', 607, 1, 2, '7900'),
(943, '1', 608, 48, 1, '4000'),
(944, '1', 608, 45, 1, '2500'),
(945, '1', 608, 1, 2, '7900'),
(946, '1', 609, 1, 2, '7900'),
(947, '1', 610, 1, 2, '7900'),
(948, '1', 611, 48, 1, '4000'),
(949, '1', 611, 44, 1, '2500'),
(950, '1', 611, 2, 2, '2000'),
(951, '1', 611, 24, 2, '2000'),
(952, '1', 612, 3, 2, '5900'),
(953, '1', 613, 8, 1, '4800'),
(954, '1', 613, 25, 1, '2000'),
(955, '1', 614, 1, 2, '7900'),
(956, '1', 615, 34, 1, '1400'),
(957, '1', 615, 45, 1, '2500'),
(958, '1', 616, 2, 2, '2000'),
(959, '1', 617, 10, 1, '2100'),
(960, '1', 617, 23, 1, '2000'),
(961, '1', 617, 3, 2, '5900'),
(962, '1', 618, 44, 1, '2500'),
(963, '2', 618, 41, 1, '2600'),
(964, '1', 619, 48, 1, '4000'),
(965, '1', 619, 2, 2, '2000'),
(966, '2', 620, 48, 1, '8000'),
(967, '2', 620, 45, 1, '5000'),
(968, '1', 621, 3, 2, '5900'),
(969, '1', 622, 22, 2, '2000'),
(970, '1', 623, 4, 1, '4800'),
(971, '1', 623, 28, 1, '2000'),
(972, '2', 624, 33, 1, '2800'),
(973, '1', 624, 3, 2, '5900'),
(974, '1', 625, 1, 2, '7900'),
(975, '1', 625, 14, 2, '4000'),
(976, '1', 626, 1, 2, '7900'),
(977, '1', 626, 37, 1, '2000'),
(978, '1', 627, 35, 1, '1400'),
(979, '1', 627, 2, 2, '2000'),
(980, '1', 628, 15, 1, '3000'),
(981, '1', 628, 7, 2, '5000'),
(982, '1', 629, 1, 2, '7900'),
(983, '2', 630, 14, 1, '8000'),
(984, '3', 631, 17, 1, '15000'),
(985, '1', 632, 17, 1, '5000'),
(986, '1', 632, 31, 1, '2000'),
(987, '2', 633, 6, 2, '6400'),
(988, '1', 634, 1, 2, '7900'),
(989, '1', 634, 8, 1, '4800'),
(990, '1', 635, 10, 1, '2100'),
(991, '1', 635, 23, 1, '2000'),
(992, '1', 636, 10, 1, '2100'),
(993, '2', 636, 21, 1, '4000'),
(994, '1', 637, 8, 1, '4800'),
(995, '2', 638, 33, 1, '2800'),
(996, '1', 638, 44, 1, '2500'),
(997, '1', 639, 34, 1, '1400'),
(998, '1', 639, 45, 1, '2500'),
(999, '1', 640, 23, 1, '2000'),
(1000, '1', 640, 6, 1, '3200'),
(1001, '1', 641, 37, 1, '2000'),
(1002, '1', 641, 45, 1, '2500'),
(1003, '1', 642, 8, 1, '4800'),
(1004, '1', 642, 25, 1, '2000'),
(1005, '1', 642, 1, 2, '7900'),
(1006, '1', 643, 40, 1, '2200'),
(1007, '1', 643, 45, 1, '2500'),
(1008, '1', 644, 1, 2, '7900'),
(1009, '1', 645, 23, 1, '2000'),
(1010, '1', 645, 10, 1, '2100'),
(1011, '1', 645, 3, 2, '5900'),
(1012, '1', 646, 1, 2, '7900'),
(1013, '1', 647, 1, 2, '7900'),
(1014, '2', 648, 35, 1, '2800'),
(1015, '1', 648, 45, 1, '2500'),
(1016, '1', 648, 1, 2, '7900'),
(1017, '1', 649, 24, 2, '2000'),
(1018, '1', 650, 1, 2, '7900'),
(1019, '1', 651, 8, 1, '4800'),
(1020, '1', 651, 18, 1, '2000'),
(1021, '2', 652, 36, 1, '1200'),
(1022, '1', 653, 2, 2, '2000'),
(1023, '1', 654, 37, 1, '2000'),
(1024, '2', 654, 43, 1, '2600'),
(1025, '1', 654, 1, 2, '7900'),
(1026, '1', 655, 2, 2, '2000'),
(1027, '1', 656, 38, 1, '2500'),
(1028, '2', 656, 33, 1, '2800'),
(1029, '1', 657, 1, 2, '7900'),
(1030, '1', 658, 35, 1, '1400'),
(1031, '1', 658, 1, 2, '7900'),
(1032, '1', 659, 34, 1, '1400'),
(1033, '1', 659, 44, 1, '2500'),
(1034, '1', 659, 37, 1, '2000'),
(1035, '1', 659, 3, 2, '5900'),
(1036, '1', 660, 44, 1, '2500'),
(1037, '2', 660, 37, 1, '4000'),
(1038, '1', 661, 12, 1, '2500'),
(1039, '1', 662, 22, 2, '2000'),
(1040, '1', 663, 3, 2, '5900'),
(1041, '1', 664, 1, 2, '7900'),
(1042, '1', 665, 4, 1, '4800'),
(1043, '1', 665, 28, 1, '2000'),
(1044, '2', 666, 2, 2, '4000'),
(1045, '1', 666, 4, 2, '4800'),
(1046, '1', 666, 13, 2, '3000'),
(1047, '1', 666, 24, 2, '2000'),
(1048, '1', 667, 1, 2, '7900'),
(1049, '1', 667, 3, 2, '5900'),
(1050, '1', 668, 9, 1, '2000'),
(1051, '1', 669, 7, 2, '5000'),
(1052, '1', 670, 34, 1, '1400'),
(1053, '1', 670, 45, 1, '2500'),
(1054, '1', 671, 1, 2, '7900'),
(1055, '1', 672, 1, 2, '7900'),
(1056, '1', 673, 1, 2, '7900'),
(1057, '1', 674, 3, 2, '5900'),
(1058, '1', 675, 10, 1, '2100'),
(1059, '1', 675, 23, 1, '2000'),
(1060, '1', 676, 21, 1, '2000'),
(1061, '1', 676, 8, 1, '4800'),
(1062, '1', 677, 2, 2, '2000'),
(1063, '1', 678, 10, 1, '2100'),
(1064, '1', 678, 3, 2, '5900'),
(1065, '1', 679, 48, 1, '4000'),
(1066, '1', 679, 27, 2, '2000'),
(1067, '1', 680, 2, 2, '2000'),
(1068, '1', 681, 2, 2, '2000'),
(1069, '1', 682, 28, 2, '2000'),
(1070, '2', 682, 7, 2, '10000'),
(1071, '1', 682, 24, 2, '2000'),
(1072, '2', 683, 37, 1, '4000'),
(1073, '1', 683, 1, 2, '7900'),
(1074, '2', 684, 40, 1, '4400'),
(1075, '2', 685, 28, 2, '4000'),
(1076, '1', 686, 33, 1, '1400'),
(1077, '1', 687, 2, 2, '2000'),
(1078, '1', 688, 3, 2, '5900'),
(1079, '2', 689, 9, 1, '4000'),
(1080, '1', 689, 1, 2, '7900'),
(1081, '1', 690, 35, 1, '1400'),
(1082, '1', 690, 2, 2, '2000'),
(1083, '2', 691, 3, 2, '11800'),
(1084, '1', 692, 46, 1, '2800'),
(1085, '1', 692, 1, 2, '7900'),
(1086, '2', 692, 37, 1, '4000'),
(1087, '1', 692, 45, 1, '2500'),
(1088, '1', 693, 2, 2, '2000'),
(1089, '1', 694, 48, 1, '4000'),
(1090, '1', 694, 40, 1, '2200'),
(1091, '1', 695, 8, 1, '4800'),
(1092, '1', 695, 29, 1, '2000'),
(1093, '1', 696, 43, 1, '1300'),
(1094, '1', 696, 38, 1, '2500'),
(1095, '1', 697, 10, 1, '2100'),
(1096, '1', 697, 3, 2, '5900'),
(1097, '1', 697, 20, 1, '2000'),
(1098, '1', 698, 1, 2, '7900'),
(1099, '1', 698, 45, 1, '2500'),
(1100, '1', 699, 15, 1, '3000'),
(1101, '1', 700, 1, 2, '7900'),
(1102, '1', 701, 2, 2, '2000'),
(1103, '1', 702, 1, 2, '7900'),
(1104, '3', 703, 36, 1, '1800'),
(1105, '1', 703, 44, 1, '2500'),
(1106, '1', 704, 3, 2, '5900'),
(1107, '1', 705, 3, 2, '5900'),
(1108, '2', 706, 23, 1, '4000'),
(1109, '1', 707, 28, 1, '2000'),
(1110, '1', 707, 4, 1, '4800'),
(1111, '1', 707, 7, 2, '5000'),
(1112, '1', 708, 18, 2, '2000'),
(1113, '1', 708, 27, 2, '2000'),
(1114, '1', 709, 13, 1, '3000'),
(1115, '1', 710, 22, 2, '2000'),
(1116, '1', 711, 1, 2, '7900'),
(1117, '1', 712, 3, 2, '5900'),
(1118, '1', 713, 1, 2, '7900'),
(1119, '1', 714, 2, 2, '2000'),
(1120, '2', 715, 33, 1, '2800'),
(1121, '1', 716, 46, 1, '2800'),
(1122, '1', 716, 44, 1, '2500'),
(1123, '1', 716, 3, 2, '5900'),
(1124, '1', 717, 7, 2, '5000'),
(1125, '1', 718, 1, 2, '7900'),
(1126, '1', 718, 13, 1, '3000'),
(1127, '1', 719, 10, 1, '2100'),
(1128, '1', 719, 3, 2, '5900'),
(1129, '1', 720, 3, 2, '5900'),
(1130, '1', 721, 34, 1, '1400'),
(1131, '1', 721, 36, 1, '600'),
(1132, '2', 722, 37, 1, '4000'),
(1133, '1', 722, 1, 2, '7900'),
(1134, '1', 722, 45, 1, '2500'),
(1135, '1', 723, 3, 2, '5900'),
(1136, '1', 724, 1, 2, '7900'),
(1137, '1', 725, 22, 2, '2000'),
(1138, '1', 726, 3, 2, '5900'),
(1139, '1', 727, 33, 2, '1400'),
(1140, '1', 728, 1, 2, '7900'),
(1141, '1', 729, 37, 1, '2000'),
(1142, '1', 729, 45, 1, '2500'),
(1143, '1', 729, 7, 2, '5000'),
(1144, '1', 730, 1, 2, '7900'),
(1145, '2', 731, 48, 1, '8000'),
(1146, '2', 731, 1, 2, '15800'),
(1147, '1', 732, 3, 2, '5900'),
(1148, '1', 733, 8, 1, '4800'),
(1149, '1', 734, 34, 1, '1400'),
(1150, '1', 734, 2, 2, '2000'),
(1151, '1', 735, 17, 1, '5000'),
(1152, '1', 736, 2, 2, '2000'),
(1153, '1', 737, 48, 1, '4000'),
(1154, '1', 738, 21, 1, '2000'),
(1155, '1', 738, 10, 1, '2100'),
(1156, '1', 739, 3, 2, '5900'),
(1157, '1', 739, 48, 1, '4000'),
(1158, '1', 740, 1, 2, '7900'),
(1159, '1', 741, 2, 2, '2000'),
(1160, '1', 742, 10, 1, '2100'),
(1161, '1', 742, 3, 2, '5900'),
(1162, '1', 743, 8, 2, '4800'),
(1163, '1', 743, 21, 2, '2000'),
(1164, '1', 743, 1, 2, '7900'),
(1165, '1', 744, 2, 2, '2000'),
(1166, '1', 745, 1, 2, '7900'),
(1167, '1', 746, 3, 2, '5900'),
(1168, '1', 747, 33, 1, '1400'),
(1169, '1', 748, 3, 2, '5900'),
(1170, '1', 748, 24, 2, '2000'),
(1171, '1', 749, 3, 2, '5900'),
(1172, '1', 749, 21, 2, '2000'),
(1173, '1', 749, 27, 2, '2000'),
(1174, '1', 750, 33, 1, '1400'),
(1175, '1', 751, 1, 2, '7900'),
(1176, '2', 752, 35, 1, '2800'),
(1178, '1', 754, 33, 1, '1400'),
(1179, '1', 755, 2, 2, '2000'),
(1180, '1', 756, 3, 2, '5900'),
(1181, '1', 756, 6, 1, '3200'),
(1182, '1', 757, 9, 1, '2000'),
(1183, '1', 757, 20, 1, '2000'),
(1184, '1', 758, 33, 1, '1400'),
(1185, '1', 758, 46, 1, '2800'),
(1186, '1', 759, 7, 2, '5000'),
(1187, '1', 759, 30, 2, '2000'),
(1188, '1', 760, 8, 2, '4800'),
(1189, '1', 761, 1, 2, '7900'),
(1190, '1', 762, 48, 1, '4000'),
(1191, '1', 762, 1, 2, '7900'),
(1192, '1', 762, 37, 1, '2000'),
(1193, '1', 763, 7, 2, '5000'),
(1194, '1', 763, 28, 2, '2000'),
(1195, '1', 764, 22, 2, '2000'),
(1196, '1', 765, 23, 1, '2000'),
(1197, '2', 765, 10, 1, '4200'),
(1198, '1', 766, 8, 1, '4800'),
(1199, '1', 766, 1, 2, '7900'),
(1200, '1', 767, 1, 2, '7900'),
(1201, '1', 768, 2, 2, '2000'),
(1202, '1', 769, 33, 1, '1400'),
(1203, '1', 770, 2, 2, '2000'),
(1204, '1', 771, 1, 2, '7900'),
(1205, '1', 772, 3, 2, '5900'),
(1206, '1', 772, 38, 1, '2500'),
(1207, '1', 773, 38, 1, '2500'),
(1208, '1', 773, 3, 2, '5900'),
(1209, '1', 774, 15, 1, '3000'),
(1210, '1', 775, 2, 2, '2000'),
(1211, '1', 776, 39, 1, '2200'),
(1212, '1', 776, 44, 1, '2500'),
(1213, '1', 776, 1, 2, '7900'),
(1214, '1', 777, 2, 2, '2000'),
(1215, '2', 778, 10, 1, '4200'),
(1216, '1', 779, 34, 1, '1400'),
(1217, '1', 779, 45, 1, '2500'),
(1218, '1', 779, 41, 1, '1300'),
(1219, '1', 780, 22, 2, '2000'),
(1220, '1', 781, 3, 2, '5900'),
(1221, '1', 782, 2, 2, '2000'),
(1222, '1', 783, 10, 1, '2100'),
(1223, '1', 783, 3, 2, '5900'),
(1224, '2', 784, 37, 1, '4000'),
(1225, '1', 784, 45, 1, '2500'),
(1226, '1', 785, 37, 1, '2000'),
(1227, '1', 785, 45, 1, '2500'),
(1228, '1', 785, 3, 2, '5900'),
(1229, '1', 786, 3, 2, '5900'),
(1230, '1', 787, 7, 2, '5000'),
(1231, '1', 787, 23, 2, '2000'),
(1232, '1', 788, 33, 1, '1400'),
(1233, '2', 789, 10, 1, '4200'),
(1234, '1', 789, 22, 1, '2000'),
(1235, '1', 790, 45, 1, '2500'),
(1236, '1', 791, 1, 2, '7900'),
(1237, '1', 792, 3, 2, '5900'),
(1238, '2', 793, 33, 1, '2800'),
(1239, '1', 793, 1, 2, '7900'),
(1240, '2', 793, 44, 1, '5000'),
(1241, '1', 794, 3, 2, '5900'),
(1242, '1', 795, 2, 2, '2000'),
(1243, '1', 796, 45, 1, '2500'),
(1244, '1', 796, 37, 1, '2000'),
(1245, '1', 797, 34, 1, '1400'),
(1246, '1', 798, 48, 1, '4000'),
(1247, '1', 798, 3, 2, '5900'),
(1248, '1', 799, 2, 2, '2000'),
(1249, '1', 800, 10, 1, '2100'),
(1250, '1', 800, 3, 2, '5900'),
(1251, '1', 801, 4, 1, '4800'),
(1252, '1', 801, 28, 1, '2000'),
(1253, '1', 802, 1, 2, '7900'),
(1254, '3', 803, 35, 1, '4200'),
(1255, '1', 804, 1, 2, '7900'),
(1256, '2', 805, 10, 1, '4200'),
(1257, '2', 806, 33, 1, '2800'),
(1258, '1', 807, 8, 1, '4800'),
(1259, '1', 807, 24, 1, '2000'),
(1260, '1', 808, 1, 2, '7900'),
(1261, '1', 809, 40, 1, '2200'),
(1262, '1', 809, 45, 1, '2500'),
(1263, '1', 809, 1, 2, '7900'),
(1264, '2', 810, 10, 1, '4200'),
(1265, '1', 810, 28, 1, '2000'),
(1266, '1', 811, 3, 2, '5900'),
(1267, '1', 812, 8, 2, '4800'),
(1268, '1', 813, 1, 2, '7900'),
(1269, '1', 813, 2, 2, '2000'),
(1270, '1', 814, 1, 2, '7900'),
(1271, '1', 814, 2, 2, '2000'),
(1272, '1', 815, 33, 1, '1400'),
(1273, '1', 815, 46, 1, '2800'),
(1274, '1', 816, 22, 2, '2000'),
(1275, '2', 817, 47, 1, '5800'),
(1276, '1', 817, 45, 1, '2500'),
(1277, '1', 817, 4, 2, '4800'),
(1278, '1', 818, 6, 2, '3200'),
(1279, '1', 818, 29, 2, '2000'),
(1280, '1', 819, 10, 1, '2100'),
(1281, '1', 820, 2, 2, '2000'),
(1283, '1', 822, 48, 1, '4000'),
(1284, '1', 822, 36, 1, '600'),
(1285, '1', 823, 47, 1, '2900'),
(1286, '1', 824, 10, 1, '2100'),
(1287, '1', 824, 23, 1, '2000'),
(1288, '1', 824, 23, 2, '2000'),
(1289, '1', 825, 8, 1, '4800'),
(1290, '1', 825, 1, 2, '7900'),
(1291, '1', 825, 25, 1, '2000'),
(1292, '1', 826, 1, 2, '7900'),
(1293, '1', 827, 33, 1, '1400'),
(1294, '1', 827, 44, 1, '2500'),
(1296, '1', 828, 13, 1, '3000'),
(1297, '1', 829, 12, 1, '2500'),
(1298, '1', 830, 33, 1, '1400'),
(1300, '2', 831, 37, 1, '4000'),
(1301, '1', 831, 44, 1, '2500'),
(1302, '1', 832, 27, 1, '2000'),
(1303, '1', 833, 14, 1, '4000'),
(1304, '1', 834, 12, 1, '2500'),
(1305, '1', 835, 2, 2, '2000'),
(1306, '1', 836, 1, 2, '7900'),
(1307, '1', 837, 2, 2, '2000'),
(1308, '1', 838, 22, 2, '2000'),
(1309, '1', 839, 1, 2, '7900'),
(1310, '1', 840, 21, 1, '2000'),
(1311, '1', 840, 7, 2, '5000'),
(1312, '1', 840, 21, 2, '2000'),
(1314, '1', 841, 10, 1, '2100'),
(1315, '1', 842, 34, 1, '1400'),
(1316, '1', 842, 45, 1, '2500'),
(1317, '1', 843, 3, 2, '5900'),
(1318, '1', 844, 3, 2, '5900'),
(1319, '1', 845, 4, 1, '4800'),
(1320, '1', 845, 28, 1, '2000'),
(1321, '1', 846, 33, 1, '1400'),
(1322, '1', 846, 35, 1, '1400'),
(1323, '2', 847, 4, 1, '9600'),
(1324, '1', 848, 1, 2, '7900'),
(1325, '1', 849, 1, 2, '7900'),
(1326, '2', 849, 37, 1, '4000'),
(1327, '1', 849, 45, 1, '2500'),
(1328, '1', 850, 15, 1, '3000'),
(1329, '3', 851, 33, 1, '4200'),
(1330, '1', 851, 35, 1, '1400'),
(1331, '2', 852, 1, 2, '15800'),
(1332, '2', 853, 35, 1, '2800'),
(1333, '1', 853, 8, 2, '4800'),
(1334, '1', 840, 38, 1, '2500'),
(1335, '1', 854, 1, 2, '7900'),
(1336, '1', 855, 38, 1, '2500'),
(1337, '1', 856, 1, 2, '7900'),
(1338, '1', 857, 13, 1, '3000'),
(1339, '1', 858, 8, 1, '4800'),
(1340, '1', 858, 24, 1, '2000'),
(1343, '1', 860, 3, 2, '5900'),
(1344, '1', 860, 13, 1, '3000'),
(1345, '1', 861, 3, 2, '5900'),
(1346, '3', 862, 36, 1, '1800'),
(1347, '1', 862, 44, 1, '2500'),
(1348, '1', 862, 1, 2, '7900'),
(1349, '3', 863, 36, 1, '1800'),
(1350, '1', 863, 2, 2, '2000'),
(1351, '2', 864, 33, 1, '2800'),
(1352, '1', 864, 45, 1, '2500'),
(1353, '1', 864, 1, 2, '7900'),
(1354, '1', 865, 2, 2, '2000'),
(1355, '1', 866, 1, 2, '7900'),
(1356, '1', 867, 1, 2, '7900'),
(1357, '1', 868, 44, 1, '2500'),
(1358, '1', 869, 2, 2, '2000'),
(1359, '1', 870, 3, 2, '5900'),
(1360, '1', 871, 45, 1, '2500'),
(1361, '1', 871, 36, 1, '600'),
(1362, '1', 871, 48, 1, '4000'),
(1363, '1', 872, 1, 2, '7900'),
(1364, '2', 873, 38, 1, '5000'),
(1365, '1', 873, 45, 1, '2500'),
(1366, '1', 873, 1, 2, '7900'),
(1367, '1', 874, 38, 1, '2500'),
(1368, '1', 874, 35, 1, '1400'),
(1369, '1', 874, 44, 1, '2500'),
(1370, '1', 874, 24, 2, '2000'),
(1371, '1', 874, 6, 2, '3200'),
(1372, '1', 874, 2, 2, '2000'),
(1373, '1', 875, 1, 2, '7900'),
(1374, '1', 876, 45, 1, '2500'),
(1375, '1', 876, 34, 1, '1400'),
(1376, '1', 877, 1, 2, '7900'),
(1377, '1', 878, 10, 1, '2100'),
(1378, '1', 879, 1, 2, '7900'),
(1379, '1', 880, 33, 1, '1400'),
(1380, '1', 881, 34, 1, '1400'),
(1381, '1', 882, 45, 1, '2500'),
(1382, '1', 882, 37, 1, '2000'),
(1383, '1', 882, 3, 2, '5900'),
(1384, '1', 883, 3, 2, '5900'),
(1385, '1', 884, 1, 2, '7900'),
(1386, '2', 885, 1, 2, '15800'),
(1387, '1', 886, 1, 2, '7900'),
(1388, '1', 887, 31, 1, '2000'),
(1389, '1', 887, 1, 2, '7900'),
(1390, '1', 888, 1, 2, '7900'),
(1391, '1', 889, 7, 2, '5000'),
(1392, '1', 890, 36, 1, '600'),
(1393, '1', 890, 1, 2, '7900'),
(1394, '1', 890, 34, 1, '1400'),
(1395, '1', 890, 45, 1, '2500'),
(1396, '2', 891, 1, 2, '15800'),
(1397, '1', 891, 28, 2, '2000'),
(1398, '1', 892, 2, 2, '2000'),
(1399, '2', 893, 37, 1, '4000'),
(1400, '1', 893, 45, 1, '2500'),
(1401, '1', 893, 1, 2, '7900'),
(1402, '2', 894, 40, 1, '4400'),
(1403, '1', 894, 44, 1, '2500'),
(1404, '1', 894, 1, 2, '7900'),
(1405, '2', 895, 48, 1, '8000'),
(1406, '1', 896, 34, 1, '1400'),
(1407, '1', 896, 45, 1, '2500'),
(1408, '1', 896, 36, 1, '600'),
(1409, '1', 897, 14, 1, '4000'),
(1410, '1', 898, 27, 1, '2000'),
(1411, '1', 898, 4, 1, '4800'),
(1412, '2', 899, 11, 1, '4200'),
(1413, '1', 899, 2, 2, '2000'),
(1414, '1', 900, 8, 1, '4800'),
(1415, '1', 901, 3, 2, '5900'),
(1416, '1', 901, 10, 1, '2100'),
(1417, '2', 902, 1, 2, '15800'),
(1418, '1', 903, 2, 2, '2000'),
(1419, '1', 904, 20, 1, '2000'),
(1420, '1', 905, 20, 1, '2000'),
(1421, '1', 906, 44, 1, '2500'),
(1422, '2', 906, 43, 1, '2600'),
(1423, '1', 907, 10, 1, '2100'),
(1424, '1', 907, 23, 1, '2000'),
(1425, '1', 907, 3, 2, '5900'),
(1426, '1', 908, 44, 1, '2500'),
(1427, '1', 908, 3, 2, '5900'),
(1428, '1', 908, 38, 1, '2500'),
(1429, '1', 909, 48, 1, '4000'),
(1430, '1', 909, 1, 2, '7900'),
(1431, '1', 910, 1, 2, '7900'),
(1432, '1', 911, 2, 2, '2000'),
(1433, '1', 912, 1, 2, '7900'),
(1434, '1', 913, 7, 1, '5000'),
(1435, '1', 913, 1, 2, '7900'),
(1436, '1', 913, 23, 1, '2000'),
(1437, '1', 914, 3, 2, '5900'),
(1438, '2', 915, 35, 1, '2800'),
(1439, '1', 916, 2, 2, '2000'),
(1440, '1', 917, 20, 1, '2000'),
(1441, '1', 917, 37, 1, '2000'),
(1442, '1', 918, 3, 2, '5900'),
(1443, '1', 919, 13, 1, '3000'),
(1444, '1', 920, 33, 1, '1400'),
(1445, '1', 920, 44, 1, '2500'),
(1449, '1', 922, 44, 1, '2500'),
(1450, '2', 922, 46, 2, '5600'),
(1451, '1', 923, 2, 2, '2000'),
(1452, '1', 924, 10, 1, '2100'),
(1453, '1', 925, 2, 2, '2000'),
(1454, '1', 926, 13, 1, '3000'),
(1455, '1', 926, 2, 2, '2000'),
(1456, '1', 927, 1, 2, '7900'),
(1457, '1', 928, 3, 2, '5900'),
(1458, '1', 929, 46, 2, '2800'),
(1459, '1', 929, 44, 1, '2500'),
(1460, '1', 930, 45, 1, '2500'),
(1461, '1', 930, 3, 2, '5900'),
(1462, '1', 930, 33, 1, '1400'),
(1463, '2', 931, 2, 2, '4000'),
(1464, '1', 931, 28, 2, '2000'),
(1465, '1', 931, 24, 2, '2000'),
(1466, '1', 932, 20, 1, '2000'),
(1467, '1', 933, 3, 2, '5900'),
(1468, '1', 934, 38, 2, '2500'),
(1469, '3', 935, 36, 1, '1800'),
(1470, '1', 935, 44, 1, '2500'),
(1471, '1', 935, 24, 2, '2000'),
(1472, '3', 936, 35, 1, '4200'),
(1473, '1', 937, 3, 2, '5900'),
(1474, '1', 937, 37, 1, '2000'),
(1475, '2', 938, 38, 1, '5000'),
(1476, '1', 939, 45, 1, '2500'),
(1477, '1', 939, 2, 2, '2000'),
(1478, '1', 940, 2, 2, '2000'),
(1479, '1', 941, 2, 2, '2000'),
(1480, '1', 942, 12, 1, '2500'),
(1481, '1', 942, 11, 1, '2100'),
(1482, '1', 942, 14, 2, '4000'),
(1483, '1', 943, 48, 1, '4000'),
(1484, '1', 944, 39, 1, '2200'),
(1485, '1', 945, 33, 1, '1400'),
(1486, '1', 946, 20, 1, '2000'),
(1487, '1', 947, 8, 1, '4800'),
(1488, '1', 947, 21, 1, '2000'),
(1489, '2', 948, 2, 2, '4000'),
(1490, '1', 948, 24, 2, '2000'),
(1491, '1', 949, 17, 1, '5000'),
(1492, '1', 949, 25, 1, '2000'),
(1493, '1', 950, 45, 1, '2500'),
(1494, '1', 950, 9, 1, '2000'),
(1495, '1', 951, 13, 1, '3000'),
(1496, '1', 952, 31, 1, '2000'),
(1497, '1', 952, 9, 1, '2000'),
(1498, '1', 953, 1, 2, '7900'),
(1499, '1', 954, 1, 2, '7900'),
(1500, '1', 955, 22, 2, '2000'),
(1501, '1', 956, 2, 2, '2000'),
(1502, '1', 957, 28, 2, '2000'),
(1503, '1', 958, 10, 1, '2100'),
(1504, '1', 958, 8, 2, '4800'),
(1506, '1', 960, 36, 1, '600'),
(1507, '1', 960, 39, 1, '2200'),
(1508, '1', 960, 44, 1, '2500'),
(1509, '1', 960, 1, 2, '7900'),
(1510, '1', 961, 1, 2, '7900'),
(1511, '1', 962, 3, 2, '5900'),
(1512, '4', 963, 43, 1, '5200'),
(1513, '1', 963, 45, 2, '2500'),
(1514, '1', 964, 23, 1, '2000'),
(1515, '1', 964, 3, 2, '5900'),
(1516, '2', 964, 10, 1, '4200'),
(1517, '1', 965, 3, 2, '5900'),
(1518, '1', 966, 13, 1, '3000'),
(1519, '1', 966, 3, 2, '5900'),
(1520, '1', 966, 25, 1, '2000'),
(1521, '3', 967, 33, 1, '4200'),
(1522, '1', 968, 1, 2, '7900'),
(1523, '1', 969, 23, 1, '2000'),
(1524, '2', 969, 10, 1, '4200'),
(1525, '1', 970, 18, 1, '2000'),
(1526, '1', 970, 27, 2, '2000'),
(1527, '1', 971, 1, 2, '7900'),
(1528, '1', 972, 20, 1, '2000'),
(1529, '1', 973, 37, 1, '2000'),
(1530, '1', 974, 22, 2, '2000'),
(1531, '1', 975, 1, 2, '7900'),
(1532, '1', 976, 3, 2, '5900'),
(1533, '1', 977, 23, 1, '2000'),
(1534, '1', 977, 3, 2, '5900'),
(1535, '1', 977, 10, 1, '2100'),
(1536, '1', 978, 3, 2, '5900'),
(1537, '1', 979, 7, 2, '5000'),
(1538, '1', 979, 22, 2, '2000'),
(1539, '1', 980, 1, 2, '7900'),
(1540, '1', 980, 2, 2, '2000'),
(1541, '1', 980, 31, 1, '2000'),
(1542, '2', 980, 37, 1, '4000'),
(1543, '2', 981, 43, 1, '2600'),
(1544, '2', 981, 44, 1, '5000'),
(1545, '2', 981, 37, 1, '4000'),
(1546, '1', 982, 3, 2, '5900'),
(1547, '1', 983, 3, 2, '5900'),
(1548, '2', 984, 37, 1, '4000'),
(1549, '1', 985, 27, 2, '2000'),
(1550, '1', 985, 45, 1, '2500'),
(1551, '2', 985, 33, 1, '2800'),
(1552, '1', 986, 1, 2, '7900'),
(1553, '1', 987, 33, 1, '1400'),
(1554, '1', 988, 38, 1, '2500'),
(1555, '2', 989, 2, 2, '4000'),
(1556, '2', 958, 24, 2, '4000'),
(1557, '1', 963, 1, 2, '7900'),
(1558, '1', 963, 3, 2, '5900'),
(1559, '2', 990, 10, 1, '4200'),
(1560, '1', 990, 28, 1, '2000'),
(1561, '1', 990, 2, 2, '2000'),
(1562, '1', 991, 1, 2, '7900'),
(1563, '2', 992, 10, 1, '4200'),
(1564, '1', 992, 23, 1, '2000'),
(1565, '1', 993, 34, 1, '1400'),
(1566, '1', 993, 45, 1, '2500'),
(1567, '1', 994, 3, 2, '5900'),
(1568, '1', 995, 9, 1, '2000'),
(1569, '1', 995, 31, 1, '2000'),
(1570, '2', 996, 40, 1, '4400'),
(1571, '1', 996, 44, 1, '2500'),
(1572, '1', 997, 2, 2, '2000'),
(1573, '1', 998, 44, 1, '2500'),
(1574, '1', 998, 37, 1, '2000'),
(1575, '1', 998, 1, 2, '7900'),
(1576, '1', 999, 1, 2, '7900'),
(1577, '1', 1000, 33, 1, '1400'),
(1578, '1', 1000, 43, 1, '1300'),
(1579, '2', 1001, 2, 2, '4000'),
(1580, '2', 1001, 13, 2, '6000'),
(1581, '1', 1002, 10, 1, '2100'),
(1582, '1', 1003, 1, 2, '7900'),
(1583, '2', 1004, 10, 1, '4200'),
(1584, '1', 1004, 21, 1, '2000'),
(1585, '1', 1005, 4, 1, '4800'),
(1586, '1', 1005, 21, 1, '2000'),
(1587, '1', 1006, 4, 1, '4800'),
(1588, '1', 1006, 31, 1, '2000'),
(1589, '1', 1006, 1, 2, '7900'),
(1590, '1', 1007, 20, 1, '2000'),
(1591, '1', 1008, 44, 1, '2500'),
(1592, '1', 1008, 37, 1, '2000'),
(1593, '1', 1009, 14, 1, '4000'),
(1594, '1', 1009, 2, 2, '2000'),
(1595, '1', 1010, 24, 2, '2000'),
(1596, '1', 1011, 31, 1, '2000'),
(1597, '1', 1011, 23, 2, '2000'),
(1598, '3', 1012, 10, 1, '6300'),
(1599, '1', 1012, 24, 1, '2000'),
(1600, '2', 1013, 34, 1, '2800'),
(1601, '1', 1013, 3, 2, '5900'),
(1602, '1', 1014, 28, 1, '2000'),
(1603, '1', 1014, 4, 1, '4800'),
(1604, '1', 1015, 2, 2, '2000'),
(1605, '2', 1016, 34, 1, '2800'),
(1606, '1', 1017, 10, 1, '2100'),
(1607, '1', 1018, 10, 1, '2100'),
(1608, '2', 1019, 33, 1, '2800'),
(1609, '1', 1019, 39, 1, '2200'),
(1610, '1', 1020, 2, 2, '2000'),
(1611, '1', 1021, 1, 2, '7900'),
(1612, '1', 1022, 3, 2, '5900'),
(1613, '1', 1023, 37, 1, '2000'),
(1614, '1', 1023, 45, 1, '2500'),
(1615, '1', 1024, 20, 1, '2000'),
(1616, '2', 1025, 33, 1, '2800'),
(1617, '1', 1026, 17, 1, '5000'),
(1618, '1', 1026, 24, 1, '2000'),
(1619, '1', 1027, 10, 1, '2100'),
(1620, '1', 1028, 1, 2, '7900'),
(1621, '1', 1029, 24, 2, '2000'),
(1622, '1', 1030, 3, 2, '5900'),
(1623, '1', 1031, 8, 1, '4800'),
(1624, '1', 1031, 8, 2, '4800'),
(1625, '1', 1031, 10, 1, '2100'),
(1626, '1', 1031, 31, 2, '2000'),
(1627, '1', 1031, 31, 1, '2000'),
(1628, '1', 1032, 2, 2, '2000'),
(1629, '1', 1033, 7, 2, '5000'),
(1630, '1', 1033, 22, 2, '2000'),
(1631, '2', 1034, 48, 1, '8000'),
(1632, '1', 1034, 45, 1, '2500'),
(1633, '1', 1034, 2, 2, '2000'),
(1634, '2', 1034, 7, 2, '10000'),
(1635, '2', 1035, 37, 1, '4000'),
(1636, '1', 1035, 45, 1, '2500'),
(1637, '1', 1035, 1, 2, '7900'),
(1638, '1', 1036, 2, 2, '2000'),
(1639, '1', 1037, 20, 1, '2000'),
(1640, '1', 1037, 1, 2, '7900'),
(1641, '1', 1037, 8, 1, '4800'),
(1642, '1', 1038, 10, 1, '2100'),
(1643, '1', 1038, 26, 1, '2000'),
(1644, '1', 1038, 3, 2, '5900'),
(1645, '1', 1039, 1, 2, '7900'),
(1646, '2', 1040, 10, 1, '4200'),
(1647, '1', 1040, 21, 1, '2000'),
(1648, '1', 1040, 3, 2, '5900'),
(1649, '3', 1041, 33, 1, '4200'),
(1650, '2', 1042, 4, 2, '9600'),
(1651, '1', 1043, 38, 1, '2500'),
(1652, '1', 1043, 2, 2, '2000'),
(1653, '1', 1044, 33, 1, '1400'),
(1654, '1', 1045, 20, 1, '2000'),
(1655, '1', 1046, 35, 1, '1400'),
(1656, '1', 1047, 45, 1, '2500'),
(1657, '1', 1048, 1, 2, '7900'),
(1658, '1', 1049, 1, 2, '7900'),
(1659, '1', 1050, 48, 1, '4000'),
(1660, '1', 1050, 44, 1, '2500'),
(1661, '1', 1050, 1, 2, '7900'),
(1662, '1', 1051, 18, 1, '2000'),
(1663, '1', 1051, 1, 2, '7900'),
(1664, '1', 1051, 4, 1, '4800'),
(1665, '1', 1052, 10, 1, '2100'),
(1666, '1', 1052, 30, 1, '2000'),
(1667, '1', 1052, 1, 2, '7900'),
(1668, '1', 1052, 9, 1, '2000'),
(1669, '1', 1053, 3, 2, '5900'),
(1670, '1', 1054, 47, 1, '2900'),
(1671, '1', 1055, 10, 1, '2100'),
(1672, '1', 1055, 3, 2, '5900'),
(1673, '1', 1056, 1, 2, '7900'),
(1674, '1', 1056, 45, 1, '2500'),
(1675, '1', 1057, 37, 1, '2000'),
(1676, '1', 1057, 45, 1, '2500'),
(1677, '1', 1057, 1, 2, '7900'),
(1678, '1', 1058, 2, 2, '2000'),
(1679, '1', 1059, 35, 1, '1400'),
(1680, '1', 1060, 48, 1, '4000'),
(1681, '1', 1060, 45, 1, '2500'),
(1682, '1', 1061, 1, 2, '7900'),
(1683, '1', 1062, 13, 1, '3000'),
(1684, '1', 1063, 13, 1, '3000'),
(1685, '1', 1064, 37, 1, '2000'),
(1686, '1', 1064, 3, 2, '5900'),
(1687, '1', 1064, 44, 1, '2500'),
(1688, '1', 1065, 34, 1, '1400'),
(1689, '1', 1065, 45, 1, '2500'),
(1690, '1', 1065, 36, 1, '600'),
(1691, '1', 1066, 33, 1, '1400'),
(1692, '5', 1067, 36, 1, '3000'),
(1693, '2', 1068, 47, 1, '5800'),
(1694, '3', 1068, 44, 1, '7500'),
(1695, '1', 1069, 1, 2, '7900'),
(1696, '1', 1069, 2, 2, '2000'),
(1697, '1', 1070, 20, 1, '2000'),
(1698, '1', 1071, 37, 1, '2000'),
(1699, '1', 1071, 33, 1, '1400'),
(1700, '1', 1072, 35, 1, '1400'),
(1701, '1', 1073, 1, 2, '7900'),
(1703, '1', 1075, 48, 1, '4000'),
(1704, '1', 1076, 48, 1, '4000'),
(1705, '1', 1077, 14, 1, '4000'),
(1706, '1', 1077, 1, 2, '7900'),
(1707, '2', 1077, 10, 1, '4200'),
(1708, '1', 1077, 30, 1, '2000'),
(1709, '1', 1078, 45, 1, '2500'),
(1710, '1', 1078, 38, 1, '2500'),
(1711, '1', 1078, 1, 2, '7900'),
(1712, '1', 1079, 10, 1, '2100'),
(1713, '1', 1079, 3, 2, '5900'),
(1714, '1', 1080, 1, 2, '7900'),
(1715, '1', 1081, 1, 2, '7900'),
(1716, '2', 1082, 10, 1, '4200'),
(1717, '1', 1083, 3, 2, '5900'),
(1719, '1', 1085, 4, 1, '4800'),
(1720, '1', 1085, 3, 2, '5900'),
(1721, '1', 1085, 25, 1, '2000'),
(1722, '1', 1086, 24, 2, '2000');
INSERT INTO `lineas_pedido` (`idLineas_pedido`, `cantidad`, `idPedido`, `idProducto`, `idMomento`, `precio`) VALUES
(1723, '1', 1087, 3, 2, '5900'),
(1724, '1', 1088, 2, 2, '2000'),
(1725, '1', 1089, 1, 2, '7900'),
(1726, '1', 1090, 3, 2, '5900'),
(1727, '1', 1091, 2, 2, '2000'),
(1728, '1', 1092, 2, 2, '2000'),
(1729, '2', 1092, 11, 1, '4200'),
(1730, '1', 1093, 38, 1, '2500'),
(1731, '1', 1093, 45, 1, '2500'),
(1732, '1', 1094, 1, 2, '7900'),
(1733, '1', 1095, 1, 2, '7900'),
(1734, '1', 1096, 35, 1, '1400'),
(1735, '1', 1097, 2, 2, '2000'),
(1736, '1', 1098, 46, 1, '2800'),
(1737, '1', 1099, 1, 2, '7900'),
(1738, '1', 1100, 2, 2, '2000'),
(1739, '1', 1101, 23, 2, '2000'),
(1740, '1', 1101, 14, 1, '4000'),
(1741, '1', 1102, 8, 2, '4800'),
(1742, '1', 1103, 48, 1, '4000'),
(1743, '1', 1104, 37, 1, '2000'),
(1744, '1', 1104, 20, 1, '2000'),
(1745, '1', 1105, 21, 1, '2000'),
(1746, '2', 1105, 10, 1, '4200'),
(1747, '1', 1105, 3, 2, '5900'),
(1748, '1', 1106, 2, 2, '2000'),
(1749, '1', 1107, 20, 1, '2000'),
(1750, '1', 1108, 3, 2, '5900'),
(1751, '2', 1108, 2, 2, '4000'),
(1752, '1', 1109, 48, 1, '4000'),
(1753, '1', 1109, 1, 2, '7900'),
(1754, '1', 1110, 48, 1, '4000'),
(1755, '1', 1110, 45, 1, '2500'),
(1756, '1', 1111, 20, 1, '2000'),
(1757, '2', 1111, 10, 1, '4200'),
(1758, '1', 1111, 2, 2, '2000'),
(1759, '1', 1112, 3, 2, '5900'),
(1760, '1', 1113, 2, 2, '2000'),
(1761, '1', 1114, 2, 2, '2000'),
(1762, '1', 1115, 1, 2, '7900'),
(1763, '1', 1116, 43, 1, '1300'),
(1764, '1', 1116, 38, 1, '2500'),
(1766, '1', 1117, 45, 1, '2500'),
(1767, '1', 1118, 10, 1, '2100'),
(1768, '1', 1118, 14, 1, '4000'),
(1769, '2', 1119, 37, 1, '4000'),
(1770, '1', 1119, 45, 1, '2500'),
(1771, '1', 1119, 1, 2, '7900'),
(1772, '1', 1120, 23, 1, '2000'),
(1773, '1', 1120, 5, 1, '2200'),
(1774, '1', 1120, 7, 2, '5000'),
(1775, '2', 1121, 36, 1, '1200'),
(1776, '1', 1121, 45, 1, '2500'),
(1777, '1', 1122, 1, 2, '7900'),
(1778, '1', 1123, 33, 1, '1400'),
(1779, '2', 1124, 10, 1, '4200'),
(1780, '1', 1124, 21, 1, '2000'),
(1781, '1', 1125, 10, 1, '2100'),
(1782, '1', 1126, 14, 1, '4000'),
(1783, '1', 1127, 2, 2, '2000'),
(1784, '2', 1128, 38, 1, '5000'),
(1785, '1', 1128, 44, 1, '2500'),
(1786, '1', 1128, 1, 2, '7900'),
(1787, '2', 1128, 2, 2, '4000'),
(1788, '1', 1129, 1, 2, '7900'),
(1789, '1', 1130, 2, 2, '2000'),
(1790, '1', 1131, 1, 2, '7900'),
(1791, '2', 1132, 10, 1, '4200'),
(1792, '1', 1132, 20, 1, '2000'),
(1793, '1', 1133, 14, 1, '4000'),
(1794, '1', 1134, 14, 1, '4000'),
(1795, '1', 1135, 24, 2, '2000'),
(1796, '1', 1136, 28, 2, '2000'),
(1797, '2', 1137, 10, 1, '4200'),
(1798, '1', 1137, 23, 1, '2000'),
(1799, '1', 1138, 2, 2, '2000'),
(1800, '1', 1139, 1, 2, '7900'),
(1801, '1', 1140, 26, 2, '2000'),
(1802, '1', 1138, 45, 1, '2500'),
(1803, '1', 1138, 37, 1, '2000'),
(1804, '1', 1141, 22, 1, '2000'),
(1805, '1', 1141, 10, 1, '2100'),
(1806, '1', 1142, 1, 2, '7900'),
(1807, '1', 1143, 42, 1, '1300'),
(1808, '1', 1143, 38, 1, '2500'),
(1809, '1', 1143, 44, 1, '2500'),
(1810, '1', 1144, 1, 2, '7900'),
(1811, '1', 1144, 3, 2, '5900'),
(1812, '2', 1145, 4, 1, '9600'),
(1813, '1', 1146, 10, 1, '2100'),
(1814, '1', 1146, 21, 1, '2000'),
(1815, '1', 1146, 1, 2, '7900'),
(1816, '1', 1147, 10, 1, '2100'),
(1817, '1', 1148, 37, 1, '2000'),
(1818, '1', 1148, 45, 1, '2500'),
(1819, '1', 1149, 20, 1, '2000'),
(1820, '1', 1150, 34, 1, '1400'),
(1821, '1', 1150, 45, 1, '2500'),
(1822, '1', 1151, 1, 2, '7900'),
(1823, '2', 1152, 36, 1, '1200'),
(1824, '1', 1153, 17, 1, '5000'),
(1825, '1', 1153, 27, 1, '2000'),
(1826, '1', 1153, 1, 2, '7900'),
(1827, '1', 1154, 14, 1, '4000'),
(1828, '1', 1155, 22, 2, '2000'),
(1829, '1', 1155, 7, 2, '5000'),
(1830, '1', 1156, 3, 2, '5900'),
(1831, '1', 1157, 10, 1, '2100'),
(1832, '1', 1157, 3, 2, '5900'),
(1833, '1', 1157, 23, 1, '2000'),
(1834, '1', 1158, 10, 1, '2100'),
(1835, '1', 1158, 1, 2, '7900'),
(1836, '1', 1158, 21, 1, '2000'),
(1837, '1', 1159, 2, 2, '2000'),
(1838, '3', 1160, 35, 1, '4200'),
(1839, '1', 1161, 3, 2, '5900'),
(1840, '1', 1162, 22, 2, '2000'),
(1841, '1', 1162, 28, 2, '2000'),
(1842, '1', 1163, 33, 1, '1400'),
(1843, '2', 1164, 11, 1, '4200'),
(1844, '1', 1164, 8, 2, '4800'),
(1845, '1', 1165, 22, 2, '2000'),
(1846, '1', 1166, 2, 2, '2000'),
(1847, '1', 1167, 2, 2, '2000'),
(1848, '1', 1168, 37, 1, '2000'),
(1849, '1', 1168, 45, 1, '2500'),
(1850, '1', 1168, 2, 2, '2000'),
(1851, '2', 1169, 4, 2, '9600'),
(1852, '2', 1169, 24, 2, '4000'),
(1853, '1', 1170, 10, 1, '2100'),
(1854, '1', 1170, 21, 1, '2000'),
(1855, '1', 1171, 45, 1, '2500'),
(1856, '1', 1171, 3, 2, '5900'),
(1857, '1', 1171, 33, 1, '1400'),
(1858, '1', 1172, 2, 2, '2000'),
(1859, '1', 1173, 3, 2, '5900'),
(1860, '1', 1174, 34, 1, '1400'),
(1861, '1', 1174, 36, 1, '600'),
(1862, '1', 1174, 45, 1, '2500'),
(1863, '1', 1175, 2, 2, '2000'),
(1864, '1', 1176, 2, 2, '2000'),
(1865, '1', 1177, 40, 1, '2200'),
(1866, '1', 1178, 38, 1, '2500'),
(1867, '1', 1178, 45, 1, '2500'),
(1868, '1', 1178, 1, 2, '7900'),
(1869, '1', 1179, 2, 2, '2000'),
(1870, '1', 1179, 8, 2, '4800'),
(1871, '1', 1179, 28, 2, '2000'),
(1872, '1', 1180, 2, 2, '2000'),
(1873, '1', 1181, 29, 1, '2000'),
(1874, '1', 1181, 3, 2, '5900'),
(1875, '1', 1182, 2, 2, '2000'),
(1876, '1', 1182, 4, 2, '4800'),
(1877, '1', 1183, 47, 1, '2900'),
(1878, '1', 1183, 44, 1, '2500'),
(1879, '1', 1184, 17, 1, '5000'),
(1880, '1', 1184, 28, 1, '2000'),
(1881, '1', 1185, 2, 2, '2000'),
(1882, '2', 1185, 7, 2, '10000'),
(1883, '1', 1186, 14, 1, '4000'),
(1884, '1', 1186, 10, 1, '2100'),
(1885, '1', 1187, 10, 1, '2100'),
(1886, '1', 1188, 2, 2, '2000'),
(1887, '1', 1189, 13, 1, '3000'),
(1888, '1', 1190, 33, 1, '1400'),
(1889, '2', 1191, 10, 1, '4200'),
(1890, '1', 1191, 23, 1, '2000'),
(1891, '1', 1191, 3, 2, '5900'),
(1892, '1', 1192, 8, 1, '4800'),
(1893, '1', 1193, 3, 2, '5900'),
(1894, '1', 1194, 1, 2, '7900'),
(1895, '1', 1195, 2, 2, '2000'),
(1896, '1', 1195, 38, 1, '2500'),
(1897, '1', 1196, 38, 1, '2500'),
(1898, '1', 1196, 45, 1, '2500'),
(1899, '2', 1197, 9, 1, '4000'),
(1900, '1', 1197, 20, 1, '2000'),
(1901, '1', 1198, 2, 2, '2000'),
(1902, '1', 1199, 10, 1, '2100'),
(1903, '1', 1200, 8, 1, '4800'),
(1904, '1', 1200, 21, 1, '2000'),
(1905, '1', 1201, 28, 2, '2000'),
(1906, '1', 1201, 14, 1, '4000'),
(1907, '1', 1202, 14, 1, '4000'),
(1908, '2', 1202, 10, 1, '4200'),
(1909, '1', 1202, 20, 1, '2000'),
(1910, '1', 1203, 16, 1, '2000'),
(1911, '1', 1203, 18, 1, '2000'),
(1912, '1', 1204, 2, 2, '2000'),
(1913, '1', 1204, 22, 2, '2000'),
(1914, '1', 1205, 2, 2, '2000'),
(1915, '1', 1206, 33, 1, '1400'),
(1916, '1', 1206, 15, 1, '3000'),
(1917, '1', 1207, 12, 1, '2500'),
(1918, '1', 1207, 21, 2, '2000'),
(1919, '1', 1208, 20, 1, '2000'),
(1920, '3', 1209, 33, 1, '4200'),
(1921, '1', 1210, 2, 2, '2000'),
(1922, '1', 1211, 33, 1, '1400'),
(1923, '2', 1212, 43, 1, '2600'),
(1924, '1', 1212, 45, 1, '2500'),
(1925, '1', 1213, 14, 1, '4000'),
(1926, '2', 1214, 33, 1, '2800'),
(1927, '1', 1214, 45, 1, '2500'),
(1928, '1', 1214, 3, 2, '5900'),
(1929, '1', 1215, 12, 1, '2500'),
(1930, '1', 1216, 38, 1, '2500'),
(1931, '1', 1216, 45, 1, '2500'),
(1932, '1', 1216, 37, 1, '2000'),
(1933, '1', 1217, 4, 1, '4800'),
(1934, '1', 1217, 30, 1, '2000'),
(1935, '1', 1218, 14, 1, '4000'),
(1937, '1', 1219, 3, 2, '5900'),
(1938, '1', 1220, 2, 2, '2000'),
(1939, '1', 1221, 20, 1, '2000'),
(1940, '1', 1222, 3, 2, '5900'),
(1941, '3', 1222, 36, 1, '1800'),
(1942, '1', 1223, 45, 1, '2500'),
(1943, '1', 1223, 36, 1, '600'),
(1944, '1', 1224, 13, 1, '3000'),
(1945, '1', 1225, 48, 1, '4000'),
(1946, '1', 1225, 45, 1, '2500'),
(1947, '2', 1226, 43, 1, '2600'),
(1948, '1', 1227, 45, 1, '2500'),
(1949, '1', 1227, 1, 2, '7900'),
(1950, '1', 1228, 8, 2, '4800'),
(1951, '1', 1229, 1, 2, '7900'),
(1952, '1', 1229, 10, 1, '2100'),
(1953, '1', 1229, 18, 1, '2000'),
(1954, '2', 1230, 48, 1, '8000'),
(1955, '2', 1230, 45, 1, '5000'),
(1956, '1', 1230, 3, 2, '5900'),
(1957, '2', 1230, 2, 2, '4000'),
(1958, '2', 1231, 33, 1, '2800'),
(1959, '1', 1231, 2, 2, '2000'),
(1960, '1', 1232, 36, 1, '600'),
(1961, '2', 1232, 35, 1, '2800'),
(1962, '1', 1233, 2, 2, '2000'),
(1963, '1', 1233, 33, 1, '1400'),
(1964, '1', 1234, 35, 1, '1400'),
(1965, '1', 1234, 5, 1, '2200'),
(1966, '1', 1235, 1, 2, '7900'),
(1967, '1', 1236, 14, 1, '4000'),
(1968, '1', 1237, 3, 2, '5900'),
(1969, '1', 1238, 14, 1, '4000'),
(1970, '1', 1238, 3, 2, '5900'),
(1971, '1', 1239, 38, 1, '2500'),
(1972, '1', 1240, 1, 2, '7900'),
(1973, '3', 1241, 37, 1, '6000'),
(1974, '1', 1241, 45, 1, '2500'),
(1975, '1', 1241, 1, 2, '7900'),
(1976, '1', 1242, 2, 2, '2000'),
(1977, '1', 1243, 1, 2, '7900'),
(1978, '1', 1244, 1, 2, '7900'),
(1979, '2', 1245, 35, 1, '2800'),
(1980, '1', 1246, 1, 2, '7900'),
(1981, '1', 1246, 10, 1, '2100'),
(1982, '1', 1247, 28, 2, '2000'),
(1983, '1', 1247, 2, 2, '2000'),
(1984, '1', 1247, 7, 2, '5000'),
(1985, '1', 1248, 20, 1, '2000'),
(1986, '1', 1249, 25, 1, '2000'),
(1987, '1', 1249, 1, 2, '7900'),
(1988, '1', 1249, 17, 1, '5000'),
(1989, '3', 1250, 34, 1, '4200'),
(1990, '2', 1250, 45, 1, '5000'),
(1991, '1', 1251, 31, 1, '2000'),
(1992, '1', 1251, 33, 1, '1400'),
(1993, '1', 1252, 3, 2, '5900'),
(1994, '1', 1252, 26, 2, '2000'),
(1995, '1', 1253, 6, 1, '3200'),
(1996, '1', 1253, 11, 1, '2100'),
(1997, '1', 1253, 31, 1, '2000'),
(1998, '1', 1254, 43, 1, '1300'),
(1999, '1', 1254, 39, 1, '2200'),
(2000, '2', 1255, 10, 1, '4200'),
(2001, '1', 1255, 25, 1, '2000'),
(2002, '2', 1256, 10, 1, '4200'),
(2003, '1', 1256, 23, 1, '2000'),
(2004, '1', 1257, 31, 1, '2000'),
(2005, '2', 1257, 11, 1, '4200'),
(2006, '1', 1257, 1, 2, '7900'),
(2007, '1', 1257, 2, 2, '2000'),
(2008, '2', 1258, 37, 1, '4000'),
(2009, '1', 1258, 44, 1, '2500'),
(2010, '1', 1259, 3, 2, '5900'),
(2011, '4', 1260, 43, 1, '5200'),
(2012, '2', 1260, 44, 1, '5000'),
(2013, '1', 1260, 37, 1, '2000'),
(2014, '1', 1261, 1, 2, '7900'),
(2015, '1', 1262, 1, 2, '7900'),
(2016, '1', 1262, 2, 2, '2000'),
(2017, '1', 1263, 41, 1, '1300'),
(2018, '2', 1263, 36, 1, '1200'),
(2019, '1', 1263, 3, 2, '5900'),
(2020, '1', 1264, 1, 2, '7900'),
(2021, '1', 1265, 22, 2, '2000'),
(2022, '3', 1266, 35, 1, '4200'),
(2023, '1', 1267, 10, 1, '2100'),
(2024, '2', 1267, 25, 1, '4000'),
(2025, '1', 1268, 4, 1, '4800'),
(2026, '1', 1268, 25, 1, '2000'),
(2027, '1', 1269, 10, 1, '2100'),
(2028, '1', 1269, 1, 2, '7900'),
(2029, '1', 1270, 40, 1, '2200'),
(2030, '1', 1270, 37, 2, '2000'),
(2031, '1', 1271, 45, 1, '2500'),
(2032, '1', 1271, 37, 1, '2000'),
(2033, '1', 1272, 33, 1, '1400'),
(2034, '1', 1273, 37, 1, '2000'),
(2035, '1', 1273, 45, 1, '2500'),
(2036, '1', 1274, 13, 1, '3000'),
(2037, '1', 1275, 2, 2, '2000'),
(2038, '2', 1276, 4, 1, '9600'),
(2039, '1', 1277, 2, 2, '2000'),
(2040, '1', 1277, 4, 1, '4800'),
(2041, '1', 1277, 44, 1, '2500'),
(2042, '1', 1278, 2, 2, '2000'),
(2043, '1', 1279, 13, 1, '3000'),
(2044, '2', 1280, 9, 1, '4000'),
(2045, '2', 1280, 4, 2, '9600'),
(2046, '2', 1280, 24, 2, '4000'),
(2047, '2', 1281, 21, 1, '4000'),
(2048, '1', 1281, 30, 1, '2000'),
(2049, '1', 1281, 27, 1, '2000'),
(2050, '1', 1282, 2, 2, '2000'),
(2051, '1', 1282, 35, 1, '1400'),
(2052, '2', 1283, 37, 1, '4000'),
(2053, '1', 1283, 2, 2, '2000'),
(2054, '1', 1283, 45, 1, '2500'),
(2055, '1', 1284, 1, 2, '7900'),
(2056, '1', 1284, 10, 1, '2100'),
(2057, '1', 1285, 33, 1, '1400'),
(2058, '1', 1286, 21, 1, '2000'),
(2059, '1', 1286, 3, 2, '5900'),
(2060, '2', 1286, 10, 1, '4200'),
(2061, '1', 1287, 1, 2, '7900'),
(2062, '1', 1288, 8, 2, '4800'),
(2063, '1', 1288, 22, 2, '2000'),
(2064, '1', 1289, 20, 1, '2000'),
(2065, '2', 1290, 36, 1, '1200'),
(2066, '1', 1290, 45, 1, '2500'),
(2067, '1', 1290, 3, 2, '5900'),
(2068, '1', 1291, 8, 2, '4800'),
(2069, '1', 1291, 23, 1, '2000'),
(2070, '1', 1292, 3, 2, '5900'),
(2071, '1', 1293, 40, 1, '2200'),
(2072, '1', 1293, 3, 2, '5900'),
(2073, '1', 1293, 44, 1, '2500'),
(2074, '1', 1294, 48, 1, '4000'),
(2075, '1', 1294, 43, 1, '1300'),
(2076, '1', 1294, 7, 2, '5000'),
(2077, '1', 1294, 45, 1, '2500'),
(2078, '1', 1295, 46, 1, '2800'),
(2079, '2', 1295, 43, 1, '2600'),
(2080, '2', 1296, 38, 1, '5000'),
(2081, '1', 1296, 45, 1, '2500'),
(2082, '1', 1297, 2, 2, '2000'),
(2083, '1', 1297, 7, 2, '5000'),
(2084, '1', 1298, 35, 1, '1400'),
(2085, '1', 1298, 36, 1, '600'),
(2086, '1', 1299, 1, 2, '7900'),
(2087, '1', 1300, 34, 1, '1400'),
(2088, '1', 1301, 10, 1, '2100'),
(2089, '1', 1302, 1, 2, '7900'),
(2090, '1', 1303, 37, 1, '2000'),
(2091, '1', 1303, 45, 1, '2500'),
(2092, '1', 1304, 38, 1, '2500'),
(2093, '1', 1304, 31, 1, '2000'),
(2094, '1', 1305, 3, 2, '5900'),
(2095, '2', 1306, 10, 1, '4200'),
(2096, '1', 1307, 2, 2, '2000'),
(2097, '1', 1308, 41, 1, '1300'),
(2098, '2', 1308, 36, 1, '1200'),
(2099, '1', 1308, 3, 2, '5900'),
(2100, '1', 1309, 34, 1, '1400'),
(2101, '1', 1309, 36, 1, '600'),
(2102, '1', 1310, 1, 2, '7900'),
(2103, '1', 1311, 35, 1, '1400'),
(2104, '1', 1311, 42, 1, '1300'),
(2105, '1', 1312, 48, 1, '4000'),
(2106, '1', 1312, 45, 1, '2500'),
(2107, '1', 1313, 17, 1, '5000'),
(2108, '1', 1313, 1, 2, '7900'),
(2109, '1', 1314, 24, 2, '2000'),
(2110, '1', 1315, 14, 1, '4000'),
(2111, '1', 1315, 7, 2, '5000'),
(2112, '1', 1316, 33, 1, '1400'),
(2113, '1', 1317, 1, 2, '7900'),
(2114, '1', 1318, 14, 1, '4000'),
(2115, '1', 1318, 10, 1, '2100'),
(2116, '1', 1319, 34, 1, '1400'),
(2117, '1', 1319, 36, 1, '600'),
(2118, '1', 1320, 22, 2, '2000'),
(2119, '1', 1320, 1, 2, '7900'),
(2120, '1', 1321, 10, 1, '2100'),
(2121, '1', 1321, 3, 2, '5900'),
(2122, '1', 1317, 38, 1, '2500'),
(2123, '1', 1317, 45, 1, '2500'),
(2124, '1', 1322, 1, 2, '7900'),
(2125, '1', 1323, 8, 2, '4800'),
(2126, '1', 1324, 4, 1, '4800'),
(2127, '1', 1325, 2, 2, '2000'),
(2128, '1', 1326, 3, 2, '5900'),
(2129, '1', 1327, 1, 2, '7900'),
(2130, '1', 1328, 37, 1, '2000'),
(2131, '1', 1328, 20, 1, '2000'),
(2132, '1', 1329, 1, 2, '7900'),
(2133, '7', 1330, 36, 1, '4200'),
(2134, '1', 1331, 20, 1, '2000'),
(2135, '1', 1332, 2, 2, '2000'),
(2136, '1', 1332, 24, 2, '2000'),
(2137, '1', 1333, 10, 1, '2100'),
(2138, '1', 1333, 9, 1, '2000'),
(2139, '1', 1333, 1, 2, '7900'),
(2140, '1', 1334, 34, 1, '1400'),
(2141, '1', 1334, 36, 1, '600'),
(2142, '1', 1335, 1, 2, '7900'),
(2143, '1', 1336, 14, 1, '4000'),
(2144, '1', 1337, 22, 2, '2000'),
(2145, '1', 1338, 3, 2, '5900'),
(2146, '1', 1339, 2, 2, '2000'),
(2147, '2', 1340, 38, 1, '5000'),
(2148, '1', 1340, 1, 2, '7900'),
(2149, '1', 1340, 45, 1, '2500'),
(2150, '1', 1340, 2, 2, '2000'),
(2151, '1', 1341, 10, 1, '2100'),
(2152, '1', 1342, 10, 1, '2100'),
(2153, '1', 1342, 1, 2, '7900'),
(2154, '1', 1343, 8, 2, '4800'),
(2155, '1', 1343, 2, 2, '2000'),
(2156, '2', 1343, 36, 1, '1200'),
(2157, '3', 1344, 33, 1, '4200'),
(2158, '1', 1345, 1, 2, '7900'),
(2159, '1', 1345, 45, 1, '2500'),
(2160, '2', 1345, 43, 1, '2600'),
(2161, '1', 1346, 37, 1, '2000'),
(2163, '1', 1348, 44, 1, '2500'),
(2164, '1', 1348, 1, 2, '7900'),
(2165, '1', 1348, 38, 1, '2500'),
(2166, '1', 1350, 1, 2, '7900'),
(2167, '1', 1350, 2, 2, '2000'),
(2168, '2', 1351, 7, 2, '10000'),
(2169, '1', 1352, 10, 1, '2100'),
(2170, '2', 1353, 10, 1, '4200'),
(2171, '1', 1353, 24, 1, '2000'),
(2172, '1', 1353, 1, 2, '7900'),
(2173, '1', 1354, 34, 1, '1400'),
(2174, '1', 1354, 36, 1, '600'),
(2175, '1', 1355, 2, 2, '2000'),
(2176, '1', 1356, 13, 1, '3000'),
(2177, '1', 1357, 6, 1, '3200'),
(2178, '1', 1357, 28, 1, '2000'),
(2179, '1', 1357, 3, 2, '5900'),
(2180, '1', 1358, 8, 2, '4800'),
(2181, '1', 1359, 10, 1, '2100'),
(2182, '1', 1359, 1, 2, '7900'),
(2183, '1', 1360, 20, 1, '2000'),
(2184, '1', 1361, 3, 2, '5900'),
(2185, '1', 1362, 1, 2, '7900'),
(2186, '1', 1363, 36, 1, '600'),
(2187, '1', 1363, 44, 1, '2500'),
(2188, '1', 1363, 38, 1, '2500'),
(2189, '1', 1363, 28, 2, '2000'),
(2190, '1', 1364, 3, 2, '5900'),
(2191, '1', 1365, 36, 1, '600'),
(2192, '1', 1365, 14, 2, '4000'),
(2193, '1', 1365, 34, 1, '1400'),
(2194, '1', 1365, 19, 1, '2000'),
(2195, '1', 1366, 38, 1, '2500'),
(2196, '1', 1366, 1, 2, '7900'),
(2197, '1', 1366, 44, 1, '2500'),
(2198, '1', 1367, 28, 1, '2000'),
(2199, '1', 1367, 2, 2, '2000'),
(2200, '1', 1368, 10, 1, '2100'),
(2201, '1', 1367, 14, 2, '4000'),
(2202, '1', 1369, 1, 2, '7900'),
(2203, '1', 1370, 1, 2, '7900'),
(2204, '1', 1370, 34, 1, '1400'),
(2205, '1', 1371, 14, 1, '4000'),
(2206, '1', 1372, 14, 1, '4000'),
(2207, '1', 1373, 4, 1, '4800'),
(2208, '1', 1373, 27, 1, '2000'),
(2209, '1', 1374, 8, 1, '4800'),
(2210, '1', 1375, 1, 2, '7900'),
(2211, '1', 1376, 1, 2, '7900'),
(2212, '1', 1376, 26, 2, '2000'),
(2213, '2', 1377, 35, 1, '2800'),
(2214, '1', 1377, 4, 1, '4800'),
(2215, '2', 1378, 10, 1, '4200'),
(2216, '1', 1379, 2, 2, '2000'),
(2217, '1', 1380, 13, 1, '3000'),
(2218, '1', 1381, 2, 2, '2000'),
(2219, '2', 1382, 2, 2, '4000'),
(2220, '2', 1382, 28, 2, '4000'),
(2221, '1', 1383, 44, 1, '2500'),
(2222, '2', 1383, 36, 1, '1200'),
(2223, '1', 1383, 24, 2, '2000'),
(2224, '1', 1383, 8, 2, '4800'),
(2225, '3', 1384, 10, 1, '6300'),
(2226, '1', 1384, 23, 1, '2000'),
(2227, '1', 1385, 2, 2, '2000'),
(2228, '1', 1386, 33, 1, '1400'),
(2229, '1', 1386, 36, 1, '600'),
(2230, '1', 1387, 1, 2, '7900'),
(2231, '3', 1388, 35, 1, '4200'),
(2232, '2', 1389, 1, 2, '15800'),
(2233, '2', 1390, 46, 1, '5600'),
(2234, '1', 1391, 4, 2, '4800'),
(2235, '1', 1392, 33, 1, '1400'),
(2236, '1', 1393, 10, 1, '2100'),
(2237, '1', 1393, 1, 2, '7900'),
(2238, '1', 1394, 13, 1, '3000'),
(2239, '1', 1395, 37, 1, '2000'),
(2240, '1', 1395, 45, 1, '2500'),
(2241, '1', 1396, 45, 1, '2500'),
(2242, '1', 1397, 10, 1, '2100'),
(2243, '2', 1397, 25, 1, '4000'),
(2244, '2', 1398, 10, 1, '4200'),
(2245, '1', 1399, 3, 2, '5900'),
(2246, '1', 1400, 2, 2, '2000'),
(2248, '1', 1401, 8, 2, '4800'),
(2249, '1', 1401, 24, 2, '2000'),
(2250, '2', 1401, 36, 1, '1200'),
(2251, '1', 1401, 45, 1, '2500'),
(2253, '1', 1403, 37, 1, '2000'),
(2254, '1', 1403, 45, 1, '2500'),
(2255, '1', 1403, 42, 1, '1300'),
(2256, '1', 1403, 1, 2, '7900'),
(2257, '1', 1404, 1, 2, '7900'),
(2258, '1', 1405, 40, 1, '2200'),
(2259, '1', 1405, 3, 2, '5900'),
(2260, '1', 1405, 44, 1, '2500'),
(2261, '1', 1406, 4, 1, '4800'),
(2262, '1', 1406, 28, 1, '2000'),
(2263, '1', 1406, 1, 2, '7900'),
(2264, '2', 1407, 43, 1, '2600'),
(2265, '1', 1407, 44, 1, '2500'),
(2266, '1', 1407, 1, 2, '7900'),
(2267, '1', 1408, 34, 1, '1400'),
(2268, '1', 1408, 36, 1, '600'),
(2269, '1', 1402, 45, 1, '2500'),
(2270, '1', 1402, 34, 1, '1400'),
(2271, '1', 1409, 22, 2, '2000'),
(2272, '1', 1410, 45, 1, '2500'),
(2273, '1', 1410, 48, 1, '4000'),
(2274, '1', 1410, 1, 2, '7900'),
(2275, '2', 1411, 38, 1, '5000'),
(2276, '1', 1411, 3, 2, '5900'),
(2277, '1', 1411, 1, 2, '7900'),
(2278, '2', 1412, 14, 1, '8000'),
(2279, '1', 1413, 3, 2, '5900'),
(2280, '1', 1413, 10, 1, '2100'),
(2281, '1', 1414, 1, 2, '7900'),
(2282, '1', 1415, 14, 1, '4000'),
(2283, '1', 1416, 1, 2, '7900'),
(2284, '1', 1417, 21, 2, '2000'),
(2285, '1', 1418, 40, 1, '2200'),
(2286, '2', 1418, 36, 1, '1200'),
(2287, '1', 1418, 45, 1, '2500'),
(2288, '1', 1418, 30, 2, '2000'),
(2289, '2', 1418, 36, 2, '1200'),
(2290, '1', 1419, 14, 1, '4000'),
(2291, '1', 1419, 3, 2, '5900'),
(2292, '1', 1420, 10, 1, '2100'),
(2293, '1', 1420, 23, 2, '2000'),
(2294, '1', 1420, 14, 1, '4000'),
(2295, '1', 1421, 10, 1, '2100'),
(2296, '1', 1422, 17, 2, '5000'),
(2297, '1', 1422, 8, 2, '4800'),
(2298, '2', 1422, 24, 2, '4000'),
(2299, '1', 1423, 4, 2, '4800'),
(2300, '1', 1423, 33, 1, '1400'),
(2301, '1', 1423, 21, 2, '2000'),
(2302, '1', 1424, 1, 2, '7900'),
(2303, '1', 1425, 1, 2, '7900'),
(2304, '2', 1426, 36, 1, '1200'),
(2305, '3', 1427, 33, 1, '4200'),
(2306, '1', 1428, 28, 2, '2000'),
(2307, '1', 1428, 8, 2, '4800'),
(2308, '2', 1429, 34, 1, '2800'),
(2309, '1', 1430, 7, 2, '5000'),
(2311, '1', 1431, 20, 1, '2000'),
(2312, '1', 1432, 46, 1, '2800'),
(2313, '1', 1433, 2, 2, '2000'),
(2314, '1', 1433, 4, 2, '4800'),
(2315, '1', 1434, 46, 1, '2800'),
(2316, '1', 1435, 3, 2, '5900'),
(2317, '1', 1416, 24, 2, '2000'),
(2319, '2', 1437, 14, 1, '8000'),
(2320, '1', 1437, 23, 2, '2000'),
(2321, '1', 1438, 1, 2, '7900'),
(2322, '1', 1439, 34, 1, '1400'),
(2323, '1', 1440, 22, 2, '2000'),
(2324, '1', 1441, 10, 1, '2100'),
(2325, '2', 1442, 46, 1, '5600'),
(2326, '2', 1443, 1, 2, '15800'),
(2327, '3', 1444, 43, 1, '3900'),
(2328, '1', 1444, 44, 1, '2500'),
(2329, '1', 1445, 13, 1, '3000'),
(2330, '1', 1446, 22, 2, '2000'),
(2331, '1', 1446, 2, 2, '2000'),
(2332, '1', 1447, 1, 2, '7900'),
(2333, '1', 1448, 27, 2, '2000'),
(2334, '1', 1449, 3, 2, '5900'),
(2335, '1', 1450, 20, 1, '2000'),
(2336, '1', 1450, 17, 1, '5000'),
(2337, '3', 1451, 34, 1, '4200'),
(2340, '1', 1453, 3, 2, '5900'),
(2341, '1', 1453, 34, 1, '1400'),
(2342, '1', 1453, 36, 1, '600'),
(2343, '1', 1454, 13, 1, '3000'),
(2344, '2', 1455, 14, 1, '8000'),
(2345, '1', 1455, 3, 2, '5900'),
(2346, '1', 1456, 44, 1, '2500'),
(2347, '1', 1456, 40, 1, '2200'),
(2348, '1', 1457, 8, 2, '4800'),
(2349, '1', 1458, 2, 2, '2000'),
(2350, '2', 1459, 10, 1, '4200'),
(2351, '1', 1460, 10, 1, '2100'),
(2353, '1', 1462, 2, 2, '2000'),
(2354, '1', 1463, 2, 2, '2000'),
(2355, '1', 1463, 14, 2, '4000'),
(2356, '1', 1464, 22, 2, '2000'),
(2357, '1', 1464, 2, 2, '2000'),
(2358, '1', 1465, 24, 2, '2000'),
(2360, '1', 1467, 37, 1, '2000'),
(2361, '1', 1467, 44, 1, '2500'),
(2362, '1', 1467, 1, 2, '7900'),
(2363, '1', 1468, 2, 2, '2000'),
(2364, '1', 1469, 14, 1, '4000'),
(2365, '2', 1470, 4, 1, '9600'),
(2366, '3', 1471, 10, 1, '6300'),
(2367, '1', 1471, 23, 1, '2000'),
(2368, '1', 1472, 1, 2, '7900'),
(2369, '1', 1473, 37, 1, '2000'),
(2370, '1', 1473, 45, 1, '2500'),
(2371, '1', 1474, 45, 1, '2500'),
(2372, '1', 1474, 2, 2, '2000'),
(2373, '1', 1474, 37, 1, '2000'),
(2374, '1', 1475, 2, 2, '2000'),
(2375, '1', 1475, 4, 2, '4800'),
(2376, '1', 1476, 1, 2, '7900'),
(2379, '2', 1478, 10, 2, '4200'),
(2380, '1', 1478, 12, 1, '2500'),
(2381, '1', 1478, 18, 2, '2000'),
(2382, '1', 1479, 10, 1, '2100'),
(2383, '1', 1480, 2, 2, '2000'),
(2386, '1', 1482, 36, 1, '600'),
(2387, '1', 1482, 34, 1, '1400'),
(2388, '1', 1483, 4, 1, '4800'),
(2389, '2', 1483, 14, 1, '8000'),
(2390, '1', 1483, 1, 2, '7900'),
(2391, '1', 1484, 1, 2, '7900'),
(2392, '1', 1484, 39, 1, '2200'),
(2393, '1', 1485, 37, 1, '2000'),
(2394, '2', 1485, 43, 1, '2600'),
(2395, '1', 1486, 3, 2, '5900'),
(2396, '1', 1487, 31, 1, '2000'),
(2397, '1', 1487, 1, 2, '7900'),
(2398, '1', 1488, 14, 1, '4000'),
(2399, '1', 1488, 23, 2, '2000'),
(2400, '1', 1488, 10, 1, '2100'),
(2401, '1', 1488, 9, 1, '2000'),
(2402, '1', 1489, 37, 1, '2000'),
(2403, '1', 1490, 7, 2, '5000'),
(2404, '1', 1490, 25, 2, '2000'),
(2405, '1', 1491, 1, 2, '7900'),
(2406, '1', 1492, 1, 2, '7900'),
(2407, '1', 1493, 16, 1, '2000'),
(2408, '1', 1493, 1, 2, '7900'),
(2409, '1', 1494, 9, 1, '2000'),
(2410, '1', 1494, 3, 2, '5900'),
(2411, '3', 1495, 36, 1, '1800'),
(2412, '1', 1495, 45, 1, '2500'),
(2413, '1', 1495, 24, 2, '2000'),
(2414, '2', 1495, 10, 2, '4200'),
(2415, '1', 1496, 10, 1, '2100'),
(2416, '1', 1497, 1, 2, '7900'),
(2417, '1', 1498, 45, 1, '2500'),
(2418, '1', 1498, 34, 1, '1400'),
(2419, '1', 1498, 7, 2, '5000'),
(2420, '2', 1499, 10, 1, '4200'),
(2421, '1', 1499, 27, 1, '2000'),
(2422, '1', 1500, 11, 1, '2100'),
(2423, '1', 1500, 9, 1, '2000'),
(2424, '1', 1501, 2, 2, '2000'),
(2425, '1', 1502, 39, 1, '2200'),
(2426, '1', 1503, 34, 1, '1400'),
(2427, '1', 1503, 45, 1, '2500'),
(2428, '1', 1503, 36, 1, '600'),
(2429, '1', 1504, 40, 1, '2200'),
(2430, '1', 1505, 35, 1, '1400'),
(2431, '1', 1505, 8, 2, '4800'),
(2432, '1', 1505, 27, 2, '2000'),
(2433, '1', 1505, 47, 1, '2900'),
(2434, '1', 1506, 4, 1, '4800'),
(2435, '1', 1506, 31, 1, '2000'),
(2436, '1', 1506, 1, 2, '7900'),
(2437, '1', 1507, 33, 1, '1400'),
(2438, '1', 1507, 44, 1, '2500'),
(2439, '3', 1508, 35, 1, '4200'),
(2440, '1', 1509, 2, 2, '2000'),
(2441, '1', 1510, 45, 1, '2500'),
(2442, '1', 1510, 3, 2, '5900'),
(2443, '2', 1510, 10, 1, '4200'),
(2444, '1', 1511, 45, 1, '2500'),
(2445, '2', 1511, 36, 1, '1200'),
(2446, '1', 1512, 10, 1, '2100'),
(2447, '1', 1513, 14, 1, '4000'),
(2448, '1', 1514, 33, 1, '1400'),
(2449, '2', 1515, 7, 2, '10000'),
(2450, '2', 1515, 24, 2, '4000'),
(2451, '1', 1516, 14, 1, '4000'),
(2452, '1', 1517, 2, 2, '2000'),
(2453, '1', 1517, 22, 2, '2000'),
(2454, '1', 1518, 41, 1, '1300'),
(2455, '1', 1518, 44, 1, '2500'),
(2456, '1', 1518, 33, 1, '1400'),
(2457, '1', 1519, 23, 2, '2000'),
(2458, '1', 1520, 37, 1, '2000'),
(2459, '1', 1520, 2, 2, '2000'),
(2460, '1', 1520, 44, 1, '2500'),
(2461, '1', 1521, 14, 1, '4000'),
(2462, '1', 1522, 20, 1, '2000'),
(2463, '1', 1523, 1, 2, '7900'),
(2464, '2', 1524, 10, 1, '4200'),
(2465, '1', 1524, 22, 1, '2000'),
(2466, '1', 1524, 22, 2, '2000'),
(2467, '1', 1525, 2, 2, '2000'),
(2468, '1', 1525, 22, 2, '2000'),
(2469, '1', 1526, 14, 1, '4000'),
(2470, '3', 1527, 35, 1, '4200'),
(2471, '1', 1528, 3, 2, '5900'),
(2472, '1', 1529, 14, 1, '4000'),
(2473, '1', 1530, 4, 1, '4800'),
(2474, '1', 1530, 3, 2, '5900'),
(2475, '1', 1530, 28, 1, '2000'),
(2476, '2', 1531, 10, 1, '4200'),
(2477, '1', 1531, 31, 1, '2000'),
(2478, '1', 1532, 1, 2, '7900'),
(2479, '1', 1533, 5, 1, '2200'),
(2480, '1', 1533, 31, 1, '2000'),
(2481, '1', 1533, 1, 2, '7900'),
(2482, '1', 1534, 34, 1, '1400'),
(2483, '1', 1534, 36, 1, '600'),
(2484, '2', 1535, 36, 1, '1200'),
(2485, '1', 1535, 45, 1, '2500'),
(2486, '1', 1536, 35, 1, '1400'),
(2487, '1', 1536, 41, 1, '1300'),
(2488, '1', 1536, 36, 1, '600'),
(2489, '1', 1537, 10, 1, '2100'),
(2490, '1', 1538, 2, 2, '2000'),
(2491, '1', 1539, 14, 1, '4000'),
(2492, '1', 1539, 23, 1, '2000'),
(2493, '1', 1540, 33, 1, '1400'),
(2494, '1', 1540, 43, 1, '1300'),
(2495, '1', 1541, 1, 2, '7900'),
(2496, '2', 1542, 10, 1, '4200'),
(2497, '2', 1542, 20, 1, '4000'),
(2498, '1', 1543, 44, 1, '2500'),
(2499, '2', 1543, 37, 1, '4000'),
(2500, '1', 1543, 2, 2, '2000'),
(2501, '1', 1543, 24, 2, '2000'),
(2502, '1', 1544, 36, 1, '600'),
(2503, '1', 1544, 33, 1, '1400'),
(2504, '1', 1544, 34, 1, '1400'),
(2505, '1', 1545, 45, 1, '2500'),
(2506, '2', 1545, 36, 1, '1200'),
(2507, '1', 1545, 24, 2, '2000'),
(2508, '2', 1545, 10, 2, '4200'),
(2509, '1', 1546, 2, 2, '2000'),
(2510, '1', 1547, 35, 1, '1400'),
(2511, '1', 1547, 39, 1, '2200'),
(2512, '2', 1548, 10, 1, '4200'),
(2513, '1', 1548, 27, 2, '2000'),
(2514, '2', 1549, 10, 1, '4200'),
(2515, '1', 1549, 31, 1, '2000'),
(2516, '2', 1550, 46, 1, '5600'),
(2517, '1', 1551, 10, 1, '2100'),
(2518, '1', 1552, 37, 1, '2000'),
(2519, '1', 1552, 43, 1, '1300'),
(2520, '1', 1552, 44, 1, '2500'),
(2521, '2', 1553, 2, 2, '4000'),
(2522, '1', 1553, 43, 1, '1300'),
(2523, '1', 1554, 1, 2, '7900'),
(2524, '1', 1554, 2, 2, '2000'),
(2525, '1', 1555, 36, 1, '600'),
(2526, '1', 1556, 45, 1, '2500'),
(2527, '1', 1556, 34, 1, '1400'),
(2528, '1', 1556, 36, 1, '600'),
(2529, '1', 1556, 27, 2, '2000'),
(2530, '1', 1556, 7, 2, '5000'),
(2531, '2', 1557, 1, 2, '15800'),
(2532, '1', 1558, 1, 2, '7900'),
(2533, '1', 1559, 34, 1, '1400'),
(2534, '1', 1559, 45, 1, '2500'),
(2535, '1', 1559, 36, 1, '600'),
(2536, '1', 1560, 2, 2, '2000'),
(2537, '1', 1561, 35, 1, '1400'),
(2538, '1', 1561, 40, 1, '2200'),
(2539, '1', 1561, 2, 2, '2000'),
(2540, '2', 1562, 41, 1, '2600'),
(2541, '1', 1562, 43, 1, '1300'),
(2542, '1', 1563, 5, 1, '2200'),
(2543, '1', 1563, 31, 1, '2000'),
(2544, '1', 1563, 3, 2, '5900'),
(2545, '1', 1564, 48, 1, '4000'),
(2546, '1', 1564, 4, 2, '4800'),
(2547, '1', 1565, 5, 1, '2200'),
(2548, '1', 1565, 1, 2, '7900'),
(2549, '1', 1565, 31, 1, '2000'),
(2550, '6', 1566, 36, 1, '3600'),
(2551, '2', 1567, 4, 1, '9600'),
(2552, '2', 1567, 25, 1, '4000'),
(2553, '1', 1568, 45, 1, '2500'),
(2554, '1', 1568, 33, 1, '1400'),
(2555, '1', 1568, 36, 1, '600'),
(2556, '1', 1569, 2, 2, '2000'),
(2557, '1', 1570, 3, 2, '5900'),
(2558, '1', 1570, 10, 1, '2100'),
(2559, '2', 1571, 1, 2, '15800'),
(2560, '1', 1572, 38, 1, '2500'),
(2561, '1', 1572, 44, 1, '2500'),
(2562, '2', 1572, 10, 2, '4200'),
(2563, '1', 1572, 24, 2, '2000'),
(2564, '1', 1573, 2, 2, '2000'),
(2565, '1', 1574, 45, 1, '2500'),
(2566, '1', 1574, 1, 2, '7900'),
(2567, '2', 1574, 37, 1, '4000'),
(2568, '1', 1575, 11, 1, '2100'),
(2569, '2', 1576, 35, 1, '2800'),
(2570, '2', 1577, 46, 1, '5600'),
(2571, '2', 1578, 36, 1, '1200'),
(2572, '1', 1578, 45, 1, '2500'),
(2573, '1', 1579, 36, 1, '600'),
(2574, '1', 1579, 34, 1, '1400'),
(2575, '1', 1580, 2, 2, '2000'),
(2576, '2', 1581, 36, 1, '1200'),
(2577, '1', 1582, 47, 1, '2900'),
(2578, '1', 1583, 21, 1, '2000'),
(2579, '1', 1583, 1, 2, '7900'),
(2580, '1', 1583, 4, 1, '4800'),
(2581, '1', 1584, 8, 1, '4800'),
(2582, '2', 1585, 46, 1, '5600'),
(2583, '1', 1585, 2, 2, '2000'),
(2584, '1', 1586, 11, 1, '2100'),
(2585, '1', 1586, 34, 1, '1400'),
(2586, '1', 1587, 38, 1, '2500'),
(2587, '1', 1587, 31, 1, '2000'),
(2588, '1', 1587, 24, 2, '2000'),
(2589, '1', 1587, 8, 2, '4800'),
(2590, '2', 1588, 41, 1, '2600'),
(2591, '1', 1588, 10, 1, '2100'),
(2592, '1', 1588, 14, 1, '4000'),
(2593, '2', 1589, 33, 1, '2800'),
(2594, '1', 1589, 45, 1, '2500'),
(2595, '1', 1589, 43, 1, '1300'),
(2596, '1', 1590, 33, 1, '1400'),
(2597, '1', 1591, 37, 1, '2000'),
(2598, '2', 1591, 44, 1, '5000'),
(2599, '1', 1591, 36, 1, '600'),
(2600, '1', 1592, 35, 1, '1400'),
(2601, '1', 1592, 7, 2, '5000'),
(2602, '1', 1592, 27, 2, '2000'),
(2603, '1', 1593, 10, 1, '2100'),
(2604, '1', 1593, 11, 1, '2100'),
(2605, '1', 1593, 2, 2, '2000'),
(2606, '1', 1594, 48, 1, '4000'),
(2607, '1', 1594, 7, 2, '5000'),
(2608, '1', 1594, 45, 1, '2500'),
(2609, '1', 1594, 27, 2, '2000'),
(2610, '1', 1595, 33, 1, '1400'),
(2611, '1', 1595, 43, 1, '1300'),
(2612, '1', 1595, 40, 1, '2200'),
(2613, '1', 1596, 2, 2, '2000'),
(2614, '3', 1597, 35, 1, '4200'),
(2615, '1', 1598, 1, 2, '7900'),
(2616, '1', 1598, 33, 1, '1400'),
(2617, '2', 1599, 43, 1, '2600'),
(2618, '1', 1599, 48, 1, '4000'),
(2619, '1', 1599, 44, 1, '2500'),
(2620, '1', 1599, 22, 2, '2000'),
(2621, '1', 1600, 45, 1, '2500'),
(2622, '1', 1600, 20, 2, '2000'),
(2623, '1', 1600, 7, 2, '5000'),
(2624, '1', 1600, 37, 1, '2000'),
(2625, '1', 1601, 1, 2, '7900'),
(2626, '1', 1602, 14, 1, '4000'),
(2627, '1', 1602, 3, 2, '5900'),
(2628, '1', 1603, 1, 2, '7900'),
(2629, '1', 1603, 21, 1, '2000'),
(2630, '1', 1604, 8, 1, '4800'),
(2631, '1', 1604, 21, 1, '2000'),
(2632, '1', 1604, 3, 2, '5900'),
(2633, '1', 1605, 1, 2, '7900'),
(2634, '1', 1606, 38, 1, '2500'),
(2635, '1', 1606, 36, 1, '600'),
(2636, '1', 1607, 2, 2, '2000'),
(2637, '1', 1608, 37, 1, '2000'),
(2638, '1', 1608, 39, 1, '2200'),
(2639, '1', 1609, 40, 1, '2200'),
(2640, '1', 1609, 41, 1, '1300'),
(2641, '1', 1610, 3, 2, '5900'),
(2642, '1', 1611, 2, 2, '2000'),
(2643, '1', 1612, 34, 1, '1400'),
(2644, '1', 1612, 36, 1, '600'),
(2645, '1', 1613, 2, 2, '2000'),
(2646, '1', 1613, 7, 2, '5000'),
(2647, '1', 1613, 13, 1, '3000'),
(2648, '1', 1613, 5, 1, '2200'),
(2649, '1', 1614, 20, 1, '2000'),
(2650, '1', 1614, 9, 1, '2000'),
(2651, '1', 1615, 8, 2, '4800'),
(2652, '2', 1616, 33, 1, '2800'),
(2653, '1', 1617, 1, 2, '7900'),
(2654, '1', 1618, 44, 1, '2500'),
(2655, '1', 1618, 33, 1, '1400'),
(2656, '1', 1619, 1, 2, '7900'),
(2657, '1', 1620, 39, 1, '2200'),
(2658, '1', 1621, 2, 2, '2000'),
(2659, '1', 1621, 42, 1, '1300'),
(2660, '1', 1621, 35, 1, '1400'),
(2661, '1', 1622, 20, 1, '2000'),
(2662, '1', 1623, 2, 2, '2000'),
(2663, '1', 1624, 1, 2, '7900'),
(2664, '1', 1624, 2, 2, '2000'),
(2665, '1', 1625, 34, 1, '1400'),
(2666, '1', 1625, 36, 1, '600'),
(2667, '1', 1626, 2, 2, '2000'),
(2668, '1', 1626, 28, 2, '2000'),
(2669, '1', 1627, 45, 1, '2500'),
(2670, '1', 1627, 7, 2, '5000'),
(2671, '1', 1627, 34, 1, '1400'),
(2672, '1', 1627, 36, 1, '600'),
(2673, '1', 1628, 3, 2, '5900'),
(2674, '1', 1629, 10, 1, '2100'),
(2675, '1', 1630, 9, 1, '2000'),
(2676, '2', 1631, 34, 1, '2800'),
(2677, '2', 1632, 10, 2, '4200'),
(2678, '1', 1632, 31, 2, '2000'),
(2679, '1', 1633, 42, 1, '1300'),
(2680, '1', 1633, 43, 1, '1300'),
(2681, '1', 1633, 2, 2, '2000'),
(2682, '1', 1633, 22, 2, '2000'),
(2683, '1', 1634, 2, 2, '2000'),
(2684, '1', 1634, 18, 2, '2000'),
(2685, '1', 1635, 47, 1, '2900'),
(2686, '1', 1635, 2, 2, '2000'),
(2687, '1', 1636, 1, 2, '7900'),
(2688, '1', 1637, 1, 2, '7900'),
(2689, '1', 1638, 10, 1, '2100'),
(2690, '1', 1638, 3, 2, '5900'),
(2691, '1', 1639, 34, 1, '1400'),
(2692, '2', 1639, 36, 1, '1200'),
(2693, '1', 1639, 45, 1, '2500'),
(2694, '1', 1640, 1, 2, '7900'),
(2695, '1', 1641, 3, 2, '5900'),
(2696, '1', 1642, 3, 2, '5900'),
(2697, '1', 1643, 27, 1, '2000'),
(2698, '2', 1643, 1, 2, '15800'),
(2699, '2', 1644, 1, 2, '15800'),
(2700, '2', 1645, 41, 1, '2600'),
(2701, '1', 1646, 2, 2, '2000'),
(2702, '1', 1647, 4, 1, '4800'),
(2703, '1', 1647, 25, 1, '2000'),
(2704, '2', 1648, 34, 1, '2800'),
(2705, '1', 1649, 10, 1, '2100'),
(2706, '1', 1649, 22, 2, '2000'),
(2707, '1', 1649, 22, 1, '2000'),
(2708, '1', 1649, 2, 2, '2000'),
(2709, '1', 1650, 1, 2, '7900'),
(2710, '1', 1650, 2, 2, '2000'),
(2711, '1', 1651, 48, 1, '4000'),
(2712, '1', 1651, 5, 1, '2200'),
(2713, '1', 1651, 45, 1, '2500'),
(2714, '1', 1652, 34, 1, '1400'),
(2715, '1', 1652, 45, 1, '2500'),
(2716, '1', 1653, 35, 1, '1400'),
(2717, '1', 1653, 2, 2, '2000'),
(2718, '1', 1653, 41, 1, '1300'),
(2719, '1', 1654, 33, 1, '1400'),
(2720, '3', 1655, 33, 2, '4200'),
(2721, '2', 1656, 34, 2, '2800'),
(2722, '1', 1657, 34, 1, '1400'),
(2723, '1', 1657, 35, 1, '1400'),
(2724, '1', 1657, 45, 1, '2500'),
(2725, '1', 1658, 14, 1, '4000'),
(2726, '1', 1659, 39, 1, '2200'),
(2727, '2', 1659, 36, 1, '1200'),
(2728, '1', 1659, 45, 1, '2500'),
(2729, '1', 1660, 31, 1, '2000'),
(2730, '1', 1660, 4, 1, '4800'),
(2731, '1', 1661, 20, 1, '2000'),
(2732, '1', 1661, 11, 1, '2100'),
(2733, '1', 1662, 20, 1, '2000'),
(2734, '1', 1662, 7, 2, '5000'),
(2735, '1', 1662, 9, 1, '2000'),
(2736, '1', 1663, 1, 2, '7900'),
(2737, '1', 1664, 45, 1, '2500'),
(2738, '2', 1664, 36, 1, '1200'),
(2739, '1', 1664, 1, 2, '7900'),
(2740, '1', 1664, 37, 1, '2000'),
(2741, '1', 1665, 2, 2, '2000'),
(2742, '1', 1666, 14, 1, '4000'),
(2743, '1', 1666, 11, 1, '2100'),
(2744, '1', 1667, 2, 2, '2000'),
(2745, '1', 1668, 10, 1, '2100'),
(2746, '1', 1669, 34, 1, '1400'),
(2747, '1', 1669, 36, 1, '600'),
(2748, '2', 1670, 34, 1, '2800'),
(2749, '1', 1671, 8, 2, '4800'),
(2750, '2', 1671, 9, 2, '4000'),
(2751, '1', 1672, 43, 1, '1300'),
(2752, '1', 1672, 5, 1, '2200'),
(2753, '1', 1672, 9, 1, '2000'),
(2754, '2', 1673, 45, 1, '5000'),
(2755, '2', 1673, 34, 1, '2800'),
(2756, '2', 1674, 10, 1, '4200'),
(2757, '1', 1674, 3, 2, '5900'),
(2758, '1', 1674, 21, 1, '2000'),
(2759, '2', 1675, 7, 2, '10000'),
(2760, '1', 1675, 45, 1, '2500'),
(2761, '2', 1676, 34, 1, '2800'),
(2762, '1', 1676, 24, 2, '2000'),
(2763, '1', 1676, 45, 2, '2500'),
(2764, '1', 1677, 7, 2, '5000'),
(2765, '1', 1677, 22, 2, '2000'),
(2766, '1', 1678, 14, 1, '4000'),
(2767, '1', 1679, 14, 2, '4000'),
(2768, '1', 1680, 31, 1, '2000'),
(2769, '2', 1680, 9, 1, '4000'),
(2770, '1', 1681, 16, 1, '2000'),
(2771, '1', 1681, 18, 1, '2000'),
(2772, '1', 1682, 1, 2, '7900'),
(2773, '1', 1683, 9, 1, '2000'),
(2774, '1', 1683, 20, 1, '2000'),
(2775, '1', 1684, 1, 2, '7900'),
(2776, '1', 1685, 36, 1, '600'),
(2777, '1', 1685, 44, 1, '2500'),
(2778, '2', 1685, 10, 2, '4200'),
(2779, '1', 1685, 34, 1, '1400'),
(2780, '1', 1685, 22, 2, '2000'),
(2781, '1', 1686, 34, 1, '1400'),
(2782, '1', 1686, 25, 1, '2000'),
(2783, '1', 1687, 2, 2, '2000'),
(2784, '1', 1688, 2, 2, '2000'),
(2785, '1', 1689, 13, 1, '3000'),
(2786, '1', 1689, 2, 2, '2000'),
(2787, '1', 1690, 9, 1, '2000'),
(2788, '1', 1691, 12, 1, '2500'),
(2789, '5', 1692, 36, 1, '3000'),
(2790, '2', 1693, 34, 1, '2800'),
(2791, '3', 1694, 41, 1, '3900'),
(2792, '1', 1694, 28, 1, '2000'),
(2793, '1', 1695, 10, 1, '2100'),
(2794, '1', 1696, 19, 1, '2000'),
(2795, '1', 1696, 18, 2, '2000'),
(2796, '1', 1696, 2, 2, '2000'),
(2797, '1', 1697, 3, 2, '5900'),
(2798, '1', 1698, 45, 1, '2500'),
(2799, '1', 1698, 34, 1, '1400'),
(2800, '1', 1699, 2, 2, '2000'),
(2801, '1', 1700, 36, 1, '600'),
(2802, '1', 1700, 35, 1, '1400'),
(2803, '1', 1700, 45, 1, '2500'),
(2804, '1', 1701, 3, 2, '5900'),
(2805, '1', 1702, 22, 2, '2000'),
(2806, '1', 1703, 36, 1, '600'),
(2807, '1', 1703, 44, 1, '2500'),
(2808, '1', 1703, 34, 1, '1400'),
(2809, '1', 1704, 35, 1, '1400'),
(2810, '1', 1704, 43, 1, '1300'),
(2813, '2', 1706, 10, 1, '4200'),
(2814, '1', 1706, 3, 2, '5900'),
(2815, '1', 1706, 21, 1, '2000'),
(2816, '1', 1707, 14, 1, '4000'),
(2817, '2', 1708, 5, 1, '4400'),
(2818, '2', 1708, 45, 1, '5000'),
(2819, '2', 1709, 35, 1, '2800'),
(2820, '1', 1710, 22, 2, '2000'),
(2821, '1', 1711, 48, 1, '4000'),
(2822, '3', 1712, 33, 1, '4200'),
(2823, '1', 1713, 31, 1, '2000'),
(2824, '2', 1713, 9, 1, '4000'),
(2825, '1', 1714, 48, 1, '4000'),
(2826, '1', 1714, 41, 1, '1300'),
(2827, '1', 1714, 3, 2, '5900'),
(2828, '1', 1715, 1, 2, '7900'),
(2829, '1', 1716, 34, 1, '1400'),
(2830, '6', 1717, 36, 1, '3600'),
(2831, '1', 1717, 44, 1, '2500'),
(2832, '1', 1717, 3, 2, '5900'),
(2837, '1', 1719, 35, 1, '1400'),
(2838, '1', 1719, 41, 1, '1300'),
(2839, '1', 1720, 34, 1, '1400'),
(2840, '1', 1720, 36, 1, '600'),
(2841, '1', 1721, 1, 2, '7900'),
(2842, '1', 1722, 14, 1, '4000'),
(2843, '1', 1723, 2, 2, '2000'),
(2844, '1', 1724, 12, 1, '2500'),
(2845, '1', 1724, 22, 2, '2000'),
(2847, '1', 1726, 3, 2, '5900'),
(2848, '1', 1727, 1, 2, '7900'),
(2849, '1', 1727, 3, 2, '5900'),
(2850, '1', 1728, 1, 2, '7900'),
(2851, '1', 1729, 44, 1, '2500'),
(2852, '1', 1729, 45, 1, '2500'),
(2853, '1', 1729, 1, 2, '7900'),
(2854, '1', 1730, 1, 2, '7900'),
(2855, '1', 1731, 2, 2, '2000'),
(2856, '1', 1725, 1, 2, '7900'),
(2857, '2', 1732, 10, 1, '4200'),
(2858, '1', 1732, 1, 2, '7900'),
(2859, '1', 1732, 21, 1, '2000'),
(2860, '2', 1733, 33, 1, '2800'),
(2861, '1', 1733, 45, 1, '2500'),
(2862, '1', 1733, 1, 2, '7900'),
(2863, '2', 1734, 14, 1, '8000'),
(2864, '1', 1735, 1, 2, '7900'),
(2865, '1', 1736, 10, 1, '2100'),
(2866, '1', 1737, 1, 2, '7900'),
(2867, '1', 1738, 3, 2, '5900'),
(2868, '1', 1739, 35, 1, '1400'),
(2869, '1', 1740, 33, 1, '1400'),
(2870, '2', 1741, 14, 1, '8000'),
(2871, '2', 1741, 10, 1, '4200'),
(2872, '1', 1742, 1, 2, '7900'),
(2873, '1', 1743, 14, 1, '4000'),
(2874, '2', 1744, 36, 1, '1200'),
(2875, '1', 1744, 33, 1, '1400'),
(2876, '1', 1744, 45, 1, '2500'),
(2877, '1', 1745, 1, 2, '7900'),
(2878, '4', 1746, 36, 1, '2400'),
(2879, '1', 1747, 38, 1, '2500'),
(2880, '1', 1747, 17, 2, '5000'),
(2881, '1', 1747, 20, 2, '2000'),
(2882, '2', 1748, 35, 1, '2800'),
(2883, '1', 1749, 48, 1, '4000'),
(2884, '1', 1749, 25, 1, '2000'),
(2885, '1', 1750, 14, 1, '4000'),
(2886, '2', 1751, 36, 1, '1200'),
(2887, '1', 1752, 17, 1, '5000'),
(2888, '1', 1752, 7, 2, '5000'),
(2889, '2', 1753, 9, 1, '4000'),
(2890, '2', 1753, 11, 1, '4200'),
(2891, '2', 1753, 31, 1, '4000'),
(2892, '1', 1753, 1, 2, '7900'),
(2893, '1', 1754, 4, 1, '4800'),
(2894, '1', 1754, 7, 2, '5000'),
(2895, '1', 1755, 2, 2, '2000'),
(2896, '1', 1756, 45, 1, '2500'),
(2897, '2', 1756, 33, 1, '2800'),
(2898, '1', 1756, 23, 2, '2000'),
(2899, '1', 1756, 8, 2, '4800'),
(2900, '1', 1757, 14, 1, '4000'),
(2901, '1', 1758, 35, 1, '1400'),
(2902, '1', 1758, 42, 1, '1300'),
(2903, '1', 1759, 12, 1, '2500'),
(2904, '1', 1760, 14, 1, '4000'),
(2905, '1', 1761, 22, 2, '2000'),
(2906, '2', 1761, 14, 1, '8000'),
(2907, '1', 1762, 34, 1, '1400'),
(2908, '1', 1762, 29, 1, '2000'),
(2909, '1', 1762, 36, 1, '600'),
(2910, '2', 1763, 9, 1, '4000'),
(2911, '1', 1763, 23, 1, '2000'),
(2912, '1', 1764, 11, 1, '2100'),
(2913, '1', 1764, 13, 1, '3000'),
(2914, '1', 1765, 28, 2, '2000'),
(2915, '1', 1766, 22, 2, '2000'),
(2916, '1', 1766, 43, 1, '1300'),
(2917, '1', 1766, 33, 1, '1400'),
(2918, '2', 1767, 10, 1, '4200'),
(2919, '1', 1767, 3, 2, '5900'),
(2920, '1', 1767, 21, 1, '2000'),
(2921, '1', 1768, 1, 2, '7900'),
(2922, '1', 1769, 4, 1, '4800'),
(2923, '1', 1769, 1, 2, '7900'),
(2924, '1', 1769, 24, 1, '2000'),
(2925, '2', 1770, 11, 1, '4200'),
(2926, '1', 1771, 14, 1, '4000'),
(2927, '1', 1772, 2, 2, '2000'),
(2928, '1', 1773, 4, 2, '4800'),
(2929, '1', 1774, 1, 2, '7900'),
(2930, '3', 1775, 33, 1, '4200'),
(2931, '1', 1776, 10, 1, '2100'),
(2932, '1', 1776, 3, 2, '5900'),
(2933, '1', 1776, 21, 1, '2000'),
(2934, '2', 1777, 36, 1, '1200'),
(2935, '1', 1777, 33, 1, '1400'),
(2936, '1', 1777, 10, 2, '2100'),
(2937, '1', 1777, 23, 2, '2000'),
(2938, '1', 1777, 45, 1, '2500'),
(2939, '1', 1778, 9, 1, '2000'),
(2940, '1', 1778, 11, 1, '2100'),
(2941, '1', 1779, 17, 1, '5000'),
(2942, '1', 1779, 22, 1, '2000'),
(2943, '1', 1779, 1, 2, '7900'),
(2946, '2', 1781, 35, 1, '2800'),
(2947, '2', 1782, 46, 1, '5600'),
(2948, '1', 1783, 34, 1, '1400'),
(2949, '1', 1783, 36, 1, '600'),
(2950, '1', 1784, 14, 1, '4000'),
(2951, '1', 1785, 4, 2, '4800'),
(2952, '2', 1786, 37, 1, '4000'),
(2953, '1', 1786, 1, 2, '7900'),
(2954, '1', 1786, 45, 1, '2500'),
(2955, '2', 1787, 10, 1, '4200'),
(2956, '1', 1787, 21, 1, '2000'),
(2957, '1', 1787, 1, 2, '7900'),
(2958, '2', 1788, 9, 1, '4000'),
(2959, '1', 1788, 23, 1, '2000'),
(2960, '1', 1788, 17, 2, '5000'),
(2961, '1', 1789, 2, 2, '2000'),
(2962, '1', 1789, 43, 1, '1300'),
(2963, '1', 1789, 44, 1, '2500'),
(2964, '1', 1789, 37, 1, '2000'),
(2965, '1', 1789, 28, 2, '2000'),
(2966, '1', 1790, 4, 2, '4800'),
(2967, '2', 1790, 34, 1, '2800'),
(2968, '1', 1791, 17, 1, '5000'),
(2969, '1', 1791, 6, 2, '3200'),
(2970, '1', 1791, 25, 1, '2000'),
(2971, '2', 1792, 11, 1, '4200'),
(2972, '2', 1793, 45, 1, '5000'),
(2973, '1', 1793, 36, 1, '600'),
(2974, '1', 1793, 2, 2, '2000'),
(2975, '2', 1793, 35, 1, '2800'),
(2976, '1', 1794, 37, 1, '2000'),
(2977, '1', 1794, 20, 1, '2000'),
(2978, '1', 1795, 14, 1, '4000'),
(2979, '1', 1796, 1, 2, '7900'),
(2980, '1', 1797, 35, 1, '1400'),
(2982, '1', 1798, 1, 2, '7900'),
(2983, '1', 1798, 45, 1, '2500'),
(2984, '2', 1798, 33, 1, '2800'),
(2985, '1', 1799, 2, 2, '2000'),
(2986, '1', 1800, 14, 1, '4000'),
(2987, '1', 1801, 22, 1, '2000'),
(2988, '1', 1801, 7, 1, '5000'),
(2989, '1', 1801, 22, 2, '2000'),
(2990, '1', 1802, 21, 2, '2000'),
(2991, '1', 1802, 12, 1, '2500'),
(2992, '1', 1803, 15, 1, '3000'),
(2993, '1', 1804, 2, 2, '2000'),
(2994, '1', 1805, 48, 1, '4000'),
(2995, '1', 1805, 3, 2, '5900'),
(2996, '1', 1806, 8, 1, '4800'),
(2997, '2', 1807, 9, 1, '4000'),
(2998, '1', 1807, 23, 1, '2000'),
(2999, '2', 1808, 35, 1, '2800'),
(3000, '1', 1808, 46, 1, '2800'),
(3001, '1', 1809, 34, 1, '1400'),
(3002, '1', 1809, 33, 1, '1400'),
(3003, '1', 1809, 23, 1, '2000'),
(3004, '1', 1810, 10, 1, '2100'),
(3005, '1', 1810, 21, 1, '2000'),
(3006, '1', 1810, 3, 2, '5900'),
(3007, '3', 1811, 33, 1, '4200'),
(3008, '1', 1812, 43, 1, '1300'),
(3009, '1', 1812, 33, 1, '1400'),
(3010, '1', 1813, 28, 1, '2000'),
(3011, '1', 1813, 2, 2, '2000'),
(3012, '2', 1813, 33, 1, '2800'),
(3013, '1', 1814, 1, 2, '7900'),
(3014, '1', 1815, 3, 2, '5900'),
(3015, '1', 1815, 10, 1, '2100'),
(3016, '1', 1815, 21, 1, '2000'),
(3017, '1', 1816, 2, 2, '2000'),
(3018, '1', 1817, 35, 1, '1400'),
(3019, '1', 1817, 42, 1, '1300'),
(3020, '1', 1818, 20, 1, '2000'),
(3022, '1', 1819, 33, 1, '1400'),
(3023, '1', 1820, 40, 1, '2200'),
(3024, '1', 1821, 4, 2, '4800'),
(3025, '2', 1821, 34, 1, '2800'),
(3026, '2', 1822, 14, 1, '8000'),
(3027, '1', 1822, 2, 2, '2000'),
(3028, '1', 1822, 22, 2, '2000'),
(3029, '1', 1823, 1, 2, '7900'),
(3030, '4', 1824, 36, 1, '2400'),
(3031, '1', 1825, 44, 1, '2500'),
(3032, '1', 1825, 3, 2, '5900'),
(3033, '2', 1825, 36, 1, '1200'),
(3034, '2', 1826, 36, 1, '1200'),
(3035, '1', 1827, 34, 1, '1400'),
(3036, '1', 1827, 45, 1, '2500'),
(3037, '1', 1827, 36, 1, '600'),
(3038, '3', 1828, 35, 1, '4200'),
(3039, '1', 1829, 3, 2, '5900'),
(3040, '1', 1830, 17, 1, '5000'),
(3041, '1', 1830, 7, 2, '5000'),
(3042, '1', 1831, 21, 1, '2000'),
(3043, '1', 1831, 3, 2, '5900'),
(3044, '1', 1831, 10, 1, '2100'),
(3045, '1', 1832, 12, 1, '2500'),
(3046, '1', 1833, 3, 2, '5900'),
(3047, '1', 1833, 21, 1, '2000'),
(3048, '2', 1833, 10, 1, '4200'),
(3049, '1', 1834, 13, 1, '3000'),
(3050, '1', 1835, 11, 1, '2100'),
(3051, '1', 1835, 9, 1, '2000'),
(3052, '1', 1835, 21, 1, '2000'),
(3053, '1', 1835, 1, 2, '7900'),
(3054, '1', 1836, 3, 2, '5900'),
(3055, '1', 1837, 39, 1, '2200'),
(3056, '1', 1838, 33, 1, '1400'),
(3057, '1', 1839, 3, 2, '5900'),
(3058, '1', 1839, 10, 1, '2100'),
(3059, '1', 1839, 21, 1, '2000'),
(3060, '1', 1840, 1, 2, '7900'),
(3061, '1', 1841, 3, 2, '5900'),
(3062, '1', 1842, 1, 2, '7900'),
(3063, '1', 1843, 1, 2, '7900'),
(3064, '1', 1843, 2, 2, '2000'),
(3065, '1', 1844, 3, 2, '5900'),
(3066, '1', 1845, 1, 2, '7900'),
(3067, '1', 1846, 22, 1, '2000'),
(3068, '1', 1846, 7, 1, '5000'),
(3069, '1', 1846, 22, 2, '2000'),
(3070, '1', 1847, 47, 1, '2900'),
(3071, '1', 1847, 21, 2, '2000'),
(3072, '1', 1847, 7, 2, '5000'),
(3073, '1', 1848, 13, 1, '3000'),
(3074, '1', 1849, 13, 1, '3000'),
(3075, '1', 1850, 1, 2, '7900'),
(3076, '1', 1850, 22, 2, '2000'),
(3077, '1', 1851, 14, 1, '4000'),
(3078, '1', 1852, 1, 2, '7900'),
(3079, '4', 1853, 1, 2, '31600'),
(3080, '3', 1854, 4, 2, '14400'),
(3081, '1', 1855, 35, 1, '1400'),
(3082, '1', 1855, 43, 1, '1300'),
(3083, '1', 1856, 1, 2, '7900'),
(3084, '1', 1857, 33, 1, '1400'),
(3085, '1', 1858, 40, 1, '2200'),
(3086, '1', 1858, 1, 2, '7900'),
(3087, '2', 1859, 10, 2, '4200'),
(3088, '1', 1859, 23, 2, '2000'),
(3089, '1', 1860, 14, 1, '4000'),
(3090, '1', 1861, 1, 2, '7900'),
(3091, '2', 1862, 22, 2, '4000'),
(3092, '2', 1862, 2, 2, '4000'),
(3093, '1', 1863, 38, 1, '2500'),
(3094, '1', 1864, 34, 1, '1400'),
(3095, '1', 1864, 36, 1, '600'),
(3096, '1', 1865, 8, 2, '4800'),
(3097, '1', 1865, 14, 1, '4000'),
(3098, '1', 1865, 20, 2, '2000'),
(3099, '1', 1866, 34, 1, '1400'),
(3100, '1', 1866, 45, 1, '2500'),
(3101, '1', 1866, 3, 2, '5900'),
(3102, '1', 1867, 10, 1, '2100'),
(3103, '1', 1867, 21, 1, '2000'),
(3104, '1', 1867, 3, 2, '5900'),
(3105, '1', 1868, 22, 2, '2000'),
(3106, '1', 1869, 3, 2, '5900'),
(3107, '1', 1870, 2, 2, '2000'),
(3108, '1', 1871, 37, 1, '2000'),
(3109, '1', 1872, 1, 2, '7900'),
(3110, '1', 1873, 17, 1, '5000'),
(3111, '1', 1873, 1, 2, '7900'),
(3112, '1', 1873, 31, 1, '2000'),
(3113, '1', 1874, 20, 1, '2000'),
(3114, '1', 1875, 48, 1, '4000'),
(3115, '1', 1876, 2, 2, '2000'),
(3116, '1', 1876, 22, 2, '2000'),
(3117, '1', 1876, 14, 1, '4000'),
(3118, '1', 1877, 2, 2, '2000'),
(3119, '1', 1878, 3, 2, '5900'),
(3120, '1', 1879, 3, 2, '5900'),
(3121, '1', 1879, 22, 1, '2000'),
(3122, '1', 1879, 7, 1, '5000'),
(3123, '1', 1880, 33, 1, '1400'),
(3124, '3', 1881, 36, 1, '1800'),
(3125, '1', 1881, 45, 1, '2500'),
(3126, '1', 1881, 23, 2, '2000'),
(3127, '2', 1881, 10, 2, '4200'),
(3128, '1', 1882, 34, 1, '1400'),
(3129, '1', 1882, 36, 1, '600'),
(3130, '1', 1883, 17, 1, '5000'),
(3131, '1', 1883, 20, 1, '2000'),
(3132, '1', 1883, 3, 2, '5900'),
(3133, '1', 1884, 8, 2, '4800'),
(3134, '1', 1884, 25, 2, '2000'),
(3135, '1', 1884, 41, 1, '1300'),
(3136, '1', 1885, 45, 1, '2500'),
(3137, '1', 1885, 7, 2, '5000'),
(3138, '1', 1885, 36, 1, '600'),
(3139, '1', 1886, 14, 2, '4000'),
(3140, '5', 1887, 43, 1, '6500'),
(3141, '1', 1887, 23, 1, '2000'),
(3142, '1', 1887, 35, 1, '1400'),
(3143, '1', 1887, 10, 1, '2100'),
(3144, '2', 1888, 33, 1, '2800'),
(3145, '1', 1889, 34, 1, '1400'),
(3146, '1', 1889, 41, 1, '1300'),
(3147, '4', 1890, 36, 1, '2400'),
(3148, '1', 1890, 45, 1, '2500'),
(3149, '1', 1890, 1, 2, '7900'),
(3150, '2', 1891, 31, 1, '4000'),
(3151, '2', 1891, 43, 1, '2600'),
(3152, '1', 1891, 1, 2, '7900'),
(3153, '1', 1891, 33, 1, '1400'),
(3154, '1', 1892, 2, 2, '2000'),
(3155, '1', 1893, 45, 1, '2500'),
(3156, '1', 1893, 36, 1, '600'),
(3157, '1', 1893, 37, 1, '2000'),
(3158, '1', 1893, 8, 2, '4800'),
(3159, '1', 1894, 2, 2, '2000'),
(3160, '1', 1895, 17, 1, '5000'),
(3161, '1', 1895, 31, 1, '2000'),
(3162, '1', 1896, 10, 1, '2100'),
(3163, '3', 1897, 35, 1, '4200'),
(3164, '1', 1898, 33, 1, '1400'),
(3165, '1', 1899, 37, 1, '2000'),
(3166, '1', 1899, 1, 2, '7900'),
(3167, '1', 1899, 45, 1, '2500'),
(3168, '1', 1900, 37, 1, '2000'),
(3169, '1', 1900, 44, 1, '2500'),
(3170, '1', 1900, 22, 2, '2000'),
(3171, '1', 1900, 8, 2, '4800'),
(3172, '1', 1901, 1, 2, '7900'),
(3173, '1', 1902, 8, 1, '4800'),
(3174, '1', 1903, 3, 2, '5900'),
(3175, '1', 1904, 1, 2, '7900'),
(3176, '1', 1904, 35, 1, '1400'),
(3177, '1', 1904, 42, 1, '1300'),
(3178, '1', 1905, 8, 1, '4800'),
(3179, '1', 1905, 18, 1, '2000'),
(3180, '1', 1906, 34, 1, '1400'),
(3181, '1', 1906, 41, 1, '1300'),
(3182, '1', 1907, 34, 1, '1400'),
(3183, '1', 1907, 41, 1, '1300'),
(3184, '1', 1907, 7, 2, '5000'),
(3185, '1', 1908, 4, 1, '4800'),
(3186, '1', 1909, 45, 1, '2500'),
(3187, '1', 1909, 36, 1, '600'),
(3188, '1', 1909, 33, 1, '1400'),
(3189, '1', 1908, 11, 1, '2100'),
(3190, '2', 1910, 4, 2, '9600'),
(3191, '1', 1911, 12, 1, '2500'),
(3192, '1', 1911, 3, 2, '5900'),
(3193, '1', 1912, 48, 1, '4000'),
(3194, '1', 1912, 45, 1, '2500'),
(3195, '1', 1912, 1, 2, '7900'),
(3196, '1', 1913, 2, 2, '2000'),
(3197, '1', 1914, 37, 1, '2000'),
(3198, '1', 1914, 1, 2, '7900'),
(3199, '1', 1914, 45, 1, '2500'),
(3200, '1', 1915, 1, 2, '7900'),
(3201, '1', 1915, 10, 1, '2100'),
(3202, '1', 1915, 23, 1, '2000'),
(3203, '1', 1916, 14, 1, '4000'),
(3204, '1', 1917, 10, 1, '2100'),
(3205, '1', 1918, 1, 2, '7900'),
(3206, '1', 1919, 1, 2, '7900'),
(3207, '1', 1920, 1, 2, '7900'),
(3208, '2', 1921, 10, 1, '4200'),
(3209, '1', 1921, 21, 1, '2000'),
(3210, '1', 1921, 3, 2, '5900'),
(3211, '4', 1922, 36, 1, '2400'),
(3212, '1', 1922, 3, 2, '5900'),
(3213, '2', 1923, 9, 1, '4000'),
(3214, '1', 1923, 21, 1, '2000'),
(3215, '1', 1924, 2, 2, '2000'),
(3216, '1', 1925, 3, 2, '5900'),
(3217, '1', 1926, 7, 2, '5000'),
(3218, '1', 1926, 25, 2, '2000'),
(3219, '1', 1927, 37, 1, '2000'),
(3220, '1', 1928, 33, 1, '1400'),
(3221, '1', 1928, 45, 1, '2500'),
(3222, '1', 1928, 36, 1, '600'),
(3223, '1', 1929, 10, 1, '2100'),
(3224, '1', 1930, 1, 2, '7900'),
(3225, '2', 1930, 36, 1, '1200'),
(3226, '1', 1930, 45, 1, '2500'),
(3227, '1', 1931, 45, 1, '2500'),
(3228, '1', 1931, 15, 2, '3000'),
(3229, '2', 1932, 35, 1, '2800'),
(3230, '1', 1932, 44, 1, '2500'),
(3231, '1', 1933, 3, 2, '5900'),
(3232, '1', 1933, 45, 1, '2500'),
(3233, '2', 1933, 33, 1, '2800'),
(3234, '3', 1934, 35, 1, '4200'),
(3235, '3', 1935, 35, 1, '4200'),
(3236, '2', 1936, 35, 1, '2800'),
(3237, '1', 1936, 2, 2, '2000'),
(3238, '1', 1936, 19, 2, '2000'),
(3239, '1', 1937, 3, 2, '5900'),
(3240, '2', 1937, 28, 2, '4000'),
(3241, '1', 1937, 7, 2, '5000'),
(3242, '1', 1937, 8, 2, '4800'),
(3243, '1', 1938, 33, 1, '1400'),
(3244, '1', 1939, 1, 2, '7900'),
(3245, '1', 1940, 3, 2, '5900'),
(3246, '1', 1940, 6, 1, '3200'),
(3247, '1', 1941, 9, 1, '2000'),
(3248, '1', 1942, 29, 1, '2000'),
(3249, '1', 1942, 5, 1, '2200'),
(3250, '1', 1942, 3, 2, '5900'),
(3251, '1', 1942, 37, 1, '2000'),
(3252, '1', 1943, 22, 1, '2000'),
(3253, '1', 1943, 22, 2, '2000'),
(3254, '1', 1943, 8, 1, '4800'),
(3255, '2', 1944, 36, 1, '1200'),
(3256, '1', 1944, 44, 1, '2500'),
(3257, '1', 1945, 21, 1, '2000'),
(3258, '2', 1945, 9, 1, '4000'),
(3259, '1', 1946, 43, 1, '1300'),
(3260, '1', 1946, 45, 1, '2500'),
(3261, '1', 1947, 48, 1, '4000'),
(3262, '1', 1948, 14, 1, '4000'),
(3263, '1', 1949, 33, 1, '1400'),
(3264, '1', 1949, 36, 1, '600'),
(3265, '3', 1950, 35, 1, '4200'),
(3266, '1', 1951, 1, 2, '7900'),
(3267, '1', 1952, 13, 1, '3000'),
(3268, '1', 1952, 22, 2, '2000'),
(3269, '1', 1953, 13, 1, '3000'),
(3270, '1', 1953, 2, 2, '2000'),
(3271, '2', 1954, 39, 1, '4400'),
(3272, '2', 1955, 10, 1, '4200'),
(3273, '1', 1955, 21, 1, '2000'),
(3274, '1', 1955, 3, 2, '5900'),
(3275, '1', 1956, 10, 1, '2100'),
(3276, '1', 1956, 31, 1, '2000'),
(3277, '1', 1957, 45, 1, '2500'),
(3278, '1', 1957, 34, 1, '1400'),
(3279, '1', 1957, 7, 2, '5000'),
(3280, '1', 1958, 14, 1, '4000'),
(3281, '1', 1959, 8, 1, '4800'),
(3282, '1', 1959, 21, 1, '2000'),
(3283, '1', 1959, 3, 2, '5900'),
(3284, '1', 1960, 4, 2, '4800'),
(3285, '1', 1960, 15, 1, '3000'),
(3286, '1', 1961, 36, 1, '600'),
(3287, '1', 1961, 38, 1, '2500'),
(3288, '1', 1961, 45, 1, '2500'),
(3289, '1', 1961, 10, 2, '2100'),
(3290, '1', 1961, 23, 2, '2000'),
(3291, '1', 1962, 3, 2, '5900'),
(3292, '1', 1962, 24, 1, '2000'),
(3293, '1', 1962, 7, 1, '5000'),
(3294, '1', 1962, 9, 1, '2000'),
(3295, '1', 1963, 1, 2, '7900'),
(3296, '1', 1964, 36, 1, '600'),
(3297, '1', 1964, 33, 1, '1400'),
(3298, '1', 1965, 13, 1, '3000'),
(3299, '1', 1965, 1, 2, '7900'),
(3300, '1', 1966, 37, 1, '2000'),
(3301, '1', 1966, 25, 1, '2000'),
(3302, '1', 1967, 45, 1, '2500'),
(3303, '3', 1967, 39, 1, '6600'),
(3304, '1', 1968, 14, 1, '4000'),
(3305, '1', 1969, 35, 1, '1400'),
(3306, '1', 1970, 33, 1, '1400'),
(3307, '1', 1971, 48, 1, '4000'),
(3308, '1', 1971, 2, 2, '2000'),
(3309, '1', 1971, 44, 1, '2500'),
(3310, '1', 1971, 21, 2, '2000'),
(3311, '2', 1972, 5, 1, '4400'),
(3312, '2', 1972, 31, 1, '4000'),
(3313, '1', 1973, 14, 1, '4000'),
(3314, '1', 1973, 28, 2, '2000'),
(3315, '1', 1974, 1, 2, '7900'),
(3316, '1', 1975, 8, 2, '4800'),
(3317, '1', 1975, 25, 2, '2000'),
(3318, '1', 1976, 14, 1, '4000'),
(3319, '1', 1977, 20, 1, '2000'),
(3320, '1', 1978, 44, 1, '2500'),
(3321, '1', 1978, 3, 2, '5900'),
(3322, '2', 1978, 38, 1, '5000'),
(3323, '1', 1979, 34, 1, '1400'),
(3324, '2', 1979, 36, 1, '1200');
INSERT INTO `lineas_pedido` (`idLineas_pedido`, `cantidad`, `idPedido`, `idProducto`, `idMomento`, `precio`) VALUES
(3325, '1', 1979, 45, 1, '2500'),
(3326, '1', 1979, 13, 2, '3000'),
(3327, '1', 1980, 35, 1, '1400'),
(3328, '1', 1980, 41, 1, '1300'),
(3329, '1', 1980, 1, 2, '7900'),
(3330, '1', 1980, 45, 1, '2500'),
(3331, '1', 1981, 1, 2, '7900'),
(3332, '1', 1982, 33, 1, '1400'),
(3333, '1', 1982, 36, 1, '600'),
(3334, '1', 1983, 2, 2, '2000'),
(3335, '1', 1983, 14, 1, '4000'),
(3336, '2', 1984, 10, 1, '4200'),
(3337, '1', 1984, 3, 2, '5900'),
(3338, '1', 1984, 24, 1, '2000'),
(3339, '1', 1985, 25, 1, '2000'),
(3340, '1', 1986, 14, 1, '4000'),
(3341, '1', 1986, 10, 2, '2100'),
(3342, '1', 1986, 21, 2, '2000'),
(3343, '1', 1987, 8, 2, '4800'),
(3344, '1', 1988, 12, 1, '2500'),
(3345, '1', 1989, 8, 2, '4800'),
(3346, '1', 1989, 25, 2, '2000'),
(3347, '1', 1990, 1, 2, '7900'),
(3348, '1', 1991, 45, 1, '2500'),
(3349, '1', 1992, 14, 1, '4000'),
(3350, '1', 1992, 9, 1, '2000'),
(3351, '1', 1992, 31, 1, '2000'),
(3352, '1', 1992, 23, 1, '2000'),
(3353, '1', 1992, 1, 2, '7900'),
(3354, '2', 1992, 11, 1, '4200'),
(3355, '1', 1993, 2, 2, '2000'),
(3356, '1', 1994, 14, 1, '4000'),
(3357, '1', 1994, 1, 2, '7900'),
(3358, '2', 1995, 21, 1, '4000'),
(3359, '2', 1996, 10, 1, '4200'),
(3360, '1', 1996, 21, 1, '2000'),
(3361, '1', 1996, 1, 2, '7900'),
(3362, '2', 1997, 4, 2, '9600'),
(3363, '1', 1998, 1, 2, '7900'),
(3364, '1', 1999, 20, 1, '2000'),
(3365, '1', 1999, 3, 2, '5900'),
(3366, '1', 1999, 11, 1, '2100'),
(3367, '2', 2000, 35, 1, '2800'),
(3368, '1', 2001, 3, 2, '5900'),
(3369, '1', 2001, 44, 1, '2500'),
(3370, '1', 2001, 41, 1, '1300'),
(3371, '1', 2002, 3, 2, '5900'),
(3372, '1', 2003, 1, 2, '7900'),
(3373, '1', 2003, 38, 1, '2500'),
(3374, '1', 2004, 1, 2, '7900'),
(3375, '1', 2005, 1, 2, '7900'),
(3376, '1', 2006, 37, 1, '2000'),
(3377, '2', 2007, 10, 2, '4200'),
(3378, '1', 2007, 18, 2, '2000'),
(3379, '1', 2008, 37, 1, '2000'),
(3380, '1', 2008, 45, 1, '2500'),
(3381, '1', 2009, 3, 2, '5900'),
(3382, '1', 2010, 3, 2, '5900'),
(3383, '1', 2011, 1, 2, '7900'),
(3384, '1', 2011, 43, 1, '1300'),
(3385, '1', 2012, 41, 1, '1300'),
(3386, '1', 2012, 44, 1, '2500'),
(3387, '1', 2013, 1, 2, '7900'),
(3388, '1', 2014, 33, 1, '1400'),
(3389, '1', 2014, 36, 1, '600'),
(3390, '1', 2014, 45, 1, '2500'),
(3391, '1', 2015, 37, 1, '2000'),
(3392, '1', 2015, 43, 1, '1300'),
(3393, '1', 2016, 4, 1, '4800'),
(3394, '1', 2016, 13, 1, '3000'),
(3395, '1', 2017, 17, 2, '5000'),
(3396, '1', 2018, 1, 2, '7900'),
(3397, '1', 2019, 33, 1, '1400'),
(3398, '1', 2019, 45, 1, '2500'),
(3399, '1', 2019, 1, 2, '7900'),
(3400, '2', 2020, 36, 1, '1200'),
(3401, '1', 2021, 20, 1, '2000'),
(3402, '1', 2021, 27, 1, '2000'),
(3403, '1', 2022, 22, 1, '2000'),
(3404, '1', 2022, 3, 2, '5900'),
(3405, '1', 2022, 4, 1, '4800'),
(3406, '1', 2020, 1, 2, '7900'),
(3407, '2', 2023, 34, 1, '2800'),
(3408, '1', 2024, 1, 2, '7900'),
(3409, '1', 2025, 20, 1, '2000'),
(3410, '2', 2026, 33, 1, '2800'),
(3411, '1', 2027, 7, 1, '5000'),
(3412, '1', 2027, 23, 1, '2000'),
(3413, '1', 2028, 3, 2, '5900'),
(3414, '1', 2028, 21, 1, '2000'),
(3415, '1', 2028, 10, 1, '2100'),
(3416, '1', 2029, 8, 2, '4800'),
(3417, '1', 2030, 14, 1, '4000'),
(3418, '1', 2031, 35, 1, '1400'),
(3419, '1', 2031, 42, 1, '1300'),
(3420, '1', 2031, 45, 1, '2500'),
(3421, '1', 2032, 1, 2, '7900'),
(3422, '1', 2033, 2, 2, '2000'),
(3423, '1', 2034, 1, 2, '7900'),
(3424, '1', 2035, 9, 1, '2000'),
(3425, '1', 2035, 21, 1, '2000'),
(3426, '1', 2036, 10, 1, '2100'),
(3427, '1', 2036, 31, 1, '2000'),
(3428, '2', 2037, 14, 1, '8000'),
(3429, '1', 2038, 37, 1, '2000'),
(3430, '1', 2038, 45, 1, '2500'),
(3431, '1', 2038, 1, 2, '7900'),
(3432, '1', 2039, 1, 2, '7900'),
(3433, '1', 2040, 1, 2, '7900'),
(3434, '1', 2041, 12, 1, '2500'),
(3435, '2', 2042, 33, 1, '2800'),
(3436, '1', 2043, 43, 1, '1300'),
(3437, '1', 2044, 14, 1, '4000'),
(3438, '1', 2044, 28, 2, '2000'),
(3439, '1', 2045, 37, 1, '2000'),
(3440, '1', 2045, 8, 2, '4800'),
(3441, '2', 2046, 34, 1, '2800'),
(3442, '1', 2047, 48, 1, '4000'),
(3443, '1', 2048, 2, 2, '2000'),
(3444, '1', 2049, 13, 1, '3000'),
(3445, '1', 2050, 31, 1, '2000'),
(3446, '2', 2050, 10, 1, '4200'),
(3447, '1', 2051, 10, 1, '2100'),
(3448, '1', 2051, 24, 1, '2000'),
(3449, '1', 2051, 1, 2, '7900'),
(3450, '1', 2052, 1, 2, '7900'),
(3451, '1', 2053, 45, 1, '2500'),
(3452, '1', 2053, 24, 2, '2000'),
(3453, '2', 2053, 36, 1, '1200'),
(3454, '1', 2054, 14, 1, '4000'),
(3455, '1', 2055, 2, 2, '2000'),
(3456, '1', 2056, 2, 2, '2000'),
(3457, '1', 2057, 12, 1, '2500'),
(3458, '1', 2058, 4, 1, '4800'),
(3459, '1', 2058, 14, 1, '4000'),
(3460, '1', 2058, 23, 1, '2000'),
(3461, '1', 2059, 1, 2, '7900'),
(3462, '2', 2060, 33, 1, '2800'),
(3463, '1', 2061, 1, 2, '7900'),
(3464, '2', 2062, 36, 1, '1200'),
(3465, '1', 2062, 45, 1, '2500'),
(3466, '1', 2062, 1, 2, '7900'),
(3467, '1', 2063, 1, 2, '7900'),
(3468, '2', 2064, 41, 1, '2600'),
(3469, '1', 2065, 2, 2, '2000'),
(3470, '1', 2066, 1, 2, '7900'),
(3471, '1', 2067, 1, 2, '7900'),
(3472, '1', 2068, 44, 1, '2500'),
(3473, '1', 2068, 35, 1, '1400'),
(3474, '1', 2068, 20, 1, '2000'),
(3475, '1', 2069, 34, 1, '1400'),
(3476, '1', 2069, 41, 1, '1300'),
(3477, '1', 2069, 45, 1, '2500'),
(3478, '1', 2070, 10, 1, '2100'),
(3479, '1', 2070, 1, 2, '7900'),
(3480, '1', 2070, 31, 1, '2000'),
(3481, '1', 2071, 48, 1, '4000'),
(3482, '1', 2071, 45, 1, '2500'),
(3483, '3', 2072, 43, 1, '3900'),
(3484, '2', 2072, 24, 1, '4000'),
(3485, '1', 2072, 2, 2, '2000'),
(3486, '1', 2072, 22, 2, '2000'),
(3487, '2', 2073, 10, 1, '4200'),
(3488, '1', 2073, 31, 1, '2000'),
(3489, '1', 2073, 1, 2, '7900'),
(3490, '1', 2074, 3, 2, '5900'),
(3491, '1', 2075, 48, 1, '4000'),
(3492, '1', 2075, 8, 2, '4800'),
(3493, '1', 2076, 2, 2, '2000'),
(3494, '1', 2077, 12, 1, '2500'),
(3495, '1', 2078, 14, 1, '4000'),
(3496, '1', 2078, 23, 1, '2000'),
(3497, '2', 2078, 41, 1, '2600'),
(3498, '1', 2079, 21, 2, '2000'),
(3499, '1', 2079, 8, 2, '4800'),
(3500, '1', 2080, 40, 1, '2200'),
(3501, '1', 2079, 20, 1, '2000'),
(3502, '1', 2081, 47, 1, '2900'),
(3503, '1', 2081, 45, 1, '2500'),
(3504, '2', 2082, 37, 1, '4000'),
(3505, '1', 2082, 45, 1, '2500'),
(3506, '1', 2083, 20, 1, '2000'),
(3507, '1', 2084, 1, 2, '7900'),
(3508, '1', 2085, 1, 2, '7900'),
(3509, '2', 2086, 36, 1, '1200'),
(3510, '1', 2087, 2, 2, '2000'),
(3511, '2', 2088, 37, 1, '4000'),
(3512, '1', 2088, 20, 1, '2000'),
(3513, '1', 2089, 40, 1, '2200'),
(3514, '1', 2089, 45, 1, '2500'),
(3515, '1', 2089, 7, 2, '5000'),
(3516, '1', 2090, 12, 1, '2500'),
(3517, '1', 2091, 33, 1, '1400'),
(3518, '1', 2091, 43, 1, '1300'),
(3519, '1', 2092, 37, 1, '2000'),
(3520, '2', 2093, 11, 2, '4200'),
(3521, '1', 2094, 10, 1, '2100'),
(3522, '1', 2095, 2, 2, '2000'),
(3523, '2', 2096, 41, 1, '2600'),
(3524, '2', 2096, 22, 1, '4000'),
(3525, '1', 2097, 2, 2, '2000'),
(3526, '1', 2098, 18, 1, '2000'),
(3527, '1', 2098, 10, 1, '2100'),
(3528, '1', 2099, 48, 1, '4000'),
(3529, '1', 2099, 7, 2, '5000'),
(3530, '2', 2100, 34, 1, '2800'),
(3531, '1', 2101, 3, 2, '5900'),
(3532, '1', 2102, 3, 2, '5900'),
(3533, '1', 2103, 33, 1, '1400'),
(3534, '2', 2103, 36, 1, '1200'),
(3535, '1', 2103, 45, 1, '2500'),
(3536, '1', 2103, 12, 2, '2500'),
(3537, '1', 2104, 2, 2, '2000'),
(3538, '1', 2105, 20, 1, '2000'),
(3539, '1', 2105, 43, 1, '1300'),
(3540, '1', 2106, 43, 1, '1300'),
(3541, '1', 2106, 37, 1, '2000'),
(3542, '2', 2107, 41, 1, '2600'),
(3543, '2', 2107, 10, 1, '4200'),
(3544, '1', 2107, 31, 1, '2000'),
(3545, '1', 2107, 33, 1, '1400'),
(3546, '1', 2108, 14, 1, '4000'),
(3547, '1', 2108, 43, 1, '1300'),
(3548, '1', 2109, 4, 1, '4800'),
(3549, '1', 2109, 25, 1, '2000'),
(3550, '1', 2110, 10, 1, '2100'),
(3551, '1', 2110, 3, 2, '5900'),
(3552, '1', 2110, 21, 1, '2000'),
(3553, '1', 2111, 10, 1, '2100'),
(3554, '1', 2111, 31, 1, '2000'),
(3555, '1', 2112, 10, 2, '2100'),
(3556, '1', 2112, 21, 1, '2000'),
(3557, '4', 2113, 33, 1, '5600'),
(3558, '1', 2114, 3, 2, '5900'),
(3559, '2', 2114, 11, 1, '4200'),
(3560, '1', 2115, 33, 1, '1400'),
(3561, '1', 2116, 33, 1, '1400'),
(3562, '1', 2117, 47, 1, '2900'),
(3563, '1', 2118, 48, 1, '4000'),
(3564, '1', 2118, 3, 2, '5900'),
(3565, '1', 2119, 46, 1, '2800'),
(3566, '1', 2120, 3, 2, '5900'),
(3567, '2', 2121, 13, 1, '6000'),
(3568, '1', 2122, 12, 1, '2500'),
(3569, '1', 2123, 10, 1, '2100'),
(3570, '3', 2124, 35, 1, '4200'),
(3571, '1', 2124, 44, 1, '2500'),
(3572, '1', 2125, 5, 1, '2200'),
(3573, '1', 2125, 31, 1, '2000'),
(3574, '1', 2126, 17, 1, '5000'),
(3575, '1', 2126, 31, 1, '2000'),
(3576, '1', 2127, 40, 1, '2200'),
(3577, '1', 2127, 45, 1, '2500'),
(3578, '3', 2128, 34, 1, '4200'),
(3579, '1', 2129, 1, 2, '7900'),
(3580, '1', 2130, 45, 1, '2500'),
(3581, '1', 2130, 46, 1, '2800'),
(3582, '1', 2131, 34, 1, '1400'),
(3583, '1', 2131, 35, 1, '1400'),
(3584, '1', 2131, 8, 2, '4800'),
(3585, '1', 2131, 45, 1, '2500'),
(3586, '1', 2132, 20, 1, '2000'),
(3587, '1', 2133, 44, 1, '2500'),
(3588, '1', 2133, 24, 2, '2000'),
(3589, '1', 2133, 33, 1, '1400'),
(3590, '1', 2134, 12, 1, '2500'),
(3591, '1', 2135, 14, 1, '4000'),
(3592, '1', 2136, 1, 2, '7900'),
(3593, '1', 2137, 4, 1, '4800'),
(3594, '1', 2137, 1, 2, '7900'),
(3595, '1', 2138, 21, 1, '2000'),
(3596, '1', 2138, 16, 1, '2000'),
(3597, '2', 2139, 7, 1, '10000'),
(3598, '1', 2140, 13, 2, '3000'),
(3599, '1', 2141, 44, 1, '2500'),
(3600, '1', 2141, 7, 2, '5000'),
(3601, '1', 2142, 1, 2, '7900'),
(3602, '1', 2143, 31, 1, '2000'),
(3603, '1', 2143, 5, 1, '2200'),
(3604, '2', 2144, 33, 1, '2800'),
(3605, '1', 2144, 2, 2, '2000'),
(3606, '1', 2145, 1, 2, '7900'),
(3607, '1', 2145, 45, 1, '2500'),
(3608, '1', 2145, 37, 1, '2000'),
(3609, '1', 2146, 1, 2, '7900'),
(3610, '2', 2147, 28, 1, '4000'),
(3611, '1', 2148, 10, 1, '2100'),
(3612, '1', 2149, 2, 2, '2000'),
(3613, '1', 2150, 8, 1, '4800'),
(3614, '1', 2150, 3, 2, '5900'),
(3615, '1', 2151, 2, 2, '2000'),
(3616, '1', 2152, 47, 1, '2900'),
(3617, '1', 2152, 4, 2, '4800'),
(3618, '1', 2153, 34, 1, '1400'),
(3619, '1', 2154, 37, 1, '2000'),
(3620, '1', 2154, 35, 1, '1400'),
(3621, '1', 2154, 45, 1, '2500'),
(3622, '3', 2155, 41, 1, '3900'),
(3623, '1', 2155, 44, 1, '2500'),
(3624, '1', 2156, 37, 1, '2000'),
(3625, '1', 2156, 43, 1, '1300'),
(3626, '1', 2157, 12, 2, '2500'),
(3627, '1', 2158, 1, 2, '7900'),
(3628, '1', 2159, 37, 1, '2000'),
(3629, '1', 2159, 7, 2, '5000'),
(3630, '1', 2160, 17, 1, '5000'),
(3631, '1', 2161, 2, 2, '2000'),
(3632, '1', 2162, 41, 1, '1300'),
(3633, '1', 2162, 44, 1, '2500'),
(3634, '1', 2162, 1, 2, '7900'),
(3635, '1', 2162, 37, 1, '2000'),
(3636, '2', 2163, 37, 1, '4000'),
(3637, '1', 2164, 10, 1, '2100'),
(3638, '1', 2165, 36, 1, '600'),
(3639, '1', 2165, 34, 1, '1400'),
(3640, '2', 2165, 4, 2, '9600'),
(3641, '1', 2166, 21, 1, '2000'),
(3642, '1', 2166, 10, 1, '2100'),
(3643, '1', 2166, 3, 2, '5900'),
(3644, '1', 2167, 37, 1, '2000'),
(3645, '1', 2168, 8, 1, '4800'),
(3646, '1', 2169, 8, 2, '4800'),
(3647, '1', 2170, 4, 2, '4800'),
(3648, '2', 2158, 37, 1, '4000'),
(3649, '2', 2171, 37, 1, '4000'),
(3650, '1', 2171, 45, 1, '2500'),
(3651, '1', 2171, 1, 2, '7900'),
(3652, '1', 2172, 20, 1, '2000'),
(3653, '1', 2173, 1, 2, '7900'),
(3654, '1', 2174, 3, 2, '5900'),
(3655, '1', 2175, 2, 2, '2000'),
(3656, '1', 2176, 33, 1, '1400'),
(3657, '1', 2176, 36, 1, '600'),
(3658, '1', 2177, 23, 2, '2000'),
(3659, '1', 2177, 37, 1, '2000'),
(3660, '1', 2178, 7, 2, '5000'),
(3661, '1', 2179, 22, 2, '2000'),
(3662, '1', 2179, 7, 2, '5000'),
(3663, '1', 2180, 40, 1, '2200'),
(3664, '1', 2180, 1, 2, '7900'),
(3665, '1', 2181, 45, 1, '2500'),
(3666, '1', 2181, 41, 1, '1300'),
(3667, '1', 2181, 43, 1, '1300'),
(3668, '1', 2182, 33, 1, '1400'),
(3670, '4', 2184, 43, 1, '5200'),
(3671, '1', 2184, 14, 1, '4000'),
(3673, '1', 2185, 1, 2, '7900'),
(3674, '1', 2185, 14, 1, '4000'),
(3675, '1', 2186, 10, 1, '2100'),
(3676, '1', 2186, 3, 2, '5900'),
(3677, '1', 2187, 37, 1, '2000'),
(3678, '1', 2187, 45, 1, '2500'),
(3679, '1', 2188, 1, 2, '7900'),
(3680, '1', 2189, 44, 1, '2500'),
(3681, '1', 2190, 34, 1, '1400'),
(3682, '1', 2191, 3, 2, '5900'),
(3683, '1', 2191, 28, 1, '2000'),
(3684, '1', 2192, 48, 1, '4000'),
(3686, '1', 2194, 10, 1, '2100'),
(3687, '1', 2194, 31, 1, '2000'),
(3688, '1', 2195, 14, 1, '4000'),
(3689, '1', 2196, 7, 2, '5000'),
(3690, '1', 2197, 35, 1, '1400'),
(3691, '1', 2198, 2, 2, '2000'),
(3692, '1', 2198, 4, 2, '4800'),
(3693, '1', 2198, 46, 1, '2800'),
(3694, '3', 2199, 33, 1, '4200'),
(3695, '1', 2199, 40, 1, '2200'),
(3696, '1', 2200, 39, 1, '2200'),
(3697, '1', 2201, 10, 1, '2100'),
(3698, '1', 2202, 13, 1, '3000'),
(3699, '2', 2203, 34, 1, '2800'),
(3700, '1', 2204, 12, 1, '2500'),
(3701, '1', 2204, 1, 2, '7900'),
(3702, '2', 2205, 2, 2, '4000'),
(3703, '1', 2205, 47, 1, '2900'),
(3704, '1', 2205, 6, 2, '3200'),
(3705, '1', 2206, 8, 2, '4800'),
(3706, '1', 2207, 14, 1, '4000'),
(3707, '1', 2207, 20, 1, '2000'),
(3708, '1', 2208, 1, 2, '7900'),
(3709, '1', 2209, 1, 2, '7900'),
(3710, '1', 2209, 14, 2, '4000'),
(3711, '1', 2210, 1, 2, '7900'),
(3712, '2', 2211, 35, 1, '2800'),
(3713, '1', 2212, 7, 2, '5000'),
(3714, '1', 2212, 24, 2, '2000'),
(3715, '1', 2213, 10, 1, '2100'),
(3716, '1', 2214, 33, 1, '1400'),
(3717, '1', 2215, 10, 1, '2100'),
(3718, '1', 2216, 23, 1, '2000'),
(3719, '1', 2216, 1, 2, '7900'),
(3720, '1', 2217, 4, 1, '4800'),
(3721, '1', 2217, 7, 2, '5000'),
(3722, '1', 2218, 1, 2, '7900'),
(3723, '1', 2218, 37, 1, '2000'),
(3724, '1', 2218, 45, 1, '2500'),
(3725, '1', 2219, 1, 2, '7900'),
(3726, '1', 2220, 1, 2, '7900'),
(3727, '1', 2221, 2, 2, '2000'),
(3728, '2', 2222, 41, 1, '2600'),
(3729, '1', 2222, 37, 1, '2000'),
(3730, '1', 2223, 27, 1, '2000'),
(3731, '2', 2223, 10, 1, '4200'),
(3732, '1', 2224, 2, 2, '2000'),
(3733, '1', 2225, 10, 1, '2100'),
(3734, '1', 2225, 21, 1, '2000'),
(3735, '1', 2225, 3, 2, '5900'),
(3736, '1', 2226, 10, 1, '2100'),
(3737, '1', 2226, 1, 2, '7900'),
(3738, '1', 2227, 1, 2, '7900'),
(3739, '1', 2228, 48, 1, '4000'),
(3740, '1', 2228, 1, 2, '7900'),
(3741, '1', 2229, 35, 1, '1400'),
(3742, '1', 2229, 45, 1, '2500'),
(3743, '1', 2229, 1, 2, '7900'),
(3744, '2', 2230, 36, 1, '1200'),
(3745, '1', 2231, 48, 1, '4000'),
(3746, '1', 2231, 3, 2, '5900'),
(3747, '1', 2232, 43, 1, '1300'),
(3748, '1', 2233, 3, 2, '5900'),
(3749, '1', 2234, 1, 2, '7900'),
(3750, '1', 2235, 5, 1, '2200'),
(3751, '1', 2235, 3, 2, '5900'),
(3752, '2', 2236, 8, 2, '9600'),
(3753, '1', 2236, 28, 2, '2000'),
(3754, '1', 2237, 33, 1, '1400'),
(3755, '2', 2237, 36, 1, '1200'),
(3756, '1', 2237, 44, 1, '2500'),
(3757, '1', 2238, 4, 1, '4800'),
(3758, '2', 2238, 11, 1, '4200'),
(3759, '1', 2239, 40, 1, '2200'),
(3760, '1', 2240, 14, 1, '4000'),
(3761, '1', 2241, 5, 1, '2200'),
(3762, '1', 2241, 31, 1, '2000'),
(3763, '1', 2241, 2, 2, '2000'),
(3764, '1', 2242, 25, 2, '2000'),
(3765, '1', 2243, 3, 2, '5900'),
(3766, '1', 2244, 4, 2, '4800'),
(3767, '1', 2244, 31, 2, '2000'),
(3768, '2', 2245, 36, 1, '1200'),
(3769, '1', 2245, 34, 1, '1400'),
(3770, '1', 2246, 1, 2, '7900'),
(3771, '1', 2247, 12, 1, '2500'),
(3772, '1', 2248, 23, 2, '2000'),
(3773, '1', 2248, 13, 1, '3000'),
(3774, '1', 2248, 8, 2, '4800'),
(3775, '1', 2249, 14, 1, '4000'),
(3776, '1', 2250, 10, 1, '2100'),
(3777, '1', 2251, 45, 1, '2500'),
(3778, '1', 2251, 7, 2, '5000'),
(3779, '1', 2251, 46, 1, '2800'),
(3780, '1', 2252, 37, 1, '2000'),
(3781, '1', 2252, 44, 1, '2500'),
(3782, '1', 2252, 1, 2, '7900'),
(3783, '1', 2253, 12, 1, '2500'),
(3784, '2', 2254, 34, 1, '2800'),
(3785, '1', 2254, 3, 2, '5900'),
(3786, '1', 2255, 1, 2, '7900'),
(3787, '1', 2256, 14, 1, '4000'),
(3788, '1', 2256, 24, 1, '2000'),
(3789, '1', 2257, 20, 1, '2000'),
(3790, '1', 2258, 1, 2, '7900'),
(3791, '1', 2259, 48, 1, '4000'),
(3792, '1', 2259, 2, 2, '2000'),
(3793, '1', 2260, 3, 2, '5900'),
(3794, '1', 2261, 20, 1, '2000'),
(3795, '1', 2262, 11, 1, '2100'),
(3796, '1', 2262, 14, 1, '4000'),
(3797, '1', 2263, 18, 1, '2000'),
(3798, '1', 2263, 2, 2, '2000'),
(3799, '1', 2263, 21, 2, '2000'),
(3800, '1', 2263, 10, 1, '2100'),
(3801, '1', 2264, 10, 1, '2100'),
(3802, '2', 2265, 10, 1, '4200'),
(3803, '1', 2265, 1, 2, '7900'),
(3804, '1', 2265, 31, 1, '2000'),
(3805, '2', 2266, 10, 2, '4200'),
(3806, '1', 2266, 22, 2, '2000'),
(3807, '1', 2267, 2, 2, '2000'),
(3808, '1', 2268, 17, 2, '5000'),
(3809, '3', 2269, 35, 1, '4200'),
(3810, '1', 2270, 13, 1, '3000'),
(3811, '1', 2271, 45, 1, '2500'),
(3812, '1', 2272, 35, 1, '1400'),
(3813, '1', 2273, 47, 1, '2900'),
(3814, '1', 2273, 44, 1, '2500'),
(3815, '1', 2274, 8, 2, '4800'),
(3816, '1', 2274, 22, 2, '2000'),
(3817, '2', 2275, 10, 1, '4200'),
(3818, '1', 2276, 45, 1, '2500'),
(3819, '1', 2276, 36, 1, '600'),
(3820, '1', 2276, 37, 1, '2000'),
(3821, '1', 2276, 2, 2, '2000'),
(3822, '1', 2277, 2, 2, '2000'),
(3823, '2', 2278, 17, 2, '10000'),
(3824, '1', 2279, 33, 1, '1400'),
(3825, '1', 2279, 37, 1, '2000'),
(3826, '1', 2279, 2, 2, '2000'),
(3827, '3', 2280, 33, 1, '4200'),
(3828, '1', 2281, 13, 1, '3000'),
(3830, '1', 2283, 4, 1, '4800'),
(3831, '1', 2283, 23, 1, '2000'),
(3832, '1', 2284, 48, 1, '4000'),
(3833, '1', 2285, 34, 1, '1400'),
(3834, '1', 2270, 3, 2, '5900'),
(3835, '1', 2286, 24, 1, '2000'),
(3836, '1', 2286, 1, 2, '7900'),
(3837, '2', 2286, 10, 1, '4200'),
(3838, '1', 2287, 1, 2, '7900'),
(3839, '1', 2288, 1, 2, '7900'),
(3840, '1', 2288, 37, 1, '2000'),
(3841, '1', 2288, 45, 1, '2500'),
(3842, '1', 2289, 1, 2, '7900'),
(3843, '2', 2290, 20, 1, '4000'),
(3844, '2', 2290, 41, 1, '2600'),
(3845, '1', 2290, 33, 1, '1400'),
(3846, '1', 2291, 10, 1, '2100'),
(3847, '1', 2292, 10, 1, '2100'),
(3848, '1', 2292, 21, 1, '2000'),
(3849, '1', 2293, 1, 2, '7900'),
(3850, '1', 2294, 14, 1, '4000'),
(3851, '1', 2295, 1, 2, '7900'),
(3852, '1', 2296, 20, 1, '2000'),
(3853, '2', 2297, 36, 1, '1200'),
(3854, '1', 2297, 8, 2, '4800'),
(3855, '1', 2297, 44, 1, '2500'),
(3856, '1', 2297, 24, 2, '2000'),
(3857, '1', 2298, 1, 2, '7900'),
(3858, '2', 2299, 35, 1, '2800'),
(3859, '2', 2299, 8, 2, '9600'),
(3860, '1', 2300, 3, 2, '5900'),
(3861, '1', 2301, 14, 2, '4000'),
(3862, '2', 2301, 43, 1, '2600'),
(3863, '1', 2302, 8, 2, '4800'),
(3864, '1', 2303, 8, 2, '4800'),
(3865, '1', 2303, 20, 2, '2000'),
(3866, '1', 2303, 37, 1, '2000'),
(3867, '2', 2304, 9, 1, '4000'),
(3868, '1', 2305, 1, 2, '7900'),
(3869, '1', 2305, 37, 1, '2000'),
(3870, '1', 2306, 4, 2, '4800'),
(3871, '1', 2307, 10, 1, '2100'),
(3872, '1', 2307, 3, 2, '5900'),
(3873, '1', 2307, 21, 1, '2000'),
(3874, '1', 2308, 10, 1, '2100'),
(3875, '1', 2308, 1, 2, '7900'),
(3876, '2', 2309, 8, 1, '9600'),
(3877, '1', 2310, 48, 1, '4000'),
(3878, '1', 2310, 3, 2, '5900'),
(3879, '1', 2311, 45, 1, '2500'),
(3880, '1', 2312, 2, 2, '2000'),
(3881, '1', 2313, 1, 2, '7900'),
(3882, '2', 2314, 33, 1, '2800'),
(3883, '1', 2315, 37, 1, '2000'),
(3884, '1', 2315, 43, 1, '1300'),
(3885, '1', 2316, 8, 2, '4800'),
(3886, '1', 2316, 24, 2, '2000'),
(3887, '2', 2317, 7, 2, '10000'),
(3888, '1', 2318, 2, 2, '2000'),
(3889, '1', 2319, 33, 1, '1400'),
(3890, '1', 2319, 22, 2, '2000'),
(3891, '1', 2320, 2, 2, '2000'),
(3892, '1', 2321, 7, 1, '5000'),
(3893, '3', 2321, 35, 1, '4200'),
(3894, '1', 2322, 1, 2, '7900'),
(3895, '1', 2323, 10, 1, '2100'),
(3896, '1', 2324, 48, 1, '4000'),
(3897, '1', 2324, 3, 2, '5900'),
(3898, '1', 2324, 22, 1, '2000'),
(3899, '1', 2325, 1, 2, '7900'),
(3900, '1', 2326, 3, 2, '5900'),
(3901, '1', 2327, 14, 1, '4000'),
(3902, '1', 2327, 1, 2, '7900'),
(3903, '1', 2328, 1, 2, '7900'),
(3904, '1', 2329, 3, 2, '5900'),
(3905, '3', 2330, 42, 1, '3900'),
(3906, '1', 2330, 9, 1, '2000'),
(3907, '1', 2330, 45, 1, '2500'),
(3908, '1', 2331, 41, 1, '1300'),
(3909, '2', 2331, 36, 1, '1200'),
(3910, '1', 2332, 8, 2, '4800'),
(3911, '1', 2333, 10, 1, '2100'),
(3912, '1', 2334, 2, 2, '2000'),
(3913, '1', 2335, 34, 1, '1400'),
(3914, '2', 2336, 10, 1, '4200'),
(3915, '1', 2336, 31, 1, '2000'),
(3916, '1', 2337, 3, 2, '5900'),
(3917, '1', 2338, 13, 2, '3000'),
(3918, '1', 2339, 3, 2, '5900'),
(3919, '1', 2340, 6, 2, '3200'),
(3920, '1', 2340, 24, 2, '2000'),
(3921, '1', 2341, 7, 2, '5000'),
(3922, '2', 2342, 10, 1, '4200'),
(3923, '1', 2343, 22, 2, '2000'),
(3924, '1', 2343, 9, 1, '2000'),
(3925, '1', 2344, 3, 2, '5900'),
(3926, '1', 2345, 10, 1, '2100'),
(3927, '1', 2346, 10, 1, '2100'),
(3928, '1', 2346, 31, 1, '2000'),
(3929, '1', 2347, 37, 1, '2000'),
(3930, '1', 2348, 31, 1, '2000'),
(3931, '1', 2348, 9, 1, '2000'),
(3932, '1', 2349, 37, 1, '2000'),
(3933, '2', 2349, 36, 1, '1200'),
(3934, '1', 2349, 31, 1, '2000'),
(3935, '1', 2350, 1, 2, '7900'),
(3936, '1', 2351, 3, 2, '5900'),
(3937, '1', 2352, 1, 2, '7900'),
(3938, '1', 2352, 13, 1, '3000'),
(3939, '1', 2353, 1, 2, '7900'),
(3940, '2', 2353, 35, 1, '2800'),
(3941, '1', 2354, 1, 2, '7900'),
(3942, '1', 2354, 37, 1, '2000'),
(3943, '1', 2354, 45, 1, '2500'),
(3945, '1', 2355, 3, 2, '5900'),
(3946, '3', 2356, 34, 1, '4200'),
(3947, '2', 2357, 1, 2, '15800'),
(3948, '1', 2358, 20, 1, '2000'),
(3949, '1', 2358, 6, 1, '3200'),
(3950, '3', 2359, 36, 1, '1800'),
(3951, '1', 2360, 8, 2, '4800'),
(3952, '1', 2360, 24, 1, '2000'),
(3953, '1', 2361, 1, 2, '7900'),
(3954, '2', 2362, 9, 1, '4000'),
(3955, '1', 2363, 3, 2, '5900'),
(3956, '1', 2364, 41, 1, '1300'),
(3957, '1', 2364, 37, 1, '2000'),
(3958, '1', 2364, 44, 1, '2500'),
(3959, '1', 2364, 1, 2, '7900'),
(3960, '1', 2365, 24, 2, '2000'),
(3961, '1', 2365, 2, 2, '2000'),
(3962, '1', 2366, 38, 1, '2500'),
(3963, '1', 2366, 36, 1, '600'),
(3964, '1', 2366, 14, 2, '4000'),
(3965, '1', 2367, 48, 1, '4000'),
(3966, '1', 2367, 45, 1, '2500'),
(3967, '1', 2367, 3, 2, '5900'),
(3968, '1', 2368, 10, 2, '2100'),
(3969, '1', 2369, 37, 2, '2000'),
(3970, '2', 2370, 34, 1, '2800'),
(3971, '1', 2371, 33, 1, '1400'),
(3972, '1', 2371, 36, 1, '600'),
(3973, '1', 2371, 8, 2, '4800'),
(3974, '1', 2371, 44, 1, '2500'),
(3975, '2', 2372, 42, 1, '2600'),
(3976, '2', 2373, 22, 1, '4000'),
(3977, '2', 2373, 10, 2, '4200'),
(3978, '1', 2372, 14, 1, '4000'),
(3979, '1', 2374, 10, 1, '2100'),
(3980, '1', 2375, 2, 2, '2000'),
(3981, '3', 2376, 36, 1, '1800'),
(3982, '1', 2376, 44, 1, '2500'),
(3983, '1', 2376, 1, 2, '7900'),
(3985, '1', 2378, 1, 2, '7900'),
(3986, '1', 2379, 37, 1, '2000'),
(3987, '1', 2379, 28, 2, '2000'),
(3988, '2', 2379, 43, 1, '2600'),
(3989, '1', 2380, 1, 2, '7900'),
(3990, '1', 2381, 33, 1, '1400'),
(3991, '1', 2381, 1, 2, '7900'),
(3992, '1', 2382, 20, 1, '2000'),
(3994, '1', 2384, 34, 1, '1400'),
(3995, '1', 2384, 44, 1, '2500'),
(3996, '1', 2384, 8, 2, '4800'),
(3997, '1', 2385, 21, 2, '2000'),
(3998, '2', 2386, 34, 1, '2800'),
(3999, '1', 2387, 5, 1, '2200'),
(4000, '1', 2387, 24, 2, '2000'),
(4001, '1', 2387, 8, 2, '4800'),
(4002, '1', 2388, 10, 1, '2100'),
(4003, '1', 2388, 3, 2, '5900'),
(4004, '1', 2388, 23, 1, '2000'),
(4005, '1', 2389, 3, 2, '5900'),
(4006, '3', 2390, 34, 1, '4200'),
(4007, '1', 2391, 8, 2, '4800'),
(4009, '1', 2393, 1, 2, '7900'),
(4010, '1', 2393, 35, 1, '1400'),
(4011, '1', 2393, 44, 1, '2500'),
(4012, '1', 2394, 34, 1, '1400'),
(4013, '1', 2394, 45, 1, '2500'),
(4014, '1', 2394, 3, 2, '5900'),
(4015, '1', 2395, 35, 1, '1400'),
(4016, '1', 2395, 18, 2, '2000'),
(4017, '1', 2395, 8, 2, '4800'),
(4018, '2', 2396, 34, 1, '2800'),
(4019, '1', 2397, 1, 2, '7900'),
(4020, '1', 2398, 4, 1, '4800'),
(4021, '1', 2399, 2, 2, '2000'),
(4022, '1', 2400, 24, 2, '2000'),
(4023, '2', 2400, 10, 2, '4200'),
(4024, '1', 2401, 10, 1, '2100'),
(4025, '3', 2402, 33, 1, '4200'),
(4026, '1', 2403, 48, 1, '4000'),
(4027, '1', 2403, 7, 2, '5000'),
(4028, '1', 2404, 2, 2, '2000'),
(4029, '1', 2405, 14, 1, '4000'),
(4030, '2', 2405, 11, 1, '4200'),
(4031, '1', 2406, 17, 1, '5000'),
(4032, '1', 2406, 1, 2, '7900'),
(4033, '1', 2407, 20, 1, '2000'),
(4034, '2', 2408, 10, 2, '4200'),
(4035, '1', 2408, 24, 2, '2000'),
(4037, '1', 2410, 3, 2, '5900'),
(4038, '1', 2411, 10, 1, '2100'),
(4039, '2', 2409, 14, 2, '8000'),
(4040, '1', 2412, 20, 1, '2000'),
(4041, '1', 2413, 2, 2, '2000'),
(4042, '1', 2414, 8, 2, '4800'),
(4043, '1', 2414, 33, 1, '1400'),
(4044, '1', 2414, 44, 1, '2500'),
(4045, '1', 2414, 36, 1, '600'),
(4046, '1', 2415, 14, 1, '4000'),
(4047, '1', 2416, 14, 1, '4000'),
(4048, '2', 2416, 43, 1, '2600'),
(4049, '1', 2417, 10, 1, '2100'),
(4050, '1', 2417, 21, 1, '2000'),
(4051, '1', 2418, 45, 1, '2500'),
(4052, '1', 2418, 38, 1, '2500'),
(4053, '1', 2418, 1, 2, '7900'),
(4054, '1', 2418, 33, 1, '1400'),
(4055, '1', 2419, 1, 2, '7900'),
(4056, '1', 2420, 1, 2, '7900'),
(4057, '1', 2421, 38, 1, '2500'),
(4058, '1', 2421, 4, 1, '4800'),
(4059, '2', 2421, 34, 1, '2800'),
(4060, '1', 2422, 2, 2, '2000'),
(4061, '1', 2422, 28, 2, '2000'),
(4062, '1', 2423, 8, 2, '4800'),
(4063, '2', 2424, 12, 2, '5000'),
(4064, '1', 2425, 17, 1, '5000'),
(4065, '1', 2425, 1, 2, '7900'),
(4066, '1', 2426, 1, 2, '7900'),
(4067, '1', 2427, 3, 2, '5900'),
(4068, '1', 2428, 13, 1, '3000'),
(4069, '1', 2428, 24, 2, '2000'),
(4070, '1', 2429, 2, 2, '2000'),
(4071, '1', 2430, 4, 1, '4800'),
(4072, '1', 2430, 31, 1, '2000'),
(4073, '1', 2430, 3, 2, '5900'),
(4074, '1', 2431, 9, 1, '2000'),
(4075, '1', 2432, 37, 1, '2000'),
(4076, '1', 2432, 33, 1, '1400'),
(4077, '1', 2432, 45, 1, '2500'),
(4078, '2', 2433, 10, 1, '4200'),
(4079, '1', 2433, 31, 1, '2000'),
(4080, '1', 2433, 1, 2, '7900'),
(4081, '1', 2434, 8, 2, '4800'),
(4082, '3', 2435, 35, 1, '4200'),
(4083, '1', 2436, 8, 2, '4800'),
(4084, '1', 2436, 24, 2, '2000'),
(4085, '1', 2437, 1, 2, '7900'),
(4086, '1', 2438, 2, 2, '2000'),
(4087, '1', 2439, 10, 1, '2100'),
(4088, '2', 2440, 10, 1, '4200'),
(4089, '1', 2440, 12, 1, '2500'),
(4090, '1', 2440, 20, 1, '2000'),
(4091, '1', 2440, 42, 1, '1300'),
(4092, '1', 2441, 1, 2, '7900'),
(4093, '1', 2442, 14, 1, '4000'),
(4094, '1', 2442, 2, 2, '2000'),
(4095, '1', 2442, 22, 2, '2000'),
(4096, '1', 2442, 22, 1, '2000'),
(4097, '2', 2443, 7, 1, '10000'),
(4098, '1', 2444, 24, 2, '2000'),
(4099, '1', 2444, 12, 1, '2500'),
(4100, '1', 2445, 35, 1, '1400'),
(4101, '1', 2446, 6, 1, '3200'),
(4102, '1', 2446, 20, 1, '2000'),
(4103, '1', 2447, 8, 2, '4800'),
(4104, '1', 2447, 31, 2, '2000'),
(4105, '1', 2448, 2, 2, '2000'),
(4106, '1', 2449, 17, 2, '5000'),
(4107, '2', 2450, 11, 2, '4200'),
(4108, '1', 2451, 3, 2, '5900'),
(4109, '2', 2451, 14, 1, '8000'),
(4110, '1', 2452, 14, 1, '4000'),
(4111, '2', 2453, 37, 1, '4000'),
(4112, '1', 2453, 44, 1, '2500'),
(4113, '1', 2454, 8, 1, '4800'),
(4114, '1', 2454, 28, 1, '2000'),
(4115, '1', 2455, 12, 1, '2500'),
(4116, '1', 2456, 3, 2, '5900'),
(4117, '2', 2457, 14, 1, '8000'),
(4118, '1', 2457, 24, 2, '2000'),
(4119, '1', 2458, 3, 2, '5900'),
(4120, '2', 2459, 10, 2, '4200'),
(4121, '1', 2459, 22, 2, '2000'),
(4122, '1', 2460, 3, 2, '5900'),
(4123, '1', 2461, 37, 1, '2000'),
(4124, '3', 2462, 33, 1, '4200'),
(4125, '1', 2463, 3, 2, '5900'),
(4126, '1', 2464, 10, 1, '2100'),
(4127, '1', 2464, 21, 1, '2000'),
(4128, '1', 2464, 3, 2, '5900'),
(4129, '1', 2465, 10, 1, '2100'),
(4130, '1', 2466, 3, 2, '5900'),
(4131, '1', 2467, 1, 2, '7900'),
(4132, '1', 2468, 1, 2, '7900'),
(4133, '1', 2469, 34, 1, '1400'),
(4134, '1', 2469, 3, 2, '5900'),
(4135, '1', 2470, 4, 1, '4800'),
(4136, '1', 2470, 11, 1, '2100'),
(4137, '1', 2471, 1, 2, '7900'),
(4138, '1', 2472, 3, 2, '5900'),
(4139, '2', 2473, 36, 1, '1200'),
(4140, '1', 2474, 1, 2, '7900'),
(4141, '1', 2475, 1, 2, '7900'),
(4142, '1', 2475, 43, 1, '1300'),
(4143, '1', 2475, 22, 1, '2000'),
(4144, '1', 2476, 14, 1, '4000'),
(4145, '2', 2477, 10, 1, '4200'),
(4146, '1', 2477, 31, 1, '2000'),
(4147, '2', 2478, 38, 1, '5000'),
(4148, '1', 2478, 45, 1, '2500'),
(4149, '1', 2479, 10, 1, '2100'),
(4150, '1', 2480, 34, 1, '1400'),
(4151, '1', 2481, 10, 1, '2100'),
(4152, '1', 2481, 3, 2, '5900'),
(4153, '1', 2481, 21, 1, '2000'),
(4154, '1', 2482, 14, 1, '4000'),
(4155, '1', 2482, 43, 1, '1300'),
(4156, '1', 2483, 14, 1, '4000'),
(4157, '1', 2484, 34, 1, '1400'),
(4158, '1', 2485, 37, 1, '2000'),
(4159, '1', 2485, 45, 1, '2500'),
(4160, '1', 2485, 1, 2, '7900'),
(4161, '1', 2486, 3, 2, '5900'),
(4162, '1', 2486, 21, 1, '2000'),
(4163, '1', 2486, 10, 1, '2100'),
(4164, '1', 2487, 1, 2, '7900'),
(4165, '1', 2488, 1, 2, '7900'),
(4166, '1', 2489, 14, 1, '4000'),
(4167, '1', 2489, 2, 2, '2000'),
(4168, '1', 2490, 35, 1, '1400'),
(4169, '1', 2491, 38, 1, '2500'),
(4170, '1', 2491, 45, 1, '2500'),
(4171, '1', 2492, 1, 2, '7900'),
(4172, '1', 2493, 10, 1, '2100'),
(4173, '1', 2494, 1, 2, '7900'),
(4174, '3', 2495, 35, 1, '4200'),
(4175, '1', 2496, 1, 2, '7900'),
(4176, '2', 2497, 43, 1, '2600'),
(4177, '1', 2497, 5, 1, '2200'),
(4178, '1', 2497, 7, 2, '5000'),
(4179, '1', 2497, 22, 1, '2000'),
(4180, '1', 2497, 22, 2, '2000'),
(4181, '1', 2498, 37, 1, '2000'),
(4182, '1', 2498, 45, 1, '2500'),
(4183, '1', 2498, 1, 2, '7900'),
(4184, '1', 2499, 1, 2, '7900'),
(4185, '2', 2500, 41, 1, '2600'),
(4186, '2', 2501, 9, 2, '4000'),
(4187, '1', 2501, 24, 2, '2000'),
(4188, '1', 2502, 1, 2, '7900'),
(4189, '1', 2503, 8, 2, '4800'),
(4190, '1', 2504, 10, 1, '2100'),
(4191, '1', 2505, 12, 1, '2500'),
(4192, '1', 2505, 28, 1, '2000'),
(4193, '1', 2506, 14, 1, '4000'),
(4194, '1', 2507, 10, 1, '2100'),
(4195, '2', 2508, 34, 1, '2800'),
(4196, '1', 2509, 48, 1, '4000'),
(4197, '1', 2509, 45, 1, '2500'),
(4198, '1', 2509, 1, 2, '7900'),
(4199, '1', 2510, 38, 1, '2500'),
(4200, '1', 2510, 44, 1, '2500'),
(4201, '1', 2510, 3, 2, '5900'),
(4202, '2', 2511, 43, 1, '2600'),
(4203, '1', 2511, 28, 1, '2000'),
(4204, '1', 2512, 10, 1, '2100'),
(4205, '2', 2513, 9, 1, '4000'),
(4206, '2', 2514, 33, 1, '2800'),
(4207, '1', 2515, 38, 1, '2500'),
(4208, '2', 2515, 36, 1, '1200'),
(4209, '2', 2516, 11, 1, '4200'),
(4210, '1', 2517, 14, 2, '4000'),
(4211, '1', 2517, 24, 2, '2000'),
(4212, '1', 2516, 4, 1, '4800'),
(4213, '1', 2518, 33, 1, '1400'),
(4214, '1', 2519, 12, 1, '2500'),
(4215, '1', 2519, 10, 1, '2100'),
(4216, '1', 2520, 10, 1, '2100'),
(4217, '1', 2521, 2, 2, '2000'),
(4218, '1', 2521, 12, 1, '2500'),
(4219, '1', 2522, 14, 1, '4000'),
(4220, '1', 2523, 20, 1, '2000'),
(4221, '1', 2524, 1, 2, '7900'),
(4222, '3', 2525, 36, 1, '1800'),
(4223, '1', 2525, 45, 1, '2500'),
(4224, '1', 2525, 3, 2, '5900'),
(4225, '2', 2526, 34, 1, '2800'),
(4226, '1', 2526, 44, 1, '2500'),
(4227, '1', 2526, 20, 2, '2000'),
(4228, '2', 2526, 8, 2, '9600'),
(4229, '2', 2527, 33, 1, '2800'),
(4230, '1', 2528, 38, 1, '2500'),
(4232, '1', 2529, 10, 1, '2100'),
(4233, '1', 2530, 44, 1, '2500'),
(4234, '1', 2530, 37, 1, '2000'),
(4235, '1', 2530, 18, 2, '2000'),
(4236, '1', 2530, 7, 2, '5000'),
(4237, '1', 2531, 37, 1, '2000'),
(4238, '1', 2531, 1, 2, '7900'),
(4239, '2', 2528, 11, 2, '4200'),
(4240, '1', 2528, 13, 2, '3000'),
(4241, '2', 2532, 33, 1, '2800'),
(4242, '1', 2532, 17, 2, '5000'),
(4243, '2', 2533, 9, 1, '4000'),
(4244, '1', 2534, 14, 1, '4000'),
(4245, '2', 2535, 10, 1, '4200'),
(4246, '1', 2535, 22, 1, '2000'),
(4247, '1', 2536, 10, 1, '2100'),
(4248, '1', 2536, 21, 1, '2000'),
(4249, '1', 2536, 3, 2, '5900'),
(4250, '2', 2537, 9, 1, '4000'),
(4251, '1', 2537, 20, 2, '2000'),
(4252, '1', 2537, 3, 2, '5900'),
(4253, '1', 2538, 3, 2, '5900'),
(4254, '1', 2539, 1, 2, '7900'),
(4255, '1', 2540, 1, 2, '7900'),
(4256, '1', 2541, 1, 2, '7900'),
(4257, '1', 2542, 33, 1, '1400'),
(4258, '1', 2543, 1, 2, '7900'),
(4259, '2', 2544, 34, 1, '2800'),
(4260, '1', 2545, 2, 2, '2000'),
(4261, '1', 2546, 1, 2, '7900'),
(4262, '1', 2547, 20, 1, '2000'),
(4263, '1', 2548, 3, 2, '5900'),
(4264, '2', 2549, 9, 1, '4000'),
(4265, '1', 2550, 21, 1, '2000'),
(4266, '1', 2550, 3, 2, '5900'),
(4267, '1', 2550, 10, 1, '2100'),
(4268, '1', 2551, 1, 2, '7900'),
(4269, '1', 2552, 3, 2, '5900'),
(4270, '2', 2552, 11, 1, '4200'),
(4271, '1', 2553, 48, 1, '4000'),
(4272, '1', 2553, 1, 2, '7900'),
(4273, '1', 2554, 1, 2, '7900'),
(4274, '1', 2555, 8, 2, '4800'),
(4275, '1', 2556, 1, 2, '7900'),
(4276, '1', 2556, 34, 1, '1400'),
(4277, '1', 2557, 37, 1, '2000'),
(4278, '1', 2557, 1, 2, '7900'),
(4279, '1', 2557, 45, 1, '2500'),
(4280, '2', 2557, 36, 1, '1200'),
(4281, '1', 2558, 22, 2, '2000'),
(4282, '1', 2558, 2, 2, '2000'),
(4283, '1', 2559, 12, 2, '2500'),
(4284, '2', 2560, 11, 1, '4200'),
(4285, '1', 2561, 8, 2, '4800'),
(4286, '1', 2562, 34, 1, '1400'),
(4287, '2', 2563, 34, 1, '2800'),
(4288, '1', 2564, 1, 2, '7900'),
(4289, '1', 2565, 2, 2, '2000'),
(4290, '1', 2566, 10, 1, '2100'),
(4291, '1', 2566, 21, 1, '2000'),
(4292, '1', 2566, 3, 2, '5900'),
(4293, '2', 2567, 48, 1, '8000'),
(4294, '1', 2568, 15, 1, '3000'),
(4295, '1', 2568, 2, 2, '2000'),
(4296, '1', 2569, 35, 1, '1400'),
(4297, '2', 2570, 34, 1, '2800'),
(4298, '1', 2571, 3, 2, '5900'),
(4299, '1', 2572, 2, 2, '2000'),
(4300, '1', 2573, 10, 1, '2100'),
(4301, '1', 2574, 2, 2, '2000'),
(4302, '1', 2575, 10, 1, '2100'),
(4303, '1', 2576, 7, 2, '5000'),
(4304, '1', 2577, 10, 1, '2100'),
(4305, '1', 2577, 24, 1, '2000'),
(4306, '1', 2578, 14, 1, '4000'),
(4307, '1', 2579, 1, 2, '7900'),
(4308, '1', 2580, 1, 2, '7900'),
(4309, '1', 2581, 1, 2, '7900'),
(4310, '1', 2582, 1, 2, '7900'),
(4311, '1', 2582, 35, 1, '1400'),
(4312, '1', 2583, 1, 2, '7900'),
(4313, '1', 2584, 10, 1, '2100'),
(4314, '1', 2585, 1, 2, '7900'),
(4315, '1', 2586, 10, 1, '2100'),
(4316, '1', 2587, 1, 2, '7900'),
(4317, '2', 2588, 47, 1, '5800'),
(4318, '1', 2589, 38, 1, '2500'),
(4319, '1', 2589, 45, 1, '2500'),
(4320, '1', 2589, 1, 2, '7900'),
(4321, '1', 2590, 2, 2, '2000'),
(4322, '1', 2591, 3, 2, '5900'),
(4323, '1', 2592, 2, 2, '2000'),
(4324, '1', 2593, 7, 2, '5000'),
(4325, '1', 2593, 28, 2, '2000'),
(4326, '1', 2594, 2, 2, '2000'),
(4327, '1', 2595, 2, 2, '2000'),
(4328, '1', 2596, 10, 1, '2100'),
(4329, '1', 2597, 1, 2, '7900'),
(4330, '4', 2598, 33, 1, '5600'),
(4331, '1', 2599, 18, 2, '2000'),
(4332, '1', 2599, 7, 2, '5000'),
(4333, '1', 2600, 1, 2, '7900'),
(4334, '1', 2600, 35, 1, '1400'),
(4335, '1', 2601, 9, 1, '2000'),
(4336, '1', 2601, 13, 1, '3000'),
(4337, '1', 2602, 1, 2, '7900'),
(4338, '1', 2603, 13, 1, '3000'),
(4339, '1', 2603, 11, 1, '2100'),
(4340, '1', 2604, 31, 1, '2000'),
(4341, '1', 2604, 8, 2, '4800'),
(4342, '1', 2604, 23, 2, '2000'),
(4343, '3', 2605, 34, 1, '4200'),
(4344, '1', 2606, 10, 1, '2100'),
(4345, '1', 2606, 3, 2, '5900'),
(4346, '2', 2607, 10, 1, '4200'),
(4347, '1', 2607, 23, 1, '2000'),
(4348, '2', 2608, 34, 1, '2800'),
(4349, '2', 2609, 7, 1, '10000'),
(4350, '1', 2610, 10, 1, '2100'),
(4351, '1', 2610, 45, 1, '2500'),
(4352, '1', 2611, 10, 1, '2100'),
(4353, '2', 2612, 15, 1, '6000'),
(4354, '2', 2613, 36, 1, '1200'),
(4355, '1', 2614, 48, 1, '4000'),
(4356, '1', 2614, 14, 1, '4000'),
(4357, '2', 2615, 34, 1, '2800'),
(4358, '1', 2616, 3, 2, '5900'),
(4359, '1', 2617, 14, 1, '4000'),
(4360, '2', 2617, 41, 1, '2600'),
(4361, '1', 2618, 34, 1, '1400'),
(4362, '1', 2618, 33, 1, '1400'),
(4363, '2', 2619, 48, 1, '8000'),
(4364, '2', 2619, 43, 1, '2600'),
(4365, '1', 2620, 14, 2, '4000'),
(4366, '1', 2621, 10, 1, '2100'),
(4367, '2', 2622, 34, 1, '2800'),
(4368, '1', 2623, 10, 1, '2100'),
(4369, '1', 2623, 3, 2, '5900'),
(4370, '1', 2623, 22, 1, '2000'),
(4371, '2', 2624, 43, 1, '2600'),
(4372, '2', 2624, 37, 1, '4000'),
(4373, '2', 2624, 44, 1, '5000'),
(4374, '1', 2625, 1, 2, '7900'),
(4375, '1', 2626, 1, 2, '7900'),
(4376, '1', 2626, 24, 2, '2000'),
(4377, '3', 2627, 1, 2, '23700'),
(4378, '1', 2627, 45, 1, '2500'),
(4379, '3', 2627, 10, 1, '6300'),
(4380, '2', 2628, 47, 1, '5800'),
(4381, '1', 2629, 18, 1, '2000'),
(4382, '1', 2629, 17, 1, '5000'),
(4383, '1', 2630, 31, 1, '2000'),
(4384, '2', 2630, 41, 1, '2600'),
(4385, '1', 2630, 20, 2, '2000'),
(4386, '2', 2631, 33, 1, '2800'),
(4387, '2', 2631, 4, 2, '9600'),
(4388, '2', 2632, 33, 1, '2800'),
(4389, '1', 2632, 2, 2, '2000'),
(4390, '1', 2633, 1, 2, '7900'),
(4391, '2', 2634, 9, 1, '4000'),
(4392, '1', 2635, 1, 2, '7900'),
(4393, '1', 2635, 34, 1, '1400'),
(4394, '2', 2636, 1, 2, '15800'),
(4395, '1', 2637, 14, 1, '4000'),
(4396, '1', 2638, 17, 2, '5000'),
(4397, '1', 2638, 21, 2, '2000'),
(4398, '1', 2639, 1, 2, '7900'),
(4399, '1', 2640, 2, 2, '2000'),
(4400, '1', 2641, 9, 1, '2000'),
(4401, '1', 2642, 2, 2, '2000'),
(4402, '1', 2643, 1, 2, '7900'),
(4403, '1', 2644, 5, 1, '2200'),
(4404, '1', 2644, 43, 1, '1300'),
(4405, '1', 2644, 8, 2, '4800'),
(4406, '2', 2645, 46, 1, '5600'),
(4407, '1', 2646, 37, 1, '2000'),
(4408, '1', 2646, 2, 2, '2000'),
(4409, '1', 2647, 1, 2, '7900'),
(4410, '1', 2648, 13, 1, '3000'),
(4411, '2', 2648, 34, 1, '2800'),
(4412, '1', 2649, 10, 1, '2100'),
(4413, '1', 2649, 21, 1, '2000'),
(4414, '1', 2649, 3, 2, '5900'),
(4415, '1', 2650, 33, 1, '1400'),
(4416, '2', 2651, 9, 1, '4000'),
(4417, '1', 2652, 8, 1, '4800'),
(4418, '1', 2653, 6, 1, '3200'),
(4419, '1', 2653, 20, 1, '2000'),
(4420, '1', 2654, 10, 1, '2100'),
(4421, '1', 2655, 37, 1, '2000'),
(4422, '1', 2655, 20, 1, '2000'),
(4423, '1', 2656, 10, 2, '2100'),
(4424, '1', 2656, 2, 2, '2000'),
(4425, '1', 2656, 28, 2, '2000'),
(4426, '1', 2657, 45, 1, '2500'),
(4427, '1', 2657, 7, 2, '5000'),
(4428, '1', 2657, 34, 1, '1400'),
(4429, '1', 2658, 1, 2, '7900'),
(4430, '1', 2659, 48, 1, '4000'),
(4431, '2', 2660, 34, 1, '2800'),
(4432, '1', 2661, 2, 2, '2000'),
(4433, '1', 2662, 13, 1, '3000'),
(4434, '1', 2663, 2, 2, '2000'),
(4435, '1', 2664, 45, 1, '2500'),
(4436, '1', 2664, 38, 1, '2500'),
(4437, '1', 2664, 1, 2, '7900'),
(4438, '1', 2665, 1, 2, '7900'),
(4439, '1', 2666, 37, 1, '2000'),
(4440, '1', 2666, 14, 2, '4000'),
(4441, '1', 2667, 17, 2, '5000'),
(4442, '1', 2668, 43, 1, '1300'),
(4443, '1', 2668, 20, 1, '2000'),
(4444, '1', 2669, 41, 1, '1300'),
(4445, '1', 2669, 44, 1, '2500'),
(4446, '1', 2669, 37, 1, '2000'),
(4447, '1', 2670, 2, 2, '2000'),
(4448, '1', 2671, 37, 1, '2000'),
(4449, '1', 2671, 44, 1, '2500'),
(4450, '1', 2672, 37, 1, '2000'),
(4451, '3', 2673, 35, 1, '4200'),
(4452, '1', 2674, 3, 2, '5900'),
(4453, '1', 2675, 10, 1, '2100'),
(4454, '1', 2676, 31, 1, '2000'),
(4455, '2', 2676, 36, 1, '1200'),
(4456, '1', 2676, 33, 1, '1400'),
(4457, '1', 2676, 1, 2, '7900'),
(4458, '1', 2677, 2, 2, '2000'),
(4459, '1', 2678, 45, 1, '2500'),
(4460, '1', 2678, 34, 1, '1400'),
(4461, '1', 2678, 27, 2, '2000'),
(4462, '1', 2679, 20, 1, '2000'),
(4463, '1', 2680, 14, 1, '4000'),
(4464, '3', 2681, 33, 1, '4200'),
(4465, '1', 2682, 41, 1, '1300'),
(4466, '1', 2683, 2, 2, '2000'),
(4467, '2', 2684, 35, 1, '2800'),
(4468, '1', 2685, 48, 1, '4000'),
(4469, '1', 2685, 43, 1, '1300'),
(4470, '1', 2685, 28, 2, '2000'),
(4471, '1', 2685, 7, 2, '5000'),
(4472, '1', 2686, 10, 1, '2100'),
(4473, '1', 2686, 3, 2, '5900'),
(4474, '1', 2687, 14, 2, '4000'),
(4475, '1', 2688, 13, 1, '3000'),
(4476, '1', 2689, 1, 2, '7900'),
(4477, '1', 2690, 14, 1, '4000'),
(4478, '1', 2691, 1, 2, '7900'),
(4479, '1', 2692, 1, 2, '7900'),
(4480, '1', 2693, 20, 1, '2000'),
(4481, '1', 2694, 8, 2, '4800'),
(4482, '1', 2694, 20, 2, '2000'),
(4483, '1', 2695, 8, 2, '4800'),
(4484, '1', 2696, 8, 2, '4800'),
(4485, '2', 2697, 14, 1, '8000'),
(4486, '1', 2698, 2, 2, '2000'),
(4487, '1', 2699, 1, 2, '7900'),
(4488, '1', 2699, 17, 1, '5000'),
(4489, '1', 2699, 28, 1, '2000'),
(4490, '1', 2700, 10, 1, '2100'),
(4491, '1', 2700, 21, 1, '2000'),
(4492, '1', 2700, 3, 2, '5900'),
(4493, '1', 2701, 40, 1, '2200'),
(4494, '1', 2701, 23, 1, '2000'),
(4495, '1', 2702, 2, 2, '2000'),
(4496, '2', 2703, 34, 1, '2800'),
(4497, '1', 2704, 34, 1, '1400'),
(4498, '1', 2705, 1, 2, '7900'),
(4499, '2', 2706, 33, 1, '2800'),
(4500, '1', 2707, 6, 1, '3200'),
(4501, '1', 2708, 8, 2, '4800'),
(4502, '1', 2709, 21, 1, '2000'),
(4503, '1', 2709, 10, 1, '2100'),
(4504, '1', 2709, 3, 2, '5900'),
(4505, '1', 2710, 1, 2, '7900'),
(4506, '1', 2711, 13, 1, '3000'),
(4507, '2', 2712, 43, 1, '2600'),
(4508, '1', 2712, 24, 2, '2000'),
(4509, '1', 2712, 34, 1, '1400'),
(4510, '1', 2713, 35, 1, '1400'),
(4511, '1', 2714, 8, 2, '4800'),
(4512, '1', 2715, 35, 1, '1400'),
(4513, '1', 2716, 1, 2, '7900'),
(4514, '2', 2717, 34, 1, '2800'),
(4515, '1', 2718, 10, 1, '2100'),
(4516, '1', 2718, 21, 1, '2000'),
(4517, '1', 2718, 3, 2, '5900'),
(4518, '1', 2719, 25, 1, '2000'),
(4519, '2', 2719, 11, 1, '4200'),
(4520, '1', 2720, 34, 1, '1400'),
(4521, '2', 2720, 43, 1, '2600'),
(4522, '1', 2720, 22, 2, '2000'),
(4523, '1', 2720, 45, 1, '2500'),
(4524, '1', 2721, 2, 2, '2000'),
(4525, '2', 2722, 10, 1, '4200'),
(4526, '1', 2722, 23, 1, '2000'),
(4527, '1', 2722, 33, 1, '1400'),
(4528, '1', 2723, 48, 1, '4000'),
(4529, '1', 2724, 10, 1, '2100'),
(4530, '1', 2725, 33, 1, '1400'),
(4531, '1', 2725, 34, 1, '1400'),
(4532, '1', 2726, 20, 1, '2000'),
(4533, '1', 2727, 33, 1, '1400'),
(4534, '1', 2727, 34, 1, '1400'),
(4535, '1', 2728, 45, 1, '2500'),
(4536, '2', 2729, 35, 1, '2800'),
(4537, '2', 2730, 35, 1, '2800'),
(4538, '2', 2731, 35, 1, '2800'),
(4539, '1', 2732, 2, 2, '2000'),
(4540, '1', 2733, 2, 2, '2000'),
(4541, '1', 2734, 47, 1, '2900'),
(4542, '1', 2734, 45, 1, '2500'),
(4543, '1', 2735, 10, 1, '2100'),
(4544, '1', 2736, 24, 1, '2000'),
(4545, '2', 2736, 10, 1, '4200'),
(4546, '1', 2737, 13, 1, '3000'),
(4547, '1', 2738, 8, 2, '4800'),
(4548, '2', 2739, 36, 1, '1200'),
(4549, '1', 2739, 31, 1, '2000'),
(4550, '2', 2739, 11, 2, '4200'),
(4551, '1', 2739, 11, 1, '2100'),
(4552, '3', 2740, 33, 1, '4200'),
(4553, '1', 2741, 2, 2, '2000'),
(4554, '1', 2742, 14, 1, '4000'),
(4555, '1', 2743, 34, 1, '1400'),
(4556, '1', 2743, 8, 2, '4800'),
(4557, '2', 2743, 42, 1, '2600'),
(4558, '1', 2744, 13, 2, '3000'),
(4559, '1', 2745, 45, 1, '2500'),
(4560, '1', 2745, 1, 2, '7900'),
(4561, '1', 2745, 35, 1, '1400'),
(4562, '1', 2746, 34, 1, '1400'),
(4563, '1', 2747, 2, 2, '2000'),
(4564, '1', 2748, 44, 1, '2500'),
(4565, '1', 2748, 48, 1, '4000'),
(4566, '1', 2748, 3, 2, '5900'),
(4567, '3', 2749, 33, 1, '4200'),
(4568, '1', 2750, 34, 1, '1400'),
(4569, '1', 2750, 33, 1, '1400'),
(4570, '1', 2751, 13, 1, '3000'),
(4571, '1', 2751, 1, 2, '7900'),
(4572, '1', 2752, 44, 1, '2500'),
(4573, '1', 2752, 33, 1, '1400'),
(4574, '1', 2753, 1, 2, '7900'),
(4575, '1', 2754, 3, 2, '5900'),
(4576, '1', 2755, 1, 2, '7900'),
(4577, '1', 2756, 14, 1, '4000'),
(4578, '1', 2756, 1, 2, '7900'),
(4579, '1', 2757, 1, 2, '7900'),
(4580, '1', 2757, 20, 1, '2000'),
(4581, '1', 2758, 2, 2, '2000'),
(4582, '1', 2759, 10, 1, '2100'),
(4584, '1', 2759, 21, 1, '2000'),
(4585, '1', 2760, 8, 2, '4800'),
(4586, '1', 2760, 29, 2, '2000'),
(4587, '1', 2761, 43, 1, '1300'),
(4588, '1', 2762, 17, 2, '5000'),
(4589, '1', 2763, 4, 2, '4800'),
(4590, '1', 2764, 1, 2, '7900'),
(4591, '2', 2765, 21, 1, '4000'),
(4592, '1', 2766, 38, 1, '2500'),
(4593, '1', 2766, 9, 2, '2000'),
(4594, '1', 2766, 21, 2, '2000'),
(4595, '1', 2766, 31, 1, '2000'),
(4596, '1', 2766, 40, 1, '2200'),
(4597, '1', 2767, 28, 2, '2000'),
(4598, '1', 2768, 8, 2, '4800'),
(4599, '1', 2768, 22, 2, '2000'),
(4600, '1', 2769, 33, 1, '1400'),
(4601, '1', 2769, 43, 1, '1300'),
(4602, '6', 2770, 36, 1, '3600'),
(4603, '2', 2771, 34, 1, '2800'),
(4604, '1', 2772, 10, 1, '2100'),
(4605, '1', 2773, 2, 2, '2000'),
(4606, '1', 2774, 37, 1, '2000'),
(4607, '1', 2774, 12, 1, '2500'),
(4608, '2', 2775, 42, 1, '2600'),
(4609, '1', 2775, 37, 1, '2000'),
(4610, '1', 2776, 1, 2, '7900'),
(4611, '1', 2776, 2, 2, '2000'),
(4612, '1', 2777, 1, 2, '7900'),
(4613, '1', 2777, 34, 1, '1400'),
(4614, '1', 2778, 8, 2, '4800'),
(4615, '1', 2779, 25, 1, '2000'),
(4616, '1', 2779, 33, 1, '1400'),
(4617, '1', 2780, 38, 1, '2500'),
(4618, '2', 2781, 34, 1, '2800'),
(4619, '1', 2782, 2, 2, '2000'),
(4620, '1', 2783, 14, 1, '4000'),
(4621, '1', 2784, 18, 2, '2000'),
(4622, '1', 2783, 26, 2, '2000'),
(4623, '1', 2785, 2, 2, '2000'),
(4624, '1', 2786, 3, 2, '5900'),
(4625, '1', 2787, 7, 2, '5000'),
(4626, '1', 2788, 2, 2, '2000'),
(4627, '1', 2789, 2, 2, '2000'),
(4628, '1', 2790, 28, 1, '2000'),
(4629, '1', 2790, 1, 2, '7900'),
(4630, '1', 2790, 17, 1, '5000'),
(4631, '1', 2791, 33, 1, '1400'),
(4632, '1', 2792, 20, 1, '2000'),
(4633, '2', 2793, 11, 1, '4200'),
(4634, '1', 2794, 20, 1, '2000'),
(4635, '1', 2795, 1, 2, '7900'),
(4636, '2', 2796, 10, 2, '4200'),
(4637, '1', 2796, 18, 2, '2000'),
(4638, '4', 2797, 33, 1, '5600'),
(4639, '1', 2798, 14, 1, '4000'),
(4640, '1', 2799, 14, 1, '4000'),
(4641, '1', 2799, 48, 1, '4000'),
(4642, '1', 2800, 1, 2, '7900'),
(4643, '1', 2801, 10, 1, '2100'),
(4644, '1', 2801, 21, 1, '2000'),
(4645, '1', 2801, 3, 2, '5900'),
(4646, '1', 2802, 3, 2, '5900'),
(4647, '2', 2803, 34, 1, '2800'),
(4648, '2', 2804, 48, 1, '8000'),
(4649, '1', 2805, 1, 2, '7900'),
(4650, '1', 2806, 33, 1, '1400'),
(4651, '1', 2806, 44, 1, '2500'),
(4652, '1', 2807, 28, 2, '2000'),
(4653, '1', 2808, 45, 1, '2500'),
(4654, '1', 2808, 35, 1, '1400'),
(4655, '1', 2809, 1, 2, '7900'),
(4656, '1', 2809, 45, 1, '2500'),
(4657, '1', 2809, 37, 1, '2000'),
(4658, '1', 2810, 2, 2, '2000'),
(4659, '1', 2811, 38, 1, '2500'),
(4660, '1', 2812, 2, 2, '2000'),
(4661, '2', 2813, 34, 1, '2800'),
(4662, '1', 2814, 1, 2, '7900'),
(4663, '1', 2815, 1, 2, '7900'),
(4664, '2', 2816, 14, 1, '8000'),
(4665, '1', 2816, 2, 2, '2000'),
(4666, '3', 2817, 34, 1, '4200'),
(4667, '3', 2818, 35, 1, '4200'),
(4668, '1', 2819, 37, 1, '2000'),
(4669, '1', 2819, 42, 1, '1300'),
(4670, '1', 2819, 44, 1, '2500'),
(4671, '1', 2819, 1, 2, '7900'),
(4672, '1', 2820, 8, 2, '4800'),
(4673, '1', 2821, 7, 2, '5000'),
(4674, '1', 2821, 27, 2, '2000'),
(4675, '1', 2820, 23, 2, '2000'),
(4676, '1', 2822, 20, 1, '2000'),
(4677, '1', 2823, 3, 2, '5900'),
(4678, '1', 2824, 35, 1, '1400'),
(4679, '2', 2825, 11, 1, '4200'),
(4680, '2', 2826, 34, 1, '2800'),
(4681, '1', 2826, 43, 1, '1300'),
(4682, '1', 2827, 1, 2, '7900'),
(4683, '1', 2828, 1, 2, '7900'),
(4684, '1', 2829, 2, 2, '2000'),
(4685, '1', 2830, 38, 1, '2500'),
(4686, '1', 2831, 1, 2, '7900'),
(4687, '1', 2831, 34, 1, '1400'),
(4688, '1', 2832, 21, 2, '2000'),
(4689, '1', 2833, 38, 1, '2500'),
(4690, '1', 2834, 35, 1, '1400'),
(4691, '1', 2834, 34, 1, '1400'),
(4692, '1', 2835, 2, 2, '2000'),
(4693, '1', 2836, 2, 2, '2000'),
(4694, '1', 2837, 33, 1, '1400'),
(4695, '1', 2838, 10, 1, '2100'),
(4696, '1', 2839, 13, 1, '3000'),
(4697, '1', 2839, 5, 1, '2200'),
(4698, '1', 2839, 44, 1, '2500'),
(4699, '1', 2840, 1, 2, '7900'),
(4700, '2', 2841, 22, 2, '4000'),
(4701, '1', 2842, 2, 2, '2000'),
(4702, '1', 2843, 3, 2, '5900'),
(4703, '2', 2844, 4, 1, '9600'),
(4704, '1', 2844, 18, 1, '2000'),
(4705, '1', 2845, 21, 1, '2000'),
(4706, '1', 2845, 3, 2, '5900'),
(4707, '1', 2845, 10, 1, '2100'),
(4708, '2', 2846, 43, 1, '2600'),
(4709, '1', 2846, 34, 1, '1400'),
(4710, '1', 2847, 2, 2, '2000'),
(4711, '1', 2847, 20, 2, '2000'),
(4712, '1', 2848, 35, 1, '1400'),
(4713, '1', 2848, 34, 1, '1400'),
(4714, '1', 2849, 2, 2, '2000'),
(4715, '4', 2850, 34, 1, '5600'),
(4716, '1', 2851, 21, 1, '2000'),
(4717, '1', 2851, 8, 1, '4800'),
(4718, '2', 2852, 10, 1, '4200'),
(4719, '1', 2852, 23, 1, '2000'),
(4720, '1', 2852, 1, 2, '7900'),
(4721, '1', 2853, 7, 2, '5000'),
(4722, '1', 2853, 20, 2, '2000'),
(4723, '2', 2854, 35, 1, '2800'),
(4724, '1', 2855, 35, 1, '1400'),
(4725, '2', 2855, 36, 1, '1200'),
(4726, '1', 2856, 1, 2, '7900'),
(4727, '1', 2857, 3, 2, '5900'),
(4728, '1', 2858, 7, 2, '5000'),
(4729, '1', 2858, 27, 2, '2000'),
(4730, '1', 2858, 6, 2, '3200'),
(4731, '2', 2859, 1, 2, '15800'),
(4732, '1', 2859, 10, 1, '2100'),
(4733, '1', 2859, 18, 1, '2000'),
(4734, '1', 2860, 3, 2, '5900'),
(4735, '2', 2861, 35, 1, '2800'),
(4736, '1', 2861, 1, 2, '7900'),
(4737, '1', 2862, 8, 2, '4800'),
(4738, '1', 2863, 7, 2, '5000'),
(4739, '2', 2864, 43, 1, '2600'),
(4740, '1', 2864, 31, 1, '2000'),
(4741, '1', 2864, 24, 2, '2000'),
(4742, '1', 2865, 1, 2, '7900'),
(4743, '1', 2866, 1, 2, '7900'),
(4744, '1', 2867, 33, 1, '1400'),
(4745, '1', 2868, 1, 2, '7900'),
(4746, '1', 2869, 20, 1, '2000'),
(4747, '1', 2870, 2, 2, '2000'),
(4748, '1', 2870, 4, 2, '4800'),
(4749, '1', 2871, 23, 1, '2000'),
(4750, '1', 2871, 17, 1, '5000'),
(4751, '1', 2871, 1, 2, '7900'),
(4752, '1', 2872, 8, 1, '4800'),
(4753, '2', 2873, 43, 1, '2600'),
(4754, '1', 2874, 3, 2, '5900'),
(4755, '1', 2875, 14, 1, '4000'),
(4756, '1', 2875, 8, 2, '4800'),
(4757, '1', 2875, 26, 2, '2000'),
(4758, '1', 2876, 22, 1, '2000'),
(4759, '2', 2876, 43, 1, '2600'),
(4760, '1', 2877, 10, 1, '2100'),
(4761, '1', 2877, 13, 1, '3000'),
(4762, '1', 2878, 48, 1, '4000'),
(4763, '1', 2878, 3, 2, '5900'),
(4764, '1', 2878, 44, 1, '2500'),
(4765, '1', 2879, 24, 2, '2000'),
(4766, '1', 2879, 20, 1, '2000'),
(4767, '1', 2879, 38, 1, '2500'),
(4768, '1', 2879, 39, 1, '2200'),
(4769, '1', 2880, 13, 1, '3000'),
(4770, '2', 2881, 35, 1, '2800'),
(4771, '1', 2881, 37, 1, '2000'),
(4772, '1', 2881, 45, 1, '2500'),
(4773, '1', 2881, 1, 2, '7900'),
(4774, '1', 2882, 1, 2, '7900'),
(4775, '2', 2883, 36, 1, '1200'),
(4776, '1', 2883, 44, 1, '2500'),
(4777, '2', 2884, 7, 1, '10000'),
(4778, '1', 2885, 10, 1, '2100'),
(4779, '1', 2885, 3, 2, '5900'),
(4780, '1', 2885, 21, 1, '2000'),
(4781, '1', 2886, 1, 2, '7900'),
(4782, '1', 2887, 1, 2, '7900'),
(4783, '1', 2888, 7, 1, '5000'),
(4784, '1', 2888, 28, 1, '2000'),
(4785, '1', 2889, 45, 1, '2500'),
(4786, '1', 2889, 34, 1, '1400'),
(4787, '1', 2890, 13, 1, '3000'),
(4788, '1', 2891, 1, 2, '7900'),
(4789, '1', 2892, 3, 2, '5900'),
(4790, '1', 2893, 3, 2, '5900'),
(4791, '1', 2893, 10, 1, '2100'),
(4792, '1', 2893, 21, 1, '2000'),
(4793, '2', 2894, 4, 1, '9600'),
(4794, '1', 2895, 43, 1, '1300'),
(4795, '1', 2895, 26, 1, '2000'),
(4796, '1', 2896, 3, 2, '5900'),
(4797, '1', 2897, 7, 1, '5000'),
(4798, '1', 2898, 3, 2, '5900'),
(4799, '1', 2899, 18, 1, '2000'),
(4800, '1', 2900, 1, 2, '7900'),
(4801, '1', 2901, 1, 2, '7900'),
(4802, '3', 2902, 41, 1, '3900'),
(4803, '4', 2903, 36, 1, '2400'),
(4804, '1', 2904, 3, 2, '5900'),
(4805, '1', 2904, 10, 1, '2100'),
(4806, '1', 2904, 21, 1, '2000'),
(4807, '1', 2905, 34, 1, '1400'),
(4808, '1', 2906, 1, 2, '7900'),
(4809, '2', 2907, 31, 1, '4000'),
(4810, '2', 2908, 8, 1, '9600'),
(4811, '1', 2909, 10, 1, '2100'),
(4812, '1', 2909, 21, 1, '2000'),
(4813, '1', 2909, 3, 2, '5900'),
(4814, '1', 2910, 10, 1, '2100'),
(4815, '1', 2910, 1, 2, '7900'),
(4816, '1', 2910, 18, 1, '2000'),
(4817, '1', 2911, 4, 2, '4800'),
(4818, '1', 2911, 11, 2, '2100'),
(4819, '1', 2912, 35, 1, '1400'),
(4820, '1', 2912, 43, 1, '1300'),
(4821, '1', 2913, 33, 1, '1400'),
(4822, '1', 2914, 42, 1, '1300'),
(4823, '1', 2914, 2, 2, '2000'),
(4824, '1', 2915, 3, 2, '5900'),
(4825, '1', 2916, 1, 2, '7900'),
(4826, '1', 2917, 1, 2, '7900'),
(4827, '1', 2918, 10, 1, '2100'),
(4828, '1', 2918, 3, 2, '5900'),
(4829, '1', 2918, 23, 1, '2000'),
(4830, '1', 2919, 13, 1, '3000'),
(4831, '1', 2919, 25, 1, '2000'),
(4832, '1', 2920, 43, 1, '1300'),
(4833, '1', 2920, 35, 1, '1400'),
(4834, '1', 2921, 31, 1, '2000'),
(4835, '1', 2921, 6, 1, '3200'),
(4836, '1', 2922, 48, 1, '4000'),
(4837, '1', 2923, 11, 1, '2100'),
(4838, '1', 2923, 31, 1, '2000'),
(4839, '1', 2924, 15, 1, '3000'),
(4840, '1', 2925, 20, 1, '2000'),
(4841, '2', 2926, 10, 1, '4200'),
(4842, '1', 2927, 34, 1, '1400'),
(4843, '1', 2927, 41, 1, '1300'),
(4844, '2', 2928, 34, 1, '2800'),
(4845, '1', 2929, 38, 1, '2500'),
(4846, '1', 2929, 3, 2, '5900'),
(4847, '1', 2930, 43, 1, '1300'),
(4848, '1', 2930, 34, 1, '1400'),
(4849, '1', 2931, 1, 2, '7900'),
(4850, '1', 2932, 28, 1, '2000'),
(4851, '1', 2933, 34, 1, '1400'),
(4852, '1', 2934, 18, 2, '2000'),
(4853, '1', 2935, 13, 1, '3000'),
(4854, '2', 2936, 11, 1, '4200'),
(4855, '3', 2937, 10, 1, '6300'),
(4856, '2', 2937, 18, 1, '4000'),
(4857, '1', 2938, 35, 1, '1400'),
(4858, '1', 2938, 44, 1, '2500'),
(4859, '2', 2938, 43, 1, '2600'),
(4860, '1', 2939, 13, 1, '3000'),
(4861, '1', 2940, 20, 1, '2000'),
(4862, '1', 2940, 14, 1, '4000'),
(4863, '1', 2941, 45, 1, '2500'),
(4864, '2', 2941, 35, 1, '2800'),
(4865, '1', 2942, 3, 2, '5900'),
(4866, '1', 2943, 38, 1, '2500'),
(4867, '1', 2943, 3, 2, '5900'),
(4868, '2', 2944, 33, 1, '2800'),
(4869, '2', 2945, 4, 1, '9600'),
(4870, '1', 2945, 34, 1, '1400'),
(4871, '1', 2946, 20, 1, '2000'),
(4872, '1', 2947, 1, 2, '7900'),
(4873, '1', 2948, 1, 2, '7900'),
(4874, '1', 2949, 20, 1, '2000'),
(4875, '1', 2950, 2, 2, '2000'),
(4876, '1', 2951, 1, 2, '7900'),
(4878, '2', 2953, 35, 1, '2800'),
(4879, '3', 2953, 36, 1, '1800'),
(4880, '1', 2954, 12, 1, '2500'),
(4881, '1', 2954, 1, 2, '7900'),
(4882, '1', 2955, 4, 1, '4800'),
(4883, '1', 2955, 31, 1, '2000'),
(4884, '1', 2955, 10, 1, '2100'),
(4885, '2', 2956, 9, 1, '4000'),
(4886, '1', 2957, 22, 1, '2000'),
(4887, '1', 2957, 48, 1, '4000'),
(4888, '1', 2958, 1, 2, '7900'),
(4889, '2', 2959, 37, 1, '4000'),
(4890, '1', 2959, 45, 1, '2500'),
(4891, '1', 2959, 1, 2, '7900'),
(4892, '1', 2960, 33, 1, '1400'),
(4893, '1', 2961, 45, 1, '2500'),
(4894, '1', 2961, 35, 1, '1400'),
(4895, '1', 2962, 1, 2, '7900'),
(4896, '1', 2963, 80, 2, '12600'),
(4897, '1', 2963, 69, 1, '1200'),
(4898, '2', 2964, 33, 1, '2800'),
(4899, '1', 2965, 68, 1, '2000'),
(4900, '1', 2966, 67, 1, '2000'),
(4901, '1', 2966, 28, 1, '2000'),
(4902, '1', 2967, 76, 1, '3000'),
(4903, '1', 2967, 69, 1, '1200'),
(4904, '1', 2968, 53, 1, '2600'),
(4905, '1', 2969, 78, 1, '2500'),
(4906, '1', 2969, 71, 1, '2000'),
(4907, '1', 2969, 72, 1, '1000'),
(4908, '1', 2970, 51, 1, '1800'),
(4909, '1', 2970, 80, 2, '12600'),
(4910, '1', 2971, 78, 1, '2500'),
(4911, '1', 2972, 73, 1, '2000');
INSERT INTO `lineas_pedido` (`idLineas_pedido`, `cantidad`, `idPedido`, `idProducto`, `idMomento`, `precio`) VALUES
(4912, '1', 2972, 80, 2, '12600'),
(4914, '1', 2974, 73, 1, '2000'),
(4915, '1', 2974, 72, 1, '1000'),
(4916, '1', 2975, 69, 1, '1200'),
(4917, '1', 2976, 80, 2, '12600'),
(4918, '1', 2976, 68, 1, '2000'),
(4919, '1', 2977, 74, 1, '2000'),
(4920, '1', 2977, 20, 1, '2000'),
(4921, '1', 2978, 54, 1, '2500'),
(4922, '1', 2978, 49, 2, '6000'),
(4923, '1', 2979, 78, 1, '2500'),
(4924, '1', 2980, 33, 1, '1400'),
(4925, '1', 2979, 57, 1, '1400'),
(4926, '2', 2981, 72, 1, '2000'),
(4927, '2', 2981, 51, 1, '3600'),
(4928, '1', 2982, 1, 2, '7900'),
(4929, '1', 2983, 66, 1, '2500'),
(4930, '2', 2984, 57, 1, '2800'),
(4931, '1', 2985, 58, 1, '1200'),
(4932, '1', 2985, 69, 1, '1200'),
(4934, '3', 2986, 70, 1, '3600'),
(4935, '1', 2987, 71, 1, '2000'),
(4936, '1', 2987, 63, 1, '3500'),
(4937, '1', 2988, 69, 1, '1200'),
(4938, '1', 2988, 71, 1, '2000'),
(4939, '1', 2989, 50, 1, '1800'),
(4940, '1', 2989, 80, 2, '12600'),
(4941, '1', 2990, 68, 1, '2000'),
(4942, '1', 2991, 73, 1, '2000'),
(4943, '1', 2991, 70, 1, '1200'),
(4944, '1', 2992, 84, 2, '12600'),
(4945, '2', 2993, 33, 1, '2800'),
(4946, '1', 2994, 66, 1, '2500'),
(4947, '1', 2994, 77, 1, '1500'),
(4948, '1', 2995, 66, 1, '2500'),
(4949, '1', 2995, 3, 2, '5900'),
(4950, '1', 2996, 52, 1, '3500'),
(4951, '1', 2996, 80, 2, '12600'),
(4952, '1', 2997, 59, 1, '1600'),
(4953, '1', 2997, 71, 1, '2000'),
(4954, '1', 2997, 2, 2, '2000'),
(4955, '1', 2998, 66, 1, '2500'),
(4956, '1', 2998, 69, 1, '1200'),
(4957, '1', 2999, 80, 2, '12600'),
(4958, '1', 3000, 73, 1, '2000'),
(4959, '1', 3000, 72, 1, '1000'),
(4960, '1', 3001, 66, 1, '2500'),
(4961, '1', 3001, 3, 2, '5900'),
(4962, '1', 3002, 1, 2, '7900'),
(4963, '1', 3003, 1, 2, '7900'),
(4964, '1', 3004, 31, 1, '2000'),
(4965, '1', 3004, 27, 1, '2000'),
(4966, '1', 3005, 80, 2, '12600'),
(4967, '1', 3006, 57, 1, '1400'),
(4968, '1', 3007, 35, 1, '1400'),
(4969, '1', 3007, 43, 1, '1300'),
(4970, '1', 3008, 73, 1, '2000'),
(4971, '1', 3008, 66, 1, '2500'),
(4972, '1', 3009, 80, 2, '12600'),
(4973, '1', 3010, 66, 1, '2500'),
(4974, '1', 3011, 78, 1, '2500'),
(4975, '1', 3012, 73, 1, '2000'),
(4976, '2', 3013, 52, 1, '7000'),
(4977, '1', 3013, 45, 1, '2500'),
(4978, '1', 3014, 75, 1, '3000'),
(4979, '4', 3015, 33, 1, '5600'),
(4980, '1', 3016, 57, 1, '1400'),
(4981, '1', 3017, 77, 1, '1500'),
(4982, '1', 3017, 66, 1, '2500'),
(4983, '1', 3017, 80, 2, '12600'),
(4984, '1', 3018, 71, 1, '2000'),
(4985, '1', 3019, 66, 1, '2500'),
(4986, '1', 3019, 80, 2, '12600'),
(4987, '1', 3020, 66, 1, '2500'),
(4988, '1', 3021, 23, 2, '2000'),
(4989, '1', 3021, 4, 2, '4800'),
(4990, '1', 3021, 77, 1, '1500'),
(4991, '1', 3021, 68, 1, '2000'),
(4992, '1', 3022, 67, 1, '2000'),
(4993, '1', 3022, 77, 1, '1500'),
(4994, '1', 3023, 83, 2, '12600'),
(4995, '1', 3023, 73, 1, '2000'),
(4996, '1', 3023, 72, 1, '1000'),
(4997, '1', 3024, 65, 1, '2500'),
(4998, '1', 3024, 83, 2, '12600'),
(4999, '1', 3025, 50, 1, '1800'),
(5000, '1', 3025, 84, 2, '12600'),
(5001, '1', 3025, 44, 1, '2500'),
(5002, '1', 3026, 84, 2, '12600'),
(5003, '1', 3027, 73, 1, '2000'),
(5004, '1', 3027, 1, 2, '7900'),
(5005, '1', 3028, 75, 1, '3000'),
(5006, '2', 3029, 33, 1, '2800'),
(5007, '1', 3030, 2, 2, '2000'),
(5008, '1', 3031, 84, 2, '12600'),
(5009, '1', 3032, 73, 1, '2000'),
(5010, '1', 3032, 84, 2, '12600'),
(5011, '1', 3032, 71, 1, '2000'),
(5012, '1', 3033, 54, 1, '2500'),
(5013, '1', 3034, 66, 1, '2500'),
(5014, '1', 3035, 66, 1, '2500'),
(5015, '1', 3035, 70, 1, '1200'),
(5016, '1', 3035, 77, 1, '1500'),
(5017, '1', 3035, 24, 2, '2000'),
(5018, '2', 3035, 10, 2, '4200'),
(5019, '1', 3036, 7, 2, '5000'),
(5020, '1', 3036, 22, 2, '2000'),
(5021, '1', 3037, 4, 2, '4800'),
(5022, '1', 3038, 66, 1, '2500'),
(5023, '1', 3038, 43, 1, '1300'),
(5024, '1', 3039, 77, 1, '1500'),
(5025, '1', 3040, 73, 1, '2000'),
(5026, '1', 3041, 72, 1, '1000'),
(5027, '1', 3041, 71, 1, '2000'),
(5028, '2', 3041, 73, 1, '4000'),
(5029, '1', 3039, 73, 1, '2000'),
(5030, '1', 3039, 76, 1, '3000'),
(5031, '1', 3042, 80, 2, '12600'),
(5032, '1', 3043, 72, 1, '1000'),
(5033, '1', 3043, 73, 1, '2000'),
(5034, '1', 3044, 80, 2, '12600'),
(5035, '1', 3045, 71, 1, '2000'),
(5036, '1', 3045, 77, 1, '1500'),
(5037, '1', 3045, 70, 1, '1200'),
(5038, '1', 3046, 84, 2, '12600'),
(5039, '1', 3047, 2, 2, '2000'),
(5040, '1', 3048, 58, 1, '1200'),
(5041, '1', 3048, 71, 1, '2000'),
(5042, '2', 3049, 68, 2, '4000'),
(5043, '1', 3050, 48, 1, '4000'),
(5044, '1', 3050, 45, 1, '2500'),
(5045, '1', 3051, 34, 1, '1400'),
(5046, '6', 3052, 36, 1, '3600'),
(5047, '1', 3053, 52, 1, '3500'),
(5048, '1', 3054, 68, 1, '2000'),
(5049, '1', 3055, 81, 2, '12600'),
(5050, '1', 3056, 66, 1, '2500'),
(5051, '1', 3057, 66, 1, '2500'),
(5052, '1', 3058, 3, 2, '5900'),
(5053, '1', 3059, 73, 1, '2000'),
(5054, '1', 3059, 1, 2, '7900'),
(5055, '1', 3060, 73, 1, '2000'),
(5056, '1', 3061, 73, 1, '2000'),
(5057, '1', 3061, 72, 1, '1000'),
(5058, '1', 3062, 66, 1, '2500'),
(5059, '1', 3063, 78, 1, '2500'),
(5060, '1', 3063, 72, 1, '1000'),
(5061, '1', 3063, 77, 1, '1500'),
(5062, '1', 3063, 80, 2, '12600'),
(5063, '1', 3064, 45, 1, '2500'),
(5064, '1', 3064, 35, 1, '1400'),
(5065, '1', 3065, 10, 1, '2100'),
(5066, '1', 3065, 18, 1, '2000'),
(5067, '1', 3066, 62, 1, '6000'),
(5068, '2', 3067, 69, 1, '2400'),
(5069, '1', 3068, 77, 1, '1500'),
(5070, '1', 3068, 71, 1, '2000'),
(5071, '2', 3069, 81, 2, '25200'),
(5072, '1', 3070, 84, 2, '12600'),
(5073, '1', 3070, 78, 1, '2500'),
(5074, '1', 3070, 77, 1, '1500'),
(5075, '1', 3071, 12, 1, '2500'),
(5076, '1', 3072, 73, 1, '2000'),
(5077, '1', 3073, 77, 1, '1500'),
(5078, '1', 3073, 69, 1, '1200'),
(5079, '1', 3074, 77, 1, '1500'),
(5080, '1', 3074, 66, 1, '2500'),
(5081, '1', 3075, 67, 1, '2000'),
(5082, '1', 3075, 72, 1, '1000'),
(5083, '1', 3076, 3, 2, '5900'),
(5084, '1', 3077, 66, 1, '2500'),
(5085, '1', 3077, 71, 1, '2000'),
(5086, '1', 3077, 58, 1, '1200'),
(5087, '1', 3078, 66, 1, '2500'),
(5088, '1', 3079, 1, 2, '7900'),
(5089, '1', 3079, 69, 1, '1200'),
(5090, '1', 3079, 66, 1, '2500'),
(5091, '1', 3080, 73, 1, '2000'),
(5092, '1', 3080, 84, 2, '12600'),
(5093, '1', 3080, 72, 1, '1000'),
(5094, '1', 3081, 3, 2, '5900'),
(5095, '1', 3082, 84, 2, '12600'),
(5096, '1', 3082, 77, 1, '1500'),
(5097, '1', 3082, 71, 1, '2000'),
(5098, '1', 3083, 8, 1, '4800'),
(5099, '1', 3083, 28, 1, '2000'),
(5100, '1', 3083, 1, 2, '7900'),
(5101, '2', 3084, 33, 2, '2800'),
(5102, '2', 3084, 4, 2, '9600'),
(5103, '6', 3085, 36, 1, '3600'),
(5104, '3', 3086, 33, 1, '4200'),
(5105, '1', 3087, 76, 1, '3000'),
(5106, '1', 3088, 73, 1, '2000'),
(5107, '1', 3089, 66, 1, '2500'),
(5108, '1', 3090, 68, 1, '2000'),
(5109, '1', 3090, 77, 1, '1500'),
(5110, '1', 3091, 72, 1, '1000'),
(5111, '1', 3091, 59, 1, '1600'),
(5112, '1', 3091, 24, 1, '2000'),
(5113, '1', 3085, 84, 2, '12600'),
(5114, '1', 3092, 57, 1, '1400'),
(5115, '1', 3093, 68, 1, '2000'),
(5116, '1', 3093, 66, 1, '2500'),
(5117, '1', 3094, 53, 1, '2600'),
(5118, '1', 3094, 45, 1, '2500'),
(5119, '1', 3095, 1, 2, '7900'),
(5120, '1', 3096, 72, 1, '1000'),
(5121, '1', 3096, 73, 1, '2000'),
(5122, '1', 3097, 3, 2, '5900'),
(5123, '1', 3098, 65, 1, '2500'),
(5124, '1', 3098, 68, 1, '2000'),
(5125, '1', 3099, 8, 1, '4800'),
(5126, '1', 3099, 28, 1, '2000'),
(5127, '1', 3100, 80, 2, '12600'),
(5128, '1', 3101, 77, 1, '1500'),
(5129, '2', 3101, 58, 1, '2400'),
(5130, '1', 3102, 77, 1, '1500'),
(5131, '1', 3102, 66, 1, '2500'),
(5132, '1', 3102, 70, 1, '1200'),
(5133, '1', 3102, 14, 2, '4000'),
(5134, '2', 3103, 69, 1, '2400'),
(5135, '1', 3103, 4, 2, '4800'),
(5136, '1', 3104, 67, 1, '2000'),
(5137, '2', 3104, 69, 1, '2400'),
(5138, '1', 3104, 84, 2, '12600'),
(5139, '1', 3105, 63, 1, '3500'),
(5140, '1', 3105, 84, 2, '12600'),
(5141, '1', 3106, 1, 2, '7900'),
(5142, '1', 3107, 73, 1, '2000'),
(5143, '1', 3108, 73, 1, '2000'),
(5144, '1', 3108, 72, 1, '1000'),
(5145, '1', 3109, 20, 1, '2000'),
(5146, '1', 3110, 3, 2, '5900'),
(5147, '1', 3110, 21, 1, '2000'),
(5148, '2', 3111, 69, 1, '2400'),
(5149, '1', 3111, 77, 1, '1500'),
(5150, '2', 3112, 69, 1, '2400'),
(5151, '1', 3113, 72, 1, '1000'),
(5152, '1', 3113, 20, 1, '2000'),
(5153, '1', 3113, 80, 2, '12600'),
(5154, '1', 3114, 66, 1, '2500'),
(5155, '1', 3114, 84, 2, '12600'),
(5156, '1', 3115, 12, 1, '2500'),
(5157, '2', 3115, 35, 1, '2800'),
(5158, '1', 3115, 2, 2, '2000'),
(5159, '1', 3116, 4, 2, '4800'),
(5160, '2', 3116, 70, 1, '2400'),
(5161, '1', 3117, 84, 2, '12600'),
(5162, '1', 3118, 28, 1, '2000'),
(5163, '1', 3118, 4, 1, '4800'),
(5164, '1', 3119, 3, 2, '5900'),
(5165, '1', 3119, 69, 2, '1200'),
(5166, '1', 3120, 21, 1, '2000'),
(5167, '1', 3120, 3, 2, '5900'),
(5168, '2', 3121, 33, 1, '2800'),
(5169, '1', 3122, 70, 1, '1200'),
(5170, '1', 3122, 66, 1, '2500'),
(5171, '2', 3123, 69, 1, '2400'),
(5172, '1', 3124, 76, 1, '3000'),
(5173, '1', 3124, 77, 1, '1500'),
(5174, '1', 3124, 80, 2, '12600'),
(5175, '1', 3125, 34, 1, '1400'),
(5176, '1', 3126, 66, 1, '2500'),
(5177, '1', 3127, 73, 1, '2000'),
(5178, '1', 3128, 71, 1, '2000'),
(5179, '1', 3128, 73, 1, '2000'),
(5180, '2', 3129, 66, 1, '5000'),
(5181, '1', 3129, 68, 1, '2000'),
(5182, '1', 3130, 77, 1, '1500'),
(5183, '1', 3130, 14, 2, '4000'),
(5184, '1', 3130, 65, 1, '2500'),
(5185, '2', 3131, 69, 1, '2400'),
(5186, '1', 3131, 73, 1, '2000'),
(5187, '1', 3131, 71, 1, '2000'),
(5188, '1', 3132, 71, 1, '2000'),
(5189, '1', 3132, 13, 1, '3000'),
(5190, '1', 3133, 33, 1, '1400'),
(5191, '1', 3133, 80, 2, '12600'),
(5192, '1', 3134, 72, 1, '1000'),
(5193, '1', 3134, 78, 1, '2500'),
(5194, '1', 3134, 73, 1, '2000'),
(5195, '2', 3135, 66, 1, '5000'),
(5196, '1', 3136, 84, 2, '12600'),
(5197, '1', 3137, 66, 1, '2500'),
(5198, '1', 3137, 69, 1, '1200'),
(5199, '1', 3138, 78, 1, '2500'),
(5200, '2', 3138, 69, 1, '2400'),
(5201, '1', 3139, 80, 2, '12600'),
(5202, '1', 3140, 77, 1, '1500'),
(5203, '1', 3140, 69, 1, '1200'),
(5204, '1', 3140, 66, 1, '2500'),
(5205, '1', 3141, 3, 2, '5900'),
(5206, '1', 3140, 80, 2, '12600'),
(5207, '1', 3142, 3, 2, '5900'),
(5208, '1', 3143, 84, 2, '12600'),
(5209, '1', 3143, 66, 1, '2500'),
(5210, '1', 3143, 70, 1, '1200'),
(5211, '1', 3143, 77, 1, '1500'),
(5212, '1', 3144, 1, 2, '7900'),
(5213, '1', 3145, 80, 2, '12600'),
(5214, '1', 3146, 84, 2, '12600'),
(5215, '1', 3146, 74, 1, '2000'),
(5216, '1', 3146, 73, 1, '2000'),
(5217, '1', 3147, 81, 2, '12600'),
(5218, '3', 3148, 31, 1, '6000'),
(5219, '1', 3149, 3, 2, '5900'),
(5220, '1', 3150, 63, 1, '3500'),
(5221, '1', 3151, 66, 1, '2500'),
(5222, '5', 3152, 70, 1, '6000'),
(5223, '1', 3153, 73, 1, '2000'),
(5224, '1', 3153, 84, 2, '12600'),
(5225, '1', 3154, 1, 2, '7900'),
(5226, '1', 3155, 66, 1, '2500'),
(5227, '1', 3155, 73, 2, '2000'),
(5228, '1', 3155, 69, 1, '1200'),
(5229, '1', 3156, 74, 1, '2000'),
(5230, '3', 3157, 69, 1, '3600'),
(5231, '1', 3158, 84, 2, '12600'),
(5232, '1', 3158, 66, 1, '2500'),
(5233, '1', 3159, 3, 2, '5900'),
(5234, '1', 3159, 21, 1, '2000'),
(5235, '1', 3160, 66, 1, '2500'),
(5236, '1', 3161, 63, 1, '3500'),
(5237, '1', 3162, 71, 1, '2000'),
(5238, '1', 3162, 72, 1, '1000'),
(5239, '1', 3162, 77, 1, '1500'),
(5240, '1', 3162, 83, 2, '12600'),
(5241, '2', 3163, 71, 1, '4000'),
(5242, '2', 3163, 77, 1, '3000'),
(5243, '2', 3163, 72, 1, '2000'),
(5244, '1', 3163, 63, 1, '3500'),
(5245, '1', 3163, 14, 2, '4000'),
(5246, '1', 3163, 58, 1, '1200'),
(5247, '1', 3164, 84, 2, '12600'),
(5248, '2', 3165, 69, 1, '2400'),
(5249, '2', 3165, 1, 2, '15800'),
(5250, '1', 3166, 17, 2, '5000'),
(5251, '1', 3166, 27, 2, '2000'),
(5252, '1', 3167, 63, 2, '3500'),
(5253, '1', 3167, 52, 2, '3500'),
(5254, '4', 3168, 34, 1, '5600'),
(5255, '1', 3169, 1, 2, '7900'),
(5256, '1', 3169, 28, 1, '2000'),
(5257, '1', 3169, 8, 1, '4800'),
(5258, '1', 3170, 1, 2, '7900'),
(5259, '2', 3171, 35, 1, '2800'),
(5260, '1', 3171, 45, 1, '2500'),
(5261, '1', 3172, 3, 2, '5900'),
(5262, '1', 3172, 21, 1, '2000'),
(5263, '1', 3173, 35, 1, '1400'),
(5264, '2', 3173, 36, 1, '1200'),
(5265, '1', 3174, 66, 1, '2500'),
(5266, '1', 3174, 83, 2, '12600'),
(5267, '1', 3175, 12, 1, '2500'),
(5268, '1', 3175, 75, 1, '3000'),
(5269, '1', 3176, 77, 1, '1500'),
(5270, '1', 3176, 14, 2, '4000'),
(5271, '1', 3176, 66, 1, '2500'),
(5272, '1', 3177, 76, 1, '3000'),
(5273, '1', 3173, 63, 1, '3500'),
(5274, '2', 3178, 7, 2, '10000'),
(5275, '1', 3179, 80, 2, '12600'),
(5276, '1', 3180, 69, 1, '1200'),
(5277, '1', 3181, 4, 1, '4800'),
(5278, '1', 3181, 28, 1, '2000'),
(5279, '1', 3181, 82, 2, '12600'),
(5280, '1', 3182, 69, 1, '1200'),
(5281, '1', 3182, 66, 1, '2500'),
(5282, '1', 3183, 3, 2, '5900'),
(5283, '2', 3184, 69, 1, '2400'),
(5284, '1', 3184, 67, 1, '2000'),
(5285, '1', 3184, 77, 1, '1500'),
(5286, '1', 3184, 1, 2, '7900'),
(5287, '2', 3185, 28, 2, '4000'),
(5288, '1', 3186, 33, 1, '1400'),
(5289, '1', 3181, 50, 1, '1800'),
(5290, '1', 3181, 21, 1, '2000'),
(5291, '1', 3187, 65, 1, '2500'),
(5292, '1', 3187, 77, 1, '1500'),
(5293, '1', 3187, 73, 1, '2000'),
(5294, '1', 3188, 73, 1, '2000'),
(5295, '1', 3188, 83, 2, '12600'),
(5296, '1', 3189, 63, 1, '3500'),
(5297, '3', 3190, 70, 1, '3600'),
(5298, '1', 3190, 69, 1, '1200'),
(5299, '1', 3190, 66, 1, '2500'),
(5300, '2', 3190, 77, 1, '3000'),
(5301, '2', 3190, 84, 2, '25200'),
(5302, '1', 3191, 77, 1, '1500'),
(5303, '1', 3191, 74, 1, '2000'),
(5304, '1', 3191, 69, 1, '1200'),
(5305, '2', 3192, 36, 1, '1200'),
(5306, '2', 3192, 33, 1, '2800'),
(5307, '1', 3193, 81, 2, '12600'),
(5308, '2', 3194, 45, 1, '5000'),
(5309, '2', 3194, 33, 1, '2800'),
(5310, '1', 3195, 66, 1, '2500'),
(5311, '1', 3195, 77, 1, '1500'),
(5312, '2', 3195, 69, 1, '2400'),
(5313, '1', 3196, 66, 1, '2500'),
(5314, '1', 3196, 80, 2, '12600'),
(5315, '2', 3196, 70, 1, '2400'),
(5316, '1', 3197, 65, 1, '2500'),
(5317, '1', 3197, 68, 1, '2000'),
(5318, '1', 3197, 77, 1, '1500'),
(5319, '1', 3198, 81, 2, '12600'),
(5320, '1', 3199, 73, 1, '2000'),
(5321, '1', 3199, 72, 1, '1000'),
(5322, '1', 3200, 82, 2, '12600'),
(5323, '1', 3193, 66, 1, '2500'),
(5324, '1', 3201, 38, 1, '2500'),
(5325, '1', 3201, 51, 1, '1800'),
(5326, '1', 3201, 60, 1, '2000'),
(5327, '2', 3202, 73, 1, '4000'),
(5328, '1', 3202, 82, 2, '12600'),
(5329, '1', 3202, 64, 1, '6000'),
(5330, '1', 3203, 66, 1, '2500'),
(5331, '1', 3203, 71, 1, '2000'),
(5332, '1', 3204, 74, 1, '2000'),
(5333, '1', 3204, 1, 2, '7900'),
(5334, '3', 3205, 70, 1, '3600'),
(5335, '1', 3205, 68, 1, '2000'),
(5336, '1', 3206, 20, 1, '2000'),
(5337, '1', 3207, 78, 1, '2500'),
(5338, '1', 3207, 77, 1, '1500'),
(5339, '1', 3208, 82, 2, '12600'),
(5340, '1', 3207, 72, 1, '1000'),
(5341, '1', 3209, 74, 1, '2000'),
(5342, '1', 3209, 77, 1, '1500'),
(5343, '1', 3209, 1, 2, '7900'),
(5344, '1', 3210, 13, 1, '3000'),
(5345, '1', 3210, 77, 1, '1500'),
(5346, '1', 3211, 73, 1, '2000'),
(5347, '1', 3212, 80, 2, '12600'),
(5348, '1', 3212, 70, 1, '1200'),
(5349, '1', 3213, 76, 1, '3000'),
(5350, '1', 3213, 72, 1, '1000'),
(5351, '3', 3214, 33, 1, '4200'),
(5352, '1', 3215, 21, 1, '2000'),
(5353, '1', 3207, 84, 2, '12600'),
(5354, '1', 3216, 74, 1, '2000'),
(5355, '1', 3216, 77, 1, '1500'),
(5356, '1', 3217, 66, 1, '2500'),
(5357, '1', 3217, 77, 1, '1500'),
(5360, '1', 3219, 72, 1, '1000'),
(5361, '1', 3219, 73, 1, '2000'),
(5362, '1', 3219, 70, 1, '1200'),
(5363, '2', 3220, 36, 1, '1200'),
(5364, '1', 3220, 84, 2, '12600'),
(5365, '2', 3220, 35, 1, '2800'),
(5366, '1', 3221, 18, 1, '2000'),
(5367, '1', 3222, 3, 2, '5900'),
(5368, '1', 3222, 21, 1, '2000'),
(5369, '2', 3223, 77, 1, '3000'),
(5370, '1', 3224, 4, 2, '4800'),
(5371, '2', 3224, 34, 1, '2800'),
(5372, '1', 3225, 71, 1, '2000'),
(5373, '1', 3223, 66, 1, '2500'),
(5374, '3', 3226, 52, 1, '10500'),
(5375, '1', 3227, 81, 2, '12600'),
(5376, '1', 3228, 1, 2, '7900'),
(5377, '1', 3228, 69, 1, '1200'),
(5378, '1', 3229, 52, 1, '3500'),
(5379, '1', 3229, 55, 1, '2500'),
(5380, '1', 3230, 73, 1, '2000'),
(5381, '1', 3231, 1, 2, '7900'),
(5382, '1', 3231, 61, 1, '3500'),
(5383, '1', 3232, 35, 1, '1400'),
(5384, '1', 3233, 21, 1, '2000'),
(5385, '1', 3233, 4, 1, '4800'),
(5386, '1', 3233, 3, 2, '5900'),
(5387, '1', 3234, 22, 2, '2000'),
(5388, '1', 3234, 7, 2, '5000'),
(5389, '1', 3235, 77, 1, '1500'),
(5390, '2', 3236, 72, 1, '2000'),
(5391, '1', 3237, 55, 1, '2500'),
(5392, '1', 3238, 17, 1, '5000'),
(5393, '1', 3238, 80, 2, '12600'),
(5394, '1', 3239, 84, 2, '12600'),
(5395, '1', 3240, 16, 1, '2000'),
(5396, '1', 3241, 80, 2, '12600'),
(5397, '1', 3242, 33, 1, '1400'),
(5398, '1', 3243, 84, 2, '12600'),
(5399, '1', 3244, 1, 2, '7900'),
(5400, '1', 3245, 70, 1, '1200'),
(5401, '1', 3246, 35, 1, '1400'),
(5402, '1', 3246, 43, 1, '1300'),
(5403, '1', 3246, 44, 1, '2500'),
(5404, '2', 3247, 74, 1, '4000'),
(5405, '1', 3247, 77, 1, '1500'),
(5406, '2', 3248, 70, 1, '2400'),
(5407, '1', 3248, 77, 1, '1500'),
(5408, '1', 3249, 8, 2, '4800'),
(5409, '1', 3249, 23, 2, '2000'),
(5410, '1', 3250, 84, 2, '12600'),
(5411, '1', 3251, 33, 1, '1400'),
(5412, '1', 3251, 34, 1, '1400'),
(5413, '2', 3252, 35, 1, '2800'),
(5414, '1', 3253, 63, 1, '3500'),
(5415, '1', 3253, 1, 2, '7900'),
(5416, '1', 3254, 21, 1, '2000'),
(5417, '1', 3255, 20, 1, '2000'),
(5418, '1', 3255, 77, 1, '1500'),
(5419, '1', 3255, 73, 1, '2000'),
(5420, '1', 3256, 66, 1, '2500'),
(5421, '1', 3256, 82, 2, '12600'),
(5422, '1', 3256, 77, 1, '1500'),
(5423, '1', 3257, 72, 1, '1000');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `momento`
--

CREATE TABLE `momento` (
  `idmomento` tinyint(4) NOT NULL,
  `momento` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `momento`
--

INSERT INTO `momento` (`idmomento`, `momento`) VALUES
(1, 'Desayuno'),
(2, 'Almuerzo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `motivo`
--

CREATE TABLE `motivo` (
  `idMotivo` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `motivo`
--

INSERT INTO `motivo` (`idMotivo`, `nombre`, `estado`) VALUES
(1, 'Renuncia', 1),
(2, 'Terminación de contrato', 1),
(3, 'Vinculación Colcircuitos', 1),
(4, 'Abandono de trabajo', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `municipio`
--

CREATE TABLE `municipio` (
  `idMunicipio` tinyint(4) NOT NULL,
  `nombre` varchar(25) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `municipio`
--

INSERT INTO `municipio` (`idMunicipio`, `nombre`, `estado`) VALUES
(1, 'Medellin', 1),
(2, 'Bello', 1),
(3, 'Itagüí', 1),
(4, 'Envigado', 1),
(5, 'Caldas', 1),
(6, 'Copacabana', 1),
(7, 'La Estrella', 1),
(8, 'Girardota', 1),
(9, 'Sabaneta', 1),
(10, 'Barbosa', 1),
(11, 'La ceja', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificacion`
--

CREATE TABLE `notificacion` (
  `idNotificacion` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `comentario` varchar(100) NOT NULL,
  `leido` tinyint(1) NOT NULL,
  `idUsuario` tinyint(4) NOT NULL,
  `idTipo_notificacion` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `notificacion`
--

INSERT INTO `notificacion` (`idNotificacion`, `fecha`, `comentario`, `leido`, `idUsuario`, `idTipo_notificacion`) VALUES
(3, '2018-06-25 06:14:13', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(4, '2018-06-26 06:26:41', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(5, '2018-06-27 06:11:49', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(6, '2018-06-28 06:30:01', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(7, '2018-06-29 06:02:53', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(8, '2018-07-03 06:07:56', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(9, '2018-07-04 06:06:51', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(10, '2018-07-05 06:33:15', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(11, '2018-07-06 10:24:46', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(12, '2018-07-09 06:17:20', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(13, '2018-07-10 06:35:52', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(14, '2018-07-11 06:08:50', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(15, '2018-07-12 06:15:52', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(16, '2018-07-13 06:12:11', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(17, '2018-07-16 06:25:39', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(18, '2018-07-17 06:05:59', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(19, '2018-07-18 06:12:16', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(20, '2018-07-19 06:11:45', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(21, '2018-07-23 06:13:42', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(22, '2018-07-24 06:08:06', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(23, '2018-07-25 06:09:02', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(24, '2018-07-26 06:11:26', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(25, '2018-07-27 06:04:22', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(26, '2018-08-01 06:29:49', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(27, '2018-10-02 10:46:55', 'El dia de hoy 6 llego/aron tarde...', 1, 7, 4),
(28, '2018-10-03 06:19:58', 'El dia de hoy 12 llego/aron tarde...', 1, 7, 4),
(29, '2018-10-04 06:15:51', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(30, '2018-10-05 08:44:30', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(31, '2018-10-08 06:26:41', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(32, '2018-10-09 06:06:53', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(33, '2018-10-10 06:17:59', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(34, '2018-10-11 07:41:21', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(35, '2018-10-12 06:21:42', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(36, '2018-10-16 06:20:00', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(37, '2018-11-30 00:00:00', '5 personas están cumpliendo años...', 1, 7, 1),
(38, '2018-10-22 00:00:00', '5 personas tienen contrato proximo a vencer...', 1, 7, 3),
(39, '2018-10-18 00:00:00', '2 personas cumplen aniversario...', 1, 7, 2),
(40, '2018-10-18 07:28:28', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(41, '2018-10-19 06:22:15', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(42, '2018-10-22 07:10:24', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(53, '2018-10-22 12:40:18', 'Hoy es el aniversario de 1 persona/s en la empresa', 1, 7, 2),
(54, '2018-10-22 12:40:18', '1 Contratos proximos a vencer...', 1, 7, 3),
(55, '2018-10-22 12:40:18', 'Hoy es el aniversario de 1 persona/s en la empresa', 1, 22, 2),
(56, '2018-10-22 12:40:18', '1 Contratos proximos a vencer...', 1, 22, 3),
(60, '2018-10-22 15:19:02', '1 nuevo/s Empleado/s', 1, 7, 5),
(61, '2018-10-22 15:19:02', '1 nuevo/s Empleado/s', 1, 21, 5),
(62, '2018-10-22 15:19:02', '1 nuevo/s Empleado/s', 1, 22, 5),
(63, '2018-10-23 06:31:18', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(64, '2018-10-24 06:09:25', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(65, '2018-10-25 10:38:46', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(66, '2018-10-26 06:37:05', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(67, '2018-10-29 06:05:38', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(68, '2018-10-30 06:06:13', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(69, '2018-10-31 06:12:07', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(70, '2018-11-01 06:16:47', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(71, '2018-11-02 06:17:37', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(72, '2018-11-06 06:23:56', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(73, '2018-11-07 10:56:59', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(74, '2018-11-07 17:14:17', '1 nuevo/s Empleado/s', 1, 7, 5),
(75, '2018-11-07 17:14:17', '1 nuevo/s Empleado/s', 1, 21, 5),
(76, '2018-11-07 17:14:17', '1 nuevo/s Empleado/s', 1, 22, 5),
(77, '2018-11-08 07:23:26', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(78, '2018-11-09 14:59:10', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(79, '2018-11-13 06:03:31', 'El dia de hoy 18 llego/aron tarde...', 1, 7, 4),
(80, '2018-11-13 07:53:47', '1 nuevo/s Empleado/s', 1, 7, 5),
(81, '2018-11-13 07:53:48', '1 nuevo/s Empleado/s', 1, 21, 5),
(82, '2018-11-13 07:53:48', '1 nuevo/s Empleado/s', 1, 22, 5),
(83, '2018-11-13 07:53:48', '1 nuevo/s Empleado/s', 1, 24, 5),
(84, '2018-11-13 07:53:48', '1 nuevo/s Empleado/s', 1, 25, 5),
(85, '2018-11-13 07:53:48', '1 nuevo/s Empleado/s', 1, 26, 5),
(86, '2018-11-14 06:00:05', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(87, '2018-11-15 06:00:01', 'El dia de hoy 7 llego/aron tarde...', 1, 7, 4),
(88, '2018-11-16 06:00:13', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(89, '2018-11-19 06:00:15', 'El dia de hoy 14 llego/aron tarde...', 1, 7, 4),
(90, '2018-11-20 06:25:20', 'El dia de hoy 10 llego/aron tarde...', 1, 7, 4),
(91, '2018-11-21 06:00:57', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(92, '2018-11-22 06:00:04', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(93, '2018-11-23 06:00:52', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(94, '2018-11-26 06:02:31', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(95, '2018-11-27 06:01:05', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(96, '2018-11-28 06:03:40', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(97, '2018-11-29 06:00:52', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(98, '2018-11-30 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(99, '2018-11-30 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(100, '2018-11-30 13:14:59', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(101, '2018-12-03 06:01:27', 'El dia de hoy 6 llego/aron tarde...', 1, 7, 4),
(102, '2018-12-04 06:11:20', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(103, '2018-12-05 06:00:05', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(104, '2018-12-06 06:01:46', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(105, '2018-12-07 08:28:16', 'El dia de hoy 7 llego/aron tarde...', 1, 7, 4),
(106, '2018-12-10 06:06:01', 'El dia de hoy 7 llego/aron tarde...', 1, 7, 4),
(107, '2018-12-11 06:00:15', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(108, '2018-12-11 16:11:43', '1 nuevo/s Empleado/s', 1, 7, 5),
(109, '2018-12-11 16:11:43', '1 nuevo/s Empleado/s', 1, 21, 5),
(110, '2018-12-11 16:11:44', '1 nuevo/s Empleado/s', 1, 22, 5),
(111, '2018-12-11 16:11:44', '1 nuevo/s Empleado/s', 1, 24, 5),
(112, '2018-12-11 16:11:44', '1 nuevo/s Empleado/s', 0, 25, 5),
(113, '2018-12-11 16:11:44', '1 nuevo/s Empleado/s', 0, 26, 5),
(114, '2018-12-11 16:11:44', '1 nuevo/s Empleado/s', 0, 27, 5),
(115, '2018-12-12 06:00:53', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(116, '2018-12-13 06:01:18', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(117, '2018-12-14 06:00:17', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(118, '2018-12-17 06:03:51', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(119, '2018-12-17 07:34:59', '1 nuevo/s Empleado/s', 1, 7, 5),
(120, '2018-12-17 07:34:59', '1 nuevo/s Empleado/s', 1, 21, 5),
(121, '2018-12-17 07:34:59', '1 nuevo/s Empleado/s', 1, 22, 5),
(122, '2018-12-17 07:34:59', '1 nuevo/s Empleado/s', 1, 24, 5),
(123, '2018-12-17 07:34:59', '1 nuevo/s Empleado/s', 0, 25, 5),
(124, '2018-12-17 07:35:00', '1 nuevo/s Empleado/s', 0, 26, 5),
(125, '2018-12-17 07:35:00', '1 nuevo/s Empleado/s', 0, 27, 5),
(126, '2018-12-18 06:02:43', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(127, '2018-12-19 06:02:05', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(128, '2018-12-20 06:00:16', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(129, '2018-12-21 06:01:12', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(130, '2018-12-26 06:02:25', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(131, '2018-12-27 06:00:27', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(132, '2018-12-28 06:30:01', 'Hoy esta/n cumpliendo años 2 persona/s', 1, 7, 1),
(133, '2018-12-28 06:30:01', 'Hoy esta/n cumpliendo años 2 persona/s', 1, 22, 1),
(134, '2018-12-28 06:30:01', 'Hoy esta/n cumpliendo años 2 persona/s', 0, 27, 1),
(135, '2018-12-30 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(136, '2018-12-30 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(137, '2018-12-30 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(138, '2019-01-09 06:03:55', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(139, '2019-01-09 06:30:01', 'Hoy esta/n cumpliendo años 2 persona/s', 1, 7, 1),
(140, '2019-01-09 06:30:01', 'Hoy esta/n cumpliendo años 2 persona/s', 1, 22, 1),
(141, '2019-01-09 06:30:01', 'Hoy esta/n cumpliendo años 2 persona/s', 0, 27, 1),
(142, '2019-01-10 13:10:16', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(143, '2019-01-11 06:01:53', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(144, '2019-01-11 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(145, '2019-01-11 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(146, '2019-01-11 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(147, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 1, 7, 5),
(148, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 1, 21, 5),
(149, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 1, 22, 5),
(150, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 1, 24, 5),
(151, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 0, 25, 5),
(152, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 0, 26, 5),
(153, '2019-01-11 10:23:26', '1 nuevo/s Empleado/s', 0, 27, 5),
(154, '2019-01-14 06:01:15', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(155, '2019-01-14 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(156, '2019-01-14 06:30:03', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(157, '2019-01-14 06:30:03', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(158, '2019-01-15 06:01:04', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(159, '2019-01-16 06:01:44', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(160, '2019-01-16 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(161, '2019-01-16 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(162, '2019-01-16 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(163, '2019-01-17 06:00:25', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(164, '2019-01-21 06:11:09', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(165, '2019-01-21 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(166, '2019-01-21 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(167, '2019-01-21 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(168, '2019-01-22 06:02:20', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(169, '2019-01-23 06:25:50', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(170, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 1, 7, 5),
(171, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 1, 21, 5),
(172, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 1, 22, 5),
(173, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 1, 24, 5),
(174, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 0, 25, 5),
(175, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 0, 26, 5),
(176, '2019-01-25 07:23:02', '1 nuevo/s Empleado/s', 0, 27, 5),
(177, '2019-01-25 16:29:00', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(178, '2019-01-28 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(179, '2019-01-28 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(180, '2019-01-28 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(181, '2019-01-28 13:01:19', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(182, '2019-01-28 14:38:02', '1 nuevo/s Empleado/s', 1, 7, 5),
(183, '2019-01-28 14:38:03', '1 nuevo/s Empleado/s', 1, 21, 5),
(184, '2019-01-28 14:38:03', '1 nuevo/s Empleado/s', 1, 22, 5),
(185, '2019-01-28 14:38:03', '1 nuevo/s Empleado/s', 1, 24, 5),
(186, '2019-01-28 14:38:03', '1 nuevo/s Empleado/s', 0, 25, 5),
(187, '2019-01-28 14:38:03', '1 nuevo/s Empleado/s', 0, 26, 5),
(188, '2019-01-28 14:38:03', '1 nuevo/s Empleado/s', 0, 27, 5),
(189, '2019-01-29 06:00:07', 'El dia de hoy 6 llego/aron tarde...', 1, 7, 4),
(190, '2019-01-30 06:27:02', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(191, '2019-01-30 14:57:09', '1 nuevo/s Empleado/s', 1, 7, 5),
(192, '2019-01-30 14:57:09', '1 nuevo/s Empleado/s', 1, 22, 5),
(193, '2019-01-30 14:57:09', '1 nuevo/s Empleado/s', 1, 24, 5),
(194, '2019-01-30 14:57:09', '1 nuevo/s Empleado/s', 0, 25, 5),
(195, '2019-01-31 06:00:03', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(196, '2019-01-31 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(197, '2019-01-31 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(198, '2019-01-31 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(199, '2019-01-31 17:12:39', '1 nuevo/s Empleado/s', 1, 7, 5),
(200, '2019-01-31 17:12:40', '1 nuevo/s Empleado/s', 1, 22, 5),
(201, '2019-01-31 17:12:40', '1 nuevo/s Empleado/s', 1, 24, 5),
(202, '2019-01-31 17:12:40', '1 nuevo/s Empleado/s', 0, 25, 5),
(203, '2019-02-01 06:01:12', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(204, '2019-02-01 09:20:28', '2 nuevo/s Empleado/s', 1, 7, 5),
(205, '2019-02-01 09:20:28', '2 nuevo/s Empleado/s', 1, 22, 5),
(206, '2019-02-01 09:20:28', '2 nuevo/s Empleado/s', 1, 24, 5),
(207, '2019-02-01 09:20:28', '2 nuevo/s Empleado/s', 0, 25, 5),
(208, '2019-02-04 06:01:15', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(213, '2019-02-04 16:56:17', '1 nuevo/s Empleado/s', 1, 7, 5),
(214, '2019-02-04 16:56:18', '1 nuevo/s Empleado/s', 1, 22, 5),
(215, '2019-02-04 16:56:18', '1 nuevo/s Empleado/s', 1, 24, 5),
(216, '2019-02-04 16:56:18', '1 nuevo/s Empleado/s', 0, 25, 5),
(217, '2019-02-05 06:01:07', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(218, '2019-02-05 08:10:21', '1 nuevo/s Empleado/s', 1, 7, 5),
(219, '2019-02-05 08:10:21', '1 nuevo/s Empleado/s', 1, 22, 5),
(220, '2019-02-05 08:10:21', '1 nuevo/s Empleado/s', 1, 24, 5),
(221, '2019-02-05 08:10:21', '1 nuevo/s Empleado/s', 0, 25, 5),
(222, '2019-02-06 06:02:44', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(223, '2019-02-06 09:15:16', '2 nuevo/s Empleado/s', 1, 7, 5),
(224, '2019-02-06 09:15:16', '2 nuevo/s Empleado/s', 1, 22, 5),
(225, '2019-02-06 09:15:16', '2 nuevo/s Empleado/s', 1, 24, 5),
(226, '2019-02-06 09:15:16', '2 nuevo/s Empleado/s', 0, 25, 5),
(227, '2019-02-07 08:58:59', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(228, '2019-02-08 06:00:48', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(229, '2019-02-08 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(230, '2019-02-08 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(231, '2019-02-08 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(232, '2019-02-09 06:30:03', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(233, '2019-02-09 06:30:03', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(234, '2019-02-09 06:30:03', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(235, '2019-02-11 06:13:35', 'El dia de hoy 28 llego/aron tarde...', 1, 7, 4),
(236, '2019-02-11 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(237, '2019-02-11 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(238, '2019-02-11 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(239, '2019-02-12 06:01:23', 'El dia de hoy 6 llego/aron tarde...', 1, 7, 4),
(240, '2019-02-13 06:00:57', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(241, '2019-02-14 06:02:42', 'El dia de hoy 6 llego/aron tarde...', 1, 7, 4),
(242, '2019-02-15 12:16:41', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(243, '2019-02-16 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(244, '2019-02-16 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(245, '2019-02-16 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(246, '2019-02-17 06:30:00', 'Hoy esta/n cumpliendo años 2 persona/s', 1, 7, 1),
(247, '2019-02-17 06:30:00', 'Hoy esta/n cumpliendo años 2 persona/s', 1, 22, 1),
(248, '2019-02-17 06:30:00', 'Hoy esta/n cumpliendo años 2 persona/s', 0, 27, 1),
(249, '2019-02-18 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(250, '2019-02-18 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(251, '2019-02-18 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(252, '2019-02-18 08:15:13', '1 nuevo/s Empleado/s', 1, 7, 5),
(253, '2019-02-18 08:15:14', '1 nuevo/s Empleado/s', 1, 22, 5),
(254, '2019-02-18 08:15:14', '1 nuevo/s Empleado/s', 1, 24, 5),
(255, '2019-02-18 08:15:14', '1 nuevo/s Empleado/s', 0, 25, 5),
(256, '2019-02-18 09:03:36', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(257, '2019-02-19 09:06:34', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(258, '2019-02-20 06:00:16', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(259, '2019-02-21 06:00:16', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(260, '2019-02-22 06:05:47', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(261, '2019-02-23 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(262, '2019-02-23 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(263, '2019-02-23 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(264, '2019-02-25 06:01:23', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(265, '2019-02-26 06:00:47', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(266, '2019-02-26 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(267, '2019-02-26 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(268, '2019-02-26 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(269, '2019-02-27 06:02:38', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(270, '2019-02-27 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(271, '2019-02-27 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(272, '2019-02-27 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(273, '2019-03-04 06:00:24', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(274, '2019-03-05 06:01:40', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(275, '2019-03-06 06:08:33', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(276, '2019-03-06 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(277, '2019-03-06 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(278, '2019-03-06 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(279, '2019-03-07 06:02:41', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(280, '2019-03-07 10:59:02', '1 nuevo/s Empleado/s', 1, 7, 5),
(281, '2019-03-07 10:59:02', '1 nuevo/s Empleado/s', 1, 22, 5),
(282, '2019-03-07 10:59:02', '1 nuevo/s Empleado/s', 1, 24, 5),
(283, '2019-03-07 10:59:02', '1 nuevo/s Empleado/s', 0, 25, 5),
(284, '2019-03-08 06:00:01', 'El dia de hoy 8 llego/aron tarde...', 1, 7, 4),
(285, '2019-03-09 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(286, '2019-03-09 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(287, '2019-03-09 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(288, '2019-03-11 06:00:11', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(289, '2019-03-12 06:02:23', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(290, '2019-03-13 06:01:50', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(291, '2019-03-13 15:33:17', '1 nuevo/s Empleado/s', 1, 7, 5),
(292, '2019-03-13 15:33:18', '1 nuevo/s Empleado/s', 1, 22, 5),
(293, '2019-03-13 15:33:18', '1 nuevo/s Empleado/s', 1, 24, 5),
(294, '2019-03-13 15:33:18', '1 nuevo/s Empleado/s', 0, 25, 5),
(295, '2019-03-14 06:00:09', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(296, '2019-03-15 09:02:04', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(297, '2019-03-17 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(298, '2019-03-17 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 22, 1),
(299, '2019-03-17 06:30:00', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(300, '2019-03-18 06:00:30', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(301, '2019-03-19 06:00:07', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(302, '2019-03-20 08:31:59', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(303, '2019-03-21 06:00:35', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(304, '2019-03-22 06:00:05', 'El dia de hoy 9 llego/aron tarde...', 1, 7, 4),
(305, '2019-03-26 06:00:01', 'El dia de hoy 8 llego/aron tarde...', 1, 7, 4),
(306, '2019-03-26 06:00:01', 'El dia de hoy 8 llego/aron tarde...', 1, 7, 4),
(307, '2019-03-26 08:23:53', '1 nuevo/s Empleado/s', 1, 7, 5),
(308, '2019-03-26 08:23:54', '1 nuevo/s Empleado/s', 1, 22, 5),
(309, '2019-03-26 08:23:54', '1 nuevo/s Empleado/s', 1, 24, 5),
(310, '2019-03-26 08:23:54', '1 nuevo/s Empleado/s', 0, 25, 5),
(311, '2019-03-27 06:00:34', 'El dia de hoy 7 llego/aron tarde...', 1, 7, 4),
(312, '2019-03-28 06:00:22', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(313, '2019-03-29 06:00:04', 'El dia de hoy 18 llego/aron tarde...', 1, 7, 4),
(314, '2019-04-01 06:00:03', 'El dia de hoy 7 llego/aron tarde...', 1, 7, 4),
(315, '2019-04-02 06:00:01', 'El dia de hoy 28 llego/aron tarde...', 1, 7, 4),
(316, '2019-04-03 06:00:03', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(317, '2019-04-04 06:00:04', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(318, '2019-04-04 07:22:42', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(319, '2019-04-04 07:22:43', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 22, 1),
(320, '2019-04-04 07:22:43', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(321, '2019-04-05 06:02:23', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(322, '2019-04-06 06:15:26', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(323, '2019-04-06 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 1, 7, 1),
(324, '2019-04-06 06:30:01', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 22, 1),
(325, '2019-04-06 06:30:02', 'Hoy esta/n cumpliendo años 1 persona/s', 0, 27, 1),
(326, '2019-04-08 06:00:03', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(327, '2019-04-09 06:00:25', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(328, '2019-04-10 06:00:03', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(329, '2019-04-11 06:05:44', 'El dia de hoy 36 llego/aron tarde...', 1, 7, 4),
(330, '2019-04-12 06:01:10', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(331, '2019-04-15 06:00:53', 'El dia de hoy 4 llego/aron tarde...', 1, 7, 4),
(332, '2019-04-16 06:00:44', 'El dia de hoy 3 llego/aron tarde...', 1, 7, 4),
(333, '2019-04-17 06:00:02', 'El dia de hoy 8 llego/aron tarde...', 1, 7, 4),
(334, '2019-04-22 06:06:41', 'El dia de hoy 38 llego/aron tarde...', 1, 7, 4),
(335, '2019-04-22 07:25:45', '1 nuevo/s Empleado/s', 1, 7, 5),
(336, '2019-04-22 07:25:45', '1 nuevo/s Empleado/s', 0, 22, 5),
(337, '2019-04-22 07:25:45', '1 nuevo/s Empleado/s', 1, 24, 5),
(338, '2019-04-22 07:25:45', '1 nuevo/s Empleado/s', 0, 25, 5),
(339, '2019-04-23 06:00:12', 'El dia de hoy 38 llego/aron tarde...', 1, 7, 4),
(340, '2019-04-24 06:00:04', 'El dia de hoy 37 llego/aron tarde...', 1, 7, 4),
(341, '2019-04-25 06:00:05', 'El dia de hoy 2 llego/aron tarde...', 1, 7, 4),
(342, '2019-04-26 06:00:04', 'El dia de hoy 25 llego/aron tarde...', 1, 7, 4),
(343, '2019-04-27 06:02:50', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(344, '2019-04-29 06:00:01', 'El dia de hoy 5 llego/aron tarde...', 1, 7, 4),
(345, '2019-04-30 06:00:04', 'El dia de hoy 8 llego/aron tarde...', 1, 7, 4),
(346, '2019-05-02 06:30:36', 'El dia de hoy 38 llego/aron tarde...', 1, 7, 4),
(347, '2019-05-02 07:35:30', '2 nuevo/s Empleado/s', 1, 7, 5),
(348, '2019-05-02 07:35:30', '2 nuevo/s Empleado/s', 0, 22, 5),
(349, '2019-05-02 07:35:30', '2 nuevo/s Empleado/s', 1, 24, 5),
(350, '2019-05-02 07:35:30', '2 nuevo/s Empleado/s', 0, 25, 5),
(351, '2019-05-03 10:52:37', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(352, '2019-05-04 11:12:43', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(353, '2019-05-07 08:08:08', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(354, '2019-05-14 07:10:07', 'El dia de hoy 1 llego/aron tarde...', 1, 7, 4),
(355, '2019-05-15 08:43:30', 'El dia de hoy 0 llego/aron tarde...', 1, 7, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `otros`
--

CREATE TABLE `otros` (
  `idOtros` smallint(6) NOT NULL,
  `talla_camisa` varchar(4) DEFAULT NULL,
  `talla_pantalon` varchar(2) DEFAULT NULL,
  `talla_zapatos` varchar(2) DEFAULT NULL,
  `vigencia_curso_alturas` varchar(20) NOT NULL,
  `brigadas` tinyint(1) NOT NULL,
  `comites` tinyint(1) NOT NULL,
  `necesitaCALT` tinyint(1) NOT NULL,
  `locker` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `otros`
--

INSERT INTO `otros` (`idOtros`, `talla_camisa`, `talla_pantalon`, `talla_zapatos`, `vigencia_curso_alturas`, `brigadas`, `comites`, `necesitaCALT`, `locker`) VALUES
(1, 'L', '30', '40', '', 0, 0, 0, '44'),
(2, 'S', '6', '36', '', 1, 0, 0, NULL),
(3, 'S', '30', '37', '', 0, 0, 0, NULL),
(4, 'M', '10', '36', '', 0, 0, 1, '32'),
(5, 'M', '34', '43', '', 1, 0, 0, NULL),
(6, 'S', '8', '39', 'NO', 1, 0, 1, NULL),
(7, 'M', '12', '37', '', 1, 0, 0, NULL),
(8, 'M', '12', '38', '', 1, 0, 0, '8'),
(9, 'S', '8', '35', '', 0, 0, 0, '2'),
(10, 'L', '8', '39', '', 1, 0, 0, NULL),
(11, 'L', '14', '37', '', 0, 0, 0, '1'),
(12, 'M', '32', '40', '', 0, 0, 0, '46'),
(13, 'S', '10', '35', '', 1, 0, 1, '45'),
(14, 'XL', '36', '42', '', 0, 0, 0, NULL),
(15, 'L', '30', '39', 'NO', 0, 0, 0, NULL),
(16, 'M', '12', '36', '', 0, 0, 0, '41'),
(17, 'L', '32', '39', '', 1, 0, 0, '27'),
(18, 'M', '8', '35', '', 0, 0, 0, NULL),
(19, 'L', '34', '40', '', 1, 0, 0, NULL),
(20, 'M', '16', '38', '', 1, 0, 1, '35'),
(21, 'XL', '34', '43', '', 0, 1, 0, '26'),
(22, 'L', '30', '40', '', 0, 1, 0, '20'),
(23, 'XXL', '36', '39', '', 1, 1, 0, '10'),
(24, 'S', '8', '36', '', 0, 0, 0, '34'),
(25, 'XL', '36', '42', '', 1, 0, 0, NULL),
(26, 'L', '14', '37', '', 1, 0, 0, NULL),
(27, 'L', '30', '39', '', 0, 0, 0, NULL),
(28, 'M', '14', '37', '', 0, 0, 0, '6'),
(29, 'S', '8', '39', '', 0, 0, 0, NULL),
(30, 'L', '10', '38', '', 0, 0, 0, NULL),
(31, 'XL', '34', '38', '', 0, 0, 0, '4'),
(32, 'M', '10', '38', '', 0, 0, 0, NULL),
(33, 'M', '30', '39', '', 0, 0, 0, '29'),
(34, 'M', '32', '42', '', 0, 0, 0, '5'),
(35, 'L', '34', '40', '', 1, 0, 0, '23'),
(36, 'M', '30', '42', '', 1, 1, 1, '11'),
(37, 'XXL', '34', '39', '', 0, 1, 1, '33'),
(38, 'L', '12', '36', '', 1, 0, 1, '15'),
(39, 'M', '12', '36', '', 0, 0, 0, NULL),
(40, 'L', '14', '38', '', 1, 0, 0, '17'),
(41, 'M', '16', '35', '', 0, 0, 0, '13'),
(42, 'L', '14', '37', '', 1, 0, 1, '31'),
(43, 'S', '10', '38', '', 0, 0, 0, '36'),
(44, 'M', '12', '35', '', 0, 0, 0, '14'),
(45, 'L', '12', '38', '', 1, 0, 0, NULL),
(46, 'M', '8', '38', '', 1, 0, 1, '25'),
(47, 'M', '8', '38', '', 0, 0, 0, NULL),
(48, 'M', '8', '37', '', 0, 0, 0, '16'),
(49, 'M', '14', '38', '', 1, 0, 0, NULL),
(50, 'M', '10', '37', '', 0, 0, 0, NULL),
(51, 'M', '10', '37', '', 1, 0, 0, '18'),
(52, 'M', '30', '40', '', 0, 0, 0, '24'),
(53, 'M', '32', '38', '', 1, 0, 1, NULL),
(54, 'M', '32', '40', '', 0, 0, 0, '12'),
(55, 'L', '32', '40', '', 0, 0, 0, '21'),
(56, 'M', '30', '39', '', 0, 0, 0, '38'),
(57, 'XL', '36', '42', '', 1, 0, 0, NULL),
(58, 'M', '32', '41', '', 1, 0, 0, NULL),
(59, 'XL', '32', '40', '', 0, 0, 0, '39'),
(60, 'M', '16', '37', '', 0, 0, 1, NULL),
(61, 'L', '30', '40', '', 0, 0, 0, NULL),
(62, 'M', '32', '40', '', 0, 0, 1, NULL),
(63, 'L', '22', '37', 'NO', 1, 0, 1, NULL),
(64, 'S', '8', '35', 'NO', 0, 0, 0, NULL),
(65, 'M', '14', '36', '', 0, 0, 0, '7'),
(66, 'M', '12', '35', 'NO', 0, 0, 0, NULL),
(67, 'XL', '16', '38', '', 0, 0, 0, '42'),
(68, 'S', '30', '39', '', 0, 0, 0, '30'),
(69, 'L', '30', '38', 'NO', 0, 0, 0, NULL),
(70, 'M', '14', '37', 'NO', 0, 0, 0, NULL),
(71, 'XL', '14', '36', 'NO', 0, 0, 1, NULL),
(72, 'L', '32', '40', 'NO', 0, 0, 0, NULL),
(73, 'M', '12', '37', '', 0, 0, 1, '37'),
(74, 'S', '14', '37', 'NO', 0, 0, 0, NULL),
(75, 'M', '12', '38', '', 0, 0, 0, '40'),
(76, 'XL', '32', '41', '', 0, 1, 0, NULL),
(77, 'S', '30', '42', '', 1, 0, 0, '47'),
(78, 'M', '10', '37', 'NO', 0, 0, 0, NULL),
(79, 'S', '8', '37', '', 1, 0, 0, NULL),
(80, 'M', '14', '37', '', 0, 0, 1, '3'),
(81, 'M', '6', '37', 'NO', 1, 0, 1, NULL),
(82, 'L', '38', '38', '', 0, 0, 0, '5'),
(83, 'XL', '30', '43', '', 0, 1, 1, NULL),
(84, 'L', '32', '40', '', 0, 0, 0, NULL),
(85, 'S', '30', '39', '', 1, 0, 1, NULL),
(86, 'S', '32', '37', '', 0, 0, 0, NULL),
(87, 'M', '30', '37', '', 0, 0, 0, NULL),
(88, 'L', '36', '41', 'NO', 0, 0, 1, NULL),
(89, 'M', '32', '38', '', 1, 0, 0, NULL),
(90, 'XL', '41', '41', '', 0, 0, 0, NULL),
(91, 'M', '32', '40', '', 0, 0, 0, ''),
(92, 'S', '06', '36', '', 1, 1, 0, NULL),
(93, 'M', '30', '40', '', 0, 1, 0, NULL),
(94, 'S', '8', '38', '', 0, 0, 0, NULL),
(95, 'S', '6', '36', '', 0, 0, 0, NULL),
(96, 'L', '34', '41', '', 0, 0, 0, NULL),
(97, 'M', '32', '40', '', 0, 0, 0, NULL),
(98, 'M', '10', '36', '', 0, 0, 0, NULL),
(99, 'M', '32', '40', '', 1, 0, 1, NULL),
(100, 'L', '36', '41', '', 0, 0, 0, NULL),
(101, 'M', '10', '37', '', 0, 0, 0, NULL),
(102, 'm', '12', '37', '', 0, 0, 0, NULL),
(103, 'XL', '36', '43', '', 0, 1, 0, '22'),
(104, 'S', '10', '37', '', 0, 0, 0, '28'),
(105, 'S', '8', '36', '', 0, 0, 0, NULL),
(106, 'L', '32', '42', '', 0, 0, 1, '9'),
(107, 'M', '10', '38', '', 0, 1, 0, NULL),
(108, 'M', '34', '39', '', 0, 0, 0, NULL),
(109, 'M', '12', '38', '', 0, 1, 0, NULL),
(110, 'L', '32', '42', '', 0, 0, 0, '43'),
(111, 'XS', '6', '35', '', 1, 1, 0, NULL),
(112, 'M', '34', '39', '', 0, 0, 0, NULL),
(113, 'L', '28', '39', '', 0, 0, 0, NULL),
(114, 'XL', '30', '40', '', 0, 0, 0, '19'),
(115, 'M', '10', '35', '', 0, 0, 0, NULL),
(116, 'M', '14', '38', '', 0, 0, 0, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parentezco`
--

CREATE TABLE `parentezco` (
  `idParentezco` tinyint(4) NOT NULL,
  `nombre` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `parentezco`
--

INSERT INTO `parentezco` (`idParentezco`, `nombre`) VALUES
(1, 'Madre'),
(2, 'Padre'),
(3, 'Comprometido/a'),
(4, 'Abuelos'),
(5, 'Tios'),
(6, 'Hermanos'),
(7, 'Otros'),
(8, 'Hijo'),
(9, 'Hijastro');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `idPedido` int(11) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `fecha_pedido` datetime NOT NULL,
  `total` varchar(8) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `pedido`
--

INSERT INTO `pedido` (`idPedido`, `documento`, `fecha_pedido`, `total`, `estado`) VALUES
(2, '1017212362', '2018-06-05 06:28:57', '7900', 1),
(3, '1017216447', '2018-06-05 06:35:31', '14100', 1),
(4, '1066743123', '2018-06-05 06:32:55', '2100', 1),
(5, '1039457744', '2018-06-05 06:34:14', '7900', 1),
(6, '1020430141', '2018-06-05 06:38:19', '3000', 1),
(7, '1017137065', '2018-06-05 06:40:01', '2000', 1),
(8, '1036601013', '2018-06-05 06:42:52', '2000', 1),
(9, '98699433', '2018-06-05 06:46:19', '6800', 1),
(10, '1017125039', '2018-06-05 06:49:42', '2000', 1),
(11, '1129045994', '2018-06-05 07:21:46', '14700', 1),
(12, '1020479554', '2018-06-05 07:43:10', '2100', 1),
(13, '1020432053', '2018-06-05 07:44:04', '7900', 1),
(15, '1017171421', '2018-06-05 07:59:31', '5900', 1),
(16, '1046913982', '2018-06-06 06:15:38', '7900', 1),
(17, '1152450553', '2018-06-06 06:18:00', '7900', 1),
(18, '1017216447', '2018-06-06 06:25:43', '5200', 1),
(19, '1036601013', '2018-06-06 07:02:03', '3000', 1),
(20, '32353491', '2018-06-06 06:39:07', '4000', 1),
(21, '43975208', '2018-06-06 06:46:01', '6400', 1),
(22, '71268332', '2018-06-06 06:56:26', '3000', 1),
(23, '1035915735', '2018-06-06 07:07:54', '9900', 1),
(24, '98699433', '2018-06-06 07:44:44', '7000', 1),
(25, '1017212362', '2018-06-06 07:45:36', '7000', 1),
(26, '1028009266', '2018-06-06 07:49:08', '5200', 1),
(27, '1020479554', '2018-06-06 07:50:24', '10000', 1),
(28, '1036629003', '2018-06-06 07:54:02', '3000', 1),
(29, '1017137065', '2018-06-06 07:56:41', '2000', 1),
(30, '1017216447', '2018-06-07 06:12:09', '11900', 1),
(31, '1035427628', '2018-06-07 06:13:20', '2000', 1),
(32, '1039457744', '2018-06-07 06:25:56', '7900', 1),
(33, '1020430141', '2018-06-07 06:28:20', '8300', 1),
(34, '1066743123', '2018-06-07 06:29:18', '7900', 1),
(35, '1039049115', '2018-06-07 06:38:12', '15800', 1),
(36, '1017156424', '2018-06-07 06:40:54', '7900', 1),
(37, '1152697088', '2018-06-07 06:55:15', '7900', 1),
(38, '1017125039', '2018-06-07 07:00:02', '7900', 1),
(39, '1036601013', '2018-06-07 07:25:31', '7900', 1),
(40, '1028009266', '2018-06-07 07:46:42', '7900', 1),
(41, '1128267430', '2018-06-07 07:46:46', '7900', 1),
(42, '1020479554', '2018-06-07 07:48:46', '10000', 1),
(43, '1078579715', '2018-06-07 07:48:54', '7900', 1),
(44, '1017137065', '2018-06-07 07:50:20', '2000', 1),
(45, '1017216447', '2018-06-08 07:09:04', '14700', 1),
(46, '1053769411', '2018-06-08 06:02:31', '7900', 1),
(47, '1036601013', '2018-06-08 06:06:31', '10900', 1),
(48, '1037587834', '2018-06-08 06:34:56', '7900', 1),
(49, '71267825', '2018-06-08 06:38:34', '5900', 1),
(50, '1046913982', '2018-06-08 06:45:39', '7000', 1),
(51, '1152450553', '2018-06-08 06:58:46', '7900', 1),
(52, '71268332', '2018-06-08 07:01:35', '3000', 1),
(53, '71387038', '2018-06-08 07:07:07', '4800', 1),
(54, '1039049115', '2018-06-08 07:12:10', '4100', 1),
(55, '32353491', '2018-06-08 07:29:46', '11900', 1),
(56, '1128267430', '2018-06-08 07:36:17', '5700', 1),
(57, '1017239142', '2018-06-08 07:42:32', '2100', 1),
(58, '1017125039', '2018-06-08 07:51:17', '4200', 1),
(59, '43271378', '2018-06-08 07:54:24', '5900', 1),
(60, '1017137065', '2018-06-08 07:58:18', '2000', 1),
(61, '1017156424', '2018-06-12 06:07:54', '13600', 1),
(62, '98699433', '2018-06-12 06:22:52', '7000', 1),
(63, '1035427628', '2018-06-12 06:24:12', '7900', 1),
(64, '1020430141', '2018-06-12 06:26:16', '6800', 1),
(65, '1066743123', '2018-06-12 06:29:36', '7900', 1),
(66, '1039457744', '2018-06-12 06:30:09', '7900', 1),
(67, '1037581069', '2018-06-12 06:36:21', '7900', 1),
(68, '1036629003', '2018-06-12 06:41:05', '7900', 1),
(69, '1017125039', '2018-06-12 06:47:06', '7000', 1),
(70, '71267825', '2018-06-12 06:48:26', '2000', 1),
(71, '1039049115', '2018-06-12 07:14:48', '7900', 1),
(72, '1017137065', '2018-06-12 07:27:50', '2000', 1),
(73, '1017212362', '2018-06-12 07:29:03', '7900', 1),
(74, '43265824', '2018-06-12 07:29:56', '7900', 1),
(75, '1020479554', '2018-06-12 07:30:57', '2100', 1),
(76, '1037606721', '2018-06-12 07:45:11', '4000', 1),
(77, '32353491', '2018-06-12 07:55:11', '2000', 1),
(78, '1017216447', '2018-06-13 06:01:01', '6800', 1),
(79, '1044915764', '2018-06-13 06:02:02', '7900', 1),
(80, '1017132272', '2018-06-13 06:05:37', '2000', 1),
(81, '1020430141', '2018-06-13 06:11:46', '6000', 1),
(82, '71267825', '2018-06-13 06:17:19', '2000', 1),
(83, '1053769411', '2018-06-13 06:19:42', '2000', 1),
(84, '1036601013', '2018-06-13 06:20:34', '7900', 1),
(85, '1017137065', '2018-06-13 06:21:19', '2000', 1),
(86, '1129045994', '2018-06-13 06:40:15', '6800', 1),
(87, '1020479554', '2018-06-13 06:40:50', '8000', 1),
(88, '1152450553', '2018-06-13 06:53:33', '6800', 1),
(89, '1039049115', '2018-06-13 07:20:56', '7900', 1),
(90, '760579', '2018-06-13 07:37:07', '2100', 1),
(91, '1039447684', '2018-06-13 07:38:56', '7900', 1),
(92, '1143366120', '2018-06-13 07:44:06', '2000', 1),
(93, '43841319', '2018-06-13 07:47:16', '3000', 1),
(94, '1020430141', '2018-06-14 10:40:36', '6700', 1),
(95, '1017216447', '2018-06-14 06:04:33', '12400', 1),
(96, '43189198', '2018-06-14 06:05:30', '15800', 1),
(97, '1035427628', '2018-06-14 06:06:52', '2000', 1),
(98, '43265824', '2018-06-14 06:09:04', '7900', 1),
(99, '1046913982', '2018-06-14 06:10:09', '7900', 1),
(100, '1036601013', '2018-06-14 06:11:22', '2000', 1),
(101, '71387038', '2018-06-14 06:23:57', '6800', 1),
(102, '1066743123', '2018-06-14 06:24:44', '7900', 1),
(103, '43975208', '2018-06-14 06:40:41', '6800', 1),
(104, '71267825', '2018-06-14 06:48:35', '2000', 1),
(105, '1044915764', '2018-06-14 06:49:31', '7900', 1),
(106, '1039457744', '2018-06-14 07:05:08', '7900', 1),
(107, '71268332', '2018-06-14 07:06:48', '3000', 1),
(108, '1053769411', '2018-06-14 07:14:06', '2000', 1),
(109, '1017137065', '2018-06-14 07:15:11', '2000', 1),
(110, '1152697088', '2018-06-14 07:22:06', '2200', 1),
(111, '43583398', '2018-06-14 07:23:10', '4200', 1),
(112, '43271378', '2018-06-14 10:39:51', '10800', 1),
(113, '1017125039', '2018-06-14 10:39:25', '6100', 1),
(114, '1020479554', '2018-06-14 07:49:35', '8000', 1),
(115, '1028009266', '2018-06-14 10:38:42', '2200', 1),
(116, '78758797', '2018-06-14 07:52:16', '13200', 1),
(117, '1041151150', '2018-06-15 06:03:48', '8200', 1),
(118, '1053769411', '2018-06-15 06:04:38', '7900', 1),
(119, '1077453248', '2018-06-15 06:06:58', '3900', 1),
(120, '1020430141', '2018-06-15 06:09:00', '5900', 1),
(121, '1096238261', '2018-06-15 06:13:43', '7900', 1),
(122, '1036629003', '2018-06-15 06:16:07', '7900', 1),
(123, '1152450553', '2018-06-15 06:35:39', '13200', 1),
(125, '1039457744', '2018-06-15 06:38:04', '6100', 1),
(126, '1017137065', '2018-06-15 06:44:38', '6500', 1),
(127, '1037587834', '2018-06-15 06:47:22', '14700', 1),
(128, '43605625', '2018-06-15 06:48:53', '7900', 1),
(129, '1017156424', '2018-06-15 06:49:42', '5000', 1),
(130, '1044915764', '2018-06-15 06:50:57', '7900', 1),
(131, '1128405581', '2018-06-15 06:51:09', '14000', 1),
(132, '1039049115', '2018-06-15 06:52:13', '7500', 1),
(133, '71267825', '2018-06-15 06:56:55', '5900', 1),
(134, '1036651097', '2018-06-15 06:58:43', '12000', 1),
(135, '98699433', '2018-06-15 07:16:23', '4000', 1),
(136, '1017212362', '2018-06-15 07:17:22', '2800', 1),
(137, '71387038', '2018-06-15 07:19:50', '2000', 1),
(138, '43975208', '2018-06-15 07:21:40', '4200', 1),
(139, '43265824', '2018-06-15 07:30:20', '7900', 1),
(140, '1128267430', '2018-06-15 07:39:20', '4000', 1),
(141, '43841319', '2018-06-15 07:45:42', '3000', 1),
(142, '1017171421', '2018-06-15 07:51:41', '9600', 1),
(143, '1129045994', '2018-06-16 08:32:59', '5300', 1),
(144, '71387038', '2018-06-16 07:59:38', '5900', 1),
(145, '43271378', '2018-06-16 08:18:20', '5300', 1),
(146, '1017216447', '2018-06-18 06:00:42', '7900', 1),
(147, '1044915764', '2018-06-18 06:01:29', '5900', 1),
(148, '1017156424', '2018-06-18 06:18:48', '15800', 1),
(149, '1020430141', '2018-06-18 06:23:14', '3900', 1),
(150, '1017137065', '2018-06-18 06:24:01', '2000', 1),
(151, '1152450553', '2018-06-18 06:46:38', '4500', 1),
(152, '43265824', '2018-06-18 06:54:00', '10100', 1),
(153, '1046913982', '2018-06-18 07:27:04', '2000', 1),
(154, '43975208', '2018-06-18 07:33:44', '23700', 1),
(155, '1017239142', '2018-06-18 07:45:21', '1400', 1),
(156, '1028009266', '2018-06-18 07:46:10', '8700', 1),
(157, '43841319', '2018-06-18 07:58:27', '1400', 1),
(160, '1020479554', '2018-06-19 06:02:14', '8000', 1),
(161, '1044915764', '2018-06-19 06:04:02', '5900', 1),
(162, '1017216447', '2018-06-19 06:04:23', '10900', 1),
(163, '1040757557', '2018-06-19 06:09:25', '12400', 1),
(164, '1020430141', '2018-06-19 09:07:42', '6100', 1),
(165, '43265824', '2018-06-19 06:16:50', '23700', 1),
(166, '32353491', '2018-06-19 06:59:56', '2000', 1),
(167, '1017137065', '2018-06-19 07:03:23', '2000', 1),
(168, '1046913982', '2018-06-19 07:06:19', '6800', 1),
(169, '1152450553', '2018-06-19 07:10:50', '2000', 1),
(170, '43583398', '2018-06-19 10:40:03', '3200', 1),
(171, '1017212362', '2018-06-19 07:35:27', '7900', 1),
(172, '1053769411', '2018-06-19 07:38:12', '2500', 1),
(177, '1044915764', '2018-06-20 06:01:03', '5900', 1),
(178, '1017216447', '2018-06-20 06:02:43', '9800', 1),
(179, '1020430141', '2018-06-20 06:04:27', '5000', 1),
(180, '1152450553', '2018-06-20 06:06:16', '5700', 1),
(181, '1017156424', '2018-06-20 06:32:16', '9500', 1),
(182, '1037587834', '2018-06-20 06:32:54', '7900', 1),
(183, '1129045994', '2018-06-20 06:40:30', '4500', 1),
(184, '1020432053', '2018-06-20 06:41:18', '7900', 1),
(185, '1053769411', '2018-06-20 06:43:14', '2000', 1),
(186, '1017137065', '2018-06-20 06:44:08', '2000', 1),
(187, '1046913982', '2018-06-20 07:06:24', '2000', 1),
(188, '1152210828', '2018-06-20 07:18:40', '5900', 1),
(189, '1214723132', '2018-06-20 07:23:26', '4500', 1),
(190, '32353491', '2018-06-20 07:43:47', '2000', 1),
(191, '1036629003', '2018-06-20 07:48:41', '3900', 1),
(193, '32353491', '2018-06-21 06:18:33', '7900', 1),
(194, '1017216447', '2018-06-21 06:19:28', '11800', 1),
(195, '1039049115', '2018-06-21 06:26:35', '7900', 1),
(196, '1020479554', '2018-06-21 06:26:51', '8000', 1),
(197, '1020430141', '2018-06-21 06:36:45', '5300', 1),
(198, '1017156424', '2018-06-21 06:37:46', '15800', 1),
(199, '1152450553', '2018-06-21 06:55:05', '19400', 1),
(200, '1044915764', '2018-06-21 07:01:21', '5900', 1),
(201, '1017212362', '2018-06-21 07:20:13', '7000', 1),
(202, '71267825', '2018-06-21 07:26:47', '2000', 1),
(203, '1129045994', '2018-06-21 07:30:32', '6800', 1),
(204, '1039447684', '2018-06-21 07:36:40', '4000', 1),
(205, '1036601013', '2018-06-21 07:51:03', '2000', 1),
(206, '1046913982', '2018-06-21 07:54:18', '11900', 1),
(207, '1017137065', '2018-06-21 07:54:57', '2000', 1),
(208, '1028009266', '2018-06-21 07:55:02', '9900', 1),
(209, '1020430141', '2018-06-22 06:03:01', '6200', 1),
(210, '32353491', '2018-06-22 06:03:44', '2000', 1),
(211, '1017132272', '2018-06-22 06:06:56', '2000', 1),
(212, '1036629003', '2018-06-22 06:09:29', '12400', 1),
(213, '1152450553', '2018-06-22 06:46:43', '7000', 1),
(214, '71267825', '2018-06-22 06:20:16', '5900', 1),
(215, '43288005', '2018-06-22 06:33:44', '7900', 1),
(216, '1044915764', '2018-06-22 06:41:08', '11800', 1),
(217, '1017216447', '2018-06-22 07:11:53', '6800', 1),
(218, '1020479554', '2018-06-22 07:13:08', '10000', 1),
(220, '1017219391', '2018-06-22 07:24:07', '7900', 1),
(221, '1017239142', '2018-06-22 07:40:29', '9300', 1),
(222, '43841319', '2018-06-22 07:43:54', '5000', 1),
(223, '1028016893', '2018-06-22 07:57:08', '5900', 1),
(224, '1044915764', '2018-06-25 06:00:36', '5900', 1),
(225, '1036601013', '2018-06-25 06:02:16', '4000', 1),
(226, '43265824', '2018-06-25 06:03:13', '7900', 1),
(227, '1035427628', '2018-06-25 06:04:34', '7900', 1),
(228, '1020430141', '2018-06-25 06:09:26', '1400', 1),
(229, '1039457744', '2018-06-25 06:36:32', '7900', 1),
(230, '1046913982', '2018-06-25 06:48:04', '2000', 1),
(231, '1037587834', '2018-06-25 06:49:11', '16100', 1),
(232, '1017216447', '2018-06-25 06:50:15', '5300', 1),
(233, '1017156424', '2018-06-25 06:51:11', '15000', 1),
(234, '43271378', '2018-06-25 07:06:11', '5300', 1),
(235, '1017212362', '2018-06-25 07:06:34', '6800', 1),
(236, '1017125039', '2018-06-25 07:09:54', '6100', 1),
(237, '1129045994', '2018-06-25 07:16:32', '5000', 1),
(238, '32353491', '2018-06-25 07:17:02', '2000', 1),
(239, '1020479554', '2018-06-25 07:19:04', '2500', 1),
(240, '43583398', '2018-06-25 07:27:03', '6500', 1),
(241, '1040757557', '2018-06-25 07:41:05', '4000', 1),
(242, '1017239142', '2018-06-25 07:47:39', '9200', 1),
(243, '71267825', '2018-06-25 07:52:55', '2000', 1),
(244, '1028016893', '2018-06-25 07:58:44', '5900', 1),
(245, '1035427628', '2018-06-26 06:04:15', '2000', 1),
(246, '1066743123', '2018-06-26 06:05:25', '5900', 1),
(247, '1017156424', '2018-06-26 06:19:15', '22600', 1),
(248, '1017125039', '2018-06-26 06:19:40', '4200', 1),
(249, '1020479554', '2018-06-26 06:22:09', '7300', 1),
(250, '1020432053', '2018-06-26 06:26:33', '2000', 1),
(251, '43975208', '2018-06-26 06:38:54', '2600', 1),
(252, '1039447684', '2018-06-26 07:09:44', '7900', 1),
(253, '1053769411', '2018-06-26 07:16:44', '2000', 1),
(254, '1129045994', '2018-06-26 07:19:17', '2800', 1),
(255, '71268332', '2018-06-26 07:31:25', '3000', 1),
(256, '43583398', '2018-06-26 07:54:10', '6600', 1),
(257, '1044915764', '2018-06-27 06:02:10', '5900', 1),
(258, '1017132272', '2018-06-27 06:04:39', '2000', 1),
(259, '1036601013', '2018-06-27 06:07:47', '2000', 1),
(260, '1039049115', '2018-06-27 06:27:12', '7900', 1),
(261, '1017125039', '2018-06-27 06:33:52', '5600', 1),
(262, '1017216447', '2018-06-27 06:46:59', '7900', 1),
(263, '1152210828', '2018-06-27 07:05:33', '1400', 1),
(264, '1035915735', '2018-06-27 07:06:55', '5600', 1),
(265, '1020479554', '2018-06-27 07:22:40', '2100', 1),
(266, '71267825', '2018-06-27 07:34:30', '2000', 1),
(268, '1037631569', '2018-06-28 12:00:00', '9900', 1),
(269, '1152450553', '2018-06-28 00:00:00', '4000', 1),
(270, '1096238261', '2018-06-28 00:00:00', '7900', 1),
(271, '1039457744', '2018-06-28 00:00:00', '6200', 1),
(272, '1044915764', '2018-06-28 00:00:00', '7900', 1),
(273, '43189198', '2018-06-28 00:00:00', '7900', 1),
(274, '1036601013', '2018-06-28 00:00:00', '7000', 1),
(275, '1046913982', '2018-06-28 00:00:00', '6800', 1),
(276, '1017147712', '2018-06-28 00:00:00', '7900', 1),
(277, '1017216447', '2018-06-28 00:00:00', '7900', 1),
(278, '1214723132', '2018-06-28 00:00:00', '5900', 1),
(279, '1017156424', '2018-06-28 00:00:00', '7900', 1),
(280, '1152210828', '2018-06-28 06:53:16', '7900', 1),
(281, '1037587834', '2018-06-28 07:01:58', '4100', 1),
(282, '43605625', '2018-06-28 07:03:50', '7900', 1),
(283, '1017137065', '2018-06-28 07:09:43', '4000', 1),
(284, '1039447684', '2018-06-28 07:31:03', '7900', 1),
(285, '1152697088', '2018-06-28 07:34:47', '9800', 1),
(286, '1129045994', '2018-06-28 07:35:18', '11800', 1),
(287, '1128267430', '2018-06-28 07:38:22', '5900', 1),
(288, '43841319', '2018-06-28 07:38:37', '1400', 1),
(289, '43975208', '2018-06-28 07:45:07', '5900', 1),
(290, '43271378', '2018-06-29 14:47:19', '2500', 1),
(292, '1017216447', '2018-06-29 06:03:43', '5000', 1),
(293, '21424773', '2018-06-29 06:04:23', '7900', 1),
(294, '1035427628', '2018-06-29 06:05:42', '4000', 1),
(295, '1036601013', '2018-06-29 06:06:55', '7000', 1),
(296, '1096238261', '2018-06-29 06:08:36', '7900', 1),
(297, '1039457744', '2018-06-29 06:12:37', '5200', 1),
(298, '71267825', '2018-06-29 06:18:16', '5900', 1),
(299, '1152450553', '2018-06-29 06:22:07', '14900', 1),
(300, '1037587834', '2018-06-29 06:23:29', '7900', 1),
(301, '1046913982', '2018-06-29 06:28:56', '6800', 1),
(302, '1017125039', '2018-06-29 06:32:02', '4200', 1),
(303, '1143991147', '2018-06-29 06:37:35', '4800', 1),
(304, '1020464577', '2018-06-29 06:37:44', '7900', 1),
(305, '1020479554', '2018-06-29 06:40:50', '8000', 1),
(306, '1037949696', '2018-06-29 06:56:30', '10800', 1),
(307, '43975208', '2018-06-29 06:46:03', '4000', 1),
(308, '1128405581', '2018-06-29 06:52:27', '9700', 1),
(309, '32353491', '2018-06-29 07:02:59', '4000', 1),
(310, '1039447684', '2018-06-29 07:26:45', '7900', 1),
(311, '1128267430', '2018-06-29 07:37:56', '7300', 1),
(312, '1017239142', '2018-06-29 07:40:06', '7900', 1),
(314, '1017137065', '2018-06-30 12:00:00', '6500', 1),
(315, '1040757557', '2018-06-30 06:04:49', '4000', 1),
(316, '760579', '2018-06-30 06:05:02', '1200', 1),
(317, '1152450553', '2018-06-30 07:00:26', '4500', 1),
(318, '1044915764', '2018-07-03 06:00:50', '5900', 1),
(319, '1017216447', '2018-07-03 06:01:49', '10900', 1),
(320, '1036601013', '2018-07-03 06:04:48', '10900', 1),
(322, '1017132272', '2018-07-03 06:07:30', '2000', 1),
(323, '1152450553', '2018-07-03 06:37:57', '4500', 1),
(324, '1017156424', '2018-07-03 06:43:21', '15800', 1),
(325, '54253320', '2018-07-03 06:49:44', '4000', 1),
(326, '43271378', '2018-07-03 06:50:52', '5000', 1),
(327, '1020430141', '2018-07-03 06:52:51', '5300', 1),
(328, '1128405581', '2018-07-03 07:23:12', '7900', 1),
(329, '1017239142', '2018-07-03 07:38:41', '9300', 1),
(330, '1128267430', '2018-07-03 07:40:46', '5900', 1),
(331, '1028009266', '2018-07-03 07:41:02', '5900', 1),
(332, '43605625', '2018-07-03 07:42:40', '7900', 1),
(335, '1017216447', '2018-07-04 06:03:51', '10700', 1),
(336, '1020430141', '2018-07-04 06:07:16', '11000', 1),
(337, '1035427628', '2018-07-04 06:08:19', '2000', 1),
(338, '1036629003', '2018-07-04 06:10:03', '5000', 1),
(339, '1046913982', '2018-07-04 06:14:42', '13300', 1),
(340, '8433778', '2018-07-04 06:16:09', '2000', 1),
(341, '1017137065', '2018-07-04 06:17:03', '2000', 1),
(342, '1044915764', '2018-07-04 06:17:45', '5900', 1),
(343, '760579', '2018-07-04 06:19:26', '5900', 1),
(344, '1066743123', '2018-07-04 06:21:15', '5900', 1),
(345, '71267825', '2018-07-04 06:37:16', '2000', 1),
(346, '1152450553', '2018-07-04 06:37:42', '7900', 1),
(347, '1017156424', '2018-07-04 06:39:17', '10500', 1),
(348, '1037587834', '2018-07-04 06:39:52', '7900', 1),
(349, '43271378', '2018-07-04 06:49:48', '8000', 1),
(350, '1017125039', '2018-07-04 07:28:28', '5700', 1),
(351, '1020479554', '2018-07-04 07:29:46', '2100', 1),
(353, '1028009266', '2018-07-04 07:43:01', '3200', 1),
(354, '32353491', '2018-07-04 07:46:12', '9900', 1),
(357, '1044915764', '2018-07-05 06:00:57', '5900', 1),
(358, '8433778', '2018-07-05 06:03:38', '2000', 1),
(359, '1037587834', '2018-07-05 06:17:55', '7900', 1),
(360, '1152450553', '2018-07-05 06:21:08', '13100', 1),
(361, '1046913982', '2018-07-05 06:25:40', '6600', 1),
(362, '1020479554', '2018-07-05 06:31:37', '8000', 1),
(363, '15489896', '2018-07-05 06:35:55', '7900', 1),
(364, '1020430141', '2018-07-05 07:02:46', '3900', 1),
(365, '1017125039', '2018-07-05 07:12:58', '4000', 1),
(366, '32353491', '2018-07-05 07:15:22', '3400', 1),
(367, '1039447684', '2018-07-05 07:16:57', '7900', 1),
(368, '43271378', '2018-07-05 07:18:40', '2500', 1),
(369, '1036629003', '2018-07-05 07:20:13', '3900', 1),
(370, '1017212362', '2018-07-05 07:30:50', '6800', 1),
(371, '1017156424', '2018-07-05 07:35:49', '7900', 1),
(372, '1017137065', '2018-07-05 07:40:12', '2000', 1),
(373, '1078579715', '2018-07-05 07:56:04', '7900', 1),
(374, '1020430141', '2018-07-06 06:00:13', '3900', 1),
(375, '1214723132', '2018-07-06 06:01:28', '7900', 1),
(376, '1017216447', '2018-07-06 06:01:51', '7900', 1),
(377, '26201420', '2018-07-06 06:02:52', '7900', 1),
(378, '1017137065', '2018-07-06 06:03:33', '2000', 1),
(379, '1036601013', '2018-07-06 06:04:57', '7000', 1),
(380, '8433778', '2018-07-06 06:08:07', '2000', 1),
(381, '1020479554', '2018-07-06 06:09:12', '8000', 1),
(382, '1035427628', '2018-07-06 06:10:11', '7900', 1),
(383, '1096238261', '2018-07-06 06:14:41', '5900', 1),
(384, '1152450553', '2018-07-06 06:26:12', '12400', 1),
(385, '1017156424', '2018-07-06 06:38:49', '22000', 1),
(386, '71267825', '2018-07-06 06:41:14', '5900', 1),
(387, '1017212362', '2018-07-06 07:04:41', '7900', 1),
(388, '15489917', '2018-07-06 07:17:21', '7000', 1),
(389, '43583398', '2018-07-06 07:20:03', '5200', 1),
(391, '32353491', '2018-07-06 07:37:23', '1400', 1),
(393, '43271378', '2018-07-06 07:41:44', '6400', 1),
(396, '8433778', '2018-07-07 16:19:50', '4800', 1),
(397, '1035427628', '2018-07-07 16:23:26', '6800', 1),
(398, '1040757557', '2018-07-07 16:35:43', '4000', 1),
(399, '1128430240', '2018-07-07 17:17:01', '5000', 1),
(400, '1037631569', '2018-07-09 06:07:52', '5300', 1),
(401, '1020479554', '2018-07-09 06:09:39', '8000', 1),
(402, '1017137065', '2018-07-09 06:10:52', '2000', 1),
(403, '1036601013', '2018-07-09 06:47:23', '2000', 1),
(404, '1017212362', '2018-07-09 07:12:45', '7900', 1),
(405, '1216714526', '2018-07-09 07:18:21', '7900', 1),
(406, '1039049115', '2018-07-09 07:19:06', '5600', 1),
(407, '32353491', '2018-07-09 07:28:37', '3400', 1),
(408, '1020430141', '2018-07-09 07:37:56', '3900', 1),
(409, '1020430141', '2018-07-10 06:00:20', '8200', 1),
(410, '21424773', '2018-07-10 06:03:33', '3600', 1),
(411, '1044915764', '2018-07-10 06:04:32', '5900', 1),
(412, '42702332', '2018-07-10 06:09:29', '7900', 1),
(413, '1036651097', '2018-07-10 06:20:19', '3900', 1),
(414, '43975208', '2018-07-10 06:27:18', '12400', 1),
(415, '1152450553', '2018-07-10 06:37:03', '6500', 1),
(416, '1017156424', '2018-07-10 06:40:56', '17000', 1),
(417, '43271378', '2018-07-10 07:03:22', '6200', 1),
(418, '1017125039', '2018-07-10 07:04:07', '4200', 1),
(419, '1017212362', '2018-07-10 07:04:13', '10000', 1),
(420, '1046913982', '2018-07-10 07:05:23', '7900', 1),
(421, '1040757557', '2018-07-10 07:05:55', '5000', 1),
(422, '1017137065', '2018-07-10 07:06:23', '2000', 1),
(423, '1036629003', '2018-07-10 07:08:02', '3900', 1),
(424, '71267825', '2018-07-10 07:20:02', '2000', 1),
(425, '1078579715', '2018-07-11 17:12:38', '2800', 1),
(426, '43605625', '2018-07-11 06:00:53', '7900', 1),
(427, '1020430141', '2018-07-11 06:02:22', '6200', 1),
(428, '1017137065', '2018-07-11 06:05:43', '6000', 1),
(429, '1017216447', '2018-07-11 06:07:16', '10900', 1),
(430, '1152450553', '2018-07-11 06:10:31', '14400', 1),
(431, '1044915764', '2018-07-11 06:12:08', '5900', 1),
(432, '1066743123', '2018-07-11 06:13:36', '5900', 1),
(433, '760579', '2018-07-11 06:14:39', '1200', 1),
(434, '71267825', '2018-07-11 06:21:28', '2000', 1),
(435, '54253320', '2018-07-11 06:42:37', '3400', 1),
(436, '1017156424', '2018-07-11 06:42:51', '15800', 1),
(437, '43271378', '2018-07-11 06:47:04', '7500', 1),
(438, '1036629003', '2018-07-11 07:26:43', '9000', 1),
(439, '1017125039', '2018-07-11 07:29:37', '4000', 1),
(440, '1020479554', '2018-07-11 07:35:41', '2100', 1),
(441, '1143991147', '2018-07-11 07:43:48', '2200', 1),
(442, '1017216447', '2018-07-12 06:10:10', '10900', 1),
(443, '1214723132', '2018-07-12 06:11:22', '5000', 1),
(444, '1035427628', '2018-07-12 06:12:08', '7900', 1),
(445, '1044915764', '2018-07-12 06:12:44', '7900', 1),
(446, '1017212362', '2018-07-12 06:17:25', '7000', 1),
(447, '1037587834', '2018-07-12 06:20:08', '7900', 1),
(448, '71267825', '2018-07-12 06:20:16', '2000', 1),
(449, '43975208', '2018-07-12 06:21:23', '7600', 1),
(450, '1020479554', '2018-07-12 06:26:05', '8000', 1),
(451, '1020430141', '2018-07-12 06:26:25', '6100', 1),
(452, '8433778', '2018-07-12 06:53:54', '2000', 1),
(453, '71268332', '2018-07-12 07:01:29', '7900', 1),
(454, '1017137065', '2018-07-12 07:09:08', '7900', 1),
(455, '1028009266', '2018-07-12 07:10:26', '7900', 1),
(456, '1036601013', '2018-07-12 07:39:03', '2000', 1),
(457, '43583398', '2018-07-12 07:40:32', '7900', 1),
(458, '1017216447', '2018-07-13 06:03:20', '7300', 1),
(459, '1035427628', '2018-07-13 06:12:20', '14400', 1),
(460, '43605625', '2018-07-13 06:14:30', '3000', 1),
(461, '1044915764', '2018-07-13 06:17:23', '5900', 1),
(462, '1020430141', '2018-07-13 06:19:49', '6200', 1),
(463, '1036629003', '2018-07-13 06:23:52', '3900', 1),
(464, '1066743123', '2018-07-13 06:25:22', '5900', 1),
(465, '1077453248', '2018-07-13 06:28:35', '13900', 1),
(466, '1036601013', '2018-07-13 06:29:48', '2000', 1),
(467, '1152450553', '2018-07-13 06:48:43', '9900', 1),
(468, '98699433', '2018-07-13 06:53:21', '9900', 1),
(469, '1046913982', '2018-07-13 06:53:19', '11800', 1),
(470, '43975208', '2018-07-13 06:54:08', '9400', 1),
(471, '1017212362', '2018-07-13 06:54:37', '7900', 1),
(472, '32353491', '2018-07-13 07:06:56', '6000', 1),
(473, '1039447684', '2018-07-13 07:09:02', '7900', 1),
(474, '1017137065', '2018-07-13 07:09:23', '6000', 1),
(475, '1017125039', '2018-07-13 07:11:05', '4200', 1),
(476, '1017219391', '2018-07-13 07:11:36', '1400', 1),
(477, '54253320', '2018-07-13 07:17:32', '4200', 1),
(478, '1152697088', '2018-07-13 07:23:11', '3200', 1),
(479, '43583398', '2018-07-13 07:43:38', '16300', 1),
(480, '1044915764', '2018-07-16 06:41:04', '5900', 1),
(481, '1020479554', '2018-07-16 06:42:51', '8000', 1),
(482, '43288005', '2018-07-16 06:48:38', '7900', 1),
(483, '71267825', '2018-07-16 07:13:47', '2000', 1),
(484, '1152450553', '2018-07-16 07:19:50', '9900', 1),
(485, '43271378', '2018-07-16 07:22:56', '6200', 1),
(486, '1028009266', '2018-07-16 07:33:01', '2000', 1),
(487, '1017216447', '2018-07-17 06:00:32', '7900', 1),
(488, '1214721942', '2018-07-17 06:03:12', '7900', 1),
(489, '1044915764', '2018-07-17 06:06:55', '5900', 1),
(490, '71267825', '2018-07-17 06:36:31', '2000', 1),
(491, '1152450553', '2018-07-17 06:54:20', '14900', 1),
(492, '1036601013', '2018-07-17 06:55:16', '2000', 1),
(493, '1036651097', '2018-07-17 06:57:50', '5600', 1),
(494, '1017125039', '2018-07-17 06:58:14', '5400', 1),
(495, '1128405581', '2018-07-17 07:00:48', '5600', 1),
(496, '32353491', '2018-07-17 07:05:12', '1400', 1),
(497, '1039049115', '2018-07-17 07:12:14', '4800', 1),
(498, '43271378', '2018-07-17 07:32:16', '4000', 1),
(499, '1017239142', '2018-07-17 07:43:20', '1400', 1),
(500, '1017216447', '2018-07-18 06:00:26', '2500', 1),
(501, '1020479554', '2018-07-18 06:01:26', '8000', 1),
(502, '1017137065', '2018-07-18 06:01:39', '2000', 1),
(503, '1036601013', '2018-07-18 06:02:47', '2000', 1),
(504, '1020430141', '2018-07-18 06:04:30', '4100', 1),
(505, '71267825', '2018-07-18 06:12:27', '2000', 1),
(506, '43288005', '2018-07-18 06:38:28', '7900', 1),
(507, '1152450553', '2018-07-18 06:58:02', '7000', 1),
(508, '1017156424', '2018-07-18 07:00:29', '7000', 1),
(509, '1039447684', '2018-07-18 07:19:43', '7900', 1),
(510, '1036629003', '2018-07-18 07:35:48', '4000', 1),
(511, '1035915735', '2018-07-18 07:41:14', '1400', 1),
(512, '760579', '2018-07-18 09:44:09', '7900', 1),
(513, '43271378', '2018-07-18 09:44:28', '5900', 1),
(514, '1078579715', '2018-07-19 17:08:06', '7900', 1),
(515, '1040757557', '2018-07-19 06:00:22', '2000', 1),
(516, '1017137065', '2018-07-19 06:01:22', '2000', 1),
(517, '1017216447', '2018-07-19 06:06:35', '9200', 1),
(518, '1036601013', '2018-07-19 06:15:24', '7000', 1),
(519, '1066743123', '2018-07-19 06:33:46', '7900', 1),
(520, '1017125039', '2018-07-19 06:48:17', '3900', 1),
(521, '1020479554', '2018-07-19 07:05:18', '10000', 1),
(522, '1017156424', '2018-07-19 07:18:10', '21800', 1),
(523, '43271378', '2018-07-19 07:31:21', '11900', 1),
(524, '1036629003', '2018-07-19 07:38:03', '7900', 1),
(525, '1128267430', '2018-07-19 07:43:55', '19800', 1),
(526, '1017216447', '2018-07-23 06:10:36', '14100', 1),
(527, '1044915764', '2018-07-23 06:11:47', '7900', 1),
(528, '1036601013', '2018-07-23 06:15:47', '7000', 1),
(529, '1066743123', '2018-07-23 06:19:07', '5900', 1),
(530, '43605625', '2018-07-23 06:24:29', '10000', 1),
(531, '43265824', '2018-07-23 06:44:08', '7900', 1),
(532, '1017156424', '2018-07-23 07:18:45', '15400', 1),
(533, '1096238261', '2018-07-23 06:55:31', '15800', 1),
(534, '1035427628', '2018-07-23 06:56:43', '14400', 1),
(535, '1017125039', '2018-07-23 06:57:04', '3600', 1),
(536, '760579', '2018-07-23 06:57:10', '1200', 1),
(537, '42702332', '2018-07-23 06:58:17', '7900', 1),
(538, '1152450553', '2018-07-23 06:58:24', '6500', 1),
(539, '71267825', '2018-07-23 06:59:00', '5900', 1),
(540, '1020479554', '2018-07-23 07:05:30', '2100', 1),
(541, '1035915735', '2018-07-23 07:05:46', '2800', 1),
(542, '1017137065', '2018-07-23 07:16:17', '2000', 1),
(543, '1028009266', '2018-07-23 07:26:42', '5900', 1),
(545, '1017216447', '2018-07-24 06:08:45', '10400', 1),
(546, '43265824', '2018-07-24 06:10:18', '7900', 1),
(547, '1037587834', '2018-07-24 06:16:15', '6100', 1),
(548, '71267825', '2018-07-24 06:25:16', '2000', 1),
(549, '1020479554', '2018-07-24 06:44:29', '7900', 1),
(550, '1017212362', '2018-07-24 06:52:10', '2000', 1),
(551, '1152450553', '2018-07-24 06:53:14', '9900', 1),
(552, '1036601013', '2018-07-24 06:57:19', '2000', 1),
(553, '1037631569', '2018-07-24 07:01:33', '2000', 1),
(554, '1020430141', '2018-07-24 07:02:13', '4200', 1),
(555, '1039049115', '2018-07-24 07:25:22', '5600', 1),
(556, '1129045994', '2018-07-24 07:33:25', '5000', 1),
(557, '1020479554', '2018-07-25 06:01:15', '10000', 1),
(558, '1044915764', '2018-07-25 06:02:51', '7900', 1),
(559, '1035879778', '2018-07-25 06:06:07', '3900', 1),
(560, '1017216447', '2018-07-25 06:07:11', '3900', 1),
(561, '1037587834', '2018-07-25 06:10:18', '14500', 1),
(562, '1036601013', '2018-07-25 06:11:09', '2000', 1),
(563, '43605625', '2018-07-25 06:11:47', '7900', 1),
(564, '1066743123', '2018-07-25 06:12:43', '5900', 1),
(565, '1017137065', '2018-07-25 06:14:58', '2000', 1),
(566, '1046913982', '2018-07-25 06:15:59', '2000', 1),
(567, '1129045994', '2018-07-25 06:16:53', '6800', 1),
(568, '1095791547', '2018-07-25 06:19:15', '6800', 1),
(569, '760579', '2018-07-25 06:19:45', '9100', 1),
(570, '1039049115', '2018-07-25 06:22:55', '7900', 1),
(572, '1017156424', '2018-07-25 06:38:11', '6400', 1),
(573, '1017212362', '2018-07-25 06:48:25', '7900', 1),
(574, '1020430141', '2018-07-25 06:59:40', '2100', 1),
(575, '1036629003', '2018-07-25 07:05:37', '11900', 1),
(576, '1020457057', '2018-07-25 07:06:48', '2900', 1),
(577, '43271378', '2018-07-25 07:38:45', '4500', 1),
(579, '1078579715', '2018-07-26 16:37:05', '7900', 1),
(580, '21424773', '2018-07-26 06:02:17', '5900', 1),
(581, '1017216447', '2018-07-26 06:03:23', '2500', 1),
(582, '43189198', '2018-07-26 06:04:22', '7900', 1),
(583, '43288005', '2018-07-26 06:06:55', '7900', 1),
(584, '1035879778', '2018-07-26 06:10:09', '4500', 1),
(585, '1036601013', '2018-07-26 06:11:02', '2000', 1),
(586, '1020430141', '2018-07-26 06:19:32', '8200', 1),
(587, '1020464577', '2018-07-26 06:20:10', '15800', 1),
(588, '1152450553', '2018-07-26 06:21:07', '12400', 1),
(589, '1036629003', '2018-07-26 06:24:38', '2000', 1),
(590, '1044915764', '2018-07-26 06:25:17', '7900', 1),
(591, '1017212362', '2018-07-26 06:28:49', '4000', 1),
(592, '1046913982', '2018-07-26 06:48:40', '14100', 1),
(593, '71267825', '2018-07-26 06:43:55', '5900', 1),
(594, '1066743123', '2018-07-26 06:51:54', '5900', 1),
(595, '98699433', '2018-07-26 06:52:03', '6800', 1),
(596, '1096238261', '2018-07-26 07:07:37', '7900', 1),
(597, '1040757557', '2018-07-26 07:18:47', '2000', 1),
(598, '1020479554', '2018-07-26 07:24:15', '10000', 1),
(599, '1035915735', '2018-07-26 07:34:44', '5900', 1),
(600, '1017171421', '2018-07-26 07:36:09', '4200', 1),
(601, '1037606721', '2018-07-26 07:37:04', '2000', 1),
(602, '1017125039', '2018-07-26 07:37:25', '4800', 1),
(603, '1128267430', '2018-07-26 07:37:31', '7300', 1),
(604, '1037587834', '2018-07-26 07:40:41', '2000', 1),
(605, '1017137065', '2018-07-27 06:00:38', '7900', 1),
(606, '1020457057', '2018-07-27 06:02:35', '2800', 1),
(607, '1046913982', '2018-07-27 06:03:34', '7900', 1),
(608, '1017216447', '2018-07-27 06:05:39', '14400', 1),
(609, '1044915764', '2018-07-27 06:07:09', '7900', 1),
(610, '1096238261', '2018-07-27 06:08:28', '7900', 1),
(611, '1037587834', '2018-07-27 06:10:06', '10500', 1),
(612, '43605625', '2018-07-27 06:12:03', '5900', 1),
(613, '1129045994', '2018-07-27 06:12:44', '6800', 1),
(614, '1017147712', '2018-07-27 06:25:21', '7900', 1),
(615, '1035879778', '2018-07-27 06:34:46', '3900', 1),
(616, '71267825', '2018-07-27 06:47:01', '2000', 1),
(617, '1020479554', '2018-07-27 06:49:38', '10000', 1),
(618, '1020430141', '2018-07-27 07:02:32', '5100', 1),
(619, '43975208', '2018-07-27 07:03:30', '6000', 1),
(620, '1017156424', '2018-07-27 07:05:49', '13000', 1),
(621, '1152697088', '2018-07-27 07:10:11', '5900', 1),
(622, '1036601013', '2018-07-27 07:11:32', '2000', 1),
(623, '98699433', '2018-07-27 07:12:20', '6800', 1),
(624, '1040044905', '2018-07-27 07:14:52', '8700', 1),
(625, '1017212362', '2018-07-27 07:23:39', '11900', 1),
(626, '1152450553', '2018-07-27 07:24:19', '9900', 1),
(627, '32353491', '2018-07-27 07:27:09', '3400', 1),
(628, '43271378', '2018-07-27 07:38:07', '8000', 1),
(629, '1017239142', '2018-07-26 09:54:48', '7900', 1),
(630, '1214721942', '2018-07-28 12:00:00', '8000', 1),
(631, '1017156424', '2018-07-28 06:14:16', '15000', 1),
(632, '1040757557', '2018-07-28 06:16:29', '7000', 1),
(633, '1020464577', '2018-07-28 06:20:41', '6400', 1),
(634, '1046913982', '2018-07-28 06:23:21', '12700', 1),
(635, '1020479554', '2018-07-28 07:04:33', '4100', 1),
(636, '1129045994', '2018-07-28 07:06:31', '6100', 1),
(637, '1095791547', '2018-07-28 07:17:28', '4800', 1),
(638, '1017219391', '2018-07-28 07:28:24', '5300', 1),
(639, '1035879778', '2018-07-28 07:29:43', '3900', 1),
(640, '1020430141', '2018-07-28 07:34:11', '5200', 1),
(641, '43271378', '2018-07-28 07:35:25', '4500', 1),
(642, '1129045994', '2018-07-30 06:05:15', '14700', 1),
(643, '1017216447', '2018-07-30 06:05:24', '4700', 1),
(644, '1017137065', '2018-07-30 06:06:02', '7900', 1),
(645, '1020479554', '2018-07-30 06:06:38', '10000', 1),
(646, '1037631569', '2018-07-30 06:06:49', '7900', 1),
(647, '1044915764', '2018-07-30 06:08:36', '7900', 1),
(648, '1035427628', '2018-07-30 06:10:47', '13200', 1),
(649, '1017132272', '2018-07-30 06:12:13', '2000', 1),
(650, '1020430141', '2018-07-30 06:34:05', '7900', 1),
(651, '1095791547', '2018-07-30 06:36:33', '6800', 1),
(652, '760579', '2018-07-30 06:37:19', '1200', 1),
(653, '71267825', '2018-07-30 06:39:45', '2000', 1),
(654, '1152450553', '2018-07-30 06:44:17', '12500', 1),
(655, '1040757557', '2018-07-30 06:50:38', '2000', 1),
(656, '1020457057', '2018-07-30 06:52:19', '5300', 1),
(657, '43288005', '2018-07-30 06:56:05', '7900', 1),
(658, '32353491', '2018-07-30 06:58:32', '9300', 1),
(659, '1046913982', '2018-07-30 06:59:03', '11800', 1),
(660, '1077453248', '2018-07-30 07:02:48', '6500', 1),
(661, '1017125039', '2018-07-30 07:10:59', '2500', 1),
(662, '1036601013', '2018-07-30 07:15:13', '2000', 1),
(663, '1028009266', '2018-07-30 07:19:16', '5900', 1),
(664, '1078579715', '2018-07-30 07:25:53', '7900', 1),
(665, '98699433', '2018-07-30 07:38:00', '6800', 1),
(666, '1017156424', '2018-07-30 07:38:56', '13800', 1),
(667, '1128267430', '2018-07-30 07:41:56', '13800', 1),
(668, '43841319', '2018-07-30 08:24:56', '2000', 1),
(669, '1028016893', '2018-07-31 14:20:51', '5000', 1),
(670, '1035879778', '2018-07-31 06:03:19', '3900', 1),
(671, '43189198', '2018-07-31 06:04:41', '7900', 1),
(672, '26201420', '2018-07-31 06:06:03', '7900', 1),
(673, '1044915764', '2018-07-31 06:06:53', '7900', 1),
(674, '1017216447', '2018-07-31 06:07:56', '5900', 1),
(675, '1020430141', '2018-07-31 06:11:46', '4100', 1),
(676, '1129045994', '2018-07-31 06:13:41', '6800', 1),
(677, '43975208', '2018-07-31 06:25:45', '2000', 1),
(678, '1020479554', '2018-07-31 06:26:45', '8000', 1),
(679, '1214721942', '2018-07-31 06:40:21', '6000', 1),
(680, '1040757557', '2018-07-31 06:47:53', '2000', 1),
(681, '71267825', '2018-07-31 06:52:32', '2000', 1),
(682, '1020464577', '2018-07-31 07:09:06', '14000', 1),
(683, '1152450553', '2018-07-31 07:10:44', '11900', 1),
(684, '1143991147', '2018-07-31 07:25:43', '4400', 1),
(685, '1046913982', '2018-07-31 07:27:08', '4000', 1),
(686, '1152210828', '2018-07-31 07:30:03', '1400', 1),
(687, '1017125039', '2018-07-31 07:30:09', '2000', 1),
(688, '1028009266', '2018-07-31 07:31:18', '5900', 1),
(689, '43265824', '2018-08-01 06:03:09', '11900', 1),
(690, '32353491', '2018-08-01 06:04:08', '3400', 1),
(691, '1037587834', '2018-08-01 06:10:49', '11800', 1),
(692, '1152450553', '2018-08-01 06:21:42', '17200', 1),
(693, '71267825', '2018-08-01 06:34:59', '2000', 1),
(694, '1017125039', '2018-08-01 07:01:09', '6200', 1),
(695, '1129045994', '2018-08-01 07:13:47', '6800', 1),
(696, '1046913982', '2018-08-01 07:30:05', '3800', 1),
(697, '1020479554', '2018-08-01 07:33:16', '10000', 1),
(698, '1036629003', '2018-08-01 07:36:45', '10400', 1),
(699, '1214721942', '2018-08-01 07:39:21', '3000', 1),
(700, '1044915764', '2018-08-01 15:53:36', '7900', 0),
(701, '71267825', '2018-08-02 06:08:05', '2000', 1),
(702, '1044915764', '2018-08-02 06:14:16', '7900', 1),
(703, '1017216447', '2018-08-02 06:27:03', '4300', 1),
(704, '1066743123', '2018-08-02 06:29:13', '5900', 1),
(705, '760579', '2018-08-02 06:32:41', '5900', 1),
(706, '1020430141', '2018-08-02 06:51:00', '4000', 1),
(707, '98699433', '2018-08-02 06:51:36', '11800', 1),
(708, '32353491', '2018-08-02 06:55:00', '4000', 1),
(709, '71268332', '2018-08-02 07:01:32', '3000', 1),
(710, '1036601013', '2018-08-02 07:09:28', '2000', 1),
(711, '1017147712', '2018-08-02 07:13:24', '7900', 1),
(712, '43271378', '2018-08-02 07:14:35', '5900', 1),
(713, '43841319', '2018-08-02 07:25:22', '7900', 1),
(714, '1028009266', '2018-08-02 11:57:45', '2000', 0),
(715, '1078579715', '2018-08-03 17:15:39', '2800', 1),
(716, '1017216447', '2018-08-03 06:05:13', '11200', 1),
(717, '1035427628', '2018-08-03 06:06:30', '5000', 1),
(718, '43288005', '2018-08-03 06:08:03', '10900', 1),
(719, '1020479554', '2018-08-03 06:21:45', '8000', 1),
(720, '71267825', '2018-08-03 06:33:26', '5900', 1),
(721, '1035879778', '2018-08-03 06:34:49', '2000', 1),
(722, '1152450553', '2018-08-03 06:37:05', '14400', 1),
(723, '760579', '2018-08-03 06:38:00', '5900', 1),
(724, '1096238261', '2018-08-03 06:38:57', '7900', 1),
(725, '1036601013', '2018-08-03 07:12:24', '2000', 1),
(726, '1152697088', '2018-08-03 07:19:31', '5900', 1),
(727, '1152210828', '2018-08-03 07:23:22', '1400', 1),
(728, '1036629003', '2018-08-03 07:27:02', '7900', 1),
(729, '43271378', '2018-08-03 07:29:49', '9500', 1),
(730, '8433778', '2018-08-03 07:30:18', '7900', 1),
(731, '1017156424', '2018-08-03 07:33:31', '23800', 1),
(732, '1066743123', '2018-08-03 07:34:00', '5900', 1),
(733, '1095791547', '2018-08-03 07:34:02', '4800', 1),
(734, '32353491', '2018-08-03 07:36:35', '3400', 1),
(735, '1017125039', '2018-08-03 07:38:10', '5000', 1),
(736, '71267825', '2018-08-06 06:13:16', '2000', 1),
(737, '1035427628', '2018-08-06 06:28:38', '4000', 1),
(738, '1129045994', '2018-08-06 06:29:04', '4100', 1),
(739, '1036598684', '2018-08-06 06:31:06', '9900', 1),
(740, '43288005', '2018-08-06 06:33:58', '7900', 1),
(741, '43975208', '2018-08-06 06:34:55', '2000', 1),
(742, '1020479554', '2018-08-06 06:48:46', '8000', 1),
(743, '1036629003', '2018-08-06 06:51:24', '14700', 1),
(744, '1096238261', '2018-08-06 06:53:41', '2000', 1),
(745, '1152450553', '2018-08-06 06:57:11', '7900', 1),
(746, '1066743123', '2018-08-06 07:00:53', '5900', 1),
(747, '1152210828', '2018-08-06 07:10:59', '1400', 1),
(748, '1037587834', '2018-08-06 07:11:29', '7900', 1),
(749, '32353491', '2018-08-06 07:16:19', '9900', 1),
(750, '1017239142', '2018-08-06 07:29:07', '1400', 1),
(751, '1037606721', '2018-08-06 07:29:44', '7900', 1),
(752, '1020464577', '2018-08-06 07:29:44', '2800', 1),
(754, '1017219391', '2018-08-06 07:34:34', '1400', 1),
(755, '1017137065', '2018-08-06 07:37:48', '2000', 1),
(756, '1028009266', '2018-08-06 07:40:14', '9100', 1),
(757, '43271378', '2018-08-06 07:42:16', '4000', 1),
(758, '1128405581', '2018-08-06 07:44:04', '4200', 1),
(759, '1036601013', '2018-08-08 06:18:47', '7000', 1),
(760, '98699433', '2018-08-08 06:21:36', '4800', 1),
(761, '1017216447', '2018-08-08 06:24:53', '7900', 1),
(762, '1152450553', '2018-08-08 06:32:51', '13900', 1),
(763, '1037587834', '2018-08-08 06:38:13', '7000', 1),
(764, '1017132272', '2018-08-08 06:42:17', '2000', 1),
(765, '1020430141', '2018-08-08 06:46:09', '6200', 1),
(766, '1129045994', '2018-08-08 06:56:16', '12700', 1),
(767, '1035427628', '2018-08-08 06:57:56', '7900', 1),
(768, '1017137065', '2018-08-08 06:59:25', '2000', 1),
(769, '1152210828', '2018-08-08 07:04:25', '1400', 1),
(770, '71267825', '2018-08-08 07:07:34', '2000', 1),
(771, '1039447684', '2018-08-08 07:15:15', '7900', 1),
(772, '1128267430', '2018-08-08 07:35:09', '8400', 1),
(773, '1028009266', '2018-08-08 07:36:36', '8400', 1),
(774, '43271378', '2018-08-08 07:45:58', '3000', 1),
(775, '43975208', '2018-08-08 09:33:35', '2000', 1),
(776, '1017216447', '2018-08-09 06:00:43', '12600', 1),
(777, '1017137065', '2018-08-09 06:01:29', '2000', 1),
(778, '1020430141', '2018-08-09 06:02:17', '4200', 1),
(779, '1035879778', '2018-08-09 06:05:12', '5200', 1),
(780, '1036601013', '2018-08-09 06:07:10', '2000', 1),
(781, '760579', '2018-08-09 06:09:36', '5900', 1),
(782, '71267825', '2018-08-09 06:14:19', '2000', 1),
(783, '1020479554', '2018-08-09 06:30:36', '8000', 1),
(784, '1152450553', '2018-08-09 06:39:51', '6500', 1),
(785, '43271378', '2018-08-09 06:57:45', '10400', 1),
(786, '1152697088', '2018-08-09 07:02:52', '5900', 1),
(787, '1039049115', '2018-08-09 07:23:02', '7000', 1),
(788, '1152210828', '2018-08-09 07:23:45', '1400', 1),
(789, '1129045994', '2018-08-09 07:41:32', '6200', 1),
(790, '1036629003', '2018-08-09 07:42:52', '2500', 1),
(791, '1078579715', '2018-08-10 16:30:12', '7900', 1),
(792, '71267825', '2018-08-10 06:04:20', '5900', 1),
(793, '1017216447', '2018-08-10 06:07:02', '15700', 1),
(794, '760579', '2018-08-10 06:07:47', '5900', 1),
(795, '1017137065', '2018-08-10 06:09:50', '2000', 1),
(796, '1152450553', '2018-08-10 06:10:49', '4500', 1),
(797, '1035427628', '2018-08-10 06:11:46', '1400', 1),
(798, '1037587834', '2018-08-10 06:25:00', '9900', 1),
(799, '1040757557', '2018-08-10 06:27:52', '2000', 1),
(800, '1020479554', '2018-08-10 06:29:47', '8000', 1),
(801, '98699433', '2018-08-10 06:42:15', '6800', 1),
(802, '1095791547', '2018-08-10 06:47:23', '7900', 1),
(803, '54253320', '2018-08-10 06:51:08', '4200', 1),
(804, '1046913982', '2018-08-10 07:08:30', '7900', 1),
(805, '1020430141', '2018-08-10 07:09:15', '4200', 1),
(806, '1017125039', '2018-08-10 07:30:31', '2800', 1),
(807, '1129045994', '2018-08-10 07:40:49', '6800', 1),
(808, '1046913982', '2018-08-13 06:10:40', '7900', 1),
(809, '1037631569', '2018-08-13 06:12:27', '12600', 1),
(810, '1017216447', '2018-08-13 06:13:28', '6200', 1),
(811, '1066743123', '2018-08-13 06:14:28', '5900', 1),
(812, '1039049115', '2018-08-13 06:22:52', '4800', 1),
(813, '43975208', '2018-08-13 06:24:06', '9900', 1),
(814, '1096238261', '2018-08-13 06:24:28', '9900', 1),
(815, '1128405581', '2018-08-13 06:49:35', '4200', 1),
(816, '1036601013', '2018-08-13 06:52:03', '2000', 1),
(817, '1017156424', '2018-08-13 06:55:31', '13100', 1),
(818, '1214721942', '2018-08-13 07:00:01', '5200', 1),
(819, '1020479554', '2018-08-13 07:04:27', '2100', 1),
(820, '1017137065', '2018-08-13 07:06:54', '2000', 1),
(822, '1017125039', '2018-08-13 07:13:30', '4600', 1),
(823, '1143991147', '2018-08-13 07:15:09', '2900', 1),
(824, '1020430141', '2018-08-13 07:22:49', '6100', 1),
(825, '1129045994', '2018-08-13 07:24:10', '14700', 1),
(826, '1095791547', '2018-08-13 07:25:50', '7900', 1),
(827, '1028009266', '2018-08-13 07:27:19', '9800', 1),
(828, '71268332', '2018-08-13 07:29:32', '3000', 1),
(829, '1040757557', '2018-08-13 07:32:26', '2500', 1),
(830, '1128267430', '2018-08-13 12:00:00', '1400', 1),
(831, '1077453248', '2018-08-13 07:35:40', '6500', 1),
(832, '43271378', '2018-08-13 11:24:26', '2000', 1),
(833, '1214721942', '2018-08-14 06:01:03', '4000', 1),
(834, '1017216447', '2018-08-14 06:01:57', '2500', 1),
(835, '8433778', '2018-08-14 06:03:40', '2000', 1),
(836, '1035427628', '2018-08-14 06:04:36', '7900', 1),
(837, '1017137065', '2018-08-14 06:06:49', '2000', 1),
(838, '1036601013', '2018-08-14 06:08:03', '2000', 1),
(839, '1152701919', '2018-08-14 06:09:44', '7900', 1),
(840, '1046913982', '2018-08-14 07:26:07', '11500', 1),
(841, '1020479554', '2018-08-14 06:10:46', '2100', 1),
(842, '1035879778', '2018-08-14 06:10:48', '3900', 1),
(843, '1066743123', '2018-08-14 06:11:39', '5900', 1),
(844, '71267825', '2018-08-14 06:12:08', '5900', 1),
(845, '98699433', '2018-08-14 06:16:10', '6800', 1),
(846, '1039049115', '2018-08-14 06:19:55', '2800', 1),
(847, '43975208', '2018-08-14 06:24:18', '9600', 1),
(848, '1096238261', '2018-08-14 06:26:51', '7900', 1),
(849, '1152450553', '2018-08-14 06:28:36', '14400', 1),
(850, '71268332', '2018-08-14 07:01:25', '3000', 1),
(851, '54253320', '2018-08-14 07:14:54', '5600', 1),
(852, '1017156424', '2018-08-14 07:18:12', '15800', 1),
(853, '1035915735', '2018-08-14 07:20:36', '7600', 1),
(854, '1095791547', '2018-08-14 07:36:28', '7900', 1),
(855, '1017125039', '2018-08-14 07:37:31', '2500', 1),
(856, '1017239142', '2018-08-14 07:39:59', '7900', 1),
(857, '1128267430', '2018-08-14 07:41:43', '3000', 1),
(858, '1129045994', '2018-08-14 07:42:01', '6800', 1),
(860, '1028009266', '2018-08-14 07:53:06', '8900', 1),
(861, '43605625', '2018-08-14 07:54:56', '5900', 1),
(862, '1017216447', '2018-08-15 06:02:07', '12200', 1),
(863, '1040757557', '2018-08-15 06:03:22', '3800', 1),
(864, '1035427628', '2018-08-15 06:05:24', '13200', 1),
(865, '43975208', '2018-08-15 06:05:40', '2000', 1),
(866, '1128430240', '2018-08-15 06:06:34', '7900', 1),
(867, '1096238261', '2018-08-15 06:06:52', '7900', 1),
(868, '1035879778', '2018-08-15 06:09:13', '2500', 1),
(869, '71267825', '2018-08-15 06:12:36', '2000', 1),
(870, '1066743123', '2018-08-15 06:13:15', '5900', 1),
(871, '1017137065', '2018-08-15 06:17:09', '7100', 1),
(872, '98699433', '2018-08-15 06:23:17', '7900', 1),
(873, '1214721942', '2018-08-15 06:30:15', '15400', 1),
(874, '1046913982', '2018-08-15 06:35:25', '13600', 1),
(875, '1017147712', '2018-08-15 06:43:04', '7900', 1),
(876, '1036629003', '2018-08-15 06:43:52', '3900', 1),
(877, '32353491', '2018-08-15 07:24:04', '7900', 1),
(878, '1020479554', '2018-08-15 07:24:21', '2100', 1),
(879, '1095791547', '2018-08-15 07:25:35', '7900', 1),
(880, '1152210828', '2018-08-15 07:36:11', '1400', 1),
(881, '1020457057', '2018-08-15 07:36:30', '1400', 1),
(882, '43271378', '2018-08-15 07:38:07', '10400', 1),
(883, '1028009266', '2018-08-15 07:40:14', '5900', 1),
(884, '1078579715', '2018-08-16 15:32:35', '7900', 1),
(885, '1020457057', '2018-08-16 06:00:58', '15800', 1),
(886, '1036598684', '2018-08-16 06:01:41', '7900', 1),
(887, '1040757557', '2018-08-16 06:02:54', '9900', 1),
(888, '1017137065', '2018-08-16 06:03:40', '7900', 1),
(889, '43189198', '2018-08-16 06:08:06', '5000', 1),
(890, '1017216447', '2018-08-16 06:09:32', '12400', 1),
(891, '1037587834', '2018-08-16 06:10:31', '17800', 1),
(892, '71267825', '2018-08-16 06:11:25', '2000', 1),
(893, '1152450553', '2018-08-16 06:12:34', '14400', 1),
(894, '1152701919', '2018-08-16 06:15:33', '14800', 1),
(895, '1017156424', '2018-08-16 06:32:40', '8000', 1),
(896, '1035879778', '2018-08-16 06:33:32', '4500', 1),
(897, '43605625', '2018-08-16 06:41:20', '4000', 1),
(898, '98699433', '2018-08-16 06:43:00', '6800', 1),
(899, '1017125039', '2018-08-16 06:48:31', '6200', 1),
(900, '1143991147', '2018-08-16 06:50:53', '4800', 1),
(901, '1020479554', '2018-08-16 07:03:43', '8000', 1),
(902, '1095791547', '2018-08-16 07:04:40', '15800', 1),
(903, '32353491', '2018-08-16 07:26:30', '2000', 1),
(904, '43596807', '2018-08-16 07:34:34', '2000', 1),
(905, '43271378', '2018-08-16 07:37:02', '2000', 1),
(906, '1037587834', '2018-08-17 06:09:35', '5100', 1),
(907, '1020479554', '2018-08-17 06:12:23', '10000', 1),
(908, '1017216447', '2018-08-17 06:13:26', '10900', 1),
(909, '1036629003', '2018-08-17 06:15:50', '11900', 1),
(910, '26201420', '2018-08-17 06:20:17', '7900', 1),
(911, '1040757557', '2018-08-17 06:21:15', '2000', 1),
(912, '1095791547', '2018-08-17 06:23:08', '7900', 1),
(913, '1152450553', '2018-08-17 06:28:52', '14900', 1),
(914, '71267825', '2018-08-17 06:35:11', '5900', 1),
(915, '1039049115', '2018-08-17 06:35:25', '2800', 1),
(916, '32353491', '2018-08-17 07:14:07', '2000', 1),
(917, '43271378', '2018-08-17 07:29:20', '4000', 1),
(918, '1152697088', '2018-08-17 07:32:48', '5900', 1),
(919, '43841319', '2018-08-17 07:44:26', '3000', 1),
(920, '1017219391', '2018-08-17 08:10:28', '3900', 1),
(922, '1017156424', '2018-08-21 12:00:00', '8100', 1),
(923, '71267825', '2018-08-21 06:36:44', '2000', 1),
(924, '1020479554', '2018-08-21 06:41:46', '2100', 1),
(925, '1040757557', '2018-08-21 06:45:22', '2000', 1),
(926, '1037587834', '2018-08-21 06:50:48', '5000', 1),
(927, '43288005', '2018-08-21 06:59:43', '7900', 1),
(928, '1066743123', '2018-08-21 07:01:05', '5900', 1),
(929, '1017137065', '2018-08-21 12:00:00', '5300', 1),
(930, '1129045994', '2018-08-21 07:11:38', '9800', 1),
(931, '1020464577', '2018-08-21 07:13:59', '8000', 1),
(932, '43596807', '2018-08-21 07:31:38', '2000', 1),
(933, '32353491', '2018-08-21 07:33:08', '5900', 1),
(934, '1152450553', '2018-08-21 12:00:00', '2500', 1),
(935, '1017216447', '2018-08-22 06:23:21', '6300', 1),
(936, '1039049115', '2018-08-22 06:32:18', '4200', 1),
(937, '1077453248', '2018-08-22 06:35:39', '7900', 1),
(938, '1017125039', '2018-08-22 06:37:59', '5000', 1),
(939, '1046913982', '2018-08-22 06:40:13', '4500', 1),
(940, '32353491', '2018-08-22 06:47:00', '2000', 1),
(941, '71267825', '2018-08-22 06:54:52', '2000', 1),
(942, '1214721942', '2018-08-22 07:06:17', '8600', 1),
(943, '1036629003', '2018-08-22 07:20:45', '4000', 1),
(944, '1152450553', '2018-08-22 07:24:01', '2200', 1),
(945, '1152210828', '2018-08-22 07:25:47', '1400', 1),
(946, '43596807', '2018-08-22 07:30:17', '2000', 1),
(947, '1129045994', '2018-08-22 07:37:24', '6800', 1),
(948, '1017156424', '2018-08-22 07:38:21', '6000', 1),
(949, '1007110815', '2018-08-22 07:38:59', '7000', 1),
(950, '43841319', '2018-08-22 07:41:52', '4500', 1),
(951, '71268332', '2018-08-22 07:42:28', '3000', 1),
(952, '1128447453', '2018-08-22 07:43:14', '4000', 1),
(953, '1078579715', '2018-08-23 17:29:32', '7900', 1),
(954, '1152450553', '2018-08-23 06:04:53', '7900', 1),
(955, '1036601013', '2018-08-23 06:05:46', '2000', 1),
(956, '71267825', '2018-08-23 06:12:12', '2000', 1),
(957, '1035427628', '2018-08-23 06:14:19', '2000', 1),
(958, '1020479554', '2018-08-23 12:00:00', '10900', 1),
(960, '1017216447', '2018-08-23 06:21:10', '13200', 1),
(961, '98772784', '2018-08-23 06:24:00', '7900', 1),
(962, '43975208', '2018-08-23 06:30:04', '5900', 1),
(963, '1017156424', '2018-08-23 06:31:13', '21500', 1),
(964, '1129045994', '2018-08-23 07:09:28', '12100', 1),
(965, '1035915735', '2018-08-23 07:16:14', '5900', 1),
(966, '1046913982', '2018-08-23 07:18:28', '10900', 1),
(967, '1039049115', '2018-08-23 07:20:00', '4200', 1),
(968, '43288005', '2018-08-23 07:21:17', '7900', 1),
(969, '1020430141', '2018-08-23 07:25:31', '6200', 1),
(970, '1128447453', '2018-08-23 07:26:55', '4000', 1),
(971, '32353491', '2018-08-23 07:30:54', '7900', 1),
(972, '43596807', '2018-08-23 07:37:58', '2000', 1),
(973, '1017239142', '2018-08-23 07:38:43', '2000', 1),
(974, '1036601013', '2018-08-24 06:05:16', '2000', 1),
(975, '1036598684', '2018-08-24 06:06:12', '7900', 1),
(976, '760579', '2018-08-24 06:06:52', '5900', 1),
(977, '1020479554', '2018-08-24 06:07:36', '10000', 1),
(978, '1066743123', '2018-08-24 06:08:46', '5900', 1),
(979, '1017132272', '2018-08-24 06:11:39', '7000', 1),
(980, '1152450553', '2018-08-24 06:30:05', '15900', 1),
(981, '1037587834', '2018-08-24 06:34:54', '11600', 1),
(982, '43605625', '2018-08-24 06:36:26', '5900', 1);
INSERT INTO `pedido` (`idPedido`, `documento`, `fecha_pedido`, `total`, `estado`) VALUES
(983, '71267825', '2018-08-24 06:36:47', '5900', 1),
(984, '1077453248', '2018-08-24 06:42:29', '4000', 1),
(985, '1214721942', '2018-08-24 06:44:12', '7300', 1),
(986, '1095791547', '2018-08-24 07:02:27', '7900', 1),
(987, '1152210828', '2018-08-24 07:15:23', '1400', 1),
(988, '1028009266', '2018-08-24 07:41:10', '2500', 1),
(989, '1020464577', '2018-08-24 08:26:54', '4000', 1),
(990, '1017216447', '2018-08-27 06:13:45', '8200', 1),
(991, '21424773', '2018-08-27 06:14:42', '7900', 1),
(992, '1020430141', '2018-08-27 06:16:30', '6200', 1),
(993, '1035879778', '2018-08-27 06:17:46', '3900', 1),
(994, '71267825', '2018-08-27 06:20:05', '5900', 1),
(995, '98772784', '2018-08-27 06:23:24', '4000', 1),
(996, '1152701919', '2018-08-27 06:25:50', '6900', 1),
(997, '32353491', '2018-08-27 06:26:31', '2000', 1),
(998, '43288005', '2018-08-27 06:28:29', '12400', 1),
(999, '1037606721', '2018-08-27 06:32:37', '7900', 1),
(1000, '1152210828', '2018-08-27 06:34:14', '2700', 1),
(1001, '1017156424', '2018-08-27 06:36:14', '10000', 1),
(1002, '1020479554', '2018-08-27 06:47:36', '2100', 1),
(1003, '71268332', '2018-08-27 07:13:16', '7900', 1),
(1004, '1129045994', '2018-08-27 07:15:11', '6200', 1),
(1005, '98699433', '2018-08-27 07:26:20', '6800', 1),
(1006, '1007110815', '2018-08-27 07:35:50', '14700', 1),
(1007, '43596807', '2018-08-27 07:37:47', '2000', 1),
(1008, '43271378', '2018-08-27 07:44:11', '4500', 1),
(1009, '1046913982', '2018-08-28 06:02:20', '6000', 1),
(1010, '1035427628', '2018-08-28 06:03:35', '2000', 1),
(1011, '1128447453', '2018-08-28 06:07:11', '4000', 1),
(1012, '1017216447', '2018-08-28 06:08:58', '8300', 1),
(1013, '1036629003', '2018-08-28 06:42:48', '8700', 1),
(1014, '98699433', '2018-08-28 06:42:52', '6800', 1),
(1015, '43975208', '2018-08-28 06:50:39', '2000', 1),
(1016, '1020430141', '2018-08-28 06:56:44', '2800', 1),
(1017, '98772784', '2018-08-28 07:05:56', '2100', 1),
(1018, '1020479554', '2018-08-28 07:06:33', '2100', 1),
(1019, '1017125039', '2018-08-28 07:15:46', '5000', 1),
(1020, '32353491', '2018-08-28 07:14:05', '2000', 1),
(1021, '43288005', '2018-08-28 07:24:41', '7900', 1),
(1022, '1066743123', '2018-08-28 07:34:07', '5900', 1),
(1023, '43271378', '2018-08-28 07:34:57', '4500', 1),
(1024, '43596807', '2018-08-28 07:35:50', '2000', 1),
(1025, '1078579715', '2018-08-29 16:14:19', '2800', 1),
(1026, '1017216447', '2018-08-29 06:02:40', '7000', 1),
(1027, '1017137065', '2018-08-29 06:03:47', '2100', 1),
(1028, '1007110815', '2018-08-29 06:04:40', '7900', 1),
(1029, '1035427628', '2018-08-29 06:05:44', '2000', 1),
(1030, '1066743123', '2018-08-29 06:07:52', '5900', 1),
(1031, '1020430141', '2018-08-29 06:11:15', '15700', 1),
(1032, '71267825', '2018-08-29 06:16:46', '2000', 1),
(1033, '1036601013', '2018-08-29 06:43:08', '7000', 1),
(1034, '1017156424', '2018-08-29 06:47:15', '22500', 1),
(1035, '1152450553', '2018-08-29 06:52:43', '14400', 1),
(1036, '32353491', '2018-08-29 06:57:32', '2000', 1),
(1037, '1152701919', '2018-08-29 06:58:24', '14700', 1),
(1038, '1020479554', '2018-08-29 07:02:41', '10000', 1),
(1039, '26201420', '2018-08-29 07:06:07', '7900', 1),
(1040, '1129045994', '2018-08-29 07:09:19', '12100', 1),
(1041, '54253320', '2018-08-29 07:12:18', '4200', 1),
(1042, '43975208', '2018-08-29 07:13:52', '9600', 1),
(1043, '1046913982', '2018-08-29 07:25:34', '4500', 1),
(1044, '1152210828', '2018-08-29 07:27:12', '1400', 1),
(1045, '43596807', '2018-08-29 07:28:45', '2000', 1),
(1046, '1143991147', '2018-08-29 07:36:37', '1400', 1),
(1047, '1036629003', '2018-08-29 07:37:53', '2500', 1),
(1048, '1039447684', '2018-08-30 15:44:23', '7900', 1),
(1049, '1078579715', '2018-08-30 17:03:53', '7900', 1),
(1050, '1035427628', '2018-08-30 06:04:43', '14400', 1),
(1051, '1007110815', '2018-08-30 06:08:11', '14700', 1),
(1052, '1017216447', '2018-08-30 06:10:06', '14000', 1),
(1053, '71267825', '2018-08-30 06:10:14', '5900', 1),
(1054, '1017137065', '2018-08-30 06:10:26', '2900', 1),
(1055, '1020479554', '2018-08-30 06:12:58', '8000', 1),
(1056, '1152450553', '2018-08-30 06:24:35', '10400', 1),
(1057, '43288005', '2018-08-30 06:30:24', '12400', 1),
(1058, '43605625', '2018-08-30 06:34:39', '2000', 1),
(1059, '1039049115', '2018-08-30 06:44:08', '1400', 1),
(1060, '43975208', '2018-08-30 06:44:25', '6500', 1),
(1061, '1128447453', '2018-08-30 06:57:02', '7900', 1),
(1062, '43841319', '2018-08-30 07:09:49', '3000', 1),
(1063, '71268332', '2018-08-30 07:11:23', '3000', 1),
(1064, '43271378', '2018-08-30 07:13:48', '10400', 1),
(1065, '1035879778', '2018-08-30 07:16:56', '4500', 1),
(1066, '1152210828', '2018-08-30 07:21:08', '1400', 1),
(1067, '54253320', '2018-08-30 07:22:40', '3000', 1),
(1068, '1020464577', '2018-08-30 07:24:49', '13300', 1),
(1069, '1017156424', '2018-08-30 07:27:00', '9900', 1),
(1070, '43596807', '2018-08-30 07:30:28', '2000', 1),
(1071, '1017125039', '2018-08-30 07:32:15', '3400', 1),
(1072, '1017239142', '2018-08-30 07:38:33', '1400', 1),
(1073, '32353491', '2018-08-30 07:40:40', '7900', 1),
(1075, '1020457057', '2018-08-31 06:03:09', '4000', 1),
(1076, '1017137065', '2018-08-31 06:05:14', '4000', 1),
(1077, '1017216447', '2018-08-31 06:06:33', '18100', 1),
(1078, '1046913982', '2018-08-31 06:09:26', '12900', 1),
(1079, '1020479554', '2018-08-31 06:09:39', '8000', 1),
(1080, '43288005', '2018-08-31 06:14:55', '7900', 1),
(1081, '1036629003', '2018-08-31 06:15:48', '7900', 1),
(1082, '1020430141', '2018-08-31 06:18:51', '4200', 1),
(1083, '71267825', '2018-08-31 06:20:32', '5900', 1),
(1085, '1007110815', '2018-08-31 06:51:18', '12700', 1),
(1086, '1036601013', '2018-08-31 07:03:37', '2000', 1),
(1087, '1152450553', '2018-08-31 07:04:25', '5900', 1),
(1088, '1096238261', '2018-08-31 07:05:20', '2000', 1),
(1089, '1128447453', '2018-08-31 07:06:17', '7900', 1),
(1090, '98772784', '2018-08-31 07:14:06', '5900', 1),
(1091, '1020464577', '2018-08-31 07:23:47', '2000', 1),
(1092, '1017125039', '2018-08-31 07:33:17', '6200', 1),
(1093, '43271378', '2018-08-31 07:37:32', '5000', 1),
(1094, '43605625', '2018-08-31 07:41:11', '7900', 1),
(1095, '1017187557', '2018-08-31 07:41:57', '7900', 1),
(1096, '1017239142', '2018-08-31 07:42:35', '1400', 1),
(1097, '32353491', '2018-08-31 07:43:24', '2000', 1),
(1098, '1128405581', '2018-08-31 07:43:25', '2800', 1),
(1099, '1017216447', '2018-09-03 06:22:21', '7900', 1),
(1100, '43975208', '2018-09-03 06:36:37', '2000', 1),
(1101, '1020430141', '2018-09-03 07:15:34', '6000', 1),
(1102, '1035915735', '2018-09-03 07:20:08', '4800', 1),
(1103, '1036629003', '2018-09-03 07:23:12', '4000', 1),
(1104, '43271378', '2018-09-03 07:26:06', '4000', 1),
(1105, '1129045994', '2018-09-03 07:31:29', '12100', 1),
(1106, '32353491', '2018-09-03 07:39:45', '2000', 1),
(1107, '43596807', '2018-09-03 07:40:18', '2000', 1),
(1108, '1017156424', '2018-09-04 06:05:34', '9900', 1),
(1109, '1036629003', '2018-09-04 06:05:43', '11900', 1),
(1110, '1007110815', '2018-09-04 06:07:05', '6500', 1),
(1111, '1046913982', '2018-09-04 06:09:26', '8200', 1),
(1112, '1152701919', '2018-09-04 06:12:48', '5900', 1),
(1113, '1017137065', '2018-09-04 06:14:50', '2000', 1),
(1114, '71267825', '2018-09-04 06:38:36', '2000', 1),
(1115, '1096238261', '2018-09-04 06:39:10', '7900', 1),
(1116, '1020457057', '2018-09-04 12:00:00', '3800', 1),
(1117, '1017179570', '2018-09-04 06:42:40', '2500', 1),
(1118, '1020430141', '2018-09-04 06:48:59', '6100', 1),
(1119, '1152450553', '2018-09-04 06:51:10', '14400', 1),
(1120, '98699433', '2018-09-04 06:51:56', '9200', 1),
(1121, '43271378', '2018-09-04 07:15:12', '3700', 1),
(1122, '1037587834', '2018-09-04 07:30:01', '7900', 1),
(1123, '1017239142', '2018-09-04 07:41:40', '1400', 1),
(1124, '1129045994', '2018-09-05 06:02:37', '6200', 1),
(1125, '1020479554', '2018-09-05 06:07:48', '2100', 1),
(1126, '1020430141', '2018-09-05 06:19:16', '4000', 1),
(1127, '71267825', '2018-09-05 06:21:41', '2000', 1),
(1128, '1017156424', '2018-09-05 06:41:29', '19400', 1),
(1129, '43189198', '2018-09-05 06:50:53', '7900', 1),
(1130, '32353491', '2018-09-05 07:43:32', '2000', 1),
(1131, '1078579715', '2018-09-06 15:30:11', '7900', 1),
(1132, '1036598684', '2018-09-06 06:01:33', '6200', 1),
(1133, '21424773', '2018-09-06 06:02:55', '4000', 1),
(1134, '1020430141', '2018-09-06 06:04:14', '4000', 1),
(1135, '1036601013', '2018-09-06 06:05:33', '2000', 1),
(1136, '1017132272', '2018-09-06 06:07:45', '2000', 1),
(1137, '1129045994', '2018-09-06 06:10:03', '6200', 1),
(1138, '1096238261', '2018-09-06 06:23:11', '6500', 1),
(1139, '1152450553', '2018-09-06 06:15:52', '7900', 1),
(1140, '1035427628', '2018-09-06 06:20:28', '2000', 1),
(1141, '1017216447', '2018-09-06 06:29:32', '4100', 1),
(1142, '43605625', '2018-09-06 06:29:43', '7900', 1),
(1143, '1017156424', '2018-09-06 06:38:06', '6300', 1),
(1144, '1020464577', '2018-09-06 06:41:45', '13800', 1),
(1145, '1017125039', '2018-09-06 07:03:07', '9600', 1),
(1146, '1095791547', '2018-09-06 07:10:19', '12000', 1),
(1147, '1020479554', '2018-09-06 07:10:59', '2100', 1),
(1148, '43271378', '2018-09-06 07:35:09', '4500', 1),
(1149, '43596807', '2018-09-06 07:36:26', '2000', 1),
(1150, '1036629003', '2018-09-06 07:38:54', '3900', 1),
(1151, '1128267430', '2018-09-06 08:47:29', '7900', 1),
(1152, '760579', '2018-09-07 06:03:53', '1200', 1),
(1153, '1007110815', '2018-09-07 06:07:48', '14900', 1),
(1154, '1020430141', '2018-09-07 06:09:12', '4000', 1),
(1155, '1036601013', '2018-09-07 06:12:37', '7000', 1),
(1156, '71267825', '2018-09-07 06:16:20', '5900', 1),
(1157, '1020479554', '2018-09-07 06:22:05', '10000', 1),
(1158, '1095791547', '2018-09-07 06:24:34', '12000', 1),
(1159, '32353491', '2018-09-07 06:59:07', '2000', 1),
(1160, '1039049115', '2018-09-07 07:01:47', '4200', 1),
(1161, '1028016893', '2018-09-07 12:00:00', '5900', 1),
(1162, '1037587834', '2018-09-07 07:13:13', '4000', 1),
(1163, '1152210828', '2018-09-07 07:16:57', '1400', 1),
(1164, '1046913982', '2018-09-07 07:19:22', '9000', 1),
(1165, '1017132272', '2018-09-07 07:21:29', '2000', 1),
(1166, '26201420', '2018-09-07 07:22:49', '2000', 1),
(1167, '1017137065', '2018-09-07 07:23:46', '2000', 1),
(1168, '1152450553', '2018-09-07 07:24:02', '6500', 1),
(1169, '1017156424', '2018-09-07 07:27:00', '13600', 1),
(1170, '1129045994', '2018-09-07 07:35:08', '4100', 1),
(1171, '43271378', '2018-09-07 07:43:21', '9800', 1),
(1172, '1035915735', '2018-09-07 12:23:01', '2000', 0),
(1173, '71267825', '2018-09-10 06:23:01', '5900', 1),
(1174, '1035879778', '2018-09-10 06:23:58', '4500', 1),
(1175, '8433778', '2018-09-10 06:24:55', '2000', 1),
(1176, '1096238261', '2018-09-10 06:25:53', '2000', 1),
(1177, '1152701919', '2018-09-10 06:30:07', '2200', 1),
(1178, '1017216447', '2018-09-10 06:30:26', '12900', 1),
(1179, '1017187557', '2018-09-10 06:31:13', '8800', 1),
(1180, '1037587834', '2018-09-10 06:31:47', '2000', 1),
(1181, '1007110815', '2018-09-10 06:34:55', '7900', 1),
(1182, '43975208', '2018-09-10 06:45:40', '6800', 1),
(1183, '1017137065', '2018-09-10 07:07:56', '5400', 1),
(1184, '98699433', '2018-09-10 07:10:20', '7000', 1),
(1185, '1017156424', '2018-09-10 07:12:56', '12000', 1),
(1186, '1020430141', '2018-09-10 07:19:44', '6100', 1),
(1187, '1020479554', '2018-09-10 07:20:09', '2100', 1),
(1188, '1017125039', '2018-09-10 07:31:31', '2000', 1),
(1189, '43271378', '2018-09-10 07:31:48', '3000', 1),
(1190, '1143991147', '2018-09-10 07:32:25', '1400', 1),
(1191, '1129045994', '2018-09-10 07:32:46', '12100', 1),
(1192, '1095791547', '2018-09-10 07:34:54', '4800', 1),
(1193, '1046913982', '2018-09-10 07:40:57', '5900', 1),
(1194, '1028009266', '2018-09-10 07:45:40', '7900', 1),
(1195, '1020464577', '2018-09-11 06:10:19', '4500', 1),
(1196, '1017216447', '2018-09-11 06:10:44', '5000', 1),
(1197, '1152701919', '2018-09-11 06:28:39', '6000', 1),
(1198, '71267825', '2018-09-11 06:31:30', '2000', 1),
(1199, '1020479554', '2018-09-11 06:45:01', '2100', 1),
(1200, '1129045994', '2018-09-11 07:00:01', '6800', 1),
(1201, '1037587834', '2018-09-11 07:11:01', '6000', 1),
(1202, '1020430141', '2018-09-11 07:11:10', '10200', 1),
(1203, '1095791547', '2018-09-11 07:11:26', '4000', 1),
(1204, '43605625', '2018-09-11 07:12:03', '4000', 1),
(1205, '32353491', '2018-09-11 07:12:11', '2000', 1),
(1206, '43583398', '2018-09-11 07:17:47', '4400', 1),
(1207, '1036601013', '2018-09-11 07:23:13', '4500', 1),
(1208, '43596807', '2018-09-11 07:28:34', '2000', 1),
(1209, '1039049115', '2018-09-11 07:30:56', '4200', 1),
(1210, '1017137065', '2018-09-11 07:31:40', '2000', 1),
(1211, '1152210828', '2018-09-11 07:32:14', '1400', 1),
(1212, '1017179570', '2018-09-11 07:44:25', '5100', 1),
(1213, '1020430141', '2018-09-12 06:04:43', '4000', 1),
(1214, '1129045994', '2018-09-12 06:07:22', '11200', 1),
(1215, '1036601013', '2018-09-12 06:08:24', '2500', 1),
(1216, '1017216447', '2018-09-12 06:09:21', '7000', 1),
(1217, '1007110815', '2018-09-12 06:10:15', '6800', 1),
(1218, '1046913982', '2018-09-12 06:10:59', '4000', 1),
(1219, '1020479554', '2018-09-12 06:12:42', '5900', 1),
(1220, '71267825', '2018-09-12 06:17:03', '2000', 1),
(1221, '1036598684', '2018-09-12 06:28:27', '2000', 1),
(1222, '760579', '2018-09-12 06:33:28', '7700', 1),
(1223, '1035879778', '2018-09-12 06:47:49', '3100', 1),
(1224, '43605625', '2018-09-12 06:51:40', '3000', 1),
(1225, '1017187557', '2018-09-12 06:55:26', '6500', 1),
(1226, '1037587834', '2018-09-12 06:56:32', '2600', 1),
(1227, '1036629003', '2018-09-12 06:59:20', '10400', 1),
(1228, '1035915735', '2018-09-12 07:03:55', '4800', 1),
(1229, '1095791547', '2018-09-12 07:05:18', '12000', 1),
(1230, '1017156424', '2018-09-12 07:09:41', '22900', 1),
(1231, '43975208', '2018-09-12 07:15:22', '4800', 1),
(1232, '1017125039', '2018-09-12 07:16:46', '3400', 1),
(1233, '1152450553', '2018-09-12 07:33:59', '3400', 1),
(1234, '1152697088', '2018-09-12 07:35:32', '3600', 1),
(1235, '1078579715', '2018-09-13 15:42:42', '7900', 1),
(1236, '1020430141', '2018-09-13 06:01:51', '4000', 1),
(1237, '1129045994', '2018-09-13 06:19:16', '5900', 1),
(1238, '1046913982', '2018-09-13 06:23:48', '9900', 1),
(1239, '98772784', '2018-09-13 06:29:48', '2500', 1),
(1240, '1017216447', '2018-09-13 06:31:56', '7900', 1),
(1241, '1152450553', '2018-09-13 06:43:28', '16400', 1),
(1242, '71267825', '2018-09-13 06:44:47', '2000', 1),
(1243, '1096238261', '2018-09-13 06:45:35', '7900', 1),
(1244, '1017179570', '2018-09-13 07:04:23', '7900', 1),
(1245, '1017137065', '2018-09-13 07:06:12', '2800', 1),
(1246, '1095791547', '2018-09-13 07:08:10', '10000', 1),
(1247, '1035427628', '2018-09-13 07:08:14', '9000', 1),
(1248, '1036598684', '2018-09-13 07:09:25', '2000', 1),
(1249, '1007110815', '2018-09-13 07:14:17', '14900', 1),
(1250, '1036629003', '2018-09-13 07:15:55', '9200', 1),
(1251, '71752141', '2018-09-13 07:21:15', '3400', 1),
(1252, '1017225857', '2018-09-13 07:25:12', '7900', 1),
(1253, '1020464577', '2018-09-13 07:25:32', '7300', 1),
(1254, '1017137065', '2018-09-14 06:01:49', '3500', 1),
(1255, '1129045994', '2018-09-14 06:03:53', '6200', 1),
(1256, '1020430141', '2018-09-14 06:04:59', '6200', 1),
(1257, '1017156424', '2018-09-14 06:07:48', '16100', 1),
(1258, '1077453248', '2018-09-14 06:13:56', '6500', 1),
(1259, '71267825', '2018-09-14 06:15:44', '5900', 1),
(1260, '1037587834', '2018-09-14 06:16:24', '12200', 1),
(1261, '1096238261', '2018-09-14 06:18:55', '7900', 1),
(1262, '43605625', '2018-09-14 06:20:26', '9900', 1),
(1263, '760579', '2018-09-14 06:24:04', '8400', 1),
(1264, '1017216447', '2018-09-14 06:25:13', '7900', 1),
(1265, '1017132272', '2018-09-14 06:27:24', '2000', 1),
(1266, '1039049115', '2018-09-14 06:44:19', '4200', 1),
(1267, '1007110815', '2018-09-14 07:02:02', '6100', 1),
(1268, '1036629003', '2018-09-14 07:05:16', '6800', 1),
(1269, '1095791547', '2018-09-14 07:17:47', '10000', 1),
(1270, '1046913982', '2018-09-14 12:00:00', '4200', 1),
(1271, '1152450553', '2018-09-14 07:30:19', '4500', 1),
(1272, '1152210828', '2018-09-14 07:35:18', '1400', 1),
(1273, '43271378', '2018-09-14 07:37:04', '4500', 1),
(1274, '43841319', '2018-09-14 07:40:05', '3000', 1),
(1275, '32353491', '2018-09-14 07:40:49', '2000', 1),
(1276, '1017125039', '2018-09-14 07:42:04', '9600', 1),
(1277, '43975208', '2018-09-14 07:42:29', '9300', 1),
(1278, '71267825', '2018-09-17 06:24:43', '2000', 1),
(1279, '98772784', '2018-09-17 06:36:30', '3000', 1),
(1280, '1017156424', '2018-09-17 06:56:13', '17600', 1),
(1281, '1007110815', '2018-09-17 07:00:50', '8000', 1),
(1282, '1017125039', '2018-09-17 07:09:28', '3400', 1),
(1283, '1152450553', '2018-09-17 07:27:37', '8500', 1),
(1284, '1095791547', '2018-09-17 07:28:19', '10000', 1),
(1285, '1152210828', '2018-09-17 07:29:03', '1400', 1),
(1286, '1129045994', '2018-09-17 07:31:03', '12100', 1),
(1287, '26201420', '2018-09-17 07:32:32', '7900', 1),
(1288, '1017187557', '2018-09-17 07:39:02', '6800', 1),
(1289, '43596807', '2018-09-17 07:41:42', '2000', 1),
(1290, '1017216447', '2018-09-18 06:00:29', '9600', 1),
(1291, '1020430141', '2018-09-18 06:02:48', '6800', 1),
(1292, '1129045994', '2018-09-18 06:04:20', '5900', 1),
(1293, '1152701919', '2018-09-18 06:55:01', '10600', 1),
(1294, '1017187557', '2018-09-18 06:59:08', '12800', 1),
(1295, '1128405581', '2018-09-18 07:00:58', '5400', 1),
(1296, '1017156424', '2018-09-18 07:03:05', '7500', 1),
(1297, '1020464577', '2018-09-18 07:07:01', '7000', 1),
(1298, '1017137065', '2018-09-18 07:07:14', '2000', 1),
(1299, '1036629003', '2018-09-18 07:13:36', '7900', 1),
(1300, '1035879778', '2018-09-18 07:18:41', '1400', 1),
(1301, '1020479554', '2018-09-18 07:19:51', '2100', 1),
(1302, '1028009266', '2018-09-18 07:38:04', '7900', 1),
(1303, '1152450553', '2018-09-18 07:40:10', '4500', 1),
(1304, '15489917', '2018-09-18 07:41:44', '4500', 1),
(1305, '1028016893', '2018-09-19 17:37:03', '5900', 1),
(1306, '1020430141', '2018-09-19 06:03:30', '4200', 1),
(1307, '71267825', '2018-09-19 06:06:54', '2000', 1),
(1308, '760579', '2018-09-19 06:14:42', '8400', 1),
(1309, '1035879778', '2018-09-19 06:18:03', '2000', 1),
(1310, '1096238261', '2018-09-19 06:20:10', '7900', 1),
(1311, '1017137065', '2018-09-19 06:30:20', '2700', 1),
(1312, '1036629003', '2018-09-19 06:45:42', '6500', 1),
(1313, '1007110815', '2018-09-19 06:47:14', '12900', 1),
(1314, '1017216447', '2018-09-19 06:51:04', '2000', 1),
(1315, '1017179570', '2018-09-19 06:51:06', '9000', 1),
(1316, '1017239142', '2018-09-19 07:31:00', '1400', 1),
(1317, '1037631569', '2018-09-20 06:59:26', '12900', 1),
(1318, '1020430141', '2018-09-20 06:07:04', '6100', 1),
(1319, '1035879778', '2018-09-20 06:08:32', '2000', 1),
(1320, '1037587834', '2018-09-20 06:43:49', '9900', 1),
(1321, '1020479554', '2018-09-20 07:01:35', '8000', 1),
(1322, '1095791547', '2018-09-20 07:00:35', '7900', 1),
(1323, '1017125039', '2018-09-20 07:04:44', '4800', 1),
(1324, '1143991147', '2018-09-20 07:07:37', '4800', 1),
(1325, '71267825', '2018-09-20 07:19:53', '2000', 1),
(1326, '1007110815', '2018-09-20 07:24:35', '5900', 1),
(1327, '1096238261', '2018-09-20 07:27:02', '7900', 1),
(1328, '43271378', '2018-09-20 07:27:45', '4000', 1),
(1329, '1152450553', '2018-09-20 07:37:37', '7900', 1),
(1330, '1128267430', '2018-09-20 07:42:14', '4200', 1),
(1331, '43596807', '2018-09-20 07:43:15', '2000', 1),
(1332, '1037587834', '2018-09-21 06:03:04', '4000', 1),
(1333, '1017216447', '2018-09-21 06:09:14', '12000', 1),
(1334, '1035879778', '2018-09-21 06:13:12', '2000', 1),
(1335, '1152450553', '2018-09-21 06:16:01', '7900', 1),
(1336, '1017137065', '2018-09-21 06:18:22', '4000', 1),
(1337, '1017132272', '2018-09-21 06:28:14', '2000', 1),
(1338, '71267825', '2018-09-21 06:33:31', '5900', 1),
(1339, '1046913982', '2018-09-21 06:45:40', '2000', 1),
(1340, '1017156424', '2018-09-21 07:01:04', '17400', 1),
(1341, '1020479554', '2018-09-21 07:05:29', '2100', 1),
(1342, '1095791547', '2018-09-21 07:07:13', '10000', 1),
(1343, '1035915735', '2018-09-21 07:10:28', '8000', 1),
(1344, '1039049115', '2018-09-21 07:34:13', '4200', 1),
(1345, '1017179570', '2018-09-21 07:36:51', '13000', 1),
(1346, '43271378', '2018-09-21 07:43:40', '2000', 1),
(1348, '1017187557', '2018-09-24 06:24:01', '12900', 1),
(1350, '8433778', '2018-09-24 06:24:29', '9900', 1),
(1351, '1017156424', '2018-09-24 06:26:15', '10000', 1),
(1352, '1020479554', '2018-09-24 06:47:40', '2100', 1),
(1353, '1017216447', '2018-09-24 06:50:03', '14100', 1),
(1354, '1035879778', '2018-09-24 06:59:11', '2000', 1),
(1355, '71267825', '2018-09-24 07:00:53', '2000', 1),
(1356, '1017137065', '2018-09-24 07:00:59', '3000', 1),
(1357, '1007110815', '2018-09-24 07:01:26', '11100', 1),
(1358, '1035915735', '2018-09-24 07:23:33', '4800', 1),
(1359, '1095791547', '2018-09-24 07:25:57', '10000', 1),
(1360, '43596807', '2018-09-24 07:26:31', '2000', 1),
(1361, '1028009266', '2018-09-24 07:37:24', '5900', 1),
(1362, '1036629003', '2018-09-24 13:01:07', '7900', 1),
(1363, '1017216447', '2018-09-25 06:04:52', '7600', 1),
(1364, '71267825', '2018-09-25 06:20:26', '5900', 1),
(1365, '71759957', '2018-09-25 07:00:35', '8000', 1),
(1366, '1017187557', '2018-09-25 07:06:15', '12900', 1),
(1367, '1046913982', '2018-09-25 07:15:16', '8000', 1),
(1368, '1020479554', '2018-09-25 07:07:57', '2100', 1),
(1369, '1017156424', '2018-09-25 07:16:42', '7900', 1),
(1370, '1017239142', '2018-09-25 07:19:26', '9300', 1),
(1371, '1017137065', '2018-09-25 07:19:41', '4000', 1),
(1372, '1007110815', '2018-09-25 07:22:18', '4000', 1),
(1373, '1036629003', '2018-09-25 07:26:30', '6800', 1),
(1374, '1095791547', '2018-09-25 07:26:53', '4800', 1),
(1375, '1152450553', '2018-09-25 07:31:01', '7900', 1),
(1376, '1017225857', '2018-09-25 07:33:48', '9900', 1),
(1377, '1017125039', '2018-09-25 07:40:02', '7600', 1),
(1378, '1020457057', '2018-09-26 06:00:24', '4200', 1),
(1379, '43288005', '2018-09-26 06:01:37', '2000', 1),
(1380, '1017137065', '2018-09-26 06:02:56', '3000', 1),
(1381, '43605625', '2018-09-26 06:07:02', '2000', 1),
(1382, '1037587834', '2018-09-26 06:08:03', '8000', 1),
(1383, '1017216447', '2018-09-26 06:11:51', '10500', 1),
(1384, '1020430141', '2018-09-26 06:13:05', '8300', 1),
(1385, '71267825', '2018-09-26 06:19:26', '2000', 1),
(1386, '1035879778', '2018-09-26 06:22:11', '2000', 1),
(1387, '1096238261', '2018-09-26 06:23:07', '7900', 1),
(1388, '1039049115', '2018-09-26 06:25:57', '4200', 1),
(1389, '1017156424', '2018-09-26 06:28:29', '15800', 1),
(1390, '1077453248', '2018-09-26 06:43:13', '5600', 1),
(1391, '43975208', '2018-09-26 06:55:18', '4800', 1),
(1392, '1152210828', '2018-09-26 07:11:46', '1400', 1),
(1393, '1095791547', '2018-09-26 07:14:40', '10000', 1),
(1394, '71268332', '2018-09-26 07:27:28', '3000', 1),
(1395, '43271378', '2018-09-26 07:28:40', '4500', 1),
(1396, '1216718503', '2018-09-26 07:28:44', '2500', 1),
(1397, '1007110815', '2018-09-26 07:31:14', '6100', 1),
(1398, '1020479554', '2018-09-26 07:37:49', '4200', 1),
(1399, '1046913982', '2018-09-27 06:00:40', '5900', 1),
(1400, '43288005', '2018-09-27 06:05:08', '2000', 1),
(1401, '1017216447', '2018-09-27 06:11:01', '10500', 1),
(1402, '1216718503', '2018-09-27 06:37:14', '3900', 1),
(1403, '1152450553', '2018-09-27 12:00:00', '13700', 1),
(1404, '1096238261', '2018-09-27 06:08:50', '7900', 1),
(1405, '1152701919', '2018-09-27 06:13:31', '10600', 1),
(1406, '1007110815', '2018-09-27 06:19:31', '14700', 1),
(1407, '1037587834', '2018-09-27 06:20:55', '13000', 1),
(1408, '1035879778', '2018-09-27 06:22:13', '2000', 1),
(1409, '1017132272', '2018-09-27 06:43:08', '2000', 1),
(1410, '1036629003', '2018-09-27 06:51:57', '14400', 1),
(1411, '1020464577', '2018-09-27 06:55:41', '18800', 1),
(1412, '1017179570', '2018-09-27 07:10:36', '8000', 1),
(1413, '1020479554', '2018-09-27 07:11:16', '8000', 1),
(1414, '71267825', '2018-09-27 07:12:58', '7900', 1),
(1415, '1017137065', '2018-09-27 07:43:45', '4000', 1),
(1416, '1216718503', '2018-09-28 15:49:50', '9900', 1),
(1417, '1036601013', '2018-09-28 06:03:36', '2000', 1),
(1418, '1017216447', '2018-09-28 06:04:01', '9100', 1),
(1419, '1017179570', '2018-09-28 06:12:56', '9900', 1),
(1420, '1020430141', '2018-09-28 06:15:12', '8100', 1),
(1421, '1020479554', '2018-09-28 06:21:14', '2100', 1),
(1422, '1017156424', '2018-09-28 06:27:23', '13800', 1),
(1423, '43975208', '2018-09-28 06:35:51', '8200', 1),
(1424, '1096238261', '2018-09-28 06:43:39', '7900', 1),
(1425, '1152450553', '2018-09-28 06:45:35', '7900', 1),
(1426, '1035879778', '2018-09-28 06:47:40', '1200', 1),
(1427, '54253320', '2018-09-28 07:15:51', '4200', 1),
(1428, '1037587834', '2018-09-28 07:16:39', '6800', 1),
(1429, '1035915735', '2018-09-28 07:17:14', '2800', 1),
(1430, '43841319', '2018-09-28 12:00:00', '5000', 1),
(1431, '43596807', '2018-09-28 07:26:26', '2000', 1),
(1432, '1128405581', '2018-09-28 07:35:03', '2800', 1),
(1433, '1017125039', '2018-09-28 07:36:09', '6800', 1),
(1434, '1039049115', '2018-09-28 07:38:58', '2800', 1),
(1435, '1028009266', '2018-09-28 07:43:26', '5900', 1),
(1437, '1020430141', '2018-10-01 06:18:34', '10000', 1),
(1438, '1037581069', '2018-10-01 06:29:14', '7900', 1),
(1439, '1007110815', '2018-10-01 06:33:16', '1400', 1),
(1440, '1036601013', '2018-10-01 06:37:48', '2000', 1),
(1441, '1020479554', '2018-10-01 06:55:28', '2100', 1),
(1442, '1077453248', '2018-10-01 07:05:29', '5600', 1),
(1443, '1017156424', '2018-10-01 07:15:10', '15800', 1),
(1444, '1037587834', '2018-10-01 07:16:51', '6400', 1),
(1445, '1036629003', '2018-10-01 07:18:14', '3000', 1),
(1446, '43605625', '2018-10-01 07:19:48', '4000', 1),
(1447, '1017239142', '2018-10-01 07:33:18', '7900', 1),
(1448, '1036598684', '2018-10-01 07:35:13', '2000', 1),
(1449, '1128267430', '2018-10-01 07:38:19', '5900', 1),
(1450, '43271378', '2018-10-01 07:41:44', '7000', 1),
(1451, '1035915735', '2018-10-01 07:43:03', '4200', 1),
(1453, '1035879778', '2018-10-02 06:06:23', '7900', 1),
(1454, '1017137065', '2018-10-02 06:13:51', '3000', 1),
(1455, '1007110815', '2018-10-02 06:16:00', '13900', 1),
(1456, '1152701919', '2018-10-02 06:32:35', '4700', 1),
(1457, '1039049115', '2018-10-02 06:40:18', '4800', 1),
(1458, '71267825', '2018-10-02 06:42:54', '2000', 1),
(1459, '1020430141', '2018-10-02 07:12:48', '4200', 1),
(1460, '1020479554', '2018-10-02 07:21:33', '2100', 1),
(1462, '1037606721', '2018-10-02 07:35:05', '2000', 1),
(1463, '1046913982', '2018-10-02 07:35:19', '6000', 1),
(1464, '43605625', '2018-10-02 07:41:16', '4000', 1),
(1465, '1037587834', '2018-10-03 06:03:00', '2000', 1),
(1467, '1017187557', '2018-10-03 06:10:52', '12400', 1),
(1468, '71267825', '2018-10-03 06:17:48', '2000', 1),
(1469, '1017137065', '2018-10-03 06:20:42', '4000', 1),
(1470, '1007110815', '2018-10-03 06:29:47', '9600', 1),
(1471, '1020430141', '2018-10-03 06:45:45', '8300', 1),
(1472, '1017216447', '2018-10-03 06:51:18', '7900', 1),
(1473, '43271378', '2018-10-03 07:23:37', '4500', 1),
(1474, '1152450553', '2018-10-03 07:24:52', '6500', 1),
(1475, '43975208', '2018-10-03 07:43:04', '6800', 1),
(1476, '43189198', '2018-10-04 06:01:26', '7900', 1),
(1478, '1017216447', '2018-10-04 06:12:43', '8700', 1),
(1479, '1020479554', '2018-10-04 06:26:02', '2100', 1),
(1480, '71267825', '2018-10-04 06:30:09', '2000', 1),
(1482, '1035879778', '2018-10-04 06:43:24', '2000', 1),
(1483, '1007110815', '2018-10-04 06:48:11', '20700', 1),
(1484, '1152450553', '2018-10-04 06:52:23', '10100', 1),
(1485, '43605625', '2018-10-04 06:53:01', '4600', 1),
(1486, '1046913982', '2018-10-04 06:56:46', '5900', 1),
(1487, '1017179570', '2018-10-04 06:57:38', '9900', 1),
(1488, '1020430141', '2018-10-04 07:03:56', '10100', 1),
(1489, '1037587834', '2018-10-04 07:07:17', '2000', 1),
(1490, '1036629003', '2018-10-04 07:09:38', '7000', 1),
(1491, '1152210828', '2018-10-04 07:21:07', '7900', 1),
(1492, '1039447684', '2018-10-04 07:33:02', '7900', 1),
(1493, '1017125039', '2018-10-04 07:33:50', '9900', 1),
(1494, '43271378', '2018-10-04 07:42:58', '7900', 1),
(1495, '1017216447', '2018-10-05 06:13:01', '10500', 1),
(1496, '1020479554', '2018-10-05 06:27:04', '2100', 1),
(1497, '1017187557', '2018-10-05 06:44:35', '7900', 1),
(1498, '1036629003', '2018-10-05 06:46:28', '8900', 1),
(1499, '1037587834', '2018-10-05 06:47:58', '6200', 1),
(1500, '1017137065', '2018-10-05 07:00:29', '4100', 1),
(1501, '71267825', '2018-10-05 07:04:42', '2000', 1),
(1502, '1007110815', '2018-10-05 07:17:41', '2200', 1),
(1503, '1035879778', '2018-10-05 07:19:38', '4500', 1),
(1504, '1152701919', '2018-10-05 07:20:00', '2200', 1),
(1505, '1017125039', '2018-10-05 07:21:40', '11100', 1),
(1506, '1152450553', '2018-10-05 07:25:57', '14700', 1),
(1507, '1020430141', '2018-10-05 07:31:56', '3900', 1),
(1508, '1039049115', '2018-10-05 07:37:53', '4200', 1),
(1509, '43975208', '2018-10-05 07:38:49', '2000', 1),
(1510, '1017179570', '2018-10-05 07:39:55', '12600', 1),
(1511, '1017216447', '2018-10-08 06:02:50', '3700', 1),
(1512, '1020479554', '2018-10-08 06:27:40', '2100', 1),
(1513, '1017137065', '2018-10-08 06:30:24', '4000', 1),
(1514, '1152210828', '2018-10-08 06:45:53', '1400', 1),
(1515, '1017156424', '2018-10-08 06:52:14', '14000', 1),
(1516, '1036629003', '2018-10-08 06:52:49', '4000', 1),
(1517, '1037587834', '2018-10-08 07:00:02', '4000', 1),
(1518, '1020430141', '2018-10-08 07:09:20', '5200', 1),
(1519, '1046913982', '2018-10-08 07:17:39', '2000', 1),
(1520, '1152450553', '2018-10-08 07:20:02', '6500', 1),
(1521, '1095791547', '2018-10-08 07:25:57', '4000', 1),
(1522, '43596807', '2018-10-08 07:36:53', '2000', 1),
(1523, '1037631569', '2018-10-09 06:00:46', '7900', 1),
(1524, '1037587834', '2018-10-09 06:18:57', '8200', 1),
(1525, '43605625', '2018-10-09 06:20:56', '4000', 1),
(1526, '98699433', '2018-10-09 06:31:02', '4000', 1),
(1527, '1039049115', '2018-10-09 06:36:42', '4200', 1),
(1528, '71267825', '2018-10-09 06:39:43', '5900', 1),
(1529, '1036629003', '2018-10-09 06:41:11', '4000', 1),
(1530, '1007110815', '2018-10-09 06:43:05', '12700', 1),
(1531, '1017179570', '2018-10-09 06:56:59', '6200', 1),
(1532, '1152450553', '2018-10-09 06:58:53', '7900', 1),
(1533, '1046913982', '2018-10-09 07:01:23', '12100', 1),
(1534, '1035879778', '2018-10-09 07:02:18', '2000', 1),
(1535, '1017216447', '2018-10-09 07:04:40', '3700', 1),
(1536, '1017137065', '2018-10-09 07:05:23', '3300', 1),
(1537, '1020479554', '2018-10-09 07:07:47', '2100', 1),
(1538, '43975208', '2018-10-09 07:15:02', '2000', 1),
(1539, '1020430141', '2018-10-09 07:31:36', '6000', 1),
(1540, '1152210828', '2018-10-09 07:34:48', '2700', 1),
(1541, '43189198', '2018-10-10 06:16:25', '7900', 1),
(1542, '1020430141', '2018-10-10 06:17:24', '8200', 1),
(1543, '1017187557', '2018-10-10 06:17:48', '10500', 1),
(1544, '1035879778', '2018-10-10 06:24:31', '3400', 1),
(1545, '1017216447', '2018-10-10 06:28:53', '9900', 1),
(1546, '71267825', '2018-10-10 06:32:58', '2000', 1),
(1547, '1017137065', '2018-10-10 06:36:43', '3600', 1),
(1548, '1017179570', '2018-10-10 06:39:28', '6200', 1),
(1549, '1216718503', '2018-10-10 06:42:10', '6200', 1),
(1550, '1077453248', '2018-10-10 06:43:10', '5600', 1),
(1551, '1020479554', '2018-10-10 06:50:05', '2100', 1),
(1552, '1037587834', '2018-10-10 06:50:07', '5800', 1),
(1553, '43605625', '2018-10-10 06:51:05', '5300', 1),
(1554, '1020464577', '2018-10-10 07:01:04', '9900', 1),
(1555, '760579', '2018-10-10 07:03:49', '600', 1),
(1556, '1036629003', '2018-10-10 07:22:28', '11500', 1),
(1557, '1020457057', '2018-10-11 06:49:21', '15800', 1),
(1558, '43288005', '2018-10-11 06:50:04', '7900', 1),
(1559, '1035879778', '2018-10-11 06:50:58', '4500', 1),
(1560, '1037631569', '2018-10-11 06:53:24', '2000', 1),
(1561, '1017137065', '2018-10-11 06:54:29', '5600', 1),
(1562, '1020430141', '2018-10-11 06:54:37', '3900', 1),
(1563, '1046913982', '2018-10-11 06:55:48', '10100', 1),
(1564, '1017125039', '2018-10-11 06:55:53', '8800', 1),
(1565, '1017179570', '2018-10-11 06:56:25', '12100', 1),
(1566, '1152701919', '2018-10-11 07:00:09', '3600', 1),
(1567, '1007110815', '2018-10-11 07:02:40', '13600', 1),
(1568, '1036629003', '2018-10-11 07:08:23', '4500', 1),
(1569, '71267825', '2018-10-11 07:11:51', '2000', 1),
(1570, '1020479554', '2018-10-11 07:13:41', '8000', 1),
(1571, '1017156424', '2018-10-11 07:14:44', '15800', 1),
(1572, '1017216447', '2018-10-11 07:20:58', '11200', 1),
(1573, '1037606721', '2018-10-11 07:22:20', '2000', 1),
(1574, '1152450553', '2018-10-11 07:24:11', '14400', 1),
(1575, '43596807', '2018-10-11 07:38:49', '2100', 1),
(1576, '1039049115', '2018-10-12 06:21:00', '2800', 1),
(1577, '1128405581', '2018-10-12 06:22:49', '5600', 1),
(1578, '1017216447', '2018-10-12 06:26:56', '3700', 1),
(1579, '1035879778', '2018-10-12 06:28:33', '2000', 1),
(1580, '71267825', '2018-10-12 06:28:46', '2000', 1),
(1581, '760579', '2018-10-12 06:29:27', '1200', 1),
(1582, '1152701919', '2018-10-12 06:35:46', '2900', 1),
(1583, '1216714526', '2018-10-12 06:35:55', '14700', 1),
(1584, '1095791547', '2018-10-12 06:36:51', '4800', 1),
(1585, '1077453248', '2018-10-12 06:50:34', '7600', 1),
(1586, '1036598684', '2018-10-12 06:58:27', '3500', 1),
(1587, '1216718503', '2018-10-12 07:03:15', '11300', 1),
(1588, '1020430141', '2018-10-12 07:03:33', '8700', 1),
(1589, '1214721942', '2018-10-12 07:04:52', '6600', 1),
(1590, '1152210828', '2018-10-12 07:05:47', '1400', 1),
(1591, '1007110815', '2018-10-12 07:08:17', '7600', 1),
(1592, '1017179570', '2018-10-12 07:08:28', '8400', 1),
(1593, '1046913982', '2018-10-12 07:11:10', '6200', 1),
(1594, '1036629003', '2018-10-12 07:14:52', '13500', 1),
(1595, '1017137065', '2018-10-12 07:17:44', '4900', 1),
(1596, '1017125039', '2018-10-12 07:23:33', '2000', 1),
(1597, '54253320', '2018-10-12 07:24:34', '4200', 1),
(1598, '1017239142', '2018-10-12 07:26:14', '9300', 1),
(1599, '1037587834', '2018-10-12 07:28:36', '11100', 1),
(1600, '43271378', '2018-10-12 07:35:07', '11500', 1),
(1601, '1040044905', '2018-10-12 07:41:04', '7900', 1),
(1602, '1020479554', '2018-10-16 06:32:34', '9900', 1),
(1603, '1095791547', '2018-10-16 06:34:11', '9900', 1),
(1604, '1129045994', '2018-10-16 06:35:54', '12700', 1),
(1605, '21424773', '2018-10-16 06:37:52', '7900', 1),
(1606, '1017216447', '2018-10-16 06:40:12', '3100', 1),
(1607, '71267825', '2018-10-16 06:41:18', '2000', 1),
(1608, '1152450553', '2018-10-16 06:42:36', '4200', 1),
(1609, '1017137065', '2018-10-16 06:47:59', '3500', 1),
(1610, '1128430240', '2018-10-16 12:00:00', '5900', 1),
(1611, '1077453248', '2018-10-16 06:53:04', '2000', 1),
(1612, '1035879778', '2018-10-16 06:53:08', '2000', 1),
(1613, '1020464577', '2018-10-16 07:10:17', '12200', 1),
(1614, '43271378', '2018-10-16 07:15:08', '4000', 1),
(1615, '1007110815', '2018-10-16 07:20:08', '4800', 1),
(1616, '1216718503', '2018-10-16 07:21:55', '2800', 1),
(1617, '1039447684', '2018-10-16 07:25:13', '7900', 1),
(1618, '1017216447', '2018-10-17 06:06:59', '3900', 1),
(1619, '1096238261', '2018-10-17 06:23:35', '7900', 1),
(1620, '1152450553', '2018-10-17 06:24:17', '2200', 1),
(1621, '1017137065', '2018-10-17 06:27:26', '4700', 1),
(1622, '1036598684', '2018-10-17 06:32:37', '2000', 1),
(1623, '43605625', '2018-10-17 06:38:00', '2000', 1),
(1624, '1017156424', '2018-10-17 06:38:41', '9900', 1),
(1625, '1035879778', '2018-10-17 06:50:36', '2000', 1),
(1626, '1037587834', '2018-10-17 06:53:16', '4000', 1),
(1627, '1036629003', '2018-10-17 07:00:45', '9500', 1),
(1628, '71267825', '2018-10-17 07:05:07', '5900', 1),
(1629, '1020479554', '2018-10-17 07:16:33', '2100', 1),
(1630, '1095791547', '2018-10-17 07:17:17', '2000', 1),
(1631, '1035915735', '2018-10-17 07:30:25', '2800', 1),
(1632, '1017216447', '2018-10-18 06:06:51', '6200', 1),
(1633, '1037587834', '2018-10-18 06:24:42', '6600', 1),
(1634, '1017187557', '2018-10-18 06:25:54', '4000', 1),
(1635, '1017137065', '2018-10-18 06:35:17', '4900', 1),
(1636, '1152450553', '2018-10-18 06:52:37', '7900', 1),
(1637, '1095791547', '2018-10-18 07:05:32', '7900', 1),
(1638, '1020479554', '2018-10-18 07:06:54', '8000', 1),
(1639, '1035879778', '2018-10-18 07:11:03', '5100', 1),
(1640, '1037606721', '2018-10-18 07:14:57', '7900', 1),
(1641, '1128267430', '2018-10-18 07:19:57', '5900', 1),
(1642, '1028009266', '2018-10-18 07:20:24', '5900', 1),
(1643, '1017179570', '2018-10-18 07:31:40', '17800', 1),
(1644, '1017156424', '2018-10-18 07:33:05', '15800', 1),
(1645, '1020430141', '2018-10-18 07:38:39', '2600', 1),
(1646, '71267825', '2018-10-19 06:14:16', '2000', 1),
(1647, '1007110815', '2018-10-19 06:22:37', '6800', 1),
(1648, '1152701919', '2018-10-19 06:23:26', '2800', 1),
(1649, '1037587834', '2018-10-19 06:25:02', '8100', 1),
(1650, '1017156424', '2018-10-19 06:26:08', '9900', 1),
(1651, '1020464577', '2018-10-19 06:26:29', '8700', 1),
(1652, '1036680551', '2018-10-19 06:39:58', '3900', 1),
(1653, '1017137065', '2018-10-19 06:42:36', '4700', 1),
(1654, '1152210828', '2018-10-19 07:12:10', '1400', 1),
(1655, '54253320', '2018-10-19 07:13:26', '4200', 1),
(1656, '1035915735', '2018-10-19 07:13:58', '2800', 1),
(1657, '1035879778', '2018-10-19 07:26:10', '5300', 1),
(1658, '1095791547', '2018-10-19 07:27:39', '4000', 1),
(1659, '1152450553', '2018-10-19 07:27:40', '5900', 1),
(1660, '1006887114', '2018-10-19 07:32:03', '6800', 1),
(1661, '43596807', '2018-10-19 07:33:30', '4100', 1),
(1662, '43271378', '2018-10-19 07:36:06', '9000', 1),
(1663, '1017216447', '2018-10-19 11:45:56', '7900', 1),
(1664, '1017216447', '2018-10-22 06:14:15', '13600', 1),
(1665, '1096238261', '2018-10-22 06:35:07', '2000', 1),
(1666, '1017125039', '2018-10-22 06:38:18', '6100', 1),
(1667, '1152450553', '2018-10-22 06:40:26', '2000', 1),
(1668, '1020479554', '2018-10-22 06:42:04', '2100', 1),
(1669, '1035879778', '2018-10-22 06:47:49', '2000', 1),
(1670, '1152701919', '2018-10-22 06:49:20', '2800', 1),
(1671, '1017156424', '2018-10-22 06:58:22', '8800', 1),
(1672, '1020464577', '2018-10-22 06:59:20', '5500', 1),
(1673, '1036629003', '2018-10-22 07:04:18', '7800', 1),
(1674, '1129045994', '2018-10-22 07:04:59', '12100', 1),
(1675, '1036680551', '2018-10-22 07:05:49', '12500', 1),
(1676, '1216718503', '2018-10-22 07:16:44', '7300', 1),
(1677, '1036601013', '2018-10-22 07:22:23', '7000', 1),
(1678, '1017137065', '2018-10-22 07:26:43', '4000', 1),
(1679, '1046913982', '2018-10-22 07:29:33', '4000', 1),
(1680, '1006887114', '2018-10-22 07:35:53', '6000', 1),
(1681, '1095791547', '2018-10-22 07:37:07', '4000', 1),
(1682, '1028009266', '2018-10-22 07:43:22', '7900', 1),
(1683, '43271378', '2018-10-22 07:43:57', '4000', 1),
(1684, '43189198', '2018-10-23 06:03:24', '7900', 1),
(1685, '1017216447', '2018-10-23 06:03:26', '10700', 1),
(1686, '1036680551', '2018-10-23 06:21:02', '3400', 1),
(1687, '1037631569', '2018-10-23 06:27:38', '2000', 1),
(1688, '71267825', '2018-10-23 06:40:02', '2000', 1),
(1689, '1017137065', '2018-10-23 06:44:27', '5000', 1),
(1690, '1216718503', '2018-10-23 06:47:41', '2000', 1),
(1691, '1036601013', '2018-10-23 06:49:14', '2500', 1),
(1692, '54253320', '2018-10-23 07:07:21', '3000', 1),
(1693, '1035915735', '2018-10-23 07:07:47', '2800', 1),
(1694, '1020464577', '2018-10-23 07:29:04', '5900', 1),
(1695, '1020479554', '2018-10-23 07:29:55', '2100', 1),
(1696, '1095791547', '2018-10-23 07:31:59', '6000', 1),
(1697, '1129045994', '2018-10-23 07:34:38', '5900', 1),
(1698, '1036629003', '2018-10-23 07:35:12', '3900', 1),
(1699, '71267825', '2018-10-24 06:07:27', '2000', 1),
(1700, '1017216447', '2018-10-24 06:25:53', '4500', 1),
(1701, '43605625', '2018-10-24 06:26:19', '5900', 1),
(1702, '1036601013', '2018-10-24 06:34:35', '2000', 1),
(1703, '1035879778', '2018-10-24 06:45:16', '4500', 1),
(1704, '1017137065', '2018-10-24 06:53:41', '2700', 1),
(1706, '1129045994', '2018-10-24 07:08:37', '12100', 1),
(1707, '1017179570', '2018-10-24 07:10:08', '4000', 1),
(1708, '1036680551', '2018-10-24 07:16:30', '9400', 1),
(1709, '1017187557', '2018-10-24 07:16:36', '2800', 1),
(1710, '1017132272', '2018-10-24 07:18:23', '2000', 1),
(1711, '98772784', '2018-10-24 07:18:56', '4000', 1),
(1712, '1017125039', '2018-10-24 07:19:45', '4200', 1),
(1713, '1006887114', '2018-10-24 07:25:13', '6000', 1),
(1714, '1007110815', '2018-10-24 07:28:47', '11200', 1),
(1715, '1017156424', '2018-10-24 07:32:22', '7900', 1),
(1716, '1035915735', '2018-10-24 07:38:13', '1400', 1),
(1717, '1152701919', '2018-10-25 06:01:35', '12000', 1),
(1719, '1017137065', '2018-10-25 06:09:59', '2700', 1),
(1720, '1035879778', '2018-10-25 06:10:25', '2000', 1),
(1721, '1017216447', '2018-10-25 06:12:06', '7900', 1),
(1722, '98699433', '2018-10-25 06:12:56', '4000', 1),
(1723, '71267825', '2018-10-25 06:17:41', '2000', 1),
(1724, '1036601013', '2018-10-25 06:19:36', '4500', 1),
(1725, '1020464577', '2018-10-25 06:32:24', '7900', 1),
(1726, '760579', '2018-10-25 06:22:12', '5900', 1),
(1727, '1017187557', '2018-10-25 06:22:42', '13800', 1),
(1728, '43605625', '2018-10-25 06:23:16', '7900', 1),
(1729, '1036629003', '2018-10-25 06:25:20', '12900', 1),
(1730, '1007110815', '2018-10-25 06:26:16', '7900', 1),
(1731, '1096238261', '2018-10-25 06:27:51', '2000', 1),
(1732, '1129045994', '2018-10-25 06:33:54', '14100', 1),
(1733, '1214721942', '2018-10-25 06:41:27', '13200', 1),
(1734, '1017125039', '2018-10-25 06:52:34', '8000', 1),
(1735, '1152450553', '2018-10-25 06:54:14', '7900', 1),
(1736, '1020479554', '2018-10-25 06:55:27', '2100', 1),
(1737, '1095791547', '2018-10-25 06:56:18', '7900', 1),
(1738, '1046913982', '2018-10-25 06:57:16', '5900', 1),
(1739, '1017239142', '2018-10-25 07:32:41', '1400', 1),
(1740, '1152210828', '2018-10-25 07:37:35', '1400', 1),
(1741, '1020457057', '2018-10-26 06:01:18', '12200', 1),
(1742, '1096238261', '2018-10-26 06:01:20', '7900', 1),
(1743, '1036598684', '2018-10-26 06:02:07', '4000', 1),
(1744, '1017216447', '2018-10-26 06:02:42', '5100', 1),
(1745, '43265824', '2018-10-26 06:02:48', '7900', 1),
(1746, '1152701919', '2018-10-26 06:03:11', '2400', 1),
(1747, '1046913982', '2018-10-26 06:07:05', '9500', 1),
(1748, '1039049115', '2018-10-26 06:07:48', '2800', 1),
(1749, '1036680551', '2018-10-26 06:10:37', '6000', 1),
(1750, '1214721942', '2018-10-26 06:11:52', '4000', 1),
(1751, '760579', '2018-10-26 06:13:54', '1200', 1),
(1752, '1007110815', '2018-10-26 06:18:53', '10000', 1),
(1753, '1017156424', '2018-10-26 07:09:00', '20100', 1),
(1754, '1036629003', '2018-10-26 06:21:10', '9800', 1),
(1755, '43189198', '2018-10-26 06:22:58', '2000', 1),
(1756, '1216718503', '2018-10-26 06:24:31', '12100', 1),
(1757, '43288005', '2018-10-26 06:26:07', '4000', 1),
(1758, '1017137065', '2018-10-26 06:27:08', '2700', 1),
(1759, '1036601013', '2018-10-26 06:27:16', '2500', 1),
(1760, '1017179570', '2018-10-26 06:29:55', '4000', 1),
(1761, '1037587834', '2018-10-26 06:31:36', '10000', 1),
(1762, '1035879778', '2018-10-26 06:39:50', '4000', 1),
(1763, '1006887114', '2018-10-26 06:42:59', '6000', 1),
(1764, '71268332', '2018-10-26 06:55:53', '5100', 1),
(1765, '1020464577', '2018-10-26 07:09:36', '2000', 1),
(1766, '1152210828', '2018-10-26 07:11:45', '4700', 1),
(1767, '1129045994', '2018-10-26 07:14:15', '12100', 1),
(1768, '1152697088', '2018-10-26 07:22:58', '7900', 1),
(1769, '1152450553', '2018-10-26 07:25:20', '14700', 1),
(1770, '1017125039', '2018-10-26 07:32:19', '4200', 1),
(1771, '43596807', '2018-10-26 07:32:22', '4000', 1),
(1772, '71267825', '2018-10-26 07:32:52', '2000', 1),
(1773, '1143991147', '2018-10-26 07:35:14', '4800', 1),
(1774, '1095791547', '2018-10-26 07:38:36', '7900', 1),
(1775, '54253320', '2018-10-26 07:42:00', '4200', 1),
(1776, '1020479554', '2018-10-29 06:04:28', '10000', 1),
(1777, '1017216447', '2018-10-29 06:05:34', '9200', 1),
(1778, '98772784', '2018-10-29 06:14:15', '4100', 1),
(1779, '1216718503', '2018-10-29 06:16:58', '14900', 1),
(1781, '1039049115', '2018-10-29 06:25:57', '2800', 1),
(1782, '1128405581', '2018-10-29 06:27:06', '5600', 1),
(1783, '1035879778', '2018-10-29 06:29:57', '2000', 1),
(1784, '1017137065', '2018-10-29 06:36:14', '4000', 1),
(1785, '43975208', '2018-10-29 06:47:33', '4800', 1),
(1786, '1152450553', '2018-10-29 06:49:53', '14400', 1),
(1787, '1129045994', '2018-10-29 06:55:14', '14100', 1),
(1788, '1017156424', '2018-10-29 06:57:50', '11000', 1),
(1789, '1037587834', '2018-10-29 06:57:58', '9800', 1),
(1790, '1035915735', '2018-10-29 07:07:31', '7600', 1),
(1791, '1007110815', '2018-10-29 07:15:19', '10200', 1),
(1792, '1017125039', '2018-10-29 07:17:48', '4200', 1),
(1793, '1036629003', '2018-10-29 07:20:37', '10400', 1),
(1794, '1017239142', '2018-10-29 07:22:24', '4000', 1),
(1795, '1020457057', '2018-10-29 07:29:46', '4000', 1),
(1796, '1028009266', '2018-10-29 07:41:44', '7900', 1),
(1797, '760579', '2018-10-30 12:00:00', '1400', 1),
(1798, '1017216447', '2018-10-30 12:00:00', '13200', 1),
(1799, '71267825', '2018-10-30 06:11:16', '2000', 1),
(1800, '43288005', '2018-10-30 06:26:08', '4000', 1),
(1801, '1216718503', '2018-10-30 06:31:08', '9000', 1),
(1802, '1036601013', '2018-10-30 06:33:19', '4500', 1),
(1803, '1007110815', '2018-10-30 06:40:24', '3000', 1),
(1804, '43605625', '2018-10-30 06:46:48', '2000', 1),
(1805, '1036629003', '2018-10-30 06:48:44', '9900', 1),
(1806, '43265824', '2018-10-30 06:57:13', '4800', 1),
(1807, '1006887114', '2018-10-30 06:59:21', '6000', 1),
(1808, '1077453248', '2018-10-30 07:01:59', '5600', 1),
(1809, '1035879778', '2018-10-30 12:00:00', '4800', 1),
(1810, '1020479554', '2018-10-30 07:04:32', '10000', 1),
(1811, '1039049115', '2018-10-30 07:05:43', '4200', 1),
(1812, '1036680551', '2018-10-30 07:07:53', '2700', 1),
(1813, '1020464577', '2018-10-30 12:00:00', '6800', 1),
(1814, '1095791547', '2018-10-30 07:11:07', '7900', 1),
(1815, '1129045994', '2018-10-30 07:11:59', '10000', 1),
(1816, '1017156424', '2018-10-30 07:13:08', '2000', 1),
(1817, '1017137065', '2018-10-30 07:16:15', '2700', 1),
(1818, '43596807', '2018-10-30 07:30:34', '2000', 1),
(1819, '1128267430', '2018-10-30 07:33:46', '1400', 1),
(1820, '1037631569', '2018-10-30 07:38:06', '2200', 1),
(1821, '1035915735', '2018-10-30 07:41:52', '7600', 1),
(1822, '1037587834', '2018-10-31 06:08:17', '12000', 1),
(1823, '1036598684', '2018-10-31 06:11:51', '7900', 1),
(1824, '1152701919', '2018-10-31 06:12:35', '2400', 1),
(1825, '1017216447', '2018-10-31 06:27:55', '9600', 1),
(1826, '760579', '2018-10-31 06:28:28', '1200', 1),
(1827, '1035879778', '2018-10-31 06:32:25', '4500', 1),
(1828, '1039049115', '2018-10-31 06:34:46', '4200', 1),
(1829, '71267825', '2018-10-31 06:40:37', '5900', 1),
(1830, '1007110815', '2018-10-31 06:43:05', '10000', 1),
(1831, '1020479554', '2018-10-31 06:45:04', '10000', 1),
(1832, '1036601013', '2018-10-31 06:50:23', '2500', 1),
(1833, '1129045994', '2018-10-31 06:52:17', '12100', 1),
(1834, '43288005', '2018-10-31 06:52:43', '3000', 1),
(1835, '1006887114', '2018-10-31 06:53:28', '14000', 1),
(1836, '1036629003', '2018-10-31 07:02:24', '5900', 1),
(1837, '1152450553', '2018-10-31 07:30:06', '2200', 1),
(1838, '1152210828', '2018-10-31 07:35:15', '1400', 1),
(1839, '1020479554', '2018-11-01 06:02:18', '10000', 1),
(1840, '1017216447', '2018-11-01 06:03:14', '7900', 1),
(1841, '1152701919', '2018-11-01 06:04:12', '5900', 1),
(1842, '8433778', '2018-11-01 06:17:29', '7900', 1),
(1843, '1152450553', '2018-11-01 06:19:04', '9900', 1),
(1844, '71267825', '2018-11-01 06:29:07', '5900', 1),
(1845, '1129045994', '2018-11-01 06:29:14', '7900', 1),
(1846, '1216718503', '2018-11-01 06:44:42', '9000', 1),
(1847, '1046913982', '2018-11-01 06:46:53', '9900', 1),
(1848, '1017137065', '2018-11-01 06:48:33', '3000', 1),
(1849, '71268332', '2018-11-01 07:03:42', '3000', 1),
(1850, '1037587834', '2018-11-01 07:08:57', '9900', 1),
(1851, '43288005', '2018-11-01 07:11:29', '4000', 1),
(1852, '1017239142', '2018-11-01 07:23:32', '7900', 1),
(1853, '43583398', '2018-11-01 07:24:35', '31600', 1),
(1854, '43975208', '2018-11-01 07:33:27', '14400', 1),
(1855, '1036680551', '2018-11-01 07:39:16', '2700', 1),
(1856, '1095791547', '2018-11-01 07:40:16', '7900', 1),
(1857, '1152210828', '2018-11-01 07:42:39', '1400', 1),
(1858, '1037631569', '2018-11-02 06:00:21', '10100', 1),
(1859, '1017216447', '2018-11-02 06:01:53', '6200', 1),
(1860, '1017137065', '2018-11-02 06:02:07', '4000', 1),
(1861, '1037581069', '2018-11-02 06:04:16', '7900', 1),
(1862, '43605625', '2018-11-02 06:08:16', '8000', 1),
(1863, '23917651', '2018-11-02 06:16:21', '2500', 1),
(1864, '1035879778', '2018-11-02 06:18:34', '2000', 1),
(1865, '43288005', '2018-11-02 06:23:28', '10800', 1),
(1866, '1036629003', '2018-11-02 06:27:32', '9800', 1),
(1867, '1020479554', '2018-11-02 06:28:40', '10000', 1),
(1868, '1046913982', '2018-11-02 06:39:18', '2000', 1),
(1869, '71267825', '2018-11-02 06:40:59', '5900', 1),
(1870, '8433778', '2018-11-02 07:03:51', '2000', 1),
(1871, '1152701919', '2018-11-02 07:16:31', '2000', 1),
(1872, '1096238261', '2018-11-02 07:17:28', '7900', 1),
(1873, '1152450553', '2018-11-02 07:24:15', '14900', 1),
(1874, '43596807', '2018-11-02 07:29:05', '2000', 1),
(1875, '1035915735', '2018-11-02 07:31:47', '4000', 1),
(1876, '1037587834', '2018-11-06 06:15:28', '8000', 1),
(1877, '8433778', '2018-11-06 06:17:08', '2000', 1),
(1878, '1128430240', '2018-11-06 06:26:48', '5900', 1),
(1879, '1216718503', '2018-11-06 06:28:24', '12900', 1),
(1880, '1020464577', '2018-11-06 06:38:00', '1400', 1),
(1881, '1017216447', '2018-11-06 06:38:03', '10500', 1),
(1882, '1035879778', '2018-11-06 06:39:58', '2000', 1),
(1883, '1007110815', '2018-11-06 06:42:57', '12900', 1),
(1884, '1036680551', '2018-11-06 06:45:16', '8100', 1),
(1885, '1036629003', '2018-11-06 06:47:04', '8100', 1),
(1886, '1017179570', '2018-11-06 06:54:19', '4000', 1),
(1887, '32353491', '2018-11-06 07:22:45', '12000', 1),
(1888, '1017125039', '2018-11-06 07:24:29', '2800', 1),
(1889, '1036680551', '2018-11-07 06:01:40', '2700', 1),
(1890, '1017216447', '2018-11-07 06:02:15', '12800', 1),
(1891, '1214721942', '2018-11-07 06:08:58', '15900', 1),
(1892, '8433778', '2018-11-07 06:10:02', '2000', 1),
(1893, '1007110815', '2018-11-07 06:23:13', '9900', 1),
(1894, '71267825', '2018-11-07 06:29:47', '2000', 1),
(1895, '1017179570', '2018-11-07 06:34:14', '7000', 1),
(1896, '1020479554', '2018-11-07 06:38:42', '2100', 1),
(1897, '1039049115', '2018-11-07 07:15:30', '4200', 1),
(1898, '1152210828', '2018-11-07 07:19:22', '1400', 1),
(1899, '1152450553', '2018-11-07 07:33:24', '12400', 1),
(1900, '1017187557', '2018-11-07 07:33:59', '11300', 1),
(1901, '1017216447', '2018-11-08 06:12:47', '7900', 1),
(1902, '1152701919', '2018-11-08 06:14:41', '4800', 1),
(1903, '71267825', '2018-11-08 06:18:56', '5900', 1),
(1904, '1017137065', '2018-11-08 06:36:26', '10600', 1),
(1905, '71268332', '2018-11-08 07:04:19', '6800', 1),
(1906, '1036680551', '2018-11-08 07:04:52', '2700', 1),
(1907, '1036629003', '2018-11-08 07:07:08', '7700', 1),
(1908, '1017125039', '2018-11-08 07:08:14', '6900', 1),
(1909, '1128430240', '2018-11-08 07:07:37', '4500', 1),
(1910, '43975208', '2018-11-08 07:09:34', '9600', 1),
(1911, '1046913982', '2018-11-08 07:10:43', '8400', 1),
(1912, '1007110815', '2018-11-08 07:14:31', '14400', 1),
(1913, '8433778', '2018-11-08 07:15:10', '2000', 1),
(1914, '1017179570', '2018-11-08 07:17:13', '12400', 1),
(1915, '1152450553', '2018-11-08 07:17:19', '12000', 1),
(1916, '43342456', '2018-11-08 07:18:46', '4000', 1),
(1917, '1020479554', '2018-11-08 07:35:20', '2100', 1),
(1918, '1214721942', '2018-11-08 07:40:48', '7900', 1),
(1919, '1039447684', '2018-11-09 16:20:22', '7900', 1),
(1920, '1037631569', '2018-11-09 06:03:26', '7900', 1),
(1921, '1129045994', '2018-11-09 06:04:50', '12100', 1),
(1922, '1152701919', '2018-11-09 06:06:58', '8300', 1),
(1923, '1006887114', '2018-11-09 06:06:59', '6000', 1),
(1924, '8433778', '2018-11-09 06:08:11', '2000', 1);
INSERT INTO `pedido` (`idPedido`, `documento`, `fecha_pedido`, `total`, `estado`) VALUES
(1925, '71267825', '2018-11-09 06:11:16', '5900', 1),
(1926, '1036629003', '2018-11-09 06:13:41', '7000', 1),
(1927, '1036680551', '2018-11-09 06:19:15', '2000', 1),
(1928, '1035879778', '2018-11-09 06:21:17', '4500', 1),
(1929, '1020479554', '2018-11-09 06:22:13', '2100', 1),
(1930, '1017216447', '2018-11-09 06:52:37', '11600', 1),
(1931, '1007110815', '2018-11-09 06:57:41', '5500', 1),
(1932, '1077453248', '2018-11-09 06:59:02', '5300', 1),
(1933, '1216718503', '2018-11-09 07:06:16', '11200', 1),
(1934, '54253320', '2018-11-09 07:08:16', '4200', 1),
(1935, '1039049115', '2018-11-09 07:09:19', '4200', 1),
(1936, '1017137065', '2018-11-09 07:09:44', '6800', 1),
(1937, '1037587834', '2018-11-09 07:15:20', '19700', 1),
(1938, '1152210828', '2018-11-09 07:17:28', '1400', 1),
(1939, '1152450553', '2018-11-09 07:29:28', '7900', 1),
(1940, '1028009266', '2018-11-09 07:44:07', '9100', 1),
(1941, '1020464577', '2018-11-13 06:24:57', '2000', 1),
(1942, '1007110815', '2018-11-13 06:28:58', '12100', 1),
(1943, '1216718503', '2018-11-13 06:31:20', '8800', 1),
(1944, '1017216447', '2018-11-13 06:32:35', '3700', 1),
(1945, '1006887114', '2018-11-13 06:35:02', '6000', 1),
(1946, '1036680551', '2018-11-13 06:47:22', '3800', 1),
(1947, '1036629003', '2018-11-13 06:48:10', '4000', 1),
(1948, '1020457057', '2018-11-13 06:49:23', '4000', 1),
(1949, '1035879778', '2018-11-13 06:51:55', '2000', 1),
(1950, '1039049115', '2018-11-13 06:55:32', '4200', 1),
(1951, '1095791547', '2018-11-13 07:01:56', '7900', 1),
(1952, '1037587834', '2018-11-13 07:15:30', '5000', 1),
(1953, '43605625', '2018-11-13 07:16:43', '5000', 1),
(1954, '1017125039', '2018-11-13 07:31:39', '4400', 1),
(1955, '1129045994', '2018-11-13 07:37:28', '12100', 1),
(1956, '1152450553', '2018-11-13 07:38:16', '4100', 1),
(1957, '1036629003', '2018-11-14 06:42:50', '8900', 1),
(1958, '1037631569', '2018-11-14 06:45:58', '4000', 1),
(1959, '1129045994', '2018-11-14 06:47:35', '12700', 1),
(1960, '1007110815', '2018-11-14 06:49:43', '7800', 1),
(1961, '1017216447', '2018-11-14 06:50:43', '9700', 1),
(1962, '1216718503', '2018-11-14 06:51:03', '14900', 1),
(1963, '1095791547', '2018-11-14 06:52:52', '7900', 1),
(1964, '1035879778', '2018-11-14 06:54:49', '2000', 1),
(1965, '71268332', '2018-11-14 06:57:54', '10900', 1),
(1966, '1036680551', '2018-11-14 06:58:25', '4000', 1),
(1967, '1020464577', '2018-11-14 07:00:08', '9100', 1),
(1968, '1017179570', '2018-11-14 07:01:33', '4000', 1),
(1969, '1077453248', '2018-11-14 07:05:08', '1400', 1),
(1970, '1152210828', '2018-11-14 07:14:26', '1400', 1),
(1971, '1046913982', '2018-11-14 07:18:04', '10500', 1),
(1972, '43583398', '2018-11-14 07:23:08', '8400', 1),
(1973, '1037587834', '2018-11-14 07:31:47', '6000', 1),
(1974, '1017239142', '2018-11-14 07:32:23', '7900', 1),
(1975, '43605625', '2018-11-14 07:33:44', '6800', 1),
(1976, '1017187557', '2018-11-14 07:39:22', '4000', 1),
(1977, '43596807', '2018-11-14 07:43:40', '2000', 1),
(1978, '1152701919', '2018-11-15 06:16:23', '13400', 1),
(1979, '1017216447', '2018-11-15 06:08:38', '8100', 1),
(1980, '1017137065', '2018-11-15 06:11:44', '13100', 1),
(1981, '1096238261', '2018-11-15 06:14:00', '7900', 1),
(1982, '1035879778', '2018-11-15 06:15:35', '2000', 1),
(1983, '43605625', '2018-11-15 06:20:12', '6000', 1),
(1984, '1037587834', '2018-11-15 06:22:37', '12100', 1),
(1985, '1007110815', '2018-11-15 06:33:01', '2000', 1),
(1986, '1017179570', '2018-11-15 06:34:47', '8100', 1),
(1987, '1035915735', '2018-11-15 06:35:55', '4800', 1),
(1988, '1036601013', '2018-11-15 06:36:12', '2500', 1),
(1989, '1036680551', '2018-11-15 06:36:44', '6800', 1),
(1990, '1036598684', '2018-11-15 06:37:16', '7900', 1),
(1991, '1216718503', '2018-11-15 06:38:39', '2500', 1),
(1992, '1214721942', '2018-11-15 06:43:42', '22100', 1),
(1993, '71267825', '2018-11-15 06:45:27', '2000', 1),
(1994, '1095791547', '2018-11-15 06:45:34', '11900', 1),
(1995, '1006887114', '2018-11-15 06:47:06', '4000', 1),
(1996, '1129045994', '2018-11-15 06:47:48', '14100', 1),
(1997, '43975208', '2018-11-15 07:01:36', '9600', 1),
(1998, '98699433', '2018-11-15 07:06:50', '7900', 1),
(1999, '1046913982', '2018-11-15 07:11:27', '10000', 1),
(2000, '1017125039', '2018-11-15 07:18:43', '2800', 1),
(2001, '1017187557', '2018-11-15 07:19:03', '9700', 1),
(2002, '1036629003', '2018-11-15 07:20:23', '5900', 1),
(2003, '1017156424', '2018-11-15 07:22:34', '10400', 1),
(2004, '1128405581', '2018-11-15 07:30:31', '7900', 1),
(2005, '1028009266', '2018-11-15 07:32:59', '7900', 1),
(2006, '43288005', '2018-11-15 07:44:38', '2000', 1),
(2007, '1017216447', '2018-11-16 06:01:20', '6200', 1),
(2008, '1017179570', '2018-11-16 06:11:46', '4500', 1),
(2009, '71267825', '2018-11-16 06:24:50', '5900', 1),
(2010, '1129045994', '2018-11-16 06:31:27', '5900', 1),
(2011, '1017187557', '2018-11-16 06:37:04', '9200', 1),
(2012, '1152450553', '2018-11-16 06:39:00', '3800', 1),
(2013, '1095791547', '2018-11-16 06:41:01', '7900', 1),
(2014, '1035879778', '2018-11-16 06:41:01', '4500', 1),
(2015, '1037587834', '2018-11-16 06:53:31', '3300', 1),
(2016, '71268332', '2018-11-16 06:55:22', '7800', 1),
(2017, '43605625', '2018-11-16 06:57:33', '5000', 1),
(2018, '1020464577', '2018-11-16 07:02:58', '7900', 1),
(2019, '1128430240', '2018-11-16 07:05:03', '11800', 1),
(2020, '760579', '2018-11-16 07:13:26', '9100', 1),
(2021, '1020457057', '2018-11-16 07:10:12', '4000', 1),
(2022, '1216718503', '2018-11-16 07:13:25', '12700', 1),
(2023, '1035915735', '2018-11-16 07:17:05', '2800', 1),
(2024, '1017239142', '2018-11-16 07:30:35', '7900', 1),
(2025, '43596807', '2018-11-16 07:36:48', '2000', 1),
(2026, '1152701919', '2018-11-19 06:01:44', '2800', 1),
(2027, '1037631569', '2018-11-19 06:05:54', '7000', 1),
(2028, '71267825', '2018-11-19 06:19:25', '10000', 1),
(2029, '1017216447', '2018-11-19 06:22:43', '4800', 1),
(2030, '1020457057', '2018-11-19 06:24:14', '4000', 1),
(2031, '1017137065', '2018-11-19 06:37:18', '5200', 1),
(2032, '1017156424', '2018-11-19 06:40:21', '7900', 1),
(2033, '1077453248', '2018-11-19 06:45:53', '2000', 1),
(2034, '1095791547', '2018-11-19 06:56:33', '7900', 1),
(2035, '1006887114', '2018-11-19 06:57:47', '4000', 1),
(2036, '1017179570', '2018-11-19 07:08:10', '4100', 1),
(2037, '1037587834', '2018-11-19 07:25:57', '8000', 1),
(2038, '1152450553', '2018-11-19 07:29:55', '12400', 1),
(2039, '1028009266', '2018-11-19 07:33:09', '7900', 1),
(2040, '1017239142', '2018-11-19 07:36:38', '7900', 1),
(2041, '1036601013', '2018-11-20 06:18:05', '2500', 1),
(2042, '1152701919', '2018-11-20 06:40:35', '2800', 1),
(2043, '1036598684', '2018-11-20 06:43:28', '1300', 1),
(2044, '1037587834', '2018-11-20 06:45:02', '6000', 1),
(2045, '1007110815', '2018-11-20 06:45:03', '6800', 1),
(2046, '1036680551', '2018-11-20 06:47:07', '2800', 1),
(2047, '1036629003', '2018-11-20 06:48:04', '4000', 1),
(2048, '71267825', '2018-11-20 06:57:40', '2000', 1),
(2049, '43596807', '2018-11-20 07:26:17', '3000', 1),
(2050, '1020430141', '2018-11-20 07:30:17', '6200', 1),
(2051, '1152450553', '2018-11-20 07:35:46', '12000', 1),
(2052, '1017156424', '2018-11-20 07:39:37', '7900', 1),
(2053, '1017216447', '2018-11-21 06:03:04', '5700', 1),
(2054, '1037587834', '2018-11-21 06:04:35', '4000', 1),
(2055, '1020464577', '2018-11-21 06:10:10', '2000', 1),
(2056, '71267825', '2018-11-21 06:14:54', '2000', 1),
(2057, '1036601013', '2018-11-21 06:19:19', '2500', 1),
(2058, '1017156424', '2018-11-21 07:08:36', '10800', 1),
(2059, '1096238261', '2018-11-21 07:14:54', '7900', 1),
(2060, '1152701919', '2018-11-21 07:17:16', '2800', 1),
(2061, '1028009266', '2018-11-21 07:41:49', '7900', 1),
(2062, '1017216447', '2018-11-22 06:02:23', '11600', 1),
(2063, '1096238261', '2018-11-22 06:03:17', '7900', 1),
(2064, '1036598684', '2018-11-22 06:13:47', '2600', 1),
(2065, '71267825', '2018-11-22 06:14:04', '2000', 1),
(2066, '1007110815', '2018-11-22 06:28:50', '7900', 1),
(2067, '1095791547', '2018-11-22 06:41:12', '7900', 1),
(2068, '1020430141', '2018-11-22 07:10:58', '5900', 1),
(2069, '1036680551', '2018-11-22 07:23:26', '5200', 1),
(2070, '1152450553', '2018-11-22 07:24:02', '12000', 1),
(2071, '1036629003', '2018-11-22 07:26:32', '6500', 1),
(2072, '1037587834', '2018-11-23 06:01:08', '11900', 1),
(2073, '1017216447', '2018-11-23 06:03:33', '14100', 1),
(2074, '1152701919', '2018-11-23 06:04:36', '5900', 1),
(2075, '1036612156', '2018-11-23 06:22:17', '8800', 1),
(2076, '71267825', '2018-11-23 06:26:22', '2000', 1),
(2077, '1036601013', '2018-11-23 06:37:55', '2500', 1),
(2078, '1020430141', '2018-11-23 06:39:38', '8600', 1),
(2079, '43841319', '2018-11-23 07:22:47', '8800', 1),
(2080, '1007110815', '2018-11-23 07:21:32', '2200', 1),
(2081, '1036680551', '2018-11-23 07:24:33', '5400', 1),
(2082, '1152450553', '2018-11-23 07:28:01', '6500', 1),
(2083, '43596807', '2018-11-23 07:36:11', '2000', 1),
(2084, '1017216447', '2018-11-26 06:01:56', '7900', 1),
(2085, '1096238261', '2018-11-26 06:06:57', '7900', 1),
(2086, '760579', '2018-11-26 06:10:11', '1200', 1),
(2087, '71267825', '2018-11-26 06:10:43', '2000', 1),
(2088, '43288005', '2018-11-26 06:22:45', '6000', 1),
(2089, '1007110815', '2018-11-26 06:33:02', '9700', 1),
(2090, '1020457057', '2018-11-26 06:36:21', '2500', 1),
(2091, '1152210828', '2018-11-26 06:38:10', '2700', 1),
(2092, '1036680551', '2018-11-26 06:41:55', '2000', 1),
(2093, '1046913982', '2018-11-26 06:45:12', '4200', 1),
(2094, '1020479554', '2018-11-26 06:53:01', '2100', 1),
(2095, '32353491', '2018-11-26 07:00:05', '2000', 1),
(2096, '1017187557', '2018-11-26 07:03:54', '6600', 1),
(2097, '1077453248', '2018-11-26 07:06:25', '2000', 1),
(2098, '1095791547', '2018-11-26 07:09:51', '4100', 1),
(2099, '1036629003', '2018-11-26 07:19:45', '9000', 1),
(2100, '1035915735', '2018-11-26 07:37:08', '2800', 1),
(2101, '1028016893', '2018-11-27 16:59:24', '5900', 1),
(2102, '1152701919', '2018-11-27 06:00:55', '5900', 1),
(2103, '1017216447', '2018-11-27 06:02:58', '7600', 1),
(2104, '8433778', '2018-11-27 06:33:45', '2000', 1),
(2105, '1036598684', '2018-11-27 06:36:02', '3300', 1),
(2106, '43605625', '2018-11-27 06:37:18', '3300', 1),
(2107, '1020430141', '2018-11-27 06:37:50', '10200', 1),
(2108, '1017187557', '2018-11-27 06:39:26', '5300', 1),
(2109, '1152450553', '2018-11-27 06:45:40', '6800', 1),
(2110, '1020479554', '2018-11-27 06:59:35', '10000', 1),
(2111, '1095791547', '2018-11-27 07:02:22', '4100', 1),
(2112, '71267825', '2018-11-27 07:04:16', '4100', 1),
(2113, '54253320', '2018-11-27 07:07:08', '5600', 1),
(2114, '1046913982', '2018-11-27 07:12:19', '10100', 1),
(2115, '1152210828', '2018-11-27 07:17:21', '1400', 1),
(2116, '1214734202', '2018-11-27 07:18:19', '1400', 1),
(2117, '1036680551', '2018-11-27 07:25:39', '2900', 1),
(2118, '1036629003', '2018-11-27 07:33:09', '9900', 1),
(2119, '1017239142', '2018-11-27 07:33:42', '2800', 1),
(2120, '1017216447', '2018-11-28 06:00:45', '5900', 1),
(2121, '43288005', '2018-11-28 06:11:06', '6000', 1),
(2122, '1020457057', '2018-11-28 06:12:33', '2500', 1),
(2123, '1020479554', '2018-11-28 06:54:23', '2100', 1),
(2124, '1077453248', '2018-11-28 06:58:19', '6700', 1),
(2125, '1095791547', '2018-11-28 07:01:23', '4200', 1),
(2126, '1152450553', '2018-11-28 07:08:02', '7000', 1),
(2127, '1007110815', '2018-11-28 07:08:47', '4700', 1),
(2128, '1035915735', '2018-11-28 07:15:03', '4200', 1),
(2129, '43265824', '2018-11-28 07:19:20', '7900', 1),
(2130, '1036680551', '2018-11-28 07:30:37', '5300', 1),
(2131, '1036629003', '2018-11-28 07:32:59', '10100', 1),
(2132, '43596807', '2018-11-28 07:36:14', '2000', 1),
(2133, '1017216447', '2018-11-29 06:02:28', '5900', 1),
(2134, '43288005', '2018-11-29 06:07:06', '2500', 1),
(2135, '43605625', '2018-11-29 06:11:41', '4000', 1),
(2136, '1017187557', '2018-11-29 06:13:13', '7900', 1),
(2137, '98772784', '2018-11-29 06:20:32', '12700', 1),
(2138, '1095791547', '2018-11-29 06:22:27', '4000', 1),
(2139, '1017125039', '2018-11-29 06:45:37', '10000', 1),
(2140, '1152701919', '2018-11-29 06:45:57', '3000', 1),
(2141, '43189198', '2018-11-29 06:51:20', '7500', 1),
(2142, '1017156424', '2018-11-29 07:01:25', '7900', 1),
(2143, '1036680551', '2018-11-29 07:02:07', '4200', 1),
(2144, '1077453248', '2018-11-29 07:12:51', '4800', 1),
(2145, '1152450553', '2018-11-29 07:15:21', '12400', 1),
(2146, '1017239142', '2018-11-29 07:20:06', '7900', 1),
(2147, '1007110815', '2018-11-29 07:29:18', '4000', 1),
(2148, '1020479554', '2018-11-29 07:37:46', '2100', 1),
(2149, '32353491', '2018-11-29 07:43:42', '2000', 1),
(2150, '1017216447', '2018-11-30 06:00:39', '10700', 1),
(2151, '71267825', '2018-11-30 06:04:02', '2000', 1),
(2152, '1036612156', '2018-11-30 06:04:26', '7700', 1),
(2153, '760579', '2018-11-30 06:04:26', '1400', 1),
(2154, '1007110815', '2018-11-30 06:06:13', '5900', 1),
(2155, '1020430141', '2018-11-30 06:08:14', '6400', 1),
(2156, '43605625', '2018-11-30 06:12:20', '3300', 1),
(2157, '1152701919', '2018-11-30 06:16:53', '2500', 1),
(2158, '1096238261', '2018-11-30 07:22:35', '11900', 1),
(2159, '1036680551', '2018-11-30 06:20:03', '7000', 1),
(2160, '1036651097', '2018-11-30 06:29:36', '5000', 1),
(2161, '1046913982', '2018-11-30 06:39:09', '2000', 1),
(2162, '1017187557', '2018-11-30 06:41:02', '13700', 1),
(2163, '43288005', '2018-11-30 06:55:30', '4000', 1),
(2164, '71268332', '2018-11-30 07:05:51', '2100', 1),
(2165, '43975208', '2018-11-30 07:06:32', '11600', 1),
(2166, '1020479554', '2018-11-30 07:07:14', '10000', 1),
(2167, '1017225857', '2018-11-30 07:08:38', '2000', 1),
(2168, '1095791547', '2018-11-30 07:09:50', '4800', 1),
(2169, '1039049115', '2018-11-30 07:15:00', '4800', 1),
(2170, '1035915735', '2018-11-30 07:21:14', '4800', 1),
(2171, '1152450553', '2018-11-30 07:30:10', '14400', 1),
(2172, '43596807', '2018-11-30 07:35:49', '2000', 1),
(2173, '1028009266', '2018-11-30 07:38:54', '7900', 1),
(2174, '1017216447', '2018-12-03 06:18:10', '5900', 1),
(2175, '71267825', '2018-12-03 06:25:39', '2000', 1),
(2176, '1152701919', '2018-12-03 06:34:58', '2000', 1),
(2177, '1037949696', '2018-12-03 06:47:40', '4000', 1),
(2178, '1036680551', '2018-12-03 06:54:22', '5000', 1),
(2179, '43605625', '2018-12-03 06:57:20', '7000', 1),
(2180, '1007110815', '2018-12-03 06:58:52', '10100', 1),
(2181, '1036598684', '2018-12-03 07:02:32', '5100', 1),
(2182, '1214734202', '2018-12-03 07:04:46', '1400', 1),
(2184, '1020430141', '2018-12-03 07:12:25', '9200', 1),
(2185, '71268332', '2018-12-03 07:17:14', '11900', 1),
(2186, '1020479554', '2018-12-03 07:17:48', '8000', 1),
(2187, '1152450553', '2018-12-03 07:27:25', '4500', 1),
(2188, '1017156424', '2018-12-03 07:28:44', '7900', 1),
(2189, '1020457057', '2018-12-03 07:28:48', '2500', 1),
(2190, '1036629003', '2018-12-03 07:39:20', '1400', 1),
(2191, '1017216447', '2018-12-04 06:02:17', '7900', 1),
(2192, '1039049115', '2018-12-04 06:29:33', '4000', 1),
(2194, '1020430141', '2018-12-04 06:36:15', '4100', 1),
(2195, '43605625', '2018-12-04 06:40:26', '4000', 1),
(2196, '1036629003', '2018-12-04 06:47:49', '5000', 1),
(2197, '1036680551', '2018-12-04 06:49:11', '1400', 1),
(2198, '1007110815', '2018-12-04 06:53:33', '9600', 1),
(2199, '43288005', '2018-12-04 06:56:15', '6400', 1),
(2200, '1046913982', '2018-12-04 07:14:02', '2200', 1),
(2201, '1020479554', '2018-12-04 07:33:20', '2100', 1),
(2202, '43596807', '2018-12-04 07:34:01', '3000', 1),
(2203, '1035915735', '2018-12-04 07:42:40', '2800', 1),
(2204, '1017216447', '2018-12-05 06:00:44', '10400', 1),
(2205, '1007110815', '2018-12-05 06:06:09', '10100', 1),
(2206, '1036680551', '2018-12-05 06:12:54', '4800', 1),
(2207, '1020430141', '2018-12-05 06:37:16', '6000', 1),
(2208, '1096238261', '2018-12-05 06:38:46', '7900', 1),
(2209, '1017187557', '2018-12-05 06:39:33', '11900', 1),
(2210, '43189198', '2018-12-05 06:55:02', '7900', 1),
(2211, '1077453248', '2018-12-05 07:02:10', '2800', 1),
(2212, '43841319', '2018-12-05 07:11:52', '7000', 1),
(2213, '1020479554', '2018-12-05 07:31:49', '2100', 1),
(2214, '1152210828', '2018-12-05 07:32:21', '1400', 1),
(2215, '1095791547', '2018-12-05 07:41:05', '2100', 1),
(2216, '1017216447', '2018-12-06 06:06:06', '9900', 1),
(2217, '1096238261', '2018-12-06 06:09:48', '9800', 1),
(2218, '1152450553', '2018-12-06 06:11:34', '12400', 1),
(2219, '1039049115', '2018-12-06 06:12:26', '7900', 1),
(2220, '8433778', '2018-12-06 06:12:53', '7900', 1),
(2221, '71267825', '2018-12-06 06:24:56', '2000', 1),
(2222, '1017187557', '2018-12-06 06:26:21', '4600', 1),
(2223, '1020430141', '2018-12-06 06:27:04', '6200', 1),
(2224, '43605625', '2018-12-06 06:31:47', '2000', 1),
(2225, '1020479554', '2018-12-06 06:53:50', '10000', 1),
(2226, '1095791547', '2018-12-06 06:54:44', '10000', 1),
(2227, '1017156424', '2018-12-06 07:01:06', '7900', 1),
(2228, '1007110815', '2018-12-06 07:01:51', '11900', 1),
(2229, '1036680551', '2018-12-06 07:08:01', '11800', 1),
(2230, '760579', '2018-12-06 07:10:29', '1200', 1),
(2231, '1036629003', '2018-12-06 07:11:24', '9900', 1),
(2232, '1152210828', '2018-12-06 07:15:17', '1300', 1),
(2233, '43265824', '2018-12-06 07:17:12', '5900', 1),
(2234, '1017239142', '2018-12-06 07:27:21', '7900', 1),
(2235, '1046913982', '2018-12-06 07:27:57', '8100', 1),
(2236, '1152701919', '2018-12-07 06:37:08', '11600', 1),
(2237, '1017216447', '2018-12-07 06:46:57', '5100', 1),
(2238, '1017125039', '2018-12-07 06:48:20', '9000', 1),
(2239, '1007110815', '2018-12-07 06:50:05', '2200', 1),
(2240, '1020430141', '2018-12-07 06:50:16', '4000', 1),
(2241, '1046913982', '2018-12-07 06:53:28', '6200', 1),
(2242, '1036680551', '2018-12-07 06:56:59', '2000', 1),
(2243, '1036629003', '2018-12-07 06:59:59', '5900', 1),
(2244, '1017156424', '2018-12-07 07:02:44', '6800', 1),
(2245, '760579', '2018-12-07 07:02:59', '2600', 1),
(2246, '1096238261', '2018-12-07 07:26:19', '7900', 1),
(2247, '1095791547', '2018-12-07 07:38:10', '2500', 1),
(2248, '1017216447', '2018-12-10 06:07:07', '9800', 1),
(2249, '43605625', '2018-12-10 06:50:08', '4000', 1),
(2250, '1020479554', '2018-12-10 06:50:41', '2100', 1),
(2251, '1007110815', '2018-12-10 06:55:11', '10300', 1),
(2252, '1152450553', '2018-12-10 06:56:00', '12400', 1),
(2253, '43288005', '2018-12-10 06:56:59', '2500', 1),
(2254, '1036629003', '2018-12-10 07:19:20', '8700', 1),
(2255, '71268332', '2018-12-10 07:20:17', '7900', 1),
(2256, '1017187557', '2018-12-10 07:21:32', '6000', 1),
(2257, '43596807', '2018-12-10 07:40:48', '2000', 1),
(2258, '1017216447', '2018-12-11 06:04:31', '7900', 1),
(2259, '1036629003', '2018-12-11 06:30:34', '6000', 1),
(2260, '1007110815', '2018-12-11 06:31:18', '5900', 1),
(2261, '43288005', '2018-12-11 06:44:18', '2000', 1),
(2262, '1017156424', '2018-12-11 06:49:36', '6100', 1),
(2263, '1095791547', '2018-12-11 06:52:25', '8100', 1),
(2264, '1020479554', '2018-12-11 07:15:34', '2100', 1),
(2265, '1152450553', '2018-12-11 07:16:00', '14100', 1),
(2266, '43605625', '2018-12-11 07:16:48', '6200', 1),
(2267, '71267825', '2018-12-11 07:24:13', '2000', 1),
(2268, '1035915735', '2018-12-11 07:32:44', '5000', 1),
(2269, '1077453248', '2018-12-11 07:43:10', '4200', 1),
(2270, '1017216447', '2018-12-12 10:10:35', '8900', 1),
(2271, '43288005', '2018-12-12 06:08:47', '2500', 1),
(2272, '1152701919', '2018-12-12 06:09:35', '1400', 1),
(2273, '43605625', '2018-12-12 06:24:17', '5400', 1),
(2274, '1017187557', '2018-12-12 06:26:42', '6800', 1),
(2275, '1037587834', '2018-12-12 06:36:28', '4200', 1),
(2276, '1007110815', '2018-12-12 06:48:15', '7100', 1),
(2277, '1077453248', '2018-12-12 06:54:24', '2000', 1),
(2278, '43975208', '2018-12-12 07:12:52', '10000', 1),
(2279, '1046913982', '2018-12-12 07:13:26', '5400', 1),
(2280, '1017125039', '2018-12-12 07:14:22', '4200', 1),
(2281, '1095791547', '2018-12-12 07:22:02', '3000', 1),
(2283, '1152450553', '2018-12-12 07:30:33', '6800', 1),
(2284, '1036629003', '2018-12-12 07:33:44', '4000', 1),
(2285, '1036680551', '2018-12-12 07:34:48', '1400', 1),
(2286, '1017216447', '2018-12-13 06:04:04', '14100', 1),
(2287, '1096238261', '2018-12-13 06:42:08', '7900', 1),
(2288, '1152450553', '2018-12-13 06:44:05', '12400', 1),
(2289, '1017156424', '2018-12-13 06:45:02', '7900', 1),
(2290, '43288005', '2018-12-13 06:46:53', '8000', 1),
(2291, '1020479554', '2018-12-13 06:59:17', '2100', 1),
(2292, '1095791547', '2018-12-13 07:07:24', '4100', 1),
(2293, '1007110815', '2018-12-13 07:15:18', '7900', 1),
(2294, '1037587834', '2018-12-13 07:32:00', '4000', 1),
(2295, '1028009266', '2018-12-13 07:36:29', '7900', 1),
(2296, '43596807', '2018-12-13 07:38:10', '2000', 1),
(2297, '1017216447', '2018-12-14 06:00:19', '10500', 1),
(2298, '43265824', '2018-12-14 06:01:34', '7900', 1),
(2299, '1152701919', '2018-12-14 06:05:38', '12400', 1),
(2300, '71267825', '2018-12-14 06:07:09', '5900', 1),
(2301, '1037587834', '2018-12-14 06:20:40', '6600', 1),
(2302, '1039049115', '2018-12-14 06:23:53', '4800', 1),
(2303, '43288005', '2018-12-14 06:30:32', '8800', 1),
(2304, '1077453248', '2018-12-14 06:54:22', '4000', 1),
(2305, '1096238261', '2018-12-14 07:00:06', '9900', 1),
(2306, '1007110815', '2018-12-14 07:04:51', '4800', 1),
(2307, '1020479554', '2018-12-14 07:09:01', '10000', 1),
(2308, '1095791547', '2018-12-14 07:11:03', '10000', 1),
(2309, '1017125039', '2018-12-14 07:21:43', '9600', 1),
(2310, '1036629003', '2018-12-14 07:28:13', '9900', 1),
(2311, '1152450553', '2018-12-14 07:31:47', '2500', 1),
(2312, '32353491', '2018-12-14 07:42:12', '2000', 1),
(2313, '1017239142', '2018-12-14 07:42:25', '7900', 1),
(2314, '1152701919', '2018-12-17 06:14:10', '2800', 1),
(2315, '1017187557', '2018-12-17 06:15:35', '3300', 1),
(2316, '1017216447', '2018-12-17 06:16:29', '6800', 1),
(2317, '1037587834', '2018-12-17 06:18:16', '10000', 1),
(2318, '1077453248', '2018-12-17 06:26:09', '2000', 1),
(2319, '1152210828', '2018-12-17 06:33:00', '3400', 1),
(2320, '1007110815', '2018-12-17 06:35:36', '2000', 1),
(2321, '1017125039', '2018-12-17 06:39:15', '9200', 1),
(2322, '1095791547', '2018-12-17 07:07:57', '7900', 1),
(2323, '1020479554', '2018-12-17 07:09:08', '2100', 1),
(2324, '1046913982', '2018-12-17 07:10:40', '11900', 1),
(2325, '1017239142', '2018-12-17 07:13:41', '7900', 1),
(2326, '43583398', '2018-12-17 07:19:06', '5900', 1),
(2327, '43288005', '2018-12-17 07:21:50', '11900', 1),
(2328, '1152450553', '2018-12-17 07:21:52', '7900', 1),
(2329, '23917651', '2018-12-17 07:37:25', '5900', 1),
(2330, '1001545147', '2018-12-17 07:43:12', '8400', 1),
(2331, '760579', '2018-12-18 06:04:30', '2500', 1),
(2332, '1017216447', '2018-12-18 06:06:29', '4800', 1),
(2333, '1020479554', '2018-12-18 07:00:42', '2100', 1),
(2334, '1077453248', '2018-12-18 07:03:05', '2000', 1),
(2335, '1152210828', '2018-12-18 07:12:30', '1400', 1),
(2336, '1152450553', '2018-12-18 07:36:50', '6200', 1),
(2337, '43605625', '2018-12-18 07:38:12', '5900', 1),
(2338, '1046913982', '2018-12-18 07:44:09', '3000', 1),
(2339, '32353491', '2018-12-18 07:44:19', '5900', 1),
(2340, '1017216447', '2018-12-19 06:10:07', '5200', 1),
(2341, '1046913982', '2018-12-19 06:10:20', '5000', 1),
(2342, '1017156424', '2018-12-19 06:29:55', '4200', 1),
(2343, '1037587834', '2018-12-19 06:30:23', '4000', 1),
(2344, '71267825', '2018-12-19 06:55:57', '5900', 1),
(2345, '1020479554', '2018-12-19 07:14:16', '2100', 1),
(2346, '1095791547', '2018-12-19 07:16:33', '4100', 1),
(2347, '1214734202', '2018-12-19 07:31:30', '2000', 1),
(2348, '1037606721', '2018-12-19 07:32:25', '4000', 1),
(2349, '1152450553', '2018-12-19 07:34:38', '5200', 1),
(2350, '1017239142', '2018-12-19 07:44:39', '7900', 1),
(2351, '43265824', '2018-12-20 06:01:19', '5900', 0),
(2352, '1017216447', '2018-12-20 06:14:12', '10900', 0),
(2353, '1039049115', '2018-12-20 06:35:14', '10700', 0),
(2354, '1152450553', '2018-12-20 06:57:31', '12400', 0),
(2355, '1020479554', '2018-12-20 07:19:08', '5900', 0),
(2356, '1035915735', '2018-12-20 07:09:48', '4200', 0),
(2357, '43583398', '2018-12-20 07:39:16', '15800', 0),
(2358, '1037606721', '2018-12-20 07:42:42', '5200', 0),
(2359, '1152701919', '2018-12-21 06:00:34', '1800', 0),
(2360, '1017216447', '2018-12-21 06:03:21', '6800', 0),
(2361, '1095791547', '2018-12-21 06:19:57', '7900', 0),
(2362, '1077453248', '2018-12-21 06:24:24', '4000', 0),
(2363, '71267825', '2018-12-21 06:27:15', '5900', 0),
(2364, '1017187557', '2018-12-21 07:02:38', '13700', 0),
(2365, '1037587834', '2018-12-21 07:04:02', '4000', 0),
(2366, '1046913982', '2018-12-21 07:13:52', '7100', 0),
(2367, '1036629003', '2018-12-21 07:28:45', '12400', 0),
(2368, '1020479554', '2018-12-21 07:30:09', '2100', 0),
(2369, '32353491', '2018-12-21 07:37:33', '2000', 0),
(2370, '1152701919', '2018-12-26 06:50:51', '2800', 0),
(2371, '1017216447', '2018-12-26 06:19:40', '9300', 0),
(2372, '1037587834', '2018-12-26 07:10:37', '6600', 0),
(2373, '1017187557', '2018-12-26 07:09:50', '8200', 0),
(2374, '43596807', '2018-12-26 07:23:03', '2100', 0),
(2375, '32353491', '2018-12-26 07:42:34', '2000', 0),
(2376, '1017216447', '2018-12-27 06:07:22', '12200', 0),
(2378, '1046913982', '2018-12-27 06:26:30', '7900', 0),
(2379, '1037587834', '2018-12-27 06:40:38', '6600', 0),
(2380, '15489896', '2018-12-27 06:49:04', '7900', 0),
(2381, '1152210828', '2018-12-27 07:19:37', '9300', 0),
(2382, '43596807', '2018-12-27 07:21:51', '2000', 0),
(2384, '1017216447', '2018-12-28 06:05:13', '8700', 0),
(2385, '1046913982', '2018-12-28 06:12:05', '2000', 0),
(2386, '1152701919', '2018-12-28 06:16:43', '2800', 0),
(2387, '1037587834', '2018-12-28 06:40:42', '9000', 0),
(2388, '1036629003', '2018-12-28 06:58:35', '10000', 0),
(2389, '32353491', '2018-12-28 07:39:04', '5900', 0),
(2390, '1035915735', '2018-12-28 07:43:03', '4200', 0),
(2391, '1017216447', '2019-01-02 06:06:29', '4800', 0),
(2393, '43189198', '2019-01-02 06:15:35', '11800', 0),
(2394, '1036629003', '2019-01-02 06:17:25', '9800', 0),
(2395, '1036680551', '2019-01-02 06:19:07', '8200', 0),
(2396, '1035915735', '2019-01-02 07:26:02', '2800', 0),
(2397, '1017187557', '2019-01-02 07:26:41', '7900', 0),
(2398, '1017156424', '2019-01-02 07:26:45', '4800', 0),
(2399, '1037587834', '2019-01-02 07:27:22', '2000', 0),
(2400, '1017216447', '2019-01-03 06:01:40', '6200', 0),
(2401, '1020479554', '2019-01-03 06:28:47', '2100', 0),
(2402, '54253320', '2019-01-03 06:37:53', '4200', 0),
(2403, '1036629003', '2019-01-03 06:42:01', '9000', 0),
(2404, '71267825', '2019-01-03 07:02:06', '2000', 0),
(2405, '1017125039', '2019-01-03 07:13:45', '8200', 0),
(2406, '98699433', '2019-01-03 07:27:26', '12900', 0),
(2407, '43596807', '2019-01-03 07:36:29', '2000', 0),
(2408, '1017216447', '2019-01-04 06:00:24', '6200', 0),
(2409, '1046913982', '2019-01-04 06:19:23', '8000', 0),
(2410, '71267825', '2019-01-04 06:11:02', '5900', 0),
(2411, '1020479554', '2019-01-04 06:18:45', '2100', 0),
(2412, '43596807', '2019-01-04 07:27:40', '2000', 0),
(2413, '71267825', '2019-01-09 06:07:11', '2000', 1),
(2414, '1017216447', '2019-01-09 06:12:01', '9300', 1),
(2415, '1037587834', '2019-01-09 07:29:42', '4000', 1),
(2416, '1017187557', '2019-01-09 07:30:21', '6600', 1),
(2417, '71268332', '2019-01-09 07:33:47', '4100', 1),
(2418, '1017216447', '2019-01-10 06:34:30', '14300', 1),
(2419, '1095791547', '2019-01-10 07:08:20', '7900', 1),
(2420, '1152450553', '2019-01-10 07:14:15', '7900', 1),
(2421, '43975208', '2019-01-10 07:19:39', '10100', 1),
(2422, '1037587834', '2019-01-10 07:21:12', '4000', 1),
(2423, '1046913982', '2019-01-10 07:22:18', '4800', 1),
(2424, '1017156424', '2019-01-10 07:25:28', '5000', 1),
(2425, '98699433', '2019-01-10 07:28:05', '12900', 1),
(2426, '43596807', '2019-01-10 07:37:19', '7900', 1),
(2427, '71267825', '2019-01-11 06:20:45', '5900', 1),
(2428, '1037587834', '2019-01-11 06:30:17', '5000', 1),
(2429, '32353491', '2019-01-11 07:01:36', '2000', 1),
(2430, '1036629003', '2019-01-11 07:10:18', '12700', 1),
(2431, '23917651', '2019-01-11 07:11:59', '2000', 1),
(2432, '1017216447', '2019-01-11 07:22:17', '5900', 1),
(2433, '1152450553', '2019-01-11 07:23:24', '14100', 1),
(2434, '43596807', '2019-01-11 07:29:47', '4800', 1),
(2435, '1039049115', '2019-01-11 07:34:02', '4200', 1),
(2436, '1017216447', '2019-01-14 06:02:45', '6800', 1),
(2437, '43265824', '2019-01-14 06:16:05', '7900', 1),
(2438, '71267825', '2019-01-14 06:36:31', '2000', 1),
(2439, '1020479554', '2019-01-14 07:02:33', '2100', 1),
(2440, '1020457057', '2019-01-14 07:05:52', '10000', 1),
(2441, '71268332', '2019-01-14 07:08:06', '7900', 1),
(2442, '1017187557', '2019-01-14 07:23:31', '10000', 1),
(2443, '1017125039', '2019-01-14 07:23:44', '10000', 1),
(2444, '1046913982', '2019-01-14 07:23:54', '4500', 1),
(2445, '54253320', '2019-01-14 07:34:00', '1400', 1),
(2446, '1037606721', '2019-01-14 07:34:51', '5200', 1),
(2447, '1017216447', '2019-01-15 06:04:58', '6800', 1),
(2448, '71267825', '2019-01-15 06:40:02', '2000', 1),
(2449, '1035915735', '2019-01-15 06:54:15', '5000', 1),
(2450, '1046913982', '2019-01-15 07:09:45', '4200', 1),
(2451, '43605625', '2019-01-15 07:21:34', '13900', 1),
(2452, '1017187557', '2019-01-15 07:23:56', '4000', 1),
(2453, '1152450553', '2019-01-15 07:26:01', '6500', 1),
(2454, '43265824', '2019-01-15 07:27:57', '6800', 1),
(2455, '1037606721', '2019-01-15 07:28:53', '2500', 1),
(2456, '32353491', '2019-01-15 07:41:19', '5900', 1),
(2457, '1037587834', '2019-01-16 06:22:39', '10000', 1),
(2458, '43605625', '2019-01-16 06:23:12', '5900', 1),
(2459, '1017187557', '2019-01-16 06:24:16', '6200', 1),
(2460, '71267825', '2019-01-16 06:43:15', '5900', 1),
(2461, '1214734202', '2019-01-16 07:15:08', '2000', 1),
(2462, '43288005', '2019-01-16 07:24:37', '4200', 1),
(2463, '23917651', '2019-01-16 07:24:47', '5900', 1),
(2464, '1020479554', '2019-01-16 07:25:05', '10000', 1),
(2465, '1152450553', '2019-01-16 07:27:28', '2100', 1),
(2466, '71267825', '2019-01-17 06:05:16', '5900', 1),
(2467, '1152450553', '2019-01-17 07:09:50', '7900', 1),
(2468, '1096238261', '2019-01-17 07:10:53', '7900', 1),
(2469, '43975208', '2019-01-17 07:18:50', '7300', 1),
(2470, '1017125039', '2019-01-17 07:21:24', '6900', 1),
(2471, '43596807', '2019-01-17 07:33:58', '7900', 1),
(2472, '71267825', '2019-01-18 06:01:36', '5900', 1),
(2473, '760579', '2019-01-18 06:12:42', '1200', 1),
(2474, '1095791547', '2019-01-18 07:09:39', '7900', 1),
(2475, '1017187557', '2019-01-18 07:18:16', '11200', 1),
(2476, '1037587834', '2019-01-18 07:19:22', '4000', 1),
(2477, '1017216447', '2019-01-18 07:30:12', '6200', 1),
(2478, '1152450553', '2019-01-18 07:38:50', '7500', 1),
(2479, '1020479554', '2019-01-21 07:42:37', '2100', 0),
(2480, '1017239142', '2019-01-21 07:43:45', '1400', 0),
(2481, '1020479554', '2019-01-22 06:12:17', '10000', 1),
(2482, '1017187557', '2019-01-22 06:50:15', '5300', 1),
(2483, '1037587834', '2019-01-22 06:50:40', '4000', 1),
(2484, '1017239142', '2019-01-22 07:28:33', '1400', 1),
(2485, '1152450553', '2019-01-22 07:35:01', '12400', 1),
(2486, '1020479554', '2019-01-23 06:32:17', '10000', 1),
(2487, '1096238261', '2019-01-23 06:36:11', '7900', 1),
(2488, '43189198', '2019-01-23 06:37:33', '7900', 1),
(2489, '43605625', '2019-01-23 07:06:05', '6000', 1),
(2490, '1017187557', '2019-01-23 07:24:12', '1400', 1),
(2491, '1152450553', '2019-01-23 07:30:08', '5000', 1),
(2492, '1037606721', '2019-01-23 07:36:09', '7900', 1),
(2493, '1020479554', '2019-01-24 06:40:29', '2100', 1),
(2494, '43288005', '2019-01-24 06:43:10', '7900', 1),
(2495, '1039049115', '2019-01-24 07:08:52', '4200', 1),
(2496, '1036680551', '2019-01-24 07:14:39', '7900', 1),
(2497, '1037587834', '2019-01-24 07:16:24', '13800', 1),
(2498, '1152450553', '2019-01-24 07:17:08', '12400', 1),
(2499, '32353491', '2019-01-24 07:29:47', '7900', 1),
(2500, '760579', '2019-01-25 06:00:38', '2600', 1),
(2501, '1017216447', '2019-01-25 06:02:32', '6000', 1),
(2502, '1095791547', '2019-01-25 06:03:57', '7900', 1),
(2503, '43288005', '2019-01-25 06:22:21', '4800', 1),
(2504, '1020479554', '2019-01-25 06:46:12', '2100', 1),
(2505, '1037587834', '2019-01-25 07:04:15', '4500', 1),
(2506, '43263856', '2019-01-25 07:25:03', '4000', 1),
(2507, '43596807', '2019-01-25 07:27:17', '2100', 1),
(2508, '1152701919', '2019-01-28 06:10:57', '2800', 1),
(2509, '1036629003', '2019-01-28 06:31:46', '14400', 1),
(2510, '43605625', '2019-01-28 06:36:12', '10900', 1),
(2511, '1017187557', '2019-01-28 06:38:18', '4600', 1),
(2512, '1020479554', '2019-01-28 06:41:00', '2100', 1),
(2513, '1077453248', '2019-01-28 07:23:59', '4000', 1),
(2514, '43975208', '2019-01-28 07:31:46', '2800', 1),
(2515, '1152701919', '2019-01-29 06:00:24', '3700', 1),
(2516, '1017125039', '2019-01-29 07:15:43', '9000', 1),
(2517, '1037587834', '2019-01-29 07:11:04', '6000', 1),
(2518, '1152210828', '2019-01-29 07:18:57', '1400', 1),
(2519, '1095791547', '2019-01-29 07:26:01', '4600', 1),
(2520, '1020479554', '2019-01-29 07:27:59', '2100', 1),
(2521, '1077453248', '2019-01-29 07:28:11', '4500', 1),
(2522, '43263856', '2019-01-29 07:31:30', '4000', 1),
(2523, '43841319', '2019-01-29 07:40:49', '2000', 1),
(2524, '1096238261', '2019-01-30 06:01:28', '7900', 1),
(2525, '1017216447', '2019-01-30 06:01:38', '10200', 1),
(2526, '1152701919', '2019-01-30 06:01:58', '16900', 1),
(2527, '98772784', '2019-01-30 06:04:48', '2800', 1),
(2528, '1046913982', '2019-01-30 06:50:21', '9700', 1),
(2529, '1020479554', '2019-01-30 06:45:22', '2100', 1),
(2530, '43189198', '2019-01-30 06:46:32', '11500', 1),
(2531, '1152450553', '2019-01-30 06:47:39', '9900', 1),
(2532, '43975208', '2019-01-30 07:13:51', '7800', 1),
(2533, '1077453248', '2019-01-30 07:25:40', '4000', 1),
(2534, '1214734202', '2019-01-30 07:36:27', '4000', 1),
(2535, '1037587834', '2019-01-30 07:37:31', '6200', 1),
(2536, '1020479554', '2019-01-31 06:05:53', '10000', 1),
(2537, '1152701919', '2019-01-31 06:08:04', '11900', 1),
(2538, '43605625', '2019-01-31 06:11:02', '5900', 1),
(2539, '42702332', '2019-01-31 06:11:42', '7900', 1),
(2540, '1039049115', '2019-01-31 06:46:50', '7900', 1),
(2541, '1095791547', '2019-01-31 06:50:14', '7900', 1),
(2542, '1152210828', '2019-01-31 07:12:24', '1400', 1),
(2543, '1036629003', '2019-01-31 07:19:22', '7900', 1),
(2544, '1035915735', '2019-01-31 07:19:40', '2800', 1),
(2545, '1046913982', '2019-01-31 07:19:56', '2000', 1),
(2546, '1037606721', '2019-01-31 07:30:41', '7900', 1),
(2547, '43596807', '2019-01-31 07:36:18', '2000', 1),
(2548, '98772784', '2019-02-01 06:08:55', '5900', 1),
(2549, '1152701919', '2019-02-01 06:11:28', '4000', 1),
(2550, '1020479554', '2019-02-01 06:31:48', '10000', 1),
(2551, '1095791547', '2019-02-01 06:36:37', '7900', 1),
(2552, '1046913982', '2019-02-01 06:39:41', '10100', 1),
(2553, '1036629003', '2019-02-01 06:47:59', '11900', 1),
(2554, '1152450553', '2019-02-01 06:56:01', '7900', 1),
(2555, '1096238261', '2019-02-01 06:57:39', '4800', 1),
(2556, '1017239142', '2019-02-01 07:31:36', '9300', 1),
(2557, '1152450553', '2019-02-04 06:36:12', '13600', 1),
(2558, '43605625', '2019-02-04 06:39:14', '4000', 1),
(2559, '1020457057', '2019-02-04 06:56:16', '2500', 1),
(2560, '1017125039', '2019-02-04 07:07:37', '4200', 1),
(2561, '43288005', '2019-02-04 07:12:12', '4800', 1),
(2562, '1017239142', '2019-02-04 07:35:44', '1400', 1),
(2563, '1035915735', '2019-02-04 07:42:12', '2800', 1),
(2564, '71268332', '2019-02-04 07:43:49', '7900', 1),
(2565, '71267825', '2019-02-05 06:10:26', '2000', 1),
(2566, '1020479554', '2019-02-05 06:20:32', '10000', 1),
(2567, '43975208', '2019-02-05 06:30:36', '8000', 1),
(2568, '1077453248', '2019-02-05 07:19:46', '5000', 1),
(2569, '1017239142', '2019-02-05 07:22:11', '1400', 1),
(2570, '1152701919', '2019-02-06 06:01:18', '2800', 1),
(2571, '71267825', '2019-02-06 06:07:58', '5900', 1),
(2572, '43288005', '2019-02-06 06:20:49', '2000', 1),
(2573, '1020479554', '2019-02-06 06:29:07', '2100', 1),
(2574, '1017156424', '2019-02-06 06:45:23', '2000', 1),
(2575, '1216727816', '2019-02-06 07:24:23', '2100', 1),
(2576, '1037587834', '2019-02-06 07:08:30', '5000', 1),
(2577, '1020457057', '2019-02-06 07:19:24', '4100', 1),
(2578, '98699433', '2019-02-06 07:22:11', '4000', 1),
(2579, '43605625', '2019-02-07 06:01:09', '7900', 0),
(2580, '1017156424', '2019-02-07 06:07:54', '7900', 0),
(2581, '43288005', '2019-02-07 06:34:04', '7900', 0),
(2582, '32353491', '2019-02-07 06:51:28', '9300', 0),
(2583, '1077453248', '2019-02-07 06:53:55', '7900', 0),
(2584, '1020479554', '2019-02-07 07:15:06', '2100', 0),
(2585, '43596807', '2019-02-07 07:23:57', '7900', 0),
(2586, '1095791547', '2019-02-07 07:25:10', '2100', 0),
(2587, '1152210828', '2019-02-07 07:28:56', '7900', 0),
(2588, '1039049115', '2019-02-07 07:29:42', '5800', 0),
(2589, '1152450553', '2019-02-07 07:35:13', '12900', 0),
(2590, '71267825', '2019-02-07 07:38:59', '2000', 0),
(2591, '71267825', '2019-02-08 06:09:35', '5900', 1),
(2592, '1017156424', '2019-02-08 06:46:40', '2000', 1),
(2593, '1036629003', '2019-02-08 06:46:51', '7000', 1),
(2594, '1077453248', '2019-02-08 06:54:43', '2000', 1),
(2595, '1152210828', '2019-02-08 07:14:28', '2000', 1),
(2596, '1020479554', '2019-02-08 07:17:03', '2100', 1),
(2597, '1040044905', '2019-02-08 07:18:11', '7900', 1),
(2598, '54253320', '2019-02-08 07:28:00', '5600', 1),
(2599, '1036680551', '2019-02-08 07:28:17', '7000', 1),
(2600, '32353491', '2019-02-08 07:34:20', '9300', 1),
(2601, '1077453248', '2019-02-11 06:36:05', '5000', 1),
(2602, '43288005', '2019-02-11 06:46:12', '7900', 1),
(2603, '1017156424', '2019-02-11 06:55:04', '5100', 1),
(2604, '1096238261', '2019-02-11 07:13:33', '8800', 1),
(2605, '1035915735', '2019-02-11 07:31:50', '4200', 1),
(2606, '1020479554', '2019-02-11 07:35:47', '8000', 1),
(2607, '1020430141', '2019-02-12 06:06:40', '6200', 1),
(2608, '1077453248', '2019-02-12 06:46:33', '2800', 1),
(2609, '1017125039', '2019-02-12 07:10:25', '10000', 1),
(2610, '1152450553', '2019-02-12 07:28:04', '4600', 1),
(2611, '1020479554', '2019-02-12 07:32:24', '2100', 1),
(2612, '1017156424', '2019-02-12 07:43:21', '6000', 1),
(2613, '760579', '2019-02-13 06:01:03', '1200', 1),
(2614, '1017156424', '2019-02-13 06:01:20', '8000', 1),
(2615, '1152701919', '2019-02-13 06:03:17', '2800', 1),
(2616, '71267825', '2019-02-13 06:15:12', '5900', 1),
(2617, '1020430141', '2019-02-13 06:17:02', '6600', 1),
(2618, '98772784', '2019-02-13 06:52:50', '2800', 1),
(2619, '1037587834', '2019-02-13 07:02:47', '10600', 1),
(2620, '43605625', '2019-02-13 07:04:08', '4000', 1),
(2621, '1020479554', '2019-02-13 07:07:25', '2100', 1),
(2622, '1152701919', '2019-02-14 06:00:40', '2800', 1),
(2623, '1020479554', '2019-02-14 06:15:01', '10000', 1),
(2624, '1037587834', '2019-02-14 06:23:25', '11600', 1),
(2625, '1036680551', '2019-02-14 06:24:54', '7900', 1),
(2626, '43605625', '2019-02-14 06:25:15', '9900', 1),
(2627, '1017156424', '2019-02-14 06:25:33', '32500', 1),
(2628, '1039049115', '2019-02-14 06:25:54', '5800', 1),
(2629, '98699433', '2019-02-14 06:27:15', '7000', 1),
(2630, '1020430141', '2019-02-14 06:33:41', '6600', 1),
(2631, '43975208', '2019-02-14 06:47:53', '12400', 1),
(2632, '1077453248', '2019-02-14 06:56:33', '4800', 1),
(2633, '1036629003', '2019-02-14 06:59:50', '7900', 1),
(2634, '98772784', '2019-02-14 07:21:06', '4000', 1),
(2635, '1017239142', '2019-02-14 07:22:36', '9300', 1),
(2636, '43583398', '2019-02-14 07:26:39', '15800', 1),
(2637, '43263856', '2019-02-14 07:30:07', '4000', 1),
(2638, '1046913982', '2019-02-14 07:39:28', '7000', 1),
(2639, '1040044905', '2019-02-14 07:44:24', '7900', 1),
(2640, '43265824', '2019-02-15 06:09:01', '2000', 1),
(2641, '1152701919', '2019-02-15 06:12:00', '2000', 1),
(2642, '71267825', '2019-02-15 06:12:03', '2000', 1),
(2643, '1152450553', '2019-02-15 06:16:51', '7900', 1),
(2644, '1037587834', '2019-02-15 06:25:36', '8300', 1),
(2645, '1017125039', '2019-02-15 06:26:12', '5600', 1),
(2646, '43605625', '2019-02-15 06:27:20', '4000', 1),
(2647, '43189198', '2019-02-15 06:32:19', '7900', 1),
(2648, '1077453248', '2019-02-15 06:59:15', '5800', 1),
(2649, '1020479554', '2019-02-15 07:02:11', '10000', 1),
(2650, '1020457057', '2019-02-15 07:14:31', '1400', 1),
(2651, '98772784', '2019-02-15 07:18:53', '4000', 1),
(2652, '1216727816', '2019-02-15 07:22:35', '4800', 1),
(2653, '1037606721', '2019-02-15 07:24:48', '5200', 1),
(2654, '1017239142', '2019-02-15 07:33:12', '2100', 1),
(2655, '43271378', '2019-02-15 07:38:01', '4000', 1),
(2656, '1017187557', '2019-02-15 07:41:08', '6100', 1),
(2657, '1036629003', '2019-02-15 07:41:26', '8900', 1),
(2658, '1017216447', '2019-02-18 06:03:05', '7900', 1),
(2659, '43975208', '2019-02-18 06:45:22', '4000', 1),
(2660, '1152701919', '2019-02-18 06:47:01', '2800', 1),
(2661, '1017156424', '2019-02-18 06:50:17', '2000', 1),
(2662, '1077453248', '2019-02-18 06:51:32', '3000', 1),
(2663, '71267825', '2019-02-18 06:53:30', '2000', 1),
(2664, '1152450553', '2019-02-18 07:08:07', '12900', 1),
(2665, '1036629003', '2019-02-18 07:11:31', '7900', 1),
(2666, '1037587834', '2019-02-18 07:14:03', '6000', 1),
(2667, '1035915735', '2019-02-18 07:20:27', '5000', 1),
(2668, '43271378', '2019-02-18 07:24:40', '3300', 1),
(2669, '1020430141', '2019-02-18 07:28:16', '5800', 1),
(2670, '71267825', '2019-02-19 06:02:50', '2000', 1),
(2671, '43189198', '2019-02-19 06:50:03', '4500', 1),
(2672, '1096238261', '2019-02-19 06:52:31', '2000', 1),
(2673, '1039049115', '2019-02-19 06:55:02', '4200', 1),
(2674, '23917651', '2019-02-19 07:00:27', '5900', 1),
(2675, '1020479554', '2019-02-19 07:00:41', '2100', 1),
(2676, '1046913982', '2019-02-19 07:15:45', '12500', 1),
(2677, '8433778', '2019-02-19 07:17:43', '2000', 1),
(2678, '1036629003', '2019-02-19 07:19:26', '5900', 1),
(2679, '43596807', '2019-02-19 07:37:17', '2000', 1),
(2680, '43263856', '2019-02-19 07:39:14', '4000', 1),
(2681, '54253320', '2019-02-19 07:39:38', '4200', 1),
(2682, '1017187557', '2019-02-19 07:40:15', '1300', 1),
(2683, '21424773', '2019-02-20 06:09:24', '2000', 1),
(2684, '1077453248', '2019-02-20 06:31:13', '2800', 1),
(2685, '1037587834', '2019-02-20 06:41:06', '12300', 1),
(2686, '1020479554', '2019-02-20 07:03:10', '8000', 1),
(2687, '1020430141', '2019-02-20 07:03:28', '4000', 1),
(2688, '71268332', '2019-02-20 07:05:36', '3000', 1),
(2689, '1039447684', '2019-02-20 07:20:44', '7900', 1),
(2690, '43263856', '2019-02-20 07:39:36', '4000', 1),
(2691, '1152450553', '2019-02-21 06:02:00', '7900', 1),
(2692, '1017156424', '2019-02-21 06:09:03', '7900', 1),
(2693, '1036598684', '2019-02-21 06:11:02', '2000', 1),
(2694, '43288005', '2019-02-21 06:27:04', '6800', 1),
(2695, '1036680551', '2019-02-21 06:39:43', '4800', 1),
(2696, '1017216447', '2019-02-21 06:40:49', '4800', 1),
(2697, '1037587834', '2019-02-21 06:46:43', '8000', 1),
(2698, '8433778', '2019-02-21 06:49:29', '2000', 1),
(2699, '98699433', '2019-02-21 06:58:56', '14900', 1),
(2700, '1020479554', '2019-02-21 07:01:02', '10000', 1),
(2701, '1020430141', '2019-02-21 07:04:06', '4200', 1),
(2702, '1046913982', '2019-02-21 07:09:04', '2000', 1),
(2703, '1077453248', '2019-02-21 07:11:16', '2800', 1),
(2704, '1017239142', '2019-02-21 07:21:13', '1400', 1),
(2705, '43596807', '2019-02-21 07:21:22', '7900', 1),
(2706, '1152701919', '2019-02-22 06:00:22', '2800', 1),
(2707, '1039049115', '2019-02-22 06:04:15', '3200', 1),
(2708, '1017216447', '2019-02-22 06:05:16', '4800', 1),
(2709, '1020479554', '2019-02-22 06:31:03', '10000', 1),
(2710, '1095791547', '2019-02-22 06:36:44', '7900', 1),
(2711, '1077453248', '2019-02-22 06:42:23', '3000', 1),
(2712, '1037587834', '2019-02-22 07:02:06', '6000', 1),
(2713, '1036680551', '2019-02-22 07:14:46', '1400', 1),
(2714, '43596807', '2019-02-22 07:24:40', '4800', 1),
(2715, '1017187557', '2019-02-22 07:41:25', '1400', 1),
(2716, '98699433', '2019-02-25 06:30:42', '7900', 1),
(2717, '1152701919', '2019-02-25 06:37:24', '2800', 1),
(2718, '1020479554', '2019-02-25 06:40:10', '10000', 1),
(2719, '1020430141', '2019-02-25 06:40:44', '6200', 1),
(2720, '1037587834', '2019-02-25 07:23:48', '8500', 1),
(2721, '1017156424', '2019-02-25 07:28:45', '2000', 1),
(2722, '1020430141', '2019-02-26 06:00:30', '7600', 1),
(2723, '1020457057', '2019-02-26 06:16:10', '4000', 1),
(2724, '1020479554', '2019-02-26 06:23:39', '2100', 1),
(2725, '98772784', '2019-02-26 06:23:45', '2800', 1),
(2726, '1036598684', '2019-02-26 06:25:14', '2000', 1),
(2727, '1152701919', '2019-02-26 06:27:13', '2800', 1),
(2728, '1036629003', '2019-02-26 06:59:04', '2500', 1),
(2729, '1036622270', '2019-02-26 07:00:44', '2800', 1),
(2730, '1007310520', '2019-02-26 07:01:38', '2800', 1),
(2731, '1036680551', '2019-02-26 07:03:20', '2800', 1),
(2732, '71268332', '2019-02-26 07:12:19', '2000', 1),
(2733, '1017156424', '2019-02-26 07:18:49', '2000', 1),
(2734, '1017239142', '2019-02-26 07:21:21', '5400', 1),
(2735, '1096238261', '2019-02-26 07:22:09', '2100', 1),
(2736, '1037587834', '2019-02-26 07:23:31', '6200', 1),
(2737, '1017187557', '2019-02-26 07:39:27', '3000', 1),
(2738, '1036680551', '2019-02-27 06:07:06', '4800', 1),
(2739, '1046913982', '2019-02-27 06:16:50', '9500', 1),
(2740, '43975208', '2019-02-27 06:30:39', '4200', 1),
(2741, '8433778', '2019-02-27 06:50:06', '2000', 1),
(2742, '43605625', '2019-02-27 06:56:58', '4000', 1),
(2743, '1037587834', '2019-02-27 06:59:02', '8800', 1),
(2744, '1017156424', '2019-02-27 07:11:05', '3000', 1),
(2745, '1036629003', '2019-02-27 07:18:51', '11800', 1),
(2746, '1017239142', '2019-02-27 07:38:43', '1400', 1),
(2747, '71267825', '2019-02-28 06:19:33', '2000', 1),
(2748, '1020479554', '2019-02-28 06:20:00', '12400', 1),
(2749, '1039049115', '2019-02-28 06:38:32', '4200', 1),
(2750, '98772784', '2019-02-28 06:39:05', '2800', 1),
(2751, '1152450553', '2019-02-28 06:40:57', '10900', 1),
(2752, '1077453248', '2019-02-28 06:41:01', '3900', 1),
(2753, '43189198', '2019-02-28 06:47:38', '7900', 1),
(2754, '43265824', '2019-02-28 07:06:23', '5900', 1),
(2755, '1046913982', '2019-02-28 07:22:13', '7900', 1),
(2756, '1214734202', '2019-02-28 07:25:03', '11900', 1),
(2757, '43596807', '2019-02-28 07:28:32', '9900', 1),
(2758, '1037606721', '2019-02-28 07:42:51', '2000', 1),
(2759, '1020479554', '2019-03-01 07:11:36', '4100', 1),
(2760, '1096238261', '2019-03-01 06:39:07', '6800', 1),
(2761, '1036598684', '2019-03-01 06:44:36', '1300', 1),
(2762, '1036651097', '2019-03-01 06:45:23', '5000', 1),
(2763, '43975208', '2019-03-01 06:46:08', '4800', 1),
(2764, '1095791547', '2019-03-01 06:56:04', '7900', 1),
(2765, '98699433', '2019-03-01 07:18:48', '4000', 1),
(2766, '1046913982', '2019-03-01 07:19:45', '10700', 1),
(2767, '1037587834', '2019-03-01 07:21:47', '2000', 1),
(2768, '43605625', '2019-03-01 07:22:59', '6800', 1),
(2769, '1152210828', '2019-03-01 07:23:51', '2700', 1),
(2770, '54253320', '2019-03-01 07:43:13', '3600', 1),
(2771, '1152701919', '2019-03-04 06:19:33', '2800', 1),
(2772, '1020479554', '2019-03-04 06:23:00', '2100', 1),
(2773, '8433778', '2019-03-04 07:00:02', '2000', 1),
(2774, '1077453248', '2019-03-04 07:03:39', '4500', 1),
(2775, '1037587834', '2019-03-04 07:22:27', '4600', 1),
(2776, '43605625', '2019-03-04 07:23:22', '9900', 1),
(2777, '1017239142', '2019-03-04 07:33:41', '9300', 1),
(2778, '1039049115', '2019-03-05 06:19:13', '4800', 1),
(2779, '1077453248', '2019-03-05 06:24:55', '3400', 1),
(2780, '1020479554', '2019-03-05 06:35:25', '2500', 1),
(2781, '1152701919', '2019-03-05 06:41:21', '2800', 1),
(2782, '8433778', '2019-03-05 06:45:25', '2000', 1),
(2783, '1017125039', '2019-03-05 07:01:27', '6000', 1),
(2784, '1095791547', '2019-03-05 06:58:30', '2000', 1),
(2785, '71267825', '2019-03-05 07:23:21', '2000', 1),
(2786, '1152701919', '2019-03-06 06:01:00', '5900', 1),
(2787, '43189198', '2019-03-06 06:30:13', '5000', 1),
(2788, '71267825', '2019-03-06 06:39:37', '2000', 1),
(2789, '1077453248', '2019-03-06 06:57:02', '2000', 1),
(2790, '98699433', '2019-03-06 07:00:14', '14900', 1),
(2791, '1152210828', '2019-03-06 07:00:49', '1400', 1),
(2792, '43596807', '2019-03-06 07:23:26', '2000', 1),
(2793, '1017125039', '2019-03-06 07:24:28', '4200', 1),
(2794, '43271378', '2019-03-06 07:28:31', '2000', 1),
(2795, '1039447684', '2019-03-06 07:30:54', '7900', 1),
(2796, '1017156424', '2019-03-06 07:32:37', '6200', 1),
(2797, '54253320', '2019-03-06 07:37:16', '5600', 1),
(2798, '1017187557', '2019-03-06 07:38:01', '4000', 1),
(2799, '1039049115', '2019-03-07 06:04:41', '8000', 1),
(2800, '98699433', '2019-03-07 06:26:47', '7900', 1),
(2801, '1020479554', '2019-03-07 06:29:25', '10000', 1),
(2802, '71267825', '2019-03-07 06:40:19', '5900', 1),
(2803, '1152701919', '2019-03-07 06:42:35', '2800', 1),
(2804, '1037587834', '2019-03-07 06:45:24', '8000', 1),
(2805, '43605625', '2019-03-07 06:45:58', '7900', 1),
(2806, '1077453248', '2019-03-07 07:00:29', '3900', 1),
(2807, '1017125039', '2019-03-07 07:10:04', '2000', 1),
(2808, '1036629003', '2019-03-07 07:13:44', '3900', 1),
(2809, '1152450553', '2019-03-07 07:33:27', '12400', 1),
(2810, '43265824', '2019-03-08 06:17:04', '2000', 1),
(2811, '1020479554', '2019-03-08 06:26:42', '2500', 1),
(2812, '71267825', '2019-03-08 06:30:22', '2000', 1),
(2813, '1152701919', '2019-03-08 06:47:32', '2800', 1),
(2814, '1095791547', '2019-03-08 06:49:53', '7900', 1),
(2815, '8433778', '2019-03-08 06:59:44', '7900', 1),
(2816, '1077453248', '2019-03-08 07:01:02', '10000', 1),
(2817, '54253320', '2019-03-08 07:09:55', '4200', 1),
(2818, '1039049115', '2019-03-08 07:10:49', '4200', 1),
(2819, '1017187557', '2019-03-08 07:18:16', '13700', 1),
(2820, '760579', '2019-03-08 07:19:19', '6800', 1),
(2821, '1036629003', '2019-03-08 07:19:04', '7000', 1),
(2822, '43271378', '2019-03-08 07:41:48', '2000', 1),
(2823, '71267825', '2019-03-11 06:05:44', '5900', 1),
(2824, '1020457057', '2019-03-11 06:33:00', '1400', 1),
(2825, '1017125039', '2019-03-11 06:34:33', '4200', 1),
(2826, '1152701919', '2019-03-11 06:42:38', '4100', 1),
(2827, '1096238261', '2019-03-11 06:46:07', '7900', 1),
(2828, '1039447684', '2019-03-11 06:57:10', '7900', 1),
(2829, '1077453248', '2019-03-11 07:01:23', '2000', 1),
(2830, '43605625', '2019-03-11 07:14:16', '2500', 1),
(2831, '1017239142', '2019-03-11 07:27:56', '9300', 1),
(2832, '1095791547', '2019-03-11 07:29:17', '2000', 1),
(2833, '1020479554', '2019-03-11 07:31:49', '2500', 1),
(2834, '1152701919', '2019-03-12 06:03:10', '2800', 1),
(2835, '8433778', '2019-03-12 06:22:10', '2000', 1),
(2836, '71267825', '2019-03-12 06:25:23', '2000', 1),
(2837, '1152210828', '2019-03-12 06:55:22', '1400', 1),
(2838, '1020479554', '2019-03-12 07:00:09', '2100', 1),
(2839, '1077453248', '2019-03-12 07:00:28', '7700', 1),
(2840, '43265824', '2019-03-12 07:13:30', '7900', 1),
(2841, '1037587834', '2019-03-12 07:17:35', '4000', 1),
(2842, '43265824', '2019-03-13 06:03:12', '2000', 1),
(2843, '71267825', '2019-03-13 06:10:09', '5900', 1),
(2844, '1017156424', '2019-03-13 06:44:28', '11600', 1),
(2845, '1020479554', '2019-03-13 06:47:26', '10000', 1),
(2846, '1037587834', '2019-03-13 06:48:56', '4000', 1),
(2847, '1046913982', '2019-03-13 06:51:30', '4000', 1),
(2848, '1152701919', '2019-03-13 07:05:37', '2800', 1),
(2849, '8433778', '2019-03-13 07:20:14', '2000', 1),
(2850, '54253320', '2019-03-13 07:23:18', '5600', 1),
(2851, '71268332', '2019-03-13 07:28:54', '6800', 1),
(2852, '1152450553', '2019-03-13 07:36:24', '14100', 1),
(2853, '1039447684', '2019-03-13 07:55:44', '7000', 1),
(2854, '1152701919', '2019-03-14 06:01:46', '2800', 1),
(2855, '760579', '2019-03-14 06:04:52', '2600', 1),
(2856, '1095791547', '2019-03-14 06:07:37', '7900', 1),
(2857, '71267825', '2019-03-14 06:11:27', '5900', 1),
(2858, '1096238261', '2019-03-14 06:20:05', '10200', 1),
(2859, '1017156424', '2019-03-14 06:28:07', '19900', 1),
(2860, '1020479554', '2019-03-14 06:38:44', '5900', 1),
(2861, '1077453248', '2019-03-14 07:04:31', '10700', 1);
INSERT INTO `pedido` (`idPedido`, `documento`, `fecha_pedido`, `total`, `estado`) VALUES
(2862, '43596807', '2019-03-14 07:18:02', '4800', 1),
(2863, '43271378', '2019-03-14 07:21:13', '5000', 1),
(2864, '1037587834', '2019-03-14 07:31:38', '6600', 1),
(2865, '43605625', '2019-03-14 07:32:20', '7900', 1),
(2866, '1152210828', '2019-03-14 07:39:00', '7900', 1),
(2867, '1128267430', '2019-03-14 07:42:09', '1400', 1),
(2868, '32353491', '2019-03-15 06:02:18', '7900', 1),
(2869, '1036598684', '2019-03-15 06:08:34', '2000', 1),
(2870, '43975208', '2019-03-15 06:09:36', '6800', 1),
(2871, '98699433', '2019-03-15 06:09:45', '14900', 1),
(2872, '1152701919', '2019-03-15 06:11:16', '4800', 1),
(2873, '1037587834', '2019-03-15 06:16:52', '2600', 1),
(2874, '71267825', '2019-03-15 06:17:02', '5900', 1),
(2875, '43605625', '2019-03-15 06:18:44', '10800', 1),
(2876, '1017187557', '2019-03-15 06:20:01', '4600', 1),
(2877, '1017156424', '2019-03-15 06:21:28', '5100', 1),
(2878, '1020479554', '2019-03-15 06:33:15', '12400', 1),
(2879, '1046913982', '2019-03-15 06:48:41', '8700', 1),
(2880, '1095791547', '2019-03-15 07:05:36', '3000', 1),
(2881, '1152450553', '2019-03-15 07:17:45', '15200', 1),
(2882, '1017239142', '2019-03-15 07:26:34', '7900', 1),
(2883, '43271378', '2019-03-15 07:30:11', '3700', 1),
(2884, '1017125039', '2019-03-15 07:35:47', '10000', 1),
(2885, '1020479554', '2019-03-18 06:10:39', '10000', 1),
(2886, '1017225857', '2019-03-18 06:10:43', '7900', 1),
(2887, '1095791547', '2019-03-18 06:46:51', '7900', 1),
(2888, '98699433', '2019-03-18 06:48:48', '7000', 1),
(2889, '1036629003', '2019-03-18 06:50:44', '3900', 1),
(2890, '1077453248', '2019-03-18 06:52:35', '3000', 1),
(2891, '15489896', '2019-03-18 06:58:28', '7900', 1),
(2892, '71267825', '2019-03-19 06:07:22', '5900', 1),
(2893, '1020479554', '2019-03-19 06:22:21', '10000', 1),
(2894, '43975208', '2019-03-19 06:49:21', '9600', 1),
(2895, '1017187557', '2019-03-19 07:35:39', '3300', 1),
(2896, '1152701919', '2019-03-20 06:02:10', '5900', 1),
(2897, '1143991147', '2019-03-20 06:38:40', '5000', 1),
(2898, '1046913982', '2019-03-20 06:44:18', '5900', 1),
(2899, '1077453248', '2019-03-20 06:47:34', '2000', 1),
(2900, '98699433', '2019-03-20 06:48:39', '7900', 1),
(2901, '71268332', '2019-03-20 06:57:56', '7900', 1),
(2902, '1017125039', '2019-03-20 07:06:08', '3900', 1),
(2903, '1039049115', '2019-03-20 07:24:47', '2400', 1),
(2904, '1020479554', '2019-03-20 07:26:39', '10000', 1),
(2905, '1017239142', '2019-03-20 07:34:22', '1400', 1),
(2906, '1152450553', '2019-03-20 07:40:29', '7900', 1),
(2907, '1143991147', '2019-03-21 06:34:15', '4000', 1),
(2908, '1039049115', '2019-03-21 06:35:25', '9600', 1),
(2909, '1020479554', '2019-03-21 06:39:26', '10000', 1),
(2910, '1017156424', '2019-03-21 06:47:51', '12000', 1),
(2911, '1017125039', '2019-03-21 06:48:06', '6900', 1),
(2912, '1037587834', '2019-03-21 07:00:48', '2700', 1),
(2913, '1152210828', '2019-03-21 07:01:30', '1400', 1),
(2914, '1017187557', '2019-03-21 07:21:15', '3300', 1),
(2915, '43161988', '2019-03-21 07:24:16', '5900', 1),
(2916, '1152450553', '2019-03-21 07:32:41', '7900', 1),
(2917, '98699433', '2019-03-21 07:32:49', '7900', 1),
(2918, '1020479554', '2019-03-22 06:33:10', '10000', 1),
(2919, '1077453248', '2019-03-22 06:40:53', '5000', 1),
(2920, '1037587834', '2019-03-22 07:04:59', '2700', 1),
(2921, '1037606721', '2019-03-22 07:06:10', '5200', 1),
(2922, '43605625', '2019-03-22 07:06:17', '4000', 1),
(2923, '43161988', '2019-03-22 07:15:50', '4100', 1),
(2924, '43271378', '2019-03-22 07:16:19', '3000', 1),
(2925, '43596807', '2019-03-22 07:28:57', '2000', 1),
(2926, '1017156424', '2019-03-22 07:41:09', '4200', 1),
(2927, '1017187557', '2019-03-22 07:42:21', '2700', 1),
(2928, '1152701919', '2019-03-26 06:23:45', '2800', 1),
(2929, '1020479554', '2019-03-26 06:28:45', '8400', 1),
(2930, '1037587834', '2019-03-26 06:40:31', '2700', 1),
(2931, '98699433', '2019-03-26 06:57:26', '7900', 1),
(2932, '1020457057', '2019-03-26 06:59:32', '2000', 1),
(2933, '1017239142', '2019-03-26 07:08:52', '1400', 1),
(2934, '1095791547', '2019-03-26 07:12:25', '2000', 1),
(2935, '43161988', '2019-03-26 07:23:05', '3000', 1),
(2936, '1017125039', '2019-03-26 07:43:29', '4200', 1),
(2937, '1017156424', '2019-03-27 06:13:02', '10300', 1),
(2938, '43605625', '2019-03-27 06:33:15', '6500', 1),
(2939, '1077453248', '2019-03-27 06:35:40', '3000', 1),
(2940, '1017125039', '2019-03-27 06:39:49', '6000', 1),
(2941, '1036629003', '2019-03-27 07:35:39', '5300', 1),
(2942, '43265824', '2019-03-28 06:01:54', '5900', 1),
(2943, '1020479554', '2019-03-28 06:10:21', '8400', 1),
(2944, '1152701919', '2019-03-28 06:10:49', '2800', 1),
(2945, '43975208', '2019-03-28 07:03:51', '11000', 1),
(2946, '1036598684', '2019-03-28 07:07:04', '2000', 1),
(2947, '32353491', '2019-03-28 07:17:36', '7900', 1),
(2948, '43596807', '2019-03-28 07:28:05', '7900', 1),
(2949, '43271378', '2019-03-28 07:36:40', '2000', 1),
(2950, '1037606721', '2019-03-28 07:39:13', '2000', 1),
(2951, '1037587834', '2019-03-28 07:39:35', '7900', 1),
(2953, '1039049115', '2019-03-29 06:45:27', '4600', 1),
(2954, '1095791547', '2019-03-29 06:45:39', '10400', 1),
(2955, '1017156424', '2019-03-29 06:58:45', '8900', 1),
(2956, '1152701919', '2019-03-29 06:58:56', '4000', 1),
(2957, '43605625', '2019-03-29 07:14:30', '6000', 1),
(2958, '1096238261', '2019-03-29 07:24:05', '7900', 1),
(2959, '1152450553', '2019-03-29 07:25:46', '14400', 1),
(2960, '1020457057', '2019-03-29 07:36:03', '1400', 1),
(2961, '1036629003', '2019-03-29 07:37:00', '3900', 1),
(2962, '1017239142', '2019-03-29 07:43:28', '7900', 1),
(2963, '1017187557', '2019-04-01 06:21:17', '13800', 1),
(2964, '1152701919', '2019-04-01 06:31:38', '2800', 1),
(2965, '43288005', '2019-04-01 06:32:58', '2000', 1),
(2966, '98699433', '2019-04-01 06:52:53', '4000', 1),
(2967, '1046913982', '2019-04-01 06:53:42', '4200', 1),
(2968, '1020479554', '2019-04-01 06:54:19', '2600', 1),
(2969, '1017125039', '2019-04-01 06:56:30', '5500', 1),
(2970, '43271378', '2019-04-01 07:03:39', '14400', 1),
(2971, '1037587834', '2019-04-01 07:06:00', '2500', 1),
(2972, '1152450553', '2019-04-01 07:30:19', '14600', 1),
(2974, '1152701919', '2019-04-02 06:14:09', '3000', 1),
(2975, '32353491', '2019-04-02 06:30:39', '1200', 1),
(2976, '43288005', '2019-04-02 06:33:11', '14600', 1),
(2977, '1036598684', '2019-04-02 06:35:42', '4000', 1),
(2978, '1017125039', '2019-04-02 06:45:19', '8500', 1),
(2979, '1143991147', '2019-04-02 06:59:41', '3900', 1),
(2980, '1152210828', '2019-04-02 06:56:55', '1400', 1),
(2981, '1077453248', '2019-04-02 07:07:36', '5600', 1),
(2982, '98699433', '2019-04-02 07:08:08', '7900', 1),
(2983, '1020479554', '2019-04-02 07:08:12', '2500', 1),
(2984, '760579', '2019-04-02 07:16:23', '2800', 1),
(2985, '1017187557', '2019-04-02 07:33:25', '2400', 1),
(2986, '43975208', '2019-04-02 07:20:39', '3600', 1),
(2987, '1020457057', '2019-04-02 07:20:44', '5500', 1),
(2988, '1046913982', '2019-04-02 07:23:00', '3200', 1),
(2989, '43271378', '2019-04-02 07:23:16', '14400', 1),
(2990, '43288005', '2019-04-03 06:00:46', '2000', 1),
(2991, '1152701919', '2019-04-03 06:03:44', '3200', 1),
(2992, '1039049115', '2019-04-03 06:16:08', '12600', 1),
(2993, '43975208', '2019-04-03 06:29:57', '2800', 1),
(2994, '1037587834', '2019-04-03 06:42:41', '4000', 1),
(2995, '1020479554', '2019-04-03 06:58:24', '8400', 1),
(2996, '43271378', '2019-04-03 07:34:43', '16100', 1),
(2997, '1017187557', '2019-04-03 07:40:48', '5600', 1),
(2998, '32353491', '2019-04-03 07:42:23', '3700', 1),
(2999, '1128267430', '2019-04-03 07:43:13', '12600', 1),
(3000, '1152701919', '2019-04-04 06:05:11', '3000', 1),
(3001, '1020479554', '2019-04-04 06:13:10', '8400', 1),
(3002, '1017156424', '2019-04-04 06:50:53', '7900', 1),
(3003, '98699433', '2019-04-04 06:53:47', '7900', 1),
(3004, '1040044905', '2019-04-04 06:57:35', '4000', 1),
(3005, '15489917', '2019-04-04 06:58:23', '12600', 1),
(3006, '1020457057', '2019-04-04 07:06:29', '1400', 1),
(3007, '1037587834', '2019-04-04 07:15:08', '2700', 1),
(3008, '32353491', '2019-04-04 07:29:37', '4500', 1),
(3009, '43596807', '2019-04-04 07:34:20', '12600', 1),
(3010, '1017125039', '2019-04-04 07:35:06', '2500', 1),
(3011, '1128267430', '2019-04-04 07:38:03', '2500', 1),
(3012, '1152450553', '2019-04-04 07:39:07', '2000', 1),
(3013, '43271378', '2019-04-04 07:41:28', '9500', 1),
(3014, '1017225857', '2019-04-04 07:42:42', '3000', 1),
(3015, '54253320', '2019-04-04 07:43:31', '5600', 1),
(3016, '760579', '2019-04-05 06:13:51', '1400', 1),
(3017, '1036629003', '2019-04-05 06:30:09', '16600', 1),
(3018, '43189198', '2019-04-05 06:30:10', '2000', 1),
(3019, '1037587834', '2019-04-05 06:31:53', '15100', 1),
(3020, '1020457057', '2019-04-05 06:31:59', '2500', 1),
(3021, '1017156424', '2019-04-05 06:33:23', '10300', 1),
(3022, '1046913982', '2019-04-05 06:33:29', '3500', 1),
(3023, '1152701919', '2019-04-05 06:36:29', '15600', 1),
(3024, '1096238261', '2019-04-05 06:38:01', '15100', 1),
(3025, '1020479554', '2019-04-05 07:33:57', '16900', 1),
(3026, '1039447684', '2019-04-05 06:45:19', '12600', 1),
(3027, '1095791547', '2019-04-05 07:04:46', '9900', 1),
(3028, '1036598684', '2019-04-05 07:12:17', '3000', 1),
(3029, '43975208', '2019-04-05 07:20:01', '2800', 1),
(3030, '1077453248', '2019-04-05 07:31:31', '2000', 1),
(3031, '98699433', '2019-04-05 07:33:50', '12600', 1),
(3032, '1152450553', '2019-04-05 07:38:31', '16600', 1),
(3033, '43271378', '2019-04-05 07:39:40', '2500', 1),
(3034, '1020479554', '2019-04-08 06:07:18', '2500', 1),
(3035, '1017187557', '2019-04-08 06:23:41', '11400', 1),
(3036, '43605625', '2019-04-08 06:25:58', '7000', 1),
(3037, '1017156424', '2019-04-08 06:46:20', '4800', 1),
(3038, '1037587834', '2019-04-08 06:54:29', '3800', 1),
(3039, '1046913982', '2019-04-08 07:41:07', '6500', 1),
(3040, '1017225857', '2019-04-08 07:04:46', '2000', 1),
(3041, '1152701919', '2019-04-08 07:12:58', '7000', 1),
(3042, '43271378', '2019-04-08 07:43:52', '12600', 1),
(3043, '1152701919', '2019-04-09 06:08:21', '3000', 1),
(3044, '43189198', '2019-04-09 06:12:40', '12600', 1),
(3045, '1037587834', '2019-04-09 06:24:20', '4700', 1),
(3046, '1077453248', '2019-04-09 06:40:32', '12600', 1),
(3047, '32353491', '2019-04-09 06:47:38', '2000', 1),
(3048, '1017187557', '2019-04-09 06:51:37', '3200', 1),
(3049, '1017156424', '2019-04-09 07:00:05', '4000', 1),
(3050, '71268332', '2019-04-09 07:05:21', '6500', 1),
(3051, '1017239142', '2019-04-09 07:08:10', '1400', 1),
(3052, '1039049115', '2019-04-09 07:13:43', '3600', 1),
(3053, '43271378', '2019-04-09 07:31:48', '3500', 1),
(3054, '1152210828', '2019-04-09 07:32:20', '2000', 1),
(3055, '1096238261', '2019-04-10 06:08:01', '12600', 1),
(3056, '43288005', '2019-04-10 06:20:11', '2500', 1),
(3057, '43189198', '2019-04-10 06:20:30', '2500', 1),
(3058, '1020479554', '2019-04-10 06:27:26', '5900', 1),
(3059, '1095791547', '2019-04-10 06:41:27', '9900', 1),
(3060, '1020457057', '2019-04-10 06:53:23', '2000', 1),
(3061, '1152701919', '2019-04-10 07:02:32', '3000', 1),
(3062, '1017239142', '2019-04-10 07:20:21', '2500', 1),
(3063, '1017187557', '2019-04-10 07:26:07', '17600', 1),
(3064, '1036629003', '2019-04-10 07:27:40', '3900', 1),
(3065, '71267825', '2019-04-10 07:33:08', '4100', 1),
(3066, '98699433', '2019-04-10 07:42:14', '6000', 1),
(3067, '32353491', '2019-04-10 07:44:34', '2400', 1),
(3068, '43605625', '2019-04-11 06:22:52', '3500', 1),
(3069, '1017156424', '2019-04-11 06:29:01', '25200', 1),
(3070, '43189198', '2019-04-11 06:36:27', '16600', 1),
(3071, '1077453248', '2019-04-11 06:39:08', '2500', 1),
(3072, '43288005', '2019-04-11 06:44:14', '2000', 1),
(3073, '1046913982', '2019-04-11 06:53:43', '2700', 1),
(3074, '71268332', '2019-04-11 07:17:17', '4000', 1),
(3075, '1152701919', '2019-04-11 07:17:58', '3000', 1),
(3076, '1020479554', '2019-04-11 07:28:07', '5900', 1),
(3077, '1017187557', '2019-04-11 07:38:50', '5700', 1),
(3078, '1096238261', '2019-04-11 07:41:21', '2500', 1),
(3079, '32353491', '2019-04-11 07:42:22', '11600', 1),
(3080, '1152701919', '2019-04-12 06:06:40', '15600', 1),
(3081, '71267825', '2019-04-12 06:09:30', '5900', 1),
(3082, '1037587834', '2019-04-12 06:26:56', '16100', 1),
(3083, '98699433', '2019-04-12 06:40:45', '14700', 1),
(3084, '43975208', '2019-04-12 06:44:40', '12400', 1),
(3085, '54253320', '2019-04-12 07:16:46', '16200', 1),
(3086, '1039049115', '2019-04-12 06:54:48', '4200', 1),
(3087, '1017225857', '2019-04-12 06:58:20', '3000', 1),
(3088, '1152450553', '2019-04-12 06:59:12', '2000', 1),
(3089, '1096238261', '2019-04-12 07:04:19', '2500', 1),
(3090, '43161988', '2019-04-12 07:13:30', '3500', 1),
(3091, '1017187557', '2019-04-12 07:14:52', '4600', 1),
(3092, '760579', '2019-04-12 07:26:33', '1400', 1),
(3093, '1017156424', '2019-04-12 07:27:10', '4500', 1),
(3094, '43271378', '2019-04-12 07:31:04', '5100', 1),
(3095, '43265824', '2019-04-15 06:00:21', '7900', 1),
(3096, '1152701919', '2019-04-15 06:25:21', '3000', 1),
(3097, '1020479554', '2019-04-15 06:29:46', '5900', 1),
(3098, '1017156424', '2019-04-15 06:30:46', '4500', 1),
(3099, '98699433', '2019-04-15 06:41:51', '6800', 1),
(3100, '42702332', '2019-04-15 06:57:52', '12600', 1),
(3101, '1017187557', '2019-04-15 07:00:59', '3900', 1),
(3102, '1037587834', '2019-04-15 07:02:46', '9200', 1),
(3103, '43975208', '2019-04-15 07:12:29', '7200', 1),
(3104, '1020457057', '2019-04-15 07:19:30', '17000', 1),
(3105, '1036629003', '2019-04-15 07:21:20', '16100', 1),
(3106, '1095791547', '2019-04-15 07:26:28', '7900', 1),
(3107, '1152450553', '2019-04-15 07:39:59', '2000', 1),
(3108, '1152701919', '2019-04-16 06:15:36', '3000', 1),
(3109, '1036598684', '2019-04-16 06:40:07', '2000', 1),
(3110, '1020479554', '2019-04-16 06:41:45', '7900', 1),
(3111, '1046913982', '2019-04-16 06:42:11', '3900', 1),
(3112, '1020457057', '2019-04-16 06:53:40', '2400', 1),
(3113, '43271378', '2019-04-16 07:25:00', '15600', 1),
(3114, '1152450553', '2019-04-16 07:25:38', '15100', 1),
(3115, '1077453248', '2019-04-17 06:35:58', '7300', 1),
(3116, '1036622270', '2019-04-17 06:44:19', '7200', 1),
(3117, '43288005', '2019-04-17 06:46:50', '12600', 1),
(3118, '98699433', '2019-04-17 06:47:11', '6800', 1),
(3119, '32353491', '2019-04-17 06:57:50', '7100', 1),
(3120, '1020479554', '2019-04-17 07:04:52', '7900', 1),
(3121, '71268332', '2019-04-17 07:08:36', '2800', 1),
(3122, '1037587834', '2019-04-17 07:18:38', '3700', 1),
(3123, '1017187557', '2019-04-17 07:20:17', '2400', 1),
(3124, '1046913982', '2019-04-17 07:21:36', '17100', 1),
(3125, '1017239142', '2019-04-17 07:42:26', '1400', 1),
(3126, '1128267430', '2019-04-17 07:42:48', '2500', 1),
(3127, '1152450553', '2019-04-17 07:47:35', '2000', 1),
(3128, '1037587834', '2019-04-22 06:27:02', '4000', 1),
(3129, '1017156424', '2019-04-22 06:27:34', '7000', 1),
(3130, '43605625', '2019-04-22 06:40:46', '8000', 1),
(3131, '1020457057', '2019-04-22 06:43:45', '6400', 1),
(3132, '1017187557', '2019-04-22 06:46:28', '5000', 1),
(3133, '1128267430', '2019-04-22 07:43:11', '14000', 1),
(3134, '1152701919', '2019-04-23 06:11:43', '5500', 1),
(3135, '1017156424', '2019-04-23 06:22:37', '5000', 1),
(3136, '1017125039', '2019-04-23 06:27:18', '12600', 1),
(3137, '32353491', '2019-04-23 06:42:17', '3700', 1),
(3138, '1039049115', '2019-04-23 06:49:07', '4900', 1),
(3139, '43271378', '2019-04-23 07:18:03', '12600', 1),
(3140, '1017187557', '2019-04-23 07:41:34', '17800', 1),
(3141, '1020479554', '2019-04-23 07:38:58', '5900', 1),
(3142, '71267825', '2019-04-24 06:08:13', '5900', 1),
(3143, '1037587834', '2019-04-24 06:11:48', '17800', 1),
(3144, '43265824', '2019-04-24 06:16:59', '7900', 1),
(3145, '1096238261', '2019-04-24 06:18:30', '12600', 1),
(3146, '1152701919', '2019-04-24 06:28:36', '16600', 1),
(3147, '1036598684', '2019-04-24 06:27:34', '12600', 1),
(3148, '1143991147', '2019-04-24 06:31:31', '6000', 1),
(3149, '1020479554', '2019-04-24 06:43:33', '5900', 1),
(3150, '1039049115', '2019-04-24 06:55:26', '3500', 1),
(3151, '43189198', '2019-04-24 06:57:52', '2500', 1),
(3152, '1017156424', '2019-04-24 07:02:26', '6000', 1),
(3153, '1152450553', '2019-04-24 07:06:02', '14600', 1),
(3154, '1039447684', '2019-04-24 07:28:27', '7900', 1),
(3155, '1046913982', '2019-04-24 07:28:37', '5700', 1),
(3156, '1017239142', '2019-04-24 07:40:47', '2000', 1),
(3157, '1020457057', '2019-04-25 06:13:51', '3600', 1),
(3158, '43189198', '2019-04-25 06:17:50', '15100', 1),
(3159, '1020479554', '2019-04-25 06:19:20', '7900', 1),
(3160, '1152450553', '2019-04-25 06:21:58', '2500', 1),
(3161, '1036651097', '2019-04-25 06:24:21', '3500', 1),
(3162, '43605625', '2019-04-25 06:32:09', '17100', 1),
(3163, '1017187557', '2019-04-25 06:35:44', '17700', 1),
(3164, '43288005', '2019-04-25 06:53:21', '12600', 1),
(3165, '1017156424', '2019-04-25 06:55:44', '18200', 1),
(3166, '1017125039', '2019-04-25 07:11:40', '7000', 1),
(3167, '43975208', '2019-04-25 07:20:30', '7000', 1),
(3168, '54253320', '2019-04-25 07:21:32', '5600', 1),
(3169, '98699433', '2019-04-25 07:23:38', '14700', 1),
(3170, '1095791547', '2019-04-25 07:25:18', '7900', 1),
(3171, '1036629003', '2019-04-25 07:31:01', '5300', 1),
(3172, '1020479554', '2019-04-26 06:09:49', '7900', 1),
(3173, '1039049115', '2019-04-26 06:49:17', '6100', 1),
(3174, '43189198', '2019-04-26 07:38:30', '15100', 1),
(3175, '1077453248', '2019-04-26 06:30:58', '5500', 1),
(3176, '1037587834', '2019-04-26 06:34:54', '8000', 1),
(3177, '98772784', '2019-04-26 06:46:23', '3000', 1),
(3178, '1017125039', '2019-04-26 07:18:40', '10000', 1),
(3179, '43288005', '2019-04-26 07:29:36', '12600', 1),
(3180, '1017187557', '2019-04-26 07:29:48', '1200', 1),
(3181, '98699433', '2019-04-26 07:41:22', '23200', 1),
(3182, '32353491', '2019-04-26 07:35:35', '3700', 1),
(3183, '71267825', '2019-04-26 07:38:44', '5900', 1),
(3184, '1046913982', '2019-04-26 07:38:57', '13800', 1),
(3185, '1036598684', '2019-04-26 07:40:20', '4000', 1),
(3186, '1017239142', '2019-04-26 07:40:50', '1400', 1),
(3187, '1036629003', '2019-04-26 07:43:38', '6000', 1),
(3188, '1152450553', '2019-04-26 07:43:43', '14600', 1),
(3189, '1095791547', '2019-04-26 07:43:52', '3500', 1),
(3190, '1037587834', '2019-04-27 16:35:20', '35500', 1),
(3191, '43265824', '2019-04-27 06:04:06', '4700', 1),
(3192, '1039049115', '2019-04-27 06:05:52', '4000', 1),
(3193, '1096238261', '2019-04-27 06:44:00', '15100', 1),
(3194, '1017125039', '2019-04-27 06:07:37', '7800', 1),
(3195, '1020457057', '2019-04-27 06:08:24', '6400', 1),
(3196, '43189198', '2019-04-27 06:11:12', '17500', 1),
(3197, '43605625', '2019-04-27 06:15:53', '6000', 1),
(3198, '1017225857', '2019-04-27 06:19:29', '12600', 1),
(3199, '1152701919', '2019-04-27 06:38:08', '3000', 1),
(3200, '1090523316', '2019-04-27 06:39:04', '12600', 1),
(3201, '1046913982', '2019-04-27 06:57:43', '6300', 1),
(3202, '1036629003', '2019-04-27 07:37:03', '22600', 1),
(3203, '1017187557', '2019-04-27 07:40:26', '4500', 1),
(3204, '43265824', '2019-04-29 06:00:31', '9900', 1),
(3205, '1017156424', '2019-04-29 06:04:25', '5600', 1),
(3206, '43288005', '2019-04-29 06:11:58', '2000', 1),
(3207, '1017187557', '2019-04-29 07:39:50', '17600', 1),
(3208, '1096238261', '2019-04-29 06:14:47', '12600', 1),
(3209, '1095791547', '2019-04-29 06:32:41', '11400', 1),
(3210, '1077453248', '2019-04-29 06:45:28', '4500', 1),
(3211, '1152450553', '2019-04-29 07:29:59', '2000', 1),
(3212, '43596807', '2019-04-29 07:31:47', '13800', 1),
(3213, '32353491', '2019-04-29 07:32:58', '4000', 1),
(3214, '1039049115', '2019-04-29 07:35:40', '4200', 1),
(3215, '1020479554', '2019-04-29 07:36:33', '2000', 1),
(3216, '43265824', '2019-04-30 06:00:46', '3500', 1),
(3217, '1036629003', '2019-04-30 06:05:09', '4000', 1),
(3219, '1152701919', '2019-04-30 06:18:47', '4200', 1),
(3220, '1039049115', '2019-04-30 06:37:33', '16600', 1),
(3221, '1077453248', '2019-04-30 06:58:30', '2000', 1),
(3222, '1020479554', '2019-04-30 07:00:26', '7900', 1),
(3223, '1037587834', '2019-04-30 07:09:44', '5500', 1),
(3224, '43975208', '2019-04-30 07:00:58', '7600', 1),
(3225, '1152450553', '2019-04-30 07:03:52', '2000', 1),
(3226, '54253320', '2019-04-30 07:13:06', '10500', 1),
(3227, '1017239142', '2019-04-30 07:19:37', '12600', 1),
(3228, '32353491', '2019-04-30 07:26:58', '9100', 1),
(3229, '43161988', '2019-04-30 07:27:25', '6000', 1),
(3230, '43288005', '2019-04-30 07:29:04', '2000', 1),
(3231, '1095791547', '2019-05-02 06:25:18', '11400', 1),
(3232, '23917651', '2019-05-02 06:33:19', '1400', 1),
(3233, '1020479554', '2019-05-02 06:33:22', '12700', 1),
(3234, '43605625', '2019-05-02 06:35:06', '7000', 1),
(3235, '1037587834', '2019-05-02 06:35:45', '1500', 1),
(3236, '1001545147', '2019-05-02 06:37:53', '2000', 1),
(3237, '1017125039', '2019-05-02 06:43:51', '2500', 1),
(3238, '43271378', '2019-05-02 07:08:40', '17600', 1),
(3239, '1152450553', '2019-05-02 07:14:36', '12600', 1),
(3240, '1036598684', '2019-05-02 07:20:01', '2000', 1),
(3241, '1039447684', '2019-05-02 07:26:06', '12600', 1),
(3242, '1017239142', '2019-05-02 07:30:22', '1400', 1),
(3243, '1128267430', '2019-05-02 07:38:19', '12600', 1),
(3244, '955297213061995', '2019-05-02 07:40:57', '7900', 1),
(3245, '43596807', '2019-05-02 07:44:01', '1200', 1),
(3246, '15489896', '2019-05-03 06:05:17', '5200', 1),
(3247, '43265824', '2019-05-03 06:08:58', '5500', 1),
(3248, '1036651097', '2019-05-03 06:09:11', '3900', 1),
(3249, '1096238261', '2019-05-03 06:15:43', '6800', 1),
(3250, '15489917', '2019-05-03 06:41:46', '12600', 1),
(3251, '98772784', '2019-05-03 06:43:57', '2800', 1),
(3252, '1077453248', '2019-05-03 06:58:47', '2800', 1),
(3253, '1095791547', '2019-05-03 06:58:49', '11400', 1),
(3254, '1020479554', '2019-05-03 07:01:33', '2000', 1),
(3255, '43288005', '2019-05-03 07:15:17', '5500', 1),
(3256, '1037587834', '2019-05-03 07:15:32', '16600', 1),
(3257, '1001545147', '2019-05-03 07:20:38', '1000', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permiso`
--

CREATE TABLE `permiso` (
  `idPermiso` int(11) NOT NULL,
  `documento` varchar(20) DEFAULT NULL,
  `fecha_solicitud` datetime NOT NULL,
  `fecha_permiso` date NOT NULL,
  `idConcepto` tinyint(4) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `desde` time NOT NULL,
  `hasta` time DEFAULT NULL,
  `numero_horas` varchar(10) DEFAULT NULL,
  `estado` tinyint(1) NOT NULL,
  `idHorario_permiso` tinyint(4) NOT NULL,
  `idUsuario` tinyint(2) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `permiso`
--

INSERT INTO `permiso` (`idPermiso`, `documento`, `fecha_solicitud`, `fecha_permiso`, `idConcepto`, `descripcion`, `desde`, `hasta`, `numero_horas`, `estado`, `idHorario_permiso`, `idUsuario`) VALUES
(24, '1216727816', '2018-11-06 08:10:13', '2018-11-06', 1, '', '12:04:44', '12:15:37', '00:10:53', 3, 3, 21),
(25, '43265824', '2018-11-16 16:30:03', '2018-11-21', 3, '', '12:15:00', '16:30:00', '04:12:01', 3, 1, 24),
(26, '43265824', '2018-11-26 10:06:10', '2018-11-27', 3, '', '15:00:00', NULL, NULL, 0, 1, 0),
(27, '1216727816', '2019-03-12 09:05:05', '2019-03-12', 1, '', '09:09:40', '09:27:55', '00:18:15', 3, 3, 7),
(31, '1216727816', '2019-05-07 15:05:15', '2019-05-07', 1, '', '06:00:00', '15:05:42', '09:05:42', 3, 2, 24);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal`
--

CREATE TABLE `personal` (
  `idPersonal` smallint(6) NOT NULL,
  `direccion` varchar(70) NOT NULL,
  `barrio` varchar(20) NOT NULL,
  `comuna` varchar(2) NOT NULL,
  `idMunicipio` tinyint(4) NOT NULL,
  `estrato` varchar(1) NOT NULL,
  `caso_emergencia` varchar(50) DEFAULT NULL,
  `tel` varchar(10) DEFAULT NULL,
  `parentezco` varchar(20) DEFAULT NULL,
  `idTipo_vivienda` tinyint(4) NOT NULL,
  `altura` varchar(4) NOT NULL DEFAULT '0',
  `peso` varchar(3) NOT NULL DEFAULT '0',
  `otraActividad` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `personal`
--

INSERT INTO `personal` (`idPersonal`, `direccion`, `barrio`, `comuna`, `idMunicipio`, `estrato`, `caso_emergencia`, `tel`, `parentezco`, `idTipo_vivienda`, `altura`, `peso`, `otraActividad`) VALUES
(1, 'CL;64D;#106;207;IN;301', 'Robledo', '7', 1, '3', 'Teresita Villa', '3217290228', '1', 1, '1,75', '60', ''),
(2, 'CR;31;#69;A10;-;', 'Manrique Oriental', '3', 1, '2', 'Yadira Galeano', '3105927508', '3', 2, '1,56', '55', ''),
(3, 'CR;78A;#25;B22;-;', 'Paris', '1', 2, '1', 'Martha Madrid', '3106596945', '1', 1, '1,60', '50', ''),
(4, 'DG;55;#46;73;-;', 'Niquia', '', 2, '1', 'Maria Leticia Loaiza', '4643488', '6', 1, '1,56', '75', ''),
(5, 'CL;44;#36;12;IN;201', 'Salvador', '9', 1, '3', 'Ana Milena Gallego Perez ', '3117909709', '3', 3, '1,87', '65', 'Realizar trekking y touirng'),
(6, 'CR;67A;70;41', 'Pedregal', '', 3, '2', 'Idalides Teran', '3012799471', '1', 2, '1,68', '62', ''),
(7, '-;#6AB;30;;-;', 'Barrio de jesus', '9', 1, '3', 'Danilo Ramirez', '3116554695', '4', 1, '1,63', '57', ''),
(8, 'CR;55;CL95;A15;IN;', 'Aranjuez', '', 1, '1', 'Cristian cifuentes', '3012346998', '9', 3, '1,68', '68', ''),
(9, 'CR;18D;#63;20;-;', 'Enciso', '8', 1, '1', 'Sol Maria Morales', '3184889397', '1', 2, '1,48', '50', 'Trotar'),
(10, 'CL;65;#52;D32;-;', 'Ferrara ', '', 3, '2', 'Vanessa Garcia', '6004002', '9', 3, '1,65', '71', 'Estudiar'),
(11, 'CR;53;#;44-44;-;', 'Itagui', '', 3, '2', 'Jorge Ospina', '3017299090', '4', 3, '1,60', '66', ''),
(12, 'CL;70A;#52;D106;-;', 'Guayabo', '4', 3, '2', 'Lucia Molina', '2812730', '6', 2, '1,67', '68', 'Deporte'),
(13, 'CR;49;#126;SUR58;AP;302', 'Olaya Herrera', '', 1, '3', 'Marleny Del Socorro Restrepo Muños ', '3015640274', '1', 1, '1,57', '59', 'Caminar'),
(14, 'CL;49;#17C;80;-;', 'Buenos aires', '9', 1, '3', 'Esteisy Castaño', '3174545696', '4', 3, '1,80', '102', 'Caminar'),
(15, 'CL;18;#111;A100;', 'Belen Alta Vista', '95', 1, '2', 'Margarita Londoño', '3122112625', '9', 3, '1,69', '70', 'Deporte '),
(16, 'CR;78;#20A;12;IN;', 'Paris ', '', 2, '2', 'Duvan pamplona', '3194615332', '4', 3, '1.57', '58', 'Escuchar musica'),
(17, 'CR;48;#88;40;IN;', 'San Fernando', '15', 1, '3', 'Martha Quirama', '6014838', '1', 3, '1,66', '72', ''),
(18, 'CL;49D-SUR;#40A;78', 'Envigado', '', 4, '4', 'Luis garcia', '3167519962', '4', 1, '1,56', '55', ''),
(19, 'CR;18;#16;31;', 'Hipodromo', '', 11, '3', 'Diana carmona', '3104416165', '1', 3, '1,75', '80', ''),
(20, 'CR;28;#68A;81;-;', 'Manrique', '3', 1, '2', 'Andres Tuberquia', '3193082631', '4', 1, '1.61', '75', 'SI'),
(21, 'CR;78;#21A;20;IN;', 'Belen San bernardo', '16', 1, '3', 'Angie Arcos', '3148020605', '4', 3, '1,80', '73', 'Ejercicio, Leer'),
(22, 'CL;12A;#11;20;-;', 'San Fernando', '15', 1, '2', 'Luis atuesto', '3147865721', '2', 3, '1,78', '64', ''),
(23, 'CR;30;#46;28;-;', 'Buenos Aires', '', 1, '4', 'Adriana lopez', '3177180351', '3', 3, '1,70', '78', ''),
(24, 'CR;58-SUR;#77;41;-;', 'San Pablo', '', 3, '3', 'Jhoana villazon', '3203429750', '3', 3, '1,60', '59', ''),
(25, 'CL;18;#112;30;-;', 'Belen Alta Vista', '16', 1, '2', 'Vanesa reyes', '3122300165', '4', 1, '1.92', '95', ''),
(26, 'CL;32B;65CC;15;AP;301', 'Belen Fatima', '16', 1, '4', 'Dorian Yepes', '3013913731', '4', 3, '1,72', '84', ''),
(27, 'CR;50;D;#123A;-;', 'Santa Cruz ', '2', 1, '2', 'Deyanira osorio', '2375423', '9', 1, '1,75', '55', ''),
(28, 'CR;37;#81;48;IN;302', 'Manrique ', '3', 1, '2', 'Mariela Beltran', '3015049447', '1', 3, '1,60', '62', 'Caminar'),
(29, 'CL;94A;#70GC;60;IN;9901', 'Robledo Santa Maria', '7', 1, '3', 'Gloria luz alavarez', '3113214156', '1', 1, '1,71', '61', ''),
(30, 'CL;47B;#89A;19;-;', 'Santa Lucia ', '12', 1, '3', 'Maria beatriz Cardona', '3053190837', '1', 3, '1,63', '67', ''),
(31, 'CL;97-86;#104;;-;', 'Picacho', '6', 1, '1', 'Katerine Mosquera', '4772720', '9', 1, '1,71', '64', ''),
(32, 'CR;76;#112;50', 'Santander ', '6', 1, '2', 'Graciela rivera', '3045768737', '6', 1, '1,70', '60', ''),
(33, 'CR;50D;#93;58;-;', 'Aranjuez', '4', 1, '3', 'Martha Corral Jaramillo', '3002401009', '1', 3, '1,74', '64', ''),
(34, 'CL;48CC;120E;117;IN;301', 'San Javier la Loma', '60', 1, '2', 'Silvia Paniaguas', '3052912236', '1', 3, '1,75', '70', ''),
(35, 'CR;45D;#63;43;-;', 'Villa Hermosa', '8', 1, '3', 'Nestor cosio', '3116404070', '9', 3, '1,69', '82', ''),
(36, 'CL;25;#73;53;IN;', 'Belen San bernardo', '16', 1, '3', 'Alicia rojas', '3147988574', '4', 1, '1.7', '66', ''),
(37, 'CR;52;#46;31;-;', 'Central', '', 2, '3', 'Nathalia restrepo', '3122112041', '4', 1, '1,73', '76', 'Diseñar tarjetas'),
(38, 'CR;51A;#27B;87;-;', 'Cabañas', '', 2, '3', 'Carlos giraldo', '3116355854', '9', 2, '1,54', '65', ''),
(39, 'CL;76-SUR;#50C;44;-;', 'Itagui', '', 3, '3', 'Gudiela ortiz', '4873584', '1', 3, '1,54', '65', 'Ir a eucaristia,hacer oficios'),
(40, 'DG;59;#38-90;MANZANA-1;BD;19-APTO-305', 'Niquia', '', 2, '3', 'Jose reinel rueda', '3106220983', '4', 3, '1,68', '79', ''),
(41, 'CL;29A;#50;IN120;-;', 'Cabañas', '', 2, '2', 'Noelia Montes ', '4510973', '9', 3, '1,54', '59', ''),
(42, '-;#48A;10;;-;', 'Campo valdes', '4', 1, '3', 'Agdemago palacio', '3117151658', '2', 1, '1,54', '79', ''),
(43, 'CL;64A;#58;12;-;', 'Calatrava', '', 3, '3', 'Aida Maria Ossa', '3207898554', '3', 3, '1,65', '61', 'Deporte'),
(44, 'CR;43;#107;B52;-;', 'Popular 1 ', '2', 1, '2', 'Santiago Uribe morales', '3122493320', '7', 1, '1,55', '60', ''),
(45, 'CL;34C;#88;B66;AP;1203', 'Santa Teresita ', '12', 1, '5', 'Juan gonzalo vargas', '3015660317', '4', 3, '1.67', '75', ''),
(46, 'CR;41A;#86;A54;-;', 'Manrique', '3', 1, '2', 'Norma sanchez', '3182590891', '3', 3, '1,60', '60', ''),
(47, 'CR;52;#70;09-PISO-4;-;', 'Santa Maria', '', 3, '3', 'Jaime Agurirre', '3128584267', '4', 2, '1,65', '58', 'Caminar'),
(48, 'CL;71-SUR;#31;16;IN;', 'San Isidro', '', 9, '2', 'Edilma Villegas', '3137159874', '1', 1, '1,60', '60', 'N/A'),
(49, 'CR;42A;#81;16', 'Manrique', '2', 1, '2', 'Yesica blandon', '3005216457', '7', 3, '1,65', '72', ''),
(50, 'CL;61;#38;43;-;', 'Boston', '8', 1, '3', 'Edison rey', '3504062552', '4', 1, '1,65', '75', ''),
(51, 'CR;89;#92C;119;-;', 'Robledo', '7', 1, '3', 'Yilmar valoyes', '3103828191', '3', 1, '1.67', '57', ''),
(52, 'CL;39;#89;09;IN;', 'Santa Monica ', '12', 1, '4', 'Maria celina estrada', '3206652235', '1', 3, '1,70', '60', ''),
(53, 'CL;9A;SUR;#79A;-;', 'Rodeo Alto', '', 1, '3', 'Ana maria cadavid', '3017456565', '4', 3, '1,72', '69', ''),
(54, 'CR;43;A;#;-;SUR', 'Sabaneta ', '', 9, '', 'Maria andrea paez', '3017786185', '4', 3, '1,66', '66', ''),
(55, 'CL;96SUR;#50;43;-;', 'Inmaculada', '', 7, '2', 'Yamile Agudelo', '3104989842', '4', 1, '1,72', '80', 'Deejey'),
(56, 'CL;68A;#30;55;-;', 'Manrique', '8', 1, '2', 'Viviana Cartagena', '3135890674', '4', 2, '1,68', '54', 'Ver TV, Estudiar la biblia'),
(57, 'CR;55;#30B;47;IN;', 'La Florida', '3', 2, '3', 'Carolina Buitrago', '3002475597', '3', 3, '1,72', '94', ''),
(58, 'CR;43A;#39A;105;-;', 'San diego', '10', 1, '2', 'Yuliet echeverri', '3217476014', '4', 3, '1,80', '70', ''),
(59, 'CL;4;#78B;93;CA;piso 1', 'Belen Rincon', '16', 1, '3', 'Beatriz Palacio', '3165734068', '1', 2, '1,75', '80', 'Jugar futbol'),
(60, 'CR;37;#81;64;IN;301', 'Manrique Santa Ines ', '3', 1, '2', 'Margarita Beltran', '3504182192', '6', 2, '1,55', '69', 'Musica'),
(61, 'CR;44A;#93;98;IN;112', 'Manrique Berlin', '3', 1, '2', 'Richard alejandro arboleda', '11110000', '3', 2, '1,73', '69', ''),
(62, 'CR;72A;#97;62;-;', 'Castilla', '5', 1, '3', 'Jose luis rivera', '3043776482', '3', 3, '1,70', '70', ''),
(63, 'CR;81A;#44-SUR;09;', 'Los Salinas ', '80', 1, '3', 'MARINA RESTREPO', '3116254273', '1', 3, '1.54', '85', ''),
(64, 'CL;96BB;#81;56;IN;301', 'Robledo', '6', 1, '2', 'Adelis Chavarria ', '3207185396', '1', 3, '1,55', '48', 'Deporte'),
(65, 'CR;44;#74;31;-;', 'Manrique', '3', 1, '2', 'Flor Vargas', '3004728745', '1', 2, '1,60', '70', 'Caminar'),
(66, 'CR;41B;#21;E92;', 'Zamora Sta Rita ', '', 1, '2', 'Maria Edilia Cortes ', '3117714890', '6', 3, '1,51', '57', 'Bailar'),
(67, 'CR;26CC;#38;A41;-;', 'Pablo Escobar ', '9', 1, '2', 'Luz Marina Taborda ', '3878078', '1', 2, '1,64', '85', ''),
(68, 'CL;44AA;#7B;21;-;', 'Caunces', '9', 1, '2', 'Esther camacho', '3147704315', '1', 1, '1,74', '60', ''),
(69, 'DG;55;#46;73;-;', 'Niquia', '', 2, '1', 'Maria Leticia Loaiza', '4643488', '6', 2, '1,60', '60', 'escuachar Musica- Deporte'),
(70, 'CR;67A;#99;A25;-;', 'Castilla', '5', 1, '3', 'Erika salazar', '3115896514', '1', 1, '1,53', '62', ''),
(71, 'TV;;;;-;', 'San Gabriel', '', 3, '2', 'Yuddy Acevedo', '3136280504', '1', 3, '1,57', '85', 'Caminar'),
(72, 'CL;53A;#51;13', 'Villa Paula ', '', 3, '3', 'Adriana Patricia Pulgarin', '3046273888', '4', 3, '1,77', '61', ''),
(73, 'CR;53C-SUR;#40;B106;-;', 'Envigado', '', 4, '3', 'Edwin Soto', '3136073143', '4', 3, '1,66', '68', 'ESTUDIAR'),
(74, 'CR;53;#69;19;-;', 'El Guayabo', '', 3, '2', 'Silvia caicedo', '3017448407', '1', 1, '1,55', '55', ''),
(75, 'CL;101;#50C;117;IN;', 'Santa Cruz la Rosa ', '', 1, '2', 'Denis Jaramillo', '5363096', '3', 3, '1,59', '51', 'Caminar'),
(76, 'CR;46;#41;16;-;', 'Colon', '', 1, '3', 'Angie quintana', '3137333889', '4', 3, '1.7', '71', ''),
(77, 'CL;21;#74;68;AP;301', 'Belen San Bernardo', '16', 1, '3', 'Camilo rios', '3014347713', '9', 2, '1,70', '70', ''),
(78, 'CR;31;#69A;32;IN;303', 'Manrique', '3', 1, '2', 'Lucelly Gaviria', '3207579218', '1', 2, '1,56', '61', 'Picsina'),
(79, 'CL;66;#39;64;-;', 'Villa hermosa', '8', 1, '3', 'Luz Stella Jimenez', '3017105657', '1', 3, '1,60', '52', 'Cine'),
(80, 'CR;25BB;55;08;AP;4', 'Caicedo Las Perlas ', '8', 1, '2', 'Luz Marina Zapata', '3103921985', '1', 1, '1,55', '68', 'Caminar'),
(81, 'CL;78;#58;99', 'Bello', '', 2, '2', 'Luz Dari Durango', '2650704', '3', 1, '1,64', '56', 'ESTUDIAR'),
(82, 'CL;20F;#62;A35;-;', 'Jose Antonio Galan', '6', 2, '2', 'Janeth Rodelo', '4615008', '1', 2, '1,63', '80', 'Sale a Puebliar'),
(83, 'CR;18;#33;64;-;', 'Buenos Aires', '9', 1, '3', 'Catalina ramos', '3187350691', '3', 3, '1,80', '65', ''),
(84, 'CL;39S;#25;C89;', 'Camino Verde', '', 4, '4', 'Martha elena Calderon', '3148392564', '1', 1, '1,78', '78', ''),
(85, 'CR;65A;#32;A09;-;', 'Fatima', '16', 1, '3', 'Luz amparo morales', '3117039815', '1', 1, '1,74', '64', ''),
(86, 'CR;80A;#32D;2;IN;', 'Laureles Nogal', '16', 1, '5', 'Patricia gomez', '3122972838', '1', 2, '1,72', '52', 'GYM, BAILE, FOTOGRAFIA'),
(87, 'CR;74;#30B;50', 'Belen Rosales ', '16', 1, '5', 'Alejandra arvoleda', '3008126925', '3', 1, '1,63', '57', ''),
(88, 'CL;29;#73;32;AP;201', 'Belen Granada', '16', 1, '3', 'Diana mercado', '3008186110', '4', 2, '1,74', '94', ''),
(89, 'CL;41AA;SUR#38;44', 'El dorado', '', 4, '4', 'Mirian pineda pineda', '3152727488', '1', 1, '1,71', '58', ''),
(90, 'CR;57;#36;290;AP;324', 'Cabañas ', '', 2, '4', 'Paula andrrea lara', '3174536404', '4', 1, '1,78', '110', ''),
(91, 'CR;16B;;34;IN;12', 'Buenos Aires', '9', 1, '4', 'Diego Hernandez', '3157086933', '3', 3, '1.7', '74', ''),
(92, 'CR;55;12SUR;;9;-;', 'Guayabal', '', 1, '', 'Alejandro Roldán', '3016505663', '3', 3, '1.56', '54', ''),
(93, 'CL;43;39;77;-;', 'Boston', '10', 1, '3', 'Diana Bedoya', '3003864349', '3', 3, '1.7', '68', ''),
(94, 'CR;64;;63;-;AP', 'Bloque 20 Carlos E. ', '11', 1, '', 'Andres Felipe Alzate', '3185483525', '4', 3, '1.68', '73', ''),
(95, 'CL;34;86A;37;AP;306', 'Laureles Almeria', '12', 1, '', 'Sandra Maria Perez', '5842847', '1', 1, '1.53', '55', ''),
(96, 'DG;30;34;A;IN;', 'MANUEL URIBE ENVIGAD', '', 4, '2', 'Blanca Narvaez ', '3225866208', '1', 2, '1.8', '68', 'BAILE'),
(97, 'CL;18;A;SUR;IN;22', 'Poblado', '14', 1, '4', 'Ana Lucia Valencia', '3146323754', '4', 1, '1.78', '69', ''),
(98, 'CR;37;42;A;;58;AP;704', 'La independencia', '', 3, '6', 'Diana Patricia Arias Ospina', '372 9315', '1', 3, '1.6', '67', ''),
(99, 'CL;7;83;31;AP;323', 'los Bernal', '', 1, '4', 'Lina Cano', '3003641364', '4', 1, '1.75', '70', 'ejercicio'),
(100, 'CR;4;72;19;AP;203', 'Laureles', '11', 1, '3', 'Gloria Maria Múnera Velásquez', '3006202340', '4', 3, '1.9', '75', ''),
(101, 'CR;73;CALLE;37;SUR;-;49', 'San Antonio de Prado', '', 1, '', 'Franco Elias Espinal', '3113838288', '2', 1, '1.65', '69', ''),
(102, 'CL;34;;34C;-;165', 'Quintas del Salvador', '9', 1, '3', 'Luz Marina Gomez Ossa', '314 641411', '1', 3, '1.56', '72', ''),
(103, '-;;;;-;', 'Verreda los Gómez', '0', 3, '', 'Ester Nomine Pulgarin', '3002960801', '1', 2, '1.88', '72', 'Viajar en moto'),
(104, 'CR;47;A;69;-;IN', 'Campo Valdes', '', 1, '', 'Emmanuel Oliveros', '3046484748', '4', 3, '1.65', '48', ''),
(105, 'CR;79AA;1A;SUR;-;AP', 'Mota', '', 1, '3', 'Alberto Cortés', '3124822269', '6', 3, '1.57', '57', ''),
(106, '-;;;;-;', 'La Tablaza ', '', 7, '2', 'Carloina David', '3217616087', '4', 3, '1.8', '65', 'video juegos '),
(107, 'CL;7;83;31;AP;423', 'La Mota', '', 1, '4', 'Fernando Vélez', '3006171694', '4', 1, '1.63', '63', ''),
(108, 'CL;7;83;31;AP;423', 'La Mota', '', 1, '4', 'Viviana Echavarria ', '3006171694', '4', 1, '1.63', '64', ''),
(109, 'CL;77C;92;14;CA;PISO', 'Robledo Aures 1', '7', 1, '', 'Luis Alberto Alzate Ceballos', '3044201605', '4', 3, '1.68', '65', ''),
(110, 'CL;56;EF;18A;IN;29', 'Enciso', '8', 1, '1', 'Omaira Sucerquia', '3053046978', '1', 1, '1.74', '80', ''),
(111, 'CL;7;83;31;-;APTO;322', 'LOMA LOS BERNAL', '16', 1, '4', 'JULIAN PORRAS', '3203408414', '4', 1, '1.54', '49', ''),
(112, 'CL;30A;76;43;AP;201', 'Belen Rosales', '', 1, '4', 'Batriz Eugenia Escobar', '3007097227', '4', 3, '1.67', '74', 'bicicleta'),
(113, '-;;;;-;', 'Santa Elena', '', 1, '2', 'Gloria Selene Bernal', '5381802', '1', 1, '1.84', '59', ''),
(114, 'CL;57A;31;33;AP;304', 'Boston', '8', 1, '2', 'Sirley Fonnegra', '3004753774', '3', 3, '1.75', '65', ''),
(115, 'CL;37a;84A;24;CA;2 piso', 'Simon Bolivar la Ame', '12', 1, '5', 'Miguel Antonio Escobar ', '3127593024', '2', 1, '1.50', '63', ''),
(116, 'CR;45a;85;141;AP;3 piso', 'Las Esmeraldas', '', 1, '3', 'Maira Valencia', '3138704597', '9', 3, '1.62', '757', 'Escribe ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas_vive`
--

CREATE TABLE `personas_vive` (
  `idPersonas_vive` int(11) NOT NULL,
  `nombreC` varchar(50) NOT NULL,
  `idParentezco` tinyint(4) NOT NULL,
  `celular` varchar(10) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `vive_empleado` tinyint(1) DEFAULT NULL,
  `idPersonal` smallint(6) NOT NULL,
  `cantidad` varchar(2) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `personas_vive`
--

INSERT INTO `personas_vive` (`idPersonas_vive`, `nombreC`, `idParentezco`, `celular`, `fecha_nacimiento`, `vive_empleado`, `idPersonal`, `cantidad`) VALUES
(1, '', 1, '', '0000-00-00', 0, 1, '1'),
(2, '', 6, '', '0000-00-00', 0, 2, '1'),
(3, '', 1, '', '0000-00-00', 0, 3, '1'),
(4, '', 6, '', '0000-00-00', 0, 3, '1'),
(5, '', 1, '', '0000-00-00', 0, 4, '1'),
(6, '', 6, '', '0000-00-00', 0, 4, '2'),
(7, 'Danilo Ramirez      ', 3, '      0000', '0000-00-00', 0, 7, '1'),
(8, '', 1, '', '0000-00-00', 0, 9, '1'),
(9, '', 2, '', '0000-00-00', 0, 9, '1'),
(10, 'Sergio Gonzalez      ', 3, '      0000', '0000-00-00', 0, 9, '1'),
(11, '', 6, '', '0000-00-00', 0, 9, '1'),
(12, 'Marisol Gonzalez', 8, '', '2011-07-15', 1, 9, '1'),
(13, 'Susana Posada', 8, '', '2004-11-18', 1, 10, '1'),
(14, 'Eduardo Betancur', 8, '', '2012-11-03', 1, 10, '1'),
(15, '', 1, '', '0000-00-00', 0, 11, '1'),
(16, 'Mariana ospina', 8, '', '2007-07-11', 1, 11, '1'),
(17, '', 1, '', '0000-00-00', 0, 12, '1'),
(18, '', 2, '', '0000-00-00', 0, 12, '1'),
(19, '', 5, '', '0000-00-00', 0, 12, '1'),
(20, '', 6, '', '0000-00-00', 0, 12, '1'),
(21, '', 1, '', '0000-00-00', 0, 13, '1'),
(22, '', 2, '', '0000-00-00', 0, 13, '1'),
(23, 'Samuel agudelo', 8, '', '2005-08-03', 1, 13, '1'),
(24, 'Samantha ospina', 8, '', '2012-07-24', 1, 13, '1'),
(25, '', 1, '', '0000-00-00', 0, 15, '1'),
(26, '', 2, '', '0000-00-00', 0, 15, '1'),
(27, '', 7, '', '0000-00-00', 0, 15, '1'),
(28, '', 1, '', '0000-00-00', 0, 16, '1'),
(29, '', 2, '', '0000-00-00', 0, 16, '1'),
(30, '', 6, '', '0000-00-00', 0, 16, '1'),
(31, '', 1, '', '0000-00-00', 0, 17, '1'),
(32, '', 4, '', '0000-00-00', 0, 17, '1'),
(33, '', 6, '', '0000-00-00', 0, 17, '1'),
(34, 'Mariangel quirama', 8, '', '2016-10-04', 1, 17, '1'),
(35, 'Luis garcia      ', 3, '      0000', '0000-00-00', 0, 18, '1'),
(36, 'Maria antonia garcia', 8, '', '2014-04-12', 1, 18, '1'),
(37, '', 1, '', '0000-00-00', 0, 19, '1'),
(38, '', 2, '', '0000-00-00', 0, 19, '1'),
(39, '', 5, '', '0000-00-00', 0, 19, '2'),
(40, '', 6, '', '0000-00-00', 0, 19, '1'),
(41, '', 1, '', '0000-00-00', 0, 20, '1'),
(42, 'ANDRES TUBERQUIA      ', 3, '      0000', '0000-00-00', 0, 20, '1'),
(43, '', 7, '', '0000-00-00', 0, 20, '1'),
(44, 'ALEJANDRO TUBERQUIA', 8, '', '2017-12-22', 1, 20, '1'),
(45, 'Angie Arcos      ', 3, '      0000', '0000-00-00', 0, 21, '1'),
(46, '', 7, '', '0000-00-00', 0, 22, '4'),
(47, '', 4, '', '0000-00-00', 0, 23, '2'),
(48, '', 5, '', '0000-00-00', 0, 23, '14'),
(49, '', 6, '', '0000-00-00', 0, 23, '3'),
(50, '', 7, '', '0000-00-00', 0, 23, '20'),
(51, '', 7, '', '0000-00-00', 0, 24, '1'),
(52, 'Vanesa reyes      ', 3, '      0000', '0000-00-00', 0, 25, '1'),
(53, 'Miguel angel velez', 8, '', '2011-09-01', 1, 25, '1'),
(54, 'Maximiliano velez', 8, '', '2016-01-18', 1, 25, '1'),
(55, 'Dorian Yepes      ', 3, '      0000', '0000-00-00', 0, 26, '1'),
(56, '', 1, '', '0000-00-00', 0, 27, '1'),
(57, '', 5, '', '0000-00-00', 0, 27, '6'),
(58, '', 6, '', '0000-00-00', 0, 27, '2'),
(59, '', 1, '', '0000-00-00', 0, 28, '1'),
(60, '', 6, '', '0000-00-00', 0, 28, '1'),
(61, '', 1, '', '0000-00-00', 0, 29, '1'),
(62, '', 6, '', '0000-00-00', 0, 29, '2'),
(63, '', 1, '', '0000-00-00', 0, 30, '1'),
(64, '', 1, '', '0000-00-00', 0, 31, '1'),
(65, '', 7, '', '0000-00-00', 0, 31, '1'),
(66, '', 1, '', '0000-00-00', 0, 32, '1'),
(67, '', 6, '', '0000-00-00', 0, 32, '2'),
(68, '', 1, '', '0000-00-00', 0, 33, '1'),
(69, '', 2, '', '0000-00-00', 0, 33, '1'),
(70, '', 6, '', '0000-00-00', 0, 33, '3'),
(71, '', 7, '', '0000-00-00', 0, 33, '2'),
(72, '', 1, '', '0000-00-00', 0, 34, '1'),
(73, '', 2, '', '0000-00-00', 0, 34, '1'),
(74, '', 5, '', '0000-00-00', 0, 35, '2'),
(75, '', 6, '', '0000-00-00', 0, 35, '9'),
(76, 'Alicia rojas      ', 3, '      0000', '0000-00-00', 0, 36, '1'),
(77, '', 7, '', '0000-00-00', 0, 36, '4'),
(78, 'Nathalia restrpo      ', 3, '      0000', '0000-00-00', 0, 37, '1'),
(79, 'Alejandro tobon', 8, '', '2004-12-28', 1, 37, '1'),
(80, '', 1, '', '0000-00-00', 0, 38, '1'),
(81, '', 6, '', '0000-00-00', 0, 38, '1'),
(82, '', 7, '', '0000-00-00', 0, 38, '1'),
(83, 'Manuela giraldo', 8, '', '2006-05-05', 1, 38, '1'),
(84, '', 1, '', '0000-00-00', 0, 39, '1'),
(85, 'Horacio gomez      ', 3, '      0000', '0000-00-00', 0, 39, '1'),
(86, 'Susana castaño', 8, '', '2011-08-06', 0, 39, '1'),
(87, 'Jose reinel rueda      ', 3, '      0000', '0000-00-00', 0, 40, '1'),
(88, 'Maria jose rueda sanchez', 8, '', '2007-02-16', 1, 40, '1'),
(89, 'dahiara yiced mazo garcia', 8, '', '2004-08-16', 1, 41, '1'),
(90, 'Felipe urrego', 8, '', '2007-01-13', 1, 41, '1'),
(91, 'Mariana castañeda', 8, '', '2003-09-03', 1, 42, '1'),
(92, 'Sebastian giraldo', 8, '', '1998-06-08', 1, 42, '1'),
(93, 'Santiago uribe', 8, '', '1996-02-26', 1, 44, '1'),
(94, 'Julian uribe', 8, '', '2003-11-03', 1, 44, '1'),
(95, 'Juan gonzalo vargas      ', 3, '      0000', '0000-00-00', 0, 45, '1'),
(96, 'Maria clara', 8, '', '2003-01-20', 1, 45, '1'),
(97, 'maria paulina vargas', 8, '', '2004-10-12', 0, 45, '1'),
(98, 'Juan pablo vargas', 8, '', '2005-11-23', 1, 45, '1'),
(99, 'Ana sofia vargas', 8, '', '2012-05-04', 0, 45, '1'),
(100, '', 7, '', '0000-00-00', 0, 46, '3'),
(101, 'Stefany rios', 8, '', '1993-03-08', 1, 46, '1'),
(102, '', 1, '', '0000-00-00', 0, 47, '1'),
(103, '', 6, '', '0000-00-00', 0, 47, '1'),
(104, 'Santiago Castrillon', 8, '', '2004-12-02', 1, 48, '1'),
(105, 'Yesica blandon', 8, '', '2000-10-17', 1, 49, '1'),
(106, 'Edison rey      ', 3, '      0000', '0000-00-00', 0, 50, '1'),
(107, '', 7, '', '0000-00-00', 0, 51, '1'),
(108, 'Liyibeth mendoza', 8, '', '1983-03-23', 1, 51, '1'),
(109, '', 1, '', '0000-00-00', 0, 52, '1'),
(110, 'Ana maria cadavid      ', 3, '      0000', '0000-00-00', 0, 53, '1'),
(111, 'Emiliana montoya', 8, '', '2016-02-29', 1, 53, '1'),
(112, 'Maria andrea paez      ', 3, '      0000', '0000-00-00', 0, 54, '1'),
(113, '', 6, '', '0000-00-00', 0, 55, '2'),
(114, 'Mariana montoya', 8, '', '2009-11-05', 1, 55, '1'),
(115, 'Viviana Cartagena      ', 3, '      0000', '0000-00-00', 0, 56, '1'),
(116, '', 7, '', '0000-00-00', 0, 57, '2'),
(117, '', 1, '', '0000-00-00', 0, 58, '1'),
(118, '', 2, '', '0000-00-00', 0, 58, '1'),
(119, '', 5, '', '0000-00-00', 0, 58, '1'),
(120, '', 1, '', '0000-00-00', 0, 59, '1'),
(121, 'Fernanda Tangarife', 8, '', '2017-02-14', 1, 59, '1'),
(122, 'Manuela Tangarife', 8, '', '2006-02-25', 1, 59, '1'),
(123, 'Rafael Mesa      ', 3, '      0000', '0000-00-00', 0, 60, '1'),
(124, 'Maximiliano Mesa ', 8, '', '2016-04-04', 1, 60, '1'),
(125, 'Maryory Mesa', 8, '', '2008-05-05', 1, 60, '1'),
(126, '', 6, '', '0000-00-00', 0, 61, '1'),
(127, '', 1, '', '0000-00-00', 0, 62, '1'),
(128, '', 2, '', '0000-00-00', 0, 62, '1'),
(129, '', 6, '', '0000-00-00', 0, 62, '2'),
(130, '', 1, '', '0000-00-00', 0, 64, '1'),
(131, '', 6, '', '0000-00-00', 0, 64, '1'),
(132, '', 1, '', '0000-00-00', 0, 65, '1'),
(133, '', 2, '', '0000-00-00', 0, 65, '1'),
(134, 'Matias Sanchez', 8, '', '2012-09-13', 1, 65, '1'),
(135, '', 1, '', '0000-00-00', 0, 66, '1'),
(136, 'Santiago Alzate Arenas', 8, '', '2014-06-14', 1, 66, '1'),
(137, 'Paulina Rivera', 8, '', '2006-12-29', 0, 66, '1'),
(138, '', 1, '', '0000-00-00', 0, 67, '1'),
(139, '', 6, '', '0000-00-00', 0, 67, '2'),
(140, '', 1, '', '0000-00-00', 0, 68, '1'),
(141, '', 2, '', '0000-00-00', 0, 68, '1'),
(142, '', 6, '', '0000-00-00', 0, 68, '1'),
(143, '', 1, '', '0000-00-00', 0, 69, '1'),
(144, '', 2, '', '0000-00-00', 0, 69, '1'),
(145, '', 6, '', '0000-00-00', 0, 69, '1'),
(146, 'Geronimo Salazar', 8, '', '2015-12-06', 1, 69, '1'),
(147, '', 1, '', '0000-00-00', 0, 70, '1'),
(148, '', 2, '', '0000-00-00', 0, 70, '1'),
(149, '', 4, '', '0000-00-00', 0, 70, '1'),
(150, '', 6, '', '0000-00-00', 0, 70, '1'),
(151, 'Samuel aguirre', 8, '', '2014-06-02', 1, 70, '1'),
(152, '', 1, '', '0000-00-00', 0, 71, '1'),
(153, '', 6, '', '0000-00-00', 0, 71, '1'),
(154, '', 7, '', '0000-00-00', 0, 71, '1'),
(155, 'Adriana Patricia Pulgarin      ', 3, '      0000', '0000-00-00', 0, 72, '1'),
(156, '', 4, '', '0000-00-00', 0, 72, '1'),
(157, '', 5, '', '0000-00-00', 0, 72, '25'),
(158, '', 6, '', '0000-00-00', 0, 72, '2'),
(159, 'Paulina gomez', 8, '', '2008-12-17', 1, 72, '1'),
(160, 'Edwin Soto      ', 3, '      0000', '0000-00-00', 0, 73, '1'),
(161, '', 1, '', '0000-00-00', 0, 74, '1'),
(162, '', 6, '', '0000-00-00', 0, 74, '1'),
(163, 'Andres montes', 8, '', '2015-04-07', 1, 74, '1'),
(164, '', 6, '', '0000-00-00', 0, 75, '1'),
(165, 'Salome jaramillo', 8, '', '2014-02-10', 1, 75, '1'),
(166, 'Angie quintana      ', 3, '      0000', '0000-00-00', 0, 76, '1'),
(167, '', 7, '', '0000-00-00', 0, 76, '1'),
(168, '', 2, '', '0000-00-00', 0, 77, '1'),
(169, '', 1, '', '0000-00-00', 0, 78, '1'),
(170, '', 6, '', '0000-00-00', 0, 78, '1'),
(171, 'Matias Gaviria', 8, '', '2013-08-16', 1, 78, '1'),
(172, 'Saray Gaviria', 8, '', '2016-05-14', 1, 78, '1'),
(173, '', 1, '', '0000-00-00', 0, 79, '1'),
(174, 'Maria Paz Noreña', 8, '', '2016-07-21', 1, 79, '1'),
(175, 'Sarha Rivera', 8, '', '2007-12-08', 1, 80, '1'),
(176, '', 1, '', '0000-00-00', 0, 81, '1'),
(177, '', 6, '', '0000-00-00', 0, 81, '1'),
(178, '', 1, '', '0000-00-00', 0, 82, '1'),
(179, '', 2, '', '0000-00-00', 0, 82, '1'),
(180, '', 7, '', '0000-00-00', 0, 82, '1'),
(181, 'Thomas Grajales', 8, '', '2009-03-14', 1, 82, '1'),
(182, 'Paula hernandez      ', 3, '      0000', '0000-00-00', 0, 83, '1'),
(183, '', 1, '', '0000-00-00', 0, 84, '1'),
(184, '', 2, '', '0000-00-00', 0, 84, '1'),
(185, '', 6, '', '0000-00-00', 0, 84, '1'),
(186, '', 1, '', '0000-00-00', 0, 85, '1'),
(187, '', 4, '', '0000-00-00', 0, 85, '1'),
(188, '', 5, '', '0000-00-00', 0, 85, '2'),
(189, '', 1, '', '0000-00-00', 0, 86, '1'),
(190, '', 2, '', '0000-00-00', 0, 86, '1'),
(191, '', 1, '', '0000-00-00', 0, 87, '1'),
(192, '', 6, '', '0000-00-00', 0, 87, '3'),
(193, 'Diana mercado      ', 3, '      0000', '0000-00-00', 0, 88, '1'),
(194, 'Luciana herrera', 8, '', '2017-03-01', 1, 88, '1'),
(195, 'Mariana herrera', 8, '', '2011-12-29', 1, 88, '1'),
(196, '', 1, '', '0000-00-00', 0, 89, '1'),
(197, '', 6, '', '0000-00-00', 0, 89, '1'),
(198, '', 7, '', '0000-00-00', 0, 89, '1'),
(199, 'Saray Panqueva     ', 3, '     31935', '0000-00-00', 0, 91, '1'),
(201, '', 7, '', '0000-00-00', 0, 92, '1'),
(204, '', 1, '', '0000-00-00', 0, 93, '1'),
(206, '', 2, '', '0000-00-00', 0, 93, '1'),
(208, '', 6, '', '0000-00-00', 0, 93, '1'),
(209, '', 7, '', '0000-00-00', 0, 93, '2'),
(211, 'Andres Felipe Alzate    ', 3, '    318548', '0000-00-00', 0, 94, '1'),
(214, 'Violeta Alzate', 8, '', '2011-07-08', 1, 94, '1'),
(216, '', 1, '', '0000-00-00', 0, 95, '1'),
(217, '', 2, '', '0000-00-00', 0, 95, '1'),
(219, '', 6, '', '0000-00-00', 0, 95, '1'),
(222, '', 1, '', '0000-00-00', 0, 96, '1'),
(223, '', 6, '', '0000-00-00', 0, 96, '1'),
(226, '', 2, '', '0000-00-00', 0, 96, '1'),
(234, 'Ana Lucia Valencia    ', 3, '    314632', '0000-00-00', 0, 97, '1'),
(235, 'Maria Galeano', 8, '', '2011-03-28', 1, 97, '1'),
(237, 'Pedro Galeano', 8, '', '2012-12-11', 1, 97, '1'),
(241, '', 2, '', '0000-00-00', 0, 98, '1'),
(242, '', 1, '', '0000-00-00', 0, 98, '1'),
(252, 'Lina Cano  ', 3, '  30036413', '0000-00-00', 0, 99, '1'),
(255, 'Valentina Vélez', 8, '', '2006-11-21', 1, 99, '1'),
(256, 'Mariana Vélez', 8, '', '2004-10-30', 1, 99, '1'),
(257, 'Emiliano Vélez', 8, '', '2014-08-22', 1, 99, '1'),
(260, 'Gloria Maria Múnera Velásquez  ', 3, '  30062023', '0000-00-00', 0, 100, '1'),
(261, 'Sofía Gómez Múnera', 8, '', '1999-11-18', 1, 100, '1'),
(311, '', 1, '', '0000-00-00', 0, 101, '1'),
(313, 'Manuela Parra Espinal', 8, '', '2000-10-07', 1, 101, '1'),
(314, '', 6, '', '0000-00-00', 0, 101, '1'),
(315, '', 2, '', '0000-00-00', 0, 101, '1'),
(318, 'Jonatan Ruiz Lopez ', 3, ' 300230177', '0000-00-00', 0, 102, '1'),
(319, 'Elena Gallo Gomez', 8, '', '2017-01-12', 1, 102, '1'),
(343, '', 2, '', '0000-00-00', 0, 103, '1'),
(345, '', 1, '', '0000-00-00', 0, 103, '1'),
(347, '', 6, '', '0000-00-00', 0, 103, '1'),
(348, '', 5, '', '0000-00-00', 0, 103, '1'),
(349, 'Emmanuel Oliveros ', 3, ' 304648474', '0000-00-00', 0, 104, '1'),
(368, '', 5, '', '0000-00-00', 0, 105, '1'),
(382, '', 7, '', '0000-00-00', 0, 106, '4'),
(383, 'Carloina David ', 3, ' 321761608', '0000-00-00', 0, 106, '1'),
(385, 'Fernando Vélez  ', 3, ' 300617142', '0000-00-00', 0, 107, '1'),
(386, 'Ana María Vélez', 8, '', '2009-03-26', 1, 107, '1'),
(387, 'Pablo Vélez ', 8, '', '2005-06-18', 1, 107, '1'),
(388, 'Tomas Vélez', 8, '', '2012-04-29', 1, 107, '1'),
(393, 'Tomas Velez', 8, '', '0000-00-00', 1, 108, '1'),
(394, 'Ana Maria velez', 8, '', '0000-00-00', 1, 108, '1'),
(395, 'Pablo Velez', 8, '', '0000-00-00', 1, 108, '1'),
(396, 'Viviana Echavarría  ', 3, ' 300617142', '0000-00-00', 0, 108, '1'),
(401, 'Luis Alberto Alzate Ceballos ', 3, ' 304420160', '0000-00-00', 0, 109, '1'),
(402, 'Juan José Alzate Ospina', 8, '', '0000-00-00', 1, 109, '1'),
(408, 'David Gómez Múnera', 8, '', '2003-04-03', 1, 100, '1'),
(415, 'Daniela Tobon ', 3, ' 305304697', '0000-00-00', 0, 110, '1'),
(420, 'JUAN ANDRES PORRAS VELEZ', 8, '', '2003-03-12', 1, 111, '1'),
(421, 'JULIAN PORRAS ', 3, ' 320340841', '0000-00-00', 0, 111, '1'),
(422, 'GABRIEL PORRAS VELEZ', 8, '', '2016-03-18', 1, 111, '1'),
(423, 'ISABEL PORRAS VELEZ', 8, '', '2008-10-18', 1, 111, '1'),
(430, 'Batriz Eugenia  Escobar ', 3, ' 300709722', '0000-00-00', 0, 112, '1'),
(441, '', 2, '', '0000-00-00', 0, 113, '1'),
(444, '', 1, '', '0000-00-00', 0, 113, '1'),
(445, '', 6, '', '0000-00-00', 0, 113, '1'),
(447, '', 6, '', '0000-00-00', 0, 114, '1'),
(455, 'Matias alzate Lopez ', 8, '', '2019-03-20', 1, 94, '1'),
(577, '', 4, '', '0000-00-00', 0, 105, '0'),
(578, '', 6, '', '0000-00-00', 0, 105, '0'),
(579, '', 7, '', '0000-00-00', 0, 105, '0'),
(580, '', 4, '', '0000-00-00', 0, 34, '0'),
(581, '', 7, '', '0000-00-00', 0, 34, '0'),
(582, '', 5, '', '0000-00-00', 0, 34, '0'),
(583, '', 6, '', '0000-00-00', 0, 34, '0'),
(586, '', 6, '', '0000-00-00', 0, 80, '0'),
(587, '', 7, '', '0000-00-00', 0, 80, '0'),
(588, '', 5, '', '0000-00-00', 0, 80, '0'),
(589, '', 4, '', '0000-00-00', 0, 80, '0'),
(590, '', 4, '', '0000-00-00', 0, 71, '0'),
(591, '', 5, '', '0000-00-00', 0, 71, '0'),
(592, '', 6, '', '0000-00-00', 0, 36, '0'),
(593, '', 4, '', '0000-00-00', 0, 36, '0'),
(594, '', 5, '', '0000-00-00', 0, 36, '0'),
(595, '', 4, '', '0000-00-00', 0, 53, '0'),
(596, '', 5, '', '0000-00-00', 0, 53, '0'),
(597, '', 7, '', '0000-00-00', 0, 53, '0'),
(598, '', 6, '', '0000-00-00', 0, 53, '0'),
(599, '', 4, '', '0000-00-00', 0, 103, '0'),
(600, '', 7, '', '0000-00-00', 0, 103, '0'),
(601, '', 5, '', '0000-00-00', 0, 40, '0'),
(602, '', 4, '', '0000-00-00', 0, 40, '0'),
(603, '', 6, '', '0000-00-00', 0, 40, '0'),
(604, '', 7, '', '0000-00-00', 0, 40, '0'),
(605, '', 4, '', '0000-00-00', 0, 21, '0'),
(606, '', 5, '', '0000-00-00', 0, 21, '0'),
(607, '', 7, '', '0000-00-00', 0, 21, '0'),
(608, '', 6, '', '0000-00-00', 0, 21, '0'),
(609, '', 5, '', '0000-00-00', 0, 9, '0'),
(610, '', 4, '', '0000-00-00', 0, 9, '0'),
(611, '', 7, '', '0000-00-00', 0, 9, '0'),
(612, '', 4, '', '0000-00-00', 0, 77, '0'),
(613, '', 5, '', '0000-00-00', 0, 77, '0'),
(614, '', 6, '', '0000-00-00', 0, 77, '0'),
(615, '', 7, '', '0000-00-00', 0, 77, '0'),
(616, '', 5, '', '0000-00-00', 0, 4, '0'),
(617, '', 7, '', '0000-00-00', 0, 4, '0'),
(618, '', 4, '', '0000-00-00', 0, 4, '0'),
(619, '', 4, '', '0000-00-00', 0, 48, '0'),
(620, '', 5, '', '0000-00-00', 0, 48, '0'),
(621, '', 6, '', '0000-00-00', 0, 48, '0'),
(622, '', 7, '', '0000-00-00', 0, 48, '0'),
(623, '', 6, '', '0000-00-00', 0, 1, '0'),
(624, '', 5, '', '0000-00-00', 0, 1, '0'),
(625, '', 4, '', '0000-00-00', 0, 1, '0'),
(626, '', 7, '', '0000-00-00', 0, 1, '0'),
(627, '', 4, '', '0000-00-00', 0, 31, '0'),
(628, '', 5, '', '0000-00-00', 0, 31, '0'),
(629, '', 6, '', '0000-00-00', 0, 31, '0'),
(630, '', 7, '', '0000-00-00', 0, 67, '0'),
(631, '', 4, '', '0000-00-00', 0, 67, '0'),
(632, '', 5, '', '0000-00-00', 0, 67, '0'),
(633, '', 6, '', '0000-00-00', 0, 90, '0'),
(634, 'Paula Andrea Lara Ramirez', 3, '3174536404', '0000-00-00', 0, 90, '1'),
(635, '', 7, '', '0000-00-00', 0, 90, '0'),
(636, 'Emmanuel Gomez Lara ', 8, '', '2015-07-14', 1, 90, '1'),
(637, '', 5, '', '0000-00-00', 0, 90, '0'),
(638, '', 4, '', '0000-00-00', 0, 90, '0'),
(639, '', 4, '', '0000-00-00', 0, 37, '0'),
(640, '', 5, '', '0000-00-00', 0, 37, '0'),
(641, '', 6, '', '0000-00-00', 0, 37, '0'),
(642, '', 7, '', '0000-00-00', 0, 37, '0'),
(643, '', 4, '', '0000-00-00', 0, 56, '0'),
(644, '', 6, '', '0000-00-00', 0, 56, '0'),
(645, '', 5, '', '0000-00-00', 0, 56, '0'),
(646, '', 7, '', '0000-00-00', 0, 56, '0'),
(647, '', 5, '', '0000-00-00', 0, 50, '0'),
(648, '', 4, '', '0000-00-00', 0, 50, '0'),
(649, '', 6, '', '0000-00-00', 0, 50, '0'),
(650, '', 7, '', '0000-00-00', 0, 50, '0'),
(651, '', 4, '', '0000-00-00', 0, 93, '0'),
(652, '', 5, '', '0000-00-00', 0, 93, '0'),
(653, '', 4, '', '0000-00-00', 0, 41, '0'),
(654, '', 7, '', '0000-00-00', 0, 41, '0'),
(655, '', 6, '', '0000-00-00', 0, 41, '0'),
(656, '', 5, '', '0000-00-00', 0, 41, '0'),
(657, '', 6, '', '0000-00-00', 0, 104, '0'),
(658, '', 5, '', '0000-00-00', 0, 104, '0'),
(659, '', 4, '', '0000-00-00', 0, 104, '0'),
(660, '', 7, '', '0000-00-00', 0, 104, '0'),
(661, '', 4, '', '0000-00-00', 0, 8, '0'),
(662, '', 5, '', '0000-00-00', 0, 8, '0'),
(663, '', 7, '', '0000-00-00', 0, 8, '0'),
(664, '', 6, '', '0000-00-00', 0, 8, '0'),
(665, '', 4, '', '0000-00-00', 0, 54, '0'),
(666, '', 6, '', '0000-00-00', 0, 54, '0'),
(667, '', 5, '', '0000-00-00', 0, 54, '0'),
(668, '', 7, '', '0000-00-00', 0, 54, '0'),
(669, '', 4, '', '0000-00-00', 0, 109, '0'),
(670, '', 5, '', '0000-00-00', 0, 109, '0'),
(671, '', 6, '', '0000-00-00', 0, 109, '0'),
(672, '', 7, '', '0000-00-00', 0, 109, '0'),
(673, 'fabian fernando vélez pérez ', 8, '', '1972-02-26', 0, 112, '1'),
(674, 'gloria liliana vélez pérez ', 8, '', '1975-12-16', 0, 112, '1'),
(675, 'gabriel jaime vélez pérez ', 8, '', '1977-02-17', 0, 112, '1'),
(676, '', 4, '', '0000-00-00', 0, 112, '0'),
(677, '', 5, '', '0000-00-00', 0, 112, '0'),
(678, '', 6, '', '0000-00-00', 0, 112, '0'),
(679, '', 7, '', '0000-00-00', 0, 112, '0'),
(680, '', 1, '', '0000-00-00', 0, 115, '1'),
(681, '', 5, '', '0000-00-00', 0, 115, '0'),
(682, '', 2, '', '0000-00-00', 0, 115, '1'),
(683, '', 7, '', '0000-00-00', 0, 115, '0'),
(684, '', 4, '', '0000-00-00', 0, 115, '0'),
(685, '', 6, '', '0000-00-00', 0, 115, '0'),
(686, '', 4, '', '0000-00-00', 0, 59, '0'),
(687, '', 6, '', '0000-00-00', 0, 59, '0'),
(688, '', 5, '', '0000-00-00', 0, 59, '0'),
(689, '', 7, '', '0000-00-00', 0, 59, '0'),
(690, 'Yamile Patron', 3, '3107020736', '0000-00-00', 0, 59, '1'),
(691, '', 4, '', '0000-00-00', 0, 110, '0'),
(692, '', 7, '', '0000-00-00', 0, 110, '0'),
(693, '', 5, '', '0000-00-00', 0, 110, '0'),
(694, '', 6, '', '0000-00-00', 0, 110, '0'),
(695, '', 6, '', '0000-00-00', 0, 11, '0'),
(696, '', 7, '', '0000-00-00', 0, 11, '0'),
(697, '', 5, '', '0000-00-00', 0, 11, '0'),
(698, '', 4, '', '0000-00-00', 0, 11, '0'),
(699, '', 6, '', '0000-00-00', 0, 82, '0'),
(700, '', 5, '', '0000-00-00', 0, 82, '0'),
(701, '', 4, '', '0000-00-00', 0, 82, '0'),
(702, '', 5, '', '0000-00-00', 0, 28, '0'),
(703, '', 4, '', '0000-00-00', 0, 28, '0'),
(704, '', 7, '', '0000-00-00', 0, 28, '0'),
(705, '', 7, '', '0000-00-00', 0, 65, '0'),
(706, '', 4, '', '0000-00-00', 0, 65, '0'),
(707, '', 6, '', '0000-00-00', 0, 65, '0'),
(708, '', 5, '', '0000-00-00', 0, 65, '0'),
(709, '', 6, '', '0000-00-00', 0, 106, '0'),
(710, '', 4, '', '0000-00-00', 0, 106, '0'),
(711, '', 5, '', '0000-00-00', 0, 106, '0'),
(712, '', 4, '', '0000-00-00', 0, 44, '0'),
(713, '', 7, '', '0000-00-00', 0, 44, '0'),
(714, '', 5, '', '0000-00-00', 0, 44, '0'),
(715, '', 6, '', '0000-00-00', 0, 44, '0'),
(716, '', 4, '', '0000-00-00', 0, 38, '0'),
(717, '', 5, '', '0000-00-00', 0, 38, '0'),
(718, '', 6, '', '0000-00-00', 0, 51, '0'),
(719, '', 5, '', '0000-00-00', 0, 51, '0'),
(720, '', 4, '', '0000-00-00', 0, 51, '0'),
(721, '', 4, '', '0000-00-00', 0, 114, '0'),
(722, '', 5, '', '0000-00-00', 0, 114, '0'),
(723, '', 7, '', '0000-00-00', 0, 114, '0'),
(724, '', 4, '', '0000-00-00', 0, 22, '0'),
(725, '', 6, '', '0000-00-00', 0, 22, '0'),
(726, '', 5, '', '0000-00-00', 0, 22, '0'),
(727, '', 7, '', '0000-00-00', 0, 55, '0'),
(728, '', 5, '', '0000-00-00', 0, 55, '0'),
(729, '', 4, '', '0000-00-00', 0, 55, '0'),
(730, '', 7, '', '0000-00-00', 0, 35, '0'),
(731, '', 4, '', '0000-00-00', 0, 35, '0'),
(732, '', 4, '', '0000-00-00', 0, 52, '0'),
(733, '', 7, '', '0000-00-00', 0, 52, '0'),
(734, '', 6, '', '0000-00-00', 0, 52, '0'),
(735, '', 5, '', '0000-00-00', 0, 52, '0'),
(736, '', 5, '', '0000-00-00', 0, 46, '0'),
(737, '', 6, '', '0000-00-00', 0, 46, '0'),
(738, '', 4, '', '0000-00-00', 0, 46, '0'),
(739, '', 7, '', '0000-00-00', 0, 17, '0'),
(740, '', 5, '', '0000-00-00', 0, 17, '0'),
(741, '', 4, '', '0000-00-00', 0, 33, '0'),
(742, '', 5, '', '0000-00-00', 0, 33, '0'),
(743, '', 4, '', '0000-00-00', 0, 68, '0'),
(744, '', 5, '', '0000-00-00', 0, 68, '0'),
(745, '', 7, '', '0000-00-00', 0, 68, '0'),
(746, '', 5, '', '0000-00-00', 0, 42, '0'),
(747, '', 7, '', '0000-00-00', 0, 42, '0'),
(748, '', 4, '', '0000-00-00', 0, 42, '0'),
(749, '', 6, '', '0000-00-00', 0, 42, '0'),
(750, '', 6, '', '0000-00-00', 0, 24, '0'),
(751, '', 4, '', '0000-00-00', 0, 24, '0'),
(752, '', 5, '', '0000-00-00', 0, 24, '0'),
(753, '', 5, '', '0000-00-00', 0, 20, '0'),
(754, '', 6, '', '0000-00-00', 0, 20, '0'),
(755, '', 4, '', '0000-00-00', 0, 20, '0'),
(756, '', 4, '', '0000-00-00', 0, 43, '0'),
(757, '', 6, '', '0000-00-00', 0, 43, '0'),
(758, '', 7, '', '0000-00-00', 0, 43, '0'),
(759, '', 5, '', '0000-00-00', 0, 43, '0'),
(760, '', 5, '', '0000-00-00', 0, 73, '0'),
(761, '', 7, '', '0000-00-00', 0, 73, '0'),
(762, '', 4, '', '0000-00-00', 0, 73, '0'),
(763, '', 6, '', '0000-00-00', 0, 73, '0'),
(764, '', 4, '', '0000-00-00', 0, 75, '0'),
(765, '', 5, '', '0000-00-00', 0, 75, '0'),
(766, '', 7, '', '0000-00-00', 0, 75, '0'),
(767, '', 7, '', '0000-00-00', 0, 16, '0'),
(768, '', 4, '', '0000-00-00', 0, 16, '0'),
(769, '', 5, '', '0000-00-00', 0, 16, '0'),
(770, '', 7, '', '0000-00-00', 0, 13, '0'),
(771, '', 5, '', '0000-00-00', 0, 13, '0'),
(772, '', 6, '', '0000-00-00', 0, 13, '0'),
(773, '', 4, '', '0000-00-00', 0, 13, '0'),
(774, '', 4, '', '0000-00-00', 0, 12, '0'),
(775, '', 7, '', '0000-00-00', 0, 12, '0'),
(776, '', 4, '', '0000-00-00', 0, 91, '0'),
(777, '', 6, '', '0000-00-00', 0, 91, '0'),
(778, '', 7, '', '0000-00-00', 0, 91, '0'),
(779, '', 5, '', '0000-00-00', 0, 91, '0'),
(780, '', 4, '', '0000-00-00', 0, 116, '0'),
(781, '', 6, '', '0000-00-00', 0, 116, '0'),
(782, '', 7, '', '0000-00-00', 0, 116, '1'),
(783, '', 5, '', '0000-00-00', 0, 116, '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `idProducto` smallint(6) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `precio` varchar(8) NOT NULL,
  `estado` tinyint(1) NOT NULL,
  `idProveedor` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`idProducto`, `nombre`, `precio`, `estado`, `idProveedor`) VALUES
(1, 'MENU COMPLETO DEL DIA', '7900', 1, 2),
(2, 'SOPA DEL DIA', '2000', 1, 2),
(3, 'SECO DEL DIA', '5900', 1, 2),
(4, 'AREPA CON TODO', '4800', 1, 1),
(5, 'AREPA DE CHÓCOLO Y QUESO MOZARELLA', '2200', 1, 1),
(6, 'AREPA CON CHORIZO', '3200', 1, 1),
(7, 'CHUZO DE POLLO', '5000', 1, 1),
(8, 'HAMBURGUESA', '4800', 1, 1),
(9, 'PANZEROTI', '2000', 1, 1),
(10, 'SANDUCHE DE TOCINETA', '2100', 1, 1),
(11, 'SANDUCHE DE JAMON Y QUESO', '2100', 1, 1),
(12, 'GRANOLA CON KUMIS', '2500', 1, 1),
(13, 'CEREAL, KUMIS Y 1 FRUTA', '3000', 1, 1),
(14, 'ENSALADA DE FRUTAS CON CEREAL Y KUMIS', '4000', 1, 1),
(15, 'FRESA CON KUMIS', '3000', 1, 1),
(16, 'AREPA CON JAMÓN Y QUESO', '2000', 1, 1),
(17, 'AREPA POLLO DESMECHADO, TOCINETA Y QUESO', '5000', 1, 1),
(18, 'JUGO DE GUANABANA EN LECHE', '2000', 1, 1),
(19, 'JUGO DE GUANABANA EN AGUA', '2000', 1, 1),
(20, 'JUGO DE NARANJA', '2000', 1, 1),
(21, 'JUGO DE MANGO EN LECHE', '2000', 1, 1),
(22, 'JUGO DE MANGO EN AGUA', '2000', 1, 1),
(23, 'JUGO DE MORA EN LECHE', '2000', 1, 1),
(24, 'JUGO DE MORA EN AGUA', '2000', 1, 1),
(25, 'JUGO DE FRESA EN LECHE', '2000', 1, 1),
(26, 'JUGO DE FRESA EN AGUA', '2000', 1, 1),
(27, 'JUGO DE MARACUYA EN LECHE', '2000', 1, 1),
(28, 'JUGO DE MARACUYA EN AGUA', '2000', 1, 1),
(29, 'JUGO DE LULO EN LECHE', '2000', 1, 1),
(30, 'JUGO DE LULO EN AGUA', '2000', 1, 1),
(31, 'MILO', '2000', 1, 1),
(32, 'YOGURTH', '800', 1, 1),
(33, 'PALITO DE QUESO (ó Croasán o Pastel de Queso)', '1400', 1, 3),
(34, 'CROASÁN (ó Palito de Queso ó Pastel de Queso)', '1400', 1, 3),
(35, 'PASTEL DE QUESO (ó Palito de Queso ó Croasán)', '1400', 1, 3),
(36, 'BUÑUELO', '600', 1, 3),
(37, 'PASTEL DE POLLO HOJALDRADO', '2000', 1, 3),
(38, 'PASTEL DE POLLO FRITO', '2500', 1, 3),
(39, 'EMPANADA DE CARNE (ó Papa Rellena)', '2200', 1, 3),
(40, 'PAPA RELLENA (ó Empanada de Carne)', '2200', 1, 3),
(41, 'PANDEBONO (ó Pandequeso ó Almojabana)', '1300', 1, 3),
(42, 'PANDEQUESO (ó Pandebono ó Almojabana)', '1300', 1, 3),
(43, 'ALMOJABANA (ó Pandebono ó Pandequeso)', '1300', 1, 3),
(44, 'AVENA (ó Milo Caliente)', '2500', 1, 3),
(45, 'MILO CALIENTE (ó AVENA)', '2500', 1, 3),
(46, 'PASTEL DE CARNE', '2800', 1, 3),
(47, 'PASTEL RANCHERO', '2900', 1, 3),
(48, 'HUEVOS CON TODO', '4000', 1, 3),
(49, 'OMELETTE - TORTILLA DE HUEVO RELLENA', '6000', 1, 3),
(50, 'CROASÁN DE JAMÓN Y QUESO', '1800', 1, 3),
(51, 'CROASÁN RANCHERO', '1800', 1, 3),
(52, 'CROASÁN SANDUCHE', '3500', 1, 3),
(53, 'PANDEQUESO XXL', '2600', 1, 3),
(54, 'PAN DE MAÍZ', '2500', 1, 3),
(55, 'MILO FRÍO (DELEITATE)', '2500', 1, 3),
(56, 'JUGO DE NARANJA (DELEITATE)', '2600', 1, 3),
(57, 'PASTEL DE AREQUIPE', '1400', 1, 3),
(58, 'PASTEL DE GUAYABA', '1200', 1, 3),
(59, 'PASTEL DE AREQUIPE Y QUESO', '1600', 1, 3),
(60, 'MR TEA', '2000', 1, 3),
(61, 'GASEOSA POSTOBÓN LITRO 1/2 (CUALQUIER SABOR)', '3500', 1, 3),
(62, 'GASEOSA POSTOBÓN MEGA (CUALQUIER SABOR)', '6000', 1, 3),
(63, 'GASEOSA COCA-COLA LITRO 1/2 (CUALQUIER SABOR)', '3500', 1, 3),
(64, 'GASEOSA COCA-COLA MEGA (CUALQUIER SABOR)', '6000', 1, 3),
(65, 'AREPA CON HUEVO REVUELTO', '2500', 1, 4),
(66, 'AREPA CON HUEVO REVUELTO Y ALIÑOS', '2500', 1, 4),
(67, 'AREPA CON HOGAO', '2000', 1, 4),
(68, 'AREPA CON QUESITO', '2000', 1, 4),
(69, 'EMPANADA DE ARROZ', '1200', 1, 4),
(70, 'EMPANADA DE PAPA', '1200', 1, 4),
(71, 'PASTEL DE POLLO', '2000', 1, 4),
(72, 'PALITO DE QUESO FRITO', '1000', 1, 4),
(73, 'PATACÓN CON HOGAO', '2000', 1, 4),
(74, 'PATACÓN CON QUESO', '2000', 1, 4),
(75, 'PATACÓN CON HUEVO REVUELTO', '3000', 1, 4),
(76, 'PATATÓN CON HUEVO CON ALIÑOS', '3000', 1, 4),
(77, 'CHOCOLATE EN AGUAPANELA', '1500', 1, 4),
(78, 'AREPA DE CHÓCOLO, MANTEQUILLA Y QUESITO', '2500', 1, 4),
(79, 'CAFÉ EN LECHE', '1100', 1, 4),
(80, 'MENÚ DEL DÍA (MARU RICO)', '12600', 1, 5),
(81, 'BANDEJA CON RES (MARU RICO)', '12600', 1, 5),
(82, 'BANDEJA CON CERDO (MARU RICO)', '12600', 1, 5),
(83, 'BANDEJA CON POLLO (MARU RICO)', '12600', 1, 5),
(84, 'BANDEJA CON CHICHARRÓN (MARU RICO)', '12600', 1, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promedio_salario`
--

CREATE TABLE `promedio_salario` (
  `idPromedio_salario` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `promedio_salario`
--

INSERT INTO `promedio_salario` (`idPromedio_salario`, `nombre`, `estado`) VALUES
(1, '1 SMMLV', 1),
(2, 'Menos de 2 SMMLV', 1),
(3, 'Entre 2 y 3 SMMLV', 1),
(4, 'Entre 3 y 4 SMMLV', 1),
(5, 'Mas de 4 SMMLV', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `idProveedor` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `telefono` varchar(11) NOT NULL,
  `estado` tinyint(1) NOT NULL,
  `evento` tinyint(1) NOT NULL DEFAULT '1',
  `email` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`idProveedor`, `nombre`, `telefono`, `estado`, `evento`, `email`) VALUES
(1, 'DESAYUNOS-COMIDAS RÁPIDAS - DIEGO CASTRILLÓN', '3206700807', 1, 1, 'liliana.restrepo@colcircuitos.com'),
(2, 'ALMUERZOS - EDWIN GALVIS', '3046113686', 1, 2, 'edwingalvis360@gmail.com'),
(3, 'PANADERÍA DELEITATE - DESAYUNO', '2557620', 1, 1, 'deleitatexpress@hotmail.com'),
(4, 'DESAYUNOS - LUZ ERLEY VEGA', '3217569095', 1, 1, 'aracelly.ospina@colcircuitos.com'),
(5, 'RESTAURANTE MARU RICO - ALMUERZOS', '3545565', 1, 2, 'gastronomia.industrial@hotmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `restriccion`
--

CREATE TABLE `restriccion` (
  `idRestriccion` tinyint(4) NOT NULL,
  `hora_inicio_pedidos` time NOT NULL,
  `hora_fin_pedidos` time NOT NULL,
  `estado` tinyint(1) NOT NULL,
  `hora_inicio_siguiente_dia` time NOT NULL DEFAULT '14:00:00',
  `hora_fin_siguiente_dia` time NOT NULL DEFAULT '18:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `restriccion`
--

INSERT INTO `restriccion` (`idRestriccion`, `hora_inicio_pedidos`, `hora_fin_pedidos`, `estado`, `hora_inicio_siguiente_dia`, `hora_fin_siguiente_dia`) VALUES
(1, '06:00:00', '07:45:00', 1, '14:00:00', '18:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `idRol` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idRol`, `nombre`, `estado`) VALUES
(1, 'Producción', 1),
(2, 'Administrativo', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salarial`
--

CREATE TABLE `salarial` (
  `idSalarial` smallint(6) NOT NULL,
  `idPromedio_salario` tinyint(4) NOT NULL,
  `idClasificacion_mega` tinyint(4) NOT NULL,
  `salario_basico` varchar(20) NOT NULL,
  `total` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `salarial`
--

INSERT INTO `salarial` (`idSalarial`, `idPromedio_salario`, `idClasificacion_mega`, `salario_basico`, `total`) VALUES
(1, 1, 0, '954000', '1.111.032'),
(2, 1, 0, '1380000', '1677032'),
(3, 1, 0, '1100000', '1197032'),
(4, 1, 0, '859916', '956.948'),
(5, 1, 0, '1220000', '1317032'),
(6, 1, 0, '1400000', '1688211'),
(7, 1, 0, '1560000', '1657032'),
(8, 1, 0, '954000', '1.141.032'),
(9, 1, 0, '859916', '956.948'),
(10, 3, 0, '1800000', '1880000'),
(11, 1, 0, '872815', '969.847'),
(12, 1, 0, '872815', '969.847'),
(13, 1, 0, '912485', '1.009.517'),
(14, 3, 0, '1800000', '2100000'),
(15, 1, 0, '811242', '811242'),
(16, 1, 0, '859916', '956.948'),
(17, 1, 0, '885907', '1.108.012'),
(18, 3, 0, '2000000', '2000000'),
(19, 1, 0, '981000', '1178032'),
(20, 1, 0, '859916', '956.948'),
(21, 1, 0, '859916', '956.948'),
(22, 1, 0, '900000', '1.057.032'),
(23, 1, 0, '954000', '1.111.032'),
(24, 1, 0, '900000', '1.057.032'),
(25, 3, 0, '2000000', '2200000'),
(26, 3, 0, '1800000', '1800000'),
(27, 1, 0, '872815', '969847'),
(28, 1, 0, '859916', '956.948'),
(29, 1, 0, '972000', '1129032'),
(30, 1, 0, '1000000', '1297032'),
(31, 1, 0, '828116', '925.148'),
(32, 1, 0, '1000000', '1297032'),
(33, 1, 0, '1100000', '1.317.032'),
(34, 1, 0, '1200000', '1.297.032'),
(35, 1, 0, '859916', '1.016.948'),
(36, 1, 0, '972000', '1.319.032'),
(37, 1, 0, '954000', '1.111.032'),
(38, 1, 0, '859916', '956.948'),
(39, 2, 0, '1322000', '1322000'),
(40, 1, 0, '912485', '1.069.517'),
(41, 1, 0, '859916', '956.948'),
(42, 1, 0, '859916', '956.948'),
(43, 1, 0, '912485', '1.069.517'),
(44, 1, 0, '912485', '1.139.517'),
(45, 4, 0, '3500000', '3500000'),
(46, 1, 0, '872815', '1.029.847'),
(47, 1, 0, '1200000', '1397032'),
(48, 1, 0, '859916', '956.948'),
(49, 1, 0, '1040000', '1317032'),
(50, 4, 0, '3120000', '3.820.000'),
(51, 1, 0, '872815', '969.847'),
(52, 1, 0, '859916', '1.096.948'),
(53, 1, 0, '1560000', '1.907.032'),
(54, 1, 0, '1560000', '1.907.032'),
(55, 1, 0, '859916', '956.948'),
(56, 1, 0, '954000', '1.111.032'),
(57, 1, 0, '1484000', '1781032'),
(58, 1, 0, '1200000', '1497032'),
(59, 1, 0, '900000', '997.032'),
(60, 1, 0, '859916', '956948'),
(61, 1, 0, '828116', '985148'),
(62, 1, 0, '900000', '997032'),
(63, 1, 0, '781242', '781242'),
(64, 1, 0, '781242', '781242'),
(65, 1, 0, '828116', '925.148'),
(66, 1, 0, '781242', '781242'),
(67, 1, 0, '828116', '925.148'),
(68, 1, 0, '912485', '1.049.517'),
(69, 1, 0, '828116', '828116'),
(70, 1, 0, '781242', '869453'),
(71, 1, 0, '781242', '781.242'),
(72, 1, 0, '781242', '781242'),
(73, 1, 0, '828116', '925.148'),
(74, 1, 0, '781242', '781242'),
(75, 1, 0, '828116', '925.148'),
(76, 1, 0, '1000000', '1000000'),
(77, 1, 0, '954000', '1.111.032'),
(78, 1, 0, '781242', '781242'),
(79, 1, 0, '900000', '997032'),
(80, 1, 0, '859916', '956.948'),
(81, 1, 0, '781242', '781242'),
(82, 1, 0, '828116', '925.148'),
(83, 1, 0, '847000', '1144032'),
(84, 1, 0, '1500000', '1597032'),
(85, 1, 0, '1560000', '1907032'),
(86, 1, 0, '1560000', '1907032'),
(87, 4, 0, '2500000', '2500000'),
(88, 4, 0, '3000000', '3800000'),
(89, 3, 0, '1560000', '1907032'),
(90, 5, 0, '4500000', '5.000.000'),
(91, 1, 0, '2300000', '2.300.000'),
(92, 3, 0, '1800000', '2000000'),
(93, 3, 0, '2500000', '3.000.000'),
(94, 2, 0, '982800', '1309832'),
(95, 0, 0, '2300000', '2397032'),
(96, 4, 0, '2500000', '2900000'),
(97, 5, 0, '6000000', '6250000'),
(98, 2, 0, '1000000', '1097032'),
(99, 4, 0, '3000000', '3000000'),
(100, 4, 0, '4000000', '5500000'),
(101, 2, 0, '1200000', '1297032'),
(102, 2, 0, '1000000', '1297032'),
(103, 2, 0, '912485', '1.009.517'),
(104, 1, 1, '828116', '925.148'),
(105, 3, 0, '2070000', '2.070.000'),
(106, 2, 0, '912845', '1.049.877'),
(107, 4, 0, '3000000', '3000000'),
(108, 4, 0, '3000000', '3000000'),
(109, 2, 0, '1560000', '2.457.032'),
(110, 1, 0, '859916', '956.948'),
(111, 5, 1, '3000000', '4400000'),
(112, 0, 0, '885907', '982.939'),
(113, 1, 0, '828116', '925148'),
(114, 1, 0, '828116', '925.148'),
(115, 0, 0, '1000000', '1.097.032'),
(116, 2, 0, '1200000', '1.297.032');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salud`
--

CREATE TABLE `salud` (
  `idSalud` smallint(6) NOT NULL,
  `fuma` varchar(3) NOT NULL,
  `alcohol` varchar(15) NOT NULL,
  `descripccion_emergencia` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `salud`
--

INSERT INTO `salud` (`idSalud`, `fuma`, `alcohol`, `descripccion_emergencia`) VALUES
(1, '', 'RARA VEZ', 'Condromalacia'),
(2, '0', 'RARA VEZ', ''),
(3, '0', 'RARA VEZ', ''),
(4, '1', 'RARA VEZ', ''),
(5, '0', 'RARA VEZ', ''),
(6, '0', 'RARA VEZ', 'Migraña '),
(7, '0', 'RARA VEZ', 'Vertigo'),
(8, '', 'RARA VEZ', ''),
(9, '', 'RARA VEZ', ''),
(10, '0', 'RARA VEZ', ''),
(11, '', 'RARA VEZ', ''),
(12, '', 'RARA VEZ', ''),
(13, '', 'RARA VEZ', ''),
(14, '0', 'RARA VEZ', ''),
(15, '0', 'RARA VEZ', ''),
(16, '', 'RARA VEZ', 'Migraña Aguda'),
(17, '', 'RARA VEZ', ''),
(18, '0', '', ''),
(19, '0', 'RARA VEZ', ''),
(20, '', 'RARA VEZ', 'TEMBLOR ESCENCIAL'),
(21, '', 'RARA VEZ', ''),
(22, '', 'QUINCENAL', ''),
(23, '', 'RARA VEZ', 'Renitis'),
(24, '', 'RARA VEZ', ''),
(25, '0', 'RARA VEZ', ''),
(26, '0', 'RARA VEZ', ''),
(27, '0', 'RARA VEZ', ''),
(28, '', 'RARA VEZ', 'Embarazada'),
(29, '0', 'RARA VEZ', 'Asma'),
(30, '0', 'RARA VEZ', ''),
(31, '', 'RARA VEZ', ''),
(32, '0', '', ''),
(33, '', 'RARA VEZ', ''),
(34, '', 'RARA VEZ', ''),
(35, '', 'RARA VEZ', ''),
(36, '', 'RARA VEZ', ''),
(37, '', 'RARA VEZ', ''),
(38, '', 'RARA VEZ', 'Presion'),
(39, '0', 'RARA VEZ', 'Osteoartrosis'),
(40, '', 'RARA VEZ', 'Tiroides'),
(41, '', 'RARA VEZ', 'Asma'),
(42, '', 'RARA VEZ', ''),
(43, '', 'RARA VEZ', ''),
(44, '', 'RARA VEZ', 'Escapula halada'),
(45, '0', 'RARA VEZ', ''),
(46, '', 'RARA VEZ', ''),
(47, '0', 'RARA VEZ', ''),
(48, '', 'RARA VEZ', 'Hipertencia'),
(49, '0', 'RARA VEZ', ''),
(50, '', 'RARA VEZ', ''),
(51, '', 'RARA VEZ', ''),
(52, '', 'RARA VEZ', ''),
(53, '', 'RARA VEZ', ''),
(54, '', 'RARA VEZ', ''),
(55, '', 'RARA VEZ', ''),
(56, '', 'RARA VEZ', ''),
(57, '0', 'RARA VEZ', ''),
(58, '0', 'RARA VEZ', 'Renitis'),
(59, '', 'RARA VEZ', ''),
(60, '0', 'RARA VEZ', 'Migraña, Renitis'),
(61, '1', 'RARA VEZ', 'Admidalitis'),
(62, '0', 'RARA VEZ', ''),
(63, '3', 'QUINCENAL', 'ALERGICA A LA DIPIRONA-RENITIS'),
(64, '0', 'RARA VEZ', 'Migraña'),
(65, '', 'RARA VEZ', ''),
(66, '0', 'RARA VEZ', ''),
(67, '', 'RARA VEZ', 'Sinusitis'),
(68, '', 'RARA VEZ', 'Sindrome de colon irritable'),
(69, '0', 'RARA VEZ', ''),
(70, '0', 'RARA VEZ', ''),
(71, '', 'RARA VEZ', ''),
(72, '0', 'RARA VEZ', 'Alergico a la acetaminofen'),
(73, '', 'RARA VEZ', ''),
(74, '0', 'RARA VEZ', ''),
(75, '', 'RARA VEZ', ''),
(76, '0', 'RARA VEZ', ''),
(77, '', 'RARA VEZ', ''),
(78, '0', 'RARA VEZ', 'Migraña clasica'),
(79, '0', 'RARA VEZ', ''),
(80, '', 'RARA VEZ', ''),
(81, '0', '', 'Gastritis'),
(82, '', 'RARA VEZ', 'Migraña clasica'),
(83, '0', 'RARA VEZ', 'Sindrome de colon irritable'),
(84, '0', '', ''),
(85, '0', 'RARA VEZ', ''),
(86, '0', 'RARA VEZ', 'Migraña, Renitis'),
(87, '0', 'RARA VEZ', ''),
(88, '0', 'RARA VEZ', ''),
(89, '0', 'RARA VEZ', ''),
(90, '', 'RARA VEZ', ''),
(91, '', 'RARA VEZ', ''),
(92, '0', 'RARA VEZ', 'N/A'),
(93, '', 'RARA VEZ', ''),
(94, '0', 'RARA VEZ', ''),
(95, '0', 'RARA VEZ', ''),
(96, '0', 'RARA VEZ', ''),
(97, '0', 'RARA VEZ', ''),
(98, '0', 'RARA VEZ', ''),
(99, '0', 'RARA VEZ', ''),
(100, '0', 'RARA VEZ', ''),
(101, '0', '', 'Alérgica a la Penicilina.'),
(102, '0', '', ''),
(103, '', 'RARA VEZ', ''),
(104, '', 'RARA VEZ', ''),
(105, '', 'RARA VEZ', ''),
(106, '', 'RARA VEZ', ''),
(107, '0', '', 'Presión baja '),
(108, '0', '', ''),
(109, '', 'RARA VEZ', 'FIBROMIALGIA (EN ESTUDIO)'),
(110, '', 'RARA VEZ', ''),
(111, '0', '', 'HIPERTENSION (Losartan y Anlodipino)'),
(112, '', 'SEMANAL', ''),
(113, '0', '', ''),
(114, '', 'RARA VEZ', ''),
(115, '', '0', 'Hipoglucemia, Disautonomia(desmayo): en caso de esto colocar los pies en tren de lembur y cuando reaccione darle un baso de agua y una cucharada de sal.,toma medicamento como: levotiroxina 75mg: control tiroides, Alérgica al tramadol.'),
(116, '', 'RARA VEZ', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `secundaria_basica`
--

CREATE TABLE `secundaria_basica` (
  `idSecundaria_basica` smallint(6) NOT NULL,
  `idEstado_civil` tinyint(4) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `lugar_nacimiento` varchar(50) NOT NULL,
  `tel_fijo` varchar(7) DEFAULT NULL,
  `celular` varchar(10) DEFAULT NULL,
  `idTipo_sangre` tinyint(4) NOT NULL,
  `idEPS` tinyint(4) NOT NULL,
  `idAFP` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `secundaria_basica`
--

INSERT INTO `secundaria_basica` (`idSecundaria_basica`, `idEstado_civil`, `fecha_nacimiento`, `lugar_nacimiento`, `tel_fijo`, `celular`, `idTipo_sangre`, `idEPS`, `idAFP`) VALUES
(1, 1, '1994-05-05', 'Medellin', '4984725', '3207365480', 1, 15, 1),
(2, 1, '1987-11-01', 'Medellin', '', '3002306243', 6, 15, 4),
(3, 1, '1996-01-19', 'Medellin', '', '3142991538', 7, 6, 7),
(4, 1, '1994-01-14', 'Medellin', '4815549', '3127125042', 1, 5, 7),
(5, 1, '1997-05-02', 'Medellin', '', '3007485462', 5, 15, 1),
(6, 1, '1992-09-15', 'Apartado', '', '3012034717', 1, 15, 4),
(7, 4, '1994-03-25', 'Apartado', '3615324', '3108384718', 1, 15, 1),
(8, 1, '1993-01-16', 'Medellin', '', '3008307424', 1, 15, 4),
(9, 4, '1986-02-27', 'Medellin', '2913280', '3002311915', 1, 15, 4),
(10, 5, '1987-04-25', 'Medellin', '6011163', '3194038630', 5, 15, 4),
(11, 2, '1989-12-24', 'Medellin', '3083201', '3003179487', 1, 5, 4),
(12, 1, '1993-12-18', 'Medellin', '', '3023498890', 1, 15, 7),
(13, 1, '1988-04-25', 'Caldas', '2785768', '3008389692', 1, 15, 4),
(14, 2, '1990-08-21', 'Medellin', '5367241', '3136555216', 1, 15, 4),
(15, 1, '1994-01-20', 'Montebello ATQ', '', '3128488495', 1, 3, 4),
(16, 1, '1997-06-16', 'San carlos ANT', '', '3137559850', 1, 15, 4),
(17, 1, '1991-11-15', 'Medellin', '3014838', '3234205142', 5, 15, 4),
(18, 2, '1987-10-27', 'Medellin', '6004002', '3207826711', 2, 15, 4),
(19, 1, '1994-10-19', 'Medellin', '', '3117112570', 5, 15, 4),
(20, 4, '1996-01-11', 'SEGOVIA ', '', '3223918276', 1, 15, 4),
(21, 4, '1992-04-09', 'Novita choco', '5071699', '3218770877', 7, 6, 1),
(22, 1, '1998-10-13', 'Cucuta', '', '3022489104', 1, 5, 4),
(23, 1, '1986-11-19', 'Bucaramanga', '', '3202495966', 1, 5, 1),
(24, 1, '1996-01-31', 'Barrancabermeja', '', '3115522214', 1, 3, 1),
(25, 2, '1986-09-24', 'Medellin', '3417282', '3217256729', 7, 15, 4),
(26, 2, '1986-09-16', 'Medellin', '5062355', '3013913749', 5, 15, 4),
(27, 1, '1988-07-03', 'Alejandria', '4617955', '3184519696', 5, 3, 4),
(28, 1, '1998-02-02', 'Fredonia ANT', '', '3106912014', 5, 7, 4),
(29, 1, '1995-10-30', 'Betania ANT', '', '3126916744', 2, 15, 4),
(30, 1, '1994-11-22', 'Medellin', '5842737', '3012750931', 1, 5, 4),
(31, 1, '1995-11-09', 'Medellin', '4382393', '3116548744', 1, 15, 6),
(32, 1, '1993-12-16', 'Medellin', '5036721', '3013662008', 1, 15, 4),
(33, 1, '1994-01-09', 'Concordia', '5090615', '3206590121', 1, 15, 4),
(34, 1, '1998-11-30', 'Itagui', '2528099', '3004991084', 1, 14, 1),
(35, 1, '1980-06-29', 'Urrao ANT', '', '3024024210', 1, 7, 4),
(36, 2, '1981-02-26', 'Urrao', '3433885', '3104253624', 5, 15, 7),
(37, 2, '1980-12-18', 'Medellin', '2062186', '3217089908', 1, 15, 7),
(38, 1, '1976-08-19', 'Medellin', '', '3128233166', 1, 3, 4),
(39, 2, '1983-06-10', 'Medellin', '4873684', '3217342469', 2, 15, 4),
(40, 2, '1984-02-11', 'Guadalupe ANT', '', '3117096070', 5, 7, 4),
(41, 5, '1983-05-27', 'Itagui', '4510976', '3148103452', 5, 15, 4),
(42, 5, '1981-04-06', 'Medellin', '', '3016551303', 5, 15, 4),
(43, 1, '1979-04-17', 'Andes ANT', '4981958', '3008689894', 5, 15, 4),
(44, 2, '1969-10-06', 'Yarumal ANT', '2143601', '3207498310', 3, 15, 7),
(45, 2, '1975-08-06', 'Medellin', '6066522', '3003430558', 1, 15, 4),
(46, 1, '1976-04-27', 'Anori', '', '3005899516', 1, 15, 4),
(47, 1, '1978-12-10', 'Medellin', '3721241', '3008643202', 5, 15, 7),
(48, 1, '1979-08-05', 'Medellin', '2362705', '3146068880', 5, 15, 6),
(49, 1, '1983-07-02', 'Medellin', '', '3164928830', 1, 15, 7),
(50, 2, '1984-01-21', 'Medellin', '', '3103759115', 8, 15, 4),
(51, 1, '1966-01-28', 'San alejandro ANT', '4772838', '3146714453', 1, 15, 4),
(52, 1, '1982-10-12', 'Ituango', '4433643', '3148436336', 1, 15, 4),
(53, 2, '1983-02-23', 'Medellin', '2971944', '3017448026', 1, 15, 4),
(54, 2, '1989-11-01', 'Venezuela', '484469', '3014718448', 5, 15, 1),
(55, 1, '1981-03-09', 'Medellin', '2794663', '3116023982', 7, 15, 4),
(56, 2, '1979-06-27', 'Medellin', '2840162', '3008357312', 3, 15, 1),
(57, 1, '1982-12-01', 'Medellin', '4519016', '3012723726', 1, 15, 4),
(58, 1, '1985-09-15', 'Medellin', '2622006', '3145279324', 1, 15, 4),
(59, 2, '1985-12-21', 'Medellin', '3422269', '3046654545', 1, 7, 2),
(60, 4, '1989-02-17', 'Fredonia ANT', '', '3122286855', 1, 6, 4),
(61, 1, '1993-03-17', 'Medellin', '', '3106970189', 1, 15, 4),
(62, 1, '1996-10-06', 'Bello ', '2375690', '3046800617', 5, 15, 7),
(63, 1, '1989-08-12', 'Medellín', '2867172', '3165046127', 1, 15, 4),
(64, 1, '1997-01-19', 'Ituango', '', '3046420826', 1, 15, 1),
(65, 1, '1986-02-09', 'Medellin', '2112310', '3045510501', 2, 3, 4),
(66, 1, '1989-11-08', 'Medellin', '', '3116800501', 1, 15, 4),
(67, 1, '1990-07-22', 'Medellin', '3878078', '3016994593', 1, 15, 4),
(68, 1, '1994-12-08', 'Medellin', '2695438', '3128908496', 1, 15, 1),
(69, 1, '1990-04-04', 'Medellin', '4815549', '3015173893', 5, 15, 4),
(70, 1, '1994-09-26', 'Medellin', '4779035', '3054840457', 1, 14, 1),
(71, 1, '1986-02-18', 'Itagui', '6024465', '3226630378', 5, 15, 4),
(72, 2, '1987-10-18', 'Medellin', '2815623', '3015332365', 1, 15, 2),
(73, 4, '1989-02-16', 'Medellin', '2087941', '3137404753', 5, 5, 1),
(74, 1, '1998-08-10', 'Itagui', '3280991', '3016993232', 5, 5, 4),
(75, 1, '1996-12-28', 'Puerto nare', '5363096', '3197195419', 1, 15, 4),
(76, 4, '1993-04-21', 'Cartagena', '', '3002833559', 1, 6, 4),
(77, 1, '1994-07-22', 'Bello ', '2564610', '3206045934', 5, 15, 4),
(78, 1, '1993-12-17', 'Medellin', '', '3006822774', 1, 16, 4),
(79, 1, '1995-12-30', 'Medellin', '5092144', '3016503710', 5, 15, 4),
(80, 1, '1982-02-08', 'Cali', '', '3174119188', 5, 5, 4),
(81, 1, '1968-05-24', 'Urrao ', '4569445', '3176712939', 1, 15, 7),
(82, 1, '1985-07-06', 'El bagre ATQ', '4615008', '3113840371', 1, 3, 7),
(83, 4, '1975-11-12', 'Medellin', '', '3104463170', 5, 15, 2),
(84, 1, '1992-05-08', 'Medellin', '4997569', '3207097347', 5, 17, 4),
(85, 1, '1990-12-28', 'Itagui', '4982490', '3103721434', 5, 15, 4),
(86, 1, '1995-05-17', 'Medellin', '2501614', '3146241477', 7, 15, 4),
(87, 1, '1986-07-22', 'Medellin', '5847460', '3012952274', 1, 6, 4),
(88, 2, '1978-06-12', 'Lorica cordoba', '', '3012883630', 5, 15, 1),
(89, 1, '1983-10-10', 'Medellin', '3343465', '3004469658', 1, 7, 4),
(90, 2, '1986-01-09', 'Medellin', '3873432', '3013389190', 1, 15, 4),
(91, 4, '1984-01-09', 'Medellin', '5594581', '3153962190', 7, 15, 4),
(92, 1, '1989-07-02', 'Donmatias Antioquia', '', '3017995910', 2, 15, 4),
(93, 1, '1984-06-25', 'Betulia', '4948894', '3113554302', 1, 15, 1),
(94, 2, '1981-01-13', 'Medellin', '', '3173598569', 1, 15, 4),
(95, 1, '1994-10-20', 'Itagui', '5842847', '3016663785', 1, 15, 4),
(96, 1, '1991-10-27', 'Iatgui', '6006121', '3146644565', 5, 5, 4),
(97, 2, '1976-10-11', 'Medellin', '3174314', '3148818739', 5, 15, 7),
(98, 1, '1994-01-29', 'Medellín', '3729315', '3017240103', 7, 15, 4),
(99, 2, '1977-02-17', 'Medellín', '5052599', '3006171432', 2, 15, 4),
(100, 2, '1969-03-06', 'Medellín', '4883496', '3006202817', 5, 7, 7),
(101, 1, '1979-10-29', 'Medellin', '', '3116380840', 7, 15, 1),
(102, 2, '1991-12-04', 'Medellín', '3875607', '3014370385', 5, 15, 4),
(103, 1, '1989-06-07', 'Medellín', '3770281', '3007866627', 2, 15, 4),
(104, 4, '1995-03-22', 'Venezuela', '5773336', '3045218806', 1, 7, 4),
(105, 1, '0000-00-00', 'Aguadas Caldas', '', '3012714334', 1, 7, 4),
(106, 4, '1984-11-30', 'Bogotá', '', '3123930306', 1, 15, 4),
(107, 2, '1974-03-01', 'Medellin', '5791704', '3006171694', 5, 15, 3),
(108, 2, '1972-02-26', 'Medellin', '5791704', '3006171422', 2, 15, 7),
(109, 2, '1981-08-28', 'Medellin', '5703631', '3012002309', 5, 15, 4),
(110, 4, '1994-05-05', 'Medellin', '2271688', '3216042540', 1, 15, 4),
(111, 2, '1975-12-16', 'MEDELLIN', '5394688', '3004981190', 2, 15, 4),
(112, 2, '1948-05-20', 'Medellin', '4442652', '3014000871', 2, 15, 4),
(113, 1, '2000-01-24', 'Medellin', '5381802', '3017176163', 1, 15, 4),
(114, 1, '2001-01-04', 'Porce', '', '3003954845', 1, 14, 4),
(115, 1, '1992-03-05', 'Itagui', '2976468', '3168664410', 5, 15, 4),
(116, 1, '1995-06-13', 'Venezuela ', '', '3215943380', 1, 15, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tablet_piso`
--

CREATE TABLE `tablet_piso` (
  `idtablet_piso` int(11) NOT NULL,
  `direccion` varchar(15) NOT NULL,
  `piso` varchar(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tablet_piso`
--

INSERT INTO `tablet_piso` (`idtablet_piso`, `direccion`, `piso`) VALUES
(2, '192.168.4.127', '5'),
(3, '192.168.5.223', '1'),
(4, '192.168.4.227', '4'),
(5, '192.168.4.204', '5'),
(7, '192.168.4.244', '4'),
(8, '192.168.4.226', '4'),
(9, '192.168.4.173', '2'),
(11, '192.168.5.221', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_auxilio`
--

CREATE TABLE `tipo_auxilio` (
  `idTipo_auxilio` tinyint(4) NOT NULL,
  `auxilio` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_auxilio`
--

INSERT INTO `tipo_auxilio` (`idTipo_auxilio`, `auxilio`, `estado`) VALUES
(1, 'Auxilio de Transporte', 1),
(2, 'Auxilio de gasolina', 1),
(3, 'Auxilio de Alimentación', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_contrato`
--

CREATE TABLE `tipo_contrato` (
  `idTipo_contrato` tinyint(4) NOT NULL,
  `contrato` varchar(45) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_contrato`
--

INSERT INTO `tipo_contrato` (`idTipo_contrato`, `contrato`, `estado`) VALUES
(1, 'Fijo', 1),
(2, 'Indefinido', 1),
(3, 'Aprendizaje', 1),
(4, 'En misión', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_evento`
--

CREATE TABLE `tipo_evento` (
  `idTipo_evento` tinyint(4) NOT NULL,
  `nombre` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_evento`
--

INSERT INTO `tipo_evento` (`idTipo_evento`, `nombre`) VALUES
(1, 'Laboral'),
(2, 'Desayuno'),
(3, 'Almuerzo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_notificacion`
--

CREATE TABLE `tipo_notificacion` (
  `idTipo_notificacion` tinyint(4) NOT NULL,
  `notificacion` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_notificacion`
--

INSERT INTO `tipo_notificacion` (`idTipo_notificacion`, `notificacion`) VALUES
(1, 'Cumpleaños'),
(2, 'Aniversario'),
(3, 'Contrato'),
(4, 'llegadas Tarde'),
(5, 'Nuevo usuario');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_sangre`
--

CREATE TABLE `tipo_sangre` (
  `idTipo_sangre` tinyint(4) NOT NULL,
  `nombre` varchar(3) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_sangre`
--

INSERT INTO `tipo_sangre` (`idTipo_sangre`, `nombre`, `estado`) VALUES
(1, 'O+', 1),
(2, 'O-', 1),
(3, 'AB+', 1),
(4, 'AB-', 1),
(5, 'A+', 1),
(6, 'A-', 1),
(7, 'B+', 1),
(8, 'B-', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_usuario`
--

CREATE TABLE `tipo_usuario` (
  `idTipo_usuario` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_usuario`
--

INSERT INTO `tipo_usuario` (`idTipo_usuario`, `nombre`) VALUES
(1, 'Operario'),
(2, 'Empleado'),
(3, 'Gestor Alimentacion'),
(4, 'Gestor Pedidos'),
(5, 'Gestor Humano'),
(6, 'Facilitador'),
(7, 'Líder de producción');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_vivienda`
--

CREATE TABLE `tipo_vivienda` (
  `idTipo_vivienda` tinyint(4) NOT NULL,
  `nombre` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_vivienda`
--

INSERT INTO `tipo_vivienda` (`idTipo_vivienda`, `nombre`) VALUES
(1, 'Propia'),
(2, 'Familiar'),
(3, 'Alquilada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` tinyint(4) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `contraseña` varchar(100) NOT NULL,
  `email` varchar(200) NOT NULL DEFAULT '-',
  `idTipo_usuario` tinyint(4) NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `nombre`, `contraseña`, `email`, `idTipo_usuario`, `estado`) VALUES
(1, 'Marulanda', 'MTIz', 'juan.marulanda@colcircuitos.com;jdmarulanda0@misena.edu.co', 3, 1),
(3, 'Empleado', 'MTIz', '-', 2, 1),
(4, 'gestor_pedidos', 'MTIz', '-', 4, 1),
(6, 'aracellyospina', 'bWFpbC5jb2wy', '-', 3, 1),
(7, 'GestorHumano', 'MTIzNDU2', 'Auxiliargestionhumana@Colcircuitos.com', 5, 1),
(21, 'Jhoana Marulanda', 'MTAzNzU4NzgzNA==', '-', 6, 0),
(22, 'GestionHumana', 'NzQyNA==', 'gestionhumana@colcircuitos.com;auxiliargestionhumana@colcircuitos.com', 5, 1),
(23, 'Contabilidad', 'Q29sLnVzZXI=', '-', 3, 1),
(24, 'Yazmin', 'MTAxNzE1NjQyNA==', 'yazmin1987@gmail.com', 6, 1),
(25, 'Gloria', 'NDM5NzUyMDg=', 'gloria.jaramillo@colcircuitos.com', 6, 1),
(26, 'Sebastian Gallego', 'MTAyMDQ3OTU1NA==', 'gallegosebastian11042014@gmail.com', 6, 0),
(27, 'Geraldyn', 'MTAzNzk0OTY5Ng==', 'auxiliargestionhumana@colcircuitos.com', 5, 0),
(28, 'Viviana Echavarria', 'NDM1ODMzOTg=', '-', 7, 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `actividad`
--
ALTER TABLE `actividad`
  ADD PRIMARY KEY (`idActividad`);

--
-- Indices de la tabla `actividades_timpo_libre`
--
ALTER TABLE `actividades_timpo_libre`
  ADD PRIMARY KEY (`idActividades_timpo_libre`,`idPersonal`,`idActividades`),
  ADD KEY `fk_Actividades_timpo_libre_Personal1_idx` (`idPersonal`),
  ADD KEY `fk_Actividades_timpo_libre_table11_idx` (`idActividades`);

--
-- Indices de la tabla `afp`
--
ALTER TABLE `afp`
  ADD PRIMARY KEY (`idAFP`);

--
-- Indices de la tabla `area_trabajo`
--
ALTER TABLE `area_trabajo`
  ADD PRIMARY KEY (`idArea_trabajo`);

--
-- Indices de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD PRIMARY KEY (`idAsistencia`,`documento`,`idTipo_evento`,`idEstado_asistencia`),
  ADD KEY `fk_Asistencia_Empleado_idx` (`documento`),
  ADD KEY `fk_Asistencia_Estado_asistencia1_idx` (`idEstado_asistencia`),
  ADD KEY `fk_Asistencia_Tipo_evento1` (`idTipo_evento`),
  ADD KEY `fk_asistencia_configuracion` (`idConfiguracion`);

--
-- Indices de la tabla `auxilio`
--
ALTER TABLE `auxilio`
  ADD PRIMARY KEY (`idAuxilio`,`idTipo_auxilio`,`idSalarial`),
  ADD KEY `fk_Auxilio_Tipo_auxilio1_idx` (`idTipo_auxilio`),
  ADD KEY `fk_Auxilio_Salarial1_idx` (`idSalarial`);

--
-- Indices de la tabla `cargo`
--
ALTER TABLE `cargo`
  ADD PRIMARY KEY (`idCargo`);

--
-- Indices de la tabla `clasificacion_contable`
--
ALTER TABLE `clasificacion_contable`
  ADD PRIMARY KEY (`idClasificacion_contable`);

--
-- Indices de la tabla `clasificacion_mega`
--
ALTER TABLE `clasificacion_mega`
  ADD PRIMARY KEY (`idClasificacion_mega`);

--
-- Indices de la tabla `concepto`
--
ALTER TABLE `concepto`
  ADD PRIMARY KEY (`idConcepto`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`idConfiguracion`);

--
-- Indices de la tabla `diagnostico`
--
ALTER TABLE `diagnostico`
  ADD PRIMARY KEY (`idDiagnostico`);

--
-- Indices de la tabla `dias_festivos`
--
ALTER TABLE `dias_festivos`
  ADD PRIMARY KEY (`iddias_festivos`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`documento`,`idEmpresa`),
  ADD KEY `fk_Empleado_Empresa1_idx` (`idEmpresa`),
  ADD KEY `fk_rol_empelado` (`idRol`);

--
-- Indices de la tabla `empleado_horario`
--
ALTER TABLE `empleado_horario`
  ADD PRIMARY KEY (`idEmpleado_horario`),
  ADD KEY `fk_empleado_horario` (`documento`),
  ADD KEY `fk_configuracion_horario` (`idConfiguracion`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`idEmpresa`);

--
-- Indices de la tabla `envio_pedido`
--
ALTER TABLE `envio_pedido`
  ADD PRIMARY KEY (`idEnvio_pedido`),
  ADD KEY `fk_envio_proveedor` (`idProveedor`);

--
-- Indices de la tabla `eps`
--
ALTER TABLE `eps`
  ADD PRIMARY KEY (`idEPS`);

--
-- Indices de la tabla `estado_asistencia`
--
ALTER TABLE `estado_asistencia`
  ADD PRIMARY KEY (`idEstado_asistencia`);

--
-- Indices de la tabla `estado_civil`
--
ALTER TABLE `estado_civil`
  ADD PRIMARY KEY (`idEstado_civil`);

--
-- Indices de la tabla `estado_empresarial`
--
ALTER TABLE `estado_empresarial`
  ADD PRIMARY KEY (`idEstado_empresarial`,`idFicha_SD`,`idIndicador_rotacion`),
  ADD KEY `fk_Estado_empresarial_Ficha_SD1_idx` (`idFicha_SD`),
  ADD KEY `fk_estado_empresa` (`idEmpresa`);

--
-- Indices de la tabla `estudios`
--
ALTER TABLE `estudios`
  ADD PRIMARY KEY (`idEstudios`,`idGrado_escolaridad`),
  ADD KEY `fk_Estudios_Grado_escolaridad1_idx` (`idGrado_escolaridad`);

--
-- Indices de la tabla `evento_laboral`
--
ALTER TABLE `evento_laboral`
  ADD PRIMARY KEY (`idEvento_laboral`);

--
-- Indices de la tabla `examenes_medicos`
--
ALTER TABLE `examenes_medicos`
  ADD PRIMARY KEY (`idexamenes_Medicos`),
  ADD KEY `fk_empleado_examen` (`documento`);

--
-- Indices de la tabla `ficha_sd`
--
ALTER TABLE `ficha_sd`
  ADD PRIMARY KEY (`idFicha_SD`,`documento`,`idSalarial`,`idLaboral`,`idEstudios`,`idSecundaria_basica`,`idPersonal`,`idSalud`,`idOtros`),
  ADD KEY `fk_Ficha_SD_Empleado1_idx` (`documento`),
  ADD KEY `fk_Ficha_SD_Salarial1_idx` (`idSalarial`),
  ADD KEY `fk_Ficha_SD_Laboral1_idx` (`idLaboral`),
  ADD KEY `fk_Ficha_SD_Estudios1_idx` (`idEstudios`),
  ADD KEY `fk_Ficha_SD_Secundaria_basica1_idx` (`idSecundaria_basica`),
  ADD KEY `fk_Ficha_SD_Personal1_idx` (`idPersonal`),
  ADD KEY `fk_Ficha_SD_Salud1_idx` (`idSalud`),
  ADD KEY `fk_Ficha_SD_Otros1_idx` (`idOtros`);

--
-- Indices de la tabla `grado_escolaridad`
--
ALTER TABLE `grado_escolaridad`
  ADD PRIMARY KEY (`idGrado_escolaridad`);

--
-- Indices de la tabla `horario_permiso`
--
ALTER TABLE `horario_permiso`
  ADD PRIMARY KEY (`idHorario_permiso`);

--
-- Indices de la tabla `horario_trabajo`
--
ALTER TABLE `horario_trabajo`
  ADD PRIMARY KEY (`idHorario_trabajo`);

--
-- Indices de la tabla `h_laboral`
--
ALTER TABLE `h_laboral`
  ADD PRIMARY KEY (`idH_laboral`,`documento`,`idEvento_laboral`),
  ADD KEY `fk_H_laboral_Evento_laboral1_idx` (`idEvento_laboral`),
  ADD KEY `fk_H_laboral_Empleado1_idx` (`documento`);

--
-- Indices de la tabla `incapacidad`
--
ALTER TABLE `incapacidad`
  ADD PRIMARY KEY (`idIncapacidad`,`documento`,`Diagnostico_idDiagnostico`),
  ADD KEY `fk_Incapacidad_Empleado1_idx` (`documento`),
  ADD KEY `fk_Incapacidad_Diagnostico1_idx` (`Diagnostico_idDiagnostico`);

--
-- Indices de la tabla `indicador_rotacion`
--
ALTER TABLE `indicador_rotacion`
  ADD PRIMARY KEY (`idIndicador_rotacion`);

--
-- Indices de la tabla `laboral`
--
ALTER TABLE `laboral`
  ADD PRIMARY KEY (`idLaboral`,`idHorario_trabajo`,`idArea_trabajo`,`idCargo`,`idTipo_contrato`),
  ADD KEY `fk_Laboral_Horario_trabajo1_idx` (`idHorario_trabajo`),
  ADD KEY `fk_Laboral_Area_trabajo1_idx` (`idArea_trabajo`),
  ADD KEY `fk_Laboral_Cargo1_idx` (`idCargo`),
  ADD KEY `fk_Laboral_Tipo_contrato1_idx` (`idTipo_contrato`),
  ADD KEY `fk_clasificacion_laboral` (`idClasificacion_contable`);

--
-- Indices de la tabla `lineas_pedido`
--
ALTER TABLE `lineas_pedido`
  ADD PRIMARY KEY (`idLineas_pedido`,`idPedido`,`idProducto`),
  ADD KEY `fk_Lineas_pedido_Pedido1_idx` (`idPedido`),
  ADD KEY `fk_Lineas_pedido_Producto1_idx` (`idProducto`),
  ADD KEY `fk_momento_lineas` (`idMomento`);

--
-- Indices de la tabla `momento`
--
ALTER TABLE `momento`
  ADD PRIMARY KEY (`idmomento`);

--
-- Indices de la tabla `motivo`
--
ALTER TABLE `motivo`
  ADD PRIMARY KEY (`idMotivo`);

--
-- Indices de la tabla `municipio`
--
ALTER TABLE `municipio`
  ADD PRIMARY KEY (`idMunicipio`);

--
-- Indices de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD PRIMARY KEY (`idNotificacion`,`idUsuario`,`idTipo_notificacion`),
  ADD KEY `fk_Notificacion_Usuario1_idx` (`idUsuario`),
  ADD KEY `fk_Notificacion_Tipo_notificacion1_idx` (`idTipo_notificacion`);

--
-- Indices de la tabla `otros`
--
ALTER TABLE `otros`
  ADD PRIMARY KEY (`idOtros`);

--
-- Indices de la tabla `parentezco`
--
ALTER TABLE `parentezco`
  ADD PRIMARY KEY (`idParentezco`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`idPedido`,`documento`),
  ADD KEY `fk_Pedido_Empleado1_idx` (`documento`);

--
-- Indices de la tabla `permiso`
--
ALTER TABLE `permiso`
  ADD PRIMARY KEY (`idPermiso`,`idConcepto`),
  ADD KEY `fk_Permiso_Concepto1_idx` (`idConcepto`),
  ADD KEY `fk_empleado_permiso` (`documento`),
  ADD KEY `fk_horario_permiso_permiso` (`idHorario_permiso`);

--
-- Indices de la tabla `personal`
--
ALTER TABLE `personal`
  ADD PRIMARY KEY (`idPersonal`,`idMunicipio`,`idTipo_vivienda`),
  ADD KEY `fk_Personal_Municipio1_idx` (`idMunicipio`),
  ADD KEY `fk_Personal_Tipo_vivienda1_idx` (`idTipo_vivienda`);

--
-- Indices de la tabla `personas_vive`
--
ALTER TABLE `personas_vive`
  ADD PRIMARY KEY (`idPersonas_vive`,`idParentezco`,`idPersonal`),
  ADD KEY `fk_Personas_vive_Parentezco1_idx` (`idParentezco`),
  ADD KEY `fk_Personas_vive_Personal1_idx` (`idPersonal`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idProducto`,`idProveedor`),
  ADD KEY `fk_Producto_Proveedor1_idx` (`idProveedor`);

--
-- Indices de la tabla `promedio_salario`
--
ALTER TABLE `promedio_salario`
  ADD PRIMARY KEY (`idPromedio_salario`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`idProveedor`);

--
-- Indices de la tabla `restriccion`
--
ALTER TABLE `restriccion`
  ADD PRIMARY KEY (`idRestriccion`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idRol`);

--
-- Indices de la tabla `salarial`
--
ALTER TABLE `salarial`
  ADD PRIMARY KEY (`idSalarial`);

--
-- Indices de la tabla `salud`
--
ALTER TABLE `salud`
  ADD PRIMARY KEY (`idSalud`);

--
-- Indices de la tabla `secundaria_basica`
--
ALTER TABLE `secundaria_basica`
  ADD PRIMARY KEY (`idSecundaria_basica`,`idEstado_civil`,`idTipo_sangre`,`idEPS`,`idAFP`),
  ADD KEY `fk_Secundaria_basica_Estado_civil1_idx` (`idEstado_civil`),
  ADD KEY `fk_Secundaria_basica_Tipo_sangre1_idx` (`idTipo_sangre`),
  ADD KEY `fk_Secundaria_basica_EPS1_idx` (`idEPS`),
  ADD KEY `fk_Secundaria_basica_AFP1_idx` (`idAFP`);

--
-- Indices de la tabla `tablet_piso`
--
ALTER TABLE `tablet_piso`
  ADD PRIMARY KEY (`idtablet_piso`);

--
-- Indices de la tabla `tipo_auxilio`
--
ALTER TABLE `tipo_auxilio`
  ADD PRIMARY KEY (`idTipo_auxilio`);

--
-- Indices de la tabla `tipo_contrato`
--
ALTER TABLE `tipo_contrato`
  ADD PRIMARY KEY (`idTipo_contrato`);

--
-- Indices de la tabla `tipo_evento`
--
ALTER TABLE `tipo_evento`
  ADD PRIMARY KEY (`idTipo_evento`);

--
-- Indices de la tabla `tipo_notificacion`
--
ALTER TABLE `tipo_notificacion`
  ADD PRIMARY KEY (`idTipo_notificacion`);

--
-- Indices de la tabla `tipo_sangre`
--
ALTER TABLE `tipo_sangre`
  ADD PRIMARY KEY (`idTipo_sangre`);

--
-- Indices de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  ADD PRIMARY KEY (`idTipo_usuario`);

--
-- Indices de la tabla `tipo_vivienda`
--
ALTER TABLE `tipo_vivienda`
  ADD PRIMARY KEY (`idTipo_vivienda`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`,`idTipo_usuario`),
  ADD KEY `fk_Usuario_Tipo_usuario1_idx` (`idTipo_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `actividad`
--
ALTER TABLE `actividad`
  MODIFY `idActividad` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `actividades_timpo_libre`
--
ALTER TABLE `actividades_timpo_libre`
  MODIFY `idActividades_timpo_libre` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=713;

--
-- AUTO_INCREMENT de la tabla `afp`
--
ALTER TABLE `afp`
  MODIFY `idAFP` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `area_trabajo`
--
ALTER TABLE `area_trabajo`
  MODIFY `idArea_trabajo` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  MODIFY `idAsistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT de la tabla `auxilio`
--
ALTER TABLE `auxilio`
  MODIFY `idAuxilio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;

--
-- AUTO_INCREMENT de la tabla `cargo`
--
ALTER TABLE `cargo`
  MODIFY `idCargo` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT de la tabla `clasificacion_contable`
--
ALTER TABLE `clasificacion_contable`
  MODIFY `idClasificacion_contable` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `clasificacion_mega`
--
ALTER TABLE `clasificacion_mega`
  MODIFY `idClasificacion_mega` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `concepto`
--
ALTER TABLE `concepto`
  MODIFY `idConcepto` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `idConfiguracion` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `dias_festivos`
--
ALTER TABLE `dias_festivos`
  MODIFY `iddias_festivos` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `empleado_horario`
--
ALTER TABLE `empleado_horario`
  MODIFY `idEmpleado_horario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `idEmpresa` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `envio_pedido`
--
ALTER TABLE `envio_pedido`
  MODIFY `idEnvio_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=903;

--
-- AUTO_INCREMENT de la tabla `eps`
--
ALTER TABLE `eps`
  MODIFY `idEPS` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `estado_asistencia`
--
ALTER TABLE `estado_asistencia`
  MODIFY `idEstado_asistencia` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `estado_civil`
--
ALTER TABLE `estado_civil`
  MODIFY `idEstado_civil` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `estado_empresarial`
--
ALTER TABLE `estado_empresarial`
  MODIFY `idEstado_empresarial` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=187;

--
-- AUTO_INCREMENT de la tabla `estudios`
--
ALTER TABLE `estudios`
  MODIFY `idEstudios` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT de la tabla `evento_laboral`
--
ALTER TABLE `evento_laboral`
  MODIFY `idEvento_laboral` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `examenes_medicos`
--
ALTER TABLE `examenes_medicos`
  MODIFY `idexamenes_Medicos` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ficha_sd`
--
ALTER TABLE `ficha_sd`
  MODIFY `idFicha_SD` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `grado_escolaridad`
--
ALTER TABLE `grado_escolaridad`
  MODIFY `idGrado_escolaridad` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `horario_permiso`
--
ALTER TABLE `horario_permiso`
  MODIFY `idHorario_permiso` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `horario_trabajo`
--
ALTER TABLE `horario_trabajo`
  MODIFY `idHorario_trabajo` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `h_laboral`
--
ALTER TABLE `h_laboral`
  MODIFY `idH_laboral` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `incapacidad`
--
ALTER TABLE `incapacidad`
  MODIFY `idIncapacidad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT de la tabla `indicador_rotacion`
--
ALTER TABLE `indicador_rotacion`
  MODIFY `idIndicador_rotacion` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `laboral`
--
ALTER TABLE `laboral`
  MODIFY `idLaboral` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT de la tabla `lineas_pedido`
--
ALTER TABLE `lineas_pedido`
  MODIFY `idLineas_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5424;

--
-- AUTO_INCREMENT de la tabla `momento`
--
ALTER TABLE `momento`
  MODIFY `idmomento` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `motivo`
--
ALTER TABLE `motivo`
  MODIFY `idMotivo` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `municipio`
--
ALTER TABLE `municipio`
  MODIFY `idMunicipio` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `notificacion`
--
ALTER TABLE `notificacion`
  MODIFY `idNotificacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=356;

--
-- AUTO_INCREMENT de la tabla `otros`
--
ALTER TABLE `otros`
  MODIFY `idOtros` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `parentezco`
--
ALTER TABLE `parentezco`
  MODIFY `idParentezco` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `idPedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3258;

--
-- AUTO_INCREMENT de la tabla `permiso`
--
ALTER TABLE `permiso`
  MODIFY `idPermiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `personal`
--
ALTER TABLE `personal`
  MODIFY `idPersonal` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `personas_vive`
--
ALTER TABLE `personas_vive`
  MODIFY `idPersonas_vive` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=784;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idProducto` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT de la tabla `promedio_salario`
--
ALTER TABLE `promedio_salario`
  MODIFY `idPromedio_salario` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `idProveedor` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `restriccion`
--
ALTER TABLE `restriccion`
  MODIFY `idRestriccion` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `idRol` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `salarial`
--
ALTER TABLE `salarial`
  MODIFY `idSalarial` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `salud`
--
ALTER TABLE `salud`
  MODIFY `idSalud` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `secundaria_basica`
--
ALTER TABLE `secundaria_basica`
  MODIFY `idSecundaria_basica` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;

--
-- AUTO_INCREMENT de la tabla `tablet_piso`
--
ALTER TABLE `tablet_piso`
  MODIFY `idtablet_piso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `tipo_auxilio`
--
ALTER TABLE `tipo_auxilio`
  MODIFY `idTipo_auxilio` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_contrato`
--
ALTER TABLE `tipo_contrato`
  MODIFY `idTipo_contrato` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tipo_evento`
--
ALTER TABLE `tipo_evento`
  MODIFY `idTipo_evento` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_notificacion`
--
ALTER TABLE `tipo_notificacion`
  MODIFY `idTipo_notificacion` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tipo_sangre`
--
ALTER TABLE `tipo_sangre`
  MODIFY `idTipo_sangre` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  MODIFY `idTipo_usuario` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `tipo_vivienda`
--
ALTER TABLE `tipo_vivienda`
  MODIFY `idTipo_vivienda` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `actividades_timpo_libre`
--
ALTER TABLE `actividades_timpo_libre`
  ADD CONSTRAINT `fk_Actividades_timpo_libre_Personal1` FOREIGN KEY (`idPersonal`) REFERENCES `personal` (`idPersonal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Actividades_timpo_libre_table11` FOREIGN KEY (`idActividades`) REFERENCES `actividad` (`idActividad`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD CONSTRAINT `fk_Asistencia_Empleado` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Asistencia_Estado_asistencia1` FOREIGN KEY (`idEstado_asistencia`) REFERENCES `estado_asistencia` (`idEstado_asistencia`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Asistencia_Tipo_evento1` FOREIGN KEY (`idTipo_evento`) REFERENCES `tipo_evento` (`idTipo_evento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_asistencia_configuracion` FOREIGN KEY (`idConfiguracion`) REFERENCES `configuracion` (`idConfiguracion`);

--
-- Filtros para la tabla `auxilio`
--
ALTER TABLE `auxilio`
  ADD CONSTRAINT `fk_Auxilio_Salarial1` FOREIGN KEY (`idSalarial`) REFERENCES `salarial` (`idSalarial`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Auxilio_Tipo_auxilio1` FOREIGN KEY (`idTipo_auxilio`) REFERENCES `tipo_auxilio` (`idTipo_auxilio`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD CONSTRAINT `fk_Empleado_Empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_rol_empelado` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`);

--
-- Filtros para la tabla `empleado_horario`
--
ALTER TABLE `empleado_horario`
  ADD CONSTRAINT `fk_configuracion_horario` FOREIGN KEY (`idConfiguracion`) REFERENCES `configuracion` (`idConfiguracion`),
  ADD CONSTRAINT `fk_empleado_horario` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`);

--
-- Filtros para la tabla `envio_pedido`
--
ALTER TABLE `envio_pedido`
  ADD CONSTRAINT `fk_envio_proveedor` FOREIGN KEY (`idProveedor`) REFERENCES `proveedor` (`idProveedor`);

--
-- Filtros para la tabla `estado_empresarial`
--
ALTER TABLE `estado_empresarial`
  ADD CONSTRAINT `fk_Estado_empresarial_Ficha_SD1` FOREIGN KEY (`idFicha_SD`) REFERENCES `ficha_sd` (`idFicha_SD`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_estado_empresa` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`);

--
-- Filtros para la tabla `estudios`
--
ALTER TABLE `estudios`
  ADD CONSTRAINT `fk_Estudios_Grado_escolaridad1` FOREIGN KEY (`idGrado_escolaridad`) REFERENCES `grado_escolaridad` (`idGrado_escolaridad`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `examenes_medicos`
--
ALTER TABLE `examenes_medicos`
  ADD CONSTRAINT `fk_empleado_examen` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`);

--
-- Filtros para la tabla `ficha_sd`
--
ALTER TABLE `ficha_sd`
  ADD CONSTRAINT `fk_Ficha_SD_Empleado1` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Estudios1` FOREIGN KEY (`idEstudios`) REFERENCES `estudios` (`idEstudios`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Laboral1` FOREIGN KEY (`idLaboral`) REFERENCES `laboral` (`idLaboral`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Otros1` FOREIGN KEY (`idOtros`) REFERENCES `otros` (`idOtros`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Personal1` FOREIGN KEY (`idPersonal`) REFERENCES `personal` (`idPersonal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Salarial1` FOREIGN KEY (`idSalarial`) REFERENCES `salarial` (`idSalarial`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Salud1` FOREIGN KEY (`idSalud`) REFERENCES `salud` (`idSalud`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Ficha_SD_Secundaria_basica1` FOREIGN KEY (`idSecundaria_basica`) REFERENCES `secundaria_basica` (`idSecundaria_basica`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `h_laboral`
--
ALTER TABLE `h_laboral`
  ADD CONSTRAINT `fk_H_laboral_Empleado1` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_H_laboral_Evento_laboral1` FOREIGN KEY (`idEvento_laboral`) REFERENCES `evento_laboral` (`idEvento_laboral`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `incapacidad`
--
ALTER TABLE `incapacidad`
  ADD CONSTRAINT `fk_Incapacidad_Diagnostico1` FOREIGN KEY (`Diagnostico_idDiagnostico`) REFERENCES `diagnostico` (`idDiagnostico`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Incapacidad_Empleado1` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `laboral`
--
ALTER TABLE `laboral`
  ADD CONSTRAINT `fk_Laboral_Area_trabajo1` FOREIGN KEY (`idArea_trabajo`) REFERENCES `area_trabajo` (`idArea_trabajo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Laboral_Cargo1` FOREIGN KEY (`idCargo`) REFERENCES `cargo` (`idCargo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Laboral_Horario_trabajo1` FOREIGN KEY (`idHorario_trabajo`) REFERENCES `horario_trabajo` (`idHorario_trabajo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Laboral_Tipo_contrato1` FOREIGN KEY (`idTipo_contrato`) REFERENCES `tipo_contrato` (`idTipo_contrato`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_clasificacion_laboral` FOREIGN KEY (`idClasificacion_contable`) REFERENCES `clasificacion_contable` (`idClasificacion_contable`);

--
-- Filtros para la tabla `lineas_pedido`
--
ALTER TABLE `lineas_pedido`
  ADD CONSTRAINT `fk_Lineas_pedido_Pedido1` FOREIGN KEY (`idPedido`) REFERENCES `pedido` (`idPedido`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Lineas_pedido_Producto1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_momento_lineas` FOREIGN KEY (`idMomento`) REFERENCES `momento` (`idmomento`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `notificacion`
--
ALTER TABLE `notificacion`
  ADD CONSTRAINT `fk_Notificacion_Tipo_notificacion1` FOREIGN KEY (`idTipo_notificacion`) REFERENCES `tipo_notificacion` (`idTipo_notificacion`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Notificacion_Usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `fk_Pedido_Empleado1` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `permiso`
--
ALTER TABLE `permiso`
  ADD CONSTRAINT `fk_Permiso_Concepto1` FOREIGN KEY (`idConcepto`) REFERENCES `concepto` (`idConcepto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_empleado_permiso` FOREIGN KEY (`documento`) REFERENCES `empleado` (`documento`),
  ADD CONSTRAINT `fk_horario_permiso_permiso` FOREIGN KEY (`idHorario_permiso`) REFERENCES `horario_permiso` (`idHorario_permiso`);

--
-- Filtros para la tabla `personal`
--
ALTER TABLE `personal`
  ADD CONSTRAINT `fk_Personal_Municipio1` FOREIGN KEY (`idMunicipio`) REFERENCES `municipio` (`idMunicipio`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Personal_Tipo_vivienda1` FOREIGN KEY (`idTipo_vivienda`) REFERENCES `tipo_vivienda` (`idTipo_vivienda`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `personas_vive`
--
ALTER TABLE `personas_vive`
  ADD CONSTRAINT `fk_Personas_vive_Parentezco1` FOREIGN KEY (`idParentezco`) REFERENCES `parentezco` (`idParentezco`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Personas_vive_Personal1` FOREIGN KEY (`idPersonal`) REFERENCES `personal` (`idPersonal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_Producto_Proveedor1` FOREIGN KEY (`idProveedor`) REFERENCES `proveedor` (`idProveedor`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `secundaria_basica`
--
ALTER TABLE `secundaria_basica`
  ADD CONSTRAINT `fk_Secundaria_basica_AFP1` FOREIGN KEY (`idAFP`) REFERENCES `afp` (`idAFP`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Secundaria_basica_EPS1` FOREIGN KEY (`idEPS`) REFERENCES `eps` (`idEPS`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Secundaria_basica_Estado_civil1` FOREIGN KEY (`idEstado_civil`) REFERENCES `estado_civil` (`idEstado_civil`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Secundaria_basica_Tipo_sangre1` FOREIGN KEY (`idTipo_sangre`) REFERENCES `tipo_sangre` (`idTipo_sangre`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_Usuario_Tipo_usuario1` FOREIGN KEY (`idTipo_usuario`) REFERENCES `tipo_usuario` (`idTipo_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
