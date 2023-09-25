/***
*
*  Dbucopy.prg
*
*  M¢dulo de copia bases de datos y de adici¢n de registros de la utilidad 
*  DBU
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.
*
*/


******
*       capprep
*
*       copia/adici¢n/sustituci¢n
*
*       Nota: v‚ase multibox en el m¢dulo DBUUTIL.PRG
******
PROCEDURE capprep

PRIVATE filename, files, fi_disp, okee_dokee, cur_el, rel_row, def_ext, mode,;
		fi_done, for_cond, while_cond, how_many, bcur, for_row, height,;
		field_mvar, with_what

IF M->func_sel = 3
	* Mandato CAMBIAR (REPLACE)
	help_code = 22

	* Selecci¢n de la actual  rea de trabajo
	SELECT (M->cur_area)

    * Inicializaci¢n de las variables que contienen el nombre del campo y
    * la nueva expresi¢n a asignar
	field_mvar = ""
	with_what = ""

    * Guarda la lista de campos principal en una matriz local para poderlos 
    * seleccionar
	DECLARE field_m[FCOUNT()]
	all_fields(M->cur_area, M->field_m)

	* Configuraci¢n para multi-box
	DECLARE boxarray[9]
	boxarray[1] = "repl_title(sysparam)"
	boxarray[2] = "repl_field(sysparam)"
	boxarray[3] = "with_exp(sysparam)"
	boxarray[4] = "for_exp(sysparam)"
	boxarray[5] = "while_exp(sysparam)"
	boxarray[6] = "scope_num(sysparam)"
	boxarray[7] = "ok_button(sysparam)"
	boxarray[8] = "can_button(sysparam)"
	boxarray[9] = "fieldlist(sysparam)"

	* Tama¤o y configuraci¢n
	bcur = 9                        && El cursor comenzar  en la lista de campos
	for_row = 6
	height = 10
	okee_dokee = "do_replace()"
	fi_disp = "repl_field(3)"

ELSE
	* Inicializaci¢n del nombre del fichero
	filename = ""

	* S¢lo COPIAR y CAMBIAR pueden usar ficheros de texto
	DECLARE txt_list[adir("*.TXT") + 20]      && Directorio de los ficheros de texto
	array_dir("*.TXT",txt_list)               && Llena matrices con los nombres de fichero

	* Configuraci¢n para multibox
	DECLARE boxarray[10]

	IF M->func_sel = 1
		* Mandato COPIAR
		help_code = 12
		bcur = 2                        && El cursor comienza en el campo de entrada del nombre de fichero
		boxarray[1] = "copy_title(sysparam)"
		boxarray[2] = "trg_getfil(sysparam)"
		fi_disp = "trg_getfil(3)"
		okee_dokee = "do_copy()"

	ELSE
		* Mandato A¥ADIR
		help_code = 15
		bcur = 10                       && El cursor comienza en la lista de selecci¢n
		boxarray[1] = "appe_title(sysparam)"
		boxarray[2] = "src_getfil(sysparam)"
		fi_disp = "src_getfil(3)"
		okee_dokee = "do_append()"

	ENDIF

	* El resto de configuraci¢n es com£n a COPIAR y a A¥ADIR
	boxarray[3] = "for_exp(sysparam)"
	boxarray[4] = "while_exp(sysparam)"
	boxarray[5] = "scope_num(sysparam)"
	boxarray[6] = "tog_sdf(sysparam)"
	boxarray[7] = "ok_button(sysparam)"
	boxarray[8] = "tog_delim(sysparam)"
	boxarray[9] = "can_button(sysparam)"
	boxarray[10] = "filelist(sysparam)"

	* Tama¤o y configuraci¢n
	for_row = 5
	height = 11

	* Ficheros DBF para modo normal
	files = "dbf_list"
	def_ext = ".DBF"

	* ¨Cu ndo es aceptable un nombre de fichero?
	fi_done = "not_empty('filename')"

ENDIF

