; Strsubst.asm (Source for Strsubst.bin)
;
; Substitute characters in a character string.
;
; Usage - CALL command:
;
;       LOAD Strsubst
;       CALL Strsubst WITH <expC1>, <expC2>, <expC3>
;
; Usage - CALL() function:
;
;       LOAD Strsubst
;       result = CALL("Strsubst", <expC1>, <expC2>, <expC3>)
;
;       Strsubst searches through <expC1>, replacing all occurrences
;       of the first character in <expC2> with the first character
;       in <expC3>.
;
CODE    SEGMENT BYTE PUBLIC 'CODE'
STRSUB  PROC    FAR
ASSUME  CS:CODE

        PARAM1  EQU   ES:[DI+0]
        PARAM2  EQU   ES:[DI+4]
        PARAM3  EQU   ES:[DI+8]
        PARAM4  EQU   ES:[DI+12]
        PARAM5  EQU   ES:[DI+16]
        PARAM6  EQU   ES:[DI+20]
        PARAM7  EQU   ES:[DI+24]

START:
        PUSH  BP                ; Save stack frame
        MOV   BP, SP

; Quit if there aren't at least 3 parameters.
        CMP   CX, 3
        JL    DONE

; Load first byte of 2nd paramter in CL
        LDS   BX, PARAM2        ; DS:BX points to 2nd parameter
        MOV   CL, [BX]          ; Store 1st byte

; Load first byte of 3nd paramter in CH
        LDS   BX, PARAM3        ; DS:BX points to 3rd parameter
        MOV   CH, [BX]          ; Store 1st byte in CH

; Point DS:BX to 1st parameter
        LDS   BX, PARAM1

; Loop for each character in 1st parameter
AGAIN:  MOV   AL, [BX]          ; Get next character in AL
        CMP   AL, 0             ; Is it end of string?
        JE    DONE              ;    Yes: exit
        CMP   AL, CL            ; Is it character we're searching for?
        JNE   NEXT              ;    No:  don't replace
        MOV   [BX], CH          ;    Yes: replace
NEXT:   INC   BX                ; Point to next
        JMP   AGAIN             ;

DONE:   POP   BP                ; Restore stack frame
        RET

STRSUB  ENDP
CODE    ENDS
        END
