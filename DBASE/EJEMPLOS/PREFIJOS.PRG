
******************************************************************************
* NOMBRE DEL PROGRAMA:            PREFIJOS.PRG
*                                 PANTALLA DEL FICHERO DE PREFIJOS
*                                 PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:                  06/20/90 08:00AM
* ESCRITO POR:                    ASHTON-TATE
******************************************************************************
*       FICHEROS USADOS:
*       Fichero de base de datos  =  Prefijos.dbf  (Fichero de prefijos)
*       Fichero de ¡ndice         =  Prefijos.mdx
*         ETIQUETA: Ciudad   =  ciudad  <= Maestro
*         ETIQUETA: Prefijo  =  prefijo
*       Fichero de procedimientos externos  =  Libreria.prg
******************************************************************************
* Procedimiento principal
PROCEDURE Prefijos

   * Enlazar con el fichero de procedimientos externos
   SET PROCEDURE TO Librer¡a

   * Definir entorno del fichero
   IF TYPE("c_save") = "U"
      * No sobreescribe c_save si ya existe
      PUBLIC c_save
      SET CONSOLE off
      c_save = SET("ATTRIBUTES")
      SET CONSOLE on
   ENDIF

   * Definir entorno del fichero
   SET CONSOLE off
   DO Set_env
   SET CONSOLE on

   SET COLOR TO &c_standard.

   * Declaraci¢n de variables usadas:
   * Variables de memoria para los campos de la base de datos
   Ciudad = SPACE(20)
   Prefijo = 0
   * Variables diversas - usadas para pasar par metros a Libreria
   STORE "Prefijos" TO dbf
   STORE "NO DISPONIBLE" TO mlist     && Lista de correo no disponible
   STORE "N/D" TO Cli_rpt             && Informe personalizado no disponible
   STORE "m->Ciudad" TO key, key1
   STORE "NINGUNO" TO key2, key3
   keyNomb1 = "Ciudad:"
   STORE "" TO keyNomb2, keyNomb3
   list_flds = "Ciudad, Prefijo"
   mPrefijo     = 0
   lookup_ok = .F.                    && consulta no aplicable

   * Abrir ficheros de base de datos y de ¡ndices
   SELECT 1
   USE Prefijos ORDER Ciudad
   GO TOP

   record_num = RECNO()
   DO Load_fld    && Cargar el registro inicial de la base de datos a variable de memoria

   * Visualizar la pantalla de datos
   CLEAR
   DO Dstatus
   DO Backgrnd
   DO Show_data

   * Definir men£s de ventana
   DO Bar_def

   * Activar el men£ de ventana principal - ejecutar opci¢n
   SET COLOR TO &c_popup.
   ACTIVATE POPUP main_mnu
   DO Sub_ret
RETURN
*==================== fin del procedimiento principal ==================

*  PROCEDIMIENTOS DE UTILIDADES (Espec¡ficos de Prefijos.prg)
PROCEDURE Filter
   * Agrupar datos por condici¢n de filtro
   * Seleccionar la condici¢n de filtro (S=activar,N=cancelar,D=desactivar)
   * Si el filtro est  activado, la opci¢n por defecto es D, visualizar ventana
   * Si el filtro est  desactivado, la opci¢n por defecto es S, visualizar ventana
   choice = IIF(filters_on,"D","S")
   DO Filt_ans
   IF choice = "S"                && Comenzar el proceso de selecci¢n de la condici¢n de filtro
      mPrefijo  = 0
      ACTIVATE WINDOW alert
         * Obtener del usuario la condici¢n de filtro
         @ 0, 0 SAY "---------- CONDICION DE FILTRO -----------"
         @  2, 0 SAY "PREFIJO:" GET mPrefijo PICTURE "999"
         READ
      DEACTIVATE WINDOW alert
      IF 0 <> mPrefijo             && Comprobar si se han introducido datos
         SET FILTER TO Prefijo = mPrefijo
      ELSE                         && No se introdujeron datos y se abandona
         ?? CHR(7)
         filters_on = .F.
         RETURN
      ENDIF
      GO TOP                      && Activar el filtro moviendo el puntero de registro
      * Comprobar si algunos registros cumplen la condici¢n de filtro (ninguno=EOF)
      filters_on = .NOT. EOF()
      IF .NOT. filters_on         && Desactivar el filtro si no se encuentran registros que lo cump
         ?? CHR(7)
         DO Show_msg WITH "Ning£n registro de Prefijos cumple la     condici¢n de filtro"
         SET FILTER TO
         GO record_num
      ENDIF
   ELSE
      * Si se selecciona "D", se desactiva el filtro
      SET FILTER TO
      filters_on = .F.
   ENDIF
