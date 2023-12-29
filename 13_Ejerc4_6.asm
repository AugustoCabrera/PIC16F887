; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
;Considerando el mismo hardware del ejercicio 4.4, escribir un programa que ilumine los LEDs conectados a PORTD según las siguientes especificaciones:
;·     Inicialmente (al salir del reset), aparecen parpadeando los LEDs.
;·     Si se aprieta el pulsador conectado al pin RA4, se produce un desplazamiento de derecha a izquierda.
;·     Si se vuelve a apretar el pulsador RA4, cambia el sentido del desplazamiento.
;·     El desplazamiento debe comenzar al soltar el pulsador.
;·     En cualquier momento, al apretar el pulsador conectado al pin RB0, se vuelve al parpadeo inicial.
  

;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00
	    
	    V1	    EQU	    0x20    ; Variable para el loop interno.
	    V2	    EQU	    0x21    ; Variable para el loop medio.
	    V3	    EQU	    0x22    ; Variable para el loop externo.
	    AUX	    EQU	    0x23    ; Variable para togglear el desplazamiento.
	    FLAG    EQU	    0x24    ; Flag auxiliar.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    BANKSEL TRISA	    ; Seteo RA4 y RB0 como inputs.
	    MOVLW   b'00010000'	
	    MOVWF   TRISA
	    BANKSEL TRISB
	    MOVLW   b'00000001'
	    MOVWF   TRISB
	    BANKSEL TRISD	    ; Seteo PORTD como output digital.
	    CLRF    TRISD
	    BANKSEL ANSEL	    ; Seteo PORTA y PORTB como digitales.
	    CLRF    ANSEL
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA.
	    CLRF    AUX		    ; Limpio el valor de toggleo de dirección y
	    CLRF    PORTA	    ; también los registros a leer para evitar 
	    CLRF    PORTB	    ; trabajar con basura.
	    CLRF    PORTD
	    CLRW

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
				; Se comienza con el parpadeo de LEDs.
  TOGGLE    COMF    PORTD,1	; Complemento el valor de PORTD.
	    CALL    TIMER_2S	; Espero dos segundos.
	    BTFSS   PORTA,4	; Chequeo el estado de RA4.
	    GOTO    PRESSEDA	; Si se apretó, hago el antirrebote.
	    GOTO    TOGGLE	; Y vuelvo.
	    
PRESSEDA    BTFSS   FLAG,0	; Chequeo si fue la primera vez en apretar RA4.
	    CALL    FIRST	; Si sí, cargo PORTD por primera vez.
	    BTFSS   PORTA,4	; Cuando el estado de RA4 cambie, continúo.
	    GOTO    $-1
	    INCF    AUX		; Incremento la cantidad de veces que se
	    BTFSC   AUX,1	; presionó RA4 y en base a eso toggleo la
	    GOTO    LTOR	; dirección de desplazamiento de los LEDs.
	    GOTO    RTOL
	    
PRESSEDB    BTFSS   PORTB,0	; Cuando el estado de RB0 cambie, continúo.
	    GOTO    $-1
	    CLRF    AUX		; Limpio todos los registros utilizados y
	    CLRF    FLAG	; vuelvo al estado inicial de toggleo.
	    CLRF    PORTD
	    GOTO    TOGGLE
	    
    RTOL    CALL    TIMER_2S	; Espero dos segundos.
    	    BTFSS   PORTA,4	; Chequeo el estado de RA4.
	    GOTO    PRESSEDA	; Si se apretó, hago el antirrebote.
	    BTFSS   PORTB,0	; Chequeo el estado de RB0.
	    GOTO    PRESSEDB	; Si se apretó, hago el antirrebote.
	    RLF	    PORTD	; Roto PORTD hacia la izquierda.
	    BTFSC   STATUS,C	; Si el carry está en '1' (di toda la vuelta),
	    CALL    LOAD	; recargo PORTD y continúo.
	    GOTO    RTOL
	    
    LTOR    CLRF    AUX		; Reseteo AUX.
	    CALL    TIMER_2S	; Espero dos segundos.
	    BTFSS   PORTA,4	; Chequeo el estado de RA4.
	    GOTO    PRESSEDA	; Si se apretó, hago el antirrebote.
	    BTFSS   PORTB,0	; Chequeo el estado de RB0.
	    GOTO    PRESSEDB	; Si se apretó, hago el antirrebote.
	    RRF	    PORTD	; Roto PORTD hacia la derecha.
	    BTFSC   STATUS,C	; Si el carry está en '1' (di toda la vuelta),
	    CALL    LOAD2	; recargo PORTD y continúo.
	    GOTO    LTOR
	    
TIMER_2S    NOP			; --SUBRUTINA DE TIEMPO DE DOS SEGUNDOS--
	    MOVLW   .11		; Cargo V1, V2 y V3 con valores previamente
	    MOVWF   V3		; calculados para que el ciclo dure 2[s].
   LEXT2    MOVLW   .255
	    MOVWF   V2
   LINT2    MOVLW   .255
	    MOVWF   V1
	    DECFSZ  V1		; Decremento V1. Si aún no es cero...
	    GOTO    $-1		; sigo decrementando V1.
	    DECFSZ  V2		; Si V1 es cero, decremento V2.
	    GOTO    LINT2	; Si V2 aún no es cero, recargo V1 y repito.
	    DECFSZ  V3		; Si V2 es cero, decremento V3.
	    GOTO    LEXT2	; Si V3 aún no es cero, recargo V2 y repito.
	    RETURN		; Si V3 es cero, salgo de la subrutina.
	    
   FIRST    INCF    FLAG	; Si es la primera vez pulsando RA4, se setea
	    CALL    LOAD	; FLAG en 1 y se carga PORTD por primera vez.
	    RETURN
	    
    LOAD    BCF	    STATUS,C	; Limpio el bit de carry para evitar basura, y
	    MOVLW   .1		; cargo en PORTD el valor a mostrar para los
	    MOVWF   PORTD	; desplazamientos.
	    RETURN
	    
   LOAD2    BCF	    STATUS,C	; Limpio el bit de carry para evitar basura, y
	    MOVLW   b'10000000'	; cargo en PORTD el valor a mostrar para el
	    MOVWF   PORTD	; desplazamiento.
	    RETURN
	    
;-------------------COMENTARIOS-------------------------------------------------

;   Este ejercicio, al igual que el 4.5, está hecho de manera muy tosca por el
;   hecho de que en la unidad 4 no se abarcan las interrupciones. Para poder
;   apreciar correctamente el comportamiento del PIC en la simulación en
;   Proteus, hay que hacer lo mismo que en el ejercicio 4.5. Ver la sección
;   COMENTARIOS del ejercicio 4.5 para entender mejor.

