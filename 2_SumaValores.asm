
	;Escribir un programa que sume dos valores guardados en los Registros 21H y 22H
	;con resultado en 23H y 24H
	
	;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------DECLARACION DE VARIABLES------------------------------------

	    VAL1  EQU 0X21 
	    VAL2  EQU 0X22
	    ResultLOW EQU 0X23
	    ResultHIGH EQU 0X24
	    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

     ORG	    0x0
 
	    MOVLW .255
	    MOVWF VAL1
	    CLRW
	    MOVLW .255
	    MOVWF VAL2
	    CLRW
	    
	    GOTO MAIN

;-------------------INICIO DEL PROGRAMA-----------------------------------------

MAIN	    MOVF  VAL1,W    ; Cargo el valor de VAL1 en W, (IGUAL MOVFW VAR1)
	    ADDWF VAL2,W     ; Sumo lo que hay en W con VAL2 y lo almaceno en W.
	    MOVWF ResultLOW   ; Almaceno W + VAL2 en ResultLOW  
	    BTFSC STATUS,C
	    INCF  ResultHIGH
	    END






