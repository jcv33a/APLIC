********************************************************************************
*-- Nombre..: FACTURA2.PRG
*-- Fecha...: 10-09-90
*-- Versi¢n.: dBASE IV, Formatos 1.0
*-- Notas...: ­Los ficheros de formato usan "" como delimitadores!
********************************************************************************

CLEAR WIND
CLOSE DATABASE
SAVE SCREEN TO Factura2
CLEAR

DEFINE WINDOW Pause FROM 15,00 TO 19,79 DOUBLE
DEFINE WINDOW Fact_hlp FROM 3,00 TO 21,79 DOUBLE
ON ERROR DO Pause WITH "N£mero de l¡nea del programa "+Program()+": "+LTRIM(STR(LINE()))

IF EOF()
  SKIP -1
ENDIF

IF SET("TALK")="ON"
   SET TALK OFF
   lc_talk = "ON"
ELSE
   lc_talk = "OFF"
ENDIF
lc_escape = SET("ESCAPE")
lc_cursor = SET("CURSOR")
SET CURSOR OFF

*-- C¢digo importado de C:\DBASE\EJEMPLOS\FACTURA2.QBE
* DBASE IV .QBE FILE 
SET FIELDS TO
SELECT 1
USE TRANSACC.DBF 
USE CLIENTES.DBF IN 2 ORDER COD_CLIENT
SET RELATION TO A->COD_CLIENT INTO B
SET FIELDS TO A->COD_CLIENT,A->COD_PED,A->FECH_TRANS,A->FACTURADO,A->;
TOTAL_CTA,B->CLIENT,B->APELLIDO,B->NOMBRE,B->DIRECCION,B->CIUDAD,B->;
PROVINCIA,B->COD_POST,B->TELEFONO,B->HIST_CLI
*-------------------------------------------------------------------------------
GO TOP


lc_status = SET("STATUS")
*-- SET STATUS estaba ON cuando se entr¢ en el Dise¤ador de Pantallas.
IF lc_status = "OFF"
   SET STATUS ON
ENDIF

gc_messg = "F9:L¡neas | PgDn:Sig. | PgUp:Ant. | Ctrl-PgDn:Final | Ctrl-PgUp:Principio"
 
*-- Ventana para el campo memo Hist_cli.
DEFINE WINDOW wndow1 FROM 7,26 TO 20,78 

DEFINE WINDOW Table FROM 9,1 TO 20,78 DOUBLE

ON KEY LABEL F1 DO Fact_hlp
ON KEY LABEL F9  KEYBOARD CHR(23)+"L" && Manda Ctrl-W + L para l¡nea
ON KEY LABEL F10 KEYBOARD CHR(23)+"M" && Manda Ctrl-W + M para el Men£

DO Defnmenu

gc_mdx = MDX(1)
gc_alias = ALIAS()

*-- Establece el  rea de trabajo de las l¡neas de detalle (BROWSE) ------------

gn_sele = IIF(SELE()=10, SELE()-1, SELE())
SELE (gn_sele)
USE EXISTEN ORDER TAG COD_PED
SET FIELDS TO COD_PED, COD_ART,NOM_ART,DESCRIP,CAN,COSTE_UNI,TOTAL=COSTE_UNI*CAN
SET CARRY TO EXISTEN->COD_PED

*------------------------------------------------------------------------------

SELE &gc_alias.
gn_gorec = 0                          && Variable para la opci¢n desplazar
gc_search = SPACE(200)                && Variable para b£squeda delante y atr s
gc_seek = SPACE( LEN( COD_PED))       && Variable para buscar registros
gl_newrec = .f.                        && Variable para el registro a¤adido
gl_chgrec = .t.           && Var. para probar si cambi¢ la posici¢n del registro
gl_extloop = .f.
gl_rollbck = .f.
@ 23,0
@ 23,CENTER(gc_messg,80) SAY gc_messg

