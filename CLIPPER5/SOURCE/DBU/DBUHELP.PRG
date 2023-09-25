/***
*
*  Dbuhelp.prg
*
*  M¢dulo de ayuda de DBU 
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  Todos los derechos reservados.       
*
*/


******
*       syshelp
*
*   Visualiza las pantallas de ayuda contenidas en el fichero DBU.HLP.
*   El fichero de ayuda puede estar en cualquiera de estos lugares:
*
*               <directorio actual>
*               \CLIPPER\
*
*   La variable p£blica "helpfile" contiene el directorio\fichero o bien
*   una cadena vac¡a si no se ha hallado.
******
PROCEDURE syshelp
local saveColor
PRIVATE hrow, hcol, hwbuf, htext

saveColor := SetColor()

IF EMPTY(M->helpfile)
	error_msg("No se encuentra el fichero de ayuda DBU.HLP")

ELSE
	* Almacenamos la posici¢n del cursor
	hrow = ROW()
	hcol = COL()

	* Salvamos la pantalla
	hwbuf = SAVESCREEN (8, 07, 22, 72)

	* Borra la ventana y visualiza la caja
	SetColor(M->color8)
	scroll (8, 07, 22, 72, 0)
	@ 8, 07, 22, 72 BOX M->frame

	* Visualizaci¢n del t¡tulo del texto de ayuda
	SetColor(M->color10)
	@ 8, (76 - LEN(help_title[M->help_code])) / 2;
	SAY "  " + help_title[M->help_code] + "  "

	* Lectura del texto de ayuda
	htext = helptext(M->helpfile, M->help_code)

    * Eliminaci¢n del cursor
	SET CURSOR OFF

	* Visualizaci¢n del texto de ayuda
	SetColor(M->color8)
	MEMOEDIT(M->htext, 9, 08, 21, 71, .F.)

	* Reestablece la pantalla
	RESTSCREEN (8, 07, 22, 72, M->hwbuf)

	* Reestablece el cursor
	@ M->hrow,M->hcol SAY ""
	IF M->curs_on
		SET CURSOR ON

	ENDIF
ENDIF

* reset
SetColor(saveColor)
local_func = 0
RETURN


******
*       helptext()
*
*   Extrae el texto de ayuda del fichero de ayuda con el siguiente formato:
*
*   o   La cabecera del fichero de ayuda consiste en una tabla que contiene
*       el desplazamiento y longitud de cada bloque de texto de ayuda del
*       fichero.
*
*   o   Las entradas a esta tabla tienen 4 bytes de longitud consistentes
*       en dos n£meros binarios sin signo de 16 bits cada uno. El primero
*       de ellos representa el desplazamiento en el cual comienza el corres-
*       pondiente texto de ayuda, y el segundo es la longitud de ese texto 
*       en bytes.
*
*   o   Las entradas y sus textos de ayuda asociados estan dispuestos en
*       orden num‚rico de acuerdo con la variable p£blica "help_code" que
*       se usa para acceder al bloque correcto de texto.
*
*   o   Se asumir  que los n£meros situados en la cabecera del fichero
*       estar n en el formato compatible Intel; o sea, el byte menos 
*       significativo es el primero almacenado y el m s significativo
*       es el almacenado en £ltimo lugar.
******
FUNCTION helptext

PARAMETERS hfile, hnum
PRIVATE htbuf, hoff, hlen, hhandle

* abre el archivo y obtiene el manejador
hhandle = FOPEN(M->hfile)

IF FERROR() = 0
	* buffer de 512 bytes
	htbuf = SPACE(512)

	* lee la cabecera del archivo en memoria
	FREAD(M->hhandle, @htbuf, 512)

	* obtiene los 4 bytes correctos de la tabla
	htbuf = SUBSTR(M->htbuf, (4 * (M->hnum - 1)) + 1, 4)

	* convierte n£meros binarios (LSB, MSB) a n£meros en Clipper
	hoff = ASC(M->htbuf) + (256 * ASC(SUBSTR(M->htbuf, 2)))
	hlen = ASC(SUBSTR(M->htbuf, 3)) + (256 * ASC(SUBSTR(M->htbuf, 4)))

	* buffer
	htbuf = SPACE(M->hlen)

	* sit£a el archivo en la posici¢n correcta
	FSEEK(M->hhandle, M->hoff)

	* lee texto en el buffer
	FREAD(M->hhandle, @htbuf, M->hlen)

ELSE
	* retorna cadena vac¡a si hay error
	htbuf = ""

ENDIF

* cierra el archivo y libera manejador
FCLOSE(M->hhandle)
RETURN M->htbuf


* Fin del fichero: DBUHELP.PRG
