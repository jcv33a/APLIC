******************************************************************************
* PROGRAMA:                FACTURAS.PRG
*                          EJEMPLO DE INFORME PERSONALIZADO - FACTURAS
*                          GENERA FACTURAS Y ACTUALIZA MOV_CTAS.DBF
*                          APLICACION DE EJEMPLO GESTION
* ULTIMO CAMBIO:           09/25/89 09:26AM
* ESCRITO POR:             ASHTON-TATE
******************************************************************************
* Datos l¢gicos y algunos nombres de variables cambian despu‚s de generar informes
******************************************************************************
*
SET COLOR TO &c_normal.
CLEAR
answer    = "N"
inv_month = 0
@  6, 6 to 16,73 DOUBLE
@  8,31 SAY "IMPRESION DE INFORME"
@ 10,12 SAY "¨Est  seguro de que desea imprimir facturas (S/N) ?" ;
        GET answer PICTURE "Y"
@ 12, 8 SAY " **************************************************************"
@ 13, 8 SAY "    Se procesar n y alterar n los datos de : Mov_ctas      "
@ 14, 8 SAY "                                             Pedidos       "
READ
IF answer = "N"
   RETURN TO Gesti¢n
ELSE
   ?? CHR(7)
   inv_month = MONTH(DATE())-1
   @ 10, 8 CLEAR TO 14,72
   @ 12,12 SAY "¨De qu‚ mes desea generar facturas (01-12)?" ;
      GET inv_month PICTURE "99" RANGE 1,12
   READ
ENDIF

* Abrir bases de datos y seleccionar ¡ndices activos
SELECT 1
USE Pedidos   ORDER Pedido
USE Cli       ORDER C¢d_cli IN 2
USE Mov_ctas  ORDER C¢d_cli IN 3
USE Art¡culo  ORDER C¢d_art IN 4
* Crear una base de datos para generar facturas.
* Los registros ser n copiados en ‚l, y marcados para borrar en Pedidos.
IF .NOT. FILE("Archiv_o.dbf")
   COPY STRUCTURE TO Archiv_o
ENDIF
USE Archiv_o IN 5
* Relacionar bases de datos y activar la relaci¢n
SET RELATION TO C¢d_cli INTO Cli, C¢d_cli INTO Mov_ctas, C¢d_art INTO Art¡culo
GO TOP

* Ventana de mensajes de error
DEFINE WINDOW err_wndo FROM 16,3 TO 23,60 COLOR &c_pop.

* Si el usuario pulsa Esc durante la impresi¢n, salir
ON ESCAPE DO Stop_rpt

* Control de errores
ON ERROR DO Err_msg

* Establecer entorno
SET SPACE OFF
_plineno  =  0
_peject   = "NONE"
_pageno   = 1

* Inicializar variables
continu_on  = .T.               && Para continuar impresi¢n - Esc lo fija a .F.
complete = .F.
on_pg_line = 0                  && Linea en la que ON PAGE cambia de p gina
STORE 0  TO Imp_cta, Imp_fac, inv_amount, Balanc_ant
STORE 0  TO inv_count, ord_count, grand_tot, tot_Precio
STORE "" TO N£m_fac, mC¢d_cli, today, this_year, this_month
today      = DTOC(DATE())
this_year  = RIGHT(today,2)
this_month = LEFT(today,2)

* Calcular n§ de linea para cambio de p gina
on_pg_line = INT(_plength - 6)  && Altura menos pie y margen

* Establecer n§ de linea en la que ON PAGE act£a
ON PAGE AT LINE on_pg_line DO Page_brk

