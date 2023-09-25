******************************************************************************
* Program......: CHRTMSTR.PRG (dBASE/CHART-MASTER Bridge)
* Authors......: Douglas Haman & Kirk Nason
* .............: Ashton-Tate Torrance Development Center
* Date.........: 6-15-87
* Notice.......: Ashton-Tate 1987, 1988, 1989
* Version......: dBASE IV 1.1
* Description..: Draws and activates menus
* Modified.....: 04/30/90 VER. 1.1.6
*              : Added error check to allow only eight variables
*              : Added gc_deli variable to fix delimiter bug
*              : Per Doc added to decimals line 1057
*              : Put check in for 52 observations for "clustered bar" and
*                  "stacked bar"
*              : Restore .dbf file properly after return from QBE
*              : Fix Legend name problem - displayed wrong Legend titles
*              : Error check for negative numbers for "Pie" charts
*              : Default chart type to Clusterd Bar, If no chart type is picked
*              : Fixed bubble sort on gc_lgnd for a full array
******************************************************************************

ON ERROR DO PAUSE WITH "N§ de l¡nea de programa "+Program()+": "+LTRIM(STR(LINE()))

*-- Set Environment
IF SET("TALK")="ON"         && Check current talk setting before changing it
   SET TALK OFF
   gc_talk="ON"
ELSE
   gc_talk="OFF"
ENDIF
gc_bell = SET("BELL")       && Get current bell setting before changing it
gc_clock = SET("CLOCK")     && Get current clock setting before changing it
gc_fullpth = SET("FULLPATH")&& Get current fullpath setting before changing it
gc_space= SET("SPACE")      && Get current space setting before turning off
gc_deli = SET("DELIMITERS") && Get current delimiters setting before turning off
gc_escape = SET("ESCAPE")   && Get current escape setting before changing it
gc_safety = SET("SAFETY")   && Get current safety setting before changing it
gc_status = SET("STATUS")   && Get current status setting before turning off
gc_cursor = SET("CURSOR")   && Get current cursor setting before turning on

SET BELL OFF
SET CLOCK OFF
SET CURSOR ON
SET FULLPATH ON
SET SPACE ON
SET DELIMITERS OFF
SET ESCAPE OFF
SET SAFETY OFF
SET STATUS OFF
SET MESSAGE TO
CLEAR
CLEAR WINDOWS

*-- Declare global Variables --------------------------------------------------
gc_cat = SET("CATALOG")
IF gc_cat = "ON"        && If catalog is on we turn it off
   gc_catname = DBF(10)
   SET CATALOG TO
ENDIF
gc_mess = "Situar barra: "+CHR(27)+CHR(26)+CHR(24)+CHR(25) + "    " +;
        " Seleccionar: "+CHR(17)+CHR(196)+CHR(217)
gc_brdr = "1"
gn_error = 0
*-- gc_obflg: 1 = Auto (Obs1 Obs2 ... Obsn), 2 = Field, 3 = OFF
gc_obflg = "1"
gc_chtype = " C"                             && Default type to Clustered bar
gl_quit = .F.
gc_path = ""
STORE 0 TO gn_obs, gn_var
STORE SPACE(20) TO xaxis1,xaxis2,yaxis1,yaxis2
DECLARE gc_title[4], gc_lgnd[8,2]
DO initarry
STORE SPACE(26) TO gc_title[1], gc_title[2], gc_title[3], gc_title[4]


STORE " " TO gc_fldlst, gc_obslbl, gc_memfile, gc_mchrt
gc_filt = SPACE(200)
gc_dbf = DBF()            && Get current open dbf if there is one
IF "" <> gc_dbf
   gc_memfile = SUBSTR(gc_dbf,1,LEN(gc_dbf)-4)+".MEM"
   IF FILE(gc_memfile)
      *-- If chart definition file restore from it
      RESTORE FROM (gc_memfile) ADDITIVE
      DO chkarray
   ENDIF
ENDIF
*------------------------------------------------------------------------------

*-- Set Border style
SET BORDER TO DOUBLE
*-- If you want this application to have color uncomment the lines below
*   and search for the word "COLOR &gc_strclr" and remove the "&&" before the
*   word COLOR
gc_strclr = IIF( ISCOLOR(), "GR+/B", "W/N")
*IF ISCOLOR()
*   SET COLOR OF INFORMATION TO GR+/B
*   SET COLOR OF BOX TO GR+/B
*   SET COLOR OF TITLES TO GR+/B
*   SET COLOR OF HIGHLIGHT TO GR+/B
*   SET COLOR OF NORMAL TO BG+/RB
*   SET COLOR OF FIELDS TO GR+/B
*   SET COLOR OF MESSAGES TO BG+/RB
*ENDIF
SET STATUS ON

DEFINE WINDOW pause FROM 15,00 TO 19,79
DEFINE WINDOW temp FROM 8,20 TO 15,60
ACTIVATE WINDOW temp
@ 2,01 SAY "   Bienvenido a dBASE/CHART-MASTER"
@ 3,13 SAY "Versi¢n 1.1"

gn_temp = INKEY(3)
RELEASE gn_temp

*-- Define Menu & pads
DEFINE MENU Chtbar
DEFINE PAD Database OF Chtbar AT 1, 1 PROMPT "Ficheros"
DEFINE PAD Chart    OF Chtbar AT 1,16 PROMPT "Gr ficos"
DEFINE PAD Help     OF Chtbar AT 1,33 PROMPT "Ayuda"
DEFINE PAD Exit     OF Chtbar AT 1,50 PROMPT "Salir"

*-- Define pad actions
ON PAD Database OF Chtbar ACTIVATE POPUP CdB
ON PAD Chart    OF Chtbar ACTIVATE POPUP Cht
ON PAD Help     OF Chtbar ACTIVATE POPUP Chelp
ON PAD Exit     OF Chtbar ACTIVATE POPUP Csave

*-- Define popups under pads menu
DEFINE POPUP CdB FROM 2,1 MESSAGE gc_mess
DEFINE BAR 1 OF CdB PROMPT " Seleccionar base de datos" MESSAGE "Seleccionar un fichero de base de datos para crear un gr fico (necesario)"
DEFINE BAR 2 OF CdB PROMPT " Definir condici¢n de filtro " MESSAGE "Introducir una condici¢n para determinar los registros a incluir en el gr fico"
ON SELECTION POPUP CdB DO Prc1 WITH BAR()

DEFINE POPUP Cht FROM 2,16 MESSAGE gc_mess
DEFINE BAR 1 OF Cht PROMPT " Identificar campos como variables " MESSAGE "Seleccionar hasta ocho campos num‚ricos a incluir en el gr fico (necesario)"
DEFINE BAR 2 OF Cht PROMPT " Visualizar observaciones ... " MESSAGE "Seleccionar el tipo de etiquetas de observaci¢n para eje X del gr fico"
DEFINE BAR 3 OF Cht PROMPT " Crear/modificar t¡tulos" MESSAGE "Introducir t¡tulo del gr fico, etiquetas de ejes y observaciones"
DEFINE BAR 4 OF Cht PROMPT " Seleccionar tipo de gr fico" MESSAGE "Seleccionar el tipo de gr fico a crear"
DEFINE BAR 5 OF Cht PROMPT " Generar fichero de gr fico (.cht) " MESSAGE "Generar fichero de gr fico seg£n se ha definido"
ON SELECTION POPUP Cht DO Prc2 WITH BAR()

