/***
*
*  Dbunet.prg
*
*  Rutinas de Soporte de Red para DBU
*
*  Copyright (c) 1990-1993, Computer Associates International Inc.
*  Todos los derechos reservados.
*
*/

#include "common.ch"
#define NET_WAIT  1


/***
*
*  ErrMsg( <cMsg>, [<acChoices>] ) --> nChoice
*
*  Mecanismo de di logo que visualiza cMsg y presenta al usuario las 
*  opciones contenidas en la matriz acChoices.
*
*  Par metros:
*     cMsg      - El mensaje que se mostrar  al usuario. Se pueden mostrar
*                 mensajes de m s de una l¡nea insertando en la cadena el
*                 car cter (;) en el lugar d¢nde se desee el salto de l¡nea.
*
*     acChoices - Matriz opcional que contiene las opciones como cadenas de
*                 caracteres. Si no se especifica el par metro acChoices,
*                 se mostrar  £nicamente la opci¢n "Ok".
*
*  Devuelve:
*     El n£mero de opci¢n que se ha seleccionado.
*
*/
FUNCTION ErrMsg( cMsg, acChoices )
   RETURN ( ALERT( cMsg, acChoices ) )



/***
*
*  NetMode( [<lOpenMode>] ) --> lFilesOpenedShared
*
*  Determina el modo de apertura por defecto de los ficheros
*                 
*  Par metro:
*     lOpenMode - Si se pasa, determina el nuevo modo de apertura:
*                 .T. - Apertura en modo compartido (opci¢n por defecto)
*                 .F. - Apertura en modo exclusivo
*
*  Devuelve: El modo actual de apertura por defecto de DBU.
*
*/
FUNCTION NetMode( lNewMode )
   
   STATIC lOpenMode := .T.
   RETURN ( IIF( lNewMode != NIL, lOpenMode := lNewMode, lOpenMode ))



/***
*
*  NetUse( <cDatabase>, [<lOpenMode>], [<nWaitSeconds>], 
*          [<cAlias>], [<lNoAlert>] ) --> lSuccess
*
*  Intenta abrir una base de datos en red con reintentos consecutivos.
*
*  Par metros:
*     cDatabase    - El nombre de la base de datos a abrir
*
*     lOpenMode    - Modo de apertura: .T. abre el fichero en modo exclusivo
*                    y .F. lo hace en compartido. 
*
*     nWaitSeconds - N£mero de segundos de temporizaci¢n entre intentos de
*                    apertura. (Valor por defecto, NET_WAIT)
*
*     cAlias       - Alias a usar en este  rea de trabajo. (Valor por        
*                    defecto, el nombre del fichero).
*
*     lNoAlert     - Si es .T., se desactiva la notificaci¢n del fallo de  
*                    apertura al usuario.
*
*  Devuelve:
*     .T. si se pudo abrir el fichero en el modo especificado. Si no fue
*     as¡, devuelve .F.
*/
FUNCTION NetUse( cDatabase, lOpenMode, nSeconds, cAlias, lNoAlert )
   
   LOCAL cErrMsg        // Mensaje de error a visualizar
   LOCAL lForever       // Variable que determina infinitos reintentos
   LOCAL lRet := .F.    // Valor de retorno, se asume lo peor

   DEFAULT lOpenMode TO !NetMode()  // Se determina por NetMode ()
   DEFAULT nSeconds  TO NET_WAIT    // Dos segundos por defecto
   DEFAULT cAlias    TO MakeAlias( cDatabase )  // Alias por defecto
   DEFAULT lNoAlert  TO .F.         // Alert activado

   cErrMsg := "Imposible abrir fichero en;modo " + ;
              IIF( lOpenMode, "exclusivo", "compartido" )

   lForever := ( nSeconds == 0 )    // infinitos intentos si nSeconds es cero

   WHILE ( lForever .OR. ( nSeconds > 0 ))
      
      IF lOpenMode
          USE ( cDatabase ) ALIAS ( cAlias ) EXCLUSIVE
      ELSE
          USE ( cDatabase ) ALIAS ( cAlias ) SHARED
      ENDIF

      IF !NETERR()                // Si lo hemos abierto, salimos
         lRet := .T.
         EXIT
      ENDIF

      INKEY(1)                    // Esperamos un segundo y reintentamos
      nSeconds--

      //
      // Damos al usuario la opci¢n de abandonar o reintentar la operaci¢n 
      // si est  activada la visulizaci¢n del error, el intento no es finito
      // y el per¡odo de temporizaci¢n se ha agotado.
      //
      IF ( !lNoAlert .AND. !lForever .AND. ( nSeconds <= 0 ))
         IF ( ErrMsg( cErrMsg, { "Abandonar", "Reintentar" } ) == 2 )
            nSeconds := NET_WAIT
         ENDIF
      ENDIF

   ENDDO

   RETURN ( lRet )



/***
*
*  NetPack() --> lSuccess
*
*  Rutina que realiza un purgado en red con control de errores
*
*  Devuelve .T. si el purgado se ha realizado correctamente y .F. si
*  no ha sido as¡
*
*/
FUNCTION NetPack()
   
   LOCAL lRet := .F.    // Valor de retorno por defecto de NetPack ()
   
   // Si tenemos el fichero abierto de forma exclusiva podemos purgar ahora
   IF !NetMode()
      PACK
      lRet := .T.
   ELSE
      
      //
      // Tendremos que abrir en exclusivo, purgar y despu‚s volver a abrir
      // en modo compartido, ya que estamos en red
      //
      IF !NetUse( cur_dbf, .T., NIL, NIL, .T. )
         ErrMsg( "La operaci¢n de PURGADO ha fallado;No se ha podido abrir el fichero;en modo exclusivo" )
      ELSE
         PACK
         IF NetUse( cur_dbf, NIL, NIL, NIL, .T. )
            lRet := .T.    // La operaci¢n termin¢ con ‚xito
         ELSE
            // ­No deber¡a pasar nunca!
            ErrMsg( "No se puede abrir el fichero;despu‚s de realizar el PURGADO.;El fichero est  cerrado." )
         ENDIF
      ENDIF

   ENDIF

   RETURN ( lRet )