DO WHILE .NOT. gl_extloop
   gn_recno = RECNO()
   gl_lineitm = .T.
   BEGIN TRANSACTION

   DO WHILE gl_lineitm
       IF gl_chgrec
          *-- Dispone los SAYs y GETs en la pantalla
          DO Show_get
       ENDIF

       *-- Muestra los datos de la tabla de l¡neas de detalle
       DO Showbrow
       *-- Vuelve a edici¢n

       *-- Edici¢n de GETs
       DO Edit_get

       SET CURSOR ON
       READ
       SET CURSOR OFF

       gn_inkey = INKEY()
       gn_readkey = READKEY()
       gc_readvar = VARREAD()
       gl_lineitm = .F.

       ACTIVATE SCREEN
       DO CASE
         CASE gn_inkey = 76
           *-- Se ha introducido mediante el mandato KEYBOARD la letra "L"
           DO Lineitem
           gl_lineitm = .T.
         CASE gn_inkey = 77
           *-- Se ha introducido mediante el mandato KEYBOARD la letra "M"
           ACTIVATE MENU Editmenu
         CASE gn_readkey = 6 .OR. gn_readkey = 262 .OR. gn_readkey = 260 ;
              .OR. gn_readkey = 4
           *--  Pgup o flecha del cursor hacia arriba
           IF .NOT. BOF()
             SKIP -1
           ENDIF
         CASE gn_readkey = 7 .OR. gn_readkey = 263 .OR. gn_readkey = 5 ;
              .OR. gn_readkey = 261
           *-- PgDn o flecha del cursor hacia abajo
           SKIP
           IF EOF() .AND. .NOT. gl_newrec
              CLEAR GETS
              SET DELI OFF
              @ 23,0
              @ 23,25 SAY "===> ¨A¤adir nuevos registros? (S/N) " GET gl_newrec PICT "S"
              READ
              SET DELI ON
              CLEAR GETS
              @ 23,0
              @ 23,CENTER( gc_messg, 80) SAY gc_messg
           ENDIF
           IF gl_newrec
              DO Recappnd
           ELSE
              IF EOF()
                 SKIP -1
              ENDIF
           ENDIF
         CASE gn_readkey = 34 .OR. gn_readkey = 290
           *-- Ctrl-PgUp
           GO TOP
         CASE gn_readkey = 35 .OR. gn_readkey = 291
           *-- Ctrl-PgDn
           GO BOTTOM
         CASE gn_readkey = 12  .or. gn_readkey = 270
           *-- Esc
           gl_extloop = .T.
           EXIT
       ENDCASE
       *
       gl_chgrec = IIF(gn_recno = RECNO(), .F., .T.)  && Ver si cambia el n£m. de reg.
       *
       IF gl_rollbck              && Si el usuario escogi¢ la opci¢n Cancelar del men£
          gl_rollbck = .F.        && se reinicializa la variable de cancelaci¢n.
          ROLLBACK
       ENDIF
   ENDDO
   *
   END TRANSACTION
   *
   IF .NOT. ROLLBACK()
      DO Pause WITH "No ha sido posible la cancelaci¢n"
      ACTIVATE SCREEN
   ENDIF
   DO Chkdele
ENDDO

*-- Restauraci¢n del entorno al salir
*-- SET STATUS estaba ON cuando se entr¢ en el Dise¤ador de Pantallas.
IF lc_status = "OFF" && Al entrar en este formato de pantalla status estaba off
   SET STATUS OFF    && Restaura STATUS "OFF" al abandonar el programa
ENDIF
SET CURSOR &lc_cursor.
SET TALK &lc_talk.

ON KEY
ON ERROR

SELE 1
CLOSE DATABASE

RELEASE MENU Editmenu
RELEASE POPUPS records, go_to, exit
RELEASE WINDOWS table,pause,seek,search,bsearch,Fact_hlp,wndow1
RESTORE SCREEN FROM factura2
RELEASE lc_talk,lc_fields,lc_status,lc_escape
RELEASE SCREEN factura2
RETURN

