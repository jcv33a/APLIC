******************************************************************************
* NOMBRE DEL PROGRAMA:            LIBRERIA.PRG
*                                 LIBRERIA DE PROCEDIMIENTOS COMUN A TODOS LOS PROGRAMAS
*                                 EJEMPLO DE PROGRAMA DE APLICACION GESTION
* ULTIMO CAMBIO:                  06/20/90 8:00AM
* ESCRITO POR:                    ASHTON-TATE
******************************************************************************

PROCEDURE Add_new
   * A¤adir registro a la base de datos
   * Eliminar los registros anteriores de la pantalla
   @ 0,64 SAY SPACE(15) COLOR &c_yellow.
   * Mostrar la ayuda local obtenida con F9, si es posible
   IF lookup_ok
      DO Sho_look WITH dbf
   ENDIF
   DO Init_fld
   DO Get_data
   READ
   * Borrar la ayuda local de la pantalla
   @ 0,0 SAY SPACE(51)
   * Si el usuario no introdujo datos en los campos clave, salir sin almacenar
   IF "" = TRIM(&key.) .OR. READKEY() < 256
       RETURN
   ELSE
      * Cada aplicaci¢n busca posibles repeticiones en el campo clave si no son permitidas
      * Si las encuentra, salir del modo adicci¢n sin almacenar
      IF rec_is_dup
         * Reasignar el valor por defecto y salir
         rec_is_dup = .F.
         RETURN
      ELSE
         * A¤adir y almacenar el registro validado
         DO Sav_data
         GO record_num
      ENDIF
   ENDIF
RETURN

PROCEDURE Bar_def
   * Definir el men£ de ventana principal MENU DE OPCIONES, main_mnu
   mesg = "Pulse la inicial de una opci¢n del men£, o seleccione y pulse <Return>"
   DEFINE POPUP main_mnu FROM 2,58 TO 22,78 MESSAGE mesg
   DEFINE BAR  1 OF main_mnu PROMPT " MENU DE OPCIONES  " SKIP
   DEFINE BAR  2 OF main_mnu PROMPT " A¤adir registro"
   DEFINE BAR  3 OF main_mnu PROMPT " Modificar registro"
   DEFINE BAR  4 OF main_mnu PROMPT " Eliminar registro"
   DEFINE BAR  5 OF main_mnu PROMPT "-------------------" SKIP
   DEFINE BAR  6 OF main_mnu PROMPT " Siguiente registro"
   DEFINE BAR  7 OF main_mnu PROMPT " Registro anterior"
   DEFINE BAR  8 OF main_mnu PROMPT " Primer registro"
   DEFINE BAR  9 OF main_mnu PROMPT " Ultimo registro"
   DEFINE BAR 10 OF main_mnu PROMPT " Desplazamiento"
   DEFINE BAR 11 OF main_mnu PROMPT " Buscar registro"
   DEFINE BAR 12 OF main_mnu PROMPT "-------------------" SKIP
   DEFINE BAR 13 OF main_mnu PROMPT " Listar registros"
   DEFINE BAR 14 OF main_mnu PROMPT " Generar informes"
   DEFINE BAR 15 OF main_mnu PROMPT " Formar grupos" SKIP FOR dbf = "Mov_ctas"
   DEFINE BAR 16 OF main_mnu PROMPT " Contar registros"
   DEFINE BAR 17 OF main_mnu PROMPT " Indexar fichero"
   DEFINE BAR 18 OF main_mnu PROMPT " Texto de ayuda"
   DEFINE BAR 19 OF main_mnu PROMPT " Volver al men£"
   * Definir el men£ de ventana dest_mnu para fijar el destino de impresi¢n de un informe
   DEFINE POPUP dest_mnu FROM 13,10 TO 19,38 MESSAGE mesg
   DEFINE BAR 1 OF dest_mnu PROMPT "========= DESTINO =========" SKIP
   DEFINE BAR 2 OF dest_mnu PROMPT " Impresora"
   DEFINE BAR 3 OF dest_mnu PROMPT " Fichero"
   DEFINE BAR 4 OF dest_mnu PROMPT " Pantalla"
   DEFINE BAR 5 OF dest_mnu PROMPT " Volver al men£ de opciones"
   * Definir el menu de ventana rpt_mnu para fijar el destino de impresi¢n de un informe
   DEFINE POPUP rpt_mnu FROM 11, 5 TO 17,38 MESSAGE mesg
   DEFINE BAR 1 OF rpt_mnu  PROMPT "=========== INFORMES ===========" SKIP
   DEFINE BAR 2 OF rpt_mnu  PROMPT " Nombre del fichero: " + dbf
   DEFINE BAR 3 OF rpt_mnu  PROMPT " Lista de correo: "  + mlist ;
      SKIP FOR mlist = "NO DISPONIBLE"
   DEFINE BAR 4 OF rpt_mnu  PROMPT " Informe personalizado: " + Cli_rpt ;
      SKIP FOR Cli_rpt = "N/D"
   DEFINE BAR 5 OF rpt_mnu  PROMPT " Volver al men£ de opciones"
   * Definir qu‚ procedimientos son ejecutados por los men£s de ventana definidos
   ON SELECTION POPUP main_mnu DO Barpop
   ON SELECTION POPUP rpt_mnu  DO Barpop_r
   ON SELECTION POPUP dest_mnu DO Barpop_d
   * Definir ventanas para textos, mensajes, etc.
   DEFINE WINDOW alert      FROM 15, 3 TO 22,46 PANEL COLOR &c_alert.
   DEFINE WINDOW duplicat   FROM 15, 5 TO 21,70 PANEL COLOR &c_alert.
   DEFINE WINDOW lister     FROM  5, 5 TO 22,70 PANEL COLOR &c_list.
   DEFINE WINDOW look       FROM  6, 5 TO 16,65 PANEL COLOR &c_list.
   DEFINE WINDOW memo_windo FROM  7, 4 TO 19,75 PANEL COLOR &c_list.
RETURN

