/***
*
*  Dbustru.prg
*
*  M¢dulo de creaci¢n y modificaci¢n de estructuras de la utilidad DBU 
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados
*
*/


******
*       modi_stru
*
*       Crea o modifica la estructura de una base de datos
******
PROCEDURE modi_stru
local saveColor
PRIVATE filename,fill_row,cur_row,rec1,m_item,i,n,f_name,f_type,f_len,f_dec,;
                prev_rec,field_id,stru_ok,is_insert,is_append,altered,type_n,;
                empty_row,not_empty,old_help,chg_name,len_temp,stru_name,;
                wstru_buff

* Almacenamos el c¢digo de ayuda
old_help = help_code
saveColor := SetColor(M->color7)

* Salvamos la pantalla
wstru_buff = SAVESCREEN(8, 20, 23, 59)

* Matrices locales con valores constantes
DECLARE ffield[4]
DECLARE field_col[4]
DECLARE data_type[5]
DECLARE l_usr[5]

* Lista de campos para la estructura
ffield[1] = "field_name"
ffield[2] = "field_type"
ffield[3] = "field_len"
ffield[4] = "field_dec"

* Columnas de visualizaci¢n de ffield[]
field_col[1] = 22
field_col[2] = 35
field_col[3] = 48
field_col[4] = 55

* Tipos de datos como cadenas de caracteres
data_type[1] = "Car cter "
data_type[2] = "Num‚rico "
data_type[3] = "Fecha    "
data_type[4] = "L¢gico   "
data_type[5] = "Memo     "

* Ultimas definiciones para cada tipo de datos 
l_usr[1] = 3                    && Car cter - longitud de la variable
l_usr[2] = 4                    && Num‚rico - longitud y decimales de la variable
l_usr[3] = 2                    && Fecha - longitud fija a 8
l_usr[4] = 2                    && L¢gico - longitud fija a 1
l_usr[5] = 2                    && Memo - longitud fija a 10

* Inicializaci¢n de variables locales
type_n = 1                      && ¡ndice de cada tipo de datos
altered = .F.                   && ¨Alg£n cambio?
chg_name = .T.                  && ¨Es posible cambiar el nombre de los campos?
prev_rec = 0                    && Detecci¢n del movimiento de puntero
n = 1                           && Columna actual del cursor (1 - 4)
i = 0                           && Aspecto de campo no v lido
cur_row = 13                    && Fila actual del cursor
is_insert = .F.                 && .T. si se ha insertado un campo
keystroke = 999                 && Para el relleno inicial de la pantalla
filename = ""                   && Variable para la funci¢n "filebox"

* M scaras de fila   
empty_row = "           ³           ³       ³    "
not_empty = "           ³ Car cter  ³    10 ³    "

IF .NOT. EMPTY(M->cur_dbf)
        * Modificaci¢n de la estructura
        stat_msg("Leyendo la estructura del fichero")
        stru_name = M->cur_dbf
        SELECT (M->cur_area)

   // Se intenta reabrir el fichero en exclusivo si estaba abierto en 
   // compartido
   IF NetMode()
      IF !NetUse( M->cur_dbf, .T.,,, .T. )
         ErrMsg( "No se puede modificar la estructura de " + M->cur_dbf + ;
                 ":;No se puede obtener el uso exclusivo" )
         IF !NetUse( M->cur_dbf,,,, .T. )
            clear_dbf(M->cur_area, 2)
            cur_dbf = dbf[M->cur_area]
         ENDIF
         RETURN         /* NOTA */
      ENDIF
   ENDIF

        * Creamos el fichero de estructura extendido
        COPY TO ddbbuuuu.ext STRUCTURE EXTENDED

        * Abrimos el fichero de estructura extendido en un  rea reservada
        SELECT 10
        USE ddbbuuuu.ext

        * La estructura es v lida y no se han a¤adido campos
        stru_ok = .T.
        is_append = .F.

        * Actualizaci¢n de la cabecera de la pantalla
        stat_msg("")

ELSE
        * Creaci¢n de la estructura
        SELECT 10
        CREATE ddbbuuuu.ext

        * A¤adir el primer campo nuevo de tipo car cter
        APPEND BLANK
        REPLACE field_type WITH "C",field_len WITH 10,field_dec WITH 0

        * La estructura no es v lida
        stru_ok = .F.
        is_append = .T.
        stru_name = ""

ENDIF

* Borrar y poner marco a la ventana
scroll(8, 20, 23, 59, 0)
@ 8, 20, 23, 59 BOX M->frame