PROCEDURE Show_get
   @ 1,0 TO 21,79 COLOR gr+/b 
   @ 1,28 SAY " Sistema de Facturaci¢n " COLOR r+/b  
   @ 3,2 SAY "Cliente:"  
   @ 3,11 GET Clientes->Client PICTURE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
   @ 3,56 SAY "Cliente N§:"  
   @ 3,70 GET Transacc->Cod_client PICTURE "!XXXXX" 
   @ 4,2 SAY "Nombre:"  
   @ 4,11 GET Clientes->Apellido PICTURE "XXXXXXXXXXXXXXX" 
   @ 4,28 GET Clientes->Nombre PICTURE "XXXXXXXXXXXXXXX" 
   @ 4,56 SAY "Pedido N§:"  
   @ 4,70 GET Transacc->Cod_ped PICTURE "XX-XXX" 
   @ 5,2 SAY "Direcc.:"  
   @ 5,11 GET Clientes->Direccion PICTURE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
   @ 5,56 SAY "Fecha Pedido:"  
   @ 5,70 GET Transacc->Fech_trans 
   @ 6,2 SAY "Ciudad:"  
   @ 6,11 GET Clientes->Ciudad PICTURE "XXXXXXXXXXXXXXXXXXXX" 
   @ 6,35 SAY "Prov:"  
   @ 6,43 GET Clientes->Provincia PICTURE "!!" 
   @ 6,48 SAY "C.P.:"  
   @ 6,54 GET Clientes->Cod_post PICTURE "XXXXXXXXXX" 
   @ 7,2 SAY "Tel‚f.:"  
   @ 7,11 GET Clientes->Telefono PICTURE "XXXXXXXXXXXXX" 
   @ 7,35 SAY "Historial:"  
   @ 7,46 GET Clientes->Hist_cli WINDOW Wndow1 
   CLEAR GETS
RETURN

PROCEDURE Edit_get
   @ 3,11 GET Clientes->Client PICTURE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
   @ 3,70 GET Transacc->Cod_client PICTURE "!XXXXX" 
   @ 4,11 GET Clientes->Apellido PICTURE "XXXXXXXXXXXXXXX" 
   @ 4,28 GET Clientes->Nombre PICTURE "XXXXXXXXXXXXXXX" 
   @ 4,70 GET Transacc->Cod_ped PICTURE "XX-XXX" 
   @ 5,11 GET Clientes->Direccion PICTURE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
   @ 5,70 GET Transacc->Fech_trans 
   @ 6,11 GET Clientes->Ciudad PICTURE "XXXXXXXXXXXXXXXXXXXX" 
   @ 6,43 GET Clientes->Provincia PICTURE "!!" 
   @ 6,54 GET Clientes->Cod_post PICTURE "XXXXXXXXXX" 
   @ 7,11 GET Clientes->Telefono PICTURE "XXXXXXXXXXXXX" 
   @ 7,46 GET Clientes->Hist_cli WINDOW Wndow1 
RETURN

PROCEDURE Showbrow
   SELE EXISTEN
   SET FILTER TO
   SEEK &GC_ALIAS.->COD_PED
   IF EOF()
      APPEND BLANK
      REPLACE EXISTEN->COD_PED WITH &GC_ALIAS.->COD_PED
   ENDIF
   SET FILTER TO &GC_ALIAS.->COD_PED = EXISTEN->COD_PED
   GO TOP
   KEYBOARD CHR(27)
   DO Browseit
   SELE &gc_alias.
   ACTIVATE SCREEN
RETURN

PROCEDURE Lineitem
   ln_key = INKEY()
   DO Keykill
   SELE EXISTEN
   APPEND BLANK
   REPLACE EXISTEN->COD_PED WITH &GC_ALIAS.->COD_PED
   GO TOP
   DO Browseit
   ACTIVATE SCREEN
   DO Keyset
   *----------------------------------------------------------------------------
   *-- Se podr¡a poner c¢digo aqu¡ para sumar el balance del pedido y rellenar
   *-- un campo de total. Ejemplo:
   *-- SUM ALL importe TO m->importe
   *-- REPLACE &gc_alias.->Total_neto WITH m->importe
   *----------------------------------------------------------------------------
   SELE &gc_alias.
RETURN

PROCEDURE Browseit
SET CURSOR ON
BROWSE;
  FIELDS COD_ART,NOM_ART/12,DESCRIP/20,CAN,COSTE_UNI,TOTAL=COSTE_UNI*CAN,EXISTEN->COD_PED /R;
  WINDOW table COMPRESS NOMENU NOCLEAR
SET CURSOR OFF
RETURN

PROCEDURE Keyset
   ON KEY LABEL F1 DO Fact_hlp
   ON KEY LABEL F9  KEYBOARD CHR(23)+"L"
   ON KEY LABEL F10 KEYBOARD CHR(23)+"M"
RETURN

