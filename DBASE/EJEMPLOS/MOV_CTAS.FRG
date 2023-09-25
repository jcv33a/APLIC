* Programa...........: C:\X500SP\EJEMPLOS\MOV_CTAS.FRG
* Fecha..............: 10-31-90
* Versi¢n............: dBASE IV, Informes 1.1
*
* Notas:
* ------
* Antes de ejecutar este procedimiento con el mandato DO
* es necesario usar LOCATE, pues la sentencia CONTINUE
* est  en el bucle principal.
*
*-- Par metros
PARAMETERS gl_noeject, gl_plain, gl_summary, gc_heading, gc_extra
** Los tres primeros par metros son de tipo L¢gico.
** El cuarto es una serie y el quinto es un par metro adicional.
PRIVATE _peject, _wrap

*-- Comprueba si no se ha encontrado ning£n registro
IF EOF() .OR. .NOT. FOUND()
   RETURN
ENDIF

*-- desactiva la justificaci¢n entre m rgenes
_wrap=.F.

IF _plength < (_pspacing * 4 + 1) + (_pspacing * 3 + 1) + 2
   SET DEVICE TO SCREEN
   DEFINE WINDOW gw_report FROM 7,17 TO 11,62 DOUBLE
   ACTIVATE WINDOW gw_report
   @ 0,1 SAY "Aumente la longitud de p gina del informe."
   @ 2,1 SAY "Pulse una tecla..."
   x=INKEY(0)
   DEACTIVATE WINDOW gw_report
   RELEASE WINDOW gw_report
   RETURN
ENDIF

_plineno=0          && pone el n£mero de l¡nea a cero
*-- Par metro NOEJECT
IF gl_noeject
   IF _peject="BEFORE"
      _peject="NONE"
   ENDIF
   IF _peject="BOTH"
      _peject="AFTER"
   ENDIF
ENDIF

*-- Establecimiento del entorno
ON ESCAPE DO Prnabort
IF SET("TALK")="ON"
   SET TALK OFF
   gc_talk="ON"
ELSE
   gc_talk="OFF"
ENDIF
gc_space=SET("SPACE")
SET SPACE OFF
gc_time=TIME()      && tiempo del sistema para el campo predefinido
gd_date=DATE()      && fecha del sistema   "   "    "        "
gl_fandl=.F.        && indicador de primera y £ltima p gina
gl_prntflg=.T.      && indicador de continuar impresi¢n
gl_widow=.T.        && indicador de comprobar apartados viudos 
gn_length=LEN(gc_heading)  && almacena la longitud del encabezamiento (HEADING)
gn_level=2          && apartado actual en proceso
gn_page=_pageno     && captura el n£mero de p gina actual
gn_pspace=_pspacing && captura el interlineado de la p gina impresa actual


*-- Activa el procedimiento para el salto de p gina
gn_atline=_plength - (_pspacing * 3 + 1)
ON PAGE AT LINE gn_atline EJECT PAGE

*-- Imprime el informe

PRINTJOB

*-- Inicializa las variables del resumen.
r_msum1=0
r_msum2=0

IF gl_plain
   ON PAGE AT LINE gn_atline DO Pgplain
ELSE
   ON PAGE AT LINE gn_atline DO Pgfoot
ENDIF

DO Pghead

gl_fandl=.T.        && comienzo de la primera p gina f¡sica

DO Rintro

*-- Bucle de fichero
DO WHILE FOUND() .AND. .NOT. EOF() .AND. gl_prntflg
   gn_level=0
   *-- Cuerpo del informe
   IF gl_summary
      DO Upd_Vars
   ELSE
      DO __Detail
   ENDIF
   gl_widow=.T.         && activa la comprobaci¢n de apartados viudos
   CONTINUE
ENDDO

IF gl_prntflg
   DO Rsumm
   IF _plineno <= gn_atline
      EJECT PAGE
   ENDIF
ELSE
   DO Rsumm
   DO Reset
   RETURN
ENDIF

ON PAGE

ENDPRINTJOB

DO Reset
RETURN
* EOP: C:\X500SP\EJEMPLOS\MOV_CTAS.FRG

*-- Actualiza los campos resumen y/o los campos calculados.
PROCEDURE Upd_Vars
*-- Sumar
r_msum1=r_msum1+BALANC_ANT
*-- Sumar
r_msum2=r_msum2+IMP_CTA
RETURN
* EOP: Upd_Vars

*-- Desactiva el indicador para salir del bucle DO WHILE cuando se pulse ESC
PROCEDURE Prnabort
gl_prntflg=.F.
RETURN
* EOP: Prnabort

