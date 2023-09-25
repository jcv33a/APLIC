
*****************************************************************************
* NOMBRE DEL PROGRAMA:         INF_EMP.PRG
*                              EJEMPLO DE INFORME PERSONALIZADO - EMPLEADOS
*                              PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:               01/05/89 03:36PM
* ESCRITO POR:                 ASHTON-TATE
*****************************************************************************
*            FICHEROS USADOS:
*            Fichero de base de datos = Empleado.dbf
*            Fichero de ¡ndice        = Empleado.mdx
*              ETIQUETA: Depto  (depart+apellido+nombre+inicial)
*****************************************************************************
SET ORDER TO Dept
GO TOP

ON ESCAPE print_flag = .F.   && Si se pulsa Esc durante la impresi¢n, se abandona

* Definir entorno
SET CENTURY ON

* Inicializar variables
rpt_level   =  1               && Nivel de informe para comenzar el proceso
print_flag  = .T.              && Se¤al para continuar impresi¢n
on_pg_line  =  0               && L¡nea donde funciona ON PAGE
STORE 0 TO pageno, Salario_sum, Salario_gt, number_emp, yrsexp_sum, yrsexp_avg
group_brk = ""
p_Grado = "Informe de recursor humanos"

* Almacenar n£mero de l¡nea para salto de p gina
on_pg_line = _plength - 5      && Altura de p gina menos m rgenes inferior y superior

* Almacenar actuales caracter¡sticas del entorno
mplength  = _plength
mploffset = _ploffset
mlmargin  = _lmargin
mrmargin  = _rmargin
mppitch   = _ppitch
mwrap     = _wrap
mpeject   = _peject

* Establecer caracter¡sticas del informe
*_plength  = 66
_ploffset = 0
_lmargin  = 0
_rmargin  = 80
_ppitch   = "PICA"
_plineno  =  1
_wrap     = .F.
_peject   = "AFTER"

* Definir n£mero de l¡nea donde se ejecuta el procedimiento de salto de p gina
ON PAGE AT LINE on_pg_line DO Pg_break

SET PRINTER ON
*============================ Comenzar Impresi¢n ============================
PRINTJOB
   * Imprimir cabecera de p gina
   DO Grado
   DO Pg_head
   DO Brk_head
   GO TOP
   * Seleccionar-procesar registros en el orden del ¡ndice hasta el fin de fichero
   * o hasta que se pulse Esc (print_flag = .F.)
   SCAN WHILE print_flag
      IF group_brk <> Depart
         * Cambia el departamento, reiniciar informe
         rpt_level = 1
         DO Brk_data
         DO Reinit
         DO Brk_head
      ELSE
         * Departamento no cambia
         rpt_level = 0
      ENDIF
      * Imprimir l¡neas de detalle
      DO Detail
      * Realizar c lculos resumen
      DO Det_calc
   ENDSCAN
   *
   IF print_flag
      DO Brk_data     && Fin de fichero, no se puls¢ Esc para abandonar la impresi¢n
   ENDIF
   * Final del informe
   DO Rpt_end
   ON PAGE AT LINE on_pg_line DO Pg_foot
   EJECT PAGE
ENDPRINTJOB
*================================ Fin de Impresi¢n ==============================

* Restaurar entorno
_ppitch   = mppitch
_wrap     = mwrap
_peject   = mpeject
_plength  = mplength
_ploffset = mploffset
_lmargin  = mlmargin
_rmargin  = mrmargin

SET PRINTER OFF
ON ESCAPE
ON PAGE
SET CENTURY OFF
SET ORDER TO TAG Nombres
RETURN

****************** FIN DEL PROCEDIMIENTO DE IMPRESION PRINCIPAL ***********************

* PROCEDIMIENTOS DE UTILIDADES

PROCEDURE Brk_data
   * Imprimir los datos calculados del departamento terminado
   ?
   ?? "SUMARIO:"   STYLE "B" AT 0
   ?? number_emp   PICTURE "999"
   ?? "TOTAL:"     STYLE "B" AT 36
   ?? "  ž" AT 44
   ?? Salario_sum   PICTURE "99,999,999"
   ?? " "
   ?? "MED:"       STYLE "B" AT 59
   ??  yrsexp_avg  PICTURE "99.9"
   ?? " a¤os"
   ? "MED:"        STYLE "B" AT 36
   ?? "  ž" AT 44
   ?? ROUND(Salario_sum/number_emp,2)  PICTURE "99,999,999"
   ?
   * Acumular el total de los salarios                                                              Salario totals
   Salario_gt  = Salario_gt + Salario_sum
   * EJECT PAGE    && Quitar * si se quiere cada grupo en una p gina
RETURN