PROCEDURE Keykill
   ON KEY LABEL F1 DO Nothing
   ON KEY LABEL F9 DO Nothing
   ON KEY LABEL F10 DO Nothing
RETURN

PROCEDURE Nothing
   ln_key=INKEY()
RETURN

PROCEDURE Chkdele
  IF DELETED()
     DEFINE BAR 4 OF records PROMPT "   Quitar marca de borrado";
     MESSAGE "Marcar/Quitar marca para borrado a este registro"
  ELSE
     DEFINE BAR 4 OF records PROMPT "   Marcar registro para borrado";
     MESSAGE "Marcar/Quitar marca para borrado a este registro"
  ENDIF
RETURN

PROCEDURE Recappnd
   *------------------------------------------------------------------------
   *-- Se podr¡a poner c¢digo aqu¡ para incrementar el n£mero de factura, etc.
   GO BOTT
   morder = ORDER_ID
   APPEND BLANK
   REPLACE order_id WITH SUBSTR(morder,1,3) + LTRIM(STR(VAL(SUBSTR(morder,4))+1))
   *------------------------------------------------------------------------
RETURN

*-- Procedimientos que gestionan las selecciones del men£ de edici¢n ----------
PROCEDURE Get_recs
   *-- Acepta la selecci¢n del usuario y almacena BAR en una variable
   gn_pick = BAR()  && Variable para almacenar la opci¢n
   DO CASE
      CASE gn_pick = 1
         *-- Prepara variable para cancelar cambios al volver
         gl_rollbck = .T.
      CASE gn_pick = 3
          DO Recappnd
      CASE gn_pick = 4
         *-- Borrar/eliminar marca de borrado de registros
         IF DELETE()
            RECALL
            SELE EXISTEN
            RECALL ALL
         ELSE
            DELETE
            SELE EXISTEN
            DELETE ALL
         ENDIF
         SELE (gc_alias)
      CASE gn_pick = 5
         *-- Registro vac¡o
   ENDCASE
   DO Chkdele
   DEACTIVATE MENU
RETURN

PROCEDURE Get_goto
   *-- Acepta la selecci¢n del usuario y almacena BAR en una variable
   gn_pick = BAR()  && Variable para almacenar la opci¢n
   mpict = REPLICATE("9", LEN( LTRIM( STR( RECCOUNT()))))
   gc_search = gc_search + SPACE( 200 - LEN(gc_search))
   gc_seek = gc_seek + SPACE(LEN( COD_PED) - LEN(gc_seek))
   DO CASE
      CASE gn_pick = 1
         *-- Se sit£a en el principio del fichero
         GO TOP
      CASE gn_pick = 2
         *-- Se sit£a en el final del fichero
         GO BOTTOM
      CASE gn_pick = 3
         *-- Se situa en un registro espec¡fico
         @ 4,39 GET gn_gorec RANGE 1, RECCOUNT() PICTURE mpict
         READ
         gn_gorec = IIF( gn_gorec=0, RECNO(), gn_gorec)
         GO gn_gorec
      CASE gn_pick = 4
         *-- Salta un cierto n£mero de registros
         skiprec = IIF( RECCOUNT() > 9, 10, 5)
         SET DELI OFF
         @ 5,39 GET skiprec PICTURE mpict
         READ
         SET DELI ON
         SKIP skiprec
         IF EOF()
           SKIP -1
         ENDIF
      CASE gn_pick = 6
         ACTIVATE WINDOW seek
         *-- B£squeda por campo clave
         IF "" = ORDER()
            tempmdx = TAG(1)
            SET ORDER TO TAG &tempmdx.
         ENDIF
         @ 0,1 SAY "Introduzca serie a buscar"
         @ 1,1 SAY TAG(1)+":" GET gc_seek PICT "@S20";
           MESSAGE "Cancelar: Esc";
           VALID LEN( TRIM( gc_seek)) > 0;
           ERROR "No se ha indicado la serie a buscar"
         READ
         IF READKEY() <> 12
            gc_seek = LTRIM( TRIM(gc_seek))
            mrec = RECNO()
            SEEK gc_seek
            IF .NOT. FOUND()
               GO mrec
            ENDIF
         ENDIF
         DEACTIVATE WINDOW seek
         ACTIVATE SCREEN
      CASE gn_pick = 7
         *-- B£squeda hacia adelante
         ACTIVATE WINDOW search
         @ 0,1 SAY "Introduzca serie a buscar:" GET gc_search PICT "@S21";
           MESSAGE "Cancelar: Esc";
           VALID LEN( TRIM( gc_search)) > 0;
           ERROR "No se ha indicado la serie a buscar"
           READ
         DEACTIVATE WINDOW search
         ACTIVATE SCREEN
         IF READKEY() <> 12
            gc_search = LTRIM( RTRIM( gc_search))
            mrec = RECNO()
            LOCATE REST FOR &gc_search.
            IF .NOT. FOUND()
               GO mrec
            ENDIF
         ENDIF
      CASE gn_pick = 8
         *-- B£squeda hacia atr s
         ACTIVATE WINDOW bsearch
         @ 0,1 SAY "Introduzca serie a buscar:" GET gc_search PICT "@S21";
           MESSAGE "Cancelar: Esc";
           VALID len(trim(gc_search)) > 0;
           ERROR "No se ha indicado la serie a buscar"
         READ
         DEACTIVATE WINDOW bsearch
         ACTIVATE SCREEN
         IF READKEY() <> 12
            gc_search = LTRIM( RTRIM( gc_search))
            mrec = RECNO()
            DO WHILE .NOT. (BOF() .OR. &gc_search.)
               SKIP -1
            ENDDO
            IF BOF()
               GO mrec
            ENDIF
         ENDIF
  ENDCASE
  DEACTIVATE MENU
