@ECHO OFF
IF MDX==%1 GOTO FINISH
IF NTX==%1 GOTO FINISH

:DRIVER
cls
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³                                                 ³
ECHO ³  ¨Sobre qu‚ controlador de base de datos desea  ³
ECHO ³  instalar el controlador nacional?              ³
ECHO ³                                                 ³
ECHO ³   A. DBFMDX                                     ³
ECHO ³   B. DBFNTX / DBFNDX                            ³
ECHO ³                                                 ³
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ECHO 
CHOOSE Escoja una opci¢n o pulse Esc para acabar.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL   3 GOTO DRIVER
IF ERRORLEVEL   2 GOTO NTX
IF ERRORLEVEL   1 GOTO MDX

:MDX
CLS
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³       M¢dulos nacionales para el controlador DBFMDX       ³
ECHO ³ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ³
ECHO ³                                                           ³
ECHO ³   A. Ingl‚s    MDXUK.OBJ      E. Italiano  MDXITA.OBJ     ³
ECHO ³   B. Flamenco  MDXDUT.OBJ     F. Espa¤ol   MDXSPA.OBJ     ³
ECHO ³   C. Franc‚s   MDXFRE.OBJ     G. Sueco     MDXSWE.OBJ     ³
ECHO ³   D. Alem n    MDXGER.OBJ                                 ³
ECHO ³                                                           ³
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ECHO 
CHOOSE Escoja una opci¢n o pulse Esc para acabar.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL  8 GOTO MDX
IF ERRORLEVEL  7 NACION MDX SWE
IF ERRORLEVEL  6 NACION MDX SPA
IF ERRORLEVEL  5 NACION MDX ITA
IF ERRORLEVEL  4 NACION MDX GER
IF ERRORLEVEL  3 NACION MDX FRE
IF ERRORLEVEL  2 NACION MDX DUT
IF ERRORLEVEL  1 NACION MDX UK


:NTX
CLS
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³        M¢dulos nacionales para el controlador DBFNTX/NDX        ³
ECHO ³ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ³
ECHO ³                                                                 ³
ECHO ³   A. Ingl‚s      NTXUK.OBJ        I. Island‚s   NTXIC850.OBJ*   ³
ECHO ³   B. Dan‚s       NTXDAN.OBJ       J. Island‚s   NTXIC861.OBJ*   ³
ECHO ³   C. Flamenco    NTXDUT.OBJ       K. Italiano   NTXNOR.OBJ      ³
ECHO ³   D. Franc‚s     NTXFRE.OBJ       L. Noruego    NTXNOR.OBJ      ³
ECHO ³   E. Finland‚s   NTXFIN.OBJ       M. Portugu‚s  NTXPOR.OBJ      ³
ECHO ³   F. Alem n      NTXGER.OBJ       N. Espa¤ol    NTXSPA.OBJ      ³
ECHO ³   G. Griego      NTXGR437.OBJ*    O. Sueco      NTXSWE.OBJ      ³
ECHO ³   H. Griego      NTXGR851.OBJ*                                  ³
ECHO ³                                                                 ³
ECHO ³   * El n£mero indica la p gina de c¢digos utilizada.            ³
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ECHO 
CHOOSE Escoja una opci¢n o pulse Esc para acabar.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL  16 GOTO NTX
IF ERRORLEVEL  15 NACION NTX SWE
IF ERRORLEVEL  14 NACION NTX SPA
IF ERRORLEVEL  13 NACION NTX POR
IF ERRORLEVEL  12 NACION NTX NOR
IF ERRORLEVEL  11 NACION NTX ITA
IF ERRORLEVEL  10 NACION NTX IC861
IF ERRORLEVEL   9 NACION NTX IC850
IF ERRORLEVEL   8 NACION NTX GR851
IF ERRORLEVEL   7 NACION NTX GR437
IF ERRORLEVEL   6 NACION NTX GER
IF ERRORLEVEL   5 NACION NTX FIN
IF ERRORLEVEL   4 NACION NTX FRE
IF ERRORLEVEL   3 NACION NTX DUT
IF ERRORLEVEL   2 NACION NTX DAN
IF ERRORLEVEL   1 NACION NTX UK

:FINISH
NAT_OBJ -O MSG%2.OBJ %1%2.OBJ > nul
ECHO Copiando de %1%2 a %1SORT.OBJ
COPY %1%2.OBJ  %1SORT.OBJ

ECHO Copiando de MSG%2 a MSG.OBJ
COPY MSG%2.OBJ MSG.OBJ

:END






