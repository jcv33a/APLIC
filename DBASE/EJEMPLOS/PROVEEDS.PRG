
******************************************************************************
* NOMBRE DEL PROGRAMA:          PROVEEDS.PRG
*                               PANTALLA DEL FICHERO DE PROVEEDORES
*                               PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:                09/25/89 09:26AM
* ESCRITO POR:                  ASHTON-TATE
******************************************************************************
*
*       FICHEROS USADOS:
*       Fichero de Base de datos  =  Proveeds.dbf  (Fichero de proveedores)
*       Fichero de ¡ndices        =  Proveeds.mdx
*         ETIQUETA: Cod_prove =  cod_prove  <= Indice maestro
*       Fichero de procedimientos externos = Libreria.prg
******************************************************************************

* Procedimiento principal
PROCEDURE Proveeds

   * Enlazar con el fichero de procedimientos externos
   SET PROCEDURE TO Librer¡a

   * Definir entorno del fichero
   DO Set_env

   SET COLOR TO &c_standard.

   * Declaraci¢n de variables usadas:
   * Variables de memoria para los campos de la base de datos
   Descuento = 0
   STORE "" TO C¢d_prove, Proveedor, Direcci¢n1, Direcci¢n2, Ciudad, Provincia
   STORE "" TO C¢d_post, Tel‚fono, Contacto, Ext_tel, F_pago

   * Variables diversas - usadas para pasar par metros a Libreria
   STORE "Proveeds" TO dbf, mlist      && Informe est ndar y lista de correo disponible
   Cli_rpt = "N/D"                     && Informe personalizado no disponible
   STORE "m->C¢d_prove" TO key, key1
   STORE  "NINGUNO" TO key2, key3
   keyNomb1 = "Proveedor N§:"
   STORE "" TO keyNomb2, keyNomb3
   list_flds = "C¢d_prove, Proveedor, Tel‚fono"

   * Abrir ficheros de base de datos y de ¡ndices
   SELECT 1
   USE Proveeds ORDER C¢d_prove
   GO TOP
   * Usado para consulta de prefijos
   USE Prefijos ORDER Ciudad IN 2

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
*================= fin del procedimiento principal =========================

*  PROCEDIMIENTOS DE UTILIDADES (Espec¡ficos de proveeds.prg)

PROCEDURE Filter
  * Agrupar datos por condici¢n de filtro
  * Seleccionar la condici¢n de filtro (S=activar,N=cancelar,D=desactivar)
  * Si el filtro est  activado, la opci¢n por defecto es D, mostrar ventana
  * Si el filtro est  desactivado, la opci¢n por defecto es S, mostrar ventana
   choice = IIF(filters_on,"D","S")
   DO Filt_ans
   IF choice = "S"
      * Comenzar el proceso de selecci¢n de la condici¢n de filtro
      STORE SPACE(15) TO Ciudad,F_pago
      STORE SPACE(2)  TO Provincia
      STORE SPACE(10) TO C¢d_post
      ACTIVATE WINDOW alert
         * Obtener del usuario la condici¢n del filtro
         @   0,0 SAY "---------- CONDICION DE FILTRO ----------"
         @   1,1 SAY "CIUDAD:    " GET m->Ciudad     PICTURE "!XXXXXXXXXXXXX"
         @   2,1 SAY "PROVINCIA: " GET m->Provincia  PICTURE "!!"
         @   3,1 SAY "C. POSTAL: " GET m->C¢d_post
         @   4,1 SAY "FORMA PAGO:" GET m->F_pago  FUNCTION "!"
         READ
      DEACTIVATE WINDOW alert
      * Inicializar la variable de condici¢n de filtro
      PUBLIC subset1,subset2,subset3,subset4,subset5
      subset1 = ""
      * Proceso de entradas para definir la condici¢n de filtro
      subset2 = subset1 + IIF([] <> TRIM(m->Ciudad), ;
                [UPPER(Ciudad) = UPPER(TRIM(m->Ciudad)) .AND. ], [])
      subset3 = subset2 + IIF([] <> TRIM(m->Provincia), ;
                [Provincia = TRIM(Provincia) .AND. ], [])
      subset4 = subset3 + IIF([] <> TRIM(m->C¢d_post), ;
                [C¢d_post = TRIM(C¢d_post) .AND. ], [])
      subset5 = subset4 + IIF("" <> TRIM(m->F_pago), ;
                [F_pago = TRIM(F_pago) .AND. ], [])
      subset = subset5
      *
      * Comprobar si se han introducido datos en la serie
      IF "" = TRIM(subset)
         DO Warnbell
         filters_on = .F.
      ELSE
         * Si la serie no est  vacia, truncar desde .AND. hasta el final
         subset = SUBSTR(subset, 1, LEN(subset) - 6)
         * Activar filtro con la serie introducida
         SET FILTER TO &subset.
         * Activar filtro moviendo el puntero de registro
         GO TOP
         * Comprobar si algunos registros cumplen la condici¢n de filtro (ninguno=EOF)
         filters_on = .NOT. EOF()   && Activar el filtro si .T. (encontrados registros que cumplen la condici¢n)
         IF .NOT. filters_on
            * Desactivar el filtro si no se encuentran registros que cumplan la condici¢n
            DO Warnbell
            DO Show_msg WITH "Ning£n registro de Proveedores cumple     la condici¢n de filtro."
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
   INDEX ON C¢d_prove TAG C¢d_prove
   GO TOP
RETURN

