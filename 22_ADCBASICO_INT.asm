; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
    
;Este es un programa ejemplo de uso del conversor A/D en un PIC16F877, donde se usa un solo canal (CH0)
;y se usan interrupciones.
; El conversor A/D se configura como sigue:
;       Vref = +5V interna.
;       A/D Osc. =  RC interna
;       Canal A/D = CH0
; El programa convierte el valor del potenciómetro conectado a RA0 en 10 bits, de los que los
; 8 bits más significativos se muestran en los leds conectados al PORTB.
    
;-------------------LIBRERIAS---------------------------------------------------
    
 #INCLUDE    <P16F887.INC>
    LIST    P = 16F887
;-------------------CONFIGURACION PIC-------------------------------------------
    
        __CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
;------------------- VARIABLES -------------------------------------------	
	
TEMP    EQU 20h             ; Variable de almacenamiento temporal
TMP1    EQU 21h    

    ORG     0x00            ; Vector de Reset
	GOTO start

    ORG 0x04            ; Vector de interrupción
	GOTO service_int

    ORG 0x05
start 
	MOVLW 0FFh ; PORTB =  11111111b
	MOVF  PORTB
	BSF   STATUS,RP0 ; Banco 1
	MOVWF TRISA ; PORTA son entradas
	CLRF  TRISB ; PORTB son salida
	BCF   STATUS,RP0 ; Banco 0
	CLRF  TMP1;
	CALL  InitializeAD
	CALL  SetupDelay ; Delay para Tad
	BSF   ADCON0,GO ; Inicia conversión A/D
	GOTO $


;  Rutina de interrupción A/D:
; muestra valor en los leds del PORTB
service_int 
	BTFSS PIR1,ADIF ; ¿Interrupcion del modulo A/D?
	RETFIE ; Si no retornamos
	MOVF ADRESH,W ; Tomo los 8 bits altos de la conversión
	;incf TMP1;
	;MOVF TMP1, W;
	MOVWF PORTB ; los muestro en los LEDS del PORTB
	BCF PIR1,ADIF ; Reseteo el flag
	CALL SetupDelay ; Delay de adquisición
	CALL SetupDelay ; mayor de 20 us
	BSF ADCON0,GO ; lanzo una nueva conversión
	RETFIE ; retorno, habilito GIE


; InitializeAD, inicializa el modulo A/D.
; Selecciona CH0 a CH3 como entradas analógicas, reloj RC y lee el CH0.
InitializeAD 
	BSF STATUS,RP0 ; Banco 1
	MOVLW B'00000100' ; RA0,RA1,RA3 entradas analogicas
	MOVWF ADCON1 ; Justificado a la izquierda, 8 bits mas significativos en ADRESH
	BSF PIE1,ADIE ; Habilitamos interrupciones A/D 
	BCF STATUS,RP0 ; Banco 0
	MOVLW b'11000001' ; Oscilador RC, Entrada analógica CH0
	MOVWF ADCON0 ; Modulo A/D en funcionamiento
	BCF PIR1,ADIF ; Limpio flag interrupción
	BSF INTCON,PEIE ; Habilito interrupciones de perifericos
	BSF INTCON,GIE ; Habilito interrupciones globales
	RETURN

;  Esta rutina es un retardo software de más de 10us si
;  se usa un oscilador de 4MHz que se usa para asegurar
;  un tiempo de adquisición de más de 20 us mediante una doble llamada
;  antes de  lanzar una nueva conversión.
	
SetupDelay 
	MOVLW 5 ; Carga Temp con 3
	MOVWF TEMP
SD 
	DECFSZ TEMP, F ; Bucle de retardo
	GOTO SD
	RETURN

    END