SET CONSOLE off
SET PRINTER on
*================================ Empezar tarea de impresi¢n ===========================
PRINTJOB
   * ====== Bucle de fichero - procesa registros seg£n ¡ndice activo =========
   * hasta fin de fichero o hasta que el usuario pulsa Esc (continu_on = .F.)
   * Genera todos las facturas no procesadas de un cliente determinado
   SCAN FOR .NOT. Facturado .AND. inv_month = MONTH(Fech_trans) ;
        WHILE continu_on
      mC¢d_cli = C¢d_cli
      DO Pg_head      && Imprimir cabecera de p gina por defecto
      DO Inv_head     && Imprimir cabecera de factura
      complete = .F.  && Marcar que las facturas de este cliente no est n generadas del todo
      * Imprimir pedidos para este cliente
      SCAN FOR .NOT. Facturado .AND. inv_month = MONTH(Fech_trans) ;
           WHILE C¢d_cli = mC¢d_cli .AND. continu_on
         DO Detail
      ENDSCAN
      complete = .T.  && Marcar que las facturas de este cliente est n generadas del todo
      SKIP -1         && Volver al £ltimo registro de clientes (ENDSCAN salta al siguiente)
      DO Cal_fact     && Imprimir factura para el £ltimo cliente
      EJECT PAGE      && Imprimir pie de factura - Pie_fact llamado por ON PAGE
      DO Updat_ar     && Actualizar Mov_ctas con los datos procesados
      DO Reinit       && Reinicializar variables de totalizaci¢n
   ENDSCAN
   IF continu_on
      * Fin del fichero - El usuario no puls¢ Esc para parar la impresi¢n
      message = "Facturas generadas e impresas. Facturaci¢n completa para el mes " ;
                + STR(inv_month,2)
   ELSE
      * No EOF - El usuario puls¢ Esc para parar la impresi¢n
      message = "Facturaci¢n incompleta - cancelada por el usuario a las " + TIME()
   ENDIF
   DO Rpt_end WITH message
   ON PAGE
ENDPRINTJOB
*============================= Fin de la tarea de impresi¢n ==================
EJECT PAGE
ON PAGE
SET CONSOLE on
SET PRINTER off
CLEAR
answer = " "
@  6, 6 to 15,74 DOUBLE
@  8,33 SAY "ARCHIVAR PEDIDOS"
@ 10,12 SAY "¨Quiere archivar los pedidos procesados (S/N)?" ;
        GET answer PICTURE "Y"
@ 12,10 SAY "*************************************************************"
@ 13, 7 SAY "(Copiar los pedidos procesados a un fichero borr ndolos de Pedidos)"
READ
IF answer = "S"
   ?? CHR(7)
   @ 10,12 SAY "COPIANDO los pedidos procesados...por favor espere     "
   @ 12,10 SAY SPACE(61)
   @ 13, 7 SAY SPACE(63)
   SELECT Archiv_o
   APPEND FROM Pedidos FOR Facturado
   SELECT Pedidos
   SET TALK on
   DELETE ALL FOR Facturado
   @ 10,10 SAY "BORRANDO los pedidos procesados...por favor espere"
   PACK
   SET TALK off
ELSE
   ?? CHR(7)
   @ 10, 7 CLEAR TO 14, 73
   @ 10,10 SAY "Los pedidos procesados no ser n borrados"
   @ 12,10 SAY "Pulse espaciador para continuar..."
   WAIT ""
ENDIF
ON ESCAPE
ON ERROR
CLOSE ALL
RETURN TO Gesti¢n
********************* FIN DEL PROCEDIMIENTO PRINCIPAL DE INFORME ************************

* PROCEDIMIENTOS DE UTILIDADES

PROCEDURE Detail
   * Imprimir apartado de detalle del informe
   ?? Fech_trans       AT 0,
   ?? C¢d_art          AT 10,
   ?? Art¡culo->Nom_art AT 21,
   ?? Can_art         AT 53 PICTURE "999",
   ?? Art¡culo->Precio     AT 58 PICTURE "9,999,999",
   * Importe
   tot_Precio  = ROUND(Can_art * Art¡culo->Precio,2)
   ?? tot_Precio        AT 70 PICTURE "9,999,999"
   ?
   * Cantidad total acumulada de la factura actual
   Imp_fac = Imp_fac + tot_Precio
   * Incrementar n£mero de pedidos procesados
   ord_count  = ord_count + 1
   * Actualizar "facturado" a .T. en Pedidos.dbf para este pedido
   REPLACE Facturado WITH .T.
RETURN

