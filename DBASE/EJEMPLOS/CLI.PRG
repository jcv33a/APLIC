
******************************************************************************
* NOMBRE DEL PROGRAMA:                CLI.PRG
*                                     PANTALLA DEL FICHERO CLIENTES
*                                     PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:                      09/25/89 09:26AM
* ESCRITO POR:                        ASHTON-TATE
******************************************************************************
*       FICHEROS USADOS:
*       Fichero de base de datos =  Cli.dbf   (Fichero de clientes)
*       Fichero de ¡ndice        =  Cli.mdx
*           ETIQUETA: Cli =  cod_cli  <= Indice maestro
*       Fichero de procedimientos externos = Libreria.prg
******************************************************************************
* Procedimiento principal
PROCEDURE Cli

   * Enlazar con el fichero de procedimientos externos
   SET PROCEDURE TO Librer¡a

   * Definir entorno del fichero
   DO Set_env

   SET COLOR TO &c_standard.

   * Declaraci¢n de variables usadas:
   * Variables de memoria para los campos de la base de datos
   STORE "" TO C¢d_cli, Categor¡a, Cliente, Direcci¢n1, Direcci¢n2, Ciudad, Provincia
   STORE "" TO C¢d_post, Tel‚fono, Contacto, Tel_cont, Ext_tel, Ult_fecha, F_pago
   STORE "" TO Comentario

   * Variables diversas - usadas para pasar par metros a Libreria
   STORE "Cli" TO dbf, mlist         && Informe est ndar y lista de correo disponibles
   STORE "N/D"  TO Cli_rpt           && Informe personalizado no disponible
   STORE "m->C¢d_cli" TO key, key1
   STORE "NINGUNO" TO key2, key3
   keyNomb1 = "Cliente n§"
   STORE "" TO keyNomb2, keyNomb3, mCategor¡a, mCiudad, mProvincia
   list_flds = "C¢d_cli, Contacto, Tel_cont, Ext_tel"

   * Abrir ficheros de base de datos y de ¡ndices
   SELECT 1
   USE Cli ORDER C¢d_cli
   GO TOP
   * Usado para consulta de prefijos
   USE Prefijos ORDER Ciudad IN 2

   record_num = RECNO()
   * Cargar el registro inicial de la base de datos a variables de memoria
   DO Load_fld

   * Visualizar la pantalla de datos
   CLEAR
   DO Dstatus
   DO Backgrnd
   DO Show_data

   DO Bar_def            && Definir men£s de ventana

   * Activar el men£ de ventana principal - ejecutar opci¢n
   SET COLOR TO &c_popup.
   ACTIVATE POPUP main_mnu
   DO Sub_ret
   *
RETURN
*========================== fin del procedimiento principal ===============================

*  PROCEDIMIENTOS DE UTILIDADES (Espec¡ficos de cli.prg)

