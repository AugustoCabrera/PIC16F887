; Autor: Augusto Gabriel Cabrera
; A�o : 2023
	    
;-------------------ESPECIFICACIONES DE DISE�O----------------------------------	    
  ; Para cambiar la asociacion del PRESCALER del WDT a TMR0 + iNTERRU
;-------------------LIBRERIAS---------------------------------------------------


 #INCLUDE    <P16F887.INC>
    LIST    P = 16F887
;-------------------CONFIGURACION PIC-------------------------------------------
        __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
  
;-------------------DECLARACION DE VARIABLES------------------------------------

w_temp      EQU 0x70       ; Definici�n de variables temporales
status_temp EQU 0x71
 
;-------------------CONFIGURACION DE REGISTROS----------------------------------

    ORG 0x00              ; Direcci�n de inicio
    GOTO INICIO                ; Salto a la etiqueta INICIO

    ORG 0x04                   ; Vector de interrupci�n
    GOTO INTERRUPCION          ; Salto a la etiqueta INTERRUPCI�N

    ORG 0x05

      
INICIO	 BSF STATUS, RP0          ; Cambia a banco de registros 1
	 CLRWDT                   ; Limpia el Watchdog Timer, tambi�n limpia el registro del Prescaler!!!
	 MOVLW B'11010000'        ; Configura el registro OPTION_REG
	 ANDWF OPTION_REG,W		; IORLW me permite agregar 1 en las posiciones que yo desee sin alterar las otras
	 IORLW B'00000001'	     ; Asigna el Prescaler al temporizador TMRO y selecciona una 
				     ; divisi�n de frecuencia de 1:4
	 MOVWF OPTION_REG           ; Aplica la configuraci�n

     ; Se carga el valor deseado en el TMRO 

	 BCF STATUS, RP0            ; Cambia al banco de registros 0
	                          ; No-operation (sin operaci�n)
	    MOVLW B'11110000'    ; Carga el valor deseado en el temporizador (TMRO) 240 en TMR0 CARGO
            MOVWF TMR0           ; Asigna el valor al TMRO
 
                            ; Calcula y carga el valor en el temporizador 
    BCF INTCON, T0IF           ; Limpia la bandera de interrupci�n por desbordamiento del  temporizador
    BSF INTCON, T0IE           ; Habilita la interrupci�n por desbordamiento del temporizador
    BSF INTCON, GIE            ; Habilita las interrupciones globales ACA COMIENZA A CONTAR 4 CICLOS PARA CONTER

L1	    ;EJEMPLO DE OTRO CODIGO QUE PUEDA AGREGAR ALGO XXXXXX
    BSF PORTB, 5               ; Ejemplo de operaci�n, setea el bit 5 del puerto B
    NOP                         ; No-operation (sin operaci�n)
    NOP                         ; No-operation (sin operaci�n)
    NOP                         ; ACA RECIEN VEMOS EL INCREMENTO DEL TMR0
    NOP                         ; No-operation (sin operaci�n)
    CLRWDT
    NOP
    GOTO L1

INTERRUPCION		; SERVICIO A LA INTERRUPCION
                        ; Resguardo del contexto
    MOVWF w_temp        ; Guarda el valor del registro W
    SWAPF STATUS, W     ; Guarda el valor del registro STATUS con SWAPF para no alterar el bit Z
    MOVWF status_temp   ; Guarda el valor del registro STATUS en status_temp

                        ; Identificaci�n y asignaci�n de la prioridad de la interrupci�n
    BTFSC INTCON, T0IF  ; Verifica si la bandera de interrupci�n por desbordamiento del 
                        ;temporizador est� activa
    GOTO R_TMRO         ; Salta a la rutina de servicio si es as�
    GOTO FININT         ; Salta al final de la interrupci�n si no hay interrupci�n pendiente

R_TMRO
                         ; Rutina de servicio a la interrupci�n por temporizador
    MOVLW B'11110000'    ; Carga el valor deseado en el temporizador (TMRO) 240 en TMR0 CARGO
    MOVWF TMR0           ; Asigna el valor al TMRO
    ; Dentro de 2 ciclos comienza a cargar el TMR0
    
    BCF INTCON, T0IF     ; Limpia la bandera de interrupci�n por desbordamiento del temporizador

    NOP                  ; No-operation (sin operaci�n)
    NOP                  ; No-operation (sin operaci�n)
    NOP                  ; No-operation (sin operaci�n)
    NOP                  ; RECIEN ACA SE VE LA CUENTA DEL TMR0
    NOP                  ; No-operation (sin operaci�n)
    
 ;INTERRUMPE CADA 66 microSEG, NO DA EXACTO Ya que son 4 ciclos despues 

NOF
                          ; Recuperaci�n del contexto
    SWAPF status_temp, W  ; Recupera el valor original del registro STATUS
    MOVWF STATUS          ; Restaura el valor del registro STATUS a su contenido original
    SWAPF w_temp, F       ; Recupera el valor original de W
    SWAPF w_temp, W       ; Restaura el valor de W a su contenido original

    RETFIE               ; Retorno desde la rutina de interrupci�n

FININT
    END                  ; Fin del programa

