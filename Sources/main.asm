;*******************************************************************
;* This stationery serves as the framework for a user application. *
;* For a more comprehensive program that demonstrates the more     *
;* advanced functionality of this processor, please see the        *
;* demonstration applications, located in the examples             *
;* subdirectory of the "Freescale CodeWarrior for HC08" program    *
;* directory.                                                      *
;*******************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            
;
; export symbols
;
            XDEF _Startup
            ABSENTRY _Startup

;
; variable/data section
;
            ORG    $60         		; Insert your data definition here
M60: DS.B   1						; Rango de entrada en hexadecimal
M61: DS.B   1						; Rango de salida en decimal

;
; code section
;
            ORG    ROMStart
            

_Startup:
			LDA	   	#$12			; Inmediato A=$12 hexa, quitar el WATCHDOG
			STA		SOPT1			; Directo, guardar A en SOPT1

			MOV 	#$63, M60		; Mover un dato inmediato a M60
									; no permitira avanzar porque es mayor a 63H
Inicio:
			LDA 	M60				; Cargar en el acumulador M60
			
			SUB 	#$63			; Restar al acumulador 63H
			
			BHI		Inicio			; si el resultado es positivo, regresa a la etiqueta Inicio
			BLE		Subrutina		; si el resultado es cero o negativo, realiza la subrutina
Subrutina:
			BSR		Convertir		; Ir a la subrutina
			BRA		Inicio			; Volver a empezar con otro numero
Convertir:
			LDX		#$0A			; Divisor
			LDA		M60				; Dividendo
			
			DIV						; Division A / X
									; resultado en A
									; resto en H
			
			NSA						; Intercambiar nibbles del acumulador
									; El acumulador ahora esta en decenas
			
			PSHH					; Guardar H en la pila
									; El contador de la pila esta en FDH
									; ahi se guarda el valor de H
									; y se incrementa el contador de la pila, ahora es FCH
			
			STA		M61				; Guardar temporalmente el acumulador en M61
			
			PULA					; Sacar el valor correspondiente de la pila y ponerlo en el acumulador
									; El contador de la pila esta en FCH
									; se decrementa el contador de la pila, ahora es FDH
									; ahi esta el valor que se guardara en el acumulador
			
			ADD		M61				; Sumar decenas con unidades
			
			STA		M61				; Resultado final en decimal
			RTS						; Regreso de la subrutina
mainLoop:
            ; Insert your code here
            BRA    mainLoop
			
;**************************************************************
;* spurious - Spurious Interrupt Service Routine.             *
;*             (unwanted interrupt)                           *
;**************************************************************

spurious:				; placed here so that security value
			NOP			; does not change all the time.
			RTI

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************

            ORG	$FFFA

			DC.W  spurious			;
			DC.W  spurious			; SWI
			DC.W  _Startup			; Reset
