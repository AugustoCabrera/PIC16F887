; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
; Realizar un programa en Lenguaje Ensamblador que cuente de 0 a 9
; indefinidamente. Cada número permanecerá encendido 1 seg (retardo por
; software). El conteo iniciará en 0 al apretarse el pulsador y se detendrá al volver
; a pulsarlo en el valor que esté la cuenta. Se muestra el esquema del hardware
; sobre el que correrá el programa. El oscilador es de 4MHz. 
    
;-------------------LIBRERIAS---------------------------------------------------

LIST P=16F887
    #INCLUDE<P16F887.INC>
    
    ; CONFIG1
; __config 0x3FE4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

    
    AUX   EQU  0X20
   ESTADO EQU 0X27
    P_REG EQU  0X21 
    D_REG EQU  0X22
    S_REG EQU  0X23
    P2_REG EQU  0X24 
    D2_REG EQU  0X25
    S2_REG EQU  0X26
 
         ORG 0X0
	 GOTO MAIN
	 
	 ORG 0X5
MAIN     CLRF    AUX
	 BANKSEL ANSEL
         CLRF    ANSEL
	 CLRF    ANSELH
	 BANKSEL TRISD
	 MOVLW   0X0
	 MOVWF   TRISD
	 BCF     OPTION_REG,7
	 BANKSEL PORTD
	 CLRF    PORTD
	 
	 BTFSC PORTB,RB0
	 GOTO  $-1
	 
LOOP	 MOVF  PORTB,W
	 MOVWF ESTADO
	 CALL DEMORA2
	 
	 MOVF  AUX,W
	 CALL  TABLA
	 
	 
	 BTFSS ESTADO,0
	 GOTO  LOOP
	 BTFSS PORTB,RB0
	 GOTO  $
	 
	 MOVWF PORTD
	 CALL  DEMORA1
	 INCF  AUX,F
	 MOVLW .10
	 SUBWF AUX,W
	 BTFSC STATUS,Z
	 CLRF  AUX
	 GOTO LOOP
	 
	 
	 
TABLA   ADDWF PCL,F
	RETLW  0X3F
	RETLW  0X06
	RETLW  0X5B
	RETLW  0X4F
	RETLW  0X66
	RETLW  0X6D
	RETLW  0X7D
	RETLW  0X07
	RETLW  0X7F
	RETLW  0X67
	 
DEMORA1 ;1seg
        MOVLW .5
	MOVWF P_REG
L3	MOVLW .255
	MOVWF S_REG
L2	MOVLW .255
        MOVWF D_REG
L1	DECFSZ  D_REG,F
	GOTO L1
	DECFSZ  S_REG,F
	GOTO L2
	DECFSZ  P_REG,F
	GOTO L3
	RETURN
	
DEMORA2  ;76ms
        MOVLW .1
	MOVWF P2_REG
L33	MOVLW .100
	MOVWF S2_REG
L22	MOVLW .255
        MOVWF D2_REG
L11	DECFSZ  D2_REG,F
	GOTO L11
	DECFSZ  S2_REG,F
	GOTO L22
	DECFSZ  P2_REG,F
	GOTO L33
	RETURN

	

	
	END
	    
;-------------------COMENTARIOS-------------------------------------------------

;   Una vez más, este ejercicio tiene complicaciones por no trabajar con
;   interrupciones. Si bien la pulsación que comienza el conteo funciona
;   correctamente, la pulsación que lo detiene tiene la misma particularidad
;   que los ejercicios 4.6 y 4.5: hay que mantener presionado el botón hasta que
;   el PIC registre el cambio de estado por polling y luego se lo puede soltar
;   para continuar con la ejecución del programa.
	    
	    END