RETURN

PROCEDURE Indexer
   * Crear/reconstruir los ¡ndices
   INDEX ON Prefijo TAG Prefijo
   INDEX ON Ciudad TAG Ciudad
   SET ORDER TO TAG Ciudad
   GO TOP
RETURN

PROCEDURE Init_fld
   * Inicializar las variables de memoria para entrada de datos
   Ciudad = SPACE(20)
   Prefijo = 0
RETURN

PROCEDURE Load_fld
   * Cargar los valores de los campos del registro de Prefijos en variables de memoria
   Ciudad  = Ciudad
   Prefijo  = Prefijo
RETURN

PROCEDURE Repl_fld
   * Sustituir los campos del fichero con los valores de las variables
   REPLACE Ciudad WITH m->Ciudad, Prefijo WITH m->Prefijo
RETURN

PROCEDURE Backgrnd
   * Visualizar la pantalla para entrada de datos y visualizaciones
   * Dibujar l¡neas y ventanas
   @  1,25 TO  3,53  DOUBLE COLOR &c_blue.
   @  6,7  TO  8,39  DOUBLE COLOR &c_red.
   @  9,7  TO 11,39         COLOR &c_red.
   @  2,26 FILL TO  2,52    COLOR &c_blue.
   @  6,7  FILL TO 11,39    COLOR &c_red.
   SET COLOR TO &c_data.
   @  2,29 SAY "PREFIJOS TELEFONICOS"
   @  7,10 SAY "CIUDAD: "
   @ 10,10 SAY "PREFIJO:"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar datos
   SET COLOR TO &c_fields.
   @  7,18 SAY Ciudad
   @ 10,19 SAY Prefijo PICTURE "999"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Get_data
   * Visualizar datos para entrada de datos
   SET COLOR TO &c_data.
   @  7,18 GET m->Ciudad PICTURE "!XXXXXXXXXXXXXXXXXXX"
   @ 10,19 GET m->Prefijo PICTURE "999"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Colo_rese
PRIVATE old_color, c_messages, c_Titles, c_box, c_info, c_fields

old_color = c_save

* Definir colores primarios
SET COLOR TO &old_color.

* Eliminar colores primarios e inicializar colores secundarios
old_color = STUFF(old_color, 1, AT("&",old_color)+2, "")

comma = AT(",",old_color)
c_messages = LEFT(old_color, comma-1)           && Obtener color de mensajes
old_color = STUFF(old_color, 1, comma, "")      && Eliminar color de mensajes

comma = AT(",",old_color)
c_Titles = LEFT(old_color, comma-1)             && Obtener color de t¡tulos
old_color = STUFF(old_color, 1, comma, "")      && Eliminar color de t¡tulos

comma = AT(",",old_color)
c_box = LEFT(old_color, comma-1)                && Obtener color de cajas
old_color = STUFF(old_color, 1, comma, "")      && Eliminar color de cajas

comma = AT(",",old_color)
c_info = LEFT(old_color, comma-1)               && Obtener color de informaci¢n
old_color = STUFF(old_color, 1, comma, "")      && Eliminar color de informaci¢n

comma = AT(",",old_color)
c_fields = old_color                                                                    && Obtener color de campos

SET COLOR OF MESSAGES    TO &c_messages.
SET COLOR OF Titles      TO &c_Titles.
SET COLOR OF BOX         TO &c_box.
SET COLOR OF INFORMATION TO &c_info.
SET COLOR OF FIELDS      TO &c_fields.
RETURN

************************  FIN DE PREFIJOS.PRG  ******************************************