; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
; Programa que cuenta togglea 1 mili segundo
	
;-------------------LIBRERIAS---------------------------------------------------
; Programa que cuenta 1 mili segundo
	LIST P=16F887
	
; CONFIG1
; __config 0xFFF2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

#include <p16f887.inc> 
; Clock = 4Mhz => Ciclo de instrucción de 1us

T0_val equ .20
 
   ORG 0x0
Inicio
   goto start
   
   ORG 0x4
   goto reset_tmr0

   ORG 0x5
start
   call init
loop   
   goto loop

    
init
    BANKSEL TRISC	      ; La señal saldrá por RC0.
    BCF	    TRISC,0
    BANKSEL OPTION_REG
    MOVLW b'11010011';       PSA:TMR0,  preescaler 4, CLOCK interno
    MOVWF OPTION_REG
    BANKSEL TMR0
    MOVLW T0_val; carga del TMR0
    MOVWF TMR0
    BSF INTCON, T0IE
    BSF INTCON, GIE
    BANKSEL TRISC	      ; La señal saldrá por RC0.
    BCF	  TRISC,0
    BANKSEL PORTC	     ; Voy al banco común entre PORTC y TMR0.
    return 	   
	    
    
reset_tmr0
	    nop
TOGG_RC0    BTFSS   PORTC,0
	    GOTO    RC0_ON
	    GOTO    RC0_OFF
	    
  RC0_ON    BSF	    PORTC,0
	    GOTO    FINISH
  
 RC0_OFF    BCF	    PORTC,0
	    GOTO    FINISH
	    
FINISH    bcf INTCON, T0IF
	  MOVLW T0_val; carga del TMR0
	  MOVWF TMR0
	  retfie
	
	  END