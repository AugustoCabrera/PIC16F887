;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    AUX	    EQU	    0x20    
	    V1	    EQU	    0x21    ; loop interno.
	    V2	    EQU	    0x22    ; loop medio.
	    V3	    EQU	    0x23    ; loop externo.
   
;-------------------INICIALIZACIÓN----------------------------------------------
	    
	    ORG	    0x00
	    
	    GOTO    CONFIG_	    ; Comienzo configurando todo.
	    
	    ORG	    0x04
	    
	    GOTO    RUT_INT	    ; Cuando ocurre una interrupción, voy a la
				    ; rutina de la misma.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
            ORG	    0x05
	    
 CONFIG_    NOP			    ; Para evitar bug de MPLAB.
	    BANKSEL TRISB	    ; Seteo RB1 y RB2 como inputs y el resto de
	    MOVLW   b'00000110'	    ; bits de PORTB como outputs.
	    MOVWF   TRISB
	    BANKSEL ANSELH	    ; Seteo PORTB como digital.
	    CLRF    ANSELH
	    BANKSEL INTCON	    ; Habilito interrupciones por RB<2:1>.
	    MOVLW   b'10001000'
	    MOVWF   INTCON
	    BANKSEL IOCB
	    MOVLW   b'00000110'	    ; Habilito RB<2:1> como fuentes de
	    MOVWF   IOCB	    ; interrupción
	    BANKSEL PORTB	    ; Vuelvo al banco de PORTB para comenzar.
	    MOVLW   b'00000110'	    ; Limpio los registros a utilizar para
	    MOVWF   PORTB	    ; evitar basura.
	    CLRF    AUX
	    CLRF    V1
	    CLRF    V2
	    CLRF    V3
	    CLRW	    
	    GOTO    START

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
   START    GOTO    $		    ; El programa principal no hace nada.
				    ; Espero a que ocurra una interrupción.
				    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
 RUT_INT    BTFSC   INTCON,RBIF	    ; Si la interrupción fue por PORTB, hago un
	    CALL    BIT_TEST	    ; testeo para ver de qué bit vino la
	    BCF	    INTCON,RBIF
	    RETFIE		    ; interrupción.
	    
BIT_TEST    MOVFW   PORTB	    ; Guardo el estado de PORTB en AUX para no
	    MOVWF   AUX		    ; perder información.
	    BTFSS   AUX,1	    ; Testeo RB1...
	    CALL    LED_RB1	    ; Si está en 0 (se presionó), voy a LED_RB1.
	    BTFSS   AUX,2	    ; Sino, testeo RB2...
	    CALL    LED_RB2	    ; Si está en 0 (se presionó), voy a LED_RB2.
	    RETURN		    ; Si la interrupción fue por otro bit de
				    ; PORTB, no nos interesa, y vuelvo.
				    
 LED_RB1    BSF	    PORTB,3	    ; Si la interrupción fue por RB1, enciendo
	    CALL    TIMER_10S	    ; el LED 10 segundos, bajo la FLAG y vuelvo.
	    BCF	    PORTB,3
	    BCF	    INTCON,RBIF
	    RETFIE
	    
 LED_RB2    BSF	    PORTB,3	    ; Si la interrupción fue por RB1, enciendo
	    CALL    TIMER_5S	    ; el LED 5 segundos, bajo la FLAG y vuelvo.
	    BCF	    PORTB,3
	    BCF	    INTCON,RBIF
	    RETFIE
	    
TIMER_10S   MOVLW   .51	;Los cálculos están realizados arriba en el Anexo: Delay   
	    MOVWF   V3		    
  LMED10    MOVLW   .255
	    MOVWF   V2
  LINT10    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    
	    GOTO    $-1		    
	    DECFSZ  V2		    
	    GOTO    LINT10	    
	    DECFSZ  V3		    
	    GOTO    LMED10	    
	    RETURN
	    
TIMER_5S    MOVLW   .26		    
	    MOVWF   V3		
   LMED5    MOVLW   .255
	    MOVWF   V2
   LINT5    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		    
	    GOTO    $-1		    
	    DECFSZ  V2		    
	    GOTO    LINT5	
	    DECFSZ  V3		    
	    GOTO    LMED5	    
	    RETURN
END



