; Programa que enciende en forma dinámica un conjunto de seis displays 7 segmentos 
; y muestre los digitos de un buffer de 6 elementos en BCD no empaquetado

 LIST P=16F887 
 include <p16f887.inc>
 
 __CONFIG _CONFIG1, _FOSC_EXTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON

 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
TIEMPO EQU 0x21
DIGI1 EQU 0x30
 
    ORG 0x0
    GOTO INICIO
    ORG 0x05
    
INICIO
	BSF STATUS, RP0
	CLRF TRISA; pins Puertos A y B todos salida
	CLRf TRISB
	 BSF STATUS, RP1
	CLRF ANSEL
	CLRF ANSELH
	BCF STATUS, RP0
	BCF STATUS, RP1	    ;vuelvo al banco 0

TODOS_DIG
	MOVLW DIGI1
	MOVWF FSR	  ;apunta al primer digito a mostrar
	MOVLW B'11111110' ;habilita digito a mostrar
	MOVWF PORTA

OTRO_DIG  MOVF INDF,W	;lee dato hexadecimal a mostrar
	  CALL CONV_7SEG	;llama a subrutana convierte a 7 segmentos
	  MOVWF PORTB     ;escribe digito en 7 segmento
	  CALL RETARDO	;Lo mantiene encendido un tiempo
	  BSF STATUS,C	;carry en 1 para poder rotar
	  RLF PORTA,F	;desplaza el 0 al próximo dígito
	  INCF FSR,F	;apunta al próximo dato a mostrar
	  BTFSC PORTA,6	;ya mostró los 6 digitos?
	  GOTO OTRO_DIG	;no mostró todo, va al próximo digito
 
CONV_7SEG   ADDWF PCL, F	;suma a PC el valor del digito
	     RETLW 0x40		;obtiene el valor 7 segmentos del 0
	     RETLW 0x79		;obtiene el valor 7 segmentos del 1
	     RETLW 0x24		;obtiene el valor 7 segmentos del 2
	     RETLW 0x30         ;obtiene el valor 7 segmentos del 3
	     RETLW 0x19		;obtiene el valor 7 segmentos del 4
	     RETLW 0x12         ;obtiene el valor 7 segmentos del 5
	     RETLW 0x02         ;obtiene el valor 7 segmentos del 6
	     RETLW 0x78		;obtiene el valor 7 segmentos del 7
	     RETLW 0x00         ;obtiene el valor 7 segmentos del 8
	     RETLW 0x18		;obtiene el valor 7 segmentos del 9
	     RETLW 0x08		;obtiene el valor 7 segmentos del A
	     RETLW 0x03		;obtiene el valor 7 segmentos del B
	     RETLW 0x06		;obtiene el valor 7 segmentos del C
	     RETLW 0x21		;obtiene el valor 7 segmentos del D
	     RETLW 0x06         ;obtiene el valor 7 segmentos del E
	     RETLW 0x0E		;obtiene el valor 7 segmentos del F

			    ;	    CICLO
RETARDO	MOVLW m		    ;	    2		     Este es m
	MOVWF DELAY1	    ;	    1
LOOP1	MOVLW n		    ;	    1		     Este es n
	MOVWF DELAY2	    ;	    m
LOOP2	MOVLW p		    ;	    nm		     Este es p
	MOVWF DELAY3	    ;	    nm
LOOP3 	DECFSZ DELAY3, F    ;	    (p-1)nm+2nm
	GOTO LOOP3	    ;	    2(p-1)nm
	DECFSZ DELAY2, F    ;	    (n-1)m+2m
	GOTO LOOP2	    ;	    2(n-1)m
	DECFSZ DELAY1, F    ;	    (m-1)+2
	GOTO LOOP1	    ;	    2(m-1)
	RETURN		    ;	    2

END
	   
	
	     
	     
	     
	     
	  