* Inicializaci¢n de variables locales
STORE "" TO for_cond, while_cond

* Modo normal, con  mbito en toda la base de datos, desde el principio del
* fichero
STORE 1 TO mode,cur_el
rel_row = 0
how_many = 0

* Ejecuci¢n de multibox
multibox(8, 17, M->height, M->bcur, M->boxarray)
RETURN


*********************************
* Funciones espec¡ficas de COPY *
*********************************

******
*       copy_title()
*
*       Visualizaci¢n del t¡tulo para "COPIAR"
******
FUNCTION copy_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Copiar " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " a..")


******
*       trg_getfil()
*
*       Fichero destino para "COPIAR"
******
FUNCTION trg_getfil

PARAMETERS sysparam

help_code = M->prime_help
RETURN getfile(M->sysparam, 3)


******
*       do_copy()
*
*       Ejecuci¢n del mandato "COPIAR"
*
*       NOTA: Esta funci¢n se llama cuando se pulsa INTRO
*                 mientras el cursor est‚ en el bot¢n "Ok"
******
FUNCTION do_copy

PRIVATE done, add_name, new_el

* Por defecto incompleto
done = .F.

DO CASE

	CASE EMPTY(M->filename)
		error_msg("No se seleccion¢ fichero destino de la copia")

	CASE M->filename == M->cur_dbf
		error_msg("Un fichero no puede copiarse sobre s¡ mismo")

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("La condici¢n SI debe ser una expresi¢n l¢gica")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("La condici¢n MIENTRAS debe ser una expresi¢n l¢gica")

	OTHERWISE
		* Vamos a COPIAR 

		IF FILE(M->filename)

			IF rsvp("El fichero destino" + IF(aseek(M->dbf, M->filename) > 0,;
					"est  abierto", "ya existe") + "...¨Sobreescribo? (S/N)") <> "S"
				RETURN .F.

			ENDIF
		ENDIF

		stat_msg("Copiando")

		IF aseek(M->dbf, M->filename) > 0
			* Copiando a un fichero abierto, ­buena suerte!
			SELECT (aseek(M->dbf, M->filename))
			USE
			STORE .T. TO need_field,need_ntx,need_relat,need_filtr

		ENDIF

		SELECT (M->cur_area)

		IF RAT(M->def_ext, M->filename) = LEN(M->filename) - 3
	    * El fichero destino tiene la extensi¢n por defecto. Existe en
	    * el directorio actual
			add_name = .NOT. FILE(name(M->filename) + M->def_ext)

		ELSE
			add_name = .F.

		ENDIF

		IF EMPTY(M->for_cond)
			* Un .T. es equivalente a no tener condici¢n SI
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* La condici¢n literal .T. s¢lo vale desde el inicio del fichero
			while_cond = ".T."

			IF M->how_many = 0
				* A menos que se haya introducido un  mbito
				GO TOP

			ENDIF
		ENDIF

		DO CASE

			CASE M->mode = 1 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond

			CASE M->mode = 1 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond

			CASE M->mode = 2 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond;
						SDF

			CASE M->mode = 2 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond SDF

			CASE M->mode = 3 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond;
						DELIMITED

			CASE M->mode = 3 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond DELIMITED

		ENDCASE

		IF aseek(M->dbf, M->filename) > 0
			* Copiando a un fichero abierto, ­buena suerte de nuevo!
			SELECT (aseek(M->dbf, M->filename))
			USE &filename

		ENDIF

		IF FILE(name(M->filename) + M->def_ext) .AND. M->add_name
			* A¤adir s¢lamente los ficheros .DBF del directorio actual
			new_el = afull(&files) + 1

			IF M->new_el <= LEN(&files)
				&files[M->new_el] = M->filename
				array_sort(&files)

			ENDIF
		ENDIF

		stat_msg("Fichero copiado")
		done = .T.

ENDCASE

RETURN M->done


***********************************
* Funciones espec¡ficas de A¥ADIR *
***********************************

