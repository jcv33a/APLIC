@ECHO OFF
IF MDX==%1 GOTO FINISH
IF NTX==%1 GOTO FINISH

:DRIVER
cls
ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO �                                                 �
ECHO �  쮁obre qu� controlador de base de datos desea  �
ECHO �  instalar el controlador nacional?              �
ECHO �                                                 �
ECHO �   A. DBFMDX                                     �
ECHO �   B. DBFNTX / DBFNDX                            �
ECHO �                                                 �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO 
CHOOSE Escoja una opci줻 o pulse Esc para acabar.
ECHO 
IF ERRORLEVEL  27 GOTO END
IF ERRORLEVEL   3 GOTO DRIVER
IF ERRORLEVEL   2 GOTO NTX
IF ERRORLEVEL   1 GOTO MDX

:MDX
CLS
ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO �       M줰ulos nacionales para el controlador DBFMDX       �
ECHO 넌袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�
ECHO �                                                           �
ECHO �   A. Ingl굎    MDXUK.OBJ      E. Italiano  MDXITA.OBJ     �
ECHO �   B. Flamenco  MDXDUT.OBJ     F. Espa쨚l   MDXSPA.OBJ     �
ECHO �   C. Franc굎   MDXFRE.OBJ     G. Sueco     MDXSWE.OBJ     �
ECHO �   D. Alem쟮    MDXGER.OBJ                                 �
ECHO �                                                           �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO 
CHOOSE Escoja una opci줻 o pulse Esc para acabar.
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
ECHO 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO �        M줰ulos nacionales para el controlador DBFNTX/NDX        �
ECHO 넌袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�
ECHO �                                                                 �
ECHO �   A. Ingl굎      NTXUK.OBJ        I. Island굎   NTXIC850.OBJ*   �
ECHO �   B. Dan굎       NTXDAN.OBJ       J. Island굎   NTXIC861.OBJ*   �
ECHO �   C. Flamenco    NTXDUT.OBJ       K. Italiano   NTXNOR.OBJ      �
ECHO �   D. Franc굎     NTXFRE.OBJ       L. Noruego    NTXNOR.OBJ      �
ECHO �   E. Finland굎   NTXFIN.OBJ       M. Portugu굎  NTXPOR.OBJ      �
ECHO �   F. Alem쟮      NTXGER.OBJ       N. Espa쨚l    NTXSPA.OBJ      �
ECHO �   G. Griego      NTXGR437.OBJ*    O. Sueco      NTXSWE.OBJ      �
ECHO �   H. Griego      NTXGR851.OBJ*                                  �
ECHO �                                                                 �
ECHO �   * El n즡ero indica la p쟥ina de c줰igos utilizada.            �
ECHO 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
ECHO 
CHOOSE Escoja una opci줻 o pulse Esc para acabar.
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