DEFINE POPUP CHelp FROM 2,33 MESSAGE gc_mess
DEFINE BAR 1 OF CHelp PROMPT [ C¢mo usar el enlace "dBASE/CHART-MASTER"] MESSAGE "Revisar todas las opciones y men£s del programa de enlace con CHART-MASTER"
DEFINE BAR 2 OF CHelp PROMPT " Introducci¢n a CHART-MASTER" MESSAGE "Consultar informaci¢n sobre CHART-MASTER"
DEFINE BAR 3 OF CHelp PROMPT " Preparar un fichero .dbf para CHART-MASTER" MESSAGE "Consultar procedimiento de preparaci¢n de base de datos a usar con CHART-MASTER"
DEFINE BAR 4 OF CHelp PROMPT " Convertir fichero .dbf en fichero de gr fico  " MESSAGE "Consultar procedimiento de conversi¢n de un fichero de datos en un gr fico"
DEFINE BAR 5 OF CHelp PROMPT " Visualizar/editar gr ficos" MESSAGE "Consultar procedimiento para visualizar y editar el gr fico generado"
ON SELECTION POPUP CHelp DO Prc3 WITH BAR(), ALLTRIM(PROMPT())

DEFINE POPUP Csave FROM 2,50 MESSAGE gc_mess
DEFINE BAR 1 OF Csave PROMPT " Almacenar cambios y salir" MESSAGE "   Almacenar todos los cambios y salir del programa de enlace con CHART-MASTER     Bridge"
DEFINE BAR 2 OF Csave PROMPT " Cancelar cambios y salir " MESSAGE "Salir del programa de enlace con CHART-MASTER sin almacenar ning£n cambio"
DEFINE BAR 3 OF Csave PROMPT " Transferir a dise¤o de consulta  " MESSAGE "Ir a dise¤o de consulta para crear vista a usar con enlace de CHART-MASTER"
ON SELECTION POPUP Csave DO Prc4 WITH BAR()

*-- Define sub-level popup's
DEFINE POPUP dBfiles FROM 4,8 PROMPT FILES LIKE *.DBF
ON SELECTION POPUP dBfiles DO OpendB WITH PROMPT(), .T.

*-- Define sub-level popup's
DEFINE POPUP Coblab FROM 5,23 MESSAGE gc_mess
DEFINE BAR 1 OF Coblab PROMPT [ Por omisi¢n ("Obs1...") ] MESSAGE "Utilizar las etiquetas de observaci¢n por omisi¢n (Obs1, Obs2, Obs3, etc.)"
DEFINE BAR 2 OF Coblab PROMPT [ Derivadas de campos] MESSAGE "Utilizar campo tipo car cter, num‚rico o de fecha como etiqueta de observaci¢n"
DEFINE BAR 3 OF Coblab PROMPT [ Sin observaciones] MESSAGE "No poner etiquetas en el eje X del gr fico "
ON SELECTION POPUP Coblab DO Cobsub WITH BAR()

DEFINE POPUP Chttype FROM 7,23 TO 14,39 MESSAGE gc_mess
DEFINE BAR 1 OF Chttype PROMPT " L¡neas" MESSAGE "Dibujar gr fico con una l¡nea que cruce cada punto de cada variable"
DEFINE BAR 2 OF Chttype PROMPT " Circular" MESSAGE "Dibujar gr fico donde cada variable representa un sector de un c¡rculo"
DEFINE BAR 3 OF Chttype PROMPT " Barras " MESSAGE "Visualizar informaci¢n en forma de barras una a continuaci¢n de otra"
DEFINE BAR 4 OF Chttype PROMPT " Apiladas" MESSAGE "Visualizar informaci¢n en forma de barras apiladas una encima de otra"
DEFINE BAR 5 OF Chttype PROMPT " Puntos" MESSAGE "Dibujar gr fico con un s¡mbolo en cada coordenada de cada variable"
DEFINE BAR 6 OF Chttype PROMPT " Superficie" MESSAGE "Dibujar gr fico con la superficie sombreada entre cada l¡nea y el eje X"
ON SELECTION POPUP Chttype DO Cht_type WITH BAR()

RELEASE WINDOW temp

*-- Desktop under pad menu & above status line
DEFINE WINDOW desktop FROM 2,0 TO 21,79 NONE
*-- Window for showing fields picked by user
DEFINE WINDOW fldlst FROM 17,5 to 19,75

SET CLOCK TO 1,69
@ 1,0

DO Off_key
DO nav_mess WITH gc_mess

*-- This loop keeps the user from exiting with ESC
DO WHILE .NOT. gl_quit
   ACTIVATE MENU ChtBar
ENDDO

*-- Clean up environment
IF gc_clock = "OFF"
   SET CLOCK OFF
ELSE
   *-- NPI has clock turned on, put back to default coordinates
   SET CLOCK TO
ENDIF
@ 1,0
@ 23,0
SET BELL &gc_bell.
SET CURSOR &gc_cursor.
SET DELIMITERS &gc_deli.
SET ESCAPE &gc_escape.
SET FULLPATH &gc_fullpth.
SET SAFETY &gc_safety.
SET SPACE &gc_space.
SET MESSAGE TO
IF gc_status = "OFF"
   SET STATUS OFF
ENDIF
CLOSE ALL
IF gc_cat = "ON"
   SET CATALOG TO (gc_catname)
ENDIF
IF "" <> gc_dbf
   USE (gc_dbf)
ENDIF
ON ERROR
ON KEY
CLEAR
CLEAR WINDOWS
CLEAR POPUPS
CLEAR MENU
SET TALK &gc_talk.
RETURN

*----------------
*-- UDF's follow
*----------------

FUNCTION Center
*-- UDF to center a string.
*-- lc_string = String to center
*-- ln_width = Width of screen to center in
*--
*-- Ex. @ 15,center(string,80) SAY string
*-- Will center the <string> withing 80 columns
PARAMETER lc_string, ln_width
RETURN ((ln_width/2)-(LEN(lc_string)/2))

FUNCTION Alltrim
*-- UDF to trim all blanks around a string
*-- lc_string = String to trim
*--
*-- Ex. @ 15,0 SAY ALLTRIM(name)
PARAMETER lc_string
RETURN ( LTRIM( RTRIM( lc_string)))

*---------------------
*-- Procedures follow
*---------------------
PROCEDURE initarry
*- Initializes gc_lgnd array
STORE SPACE(10) TO ;
   gc_lgnd[1,1],gc_lgnd[2,1],gc_lgnd[3,1],gc_lgnd[4,1],;
   gc_lgnd[5,1],gc_lgnd[6,1], gc_lgnd[7,1],gc_lgnd[8,1]
*-- Used to store Legend titles that the user types in.
STORE SPACE(30) TO ;
   gc_lgnd[1,2],gc_lgnd[2,2],gc_lgnd[3,2],gc_lgnd[4,2],;
   gc_lgnd[5,2],gc_lgnd[6,2], gc_lgnd[7,2],gc_lgnd[8,2]
RETURN

PROCEDURE chkarray
*-- Used to check array dimensions of gc_lgnd for 1.0 to 1.1 conversion
*-- If 1.0 single dimension array we convert it to 2 dimensions
ll_badarry = .F.
ON ERROR ll_badarry = .T.
*-- This next statement will fail if we have a 1.0 gc_lgnd array
lc_junk = gc_lgnd[1,2]

ON ERROR DO PAUSE WITH "Line number in program "+Program()+": "+LTRIM(STR(LINE()))
IF ll_badarry                                    && have a old array
   DECLARE lc_lgnd[8]
   ln_cnt = 1
   DO WHILE  ln_cnt <= gn_var
     lc_lgnd[ln_cnt] = gc_lgnd[ln_cnt]
     ln_cnt = ln_cnt + 1
   ENDDO
   RELEASE gc_lgnd
   PUBLIC ARRAY gc_lgnd[8,2]
   DO initarry
   ln_cnt = 1
   lc_fldlst = gc_fldlst
   *-- Fill new array gc_lgnd
   DO WHILE  ln_cnt <= gn_var
     gc_lgnd[ln_cnt, 1] = SUBSTR(lc_fldlst, 1, AT(",", lc_fldlst)-1)
     lc_fldlst = SUBSTR(lc_fldlst, AT(",", lc_fldlst) + 1)
     gc_lgnd[ln_cnt, 2] = lc_lgnd[ln_cnt]
     ln_cnt = ln_cnt + 1
   ENDDO