PROCEDURE Barpop
   * Ejecutar la opci¢n seleccionada por el usuario en el MENU DE OPCIONES
   DO CASE
       * BAR() = 1 es el t¡tulo del men£
       CASE BAR() = 2                  && A¤adir registro
          DO Add_new
       CASE BAR() = 3                  && Editar registro
          DO Edit
       CASE BAR() = 4                  && Eliminar registro
          DO Eraser
       CASE BAR() = 6                  && Siguiente registro
          DO Skip_rec WITH 1
       CASE BAR() = 7                  && Registro anterior
          DO Skip_rec WITH -1
       CASE BAR() = 8                  && Primer registro, seg£n ¡ndice activo
          GO TOP
       CASE BAR() = 9                  && Ultimo registro, seg£n ¡ndice activo
          GO BOTTOM
       CASE BAR() = 10                 && Saltar registros
          DO Skip_rec WITH 0
       CASE BAR() = 11                 && Buscar registro
          DO Find_rec WITH key, key1, keyNomb1, key2, keyNomb2, key3, keyNomb3
       CASE BAR() = 13                 && Listar registros
          DO List_rec
       CASE BAR() = 14                 && Generar informes
          SAVE SCREEN TO Pre_rept      && Almacenar pantalla
          ACTIVATE POPUP rpt_mnu
          RESTORE SCREEN FROM Pre_rept
          RELEASE SCREEN Pre_rept
       CASE BAR() = 15                 && Filtrar registros
          DO Filter
       CASE BAR() = 16                 && Contar registros
          ************
          IF NETWORK()
             * Desactivar el bloqueo de fichero para contar
             SET LOCK off
             DO Kount
             SET LOCK on
             ***********
          ELSE
             DO Kount
          ENDIF
       CASE BAR() = 17                  && Indexar fichero
          ************
          IF NETWORK()
             old_tag = ORDER()
             USE (dbf) EXCLUSIVE
             IF net_choice <> 27        && Comprobar respuesta a mensaje de error (Esc=27)
                DO Indexer
                SET EXCLUSIVE off
                USE (dbf) ORDER (old_tag)
             ENDIF
             ***********************
          ELSE
             DO Indexer
          ENDIF
       CASE BAR() = 18                  && Ayuda
          SET COLOR TO &c_standard.
          DO Ayuda
       CASE BAR() = 19                && Volver al men£ principal
          DEACTIVATE POPUP
   ENDCASE
   DO Dstatus                         && Visualizar n§ de registro y estado del filtro
   DO Show_data                       && Visualizar pantalla con el registro actual
   CLEAR GETS
   SET COLOR TO &c_popup.
RETURN

PROCEDURE Barpop_d
   * Ejecutar acci¢n seleccionada en el men£ Destino
   SET COLOR TO &c_popup.
   DO CASE
      * BAR() 1 is Grado of menu
      CASE BAR() = 2                  && Salida a impresora
         DO Prt_menu                  && Activar el men£ impresora para opciones de impresi¢n
         SET PRINTER on
         SET CONSOLE off
         DO Printout                  && Imprimir el informe seleccionado
         SET PRINTER off
         SET CONSOLE on
      CASE BAR() = 3                  && Salida a fichero
         answer = SPACE(8)
         ACTIVATE WINDOW alert
            @ 0,1 SAY "------- ENVIAR INFORME A FICHERO -------"
            @ 2,1 SAY "Nombre del fichero: " GET answer ;
               VALID "" <> TRIM(answer) ;
               MESSAGE "Introduzca un nombre de fichero de hasta ocho caracteres"
            READ
         DEACTIVATE WINDOW alert
         SET ALTERNATE TO &answer.
         SET ALTERNATE on
         SET CONSOLE off
         GO TOP
         DO Printout                  && Enviar informe o etiquetas elegidas a fichero
         SET ALTERNATE off
         SET CONSOLE on
      CASE BAR() = 4                  && Salida por pantalla
         SET COLOR TO &c_standard.
         CLEAR
         * Almacenar los par metros de p gina actuales
         plength  = _plength
         rmargin  = _rmargin
         * Fijar anchura y longitud de p gina para la pantalla
         _plength = 25
         _rmargin = 80
         DO Printout                  && Visualizar informes/etiquetas por pantalla
         CLEAR
         * Restabllecer par metros de p gina
         _plength = plength
         _rmargin = rmargin
         GO record_num                && Volver al registro original
      CASE BAR() = 5                  && Salir al men£ de opciones
         DEACTIVATE POPUP
   ENDCASE
   SET COLOR TO &c_standard.
   DEACTIVATE POPUP
RETURN

PROCEDURE Barpop_r
   * Seleccionar men£ de informes disponibles
   SET COLOR TO &c_popup.
   reportype = SPACE(6)
   DO CASE
      CASE BAR() = 2                  && Enviar informes de la base de datos Nombres al destino
         reportype = "LISTADO"
         ACTIVATE POPUP dest_mnu      && Activar men£ de impresi¢n
      CASE BAR() = 3                  && Enviar etiquetas de correos al destino
         reportype = "ETIQUETAS"
         ACTIVATE POPUP dest_mnu      && Activar men£ de destino de impresi¢n
      CASE BAR() = 4                  && Enviar informe personalizado al destino
         reportype = "PERSONALIZADO"
         ACTIVATE WINDOW alert
            * Obtener del usuario el nombre del informe personalizado
            * Primero, permitir errores de lectura y sonido de aviso
            ON READERROR
            SET BELL ON
            rpt_Nomb = SPACE(8)
            @ 0,1 SAY "-------- INFORME PERSONALIZADO ---------"
            @ 2,1 SAY "  Nombre del informe:" GET rpt_Nomb ;
               VALID FILE(TRIM(rpt_Nomb) + ".prg") ;
               MESSAGE "Introduzca un nombre de fichero de hasta ocho " + ;
                       "caracteres, p.ej. Inf_emp " ;
               ERROR "Nombre de fichero no v lido. Pro favor, introduzca de nuevo"
            READ
            * Volver a redireccionar los errores de lectura
            ON READERROR
            SET BELL OFF
         DEACTIVATE WINDOW alert
         IF LASTKEY() <> 27           && Se ha encontrado el informe
            SET COLOR TO &c_popup.
            ACTIVATE POPUP dest_mnu
         ENDIF
   ENDCASE
   SET COLOR TO &c_popup.
   DEACTIVATE POPUP
