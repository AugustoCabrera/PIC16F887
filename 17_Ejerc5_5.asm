; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
;Se desea que al apretar el pulsador conectado a RA4 parpadeen, a una frecuencia de 0.5Hz, los 8 LEDs 
;conectados en cátodo común a los 8 terminales del puerto D de un microcontrolador PIC 16F887. Dicho 
; parpadeo se debe interrumpir durante unos instantes (3 segundos) si se aprieta el pulsador conectado al 
; terminal RB0. Inicialmente, los LEDs están apagados. El oscilador es de 4MHz. 
    
;-------------------LIBRERIAS---------------------------------------------------
   
    #INCLUDE    <P16F887.INC>
    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------
	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;-------------------DECLARACION DE VARIABLES------------------------------------
	
    COUNT EQU 0X70;
 ;-------------------INICIALIZACIÓN----------------------------------------------
    
    ORG 0X00
    GOTO CONFIG_
 
    ORG 0X04
    GOTO RUT_INT

;-------------------CONFIGURACION DE REGISTROS----------------------------------
 
   		 ORG 0X05
CONFIG_
	BANKSEL TRISB	  	  ; Seteo RB0 como entrada
	BSF TRISB,0
	BANKSEL TRISA	  	  ; Seteo RA4 como entrada
	BSF TRISA,4
	BANKSEL TRISD	   	 ; Seteo RD<7:0> como salida
	MOVLW   b'00000000'	    
	MOVWF   TRISD
	BANKSEL ANSEL	    	; Seteo PORTA como digital.
	CLRF    ANSEL
	BANKSEL ANSELH	   	 ; Seteo PORTB como digital.
	CLRF    ANSELH
	BANKSEL OPTION_REG	   
	MOVLW   b'10000111' 	 ; config ps para timer,flanco descendente y desactivo pull
	MOVWF   OPTION_REG
	BANKSEL PORTD	   	 ; Vuelvo al banco de PORTD para comenzar.
	CLRF PORTD 		; inician apagados
	GOTO INICIO

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	
INICIO
	BTFSC PORTA,4  ;espero a que aprete RA4 para arrancar parpadeo (no se puede hacer por interr)
	GOTO $-1	     ;y arrancar programa
	COMF PORTD	     ;prendo leds
	MOVLW .20	     ;para un segundo, veces a repetir ciclo
	MOVWF  COUNT  
	MOVLW .61
	MOVWF  TMR0		; para los 50ms
	MOVLW   b'10110000' ; Habilito interr gral, por RB0/int , timer y bajo banderas
	MOVWF   INTCON
	
	GOTO $ 			; no hay mas programa, todo sigue por interrupción
	
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------

RUT_INT					;no salvo contexto ya que no hay contexto 
	BTFSC INTCON,INTF
	GOTO INT_ON
	BTFSC INTCON,T0IF
	GOTO TIMER_
	RETFIE
INT_ON
	BCF INTCON,INTF 		;bajo bandera
	CLRF PORTD 			;apago leds
	MOVLW .61
	MOVWF  TMR0			; para a partir de ahora los 3seg
	MOVLW .60 			;para que hacer los 3 seg
	MOVWF COUNT
	RETFIE
TIMER_
	BCF INTCON, T0IF 		;bajo bandera
	DECFSZ COUNT,F
	RETFIE
	COMF PORTD                ;prendo/apago , pasó el tiempo determinado por count 
	MOVLW .20                 ;para que hacer de vuelta 1 seg
	MOVWF COUNT
	RETFIE
End