ENDIF
RETURN

PROCEDURE nav_mess
PARAMETER lc_mess
@ 23,0
@ 23,CENTER(lc_mess,80) SAY lc_mess
RETURN

PROCEDURE DrawBox
*-- Draw a box
PARA ul, ur, ll, lr, box, color
lc_boxclr = IIF(LEN( TRIM( color)) > 0, "COLOR "+color, "")
@ ul,ur TO ll,lr &box. && &lc_boxclr.
RETURN

PROCEDURE OpendB
*-- Open a .dbf file from a files picklist
PARA Filname, ll_message
PUBLIC gc_filname
IF ".DBF" $ Filname
   USE (Filname)
   gn_obs = RECCOUNT()
   lc_tmpfile = DBF()
   gc_filname = lc_tmpfile
   gc_memfile = SUBSTR(lc_tmpfile,1,LEN(lc_tmpfile)-4)+".MEM"
   IF FILE(gc_memfile)
      *-- If chart definition file restore from it
      RESTORE FROM (gc_memfile) ADDITIVE
      DO chkarray
      IF ll_message
        DO pause WITH "Se ha recuperado la definici¢n de gr fico anterior."
      ENDIF
   ELSE
      *-- Initialze variables if new database has been choosen
      gc_brdr = "1"
      DO initarry
      STORE 0 TO gn_obs, gn_var
      STORE SPACE(26) TO gc_title[1], gc_title[2], gc_title[3], gc_title[4]
      STORE SPACE(20) TO xaxis1,xaxis2,yaxis1,yaxis2
      STORE " " TO gc_fldlst, gc_obslbl
      gc_filt = SPACE(200)
      *-- gc_obflg: 1 = Auto (Obs1 Obs2 ... Obsn), 2 = Field, 3 = OFF
      gc_obflg = "1"
      gc_chtype = " C"
   ENDIF
ENDIF
IF ll_message
  DEACTIVATE POPUP
ENDIF
RETURN

PROCEDURE Fldisp
PARAMETERS row,col,length,lc_opt

DEFINE POPUP dBfields FROM m->row, m->col TO m->row+m->length+2, m->col+11 ;
  PROMPT STRUCTURE;
  MESSAGE IIF(lc_opt="V",;
  "Seleccionar campos y pulsar Esc al terminar o seleccionar campo para borrar.",;
  "Seleccionar campo para etiqueta de observaci¢n.")
ON SELECTION POPUP dBfields DO pickflds WITH PROMPT()
IF "" = DBF()
   DO notready WITH "",49,71
ELSE
   IF lc_opt="V"
      IF len(gc_fldlst) > 1 .AND. .NOT. RIGHT(gc_fldlst,1) = ","
         gc_fldlst = gc_fldlst + ","
      ENDIF
      *-- Here is the window for the fields to displayed in
      ACTIVATE WINDOW fldlst
      @ 0,1
      @ 0,1 SAY "Campos:"+gc_fldlst
   ELSE
      gc_obslbl=" "
   ENDIF
   ACTIVATE SCREEN
   ACTIVATE POPUP dBfields
   IF lc_opt="V"
      DEACTIVATE WINDOW fldlst
      gc_fldlst=IIF(right(gc_fldlst,1)=",",substr(gc_fldlst,1,len(gc_fldlst)-1),gc_fldlst)
   ENDIF
ENDIF
RETURN

PROCEDURE Pickflds
*-- Pick fields from the active .dbf file
PARA lc_fld
IF lc_opt="O"
   IF TYPE(lc_fld)$"CDN"  && variables can be Char, Date or Numeric NO float
      gc_obslbl=lc_fld
      DEACTIVATE POPUP
   ELSE
      DO notready WITH "Memos o en coma flotante prohib.",41,77
   ENDIF
ELSE
   * lc_opt="V"
   IF TYPE(lc_fld)$"NF"
      STORE 0 TO ln_x1,ln_x2
      IF gn_var <= 8
         ln_x1 = AT(TRIM(lc_fld)+',',gc_fldlst)
         IF ln_x1 = 0
            IF gn_var > 7
               DO notready WITH "S¢lo se permiten ocho variables.",37,69
               DEACTIVATE POPUP
            ENDIF
            gn_var = gn_var+1
            gc_fldlst = gc_fldlst+lc_fld+','
            IF gc_lgnd[gn_var,1] = SPACE(10)
               gc_lgnd[gn_var,1] = PROMPT()+SPACE(10-LEN(PROMPT()))
               gc_lgnd[gn_var,2] = PROMPT()+SPACE(30-LEN(PROMPT()))
            ENDIF
          ELSE
            *-- Bubble up other array elements after current selection is removed
            ln_var = 1
            DO WHILE ln_var <= gn_var
               IF gc_lgnd[ln_var,1] = TRIM(lc_fld)
                  DO WHILE ln_var < gn_var
                     gc_lgnd[ln_var, 1] = gc_lgnd[ln_var+1, 1]
                     gc_lgnd[ln_var, 2] = gc_lgnd[ln_var+1, 2]
                     ln_var = ln_var + 1
                  ENDDO
                  ln_var = ln_var + 1
               ELSE
                  ln_var = ln_var +1
               ENDIF
            ENDDO
            *-- Replace last element with spaces after adjustment
            gc_lgnd[gn_var,1] = SPACE(10)
            gc_lgnd[gn_var,2] = SPACE(30)
            gn_var = gn_var-1
            ln_x2 = AT(',',SUBSTR(gc_fldlst,ln_x1))
            gc_fldlst = STUFF(gc_fldlst,ln_x1,ln_x2,'')
         ENDIF
         ACTIVATE WINDOW fldlst
         @ 0,1
         @ 0,1 SAY "Campos:"+SUBSTR(gc_fldlst,1,LEN(gc_fldlst)-1)
         ACTIVATE SCREEN
      ELSE
         DEACTIVATE POPUP
      ENDIF
   ELSE
      DO notready WITH "No es campo num‚rico",34,57
      ACTIVATE SCREEN
   ENDIF
ENDIF
RETURN

PROCEDURE Cobsub
*-- Select fields from a fields picklist
PARA ln_optnum
IF ln_optnum=2
   DO Fldisp WITH 8,30,8,"O"
   *- 1= auto 2 = field
   gc_obflg=IIF(gc_obslbl=" ","1","2")
ELSE
   gc_obflg=STR(ln_optnum,1)
ENDIF
DEACTIVATE POPUP
RETURN

PROCEDURE Prc1
*-- Actions for popup CdB popup 1
PARA ln_optnum
DO CASE
   CASE ln_optnum=1
      ACTIVATE POPUP dBfiles
      DO nav_mess WITH gc_mess
   CASE ln_optnum=2
      @ 23,00
      DEFINE WINDOW Savescr FROM 10,9 TO 17,70
      DO nav_mess WITH "Almacenar: "+CHR(17)+CHR(196)+CHR(217)+;
        "    Borrar l¡nea: Ctrl-Y    Cancelar operaci¢n: Esc"
      ACTIVATE WINDOW Savescr
      @ 1,1 SAY "Introducir condici¢n de filtro o fichero de consulta"
      @ 2,1 SAY "(seleccionar registros que cumplan criterio indicado):"
      @ 4,1 GET gc_filt PICT "@S58" ;
        VALID TYPE(gc_filt) <> "U" .OR. gc_filt=SPACE(200);
        ERROR "Expresi¢n de filtro no v lida";
        MESSAGE "Introducir condici¢n para determinar los registros a utilizar en el gr fico"
      READ
ENDCASE
IF ln_optnum = 2
   RELEASE WINDOW Savescr
   DO nav_mess WITH gc_mess
