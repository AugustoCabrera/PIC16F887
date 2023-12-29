
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    AL	    EQU	    0x20    ; Estos registros van a conformar la
	    AH	    EQU	    0x21    ; operación.
	    BL	    EQU	    0x22
	    BH	    EQU	    0x23
	    AUX	    EQU	    0x24    ; Variable auxiliar.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    MOVLW   b'11001010'	    ; Cargo valores aleatorios en cada
	    MOVWF   AL		    ; variable.
	    MOVLW   b'00111011'
	    MOVWF   AH
	    MOVLW   b'10001111'
	    MOVWF   BL
	    MOVLW   b'01000100'
	    MOVWF   BH
	    CLRW		    ; Limpio W para evitar tener basura.
	    CLRF    AUX		    ; Limpio AUX con el mismo fin.

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
	    MOVF AL , W
	    ADDWF BL , W
	    MOVWF AL
	    BTFSC STATUS,C
	    INCF AUX,F
	    MOVF AH,W
	    ADDWF BH,W
	    MOVWF AH
	    MOVFW AUX
	    ADDWF AH,F
	    
            END


