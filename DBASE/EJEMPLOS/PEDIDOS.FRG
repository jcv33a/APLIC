* Programa...........: C:\X500SP\EJEMPLOS\PEDIDOS.FRG
* Fecha..............: 10-31-90
* Versiขn............: dBASE IV, Informes 1.1
*
* Notas:
* ------
* Antes de ejecutar este procedimiento con el mandato DO
* es necesario usar LOCATE, pues la sentencia CONTINUE
* est  en el bucle principal.
*
*-- Par metros
PARAMETERS gl_noeject, gl_plain, gl_summary, gc_heading, gc_extra
** Los tres primeros par metros son de tipo Lขgico.
** El cuarto es una serie y el quinto es un par metro adicional.
PRIVATE _peject, _wrap

*-- Comprueba si no se ha encontrado ningฃn registro
IF EOF() .OR. .NOT. FOUND()
   RETURN
ENDIF

*-- desactiva la justificaciขn entre m rgenes
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

_plineno=0          && pone el nฃmero de lกnea a cero
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
gl_fandl=.F.        && indicador de primera y ฃltima p gina
gl_intros=.F.       && indicador para las introducciones de grupo de cada p g.
gl_prntflg=.T.      && indicador de continuar impresiขn
gl_widow=.T.        && indicador de comprobar apartados viudos 
gn_length=LEN(gc_heading)  && almacena la longitud del encabezamiento (HEADING)
gn_level=2          && apartado actual en proceso
gn_page=_pageno     && captura el nฃmero de p gina actual
gn_pspace=_pspacing && captura el interlineado de la p gina impresa actual

*-- Inicializa las variables de los campos de pie de grupo
r_foot1=.F.


*-- Activa el procedimiento para el salto de p gina
gn_atline=_plength - (_pspacing * 3 + 1)
ON PAGE AT LINE gn_atline EJECT PAGE

*-- Imprime el informe

PRINTJOB

*-- Inicializa las variables de cambio de grupo
r_mvar4=COD_CLI

*-- Inicializa las variables del resumen.
r_msum1=0
r_msum2=0

IF gl_plain
   ON PAGE AT LINE gn_atline DO Pgplain
ELSE
   ON PAGE AT LINE gn_atline DO Pgfoot
ENDIF

DO Pghead

gl_fandl=.T.        && comienzo de la primera p gina fกsica

DO Rintro

DO Grphead
gl_intros=.F.

*-- Bucle de fichero
DO WHILE FOUND() .AND. .NOT. EOF() .AND. gl_prntflg
   DO CASE
   CASE COD_CLI <> r_mvar4
      gn_level=4
   OTHERWISE
      gn_level=0
   ENDCASE
   *-- comprueba si alguna expresiขn no ha casado
   IF gn_level <> 0
      DO Grpfoot WITH 100-gn_level
      DO Grpinit
   ENDIF
   *-- Repite las introducciones de grupo
   IF gn_level <> 0 .OR. gl_intros
      DO Grphead
   ENDIF
   gl_intros=.F.
   gn_level=0
   *-- Cuerpo del informe
   IF gl_summary
      DO Upd_Vars
   ELSE
      DO __Detail
   ENDIF
   gl_widow=.T.         && activa la comprobaciขn de apartados viudos
   CONTINUE
ENDDO

IF gl_prntflg
   gn_level=3
   DO Grpfoot WITH 97
   DO Rsumm
   IF _plineno <= gn_atline
      EJECT PAGE
   ENDIF
ELSE
   gn_level=3
   DO Rsumm
   DO Reset
   RETURN
ENDIF

ON PAGE

ENDPRINTJOB

DO Reset
RETURN
* EOP: C:\X500SP\EJEMPLOS\PEDIDOS.FRG

*-- Determina la altura de los apartados de grupo y del apartado cuerpo
*-- informe para la comprobaciขn de si hay apartados viudos
FUNCTION Gheight
PARAMETER Group_Band
retval=0              && valor retornado
IF Group_Band <= 4
   retval = retval + 2 * gn_pspace
ENDIF
*-- suma la altura del apartado cuerpo informe
retval = retval + 5 * gn_pspace
RETURN retval
* EOP: Gheight

*-- Actualiza los campos resumen y/o los campos calculados.
PROCEDURE Upd_Vars
r_foot1=Cod_cli
*-- Contar
r_msum1=r_msum1+1
*-- Contar
r_msum2=r_msum2+1
RETURN
* EOP: Upd_Vars

*-- Desactiva el indicador para salir del bucle DO WHILE cuando se pulse ESC
PROCEDURE Prnabort
gl_prntflg=.F.
RETURN
* EOP: Prnabort

