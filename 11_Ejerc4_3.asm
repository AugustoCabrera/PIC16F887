

; Autor: Augusto Gabriel Cabrera
; A�o : 2023
	    
;-------------------ESPECIFICACIONES DE DISE�O----------------------------------	    
; Escribir un programa que cuente el n�mero de veces que se puls� la tecla conectada al terminal RA4 y 
; que saque ese valor en binario natural por el Puerto B. S�lo se utilizar�n los bits RB0 a RB3 que son
; los que tienen conectados diodos LED para su observaci�n. Como consecuencia, el contador es de 4 bits: de 0 a 15.
;-------------------LIBRERIAS---------------------------------------------------

	#INCLUDE    <P16F887.INC>

	    LIST    P = 16F887

;-------------------CONFIGURACION PIC-------------------------------------------

	__CONFIG    _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
	__CONFIG    _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------DECLARACION DE VARIABLES------------------------------------
	    
	    ORG	    0x00

	    OUT	    EQU	    0x20    ; Registro que almacenar� la cantidad de
				    ; veces que se toc� la tecla.
            LIM	    EQU	    0x21    ; Registro que almacenar� el valor m�ximo
				    ; del contador.

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	    
	    CLRW		    ; Limpio OUT y W para eliminar basura.
	    CLRF    OUT
	    MOVLW   .16		    ; Cargo el valor m�ximo del contador en LIM.
	    MOVWF   LIM
	    BANKSEL TRISA	    ; Seteo RA4 como input y limpio TRISB para
	    MOVLW   b'000010000'    ; que todo PORTB quede como output.
	    MOVWF   TRISA
	    BANKSEL TRISB
	    CLRF    TRISB
	    BANKSEL ANSEL	    ; Limpio ANSEL y ANSELH para que todos los
	    CLRF    ANSEL	    ; pines de PORTA y PORTB queden digitales.
	    BANKSEL ANSELH
	    CLRF    ANSELH
	    BANKSEL PORTA	    ; Vuelvo al banco de PORTA para comenzar.

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	    
    LOOP    MOVFW   OUT		    ; Cargo OUT en W y lo muestro por PORTB.
	    MOVWF   PORTB
	    BTFSC   PORTA,4	    ; Chequeo el estado de RA4.
	    GOTO    $-1		    ; Si est� en '1', sigo chequeando.
	    CALL    PULSADO	    ; Si est� en '0', llamo a la subrutina.
	    GOTO    LOOP	    ; Sino, vuelvo a LOOP.
	    
 PULSADO    BTFSS   PORTA,4	    ; Hago polling en RA4 hasta que el pin
	    GOTO    $-1		    ; vuelva a estar en '1' y ah� incremento
	    CALL    SUMA		    ; el valor a mostrar en PORTB.
	    RETURN
	    
    SUMA    INCF    OUT,1	    ; Incremento OUT y lo cargo en W.
	    MOVFW   OUT
	    SUBWF   LIM,0	    ; Guardo en W la resta LIM - W para ver si
	    BTFSC   STATUS,Z	    ; llegu� a 15.
	    CLRF    OUT		    ; Si di� 0 (llegu� a 15), reseteo OUT.
	    RETURN
	    
	    END



