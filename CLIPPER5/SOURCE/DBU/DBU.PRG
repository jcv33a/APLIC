/***
*
*  Dbu.prg
*
*  M¢dulo principal de la aplicaci¢n DBU
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.
*
*/

PROCEDURE Dbu( param1, param2, param3 )
   
   PUBLIC n_files,keystroke,lkey,frame,sframe,cur_dir,more_up,more_down,;
   kf1,kf2,kf3,kf4,kf5,kf6,need_field,need_ntx,need_relat,need_filtr,;
   help_code,view_err,cur_area,cur_dbf,cur_ntx,cur_fields,error_on,;
   exit_str,page,sysfunc,func_sel,cur_func,local_func,local_sel,box_open,;
   color1,color2,color3,color4,color5,color6,color7,color8,color9,;
   color10,color11,color12,com_line,curs_on,helpfile
   
   
   ******
   *  Los par metros son opcionales y tienen el siguiente significado:
   *
   *  - Nombre del fichero a ver (.VEW o .DBF)
   *
   *  - Par metro selector de color:
   *     /C = Forzar uso del color 
   *     /M = Monocromo (sin uso de color)
   *
   *  - Modo de apertura de ficheros (para uso en red)
   *     /E = Uso exclusivo de ficheros 
   *
   *  Los par metros pueden indicarse en cualquier orden
   ******
   
   * Prevenci¢n del error de tipo y conversi¢n a may£sculas
   IF VALTYPE( param1 ) != "C"
      param1 = ""
   ENDIF
   
   IF VALTYPE( param2 ) != "C"
      param2 = ""
   ENDIF
   
   IF VALTYPE( param3 ) != "C"
      param3 := ""
   ENDIF
   
   // Combinaci¢n de todos los par metros de l¡nea en uno
   param1 := UPPER( param1 + "~" + param2 + "~" + param3 + "~" )
   
   // Proceso de la l¡nea de par metros
   param3 := ParseCommLine( param1 )
   com_line := param3[1]
   param2   := param3[2]
   
   SET CURSOR OFF                    && El cursor s¢lo en los GET
   SAVE SCREEN                       && Salva la pantalla
   SET SCOREBOARD OFF                && Eliminaci¢n de la l¡nea de estado
   SET KEY 28 TO                     && Para quien necesite ayuda
   
   IF (ISCOLOR() .OR. "/C" $ UPPER(param2)) .AND. .NOT. "/M" $ UPPER(param2)
      * Vamos a hacerlo bonito, en color
      color1 = "W+/B,N/W,B"          && Normal
      color2 = "B/W"                 && Resaltado  
      color3 = "W+/R"                && Error o alta intensidad
      color4 = "W+/B,B/W,,,W+/B"     && Opciones no seleccionadas
      color5 = "B/BG,B/W,,,W/BG"     && Opciones no seleccionables
      color6 = "W+/BG"               && Bordes del men£
      color7 = "B/BG,B/W"            && Ver, modificaci¢n de estructura, establecer relaci¢n
      color8 = "B/W,B/BG,,,B/W"      && Textos y di logos
      color9 = "W+/B,N/BG"           && T¡tulo de textos
      color10 = "B/BG"               && Resaltado en cajas de di logo
      color11 = "W+/BG"              && Resaltado en t¡tulo de men£s
      color12 = "W+/B"               && Resaltado en establecer relaci¢n
      
   ELSE
      * Monocrom tico
      color1 = "W/N,N/W"
      color2 = "N/W"
      color3 = "W+/N"
      color4 = "W/N,N/W,,,W/N"
      color5 = "W+/N,N/W,,,W/N"
      color6 = "W/N"
      color7 = "W/N,N/W"
      color8 = "W/N,N/W,,,W/N"
      color9 = "N/W,N/W"
      color10 = "N/W"
      color11 = "N/W"
      color12 = "W+/N"
      
   ENDIF
   
   * Preparaci¢n de la pantalla
   SetColor(color1)
   CLEAR
   
   * Constantes del sistema
   more_up = CHR(24)                           && Car cter de flecha arriba
   more_down = CHR(25)                         && Car cter de flecha abajo
   frame = "ÕÍ¸³¾ÍÔ³"                          && Caracteres de caja
   lframe = "ÑÍ¸³¾ÍÏ³"
   mframe = "ÂÄÂ³ÙÄÀ³"
   sframe = "ÚÄ¿³ÙÄÀ³"
   
   * Variables p£blicas
   STORE .F. TO need_field,need_ntx,need_relat,need_filtr,box_open
   STORE "" TO kf1,kf2,kf3,kf4,kf5,kf6
   help_code = 0                          && Para la ayuda
   curs_on = .F.                          && ¨qu‚ cursor?
   cur_dir = ""                           && Directorio actual
   cur_dbf = ""                           && Fichero actual   
   cur_ntx = ""                           && Indice actualmente activo     
   cur_fields = ""                        && Matriz de campos para el  rea
   cur_area = 0                           && Area de trabajo actual
   page = 1                               && Pantalla de la vista activa
   n_files = 0                            && Un m ximo de 14 ficheros por usuario
   view_file = ""                         && Fichero al que salvar la vista
   view_err = ""                          && Visualizado por "set_view"
   
   view_err = " DBU-Copyright (c) 1990-1993 Computer Associates. Todos los derechos reservados "
   
   * b£squeda del archivo de ayuda
   IF FILE( "dbu.hlp" )
      helpfile := "dbu.hlp"
      
   ELSE
      helpfile := GetHelpFile()
      
   ENDIF
   
   **
   *  Las matrices declaradas en el m¢dulo principal se consideran p£blicas
   *  y pueden ser accedidas o modificadas por cualquier otro m¢dulo del 
   *  sistema. La matriz declara 6  reas de trabajo con 7 ¡ndices y 64 campos
   *  para cada una de ellas. Se soportan un m ximo de 15 relaciones. Todos
   *  los elementos se inicializan para evitar errores de tipo.
   **
   
   * Nombres de los ficheros de datos
   DECLARE dbf[6]
   
   * Nombres de los ficheros ¡ndice
   DECLARE ntx1[7]
   DECLARE ntx2[7]
   DECLARE ntx3[7]
   DECLARE ntx4[7]
   DECLARE ntx5[7]
   DECLARE ntx6[7]
   
   * 15 relaciones
   DECLARE s_relate[15]                       && Inicio de la relaci¢n
   DECLARE k_relate[15]                       && Clave de la relaci¢n
   DECLARE t_relate[15]                       && Destino de la relaci¢n
   
   * Nombres de los campos para las listas activas
   DECLARE field_n1[64]
   DECLARE field_n2[64]
   DECLARE field_n3[64]
   DECLARE field_n4[64]
   DECLARE field_n5[64]
   DECLARE field_n6[64]
   
   * Lista de campos principal...M ximo de 128
   DECLARE field_list[128]
   
   * Primera y £ltima columna de cada secci¢n de pantalla
   DECLARE row_a[3]                 
   DECLARE row_x[3]                 
   
   * Valores constantes
   row_a[1] = 6
   row_x[1] = 6
   row_a[2] = 10
   row_x[2] = 12
   row_a[3] = 16
   row_x[3] = 22
   
   * Columna de las columnas del fichero de datos
   DECLARE column[6]
   
   * Fila actual de cada columna de datos y de cada secci¢n de pantalla
   DECLARE _cr1[3]
   DECLARE _cr2[3]
   DECLARE _cr3[3]
   DECLARE _cr4[3]
   DECLARE _cr5[3]
   DECLARE _cr6[3]
   
   * Elemento actual de cada columna de datos y cada secci¢n de pantalla
   DECLARE _el1[3]
   DECLARE _el2[3]
   DECLARE _el3[3]
   DECLARE _el4[3]
   DECLARE _el5[3]
   DECLARE _el6[3]
   
   * T¡tulos de teclas de funci¢n y pantallas de ayuda
   DECLARE func_title[8]
   DECLARE menu_deflt[8]
   DECLARE help_title[22]
   
   **
   * Inicializaci¢n de matrices
   **
   
   * Ficheros de datos activos
   afill(dbf, "")
   
   * Ficheros ¡ndice de cada fichero de base de datos
   afill(ntx1, "")
   afill(ntx2, "")
   afill(ntx3, "")
   afill(ntx4, "")
   afill(ntx5, "")
   afill(ntx6, "")
   
   * Campos de cada fichero de datos
   afill(field_n1, "")
   afill(field_n2, "")
   afill(field_n3, "")
   afill(field_n4, "")
   afill(field_n5, "")
   afill(field_n6, "")
   
   * Inicio, clave y destino de las relaciones
   afill(s_relate, "")
   afill(k_relate, "")
   afill(t_relate, "")
   
   * Lista de campos
   afill(field_list, "")
   
   * Literales de teclas de funci¢n
   func_title[1] = "Ayuda"
   func_title[2] = "Abrir"
   func_title[3] = "Crear"
   func_title[4] = "Grabar"
   func_title[5] = "Ver"
   func_title[6] = "Utilidad"
   func_title[7] = "Mover"
   func_title[8] = "Set"
   
   afill(menu_deflt, 1)
   
   * Escritura de la fila 0 a la 3 de la pantalla
   @ 0,0 SAY " F1        F2        F3        F4        F5        F6        " +;
   "F7        F8       "
   show_keys()
   @ 2,0 SAY REPLICATE("Ä", 80)
   error_msg(view_err)
   
   * Cuando salir
   exit_str = "356"
   
   * Men£s con matrices de l¢gicos asociadas para Achioce ()
   DECLARE ayuda_m[1]
   DECLARE ayuda_b[1]
   ayuda_m[1] = "Ayuda"
   ayuda_b[1] = .T.
   
   DECLARE abrir_m[3]
   DECLARE abrir_b[3]
   abrir_m[1] = "Fichero"
   abrir_m[2] = "Indice"
   abrir_m[3] = "Vista"
   abrir_b[1] = "sysfunc = 0 .AND. .NOT. box_open"
   abrir_b[2] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
   abrir_b[3] = "sysfunc = 0 .AND. .NOT. box_open"
   
   DECLARE crear_m[2]
   DECLARE crear_b[2]
   crear_m[1] = "Fichero"
   crear_m[2] = "Indice"
   crear_b[1] = "sysfunc = 0"
   crear_b[2] = "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)"
   
   DECLARE grabar_m[2]
   DECLARE grabar_b[2]
   grabar_m[1] = "Vista"
   grabar_m[2] = "Estruct."
   grabar_b[1] = "sysfunc = 0 .AND. .NOT. box_open"
   grabar_b[2] = "sysfunc = 3 .AND. func_sel = 1 .AND. .NOT. box_open"
   
   DECLARE ver_m[2]
   DECLARE ver_b[2]
   ver_m[1] = "Fichero"
   ver_m[2] = "Vista"
   ver_b[1] = "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)"
   ver_b[2] = "sysfunc = 0 .AND. .NOT. EMPTY(dbf[1])"
   
   DECLARE utilidad_m[6]
   DECLARE utilidad_b[6]
   utilidad_m[1] = "Copiar"
   utilidad_m[2] = "A¤adir"
   utilidad_m[3] = "Cambiar"
   utilidad_m[4] = "Purgar"
   utilidad_m[5] = "Vaciar"
   utilidad_m[6] = "Ejecutar"
   afill(utilidad_b, "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)", 1, 5)
   utilidad_b[6] = "sysfunc = 0"
   
   DECLARE mover_m[4]
   DECLARE mover_b[4]
   mover_m[1] = "Buscar"
   mover_m[2] = "Ir a"
   mover_m[3] = "Localiza"
   mover_m[4] = "Saltar"
   afill(mover_b, "sysfunc = 5 .AND. .NOT. box_open")
   mover_b[1] = mover_b[1] + " .AND. .NOT. EMPTY(cur_ntx)"
   
   DECLARE set_m[3]
   DECLARE set_b[3]
   set_m[1] = "Relaci¢n"
   set_m[2] = "Filtro"
   set_m[3] = "Campos"
   set_b[1] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(dbf[2])"
   set_b[2] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
   set_b[3] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
   
   * T¡tulos para las ventanas de ayuda
   help_title[1] = "INFORMACION GENERAL"
   help_title[2] = "LISTA DE CAMPOS"
   help_title[3] = "HOJEAR"
   help_title[4] = "CREAR / MODIFICAR ESTRUCTURA"
   help_title[5] = "CREAR INDICE"
   help_title[6] = "ABRIR BASE DE DATOS"
   help_title[7] = "FILTROS"
   help_title[8] = "ABRIR INDICE"
   help_title[9] = "ESTABLECER RELACION"
   help_title[10] = "LOCALIZAR EXPRESION"
   help_title[11] = "SDF / DELIMITED"
   help_title[12] = "COPIAR"
   help_title[13] = "BUSCAR EXPRESION"
   help_title[14] = "IR A UN REGISTRO"
   help_title[15] = "A¥ADIR"
   help_title[16] = "FOR / WHILE"
   help_title[17] = "AMBITO"
   help_title[18] = "VENTANA DOS"
   help_title[19] = "EDITOR DE MEMOS (TEXTO)"
   help_title[20] = "PASAR <n> REGISTROS"
   help_title[21] = "GRABAR / LEER VISTA"
   help_title[22] = "MODIFICAR"
   
   * Matrices con los nombres de fichero del directorio actual
   DECLARE dbf_list[adir("*.DBF") + 20]          && Directorio de los ficheros de datos
   DECLARE ntx_list[adir("*" + INDEXEXT()) + 20] && Directorio de los fichero ¡ndice
   DECLARE vew_list[adir("*.VEW") + 20]          && Directorio de los ficheros de vista
   
   * Se llenan las matrices con los nombres de fichero
   array_dir("*.DBF",dbf_list)
   array_dir("*" + INDEXEXT(),ntx_list)
   array_dir("*.VEW",vew_list)
   
   * Valores por defecto para establecer vista
   local_func = 0                    && Men£ local
   local_sel = 1                     && Opci¢n local del men£
   keystroke = 0                     && Tecla pulsada actual
   lkey = 0                          && Anterior tecla pulsada
   sysfunc = 0                       && Men£ de sistema
   func_sel = 1                      && Opci¢n del men£ de sistema
   
   * Ordena y procesa la l¡nea de par metros si se introdujo
   com_line = LTRIM(TRIM(com_line))
   
   IF .NOT. EMPTY(com_line)
      
      DO CASE
         
      CASE RAT(".", com_line) > RAT("\", com_line)
         * Se especific¢ un fichero con extensi¢n
         IF .NOT. FILE(com_line)
            * El fichero debe existir
            com_line = ""
            
         ENDIF
         
      CASE FILE(com_line + ".VEW")
         * B£squeda de un fichero con extensi¢n .VEW
         com_line = com_line + ".VEW"
         
      CASE FILE(com_line + ".DBF")
         * B£squeda de un fichero con extensi¢n .DBF
         com_line = com_line + ".DBF"
         
      OTHERWISE
         * Fichero no encontrado. Se ignora la l¡nea de par metros
         com_line = ""
         
      ENDCASE
      
      IF .NOT. EMPTY(com_line)
         * El fichero par metro existe
         
         IF RAT(".VEW", com_line) = LEN(com_line) - 3
            * Se asume un fichero .VEW con formato v lido
            view_file = com_line
            set_from(.F.)                        && Restauraci¢n de la vista
            KEYBOARD CHR(-4) + CHR(24) + CHR(13) && Visualizaci¢n de la vista
            
         ELSE
            * Se asume un fichero .DBF con formato v lido
            dbf[1] = com_line                    && Fichero activo al inicio
            
            IF NetUse( com_line )
               all_fields(1, M->field_n1)        && Todos los campos activos
               KEYBOARD CHR(-4) + CHR(13)        && Visualizaci¢n del fichero
            ELSE
               dbf[1] := ""
            ENDIF
            
         ENDIF
         
         IF .NOT. EMPTY(dbf[1])
            * Vista establecida. Se cancela la visualizaci¢n del error
            view_err = ""
         ENDIF
      ENDIF
   ENDIF
   
   DO WHILE .T.
      * Indefinidamente
      cur_func = M->sysfunc                && Para reconocer un cambio
      
      DO CASE
         
      CASE M->sysfunc = 5
         * Visualizaci¢n
         
         IF .NOT. EMPTY(dbf[1])
            * Existe una vista. Configuraci¢n de la misma.
            setup()
            
            IF EMPTY(M->view_err)
               * Se configur¢ con ‚xito
               cur_fields = "Field_n" + SUBSTR("123456", M->cur_area, 1)
               
               DO CASE
                  
               CASE M->func_sel = 1 .AND. EMPTY(M->cur_dbf)
                  * Visualizar un fichero
                  view_err = "Area sin base de datos asociada."
                  
               CASE M->func_sel = 1 .AND. EMPTY(&cur_fields[1])
                  * Visualizar un fichero
                  view_err = "Area sin lista de campos activa."
                  
               CASE EMPTY(field_list[1])
                  * Visualizar toda la vista
                  view_err = "No hay lista de campos activa"
                  
               OTHERWISE
                  * Preparado para la visualizaci¢n
                  
                  IF M->func_sel = 1
                     * Visualizar un fichero. Resaltar su nombre
                     hi_cur()
                     
                  ENDIF
                  
                  help_code = 3
                  DO browse
                  dehi_cur()
                  
               ENDCASE
            ENDIF
            
         ELSE
            view_err = "No hay base de datos abierta"
            
         ENDIF
         
         sysfunc = 0                    && De vuelta a la pantalla principal
         
      CASE M->sysfunc = 3
         
         IF M->func_sel = 1
            * Modificaci¢n de la estructura
            hi_cur()
            help_code = 4
            DO modi_stru
            dehi_cur()
            
            IF EMPTY(M->cur_dbf)
               * La nueva estructura no se ha creado. Deshacer lo hecho
               cur_area = 0
               
            ENDIF
            
         ELSE
            * Creaci¢n o recreaci¢n del ¡ndice
            
            IF EMPTY(M->cur_dbf)
               view_err = "Area de trabajo sin fichero de datos asociado."
               
            ELSE
               help_code = 5
               DO make_ntx
               
            ENDIF
         ENDIF
         
         sysfunc = 0                && De vuelta a la pantalla principal
         
      CASE M->sysfunc = 6 .AND. M->func_sel <> 6
         * Copiar/A¤adir/Cambiar/Purgar/Vaciar
         
         IF EMPTY(M->cur_dbf)
            view_err = "Area de trabajo sin fichero de datos asociado."
            sysfunc = 0                && De vuelta a la pantalla principal
            LOOP
            
         ENDIF
         
         IF .NOT. EMPTY(dbf[1])
            * Configurar la vista
            setup()
            
         ENDIF
         
         IF .NOT. EMPTY(M->view_err)
            * Error en la configuraci¢n
            sysfunc = 0                && de vuelta a la pantalla principal
            LOOP
            
         ENDIF
         
         hi_cur()
         
         DO CASE
            
         CASE M->func_sel < 4
            * copiar, a¤adir o cambiar
            DO capprep
            
         CASE M->func_sel = 4
            * Mandato purgar
            
            IF rsvp("¨Purgar " + M->cur_dbf + "? (S/N)") = "S"
               * Purgado confirmado
               stat_msg("Purgando " + M->cur_dbf)
               SELECT (M->cur_area)
               IF NetPack()
                  stat_msg(M->cur_dbf + " purgada")
               ELSE
                  /*
                  IF !NetUse( M->cur_dbf )
                     /// Si no es posible volver a abrir, hay problemas
                     ALERT( "Assertion failed:;Unable to re-open file" )
                     QUIT
                  ENDIF
                  */
                  clear_dbf(M->cur_area, 2)
                  cur_dbf = dbf[M->cur_area]
                  stat_msg("")
               ENDIF
               
            ENDIF
            
         CASE M->func_sel = 5
            * Mandato vaciar
            
            IF rsvp("¨Vaciar " + M->cur_dbf + "? (S/N)") = "S"
               * Vaciado confirmado
               stat_msg("Vaciando " + M->cur_dbf)
               SELECT (M->cur_area)
               IF NetZap()
                  stat_msg(M->cur_dbf + " vaciada")
               ELSE
                  /*
                  IF !NetUse( M->cur_dbf )       //Attempt to re-open shared
                     /// If we can't re-open, we're in trouble...
                     ALERT( "Assertion failed:;Unable to re-open file" )
                     QUIT
                  ENDIF
                  */
                  clear_dbf(M->cur_area, 2)
                  cur_dbf = dbf[M->cur_area]
                  stat_msg("")
               ENDIF
               
            ENDIF
            
         ENDCASE
         
         dehi_cur()
         sysfunc = 0                     && De vuelta a la pantalla principal
         
      CASE M->sysfunc = 6 .AND. M->func_sel = 6
         * Ejecuci¢n de un programa o de un mandato DOS
         @ 4,0 CLEAR
         
         IF .NOT. EMPTY(dbf[1])
            * Establecer la vista antes de un posible cambio de directorio
            setup()
            
         ENDIF
         
         IF .NOT. EMPTY(M->view_err)
            * Visulizaci¢n del mensaje y continuaci¢n para una posible
            * correcci¢n de "Fichero no encontrado", etc.
            error_msg(M->view_err, 24, 7)
            view_err = ""
            
         ENDIF
         
         run_com = ""
         com_line = ""
         help_code = 18
         
         DO WHILE .NOT. q_check()
            * Redibujar las tres primeras l¡neas de la pantalla despu‚s
            * de la ejecuci¢n de cada mandato
            @ 0,0 SAY " F1        F2        F3        F4        " +;
            "F5        F6        F7        F8       "
            show_keys()
            @ 2,0 SAY REPLICATE("Ä", 80)
            @ 24,0 SAY "Ejecutar Í" + CHR(16) + " "
            
            * Aceptar mandato
            run_com = enter_rc(M->com_line, 24, 11, 127, "@KS69", M->color1)
            
            IF .NOT. EMPTY(M->run_com) .AND. M->keystroke = 13
               * S¢lo la tecla Intro ejecutar  el mandato
               com_line = M->run_com       && Preserva el mandato anterior
               @ 24,0                      && Borra la entrada de mandatos
               
               SET CURSOR ON
               RUN &run_com
               SET CURSOR OFF
               
            ELSE
               * Comprueba la solicitud de ejecuci¢n de una opci¢n de men£
               sysmenu()
               
               IF M->local_func = 1
                  DO syshelp
                  
               ENDIF
            ENDIF
         ENDDO
         
         * Restablece el entorno
         @ 3,0 CLEAR
         
         * Reconstruye las matrices de directorios. Deben quedar como actuales
         DECLARE dbf_list[adir("*.DBF") + 20]
         DECLARE ntx_list[adir("*" + INDEXEXT()) + 20]
         DECLARE vew_list[adir("*.VEW") + 20]
         
         * Llena las matrices con los nombres de los ficheros de datos
         array_dir("*.DBF",dbf_list)
         
         * Ficheros ¡ndice
         array_dir("*" + INDEXEXT(),ntx_list)
         
         * Ficheros vista
         array_dir("*.VEW",vew_list)
         cur_area = 0                && Redibuja la pantalla de vistas
         sysfunc = 0                 && De vuelta a la pantalla principal
         
      OTHERWISE
         * Patalla principal de vistas. sysfunc = 0
         help_code = 1
         DO set_view
         
         IF M->keystroke = 27
            * Salida confirmada en set_view
            SET TYPEAHEAD TO 0             && Las teclas restantes al DOS
            CLOSE DATABASES                && Eliminar la vista
            RESTORE SCREEN                 && Restaurar la pantalla
            SET CURSOR ON                  && Activar cursor
            SET COLOR TO                   && Color normal de nuevo
            QUIT                           && Al fin salimos
         ENDIF
      ENDCASE
   ENDDO

   RETURN
   
   
   
/***
*
*  ParseCommLine( cCommandLine ) --> { cFile, cColorDescriptor }
*
*/
FUNCTION ParseCommLine( cStr )
   LOCAL aRet := { "", "" }       // Valor de retorno: fichero y colores    
   LOCAL nPos := 1                // Posici¢n del pr¢ximo token en la cadena
   LOCAL cToken                   // Par metro de la l¡nea de mandato extraido
   
   WHILE ( nPos != 0 )
      
      IF (( nPos := AT( "~", cStr ) ) != 0 )
         
         cToken := SUBSTR( cStr, 1, nPos - 1 )
         cStr   := SUBSTR( cStr, ++nPos )
         
         DO CASE
         CASE ( cToken == "/E" )
            NetMode( .F. )
            
         CASE ( cToken $ "/C/M" )
            aRet[2] := cToken
            
         CASE !( cToken == "" )
            aRet[1] := cToken
            
         ENDCASE
         
      ENDIF
      
   ENDDO
   
   RETURN ( aRet )



/***
*
*  GetHelpFile() --> cHelpFile
*
*/
FUNCTION GetHelpFile()
   LOCAL cPath := GETENV( "PATH" )
   LOCAL nPos  := 1
   LOCAL cFile
   LOCAL lFound

   WHILE ( nPos != 0 )
      
      nPos  := AT( ";", cPath )

      // B£squeda de la barra invertida en el path
      IF ( SUBSTR( cPath, nPos - 1, 1 ) == "\" )
         cFile := SUBSTR( cPath, 1, IF( nPos == 0, LEN( cPath ), nPos - 1 )) + "dbu.hlp"
      ELSE
         cFile := SUBSTR( cPath, 1, IF( nPos == 0, LEN( cPath ), nPos - 1 )) + "\dbu.hlp"
      ENDIF
         
      IF FILE( cFile )
         EXIT     // Encontrado                  
      ENDIF

      IF ( nPos == 0 )
         cFile := ""
      ELSE
         cPath := SUBSTR( cPath, nPos + 1 )
      ENDIF

   END

   RETURN ( cFile )



* Fin del fichero: DBU.PRG