RETURN

PROCEDURE Sub_ret
   IF erased
      * Eliminar registros marcados para borrar (si los hay)
      ************
      IF NETWORK()
         USE (dbf) EXCLUSIVE
      ENDIF
      IF net_choice <> 27       && Saltar si el usuario pulsa Esc como opci¢n
      *******************       && al error de bloqueo en red
         ?? CHR(7)
         ACTIVATE WINDOW alert
            @ 0,1 SAY "--------- EMPAQUETANDO FICHERO ---------"
            @ 2,1 SAY "ELIMINANDO registro marcados ahora..."
            @ 3,1 SAY "Por favor, espere... NO APAGUE"
            PACK
         DEACTIVATE WINDOW alert
      ENDIF
   ENDIF
   * Desactivar
   CLOSE DATABASES
   CLEAR WINDOWS
   RELEASE ALL
   CLEAR
   ON ERROR
   ON KEY LABEL F9             && Desactivar redirecci¢n de F9/F10
   ON KEY LABEL F10
   * Restablecer entorno (en caso de acceso desde el centro de control/Punto indicativo)
   DO Rest_env
   CLEAR
RETURN TO MASTER               && Salir de la subaplicaci¢n

FUNCTION Duplicat
   PARAMETERS key
   * Usado si las repeticiones no est n terminadas
   * Almacena .T. en rec_is_dup si el usuario introduce claves repetidas
   rec_is_dup = .F.
   IF RECCOUNT() = 0 .OR. "" = TRIM(key)
      * No hace comprobaciones si la base de datos o campo(s) clave est  vacia
      RETURN rec_is_dup
   ENDIF
   record_num = RECNO()               && Guardar la posici¢n del registro actual
   SEEK  TRIM(key)
   * Determinar si la clave del registro est  repetida
   * Se usa PROMPT() en vez de BAR() para mayor claridad
   DO CASE
      CASE PROMPT() = " Editar registro"
         * El registro tiene la clave repetida si la b£squeda
         * encuentra otro distinto
         rec_is_dup =  record_num <> RECNO() .AND. FOUND()
      CASE PROMPT() = " A¤adir registro"
         * El nuevo registro est  repetido si la b£squeda encuentra otro registro
         rec_is_dup = FOUND()
   ENDCASE
   IF rec_is_dup                      && Mostrar los registros duplicados en pantalla
      ACTIVATE WINDOW duplicat
         CLEAR
         DO Warnbell
         ?  " --- REGISTRO DUPLICADO EN " + ;
            dbf + " ---"
         ?  "                     Duplicados no permitidos"
         DO CASE
            CASE dbf = "Cli"
               ?  " " + C¢d_cli + " " + Cliente
               ? "Este registro ya EXISTE en el fichero; vuelva a " + ;
                 "introducir el N§ de cliente"
            CASE dbf = "Proveeds"
               ?  " " + C¢d_prove + " " + Proveedor
               ? "Este registro ya EXISTE en el fichero; vuelva a " + ;
                 "introducir el N§ de proveedor"
            CASE dbf = "Art¡culo"
               ?  " " + C¢d_art + " " + Nom_art
               ? "Este registro ya EXISTE en el fichero; vuelva a " + ;
                 "teclear el N§ de art¡culo"
            CASE dbf = "Mov_ctas"
               ?  " " + N£m_fac + " " + C¢d_cli + " " + DTOC(Fecha_fac)
               ? "Este registro ya EXISTE en el fichero; vuelva a " + ;
                 "teclear el N§ de factura"
         ENDCASE
         WAIT "     Pulse espaciador para continuar..."
      DEACTIVATE WINDOW duplicat
   ENDIF
   GO record_num                     && Volver al registro inicial
RETURN .NOT. rec_is_dup

PROCEDURE Dstatus
   * Mostrar n£mero de registro actual y existencia de filtro
   * Establecer colores con intermitencia en on/off dependiendo de la configuraci¢n
   IF filters_on
      * Mostrar mensaje intermitente para la existencia de filtro
      @ 0,47 SAY "Filtro activo" COLOR &c_blink.
   ELSE
      SET COLOR TO &c_standard.
      * Borrar mensaje - no hay filtro
      @ 0,47
   ENDIF
   * Mostrar n£mero de registro actual en la pantalla
   @ 0,62 SAY "Registro n§" + STR(RECNO(),5,0) COLOR &c_yellow.
RETURN

PROCEDURE Edit
   * Editar registro actual
   * Mostrar texto de ayuda local - si est  disponible (establecida en cada aplicaci¢n)
   IF lookup_ok
      DO Sho_look WITH dbf
   ENDIF
   record_num = RECNO()
   * Almacenar la informaci¢n del registro en variables de memoria
   DO Load_fld
   IF NETWORK()                      && Editar datos en una red
      ready = .F.
      DO WHILE .NOT. ready
         IF CHANGE()
            * Si el registro fue cambiado por alguien desde que el primer usuario accedi¢
            DO Warnbell
            GO RECNO()           && Actualiza el registro con los datos cambiados
            IF DELETED()
               DO Show_msg WITH "ATENCION - el registro ha sido marcado para borrado"
               SKIP
               DO Show_data
               RETURN            && Salir al MENU DE OPCIONES - salir de la opci¢n de edici¢n
            ELSE
               DO Show_msg WITH ;
                  "Los datos se modificaron - la pantalla muestra las modificaciones"
               DO Load_fld           && Actualiza las variables de memoria con los datos del registro
            ENDIF
         ENDIF
         DO Get_data
         READ                        && Editar datos
         * Comprueba que ning£n otro usuario cambi¢ los datos durante esta edici¢n
         ready = .NOT. CHANGE()      && El bucle se repetir  si .NOT. CHANGED = .F.
      ENDDO
   ELSE                              && Edici¢n fuera de entorno de red
      DO Get_data
      READ                           && Editar datos
   ENDIF
   *****
   * Borrar texto de ayuda local de la pantalla
   @ 0,0 SAY SPACE(51)
   IF "" = TRIM(&key.) .OR. READKEY() < 256
      * Si se borr¢ la clave, o no hubo cambios, o se borr¢ el registro, salir
      RETURN
   ELSE
      * Almacenar en disco los datos editados
      DO Sav_data
   ENDIF
