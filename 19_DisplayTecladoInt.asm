  ; Autor: Augusto Gabriel Cabrera
; Año : 2023
	    
;-------------------ESPECIFICACIONES DE DISEÑO----------------------------------	    
;Su función es implementar un sistema de exploración de teclado matricial y mostrar en un 
;    display de 7 segmentos el valor correspondiente a la tecla presionada.
		
;-------------------LIBRERIAS---------------------------------------------------
    
    LIST P=16F887

 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON

 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

#include "p16f887.inc"


COL_EN      EQU 0x23   ; variable con dato sobre columna habilitada 
COL_EN_T    EQU 0x24   ; variable temporal para no perder dato anterior
COLUMN      EQU 0x25   ; Valor posicional de la columna
N_COL       EQU 4      ;  
COLUMNX     EQU 0x29   ;

ROW         EQU 0x26   ; Valor decimal de la fila
N_ROW       EQU 4      ; Cantidad máxima de filas del teclado
ROWX        EQU 0x30   ;

W_TEMP      EQU 0x27   ; variables temporales para salvar contexto - W
STATUS_TEMP EQU 0x28   ; variables temporales para salvar contexto - STATUS

#include <p16f887.inc> 
			    ; Clock = 4Mhz => Ciclo de instrucción de 1us
 
   ORG 0x00
   GOTO Inicio
   
   ORG 0x04
   GOTO INTSERV
   
   ORG 0x05
Inicio 
    CALL init			; Inicializa puertos; PIC16F887 Configuration Bit Settings
loop
				;CALL keyexploration; llama a la rutina de exploracion de displays 
    GOTO loop 
    
				 ;inicializacion de puertos 
init 
    BANKSEL TRISD		; (0)outputs (1)inputs
    CLRF  TRISD			;Establece en portC RD<7:0> como salidas
    MOVLW 0xF0			;Establece en portB RB<7:4> como entradas, RB<3:0> salidas
    MOVWF TRISB
    BCF OPTION_REG, 7		; habilito pull up resistors bit NOT_RPUB
    MOVLW 0xF0
    MOVWF WPUB		        ; habilito pull up INDIVIDUALES resistors de RB<7:4>
    MOVLW 0xF0
    MOVWF IOCB			; habilito interrupciones INDIVIDUALES por entradas RB<7:4>
    BANKSEL ANSELH		; (0)i/o digitales, (1)i/o analog
    MOVLW 0x00			;Establezco RB como puerto digital
    MOVWF ANSELH ;
    BANKSEL PORTD   ; 
    CLRF  PORTD			;Inicializo a 0 PORTD, nada prendido
    MOVLW 0x00			 ;Establece en port B RB<3:0> a 0
    MOVWF PORTB
    
    CLRF COLUMN			; Inicializo  de columna y fila
    CLRF ROW
    
    BSF INTCON, RBIE		; habilito interrupciones por nivel de RB
    BSF INTCON, GIE	        ; habilito interrupciones generales
    BCF INTCON, RBIF		; DESHABILITO BANDERA DE INTERRUP EN PORTB 
    
    return 

INTSERV
    MOVWF W_TEMP		;Copio W a un registro TEMP
    SWAPF STATUS,W		;Swap status para salvarlo en W
				;ya que esta intruccion no afecta las banderas de estado
    MOVWF STATUS_TEMP		;Salvamos status en el registro STATUS_TEMP
    
    BTFSS INTCON, RBIF		; HUBO interrupcion por RB?  
    GOTO fininte		;si es no recupero contexton y vuelvo a programa principal 
    CALL keyexploration		;voy a explorar teclado 
endint				 
    BCF INTCON, RBIF		;limpio bandera de interrupcion por RB

fininte
    SWAPF STATUS_TEMP,W		;Swap registro STATUS_TEMP register a W
    MOVWF STATUS		; Guardo el estado
    SWAPF W_TEMP,F		;Swap W_TEMP
    SWAPF W_TEMP,W		;Swap W_TEMP a W
    retfie
    
keyexploration		    ;supongamos que presiono <7:4>entradas <3:0> salidas en 0==> 1101.0000 2°col.
    SWAPF PORTB, W	    ; Guardo valor de columna habilitada ej 1101.0000->0000.1101
    ANDLW 0x0F		    ; enmascaro solo el 1°nibble
    MOVWF COL_EN	    ;guardo la bits de columna
    MOVWF COL_EN_T	    ;guardo los bits de col.aux
    
    MOVLW 0x0F		    ; Pregunto si hay alguna tecla pulsada 00001111 y le resto al valor de los bits de col.
    SUBWF COL_EN, W ;                               
    BTFSC STATUS, Z	    ;si la resta es (0)==> z=1;     
    GOTO end_key_exp	    ;significa que no hubo tecla pulsada 
    CLRF COLUMN		    ; significa que hubo tecla pulsada, inicializo contadores de exploración
    CLRF ROW		    ;valor posicional de fila y col empezara en 0 
