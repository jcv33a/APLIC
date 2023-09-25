cls
echo off
cls
if not exist dbase.exe goto wrong
if not exist dbase.cac goto wrong

if %1x==x goto useage
if %1==off goto off
if %1==OFF goto off
if %1==ext goto extended
if %1==EXT goto extended
if %1==lim goto expanded
if %1==LIM goto expanded
goto useage

:off
if not exist dbase1.exe goto OFFDONE
del dbcache.ovl >nul
copy dbase1.exe dbase.exe>nul
del dbase1.exe >nul
:OFFDONE
echo Memoria cach‚ de dBASE desactivada.
goto out

:extended
copy ext.ovl dbcache.ovl >nul
if exist dbase1.exe goto EXTDONE
copy dbase.exe dbase1.exe >nul
copy dbase.cac dbase.exe >nul
:EXTDONE
echo Memoria cach‚ en modo extendido de dBASE activada.
goto out

:expanded
copy exp.ovl dbcache.ovl >nul
if exist dbase1.exe goto EXPDONE
copy dbase.exe dbase1.exe >nul
copy dbase.cac dbase.exe >nul
:EXPDONE
echo Memoria cach‚ en modo expandido de dBASE activada.
goto out

:wrong
echo  Ejecute CACHEDB desde el directorio de dBASE IV.
echo  La configuraci¢n del cach‚ de dBase IV no se ha modificado.
goto out

:useage
echo Para modificar la configuraci¢n de la memoria cach‚ de dBASE IV ...
echo Teclee: CACHEDB [TIPO]
echo Las opciones de TIPO son:
echo                      off ........ Desactiva la memoria cach‚
echo                      ext ........ Activa cach‚ en memoria extendida
echo                      lim ........ Activa cach‚ en memoria expandida

:out
