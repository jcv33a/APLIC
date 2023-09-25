
******************************************************************************
* NOMBRE DEL PROGRAMA:          AYUDA.PRG
*                               PROCEDIMIENTOS DE VISUALIZACION DE AYUDA
*                               EJEMPLO DE PROGRAMA DE APLICACION GESTION
* ULTIMO CAMBIO:                09/25/89 09:26AM
* ESCRITO POR:                  ASHTON-TATE
******************************************************************************

* Procedimiento principal
PROCEDURE Ayuda

    * Defininiciขn de colores de pantalla
    IF ISCOLOR()
    c_help = "B/BG,GR+/G"
    ELSE
    c_help = "W+/N,W/N"
    ENDIF

    * Definiciขn ventana de ayuda
    DEFINE WINDOW Helpscr FROM 0,0 TO 24,79 PANEL COLOR &c_help.
    ACTIVATE WINDOW Helpscr
    CLEAR
    * El menu de ventana actual determina la pantalla de ayuda a visualizar
    DO CASE
    CASE POPUP() = "MAINMENU"        && Ayuda para el menฃ de Gestiขn
        DO Help_main
    CASE POPUP() = "RPT_MNU"         && Ayuda para el menฃ de informes
        DO Help_rept
    CASE POPUP() = "DEST_MNU"        && Ayuda para el menฃ de Destino
        DO Help_dest
    CASE POPUP() = "MAIN_MNU"        && Ayuda para el menฃ de opciones
        DO Help_opti
    CASE POPUP() = "BACKMENU"        && Ayuda para el menฃ de copias de seguridad
        DO Help_back
    ENDCASE
    WAIT SPACE(12) + "Pulse cualquier tecla para volver al menฃ."
    CLEAR
    DEACTIVATE WINDOW Helpscr
    RELEASE WINDOW Helpscr
RETURN
*====================== fin del procedimiento principal ======================

PROCEDURE Help_main
* Visualizaciขn de la pantalla de ayuda del menฃ de Gestiขn
TEXT
   ออ AYUDA - MENU PRINCIPAL อออออออออออออออออออออออออออออออออออออออออออออ
   อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
    Selecciขn             Propขsito
    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ  ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    EMPLEADOS             Subaplicaciขn de empleados
    CLIENTES              Subaplicaciขn de clientes
    PROVEEDORES           Subaplicaciขn de proveedores
    INVENTARIO            Subaplicaciขn de inventario
    ORDENES DE PEDIDO     Subaplicaciขn de ขrdenes de pedido
    MOVIMIENTO DE CUENTAS Subaplicaciขn de movimiento de cuentas
    TELEFONOS (Prefijos)  Subaplicaciขn de prefijos

                                 ฤฤ Utilidades ฤฤ

    FACTURACION           Impresiขn de facturas
    ARCHIVAR/RESTAURAR    Archivar o restaurar ficheros de datos de Gestiขn
    VOLVER A dBASE        Salir de la aplicaciขn o volver al punto
                             indicativo o al centro de control
    SALIR AL DOS          Salir de la aplicaciขn y volver al DOS
   อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

ENDTEXT
RETURN

PROCEDURE Help_opti
* Visualizaciขn de la pantalla de ayuda del menฃ de opciones
TEXT
   ออ AYUDA - MENU DE OPCIONES อออออออออออออออออออออออออออออออออออออออออออ
   อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
    Selecciขn             Propขsito
    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    Aคadir registro       Aคadir un nuevo registro al fichero
    Modificar registro    Editar/Modificar el registro actual
    Eliminar registro     Borrar/Eliminar el registro actual
    Siguiente registro    Desplazar al siguiente registro
    Registro anterior     Desplazar al registro anterior
    Primer registro       Acceder al primer registro del fichero
    Ultimo registro       Acceder al ฃltimo registro del fichero
    Desplazamiento        Desplazar hacia delante o hacia atr s n reg.
    Buscar registro       Buscar registro utilizando กndices
    Listar registros      Listar reg. por pantalla desde registro actual
    Generar informes      Imprimir o visualizar informes/etiquetas
    Formar grupos         Especificar condiciขn de filtro para selecciขn
    Contar registros      Calcular nฃmero de registros en el fichero
    Indexar fichero       Crear o reconstruirr กndices
    Volver al menฃ        Salir de la subaplicaciขn actual
   อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

ENDTEXT
RETURN

PROCEDURE Help_rept
* Visualizaciขn de la pantalla de ayuda del menฃ de informes
TEXT


     ออ AYUDA - MENU DE INFORMES ออออออออออออออออออออออออออออออออออออออออ
     ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

      Selecciขn               Propขsito
      ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ     ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
      Nombre del fichero      Informe con datos del fichero

      Lista de correo         Imprimir etiquetas de correo

      Informe                 Ejecutar programa de informe personalizado
      personalizado           (no disponible en algunas subaplicaciones)

      Volver menฃ opciones    Volver al menฃ de opciones sin imprimir

     ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ




ENDTEXT
RETURN

PROCEDURE Help_dest
* Visualizaciขn de la pantalla de ayuda del menฃ de destino de impresiขn
TEXT



     ออ AYUDA - MENU DE DESTINO DE IMPRESION อออออออออออออออออออออออออออ
     อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

      Selecciขn              Propขsito
      ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
      Impresora              Enviar a impresora

      Fichero                Salida a fichero para posterior impresiขn

      Pantalla               Visualizar informe en pantalla

      Volver menฃ opciones   Volver al menu de opciones sin imprimir

     อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ




ENDTEXT
RETURN

PROCEDURE Help_back
* Visualizar la pantalla de ayuda del menฃ Archivar/Restaurar
TEXT



      ออ AYUDA - MENU ARCHIVAR/RESTAURAR  อออออออออออออออออออออออออออออ
      อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

       Selecciขn                  Propขsito
       ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
       Archivar datos en          Almacenar bases de datos e กndices
       copia de seguridad         en discos flexibles

       Recuperar datos de         Recuperar bases de datos e กndices
       copia de seguridad         de copia de seguridad

       Volver al menฃ principal   Volver al menฃ principal

      อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ




ENDTEXT
RETURN
**************************** FIN DE AYUDA.PRG *******************************