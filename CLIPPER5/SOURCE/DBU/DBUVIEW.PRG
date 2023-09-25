/***
*
*  Dbuview.prg
*
*  M¢dulo de mantenimiento de vistas de la utilidad DBU 
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.
*
*/


******
*       set_view
*
*       Selecciona ficheros, campos, relaciones y filtros
*
*       NOTA: Los ficheros de datos s¢lo se abren y se cierran cuando se precisa.
*             Todos los dem s aspectos de la vista ser n almacenados cuando sea
*             necesario llamando a la funci¢n setup () del m¢dulo de utilidades.
******
PROCEDURE set_view
local saveColor
PRIVATE bar_line,empty_line,ntx,field_n,el,cur_row,t_row,ch_draw,;
                strn,is_redraw,is_insert,horiz_keys,prev_area,i

saveColor := SetColor(M->color1)

* Matriz local de nombre de ficheros ¡ndice (sin v¡a ni extensi¢n)
DECLARE d_array[LEN(M->ntx1)]

* Inicializaci¢n de variables locales
horiz_keys = CHR(4) + CHR(19) + CHR(1) + CHR(6) && Retorno r pido del men£
bar_line = ""           && construido por bline()
empty_line = ""         && ditto
prev_area = 0           && Detecci¢n del movimiento horizontal
ch_draw = .F.           && Indicador de funci¢n

* C¢digo de ayuda global
help_code = 1

* Valor global de la tecla conveniente para bifurcar "en otro caso" 
keystroke = 0

* Apertura y creaci¢n de los men£s por defecto
set_deflt()

IF .NOT. EMPTY(M->view_err)
        error_msg(M->view_err)
        view_err = ""

ENDIF

DO WHILE .NOT. q_check()
        * Un gran CASE..La condici¢n de salida se determina en cualquier parte

        DO CASE

                CASE M->cur_area = 0
            * Dibuja la pantalla..Hay que ver si se necesita una 
            * completa reinicializaci¢n
                        cur_area = aseek(M->dbf, M->cur_dbf)

                        IF M->cur_area = 0
                                * Se precisa una reinicializaci¢n completa

                                FOR i = 1 TO 3
                                        * Filas y elementos actuales
               STORE row_a[M->i] TO _cr1[M->i],_cr2[M->i],_cr3[M->i],;
                               _cr4[M->i],_cr5[M->i],_cr6[M->i]
               STORE 1 TO _el1[M->i],_el2[M->i],_el3[M->i],_el4[M->i],;
                        _el5[M->i],_el6[M->i]

                                NEXT

                                * Variables globales
                                cur_dbf = dbf[1]
                                STORE 1 TO cur_area, page

                                * Valores por defecto de men£s de creaci¢n y apertura
                                set_deflt()

                        ENDIF

                        * Dibujo de la pantalla principal
                        draw_view(0)

                CASE M->cur_area <> M->prev_area
                        * Se ha detectado el movimiento 
                        cur_dbf = dbf[M->cur_area]      && Fichero de datos actual

                        * Se salva en las llamadas a funciones
                        strn = SUBSTR("123456", M->cur_area, 1)

                        ntx = "ntx" + strn
                        field_n = "field_n" + strn
                        el = "_el" + strn

                        * Uso de variables temporales para su ajuste
                        t_row = "_cr" + strn

                        IF M->page > 1 .AND. M->prev_area <> 0
                                * Ajuste elemento por (fila antigua - fila nueva)
                                &el[M->page] = &el[M->page] +;
                                                           &cur_row[M->page] - &t_row[M->page]

                                * Fila nueva = fila antigua
                                &t_row[M->page] = &cur_row[M->page]

                        ENDIF

                        * Establece canal de datos activo
                        cur_row = M->t_row

                        * Borra para siguiente bucle
                        prev_area = M->cur_area

                CASE M->keystroke = 19
                        * Flecha izquierda..mueve un canal a la izquierda

                        IF M->cur_area > 1
                                * De acuerdo para ir a la izquierda
                                cur_area = M->cur_area - 1

                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 1
                        * Tecla Inicio..Extremo izquierdo
                        cur_area = 1
                        keystroke = 0

                CASE M->keystroke = 4
                        * Flecha derecha..mueve un canal a la derecha

                        IF M->cur_area < 6 .AND. .NOT. EMPTY(M->cur_dbf)
                                * Ir a la derecha..siguiente canal
                                cur_area = M->cur_area + 1

                                IF EMPTY(dbf[M->cur_area])
                                        * Canal inactivo..imposible introducir ¡ndices o campos
                                        page = 1
                                        set_deflt()

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 6
                        * Tecla Fin..Ir al extremo derecho

                        IF M->cur_area < 6 .AND. .NOT. EMPTY(M->cur_dbf)
                                * Ir a la derecha..determina £ltimo canal activo
                                i = afull(M->dbf)

                                IF M->i < 6 .AND. (M->page = 1 .OR. M->cur_area = M->i)
                                        * Mover a canal inactivo
                                        cur_area = M->i + 1

                                        * Imposible introducir ¡ndices o campos
                                        page = 1
                                        set_deflt()

                                ELSE
                                        * Mover al £ltimo canal activo
                                        cur_area = M->i

                                ENDIF

                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 18 .OR. M->keystroke = 5
                        * ReP g o flecha arriba

                        IF M->page > 1
                                * Subir
                                page = M->page - 1
                                set_deflt()

                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 3 .OR. M->keystroke = 24
                        * AvP g o flecha abajo

                        IF M->page < 3 .AND. .NOT. EMPTY(M->cur_dbf)
                                * Bajar
                                page = M->page + 1
                                set_deflt()

                                * Ajusta fila y elemento para un movimiento suave del cursor
                                &el[M->page] = &el[M->page] -;
                                                           (&cur_row[M->page] - row_a[M->page])
                                &cur_row[M->page] = row_a[M->page]

                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 22 .OR. M->keystroke = 13 .OR.;
                         isdata(M->keystroke) .OR. (M->local_func = 2 .AND.;
                         (M->local_sel = 1 .OR. M->local_sel = 2)) .OR.;
                         (M->local_func = 8 .AND. M->local_sel = 3)
                        * Inserta o introduce ¡tem de men£ local

                        IF M->local_func <> 0
                                * Item de men£ local..establece p gina en selecci¢n de men£
                                page = M->local_sel
                                set_deflt()

                                * Selecci¢n de men£ se comporta como insertar
                                keystroke = 22

                        ENDIF

                        IF M->page = 1 .AND. M->n_files < 14
                                * Abre un fichero de datos
                                is_redraw = M->cur_area < 6 .AND. (M->keystroke = 22 .OR.;
                                                                                                  EMPTY(M->cur_dbf))

                                is_insert = (M->keystroke = 22 .AND.;
                                                        .NOT. EMPTY(M->cur_dbf) .AND. M->cur_area < 6)

                                IF M->is_redraw
                                        * Abre un canal temporal en pantalla
                                        draw_view(M->cur_area)

                                        * Temporal para temporal
                                        SetColor(M->color2)
                                        @ row_a[1], column[M->cur_area] + 2 SAY SPACE(8)
                                        SetColor(M->color1)

                                ELSE
                                        * Resalta el ¡tem
                                        hi_cur()

                                ENDIF

                                * Llama a la funci¢n abrir y guarda y retorna el estado
                                ch_draw = open_dbf(M->is_insert, .F.)

                                IF M->ch_draw
                                        * Actualiza pantalla con funci¢n "canal"
                                        channel(&ntx, &field_n, &el, &cur_row,;
                                                        M->cur_area, M->cur_area)

                                        * Nuevo fichero de datos activo
                                        cur_dbf = dbf[M->cur_area]

                                ELSE
                                        * Restaura la pantalla

                                        IF M->is_redraw
                                                * Anula el temporal
                                                draw_view(0)

                                        ELSE
                                                * Elimina resalte
                                                dehi_cur()

                                        ENDIF
                                ENDIF

                        ELSE

                                IF M->page > 1
                                        * P ginas 2 y 3 controladas por funci¢n channel
                                        channel(&ntx, &field_n, &el, &cur_row,;
                                                        M->cur_area, M->cur_area)

                                ELSE
                                        error_msg("Demasiados ficheros abiertos")

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 7
                        * Borrar

                        IF M->page = 1 .AND. .NOT. EMPTY(M->cur_dbf)
                                * Cierra esta  rea y desplaza hacia abajo las siguientes
                                stat_msg("Cerrando el fichero")
                                clear_dbf(M->cur_area, 2)

                                IF M->cur_area = 6
                                        * No es necesario redibujar ventana..Se borra
                                        ch_draw = .T.
                                        channel(&ntx, &field_n, &el, &cur_row,;
                                                        M->cur_area, M->cur_area)

                                ELSE
                                        * Redibujar ventana
                                        draw_view(0)

                                ENDIF

                                * Nuevo fichero de datos activo
                                cur_dbf = dbf[M->cur_area]

                                * Borrar mensaje de estado
                                stat_msg("")

                        ELSE

                                IF M->page > 1
                                        * P ginas 2 y 3 controladas por la funci¢n channel
                                        channel(&ntx, &field_n, &el, &cur_row,;
                                                        M->cur_area, M->cur_area)

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->local_func = 8 .AND. M->local_sel = 1
                        * "set_relation" seleccionado del men£
                        set_relation()
                        keystroke = 0

                CASE M->local_func = 8 .AND. M->local_sel = 2
                        * "set filter" seleccionado del men£
                        get_filter()
                        keystroke = 0

                CASE M->local_func = 2 .AND. M->local_sel = 3
                        * "Restaurar Vista del fichero .VEW" seleccionado del men£
                        set_from(.T.)

                        IF .NOT. EMPTY(M->view_file) .AND. M->keystroke = 13
                                * Establecer Vista..reescribir pantalla
                                cur_area = 0
                                cur_dbf = ""

                        ENDIF

                        keystroke = 0

                CASE M->local_func = 4
                        * "Grabar Vista" seleccionado del men£
                        save_view()
                        keystroke = 0

                CASE M->local_func = 1
                        * "Ayuda" seleccionado del men£
                        DO syshelp
                        keystroke = 0

                OTHERWISE
                        * Todos los casos anteriores han sido procesados

                        DO CASE

                                CASE M->page = 1
                                        * Leer pulsaci¢n, si est  pendiente

                                        IF .NOT. key_ready()
                                                * No hay teclas pendientes..Resaltar ¡tem actual
                                                hi_cur()

                                                * Esperar pulsaci¢n
                                                read_key()

                                                * Reescribir ¡tem actual como normal
                                                dehi_cur()

                                        ENDIF

                                CASE M->page = 2
                                        * Copiar nombres de fichero ¡ndice a matriz "s¢lo nombres"
                                        d_copy(&ntx)

                                        * Ejecutar selecci¢n de men£s en la Vista principal
                                        bar_menu(column[M->cur_area] + 2,;
                                                         column[M->cur_area] + 9, M->d_array)

                                CASE M->page = 3
                                        * Ejecutar selecci¢n de men£ en la Vista principal
                                        bar_menu(column[M->cur_area] + 1,;
                                                         column[M->cur_area] + 10, &field_n)

                        ENDCASE

                        IF M->keystroke = 27

                                IF rsvp("¨Salir de la aplicaci¢n? (S/N)") <> "S"
                                        keystroke = 0

                                ENDIF
                        ENDIF
        ENDCASE