RETURN

PROCEDURE Get_exit
   CLEAR GETS
   *-- Prepara variable para salir del bucle
   gl_extloop = .T.
   DEACTIVATE MENU
RETURN

PROCEDURE Pause
PARAMETER lc_msg
*-- Par metros : lc_msg = l¡nea de mensajes
IF TYPE("lc_message")="U"
   gn_error=ERROR()
ENDIF
lc_msg = lc_msg
lc_option='0'
ACTIVATE WINDOW Pause
IF gn_error > 0
   IF TYPE("lc_message")="U"
      @ 0,1 SAY [­Error! - Mensaje: ]+MESSAGE()
   ELSE
      @ 0,1 SAY [Error n§ ]+lc_message
   ENDIF
ENDIF
@ 1,1 SAY lc_msg
WAIT " Pulse cualquier tecla para continuar..."
DEACTIVATE WINDOW Pause
RETURN

*-- Librer¡a de UDFs ----------------------------------------------------------
FUNCTION Center
*-- UDF para centrar una serie.
*-- lc_string = Serie para centrar
*-- ln_width = Ancho de la pantalla en la que se centra la serie
*--
*-- Ej.: La expresi¢n @ 15,center(serie,80) SAY serie
*-- centra la <serie> en una pantalla de 80 columnas
PARAMETER lc_string, ln_width
RETURN ((ln_width/2)-(LEN(lc_string)/2))
*-- Fin de la librer¡a de UDFs -----------------------------------------------

PROCEDURE Fact_hlp
gc_readvar = VARREAD()        && Puede proporcionar ayuda sensible al contexto
ACTIVATE WINDOW Fact_hlp
CLEAR
TEXT
    AYUDA para cursor:
    ------------------
    F1: Visualiza este mensaje
    F9: Accede a las l¡neas de detalle desde la cabecera de factura
    F10: Accede al sistema de men£s desde la cabecera de factura

    PgDn: Accede a la factura siguiente
    PgUp: Accede a la factura anterior
    Ctrl-PgDn: Accede a la £ltima factura de la base de datos
    Ctrl-PgUp: Accede a la primera factura de la base de datos
    Esc: Anula la factura
ENDTEXT
@ 16,5 say "Pulse cualquier tecla..."
x = INKEY(0)
CLEAR
TEXT
    AYUDA para l¡neas de detalle:
    -----------------------------
    F1: Visualiza este mensaje

    PgDn: Visualiza la siguiente pantalla de l¡neas de detalle
    PgUp: Visualiza la pantalla anterior de l¡neas de detalle
    Ctrl-PgDn: Accede a la £ltima pantalla de l¡neas de detalle
    Ctrl-PgUp: Accede a la primera pantalla de l¡neas de detalle
    Esc: Vuelve a la cabecera de factura
