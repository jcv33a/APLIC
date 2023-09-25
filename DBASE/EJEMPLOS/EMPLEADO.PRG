
******************************************************************************
* NOMBRE DEL PROGRAMA:    EMPLEADO.PRG
*                         PANTALLA DE LA BASE DE DATOS EMPLEADO
*                         PROGRAMA EJEMPLO DE APLICACION DE GESTION
* ULTIMO CAMBIO:          09/25/89 09:26AM
* ESCRITO POR:            ASHTON-TATE
******************************************************************************
*
*       FICHEROS USADOS:
*       Base de datos   = Empleado.dbf  (Fichero de personal empleado)
*       Fichero ¡ndice  = Empleado.mdx
*           TAG: Nombres= apellido+nombre+inicial  <= Indece maestro
*           TAG: Depto  = depart+apellido+nombre+inicial
*           TAG: Estado = depart+STR(salario,8,2)
*           TAG: Exp    = STR(expcia,4,1)
*           TAG: cod_emp= cod_emp
*       Fichero de procedimientos usado = libreria.prg
******************************************************************************

* Procedimiento principal
PROCEDURE Empleado

   * Activar el fichero de procedimientos de "herramientas"
   SET PROCEDURE TO Librer¡a

   * Establecer el entorno para bases de datos
   DO Set_env

   SET COLOR TO &c_standard.

   * Declarar las variables usadas
   * Variables de memoria para los contenidos de las bases de datos
   STORE ""  TO Apellido, Nombre, Inicial, Direcci¢n1, Direcci¢n2, Ciudad, Provincia
   STORE ""  TO C¢d_post, Tel‚fono, C¢d_emp, Especiali, T¡tulo, Premios, Comentario
   STORE ""  TO Depart, Grado
   STORE  0  TO Cat_lab, Expcia, Salario, Porcentaje
   STORE .T. TO Exento, Jorn_comp
   Fecha_alta = {  /  /  }

   * Variables diversas - Usadas para pasar par metros a libreria.prg
   STORE "Empleado" TO dbf,mlist      && Est n disponibles informe y correo por defecto
   STORE "" TO Cli_rpt                && Est (n) disponible(s) informe(s) personalizado(s)
   key      = "m->Apellido+m->Nombre"
   key1     = "m->Apellido"
   key2     = "m->Nombre"
   key3     = "NINGUNO"
   keyNomb1 = "Apellido:"
   keyNomb2 = "Nombre:"
   keyNomb3 = ""
   list_flds  = "Apellido, Nombre, Depart, Tel‚fono"

   * Abrir bases de datos y elegir ¡ndices activos
   SELECT 1
   USE Empleado ORDER Nombres
   GO TOP
   * Usado para consulta de prefijo telef¢nico
   USE Prefijos ORDER Ciudad IN 2

   * Almacenar el registro inicial de la base de datos en variables de memoria
   record_num = RECNO()
   DO Load_fld

   * Mostrar datos en pantalla
   SET COLOR TO &c_standard.
   CLEAR
   DO Dstatus
   DO Backgrnd
   DO Show_data

   * Definir men£s de ventana
   DO Bar_def

   * Activar el menu de ventana principal - Ejecuta la opci¢n del usuario
   SET COLOR TO &c_popup.
   ACTIVATE POPUP main_mnu
   DO Sub_ret
   *
RETURN
*========================= fin del procedimiento principal =========================

*  PROCEDIMIENTOS DE UTILIDADES (Pertenecientes a Empleado.prg)

