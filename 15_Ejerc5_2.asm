; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
; Escribir un programa que prenda un LED que se va desplazando cada vez que se pulsa la tecla conectada a RB0. 
; Al pulsar por primera vez la tecla se enciende el LED conectado a RB1 y al llegar a RB3 vuelve a RB1 
; y así indefinidamente. El programa principal no realiza tarea alguna y todo se desarrolla dentro de 
; la subrutina de interrupción. ¿Cómo reorganizaría el software y el hardware si usara resistencia de pull-up interna en RB0?
		
;-------------------LIBRERIAS---------------------------------------------------
	#INCLUDE    <P16F887.INC>
	    LIST    P = 16F887
;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
AUX 		EQU 0X20
STATUS_TEMP	EQU 0X70
W_TEMP		EQU 0X71
	
		
	ORG	0x0
	GOTO	CONF
	ORG	0x4
	GOTO    INTERRUPCION
	ORG	0x05

CONF	;Se configura puerto
	BANKSEL ANSELH
	CLRF ANSELH		; pongo todos los pines del puerto B como I/O digital
	
	BANKSEL TRISB	     
	CLRF	TRISB			; configuro todo el puerto B como salida
	BSF	TRISB,RB0		; configuro RB0 como entrada

	BANKSEL	PORTB
	CLRF	PORTB    ;me aseguro de que todo el puerto B esté en bajo (leds apagados)
		
	BSF	AUX,0 	 ;pongo en 1 el bit 0 para luego rotarlo cada vez que se pulse RB0
	
	BCF	OPTION_REG,INTEDG	; configuro la interrupción de RB0 por flanco descendente
	BCF	INTCON,INTF		; borro el Flag de interrupción
	BSF	INTCON,INTE		; habilito interrupción por RB0	
	BSF	INTCON,GIE		; habilitación global de las interrupciones 
	GOTO	MAIN
	
MAIN	GOTO	$

;*********************************
	INTERRUPCION
;*********************************   
;Se guarda contexto    
        MOVWF   W_TEMP      
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP

;ISR
	BCF	STATUS,C		; borro el carry porque voy a rotar luego un registro
	RLF	AUX,F			; roto hacia la izquierda el registro 
	MOVLW	0x02  ;este valor lo utilizaré solamente si llegó a 16 (RB3=1) para resetear el registro
	BTFSC	AUX,4			; testeo si ya pasó de RB3=1
	MOVWF	AUX			; pasó => vuelvo a encender RB1
	MOVF	AUX,W			; no pasó => cargo en W el valor del registro aux
	MOVWF	PORTB   		; muestro en el puerto B el valor del registro auxiliar
		
SALIR					;Se recupera contexto
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS	     
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,F

	BCF	INTCON,INTF
	RETFIE
	END	



