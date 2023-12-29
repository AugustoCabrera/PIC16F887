; Autor: Augusto Gabriel Cabrera
; Año : 2023

; Descripcion:	
;Escribir un programa para almacenar el valor 33D en 15 posiciones contiguas de la memoria de datos, empezando en la dirección 0x30
    
    ;-------------------LIBRERIAS---------------------------------------------------
    
    LIST P=16F887
    #INCLUDE <P16F887.INC>
    
;-------------------DECLARACION DE VARIABLES------------------------------------    
    
    VALOR      EQU     .33
    PUNTERO    EQU     0X30
    CNT	       EQU     0X60
 
               ORG     0X0
	       GOTO    REGISTROS
	       ORG     0X5   

;-------------------CONFIGURACION DE REGISTROS----------------------------------
	       
    REGISTROS           
	       CLRW		    ; Limpio el registro de trabajo		
	       MOVLW   .15              
	       MOVWF   CNT       ; CARGO EL CONTADOR CON VALOR 15D
	     

;-------------------INICIO DEL PROGRAMA-----------------------------------------
	       
	       MOVLW   PUNTERO   ; ES LO MISMO QUE MOVLW   0x30, Cargo en W la dirección inicial.   
	       MOVWF   FSR       ;CARGO EL FSR CON LA PRIMER DIRECCION A CARGAR EL DATO
	     
	       MOVLW   VALOR
    CONTINUO  MOVWF   INDF   ;MUEVO EL VALOR A CARGAR AL REGISTRO INDF
	   
               INCF    FSR,F
	       DECFSZ  CNT,F     ; APUNTO AL SIGUIENTE REGISTRO Y DECREMENTO EL CONTADOR
	     GOTO  CONTINUO  ; SI CONTADOR ES > 0 SIGO CARGANDO VALORES EN LOS REGISTROS CONSECUTIVOS 
	      GOTO     $
	       END


