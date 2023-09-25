cls
echo off
cls
if not exist runtime.exe goto wrong
if not exist runtime.cac goto wrong

if %1x==x goto useage
if %1==off goto off
if %1==OFF goto off
if %1==ext goto extended
if %1==EXT goto extended
if %1==lim goto expanded
if %1==LIM goto expanded
goto useage

:off
del rtcache.ovl >nul
if not exist runtime1.exe goto OFFDONE
copy runtime1.exe runtime.exe>nul
del runtime1.exe >nul
:OFFDONE
echo Memoria cach‚ de RunTime desactivada.
goto out

:extended
copy ext.ovl rtcache.ovl >nul
if exist runtime1.exe goto EXTDONE
copy runtime.exe runtime1.exe >nul
copy runtime.cac runtime.exe >nul
:EXTDONE
echo Memoria cach‚ en modo extendido de RunTime activada.
goto out

:expanded
copy exp.ovl rtcache.ovl >nul
if exist runtime1.exe goto EXPDONE
copy runtime.exe runtime1.exe >nul
copy runtime.cac runtime.exe >nul
:EXPDONE
echo Memoria cach‚ en modo expandido de RunTime activada.
goto out

:wrong
echo  Ejecute CACHERT desde el directorio del RunTime de dBASE IV.
echo  La configuraci¢n del cach‚ del RunTime no se ha modificado.
goto out

:useage
echo Para modificar la configuraci¢n de la memoria cach‚ del RunTime ...
echo Teclee: CACHERT [TIPO]
echo Las opciones de TIPO son:
echo                      off ........ Desactiva la memoria cach‚
echo                      ext ........ Activa cach‚ en memoria extendida
echo                      lim ........ Activa cach‚ en memoria expandida

:out
