
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
  ; TX la cadena HOLA
;-------------------LIBRERIAS---------------------------------------------------

 LIST P=16F887
    include <p16f887.inc>

;-------------------CONFIGURACION PIC-------------------------------------------
    __CONFIG _CONFIG1, _FOSC_EXTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON

    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
;-------------------DECLARACION DE VARIABLES------------------------------------
    
    cblock 0x20
    COUNT1
    endc
    
STR_SIZE EQU .11
 
 ;-------------------INICIO DEL PROGRAMA------------------------------------
 
    ORG 0x00
    goto init
init
    bsf STATUS, RP0 ;bank 1

    movlw D'25'			 ;baud rate = 9600bp ---CONFIGURA SPBRG para el valor deseado de Baud rate
    movwf SPBRG			;a 4MHZ

    movlw B'00100100'		;---CONFIGURA TXSTA
    movwf TXSTA

    bcf STATUS, RP0 ;bank 0	;Configuro TXSTA como 8 bit transmission, tx habilitado, modo async, high speed baud rate
    movlw B'10000000'
    movwf RCSTA			;habilita los pines para recepción por puerto serie
    movlw STR_SIZE
    movwf COUNT1		;cargo contador de cantidad de caracteres de cadena
main
    movf COUNT1,W		;recorro la cadena de texto en la tabla
    sublw STR_SIZE
    call string
    movwf TXREG			;pone un caracter de la cadena en TXREG
    bsf STATUS, RP0		;bank 1
wthere
    btfss TXSTA, TRMT		;checkea si TRMT esta vacio por polling
    goto wthere 
    bcf STATUS, RP0		;bank 0, si TRMT esta vacio luego el caracter a sido transmitido 
    decfsz COUNT1, F		;chequeo si fue transmitida toda la cadena
    goto main
    movlw STR_SIZE
    movwf COUNT1		;vuelvo a transmitir la cadena
    goto main			;transmito continuamente la cadena de texto

string
    addwf PCL, F
    retlw 'H'
    retlw 'O'
    retlw 'L'
    retlw 'A'
    retlw ' '
    retlw 'M'
    retlw 'U'
    retlw 'N'
    retlw 'D'
    retlw 'O'
    retlw .13

    end    