*-- Reinicializa las variables de cambio de grupo. Reinicializa los campos
*-- resumen que vuelvan a empezar el c lculo cada apartado particular.
PROCEDURE Grpinit
IF gn_level <= 4
   r_msum1=0
ENDIF
IF gn_level <= 4
   r_mvar4=COD_CLI
ENDIF
RETURN
* EOP: Grpinit

*-- Procesa los Apartados Introducciขn de los grupos al cambiar de grupo
PROCEDURE Grphead
IF EOF()
   RETURN
ENDIF
PRIVATE _pspacing
_pspacing=gn_pspace
IF gn_level = 0
   gn_level=50
ENDIF
IF gn_level = 4
   IF 2 * gn_pspace  < gn_atline
      IF (gl_widow .AND. _plineno+Gheight(4) > gn_atline + 1) ;
      .OR. (gl_widow .AND. _plineno+2 * gn_pspace > gn_atline)
         EJECT PAGE
      ENDIF
   ENDIF
ENDIF
IF gn_level <= 4 .OR. gl_intros
   DO Head4
ENDIF
gn_level=0
RETURN
* EOP: Grphead.PRG

*-- Procesa los Apartados Resumen de los grupos al cambiar de grupo
PROCEDURE Grpfoot
PARAMETER ln_level
IF ln_level >= 96
   DO Foot96
ENDIF
RETURN
* EOP: Grpfoot.PRG

PROCEDURE Pghead
?
?? IIF(gl_plain,'',gd_date) AT 0,;
 "PAGINA " AT 69,;
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
DEFINE BOX FROM 25 TO 55 HEIGHT 4 DOUBLE
?
?? "A-T INDUSTRIAS DEL MUEBLE" AT 28
?
?? "INFORME DE PEDIDOS" AT 31
?
?
RETURN
* EOP: Rintro

PROCEDURE Head4
?? ;
"ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ";
+ "อออออออออ";
AT 0
?
?? "CLIENTE Nง: " STYLE "BU" AT 0,;
 Cod_cli FUNCTION "T" STYLE "BU" 
?
RETURN

PROCEDURE __Detail
IF 5 * gn_pspace < gn_atline - (_pspacing * 4 + 1)
   IF gl_widow .AND. _plineno+5 * gn_pspace > gn_atline + 1
      EJECT PAGE
      gl_intros=.T.
      DO Grphead
      gl_intros=.F.
   ENDIF
ENDIF
DO Upd_Vars
?? "FECHA DE PEDIDO:  " AT 0,;
 Fech_trans ,;
 "ARTICULO Nง: " AT 40,;
 Cod_art FUNCTION "T" ,;
 "CANTIDAD: " AT 66,;
 Can_art PICTURE "999" 
?
?? "NUMERO DE PEDIDO: " AT 0,;
 Num_ped FUNCTION "T" 
?
?? "VENTA DEL EMPLEADO: " AT 0,;
 Cod_emp FUNCTION "T" ,;
 "FACTURADO: " AT 66,;
 Facturado PICTURE "Y" AT 78
?
?? "NOTAS:" AT 0,;
 Notas FUNCTION "V64" AT 10
?
?? ;
"ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ";
+ "ฤฤฤฤฤฤฤฤฤ";
AT 0
?
RETURN
* EOP: __Detail

PROCEDURE Foot96
?? "NUMERO DE PEDIDOS DEL CLIENTE " AT 0,;
 r_foot1 FUNCTION "T" ,;
 ": " ,;
 r_msum1 PICTURE "999" 
?
?? ;
"ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ";
+ "อออออออออ";
AT 0
?
?
RETURN

PROCEDURE Rsumm
?? "NUMERO TOTAL DE PEDIDOS: " AT 0,;
 r_msum2 PICTURE "9,999" 
?
?? ;
"ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ";
+ "อออออออออ";
AT 0
gl_fandl=.F.        && final de la ฃltima p gina
?
RETURN
* EOP: Rsumm

PROCEDURE Pgfoot
PRIVATE _box, _pspacing
gl_widow=.F.         && desactiva la comprobaciขn de apartados viudos
_pspacing=1
?
IF .NOT. gl_plain
?
?? "PREPARADO POR EL DEPARTAMENTO DE VENTAS" AT 21
?
ENDIF
EJECT PAGE
gl_intros=.T.
*-- comprueba si el nฃmero de p gina es mayor que el de la ฃltima p gina
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

*-- Proceso de los saltos de p gina cuando se usa la opciขn PLAIN
PROCEDURE Pgplain
PRIVATE _box
EJECT PAGE
RETURN
* EOP: Pgplain

*-- Restaura el entorno de dBASE previo a la impresiขn del informe
PROCEDURE Reset
SET SPACE &gc_space.
SET TALK &gc_talk.
ON ESCAPE
ON PAGE
RETURN
* EOP: Reset

