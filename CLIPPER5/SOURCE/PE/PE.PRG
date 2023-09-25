/***
*
*  Pe.Prg
*
*  Editor de textos simple escrito en CA-Clipper 5.2.
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  Todos los derechos reservados.      
*  
*  Traducci¢n al castellano por el departamento t‚cnico de la divisi¢n de
*  microinform tica de C.A. Computer Associates S.A.
*  Copyright (c) 1993, C.A. Computer Associates S.A.
*  Todos los derechos reservados.
*
*  Para compilar:    CLIPPER pe /m /n /w
*  Para enlazar:     RTLINK FILE pe
*  Para ejecutar:    PE <nombre_de_fichero>
*
*/

#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
# Include "Box.Ch"

# Define   CRLF   Chr(13)+Chr(10)

/* Definici¢n de teclas para PE */
#define EK_WRITE K_ALT_W
#define EK_QUIT  K_ESC
#define EK_WQUIT K_CTRL_W


/* Estructura usada para mantener la informaci¢n asociada al texto editado. */
#define ES_TOP      1
#define ES_LEFT     2
#define ES_BOTTOM   3
#define ES_RIGHT    4

#define ES_FILE     5
#define ES_TEXT     6

#define ES_WIDTH    7
#define ES_TABSIZE  8
#define ES_SCROLL   9
#define ES_WRAP     10
#define ES_INS      11

#define ES_ROW      12
#define ES_COL      13
#define ES_RELROW   14
#define ES_RELCOL   15

#define ES_CHANGED  16
#define ES_LASTKEY  17

#define ES_PATTERN  18

#define ES_LENGTH   18


#define NextTab(y, z)   ( ( (y) + z ) - ( (y) % z ) )


/* Variables est ticas con  mbito de visibilidad en todo el m¢dulo fuente. */
static aEdit
static nMaxRow
static nMaxCol
static nStatCol


****
*   pe()
*