col_dec			    ;como hubo tecla pulsada empiezo a explorar columna 
    RRF COL_EN_T, F	    ; roto a la derecha la variable (con bits) de col.aux (0000.1101>>c)
    BTFSS STATUS,C	    ; verificando que bit se puso a 0 
    GOTO row_dec	    ; encontramos la colum presionada y ahora buscamos la fila
    INCF COLUMN, F	    ; inc el valor posicional de col. si no se encuentra fue un falso disparo
    MOVLW N_COL		    ;n_col es el num max de columnas (4). VEO SI LLEGA  A LA columna 4
    SUBWF COLUMN, W	    ;resto con el valor posic. de columnas 
    BTFSS STATUS, Z	    ; resta es (0)=>z=1
    GOTO col_dec	    ; si no llegue al val.max. de col. vuelvo a repetir el programa 
    CLRF COLUMN		    ;llegue al num max de col. reseteo el valor posicional de las columnas
    GOTO end_key_exp	    ;me voy de la subrutina 
row_dec			    ;buscamos la fila presionada
    MOVF ROW,W		     ;row es el valor posicional de las filas, empiezo a explorar filas (roto(0) por filas)
    CALL en_row		    ; voy rotando un 0 por las salidas dependiendo el valor pos. de la fila
    MOVWF PORTB		    ; muevo el contenido de la entradas de port b para saber quien fue
    SWAPF PORTB, W	    ; quiero que las entradas queden en el 1°nibble 'xxxxiiii' comparando contra la entrada
    ANDLW 0x0F		    ; extraigo el nibble inferior '0000iiii'
    SUBWF COL_EN, W	    ; resto con el valor que leimos en las columnas al principio ej'00001101'
    BTFSC STATUS, Z	    ; si resta da(0)==>z=1
    GOTO fin_dec	    ; encontramos la fila que corresponde al valor leido al principio
    INCF ROW, F		    ; sino es igual incremento de fila 
    MOVLW N_ROW		    ; verifico si llegue al numero max de filas 
    SUBWF ROW, W	    ; resto 
    BTFSS STATUS, Z	    ;si resta da(0)=>z=1
    GOTO row_dec	    ;en caso de no llegar al num. max de filas vuelvo a repetir el programa 
    MOVLW 0x0F		    ; si alcanze el num.max. de filas 
    MOVWF ROW		    ; pongo a 0 el valor posicional de filas
    CLRF ROW
    GOTO end_key_exp	    ; salgo de la rutina por que hubo un falso disparo 
fin_dec			    ;encontramos la fila que buscabamos 

    MOVF ROW, w  
    MOVWF ROWX 
    MOVF COLUMN, w 
    MOVWF COLUMNX ; 
   
    BCF STATUS, C	    ; con los valores de columna y fila
    RLF ROW, F		    ;para mult x2 roto a la izquierda el valor    ; detectado calculo la tecla
    RLF ROW, W		    ; ROW*4 + COLUMN
    ADDWF COLUMN, W	    ;este resultado hago que busque en la tabla el num. que quiero mostrar
  
    CALL table7seg	    ; codificamos a 7 segmento y 
    MOVWF PORTD		    ; enviamos al puerto D
end_key_exp
    MOVLW 0x00		    ;Inicializamos puerto para nueva exploración
    MOVWF PORTB		    ;limpiamos puertoB 
			   
    
    MOVF ROWX, w 
    SUBLW 3  
    BTFSC STATUS, Z 
    GOTO Verificar_Columna 
    GOTO keyexploration 

Verificar_Columna
    MOVF COLUMNX, w  
    SUBLW 0 
    BTFSC STATUS, Z 
    GOTO fin
    GOTO keyexploration 

fin MOVLW 0x00 
    MOVWF PORTD
    GOTO endint

table7seg
    ADDWF PCL, F
    RETLW 0x3F; 0   
    RETLW 0x06; 1
    RETLW 0x5B; 2
    RETLW 0x4F; 3  
    RETLW 0x66; 4
    RETLW 0x6D; 5
    RETLW 0x7D; 6
    RETLW 0x07; 7
    RETLW 0x7F; 8
    RETLW 0x6F; 9
    RETLW 0x77; A
    RETLW 0x7C; B
    RETLW 0x39; C
    RETLW 0x5E; D
    RETLW 0x79; E
    RETLW 0x71; F 
    
en_row
    ADDWF PCL, F
    RETLW 0x0E		; COL0 ;b'0...1110'
    RETLW 0x0D		; COL1 ;b'0...1101'
    RETLW 0x0B		; COL2 ;b'0...1011'
    RETLW 0x07		; COL3 ;b'0...0111'
    
    
    END