ENDDO

IF M->sysfunc = 3 .AND. M->func_sel = 1 .AND. EMPTY(M->cur_dbf)
        * Indica crear estructura abriendo canal temporal
        draw_view(M->cur_area)

ENDIF

RETURN


******
*       channel()
*
*       Procesa un canal para "establecer vista"
*
*       Nota: Los identificadores de matriz asociados con el canal
*             activo se pasan a esta funci¢n para evitar la repetida
*             expansi¢n de macros inherente a construcciones como
*             &ntx[&el[]]
******
FUNCTION channel

PARAMETERS ch_ntx, ch_field_n, ch_el, ch_cur_row, n, dbf_num
local saveColor
PRIVATE f_n, is_ins, temp_buff, d_item

saveColor := SetColor(M->color1)

DO CASE

        CASE M->ch_draw
                * Actualizar la pantalla para canal "n"..Borrar ventanas
                scroll(row_a[2], column[M->n], row_x[2], column[M->n] + 11, 0)
                scroll(row_a[3], column[M->n], row_x[3], column[M->n] + 11, 0)

                * Mostrar nombre de fichero especificado "dbf_num"
                @ row_a[1],column[M->n] + 2 SAY pad(name(dbf[M->dbf_num]), 8)

                IF .NOT. EMPTY(ch_ntx[1])
                        * Lista ficheros ¡ndice, si existen
                        d_copy(M->ch_ntx)
                        list_array(row_a[2],column[M->n] + 2,row_x[2],column[M->n] + 9,;
                                           M->d_array,ch_el[2] - (ch_cur_row[2] - row_a[2]))

                ENDIF

                * Muestra lista de campos
                list_array(row_a[3], column[M->n] + 1, row_x[3], column[M->n] + 10,;
                                   M->ch_field_n, ch_el[3] - (ch_cur_row[3] - row_a[3]))

                ch_draw = .F.           && Reinicia el indicador de actualizaci¢n de pantalla

        CASE M->keystroke = 22 .OR. M->keystroke = 13 .OR. isdata(M->keystroke)
                * Insertar, introducir o tecla de car cter

                IF isdata(M->keystroke)
                        * Avanzar car cter al sistema GET
                        KEYBOARD CHR(M->keystroke)

                ENDIF

                * Recordar si se inserta
                is_ins = (M->keystroke = 22)

                DO CASE

                        CASE M->page = 2 .AND. (M->n_files < 14 .OR. (M->keystroke <> 22;
                                 .AND. .NOT. EMPTY(ch_ntx[ch_el[2]])))
                                * A¤ade o cambia un ¡ndice en la lista actual..Guarda ventana
                                temp_buff = SAVESCREEN(row_a[2], column[M->n] + 1,;
                                                                           row_x[2], column[M->n] + 11)

                                IF M->is_ins
                                        * Inserta

                                        IF ch_el[2] + row_x[2] - ch_cur_row[2] = afull(M->ch_ntx)
                                                * Ultimo fichero desaparece de la ventana
                                                @ row_x[2], column[M->n] + 11 SAY M->more_down

                                        ENDIF

                                        IF ch_cur_row[2] < row_x[2]
                                                * Abrir fila vac¡a..Desplazar abajo
                                                scroll(ch_cur_row[2], column[M->n] + 1,;
                                                                        row_x[2], column[M->n] + 10, -1)

                                        ENDIF

                                        * Mostrar entrada vac¡a
                                        d_item = SPACE(8)

                                ELSE
                                        * Mostrar el ¡tem de Vista
                                        d_item = pad(name(ch_ntx[ch_el[2]]), 8)

                                ENDIF

                                * Resaltar el ¡tem de Vista
                                SetColor(M->color2)
                                @ ch_cur_row[2],column[M->n] + 2 SAY M->d_item
                                SetColor(M->color1)

                                * Obtener selecci¢n
                                f_n = get_ntx(ch_cur_row[2], column[M->n] + 2,;
                                                          ch_ntx[ch_el[2]], M->is_ins)

                                IF .NOT. M->f_n == ch_ntx[ch_el[2]] .AND. .NOT. EMPTY(M->f_n)
                                        * Fichero ¡ndice a¤adido a la lista
                                        need_ntx = .T.

                                        IF M->is_ins
                                                * Espacio para un nuevo nombre de fichero ¡ndice
                                                array_ins(M->ch_ntx,ch_el[2])

                                        ENDIF

                                        * Asigna nombre a elemento de la matriz
                                        ch_ntx[ch_el[2]] = M->f_n

                                        IF ch_el[2] = 1
                                                * Indice controlador..Eliminar relaciones
                                                not_target(M->n, .T.)

                                        ENDIF

                                        * Muestra el nombre del nuevo fichero ¡ndice seleccionado
                                        @ ch_cur_row[2],column[M->n] + 2;
                                        SAY pad(name(ch_ntx[ch_el[2]]), 8)

                                ELSE
                                        * Entrada cancelada..Restaurar la ventana como estaba
                                        RESTSCREEN(row_a[2], column[M->n] + 1,;
                                                           row_x[2], column[M->n] + 11, M->temp_buff)

                                ENDIF

                        CASE M->page = 3
                                * A¤ade o cambia nombre de campo en lista actual..Guarda ventana
                                temp_buff = SAVESCREEN(row_a[3], column[M->n] + 1,;
                                                                           row_x[3], column[M->n] + 11)

                                IF M->is_ins
                                        * Insertar

                                        IF ch_el[3] + row_x[3] - ch_cur_row[3] = afull(M->ch_field_n)
                                                * Ultimo nombre de campo desaparece de la ventana
                                                @ row_x[3], column[M->n] + 11 SAY M->more_down

                                        ENDIF

                                        IF ch_cur_row[3] < row_x[3]
                                                * Abrir fila vac¡a..Desplazar abajo
                                                scroll(ch_cur_row[3], column[M->n] + 1,;
                                                                        row_x[3], column[M->n] + 10, -1)

                                        ENDIF

                                        * Mostrar entrada en blanco
                                        d_item = SPACE(10)

                                ELSE
                                        * Mostrar ¡tem de la Vista
                                        d_item = pad(ch_field_n[ch_el[3]], 10)

                                ENDIF

                                * Resaltar ¡tem de la Vista
                                SetColor(M->color2)
                                @ ch_cur_row[3],column[M->n] + 1 SAY M->d_item
                                SetColor(M->color1)

                                * Obtener selecci¢n
                                f_n = get_field(ch_cur_row[3], column[M->n] + 1, M->n,;
                                                                ch_field_n[ch_el[3]])

                                IF (M->is_ins .OR. .NOT. M->f_n == ch_field_n[ch_el[3]]);
                                   .AND. .NOT. EMPTY(M->f_n)
                                        * Nombre de campo a¤adido a la lista
                                        need_field = .T.

                                        IF M->is_ins
                                                * Espacio para el nuevo nombre de campo
                                                array_ins(M->ch_field_n,ch_el[3])

                                        ENDIF

                                        * Asigna nombre de campo al elemento de la matriz
                                        ch_field_n[ch_el[3]] = M->f_n

                                        * Muestra el nombre del nuevo campo seleccionado
                                        @ ch_cur_row[3],column[M->n] + 1;
                                        SAY pad(ch_field_n[ch_el[3]], 10)

                                ELSE
                                        * Entrada cancelada..Restaura ventana como estaba
                                        RESTSCREEN(row_a[3], column[M->n] + 1,;
                                                           row_x[3], column[M->n] + 11, M->temp_buff)

                                ENDIF
                ENDCASE

        CASE M->keystroke = 7
                * Borrar

                DO CASE

                        CASE M->page = 2 .AND. .NOT. EMPTY(ch_ntx[ch_el[2]])
                                * Eliminar fichero ¡ndice de la lista
                                need_ntx = .T. 

                                IF ch_el[2] = 1
                                        * Indice principal..Eliminar relaciones
                                        not_target(M->n, .T.)

                                ENDIF

                                * Seleccionar  rea n
                                SELECT (M->n)

                                * Se asegura que n_files no excede ficheros abiertos
                                CLOSE INDEX

                                * Elimina el fichero de la lista
                                array_del(M->ch_ntx,ch_el[2])

                                * Decrementa contador de ficheros global
                                n_files = M->n_files - 1

                                IF ch_cur_row[2] < row_x[2]
                                        * Desplazamiento arriba para eliminar fichero
                                        scroll(ch_cur_row[2],column[M->n] + 1,;
                                                                row_x[2],column[M->n] + 9,1)

                                ENDIF

                                * Borra la fila inferior de la ventana
                                @ row_x[2],column[M->n] + 2;
                                SAY pad(name(ch_ntx[ch_el[2] + row_x[2] - ch_cur_row[2]]), 8)

                                IF afull(M->ch_ntx) - ch_el[2] = row_x[2] - ch_cur_row[2]
                                        * Elimina el indicador de pantalla
                                        @ row_x[2],column[M->n] + 11 SAY " "

                                ENDIF

                        CASE M->page = 3 .AND. .NOT. EMPTY(ch_field_n[ch_el[3]])
                                * Borra un campo de la lista actual
                                need_field = .T.     

                                * Elimina el campo de la lista
                                array_del(M->ch_field_n,ch_el[3])

                                IF ch_cur_row[3] < row_x[3]
                                        * Desplazamiento arriba para eliminar el campo de pantalla
                                        scroll(ch_cur_row[3],column[M->n] + 1,;
                                                                row_x[3],column[M->n] + 10,1)

                                ENDIF

                                * Borra la fila inferior de la ventana
                                @ row_x[3],column[M->n] + 1;
                                SAY pad(ch_field_n[ch_el[3] + row_x[3] - ch_cur_row[3]], 10)

                                IF afull(M->ch_field_n) - ch_el[3] = row_x[3] - ch_cur_row[3]
                                        * Elimina el indicador de la pantalla
                                        @ row_x[3],column[M->n] + 11 SAY " "

                                ENDIF
                ENDCASE
ENDCASE

SetColor(saveColor)
RETURN 0


******
*       bar_menu()
*
*       Men£ de selecci¢n de barras para la pantalla Vista principal
*
*       Nota: Se espera que esta rutina devuelva un valor en "keystroke"
*             para ser procesado por "set_view"
******
FUNCTION bar_menu

PARAMETERS l, r, array
local saveColor
PRIVATE num_d, num_full, cur_el, rel_row, x, t, b

* Examina siguiente pulsaci¢n
keystroke = NEXTKEY()

IF CHR(M->keystroke) $ M->horiz_keys
        * Mejora rendimiento de movimiento de cursor horizontal con r pido retorno
        INKEY()         && Elimina car cter del buffer
        RETURN 0

ENDIF

t = row_a[M->page]
b = row_x[M->page]

* Obtiene el n£mero de elementos activos
num_full = afull(M->array)

* y el n£mero de elementos visualizable
num_d = M->num_full

IF M->num_d < LEN(M->array)
        * Se incluye primer elemento vac¡o
        num_d = M->num_d + 1

        * Achoice() no mostrar  una cadena vac¡a
        array[M->num_d] = " "