PROCEDURE Brk_head
   * Actualizar la variable de cambio e imprimir la cabecera del departamento
   group_brk = Depart
   * Comprueba si la l¡nea actual est  pr¢xima a la localizaci¢n del pie de p gina (ON PAGE)
   IF  _plineno + 8 > on_pg_line
      EJECT PAGE        && Comenzar nueva p gina si est  demasiado pr¢xima
   ELSE
      ?
      ? "Departamento" STYLE "BU" AT 0 ,": " STYLE "B"
      ?? Depart  PICTURE "@T XXXXXXXXXXXXXXX"
      IF rpt_level = 0
         ?? " (Contin£a)" && Imprimir mensaje de continuaci¢n si el grupo" + ;
            " de la p gina anterior contin£a"
      ENDIF
      ?
      rpt_level = 0     && Restaurar nivel despu‚s de imprimir cabecera del
                        && departamento
   ENDIF
RETURN

PROCEDURE Det_calc
   * Calcular sumas y medias para impresi¢n del departamento
   number_emp = number_emp + 1                 && N£mero de empleado
   Salario_sum = Salario_sum + Salario         && Suma de salarios
   yrsexp_sum = yrsexp_sum + Expcia            && Suma de los a¤os de experiencia
   yrsexp_avg = ROUND(yrsexp_sum/number_emp,1) && Media de los a¤os de experiencia
RETURN

PROCEDURE Detail
   * Imprimir detalle del informe
   * Comprueba si la l¡nea actual est  pr¢xima a la localizaci¢n del pie de p gina (ON PAGE)
   IF _plineno + 5 > on_pg_line
      * Comenzar nueva p gina si est  demasiado pr¢xima
      EJECT PAGE
   ENDIF
   ?
   ?? Apellido PICTURE "@T XXXXXXXXXXXXXXX" AT 0
   ?? ", "
   ?? Nombre   PICTURE "XXXXXXXXXX"
   ?? Grado    PICTURE "XXXXXXXXXXXXXXX"    AT 30
   ?? "  ž"
   ?? Salario  PICTURE "9,999,999"          AT 48
   ?? Expcia   PICTURE "99.9"               AT 63
   ?? T¡tulo   PICTURE "XXX"                AT 73
   ?  C¢d_emp     AT 0
   ?? Especiali   AT 30
   IF Porcentaje <> 0
      * Imprimir tanto por ciento s¢lo si no es cero
      ?? Porcentaje   PICTURE "99.9" AT 48
      ?? " %"
   ENDIF
   ?
RETURN

PROCEDURE Pg_break
   * Salto de p gina l¢gico si la l¡nea del informe = on_pg_line
   DO Pg_foot
   IF _pageno >= _pepage   && Parar en la p gina terminada
      GO BOTTOM
      SKIP
      rpt_level = 0
      RETURN
   ENDIF
   * Imprimir cabecera de p gina t¡tulos
   DO Pg_head
   DO Brk_head
RETURN

PROCEDURE Pg_foot
   * Imprimir pie de p gina
   pageno = "-" + LTRIM(STR(_pageno,3,0)) + "-"
   _wrap = .T.
   _alignment = "CENTER"
   ?
   ?
   ? pageno
   _wrap = .F.
   _alignment = "LEFT"
   EJECT PAGE
RETURN

PROCEDURE Pg_head
   * Imprimir cabecera de p gina y t¡tulos de columnas
   ?
   IF _pageno <> 1
      ?
      ? MDY(DATE()) AT 0
      ?? p_Grado AT (_rmargin - LEN(p_Grado))
   ENDIF
   ?
   ?
   DEFINE BOX FROM 0 TO 79 HEIGHT 4
   ?   "Nombre/"         STYLE "B" AT 1
   ??  "T¡tulo/"         STYLE "B" AT 30
   ??  "Salario/"        STYLE "B" AT 48
   ??  "Exper."          STYLE "B" AT 62
   ??  "Grado"           STYLE "B" AT 73
   ?   "N£mero empleado" STYLE "B" AT 1
   ??  "Especialidad"    STYLE "B" AT 30
   ??  "Comisi¢n"        STYLE "B" AT 48
   ?
RETURN

PROCEDURE Reinit
   * Reinicializar las variables de las sumas y c lculos del departamento
   STORE 0 TO Salario_sum, number_emp, yrsexp_sum, yrsexp_avg
RETURN

PROCEDURE Rpt_end
   * Imprimir suma total al final del informe
   ?
   ?? "RESUMEN TOTAL:" STYLE "B" AT 27
   ?? "  ž" AT 42
   ?? Salario_gt PICTURE "999,999,999"
RETURN

PROCEDURE Grado
   * Imprimir t¡tulo del informe
   ?
   _wrap = .T.
   _alignment = "CENTER"
   ? "A-T INDUSTRIAS DEL MUEBLE"   STYLE "B"
   ? "CENTRO INDUSTRIAL DEL ROBLE" STYLE "BU"
   ?
   ? "INFORME DE RECURSOS HUMANOS - REUNION TRIMESTRAL DE DIRECCION"
   ?
   ? MDY(DATE())
   _wrap = .F.
   _alignment = "LEFT"
RETURN
********************************** FIN DE INF_EMP.PRG **********************************