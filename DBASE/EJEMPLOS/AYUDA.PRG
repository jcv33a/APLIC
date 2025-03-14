
******************************************************************************
* NOMBRE DEL PROGRAMA:          AYUDA.PRG
*                               PROCEDIMIENTOS DE VISUALIZACION DE AYUDA
*                               EJEMPLO DE PROGRAMA DE APLICACION GESTION
* ULTIMO CAMBIO:                09/25/89 09:26AM
* ESCRITO POR:                  ASHTON-TATE
******************************************************************************

* Procedimiento principal
PROCEDURE Ayuda

    * Defininici�n de colores de pantalla
    IF ISCOLOR()
    c_help = "B/BG,GR+/G"
    ELSE
    c_help = "W+/N,W/N"
    ENDIF

    * Definici�n ventana de ayuda
    DEFINE WINDOW Helpscr FROM 0,0 TO 24,79 PANEL COLOR &c_help.
    ACTIVATE WINDOW Helpscr
    CLEAR
    * El menu de ventana actual determina la pantalla de ayuda a visualizar
    DO CASE
    CASE POPUP() = "MAINMENU"        && Ayuda para el men� de Gesti�n
        DO Help_main
    CASE POPUP() = "RPT_MNU"         && Ayuda para el men� de informes
        DO Help_rept
    CASE POPUP() = "DEST_MNU"        && Ayuda para el men� de Destino
        DO Help_dest
    CASE POPUP() = "MAIN_MNU"        && Ayuda para el men� de opciones
        DO Help_opti
    CASE POPUP() = "BACKMENU"        && Ayuda para el men� de copias de seguridad
        DO Help_back
    ENDCASE
    WAIT SPACE(12) + "Pulse cualquier tecla para volver al men�."
    CLEAR
    DEACTIVATE WINDOW Helpscr
    RELEASE WINDOW Helpscr
RETURN
*====================== fin del procedimiento principal ======================

PROCEDURE Help_main
* Visualizaci�n de la pantalla de ayuda del men� de Gesti�n
TEXT
   �� AYUDA - MENU PRINCIPAL ���������������������������������������������
   �����������������������������������������������������������������������
    Selecci�n             Prop�sito
    ��������������������  �����������������������������������������������
    EMPLEADOS             Subaplicaci�n de empleados
    CLIENTES              Subaplicaci�n de clientes
    PROVEEDORES           Subaplicaci�n de proveedores
    INVENTARIO            Subaplicaci�n de inventario
    ORDENES DE PEDIDO     Subaplicaci�n de �rdenes de pedido
    MOVIMIENTO DE CUENTAS Subaplicaci�n de movimiento de cuentas
    TELEFONOS (Prefijos)  Subaplicaci�n de prefijos

                                 �� Utilidades ��

    FACTURACION           Impresi�n de facturas
    ARCHIVAR/RESTAURAR    Archivar o restaurar ficheros de datos de Gesti�n
    VOLVER A dBASE        Salir de la aplicaci�n o volver al punto
                             indicativo o al centro de control
    SALIR AL DOS          Salir de la aplicaci�n y volver al DOS
   �����������������������������������������������������������������������

ENDTEXT
RETURN

PROCEDURE Help_opti
* Visualizaci�n de la pantalla de ayuda del men� de opciones
TEXT
   �� AYUDA - MENU DE OPCIONES �������������������������������������������
   �����������������������������������������������������������������������
    Selecci�n             Prop�sito
    ������������������    �����������������������������������������������
    A�adir registro       A�adir un nuevo registro al fichero
    Modificar registro    Editar/Modificar el registro actual
    Eliminar registro     Borrar/Eliminar el registro actual
    Siguiente registro    Desplazar al siguiente registro
    Registro anterior     Desplazar al registro anterior
    Primer registro       Acceder al primer registro del fichero
    Ultimo registro       Acceder al �ltimo registro del fichero
    Desplazamiento        Desplazar hacia delante o hacia atr�s n reg.
    Buscar registro       Buscar registro utilizando �ndices
    Listar registros      Listar reg. por pantalla desde registro actual
    Generar informes      Imprimir o visualizar informes/etiquetas
    Formar grupos         Especificar condici�n de filtro para selecci�n
    Contar registros      Calcular n�mero de registros en el fichero
    Indexar fichero       Crear o reconstruirr �ndices
    Volver al men�        Salir de la subaplicaci�n actual
   �����������������������������������������������������������������������

ENDTEXT
RETURN

PROCEDURE Help_rept
* Visualizaci�n de la pantalla de ayuda del men� de informes
TEXT


     �� AYUDA - MENU DE INFORMES ����������������������������������������
     ��������������������������������������������������������������������

      Selecci�n               Prop�sito
      �������������������     ������������������������������������������
      Nombre del fichero      Informe con datos del fichero

      Lista de correo         Imprimir etiquetas de correo

      Informe                 Ejecutar programa de informe personalizado
      personalizado           (no disponible en algunas subaplicaciones)

      Volver men� opciones    Volver al men� de opciones sin imprimir

     ��������������������������������������������������������������������




ENDTEXT
RETURN

PROCEDURE Help_dest
* Visualizaci�n de la pantalla de ayuda del men� de destino de impresi�n
TEXT



     �� AYUDA - MENU DE DESTINO DE IMPRESION ���������������������������
     �������������������������������������������������������������������

      Selecci�n              Prop�sito
      �������������������    ������������������������������������������
      Impresora              Enviar a impresora

      Fichero                Salida a fichero para posterior impresi�n

      Pantalla               Visualizar informe en pantalla

      Volver men� opciones   Volver al menu de opciones sin imprimir

     �������������������������������������������������������������������




ENDTEXT
RETURN

PROCEDURE Help_back
* Visualizar la pantalla de ayuda del men� Archivar/Restaurar
TEXT



      �� AYUDA - MENU ARCHIVAR/RESTAURAR  �����������������������������
      �����������������������������������������������������������������

       Selecci�n                  Prop�sito
       �����������������������    ������������������������������������
       Archivar datos en          Almacenar bases de datos e �ndices
       copia de seguridad         en discos flexibles

       Recuperar datos de         Recuperar bases de datos e �ndices
       copia de seguridad         de copia de seguridad

       Volver al men� principal   Volver al men� principal

      �����������������������������������������������������������������




ENDTEXT
RETURN
**************************** FIN DE AYUDA.PRG *******************************