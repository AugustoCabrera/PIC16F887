
; Autor: Augusto Gabriel Cabrera
; A�o : 2023
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    OUT	    EQU	    0x20    ; Variable que almacenar� el output.
	    
;-------------------ESPECIFICACIONES DE DISE�O----------------------------------
	    
;	Para este ejercicio se considera que el estado del pulsador de RA4
;	ser� mostrado por el led RB3, y el estado del pulsador de RB0 ser�
;	mostrado por RB2.
;
;	Si un pulsador est� pulsado, su estado ser� '0' y el output ser�
;	su respectivo LED encendido. De lo contrario, el estado ser� '1'
;	y el output ser� su respectivo LED apagado.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    BANKSEL TRISA	    ; Voy al banco de TRISA y seteo RA4 en 1
	    MOVLW   b'00010000'    ; para que quede como input.
	    MOVWF   TRISA
            BANKSEL TRISB	    ; Voy al banco de TRISB y seteo RB0 en 1
	    MOVLW   b'00000001'    ; y RB2 y RB3 en 0 para que queden seteados
	    MOVWF   TRISB	    ; como input y outputs.
	    BANKSEL ANSEL	    ; Voy al banco de ANSEL y lo limpio para
	    CLRF    ANSEL	    ; que todos los pines queden como digitales.
	    BANKSEL ANSELH	    ; Hago lo mismo con ANSELH.
	    CLRF    ANSELH
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA para comenzar.

;-------------------INICIO DEL PROGRAMA-----------------------------------------

    LOOP    BTFSC   PORTA,4	    ; Chequeo el estado de RA4.
	    BCF	    PORTB,3	    ; Si est� en '1', APAGO RB3.
	    BTFSC   PORTB,0	    ; Chequeo el estado de RB0.
	    BCF	    PORTB,2	    ; Si est� en '1', APAGO RB2.
	    
	    BTFSS   PORTA,4	    ; Chequeo nuevamente el estado de RA4.
	    BSF	    PORTB,3	    ; Si ahora est� en 0, PRENDO RB3.
	    BTFSS   PORTB,0	    ; Chequeo nuevamente el estado de RB0.
	    BSF	    PORTB,2	    ; Si ahora est� en 0, PRENDO RB2.
	    GOTO    LOOP	    ; Repito indefinidamente.
	    
	    END