PROCEDURE Pghead
?
?? IIF(gl_plain,'',gd_date) AT 0,;
 "PAGINA  " AT 68,;
 IIF(gl_plain,'',_pageno) PICTURE "999" 
?
?
?

*-- Imprime el encabezamiento pasado como
*-- par metro de HEADING (REPORT FORM <nombre> HEADING <expC>)
IF .NOT. gl_plain .AND. gn_length > 0
   ?? gc_heading FUNCTION "I;V"+LTRIM(STR(_rmargin-_lmargin))
   ?
ENDIF
RETURN
* EOP: Pghead

PROCEDURE Rintro
?
DEFINE BOX FROM 23 TO 57 HEIGHT 4 DOUBLE
?
?? "A-T INDUSTRIAS DEL MUEBLE" STYLE "B" AT 28
?
?? "INFORME DE CUENTAS PENDIENTES" STYLE "B" AT 26
?
?
?
RETURN
* EOP: Rintro

PROCEDURE __Detail
IF 12 * gn_pspace < gn_atline - (_pspacing * 4 + 1)
   IF gl_widow .AND. _plineno+12 * gn_pspace > gn_atline + 1
      EJECT PAGE
   ENDIF
ENDIF
DO Upd_Vars
?? ;
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ";
+ "ÄÄÄÄÄÄÄÄÄ";
AT 0
?
?? "FACTURA N§: " STYLE "B" AT 0,;
 Num_fac FUNCTION "T" STYLE "B" ,;
 "FECHA: " STYLE "B" AT 64,;
 Fecha_fac STYLE "B" 
?
?? "CLIENTE N§: " AT 0,;
 Cod_cli FUNCTION "T" 
?
?? "ULTIMA FACTURA N§: " AT 5,;
 Num_ultfac FUNCTION "T" ,;
 "ENVIADA: " AT 38,;
 Fch_ultfac 
?
?? "ULTIMA CUENTA:     " AT 5,;
 Imp_ultcta PICTURE "99,999,999" ,;
 "ž" AT 35
?
?? "ULTIMO PAGO:       " AT 5,;
 Imp_ultpag PICTURE "99,999,999" 
?
?? "----------" AT 24
?
?? "BALANCE ANTERIOR:  " AT 5,;
 Balanc_ant PICTURE "99,999,999" ,;
 "ž" AT 35
?
?? "IMPORTE FACTURA:   " AT 5,;
 Imp_fac PICTURE "99,999,999" ,;
 "COMENTARIO: " AT 38,;
 Comentario FUNCTION "T" 
?
?? "==========" AT 24
?
?? "IMPORTE CUENTA:   " AT 5,;
 Imp_cta PICTURE "99,999,999" AT 24,;
 "ž" AT 35,;
 "NOTAS: " AT 38,;
 Notas FUNCTION "T" 
?
?
RETURN
* EOP: __Detail

PROCEDURE Rsumm
?
?? ;
"ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ";
+ "ÍÍÍÍÍÍÍÍÍ";
AT 0
?
?? "IMPORTE TOTAL DE BALANCES ANTERIORES:  " AT 0,;
 r_msum1 PICTURE "99,999,999" 
?
?? "IMPORTE TOTAL DE CUENTAS PENDIENTES:   " AT 0,;
 r_msum2 PICTURE "99,999,999" 
?
?? ;
"ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ";
+ "ÍÍÍÍÍÍÍÍÍ";
AT 0
gl_fandl=.F.        && final de la £ltima p gina
?
RETURN
* EOP: Rsumm

PROCEDURE Pgfoot
PRIVATE _box, _pspacing
gl_widow=.F.         && desactiva la comprobaci¢n de apartados viudos
_pspacing=1
?
IF .NOT. gl_plain
?
?? "PREPARADO POR EL DEPARTAMENTO FINANCIERO" AT 22
?
ENDIF
EJECT PAGE
*-- comprueba si el n£mero de p gina es mayor que el de la £ltima p gina
IF _pageno > _pepage
   GOTO BOTTOM
   SKIP
   gn_level=0
ENDIF
IF .NOT. gl_plain .AND. gl_fandl
   _pspacing=gn_pspace
   DO Pghead
ENDIF
RETURN
* EOP: Pgfoot

*-- Proceso de los saltos de p gina cuando se usa la opci¢n PLAIN
PROCEDURE Pgplain
PRIVATE _box
EJECT PAGE
RETURN
* EOP: Pgplain

*-- Restaura el entorno de dBASE previo a la impresi¢n del informe
PROCEDURE Reset
SET SPACE &gc_space.
SET TALK &gc_talk.
ON ESCAPE
ON PAGE
RETURN
* EOP: Reset

