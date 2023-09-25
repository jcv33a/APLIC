
******************************************************************************
* NOMBRE DEL PROGRAMA:             PEDIDOS.PRG
*                                  PANTALLA DEL FICHERO DE ORDENES DE PEDIDOS
*                                  PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:                   09/25/89 09:26AM
* ESCRITO POR:                     ASHTON-TATE
******************************************************************************
*
*       FICHEROS USADOS:
*       Fichero de base de datos =  Pedidos.dbf
*       Fichero de ¡ndice        =  Pedidos.mdx
*        ETIQUETA: Pedido =  cod_cli+DTOS(fech_trans)+numero_pp <= Indice maestro
*       Fichero de procedimientos externos  =  Libreria.prg
******************************************************************************

* Procedimiento principal
PROCEDURE Pedidos

   * Enlazar con el fichero de procedimientos externos
   SET PROCEDURE TO Librer¡a

   * Definir entorno del fichero
   DO Set_env
   SET NEAR on
   SET COLOR TO &c_standard.

   * Declaraci¢n de variables usadas:
   * Variables de memoria para los campos de la base de datos
   STORE "" TO C¢d_cli, N£m_ped, C¢d_emp, C¢d_art
   STORE {  /  /  } TO Fech_trans
   Can_art = 0
   Facturado = .F.

   * Variables diversas - usadas para pasar par metros a Libreria
   * para encontrar registros, obtener informes, listar registros y otras opciones
   dbf   = "Pedidos"                  && Informe est ndar disponible
   mlist = "NO DISPONIBLE"            && Lista de correo no disponible
   STORE "N/D" TO Cli_rpt             && Informe personalizado no disponible
   key  = "m->C¢d_cli+DTOC(m->Fech_trans)+m->N£m_ped"
   key1 = "m->C¢d_cli"
   key2 = "m->Fech_trans"
   key3 = "m->N£m_ped"
   keyNomb1 = "Cliente N§:"
   keyNomb2 = "Fecha of Pedido:"
   keyNomb3 = "Pedido N§:"
   list_flds = "C¢d_cli,Fech_trans,N£m_ped,C¢d_art,Can_art,Art¡culo->Precio"
   STORE "" TO mCliid, mpartid, mempid

   * Abrir ficheros de base de datos y de ¡ndices
   SELECT 1
   USE Pedidos   ORDER Pedido
   USE Art¡culo  ORDER C¢d_art IN 2
   USE Cli       ORDER C¢d_cli IN 3
   USE Empleado  ORDER C¢d_emp  IN 4
   SET RELATION TO C¢d_art INTO Art¡culo, C¢d_cli INTO Cli, C¢d_emp INTO Empleado
   GO TOP

   record_num = RECNO()
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
*===========================fin del procedimiento principal==============================

*  PROCEDIMIENTOS DE UTILIDADES (Espec¡ficos de Pedidos.prg)

PROCEDURE Filter
   * Agrupar datos por condici¢n de filtro
   * Seleccionar la condici¢n de filtro (S=activar,N=cancelar,D=desactivar)
   * Si el filtro est  activado, la opci¢n por defecto es S, visualizar ventana
   * Si el filtro est  desactivado, la opci¢n por defecto es D, visualizar ventana
   choice = IIF(filters_on,"D","S")
   DO Filt_ans
   IF choice = "S"
      * Comenzar proceso de selecci¢n de la condici¢n de filtro
      *
      mCliid     = SPACE(6)
      mpartid    = SPACE(10)
      mempid     = SPACE(11)
      ACTIVATE WINDOW alert
         * Obtener del usuario la condici¢n de filtro
         @  0, 0 SAY "--------- CONDICION DE FILTRO ---------"
         @  2, 0 SAY "CLIENTE N§.:" GET mCliid FUNCTION "!" ;
            MESSAGE "Introduzca c¢digo de cliente de 6 d¡gitos " + ;
                    "empezando por letra - Esc para salir"
         @  3, 0 SAY "ARTICULO N§:" GET mpartid FUNCTION "!"
         @  4, 0 SAY "EMPLEADO N§:" GET mempid
         @  5, 0 SAY "Introduzca una o m s condiciones"
         READ
     DEACTIVATE WINDOW alert
     * Inicializar la variable de la condici¢n de filtro
     subset = " "
     * Proceso de entradas para definir la condici¢n de filtro
     mCliid   = TRIM(mCliid)
     mpartid   = TRIM(mpartid)
     mempid    = TRIM(mempid)
     subset =  subset + IIF("" <> mCliid,"C¢d_cli = '&mCliid.' .AND. ","")
     subset =  subset + IIF("" <> mpartid,"C¢d_art = '&mpartid.' .AND. ","")
     subset =  subset + IIF("" <> mempid, "C¢d_emp = '&mempid.'  .AND. ","")
     *
     IF "" = TRIM(subset)      && Comprobar si se han introducido datos en la serie
        * Si la serie est  vacia, salir
        DO Warnbell
        filters_on = .F.
     ELSE
        * Si la serie no est  vacia, truncar desde .AND. hasta el final
        subset = SUBSTR(subset,1,LEN(subset)-6)
        SET FILTER TO &subset.   && Activar el filtro con la serie introducida
        GO TOP                   && Activar el filtro moviendo el puntero de registro
        * Comprobar si algunos registros cumplen la condici¢n de filtro (EOF=ninguno la cumple)
        filters_on = .NOT. EOF()
        IF .NOT. filters_on           && Desactivar el filtro si filters_on = .F.
           DO Warnbell
           DO Show_msg WITH "Ning£n registro de Ordenes de Pedido      cumple la condici¢n de filtro."
           SET FILTER TO
           GO record_num
        ENDIF
      ENDIF
   ELSE
      * Si se selecciona "D", desactivar el filtro
      SET FILTER TO
      filters_on = .F.
   ENDIF