******
*       appe_title()
*
*       Visualizaci¢n del t¡tulo para "A¥ADIR"
******
FUNCTION appe_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "A¤adir a " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " desde")


******
*       src_getfil()
*
*       Nombre del fichero fuente a "A¥ADIR"
******
FUNCTION src_getfil

PARAMETERS sysparam

help_code = M->prime_help
RETURN getfile(M->sysparam, 3)


******
*       do_append()
*
*       Ejecuci¢n del mandato "APPEND"
*
*       Nota: Esta funci¢n se llama cuando se pulsa <INTRO> mientras
*                 el cursor se encuentre sobre el bot¢n "Ok"
******
FUNCTION do_append

PRIVATE done

* Se asume el peor de los casos
done = .F.

DO CASE

	CASE EMPTY(M->filename)
		error_msg("No hay fichero fuente seleccionado")

	CASE M->filename == M->cur_dbf
		error_msg("No puede a¤adirse un fichero desde el mismo")

	CASE .NOT. FILE(M->filename)
		error_msg("No puedo abrir " + M->filename)

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("La condici¢n SI debe ser una expresi¢n l¢gica")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("La condici¢n MIENTRAS debe ser una expresion l¢gica")

	OTHERWISE
		* Vamos a A¥ADIR

		IF aseek(M->dbf, M->filename) > 0
			* Se a¤ade desde un fichero abierto
			SELECT (aseek(M->dbf, M->filename))
			USE
			STORE .T. TO need_field,need_ntx,need_relat,need_filtr

		ENDIF

		stat_msg("A¤adiendo")
		SELECT (M->cur_area)

		IF EMPTY(M->for_cond)
			* Un .T. literal es lo mismo que no tener condici¢n SI
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* Un .T. literal es lo mismo que no tener condici¢n MIENTRAS
			while_cond = ".T."

		ENDIF

		DO CASE

			CASE M->mode = 1 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond

			CASE M->mode = 1 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond

			CASE M->mode = 2 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond SDF

			CASE M->mode = 2 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond SDF

			CASE M->mode = 3 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond DELIMITED

			CASE M->mode = 3 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond DELIMITED

		ENDCASE

		IF aseek(M->dbf, M->filename) > 0
			* Se a¤aden registros desde un fichero abierto
			SELECT (aseek(M->dbf, M->filename))
			USE &filename

		ENDIF

		stat_msg("La operaci¢n adici¢n de registros se ha completado")
		done = .T.

ENDCASE

RETURN M->done


************************************
* Funciones espec¡ficas de CAMBIAR *
************************************

******
*       repl_title()
*
*       Visualiza el t¡tulo para "CAMBIAR"
******
FUNCTION repl_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Cambiar en " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  "...")


******
*       repl_field()
*
*       Lectura del campo a cambiar (S¢lo puede modificarse un campo cada vez)
******
FUNCTION repl_field

PARAMETERS sysparam

help_code = M->prime_help
RETURN genfield(M->sysparam, .T.)


******
*       with_exp()
*
*       Lectura de la condici¢n CON para CAMBIAR
******
FUNCTION with_exp

PARAMETERS sysparam
PRIVATE rval

help_code = M->prime_help
rval = get_exp(M->sysparam, "POR      ", 4, "with_what")

IF M->sysparam = 4 .AND. LASTKEY() = 13 .AND. .NOT. EMPTY(M->with_what)
	* La expresi¢n acaba de leerse..quitar el resaltado y saltar a "Ok"
	get_exp(3, "POR      ", 4, "with_what")
	to_ok()

ENDIF

RETURN M->rval


******
*       do_replace()
*
*       Ejecuci¢n del mandato CAMBIAR
*
*       NOTA: Esta funci¢n se llama cuando se pulsa <INTRO>
*                 mientras el cursor se encuentra en el bot¢n "Ok"
******
FUNCTION do_replace

PRIVATE done

* Asumimos lo peor 
done = .F.