ENDIF

* Determina offset de columna para poner indicadores "more_up" y "more_down"
x = IF(M->r - M->l > 7, 1, 2)

* Todo es relativo a achoice()
rel_row = &cur_row[M->page] - M->t

* Descarta valor de retorno
saveColor := SetColor(M->color4)
achoice(M->t, M->l, M->b, M->r, M->array, .T.,;
                "bar_func", &el[M->page], M->rel_row)
SetColor(saveColor)

* Cambia de nuevo a absoluto
&cur_row[M->page] = M->rel_row + M->t

IF array[M->num_d] == " "
        * Elimina temporal
        array[M->num_d] = ""

ENDIF

* Comprueba petici¢n de men£
sysmenu()

RETURN 0


******
*       bar_func()
*
*       Funci¢n a llamar desde achoice() espec¡ficamente por bar_menu()
******
FUNCTION bar_func

PARAMETERS mode, bar_el, row
PRIVATE ret_code

* Obtener pulsaci¢n
keystroke = LASTKEY()

* Se asume continuar
ret_code = 2

* Mantenimiento variables anteriores
&el[M->page] = M->bar_el
rel_row = M->row

IF M->error_on
        * Borrar mensaje de error
        error_off()

ENDIF

DO CASE

        CASE M->mode = 0
                * Mantener indicadores "more_up" y "more_down" correctos
                @ M->t, M->r + M->x SAY IF(M->bar_el > M->row + 1, M->more_up, " ")
                @ M->b, M->r + M->x SAY IF(M->num_full >;
                                                                   (M->bar_el + M->b - M->t - M->row),;
                                                                M->more_down, " ")

        CASE M->mode = 1 .OR. M->mode = 2
                * El cursor intenta pasar el inicio o final de la lista
                ret_code = 0

        CASE M->mode = 3
                * Excepci¢n de teclado

                DO CASE

                        CASE CHR(M->keystroke) $ M->horiz_keys
                                * Tecla cursor horizontal
                                ret_code = 0

                        CASE M->keystroke = 27
                                * Cancelar selecci¢n
                                ret_code = 0

                        CASE M->keystroke = 13
                                * Sustituye un ¡tem de la Vista
                                ret_code = 1

                        CASE isdata(M->keystroke)
                                * Tecla de car cter...Entrarla
                                ret_code = 1

                        CASE M->keystroke = 22 .OR. M->keystroke = 7
                                * Ins, Supr
                                ret_code = 1

                        CASE menu_key() <> 0
                                * Petici¢n de men£
                                ret_code = 0

                ENDCASE

        CASE M->mode = 4
                * Nada seleccionable
                ret_code = 0

ENDCASE

RETURN M->ret_code


******
*       list_array()
*
*       Lista elementos de matriz verticalmente en la ventana
******
FUNCTION list_array

PARAMETERS t, l, b, r, array, top_el
local saveColor
PRIVATE bottom_el, num_full, x

saveColor := SetColor(M->color4)
IF .NOT. EMPTY(array[M->top_el])
        * Algo a listar..Calcular n£mero de £ltimo elemento en ventana
        bottom_el = M->top_el + M->b - M->t

        * Obtiene n£mero de elementos no vac¡os
        num_full = afull(M->array)

        * Determina offset de columnas de indicadores "more_up" y "more_down"
        x = IF(M->r - M->l > 7, 1, 2)

        IF M->top_el > 1 .AND. M->bottom_el = M->num_full + 1
                * Evita que achoice() haga ajustes
                array[M->bottom_el] = " "

        ENDIF

        * S¢lo muestra y retorna sin esperar una pulsaci¢n
        achoice(M->t, M->l, M->b, M->r, M->array, .F., "", M->top_el)
        SetColor(M->color1)

        * Actualiza estado de indicadores "more_up" y "more_down"
        @ M->t, M->r + M->x SAY IF(M->top_el > 1, M->more_up, " ")
        @ M->b, M->r + M->x SAY IF(M->bottom_el < M->num_full, M->more_down, " ")

        IF array[M->bottom_el] == " "
                * Restaura a cadena nula
                array[M->bottom_el] = ""

        ENDIF
ENDIF

SetColor(saveColor)
RETURN 0


******
*       set_deflt()
*
*       Establece valores por defecto para abrir y crear men£s desplegables
******
FUNCTION set_deflt

IF M->page = 2
        * Cursor en lista de ¡ndices..Defecto: abrir y crear ¡ndice
        STORE 2 TO menu_deflt[2], menu_deflt[3]

ELSE
        * Defecto: abrir y crear base de datos
        STORE 1 TO menu_deflt[2], menu_deflt[3]

ENDIF

RETURN 0


******
*       bline()
*
*       Crea una nueva l¡nea de barra para la Vista
******
FUNCTION bline

PARAMETERS num_slots
PRIVATE i, k

IF num_slots < 6
        * A¤ade una columna vac¡a
        num_slots = num_slots + 1

ENDIF

* La primera columna es diferente al resto
bar_line = "ÍÍÍÍÍÍÍÍÍÍÍÍ"
empty_line = ""

k = 1

DO WHILE M->k < M->num_slots
        * Cada columna se separa de la anterior con una l¡nea vertical
        bar_line = M->bar_line + "ÑÍÍÍÍÍÍÍÍÍÍÍÍ"
        empty_line = M->empty_line + SPACE(12) + "³"

        * Siguiente
        k = M->k + 1

ENDDO

* Calcula valor para centrar toda la Vista
i = INT((80 - LEN(M->bar_line)) / 2)

FOR k = 1 TO M->num_slots
        * Establece el n£mero de columnas de pantalla
        column[M->k] = M->i + (13 * (M->k - 1))

NEXT

RETURN 0


******
*       draw_view()
*
*       Rellena la Vista principal
*
*       Nota: El par metro indica el canal temporal para las
*             operaciones en ejecuci¢n. Cero para no temporal.
******
FUNCTION draw_view

PARAMETERS blank_area
PRIVATE i, j, ntx, field_n, el, cur_row, strnum

* Obtiene n£mero de  reas activas
i = afull(M->dbf)

IF M->i < 6 .AND. blank_area <> 0
        * A¤ade uno para temporal
        i = M->i + 1

ENDIF

* Crea las cadenas bar_line y empty_line
bline(M->i)

* Borra y dibuja una plantilla en blanco
@ 4,0 CLEAR

* P gina 1..Nombres de ficheros de datos
@ row_a[1] - 2, 36 SAY "Ficheros"
@ row_a[1] - 1,column[1] SAY M->bar_line
@ row_a[1],column[1] SAY M->empty_line

* P gina 2..Nombres de ficheros ¡ndice
@ row_a[2] - 2,36 SAY "Indices"
@ row_a[2] - 1,column[1] SAY M->bar_line
@ row_a[2],column[1] SAY M->empty_line
@ row_a[2] + 1,column[1] SAY M->empty_line
@ row_a[2] + 2,column[1] SAY M->empty_line

* P gina 3..Listas de campos activos
@ row_a[3] - 2,37 SAY "Campos"
@ row_a[3] - 1,column[1] SAY M->bar_line

FOR i = row_a[3] TO row_x[3]
        * Completa la plantilla en blanco
        @ M->i,column[1] SAY M->empty_line

NEXT

i = 1
j = 1

DO WHILE M->j <= 6

        IF EMPTY(dbf[M->i])
                * No hay m s  reas activas
                EXIT

        ENDIF

        IF M->j <> M->blank_area
                * El canal necesita llenarse
                strnum = SUBSTR("123456", M->i, 1)

                * Establece canal "i"
                ntx = "ntx" + strnum
                field_n = "field_n" + strnum
      el = "_el" + strnum
      cur_row = "_cr" + strnum

                * Llena el canal
                ch_draw = .T.
                channel(&ntx, &field_n, &el, &cur_row, M->j, M->i)

                * Siguiente canal actual
                i = M->i + 1

        ENDIF

        * Siguiente canal
        j = M->j + 1

ENDDO

RETURN 0


******
*       d_copy()
*
*       Crea una matriz con s¢lo nombres de fichero (sin v¡as ni extensiones)
******
FUNCTION d_copy

PARAMETERS array
PRIVATE i

* Vac¡a la matriz dedicada
afill(M->d_array, "")

i = 1

DO WHILE M->i <= LEN(M->array)

        IF EMPTY(array[M->i])
                * Fin de la lista activa
                EXIT

        ENDIF

        * Asigna el nombre extra¡do
        d_array[M->i] = name(array[M->i])

        * Siguiente
        i = M->i + 1

ENDDO

RETURN 0


******
*       open_dbf()
*
*       Abre fichero de datos en el  rea especificada
******
FUNCTION open_dbf

PARAMETERS is_insert, not_view
PRIVATE shift, filename, a_temp, f_row, d_col, ret_val, old_help

IF M->n_files >= 14
        error_msg("Demasiados ficheros abiertos")
        RETURN .F.

ENDIF

* Guarda antiguos c¢digos de ayuda y establece los nuevos
old_help = M->help_code
help_code = 6

* Inicializa variables privadas
filename = ""

* Coordenadas nombres de fichero en la Vista
f_row = _cr1[1]
d_col = column[M->cur_area] + 2

* shift = 1 para inserci¢n
shift = IF(M->is_insert, 1, 0)

* Selecciona el  rea activa
SELECT (M->cur_area)

IF M->not_view
        * No se llama desde "set_view"
        filename = M->cur_dbf
        ret_val = do_opendbf()

