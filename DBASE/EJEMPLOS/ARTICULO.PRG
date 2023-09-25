
******************************************************************************
* PROGRAMA:                       ARTICULO.PRG
*                                 PANTALLA DE BASES DE DATOS INVENTARIO
*                                 PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:                  09/25/89 09:26AM
* ESCRITO POR:                    ASHTON-TATE
******************************************************************************
*
*       FICHEROS USADOS:
*       Base de datos      =  Art¡culo.dbf  (Fichero de inventario)
*       Fichero ¡ndice     =  Art¡culo.mdx
*           TAG: cod_art   =  cod_art   <= Master index
*           TAG: cod_prove =  cod_prove
*       Fichero externo de procedimientos = Libreria.prg
******************************************************************************

* Procedimiento principal
PROCEDURE Art¡culo

   * Activar fichero de procedimientos de "herramientas"
   SET PROCEDURE TO Librer¡a

   * Establecer entorno para bases de datos
   DO Set_env

   SET COLOR TO &c_standard.

   * Declarar variables usadas:
   * Variables de memoria para bases de datos
   STORE ""  TO C¢d_art, Nom_art, Descrip, C¢d_prove, Comentario
   STORE 0   TO Precio, Coste, Can_alm, Can_a_ped, D¡as_serv
   Suspendido = .F.

   * Variables diversas - usadas para pasar parametros a Libreria
   dbf      = "Art¡culo"                 && Est  disponible informe por omisi¢n
   mlist    = "NO DISPONIBLE "           && Lista de correo no disponible
   Cli_rpt  = "N/D"                      && Informe personalizado no disponible
   STORE "m->C¢d_art" TO key, key1
   STORE "NINGUNO" TO key2, key3
   keyNomb1 = "Part ID:"
   STORE "" TO keyNomb2, keyNomb3, mProveedorid
   list_flds = "C¢d_art, Nom_art, Can_alm"

   * Abrir bases de datos y elejir ¡ndices activos
   SELECT 1
   USE Art¡culo ORDER C¢d_art
   GO TOP
   * Usado para consultas de los datos de proveedores
   USE Proveeds ORDER C¢d_prove IN 2

   record_num = RECNO()
   DO Load_fld

   * Visualizar datos en pantalla
   CLEAR
   DO Dstatus
   DO Backgrnd
   DO Show_data

   * Definir men£s de ventana
   DO Bar_def

   * Activar men£ principal de ventana - Ejecutar las opciones del usuario
   SET COLOR TO &c_popup.
   ACTIVATE POPUP main_mnu
   DO Sub_ret
   *
RETURN
*======================== fin de procedimiento principal ==============================

*  PROCEDIMIENTOS DE UTILIDADES (espec¡ficos de art¡culo.prg)

PROCEDURE Filter
   * Filtrar (agrupar) datos seg£n condici¢n de filtro
   * Seleccionar agrupamiento para fijar condici¢n de filtro (S=Activar,N=Cancelar,D=Desactivar)
   * Si filtro ya activo, fijar D como opci¢n por defecto, visualizar ventana
   * Si filtro no activo, fijar S como opci¢n por defecto, visualizar ventana
   choice = IIF(filters_on,"D","S")
   DO Filt_ans
   IF choice = "S"
      * Comenzar proceso de selecci¢n de condici¢n de filtro
      mProveedorid  = SPACE(4)
      ACTIVATE WINDOW alert
         * Obtener del usuario la(s) condici¢n(es) de filtro
         @  0, 0 SAY "---------- CONDICION DE FILTRO -----------"
         @  2, 0 SAY "N§ PROVEEDOR:" GET mProveedorid FUNCTION "9"
         READ
      DEACTIVATE WINDOW alert
      *
      * Comprobar si se introdujeron datos en la condici¢n de filtro
      IF "" = TRIM(mProveedorid)
         filters_on = .F.
         DO Warnbell
      ELSE
         * Filtrar seg£n la condici¢n de filtro introducida
         SET FILTER TO C¢d_prove = TRIM(mProveedorid)
         * Resituar el registro de puntero al activar el filtro
         GO TOP
         * Comprobar si hay registros que cumplen la condici¢n de filtro (Ninguno=EOF)
         filters_on = .NOT. EOF()   && Filtro activo si .T. (Hay registros)
         IF .NOT. filters_on
            * Desactivar el filtro si ning£n registro cumple la condici¢n
            DO Warnbell
            DO Show_msg WITH "Ning£n registro de Inventario cumple" + ;
                             " la   condici¢n de filtro"
            SET FILTER TO
            GO record_num
         ENDIF
      ENDIF
   ELSE
      * Si el usuario selecciona "D", desactivar filtro
      SET FILTER TO
      filters_on = .F.
   ENDIF
RETURN

PROCEDURE Indexer
   * Crear/reconstruir ¡ndices
   INDEX ON C¢d_prove TAG C¢d_prove
   INDEX ON C¢d_art   TAG C¢d_art
   GO TOP
RETURN

PROCEDURE Init_fld
   * Inicializar variables de memoria para la entrada de datos
   C¢d_art   = SPACE(10)
   STORE SPACE(30) TO Nom_art, Descrip, Comentario
   STORE 0 TO Can_alm, Coste, Precio, Can_a_ped, D¡as_serv
   C¢d_prove = SPACE(4)
RETURN