DO CASE

	CASE EMPTY(M->field_mvar)
		error_msg("No hay campo seleccionado")

	CASE EMPTY(M->with_what)
		error_msg("No se ha introducido la expresi¢n de cambio")

	CASE TYPE(M->with_what) <> TYPE(M->field_mvar) .and. ;
		!(TYPE(M->field_mvar) == "M") .and. ;
		!(TYPE(M->with_what) == "UI")
		error_msg("Error de tipo entre la expresi¢n de cambio y el campo")

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("La condici¢n SI debe ser una expresi¢n l¢gica")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("La condici¢n MIENTRAS debe ser una expresi¢n l¢gica")

	OTHERWISE
		* Vamos a realizar el cambio
		stat_msg("Cambiando datos")

		IF EMPTY(M->for_cond)
			* Un .T. es lo mismo que no tener condici¢n SI
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* Un .T. es lo mismo que no tener condici¢n MIENTRAS
			while_cond = ".T."

			IF M->how_many = 0
				* A menos que se haya fijado un  mbito
				GO TOP

			ENDIF
		ENDIF

		IF M->how_many = 0
			REPLACE &field_mvar WITH &with_what;
					WHILE &while_cond FOR &for_cond

		ELSE
			REPLACE NEXT M->how_many &field_mvar WITH &with_what;
					WHILE &while_cond FOR &for_cond

		ENDIF

		stat_msg("Se ha realizado el cambio")
		done = .T.

ENDCASE

RETURN M->done


************************************************
* Funciones comunes a COPIAR, A¥ADIR y CAMBIAR  *
************************************************

******
*       for_exp()
*
*       Lee la condici¢n "SI"
******
FUNCTION for_exp

PARAMETERS sysparam

help_code = 16
RETURN get_exp(M->sysparam, "SI       ", M->for_row, "for_cond")


******
*       while_exp()
*
*       Lee la condici¢n "MIENTRAS" 
******
FUNCTION while_exp

PARAMETERS sysparam

help_code = 16
RETURN get_exp(M->sysparam, "MIENTRAS ", M->for_row + 1, "while_cond")


******
*       scope_num()
*
*       Lee el  mbito
******
FUNCTION scope_num

PARAMETERS sysparam
local saveColor
PRIVATE old_scope

help_code = 17
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualizaci¢n normal
		@ M->wt + M->for_row + 2, M->wl + 2;
		SAY "AMBITO   " + pad(IF(M->how_many = 0, "TODOS",;
							"PROXIMOS " + LTRIM(STR(M->how_many))), 18)

		IF M->sysparam = 1
			* Mostrar posici¢n
			@ M->wt + M->for_row + 2, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resaltar
		SetColor(M->colorHilite)
		@ M->wt + M->for_row + 2, M->wl + 11;
		SAY pad(IF(M->how_many = 0,;
				   "TODOS", "PROXIMOS " + LTRIM(STR(M->how_many))), 18)

	CASE M->sysparam = 4
		* Seleccionados

		IF CHR(M->keystroke) $ "0123456789" + CHR(13)
			* D¡gitos o Intro

			IF M->keystroke <> 13
				* Inclusi¢n del d¡gito inicial en el campo de entrada
				KEYBOARD CHR(M->keystroke)

			ENDIF

			old_scope = M->how_many         && En caso de abandonar

			* Activar ciertas teclas para salir del READ
			SET KEY 5 TO clear_gets
			SET KEY 24 TO clear_gets
			xkey_clear()

			* La apariencia es importante
			SetColor(M->colorHilite)
			@ M->wt + M->for_row + 2, M->wl + 11 SAY pad("PROXIMOS",18)

			SetColor(M->colorNorm)
			@ M->wt + M->for_row + 2, M->wl + 20;
			GET M->how_many PICTURE "99999999"

			SET CURSOR ON
			READ
			SET CURSOR OFF

			* Almacenamos la tecla de salida
			keystroke = LASTKEY()

			* Restauramos las teclas a estado normal
			SET KEY 5 TO
			SET KEY 24 TO
			xkey_norm()

			IF M->keystroke = 13
				* Nos desplazamos al bot¢n "Ok"
				to_ok()
				@ M->wt + M->for_row + 2, M->wl + 11;
				SAY pad(IF(M->how_many = 0, "TODOS    ", "PROXIMOS " +;
						LTRIM(STR(M->how_many))), 18)

			ELSE

				IF menu_key() <> 0
					* Petici¢n de men£
					how_many = M->old_scope

				ENDIF

				IF M->keystroke <> 27 .AND. .NOT. isdata(M->keystroke)
					* Formateamos la petici¢n
					KEYBOARD CHR(M->keystroke)

				ENDIF
			ENDIF

		ELSE
			* Ambito de la tecla = 0 = ALL
			how_many = 0

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


