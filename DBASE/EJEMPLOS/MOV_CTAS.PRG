
******************************************************************************
* NOMBRE DEL PROGRAMA:       MOV_CTAS.PRG
*                            PANTALLA DEL FICHERO DE MOVIMIENTO DE CUENTAS
*                            PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:             09/25/89 09:25AM
* ESCRITO POR:               ASHTON-TATE
******************************************************************************
*
*     FICHEROS USADOS:
*     Fichero de base de datos  =  Mov_ctas.dbf  (Fichero de mov. de cuentas)
*     Fichero de ¡ndice         =  Mov_ctas.mdx
*        ETIQUETAS: Num_fac     =  num_fac     <= Indice maestro
*                   Balanc_ant  =  balanc_ant
*                   Cod_cli     =  cod_cli
*     Fichero de procedimientos externos  =  Libreria.prg
******************************************************************************

* Procedimiento principal
PROCEDURE Mov_ctas

   * Enlazar con el fichero de procedimientos externos
   SET PROCEDURE TO Librer¡a

   * Definir entorno del fichero
   DO Set_env

   SET COLOR TO &c_standard.

   * Declaraci¢n de variables usadas:
   * Variables de memoria para los campos de la base de datos
   STORE "" TO N£m_fac, C¢d_cli, Comentario, Notas, N£m_fac, N£m_£ltfac
   STORE 0  TO Imp_fac, Imp_pag, Imp_cta, Imp_ultcta
   STORE 0  TO Imp_ultpag, Balanc_ant
   STORE {} TO Fecha_fac, Fch_ultfac

   * Variables diversas - usadas para pasar par metros a Libreria
   dbf      = "Mov_ctas"                 && Informe est ndar disponible
   mlist    = "NO DISPONIBLE"            && Lista de correo no disponible
   Cli_rpt  = "N/D"                      && Informe personalizado no disponible
   STORE "m->N£m_fac" TO key, key1
   STORE "NINGUNO" TO key2, key3
   keyNomb1 = "Factura n§:"
   STORE "" TO keyNomb2, keyNomb3
   list_flds = "N£m_fac, C¢d_cli, Fecha_fac, Imp_cta, Balanc_ant"
   STORE 0 TO balance, age

   * Abrir ficheros de base de datos y de ¡ndices
   SELECT 1
   USE Mov_ctas ORDER N£m_fac
   USE Cli      ORDER C¢d_cli IN 2
   SET RELATION TO C¢d_cli INTO Cli
   GO TOP

   record_num = RECNO()
   * Cargar el registro inicial de la base de datos a  variables de memoria
   DO Load_fld

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
   *
RETURN
*==================== fin del procedimiento principal ==================

*  PROCEDIMIENTOS DE UTILIDADES (Espec¡ficos de Mov_ctas.prg)

PROCEDURE Indexer
   * Crear/reconstruir ¡ndices
   INDEX ON Balanc_ant TAG Balanc_ant
   INDEX ON C¢d_cli    TAG C¢d_cli
   INDEX ON N£m_fac TAG N£m_fac
   GO TOP
RETURN

PROCEDURE Init_fld
   * Inicializar el valor de las variables de memoria para entrada de datos
   STORE SPACE(10) TO N£m_fac, N£m_£ltfac
   C¢d_cli = SPACE(6)
   STORE 0 TO Imp_fac, Imp_cta, Imp_ultcta, Imp_ultpag
   STORE SPACE(30) TO Comentario, Notas
   STORE {  /  /  } TO Fecha_fac, Fch_ultfac
RETURN

PROCEDURE Load_fld
   * Cargar los valores de los campos del registro de Mov_ctas en variables de memoria
   N£m_fac    = N£m_fac
   C¢d_cli    = C¢d_cli
   Imp_fac    = Imp_fac
   Imp_pag    = Imp_pag
   Fecha_fac  = Fecha_fac
   Imp_cta    = Imp_cta
   Comentario = Comentario
   Notas      = Notas
   Fch_ultfac = Fch_ultfac
   Imp_ultcta = Imp_ultcta
   Imp_ultpag = Imp_ultpag
   Balanc_ant = Balanc_ant
   N£m_£ltfac = N£m_£ltfac