ENDIF
RETURN

PROCEDURE Prc2
*-- Actions for popup Cht popup 2
PARA ln_optnum
DO CASE
   CASE ln_optnum=1
      DO Fldisp WITH 4,23,8,"V"
   CASE ln_optnum=2
      *-- Define observation labels
      ACTIVATE POPUP Coblab
   CASE ln_optnum=3
      *-- Define Chart
      DO ChtDefn
   CASE ln_optnum=4
      *-- Pick Chart type
      PRIVATE lc_chtype
      *-- Here is the window for the chart type to displayed in
      DO CASE
         CASE gc_chtype = " L"
            lc_chtype = "L¡neas"
         CASE gc_chtype = " P"
            lc_chtype = "Circular"
         CASE gc_chtype = " C"
            lc_chtype = "Barras"
         CASE gc_chtype = " S"
            lc_chtype = "Apiladas"
         CASE gc_chtype = "SC"
            lc_chtype = "Puntos"
         CASE gc_chtype = " A"
            lc_chtype = "Superficie"
      ENDCASE
      ACTIVATE WINDOW fldlst
      @ 0,1
      @ 0,1 SAY "Tipo de gr fico actual: "+lc_chtype
      ACTIVATE SCREEN
      ACTIVATE POPUP Chttype
      DEACTIVATE WINDOW fldlst
   CASE ln_optnum=5
      *-- Generate Chart file
      DO chtbld
ENDCASE
RETURN

PROCEDURE Cht_type
PARA ln_chtype
gc_chtype=SUBSTR(" L P C SSC A",(ln_chtype-1)*2+1,2)
DEACTIVATE POPUP
RETURN

