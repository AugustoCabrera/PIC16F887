;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
  ; Conversiones de A/D por polling y el resultado se muestra en los 8 bits del puerto B
  ; Justificado a la derecha, VREF- por defecto, Fosc=4MHz
;-------------------LIBRERIAS---------------------------------------------------


 #INCLUDE    <P16F887.INC>
    LIST    P = 16F887
;-------------------CONFIGURACION PIC-------------------------------------------
    
        __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
  
;-------------------DECLARACION DE VARIABLES------------------------------------

DELAY EQU 0X20
 
        ORG 0x00
	   GOTO start
        ORG 0x05
       
start  
	MOVLW 0FFh ; PORTB =  11111111b
	MOVF  PORTB
	MOVWF TRISA ; PORTA son entradas
	CLRF  TRISB ; PORTB son salida
	BANKSEL TRISB
	CLRF TRISB	    ; puerto como salida
	MOVLW b'00001100'   ; AN2 y AN3 como entradas analogicas
	MOVWF TRISA	    
	MOVLW B'00000100' ; RA0,RA1,RA3 entradas analogicas
	MOVWF ADCON1 ; Justificado a la izquierda, 8 bits mas significativos en ADRESH
	BANKSEL ANSEL
	MOVLW b'00001100'
	MOVWF ANSEL
	CLRF ANSELH
	BANKSEL ADCON0
	MOVLW b'01001000'   ; AD converter usa clock de FOSC/8, canal de AD
	MOVWF ADCON0	    ; El pin RA2 es usado para convertir
	BSF ADCON0,0	    ; Conversor AD es habilitado, por ende, comienza adquisicion
	

loop	CALL ADQTIME;	;DELAY de adquisicion
	BSF ADCON0,GO	; Start Conversion PUEDO PONER UN BRACK PARA VER QUE CUMPLA LOS 11,5 seg en este caso si los cumple
	BTFSC ADCON0,GO	    ;doy inicio al tiempo de conversion 			   ; testeo bit GO/DONE
	GOTO $-1	; Conversion en progreso, permanezco en bucle
	BANKSEL ADRESL
	MOVF ADRESL,W	 ; Nibble inferior de la conversion es copiado en W
	BCF STATUS,RP0
	MOVWF PORTB	; BYTE es copiado en PORTB
	GOTO loop
	
	;AD132 es el tiempo que necesito dejar entre la config y la adquisicion
	; ese tiempo sirve con ADQTIME 
	
ADQTIME 
	    MOVLW 0x3		; ajusto delay para 11.5 seg 
	    MOVWF DELAY		; una vez debo pasado eso doy el inicio de conversion
loop2				; he dejado pasar el adquisicion 
	    DECFSZ DELAY,F	; y con esta instruccion al tiempo de conversion
	    GOTO loop2
	    RETURN
	    
	    END		    ;Fin de programa


