; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
; Genere la señal que se muestra utilizando TMR0. Considere que el clock del microprocesador es de 8 MHz.
	
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;-------------------DECLARACION DE VARIABLES------------------------------------
	
	    T0_OF1  EQU	    0x20	; Overflows para contar 1[s] y 2[s].
	    T0_OF2  EQU	    0x21
	      FLAG  EQU	    0x22	; Flag para togglear RC0.
	    FLAGAUX EQU     0x23
;-------------------INICIO DEL PROGRAMA-----------------------------------------

	    ORG	    0x00
	    GOTO    CONFIG_
	    
	    ORG	    0x04
	    GOTO    RUT_IN
	    
;-------------------CONFIGURACION DE REGISTROS----------------------------------

	    ORG	    0x05
	    
 CONFIG_    MOVLW   .2
	    MOVWF   FLAGAUX
	    MOVLW   .40	              ; Primero cuento 20 veces 50[ms] para
	    MOVWF   T0_OF1	      ; llegar a 1[s], y cuento dos veces 1[s]
	    MOVLW   .2	              ; para completar la forma de onda.
	    MOVWF   T0_OF2
	    BANKSEL INTCON
	    MOVLW   b'10100000'       ; Habilito interrupciones por TMR0 con
	    MOVWF   INTCON
	    BANKSEL OPTION_REG
	    MOVLW   b'00000111'       ;Pongo en 0 a TOCS PSA y en 1 a PS2 PS1 PS0
	    MOVWF   OPTION_REG
	    BANKSEL TRISC	      ; La señal saldrá por RC0.
	    BCF	    TRISC,0
	    BANKSEL PORTC	     ; Voy al banco común entre PORTC y TMR0.
	    CALL    LOAD_TMR0
	    GOTO    INIT

	    
LOAD_TMR0   MOVLW   .61		    ; Cargo con '60' a TMR0 para que cuente
	    MOVWF   TMR0	    ; 50[ms].
	    RETURN
	    
    INIT    GOTO    $			; Me quedo esperando una interrupción.
	    
;-------------------RUTINA DE INTERRUPCIÓN--------------------------------------
	    
  RUT_IN    BTFSS   INTCON,T0IF		; Sólo atiendo interrupciones por TMR0.
	    RETFIE
	    DECFSZ  T0_OF1		; Cada 50[ms] toggleo RC0 durante 1[s].
	    GOTO    CHECK_TOG
	    CALL    RESET_OF1		; Luego de 1[s], pongo RC0 en 0 durante
	    BSF	    FLAG,0		; 1[s] sin togglear su estado, poniendo
	    DECFSZ  T0_OF2		; en '1' la flag necesaria.
	    GOTO    FINISH
	    GOTO    RESET_ALL		; Luego de 2[s] comienzo de nuevo.
	    
CHECK_TOG   BTFSS   FLAG,0		; Si la flag está en 0, toggleo. Sino,
	    GOTO    DOBLE		; dejo RC0 como está.
	    GOTO    FINISH
	    
DOBLE	    DECFSZ  FLAGAUX
	    GOTO    FINISH
	    GOTO    TOGG_RC0 
	    
TOGG_RC0    BTFSS   PORTC,0
	    GOTO    RC0_ON
	    GOTO    RC0_OFF
	    
  RC0_ON    BSF	    PORTC,0
	    MOVLW .2
	    MOVWF FLAGAUX
	    GOTO    FINISH
  
 RC0_OFF    BCF	    PORTC,0
 	    MOVLW .2
	    MOVWF FLAGAUX
	    GOTO    FINISH
	    
RESET_OF1   MOVLW   .40		; Reseteo el overflow para 1[s].
	    MOVWF   T0_OF1
	    RETURN
	    
RESET_OF2   MOVLW   .2		; Reseteo el overflow para 2[s].
	    MOVWF   T0_OF2
	    RETURN
	    
RESET_ALL   BCF	    FLAG,0		; Bajo la flag de toggleo, reseteo todos
	    CALL    RESET_OF1		; los overflows y toggleo RC0.
	    CALL    RESET_OF2
	    CALL    TOGG_RC0
	    GOTO    FINISH
	    
  FINISH    BCF	    INTCON,T0IF		; Limpio la flag de TMR0, reseteo TMR0 y
	    CALL    LOAD_TMR0		; vuelvo.
	    RETFIE
	    
	    END