ENDTEXT
@ 16,5 say "Pulse cualquier tecla..."
x = INKEY(0)
DEACTIVATE WINDOW Fact_hlp
ACTIVATE SCREEN
RETURN

PROCEDURE Defnmenu
   *-- Este men£ simula para este programa de edici¢n el men£ F10 al que se
   *-- accede tras ejecutar el mandato EDIT. Aun as¡, no todas las opciones
   *-- pueden ser ejecutadas.
   SET BORDER TO DOUBLE

   DEFINE MENU editmenu
     DEFINE PAD records OF editmenu PROMPT "Registros" AT 0,2
       ON PAD records OF editmenu ACTIVATE POPUP records
     DEFINE PAD go_to OF editmenu PROMPT "Desplazar" AT 0,14
       ON PAD go_to OF editmenu ACTIVATE POPUP go_to
     DEFINE PAD exit OF editmenu PROMPT "Salir" AT 0,26
       ON PAD exit OF editmenu ACTIVATE POPUP exit

   * -- Definici¢n de los men£s de ventana
   DEFINE POPUP records FROM 1,0
     DEFINE BAR 1 OF records PROMPT "   Cancelar cambios en el registro";
     MESSAGE "Cancelar los cambios en el registro actual"
     DEFINE BAR 2 OF records PROMPT "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" SKIP
     DEFINE BAR 3 OF records PROMPT "   A¤adir nuevos registros";
     MESSAGE "A¤adir nuevos registros al final del fichero de base de datos"
     *-- La opci¢n 4 depende de si el registro est  marcado para borrado o no
     DO Chkdele  && El mandato Define Bar 4 est  en el procedimiento
     DEFINE BAR 5 OF records PROMPT "   Eliminar contenido del registro" SKIP ;
     MESSAGE "Eliminar el contenido de los campos de este registro"
     DEFINE BAR 6 OF records PROMPT "   Bloquear registro";
     MESSAGE " " SKIP
     DEFINE BAR 7 OF records PROMPT "   Situar registro en nueva posici¢n  SI" SKIP
   DEFINE POPUP go_to FROM 1,12
     DEFINE BAR 1 OF go_to PROMPT "   Primer registro";
     MESSAGE "Situarse en el primer registro de esta base de datos"
     DEFINE BAR 2 OF go_to PROMPT "   Ultimo registro";
     MESSAGE "Situarse en el £ltimo registro de esta base de datos"
     DEFINE BAR 3 OF go_to PROMPT "   N£mero de registro";
     MESSAGE "Situarse en el registro con el n£mero que indique"
     DEFINE BAR 4 OF go_to PROMPT "   Saltar";
     MESSAGE "Saltar el n£mero de registros indicado (signo menos para ir hacia atr s)"
     DEFINE BAR 5 OF go_to PROMPT "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" SKIP
     DEFINE BAR 6 OF go_to PROMPT "   B£squeda a trav‚s del ¡ndice"  SKIP FOR "" = gc_mdx;
     MESSAGE "Usar el fichero de ¡ndice para buscar la serie indicada"
     DEFINE BAR 7 OF go_to PROMPT "   Delante: b£squeda     ";
     MESSAGE "Buscar en este campo la serie indicada a partir del registro hacia el final"
     DEFINE BAR 8 OF go_to PROMPT "   Atr s: b£squeda       ";
     MESSAGE "Buscar en este campo la serie indicada a partir del registro hacia el principio"
     DEFINE BAR 9 OF go_to PROMPT "   May£sculas deben coincidir  NO" SKIP

   DEFINE POPUP exit FROM 1,24
     DEFINE BAR 1 OF exit PROMPT "   Salir";
     MESSAGE "Almacenar cambios en el registro actual y salir"
     DEFINE BAR 2 OF exit PROMPT "   Ir al Dise¤o de consulta  " SKIP

   ON SELECTION POPUP records DO Get_recs
   ON SELECTION POPUP go_to DO Get_goto
   ON SELECTION POPUP exit DO Get_exit

   DEFINE WINDOW seek FROM 8,15 TO 11,44
   DEFINE WINDOW search FROM 9,15 TO 11,66
   DEFINE WINDOW bsearch FROM 10,15 TO 12,66

   SHOW MENU Editmenu
RETURN
*---------------------------------------------------------------------------
*-- EOP: FACTURA2.PRG
