; Escribir un programa que resuelva la ecuación: (A + B) ? C (posiciones 21H, 22H y 23H)


;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887


;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    VARA    EQU	    0x21    ; Estos registros van a conformar la
	    VARB    EQU	    0x22    ; ecuación.
	    VARC    EQU	    0x23
	    RESS    EQU	    0x24    ; Registro que alcamenará el resultado de
				    ; la suma.
         

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    MOVLW   .6		    ; Cargo valores aleatorios en cada variable.
	    MOVWF   VARA
	    MOVLW   .4
	    MOVWF   VARB
	    MOVLW   .11
	    MOVWF   VARC
	    CLRW		    ; Limpio el registro W con el mismo fin.
	    GOTO MAIN
	    
;-------------------INICIO DEL PROGRAMA-----------------------------------------

AJUSTAR	    COMF RESS,W	    ;EL RESULTADO OBTENIDO ESTA EN COMPLEMENTO A 2
	    MOVWF RESS
	    INCF RESS,F
	    GOTO TERMINAR   ;LO EXPRESO EN FORMATO COMÚN
	    
MAIN	    MOVF  VARA , W
	    ADDWF VARB , W
	    MOVWF RESS
	    MOVF VARC , W
	    SUBWF RESS,F
	    BTFSS STATUS, C
	    GOTO AJUSTAR
TERMINAR
            END