PROCEDURE Prc3
*-- Actions for popup Chelp pad 3
PARA ln_optnum,lc_headng
lc_headng = [¹ ] + lc_headng +[ Ì]
DO nav_mess WITH "Pantalla anterior: PgUp    Pantalla siguiente: PgDn    Salir de ayuda: Esc"
ACTIVATE WINDOW desktop
DO DrawBox WITH 0,0,19,79,"DOUBLE", gc_strclr
@ 0,CENTER(lc_headng,80) SAY lc_headng && COLOR &gc_strclr.
ln_key=0
ln_helpscn=1           && The # of the help screen to start on
ln_help=1              && # of help screens for this action - initialized
DO WHILE ln_key <> 27  && while not ESC
   lc_more=[¹ M s Ì]
   DO CASE
      CASE ln_optnum=1
         ln_help=6        && # of help screens for this action
         DO CASE
            CASE ln_helpscn=1
               @ 3,2 SAY [El programa de enlace con CHART-MASTER permite definir y generar gr ficos]
               @ 4,2 SAY [con datos procedentes de las base de datos. Existen cuatro men£s:]
               @ 6,2 SAY [Men£ Ficheros - Para seleccionar un fichero de base de datos y definir una]
               @ 7,2 SAY [condici¢n que determine los registros a incluir en el gr fico.]
               @ 9,4 SAY [Seleccionar base de datos - Permite elegir un fichero de base de datos]
               @10,4 SAY [del directorio actual. Se DEBE elegir un fichero de la lista que se]
               @11,4 SAY [muestra para definir un gr fico.]
               @13,4 SAY [Definir condici¢n de filtro - Permite introducir una condici¢n que deben]
               @14,4 SAY [cumplir los registros del fichero de base de datos para ser incluidos en ]
               @15,4 SAY [el gr fico.  Por ejemplo:  PROVINCIA = "Madrid" crea un gr fico con los ]
               @16,4 SAY [datos de los registros cuyo campo PROVINCIA sea Madrid.]
            CASE ln_helpscn=2
               @ 3,2 SAY [Men£ Gr ficos - Para especificar las etiquetas de observaci¢n, t¡tulos,]
               @ 4,2 SAY [tipo de gr fico y variables. ]
               @ 6,4 SAY [Identificar campos como variables - Permite seleccionar hasta ocho campos ]
               @ 7,4 SAY [num‚ricos de la base de datos para incluir en el gr fico.  Se muestra una ]
               @ 8,4 SAY [lista de los campos disponibles en el fichero. ]
               @10,4 SAY [Visualizar observaciones... - Permite asignar el tipo de etiqueta de ]
               @11,4 SAY [observaci¢n deseado a lo largo del eje X del gr fico: ]
               @12,6 SAY [Por omisi¢n - Permite usar las etiquetas est ndar (Obs1, Obs2, etc.). ]
               @13,6 SAY [Derivadas de campos - Las etiquetas de observaci¢n se obtienen del ]
               @14,6 SAY [contenido de un campo de la base de datos.  Seleccionar un campo de la ]
               @15,6 SAY [lista que se muestra.  Debe ser tipo car cter, fecha o num‚rico. ]
               @16,6 SAY [Sin observaciones - No se insertan observaciones en el eje X. ]
            CASE ln_helpscn=3
               @ 3,4 SAY [Crear/modificar t¡tulos - Permite definir o modificar el t¡tulo, las ]
               @ 4,4 SAY [etiquetas de los ejes y leyendas del gr fico.  Se muestra un formato ]
               @ 5,4 SAY [para introducir hasta cuatro l¡neas para el t¡tulo y hasta dos etiquetas ]
               @ 6,4 SAY [para cada eje y hasta ocho leyendas para el t¡tulo si utiliza las ]
               @ 7,4 SAY [opciones de etiquetas Por omisi¢n o Sin observaciones. ]
               @ 9,4 SAY [Seleccionar tipo de gr fico - Permite asignar el tipo de gr fico. Se ]
               @10,4 SAY [muestra una lista con los diferentes tipos (l¡neas, circular, barras, ]
               @11,4 SAY [barras apiladas, de puntos y de superficie). ]
               @13,4 SAY [Generar fichero de gr fico - Para generar el fichero de gr fico .cht. ]
               @14,4 SAY [Se muestra un formato con el nombre por omisi¢n del gr fico y la lo- ]
               @15,4 SAY [calizaci¢n de CHART-MASTER (que es donde se ubicar  el fichero generado). ]
               @16,4 SAY [Es posible cambiar esta informaci¢n tecleando la nueva encima. ]
            CASE ln_helpscn=4
               @ 3,4 SAY [Men£ Ayuda - Suministra informaci¢n sobre las distintas opciones de men£, ]
               @ 4,4 SAY [sobre CHART-MASTER, c¢mo preparar ficheros .dbf para CHART-MASTER, conver- ]
               @ 5,4 SAY [si¢n de ficheros .dbf en fichero de gr fico y c¢mo editar los gr ficos as¡ ]
               @ 6,4 SAY [generados.  Al seleccionar una opci¢n aparece la informaci¢n relacionada. ]
            CASE ln_helpscn=5
               @ 3,4 SAY [Men£ Salir - Permite abandonar el programa de enlace con CHART-MASTER y ]
               @ 4,4 SAY [volver al Centro de Control o al punto indicativo. ]
               @ 6,4 SAY [Almacenar cambios y salir - Almacena los campos seleccionados y la ]
               @ 7,4 SAY [definici¢n del gr fico como variables de memoria y vuelve al punto desde ]
               @ 8,4 SAY [donde se llam¢ al programa de enlace con CHART-MASTER.  La informaci¢n ]
               @ 9,4 SAY [queda almacenada en un fichero en disco como <nombre basedatos>.mem. ]
               @11,4 SAY [Cancelar cambios y salir - No tiene en cuenta los cambios realizados en ]
               @12,4 SAY [la definici¢n del gr fico (variables de memoria) y vuelve al punto desde ]
               @13,4 SAY [donde se llam¢ al programa de enlace con CHART-MASTER.  Se muestra un ]
               @14,4 SAY [recuadro de confirmaci¢n. Seleccione SI para continuar o NO para volver. ]
               @15,4 SAY [NOTA: Tanto si se almacenan cambios como si no, la acci¢n no tiene efecto ]
               @16,4 SAY [sobre el fichero de gr fico (ubicado en el directorio de CHART-MASTER). ]
            CASE ln_helpscn=6
               lc_more=[¹ Fin ÌÍ]
               @ 3,4 SAY [Transferir a dise¤o de consulta - Permite acceder a la pantalla de dise¤o ]
               @ 4,4 SAY [de consulta.  Tras crear una vista seleccione la opci¢n Grabar vista ]
               @ 5,4 SAY [como base de datos del men£ Formato y Salir del dise¤o de consulta. Al ]
               @ 6,4 SAY [volver utilice la nueva base de datos creada para generar un gr fico. ]
         ENDCASE
      CASE ln_optnum=2
         lc_more=[¹ Fin ÌÍ]
         @ 3,2 SAY [CHART-MASTER es el programa de aplicaci¢n para el cual est n destinados ]
         @ 4,2 SAY [los ficheros de gr fico creados por el presente programa de enlace para ]
         @ 5,2 SAY [una mejor comunicaci¢n y presentaci¢n de la informaci¢n. ]
         @ 7,2 SAY [El manual de usuario de CHART-MASTER y la ayuda en l¡nea del programa ]
         @ 8,2 SAY [(disponible en CHART-MASTER pulsando F1) componen una £til gu¡a para la ]
         @ 9,2 SAY [creaci¢n y dise¤o de gr ficos profesionales.  Consulte estos materiales ]
         @ 10,2 SAY [para una mayor y m s detallada informaci¢n sobre el uso de CHART-MASTER.]
      CASE ln_optnum=3
         ln_help=2        && # of help screens for this action
         DO CASE
            CASE ln_helpscn=1
               @ 3,2 SAY [El programa de enlace con CHART-MASTER utiliza £nicamente ficheros .dbf ]
               @ 4,2 SAY [y campos num‚ricos. ]
               @ 6,2 SAY [Si el fichero .dbf utilizado tiene un fichero .mem asociado con el mismo ]
               @ 7,2 SAY [nombre de fichero, ‚ste se deber  renombrar. Esto es debido a que la ]
               @ 8,2 SAY [definici¢n del gr fico que se crea se almacena en un fichero llamado ]
               @ 9,2 SAY [<nombre basedatos>.mem, el cual sustituir  cualquier otro fichero que ]
               @10,2 SAY [existiera previamente con el mismo nombre al almacenar el gr fico. ]
               @11,2 SAY [ ]
            CASE ln_helpscn=2
               lc_more=[¹ Fin ÌÍ]
               @ 3,2 SAY [Si desea crear un gr fico con los datos de una vista, deber  escribir ]
               @ 4,2 SAY [el correspondiente fichero .dbf previamente; para ello: ]
               @ 5,2 SAY [(1) Seleccione la opci¢n Transferir a dise¤o de consulta del men£ Salir ]
               @ 6,2 SAY [e introduzca el nombre del fichero de consulta que desea utilizar. ]
               @ 8,2 SAY [(2) Seleccione Grabar vista como base de datos del men£ Formato de la ]
               @ 9,2 SAY [pantalla de dise¤o de consulta. ]
               @11,2 SAY [Para volver al programa de enlace con CHART-MASTER seleccione Almacenar ]
               @12,2 SAY [cambios y salir del men£ Salir del dise¤o de consulta. Ahora ya puede ]
               @13,2 SAY [utilizar el fichero de base de datos generado para crear el gr fico. ]
         ENDCASE
      CASE ln_optnum=4
         ln_help=2        && # of help screens for this action
         DO CASE
            CASE ln_helpscn=1
               @ 3,2 SAY [Para crear un fichero de gr fico (.cht) de una base de datos (.dbf): ]
               @ 4,2 SAY [(1) Elija Seleccionar base de datos del men£ Ficheros. Elija un ]
               @ 5,2 SAY [fichero de la lista que se muestra. ]
               @ 7,2 SAY [(2) Si desea utilizar £nicamente los registros que cumplan un criterio ]
               @ 8,2 SAY [determinado seleccione Definir condici¢n de filtro del men£ Ficheros. ]
               @10,2 SAY [(3) Seleccione Identificar campos como variables del men£ Gr ficos. ]
               @11,2 SAY [Elija hasta ocho campos para incluir en el gr fico. ]
               @13,2 SAY [(4) Seleccione Visualizar observaciones del men£ Gr ficos. Elija el tipo ]
               @14,2 SAY [de etiquetas que desea que aparezcan a lo largo del eje X. ]
            CASE ln_helpscn=2
               lc_more=[¹ Fin ÌÍ]
               @ 3,2 SAY [(5) Seleccione Crear/modificar t¡tulos del men£ Gr ficos. Introduzca el ]
               @ 4,2 SAY [t¡tulo del gr fico y las observaciones de los ejes.  Tambi‚n es posible ]
               @ 5,2 SAY [introducir la leyenda de los campos cuando se utilizan como variables. ]
               @ 7,2 SAY [(6) Elija Seleccionar tipo de gr fico del men£ Gr ficos, elija el tipo ]
               @ 8,2 SAY [de gr fico a generar. ]
               @10,2 SAY [(7) Seleccione Generar fichero de gr fico del men£ Gr ficos. Introduzca la]
               @11,2 SAY [localizaci¢n de CHART-MASTER. Una vez que se ha generado el gr fico, el ]
               @12,2 SAY [cursor volver  al men£ Gr ficos. ]
               @14,2 SAY [(8) Seleccione Almacenar cambios y salir del men£ Salir para grabar la ]
               @15,2 SAY [configuraci¢n de gr fico que ha definido. ]
         ENDCASE
      CASE ln_optnum=5
         lc_more=[¹ Fin ÌÍ]
         @ 3,2 SAY [Para visualizar y/o editar el gr fico generado con el programa de enlace: ]
         @ 4,2 SAY [(1) Salir al DOS. ]
         @ 6,2 SAY [(2) En el indicativo del DOS teclee db4cm y pulse RETURN. ]
         @ 8,2 SAY [La pantalla muestra el gr fico generado durante unos segundos y a ]
         @ 9,2 SAY [continuaci¢n aparecer  el men£ principal de CHART-MASTER. A partir de ]
         @10,2 SAY [aqu¡ es posible editar, dibujar el gr fico o cambiar el tipo del mismo ]
         @11,2 SAY [con la opci¢n de men£ correspondiente. ]
         @13,2 SAY [Al terminar seleccione la opci¢n de Salir del men£ principal de ]
         @14,2 SAY [CHART-MASTER para volver al DOS. ]
   ENDCASE
   DO morehelp
ENDDO
DEACTIVATE WINDOW desktop
DO nav_mess WITH gc_mess
RETURN

PROCEDURE Morehelp
@ 1,2 SAY [Pantalla ]+str(ln_helpscn,1)+[ de ]+str(ln_help,1)
@ 19,CENTER(lc_more,80) SAY lc_more && COLOR &gc_strclr.
CLEAR GETS
ln_key=0
DO WHILE ln_key=0
   ln_key=INKEY()
   DO CASE
      CASE ln_key=18 && pageup
         ln_helpscn=IIF(ln_helpscn=1, ln_helpscn, ln_helpscn-1)
      CASE ln_key=3  && pagedown
         ln_helpscn=IIF(ln_helpscn=ln_help, ln_helpscn, ln_helpscn+1)
   ENDCASE
ENDDO
@ 1,1 CLEAR TO 18,78
RETURN

PROCEDURE Prc4
*-- Actions for popup Csave pad 4
PARA ln_optnum
ll_opt=IIF(ln_optnum=2 .or. ln_optnum=3, .F., .T.)
@ 23,0
SET MESSAGE TO
IF ln_optnum=1 .AND. LEN(TRIM(gc_memfile)) > 0
   SAVE TO (gc_memfile)