func pe(cFile)
local nKey, lDone, cScreen

    Set(_SET_BELL, .f.)
    Set(_SET_SCOREBOARD, .f.)
    SetKey(K_F1, NIL)

    if ( IsColor() )
        SetColor("w+/b, b/w, b")
    else
        SetColor("w/n, n/w")
    end

    if ( Empty(cFile) )
        cFile := "Sin_Nomb"
    elseif ( Rat(".", cFile) <= Rat("\", cFile) )
        cFile := cFile + ".prg"
    end

    nMaxRow := Maxrow()
    nMaxCol := Maxcol()
    nStatCol := nMaxCol - 25

    /* Creaci¢n de la estructura de edici¢n */
    aEdit               := Array(ES_LENGTH)
    aEdit[ES_FILE]      := Lower(cFile)
    aEdit[ES_TEXT]      := MemoRead(cFile)

    aEdit[ES_TOP]       := 0
    aEdit[ES_LEFT]      := 0
    aEdit[ES_BOTTOM]    := nMaxRow - 2
    aEdit[ES_RIGHT]     := nMaxCol

    aEdit[ES_WIDTH]     := 132
    aEdit[ES_TABSIZE]   := 4
    aEdit[ES_SCROLL]    := .f.
    aEdit[ES_WRAP]      := .t.
    aEdit[ES_INS]       := Set(_SET_INSERT)

    aEdit[ES_ROW]       := 1
    aEdit[ES_COL]       := 0
    aEdit[ES_RELROW]    := 0
    aEdit[ES_RELCOL]    := 0

    aEdit[ES_CHANGED]   := .f.
    aEdit[ES_LASTKEY]   := 0

    aEdit[ES_PATTERN]   := ""

    cScreen := SaveScreen(0, 0, nMaxRow, nMaxCol)
    cls

    @ nMaxRow - 1, 0 TO nMaxRow - 1, nMaxCol
    Msg( "Fichero: " + aEdit[ES_FILE] )
    lDone := .f.


    while (!lDone)
        DoEditing()

        nKey := aEdit[ES_LASTKEY]

        do case
        case (nKey == K_ALT_S)
            Search()

        case (nKey == K_ALT_A)
            SearchAgain()

        case (nKey == EK_WRITE)
            EditWrite()

        case (nKey == EK_QUIT)
            lDone := PExit()

        case (nKey == EK_WQUIT)
            EditWrite()
            lDone := PExit()

        otherwise
        end

    end

    if ( IsColor() )
        SetColor(",,n")
    end

    RestScreen(0, 0, nMaxRow, nMaxCol, cScreen)
    @ nMaxRow, nMaxCol SAY ""

return (NIL)


****
*   DoEditing()
*

func DoEditing()

    aEdit[ES_WRAP] := .t.
    aEdit[ES_TEXT] := MemoEdit( aEdit[ES_TEXT],     ;
                                aEdit[ES_TOP],      ;
                                aEdit[ES_LEFT],     ;
                                aEdit[ES_BOTTOM],   ;
                                aEdit[ES_RIGHT],    ;
                                .t., "ufunc",       ;
                                aEdit[ES_WIDTH],    ;
                                aEdit[ES_TABSIZE],  ;
                                aEdit[ES_ROW],      ;
                                aEdit[ES_COL],      ;
                                aEdit[ES_RELROW],   ;
                                aEdit[ES_RELCOL]    ;
                              )

return (NIL)


****
*   Prompt()
*

func Prompt(cSay, cGet)
local getList := {}, bInsSave, bAltISave

    bInsSave := SetKey(K_INS, {|| SetCursor(if( Set(_SET_INSERT,            ;
                                                !Set(_SET_INSERT) ),        ;
                                                SC_NORMAL, SC_INSERT) ) }   ;
                      )

    bAltISave := SetKey(K_ALT_I, SetKey(K_INS))

    Msg(Space(nStatCol))
    @ nMaxRow,0 SAY cSay    ;
                GET cGet    ;
                Picture "@KS" + Ltrim(Str(nStatCol - (Len(cSay) + 2)))
    READ

    SetKey(K_INS, bInsSave)
    SetKey(K_ALT_I, bAltISave)
    aEdit[ES_INS] := Set(_SET_INSERT)

return (cGet)


****
*   NewName()
*

func NewName()
local name

    name := Prompt("Nuevo nombre del fichero  :", PadR(aEdit[ES_FILE], 64))
    name := Lower(Ltrim(Rtrim(name)))
    if ( !Empty(name) .and. name != aEdit[ES_FILE] )
        aEdit[ES_FILE] := name
        aEdit[ES_CHANGED] := .t.
    end

    Msg("Fichero: " + aEdit[ES_FILE])

return (NIL)


****
*   xSearch()
*

func xSearch(x)
local nRow, pos, offset, newcol, a

    if ( !Empty(aEdit[ES_PATTERN]) )
        nRow := aEdit[ES_ROW]
        pos := x + MLCToPos(aEdit[ES_TEXT],     ;
                            aEdit[ES_WIDTH],    ;
                            aEdit[ES_ROW],      ;
                            aEdit[ES_COL],      ;
                            aEdit[ES_TABSIZE],  ;
                            aEdit[ES_WRAP]      ;
                           )

        offset := pos + At(aEdit[ES_PATTERN],Substr(aEdit[ES_TEXT], pos)) - 1
        if ( offset >= pos )
            a := MPosToLC(aEdit[ES_TEXT],   ;
                          aEdit[ES_WIDTH],  ;
                          offset,           ;
                          aEdit[ES_TABSIZE],;
                          aEdit[ES_WRAP]    ;
                         )

            aEdit[ES_ROW] := a[1]
            newcol := a[2]
            aEdit[ES_RELCOL] := aEdit[ES_RELCOL] + newcol - aEdit[ES_COL]
            aEdit[ES_COL] := newcol

            if ( aEdit[ES_ROW] - nRow <=                                ;
                 aEdit[ES_BOTTOM] - aEdit[ES_TOP] - aEdit[ES_RELROW]    ;
               )

                aEdit[ES_RELROW] := aEdit[ES_RELROW] + aEdit[ES_ROW] - nRow

            end

            Msg("B£squeda acabada.")

        else
            Msg("Cadena no hallada.")
        end
    else
        Msg("")
    end

return (NIL)


****
*   Search()
*

func Search()
local pattern

    pattern := Prompt("   Buscar :", PadR(aEdit[ES_PATTERN], 64))
    pattern := Ltrim(Rtrim(pattern))
    if ( !Empty(pattern) )
        aEdit[ES_PATTERN] := pattern
        xSearch(0)
    else
        Msg("")
    end

return (NIL)


****
*   SearchAgain()
*

func SearchAgain()
return (xSearch(1))


****
*   ufunc()
*

func ufunc(nMode, nLine, nCol)
local nKey

    aEdit[ES_LASTKEY]   := nKey := LastKey()
    aEdit[ES_ROW]       := nLine
    aEdit[ES_COL]       := nCol
    aEdit[ES_RELROW]    := Row() - aEdit[ES_TOP]
    aEdit[ES_RELCOL]    := Col() - aEdit[ES_LEFT]


    if (nMode == ME_INIT)
        if (aEdit[ES_WRAP])
            /* desactiva el ajuste de texto */
            aEdit[ES_WRAP] := .f.
            return (ME_TOGGLEWRAP)  /* NOTA */
        end

        SetCursor( if(aEdit[ES_INS], SC_INSERT, SC_NORMAL) )

    elseif (nMode == ME_IDLE)
        StatMsg()

    else
        /* Excepci¢n de teclado */
        if (nMode == ME_UNKEYX)
            aEdit[ES_CHANGED] := .t.
        end

        do case
        case (nKey == K_F1)
            DisplayHelp()

        case (nKey == K_ALT_H)
            DisplayHelp()

        case (nKey == K_ALT_F)
            Msg( "Fichero: " + aEdit[ES_FILE] )

        case (nKey == K_ALT_O)
            NewName()

        case (nKey == K_INS)
            aEdit[ES_INS] := !Set(_SET_INSERT)
            SetCursor( if(aEdit[ES_INS], SC_INSERT, SC_NORMAL) )
            return (nKey)

        case (nKey == K_ALT_I)
            aEdit[ES_INS] := !Set(_SET_INSERT)
            SetCursor( if(aEdit[ES_INS], SC_INSERT, SC_NORMAL) )
            return (K_INS)

        case (nKey == K_ALT_S)
            /* B£squeda */
            return (K_CTRL_W)

        case (nKey == K_ALT_A)
            /* Repetir b£squeda */
            return (K_CTRL_W)

        case (nKey == K_ALT_X)
            aEdit[ES_LASTKEY] := EK_QUIT
            return (K_CTRL_W)

        case (nKey == EK_QUIT)
            return (K_CTRL_W)

        case (nKey == EK_WRITE)
            return (K_CTRL_W)

        otherwise
        end
    end

return (0)



****
*   EditWrite()
*

func EditWrite()
local lRet

    lRet := .t.
    if ( aEdit[ES_CHANGED] )
        Msg( "Escribiendo " + aEdit[ES_FILE] )

        if ( MemoWrit(aEdit[ES_FILE], aEdit[ES_TEXT]) )
            Msg("Escritura correcta.")
            aEdit[ES_CHANGED] := .f.

        else
            Msg("Error de escritura.")
            lRet := .f.

        end
    else
        Msg("El fichero no se ha modificado.")

    end

return (lRet)


****
*   Msg()
*

func Msg(text)
static oldLength := 0

    if (oldLength != 0)
        @ nMaxRow, 0 SAY Replicate(" ", oldLength)
    end

    @ nMaxRow, 0 SAY text
    oldLength := Len(text)

return (NIL)


****
*   StatMsg()
*

func StatMsg()
local cLine, cCol, nCtype, nRow, nCol

    cLine := PadR( LTrim(Str(aEdit[ES_ROW])), 6 )
    cCol := LTrim( Str(aEdit[ES_COL]) )

    nCtype := SetCursor(0)
    nRow := Row()
    nCol := Col()
    @ nMaxRow, nStatCol SAY "Fila: " + cLine + "Columna: " + cCol + "  "
    DevPos(nRow, nCol)
    SetCursor(nCtype)

return (NIL)


****
*   PExit()
*

func PExit()
local c, lRet, nCtype

    lRet = .t.
    if ( aEdit[ES_CHANGED] )
        nCtype := SetCursor(SC_NORMAL)

        Msg("Abandonar " + aEdit[ES_FILE] + " [sne]?" )
        while ( !((c := Upper(Chr(InKey(0)))) $ ("SNE" + Chr(K_ESC))) )
        end

        if ( c == "E" )
            lRet := EditWrite()

        else

            if ( c != "S" )
                lRet := .f.
            end

            Msg("")
        end

        SetCursor(nCtype)

    end

return (lRet)


****
* DisplayHelp()
*

func DisplayHelp()
local cScreen := SaveScreen (03, 01, MaxRow () - 4, MaxCol() - 1), nCtype
Local cOldColor
Local cTexto := ;
                ;
     "                              ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                             " + CRLF + ;
     "                              ³ Ayuda de PE ³                             " + CRLF + ;
     "                              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                             " + CRLF + ;
     " Flecha derecha/Ctrl-E          Mueve el cursor una l¡nea arriba          " + CRLF + ;
     " Flecha abajo/Ctrl-X            Mueve el cursor una l¡nea abajo           " + CRLF + ;
     " Flecha izquierda/Ctrl-S        Mueve el cursor un car cter a la izquierda" + CRLF + ;
     " Flecha derecha/Ctrl-D          Mueve el cursor un car cter a la derecha  " + CRLF + ;
     " Ctrl-Flecha izquierda/Ctrl-A   Mueve el cursor una palabra a la izquierda" + CRLF + ;
     " Ctrl-Flecha derecha/Ctrl-F     Mueve el cursor una palabra a la derecha  " + CRLF + ;
     " Inicio                         Mueve el cursor al principio de l¡nea     " + CRLF + ;
     " Fin                            Mueve el cursor al final de la l¡nea      " + CRLF + ;
     " Ctrl-Inicio                    Mueve el cursor al inicio de la ventana   " + CRLF + ;
     " Ctrl-Fin                       Mueve el cursor al final de la ventana    " + CRLF + ;
     " RePag                          Retroceso de p gina                       " + CRLF + ;
     " AvPag                          Avance de p gina                          " + CRLF + ;
     " Ctrl-RePag                     Mueve el cursor al principio de fichero   " + CRLF + ;
     " Ctrl-AvPag                     Mueve el cursor al fin de fichero         " + CRLF + ;
     " Intro                          Nueva l¡nea                               " + CRLF + ;
     " Supr                           Eliminar car cter sobre el cursor         " + CRLF + ;
     " Retroceso                      Eliminar car cter a la izquierda          " + CRLF + ;
     " Tab                            Inserta tabulador o espacios              " + CRLF + ;
     " Ctrl-Y                         Borrar l¡nea                              " + CRLF + ;
     " Ctrl-T                         Elimina la palabra a la derecha           " + CRLF + ;
     " Alt-H, F1                      Visualiza la pantalla de ayuda            " + CRLF + ;
     " Ctrl-W                         Grabar y salir                            " + CRLF + ;
     " Alt-W                          Grabar y continuar                        " + CRLF + ;
     " Alt-O                          Cambiar nombre del fichero                " + CRLF + ;
     " Alt-X, Esc                     Salir                                     " + CRLF + ;
     " Alt-F                          Visualizar el nombre del fichero          " + CRLF + ;
     " Alt-S                          Buscar                                    " + CRLF + ;
     " Alt-A                          Repetir la b£squeda                       " + CRLF + ;
     " Alt-I, Ins                     Modo inserci¢n/sobreescritura             " + CHR (26)

    nCType := Set (_SET_CURSOR, SC_NONE)
    cOldColor := SetColor ("W+/R")
    @ 03, 01, MaxRow () - 4, MaxCol () - 1 BOX B_DOUBLE Color "W/R"
    @ MaxRow () - 4, 05 Say ' ' + Chr (25) + Chr (24) + "Movimiento. ESC acabar. " ;
                        Color "R/W"
    MemoEdit (cTexto, 04, 02, MaxRow () - 5, MaxCol() - 2, .F.)

    RestScreen (03, 01, MaxRow () - 4, MaxCol() - 1, cScreen)
    SetColor (cOldColor)
    SetCursor(nCtype)
  
return (NIL)
