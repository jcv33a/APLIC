
******************************************************************************
* NOMBRE DEL PROGRAMA:          GESTION.PRG
*                               MENU PRINCIPAL
*                               EJEMPLO DE SISTEMA DE APLICACION GESTION
* ULTIMO CAMBIO:                06/20/90 08:00AM
* ESCRITO POR:                  ASHTON-TATE
******************************************************************************

PROCEDURE Gesti¢n
   * Definir entorno
   CLEAR ALL
   SET DEVELOPMENT on
   SET DELIMITERS  off
   SET SCOREBOARD  off
   SET ESCAPE      off
   SET CLOCK       off
   SET STATUS      off
   SET TALK        off
   SET EXACT       off
   SET BELL        off
   SET CATALOG     off

   * Definir tecla de ayuda
   ON KEY LABEL F1 DO Ayuda

        * Almacenar colores
        PUBLIC c_save
        c_save = SET("ATTRIBUTES")

   * Caracter¡sticas de visualizaci¢n - dependientes del hardware
   IF ISCOLOR()
      c_normal = "W+/B,GR+/R,B"
      c_pop    = "B/W,GR+/R,W+/R"
      red      = "R/W"
      blue     = "B/W"
      lt_blue  = "W/BG"
   ELSE
      STORE "W+/N,N/W" TO c_normal, c_pop
      STORE "W"   TO red, blue
      STORE "N/W" TO lt_blue
   ENDIF

   * Definir men£ de ventana
   DO Main_def

   * Visualizar men£ y seleccionar opciones
   **mstrloop = .T.
   DO WHILE BAR() <> 13
      SET COLOR TO &c_normal.
      CLEAR
      DO Grado
      SET COLOR TO &c_pop.
      ACTIVATE POPUP mainmenu
   ENDDO
   CLOSE ALL
   CLEAR
RETURN
*================== fin del procedimiento principal ===========================

PROCEDURE Grado
   CLEAR
   * Dibujar l¡neas y ventanas para el men£ con colores para resaltar
   @ 2,24 TO 5,54 DOUBLE COLOR &blue.
   @ 2,24 FILL TO 5,54   COLOR &blue.
   SET COLOR TO &red.
   @ 3,27 SAY "A-T INDUSTRIAS DEL MUEBLE"
   @ 4,26 SAY "SISTEMA DE GESTION dBASE IV"
   SET COLOR TO &c_normal.
RETURN

PROCEDURE Main_def
   * Definir el men£ de ventana principal
   DEFINE POPUP mainmenu FROM 7,27 TO 22,51;
     MESSAGE "Pulse la inicial de una opci¢n del men£ " + ;
             "o seleccione y pulse <Return>"
   DEFINE BAR  1 OF mainmenu PROMPT "=== MENU  PRINCIPAL ===" SKIP
   DEFINE BAR  2 OF mainmenu PROMPT "      Ficheros:" SKIP
   DEFINE BAR  3 OF mainmenu PROMPT " EMPLEADOS"
   DEFINE BAR  4 OF mainmenu PROMPT " CLIENTES"
   DEFINE BAR  5 OF mainmenu PROMPT " PROVEEDORES"
   DEFINE BAR  6 OF mainmenu PROMPT " INVENTARIO"
   DEFINE BAR  7 OF mainmenu PROMPT " ORDENES DE PEDIDO"
   DEFINE BAR  8 OF mainmenu PROMPT " MOVIMIENTO DE CUENTAS"
   DEFINE BAR  9 OF mainmenu PROMPT " TELEFONOS (Prefijos)"
   DEFINE BAR 10 OF mainmenu PROMPT "     Utilidades:" SKIP
   DEFINE BAR 11 OF mainmenu PROMPT " FACTURACION"
   DEFINE BAR 12 OF mainmenu PROMPT " ARCHIVAR/RESTAURAR"
   DEFINE BAR 13 OF mainmenu PROMPT " VOLVER A dBASE"
   DEFINE BAR 14 OF mainmenu PROMPT " SALIR AL DOS"
   ON SELECTION POPUP mainmenu DO Main
RETURN

PROCEDURE Main
   * ejecutar un caso segun la opci¢n elegida
   DO CASE
      CASE BAR() =  3
         DO Empleado
      CASE BAR() =  4
         DO Cli
      CASE BAR() =  5
         DO Proveeds
      CASE BAR() =  6
         DO Art¡culo
      CASE BAR() =  7
         DO Pedidos
      CASE BAR() =  8
         DO Mov_ctas
      CASE BAR() =  9
         DO Prefijos
      CASE BAR() =  11
         DO Facturas
      CASE BAR() =  12
         DO Copiaseg
      CASE BAR() =  13 .OR. BAR() = 14
         RELEASE ALL
         SET CLOCK ON
         IF BAR() = 13
         * Restaurar los colores del Centro de Control/punto indicativo
             DO Colo_rese
             RETURN TO MASTER
         ELSE
            QUIT
         ENDIF
   ENDCASE
RETURN

PROCEDURE Colo_rese
PRIVATE old_color, c_messages, c_Titles, c_box, c_info, c_fields

old_color = c_save

* Restaurar los colores primarios
SET COLOR TO &old_color.

* Restaurar los colores secundarios
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
c_fields = old_color                            && Obtener color de campos

SET COLOR OF MESSAGES    TO &c_messages.
SET COLOR OF Titles      TO &c_Titles.
SET COLOR OF BOX         TO &c_box.
SET COLOR OF INFORMATION TO &c_info.
SET COLOR OF FIELDS      TO &c_fields.
RETURN

*** END Gesti¢n.PRG *********************************************************