/***
*
*  NetZap() --> lSuccess
*
*  Rutina que realiza un vaciado de una base de datos en red con control de
*  errores
*
*  Devuelve .T. si el vaciado se realiz¢ con ‚xito y .F. en otro caso.
*
*/
FUNCTION NetZap()
   
   LOCAL lRet := .F.    // Valor de retorno de NetZap()
   
   // Si tenemos el fichero abierto en modo exclusivo ya podemos vaciarla
   IF !NetMode()
      ZAP
      lRet := .T.
   ELSE
      
      //
      // Debemos abrirla en modo exclusivo, vaciarla y luego abrirla en modo
      // compartido.                    
      //
      IF !NetUse( cur_dbf, .T., NIL, NIL, .T. )
         ErrMsg( "La operaci¢n de VACIADO ha fallado;No se ha podido abrir el fichero en modo exclusivo.")
      ELSE
         ZAP
         IF NetUse( cur_dbf, NIL, NIL, NIL, .T. )
            lRet := .T.    // Vaciada correctamente
         ELSE
            // ­No deber¡a pasar nunca!
            ErrMsg( "No puede abrirse el fichero una vez vac¡o.;El fichero est  cerrado" )
         ENDIF
      ENDIF

   ENDIF

   RETURN ( lRet )



/***
*
*  NetAppBlank( [<nWaitSeconds>] ) --> lSuccess
*
*  Rutina que a¤ade un registro a una base de datos en red con control de
*  errores
*
*  Par metros:
*     nWaitSeconds - N£mero de segundos que deben transcurrir entre cada 
*                    reintento (Valor por defecto: NET_WAIT)
*
*  Devuelve:
*     .T. si el registro pudo a¤adirse y .F. en otro caso.
*
*/
FUNCTION NetAppBlank( nWaitSeconds )
   
   LOCAL lForever          // Variable que determina infinitos reintentos
   LOCAL lRet    := .F.    // Valor de retorno. .T. indica a¤adido   
   LOCAL cErrMsg := "No se ha podido a¤adir el registro"  // Texto del mensaje de error

   DEFAULT nWaitSeconds TO NET_WAIT
   lForever := ( nWaitSeconds == 0 )

   WHILE ( lForever .OR. ( nWaitSeconds > 0 ))
      
      APPEND BLANK
      IF !NETERR()
         lRet := .T.
         EXIT
      ENDIF

      INKEY(.5)         // Esperamos medio segundo
      nWaitSeconds -= .5

      // Le damos al usuario la opci¢n de abandonar o reintentar la operaci¢n
      IF ( !lRet .AND. !lForever .AND. ( nWaitSeconds <= 0 ))
         IF ( ErrMsg( cErrMsg, { "Abandonar", "Reintentar" } ) == 2 )
            nWaitSeconds := NET_WAIT
         ENDIF
      ENDIF

   ENDDO

   RETURN ( lRet )



/***
*
*  NetRLock( [<nWaitSeconds>] ) --> lSuccess
*
*  Funci¢n que obtiene el bloqueo de un registro en red con control de 
*  errorres.
*
*  Par metros:
*     nWaitSeconds - N£mero de segundos que deben transcurrir entre cada 
*                    reintento (alor por defecto: NET_WAIT)
*
*  Devuelve:
*     .T. si el registro se a¤adi¢ y .F. en otro caso.
*
*/
FUNCTION NetRLock( nWait )
   
   LOCAL lForever          // Variable que determina infinitos intentos
   LOCAL lRet    := .T.    // Valor de retorno, .T. indica ‚xito.    
   LOCAL cErrMsg := "Imposible bloquear el registro"  // Texto del mensaje de error

   DEFAULT nWait TO NET_WAIT
   lForever := ( nWait == 0 )

   WHILE ( NetMode() .AND. ( lForever .OR. ( nWait > 0 )))
      
      IF RLOCK()
         EXIT
      ENDIF

      INKEY( .5 )          // Esperamos medio segundo
      nWait -= .5

      // Dejamos que el usuario abandone o reintente
      IF ( !lForever .AND. ( nWait <= 0 ))
         IF ( ErrMsg( cErrMsg, { "Abandonar", "Reintentar" } ) == 2 )
            nWait := NET_WAIT
         ELSE
            lRet := .F.
         ENDIF
      ENDIF

   ENDDO

   RETURN ( lRet )




/***
*        Rutinas de servicio
*/


/***
*
*  MakeAlias( cString ) --> cAliasName
*
*  Procesa cString eliminando unidad, v¡a y extensi¢n. Devuelve s¢lo el
*  nombre del fichero.
*
*  Par metros:
*     cString - La cadena de caracteres a procesar
*
*  Devuelve: El nombre de fichero contenido en cString
*
*/
FUNCTION MakeAlias( cString )

   LOCAL nPos     // Usado para localizar la posici¢n de los caracteres
                  // buscados en la cadena

   // Eliminaci¢n de la unidad y de la v¡a
   IF (( nPos := RAT( "\", cString )) != 0 )
      cString := SUBSTR( cString, ++nPos )
   ENDIF

   // Eliminaci¢n de la extensi¢n, si existe
   IF (( nPos := RAT( ".", cString )) != 0 )
      cString := SUBSTR( cString, 1, --nPos )
   ENDIF

   RETURN ( cString )

// Fin de fichero: DBUNET.PRG
