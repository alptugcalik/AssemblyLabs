			AREA		main, READONLY, CODE
            THUMB

			EXPORT		DELAY1
				
DELAY1	PROC
			
			LDR R0,=5333 ; 1msec delay
			;since the internal clock speed is 16mhz we need to spend approximately 1.600.000 clock cycles to
			;spend 0.1 sec (100msec) 
			; to spend 1.600.000 clock cycles, 533.333 loops is enough
			
			;3 cycles are spend per loop
loop		SUBS R0,#1 ; COUNT DOWN
			BNE loop   ; loop if the count is not equal to zero
			
			BX LR
			ENDP
			ALIGN
			END