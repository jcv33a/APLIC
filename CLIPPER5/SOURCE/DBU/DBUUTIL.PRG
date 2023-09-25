/***
*
*  Dbuutil.prg
*
*  M¢dulo de las utilidades de DBU
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.
*
*/


******
*       setup()
*
*   Activar la Vista
*      
*
*   Nota: - Los ficheros de datos se abren y cierran en el momento
*           de la selecci¢n, pero todo lo dem s se hace aqu¡.
*         - Las variables globales need_field, need_ntx, need_relat,
*           y need_filtr previenen la reconfiguraci¢n de esas porciones
*           de la vista ya en efecto.
******
FUNCTION setup

PRIVATE k, t, n, i, j, field_n, s_alias, k_filter, ntx, file_name,;
		k_1, k_2, k_3, k_4, k_5, k_6, k_7

stat_msg("Estableciendo vista")

IF M->need_field
	* Ensamblando la lista principal de campos
	need_field = .F.

	* Lectura del n£mero de campos en la lista anterior
	k = afull(M->field_list)

	n = 1
	i = 1

	DO WHILE M->n <= 6 .AND. M->i <= LEN(M->field_list)

		IF EMPTY(dbf[M->n])
			* No hay m s  reas de trabajo activas
			EXIT

		ENDIF

		* Accede a una lista de campos
		field_n = "field_n" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&field_n[1])
			* A¤adimos "alias->" si  rea > 1
			s_alias = IF(M->n > 1, name(dbf[M->n]) + "->", "")
			afill(M->field_list, M->s_alias, M->i, afull(&field_n))

			j = 1

			DO WHILE M->j <= LEN(&field_n) .AND. M->i <= LEN(M->field_list)

				IF EMPTY(&field_n[M->j])
					* No m s campos en la lista
					EXIT

				ENDIF

				* "alias->" + fieldname
				field_list[M->i] = field_list[M->i] + &field_n[M->j]

				* Siguiente
				i = M->i + 1
				j = M->j + 1

			ENDDO
		ENDIF

		* Area de trabajo siguiente
		n = M->n + 1

	ENDDO

	IF M->i <= M->k
		* Borrado de los nombres de los campos de listas anteriores
		afill(M->field_list, "", M->i)

	ENDIF
ENDIF

IF M->need_ntx
	* Activaci¢n de todos los ¡ndices
	need_ntx = .F.

	n = 1

	DO WHILE M->n <= 6

		IF EMPTY(dbf[M->n])
			* No hay m s  reas de trabajo activas
			EXIT

		ENDIF

		* Acceso a una lista de ficheros ¡ndice
		ntx = "ntx" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&ntx[1])
	    * Indice(s) seleccionados..Almacenamos en 7 variables
	    * los nombres de los ficheros ¡ndice
			STORE "" TO k_1,k_2,k_3,k_4,k_5,k_6,k_7

			* Seleccionamos las  reas de trabajo adecuadas
			SELECT (M->n)

			i = 1

			DO WHILE M->i <= 7 .AND. EMPTY(M->view_err)
				* Los ficheros ¡ndice deben existir

				IF EMPTY(&ntx[M->i])
					* No hay m s ficheros en la lista
					EXIT

				ENDIF

				* Simplificaci¢n de las macrosustituciones costosas
				file_name = &ntx[M->i]

				IF FILE(M->file_name)
					* El fichero existe. D‚jemoslo en la variable adecuada
					k = "k_" + SUBSTR("1234567", M->i, 1)
					&k = M->file_name
					i = M->i + 1

				ELSE
					view_err = "No puede abrirse el fichero ¡ndice " + M->file_name

				ENDIF
			ENDDO

			IF EMPTY(M->view_err)
				* Se permiten cadenas vac¡as entre comas
				SET INDEX TO &k_1,&k_2,&k_3,&k_4,&k_5,&k_6,&k_7

			ELSE
				* Devolvemos el control de secuencia con un mensaje de error
				need_ntx = .T.
				RETURN 0

			ENDIF
		ENDIF

		* Siguiente  rea de trabajo
		n = M->n + 1

	ENDDO
ENDIF

IF M->need_relat
	* Establecemos todas las relaciones
	need_relat = .F.

	* Despreciamos las antiguas
	FOR j = 1 TO 5
		SELECT (M->j)
		SET RELATION TO

	NEXT

	j = 1

	DO WHILE M->j <= LEN(M->k_relate)
		* Buscar en la lista activa

		IF EMPTY(k_relate[M->j])
			* No hay m s relaciones en la lista
			EXIT

		ENDIF

		* Seleccionamos el  rea de trabajo fuente
		n = ASC(s_relate[M->j]) - ASC("A") + 1
		SELECT (M->n)

	* Almacenamos la clave y el destino en las variables est ndar para
	* macrosustituirlas
		k = k_relate[M->j]
		t = SUBSTR(t_relate[M->j], 2)

		* Esta opci¢n aditiva es verdaderamente preciosa
		SET RELATION ADDITIVE TO &k INTO &t

		* El siguiente por favor
		j = M->j + 1

	ENDDO

	* Alineamiento de la cadena completa de relaciones
	SELECT 1
	GO TOP

ENDIF

IF M->need_filtr
	* Activaci¢n de todos los filtros
	need_filtr = .F.

	n = 1

	DO WHILE M->n <= 6

		IF EMPTY(dbf[M->n])
			* No hay m s  reas de trabajo activas
			EXIT

		ENDIF

		* Acceso a una expresi¢n global de filtro
		k_filter = "kf" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&k_filter)
			* Establecemos el filtro seg£n esa variable
			SELECT (M->n)

			* Las expresiones deben permanecer en variables p£blicas
			DO CASE

				CASE M->n = 1
					SET FILTER TO &kf1

				CASE M->n = 2
					SET FILTER TO &kf2

				CASE M->n = 3
					SET FILTER TO &kf3

				CASE M->n = 4
					SET FILTER TO &kf4

				CASE M->n = 5
					SET FILTER TO &kf5

				CASE M->n = 6
					SET FILTER TO &kf6

			ENDCASE

	    * Desplazamos el puntero al primer registro que cumpla 
	    * la condici¢n
			GO TOP

		ENDIF

		* Area de trabajo siguiente
		n = M->n + 1

	ENDDO
ENDIF

* Borramos el mensaje
stat_msg("")
RETURN 0


**********************
* multibox subsystem *
**********************

******
*       multibox()
*
*       Subsistema de entrada/selecci¢n por parte del usuario
*
*       Valores de sysparam:
*               1       =   Inicializar, visualizar e indicar posici¢n
*               2       =   Resaltar (activar como ¡tem en curso)
*               3       =   No resaltar
*               4       =   Se activa como ¡tem en curso y devuelve un nuevo estado
*
*       Estados:
*               0       =       Abandonar el proceso
*               1       =       Inicializar
*               2       =       Apuntar con el cursor
*               3       =       Entrada/Selecci¢n
*               4       =       Completar el proceso
*
*   NOTA: - Boxarray [] es una matriz de cadenas de caracteres que contiene
*           los nombres de funciones con un par metro predefinido como
*           se ve en el ejemplo: "function(sysparam)"
*         - Cada funci¢n posee una coordenada de pantalla en la cual debe
*           escribir durante la inicializaci¢n
*         - Cada elemento de boxarray [] debe tener su coordenada en la
*           misma columna o superior (relativa al elemento anterior) sin
*           que haya dos elementos que tengan el mismo par fila/columna
******
FUNCTION multibox

