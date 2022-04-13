			AREA		main, READONLY, CODE
            THUMB

			EXPORT		DELAY100
				
DELAY100	PROC
			
			LDR R0,=533333
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