ENDIF
IF ln_optnum=2
   DEFINE WINDOW Savescr FROM 10,11 TO 14,65
   DO nav_mess WITH "Cambiar selecci¢n: Espaciador "
   ACTIVATE WINDOW Savescr
   lc_opt = "   "
   @ 1,1 SAY "¨Est  seguro que desea abandonar la operaci¢n?" GET lc_opt;
     PICT "@M NO,SI" MESSAGE "Salir del programa de enlace con CHART-MASTER sin almacenar ning£n cambio"
   READ
   ll_opt=IIF("NO"$LC_OPT, .F., .T.)
   RELEASE WINDOW Savescr
ENDIF
IF ln_optnum=3
   DO nav_mess WITH "Almacenar: "+CHR(17)+CHR(196)+CHR(217)+;
      "    Borrar l¡nea: Ctrl-Y    Cancelar operaci¢n: Esc"
   DEFINE WINDOW Savescr FROM 10,19 TO 14,65
   ACTIVATE WINDOW Savescr
   @ 1,1 SAY "Teclee consulta a modificar/crear:"
   lc_query=space(8)
   DO WHILE lc_query = SPACE(8)
      @ 1,36 GET lc_query PICT "@!" ;
        MESSAGE "Introduzca un nombre de vista para modificar/crear (no incluir la extensi¢n)"
      READ
      ln_rkey=READKEY()
      IF ln_rkey=12
         EXIT
      ENDIF
   ENDDO
   RELEASE WINDOW Savescr
   IF ln_rkey <> 12
      lc_memfile = SUBSTR(gc_filname,1,LEN(gc_filname)-4)+".ME2"
      SAVE TO (lc_memfile)
      lc_query = TRIM(lc_query)
      SAVE SCREEN TO tmpquery
      SET CLOCK OFF
      MODIFY QUERY (lc_query)
      RESTORE SCREEN FROM tmpquery
      SET CLOCK ON
      DO OpendB WITH gc_filname, .F.             && Don't show restore box
      RESTORE FROM (lc_memfile) ADDITIVE
      ERASE (lc_memfile)
   ENDIF
ENDIF
IF ll_opt
   *-- Setup for quiting program
   gl_quit = .T.
   DEACTIVATE MENU
ELSE
   DO nav_mess WITH gc_mess
ENDIF
RETURN

PROCEDURE Chtdefn
IF gn_var=0 .OR. ""=DBF()
   DO notready WITH "",49,71
ELSE
   DO nav_mess WITH "Almacenar: Ctrl-End    Borrar l¡nea: Ctrl-Y    Cancelar operaci¢n: Esc"
   lc_headng = [¹ Definici¢n de gr fico Ì]
   ACTIVATE WINDOW desktop
   DO DrawBox WITH 0,0,19,79,"DOUBLE",gc_strclr
   @ 0,CENTER(lc_headng,80) SAY lc_headng && COLOR &gc_strclr.
   *-- Titles
   @ 2,3 SAY "L¡nea t¡tulo 1" GET gc_title[1] MESSAGE "Introducir primer t¡tulo del gr fico (opcional)"
   @ 3,3 SAY "L¡nea t¡tulo 2" GET gc_title[2] MESSAGE "Introducir segundo t¡tulo del gr fico (opcional)"
   @ 4,3 SAY "L¡nea t¡tulo 3" GET gc_title[3] MESSAGE "Introducir tercer t¡tulo del gr fico (opcional)"
   @ 5,3 SAY "L¡nea t¡tulo 4" GET gc_title[4] MESSAGE "Introducir cuarto t¡tulo del gr fico (opcional)"
   *-- Axis labels
   @ 07,3 SAY "Etiqueta 1 eje-X" GET xaxis1 MESSAGE "Introducir primera etiqueta del eje X del gr fico (opcional)"
   @ 08,3 SAY "Etiqueta 1 eje-Y" GET yaxis1 MESSAGE "Introducir primera etiqueta del eje Y del gr fico (opcional)"
   @ 7,41 SAY "Etiqueta 2 eje-X" GET xaxis2 MESSAGE "Introducir segunda etiqueta del eje X del gr fico (opcional)"
   @ 8,41 SAY "Etiqueta 2 eje-Y" GET yaxis2 MESSAGE "Introducir segunda etiqueta del eje Y del gr fico (opcional)"

   *-- Legend Labels
   @ row()+1,1 SAY ""
   ln_cnt = 1
   DO WHILE ln_cnt <= gn_var .AND. ln_cnt < 9
      scnt = LTRIM(STR(ln_cnt))
      @ row()+1,3 SAY "Leyenda del t¡tulo "+scnt GET gc_lgnd[ln_cnt, 2];
        MESSAGE "Introducir leyenda para el t¡tulo del gr fico (necesario)"
      ln_cnt = ln_cnt+1
   ENDDO
   READ
   DEACTIVATE WINDOW desktop
ENDIF
DO nav_mess WITH gc_mess
RETURN

PROCEDURE Notready
PARAMETER lc_messg, col1, col2
*-- Creates 1 line window to display a message
*-- lc_messg - optional message to display (option="" passed)
*-- col1 - upper left column of window
*-- col2 - lower right column of window
DEFINE WINDOW Savetemp FROM ROW()-1,col1 TO ROW()+1,col2
ACTIVATE WINDOW Savetemp
DO CASE
   CASE LEN(lc_messg) > 0
      @ 0,1 SAY lc_messg
   CASE ""=DBF()
      @ 0,1 SAY "No hay base en uso."
   CASE gn_var=0
      @ 0,1 SAY "No hay campos."
ENDCASE
ln_temp=inkey(5)
RELEASE WINDOW Savetemp
RETURN

PROCEDURE Off_key
*- Turn off all Function keys during Chrtmstr run
ON KEY LABEL F1 ln_eatkey = INKEY()
ON KEY LABEL F2 ln_eatkey = INKEY()
ON KEY LABEL F3 ln_eatkey = INKEY()
ON KEY LABEL F4 ln_eatkey = INKEY()
ON KEY LABEL F5 ln_eatkey = INKEY()
ON KEY LABEL F6 ln_eatkey = INKEY()
ON KEY LABEL F7 ln_eatkey = INKEY()
ON KEY LABEL F8 ln_eatkey = INKEY()
ON KEY LABEL F9 ln_eatkey = INKEY()
ON KEY LABEL F10 ln_eatkey = INKEY()
RETURN


PROCEDURE Pause
PARAMETER lc_msg
*-- Parameters : lc_msg = message line
gn_error = ERROR()
lc_option = '0'
ACTIVATE WINDOW pause
IF gn_error > 0
   @ 0,1 SAY "!Se ha detectado un error!: "+MESSAGE()
ENDIF
IF  gn_error = 29
  @ 1,1 SAY "Se ha introducido una unidad o v¡a de aceso no v lida."
ELSE
  @ 1,1 SAY lc_msg
ENDIF
WAIT " Pulse cualquier tecla para continuar..."
DEACTIVATE WINDOW pause
RETURN

PROCEDURE Chtbld
*-- Description..: Builds Chartmaster .CHT file
IF ""=DBF() .OR. LEN(gc_fldlst)=1
   DO notready WITH "",49,71
   RETURN