PARAMETERS wt, wl, wh, beg_c, boxarray
local saveColor
PRIVATE sysparam, state, cursor, funcn, winbuff, save_help, prime_help,;
		x, colorNorm, colorHilite

colorNorm := color8
colorHilite := color10

* Variables globales para eliminar la recursi¢n
box_open = .T.

* Los c¢digos de ayuda pueden establecerse libremente en el subsistema
* multibox
save_help = M->help_code
prime_help = M->help_code

* Establecer matrices paralelas para filas y columnas de cada objeto
DECLARE box_row[LEN(M->boxarray)]
DECLARE box_col[LEN(M->boxarray)]

* Salvar la ventana
winbuff = SAVESCREEN(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45)

* Borra y pone marco a la ventana (anchura fija, altura y posici¢n variables)
saveColor := SetColor(M->colorNorm)
scroll(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45, 0)
@ M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45 BOX frame

* Inicializa, visualiza y nos da la posici¢n
sysparam = 1

FOR cursor = 1 TO LEN(M->boxarray)
	* Llama a todas las funciones de la lista
	funcn = boxarray[M->cursor]     && En forma normal para macro
	x = &funcn                      && Llamar a la funci¢n
	box_row[M->cursor] = ROW()      && Salva la coordenada de la fila
	box_col[M->cursor] = COL()      && Salva la coordenada de la columna

NEXT

cursor = M->beg_c                        && Quien llama decide d¢nde empezar
state = 2                                && Comenzamos en el estado de apuntar

DO WHILE M->state <> 0 .AND. M->state <> 4
	* Iterar hasta seleccionar o abandonar
	funcn = boxarray[M->cursor]     && Obtiene funci¢n actual de la lista

	DO CASE

		CASE M->state = 2
			* Estado de apuntar

			IF .NOT. key_ready()
				* Resaltar
				sysparam = 2
				x = &funcn

				* Esperar tecla
				read_key()

			ENDIF

			DO CASE

				CASE M->keystroke = 13 .OR. isdata(M->keystroke)
					* Cambio al estado de selecci¢n
					state = 3

				CASE M->local_func = 1
					* Se seleccion¢ "ayuda" del men£
					DO syshelp

				CASE q_check()
					* Proceso abandonado
					state = 0

				OTHERWISE
					* No resalta
					sysparam = 3
					x = &funcn

					* Mueve el cursor al nuevo objeto
					cursor = matrix(M->cursor, M->keystroke)

			ENDCASE

		CASE M->state = 3
			* Estado de selecci¢n
			sysparam = 4

			* Todas las funciones devuelven un valor de 0, 2 o 4
			state = &funcn

	ENDCASE
ENDDO

* Restaura la pantalla
RESTSCREEN(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45, M->winbuff)
SetColor(saveColor)

* Restaura variables globales
keystroke = 0                   && Para evitar confusiones
box_open = .F.                  && Se cierra la caja
help_code = M->save_help        && C¢digo de ayuda original

* Devolver un cero significa que el proceso se ha abandonado
RETURN M->state


******
*       matrix()
*
*       Sit£a el cursor en la posici¢n actual para uso de multibox
*
*   NOTA: - El valor del cursor es una posici¢n de una matriz de nombres
*           de funci¢n pasados a multibox (ejemplo: boxarray[cursor])
*         - Cada funci¢n posee una coordenada de pantalla que se salva
*           en las matrices box_row[] y box_col[]
*         - Debido a que hay una funci¢n que maneja la lista, la posici¢n
*           real de la fila se usa para determinar la posici¢n vertical
*         - Debido a que el cursor real puede encontrarse en cualquier
*           posici¢n en esa fila, la columna contenida en box_col[] se
*           usa para determinar la columna horizontal
*         - La nueva posici¢n del cursor es la mejor aproximaci¢n en una
*           de las cuatro direcciones.
******
FUNCTION matrix

PARAMETERS old_curs, k
PRIVATE old_row, old_col, test_curs, new_curs

* Lectura de la posici¢n actual
old_row = ROW()                 && La fila real 
old_col = box_col[M->old_curs]  && La columna

* El nuevo valor es el mismo que el anterior si no hay movimiento posible
new_curs = M->old_curs

* Valor inicial 
test_curs = M->old_curs