PROCEDURE Err_msg
   * Mensajes de error
   SET PRINTER off
   SET CONSOLE on
   ACTIVATE WINDOW err_wndo
      CLEAR
      ? "--------------------- AVISO DE ERROR -------------------"
      IF .NOT. PRINTSTATUS()
         * Error de impresora
         msg = "Error en impresora - no est  preparada o falta papel"
      ELSE
         * Error de causa desconocida - mostrar mensaje del sistema
         msg = MESSAGE()
      ENDIF
      ? " N£mero de error:", LTRIM(STR(ERROR(),4))
      ? " " + msg
      WAIT " Pulse espaciador para continuar..."
   DEACTIVATE WINDOW err_wndo
   SET CONSOLE off
   SET PRINTER on
RETURN

PROCEDURE Inv_calc
   * Imprimir datos calculados del cliente
   Imp_cta = Imp_fac + Balanc_ant
   ?? "----------" AT 69
   ?
   ?? "IMPORTE DE FACTURA" AT 0,
   ?? "ž" AT 66,
   ?? Imp_fac PICTURE "99,999,999" AT 69
   ?
   IF Balanc_ant <> 0
      ?? "----------" AT 69
      ? "+ BALANCE ANTERIOR"
      ?? Balanc_ant PICTURE "99,999,999" AT 69,
      ?
   ENDIF
   ?? "==========" AT 69
   ?
   ?? "CANTIDAD TOTAL DEBIDA" STYLE "B" AT 0,
   ?? "ž" STYLE "B" AT 66,
   ?? Imp_cta PICTURE "99,999,999" STYLE "B" AT 69
   ?
   ?? "==========" AT 69
   * Acumular cuentas totales para fin de informe
   grand_tot = grand_tot + Imp_cta
   ?
   ?
RETURN

PROCEDURE Inv_foot
   * Imprimir pie de p gina de la factura
   ?
   ? "FORMA DE PAGO: " AT 27,Cli->F_pago
   ?
   ? Mov_ctas->Notas  AT 18
   * Comenzar nueva p gina
   EJECT PAGE
RETURN

PROCEDURE Inv_head
   * C¢digo nuevo n£mero de factura
   N£m_fac = C¢d_cli + this_year + this_month
   * Incrementar contador de facturas
   inv_count  = inv_count + 1
   ?
   ?? "FACTURA N§: " STYLE "B" AT 0,
   ?? N£m_fac STYLE "B" FUNCTION "T" PICTURE "XXXXXXXXXX" ,
   ?? DATE() AT 69
   ?
   ?
   ?? "Cliente N§: " AT 0,
   ?? C¢d_cli FUNCTION "T" PICTURE "XXXXXX"
   ?
   ?
   ?? Cli->Cliente AT 0
   ?
   ?? Cli->Direcci¢n1 AT 0, Cli->Direcci¢n2 AT LEN(TRIM(Cli->Direcci¢n1))+2
   ?
   ?? Cli->Ciudad PICTURE "@T XXXXXXXXXXXXXXXXXXXX" AT 0,
   ?? ", ",
   ?? Cli->Provincia," ",
   ?? Cli->C¢d_post
   ?
   ?? "ATENCION: " AT 0 ,
   ?? Cli->Contacto PICTURE "@T XXXXXXXXXXXXXXXXXXXX","  ",
   ?? Cli->Tel_cont
   ?
   ?  REPLICATE(CHR(205),80)        && Dibujar l¡nea doble horizontal de 80 caracteres
   ?
   ?
   ?? "ESTADO ANTERIOR:" STYLE "BU" AT 0
   ?
   ?? "FACTURA N§:" AT 4, Mov_ctas->N£m_£ltfac AT 15
   ?? "FECHA:" AT 31, Mov_ctas->Fch_ultfac AT 37
   ?
   ?? "IMPORTE ž " AT 4, Mov_ctas->Imp_ultcta PICTURE "99,999,999" AT 15
   ?
   ?? "PAGADO  ž " AT 4, Mov_ctas->Imp_ultpag PICTURE "99,999,999" AT 15
   ?
   ?? "----------" AT 15
   ?
   ?? "BALANCE ž " AT 4
   Balanc_ant = Mov_ctas->Balanc_ant
   ?? Balanc_ant PICTURE "99,999,999" AT 15
   ?
   ?
   ?? "ESTADO ACTUAL:" STYLE "BU" AT 0
   ?  REPLICATE(CHR(196),80)        && Dibujar l¡nea doble horizontal de 80 caracters
   ?  "fecha"              AT 0
   ?? "N§ de art¡culo"     AT 10
   ?? "Nombre de art¡culo" AT 21
   ?? "Cant."              AT 53
   ?? "Precio"             AT 59
   ?? "Importe"            AT 74
   ?  REPLICATE(CHR(196),80)        && Dibujar l¡nea doble horizontal de 80 caracteres
   ?
