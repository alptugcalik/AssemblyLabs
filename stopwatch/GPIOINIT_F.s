SYSCTL_RCGCGPIO		EQU		0x400FE608
GPIO_PORTF_DATA 	EQU 	0x400253FC ; data address to all pins SPECIFIED WITH REQUIRED MASK 
GPIO_PORTF_DIR 		EQU 	0x40025400
GPIO_PORTF_AFSEL 	EQU 	0x40025420
GPIO_PORTF_AMSEL 	EQU 	0x40025428
GPIO_PORTF_DEN 		EQU 	0x4002551C
GPIO_PORTF_PUR 		EQU 	0x40025510 
IOF 				EQU 	0x08       ;INPUT CONFIG OF PORT F
GPIO_PORTF_LOCK		EQU		0x40025520
GPIO_PORTF_COMMIT	EQU		0x40025524
PUF					EQU		0x10

			AREA		main, READONLY, CODE
            THUMB

			EXPORT		GPIOINIT_F


GPIOINIT_F	PROC

			;ENABLE CLOCK FIRST
			LDR R1,=SYSCTL_RCGCGPIO
			LDR R0,[R1]
			ORR R0,#0x20; turn on clock for F port
			STR R0 ,[R1]
			NOP
			NOP
			
			
			LDR R1, =GPIO_PORTF_DIR ; direction register address
			LDR R0,[R1] ;direction register data
			BIC R0,#0xFF ;CONFIG INPUT AND OUTPUTS
			ORR R0,#IOF
			STR R0 ,[R1]
			
			LDR R1 , =GPIO_PORTF_AFSEL ;no alternative function
			LDR R0 , [R1]	
			BIC R0 , #0xFF   ;CLEAR AFSEL OF PORT F
			STR R0 , [R1]
			
			LDR R0 , =GPIO_PORTF_PUR ;assign pull up pins
			MOV R1 , #PUF  ;CONFIG PULL UP RESISTORS
			STR R1 , [R0]
			
			LDR R1 , =GPIO_PORTF_DEN  ;all pins are dgital
			LDR R0 , [R1]
			MOV R0 , #0xFF  ;CONFIG DIGITAL PINS
			STR R0 , [R1]
			
			LDR R1 , =GPIO_PORTF_AMSEL ;no aNALOG PIN function
			LDR R0 , [R1]	
			BIC R0 , #0xFF   ;CLEAR AMSEL OF PORT F
			STR R0 , [R1]
			
			LDR R1 , =GPIO_PORTF_LOCK ;no aNALOG PIN function
			LDR R0 , =0x4C4F434B
			STR R0 , [R1]
			
			LDR R1, =GPIO_PORTF_COMMIT ; direction register address
			LDR R0,[R1] ;direction register data
			ORR R0,#0x10
			STR R0 ,[R1]
			

			BX LR
			ENDP
			END