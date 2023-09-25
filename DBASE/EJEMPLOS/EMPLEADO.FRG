* Programa...........: C:\X500SP\EJEMPLOS\EMPLEADO.FRG
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

IF _plength < (_pspacing * 3 + 1) + (_pspacing + 1) + 2
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
gn_atline=_plength - (_pspacing + 1)
ON PAGE AT LINE gn_atline EJECT PAGE

*-- Imprime el informe

PRINTJOB

*-- Inicializa las variables del resumen.
r_msum1=0

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
* EOP: C:\X500SP\EJEMPLOS\EMPLEADO.FRG

*-- Actualiza los campos resumen y/o los campos calculados.
PROCEDURE Upd_Vars
*-- Contar
r_msum1=r_msum1+1
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
 "PAGINA " AT 68,;
 IIF(gl_plain,'',_pageno) PICTURE "999" 
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
DEFINE BOX FROM 25 TO 55 HEIGHT 4 DOUBLE
?
?? "A-T INDUSTRIAS DEL MUEBLE" AT 28
?
?? "INFORME DE EMPLEADO" AT 31
?
?
?
?? ;
"ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ";
+ "ÍÍÍÍÍÍÍÍÍÍ";
AT 0
?
RETURN
* EOP: Rintro

PROCEDURE __Detail
IF 11 * gn_pspace < gn_atline - (_pspacing * 3 + 1)
   IF gl_widow .AND. _plineno+11 * gn_pspace > gn_atline + 1
      EJECT PAGE
   ENDIF
ENDIF
DO Upd_Vars
?
?? Apellido FUNCTION "T" AT 0,;
 ", " ,;
 Nombre FUNCTION "T" ,;
 " " ,;
 Inicial FUNCTION "T" ,;
 "." ,;
 "N§:" AT 37,;
 Cod_emp FUNCTION "T" AT 41,;
 Telefono FUNCTION "T" AT 58
?
?? Direccion1 FUNCTION "T" AT 0,;
 " " ,;
 Direccion2 FUNCTION "T" 
?
?? Ciudad FUNCTION "T" AT 0,;
 ", " ,;
 Provincia FUNCTION "T" ,;
 " " ,;
 Cod_post FUNCTION "T" 
?
?? "DEPARTAMENTO:" AT 5,;
 Depart FUNCTION "T" AT 20,;
 "SALARIO:" AT 58,;
 Salario PICTURE "9,999,999" AT 68,;
 "" AT 79
?
?? Grado FUNCTION "T" AT 20,;
 Especiali FUNCTION "T" AT 37,;
 "COMISION:" AT 58,;
 Porcentaje PICTURE "99.9" AT 75,;
 "%" 
?
?? "FECHA DE ALTA:" AT 5,;
 Fecha_alta AT 20,;
 "TITULO:" AT 37,;
 Titulo FUNCTION "T" AT 45,;
 "EXPERIENCIA:" AT 58,;
 Expcia PICTURE "99.9" AT 75
?
?? "EXENTO:  " AT 5,;
 Exento PICTURE "Y" ,;
 "JORNADA COMPLETA:" AT 37,;
 Jorn_comp PICTURE "Y" AT 56
?
?? "PREMIOS: " AT 5,;
 Premios FUNCTION "T" ,;
 "CATEGORIA LABORAL:" AT 37,;
 Cat_lab PICTURE "9" AT 56
?
?? "COMENTARIO: " AT 5,;
 Comentario FUNCTION "T" PICTURE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" 
?
?? ;
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ";
+ "ÄÄÄÄÄÄÄÄÄÄ";
AT 0
?
RETURN
* EOP: __Detail

PROCEDURE Rsumm
?
?
?? ;
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ";
+ "ÄÄÄÄÄÄÄÄÄÄ";
AT 0
?
?? "NUMERO DE EMPLEADOS:" AT 0,;
 r_msum1 PICTURE "99,999" AT 21
?
?? ;
"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ";
+ "ÄÄÄÄÄÄÄÄÄÄ";
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