PROCEDURE Load_fld
   * Almacenar los valores de los campos de Articulo.dbf en variables de memoria
   C¢d_art     = C¢d_art
   Nom_art     = Nom_art
   Descrip     = Descrip
   Can_alm     = Can_alm
   Coste       = Coste
   Precio      = Precio
   Can_a_ped   = Can_a_ped
   C¢d_prove   = C¢d_prove
   D¡as_serv   = D¡as_serv
   Comentario  = Comentario
RETURN

PROCEDURE Repl_fld
   * Almacenar las variables de memoria actuales en los campos de la base de datos
   REPLACE C¢d_art WITH m->C¢d_art, Nom_art WITH m->Nom_art, ;
           Descrip WITH m->Descrip, Can_alm WITH m->Can_alm, ;
           Coste WITH m->Coste, Precio WITH m->Precio, ;
           Can_a_ped WITH m->Can_a_ped, C¢d_prove WITH m->C¢d_prove, ;
           D¡as_serv WITH m->D¡as_serv, Comentario WITH m->Comentario
RETURN

PROCEDURE Backgrnd
   * Mostrar pantalla para la entrada de datos y visualizaci¢n
   * Dibujar y rellenar cajas
   @  1,17 TO  3,46 DOUBLE COLOR &c_blue.
   @  5, 2 TO  7,30 DOUBLE COLOR &c_red.
   @  2,18 FILL TO  2,45   COLOR &c_blue.
   @  6, 3 FILL TO  6,29   COLOR &c_red.
   @  9, 3 FILL TO 18,54   COLOR &c_red.
   @ 13, 3 TO 13,54        COLOR &c_red.
   @  8, 2 TO 19,55        COLOR &c_red.
   SET COLOR TO &c_data.
   @  2,21 SAY "FICHERO DE INVENTARIO"
   @  6, 4 SAY "ARTICULO N§:"
   @  9, 4 SAY "NOMBRE:"
   @ 10, 4 SAY "DESCRIPCION:"
   @ 11, 4 SAY "P.V.P.:"
   @ 12, 4 SAY "CANTIDAD EN ALMACEN:"
   @ 12,34 SAY "SUSPENDIDO:"
   @ 14, 4 SAY "NUMERO DE PROVEEDOR:"
   @ 15, 4 SAY "COSTE:                         ž"
   @ 16, 4 SAY "CANTIDAD A PEDIR:"
   @ 16,31 SAY "(minimo/lote)"
   @ 17, 4 SAY "ROTACION:"
   @ 17,20 SAY "(en d¡as)"
   @ 18, 4 SAY "COMENTARIO:"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar pantalla para entrada de datos
   SET COLOR TO &c_fields.
   @  6,17 SAY C¢d_art
   @  9,17 SAY Nom_art
   @ 10,17 SAY Descrip
   @ 11,17 SAY Precio      PICTURE  "9,999,999"
   @ 12,25 SAY Can_alm     PICTURE  "9,999"
   @ 12,46 SAY Suspendido  PICTURE  "Y"
   @ 14,25 SAY C¢d_prove
   @ 15,25 SAY Coste       PICTURE  "9,999,999"
   @ 16,25 SAY Can_a_ped   PICTURE  "9,999"
   @ 17,16 SAY D¡as_serv   PICTURE  "999"
   @ 18,16 SAY Comentario
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Get_data
   * Visualizar pantalla para entrada de datos
   SET COLOR TO &c_data.
   @  6,17 GET m->C¢d_art    FUNCTION "!" ;
           VALID Duplicat(&key.) ;
           ERROR "N§ de art¡culo repetido - Por favor, introduzca de nuevo" ;
           MESSAGE "Introduzca un n§ de art¡culo correcto, o pulse Esc para salir"
   @  9,17 GET m->Nom_art  FUNCTION "!" ;
           MESSAGE "Introduzca el nombre del art¡culo"
   @ 10,17 GET m->Descrip   FUNCTION "!" ;
           MESSAGE "Introduzca la descripci¢n del art¡culo"
   @ 11,17 GET m->Precio      PICTURE  "9,999,999" ;
           MESSAGE "Introduzca el precio de venta del art¡culo"
   @ 12,25 GET m->Can_alm PICTURE  "9,999" ;
           MESSAGE "Introduzca la cantidad de art¡culos incluidos en el inventario"
   @ 12,46 GET m->Suspendido PICTURE  "Y" ;
           MESSAGE "Is the part now Suspendidoed (Y/N)"
   @ 14,25 GET m->C¢d_prove  FUNCTION "9" ;
           VALID Lookupid((m->C¢d_prove),"Proveeds", "Proveedor",1) ;
           ERROR "N§ de proveedor no v lido. Por favor, introduzca de nuevo" ;
           MESSAGE "Introduzca n§ de proveedor, o Esc para salir"
   @ 15,25 GET m->Coste       PICTURE  "9,999,999" ;
           MESSAGE "Introduzca el coste del art¡culo"
   @ 16,25 GET m->Can_a_ped PICTURE  "9,999" ;
           MESSAGE "Introduzca la cantidad m¡nima que puede ser pedida"
   @ 17,16 GET m->D¡as_serv  PICTURE  "999" ;
           MESSAGE "Introduzca el tiempo de servicio del proveedor" + ;
                   "que habitualmente sirve los art¡culos"
   @ 18,16 GET m->Comentario   FUNCTION "!" ;
           MESSAGE "Introduzca comentarios sobre el art¡culo"
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO Findvend WITH m->C¢d_prove
RETURN

*********************************** FIN DE ARTICULO.PRG *********************************