ELSE
        * Se asume fichero no abierto
        ret_val = .F.

        IF isdata(M->keystroke)
                * Avanza el car cter al sistema GET
                KEYBOARD CHR(M->keystroke)

                filename = enter_rc(dbf[M->cur_area],M->f_row,M->d_col,64,"@K!S8",;
                                                        M->color1)

                IF .NOT. EMPTY(M->filename)
                        * Algo se ha introducido

                        IF .NOT. (RAT(".", M->filename) > RAT("\", M->filename))
                                * No se ha indicado extensi¢n..Se indica por defecto
                                filename = M->filename + ".DBF"

                        ENDIF

                        * Intenta abrir fichero
                        ret_val = do_opendbf()

                        IF .NOT. M->ret_val
                                * Fallo..Restaurar la pantalla
                                @ M->f_row, M->d_col SAY pad(name(M->cur_dbf), 8)

                        ENDIF

                ELSE
                        * Entrada cancelada..Restaurar pantalla
                        @ M->f_row, M->d_col SAY pad(name(M->cur_dbf), 8)

                ENDIF

                IF menu_key() <> 0
                        * Introducir tecla de men£ para "set_view"
                        KEYBOARD CHR(M->keystroke)

                ELSE
                        * Evitar confusiones
                        keystroke = 0

                ENDIF

        ELSE
                * Insertar, introducir o selecci¢n de men£..Usar filebox
                ret_val = filebox(".DBF", "dbf_list", "dopen_titl",;
                                                  "do_opendbf", .F., 8) <> 0

        ENDIF
ENDIF

IF M->ret_val
        * Matrices de campos por defecto a todos los campos
        a_temp = "field_n" + SUBSTR("123456", M->cur_area, 1)
   all_fields(M->cur_area, &a_temp)

        * Reinicia fila actual para ¡ndices y campos
   a_temp = "_cr" + SUBSTR("123456", M->cur_area, 1)
   &a_temp[2] = row_a[2]
   &a_temp[3] = row_a[3]

        * Reinicia elementos actuales
   a_temp = "_el" + SUBSTR("123456", M->cur_area, 1)
   afill(&a_temp, 1)

ENDIF

* Restaura c¢digo de ayuda
help_code = M->old_help

RETURN M->ret_val


******
*       dopen_titl()
*
*       Muestra t¡tulo para fichero de datos a abrir
******
FUNCTION dopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Abrir el fichero de datos...")


******
*       do_opendbf()
*
*       Configura y abre un fichero de datos
******
FUNCTION do_opendbf

PRIVATE done

DO CASE

        CASE EMPTY(M->filename)
                error_msg("No se ha seleccionado ning£n fichero de datos")
                done = .F.

        CASE .NOT. FILE(M->filename)
                error_msg("No se puede abrir el fichero " + M->filename)
                done = .F.

        CASE aseek(M->dbf, M->filename) > 0 .AND.;
                 .NOT. (dbf[M->cur_area] == M->filename .AND. M->shift = 0)
                error_msg("El fichero de datos est  abierto en otra  rea")
                done = .F.

        OTHERWISE
                stat_msg("Abriendo el fichero")

                IF .NOT. EMPTY(dbf[M->cur_area])
                        * Borra el  rea activa
                        clear_dbf(M->cur_area, M->shift)

                ENDIF

                * Abre el fichero en el  rea actual
                SELECT (M->cur_area)

      IF NetUse( filename )

         * Ajusta variable global
         n_files = M->n_files + 1

         * Asigna el nombre de fichero a la matriz global
         dbf[M->cur_area] = M->filename

         done = .T.

      ELSE
         
         done := .F.

      ENDIF

      * Borra el mensaje
      stat_msg("")

ENDCASE

RETURN M->done


******
*       get_ntx()
*
*       Selecciona ficheros ¡ndice para el  rea actual
******
FUNCTION get_ntx

PARAMETERS d_row, d_col, org_file, is_ins
PRIVATE filename, old_help

IF M->n_files >= 14
        error_msg("Demasiados ficheros abiertos")
        RETURN ""

ENDIF

* Guarda anteriores c¢digos de ayuda y establece los nuevos
old_help = M->help_code
help_code = 8

* Inicializa variable privada
filename = ""

IF isdata(M->keystroke)
        * Proporciona tecla al sistema GET
        KEYBOARD CHR(M->keystroke)

        filename = enter_rc(M->org_file,M->d_row,M->d_col,64,"@K!S8",M->color1)

        IF .NOT. EMPTY(M->filename)
                * Algo introducido

                IF .NOT. (RAT(".", M->filename) > RAT("\", M->filename))
                        * No se ha indicado extensi¢n..Indicarla por defecto
                        filename = filename + INDEXEXT()

                ENDIF

                IF .NOT. do_openntx()
                        * Fallo..Retorna cadena vac¡a
                        filename = ""

                ENDIF
        ENDIF

        IF menu_key() <> 0
                * Proporciona petici¢n de men£ a "set_view"
                KEYBOARD CHR(M->keystroke)

        ELSE
                * Evita confusiones
                keystroke = 0

        ENDIF

ELSE

        IF filebox(INDEXEXT(),"ntx_list","xopen_titl","do_openntx",.F.,13) = 0
                * Ninguna selecci¢n..Retorna cadena vac¡a
                filename = ""

        ENDIF
ENDIF

* Restaura c¢digo de ayuda
help_code = M->old_help

RETURN M->filename


******
*       xopen_titl()
*
*       Muestra t¡tulo para fichero ¡ndice a abrir
******
FUNCTION xopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Abrir fichero ¡ndice...")


******
*       do_openntx()
*
*       Verifica si un fichero ¡ndice es seleccionable
******
FUNCTION do_openntx

PRIVATE done

DO CASE

        CASE EMPTY(M->filename)
                error_msg("No se ha seleccionado ning£n fichero ¡ndice")
                done = .F.

        CASE .NOT. FILE(M->filename)
                error_msg("No se puede abrir el fichero " + M->filename)
                done = .F.

        CASE dup_ntx(M->filename) <> 0 .AND.;
                 (M->is_ins .OR. .NOT. M->filename == M->org_file)
                error_msg("Este fichero ¡ndice ya est  abierto")
                done = .F.

        OTHERWISE
                * Fichero puede ser seleccionado

                IF EMPTY(M->org_file) .OR. M->is_ins
                        * Ajuste variable global
                        n_files = M->n_files + 1

                ENDIF

                done = .T.

ENDCASE

RETURN M->done


******
*       get_field()
*
*       A¤ade un campo a una lista de campos individuales
******
FUNCTION get_field

PARAMETERS f_row, d_col, work_area, org_field
PRIVATE field_mvar, rel_row, cur_el, okee_dokee, fi_disp, old_help

* Guarda los anteriores c¢digos de ayuda y establece los nuevos
old_help = M->help_code
help_code = 2

* Inicializa variable que contiene nombre de campo
field_mvar = ""

* Selecciona el  rea especificada
SELECT (M->work_area)

* Lista maestra de campos a matriz local para selecci¢n
DECLARE field_m[FCOUNT()]
all_fields(M->work_area, M->field_m)

IF isdata(M->keystroke)
        * Proporciona la pulsaci¢n para el GET
        KEYBOARD CHR(M->keystroke)

        field_mvar = enter_rc(M->org_field,M->f_row,M->d_col,10,"@K!",M->color1)

        IF .NOT. EMPTY(M->field_mvar)
                * Algo introducido

                IF .NOT. do_fsel()
                        * Fallo..Retorna cadena vac¡a
                        field_mvar = ""

                ENDIF

        ENDIF

        IF menu_key() <> 0
                * Proporciona petici¢n de men£ a "set_view"
                KEYBOARD CHR(M->keystroke)

        ELSE
                * Evita confusiones
                keystroke = 0

        ENDIF

ELSE
        * Establece matrices para multibox
        DECLARE boxarray[5]

        boxarray[1] = "fsel_title(sysparam)"
        boxarray[2] = "getfield(sysparam)"
        boxarray[3] = "ok_button(sysparam)"
        boxarray[4] = "can_button(sysparam)"
        boxarray[5] = "fieldlist(sysparam)"

        * Inicializa variables privadas
        cur_el = 1
        rel_row = 0

        * donde la acci¢n es
        okee_dokee = "do_fsel()"
        fi_disp = "getfield(3)"

        IF multibox(7, 17, 5, 5, M->boxarray) = 0
                * Fallo o cancelado..Retorna cadena vac¡a
                field_mvar = ""

        ENDIF
ENDIF

* Restaura c¢digo de ayuda
help_code = M->old_help

RETURN M->field_mvar


******
*       getfield()
*
*       Procesa nombre de campo en blanco (llamado por multibox)
******
FUNCTION getfield

PARAMETERS sysparam

RETURN genfield(M->sysparam, .F.)


******
*       fsel_title()
*
*       Muestra t¡tulo para selecci¢n de campo
******
FUNCTION fsel_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Seleccionar el campo...")


******
*       do_fsel()
*
*       Valida selecci¢n de campo
******
FUNCTION do_fsel

PRIVATE done

DO CASE

        CASE EMPTY(M->field_mvar)
                error_msg("No se ha seleccionado el nombre del campo")
                done = .F.

        CASE aseek(M->field_m, M->field_mvar) = 0
                error_msg("El campo " + M->field_mvar + " no existe")
                done = .F.

        OTHERWISE
                * Campo existe..Ning£n problema
                done = .T.

ENDCASE

RETURN M->done


******
*       set_relation()
*
*       Interfaz para editar la lista de relaciones
*
*       Nota: La ventana de relaciones puede mostrar un
*             m ximo de seis (6) relaciones a la vez
******
FUNCTION set_relation
local saveColor
PRIVATE c_row, c_el, rel_buff, pos_r, width, old_help, k, n_area, ls, lk, lt,;
                cNorm, cHilite

cNorm := color7
cHilite:= color2
saveColor := SetColor(M->cNorm)

* Guardar antiguos c¢digos de ayuda y establecer los nuevos
old_help = M->help_code
help_code = 9

* Evitar ciertas selecciones de men£ con mecanismo multibox
box_open = .T.

IF EMPTY(M->bar_line)
        * Se necesita barra para referencia vertical
        bline(afull(M->dbf))

ENDIF

* Ventana tiene ancho variable
width = LEN(M->bar_line) - 1

* Establece referencia a la columna derecha
pos_r = column[1] + M->width

* Guarda la ventana
rel_buff = SAVESCREEN(8, column[1] - 1, 23, M->pos_r + 1)

* Borra y recuadra la ventana
scroll(8, column[1] - 1, 23, M->pos_r + 1, 0)
@ 8, column[1] - 1, 23, M->pos_r + 1 BOX M->frame

* Muestra la l¡nea de cabecera y barras
@ 9,35 SAY "Relaciones"
@ 10,column[1] SAY M->bar_line

* Inicializa fila y elemento actual
c_row = 11
c_el = 1

* Llena ventana inicial
draw_relat(1)

* Valor tecla global..Cero es adecuado para saltar a "otherwise"
keystroke = 0

DO WHILE .NOT. q_check()
        * Gran selecci¢n..Salida condici¢n determinada en cualquier punto

        DO CASE

                CASE M->keystroke = 18
                        * ReP g

                        IF M->c_el > ((M->c_row - 11) / 2) + 1
                                * Elementos fuera..subir una p gina
                                c_el = M->c_el - 5

                                IF M->c_el < ((M->c_row - 11) / 2) + 1
                                        * Elemento m¡nimo para esta fila
                                        c_el = ((M->c_row - 11) / 2) + 1

                                ENDIF

                                * Reescribir ventana relaciones
                                draw_relat(M->c_el - ((M->c_row - 11) / 2))

                        ELSE
                                * Primer elemento en pantalla

                                IF M->c_el > 1
                                        * Al inicio de la lista
                                        c_el = 1
                                        c_row = 11

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 3
                        * AvP g..Determina m ximos elementos de cursor disponibles
                        k = afull(M->k_relate)

                        IF M->k < LEN(M->k_relate)
                                * Se permite primer elemento vac¡o
                                k = M->k + 1

                        ENDIF

                        IF M->c_el < M->k - ((21 - M->c_row) / 2)
                                * Elemento fuera de pantalla..Abajo una p gina
                                c_el = M->c_el + 5

                                IF M->c_el > M->k - ((21 - M->c_row) / 2)
                                        * Elemento m ximo para esta fila
                                        c_el = M->k - ((21 - M->c_row) / 2)

                                ENDIF

                                * Reescribir ventana de relaciones
                                draw_relat(M->c_el - ((M->c_row - 11) / 2))

                        ELSE
                                * Ultimo elemento disponible est  en pantalla

                                IF M->c_el < M->k
                                        * Mover al final de la lista
                                        c_row = M->c_row + ((M->k - M->c_el) * 2)
                                        c_el = M->k

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 22 .OR. isdata(M->keystroke)
                        * Insertar o tecla de car cter..Insertar relaci¢n

                        * k = n£mero de primera relaci¢n fuera de pantalla
                        k = M->c_el + ((21 - M->c_row) / 2 ) + 1

                        * Guarda la £ltima relaci¢n
                        ls = s_relate[LEN(M->s_relate)]
                        lk = k_relate[LEN(M->k_relate)]
                        lt = t_relate[LEN(M->t_relate)]

                        * Ejecuta insertar..Asume que se entrar  relaci¢n
                        array_ins(M->s_relate, M->c_el)
                        array_ins(M->k_relate, M->c_el)
                        array_ins(M->t_relate, M->c_el)

                        IF M->c_row < 21
                                * Crea espacio en pantalla..Baja 2 l¡neas
                                scroll(M->c_row, column[1], 22, M->pos_r - 1, -2)

                        ELSE
                                * Borra la £ltima fila
                                @ M->c_row + 1,column[1] SAY SPACE(M->width)

                        ENDIF

                        IF M->k <= LEN(M->k_relate)
                                * k est  en el rango

                                IF .NOT. EMPTY(k_relate[M->k])
                                        * Elemento fuera de pantalla est  activo
                                        @ 22, M->pos_r SAY M->more_down

                                ENDIF
                        ENDIF

                        * Acepta entrada de nueva relaci¢n
                        get_relation(M->c_row, M->c_el)

                        IF .NOT. EMPTY(k_relate[M->c_el])
                                * Relaci¢n se ha introducido..Mostrarla
                                disp_relation(M->c_row, M->c_el, color7)

                        ELSE
                                * Relaci¢n no entrada..Imposible borrar cadena vac¡a
                                STORE "x" TO s_relate[M->c_el],;
                                                         k_relate[M->c_el], t_relate[M->c_el]

                                * Restaurar matrices
                                array_del(M->s_relate, M->c_el)
                                array_del(M->k_relate, M->c_el)
                                array_del(M->t_relate, M->c_el)

                                * Restaurar £ltima relaci¢n
                                s_relate[LEN(M->s_relate)] = M->ls
                                k_relate[LEN(M->k_relate)] = M->lk
                                t_relate[LEN(M->t_relate)] = M->lt

                                IF M->c_row < 21
                                        * Cierra el hueco en pantalla..Sube 2 l¡neas
                                        scroll(M->c_row, column[1], 22, M->pos_r - 1, 2)

                                ELSE
                                        * Borra relaci¢n suprimida de pantalla
                                        @ 21,column[1] SAY SPACE(M->width)
                                        @ 22,column[1] SAY SPACE(M->width)

                                ENDIF

                                * Llena la £ltima relaci¢n en pantalla
                                disp_relation(21,M->c_el+((21-M->c_row)/2),color7)

                        ENDIF

                        IF M->k <= LEN(M->k_relate)
                                * k est  en el rango

                                IF EMPTY(k_relate[M->k])
                                        * Elemento fuera de pantalla no activo
                                        @ 22, M->pos_r SAY " "

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 13
                        * Tecla Intro..Cambiar una relaci¢n
                        get_relation(M->c_row, M->c_el)

                        * Mostrar el cambio
                        disp_relation(M->c_row, M->c_el, color7)

                        keystroke = 0

                CASE M->keystroke = 7 .AND. .NOT. EMPTY(k_relate[M->c_el])
                        * Eliminar una relaci¢n de la lista
                        need_relat = .T.

                        * Selecciona el  rea origen
                        n_area = ASC(s_relate[M->c_el]) - ASC("A") + 1
                        SELECT (M->n_area)

                        * Desactiva relaciones de este  rea
                        SET RELATION TO

                        * Elimina la relaci¢n de la lista
                        array_del(M->s_relate, M->c_el)
                        array_del(M->k_relate, M->c_el)
                        array_del(M->t_relate, M->c_el)

                        IF M->c_row < 21
                                * Cierra el hueco en pantalla
                                scroll(M->c_row, column[1], 22, M->pos_r - 1, 2)

                        ELSE
                                * Ultima fila borra la relaci¢n suprimida de pantalla
                                @ 21,column[1] SAY SPACE(M->width)
                                @ 22,column[1] SAY SPACE(M->width)

                        ENDIF

                        * Llena la £ltima relaci¢n en pantalla
                        disp_relation(21, M->c_el + ((21 - M->c_row) / 2), color7)

                        IF M->c_el < LEN(M->k_relate) - ((21 - M->c_row) / 2)
                                * Elemento fuera de pantalla est  en el rango

                                IF EMPTY(k_relate[M->c_el + ((21 - M->c_row) / 2) + 1])
                                        * Elimina indicador "more_down" de pantalla
                                        @ 22, M->pos_r SAY " "

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 5 .AND. M->c_el > 1
                        * Flecha arriba..Asciende un elemento
                        c_el = M->c_el - 1

                        IF M->c_row > 11
                                * Espacio para mover hacia arriba la pantalla
                                c_row = M->c_row - 2

                        ELSE
                                * Baja toda la ventana 2 l¡neas
                                scroll(11, column[1], 22, M->pos_r - 1, -2)

                                * Llena la fila superior
                                disp_relation(11, M->c_el, color7)

                                IF M->c_el <= LEN(M->k_relate) - 6
                                        * Elemento fuera de pantalla en el rango

                                        IF .NOT. EMPTY(k_relate[M->c_el + 6])
                                                * Elemento fuera de pantalla es activo
                                                @ 22, M->pos_r SAY M->more_down

                                        ENDIF
                                ENDIF

                                IF M->c_el = 1
                                        * Primer elemento en pantalla..No "more_up"
                                        @ 11,M->pos_r SAY " "

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->keystroke = 24 .AND. .NOT.;
                         (EMPTY(k_relate[M->c_el]) .OR. M->c_el = LEN(M->k_relate))
                        * Flecha abajo..Descender un elemento
                        c_el = M->c_el + 1

                        IF c_row < 22 - 2
                                * Espacio para bajar en pantalla
                                c_row = M->c_row + 2

                        ELSE
                                * Sube toda la ventana 2 l¡neas
                                scroll(11, column[1], 22, M->pos_r - 1, 2)

                                @ 11,M->pos_r SAY M->more_up

                                IF .NOT. EMPTY(k_relate[M->c_el])
                                        * Llena la £ltima fila
                                        disp_relation(21, M->c_el, color7)

                                ENDIF

                                IF M->c_el < LEN(M->k_relate)
                                        * Elemento fuera de pantalla en el rango

                                        IF EMPTY(k_relate[M->c_el + 1])
                                                * Borra indicador "more_down" de pantalla
                                                @ 22,M->pos_r SAY " "

                                        ENDIF

                                ELSE
                                        * No hay elementos fuera de pantalla..Borra "more_down"
                                        @ 22,M->pos_r SAY " "

                                ENDIF
                        ENDIF

                        keystroke = 0

                CASE M->local_func = 1
                        * "Ayuda" seleccionado del men£
                        DO syshelp
                        keystroke = 0

                OTHERWISE
                        * Obtiene pulsaci¢n

                        IF .NOT. key_ready()
                                * Nada pendiente..Resalta ¡tem actual
                                disp_relation(M->c_row, M->c_el, cHilite)

                                * Indica si elemento est  vac¡o
                                SetColor(M->cHilite)
                                @ M->c_row,column[1] + 2;
                                SAY IF(EMPTY(k_relate[M->c_el]), " ", "")
                                SetColor(M->cNorm)

                                * Espera pulsaci¢n
                                read_key()

                                * Reescribe ¡tem actual como normal
                                disp_relation(M->c_row, M->c_el, cNorm)

                                @ M->c_row, column[1] + 2 SAY ""

                        ENDIF
        ENDCASE
ENDDO

* Restaura la ventana
RESTSCREEN(8, column[1] - 1, 23, M->pos_r + 1, M->rel_buff)

* Restaura c¢digo de ayuda
help_code = M->old_help

* Restaura acceso a opciones de men£
box_open = .F.

* Evita confusiones
keystroke = 0
SetColor(saveColor)
RETURN 0


******
*       draw_relat()
*
*       Llena la ventana de relaciones
******
FUNCTION draw_relat

PARAMETERS start_el
PRIVATE i

* Borra la ventana
scroll(11, column[1], 22, M->pos_r, 0)

i = 0

DO WHILE M->i < 6 .AND. M->start_el + M->i <= LEN(M->k_relate)

        IF EMPTY(k_relate[M->start_el + M->i])
                * Fin de lista activa
                EXIT

        ENDIF

        * Muestra una relaci¢n
        disp_relation(11 + (2 * M->i), M->start_el + M->i, color7)

        * Siguiente
        i = M->i + 1

ENDDO

IF M->start_el > 1
        * Indica elementos activos sobre la ventana
        @ 11, M->pos_r SAY M->more_up

ENDIF

IF M->start_el + M->i <= LEN(M->k_relate)
        * Elemento fuera de pantalla en el rango

        IF .NOT. EMPTY(k_relate[M->start_el + M->i])
                * Indica elementos activos bajo la ventana
                @ 22, M->pos_r SAY M->more_down

        ENDIF
ENDIF

RETURN 0


******
*       get_relation()
*
*       Acepta entrada de una relaci¢n
*
*       Nota: Una tecla de c racter puede usarse para seleccionar
*             un fichero cuyo nombre empieza con esa letra
******
FUNCTION get_relation

PARAMETERS row_n, element

PRIVATE stroke, k_input, k_trim, s_alias, t_alias, i, j, q, pos_c,;
                ntx_expr, k_type, ok

IF isdata(M->keystroke)
        * Tecla de car cter..Busca ficheros coincidentes
        i = c_search(UPPER(CHR(M->keystroke)), M->dbf, 0, afull(M->dbf))

        IF SUBSTR(dbf[M->i],1,1) = UPPER(CHR(M->keystroke))
                * Encontrado..Lo selecciona como fichero fuente
                KEYBOARD CHR(13)

        ENDIF

ELSE

        IF EMPTY(k_relate[M->element])
                * Empezar por el principio
                i = 1

        ELSE
                * Relaci¢n existe..Empezar con fichero fuente
                i = ASC(s_relate[M->element]) - ASC("A") + 1

        ENDIF
ENDIF

j = 0
stroke = 0

DO WHILE .NOT. (M->j > 0 .AND. M->stroke = 13)
        * hasta que ficheros fuente y destino se seleccionen

        DO CASE

                CASE M->stroke = 13
                        * Tecla Intro..Selecciona fuente

                        IF M->i < 6
                                * S¢lo selecciona si otro fichero se abre a la derecha

                                IF .NOT. EMPTY(dbf[M->i + 1])

                                        IF .NOT. EMPTY(k_relate[M->element])
                                                * Asume mismo destino para relaci¢n existente
                                                j = ASC(t_relate[M->element]) - ASC("A") + 1

                                        ENDIF

                                        IF M->j <= M->i
                                                * Destino debe estar a la derecha de origen
                                                j = M->i + 1

                                        ENDIF
                                ENDIF
                        ENDIF

                        stroke = 0

                CASE M->stroke = 4
                        * Flecha derecha

                        IF M->j = 0 .AND. M->i < 6
                                * Origen no seleccionado..Cambie origen

                                IF .NOT. EMPTY(dbf[M->i + 1])
                                        * S¢lo ficheros abiertos son seleccionables
                                        i = M->i + 1

                                ENDIF

                        ELSE

                                IF M->j > 0 .AND. M->j < 6
                                        * Origen seleccionado..Cambia destino

                                        IF .NOT. EMPTY(dbf[M->j + 1])
                                                * S¢lo ficheros abiertos son seleccionables
                                                j = M->j + 1

                                        ENDIF
                                ENDIF
                        ENDIF

                        stroke = 0

                CASE M->stroke = 19
                        * Flecha izquierda

                        IF M->j = 0 .AND. M->i > 1
                                * Origen no seleccionado..Cambia origen
                                i = M->i - 1

                        ELSE

                                IF M->j > 0
                                        * Origen seleccionado..Cambia destino
                                        j = M->j - 1

                                        IF M->j = M->i
                                                * Destino debe estar a la derecha
                                                j = 0  

                                        ENDIF
                                ENDIF
                        ENDIF

                        stroke = 0

                CASE isdata(M->stroke)
                        * Tecla car cter..B£squeda car cter
                        q = c_search(UPPER(CHR(M->stroke)),M->dbf,M->i,afull(M->dbf))

                        IF SUBSTR(dbf[M->q],1,1) = UPPER(CHR(M->stroke))
                                * Encontrado

                                IF M->j = 0
                                        * Origen no seleccionado..Selecci¢n
                                        i = M->q
                                        KEYBOARD CHR(13)

                                ELSE

                                        IF M->q > M->i
                                                * Fichero hallado es correcto como destino..Selecci¢n
                                                j = M->q
                                                KEYBOARD CHR(13)

                                        ELSE
                                                * Fichero encontrado no puede ser destino
                                                j = 0       
                                                i = M->q    

                                        ENDIF
                                ENDIF
                        ENDIF

                        stroke = 0

                CASE M->stroke = 27
                        * Escape..Cancelar
                        @ M->row_n,column[1] SAY SPACE(M->width)
                        RETURN 0

                CASE M->stroke = 28
                        * "Ayuda" seleccionado del men£
                        DO syshelp
                        stroke = 0

                OTHERWISE
                        * Actualiza pantalla y obtiene nueva tecla

                        IF M->j = 0
                                * Origen no seleccionado..Borra la fila
                                @ M->row_n,column[1] SAY SPACE(M->width)

                                * Extrae el alias origen actual
                                s_alias = name(dbf[M->i])

                                * Lo muestra resaltado
                                SetColor(M->color12)
                                @ M->row_n,column[M->i] + 2 SAY M->s_alias
                                SetColor(M->cNorm)

                        ELSE
                                * Origen seleccionado..Extrae alias destino
                                t_alias = name(dbf[M->j])

                                * Calcula columna despu‚s de s_alias
                                pos_c = column[M->i] + 2 + LEN(M->s_alias)

                                * Borra hasta extremo derecho de la ventana
                                @ M->row_n,M->pos_c SAY SPACE(M->pos_r - M->pos_c)

                                * Dibuja l¡nea y flecha se¤alando alias destino
                                @ M->row_n,M->pos_c;
                                SAY REPLICATE("Ä", column[M->j] - M->pos_c + 1) + CHR(16)

                                * Resalta alias destino
                                SetColor(M->color12)
                                ?? t_alias
                                SetColor(M->cNorm)

                        ENDIF

                        * Obtiene nueva tecla
                        stroke = raw_key()

        ENDCASE
ENDDO

* Resalta origen y destino en v¡deo inverso para indicar ambos seleccionados
SetColor(M->cHilite)
@ M->row_n,column[M->i] + 2 SAY M->s_alias
@ M->row_n,column[M->j] + 2 SAY M->t_alias
SetColor(M->cNorm)

* Determina tipo correcto para expresi¢n de relaci¢n
SELECT (M->j)
ntx_expr = ctrl_key()           && Obtiene clave ¡ndice principal

IF EMPTY(M->ntx_expr)
        * Destino no indexado..debe ser num‚rico o recno()
        k_type = "N"

ELSE
        * Mismo tipo que clave ¡ndice destino
        k_type = TYPE(M->ntx_expr)

ENDIF

* Selecciona  rea destino para probar expresi¢n clave
SELECT (M->i)

* Inicio con expresi¢n anterior
k_trim = k_relate[M->element]
ok = .F.

DO WHILE .NOT. M->ok
        * Acepta entrada de expresi¢n clave
        k_trim = enter_rc(M->k_trim, M->row_n + 1, column[M->i] + 2,;
                                          127, "@KS" + LTRIM(STR(M->pos_r - column[M->i] - 2)),;
                                          M->color1)

        * Expresi¢n vac¡a cancela, si no debe ser tipo correcto
        ok = EMPTY(M->k_trim) .OR. TYPE(M->k_trim) = M->k_type

        IF .NOT. M->ok
                error_msg("Expressi¢n no v lida")

        ENDIF
ENDDO

* Borra la fila de la expresi¢n
@ M->row_n + 1,column[1] SAY SPACE(M->width)

IF EMPTY(M->k_trim)
        * Cancelar
        RETURN 0

ENDIF

* Necesita establecer relaciones
need_relat = .T.

* Guarda relaci¢n definida en matrices globales
k_relate[M->element] = M->k_trim
s_relate[M->element] = CHR(M->i + ASC("A") - 1) + M->s_alias
t_relate[M->element] = CHR(M->j + ASC("A") - 1) + M->t_alias

RETURN 0


******
*       disp_relation()
*
*       Muestra la relaci¢n indicada en la fila indicada en el color indicado
******
FUNCTION disp_relation

PARAMETERS disp_row, element, cSpecial
PRIVATE j, k

IF EMPTY(k_relate[M->element])
        * Borra s¢lo l¡neas
        @ M->disp_row,column[1] SAY SPACE(M->width)
        @ M->disp_row + 1,column[1] SAY SPACE(M->width)
        RETURN 0

ENDIF

* Calcula las  reas de los ficheros relacionados
j = ASC(s_relate[M->element]) - ASC("A") + 1    && origen
k = ASC(t_relate[M->element]) - ASC("A") + 1    && destino

* Muestra el alias origen en el color especificado
SetColor(M->cSpecial)
@ M->disp_row, column[M->j] + 2 SAY SUBSTR(s_relate[M->element], 2)
SetColor(M->cNorm)

* Muestra una flecha (siempre color normal)
?? REPLICATE("Ä", column[M->k] - COL() + 1) + CHR(16)

* Muestra el alias destino en el color especificado
SetColor(M->cSpecial)
?? SUBSTR(t_relate[M->element], 2)
SetColor(M->cNorm)

* Muestra la tecla en la l¡nea siguiente (siempre color normal)
@ M->disp_row + 1, column[M->j] + 2;
SAY pad(k_relate[M->element], M->pos_r - column[M->j] - 2)

RETURN 0


******
*       c_search()
*
*       Localiza el elemento de matriz que coincide con el primer car cter
******
FUNCTION c_search

PARAMETERS c, array, cur_el, num_d
PRIVATE chr_el

* Inicio con el siguiente elemento
chr_el = M->cur_el + 1

DO WHILE M->chr_el <= M->num_d
        * B£squeda..Salir si se encuentra

        IF UPPER(SUBSTR(array[M->chr_el], 1, 1)) = UPPER(M->c)
                EXIT

        ENDIF

        * Siguiente
        chr_el = M->chr_el + 1

ENDDO

IF M->chr_el > M->num_d
        * No se encuentra..B£squeda desde el inicio
        chr_el = 1

        DO WHILE M->chr_el < M->cur_el .AND.;
                         UPPER(SUBSTR(array[M->chr_el], 1, 1)) <> UPPER(M->c)

                * Siguiente
                chr_el = M->chr_el + 1

        ENDDO
ENDIF

RETURN M->chr_el


******
*       ctrl_key()
*
*       Retorna clave ¡ndice principal para  rea actual
******
FUNCTION ctrl_key

PRIVATE key, ntx

IF M->need_ntx
        * Indice debe especificarse pero no establecerse
        ntx = "ntx" + LTRIM(STR(SELECT()))

        * Lee tecla directamente del fichero
        key = ntx_key(&ntx[1])

ELSE
        * Obtiene tecla del sistema si ¡ndice ya establecido
        key = INDEXKEY(0)

ENDIF

RETURN M->key


******
*       get_filter()
*
*       Acepta entrada de expresi¢n de filtro para  rea actual
******
FUNCTION get_filter

PRIVATE k_filter,k_trim,old_help

* Guarda anteriores c¢digos de ayuda y establece nuevos
old_help = M->help_code
help_code = 7

* Obtiene contenido actual de expresiones de filtro
k_filter = "kf" + SUBSTR("123456", M->cur_area, 1)
k_trim = &k_filter

* Selecciona  rea actual para probar expresi¢n de filtro
SELECT (M->cur_area)

* Resalta fichero de datos
hi_cur()

* Establece matriz para mulitbox
DECLARE boxarray[4]

boxarray[1] = "fltr_title(sysparam)"
boxarray[2] = "getfilter(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"

* Indica la funci¢n que completa el proceso
okee_dokee = "do_filter()"

* Abre la caja
multibox(7, 17, 5, 2, M->boxarray)

* Restaura c¢digo de ayuda
help_code = M->old_help

* Elimina resalte del nombre del fichero de datos actual
dehi_cur()

RETURN 0


******
*       fltr_title()
*
*       Muestra t¡tulo para entrada de filtro
******
FUNCTION fltr_title

PARAMETERS sysparam

* T¡tulo incluye fichero.ext pero no la v¡a
RETURN box_title(M->sysparam, "Establecer un filtro para " +;
                                                          SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
                                                          "...")


******
*       getfilter()
*
*       Acepta entrada de expresi¢n de filtro en la variable temporal "k_trim"
******
FUNCTION getfilter

PARAMETERS sysparam

RETURN get_k_trim(M->sysparam, "Condici¢n")


******
*       do_filter()
*
*       Completa la entrada de filtro
******
FUNCTION do_filter

PRIVATE done, k_sample

IF EMPTY(M->k_trim)
        * Una expresi¢n vac¡a confirmada significa eliminar el filtro actual
        done = .T.

        IF .NOT. EMPTY(&k_filter)
                * Cancela cualquier filtro activo
                SET FILTER TO

                * Inicializa expresi¢n de filtro global
                &k_filter = ""

        ENDIF

ELSE

        IF TYPE(M->k_trim) = "L"
                * Expresi¢n se eval£a ok
                done = .T.

                IF .NOT. (&k_filter == M->k_trim)
                        * Cambio en expresi¢n filtro..Establecer variables globales
                        need_filtr = .T.
                        &k_filter = M->k_trim

                ENDIF

        ELSE
                done = .F.
                error_msg("La expresi¢n de filtro debe ser de tipo l¢gico")

        ENDIF
ENDIF

RETURN M->done


******
*       clear_dbf()
*
*       Borra  rea indicada..Desplaza  reas superiores si se solicita
*
*       Valores desplazamiento:
*               0  =  no hay desplazamiento
*               1  =  desplazamiento derecha (insertar)
*               2  =  desplazamiento izquierda (borrar)
******
FUNCTION clear_dbf

PARAMETERS work_area, shift
PRIVATE s_alias,c_area,temp,xtemp,i,file_name,alias_6,n_active

* Determina n£mero de  reas activas
n_active = afull(M->dbf)

* Extrae alias del  rea especificada
s_alias = name(dbf[M->work_area])

* Area 6 puede verse afectada si hay desplazamiento debido a insertar
alias_6 = ""

* Accede a la lista de ¡ndices para el  rea actual
temp = "ntx" + SUBSTR("123456", M->work_area, 1)

DO CASE

        CASE M->shift = 0
                * Sin desplazamiento..Ning£n problema
                dbf[M->work_area] = ""

                * Reduce n£mero de ficheros abiertos en n§ de ¡ndices + 1
                n_files = M->n_files - afull(&temp) - 1

        CASE M->shift = 1
                * Desp. derecha..Fichero de datos activo permanece abierto

                IF .NOT. EMPTY(dbf[6])
                        * Recuerda el alias
                        alias_6 = name(dbf[6])

                        * Reduce n£mero de ficheros abiertos en n§ de ¡ndices + 1
                        n_files = M->n_files - afull(M->ntx6) - 1

                ENDIF

                * Desplazamiento puede no ser necesario
                shift = IF(EMPTY(dbf[M->work_area]) .OR. M->work_area = 6, 0, 1)

                * Abre un elemento vac¡o en matriz global de ficheros de datos
                array_ins(M->dbf, M->work_area)

        CASE M->shift = 2
                * Desp. izquierda..Se cierra fichero de datos actual
                array_del(M->dbf, M->work_area)

                * Desplazamiento puede no ser necesario
                shift = IF(EMPTY(dbf[M->work_area]), 0, 2)

                * Reduce n£mero de ficheros abiertos en n§ de ¡ndices + 1
                n_files = M->n_files - afull(&temp) - 1

ENDCASE

i = 1

DO WHILE M->i <= M->n_active
        * Selecciona  rea i
        c_area = CHR(M->i + ASC("A") - 1)
        SELECT (M->i)

        IF M->i = M->work_area .OR. (M->i > M->work_area .AND. M->shift <> 0)
                * Cierra las  reas a desplazar o cerrar
                USE

        ENDIF

        * Busca filtros en  reas activas para aliases desaparecidos
        temp = "kf" + SUBSTR("123456", M->i, 1)

        IF (((M->s_alias + "->" $ UPPER(&temp)) .OR.;
           (M->i = M->work_area .AND. .NOT. EMPTY(&temp)));
           .AND. M->shift <> 1) .OR. (.NOT. EMPTY(M->alias_6) .AND.;
           M->alias_6 + "->" $ UPPER(&temp) .AND. M->shift = 1)
                * Fichero de datos era parte de expresi¢n de filtro o no puede existir

                * Desactiva filtro
                SET FILTER TO

                need_filtr = .T.

                * Inicializa expresi¢n de filtro global
                &temp = ""

        ENDIF

        * Siguiente
        i = M->i + 1

ENDDO

DO CASE

        CASE M->shift = 0
                * Borra matriz de ficheros ¡ndice
                temp = "ntx" + SUBSTR("123456", M->work_area, 1)
                afill(&temp, "")

                * Borra lista de campos
                temp = "field_n" + SUBSTR("123456", M->work_area, 1)
                afill(&temp, "")

                * Borra filtro
                temp = "kf" + SUBSTR("123456", M->work_area, 1)
                &temp = ""

        CASE M->shift = 1
                * Desplazamiento a la derecha
                need_filtr = .T.
                need_ntx = .T.

                * Contar hacia atr s..Matriz dbf puede no ser contigua
                i = 6

                DO WHILE EMPTY(dbf[M->i])
                        * Localiza mayor  rea activa
                        i = M->i - 1

                ENDDO

                DO WHILE M->i > M->work_area
                        * Desplaza  reas superiores..Lista de ¡ndices
                        temp = "ntx" + SUBSTR("123456", M->i, 1)
                        xtemp = "ntx" + SUBSTR("123456", M->i - 1, 1)
                        acopy(&xtemp,&temp)

                        * Lista de campos activos
                        temp = "field_n" + SUBSTR("123456", M->i, 1)
                        xtemp = "field_n" + SUBSTR("123456", M->i - 1, 1)
                        acopy(&xtemp,&temp)

                        * Filas actuales
         temp = "_cr" + SUBSTR("123456", M->i, 1)
         xtemp = "_cr" + SUBSTR("123456", M->i - 1, 1)
                        acopy(&xtemp,&temp)

                        * Elementos actuales
         temp = "_el" + SUBSTR("123456", M->i, 1)
         xtemp = "_el" + SUBSTR("123456", M->i - 1, 1)
                        acopy(&xtemp,&temp)

                        * Expresiones filtro
                        temp = "kf" + SUBSTR("123456", M->i, 1)
                        xtemp = "kf" + SUBSTR("123456", M->i - 1, 1)
                        &temp = &xtemp

                        * Siguiente
                        i = M->i - 1

                ENDDO

                * Borra el  rea especificada (i = work_area)
                xtemp = SUBSTR("123456", M->i, 1) 

                * Borra lista de ficheros ¡ndice
                temp = "ntx" + xtemp
                afill(&temp, "")

                * Borra lista de campos activa
                temp = "field_n" + xtemp
                afill(&temp, "")

                * Borra expresi¢n de filtro
                temp = "kf" + xtemp
                &temp = ""

                * Inicializa filas actuales
      temp = "_cr" + xtemp
                &temp[2] = row_a[2]
                &temp[3] = row_a[3]

                * Inicializa elementos actuales
      temp = "_el" + xtemp
                afill(&temp, 1)

        CASE M->shift = 2
                * Desplazamiento izquierda
                need_filtr = .T.
                need_ntx = .T.

                i = M->work_area

                DO WHILE M->i < 6 .AND. .NOT. EMPTY(dbf[M->i])
                        * Desplaza  reas superiores..Lista de ¡ndices
                        temp = "ntx" + SUBSTR("123456", M->i, 1)
                        xtemp = "ntx" + SUBSTR("123456", M->i + 1, 1)
                        acopy(&xtemp,&temp)

                        * Lista de campos activos
                        temp = "field_n" + SUBSTR("123456", M->i, 1)
                        xtemp = "field_n" + SUBSTR("123456", M->i + 1, 1)
                        acopy(&xtemp,&temp)

                        * Filas actuales
         temp = "_cr" + SUBSTR("123456", M->i, 1)
         xtemp = "_cr" + SUBSTR("123456", M->i + 1, 1)
                        acopy(&xtemp,&temp)

                        * Elementos actuales
         temp = "_el" + SUBSTR("123456", M->i, 1)
         xtemp = "_el" + SUBSTR("123456", M->i + 1, 1)
                        acopy(&xtemp,&temp)

                        * Expresiones de filtro
                        temp = "kf" + SUBSTR("123456", M->i, 1)
                        xtemp = "kf" + SUBSTR("123456", M->i + 1, 1)
                        &temp = &xtemp

                        * Siguiente
                        i = M->i + 1

                ENDDO

                * Borra la £ltima  rea (previamente activa)
                xtemp = SUBSTR("123456", M->i, 1)

                * Borra lista de ¡ndices
                temp = "ntx" + M->xtemp
                afill(&temp, "")

                * Borra lista de campos activos
                temp = "field_n" + M->xtemp
                afill(&temp, "")

                * Borra expresi¢n de filtro
                temp = "kf" + M->xtemp
                &temp = ""

                * Inicializa filas actuales
      temp = "_cr" + M->xtemp
                &temp[2] = row_a[2]
                &temp[3] = row_a[3]

                * Inicializa elementos actuales
      temp = "_el" + M->xtemp
                afill(&temp, 1)

ENDCASE

* Necesita reinicializarse
need_field = .T.

**
*       Nota: El origen y destino de relaciones se identifican
*             con la letra del  rea + alias
**

* Obtener letra del  rea borrada
c_area = CHR(M->work_area + ASC("A") - 1)

i = 1

DO WHILE M->i <= LEN(M->k_relate)
        * Buscar todas las relaciones activas

        IF EMPTY(k_relate[M->i])
                * No hay m s relaciones activas
                EXIT

        ENDIF

        IF ((SUBSTR(s_relate[M->i], 1, 1) = M->c_area .OR.;
           SUBSTR(t_relate[M->i], 1, 1) = M->c_area) .AND. M->shift <> 1) .OR.;
           (M->shift = 1 .AND. SUBSTR(t_relate[M->i], 1, 1) = "F")
                * Relaci¢n debe eliminarse de la lista

                array_del(M->s_relate, M->i)
                array_del(M->k_relate, M->i)
                array_del(M->t_relate, M->i)
                need_relat = .T.

        ELSE

                IF (M->shift = 2 .AND. SUBSTR(s_relate[M->i], 1, 1) > M->c_area) .OR.;
                   (M->shift = 1 .AND. SUBSTR(s_relate[M->i], 1, 1) >= M->c_area)
                        * Area origen debe desplazarse..Ajuste  rea origen

                        s_relate[M->i] = CHR(ASC(SUBSTR(s_relate[M->i], 1, 1)) +;
                                                         IF(M->shift = 1, 1, -1)) +;
                                                         SUBSTR(s_relate[M->i], 2)
                        need_relat = .T.

                ENDIF

                IF (M->shift = 2 .AND. SUBSTR(t_relate[M->i], 1, 1) > M->c_area) .OR.;
                   (M->shift = 1 .AND. SUBSTR(t_relate[M->i], 1, 1) >= M->c_area)
                        * Area destino debe desplazarse..Ajuste  rea destino

                        t_relate[M->i] = CHR(ASC(SUBSTR(t_relate[M->i], 1, 1)) +;
                                                         IF(M->shift = 1, 1, -1)) +;
                                                         SUBSTR(t_relate[M->i], 2)
                        need_relat = .T.

                ENDIF

                * Siguiente
                i = M->i + 1

        ENDIF
ENDDO

IF M->shift <> 0
        * Reabre fichero de datos activo en nuevas  reas
        i = 6

        DO WHILE M->i >= M->work_area
                * Busca todas  reas desplazadas

                IF .NOT. EMPTY(dbf[M->i])
                        * Abre fichero de datos
                        c_area = CHR(M->i + ASC("A") - 1)
                        SELECT (M->i)
                        file_name = dbf[M->i]
         NetUse( file_name )

                ENDIF

                * Siguiente
                i = M->i - 1

        ENDDO
ENDIF

RETURN 0


******
*       save_view()
*
*       Guarda la vista actual en un fichero ".VEW"
*
*       Nota: - El fichero VEW es una base de datos con la extensi¢n por
*               defecto ".VEW" y 2 campos: "item_name" y "contents".
*             - Los primeros 2 ¡tems se reservan para variables globales
*               "cur_dir" y "n_files"..despu‚s un n£mero variable de
*               expresiones de filtro..el resto de ¡tems son matrices.
*             - Si el contenido de un ¡tem no se ajusta al campo que lo
*               contiene, se sigue en el pr¢ximo registro donde
*               item_name se dejar  en blanco.
*             - Para matrices, s¢lo se graba el identificador..el n£mero
*               de ¡tems es el n£mero de elementos a llenar.
******
FUNCTION save_view

PRIVATE filename, old_help

* Guarda antiguos c¢digos de ayuda y establece los nuevos
old_help = M->help_code
help_code = 21

* Obtiene nombre de fichero introducido..Por defecto, principal + ".VEW"
IF EMPTY(M->view_file) .AND. .NOT. EMPTY(dbf[1])
        * Por defecto, nombre del fichero de datos principal
        filename = name(dbf[1]) + ".VEW"

ELSE
        filename = M->view_file

ENDIF

* Es mejor en una caja
filebox(".VEW", "vew_list", "vcrea_titl", "do_creavew", .T., 8)

* Restaura c¢digo de ayuda
help_code = M->old_help

RETURN 0


******
*       vcrea_titl()
*
*       Muestra t¡tulo para grabar vista
******
FUNCTION vcrea_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Grabar la vista en...")


******
*       do_creavew()
*
*       Graba la vista actual en el fichero .VEW
******
FUNCTION do_creavew

LOCAL cAlias
PRIVATE i, j, k, m_name, l_name, add_name

IF EMPTY(M->filename)
        error_msg("Fichero vista no seleccionado")
        RETURN .F.

ENDIF

* Selecciona  reas del sistema reservado
SELECT 10

stat_msg("Creando el fichero vista")

* A¤ade los nuevos ficheros .VEW a vew_list s¢lo del directorio actual
add_name = .NOT. FILE(name(filename) + ".VEW")

* Crea una plantilla ampliada de estructura
CREATE ddbbuuuu.ext

* Define 2 campos
APPEND BLANK
REPLACE field_name WITH "ITEM_NAME",field_type WITH "C",field_len WITH 10

APPEND BLANK
REPLACE field_name WITH "CONTENTS",field_type WITH "C",field_len WITH 10

* Crea el fichero vista
USE
cAlias := MakeAlias( filename )
CREATE &filename FROM ddbbuuuu.ext ALIAS cAlias

* Establece variable global
view_file = M->filename

* Abre fichero vista..Evita conflictos con el alias
NetUse( view_file, NIL, NIL, "ddbbuuuu" )

* Borra plantilla
ERASE ddbbuuuu.ext

* Siempre se guardan 2 variables globales
APPEND BLANK
REPLACE item_name WITH "cur_dir"
put_line(cur_dir)

APPEND BLANK
REPLACE item_name WITH "n_files"
put_line(LTRIM(STR(n_files)))

i = 1

DO WHILE i <= 6
        * Filtros

        IF EMPTY(dbf[i])
                * No hay m s ficheros de datos
                EXIT

        ENDIF

        * Obtiene nombre de variable para expansi¢n de macro
        m_name = "kf" + SUBSTR("123456", i, 1)

        IF .NOT. EMPTY(&m_name)
                * S¢lo graba filtros activos
                APPEND BLANK
                REPLACE item_name WITH m_name
                put_line(&m_name)

        ENDIF

        * Siguiente
        i = i + 1

ENDDO

* Graba matrices..evita grabar elementos vac¡os
i = 1

DO WHILE i <= 6
        * Especificaci¢n de ficheros de datos

        IF EMPTY(dbf[i])
                * No hay ficheros de datos
                EXIT

        ENDIF

        * Graba una especificaci¢n
        APPEND BLANK
        REPLACE item_name WITH "dbf"
        put_line(dbf[i])

        * Siguiente
        i = i + 1

ENDDO

* Guarda listas de ¡ndices y de campos
l_name = "ntx"

FOR k = 1 TO 2
        * Primero el indexado, luego los campos
        i = 1

        DO WHILE i <= 6
                * Lista de ¡ndices o campos para cada fichero de datos

                IF EMPTY(dbf[i])
                        * No hay m s ficheros de datos
                        EXIT

                ENDIF

                * Obtiene identificador de matriz para expansi¢n macro
                m_name = l_name + SUBSTR("123456", i, 1)

                j = 1

                DO WHILE j <= LEN(&m_name)
                        * Lista de ¡ndices o campos para un fichero de datos

                        IF EMPTY(&m_name[j])
                                * La salida ahorra tiempo y espacio
                                EXIT

                        ENDIF

                        * Guarda una especificaci¢n de ¡ndice o un nombre de campo
                        APPEND BLANK
                        REPLACE item_name WITH m_name
                        put_line(&m_name[j])

                        * Siguiente elemento
                        j = j + 1

                ENDDO

                * Siguiente  rea
                i = i + 1

        ENDDO

        * Cambiar a listas de campos
        l_name = "field_n"

NEXT

i = 1

DO WHILE i <= 3
        * Relaciones en 3 matrices..s_relate, k_relate y t_relate
        m_name = SUBSTR("skt", i, 1) + "_relate"
        j = 1

        DO WHILE j <= LEN(&m_name)
                * Una matriz

                IF EMPTY(&m_name[j])
                        * La salida ahorra tiempo y espacio
                        EXIT

                ENDIF

                * Un elemento
                APPEND BLANK
                REPLACE item_name WITH m_name
                put_line(&m_name[j])

                * Siguiente elemento
                j = j + 1

        ENDDO

        * Siguiente matriz
        i = i + 1

ENDDO

* Cerrar fichero vista
USE

* A¤ade nombre de fichero a la matriz de ficheros de vista
IF AT(".VEW", filename) = LEN(filename) - 3 .AND.;
   FILE(name(filename) + ".VEW") .AND. add_name
        * A¤ade s¢lo nuevos ficheros .VEW en el directorio actual

        * Determina el n£mero de elementos vac¡os
        i = afull(vew_list) + 1

        IF i <= LEN(vew_list)
                * Espacio para uno m s
                vew_list[i] = filename

                * Debe ser alfab‚tico
                array_sort(vew_list)

        ENDIF
ENDIF

stat_msg("")

RETURN .T.


******
*       put_line()
*
*       Guarda cadena en los campos del fichero de vista abierto
******
FUNCTION put_line

PARAMETERS line
PRIVATE pos

* Asigna contenido al registro actual
REPLACE contents WITH line

* Se sit£a al inicio de la fragmentaci¢n
pos = LEN(contents) + 1

DO WHILE pos <= LEN(line)
        * Contin£a contenido en siguiente registro
        APPEND BLANK
        REPLACE contents WITH SUBSTR(line, pos)

        pos = pos + LEN(contents)

ENDDO

RETURN 0


******
*       set_from()
*
*       Restaura Vista del fichero .VEW
******
FUNCTION set_from

PARAMETERS from_view
PRIVATE filename, old_help

* Guarda antiguos c¢digos de ayuda y establece los nuevos
old_help = M->help_code
help_code = 21

* Por defecto para el fichero Vista anterior
filename = M->view_file

IF M->from_view
        * Llamado por set_view

        IF filebox(".VEW", "vew_list", "vopen_titl", "do_openvew", .F., 8) <> 0
                * Indica nueva Vista establecida
                keystroke = 13

        ENDIF

ELSE
        * Hazlo
        do_openvew()

ENDIF

* Restaura c¢digo de ayuda
help_code = M->old_help

RETURN 0


******
*       vopen_titl()
*
*       Muestra t¡tulo para restaurar vista
******
FUNCTION vopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Recuperar vista de...")


******
*       do_openvew()
*
*       Restaura vista de un fichero .VEW
*
*       Nota: Esta funci¢n se llama cuando se pulsa la tecla Intro
*             mientras el cursor est  en el bot¢n Aceptar
******
FUNCTION do_openvew

PRIVATE m_name, i, done

DO CASE

        CASE EMPTY(M->filename)
                error_msg("No se ha seleccionado ning£n fichero vista")
                done = .F.

        CASE .NOT. FILE(M->filename)
                error_msg("No se puede abrir el fichero " + M->filename)
                done = .F.

        OTHERWISE
                * Selecciona  rea reservada del sistema
                SELECT 10

                * Abre fichero .VEW..Evita conflictos con alias
      NetUse( filename, NIL, NIL, "ddbbuuuu" )

                IF .NOT. (TYPE("item_name") = "C" .AND. TYPE("contents") = "C")
                        USE
                        error_msg("Fichero vista no v lido")
                        RETURN .F.

                ENDIF

                * Restaurar Vista..Establecer variable global
                view_file = M->filename

                * Toda la Vista necesita configurarse
                STORE .T. TO need_field,need_ntx,need_relat,need_filtr
                stat_msg("Recuperando vista")

                * Borra la vista actual, si hay alguna
                i = 6

                DO WHILE M->i > 0

                        IF .NOT. EMPTY(dbf[M->i])
                                * Borra un  rea
                                clear_dbf(M->i, 0)

                        ENDIF

                        * Siguiente
                        i = M->i - 1

                ENDDO

                * Selecciona  rea reservada del sistema
                SELECT 10

                * "cur_dir" y "n_files" siempre se guardan primero
                cur_dir = get_line()
                n_files = VAL(get_line())

                IF TRIM(item_name) == "k_filter"
                        * soporte para formato antiguo
                        REPLACE item_name WITH "kf1"
                        kf1 = get_line()

                ELSE

                        DO WHILE SUBSTR(item_name, 1, 2) == "kf"
                                * obtener una expresi¢n de filtro
                                m_name = TRIM(item_name)

                                * asigna la expresi¢n
                                &m_name = get_line()

                        ENDDO
                ENDIF

                * Toda la informaci¢n restante se ordena en matrices globales
                DO WHILE .NOT. EOF()
                        * Obtiene sig. identificador de matriz e inicializa ¡ndice vector
                        m_name = TRIM(item_name)
                        i = 1

                        * Llena una matriz
                        DO WHILE TRIM(item_name) == m_name
                                * Llena un elemento de la matriz
                                &m_name[i] = get_line()

                                * Siguiente elemento
                                i = i + 1

                        ENDDO
                ENDDO

                * Cierra el fichero Vista
                USE

                * Abre todos los ficheros de datos en sus  reas
                i = 1

                DO WHILE M->i <= 6

                        IF EMPTY(dbf[M->i])
                                * Ning£n fichero de datos a abrir
                                EXIT

                        ENDIF

                        * Selecciona el  rea correspondiente
                        SELECT (M->i)

                        * Abre el fichero de datos
                        filename = dbf[M->i]
         NetUse( filename )

                        * Siguiente  rea
                        i = M->i + 1

                ENDDO

                stat_msg("")
                done = .T.

ENDCASE

RETURN M->done


******
*       get_line()
*
*       Re£ne contenido de variable del fichero .VEW
******
FUNCTION get_line

PRIVATE line

* Asigna contenido del primer registro
line = TRIM(contents)
SKIP

DO WHILE LEN(TRIM(item_name)) = 0 .AND. .NOT. EOF()
        * Campo con nombre en blanco significa contenido sigue en sig. registro
        line = line + TRIM(contents)
        SKIP

ENDDO

RETURN line


* Fin de fichero: DBUVIEW.PRG
