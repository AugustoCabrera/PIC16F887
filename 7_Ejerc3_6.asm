
; EJERCICIO 3.6 ---------------------------------------------------------------------------------------------------------------
   
    LIST p=16f887
    #INCLUDE <P16F887.INC>
    
    CONTADOR1 EQU  0X20   
    CONTADOR2 EQU  0X21
    CONTADOR3 EQU  0X22
 
 ORG 0

    MOVLW .5
    MOVWF CONTADOR3
    
LOOP3	MOVLW .255
	MOVWF CONTADOR2
	
LOOP2	MOVLW	.255
	MOVWF	CONTADOR1
	  
LOOP1	DECFSZ CONTADOR1,1
	GOTO LOOP1
	DECFSZ CONTADOR2,1
	GOTO LOOP2
	DECFSZ CONTADOR3,1
	GOTO LOOP3
	NOP
	END
	