DO CASE

	CASE M->k = 19 .OR. M->k = 219
		* Flecha a la izquierda

		DO WHILE M->test_curs > 2
	    * Comprueba todos los elementos menores excepto el 1 que es siempre 
	    * el t¡tulo
			test_curs = M->test_curs - 1

			IF box_col[M->test_curs] < M->old_col .AND.;
			   box_row[M->test_curs] >= M->old_row
				* Nunca sube cuando se mueve a la izquierda

				IF box_row[M->test_curs] < box_row[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* Pero no m s abajo de donde se permite
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 4
		* Flecha a la derecha

		DO WHILE M->test_curs < LEN(M->box_col)
			* Comprueba todos los elementos superiores
			test_curs = M->test_curs + 1

			IF box_col[M->test_curs] > M->old_col .AND.;
			   box_row[M->test_curs] <= M->old_row
				* Nunca hacia abajo mientras nos movemos a la derecha

				IF box_row[M->test_curs] > box_row[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* Pero no m s all  de donde podemos
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 5
		* flecha arriba

		DO WHILE M->test_curs > 2
	    * Comprueba todos los elementos excepto el 1 que es siempre el 
	    * t¡tulo
			test_curs = M->test_curs - 1

			IF box_row[M->test_curs] < M->old_row .AND.;
			   box_col[M->test_curs] <= M->old_col
				* Nunca a la derecha mientras subimos

				IF box_col[M->test_curs] > box_col[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* Pero no m s a la izquierda de donde debamos
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 24
		* Flecha abajo

		DO WHILE M->test_curs < LEN(M->box_row)
			* Comprueba todos los elementos superiores
			test_curs = M->test_curs + 1

			IF box_row[M->test_curs] > M->old_row .AND.;
			   box_col[M->test_curs] >= M->old_col
				* Nunca hacia la izquierda mientras bajemos

				IF box_col[M->test_curs] < box_col[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* Pero no m s a la derecha de donde debamos
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO
ENDCASE

RETURN M->new_curs


******
*       to_ok()
*
*       Va directamente al bot¢n Ok
*
*       NOTA: Esta rutina depende de cosas conocidas y desconocidas
******
FUNCTION to_ok

* Sit£a el cursor en el elemento anterior al bot¢n "Ok"
cursor = ascan(M->boxarray, "ok_button(sysparam)") - 1

* Pone una flecha abajo en la memoria intermedia de teclado
KEYBOARD CHR(24)

RETURN 0


******
*       to_can()
*
*   Posicionamiento inmediato en el bot¢n Cancelar
*
*       Nota: esta rutina depende de cosas conocidas y desconocidas
******
FUNCTION to_can

* Sit£a el cursor en el bot¢n cancelar
cursor = ascan(M->boxarray, "can_button(sysparam)")

* Pone una flecha abajo en la memoria intermedia de teclado
KEYBOARD CHR(24)

RETURN 0


******
*       ok_button
*
*       NOTA: - La funci¢n que llama a multibox debe definir la variable
*               "okee_dokee" que contiene una expresi¢n de caracteres
*               con el nombre de una funci¢n sin par metros (Ej. "function()")
*             - Esta funci¢n har  la tarea para la que se llam¢ a multibox y
*               devolver  .T. si acaba bien o .F. si no pudo terminar el
*               proceso con ‚xito
******
FUNCTION ok_button

PARAMETERS sysparam
local saveColor
PRIVATE ok, reply

* Cajas de ayuda secundarias
help_code = M->prime_help

* Inicializaci¢n de variables privadas
ok = " Aceptar "        && Como m¡nimo un bot¢n
reply = 2               && Se asume incompleto
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Inicializaci¢n o quitar el resaltado
		@ M->wt + M->wh, M->wl + 8 SAY M->ok

		IF M->sysparam = 1
			* Mostrar la posici¢n
			@ M->wt + M->wh, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resaltar
		SetColor(M->colorHilite)
		@ M->wt + M->wh, M->wl + 8 SAY M->ok

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* Seleccionado, pero s¢lo si se pulsa INTRO

		IF &okee_dokee
			* Proceso finalizado correctamente
			reply = 4

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN M->reply


******
*       can_button()
*
*       NOTA: Pulsando la tecla ESC se consigue el mismo efecto que
*             seleccionando el bot¢n Cancelar
******
FUNCTION can_button

PARAMETERS sysparam
local saveColor
PRIVATE can, reply

* Cajas de ayuda secundaria
help_code = M->prime_help

* Inicializaci¢n de variables privadas
can = " Cancelar "      && El bot¢n
reply = 2               && Se asume el fallo
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Inicializa o quita resaltado
		@ M->wt + M->wh, M->wl + 17 SAY M->can

		IF M->sysparam = 1
			* Mostrar posici¢n
			@ M->wt + M->wh, M->wl + 17 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resaltar
		saveColor := SetColor(M->colorHilite)
		@ M->wt + M->wh, M->wl + 17 SAY M->can

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* Si se selecciona con la tecla INTRO se cancela el proceso
		reply = 0

ENDCASE

SetColor(saveColor)
RETURN M->reply


******
*       filelist()
*
*       Selecciona un fichero de la lista de ficheros
******
FUNCTION filelist

PARAMETERS sysparam

RETURN itemlist(M->sysparam, 32, "filename", M->files, "*" + M->def_ext, .T.)


******
*       fieldlist()
*
*       Selecciona un campo de la lista de campos
******
FUNCTION fieldlist

PARAMETERS sysparam

RETURN itemlist(M->sysparam, 34, "field_mvar", "field_m", "Fields", .F.)


******
*       itemlist()
*
*       Selecciona un ¡tem de una lista
*
*       NOTA: - Este manejador de listas s¢lo responde a valores de sysparam
*               1 (Inicializar) y 2 (Resaltar)
*             - Dado que multibox() y achoice() esperan teclas, es 
*               necesario mediar un interfaz de usuario
*             - Cuando sysparam = 2, se da el control a achoice() y se
*               resuelve el estado de selecci¢n antes de devolver el control
*               a multibox()
******
FUNCTION itemlist

PARAMETERS sysparam, l_rel, mvar, items, i_title, go_ok
local saveColor
PRIVATE n, x, i_full

* Cajas de ayuda secundaria     
help_code = M->prime_help
saveColor := SetColor(colorNorm)

* Lectura del tama¤o de la lista
i_full = afull(&items)

DO CASE

	CASE M->sysparam = 1
		* Borrar y poner marco a las cajas
		scroll(M->wt + 1, M->wl + M->l_rel - 1, M->wt + M->wh, M->wl + 44, 0)
		@ M->wt, M->wl + M->l_rel - 2, M->wt + M->wh + 1, M->wl + 45;
		BOX M->lframe

		* Formato del t¡tulo de la lista
		i_title = REPLICATE("Ä", ((46 - M->l_rel - LEN(M->i_title)) / 2) - 1);
				  + " " + M->i_title + " "
		i_title = M->i_title + REPLICATE("Ä", (46 - M->l_rel - LEN(M->i_title)))

		* Visualizar el t¡tulo de la lista
		@ M->wt + 1, M->wl + M->l_rel - 1 SAY M->i_title

		IF .NOT. EMPTY(&items[1])
			* S¢lo visualizar..no esperar entrada de teclado
			achoice(M->wt + 2, M->wl + M->l_rel, M->wt + M->wh, M->wl + 43,;
					&items, .F., "i_func", M->cur_el, M->rel_row)

		ENDIF

		* Mostrar posici¢n
		@ M->wt + 2, M->wl + M->l_rel SAY ""

	CASE M->sysparam = 2
		* Resaltar

		IF EMPTY(&items[1])
			* No hay lista..vamos de vuelta
			KEYBOARD(CHR(219))

		ELSE
	    * Selecci¢n est ndar de lista..Lectura del primer elemento y de
	    * la columna
			cur_el = M->cur_el - M->rel_row + ROW() - M->wt - 2
			rel_row = ROW() - M->wt - 2

			* Lectura del elemento seleccionado o cero si se abandona
			n = achoice(M->wt + 2, M->wl + M->l_rel, M->wt + M->wh,;
			M->wl + 43, &items, .T., "i_func", M->cur_el,;
			M->rel_row)

			* Comprobar si hay petici¢n de men£
			sysmenu()

			DO CASE

				CASE M->keystroke = 13
					* Item seleccionado..lo dejamos en una variable
					&mvar = &items[M->n]

		    * Llamamos a la funci¢n espec¡fica de visualizaci¢n de
		    * lo seleccionado
					x = &fi_disp

					IF M->go_ok
						* Ir directamente al bot¢n "Ok" por conveniencia
						to_ok()

					ELSE
						* S¢lo pasar por encima y abajo
						KEYBOARD CHR(219) + CHR(24)

					ENDIF

				CASE M->keystroke = 19
		    * Flecha a la izquierda..Sale de la lista y va a     
		    * multibox(). No se puede enviar directamente Chr (19)
		    * porque se tratar¡a como ^S y bloquear¡a el sistema
					KEYBOARD CHR(219)

				CASE M->keystroke = 0
		    * Se ha seleccionado algo desde el men£ del sistema
		    * o bien se ha abandonado la selecci¢n

					IF M->local_func = 1
						* Se seleccion¢ "Ayuda" desde el men£ de sistema
						DO syshelp

					ENDIF

		    * Poner una tecla de "no hacer nada" para volver a entrar
		    * en el achoice()
					KEYBOARD CHR(11)

				OTHERWISE
					* que multibox() decida
					KEYBOARD CHR(M->keystroke)

			ENDCASE
		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*       i_func()
*
*       Funci¢n de usuario de achoice() para multibox
******
FUNCTION i_func

PARAMETERS amod, sel, rel
PRIVATE r, srow, scol

* Guardamos fila y columna actual
srow = ROW()
scol = COL()

IF M->error_on
	* Eliminamos el mensaje de error
	error_off()

ENDIF

IF M->amod = 4
	* No hay nada seleccionable
	r = 0

ELSE
	* Mantenimiento de las variables de filas y opciones
	cur_el = M->sel
	rel_row = M->rel

	* Se asume que continuamos
	r = 2

	* Leemos la £ltima tecla
	keystroke = LASTKEY()

ENDIF

IF M->cur_el > M->rel_row + 1
	* El primer elemento no est  en pantalla
	@ M->wt + 2, M->wl + 44 SAY M->more_up

ELSE
	* El primer elemento est  en pantalla
	@ M->wt + 2, M->wl + 44 SAY " "

ENDIF

IF M->i_full - M->cur_el > M->wh - 2 - M->rel_row
	* el £ltimo elemento no est  en pantalla
	@ M->wt + M->wh, M->wl + 44 SAY M->more_down

ELSE
	* El £ltimo elemento est  en pantalla
	@ M->wt + M->wh, M->wl + 44 SAY " "

ENDIF

IF M->amod = 3
	* Excepci¢n de teclado

	DO CASE

		CASE M->keystroke = 27
			* Con escape..abandonamos
			r = 0

		CASE M->keystroke = 13 .OR. M->keystroke = 19 .OR. M->keystroke = 219
			* Salir de achoice() sin abandonar..S¢lo la tecla INTRO seleccionar 
			r = 1

		CASE M->keystroke = 1
			* Tecla inicio..Inicio de la lista
			KEYBOARD CHR(31)        && ^ReP g

		CASE M->keystroke = 6
			* Tecla Fin..Fin de la lista
			KEYBOARD CHR(30)        && ^AvP g

		CASE isdata(M->keystroke)
			* Petici¢n de b£squeda de car cter
			r = 3

		CASE menu_key() <> 0
			* Salida al sistema de men£s
			r = 0

	ENDCASE
ENDIF

* Restaurar coordenadas de pantalla
@ M->srow, M->scol SAY ""

RETURN M->r


******
*       getfile()
*
*       Lectura directa del nombre de fichero en el campo de entrada
*
*       NOTA: - La funci¢n que llama a multibox () debe establecer el valor de
*               "filename", "def_ext" y "fi_done"
*             - fi_done contiene el nombre de una funci¢n que decide si el
*               nombre del fichero est  preparado para confirmar
******
FUNCTION getfile

PARAMETERS sysparam, row_off
local saveColor
PRIVATE irow, name_temp

* Algunas cajas tiene ayuda secundaria
help_code = M->prime_help

* C lculo de la fila absoluta
irow = M->wt + M->row_off
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualiza
		@ M->irow, M->wl + 2 SAY "Fichero " + pad(M->filename, 20)

		IF M->sysparam = 1
			* Muestra la posici¢n
			@ M->irow, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resalta
		SetColor(M->colorHilite)
		@ M->irow, M->wl + 10 SAY pad(M->filename, 20)

	CASE M->sysparam = 4
		* Seleccionado..se acepta la entrada

		IF M->keystroke <> 13
			* Sit£a la tecla pulsada al alcance del sistema GET
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* La flecha abajo sale del READ
		SET KEY 24 TO clear_gets

		* Llamada a la funci¢n que lee en su posici¢n
		name_temp = enter_rc(M->filename, M->irow, M->wl+10, 64, "@K!S19",M->color9)

		* Desactivar la tecla flecha abajo
		SET KEY 24 TO

		IF .NOT. EMPTY(M->name_temp)
			* Se ha entrado algo

			IF .NOT. (RAT(".", M->name_temp) > RAT("\", M->name_temp))
				* No se ha introducido la extensi¢n..Ponemos la extensi¢n por defecto
				name_temp = M->name_temp + M->def_ext

			ENDIF

			* Lo guardamos en una variable
			filename = M->name_temp

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 24
				* La entrada vac¡a se acepta
				M->filename = ""

			ENDIF
		ENDIF

		IF M->keystroke = 13
			* Entrada deliberada

			IF &fi_done
				* Se acepta lo entrado
				@ M->irow, M->wl + 10 SAY pad(M->filename, 20)

			ENDIF

		ELSE

			IF M->keystroke <> 27 .AND. .NOT. isdata(M->keystroke)
				* Si a£n queda algo..se env¡a la tecla a multibox   
				KEYBOARD CHR(M->keystroke)

			ENDIF
		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*       g_getfile()
*
*       Lee el nombre del fichero mediante la funci¢n filebox
******
FUNCTION g_getfile

PARAMETERS sysparam

RETURN getfile(M->sysparam, 4)


******
*       genfield()
*
*       Procesa la entrada en blanco del nombre del campo 
*       (Llamada as¡ncronamente desde multibox)
******
FUNCTION genfield

PARAMETERS sysparam, is_replace

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualiza
		@ M->wt + 3, M->wl + 2 SAY "Campo  " + pad(M->field_mvar, 20)

		IF M->sysparam = 1
			* Muestra posici¢n
			@ M->wt + 3, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2 .OR. M->sysparam = 4
		* No se permite entrada por parte del usuario..Anula el cursor

		IF M->lkey = 5
			* Movimiento hacia arriba 
			KEYBOARD CHR(4)

		ELSE
			* Movi‚ndonos a la izquierda desde la lista

			IF M->is_replace
				* Cambio de la opci¢n..vamos a la expresi¢n
				KEYBOARD CHR(24)

			ELSE
				* getfield v¡a set_view

				IF EMPTY(M->field_mvar)
					* Nada a seleccionar..Vamos a Cancelar
					to_can()

				ELSE
					* Vamos al Ok para la confirmaci¢n
					to_ok()

				ENDIF
			ENDIF
		ENDIF
ENDCASE

RETURN 2


******
*       get_exp()
*
*       Permite la entrada de una expresi¢n dBase general
*
*       NOTA: - La funci¢n que llama a multibox debe determinar el valor de la
*               variable cuyo nombre est  en el par metro "mvar"
*             - Esta funci¢n se usa en COPIAR, A¥ADIR, CAMBIAR e INDEXAR
******
FUNCTION get_exp

PARAMETERS sysparam, xlable, row_off, mvar
local saveColor
PRIVATE erow, k_input

* Calcular el valor absoluto de la fila
erow = M->wt + M->row_off
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualiza
		@ M->erow, M->wl + 2 SAY M->xlable + pad(&mvar, 18)

		IF M->sysparam = 1
			* Muestra la posici¢n
			@ M->erow, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resalta
		SetColor(M->colorHilite)
		@ M->erow, M->wl + 11 SAY pad(&mvar, 18)

	CASE M->sysparam = 4
		* Seleccionado..Se acepta la entrada

		IF M->keystroke <> 13
			* Adelantar la tecla al sistema de GETs
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* Flechas arriba y abajo salen del READ
		SET KEY 5 TO clear_gets
		SET KEY 24 TO clear_gets

		* Llamada a la funci¢n de entrada de datos
		k_input = enter_rc (&mvar, M->erow, M->wl + 11, 127, "@KS18", M->color9)

		* Desactivar flechas arriba y abajo
		SET KEY 5 TO
		SET KEY 24 TO

		IF .NOT. EMPTY(M->k_input)
			* Se ha entrado algo..Dej‚moslo en una variable
			&mvar = M->k_input

			IF M->keystroke <> 5 .AND. .NOT. isdata(M->keystroke)
				* Bajamos al pr¢ximo campo de entrada
				keystroke = 24

			ENDIF

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 5 .OR. M->keystroke = 24
				* Acepta una entrada en blanco
				&mvar = ""

			ENDIF
		ENDIF

		IF M->keystroke <> 13 .AND. M->keystroke <> 27 .AND.;
		   .NOT. isdata(M->keystroke)
			* ¨Algo m s?..Adelantemos la tecla a multibox
			KEYBOARD CHR(M->keystroke)

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*       not_empty()
*
*   Validaci¢n preliminar de la entrada est ndar de valores
******
FUNCTION not_empty

PARAMETERS mvar
PRIVATE done_ok

* Se acepta cualquier cosa que no sea vac¡a
done_ok = .NOT. EMPTY(&mvar)

IF M->done_ok
	* Preparado para la confirmaci¢n
	to_ok()

ENDIF

RETURN M->done_ok


******
*       filebox()
*
*       Selecci¢n general del nombre de fichero usando multibox    
******
FUNCTION filebox

PARAMETERS def_ext, files, titl_func, do_func, creat_flag, box_top
PRIVATE rel_row, cur_el, fi_disp, okee_dokee, fi_done, bcur

* Establece la matriz para multibox
DECLARE boxarray[5]

boxarray[1] = M->titl_func + "(sysparam)"
boxarray[2] = "g_getfile(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"
boxarray[5] = "filelist(sysparam)"

* Inicializaci¢n de variables privadas
cur_el = 1
rel_row = 0
fi_disp = "g_getfile(3)"
fi_done = "not_empty('filename')"
okee_dokee = M->do_func + "()"

IF M->creat_flag
	* Se asume que se introducir  un nombre de fichero nuevo

	IF EMPTY(filename)
		* El cursor al campo de entrada  
		bcur = 2

	ELSE
		* Comencemos en el bot¢n "Aceptar" para ir m s r pido
		bcur = 3

	ENDIF

ELSE
	* Se asume que se prefiere la selecci¢n en la lista
	bcur = 5

ENDIF

* Devuelve lo mismo que multibox
RETURN multibox(M->box_top, 17, 7, M->bcur, M->boxarray)


******
*       box_title()
*
*       Visualiza el t¡tulo de una caja de selecci¢n
******
FUNCTION box_title

PARAMETERS sysparam, boxtitle

IF M->sysparam = 1
	@ M->wt + 1, M->wl + 2 SAY M->boxtitle
	@ M->wt + 1, M->wl + 2 SAY ""

ENDIF

RETURN 2


******
*       get_k_trim()
*
*       Acepta valores car cter en la variable predefinida k_trim
*
*       NOTA: Esta funci¢n se usa en el movimento de los men£s de opciones
*             as¡ como para filtrar expresiones
******
FUNCTION get_k_trim

PARAMETERS sysparam, k_label
local saveColor
PRIVATE k_input

saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualizaci¢n
		@ M->wt + 3, M->wl + 2 SAY pad(M->k_label, 12) + pad(M->k_trim, 30)

		IF M->sysparam = 1
			* Mostrar posici¢n
			@ M->wt + 3, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resaltar
		SetColor(M->colorHilite)
		@ M->wt + 3, M->wl + 14 SAY pad(M->k_trim, 30)

	CASE M->sysparam = 4
		* Seleccionado..se acepta la entrada

		IF M->keystroke <> 13
			* Adelantamos la tecla al sistema de GETs
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* Flecha abajo sale de READ
		SET KEY 24 TO clear_gets

		* Llamada a la funci¢n de entrada de datos
		k_input = enter_rc(M->k_trim, M->wt + 3, M->wl + 14, 127, "@KS30",;
		M->color9)

		* Desactivar la tecla flecha abajo
		SET KEY 24 TO

		IF .NOT. EMPTY(M->k_input)
			* Se ha entrado algo..pong moslo en una variable
			k_trim = M->k_input

			* Vamos al bot¢n "Ok"
			keystroke = 24

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 24
				* Aceptamos entradas vac¡as
				k_trim = ""

				* Vamos al bot¢n "Ok"
				keystroke = 24

			ENDIF
		ENDIF

		IF M->keystroke <> 13 .AND. M->keystroke <> 27 .AND.;
		   .NOT. isdata(M->keystroke)
			* ¨Algo m s?..Adelantamos la tecla a multibox
			KEYBOARD CHR(M->keystroke)

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


*******************************
* Sistema de men£ de persiana *
*******************************

******
*       sysmenu()
*
*       Administra el sistema de men£es de persiana
*
*       Devuelve: .T. si se ha seleccionado algo o hay tecla disponible
*
*       NOTA: - Los t¡tulos de los men£s son los mismos que los que aparecen
*               en la parte superior de la pantalla
*             - Estos t¡tulos est n almacenados en una matriz global llamada
*               func_title[] 
*             - Para cada t¡tulo hay una pareja de matrices asociadas cuyos 
*               nombres son &a._m[] y &a._b[] donde a = func_title[curr menu]
*             - Las matrices _m contienen las opciones del men£ y las _b 
*               determinan la seleccionabilidad de estas opciones de acuerdo
*               con las normas dictadas por achioce ()
******
FUNCTION sysmenu
local saveColor
PRIVATE menu_func,menu_sel,menu_buf,a,ml,mr,mb,prev_func,sav_row,sav_col,x

IF M->keystroke = 0
	* No ha pasado nada
	RETURN .F.

ENDIF

* ¨Qu‚ men£?
menu_func = menu_key()

* Siempre se reconfigura la variable global de selecci¢n
local_func = 0

IF M->menu_func = 0
	* No hay men£..Teclas 
	RETURN .T.

ENDIF

***********************************
* Entramos en el sistema de men£s *
***********************************

* Salva las coordenadas de pantalla
sav_row = ROW()
sav_col = COL()

IF M->error_on
	* Borramos el mensaje de error
	error_off()

ENDIF

* Inicializa las variables del proceso de selecci¢n
menu_sel = 0
prev_func = 0
x = M->menu_func
saveColor := SetColor()

* Abandonar o seleccionar
DO WHILE M->menu_func > 0 .AND. M->menu_sel = 0
	* Evitamos el redibujo si el men£ ya est  visualizado
	IF M->menu_func <> M->prev_func
		* Lo desplegamos
		lite_fkey(M->menu_func)             && Resaltar t¡tulo
		prev_func = M->menu_func            && Para la pr¢xima iteraci¢n
		a = func_title[M->menu_func]        && Leer nombre del men£ actual
		ml = (10 * (M->menu_func - 1)) + 1  && C lculo de la coordenada izquierda
		mr = ((10 * M->menu_func) - 2)      && C lculo de la coordenada derecha
		mb = (2 + LEN(&(a+"_m")))           && C lculo la l¡nea inferior

		* Salvamos la porci¢n de pantalla
		menu_buf = SAVESCREEN(2, M->ml - 1, M->mb + 1, M->mr + 1)

		* Dibujamos el marco del men£ correspondiente
		SetColor(M->color6)
		@ 2, M->ml - 1, M->mb + 1, M->mr + 1 BOX M->mframe

	ENDIF

	* Llamada a achoice() para realizar la selecci¢n
	SetColor(M->color5)
	menu_sel = achoice(3, M->ml, M->mb, M->mr, &(a+"_m"), &(a+"_b"), "mu_func",;
	menu_deflt[M->menu_func], menu_deflt[M->menu_func] - 1)

	* V‚ase mu_func() abajo para la configuraci¢n de la tecla y de x
	DO CASE

		CASE M->keystroke = 27
			* abandonar
			menu_func = 0

		CASE M->keystroke = 4
			* Flecha a la derecha->pr¢ximo men£
			menu_func = IF(M->menu_func < 8, M->menu_func + 1, 1)

		CASE M->keystroke = 19
			* Flecha a la izquierda->men£ anterior
			menu_func = IF(M->menu_func > 1, M->menu_func - 1, 8)

		CASE M->x <> 0
			* Acceso directo a otro men£
			menu_func = M->x

	ENDCASE

	IF M->menu_func <> M->prev_func .OR. M->menu_sel <> 0
		* Otro men£ o ninguno..restauramos la pantalla
		dim_fkey(M->prev_func)
		RESTSCREEN(2, M->ml - 1, M->mb + 1, M->mr + 1, M->menu_buf)

	ENDIF
ENDDO

IF M->menu_func <> 0
	* La £ltima opci¢n seleccionada ser  la opci¢n por defecto
	menu_deflt[M->menu_func] = M->menu_sel

ENDIF

IF LTRIM(STR(M->menu_func)) $ M->exit_str
	* La selecci¢n requiere una bifurcaci¢n de alto nivel
	sysfunc = M->menu_func
	func_sel = M->menu_sel

ELSE
	* La selecci¢n puede tratarse localmente
	local_func = M->menu_func
	local_sel = M->menu_sel

ENDIF

* Restauramos la posici¢n del cursor
@ M->sav_row,M->sav_col SAY ""

* Para que no haya posible confusi¢n
keystroke = 0
SetColor(saveColor)

* Devuelve .T. si se seleccion¢ algo
RETURN menu_func <> 0


******
*       menu_key()
*
*       Traduce la tecla a un n£mero de men£ o a cero si no la hay
******
FUNCTION menu_key

PRIVATE num

* Se asume que no se requiere men£
num = 0

DO CASE

	CASE M->keystroke = 28
		* F1
		num = 1

	CASE M->keystroke < 0 .AND. M->keystroke > -8
		* F2 - F8 (ex. 1 - (-1) = 2)
		num = 1 - M->keystroke

	CASE M->keystroke >= 249 .AND. M->keystroke < 256
		* F2 - F8..Teclas de funci¢n truncadas por la funci¢n Chr ()
		*       (ex. chr(-1) = chr(255)..257 - 255 = 2)
		num = 257 - M->keystroke

ENDCASE

RETURN M->num


******
*       mu_func()
*
*       Funci¢n de usuario para achoice para el sistema de men£s de persiana
******
FUNCTION mu_func

PARAMETERS amod, sel, rel
PRIVATE r

IF M->amod = 4
	* Nada seleccionable..esperamos una tecla
	keystroke = INKEY(0)

	* Abandonamos el proceso de selecci¢n
	r = 0

ELSE
	* Lectura de la £ltima tecla
	keystroke = LASTKEY()

	* Se asume la continuaci¢n del proceso de selecci¢n
	r = 2

ENDIF

* Si se puls¢ una tecla de men£
x = menu_key()

IF M->amod = 3
	* Excepci¢n de tecla

	DO CASE

		CASE M->keystroke = 13 .OR. M->x = M->menu_func
			* Tecla INTRO o la misma selecci¢n de men£..Seleccionar
			r = 1

		CASE M->keystroke = 27 .OR. M->keystroke = 19 .OR.;
			 M->keystroke = 4 .OR. M->x <> 0
	    * Se ha seleccionado otro men£ distinto o bien ninguno.
	    * Abandonamos el actual
			r = 0

		CASE M->keystroke = 1
			* Tecla inicio..Principio de la lista
			KEYBOARD CHR(31)

		CASE M->keystroke = 6
			* Tecla Fin..Final de la lista
			KEYBOARD CHR(30)

		CASE isdata(M->keystroke)
			* Petici¢n de selecci¢n de opci¢n a trav‚s del car cter inicial
			r = 3

	ENDCASE
ENDIF

RETURN M->r


******
*       show_keys()
*
*       Visualiza los men£es de funci¢n disponibles en cada momento
******
FUNCTION show_keys

PRIVATE n

* Borra la l¡nea
@ 1, 0

FOR n = 1 TO 8
	* Visualiza los t¡tulos de los men£s de funci¢n
	@ 1,1 + (10 * (M->n - 1)) SAY func_title[M->n]

NEXT

RETURN 0


******
*       xkey_clear()
*
*       Provoca que todas las teclas de men£ eliminen los GETs pendientes y
*       abandonen el READ actual
******
FUNCTION xkey_clear

PRIVATE i

* F1
SET KEY 28 TO clear_gets

FOR i = 1 TO 7
	* F2 - F8
	SET KEY -(M->i) TO clear_gets

NEXT

RETURN 0


******
*       xkey_norm()
*
*       Provoca que todas la teclas de men£ retornen a estado normal despu‚s de
*       un clear_gets
******
FUNCTION xkey_norm

PRIVATE i

* F1
SET KEY 28 TO

FOR i = 1 TO 7
	* F2 - F8
	SET KEY -(M->i) TO

NEXT

RETURN 0


/*****
*       lite_fkey()
*
*       Resalta la etiqueta de la tecla de funci¢n especificada
*/
func lite_fkey(k_num)
local saveColor
memvar color6

	saveColor := SetColor(M->color11)
	@ 1, (10 * (k_num - 1)) say " " + func_title[k_num] + " "
	SetColor(saveColor)

return (0)


/*****
*       dim_fkey()
*
*       Elimina el resaltado de la etiqueta de la tecla de funci¢n especificada
*/
func dim_fkey(k_num)
local saveColor
memvar color1

	saveColor := SetColor(M->color1)
	@ 1, (10 * (k_num - 1)) say " " + func_title[k_num] + " "
	SetColor(saveColor)

return (0)


******
*       key_ready()
*
*       Devuelve .T. si la tecla est  preparada o el men£ seleccionado
******
FUNCTION key_ready

* Almacena la tecla previamente pulsada
lkey = M->keystroke

* Lee una nueva tecla si est  preparada
keystroke = INKEY()

RETURN (sysmenu() .OR. M->keystroke <> 0)


******
*       read_key()
*
*       Espera una tecla o una selecci¢n de men£
******
FUNCTION read_key

DO WHILE .NOT. key_ready()
	* Espera una tecla o una selecci¢n de men£

ENDDO

IF M->error_on
	* Borra el mensaje de error
	error_off()

ENDIF

RETURN M->keystroke


******
*       raw_key()
*
*       Espera y devuelve la pr¢xima tecla sin comprobar la selecci¢n de men£
******
FUNCTION raw_key

PRIVATE k

* Espera una tecla
k = INKEY(0)

IF M->error_on
	* Borra el mensaje de error
	error_off()

ENDIF

RETURN k


******
*       q_check()
*
*       Devuelva .T. para causar la salida de una rutina
*
*       NOTA: cur_func se trata igual que sysfunc durante el bucle principal
*             del programa
******
FUNCTION q_check

RETURN (M->cur_func <> M->sysfunc .OR. M->keystroke = 27)


******
*       clear_gets
*
*       Redirecciona las teclas a esta funci¢n para salir de los READ
******
PROCEDURE clear_gets
PARAMETERS dummy1,dummy2,dummy3

CLEAR GETS
RETURN


******
*       all_fields()
*
*       Llena la matriz de campos con todos los campos de un  rea determinada
******
FUNCTION all_fields

PARAMETERS work_area,field_a

stat_msg("Leyendo la estructura del fichero")

* Se necesitar  ensamblar la lista principal de campos
need_field = .T.

* Selecci¢n del  rea de trabajo
SELECT (M->work_area)

* Llenado de la matriz con los nombres de los campos.
* La matriz se acabar  de rellenar con matrices vac¡as
afill(M->field_a, "", afields(M->field_a) + 1)

* Borrado del mensaje de estado y retorno
stat_msg("")
RETURN 0


******
*       not_target()
*
*       Se borran las relaciones donde se indique que el  rea de trabajo es
*       la destino de una relaci¢n
******
FUNCTION not_target

PARAMETERS n, do_del
PRIVATE i

i = 1

DO WHILE M->i <= LEN(M->k_relate)
	* B£squeda en la lista de relaciones

	IF EMPTY(k_relate[M->i])
		* Fin de lista
		EXIT

	ENDIF

	IF t_relate[M->i] == CHR(M->n + ASC("A") - 1) + name(dbf[M->n])
		* El alias es destino de una relaci¢n
		need_relat = .T.

		* Seleccionar el  rea de trabajo fuente de esta relaci¢n
		SELECT (M->n)

		* Desactivar la relaci¢n
		SET RELATION TO

		IF M->do_del
			* La relaci¢n no se reactivar ..La eliminamos de la lista
			array_del(M->s_relate,M->i)
			array_del(M->k_relate,M->i)
			array_del(M->t_relate,M->i)

		ELSE
			* Elemento siguiente
			i = M->i + 1

		ENDIF

	ELSE
		* El alias no es destino de ninguna relaci¢n
		i = M->i + 1

	ENDIF
ENDDO

RETURN 0


******
*       dup_ntx()
*
*       Devuelve el  rea de trabajo donde se usa el ¡ndice o cero si no est  en
*       uso
******
FUNCTION dup_ntx

PARAMETERS ntx_file
PRIVATE ntx, i

i = 1

DO WHILE M->i <= 6

	IF EMPTY(dbf[M->i])
		* No hay m s  reas de trabajo activas
		EXIT

	ENDIF

	* Acceso a una lista de ficheros ¡ndice
	ntx = "ntx" + SUBSTR("123456", M->i, 1)

	IF aseek(&ntx, M->ntx_file) > 0
		* El fichero ¡ndice est  abierto
		RETURN M->i

	ENDIF

	* Proceso del  rea siguiente
	i = M->i + 1

ENDDO

RETURN 0


/*****
*       stat_msg()
*
*       Visualizaci¢n del mensaje de estado
*/
func stat_msg(string)
local saveColor

	/* Se sobreescribe totalmente la fila */
	saveColor := SetColor(M->color1)
	@ 3,0 say Pad(string,80)
	SetColor(saveColor)

return (0)


/*****
*       error_msg()
*
*       Visualiza el mensaje de error y da valor a la variable global
*       para borrar el mensaje en la pr¢xima tecla
*/
func error_msg(string)
local saveColor

	/* Alta intensidad en el mensaje de error */
	saveColor := SetColor(M->color3)
	@ 3,0 say string

	/* Borra el resto de la fila de mensaje */
	SetColor(M->color1)
	@ Row(), Col()

	/* La pr¢xima tecla borrar  el mensaje */
	error_on = .T.
	SetColor(saveColor)

return (0)


/*****
*       error_off()
*
*       Borra el mensaje de error
*/
func error_off
local saveColor

	/* Cambia el valor global */
	error_on = .F.

	/* Borra la l¡nea de mensaje */
	saveColor := SetColor(M->color1)
	@ 3,0
	SetColor(saveColor)

return (0)


******
*       rsvp()
*
*       Lee y devuelve una respuesta S¡ o No (o ESC)
******
FUNCTION rsvp

PARAMETERS string
PRIVATE c

* Inicializaci¢n de la variable local
c = " "

* Si/No/Esc
DO WHILE .NOT. (M->c $ "SN" + CHR(27))
	* Visualiza el mensaje en resaltado como un mensaje de error
	error_msg(M->string + "  ")

	* Sit£a el cursor al final del mensaje
	@ 3,LEN(M->string) + 1 SAY ""

	* Deja el cursor visible
	SET CURSOR ON

	* Lee la respuesta y borra el mensaje
	c = UPPER(CHR(raw_key()))

	IF .NOT. M->curs_on
		* Eliminamos el cursor
		SET CURSOR OFF

	ENDIF
ENDDO

RETURN M->c


******
*       name()
*
*       Extrae el nombre del fichero de la v¡a completa
******
FUNCTION name

PARAMETERS spec
PRIVATE p

* Aisla el nombre del fichero de la v¡a entera
p = SUBSTR(M->spec, RAT("\", M->spec) + 1)

IF "." $ M->p
	* Si hay extensi¢n, la eliminamos
	p = SUBSTR(M->p, 1, AT(".", M->p) - 1)

ENDIF

RETURN M->p


******
*       pad()
*
*       Fuerza que una cadena tenga una longitud determinada
*
*       NOTA: - Si la cadena es de longitud mayor, se trunca
*             - Si la cadena es de longitud menor, se le a¤aden espacios
*               por la derecha
******
FUNCTION pad

PARAMETERS s, n

RETURN SUBSTR(M->s + SPACE(M->n), 1, M->n)


******
*       aseek()
*
*       Busca un elemento en una matriz..devuelve cero si no lo encuentra
*
*       NOTA: s¢lo se tratar n elementos no nulos
******
FUNCTION aseek

PARAMETERS array, exp
PRIVATE pos, num_el

* Lectura del n£mero de elementos no vac¡os
num_el = afull(M->array)

IF M->num_el = 0
	* No se encuentra nada si la matriz est  vac¡a
	RETURN 0

ENDIF

* Ejecuta una b£squeda exacta
SET EXACT ON

* Ascan devolver  cero si no se encuentra
pos = ascan(M->array, M->exp, 1, M->num_el)

* De vuelta al estado normal
SET EXACT OFF

RETURN M->pos


******
*       array_ins()
*
*       Desplaza los elementos hacia arriba e inserta un ""
*
*       NOTA: La £nica diferencia entre esta funci¢n y aIns() es que
*             ‚sta inserta un elemento de tipo car cter
******
FUNCTION array_ins

PARAMETERS array, pos

* Inserci¢n de un nuevo elemento
ains(M->array, M->pos)

* Asignamos una cadena vac¡a al nuevo elemento
array[M->pos] = ""

RETURN 0


******
*       array_del()
*
*       Desplaza los elementos hacia abajo y asigna a matriz[len(matriz)] = ""
*
*       NOTA: La £nica diferencia entre esta funci¢n y aDel() es que ‚sta
*             asigna una cadena vac¡a al £ltimo elemento
******
FUNCTION array_del

PARAMETERS array, pos

* Borra el elemento determinado
adel(M->array, M->pos)

* Asigna una cadena vac¡a al £ltimo elemento
array[LEN(M->array)] = ""

RETURN 0


******
*       afull()
*
*       Encuentra el n£mero de elementos contiguos no vac¡os
******
FUNCTION afull

PARAMETERS array
PRIVATE i

* Ejecuta una b£squeda exacta
SET EXACT ON

* Buscamos una cadena vac¡a
i = ascan(M->array, "")

* De vuelta al estado normal
SET EXACT OFF

IF M->i = 0
	* Sin cadenas vac¡as, implica totalmente lleno
	i = LEN(M->array)

ELSE
	* El elemento con la cadena vac¡a es el anterior
	i = M->i - 1

ENDIF

RETURN M->i


******
*       array_sort()
*
*       Ordena los elementos contiguos no vac¡os
******
FUNCTION array_sort

PARAMETERS array

* Se ordenan s¢lo los elementos no vac¡os
asort(M->array, 1, afull(M->array))

RETURN 0


******
*       array_dir()
*
*       Prepara un array ordenado de nombres de fichero que cumplen el patr¢n
******
FUNCTION array_dir

PARAMETERS skeleton, array

* Comenzamos por una matriz vac¡a
afill(M->array, "")

* Llena la matriz con los nombres de ficheros
adir(M->skeleton, M->array)

* Ordena la matriz
array_sort(M->array)

RETURN 0


******
*       ntx_key(filename)
*
*       Lee la clave de un fichero ¡ndice
*
*       NOTA: Se asume que el ¡ndice es v lido
******
FUNCTION ntx_key

PARAMETERS filename
PRIVATE k, buffer, handle, k_pos

* Inicializaci¢n de variables para tratar las expresiones
k = ""

IF FILE(M->filename)
	* S¢lo si existe el fichero

	IF INDEXEXT() = ".NTX"
		* Fichero ¡ndice de CA-Clipper
		k_pos = 23

	ELSE
		* Fichero ¡ndice de dBase III+
		k_pos = 25

	ENDIF

	* Abre el fichero y lee su descriptor
	handle = FOPEN(M->filename)

	IF FERROR() = 0
		* Creamos un buffer de 512 bytes
		buffer = SPACE(512)

		* Leemos la cabecera del fichero ¡ndice en memoria
		FREAD(M->handle, @buffer, 512)

		* Descartamos los bytes anteriores a la expresi¢n clave
		k = SUBSTR(M->buffer, M->k_pos)

		* La expresi¢n clave acaba en un Chr (0)
		k = TRIM(SUBSTR(M->k, 1, AT(CHR(0), M->k) - 1))

	ENDIF

	* Cerramos el fichero 
	FCLOSE(M->handle)

ENDIF

RETURN M->k


******
*       isdata()
*
*       Determina si la expresi¢n clave cabe en la cabecera
******
FUNCTION isdata

PARAMETERS k

RETURN (M->k >= 32 .AND. M->k < 249 .AND. M->k <> 219 .AND. CHR(M->k) <> ";")


******
*       lpad()
*
*       Rellena con espacios por la izquierda
*
*       NOTA: Esta rutina fallar  si la longitud requerida es menor que la 
*             de la cadena
******
FUNCTION lpad

PARAMETERS string,n

RETURN (SPACE(M->n - LEN(M->string)) + M->string)


******
*       hi_cur()
*
*       Resalta el nombre de fichero de datos actualmente seleccionado
******
FUNCTION hi_cur
local saveColor

IF M->cur_area > 0
	* Escribe sobre la pantalla principal de la vista
	saveColor := SetColor(M->color2)
	@ row_a[1], column[M->cur_area] + 2 SAY pad(name(M->cur_dbf), 8)
	SetColor(saveColor)

ENDIF

RETURN 0


******
*       dehi_cur()
*
*       Revisualiza el nombre del fichero actual para dejarlo en no resaltado
******
FUNCTION dehi_cur
local saveColor

IF M->cur_area > 0
	* Escritura en la pantalla principal de la vista
	saveColor := SetColor(M->color1)
	@ row_a[1], column[M->cur_area] + 2 SAY pad(name(M->cur_dbf), 8)
	SetColor(saveColor)

ENDIF

RETURN 0


******
*       enter_rc()
*
*       Entrada de datos
******
FUNCTION enter_rc

PARAMETERS org_str, r, c, max_len, pfunc, cString
local saveColor
PRIVATE wk_str

* Las teclas del men£ saldr n de los READ
xkey_clear()

* La cadena de trabajo se inicializa a la principal
wk_str = pad(M->org_str, M->max_len)
SET CURSOR ON
saveColor := SetColor(M->cString)

IF .NOT. EMPTY(M->pfunc)
	* Ejecuta un GET con entrada formateada
	@ r, c GET M->wk_str PICTURE M->pfunc

ELSE
	* sin entrada formateada
	@ r, c GET M->wk_str

ENDIF

* Aceptamos la entrada de datos
READ
SET CURSOR OFF

* Almacenamos la tecla de salida en la variable global
keystroke = LASTKEY()

* Desactivar teclas de men£
xkey_norm()

IF M->error_on
	* Borramos mensaje de error
	error_off()

ENDIF

IF M->keystroke = 27 .OR. menu_key() <> 0
	* Entrada abandonada..Devolvemos una cadena nula
	wk_str = ""

ENDIF

SetColor(saveColor)
RETURN TRIM(M->wk_str)


* Fin de Fichero: UTIL.PRG
