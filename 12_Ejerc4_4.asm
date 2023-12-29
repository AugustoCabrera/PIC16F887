; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
; Escribir un programa que, dependiendo del estado de dos interruptores conectados a RA4
; y RB0, presente en el puerto D diferentes funciones lógicas cuya tabla de verdad es:
    
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    ORG	    0x00
	    
	    BANKSEL TRISA	    ; Seteo RA4 y RB0 como inputs. Además, seteo
	    MOVLW   b'00010000'	    ; PORTD como output.
	    MOVWF   TRISA
	    BANKSEL TRISB
	    MOVLW   b'00000001'
	    BANKSEL TRISD
	    CLRF    TRISD
	    BANKSEL ANSEL	    ; Limpio ANSEL y ANSELH para que queden como
	    CLRF    ANSEL	    ; puertos digitales.
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA.
	    CLRF    PORTA	    ; Limpio los registros a utilizar para
	    CLRF    PORTB	    ; evitar basura.
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    LOOP    BTFSC   PORTA,4	    ; Chequeo el estado de RA4 y voy a distintas
	    GOTO    RA4_ON	    ; subrutinas según corresponda.
	    GOTO    RA4_OFF
    
  RA4_ON    BTFSC   PORTB,0	    ; Chequeo el estado de RB0 y voy a distintas
	    GOTO    COMB_11	    ; subrutinas según corresponda.
	    GOTO    COMB_10
	    
 RA4_OFF    BTFSC   PORTB,0	    
	    GOTO    COMB_01
	    GOTO    COMB_00
	    
 COMB_00    MOVLW   b'10101010'    ; Muestro por PORTD la salida especificada
	    MOVWF   PORTD	    ; para cada combinación posible.
	    GOTO    LOOP
	    
 COMB_01    MOVLW   b'01010101'
	    MOVWF   PORTD
	    GOTO    LOOP
	    
 COMB_10    MOVLW   b'00001111'
	    MOVWF   PORTD
	    GOTO    LOOP
	    
 COMB_11    MOVLW   b'11110000'
	    MOVWF   PORTD
	    GOTO    LOOP
	    
	    END