ENDIF
lc_headng = [¹ Generar fichero de gr fico Ì]
DO nav_mess WITH "Almacenar: Ctrl-End    Borrar l¡nea: Ctrl-Y    Cancelar operaci¢n: Esc"
ACTIVATE WINDOW desktop
DO DrawBox WITH 0,0,19,79,"DOUBLE",gc_strclr
@ 0,CENTER(lc_headng,80) SAY lc_headng && COLOR &gc_strclr
cmpath = IIF(""=gc_path, "C:\CM" + SPACE(25), gc_path)
tmpfile = SUBSTR(DBF(),3)
DO WHILE AT("\",tmpfile) > 0
   tmpfile = SUBSTR(tmpfile,AT("\",tmpfile)+1)
ENDDO
tmpfile = SUBSTR(tmpfile,1,LEN(tmpfile)-4) + ".CHT" + SPACE(12-LEN(tmpfile))
@ 08,10 SAY "Nombre de fichero .cht generado" GET tmpfile;
  MESSAGE "Este nombre de fichero necesita una extensi¢n .cht"
@ 10,10 SAY "Localizaci¢n de CHART-MASTER   " GET cmpath PICTURE "@!";
  MESSAGE "Introduzca la unidad y v¡a de acceso correcta de CHART-MASTER";
  VALID ((LEFT(cmpath,1) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ") .AND.;
  (SUBSTR(cmpath,2,2) = ":\"));
  ERROR "Se necesita la unidad y v¡a de acceso de CHART-MASTER"
READ
SET MESSAGE TO
IF READKEY()=12
   DEACTIVATE WINDOW desktop
   DO nav_mess WITH gc_mess
   RETURN
ENDIF

gc_path = cmpath                                 && save their path
cmpath = IIF(RIGHT(TRIM(cmpath),1)='\', RTRIM(cmpath), RTRIM(cmpath)+'\')

tmpfile = IIF(".CHT" $ tmpfile, RTRIM(tmpfile), RTRIM(tmpfile)+[.CHT])
lc_chtfile = cmpath + tmpfile

SET FILTER TO &gc_filt.

COUNT TO gn_obs
gl_error=.f.

DO CASE
  CASE gn_obs*gn_var > 600
    @ 2,5 SAY "N£mero de puntos = "+ ltrim(str(gn_obs*gn_var))
    @ 3,5 SAY "Este n£mero sobrepasa la capacidad m xima de 600 puntos de CHART-MASTER."
    gl_error = .t.
  CASE gc_chtype $ " P"
     ln_cnt = 1
     @ 2,5 SAY "Revisando existencia de n£meros negativos..."
     DO WHILE  ln_cnt <= gn_var
       LOCATE FOR &gc_lgnd[ln_cnt, 1]. < 0
       IF FOUND()
          @ 2,5 SAY SPACE(65)
          @ 2,5 SAY "Se han encontrado n£meros negativos"
          @ 3,5 SAY "CHART-MASTER no permite n£meros negativos para gr ficos circulares."
          gl_error = .t.
          EXIT
       ENDIF
       ln_cnt = ln_cnt + 1
     ENDDO
  CASE gn_obs*gn_var > 52 .AND. gc_chtype $ " C, S"
    @ 2,5 SAY "N£mero de puntos = "+ ltrim(str(gn_obs*gn_var))
    @ 3,5 SAY "Se ha sobrepasado el l¡mite de 52 puntos de CHART-MASTER"
    @ 4,5 SAY  "para gr ficos "+IIF(gc_chtype=" C","de barras.","barras apiladas.")+ " "
    gl_error = .t.
ENDCASE

IF gl_error
    IF gc_chtype $ " C, S"
       @ ROW()+1,5 SAY "Asigne un filtro/vista que incluya menos registros."
    ENDIF
    @ ROW()+1,5 SAY "Pulse cualquier tecla"
    READ
    DEACTIVATE WINDOW desktop
    DO nav_mess WITH gc_mess
    RETURN
ENDIF

gn_obs=IIF(gn_obs*gn_var > 600, 600/gn_var, gn_obs)

SET ECHO OFF
@ 08,1 CLEAR TO 10,78
@ 2,5 SAY SPACE(65)
@ 2,5 SAY "N£mero de Variables = "+ LTRIM( STR( gn_var))
@ 3,5 SAY "N£mero de Observaciones = " + LTRIM( STR( gn_obs))

DO ChtMake
IF gn_error <> 29
   lc_chtprg = cmpath+"COM-FILE.DRB"
   SET ALTERNATE TO &lc_chtprg.
   SET CONSOLE OFF
   SET ALTERNATE ON
   ?? "RETRIEVE "+SUBSTR(tmpfile,1,LEN(tmpfile)-3)+"CHT"
   ? "PLOT ON SCREEN1 DELAY 20"
   ? "STAY"
   ?
   SET ALTERNATE OFF
   CLOSE ALTERNATE

   SET ALTERNATE TO DB2CM.BAT
   SET ALTERNATE ON
   ?? [CD ]+SUBSTR(cmpath,1,LEN(cmpath)-1)
   setdrv=LEFT(cmpath,2)
   ? setdrv
   ? [CM COM-FILE]
   ?
ELSE
  gn_error = 0
ENDIF
CLOSE ALTERNATE
SET CONSOLE ON
RELEASE WINDOW dot
DEACTIVATE WINDOW desktop
DO nav_mess WITH gc_mess
RETURN

PROCEDURE Chtmake
* Description..: Creates CHT file from given data
ln_z = 0
*-- chart vars on (L)eft or (R)ight y-axis
lc_yaxis = "L"
lc_style = SPACE(7)
lc_var = ""
lc_temp = "Creando "+lc_chtfile
@ 7,CENTER(lc_temp,80) SAY lc_temp
gc_clrtmp = IIF( ISCOLOR(), "GR+/N", "W+/N")
DEFINE WINDOW dot FROM 10,25 TO 15,55 && COLOR &gc_clrtmp.
SET ALTERNATE TO &lc_chtfile.
RELEASE gc_clrtmp, lc_temp, lc_chtfile
SET ALTERNATE ON
IF gn_error = 29 && File not accessible / invalid path and/or file
  RETURN
ENDIF
ACTIVATE WINDOW dot
****** header, num of observations, num of variables ******
?? "MS"
? STR(gn_obs,3)
? STR(gn_var,2)
****** Titles ******
lc_style=CHR(15)+"013005"
? IIF(""=TRIM(gc_title[1]),"",lc_style+TRIM(gc_title[1]))
? IIF(""=TRIM(gc_title[2]),"",lc_style+TRIM(gc_title[2]))
? IIF(""=TRIM(gc_title[3]),"",lc_style+TRIM(gc_title[3]))
? IIF(""=TRIM(gc_title[4]),"",lc_style+TRIM(gc_title[4]))
****** Legends ******
ln_z=1
lc_style=CHR(15)+"007017"
lc_var="GC_LGND"
DO WHILE ln_z <= gn_var .AND. ln_z < 9
   ? IIF(""=TRIM(gc_lgnd[ln_z, 2]),"",lc_style+TRIM(gc_lgnd[ln_z, 2]))
   ln_z=ln_z+1
ENDDO
*-- print blank lines for legends beyond 8
DO WHILE ln_z <= gn_var
   ?
   ln_z=ln_z+1
ENDDO
****** X and Y axis labels ******
lc_style=CHR(15)+"009005"
? IIF(""=TRIM(xaxis1),"",lc_style+TRIM(xaxis1))
? IIF(""=TRIM(xaxis2),"",lc_style+TRIM(xaxis2))
lc_style=CHR(15)+"007005"
? IIF(""=TRIM(yaxis1),"",lc_style+TRIM(yaxis1))
? IIF(""=TRIM(yaxis2),"",lc_style+TRIM(yaxis2))
****** Observation Spacing ***************************************************
* - Observation spacing - There must be less than 53 observation labels
* - so we need to change the OBSSPACE variable if we have more than
* - 52 observations/variable. Below we will use the mod function
* - to control the output of Observation labels - KJN.
* - This information was provided by Rich Murphy and Barbara Richards
* - at A-T Westport R/D Center
******************************************************************************
ln_obs=IIF(gn_obs > 52, CEILING(ROUND(gn_obs/52,2)), 1) &&Bump to higher integer
* ---------------------
? "OBSSPACE "+LTRIM(STR(ln_obs))
****** Observation labels ******
lc_style=CHR(15)+"007005"
ln_z=1
GOTO TOP
DO WHILE ln_z <= gn_obs
   IF MOD(ln_z,ln_obs) = 0
      DO CASE
         CASE gc_obflg="1"
            *-- Automatic
            ? lc_style+"OBS"+LTRIM(STR(ln_z))
         CASE gc_obflg="2"
            *-- from the field
            DO CASE
               CASE TYPE(gc_obslbl) = "C"
                  gc_out=&gc_obslbl.
               CASE TYPE(gc_obslbl) = "D"
                  gc_out=DTOC(&gc_obslbl.)
               CASE TYPE(gc_obslbl) = "N"
                  gc_out=LTRIM(STR(&gc_obslbl.,10))  && Took out ,2 for PTR 26205
            ENDCASE
            ? IIF(gc_obslbl=" ","",lc_style+gc_out)
            SKIP ln_obs
            IF EOF()
               GO BOTT
            ENDIF
         CASE gc_obflg="3"
            *-- No obs. labels
            ?
      ENDCASE
   ENDIF
   ln_z=ln_z+1
ENDDO
RELEASE gc_out
****** Data (variables times observations) ******
ln_x=2
ln_z=0
ln_start=1
ln_pos=1
lc_fldlst=LTRIM(gc_fldlst)+","
lc_fld1=SUBSTR(lc_fldlst,ln_pos,AT(",",SUBSTR(lc_fldlst,ln_pos))-1)
DO WHILE ln_x <= gn_var
   lc_temp=STR(ln_x,1)
   ln_pos=AT(",",SUBSTR(lc_fldlst,ln_start))
   ln_start=ln_start+ln_pos
   lc_fld&lc_temp.=SUBSTR(lc_fldlst,ln_start,AT(",",SUBSTR(lc_fldlst,ln_start))-1)
   ln_x=ln_x+1
ENDDO
GOTO TOP
DO WHILE ln_z < gn_obs
   ln_x=1
   DO WHILE ln_x <= gn_var
      lc_temp=STR(ln_x,1)
      lc_zed=lc_fld&lc_temp.
      *-- Per Doc. Using the menu system - Chart Master Bridge (Derive from Field)
      ? " "+LTRIM(STR(&lc_zed.,20,2))
      ln_x=ln_x+1
   ENDDO
   SKIP
   ln_z=ln_z+1
ENDDO
****** Options ******
*-- Right chart limit
? "INCH 1000"
*-- Chart left
? " 0"
*-- Chart top
? " 750"
*-- Chart bottom
? " 0"
*-- Horiz. / Vert.
? "H"
*-- X-Justif.
? "M"
*-- Fraction of above
? " 1"
*-- Y-Justif.
? "M"
*-- Fraction of above
? " 1"
*-- Pen speed
? " 3"
*-- Frame
? "B"
*-- Footnote
?
*-- Unused
? " 0"
? " 0"
*-- Print data
? "N"
*-- Hatch pies
? "Y"
*-- Hatching array
ln_z=0
DO WHILE ln_z < 5
   ? " 1"
   ? " 2"
   ? " 3"
   ? " 4"
   ln_z=ln_z+1
ENDDO
*-- Proportional pie (0=No)
? " 0"
*-- Hatching patterns (1 per Var.)
ln_z=0
DO WHILE ln_z < gn_var
   ? STR(MOD(ln_z,8)+1,2)
   ln_z=ln_z+1
ENDDO
*-- Legend
? CHR(15)+"009000Legend"
*-- Vert. / Horiz. Bars
? " 0"
*-- Each pie an Obs. or Var.
? "O"
*-- Regression
? "N"
*-- Regression type (1 per Var.)
ln_z=0
DO WHILE ln_z < gn_var
   ? "N"
   ln_z=ln_z+1
ENDDO
*-- Use line types
? "Y"
*-- Use symbols for line charts (0=No)
? " 0"
*-- Unused
?
*-- High var. # (0 thru # of Vars.)
? " 0"
*-- Low var. #    ''       ''
? " 0"
*-- Close var. #     ''       ''
? " 0"
*-- # of vars against left y-axis
? IIF(lc_yaxis="L",STR(gn_var,2)," 0")
*-- Order of vars    ''      ''
IF lc_yaxis="L"
   ln_z=1
   DO WHILE ln_z <= gn_var
      ? STR(ln_z,2)
      ln_z=ln_z+1
   ENDDO
ENDIF
*-- Scale of left y-axis
? "L"
*-- Auto/Manual left max
? "A"
*-- Left max (needs to be calculated from data)
? " 0"
*-- Auto/Manual left min
? "A"
*-- Left min
? " 0"
*-- Auto/Manual left step (need from data)
? "A"
*-- Left step
? " 0"
*-- Left grid
? "N"
*-- # of vars against right y-axis
? IIF(lc_yaxis="R",STR(gn_var,2)," 0")
*-- Order of vars    ''      ''
IF lc_yaxis="R"
   ln_z=1
   DO WHILE ln_z <= gn_var
      ? STR(ln_z,2)
      ln_z=ln_z+1
   ENDDO
ENDIF
*-- Scale of right y-axis
? "L"
*-- Auto/Manual right max
? "A"
*-- Right max (needs to be calculated from data)
? " 0"
*-- Auto/Manual right min
? "A"
*-- Right min
? " 0"
*-- Auto/Manual right step (need from data)
? "A"
*-- Right step
? " 0"
*-- Right y-axis labels (1 and 2)
?
?
*-- Right grid
? "N"
*-- Pen change for pies
? "P"
*-- Slice labels
? "%"
*-- Exploded slices
? "N"
*-- Explode which slice (1-20)
ln_z=0
DO WHILE ln_z < 20
   ? "N"
   ln_z=ln_z+1
ENDDO
*-- # of pies (4 max)
? IIF(gn_obs > 4," 4",STR(gn_obs,2))
*-- Which of the pies are plotted
ln_z=1
DO WHILE ln_z <= gn_obs .AND. ln_z < 5
   ? STR(ln_z,2)
   ln_z=ln_z+1
ENDDO
*-- Line type (left and right grid)
? " 1"
? " 1"
*-- Line type order
ln_z=0
DO WHILE ln_z < gn_var
   ? STR(MOD(ln_z,8)+1,2)
   ln_z=ln_z+1
ENDDO
*-- Symbol order
ln_z=0
DO WHILE ln_z < gn_var
   ? STR(MOD(ln_z,8)+1,2)
   ln_z=ln_z+1
ENDDO
*-- Pie hatching
? "Y"
*-- Mixed chart order
ln_z=0
DO WHILE ln_z < gn_var
   ? "L"
   ln_z=ln_z+1
ENDDO
*-- Variable color order
ln_z=1
DO WHILE ln_z <= gn_var
   ? STR(MOD(ln_z,8)+1,2)
   ln_z=ln_z+1
ENDDO
*-- size of left y-axis #'s
? "A"
*-- size of right y-axis #'s
? "A"
*-- Layout of 3-pie chart
? " 3"
*-- pie slice order
ln_z=1
DO WHILE ln_z <= 20
   ? STR(ln_z,2)
   ln_z=ln_z+1
ENDDO
*-- slice/pie color order
ln_z=1
DO WHILE ln_z <= 20
   ? STR(MOD(ln_z,8)+1,2)
   ln_z=ln_z+1
ENDDO
*-- Slice label location
? "A"
*-- Unused
? " 0"

********************************************
** Floating legend data would appear here **
**  appears only if label location = "F"  **
********************************************

*-- Last chart plotted
? LTRIM(gc_chtype)
*-- Last output device
? " 2"
*-- number of floating items
? " 0"

****** Floating item data ******
*-- None

****** final return ******
?
CLOSE ALTERNATE
*Release window dot is in chtmake.prg
RETURN
*EOP CHRTMSTR.PRG

