
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
  ; TX la cadena HOLA
;-------------------LIBRERIAS---------------------------------------------------
    
; Configuración del microcontrolador PIC16F887
LIST P=16F887
include <p16f887.inc>

; Configuración del CONFIG1
; __config 0x3FE6
__CONFIG _CONFIG1, _FOSC_EXTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON

; Configuración del CONFIG2
; __config 0xFFFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

; Punto de entrada principal
org 0x00
    goto start

; Rutina de servicio de interrupción
org 0x04
    goto intserv

; Rutina de inicio
org 0x05
start
    bsf STATUS, RP0 ; Cambia al banco 1
    movlw .25
    movwf SPBRG ; Baud rate = 9600 bps
    movlw 0x24
    movwf TXSTA ; Configura TXSTA como 8-bit transmission, TX habilitado, modo asíncrono, high speed baud rate
    clrf TRISD ; Configura el puerto D como salida
    movlw 0x20
    movwf PIE1 ; Habilita interrupción por recepción (RC)
    bcf STATUS, RP0 ; Vuelve al banco 0
    movlw 0x90
    movwf RCSTA ; Habilita recepción y pines de puerto serie
    movlw 0xC0
    movwf INTCON ; Habilita interrupciones globales y por periféricos

main
    goto main ; Bucle infinito

; Rutina de servicio de interrupción
intserv
    btfss PIR1, RCIF ; Verifica si la interrupción es por recepción (RC)
    goto endint
    bcf PIR1, RCIF ; Limpia la bandera de interrupción de recepción (RC)
    movf RCREG, W ; Lee el dato recibido
    movwf PORTD ; Envía el dato al puerto D
endint
    retfie ; Retorna de la interrupción

end