RETURN

PROCEDURE Indexer
   * Crear/reconstruir ¡ndices
   INDEX ON C¢d_cli+DTOC(Fech_trans)+N£m_ped TAG Pedido
   GO TOP
RETURN

PROCEDURE Init_fld
   * Inicializar las variables de memoria para introducir datos
   C¢d_cli    = SPACE(6)
   Fech_trans = DATE()
   N£m_ped    = SPACE(5)
   C¢d_emp    = SPACE(11)
   C¢d_art    = SPACE(10)
   Can_art    = 0
   Facturado  = .F.
RETURN

PROCEDURE Load_fld
   * Cargar los valores de los campos del registro de PEDIDOS en variables de memoria
   C¢d_cli    = C¢d_cli
   Fech_trans = Fech_trans
   N£m_ped    = N£m_ped
   C¢d_emp    = C¢d_emp
   C¢d_art    = C¢d_art
   Can_art    = Can_art
   Facturado  = Facturado
RETURN

PROCEDURE Repl_fld
   * Sustituir los campos del fichero con los valores de las variables
   REPLACE C¢d_cli WITH m->C¢d_cli, N£m_ped WITH m->N£m_ped,;
           Fech_trans WITH m->Fech_trans, C¢d_emp WITH m->C¢d_emp, ;
           C¢d_art WITH m->C¢d_art, Can_art WITH m->Can_art, ;
           Facturado  WITH m->Facturado
RETURN

FUNCTION Prof_mgn
   PARAMETERS Coste,Precio
   * Calcular margen de beneficio
   margin = ROUND((Precio-Coste)/Precio*100,1)
RETURN margin

