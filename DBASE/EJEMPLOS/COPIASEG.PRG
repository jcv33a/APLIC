
******************************************************************************
*  NOMBRE DEL PROGRAMA:              COPIASEG.PRG
*                                    PROGRAMA PARA ARCHIVAR Y RECUPERAR DATOS
*                                    PROGRAMA EJEMPLO DE APLICACION DE GESTION
*  ULTIMO CAMBIO:                    09/25/89 09:26AM
*  ESCRITO POR:                      ASHTON-TATE
******************************************************************************

* Procedimiento principal
PROCEDURE Copiaseg
   CLOSE DATABASES
   PUBLIC mpath
   STORE "" TO choice, answer
   * Definir men£s de ventana
   DO M_popdef
   SET COLOR TO &c_normal.
   CLEAR
   SET COLOR TO &c_pop.
   ACTIVATE POPUP backmenu
RETURN TO Gesti¢n
*==================== fin del procedimiento principal ==================

* PROCEDIMIENTOS DE UTILIDADES
PROCEDURE Bbackup
   * Copiar ficheros de base de datos y de ¡ndice a diskette(s)
   ACTIVATE WINDOW backup
      @ 0,0  SAY "-------------- COPIA DE SEGURIDAD ---------------"
      @ 1,2  SAY "Inserte un diskette formateado en la unidad A:"
      WAIT       "  Pulse cualquier tecla para comenzar..."
      RUN BACKUP &mpath.*.DB? A:
      RUN BACKUP &mpath.*.MDX A: /A
      ?? CHR(7)
      CLEAR
      ?      "**** PROCESO DE COPIA DE SEGURIDAD FINALIZADO ***"
      WAIT
   DEACTIVATE WINDOW backup
   SET COLOR TO &c_normal.
   CLEAR
   SET COLOR TO &c_pop.
RETURN

PROCEDURE Back
   * Ejecutar un caso seg£n la opci¢n elegida
   DO CASE
      CASE BAR() =  2
         DO Sure
         IF choice = "S"
            DO Bbackup
         ENDIF
      CASE BAR() =  3
         DO Sure
         IF choice = "S"
            DO Rrestore
         ENDIF
      CASE BAR() =  4
         RETURN TO Gesti¢n
   ENDCASE
RETURN

PROCEDURE M_popdef
   * Definir el men£ de ventana principal
   DEFINE POPUP backmenu FROM 7,20 TO 12,59 ;
     MESSAGE "Pulse la inicial de una opci¢n del men£ " + ;
             "o seleccione y pulse <Intro>"
   DEFINE BAR 1 OF backmenu ;
          PROMPT "==== MENU DE COPIAS DE SEGURIDAD =====" SKIP
   DEFINE BAR 2 OF backmenu ;
          PROMPT " Archivar datos en copia de seguridad"
   DEFINE BAR 3 OF backmenu ;
          PROMPT " Recuperar datos de copia de seguridad"
   DEFINE BAR 4 OF backmenu ;
          PROMPT " Volver al men£ principal"
   ON SELECTION POPUP backmenu DO Back
   DEFINE WINDOW backup FROM 14,15 TO 20,65 COLOR &c_pop.
RETURN

PROCEDURE Rrestore
   * Recuperar ficheros de base de datos y de ¡ndice de los diskette(s)
   ACTIVATE WINDOW backup
      @ 0,0  SAY "-------------- RECUPERAR DATOS -----------------"
      @ 1,0  SAY " Inserte la copia de seguridad en la unidad A:"
      WAIT       " y pulse cualquier tecla para comenzar . . . ."
      ! RESTORE A: &mpath.*.DB?
      ! RESTORE A: &mpath.*.MDX
      ?? CHR(7)
      CLEAR
      ?      "******* PROCESO DE RECUPERACION TERMINADO *******"
      WAIT
   DEACTIVATE WINDOW backup
   SET COLOR TO &c_normal.
   CLEAR
   SET COLOR TO &c_pop.
RETURN

PROCEDURE Sure
   * Visualizar el mensaje de confirmaci¢n
   SET COLOR TO &c_normal.
   CLEAR
   choice = "N"
   ACTIVATE WINDOW backup
      @ 0, 0  SAY "------------------- ATENCION --------------------"
      @ 1, 0  SAY "  ¨Seguro que desea archivar o recuperar datos?"
      @ 2, 0  SAY "  Pulse S para continuar o N para abandonar."
      @ 3,10  SAY "ELECCION:" GET choice PICTURE "Y"
      ?? CHR(7)
      READ
      IF choice = "N"
         SET COLOR TO &c_pop.
         DEACTIVATE WINDOW backup
         RETURN
      ENDIF
      * V¡a de acceso del DOS para ejecutar los programas BACKUP y RESTORE
      IF UPPER(choice) = "S"
         ?? CHR(7)
         mpath = "C:\dBASE\EJEMPLOS\" + SPACE(10)
         CLEAR
         @ 0, 0  SAY "----- INTRODUZCA VIA DE ACCESO DE EJEMPLOS ------"
         @ 1, 0  SAY "   Introduzca unidad y v¡a de acceso del DOS"
         @ 2, 0  SAY "  (la unidad y v¡a de acceso de sus ficheros)"
         @ 3, 2  GET mpath VALID "" <> TRIM(mpath) ;
            MESSAGE "Introduzca unidad y v¡a de acceso completa"
         READ
         mpath = TRIM(mpath)
      ENDIF
   DEACTIVATE WINDOW backup
RETURN

******************************  FIN DE COPIASEG.PRG  ************************************