RETURN

PROCEDURE Repl_fld
   * Sustituir los campos del fichero con los valores de las variables
   REPLACE N£m_fac WITH m->N£m_fac, C¢d_cli WITH m->C¢d_cli,;
           Imp_fac WITH m->Imp_fac, Fecha_fac WITH m->Fecha_fac,;
           Imp_cta WITH m->Imp_cta, Comentario WITH m->Comentario
   REPLACE Notas WITH m->Notas, Fch_ultfac WITH m->Fch_ultfac,;
           Imp_ultcta WITH m->Imp_ultcta, Imp_ultpag WITH m->Imp_ultpag,;
           N£m_£ltfac WITH m->N£m_£ltfac, Balanc_ant WITH m->Balanc_ant,;
           Imp_pag WITH m->Imp_pag
RETURN

PROCEDURE Backgrnd
   * Visualizar la pantalla para entrada de datos y visualizaciones
   * Dibujar y rellenar las ventanas
   @  1,18 TO  3,41 DOUBLE COLOR &c_blue.
   @  5, 1 TO  7,56 DOUBLE COLOR &c_red.
   @  2,19 FILL TO  2,40   COLOR &c_red.
   @  6, 2 FILL TO  6,55   COLOR &c_red.
   @  9, 2 FILL TO 20,55   COLOR &c_red.
   @ 10, 1 TO 10,56        COLOR &c_red.
   @ 18, 1 TO 18,56        COLOR &c_red.
   @  8, 1 TO 21,56        COLOR &c_red.
   SET COLOR TO &c_data.
   @  2,20 SAY "FICHERO DE CUENTAS"
   @  6, 3 SAY "FACTURA N§:"
   @  6,28 SAY "FECHA:"
   @  9, 3 SAY "CLIENTE N§:"
   @ 11, 3 SAY "- ULTIMA FACTURA -"
   @ 12, 3 SAY "NUMERO:"
   @ 13, 3 SAY "FECHA: "
   @ 14, 3 SAY "DIAS:  "
   @ 14,17 SAY "d¡as"
   @ 11,26 SAY "---------- IMPORTE ----------"
   @ 12,26 SAY "ULTIMA CUENTA               ž"
   @ 13,26 SAY "ULTIMO PAGO                 ž"
   @ 14,26 SAY "BALANCE ANTERIOR            ž"
   @ 15,26 SAY "IMPORTE FACTURA             ž"
   @ 16,45 SAY "=========="
   @ 17, 3 SAY "PAGO             ž"
   @ 17,26 SAY "IMPORTE CUENTA              ž"
   @ 19, 3 SAY "COMENTARIO:"
   @ 20, 3 SAY "NOTAS:"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar pantalla para entrada de datos
   * Calcular datos temporales
   * Balance anterior = importe £ltima factura menos importe £ltimo pago
   Balanc_ant = Imp_ultcta - Imp_ultpag
   * Esta cuenta es la suma del balance anterior y el importe de factura
   Imp_cta = Balanc_ant + Imp_fac
   * Calcular la antiguedad si hay balance pendiente
   age = IIF(Balanc_ant > 0, DATE() - Fch_ultfac, 0)
   *
   SET COLOR TO &c_fields.
   @  6,15 SAY N£m_fac
   @  6,35 SAY Fecha_fac
   @  9,15 SAY C¢d_cli
   @  9,24 SAY Cli->Cliente COLOR &c_yelowhit.
   @ 12,11 SAY N£m_£ltfac
   @ 13,11 SAY Fch_ultfac
   * Definir colores para visualizar los niveles de antiguedad del balance anterior
   age_color = "W"                     && Monitor monocromo
   IF ISCOLOR()                        && Monitor en color
      DO CASE
         CASE m->age >= 60
            age_color = c_red          && Rojo - peligro
         CASE m->age >= 45
            age_color = c_yellow       && Amarillo - precauci¢n
         OTHERWISE
            age_color = c_green        && Verde - correcto
      ENDCASE
   ENDIF
   @ 12,43 SAY Imp_ultcta PICTURE "99,999,999"
   @ 14,13 SAY m->age PICTURE "999" COLOR &age_color.
   @ 13,43 SAY Imp_ultpag PICTURE "99,999,999"
   bal_color = "W"                     && Monitor monocromo
   IF ISCOLOR()                        && Monitor en color
      DO CASE
   * Definir colores para visualizar los niveles de antiguedad del balance anterior
         CASE Balanc_ant >= 1000
            bal_color = c_red          && Rojo - peligro
         CASE Balanc_ant >= 100
            bal_color = c_yelowhit     && Amarillo - precauci¢n
         OTHERWISE
            bal_color = c_green        && Verde - correcto
      ENDCASE
   ENDIF
   @ 14,43 SAY m->Balanc_ant  PICTURE "99,999,999" COLOR &bal_color.
   @ 15,43 SAY Imp_fac PICTURE "99,999,999"
   @ 17, 9 SAY Imp_pag PICTURE "99,999,999"
   @ 17,43 SAY m->Imp_cta     PICTURE "99,999,999" COLOR &c_yelowhit.
   @ 19,15 SAY Comentario
   @ 20,15 SAY Notas
   IF ISCOLOR()
      @ 22,1 SAY " Texto/n£meros en amarillo son de fichero relacionado.  " ;
             COLOR &c_yelowhit.
   ELSE
      @ 22,1 SAY " Texto/n£meros sin resaltar son de fichero relacionado. " ;
             COLOR &c_red.
   ENDIF
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Get_data
   SET COLOR TO &c_data.
   @  6,15 GET m->N£m_fac ;
               VALID Duplicat(m->N£m_fac) ;
               ERROR "N§ de factura repetido; por favor, introduzca de nuevo";
               MESSAGE "Introduzca un n§ de factura v lido " + ;
                       "(n§ de cliente + a¤o + mes)"
   @  6,35 GET m->Fecha_fac
   @  9,15 GET m->C¢d_cli PICTURE  "!XXXXX" ;
               VALID Lookupid((m->C¢d_cli), "Cli", "Cliente", 2) ;
               ERROR "N§ de cliente repetido - Por favor, introduzca de nuevo" ;
               MESSAGE "Introduzca un n§ de cliente v lido (comenzando con" + ;
                       "una letra). Esc para salir"
   IF .NOT. PROMPT() = " Add record"
      @ 9,24 SAY Cli->Cliente COLOR &c_yelowhit.
   ELSE
      @ 9,24 SAY SPACE(30)             && Borrar nombre de cliente en modo adici¢n
   ENDIF
   @ 12,11 GET m->N£m_£ltfac
   @ 13,11 GET m->Fch_ultfac FUNCTION "D"
   @ 12,43 GET m->Imp_ultcta PICTURE "99,999,999"
   @ 13,43 GET m->Imp_ultpag PICTURE "99,999,999"
   @ 15,43 GET m->Imp_fac    PICTURE "99,999,999"
   @ 17, 9 GET m->Imp_pag    PICTURE "99,999,999"
   @ 19,15 GET m->Comentario FUNCTION "!"
   @ 20,15 GET m->Notas      FUNCTION "!"
   IF ISCOLOR()
      @ 22,1 SAY " Texto/n£meros en amarillo son de fichero relacionado.  " ;
             COLOR &c_yelowhit.
   ELSE
      @ 22,1 SAY " Texto/n£meros sin resaltar son de fichero relacionado. " ;
             COLOR &c_red.
   ENDIF
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO FindCli WITH m->C¢d_cli
RETURN

***************************  FIN DEL MOV_CTAS.PRG  ***************************************