***************************************
* Funciones comunes a COPIAR y A¥ADIR *
***************************************

******
*       tog_sdf()
*
*       Cambio al modo SDF
******
FUNCTION tog_sdf

PARAMETERS sysparam
local saveColor

help_code = 11
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualizaci¢n normal
		@ M->wt + 9, M->wl + 8 SAY " SDF "

		IF M->mode = 2
			* El modo actual es SDF
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX sframe

		ENDIF

		IF M->sysparam = 1
			* Documentar la posici¢n
			@ M->wt + 9, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resaltar
		SetColor(M->colorHilite)
		@ M->wt + 9, M->wl + 8 SAY " SDF "

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* Seleccionado..No se aceptan caracteres aqu¡

		IF M->mode = 2
			* Desactivaci¢n del modo SDF
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX "        "
			mode = 1

			* Cambio de .TXT a .DBF
			cur_el = 1
			rel_row = 0
			files = "dbf_list"
			def_ext = ".DBF"
			filelist(1)                     && Visualizaci¢n de la nueva lista

		ELSE
			* Activar el modo SDF

			IF M->mode = 3
				* Desactivar la delimitaci¢n
				@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX "        "

			ELSE
				* Modo normal. Cambio de .DBF a .TXT
				cur_el = 1
				rel_row = 0
				files = "txt_list"
				def_ext = ".TXT"
				filelist(1)             && Visualizaci¢n de la nueva lista

			ENDIF

			* Indicar que el modo SDF est  activado
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX sframe
			mode = 2

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*       tog_delim
*
*       Cambia el modo de delimitaci¢n 
******
FUNCTION tog_delim

PARAMETERS sysparam
local saveColor

help_code = 11
saveColor := SetColor(M->colorNorm)
DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* Visualizaci¢n normal
		@ M->wt + 9, M->wl + 17 SAY " DELIMITADO "

		IF M->mode = 3
			* El modo actual es DELIMITADO
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 29 BOX sframe

		ENDIF

		IF M->sysparam = 1
			* Documentar la posici¢n
			@ M->wt + 9, M->wl + 17 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* Resaltar
		SetColor(M->colorHilite)
		@ M->wt + 9, M->wl + 17 SAY " DELIMITADO "

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* Seleccionado..No se aceptan caracteres ahora

		IF M->mode = 3
			* Desactivaci¢n de modo DELIMITADO
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 29 BOX "        "
			mode = 1

			* Cambio de .TXT a .DBF
			cur_el = 1
			rel_row = 0
			files = "dbf_list"
			def_ext = ".DBF"
			filelist(1)                     && Visualizaci¢n de la nueva lista

		ELSE
			* Activaci¢n del modo DELIMITADO

			IF M->mode = 2
				* Desactivar el modo SDF
				@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX "        "

			ELSE
				* Modo normal..Cambio de .DBF a .TXT
				cur_el = 1
				rel_row = 0
				files = "txt_list"
				def_ext = ".TXT"
				filelist(1)             && Visualizaci¢n de la nueva lista

			ENDIF

			* Indica que el modo DELIMITADO est  activado
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 29 BOX sframe
			mode = 3

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


* Fin de fichero: DBUCOPY.PRG