PROCEDURE Filter
  * Filtrar (agrupar) datos en grupos
  * Seleccionar grupo para establecer condici¢n de filtro (S=Activar,N=Cancelar,D=Desactivar)
  * Si el filtro ya est  activado, poner la opci¢n por defecto a D, visualizar ventana
  * Si el filtro no est  activado, poner la opci¢n por defecto a S, visualizar ventana
  choice = IIF(filters_on,"D","S")
  DO Filt_ans
  IF choice = "S"
    * Comenzar proceso de condici¢n de filtro
    STORE SPACE(15) TO Depart, Grado
    STORE SPACE(11) TO Especiali
    STORE SPACE(3)  TO T¡tulo
    ACTIVATE WINDOW alert
       @   0,0 SAY "---------- CONDICION DE FILTRO -----------"
       @   1,1 SAY "DEPARTAMENTO: " GET m->Depart     FUNCTION "!"
       @   2,1 SAY "GRADO:        " GET m->Grado      FUNCTION "!"
       @   3,1 SAY "ESPECIALIDAD: " GET m->Especiali  FUNCTION "!"
       @   4,1 SAY "TITULO        " GET m->T¡tulo     FUNCTION "!"
       @   5,1 SAY "Introduzca una o m s condiciones"
       READ
    DEACTIVATE WINDOW alert
    * Inicializar variable de filtro en blanco (vac¡o)
    subset = ""
    * Procesamiento de los datos introducidos para formar la condici¢n de filtro
    subset = subset + IIF("" <> TRIM(m->Depart), ;
       [Depart = TRIM("&Depart.") .AND.], "")
    subset = subset + IIF("" <> TRIM(m->Grado), ;
       [Grado = TRIM("&Grado.") .AND.], "")
    subset = subset + IIF("" <> TRIM(m->Especiali), ;
       [Especiali = TRIM("&Especiali.") .AND.], "")
    subset = subset + IIF("" <> TRIM(m->T¡tulo), ;
       [T¡tulo = TRIM("&T¡tulo.") .AND.], "")
    *
    * Comprobar si se introdujeron datos para filtrar
    IF "" = TRIM(subset)
       DO Warnbell
       filters_on = .F.
    ELSE
       * Si la condici¢n de filtro no est  vac¡a, quitar el £ltimo .AND.
       subset = SUBSTR(subset,1,LEN(subset)-6)
       * Filtrar seg£n la condici¢n introducida
       SET FILTER TO &subset.
       * Activar el filtro desplazando el puntero de registro
       GO TOP
       * Comprobar si la condici¢n de filtro agrupa registro(s) (Ninguno=EOF)
       filters_on = .NOT. EOF()
       IF .NOT. filters_on
          * Desactivar el filtro si no se encuentran registros
          DO Warnbell
          DO Show_msg WITH "Ning£n registro de Empleado cumple la     condici¢n de filtro"
          SET FILTER TO
          GO record_num
       ENDIF
    ENDIF
  ELSE
    * Si el usuario selecciona "T", desactivar el filtro
    SET FILTER TO
    filters_on = .F.
  ENDIF
RETURN

PROCEDURE Indexer
   * Crear/reconstruir ¡ndices
   INDEX ON Depart+Apellido+Nombre+Inicial TAG Dept
   INDEX ON Depart+STR(Salario,8,2)            TAG Status
   INDEX ON STR(Expcia,4,1)                    TAG Years
   INDEX ON C¢d_emp                                TAG C¢d_emp
   INDEX ON Apellido+Nombre+Inicial            TAG Nombres
   GO TOP
RETURN

PROCEDURE Init_fld
    * Inicializar variables de memoria para la entrada de datos
    Inicial    = " "
    STORE SPACE(20) TO Direcci¢n1, Direcci¢n2
    STORE SPACE(10) TO Nombre, C¢d_post
    STORE SPACE(15) TO Apellido, Depart, Grado, Premios
    STORE SPACE(11) TO C¢d_emp, Especiali
    STORE 0 TO Cat_lab, Expcia, Salario, Porcentaje
    STORE .T. TO Exento, Jorn_comp
    Ciudad       = SPACE(14)
    Provincia    = SPACE(2)
    Tel‚fono     = SPACE(13)
    T¡tulo       = SPACE(3)
    Comentario   = SPACE(40)
    Fecha_alta   = {  /  /  }
