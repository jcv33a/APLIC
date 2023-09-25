/***
*
*  Dbuedit.prg
*
*  M¢dulo de edici¢n de datos de la utilidad DBU
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.
*
*/

#include "inkey.ch"
#include "memoedit.ch"

#define TB_REFRESH_RATE    5     // Esperamos cinco segundos entre refresco 
				 // y refresco en la visualizaci¢n


/***
*       browse
*
*       Visualiza un fichero o una vista
*/
proc browse

local i,j,nHelpSave,cNtx,cFieldArray,cFieldName,nWa,cMemo,oB,nRec,;
	cBrowseBuf,nPrimeArea,nHsepRow,cEditField,bAlias,cAlias,nCType,;
	cHead,lMore,lCanAppend,cMemoBuff,aMoveExp,cPrimeDbf,;
   nColorSave,lAppend,lGotKey,lKillAppend,bColBlock

/*
 nRefreshTimer obliga a un refresco cada TB_REFRESH_RATE segundos
 Esto sirve para actualizar la visualizaci¢n en caso de que se estuviera   
 ejecutando en un entorno de red
*/
local nRefreshTimer  := SECONDS()
local anCursPos[2]

memvar keystroke,help_code,func_sel,cur_area,cur_dbf,field_list,frame,;
	curs_on,cur_ntx,ntx1,dbf,local_func,box_open,;
	color1,color7,color8,color9

	/* Esconde el cursor */
	nCType := SetCursor(0)
	curs_on := .f.

	/* Salva el c¢digo de error previo */
	nHelpSave := help_code

	/* Salvar, borrar y enmarcar la ventana */
	cBrowseBuf := SaveScreen(8, 0, 23, 79)

	/* Matriz donde salvar las expresiones move_ptr */
	aMoveExp := Array(4)
	AFill(aMoveExp, "")

	/* Separador de cabecera si s¢lo hay una base de datos */
	nHsepRow := 11

	/* Determina qu‚ visualizar */
	if ( func_sel == 1 )
		/* Un s¢lo fichero */
		nPrimeArea := cur_area
		cFieldArray := "field_n" + Substr("123456", cur_area, 1)
		cNtx := "ntx" + Substr("123456", cur_area, 1)
		cur_ntx := &cNtx[1]
		cPrimeDbf := Substr(cur_dbf, Rat("\", cur_dbf) + 1)
		lCanAppend := .T.
	else
		/* Visualizar la vista entera */
		nPrimeArea := 1
		cFieldArray := "field_list"
		cur_ntx := ntx1[1]
		cPrimeDbf := Substr(dbf[1], Rat("\", dbf[1]) + 1)
		lCanAppend := .F.

		if ( "->" $ field_list[afull(field_list)] )
			nHsepRow := 12
		end
	end

	/* Bloque de c¢digo para extraer el alias de alias->campo */
	bAlias := &("{|i| if('->' $" + cFieldArray + "[i], Substr(" +;
				cFieldArray + "[i], 1, At('->'," + cFieldArray +;
		"[i]) - 1), '')}")

	Select(nPrimeArea)
	if ( Eof() )
		/* No se permite el fin de fichero */
		go top
	end

	/* Varios */
	lAppend := .F.
	nRec := 0

	/* Creaci¢n del objeto Browse */
	nColorSave := SetColor(color7)
	oB := TBrowseDB(10, 1, 23, 78)

	oB:headSep := "ÍÑÍ"
	oB:colSep  := " ³ "
	oB:footSep := "ÍÏÍ"
	oB:skipBlock := {|x| Skipped(x, lAppend)}

	/* A¤adimos columnas al objeto */
	j := Len(&cFieldArray)
	for i := 1 TO j
		if ( Empty(&cFieldArray[i]) )
			EXIT
		end

		/* Determina el tema del alias y del  rea */
		cEditField := &cFieldArray[i]
		if ( "->" $ cEditField )
			cAlias := Substr(cEditField, 1, At("->", cEditField) + 1)
			cFieldName := Substr(cEditField, At("->", cEditField) + 2)
			cHead := cAlias + ";" + cFieldName
			nWa := Select(cAlias)
		else
			cAlias := ""
			cFieldName := cHead := cEditField
			nWa := Select()
		end

		/* Los campos de texto MEMO se tratan de manera diferente */
		if ( ValType(&cEditField) == "M" )
			bColBlock := &("{|| '  <Memo>  '}")
		else
			bColBlock := FieldWBlock(cFieldName, nWa)
		end

		/* A¤adimos una columna */
		oB:addColumn(TBColumnNew(cHead, bColBlock))
	next

	/* Inicializamos las partes de la pantalla que no maneja TBrowse */
	stat_msg("")
	scroll(8, 0, 23, 79, 0)
	@ 8, 0, 23, 79 BOX frame
	@ nHsepRow, 0 SAY "Æ"
	@ nHsepRow, 79 SAY "µ"

	/* Inicializaci¢n del resto de variables locales */
	cAlias := ""
	lKillAppend := .f.
	if ( (LastRec() == 0) .and. lCanAppend )
		/* Fichero vac¡o..entramos en modo de adici¢n de registros */
		keystroke := K_DOWN
		lGotKey := .t.
	else
		lGotKey := .f.
	end

	lMore := .t.
	while (lMore)
      
		if ( !lGotKey )
			/* Las teclas interrumpen la estabilizaci¢n */
			while ( !oB:stabilize() )
				if ( (keystroke := Inkey()) != 0 )
					lGotKey := .t.
					exit
				end
			end
		end

		if ( !lGotKey )
			if ( oB:hitBottom .and. lCanAppend )
				/* Activar o continuar el modo de adici¢n */
				if ( !lAppend .or. Recno() != LastRec() + 1 )
					if ( lAppend )
						/* Continuar con el modo de adici¢n */
		  oB:refreshCurrent():forceStable()
						go bottom
					else
						/* La primera vez que se a¤ade */
						lAppend := .t.
						SetCursor(1)
						curs_on := .t.
					end

					/* Bajamos y estabilizamos para fijar rowPos */
	       oB:down():forceStable()
				end
			end

			/* Visualiza el estado */
			cAlias := Eval(bAlias, oB:colPos)
			statline(oB, lAppend, cAlias)

			/* Nueva estabilizaci¢n para corregir la posici¢n del cursor */
	 WHILE !oB:stabilize() ; END

	 // Si han pasado TB_REFRESH_RATE segundos, refrescamos el browse
	 // Es necesario en red para asegurar que se visualizan datos 
	 // actualizados 
	 WHILE (( keystroke := INKEY()) == 0 )
	    IF (( nRefreshTimer + TB_REFRESH_RATE ) < SECONDS() )
	       DISPBEGIN()
	       anCursPos := { ROW(), COL() }
	       FreshOrder( oB )
	       StatLine( oB, lAppend, cAlias )
	       SETPOS( anCursPos[1], anCursPos[2] )
	       DISPEND()
	       nRefreshTimer := SECONDS()
	    ENDIF
	 END

		else
			/* Reiniciamos valores para la siguiente pasada */
			lGotKey := .f.
		end

		do case
		case keystroke == K_DOWN
			if ( lAppend )
				oB:hitBottom := .t.
			else
				oB:down()
			end

		case keystroke == K_UP
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:up()
			end

		case keystroke == K_PGDN
			if ( lAppend )
				oB:hitBottom := .t.
			else
				oB:pageDown()
			end

		case keystroke == K_PGUP
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:pageUp()
			end

		case keystroke == K_CTRL_PGUP
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:goTop()
			end

		case keystroke == K_CTRL_PGDN
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:goBottom()
			end

		case keystroke == K_RIGHT
			oB:right()

		case keystroke == K_LEFT
			oB:left()

		case keystroke == K_HOME
			oB:home()

		case keystroke == K_END
			oB:end()

		case keystroke == K_CTRL_LEFT
			oB:panLeft()

		case keystroke == K_CTRL_RIGHT
			oB:panRight()

		case keystroke == K_CTRL_HOME
			oB:panHome()

		case keystroke == K_CTRL_END
			oB:panEnd()

		case keystroke == K_DEL
			/* Cambia el indicador de borrado */
	 oB:forceStable()
			cAlias := Eval(bAlias, oB:colPos)
			if ( !Empty(cAlias) )
				Select(cAlias)
			end

			if ( Recno() != Lastrec() + 1 )
	    IF NetRLock()
	       
	       // Se ha conseguido un bloqueo
	       // Si el registro estaba borrado lo recuperamos y viceversa
	       IF DELETED()
		  RECALL
	       ELSE
		  DELETE
	       END

	       COMMIT
	       UNLOCK

	    ENDIF
			end

			Select(nPrimeArea)

		case keystroke == K_INS
			/* Cambio del modo de inserci¢n */
			tog_insert()

		case keystroke == K_RETURN
			/* Edici¢n del campo actual */

	 if bof() .and. eof() .and. !lAppend
	    keyboard chr( K_DOWN ) + chr( nextkey() )
	    loop
	 endif

	 oB:forceStable()

			cAlias := Eval(bAlias, oB:colPos)

			if ( !Empty(cAlias) )
				Select(cAlias)
			end

			if ( !lAppend .and. (Recno() == LastRec() + 1) )
				Select(nPrimeArea)
				loop    /* NOTA */
			end

			Select(nPrimeArea)

			/* Nos aseguramos de que la visualizaci¢n es correcta */
			oB:hitTop := .f.
			Statline(oB, lAppend, cAlias)
	 WHILE !oB:stabilize() ; END

			cEditField := &cFieldArray[oB:colPos]

			/* Activa el cursor */
			SetCursor(1)
			curs_on := .t.

			if ( Type(cEditField) == "M" )
				/* Edici¢n de un campo de texto */
				help_code := 19
				box_open := .t.

				/* Grabar, borrar y enmarcar la ventana de memoedit */
				cMemoBuff := SaveScreen(10, 10, 22, 69)

				SetColor(color8)
				Scroll(10, 10, 22, 69, 0)
				@ 10, 10, 22, 69 BOX frame

				/* Usamos el campo como t¡tulo */
				SetColor(color9)
				@ 10,((76 - Len(cEditField)) / 2) SAY "  " + cEditField + "  "

				/* Edici¢n del campo de texto de longitud variable */
				SetColor(color8)
				cMemo := MemoEdit(&cEditField, 11, 11, 21, 68,.T.,"xmemo")

				if Lastkey() == K_CTRL_END
					/* ^W..modificaci¢n */

	       BEGIN SEQUENCE
		  IF ( lAppend .and. Eof() )
		     /* Primeros datos del nuevo fichero */
		     IF !NetAppBlank()
			BREAK    // Abandonamos, no podemos a¤adir
		     ENDIF
		  ELSE
		     /* S¢lo editamos.. */
		     IF !NetRLock()
			BREAK    // Abandonamos, no podemos bloquear
		     ENDIF
		  END

		  REPLACE &cEditField WITH cMemo
		  COMMIT
		  UNLOCK

	       END SEQUENCE

					/* Vamos al siguiente campo */
					keystroke := K_RIGHT
					lGotKey := .t.
				else
					keystroke := 0
				end

				/* Restauramos la ventana */
				RestScreen(10, 10, 22, 69, cMemoBuff)
				box_open := .F.
			else
				/* Entrada normal de datos */
				SetColor(color1)
				keystroke := DoGet(oB, lAppend, cAlias)
				lGotKey := ( keystroke != 0 )
			end

	 lKillAppend := .T.

			/* Desactivamos el cursor a menos que estemos a¤adiendo */
			if ( !lAppend )
				SetCursor(0)
				curs_on := .f.
			end

			help_code := nHelpSave
			SetColor(color7)

		otherwise
			if ( isdata(keystroke) )
				/* Adelantamos la tecla al sistema de GETs */
				keyboard Chr(K_RETURN) + Chr(keystroke)
			else
				/* Miramos si hay petici¢n de men£ */
				sysmenu()

				do case
				case q_check()
					/* Salida */
					lMore := .f.

				case local_func == 1
					/* Se requiere ayuda */
					DO syshelp

				case local_func == 7
					/* Selecci¢n de MOVER..S¢lo el primero puede moverse */
					nRec := Recno()
					move_ptr(aMoveExp, cPrimeDbf)

					if ( nRec != Recno() )
						if ( lAppend )
							/* Fin de modo de adici¢n de registro */
							lKillAppend := .t.
						else
							FreshOrder(oB)
						end
					end
				end
			end
		end

		if ( lKillAppend )
			/* Desactivar el modo de adici¢n de registros */
			lKillAppend := .f.
			lAppend := .f.

			/* Refresco respetando los cambios en los ¡ndices */
			FreshOrder(oB)
			SetCursor(0)
			curs_on := .f.
      end

	end

	/* Restaura la pantalla */
	RestScreen(8, 0, 23, 79, cBrowseBuf)
	SetColor(nColorSave)
	SetCursor(nCType)
	curs_on := (nCType != 0)
	stat_msg("")

return


/***
*       xmemo()
*
*       Funci¢n de usuario del MemoEdit ()
*/
func xmemo(mmode, line, col)
local nRet
memvar keystroke,local_func

	nRet := 0

	if mmode <> ME_IDLE
		/* Miramos si hay requerimiento de men£ */
		keystroke := Lastkey()
		sysmenu()

		do case
		case local_func == 1
			/* Se requiere ayuda */
			do syshelp

		case keystroke == K_INS
			/* Se puls¢ la tecla Insertar */
			tog_insert()
			nRet := ME_IGNORE

		case keystroke == K_ESC
			/* Se puls¢ la tecla Escape */
			if mmode == ME_UNKEYX
				/* Se ha cambiado el texto */
				if rsvp("Se perder n los cambios. ¨Abandonar? (S/N)") <> "S"
					/* No salimos sin confirmaci¢n expl¡cita */
					nRet := ME_IGNORE
				end
			end
		end
	end

return (nRet)


/***
*       tog_insert()
*
*       Cambia el estado de inserci¢n/sobreescritura
*/
static func tog_insert
local nCType

	Readinsert(!Readinsert())
	nCType := SetCursor(0)
	show_insert()
	SetCursor(nCType)

return (0)


/***
*       show_insert()
*
*       Visualiza el modo actual de inserci¢n
*/
static func show_insert
local nColorSave

	nColorSave := SetColor(color7)
	@ 9,3 say if(ReadInsert(), "<Insertar>", "          ")
	SetColor(nColorSave)

return (0)


/***
*       statline()
*
*       Actualiza la l¡nea de estado en la ventana de visulizaci¢n
*/
static func statline(oB, lAppend, cAlias)
local cColorSave, cCurrAlias, lNoFilter, nWaSave, nCType

	/* Guarda el estado del cursor */
	nCType := SetCursor(0)

	nWaSave := Select()
	if ( !Empty(cAlias) )
		Select(cAlias)
	end

    @ 09, 03 say Space (75)

	cColorSave := SetColor(color7)

	/* Muestra el estado actual */
	show_insert()

	/* Muestra el estado del filtro */
	lNoFilter := Empty(&("kf" + Substr("123456", Select(), 1)))
	@ 9,16 say if(lNoFilter, "        ", "<Filtro>")

	/* Visualiza la informaci¢n asociada al puntero del registro */
	@ 9,37 say if(Empty(cAlias), space(10), Lpad(cAlias + "->", 10));
			   + "Registro"

	if ( EmptyFile() .and. .not. lAppend )
		/* El fichero est  vac¡o */
		@ 9,58 say "<ninguno>            "
	elseif ( Eof() )
		/* Sin n£mero de registro si estamos al final del fichero */
		@ 9,28 say Space (50)
		@ 9,55 say "    " + if(lAppend, "<Nuevo>", " <EOF> ")
	else
		/* Registro normal..Veremos recno()/lastrec() y deleted() */
		@ 9,28 say if(Deleted(), "<Borrado>", "         ")
		@ 9,58 say Pad(Ltrim(Str(Recno())) + "/" + Ltrim(Str(Lastrec())),15)+;
				   If(oB:hitTop, " <BOF>", if(oB:hitBottom, " <EOF>", "      "))
	end

	/* Restauramos el estado */
	SetColor(cColorSave)
	Select(nWaSave)
	SetCursor(nCType)

return (0)


/***
*       move_ptr()
*
*       BUSCAR, IR A, LOCALIZAR y SALTAR
*
*       La siguiente matriz se define e inicializa en el Browse:
*               aMoveExp[1] == la £ltima expresi¢n de BUSQUEDA
*               aMoveExp[2] == el £ltimo valor de IR A
*               aMoveExp[3] == la £ltima expresi¢n de LOCALIZACION
*               aMoveExp[4] == el £ltimo valor de SALTO
*/
static func move_ptr(aMoveExp, cPrimeDbf)

local nHelpSave,aBox
memvar okee_dokee, k_trim, movp_sel, titl_str, exp_label
memvar help_code,local_sel,ntx_expr
private okee_dokee, k_trim, movp_sel, titl_str, exp_label, ntx_expr

	nHelpSave := help_code

	movp_sel := local_sel

	/* Inicilizaci¢n a los valores previos, si los hay */
	k_trim := aMoveExp[movp_sel]

	/* Configuraci¢n para multibox */
	aBox := Array(4)

	aBox[1] := "movp_title(sysparam)"
	aBox[2] := "movp_exp(sysparam)"
	aBox[3] := "ok_button(sysparam)"
	aBox[4] := "can_button(sysparam)"

	do case
	case movp_sel == 1
		/* B£squeda */ 
		okee_dokee := "do_seek()"
		titl_str := "  BUSCAR en  " + cPrimeDbf + "..."
		exp_label := "Expresi¢n "
		ntx_expr := Indexkey(0)
		help_code := 13

	case movp_sel == 2
		/* IR A */
		okee_dokee := "do_goto()"
		titl_str := "Mover el puntero de  " + cPrimeDbf + " a.."
		exp_label := "Registro"
		help_code := 14

	case movp_sel == 3
		/* LOCALIZAR */
		okee_dokee := "do_locate()"
		titl_str := "  LOCALIZAR en " + cPrimeDbf + "..."
		exp_label := "Expresi¢n "
		help_code := 10

	case movp_sel == 4
		/* SALTAR */
		okee_dokee := "do_skip()"
		titl_str := "SALTAR registros en  " + cPrimeDbf + "..."
		exp_label := "N£mero"
		help_code := 20
	end

	/* Hazlo */
	set key K_INS to tog_insert
	multibox(14, 17, 5, 2, aBox)
	set key K_INS to

	/* Almacenamos la expresi¢n para la siguiente vez */
	aMoveExp[movp_sel] := k_trim

	help_code := nHelpSave

return (0)


/***
*       movp_title()
*
*       Visualiza el t¡tulo para las funciones de movimiento del puntero
*/
func movp_title(sysparam)
memvar titl_str
return (box_title(sysparam, titl_str))


/***
*       movp_exp()
*
*       Lee el par metro para las funciones
*/
func movp_exp(sysparam)
memvar exp_label
return (get_k_trim(sysparam, exp_label))


/***
*       do_seek()
*
*       BUSCA una expresi¢n
*/
func do_seek

local lDone, nRec, cSeekType
memvar k_trim,ntx_expr

	lDone := .F.

	if Empty(k_trim)
		error_msg("No se ha introducido ninguna expresi¢n")
	else
		stat_msg("Buscando...")

		/* Almacena la posici¢n actual por si no se encuentra */
		nRec := Recno()

		/* Determina el tipo de b£squeda */
		cSeekType := Type(ntx_expr)

		/* Vamos */
		do case
		case cSeekType == "C"
			/* B£squeda de una expresi¢n de tipo car cter */
			seek k_trim

		case cSeekType == "N"
			/* B£squeda de una expresi¢n de tipo num‚rico */
			seek Val(k_trim)

		case cSeekType == "D"
			/* B£squeda de una expresi¢n de tipo fecha */
			seek Ctod(k_trim)
		end

		if Found()
			/* La operaci¢n se complet¢ */
			stat_msg("Encontrado")
			lDone := .T.
		else
			/* Consideraremos que es un error..volvamos a intentarlo */
			error_msg("No se ha encontrado")
			goto nRec
		end
	end

return (lDone)


/***
*       do_goto()
*
*       Va a un registro determinado
*/
func do_goto

local lDone, nWhich
memvar k_trim

	lDone := .F.
	nWhich := Val(k_trim)           && Lo convertimos a num‚rico

	do case
	case Empty(k_trim)
		error_msg("No se ha introducido ning£n n£mero de registro")

	case .not. Substr(Ltrim(k_trim), 1, 1) $ "-+1234567890"
		error_msg("No se ha introducido una expresi¢n num‚rica")

	case nWhich <= 0 .or. nWhich > Lastrec()
		error_msg("N£mero de registro fuera de rango")

	otherwise
		/* Operaci¢n finalizada */
		goto nWhich
		lDone := .T.

	end

return (lDone)


/***
*       do_locate()
*
*       Lee la expresi¢n de localizaci¢n
*/
func do_locate

local lDone, nRec
memvar k_trim

	lDone := .F.

	do case
	case Empty(k_trim)
		error_msg("No se ha introducido la expresi¢n de localizaci¢n")

	case Type(k_trim) <> "L"
		error_msg("La expresi¢n debe ser de tipo l¢gico")

	otherwise
		/* Almacena el n£mero de registro por si no se encuentra */
		nRec := Recno()
		stat_msg("Localizando...")

		if &k_trim
			/* El registro actual cumple la condici¢n */
			skip
		end

		/* Localizamos hacia adelante hasta el fin de fichero */
		locate for &k_trim while .T.

		if Found()
			/* Operaci¢n finalizada */
			stat_msg("Localizado")
			lDone := .T.

		else
			/* Se considera un error..volvemos a empezar */
			error_msg("No se ha localizado")
			goto nRec
		end
	end

return (lDone)


/***
*       do_skip()
*
*       SALTAR un n£mero determinado de registros
*/
func do_skip

local lDone, nSkip
memvar k_trim

	lDone := .F.
	nSkip := Val(k_trim)            && Convertir a tipo num‚rico

	do case
	case Empty(k_trim)
		error_msg("No se ha introducido el n£mero de registros a saltar")

	case .not. Substr(Ltrim(k_trim), 1, 1) $ "-+1234567890"
		error_msg("El valor debe ser de tipo num‚rico")

	case nSkip == 0
		error_msg("El valor de salto es cero")

	otherwise
		/* Valor dentro de rango y sin error */
		lDone := .T.

		skip nSkip

		if Eof()
			/* Desbordamiento inferior. Fin de fichero = .F. */
			go bottom
		end

		if Bof()
			/* Desbordamiento superior. Inicio de fichero = .F. */
			go top
		end
	end

return (lDone)


/***
*       EmptyFile()
*/

static func EmptyFile()

	if (LastRec() == 0 )
		return (.t.)
	end

	if ( (Eof() .or. Recno() == LastRec() + 1) .and. Bof() ) 
		return (.t.)
	end

return (.f.)


/***
*       DoGet()
*
*       Edita el campo de entrada actual
*/

static func DoGet(oB, lAppend, cAlias)

local lExitSave, oCol, oGet, nKey, cExpr, xEval
local lFresh, mGetVar, nWaSave

	/* Almacenamos el estado actual */
	lExitSave := Set(_SET_EXIT, .t.)
	nWaSave := Select()
	if ( !Empty(cAlias) )
		Select(cAlias)
	end

	/* Determinamos el modo de inserci¢n y la visibilidad del cursor */
	set key K_INS to tog_insert
	xkey_clear()

	/* Lectura de la clave del ¡ndice actual */
	cExpr := IndexKey(0)
	if ( !Empty(cExpr) )
	/* Macrosustituci¢n de la expresi¢n clave para posteriores
	   comparaciones */
		xEval := &cExpr
	end

	/* Leemos el objeto columna del TBrowse */
	oCol := oB:getColumn(oB:colPos)

	/* Uso de un temporal de seguridad */
	mGetVar := Eval(oCol:block)

    /* Creamos un objeto GET con su bloque de c¢digo de 
       lectura/actualizaci¢n */
	oGet := GetNew(Row(), Col(),                                                                    ;
				   {|x| if(PCount() == 0, mGetVar, mGetVar := x)},      ;
				   "mGetVar")

   /* Configuraci¢n de un GET desplazable en caso que no cupiese en la pantalla */
   if oGet:type == "C" .AND. LEN( oGet:varGet() ) > 78
      oGet:picture := "@S78"
   endif

	/* Desactivamos el indicador de refresco */
	lFresh := .f.

	/* Lectura */
   BEGIN SEQUENCE
      if ( ReadModal( {oGet} ) )
	 /* Se han introducido nuevos datos */
	 if ( lAppend .and. Recno() == LastRec() + 1 )
	    /* Se ha confirmado la adici¢n de un nuevo registro */
	    IF !NetAppBlank()
	       BREAK    // No puede a¤adirse un registro
	    ENDIF
	 end

	 IF NetRLock()
	    Eval(oCol:block, mGetVar)  // Cambio de los datos
	 ELSE
	    BREAK   // Abandonamos el cambio. No podemos bloquear el registro
	 ENDIF

	 // Hemos podido a¤adir o bloquear debidamente.
	 // Ahora ya podemos validar y desbloquear
	 COMMIT
	 UNLOCK

	 /* Comprobar el cambio en el ¡ndice */
	 if ( !Empty(cExpr) .and. !lAppend )
	    if ( xEval != &cExpr )
	       /* Cambio en la clave del ¡ndice. Hay que refrescar */
	       lFresh := .t.
	    end
	 end
      end
   END SEQUENCE

	Select(nWaSave)
	if ( lFresh )
		/* Registro en un nuevo orden */
		FreshOrder(oB)

		/* Nada m s */
		nKey := 0
	else
		/* S¢lo refrescamos la fila actual */
		oB:refreshCurrent()

		/* Algunas teclas mueven el cursor despu‚s de la edici¢n si no se 
	   refresca */
	nKey := ExitKey(lAppend)
	end

	/* Restauramos el estado */ 
	Set(_SET_EXIT, lExitSave)
	set key K_INS to
	xkey_norm()

return (nKey)


/***
*       ExitKey()
*
*       Determina la acci¢n siguiente despu‚s de editar un campo */
*/

static func ExitKey(lAppend)

memvar keystroke

	keystroke := LastKey()
	if ( keystroke == K_PGDN )
		/* Bajamos si estamos en modo de adici¢n */
		if ( lAppend )
			keystroke := 0
		else
			keystroke := K_DOWN
		end

	elseif ( keystroke == K_PGUP )
		/* Subimos si no estamos en modo adici¢n */
		if ( lAppend )
			keystroke := 0
		else
			keystroke := K_UP
		end

	elseif ( keystroke == K_RETURN .or. isdata(keystroke) )
		/* Tecla INTRO o no de control. Vamos a la derecha */
		keystroke := K_RIGHT

	elseif (keystroke != K_UP .and. keystroke != K_DOWN .and. menu_key() == 0)
		/* Nada m s */
		keystroke := 0
	end

return (keystroke)


/***
*       FreshOrder()
*
*       Refresca respecto a cualquier cambio en el orden de los ¡ndices */ 
*/

static func FreshOrder(oB)

local nRec

	nRec := Recno()
	oB:refreshAll()

	/* Estabilizamos para ver si TBrowse mueve el puntero al registro */
   oB:forceStable()

	if ( nRec != LastRec() + 1 )
		/* El puntero puede moverse si IDF no est  en pantalla */
		while ( Recno() != nRec )
	 oB:up():forceStable()
		end
	end

return (NIL)


/***
*       Skipped(n)
*
*       Salta registros de la base de datos y devuelve cu ntos realmente ha 
*       podido saltar
*/

static func Skipped(nRequest, lAppend)

local nCount

	nCount := 0
	if ( LastRec() != 0 )
		if ( nRequest == 0 )
			skip 0

		elseif ( nRequest > 0 .and. Recno() != LastRec() + 1 )
			/* Hacia delante */
			while ( nCount < nRequest )
				skip 1
				if ( Eof() )
					if ( lAppend )
			/* Registro de fin de fichero permitido en modo de
			   adici¢n */
						nCount++
					else
						/* Atr s al £ltimo registro real */
						skip -1
					end

					exit
				end

				nCount++
			end

		elseif ( nRequest < 0 )
			/* Hacia atr s */
			while ( nCount > nRequest )
				skip -1
				if ( Bof() )
					exit
				end

				nCount--
			end
		end
	end

return (nCount)


/* Fin de fichero: DBUEDIT.PRG */
