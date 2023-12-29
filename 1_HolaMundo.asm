;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------DECLARACION DE VARIABLES------------------------------------

	    TIEMPO EQU 0x20
	    
               ORG 0x0	  ;Donde comienza a guardar el programa , EN LA MEMORIA DE PROGRAMA LA FLASH!
	   
	    GOTO MAIN	  ;Lo primero que voy a poner en 0x0 es la instruccion GOTO
	     
	    ORG 0x5
;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    
MAIN  BSF STATUS,RP0
	BCF STATUS,RP1
	CLRF TRISB	   ;TRISB es un registro que pertenece a la memoria de DATOS! ES LA MEMORIA RAM
	BCF STATUS,RP0	   ; cada Puerto tiene 9 pines
B1	BSF PORTB, RB0
	CALL RETARDO
	BCF PORTB , RB0
	CALL RETARDO
	GOTO B1
	
ORG 0X10		     ;ti = 1e-6 seg
	
RETARDO  MOVLW .255	    ;1*1ti
	MOVWF TIEMPO	    ; 1*1ti
B2	DECFSZ TIEMPO,F	    ;254*1ti + 1*2ti
	GOTO B2		    ; 254*2ti
	RETURN		    ; 1 *2ti
	
	END