PROCEDURE Init_fld
   * Inicializar las variables de memoria para introducir datos
   STORE SPACE(4)  TO C¢d_prove,Ext_tel
   STORE SPACE(30) TO Proveedor, Direcci¢n1, Direcci¢n2, Contacto
   F_pago    = SPACE(15)
   Descuento = 0
   Ciudad    = SPACE(20)
   Provincia = "XX"                   && Puede ser cualquier provincia o blanco
   C¢d_post  = SPACE(10)
   Tel‚fono  = SPACE(13)
RETURN

PROCEDURE Load_fld
   * Cargar los valores de los campos del registro de Proveedores en variables de memoria
   C¢d_prove   = C¢d_prove
   Proveedor   = Proveedor
   Direcci¢n1  = Direcci¢n1
   Direcci¢n2  = Direcci¢n2
   Ciudad      = Ciudad
   Provincia   = Provincia
   C¢d_post    = C¢d_post
   Tel‚fono    = Tel‚fono
   Contacto    = Contacto
   Ext_tel     = Ext_tel
   F_pago      = F_pago
   Descuento   = Descuento
RETURN

PROCEDURE Repl_fld
   * Sustituir los campos del fichero con los valores de las variables
   REPLACE C¢d_prove WITH m->C¢d_prove,Proveedor WITH m->Proveedor, ;
           Direcci¢n1 WITH m->Direcci¢n1,Direcci¢n2 WITH m->Direcci¢n2, ;
           Ciudad WITH m->Ciudad,Provincia   WITH m->Provincia, ;
           C¢d_post WITH m->C¢d_post,Tel‚fono WITH m->Tel‚fono, ;
           Contacto WITH m->Contacto,Ext_tel  WITH m->Ext_tel, ;
           F_pago WITH m->F_pago,Descuento WITH m->Descuento
RETURN

PROCEDURE Backgrnd
   * Visualizar la pantalla para entrada de datos y visualizaciones
   * Dibujar y rellenar ventanas
   @ 14, 5 TO 14,52        COLOR &c_red.
   @  1,22 TO  3,53 DOUBLE COLOR &c_blue.
   @  5, 4 TO  7,27 DOUBLE COLOR &c_red.
   @  8, 4 TO 19,53        COLOR &c_red.
   @  2,23 FILL TO  2,52   COLOR &c_blue.
   @  6, 5 FILL TO  6,26   COLOR &c_red.
   @  9, 5 FILL TO 18,52   COLOR &c_red.
   * Visualizar datos
   SET COLOR TO &c_data.
   @  2,27 SAY "FICHERO DE PROVEEDORES"
   @  6, 6 SAY "PROVEEDOR N§:"
   @  9, 6 SAY "NOMBRE:"
   @ 10, 6 SAY "DIRECCION:"
   @ 12, 6 SAY "CIUDAD:"
   @ 13, 6 SAY "PROVINCIA:"
   @ 13,27 SAY "C. POSTAL:"
   @ 15, 6 SAY "CONTACTO:"
   @ 16, 6 SAY "TELEFONO:"
   @ 16,32 SAY "EXTENSION:"
   @ 17, 6 SAY "F. PAGO:"
   @ 18, 6 SAY "DESCUENTO:"
   @ 18,20 SAY "%"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar datos
   SET COLOR TO &c_fields.
   @  6,21 SAY C¢d_prove
   @  9,17 SAY Proveedor
   @ 10,17 SAY Direcci¢n1
   @ 11,17 SAY Direcci¢n2
   @ 12,17 SAY Ciudad
   @ 13,17 SAY Provincia
   @ 13,38 SAY C¢d_post
   @ 15,17 SAY Contacto
   @ 16,17 SAY Tel‚fono
   @ 16,43 SAY Ext_tel
   @ 17,17 SAY F_pago
   @ 18,17 SAY Descuento  PICTURE "99"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Get_data
   * Visualizar pantalla para entrada de datos
   SET COLOR TO &c_data.
   @  6,21 GET m->C¢d_prove  PICTURE  "9999" ;
           VALID Duplicat(&key.) ;
           ERROR "N§ de proveedor no v lido. Por favor, introduzca de nuevo" ;
           MESSAGE "Introduzca un n§ de proveedor con 4 d¡gitos o Esc para salir"
   @  9,17 GET m->Proveedor   FUNCTION "!" ;
           MESSAGE "Introduzca nombre de proveedor"
   @ 10,17 GET m->Direcci¢n1  FUNCTION "!"
   @ 11,17 GET m->Direcci¢n2  FUNCTION "!"
   @ 12,17 GET m->Ciudad      PICTURE "!XXXXXXXXXXXXX"
   @ 13,17 GET m->Provincia   PICTURE  "!!"
   @ 13,38 GET m->C¢d_post
   @ 15,17 GET m->Contacto    FUNCTION "!" ;
           MESSAGE "Introduzca nombre del contacto del proveedor"
   @ 16,17 GET m->Tel‚fono    PICTURE "(999)999-9999"
   @ 16,43 GET m->Ext_tel     PICTURE "9999" ;
           MESSAGE "Introduzca la extensi¢n del tel‚fono"
   @ 17,17 GET m->F_pago      FUNCTION "!" ;
           MESSAGE "Introduzca la forma de pago"
   @ 18,17 GET m->Descuento  PICTURE "99" ;
           MESSAGE "Introduzca un porcentaje de descuento (m x. 99)"
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO FindPrefijo WITH m->Ciudad
RETURN

****************************  FIN DE PROVEEDS.PRG  ****************************