PROCEDURE Filter
  * Agrupar datos por condici¢n de filtro
  * Seleccionar la condici¢n de filtro (S=activar,N=cancelar,D=desactivar)
  * Si el filtro est  activado, la opci¢n por defecto es D, mostrar ventana
  * Si el filtro est  desactivado, la opci¢n por defecto es S, mostrar ventana
  choice = IIF(filters_on,"D","S")
  DO Filt_ans
  IF choice = "S"
     * Comenzar el proceso de selecci¢n de la condici¢n de filtro
     mCategor¡a = SPACE(15)
     mCiudad    = SPACE(20)
     mProvincia = SPACE(2)
     STORE SPACE(10) TO mC¢d_post, mF_pago
     ACTIVATE WINDOW alert
        * Obtener del usuario la condici¢n de filtro
        @  0, 0 SAY "---------- CONDICION DE FILTRO --------- "
        @  1, 0 SAY "CATEGORIA:  " GET mCategor¡a FUNCTION "!" ;
           MESSAGE "Introduzca una categor¡a de cliente"
        @  2, 0 SAY "CIUDAD:     " GET mCiudad    PICTURE "!XXXXXXXXXXXXXXXXXXX"
        @  3, 0 SAY "PROVINCIA:  " GET mProvincia PICTURE  "!!"
        @  3,15 SAY "C.POSTAL:" GET mC¢d_post
        @  4, 0 SAY "FORMA PAGO: " GET mF_pago    FUNCTION "!"
        @  5, 0 SAY "Introduzca una o m s condiciones de filtro"
        READ
    DEACTIVATE WINDOW alert
    subset = " "            && Inicializar la variable de condici¢n de filtro
    * Proceso de entradas para definir la condici¢n de filtro
    mCategor¡a = TRIM(mCategor¡a)
    mCiudad   = UPPER(TRIM(mCiudad))
    mProvincia  = TRIM(mProvincia)
    mC¢d_post    = TRIM(mC¢d_post)
    mF_pago  = TRIM(mF_pago)
    subset  = subset + IIF("" <> mCategor¡a, ;
              [Categor¡a = mCategor¡a .AND. ], "")
    subset  = subset + IIF("" <> mCiudad, ;
              [UPPER(TRIM(Ciudad)) = mCiudad .AND. ], "")
    subset  = subset + IIF("" <> mProvincia, ;
              [Provincia = mProvincia .AND. ], "")
    subset  = subset + IIF("" <> mC¢d_post, ;
              [C¢d_post = mC¢d_post .AND. ], "")
    subset  = subset + IIF("" <> mF_pago, ;
              [F_pago = mF_pago .AND. ], "")
    *
    IF "" = TRIM(subset)      && Comprobar si se han introducido datos en la serie
       DO Warnbell
       filters_on = .F.
    ELSE
       * Si la serie no est  vac¡a, truncar desde .AND. hasta el final
       subset = SUBSTR(subset,1,LEN(subset)-6)
       SET FILTER TO &subset.     && Activar el filtro con la serie introducida
       GO TOP                     && Activar el filtro moviendo el puntero de registro
       * Comprobar si algunos registros cumplen la condici¢n de filtro (ninguno=EOF)
       filters_on = .NOT. EOF()   && Activar el filtro si .T. (encontrados registros que lo cumplen
       IF .NOT. filters_on        && Desactivar el filtro si no se encuentran registros que lo cump
          DO Warnbell
          DO Show_msg WITH "Ning£n registro de Clientes cumple la     condici¢n de filtro"
          SET FILTER TO
          GO record_num
       ENDIF
    ENDIF
  ELSE
     * Si el usuario selecciona "D", desactivar el filtro
     SET FILTER TO
     filters_on = .F.
  ENDIF
RETURN

PROCEDURE Indexer
   * Crear/reconstruir ¡ndices
   INDEX ON C¢d_cli TAG C¢d_cli
   GO TOP
RETURN

PROCEDURE Init_fld
   * Inicializar las variables de memoria para introducir datos
   STORE SPACE(30) TO Cliente, Direcci¢n1
   STORE SPACE(20) TO Ciudad, Contacto, Comentario
   STORE SPACE(10) TO C¢d_post, F_pago
   STORE SPACE(13) TO Tel‚fono, Tel_cont
   Provincia     = "XX"          && Puede ser cualquier provincia o blanco
   C¢d_cli       = SPACE(6)
   Categor¡a     = SPACE(15)
   Direcci¢n2    = SPACE(25)
   Ext_tel       = SPACE(4)
   Ult_fecha     = { / / }
RETURN

PROCEDURE Load_fld
   * Cargar los valores de los campos del registro de Cli en variables de memoria
   C¢d_cli      = C¢d_cli
   Categor¡a    = Categor¡a
   Cliente      = Cliente
   Direcci¢n1   = Direcci¢n1
   Direcci¢n2   = Direcci¢n2
   Ciudad       = Ciudad
   Provincia    = Provincia
   C¢d_post     = C¢d_post
   Tel‚fono     = Tel‚fono
   Contacto     = Contacto
   Tel_cont     = Tel_cont
   Ext_tel      = Ext_tel
   Ult_fecha    = Ult_fecha
   F_pago       = F_pago
   Comentario   = Comentario
RETURN

PROCEDURE Repl_fld
   * Sustituir los campos del fichero con los valores de las variables
   REPLACE C¢d_cli WITH m->C¢d_cli, Categor¡a WITH m->Categor¡a, ;
           Cliente WITH m->Cliente,Direcci¢n1 WITH m->Direcci¢n1, ;
           Direcci¢n2 WITH m->Direcci¢n2,Ciudad WITH m->Ciudad, Provincia WITH m->Provincia
   REPLACE C¢d_post WITH m->C¢d_post, Tel‚fono WITH m->Tel‚fono,;
           Contacto WITH m->Contacto,Tel_cont WITH m->Tel_cont,;
           Ext_tel WITH m->Ext_tel,Ult_fecha WITH m->Ult_fecha, ;
           F_pago WITH m->F_pago,Comentario WITH m->Comentario
RETURN

PROCEDURE Backgrnd
   * Visualizar la pantalla para entrada de datos y visualizaciones
   * Dibujar y rellenar ventanas
   @  1,18 TO  3,41 DOUBLE COLOR &c_blue.
   @  5, 2 TO  7,56 DOUBLE COLOR &c_red.
   @  2,19 FILL TO  2,40   COLOR &c_blue.
   @  6, 3 FILL TO  6,55   COLOR &c_red.
   @  9, 3 FILL TO 19,55   COLOR &c_red.
   @ 15, 2 TO 15,56        COLOR &c_red.
   @  8, 2 TO 20,56        COLOR &c_red.
   SET COLOR TO &c_data.
   @  2,20 SAY "FICHERO DE CLIENTES"
   @  6, 4 SAY "CLIENTE N§:"
   @  6,29 SAY "CATEGORIA:"
   @  9, 4 SAY "NOMBRE:"
   @ 10, 4 SAY "DIRECCION:"
   @ 12, 4 SAY "CIUDAD:   "
   @ 13, 4 SAY "PROVINCIA:"
   @ 13,19 SAY "CODIGO POSTAL:"
   @ 14, 4 SAY "TELEFONO: "
   @ 16, 4 SAY "CONTACTO:"
   @ 17, 4 SAY "TELEFONO:"
   @ 17,29 SAY "EXTENSION:"
   @ 18, 4 SAY "FECHA ULTIMO CONTACTO:"
   @ 19, 4 SAY "F.PAGO:"
   @ 19,24 SAY "COMENTARIO:"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar datos para entrada de datos
   SET COLOR TO &c_fields.
   @  6,16 SAY C¢d_cli
   @  6,40 SAY Categor¡a
   @  9,15 SAY Cliente
   @ 10,15 SAY Direcci¢n1
   @ 11,15 SAY Direcci¢n2
   @ 12,15 SAY Ciudad
   @ 13,15 SAY Provincia
   @ 13,35 SAY C¢d_post
   @ 14,15 SAY Tel‚fono
   @ 16,15 SAY Contacto
   @ 17,15 SAY Tel_cont
   @ 17,40 SAY Ext_tel
   @ 18,27 SAY Ult_fecha
   @ 19,12 SAY F_pago
   @ 19,36 SAY Comentario
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Get_data
   * Visualizar datos para entrada de datos
   SET COLOR TO &c_data.
   @  6,16 GET m->C¢d_cli   PICTURE  "!99999" ;
           VALID Duplicat(&key.) ;
           ERROR "N£mero de cliente no v lido; por favor, introduzca de nuevo" ;
           MESSAGE "Introduzca un cliente de 6 d¡gitos empezando por " + ;
                   "una letra o Esc para salir"
   @  6,40 GET m->Categor¡a ;
           PICTURE "@M ARQUITECTOS, CONSULTORES, CONTRATISTAS, ABOGADOS" ;
           MESSAGE "Pulse espaciador para opciones de categor¡a"
   @  9,15 GET m->Cliente  FUNCTION "!" ;
           MESSAGE "Introduzca nombre de cliente"
   @ 10,15 GET m->Direcci¢n1
   @ 11,15 GET m->Direcci¢n2
   @ 12,15 GET m->Ciudad         PICTURE "!XXXXXXXXXXXXX"
   @ 13,15 GET m->Provincia      PICTURE  "!!"
   @ 13,35 GET m->C¢d_post
   @ 14,15 GET m->Tel‚fono       PICTURE  "(999)999-9999"
   @ 16,15 GET m->Contacto       FUNCTION "!" ;
           MESSAGE "Introduzca nombre de contacto"
   @ 17,15 GET m->Tel_cont PICTURE "(999)999-9999"
   @ 17,40 GET m->Ext_tel  PICTURE "9999" ;
           MESSAGE "Introduzca extensi¢n de tel‚fono"
   @ 18,27 GET m->Ult_fecha  FUNCTION "D" ;
           MESSAGE "Introduzca la fecha de £ltimo contacto"
   @ 19,12 GET m->F_pago      PICTURE "@M CAJA, NETO 30, NETO 45" ;
           MESSAGE "Pulse espaciador para opciones de forma de pago"
   @ 19,36 GET m->Comentario   FUNCTION "!" ;
           MESSAGE "Introduzca comentarios"
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO FindPrefijo WITH m->Ciudad
RETURN
********************************  FIN DE CLI.PRG ***************************************