RETURN

PROCEDURE Eraser
   * Borrar el registro actual
   answer = " "
   ACTIVATE WINDOW alert
      @ 0,1 SAY "----------- BORRAR REGISTROS -----------"
      @ 2,1 SAY "¨Borrar este registro (S=S¡ N=No)" GET answer PICTURE "Y"
      READ
   DEACTIVATE WINDOW alert
   IF answer = "S"
      DELETE
      * Saltar al siguiente registro
      SKIP
      * Comprobar si el anterior registro fue marcado para borrar
      DO CASE
         CASE filters_on .AND. EOF()
            * Si ning£n registro cumple la condici¢n del filtro, desactivarlo
            SET FILTER TO
            filters_on = .F.
            * Ir al primer registro si el £ltimo fue marcado para borrar
            GO TOP
         CASE .NOT. filters_on .AND. EOF()
            * IR al primer registro si el £ltimo fue marcado para borrar
            GO TOP
      ENDCASE
      * Establecer que hay registro marcado para borrar
      erased = .T.
   ENDIF
RETURN

PROCEDURE Filt_ans
   * Pedir al usuario la condici¢n de filtro, si quiere establecerlo
   ACTIVATE WINDOW alert
      @ 0,1 SAY "-------- AGRUPAR POR UN FILTRO ---------"
      IF filters_on
         * Ventana de filtro - para desactivarlo
         @ 2,0 SAY "     Grupo seleccionado actualmente"
         @ 3,0 SAY "       ¨Desactivar filtro?"
         @ 4,0 SAY "       (D=Desactivar, N=No)" GET choice PICTURE "!" ;
           VALID choice $ "DN"
      ELSE
         * Ventana de filtro - para activarlo
         @ 2,1 SAY "Selecci¢n temporal de grupo de datos"
         @ 3,1 SAY "mediante condici¢(nes) de filtro    "
         @ 4,1 SAY "                                    "
         @ 5,1 SAY "¨Ejecutar? (S=S¡, N=No) " GET choice PICTURE "Y"
      ENDIF
      READ
   DEACTIVATE WINDOW alert
   IF choice = "N"              && No cambiar el estado del filtro
      RETURN TO Barpop          && Do terminar el proceso de filtro
   ENDIF
RETURN

PROCEDURE FindPrefijo
   PARAMETERS aCiudad
   * Mostrar ayuda local de prefijos telef¢nicos - por provincia
   i = INKEY()
   aPrefijo = 0
   ACTIVATE WINDOW alert
      CLEAR
      aPrefijo = LOOKUP(Prefijos->Prefijo,TRIM(aCiudad),Prefijos->Ciudad)
      ? " ---- CONSULTA DE PREFIJO TELEFONICO ----"
      IF .NOT. FOUND("Prefijos") .OR. "" = TRIM(aCiudad)
         DO Warnbell
         ? "Ciudad: " + TRIM(aCiudad) AT 2
         ? "NO ENCONTRADO en fichero de prefijos" AT 2
      ELSE
         ?
         ? "El PREFIJO TELEFONICO es: " + STR(aPrefijo,3) AT 2
         ? "para " + TRIM(aCiudad)  AT 16
      ENDIF
      ?
      i= INKEY(3)                   && Mostrarlo durante 3 segundos
   DEACTIVATE WINDOW alert
RETURN

PROCEDURE FindCli
   PARAMETERS Cliid
   * Mostrar ayuda local para c¢digo de cliente
   i= INKEY()
   aCli = ""
   ACTIVATE WINDOW alert
      CLEAR
      aCli = LOOKUP(Cli->Cliente,TRIM(Cliid),Cli->C¢d_cli)
      ? " ---- CONSULTA DE CODIGO DE CLIENTE -----"
      IF .NOT. FOUND("Cli") .OR. "" = TRIM(Cliid)
         DO Warnbell
         ? "Cliente N§: " + TRIM(Cliid) AT 2
         ? "NO ENCONTRADO en fichero de clientes" AT 2
      ELSE
         ? "Cliente:  " + TRIM(aCli)  AT 2
         ? "Tel‚fono: " + Cli->Tel‚fono  AT 2
         ? "Con N§:   " + TRIM(Cliid) AT 12
      ENDIF
      WAIT "  Pulse espaciador para continuar..."
   DEACTIVATE WINDOW alert
RETURN