RETURN

PROCEDURE Load_fld
   * Almacenar los campos de la base de datos Empleado en variables de memoria
   Apellido     = Apellido
   Nombre       = Nombre
   Inicial      = Inicial
   C¢d_emp      = C¢d_emp
   Direcci¢n1   = Direcci¢n1
   Direcci¢n2   = Direcci¢n2
   Ciudad       = Ciudad
   Provincia    = Provincia
   C¢d_post     = C¢d_post
   Tel‚fono     = Tel‚fono
   Depart       = Depart
   Grado        = Grado
   Cat_lab      = Cat_lab
   Exento       = Exento
   Jorn_comp    = Jorn_comp
   Fecha_alta   = Fecha_alta
   Especiali    = Especiali
   Expcia       = Expcia
   T¡tulo       = T¡tulo
   Salario      = Salario
   Porcentaje   = Porcentaje
   Premios      = Premios
   Comentario   = Comentario
RETURN

PROCEDURE Repl_fld
   * Almacenar las variables de memoria actuales en los campos de la base de datos
   REPLACE C¢d_emp WITH m->C¢d_emp, Apellido WITH m->Apellido, ;
           Nombre WITH m->Nombre, Inicial WITH m->Inicial, ;
           Direcci¢n1 WITH m->Direcci¢n1, Direcci¢n2 WITH m->Direcci¢n2, ;
           Ciudad  WITH m->Ciudad, Provincia WITH m->Provincia, C¢d_post WITH m->C¢d_post, ;
           Tel‚fono WITH m->Tel‚fono, Depart WITH m->Depart
   REPLACE Grado WITH m->Grado, Cat_lab WITH m->Cat_lab, ;
           Exento WITH m->Exento, Jorn_comp WITH m->Jorn_comp, ;
           Fecha_alta WITH m->Fecha_alta, Especiali WITH m->Especiali, ;
           Expcia WITH m->Expcia, T¡tulo WITH m->T¡tulo, ;
           Salario WITH m->Salario, Porcentaje WITH m->Porcentaje, ;
           Premios WITH m->Premios, Comentario WITH m->Comentario
RETURN

PROCEDURE Backgrnd
   * Mostrar pantalla para introducci¢n y entrada
   * Dibujar y rellenar cajas
   @  1,18 TO   3,41 DOUBLE COLOR &c_blue.
   @  4, 1 TO   6,56 DOUBLE COLOR &c_red.
   @  2,19 FILL TO  2,40    COLOR &c_blue.
   @  4, 2 FILL TO 21,55    COLOR &c_red.
   @ 11, 1 TO  11,56        COLOR &c_red.
   @  7, 1 TO  22,56        COLOR &c_red.
   SET COLOR TO &c_data.
   @  2,20 SAY "FICHERO DE EMPLEADOS"
   @  5, 3 SAY "APELLIDO:"
   @  5,32 SAY "NOMBRE:"
   @  5,54 SAY "."
   @  8, 3 SAY "DIRECCION:"
   @  9, 3 SAY "CIUDAD:"
   @  9,32 SAY "PROVINCIA:"
   @ 10, 3 SAY "C.POSTAL."
   @ 10,32 SAY "TELEFONO:"
   @ 12, 3 SAY "DEPARTAMENTO:"
   @ 12,32 SAY "GRADO:"
   @ 13,32 SAY "ESPECIALID:"
   @ 14, 3 SAY "EMPLEADO N§:"
   @ 14,32 SAY "FECHA DE ALTA:"
   @ 15,32 SAY "JORNADA COMPLETA:"
   @ 16,32 SAY "EXENTO:"
   @ 17,32 SAY "CATEGORIA LABORAL:"
   @ 18, 3 SAY "SALARIO:               ž"
   @ 18,32 SAY "COMISION:"
   @ 18,49 SAY "%"
   @ 19, 3 SAY "TITULO:"
   @ 19,32 SAY "EXPERIENCIA:"
   @ 20, 3 SAY "PREMIOS:"
   @ 21, 3 SAY "COMENTARIO:"
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Show_data
   * Visualizar datos
   SET COLOR TO &c_fields.
   @  5,13 SAY Apellido
   @  5,40 SAY Nombre
   @  5,53 SAY Inicial
   @  8,14 SAY Direcci¢n1
   @  8,35 SAY Direcci¢n2
   @  9,14 SAY Ciudad
   @  9,53 SAY Provincia
   @ 10,14 SAY C¢d_post
   @ 10,42 SAY Tel‚fono
   @ 12,17 SAY Depart
   @ 12,40 SAY Grado
   @ 13,44 SAY Especiali
   @ 14,17 SAY C¢d_emp
   @ 14,47 SAY Fecha_alta
   @ 15,54 SAY Jorn_comp  PICTURE  "Y"
   @ 16,54 SAY Exento     PICTURE  "Y"
   @ 17,54 SAY Cat_lab    PICTURE  "9"
   @ 18,15 SAY Salario    PICTURE  "99,999,999"
   @ 18,51 SAY Porcentaje PICTURE  "99.9"
   @ 19,15 SAY T¡tulo
   @ 19,51 SAY Expcia     PICTURE  "99.9"
   @ 20,15 SAY Premios
   @ 21,15 SAY Comentario
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO FindPrefijo WITH m->Ciudad
RETURN

