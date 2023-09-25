;===============================================================
; Returns the default drive a character variable string.
;
;    usage:    CALL Getdrive WITH <Memory variable>
;
;===============================================================
TITLE GETDRIVE -- Returns the default drive

_PROG     SEGMENT  BYTE
          ASSUME   CS:_PROG
;
GETPATH   PROC     FAR      ; Force a FAR RETurn.
;
          MOV      AX,[BX]  ; Check for null. (End of variable.)
          CMP      AX,0     ; Is the variable long enough?
          JE       Error    ; No, exit.
;
          MOV      SI,BX    ; Load variable offset in SI.
          MOV      AH,19h   ; Get the default drive.
          INT      21h      ; The default drive is returned in
                            ; AL.  (0 = A:, 1 = B:, etc.)
          ADD      AL,'A'   ; 41h = 'A.'
          MOV      [SI],AL
Error:    RET               ; Return to dBASE.
;
GETPATH   ENDP
;
_PROG     ENDS
          END