* Establecer la cabecera de a ventana
@ 9,field_col[1];
SAY "Estructura de " + pad(IF(EMPTY(stru_name), "<nuevo>",;
                                                        SUBSTR(stru_name, RAT("\", stru_name) + 1)), 17)

@ 11,21 SAY  "Nombre campo     Tipo    Anchura  Dec"
@ 12,20 SAY "ÆÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍµ"
@ 23,33 SAY              "ÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏ"

DO WHILE .NOT. q_check()
        * Iteraci¢n principal

        DO CASE

                CASE keystroke = 999
                        * Dibujo de la ventana
                        scroll(13, 21, 22, 58, 0)             && Borrar ventana
                        rec1 = RECNO()                        && Primer registro en ventana
                        fill_row = 13                         && Primera fila a rellenar

                        DO WHILE .NOT. EOF() .AND. fill_row <= 22
                                * Rellena la ventana
                                stru_row(fill_row)

                                * Pr¢ximo n£mero de campo 
                                SKIP
                                fill_row = fill_row + 1

                        ENDDO

                        DO WHILE fill_row <= 22
                                * Fin de fichero..Completar las l¡neas verticales
                                @ fill_row,field_col[1] SAY empty_row
                                fill_row = fill_row + 1

                        ENDDO

                        * Ajustar el puntero del registro a la fila actual
                        GOTO rec1
                        fill_row = 13

                        DO WHILE fill_row < cur_row
                                * Si es posible nos desplazamos a la misma fila
                                SKIP

                                IF EOF()
                                        * No se puede ir      
                                        cur_row = fill_row
                                        GO BOTTOM
                                        EXIT

                                ENDIF

                                fill_row = fill_row + 1

                        ENDDO

                        keystroke = 0                   && Lectura de otra tecla

                CASE keystroke = 13 .OR. isdata(keystroke)
                        * INTRO. Seleccionamos algo

                        IF n = 2
                                * El tipo tiene un trato esoecial  
                                type_n = AT(field_type, "CNDLM")

                        ELSE
                                * Activamos el cursor para el GET
                                SET CURSOR ON

                                IF keystroke <> 13
                                        * Adelantamos la tecla al sistema de GET
                                        KEYBOARD CHR(keystroke)

                                ENDIF
                        ENDIF

            * Lectura del descriptor del nombre de fichero por medio de
            * una macrosustituci¢n normal
                        field_id = ffield[n]

            * Guardamos el item a comprobar para cambiarlo
                        m_item = &field_id

            * Configuraci¢n de flecha arriba, flecha abajo y las teclas
            * de men£ para salir de los READ
            SET KEY 5 TO clear_gets
                        SET KEY 24 TO clear_gets
                        xkey_clear()

                        DO CASE

                                CASE n = 1
                                        * Leemos el nombre del campo
                                        SetColor(M->color1)
                                        @ cur_row,field_col[1] GET field_name PICTURE "@!K"
                                        READ
                                        SetColor(M->color7)
                                        keystroke = LASTKEY()

                                CASE n = 2
                                        * Tratamiento especial del tipo del campo

                                        DO CASE

                                                CASE UPPER(CHR(keystroke)) $ "CNFLM"
                                                        * Poner C, N, D, L o M en el tipo
                                                        type_n = AT(UPPER(CHR(keystroke)), "CNFLM")
                                                        keystroke = 13

                                                CASE keystroke = 32
                                                        * La barra espaciadora pasa al siguiente tipo
                                                        type_n = IF(type_n = 5, 1, type_n + 1)

                                                CASE keystroke <> 13
                            * La tecla INTRO se comporta como la flecha a la
                            * derecha
                                                        keystroke = 0

                                        ENDCASE

                                        IF m_item <> SUBSTR("CNFLM", type_n, 1)
                        * Poner type_n en field_type
                                                REPLACE field_type WITH SUBSTR("CNDLM", type_n, 1)

                                                DO CASE
                                                        * Ponemos field_len y field_dec de acuerdo con el tipo

                                                        CASE field_type = "C"
                                                                * Car cter..cualquier longitud pero sin decimales
                                                                REPLACE field_dec WITH 0

                                                        CASE field_type = "N"
                                                                * Num‚rico

                                                                IF m_item = "C" .AND. (field_dec <> 0 .OR.;
                                                                   field_len > 19)
                                    * Demasiado largo o longitud extendida de
                                    * CA-Clipper (30 d¡gitos)
                                    REPLACE field_len WITH 10, ;
                                            field_dec WITH 0

                                                                ENDIF

                                                        CASE field_type = "D"
                                                                * Fecha..Siempre a 8
                                                                REPLACE field_len WITH 8,field_dec WITH 0

                                                        CASE field_type = "L"
                                                                * L¢gico..Siempre a 1
                                                                REPLACE field_len WITH 1,field_dec WITH 0

                                                        CASE field_type = "M"
                                                                * Memo..Siempre a 10
                                                                REPLACE field_len WITH 10,field_dec WITH 0

                                                ENDCASE

                                                * Visualizaci¢n de la nueva longitud del campo
                                                @ cur_row,field_col[3] SAY STR(field_len,4)

                                                IF field_type = "N"
                                                        * Visualizaci¢n de los nuevos decimales
                                                        @ cur_row,field_col[4] SAY field_dec

                                                ELSE
                                                        * Nos aseguramos que no haya decimales
                                                        @ cur_row,field_col[4] SAY "   "

                                                ENDIF
                                        ENDIF nuevo tipo

                                CASE n = 3
                                        * Leemos la longitud del campo

                                        IF field_type = "C"
                        * C lculo de la longitud extendida de Clipper a un
                        * temporal
                                                len_temp = (256 * field_dec) + field_len

                                        ELSE
                                                * Longitud normal del campo
                                                len_temp = field_len

                                        ENDIF

                                        * Leemos la nueva longitud
                                        SetColor(M->color1)
                                        @ cur_row,field_col[n] GET len_temp PICTURE "9999"
                                        READ
                                        SetColor(M->color7)
                                        keystroke = LASTKEY()

                                        IF menu_key() = 0
                                                * No hay petici¢n de men£

                                                IF field_type = "C"
                            * Situamos la longitud extendida de Clipper en  
                            * las posiciones Lon/Dec del Campo
                                                        REPLACE field_len WITH (len_temp % 256)
                                                        REPLACE field_dec WITH INT(len_temp / 256)

                                                ELSE

                                                        IF len_temp < 256
                                                                * Puede no ser una longitud v lida
                                                                REPLACE field_len WITH len_temp

                                                        ELSE
                                                                * Entrada no aceptada
                                                                keystroke = 0

                                                        ENDIF
                                                ENDIF
                                        ENDIF

                                CASE n = 4
                                        * Lectura de los decimales
                                        SetColor(M->color1)
                                        @ cur_row,field_col[n] GET field_dec
                                        READ
                                        SetColor(M->color7)
                                        keystroke = LASTKEY()

                        ENDCASE

                        * Se desactivan las teclas y se oculta el cursor
                        SET KEY 5 TO
                        SET KEY 24 TO
                        xkey_norm()
                        SET CURSOR OFF

                        IF menu_key() <> 0
                                * Restauramos el ¡tem y adelantamos la tecla de men£
                                REPLACE &field_id WITH m_item
                                KEYBOARD CHR(keystroke)

                        ENDIF

                        IF m_item <> &field_id
                                * Se ha cambiado algo
                                stru_ok = .F.           && La especificaci¢n de campo no es v lida
                                altered = .T.           && La estructura se ha alterado

                                IF n > 1
                                        * No pueden cambiarse los nombres de los campos
                                        chg_name = .F.

                                ENDIF
                        ENDIF

                        DO CASE

                                CASE keystroke = 18 .OR. keystroke = 5
                                        * Flecha arriba o ReP g desplazan al anterior
                                        keystroke = 5

                                CASE keystroke = 3 .OR. keystroke = 24
                                        * Flecha abajo o AvP g desplazan al posterior
                                        keystroke = 24

                                CASE keystroke = 13 .OR.;
                                         (isdata(keystroke) .AND. keystroke <> 32)
                                        * Pr¢ximo campo..La barra espaciadora intercambia tipos 
                                        keystroke = 4

                                OTHERWISE
                                        * El mismo campo
                                        keystroke = 0

                        ENDCASE

                        * No resalta el ¡tem actual  
                        stru_item()

                CASE keystroke = 5 .AND. RECNO() > 1
                        * Flecha arriba

                        IF is_append
                                * Comprueba el campo que se a¤adi¢ de nuevo

                                IF .NOT. stru_ck(.F.)
                                        * Borra el nuevo campo 
                                        no_append()

                                ENDIF
                        ENDIF

                        IF stru_ck(.T.)
                                * Nos movemos un campo hacia arriba
                                SKIP -1

                                IF cur_row = 13
                                        * desplazamiento de pantalla 
                                        scroll(13, 21, 22, 58, -1)

                                        * Llenamos la fila en blanco
                                        stru_row(13)

                                ELSE
                                        cur_row = cur_row - 1

                                ENDIF

                                is_append = .F.
                                is_insert = .F.

                        ELSE
                                * El campo no cumple las especificaciones
                                n = i

                        ENDIF

                        keystroke = 0

                CASE keystroke = 24
                        * Flecha abajo

                        IF stru_ck(RECNO() < LASTREC())
                                * Conforma para bajar un campo
                                SKIP

                                IF EOF()
                                        * La flecha abajo a¤adir 
                                        APPEND BLANK
                                        REPLACE field_type WITH "C",field_len WITH 10,;
                                                        field_dec WITH 0
                                        is_append = .T.
                                        stru_ok = .F.
                                        n = 1

                                        IF cur_row < 22
                                                * Muestra la nueva plantilla para el campo
                                                @ cur_row + 1, field_col[1] SAY not_empty

                                        ENDIF

                                ELSE
                                        is_insert = .F.

                                ENDIF

                                IF cur_row = 22
                                        * Necesitamos desplazamiento de pantalla
                                        scroll(13, 21, 22, 58, 1)

                                        * Llenamos la fila en blanco
                                        stru_row(22)

                                ELSE
                                        cur_row = cur_row + 1

                                ENDIF

                        ELSE
                                * Especificaci¢n de campo no v lida
                                n = i

                        ENDIF

                        keystroke = 0

                CASE keystroke = 4
                        * Flecha arriba

                        IF n < l_usr[AT(field_type, "CNDLM")]
                                n = n + 1

                        ENDIF

                        keystroke = 0

                CASE keystroke = 19
                        * Flecha izquierda

                        IF n > 1
                                n = n - 1

                        ENDIF

                        keystroke = 0

                CASE keystroke = 18
                        * ReP g
                        keystroke = 0

                        IF RECNO() = 1
                                * Evitamos redibujar si estamos en el inicio del fichero
                                LOOP

                        ENDIF

                        IF is_append
                                * Comprobaci¢n del nuevo campo

                                IF .NOT. stru_ck(.F.)
                                        * Borrado del registro que se acaba de a¤adir
                                        no_append()

                                ENDIF
                        ENDIF

                        IF stru_ck(.T.)
                                is_append = .F.
                                is_insert = .F.

                                IF RECNO() = cur_row - 12
                                        * El registro 1 est  en pantalla..no hemos de redibujar
                                        GO TOP
                                        cur_row = 13

                                ELSE
                                        * Pasamos una p gina y redibujamos
                                        SKIP -(9 + cur_row - 13)
                                        keystroke = 999

                                ENDIF

                        ELSE
                                * Especificaci¢n del campo no v lida..no pasamos p gina
                                n = i

                        ENDIF

                CASE keystroke = 3
                        * AvP g
                        keystroke = 0

                        IF is_append
                                * Evitamos mensajes de error
                                LOOP

                        ENDIF

                        IF stru_ck(.T.)
                                is_insert = .F.

                                IF LASTREC() - RECNO() <= 22 - cur_row
                                        * El £ltimo campo est  en pantalla
                                        cur_row = cur_row + LASTREC() - RECNO()
                                        GO BOTTOM

                                ELSE
                                        * Pasamos una p gina hacia abajo
                                        keystroke = 999                 && Provoca redibujado de la ventana
                                        SKIP 9 - (cur_row - 13)

                                        IF EOF()
                                                * No pudo completarse la operaci¢n de salto
                                                GO BOTTOM

                                        ENDIF
                                ENDIF

                        ELSE
                                * Especificaci¢n de campo no v lida
                                n = i

                        ENDIF

                CASE keystroke = 31
                        * ^ReP g..Inicio del fichero de estructura
                        keystroke = 0

                        IF RECNO() = 1
                                * Inicio del fichero
                                LOOP

                        ENDIF

                        IF is_append
                                * Comprueba el registro que se acaba de a¤adir

                                IF .NOT. stru_ck(.F.)
                                        * Borramos el campo que se acaba de a¤adir
                                        no_append()

                                ENDIF
                        ENDIF

                        IF stru_ck(.T.)
                                is_append = .F.
                                is_insert = .F.

                                IF RECNO() > cur_row - 12
                                        * El primer registro no est  en pantalla
                                        keystroke = 999

                                ENDIF

                                GO TOP
                                cur_row = 13

                        ELSE
                                * Especificaci¢n de campo no v lida
                                n = i

                        ENDIF

                CASE keystroke = 30
                        * ^AvP g
                        keystroke = 0

                        IF is_append
                                * Evitamos mensajes de error
                                LOOP

                        ENDIF

                        IF stru_ck(.T.)
                                is_insert = .F.

                                IF LASTREC() - RECNO() <= 22 - cur_row
                                        * El £ltimo campo est  en pantalla
                                        cur_row = cur_row + LASTREC() - RECNO()
                                        GO BOTTOM

                                ELSE
                                        * Redibujamos la pantalla con el £ltimo registro visible
                                        keystroke = 999
                                        GO BOTTOM
                                        SKIP -9
                                        cur_row = 22

                                ENDIF

                        ELSE
                                * La especificaci¢n del campo no es v lida
                                n = i

                        ENDIF

                CASE keystroke = 6 .OR. keystroke = 23
                        * Fin o ^Fin 
                        keystroke = 0
                        n = l_usr[AT(field_type, "CNDLM")]

                CASE keystroke = 1 .OR. keystroke = 29
                        * Inicio o ^Inicio
                        keystroke = 0
                        n = 1

                CASE keystroke = 22
                        * Inserta un nuevo campo delante del cursor

                        IF stru_ck(.T.)
                                n = 1                           && El cursor en el nombre del campo
                                stru_ok = .F.                   && Especificaci¢n de campo no v lida
                                is_append = .F.                 && No a¤adir 
                                is_insert = .T.                 && Nuevo campo insertado 
                                rec1 = RECNO()                  && Recordar qu‚ campo

                                * A¤adimos dr sticamente
                                APPEND BLANK

                                DO WHILE rec1 < RECNO()
                                        * Desplazamos hacia arriba
                                        SKIP -1

                                        * Leemos las especificaciones previas
                                        f_name = field_name
                                        f_type = field_type
                                        f_len = field_len
                                        f_dec = field_dec

                                        * Lo almacenamos en el campo actual
                                        SKIP
                                        REPLACE field_name WITH f_name,field_type WITH f_type,;
                                                        field_len WITH f_len,field_dec WITH f_dec

                                        * Vamos al siguiente
                                        SKIP -1

                                ENDDO

                                * Provoca que el campo actual parezca nuevo
                                REPLACE field_name WITH SPACE(10),field_type WITH "C",;
                                                field_len WITH 10,field_dec WITH 0

                                IF cur_row < 22
                                        * Desplazamos la pantalla
                                        scroll((cur_row), 21, 22, 58, -1)

                                ENDIF

                                * El campo acabado de insertar 
                                @ cur_row,field_col[1] SAY not_empty

                        ELSE
                                * Especificaci¢n de campo no v lida
                                n = i

                        ENDIF

                        keystroke = 0

                CASE keystroke = 7 .AND. LASTREC() > 1
                        * Eliminar..S¢lo el registro actual puede no ser v lido
                        rec1 = RECNO()
                        DELETE
                        PACK

                        IF rec1 > LASTREC()
                                * El £ltimo registro se ha borrado
                                GO BOTTOM

                                IF cur_row = 13
                                        * Parte superior de la ventana
                                        stru_row(13)

                                ELSE
                                        @ cur_row,field_col[1] SAY empty_row
                                        cur_row = cur_row - 1

                                ENDIF

                        ELSE

                                IF cur_row < 22
                    * Desplazamos la parte inferior de la pantalla hacia
                    * arriba
                                        scroll((cur_row), 21, 22, 58, 1)

                                ENDIF

                                * Vamos al £ltimo registro de la pantalla
                                GOTO rec1
                                SKIP 22 - cur_row

                                IF .NOT. EOF()
                                        * Llenamos la fila inferior
                                        stru_row(22)

                                ELSE
                                        * Colocamos una plantilla vac¡a en la £ltima fila
                                        @ 22,field_col[1] SAY empty_row

                                ENDIF

                                * Movemos el puntero al registro actual
                                GOTO rec1

                                * El mismo n£mero de registro pero no el mismo registro
                                prev_rec = 0

                        ENDIF

                        IF .NOT. is_append .AND. .NOT. is_insert
                * Se ha modificado la estructura..No se pueden cambiar los 
                * nombres
                                altered = .T.
                                chg_name = .F.

                        ENDIF

                        * Reconfiguramos variables 
                        is_append = .F.                         && Adici¢n anulada
                        is_insert = .F.                         && Inserci¢n anulada
                        stru_ok = .T.                           && S¢lo el registro actual puede ser no v lido
                        keystroke = 0

                CASE prev_rec <> RECNO()
                        * El puntero al registro se ha movido y se han procesado todas las
                        * teclas pendientes
                        prev_rec = RECNO()

                        * Actualizaci¢n del n£mero de registro y de campos en la pantalla
                        @ 9,field_col[1] + 27 SAY "Campo " + pad(LTRIM(STR(RECNO())), 4)

                        IF n > l_usr[AT(field_type, "CNDLM")]
                                * Comprueba si n est  en rango
                                n = l_usr[AT(field_type, "CNDLM")]

                        ENDIF

                CASE local_func = 4
                        * Se ha seleccionado "Grabar estructura" en el men£
                        local_func = 0

                        IF .NOT. stru_ck(.T.)
                                * Especificaci¢n de campo no v lida
                                n = i
                                LOOP

                        ENDIF

                        is_append = .F.
                        is_insert = .F.
                        filename = stru_name

                        IF filebox(".DBF", "dbf_list", "stru_title",;
                                           "do_modstru", .T., 13) <> 0
                                * Estructura creada o alterada
                                stru_name = filename

                                * Reescritura del nombre en la parte alta de la ventana
                                @ 9,field_col[1] + 13;
                                SAY pad(IF(EMPTY(stru_name), "<Fichero nuevo>",;
                                                        SUBSTR(stru_name, RAT("\", stru_name) + 1)), 009)

                                IF aseek(dbf, filename) = 0
                                        * Llevamos el fichero a la vista
                                        cur_dbf = filename

                                        open_dbf(.F., .T.)

                                        * Seleccionamos el  rea de trabajo reservada del sistema
                                        SELECT 10

                                ENDIF

                                * Salida a la ventana principal
                                keystroke = 27  && Salida de esta rutina
                                cur_area = 0    && Redibuja la pantalla de vista

                        ENDIF

                        * Borra el mensaje de la pantalla
                        stat_msg("")

                CASE local_func = 1
                        * Se ha seleccionado "Ayuda" en el men£ principal..keystroke = 0
                        local_func = 0
                        DO syshelp

                OTHERWISE
                        * Lectura de la pr¢xima tecla

                        IF .NOT. key_ready()
                                * Resaltar los ¡tems actuales
                                SetColor(M->color2)
                                stru_item()
                                SetColor(M->color7)

                                * Esperar una tecla
                                read_key()

                                IF .NOT. (keystroke = 13 .OR. isdata(keystroke))
                                        * No es un GET..Reescribimos en atributo normal
                                        stru_item()

                                ENDIF
                        ENDIF

                        IF keystroke = 27 .AND. altered
                                * Aviso!!

                                IF rsvp("Se perder n los cambios. ¨De acuerdo? (S/N)") <> "S"
                                        keystroke = 0

                                ENDIF
                        ENDIF
        ENDCASE
ENDDO // creaci¢n/modificaci¢n de estructura 

* Cierra y borra fichero de estructura..Todo terminado
USE
ERASE ddbbuuuu.ext

* Borramos la l¡nea de estado
stat_msg("")

* Restauramos la pantalla
RESTSCREEN(8, 20, 23, 59, M->wstru_buff)

SetColor(saveColor)
RETURN


*********************
* Funciones locales *
*********************

******
*       stru_row()
*
*       Llena una fila en la ventana de estructuras
******
FUNCTION stru_row

PARAMETERS fill_row

@ fill_row,field_col[1];
SAY field_name + " ³ " + data_type[AT(field_type, "CNDLM")] + " ³ "

IF field_type = "C"
        * Visualiza la longitud de campo extendida de CA-Clipper
        @ fill_row,field_col[3] SAY STR(((256 * field_dec) + field_len), 4) +;
                                                                " ³    "

ELSE
        * Longitud de campo normal
        @ fill_row,field_col[3] SAY STR(field_len, 4) + " ³    "

        IF field_type = "N"
                * Visualiza los decimales en los campos num‚ricos
                @ fill_row,field_col[4] SAY field_dec

        ENDIF
ENDIF

RETURN 0


******
*       stru_item()
*
*       Visualiza ¡tems en la ventana de estructuras
******
FUNCTION stru_item

DO CASE

        CASE n = 1
                * Nombre del campo
                @ cur_row,field_col[1] SAY field_name

        CASE n = 2
                * Visualiza el tipo como cadena de caracteres
                @ cur_row,field_col[2] SAY data_type[AT(field_type, "CNDLM")]

        CASE n = 3

                IF field_type = "C"
                        * Visualiza la longitud extendida de CA-Clipper
                        @ cur_row,field_col[n] SAY STR(((256 * field_dec) +;
                        field_len),4)

                ELSE
                        * Longitud de campo normal
                        @ cur_row,field_col[n] SAY STR(field_len,4)

                ENDIF

        CASE n = 4
                * Los decimales
                @ cur_row,field_col[4] SAY field_dec

ENDCASE

RETURN 0


******
*       no_append()
*
*       Elimina los registros acabados de a¤adir
******
FUNCTION no_append

DELETE
PACK
GO BOTTOM
SKIP

IF (RECNO() = cur_row - 12) .OR. keystroke = 5
        * Pone a blanco la fila actual
        @ cur_row,field_col[1] SAY empty_row

ENDIF

stru_ok = .T.

RETURN 0


******
*       stru_ck()
*
*       Comprueba la especificaci¢n del campo si es necesario
******
FUNCTION stru_ck

PARAMETERS disp_err

IF .NOT. stru_ok
        * Se necesita comprobaci¢n
        i = field_check(disp_err)
        stru_ok = (i = 0)

ENDIF

RETURN stru_ok


******
*       field_check()
*
*       Devuelve un c¢digo se¤alando la anomal¡a
******
FUNCTION field_check

PARAMETERS disp_err
PRIVATE pos,test_num,test_name,status,err_msg

* Inicializaci¢n de variables locales
status = 0
err_msg = ""

* Comprobaci¢n de la validez del nombre del campo
pos = LEN(TRIM(field_name))

IF pos = 0
        * Si est  en blanco
        status = 1
        err_msg = "El campo no tiene nombre"

ENDIF

IF status = 0

        DO WHILE pos > 0 .AND. SUBSTR(field_name, pos, 1) $;
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
                * Se validan todos los caracteres excepto los blancos de relleno
                pos = pos - 1

        ENDDO

        * El primer car cter debe ser una letra
        IF pos > 0 .OR. SUBSTR(field_name, 1, 1) $ "0123456789_"
                * Car cter no v lido
                status = 1
                err_msg = "El nombre del campo no es v lido"

                IF keystroke = 24
            * Forzamos la visualizaci¢n de un mensaje de error si se intenta
            * salir del campo con flecha abajo
                        disp_err = .T.

                ENDIF
        ENDIF
ENDIF

IF status = 0
        * Comprueba que no haya nombres de campo duplicados
        test_num = RECNO()
        test_name = field_name
        LOCATE FOR field_name = test_name .AND. RECNO() <> test_num

        IF FOUND()
                * Nombre de campo duplicado
                status = 1
                err_msg = "Nombre de campo duplicado"

                IF keystroke = 24
            * Se muestra un mensaje de error cuando se intenta salir con
            * flecha abajo
                        disp_err = .T.

                ENDIF
        ENDIF

        * Sit£a el puntero en el registro correcto
        GOTO test_num

ENDIF

IF status = 0
        * Comprueba que la longitud sea la corecta

        IF field_type = "C"
                test_num = (256 * field_dec) + field_len

                IF test_num <= 0 .OR. test_num > 1024
                        * La anchura del campo no es v lida
                        status = 3
                        err_msg = "La anchura del campo no es v lida"

                        IF keystroke = 24
                * Se muestra el mensaje de error si se intenta salir con
                * flecha abajo
                                disp_err = .T.

                        ENDIF
                ENDIF

        ELSE

                IF field_len <= 0 .OR. field_len > 19
                        * La anchura del campo no es v lida
                        status = 3
                        err_msg = "La anchura del campo no es v lida"

                        IF keystroke = 24
                * Se muestra mensaje de error cuando se intenta salir con
                * flecha abajo
                                disp_err = .T.

                        ENDIF
                ENDIF
        ENDIF
ENDIF

IF field_type = "N" .AND. status = 0
        * Validaci¢n de los decimales

        IF field_dec > IF(field_len < 3, 0, IF(field_len > 17, 15, field_len - 2))
        * n£mero de decimales incorrecto
                status = 4
                err_msg = "El n£mero de decimales es incorrecto"

                IF keystroke = 24
            * Se muestra un mensaje de error cuando se intenta salir con
            * flecha abajo
                        disp_err = .T.

                ENDIF
        ENDIF
ENDIF

IF status > 0 .AND. disp_err
        * Hay algo mal y por tanto mostraremos un mensaje
        error_msg(err_msg)

ENDIF

RETURN status


************************************
* Funciones llamadas desde filebox *
************************************

******
*       stru_title()
*
*       Visualiza el t¡tulo para la caja de creaci¢n de estructura
******
FUNCTION stru_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Grabar estructura en el")


******
*       do_modstru()
*
*       Crea o modifica la estructura de un fichero de datos
******
FUNCTION do_modstru

LOCAL cAlias
PRIVATE stru_done, i, is_open, new_name, name_temp, add_name,;
                dbt_spec, dbt_temp, rec1

DO CASE

        CASE EMPTY(filename)
                error_msg("No se introdujo nombre de fichero")
                stru_done = .F.

        OTHERWISE
        * Determina si la estructura se graba en el fichero actualmente
        * abierto o no
                i = aseek(dbf, filename)
                is_open = (i > 0)

                IF FILE(filename) .AND. .NOT. (filename == cur_dbf)
                        * El fichero existe y no es el actual fichero modificado

                        IF rsvp(filename + IF(is_open, " est  ahora abierto",;
                                                                                   " ya existe") +;
                                        "¨Sobreescribir? (S/N)") <> "S"
                                * oops
                                RETURN .F.

                        ENDIF
                ENDIF

                IF is_open
                        * No se puede modificar un fichero abierto, pero lo simularemos 
                        name_temp = "ntx" + SUBSTR("123456", i, 1)
                        need_ntx = need_ntx .OR. .NOT. EMPTY(&name_temp[1])

            * Temporalmente desactivamos las relaciones destinadas al fichero
            * abierto
                        not_target(i, .F.)

                        * Cerramos el fichero
                        SELECT (M->i)
                        USE

                        name_temp = "kf" + SUBSTR("123456", i, 1)

                        IF .NOT. EMPTY(&name_temp)
                                * Necesitaremos reestablecer los filtros del fichero abierto
                                need_filtr = .T.

                        ENDIF

                        * Seleccionamos el  rea de trabajo reservada por el sistema
                        SELECT 10

                ENDIF

                * Recordar el n£mero del campo actual y cerrar el fichero de estructura
                rec1 = RECNO()
                USE

                * Recordar si el fichero ya exist¡a antes en el directorio
                add_name = .NOT. FILE(name(filename) + ".DBF")

                IF FILE(filename)
                        * El fichero existe..Modificar estructura y salvar los datos
                        new_name = " "

                        IF chg_name .AND. altered
                                * Preguntamos si hay que cambiar el nombre de los campos
                                new_name = rsvp("¨Modificar los nombres de los campos? (S/N)")

                                IF .NOT. new_name $ "SN"
                                        * Pulsando escape anulamos la operaci¢n
                                        USE ddbbuuuu.ext
                                        GOTO rec1
                                        RETURN .F.

                                ENDIF
                        ENDIF

                        * Establece la creaci¢n de temporale en el mismo directorio
                        name_temp = SUBSTR(filename, 1, RAT("\", filename)) +;
                                                "DDBBUUUU.TMP"
                        dbt_spec = SUBSTR(filename, 1, RAT(".", filename)) +;
                                           "DBT"
                        dbt_temp = SUBSTR(name_temp, 1, RAT(".", name_temp)) +;
                                           "DBT"

                        IF FILE(dbt_spec)
                                * El fichero de datos contiene campos MEMO

                                IF new_name = "S"
                                        * Los campos se perder n durante la copia SDF
                                        new_name = rsvp("Cuidado: Los campos MEMO se perder n" +;
                                                                        "..¨Continuar? (S/N)")

                                        IF new_name <> "S"
                                                * Abandonamos la operaci¢n
                                                USE ddbbuuuu.ext
                                                GOTO rec1
                                                RETURN .F.

                                        ENDIF
                                ENDIF

                                * Cada DBT siene su DBF
                                RENAME &dbt_spec TO &dbt_temp

                        ENDIF

                        stat_msg(IF(new_name <> "S", "Modificando la estructura del fichero",;
                                                "Modificando los nombres de los campos"))

                        * Grabar el antiguo y crear uno nuevo
                        RENAME &filename TO &name_temp
         cAlias := MakeAlias( filename )
         CREATE &filename FROM ddbbuuuu.ext ALIAS cAlias

                        IF new_name = "S"
                                * Copiando los nombres de los campos SDF
                                USE &name_temp
                                COPY TO ddbbuuuu.txt SDF
                                USE &filename
                                APPEND FROM ddbbuuuu.txt SDF
                                ERASE ddbbuuuu.txt

                        ELSE
                                * Modificaci¢n normal de la estructura
                                APPEND FROM &name_temp

                        ENDIF

                        IF FILE(name_temp)
                                * Borramos el fichero temporal
                                ERASE &name_temp

                        ENDIF

                        IF FILE(dbt_temp)
                                * Borramos el fichero DBT temporal
                                ERASE &dbt_temp

                        ENDIF

                        IF is_open
                                * Devolvemos el fichero a su  rea de trabajo original
                                USE                     && Cerramos el  rea reservada del sistema
                                SELECT (M->i)           && Seleccionamos el  rea correcta
                                USE &filename           && Reabrimos el fichero

                                * Establece la lista de campos para la nueva estructura
                                name_temp = "field_n" + SUBSTR("123456", M->i, 1)
                                all_fields(M->i, &name_temp)

                                * Volvemos a seleccionar el  rea reservada del sistema
                                SELECT 10

                        ENDIF

                ELSE
                        * Creamos el nuevo fichero
                        stat_msg("Creando el nuevo fichero de datos")
         cAlias := MakeAlias( filename )
         CREATE &filename FROM ddbbuuuu.ext ALIAS cAlias
                        USE

                        IF AT(".DBF", filename) = LEN(filename) - 3 .AND.;
                           FILE(name(filename) + ".DBF") .AND. add_name
                                * A¤adimos s¢lo los fichero .DBF del directorio actual
                                i = afull(dbf_list) + 1

                                IF i <= LEN(dbf_list)
                                        * A¤adimos el nombre del fichero a la nueva lista
                                        dbf_list[i] = filename
                                        array_sort(dbf_list)

                                ENDIF
                        ENDIF
                ENDIF

                * Cerramos el fichero reci‚n creado o modificado
                USE
                stru_done = .T.

ENDCASE

RETURN stru_done


* Fin de fichero: DBUSTRU.PRG