PROCEDURE Backgrnd
   * Visualizar la pantalla para entrada de datos y visualizaciones
   @  1,18 TO  3,49 DOUBLE COLOR &c_blue.
   @  5, 2 TO  8,56 DOUBLE COLOR &c_red.
   @ 16, 2 TO 16,56        COLOR &c_red.
   @  9, 2 TO 18,56        COLOR &c_red.
   @  2,19 FILL TO  2,48   COLOR &c_blue.
   @  6, 3 FILL TO  7,55   COLOR &c_red.
   @ 10, 3 FILL TO 17,55   COLOR &c_red.
   @  6, 3 FILL TO 17,55   COLOR &c_red.
   SET COLOR TO &c_data.
   @  2,20 SAY "FICHERO DE ORDENES DE PEDIDO"
   @  6, 4 SAY "CLIENTE N§:"
   @  7, 4 SAY "FECHA DE PEDIDO:"
   @  7,35 SAY "PEDIDO N§:"
   @ 10, 4 SAY "ARTICULO N§:"
   @ 11, 4 SAY "NOMBRE ART.:"
   @ 12, 4 SAY "CANT. PEDIDA:"
   @ 12,25 SAY "unidad(es)"
   @ 12,36 SAY "PRECIO:           ž"
   @ 13, 4 SAY "CANT. DISPONIBLE:"
   @ 13,25 SAY "unidad(es)"
   @ 13,36 SAY "MARGEN:           %"
   @ 14, 4 SAY "EMPLEADO N§:"
   @ 15, 4 SAY "FACTURADO:"
   @ 17, 4 SAY "NOTAS:"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar pantalla para entrada de datos
   SET COLOR TO &c_fields.
   @  6,16 SAY C¢d_cli
   @  7,21 SAY Fech_trans
   @  7,46 SAY N£m_ped
   @ 10,18 SAY C¢d_art
   @ 12,21 SAY Can_art   PICTURE "999"
   @ 14,17 SAY C¢d_emp
   @ 15,15 SAY Facturado  PICTURE  "Y"
   @ 17,11 SAY Notas
   IF .NOT. BAR() = 2           && no modo de adici¢n
      @  6,25 SAY Cli->Cliente                          COLOR &c_yelowhit.
      @ 11,18 SAY Art¡culo->Nom_art                     COLOR &c_yelowhit.
      @ 12,44 SAY Art¡culo->Precio  PICTURE "9,999,999" COLOR &c_yelowhit.
      @ 13,21 SAY Art¡culo->Can_alm PICTURE "999"       COLOR &c_yelowhit.
      @ 13,49 SAY Prof_mgn(Art¡culo->Coste,Art¡culo->Precio) ;
              PICTURE "99.9" COLOR &c_yelowhit.
      @ 14,30 SAY TRIM(Empleado->Nombre)+" "+ Empleado->Apellido ;
              COLOR &c_yelowhit.
   ELSE
      * Modo Adici¢n borrar de pantalla las zonas de los campos
      @  6,25 SAY SPACE(30)    && CLIENTE
      @ 11,18 SAY SPACE(20)    && NOMBRE DE ARTICULO
      @ 12,44 SAY SPACE(9)     && PRECIO
      @ 13,21 SAY SPACE(3)     && CANTIDAD ALMACENADA
      @ 13,49 SAY SPACE(4)     && MARGEN
      @ 14,30 SAY SPACE(26)    && EMPLEADO
   ENDIF
   IF ISCOLOR()
      @ 20, 2 SAY " Texto/n£meros en amarillo son de fichero relacionado. " ;
         COLOR &c_yelowhit.
   ELSE
      @ 20, 2 SAY " Texto/n£meros sin resaltar son de fichero relacionado. "
         COLOR &c_red.
   ENDIF
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Get_data
   * Visualizar pantalla para entrada de datos
   SET COLOR TO &c_data.
   @  6,16 GET m->C¢d_cli    PICTURE  "!99999" ;
           VALID Lookupid(m->C¢d_cli,"Cli","Cliente", 2) ;
           ERROR "N£mero de cliente no v lido. Por favor, introduzca de nuevo." ;
           MESSAGE "Introduzca c¢digo de cliente de 6 d¡gitos " + ;
                   "comenzando por una letra - Esc para salir"
   @  7,21 GET m->Fech_trans FUNCTION "D" ;
           MESSAGE "Introduzca la fecha de este pedido"
   @  7,46 GET m->N£m_ped  FUNCTION "!" ;
           MESSAGE "Introduzca el n£mero de pedido"
   @ 10,18 GET m->C¢d_art    FUNCTION "!" ;
           VALID Lookupid(m->C¢d_art,"Art¡culo", "Part", 3) ;
           ERROR "N£mero de pedido no v lido. Por favor, introduzca de nuevo." ;
           MESSAGE "Introduzca n£mero de p‚dido - Esc para salir"
   @ 12,21 GET m->Can_art   PICTURE "999" ;
           MESSAGE "Introduzca cantidad pedida"
   @ 14,17 GET m->C¢d_emp PICTURE "999-99-9999" ;
           VALID Lookupid(m->C¢d_emp, "Empleado", "Empleado", 6) ;
           ERROR "N£mero de empleado no v lido. Por favor, introduzca de nuevo." ;
           MESSAGE "Introduzca n£mero de empleado - Esc para salir"
   @ 15,15 GET m->Facturado  PICTURE  "Y" ;
           MESSAGE "Introduzca si este pedido ha sido Facturado " + ;
                   "(normalmente realizado por el sistema)"
   @ 17,11 GET Notas WINDOW memo_windo ;
           MESSAGE "Introduzca las notas en el campo memo, pulse " + ;
                   "Ctrl-Home para acceder (Ctrl-End para salir)"
   IF .NOT. BAR() = 2           && Modo no adicci¢n
      @  6,25 SAY Cli->Cliente                          COLOR &c_yelowhit.
      @ 11,18 SAY Art¡culo->Nom_art                     COLOR &c_yelowhit.
      @ 12,44 SAY Art¡culo->Precio  PICTURE "9,999,999" COLOR &c_yelowhit.
      @ 13,21 SAY Art¡culo->Can_alm PICTURE "999"       COLOR &c_yelowhit.
      @ 13,49 SAY Prof_mgn(Art¡culo->Coste,Art¡culo->Precio) ;
              PICTURE "99.9" COLOR &c_yelowhit.
      @ 14,30 SAY TRIM(Empleado->Nombre)+" "+ Empleado->Apellido ;
              COLOR &c_yelowhit.
   ELSE
      * Modo Adici¢n borrar de pantalla las zonas de los campos
      @  6,26 SAY SPACE(30)    && CLIENTE
      @ 11,18 SAY SPACE(20)    && NOMBRE DE ARTICULO
      @ 12,44 SAY SPACE(9)     && PRECIO
      @ 13,21 SAY SPACE(3)     && CANTIDAD ALMACENADA
      @ 13,48 SAY SPACE(4)     && MARGEN DE BENEFICIOS
      @ 14,30 SAY SPACE(26)    && EMPLEADO
   ENDIF
   IF ISCOLOR()
      @ 20, 2 SAY " Texto/n£meros en amarillo son de fichero relacionado. " ;
         COLOR &c_yelowhit.
   ELSE
      @ 20, 2 SAY " Texto/n£meros sin resaltar son de fichero relacionado. " ;
         COLOR &c_red.
   ENDIF
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO FindCli WITH m->C¢d_cli
   ON KEY LABEL F10 DO Findpart WITH m->C¢d_art
RETURN
************************************** FIN DE PEDIDOS.PRG ********************************
