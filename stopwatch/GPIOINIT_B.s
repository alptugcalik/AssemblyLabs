SYSCTL_RCGCGPIO		EQU		0x400FE608 ;SYSTEM GPIO CLOCK
GPIO_PORTB_DATA 	EQU 	0x400053FC ; data address to all pins SPECIFIED WITH REQUIRED MASK 
GPIO_PORTB_DIR 		EQU 	0x40005400
GPIO_PORTB_AFSEL 	EQU 	0x40005420
GPIO_PORTB_AMSEL 	EQU 	0x40005428
GPIO_PORTB_DEN 		EQU 	0x4000551C
GPIO_PORTB_PUR 		EQU 	0x40005510 
IOB 				EQU 	0xF0       ;INPUT CONFIG OF PORT B
PUB 				EQU 	0x00 	; or #00001111


			AREA		main, READONLY, CODE
            THUMB

			EXPORT		GPIOINIT_B


GPIOINIT_B	PROC

			;ENABLE CLOCK FIRST
			LDR R1,=SYSCTL_RCGCGPIO
			LDR R0,[R1]
			ORR R0,#0x02; turn on clock for b port
			STR R0 ,[R1]
			NOP
			NOP
			NOP
			;CLOCK IS STABILIZED
			
			LDR R1, =GPIO_PORTB_DIR ; direction register address
			LDR R0,[R1] ;direction register data
			BIC R0,#0xFF ;CONFIG INPUT AND OUTPUTS
			ORR R0,#IOB
			STR R0 ,[R1]
			
			LDR R1 , =GPIO_PORTB_AFSEL ;no alternative function
			LDR R0 , [R1]	
			BIC R0 , #0xFF   ;CLEAR AFSEL OF PORT B
			STR R0 , [R1]
			
			LDR R1 , =GPIO_PORTB_DEN  ;all pins are dgital
			LDR R0 , [R1]
			MOV R0 , #0xFF  ;CONFIG DIGITAL PINS
			STR R0 , [R1]
			
			LDR R1 , =GPIO_PORTB_AMSEL ;no aNALOG PIN function
			LDR R0 , [R1]	
			BIC R0 , #0xFF   ;CLEAR AMSEL OF PORT B
			STR R0 , [R1]
			
			LDR R0 , =GPIO_PORTB_PUR ;assign pull up pins
			MOV R1 , #PUB  ;CONFIG PULL UP RESISTORS
			STR R1 , [R0]
			
			BX LR
			ENDP
			END