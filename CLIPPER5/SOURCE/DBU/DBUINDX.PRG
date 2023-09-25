/***
*
*  Dbuindx.prg
*
*  M¢dulo de lectura/creaci¢n de ¡ndices de la utilidad DBU
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.
*
*/


******
*       make_ntx
*
*       Crea un fichero ¡ndice
*
*       Nota: V‚ase multibox en el m¢dulo DBUUTIL.PRG
******
PROCEDURE make_ntx
local saveColor
PRIVATE filename, files, fi_disp, okee_dokee, cur_el, rel_row, def_ext,;
		bcur, fi_done, el, cr, ntx, k_exp


* Da valor a las variable locales para macrosustituir las matrices
cr = "_cr" + SUBSTR("123456", M->cur_area, 1)
el = "_el" + SUBSTR("123456", M->cur_area, 1)
ntx = "ntx" + SUBSTR("123456", M->cur_area, 1)

* Lectura del nombre del fichero ¡ndice actual
filename = &ntx[&el[2]]

* Resalta el fichero ¡ndice actual...incluso si est  vac¡o
saveColor := SetColor(M->color2)
@ &cr[2], column[M->cur_area] + 2 SAY pad(name(M->filename), 8)

* Temporalmente se anulan los filtros y relaciones que puedan estar activos
SELECT (M->cur_area)
SET FILTER TO
CLOSE INDEX
need_filtr = .T.
need_ntx = .T.
not_target(SELECT(), .F.)
SELECT (M->cur_area)

* Inicializaci¢n de las variables para el subsistema de ventanas
cur_el = 1
rel_row = 0
files = "ntx_list"
def_ext = INDEXEXT()

IF .NOT. EMPTY(M->filename)
	* Lectura de la clave del fichero
	k_exp = ntx_key(M->filename)
	bcur = 4

ELSE
	* Se asume que se crear  un nuevo fichero ¡ndice
	k_exp = ""
	bcur = 2

ENDIF

* Se establece una matriz de funciones para el subsitema de ventanas
DECLARE boxarray[6]

boxarray[1] = "ntx_title(sysparam)"
boxarray[2] = "ntx_getfil(sysparam)"
boxarray[3] = "ntx_exp(sysparam)"
boxarray[4] = "ok_button(sysparam)"
boxarray[5] = "can_button(sysparam)"
boxarray[6] = "filelist(sysparam)"

* Definici¢n de ciertos subprocesos
fi_disp = "ntx_exist()"
fi_done = "ntx_done()"
okee_dokee = "do_index()"

IF multibox(13, 17, 9, M->bcur, M->boxarray) <> 0 .AND.;
   aseek(&ntx, M->filename) = 0
	* Fichero ¡ndice generado pero no abierto

	IF M->n_files < 14 .OR. .NOT. EMPTY(&ntx[&el[2]])
	* Si hay espacio para otro...se a¤ada el ¡ndice a la vista actual

	IF EMPTY(&ntx[&el[2]])                                   
	    * Mantenimiento del n£mero de ¡ndices abiertos
			n_files = M->n_files + 1

		ENDIF

	* Se a¤ade el fichero ¡ndice a la matriz p£blica
		&ntx[&el[2]] = M->filename

	ENDIF
ENDIF

* Reescritura del nombre del fichero ¡ndice en color normal
saveColor := SetColor(M->color1)
@ &cr[2], column[M->cur_area] + 2 SAY pad(name(&ntx[&el[2]]), 8)

SetColor(saveColor)
RETURN


*******************************************
* Funciones de soporte para la INDEXACION *
*******************************************

******
*       ntx_title()
*
*       Visualiza el t¡tulo para "¡ndice"
******
FUNCTION ntx_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Indexar " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " a...")


******
*       ntx_getfil()
*
*       Lectura del nombre del fichero de salida
******
FUNCTION ntx_getfil

PARAMETERS sysparam

RETURN getfile(M->sysparam, 4)


******
*       ntx_done()
*
*   Comprobaci¢n preliminar del nombre de fichero tecleado en el campo de
*   entrada
******
FUNCTION ntx_done

PRIVATE done_ok

done_ok = .NOT. EMPTY(M->filename)

IF M->done_ok
	* Se introdujo nombre del fichero

	IF FILE(M->filename) .AND. EMPTY(M->k_exp)
		* Lee y visualiza la expresi¢n clave del fichero ¡ndice  
		k_exp = ntx_key(M->filename)
		ntx_exp(3)

	ENDIF

	IF EMPTY(M->k_exp)
		* Sit£a el cursor al campo expresi¢n
		KEYBOARD CHR(24)

	ELSE
		* Expresi¢n introducida..Se sit£a el cursor en el bot¢n "Ok"
		to_ok()

	ENDIF
ENDIF

RETURN M->done_ok


******
*       ntx_exp()
*
*       Lectura de la expresi¢n clave 
******
FUNCTION ntx_exp

PARAMETERS sysparam

RETURN get_exp(M->sysparam, "CLAVE    ", 6, "k_exp")


******
*       ntx_exist()
*
*       Visualiza el nombre del fichero de la lista y extrae la clave
******
FUNCTION ntx_exist

IF EMPTY(M->k_exp)
	* Expresi¢n no introducida...Se lee la del fichero ¡ndice seleccionado
	k_exp = ntx_key(M->filename)

ENDIF

* Visualiza el nombre del fichero ¡ndice y su clave
ntx_getfil(3)
ntx_exp(3)

RETURN 0


******
*       do_index()
*
*       Ejecuta el mandato ¡ndice
*
*       NOTA: Esta funci¢n se llama si pulsa la tecla <Intro>
*                 mientras el cursor se encuentra sobre el bot¢n "Ok"
******
FUNCTION do_index

PRIVATE done, n_dup, new_el, add_name

* Lectura del n£mero del  rea usando el ¡ndice si lo hay
n_dup = dup_ntx(M->filename)

DO CASE

	CASE EMPTY(M->filename)
		error_msg("No se seleccion¢ ning£n fichero ¡ndice")
		done = .F.

	CASE M->n_dup > 0 .AND. M->n_dup <> SELECT()
		error_msg("Otro fichero est  usando el fichero ¡ndice")
		done = .F.

	CASE EMPTY(M->k_exp)
		error_msg("No se ha introducido la clave de indexaci¢n")
		done = .F.

	CASE .NOT. TYPE(M->k_exp) $ "CND"
		error_msg("Expresi¢n clave no v lida")
		done = .F.

	OTHERWISE
		* Vamos a generar el fichero ¡ndice
		stat_msg("Generando fichero ¡ndice")
		add_name = .NOT. FILE(name(M->filename) + INDEXEXT())
		INDEX ON &k_exp TO &filename
		CLOSE INDEX

		IF AT(INDEXEXT(), M->filename) = LEN(M->filename) - 3 .AND.;
		   FILE(name(M->filename) + INDEXEXT()) .AND. M->add_name
	    * Se a¤ade s¢lo los ficheros NTX al directorio actual

			new_el = afull(M->ntx_list) + 1

			IF M->new_el <= LEN(M->ntx_list)
				* Adici¢n del fichero a la matriz
				ntx_list[M->new_el] = M->filename
				array_sort(M->ntx_list)

			ENDIF
		ENDIF

		stat_msg("Fichero indexado")
		done = .T.

ENDCASE

RETURN M->done


* Fin de fichero: DBUINDX.PRG
