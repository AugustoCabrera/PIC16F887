;--------------EJERCICIO 3.5 ---------------------------------------------------
;Escribir un programa que su ejecución demore un milisegundo (Cristal de 4MHz).
   
    LIST p=16f887
    #INCLUDE <P16F887.INC>

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    LIM	      EQU     0x21   
	    CONTADOR  EQU     0x20   
	    
	    
;-------------------CARGO VALORES RANDOM------------------------------------	    
	    
	    MOVLW   .250	    ; Cargo A1 en W.
	 	    
;-------------------INICIO DEL PROGRAMA-----------------------------------------
	
				;	CICLOS
	    MOVWF LIM		;	  1    
	    MOVWF CONTADOR	;	  1
  LOOP	    NOP			;         1
	    DECFSZ  CONTADOR,F	;	1 O 2
	    GOTO    LOOP	;	  2
	    GOTO $
	    END 