PROCEDURE Find_rec
   PARAMETERS key, key1, keyNomb1, key2, keyNomb2, key3, keyNomb3
   * Obtener datos por los que buscar y mostrar un registro una vez encontrado
   STORE "" TO target1, target2, target3
   target1 = IIF(TYPE(key1) = "C", SPACE(LEN(&key1.)), {  /  /  })
   * Si key2 existe (la base de datos precisa dos claves)
   IF "NINGUNO" <> key2
      target2 = IIF(TYPE(key2) = "C", SPACE(LEN(&key2.)), {  /  /  })
      * Si key3 existe (la base de datos precisa 3 claves)
      IF "NINGUNO" <> key3
         target3 = IIF(TYPE(key3) = "C", SPACE(LEN(&key3.)), {  /  /  })
      ENDIF
   ENDIF
   ACTIVATE WINDOW alert
      @ 0,1 SAY "---------- BUSQUEDA DE DATOS -----------"
      @ 2, 1 SAY keyNomb1
      @ 2,15 GET target1  MESSAGE "Introduzca " + keyNomb1
      IF "NINGUNO" <> key2
         @ 3, 1 SAY keyNomb2
         @ 3,15 GET target2
         IF "NINGUNO" <> key3
            @ 4, 1 SAY keyNomb3
            @ 4,15 GET target3
         ENDIF
      ENDIF
      @ 5,1 SAY "Introduzca datos completos o parciales"
      READ
   DEACTIVATE WINDOW alert
   target = IIF(type(key1) = "C", target1, DTOC(target1))
   IF "NINGUNO" <> key2
      target = target + IIF(type(key2) = "C", target2, DTOC(target2))
      IF "NINGUNO" <> key3
         target = target + IIF(type(key3) = "C", target3, DTOC(target3))
      ENDIF
   ENDIF
   target = TRIM(target)
   IF RIGHT(target, 6) = "  /  /"
      * Si la fecha no ha sido rellenada, eliminar la plantilla
      target = LEFT(target, LEN(target) - 6)
   ENDIF
   IF "" = target
      * Si el usuario no introdujo nada (clave en blanco) => salir
      RETURN
   ENDIF
   * Almacenar el n£mero de registro actual
   record_num = RECNO()
   * Encontrar el registro con la clave pedida
   IF .NOT. SEEK(target)
      * Si no se encuentra target, convertir a may£sculas y mirar de nuevo
      IF .NOT. SEEK(UPPER(target))
         * Avisar al usuario con se¤al sonora y mensaje
         DO Warnbell
         DO Show_msg WITH " Registro no encontrado"
         * Volver al registro que se estaba visualizando
         GO record_num
      ENDIF
   ENDIF
RETURN

PROCEDURE Findpart
   PARAMETERS partid
   * Mostrar ayuda local para el c¢digo de pieza - base de datos Existen
   * cuando se pulse la tecla de funci¢n
   i = INKEY()
   p_Nomb = SPACE(30)
   ACTIVATE WINDOW alert
      CLEAR
      p_Nomb = LOOKUP(Art¡culo->Nom_art,TRIM(partid),Art¡culo->C¢d_art)
      ? " ---- CONSULTA DE CODIGO DE ARTICULO ----"
      IF .NOT. FOUND("Art¡culo") .OR. "" = TRIM(partid)
         DO Warnbell
         ? "Art¡culo N§: " + TRIM(partid) AT 2
         ? "NO ENCONTRADO en el fichero de Articulos." AT 2
      ELSE
         ? "Con N§:     " + partid       AT 2
         ? "Art¡culo:   " + TRIM(p_Nomb) AT 2
         ? "En almac‚n: " + STR(Art¡culo->Can_alm,4) AT 2
         ? "Precio: " AT 2, Art¡culo->Precio PICTURE "9,999,999", " ž"
      ENDIF
      WAIT "      Pulse espaciador para continuar..."
   DEACTIVATE WINDOW alert
RETURN

PROCEDURE Findvend
   PARAMETERS vendr
   * Mostrar ayuda local para los nombres de proveedor - Base de datos Proveeds
   * cuando se pulse la tecla de funci¢n
   i = INKEY()
   v_Nomb = SPACE(30)
   ACTIVATE WINDOW alert
      CLEAR
      v_Nomb = LOOKUP(Proveeds->Proveedor,TRIM(vendr),Proveeds->C¢d_prove)
      ? " --- CONSULTA DE CODIGO DE PROVEEDOR ----"
      IF .NOT. FOUND("Proveeds")
         DO Warnbell
         ? "Proveedor N§: " + TRIM(vendr) AT 2
         ? "NO ENCONTRADO en fichero Proveedores." AT 2
      ELSE
         ? "Proveedor: " + TRIM(v_Nomb) AT 2
         ? "Tel‚fono:  " + Proveeds->Tel‚fono AT 2
         ? "Con N§:    " + vendr AT 16
      ENDIF
      WAIT "   Pulse espaciador para continuar..."
   DEACTIVATE WINDOW alert
RETURN