RETURN

PROCEDURE Page_brk
   * Salto de p gina l¢gico - cuando la linea de detalle del informe = on_pg_line
   DO Inv_foot
   * Imprimir cabecera si la factura del cliente no se complet¢ en p gina anterior
   IF .NOT. EOF() .AND. .NOT. complete
      DO Pg_head
   ENDIF
RETURN

PROCEDURE Pg_head
   * Imprimir cabecera al principio de cada factura
   ?
   ?  "Pagina ",
   ?? _pageno PICTURE "999"
   ?
   ?
   ?  "A-T  INDUSTRIAS DEL MUEBLE" STYLE "B"   AT 27
   ?
   DEFINE BOX FROM 34 TO 45 HEIGHT 3 SINGLE
   ?
   ?? "FACTURA" STYLE "B" AT 36
   ?
   ?
   ?  REPLICATE(CHR(205),80)        && Dibujar l¡nea doble horizontal de 80 caracteres
   ?
RETURN

PROCEDURE Reinit
   * Reinicializar variables de acumulados para un cliente
   STORE 0 TO Imp_fac, inv_amount
   _pageno = 1
RETURN

PROCEDURE Rpt_end
   PARAMETERS message
   * Imprimir los datos de totalizaciones de fin de informe
   ?
   ?
   ?  "A-T  INDUSTRIAS DEL MUEBLE" STYLE "BU"   AT 27
   ?
   ?
   ?  "SUMARIO DE FACTURAS" STYLE "B" AT 30
   ?
   inv_Fecha = CTOD(STR(inv_month,2)+RIGHT(DTOC(DATE()),6))
   ?  "FOR MONTH of " AT 31, CMONTH(inv_Fecha)
   ?
   ?
   ?
   ?  REPLICATE(CHR(205),80)        && Dibujar l¡nea doble horizontal de 80 caracteres
   ?  DATE() AT 0 ,
   ?? TIME() AT 69
   ?  REPLICATE(CHR(205),80)        && Dibujar l¡nea doble horizontal de 80 caracteres
   ?
   ?
   ?
   ?
   ?? "===========" AT 67,
   ?
   ?? "IMPORTE TOTAL de" AT 0,
   ?? inv_count PICTURE "999",
   ?? " cuentas " AT 21,
   ?? "y ", ord_count PICTURE "9,999",
   ?? " Cuentas:",
   ?? "ž" AT 66,
   ?? grand_tot PICTURE "99,999,999" ,
   ?
   ?? "===========" AT 67
   ?
   ?
   ?
   ?  message AT 6
   ?
RETURN

PROCEDURE Stop_rpt
   continu_on = .F.   && Marcar la parada de impresi¢n a .F. si se puls¢ Esc
RETURN

PROCEDURE Updat_ar
   * Actualizar registro del fichero relacionado Mov_ctas para este cliente con los datos
   * procesados/calculados durante la facturaci¢n de los datos anteriores
   SELECT Mov_ctas
   IF Pedidos->C¢d_cli <> C¢d_cli
      * Si el cliente nunca hab¡a sido facturado antes, crear un AR registro de cliente
      APPEND BLANK
      REPLACE C¢d_cli WITH Pedidos->C¢d_cli
   ENDIF
   REPLACE N£m_£ltfac WITH N£m_fac, Fch_ultfac WITH Fecha_fac, ;
           Imp_ultpag WITH Imp_pag, Imp_ultcta WITH Imp_fac, ;
           Balanc_ant WITH Imp_ultcta - Imp_ultpag, Comentario WITH "", ;
           Notas WITH "", N£m_fac WITH m->N£m_fac, ;
           Fecha_fac WITH DATE(), Imp_fac WITH m->Imp_fac, ;
           Imp_cta WITH m->Imp_cta
   SELECT Pedidos
RETURN

*********************************** FIN DE FACTURAS.PRG *********************************