PROCEDURE Get_data
   * Visualizar pantalla para entrada de datos
   SET COLOR TO &c_data.
   @  5,13 GET m->Apellido   PICTURE "!XXXXXXXXXXXXXX" ;
           MESSAGE "Introduzca apellido de empleado"
   @  5,40 GET m->Nombre     PICTURE "!XXXXXXXXX"
   @  5,53 GET m->Inicial    PICTURE "!"
   @  8,14 GET m->Direcci¢n1
   @  8,35 GET m->Direcci¢n2
   @  9,14 GET m->Ciudad     PICTURE "!XXXXXXXXXXXXX"
   @  9,53 GET m->Provincia  PICTURE "!!"
   @ 10,14 GET m->C¢d_post
   @ 10,42 GET m->Tel‚fono   PICTURE  "(999)999-9999"
   @ 12,17 GET m->Depart     PICTURE "@M VENTAS, EJECUTIVO" ;
           MESSAGE "Pulse espaciador para opciones de departamento"
   @ 12,40 GET m->Grado      FUNCTION "!"
   @ 13,44 GET m->Especiali  FUNCTION "!"
   @ 14,17 GET m->C¢d_emp    PICTURE  "999-99-9999"
   @ 14,47 GET m->Fecha_alta FUNCTION "D"
   @ 15,54 GET m->Jorn_comp  PICTURE  "Y" ;
           WHEN TRIM(m->Depart) <> "EJECUTIVO"
   @ 16,54 GET m->Exento     PICTURE  "Y" ;
           WHEN TRIM(m->Depart) <> "EJECUTIVO"
   @ 17,54 GET m->Cat_lab    PICTURE  "9"
   @ 18,15 GET m->Salario    PICTURE  "99,999,999"
   @ 18,51 GET m->Porcentaje PICTURE  "99.9" ;
           WHEN TRIM(m->Depart) <> "EJECUTIVO"
   @ 19,15 GET m->T¡tulo     PICTURE  "!!!"
   @ 19,51 GET m->Expcia  PICTURE  "99.9"
   @ 20,15 GET m->Premios     FUNCTION "!"
   @ 21,15 GET m->Comentario
   SET COLOR TO &c_standard.
   ON KEY LABEL F9 DO FindPrefijo WITH m->Ciudad
RETURN

**********************************  FIN DE EMPLEADO.PRG  ********************************