PROCEDURE Kount
   * Contar y mostrar n£mero de registros de la base de datos
   record_num = RECNO()
   ACTIVATE WINDOW alert
     @ 0,1 SAY "----------- CONTAR REGISTROS -----------"
     @ 2,1 SAY "Contando, espere por favor..."
     * Usar count si el filtro est  activo (grupo de registros
     IF filters_on
        COUNT TO kount
     ELSE
        * Usar reccount si el filtro no est  activo (todos los registros)
        kount = RECCOUNT()
     ENDIF
     @ 2,1 SAY "Hay: " + STR (kount,6) + " registros en "+ dbf
     ?
     WAIT " Pulse cualquier tecla para continuar..."
   DEACTIVATE WINDOW alert
   * Volver al registro original (antes de contar)
   GO record_num
RETURN

PROCEDURE List_rec
   * Listar registros (en el orden del ¡ndice activo) a partir del actual
   * Tener en cuenta si el filtro est  activo
   record_num = RECNO()                 && Almacenar la posici¢n del registro actual
   ACTIVATE WINDOW lister
      answer = " "
      CLEAR
      @ 0,0 SAY "----------------------- LISTAR REGISTROS " + ;
                "-----------------------" ;
            COLOR &c_red.
      SCAN WHILE .NOT. answer $ "vV"
         LIST OFF NEXT 10 &list_flds.
         WAIT " Pulse espaciador para continuar o V para volver al " + ;
              "men£" TO answer
         CLEAR
      ENDSCAN
   DEACTIVATE WINDOW lister
   * Volver al registro original (antes de visualizar el listado)
   GO record_num
RETURN

PROCEDURE Look_msg
   DO CASE                                && Mostrar mensaje de b£squeda apropiado en la ventana
      CASE similar = .F.                  && No se encuentra informaci¢n similar
         @ 1,1 SAY "El c¢digo "+look_Nomb+" introducido no existe en " + ;
               "el fichero "+look_dbf
         ?
         WAIT "No hay un n£mero de cliente parecido a " + look_Nomb + ;
              " - Pulse V para volver." TO answer
      CASE similar = .T. .AND. listcount > 0
         && Datos parecidos encontrados y listados
         WAIT "Pulse espaciador para continuar con la lista o " + ;
              "V para para volver." TO answer
         CLEAR
   ENDCASE
   CLEAR
RETURN

FUNCTION Lookupid
   PARAMETERS l_target, look_dbf, look_Nomb, matchchars
   * During data entry or editing, valiFecha data entered into any of the
   * fields of Cliente ID, parts ID, Proveedor ID, and Empleado ID by checking
   * for their existence in their respective databases - list any similar data
   * by matching the first one or more characters (between entered data and
   * database).
   * Note: matchchars = number of Inicial matching characters for lookup lists
   * Example: list will show Clientes whose C¢d_cli's first two characters
   * match with the entered C¢d_cli's first two characters (matchchars = 2)
   IF .NOT. SEEK(l_target,(look_dbf))     && Seek data in its respective dbf
      ACTIVATE WINDOW look
      DO Warnbell
      answer = " "
      similar = .F.
      SELECT (look_dbf)                   && Usar el dbf apropiado par listar
      GO TOP
      DO WHILE .NOT. (EOF() .OR. answer $ "vV")
         * Mostrar lista de registros con el(los) mismo(s) caracter(es) inicial(es)
         * en el campo COD
         @ 0,0 SAY "-- ERROR EN ENTRADA: " + look_Nomb + ;
                   ". CODIGO NO VALIDO --"
         @ 1,0 SAY "          Lista de c¢digos similaes a " + look_Nomb + ;
                   "."
         ?
         listcount = 0
         DO CASE                         && Comprobar que base de datos se encuentra en uso
           CASE dbf = "Pedidos"
              DO CASE                    && Comprobar que variable est  siendo editada
                 CASE VARREAD() = "C¢d_cli"
                    SCAN FOR LIKE(SUBSTR(l_target,1,matchchars)+"*",C¢d_cli) ;
                       WHILE listcount <= 4
                       ? C¢d_cli, Cliente            && Visualizar registro
                       listcount = listcount + 1     && Incrementar el contador de la lista
                       similar = .T.                 && Datos encontrados y listados
                    ENDSCAN
                 CASE VARREAD() = "C¢d_art"
                    SCAN FOR LIKE(SUBSTR(l_target,1,matchchars)+"*",C¢d_art) ;
                       WHILE listcount <= 4
                       ? C¢d_art, SUBSTR(Nom_art,1,21), ;
                         SUBSTR(Descrip,1,24)
                       listcount = listcount + 1     && Incrementar el contador de la lista
                       similar = .T.                 && Datos encontrados y listados
                    ENDSCAN
                 CASE VARREAD() = "C¢d_emp"
                    SCAN FOR LIKE(SUBSTR(l_target,1,matchchars)+"*",C¢d_emp) ;
                       WHILE listcount <= 4
                       ? C¢d_emp, Apellido, Nombre   && Visualizar registro
                       listcount = listcount + 1     && Incrementar contador de la listar
                       similar = .T.                 && Datos encontrados y listados
                    ENDSCAN
              ENDCASE
           CASE dbf = "Art¡culo"
              SCAN FOR LIKE(SUBSTR(l_target,1,matchchars)+"*",C¢d_prove) ;
                 WHILE listcount <= 4
                 ? C¢d_prove, Proveedor              && Visualizar registro
                 listcount = listcount + 1           && Incrementar contador de la lista
                 similar = .T.                       && Datos encontrados y listados
              ENDSCAN
           CASE dbf = "Mov_ctas"
              SCAN FOR LIKE(SUBSTR(l_target,1,matchchars)+"*",C¢d_cli) ;
                 WHILE listcount <= 4
                 ? C¢d_cli, Cliente                  && Visualizar registro
                 listcount = listcount + 1           && Incrementar contador de la lista
                 similar = .T.                       && Datos encontrados y listados
              ENDSCAN
         ENDCASE
         DO Look_msg                                 && Visualizar mensaje en ventana
      ENDDO
      DEACTIVATE WINDOW look
      SELECT 1                                       && Usar la base de datos original
   ENDIF
RETURN not_valid = .NOT. FOUND((look_dbf))

PROCEDURE Net_err
   PARAMETERS err_number
   * Procedimiento de errores para redes
   DO CASE
      CASE err_number = 108
         * Fichero en uso por otro usuario
         IF "" <> TRIM(LKSYS(2))
            message = " " + dbf + " est  bloqueado por: " + LKSYS(2)
         ELSE
            message = " " + dbf + " est  bloqueado por alguien"
         ENDIF
      CASE err_number = 109
         * Registro bloqueado por otro usuario
         message = " Registro bloqueado por: " + LKSYS(2)
      CASE err_number = 110
         * Es preciso uso exclusivo del fichero para indexar/PACK
         message = "El fichero deber¡a ser usado en modo exclusivo"
      CASE err_number = 372 .OR. err_number = 373
         * Fichero o registro en uso por otro usuario
         message = MESSAGE()
      OTHERWISE
         message = " Error desconocido: " + MESSAGE()
   ENDCASE
   DO Warnbell
   ACTIVATE WINDOW alert
      CLEAR
      ? " ------- ERROR EN ENTORNO DE RED --------"
      ?
      ? message AT 1
      ? "Pulse espaciador par reintentar" AT 1
      ? " - o Esc para salir" AT 1
      net_choice = INKEY(0)          && Esperar cualquier tecla
   DEACTIVATE WINDOW alert
   IF net_choice <> 27               && No se ha pulsado Esc
      * Reintentear el proceso que provoc¢ el error
      RETRY
   ENDIF
RETURN

PROCEDURE Printout
   * Imprimier informes o etiquetas
   DO CASE
      CASE reportype = "LISTADO"
         REPORT FORM &dbf.
      CASE reportype = "ETIQUETAS"
         LABEL FORM &dbf.
      CASE reportype = "PERSONALIZADO"
         DO &rpt_Nomb.
   ENDCASE
   GO record_num
RETURN

PROCEDURE Prt_menu
   * Mostrar men£ de opciones de impresi¢n
   msg_num   = "Introduzca un n£mero"
   msg_logic = "Introduzca S o N"
   msg_enum  = "Pulse espaciador para otras opciones"
   * Fijar valores por defecto para las variables de impresi¢n de informes
   loffset  = 0
   lmargin  = 0
   rmargin  = 80
   indent   = 4
   plength  = 66           && 60 - Impresora HP laserjet
   STORE 1 TO pspacing, pbpage, pcopies
   pepage   = 9999
   peject   = "NONE"
   STORE .F. TO pwait, pquality
   ppitch   = "PICA"
   *
   ACTIVATE WINDOW lister
   CLEAR
   @  0, 0 SAY "---------------------- MENU DE IMPRESION " + ;
               "-----------------------" COLOR &c_red.
   @  2, 1 SAY "Par metro de p gina:"
   @  3, 1 SAY "==================="
   @  4, 1 SAY "Desplazamiento    " GET loffset ;
           PICTURE "99" MESSAGE msg_num
   @  5, 1 SAY "Margen izquierdo  " GET lmargin ;
           PICTURE "99" MESSAGE msg_num
   @  6, 1 SAY "Margen dercho     " GET rmargin ;
           PICTURE "99" MESSAGE msg_num
   @  7, 1 SAY "Sangrado          " GET indent ;
           PICTURE "99" MESSAGE msg_num
   @  8, 1 SAY "Longitud de p gina" GET plength ;
           PICTURE "99" MESSAGE msg_num
   @  9, 1 SAY "Interlineado      " GET pspacing ;
           PICTURE "9"  RANGE 1,3 MESSAGE msg_num
   @  2,26 SAY "Par metros de impresi¢n:"
   @  3,26 SAY "======================="
   @  4,26 SAY "Comenzar impr. en p gina" GET pbpage ;
           PICTURE "999"  MESSAGE msg_num
   @  5,26 SAY "Terminar impr. en p gina" GET pepage ;
           PICTURE "9999" MESSAGE msg_num
   @  6,26 SAY "N£mero de copias        " ;
           GET pcopies  PICTURE "999"  MESSAGE msg_num
   @  7,26 SAY "Expulsar papel          " GET peject ;
           PICTURE "@M BEFORE,AFTER,BOTH,NONE"  MESSAGE msg_enum
   @  8,26 SAY "Pausa entre p ginas     " GET pwait ;
           PICTURE "Y" MESSAGE msg_logic
   @  9,26 SAY "Tipo de letra           " GET ppitch ;
           PICTURE "@M DEFAULT,PICA,ELITE,CONDENSED" MESSAGE msg_enum
   @ 10,26 SAY "Calidad de impresi¢n    " GET pquality ;
           PICTURE "Y" MESSAGE msg_logic
   @ 12, 1 SAY "Introduzca los par metros deseados; pulse PgDn para salvar y salir"
   READ
   DEACTIVATE WINDOW lister
   * Asignar valores a las variables de sistema
   _ploffset = loffset
   _lmargin  = lmargin
   _rmargin  = rmargin
   _indent   = indent
   _plength  = plength
   _pspacing = pspacing
   _pbpage   = pbpage
   _pepage   = pepage
   _pcopies  = pcopies
   _peject   = peject
   _pwait    = pwait
   _ppitch   = ppitch
   _pquality = pquality
   SET COLOR TO &c_standard.
RETURN

PROCEDURE Rest_env
    * Restablecer entorno
    SET COLOR TO &c_standard.
    SET SCOREBOARD &scor.
    SET DELIMITERS &deli.
    SET HELP &hellp.
    SET CLOCK &clock.
    SET ESCAPE &esca.
    SET DELETED &delee.
    SET HEADING &head.
    SET STATUS &stat.
    SET SAFETY &safe.
    SET EXACT &exac.
    SET BELL &bell.
    SET NEAR &near.
    * Restablecer colores del sistema por defecto
    DO Colo_rese
    SET TALK &talk.
RETURN

PROCEDURE Sav_data
   * Datos nuevos: a¤adir registros a la base de datos
   * Datos editados/modificados: Actualizar el registro con las variables de memoria
   choice = "S"
   ACTIVATE WINDOW alert
      @ 0,1 SAY "----------- ALMACENAR DATOS ------------"
      @ 2,1 SAY "¨Almacenar los datos en disco? (S/N)" GET choice PICTURE "Y"
      READ
   DEACTIVATE WINDOW alert
   IF choice = "S"
      IF PROMPT() = " A¤adir registro"      && A¤adir registro en blanco
         APPEND BLANK
         record_num = RECNO()
      ENDIF
      * Actualizar la base de datos con las variables de memoria
      DO Repl_fld
   ELSE
      * No salvar datos, volver al registro original
      GO record_num
   ENDIF
RETURN

PROCEDURE Set_env
   PUBLIC talk
   talk         = SET("TALK")
   SET TALK off

   PUBLIC c_standard, c_data, c_fields, c_popup, c_alert, c_list
   PUBLIC c_red, c_blue, c_yellow, c_yelowhit, c_green, c_blink

   * Establecer variables de color para las aplicaciones
   IF ISCOLOR()
      * Tarjeta de v¡deo/monitor en color
      c_standard = "W/B,BG+/R,B"
      c_data     = "B/W,R/BG,B"
      c_fields   = "B/BG"
      c_popup    = "B/W,GR+/R"
      c_alert    = "GR+/R,B/W,R/G"
      c_list     = "W+/G,GR+/B,GR+/GR"
      c_red      = "R/W"
      c_blue     = "B/W"
      c_yellow   = "GR+/B"
      c_yelowhit = "GR+/W"
      c_green    = "G/W"
      c_blink    = "GR+*/B"
   ELSE
      * Tarjeta de v¡deo/monitor monocromo
      STORE "W+/N,N/W" TO c_standard, c_data, c_popup, c_alert, c_list
      STORE "W" TO  c_red, c_blue, c_yellow, c_yelowhit, c_green, c_fields
      c_blink = "W+*/N,N/W"
   ENDIF
   SET COLOR OF MESSAGES TO &c_blue.
   SET COLOR TO &c_standard.

   * Configurar el entorno de trabajo
   * Almacenar los mandatos SET, si el usuario entr¢ desde el punto indicativo o el centro de control
   PUBLIC scor, deli, hellp, clock, esca, delee, head, stat, safe
   PUBLIC exac, bell, near
   scor  = SET("SCOREBOARD")
   deli  = SET("DELIMITERS")
   hellp = SET("HELP")
   clock = SET("CLOCK")
   esca  = SET("ESCAPE")
   delee = SET("DELETED")
   head  = SET("HEADING")
   stat  = SET("STATUS")
   safe  = SET("SAFETY")
   exac  = SET("EXACT")
   bell  = SET("BELL")
   near  = SET("NEAR")

   * Establecer entorno para las aplicaciones
   SET SCOREBOARD off
   SET DELIMITERS off
   SET HELP    off
   SET CLOCK   off
   SET ESCAPE  off
   SET DELETED on
   SET HEADING on
   SET STATUS  off
   SET SAFETY  off
   SET TALK    off
   SET EXACT   off
   SET BELL    off
   SET NEAR    off
   PUBLIC erased, not_valid, rec_is_dup, filters_on, lookup_ok, choice
   PUBLIC record_num, net_choice
   PUBLIC target, look_dbf, matchchar, scanfield
   * Variables l¢gicas utilizadas como indicadores de estado
   STORE .F. TO  erased, not_valid, rec_is_dup, filters_on
   lookup_ok = .T.
   * Otras variables
   STORE "" TO choice,subset
   STORE 0 TO record_num, net_choice
   ************************************************
   * Establecer tratamiento de errores si se trabaja en red
   IF NETWORK()
      * La programaci¢n en red supone que las bases de datos ha sido CONVERTidas
      SET EXCLUSIVE off
      ON ERROR DO Net_err WITH ERROR()
      * Fijar n£mero de reintentos razonable (seg£n el ordenador)
      SET REPROCESS TO 3
   ENDIF
   ************************************************
   * Desactivar validaciones (PULSE ESPACIADOR)
   ON READERROR ??
RETURN

PROCEDURE Sho_look
   PARAMETERS db
   * Definir y mostrar tecla(s) de funci¢n para ayuda local (seg£n la base de datos)
   DO CASE
      CASE db = "Empleado" .OR. db = "Cli" .OR. db = "Proveeds"
         look_txt = "Pulse F9 para consultar el prefijo telef¢nico"
      CASE db = "Art¡culo"
         look_txt = "Pulse F9 para consultar nombre de proveedor y tel‚fono"
      CASE db = "Pedidos"
         look_txt = "Pulse F9 para consultar datos de clientes y F10 para n§ de art¡culo"
      CASE db = "Mov_ctas"
         look_txt = "Pulse F9 para consutar nombre de cliente y tel‚fono"
   ENDCASE
   @ 0,0 SAY look_txt COLOR &c_blink.
   i = INKEY(1)                                  && Parpadeo durante un segundo
   @ 0,0 SAY look_txt COLOR &c_yellow.
RETURN

PROCEDURE Show_msg
   PARAMETERS u_message
   _wrap = .T.
   ACTIVATE WINDOW alert
      @ 1,0 SAY u_message
      ?
      WAIT " Pulse espaciador para continuar..."
   DEACTIVATE WINDOW alert
RETURN

PROCEDURE Skip_rec
   PARAMETERS skipno
   * Saltar registro(s) delante o atr s en la base de datos
   DO CASE
   CASE skipno = 1         && Ir al siguiente registro (seg£n el ¡ndice activo)
      IF .NOT. EOF()
         SKIP
      ENDIF
   CASE skipno = -1        && Ir al registro anterior (seg£n el ¡ndice activo)
      IF .NOT. BOF()
         SKIP -1
      ENDIF
   CASE skipno = 0
      * Saltar registros - para ir a/visualizar registros delante o detr s del actual
      numb_2skip = 0
      ACTIVATE WINDOW alert
         @ 0,1 SAY "----------- SALTAR REGISTROS -----------"
         @ 2,1 SAY "*Cu ntos registros desea saltar?"
         @ 3,0 SAY "   (Ejemplo: 15 or -5) ?   " ;
               GET numb_2skip PICTURE "9999" ;
               MESSAGE "Introduzca un n§ positivo para ir hacia delante" + ;
                       "o negativo para ir hacia atr s"
         READ
      DEACTIVATE WINDOW alert
      IF .NOT. (BOF() .AND. numb_2skip < 0) .OR. (EOF() .AND. numb_2skip > 0)
         SKIP numb_2skip
      ENDIF
   ENDCASE

   * Comprobar si el puntero de registro apunta al principio o al final del fichero
   DO CASE
      CASE EOF()
         GO BOTTOM                  && Si es EOF, restablecer el puntero de registro
         DO Show_msg WITH " Ultimo registro del fichero " + dbf + "."
      CASE BOF()
         DO Show_msg WITH " Primer registro del fichero " + dbf + "."
   ENDCASE
RETURN

PROCEDURE Warnbell
   PRIVATE mwrap
   mwrap = _wrap           && Almacenar el valor de _wrap
   _wrap = .F.
   * Sonido de aviso para errores
   SET BELL TO 880,4
   ?? CHR(7)
   SET BELL TO 1400,4
   ?? CHR(7)
   SET BELL TO 880,4
   ?? CHR(7)
   SET BELL TO
   _wrap = mwrap
RETURN

**************************** FIN DE Librer¡a.PRG ******************************
