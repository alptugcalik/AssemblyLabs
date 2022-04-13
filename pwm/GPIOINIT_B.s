SYSCTL_RCGCGPIO		EQU		0x400FE608 ;SYSTEM GPIO CLOCK
;GPIO Registers for Port B 
;Port B base 0x40005000
GPIO_PORTB_DATA 	EQU 0x400053FC ; Data
GPIO_PORTB_IM 		EQU 0x40005010 ; Interrupt Mask 
GPIO_PORTB_DIR 		EQU 0x40005400 ; Port Direction 
GPIO_PORTB_AFSEL 	EQU 0x40005420 ; Alt Function enable 
GPIO_PORTB_DEN 		EQU 0x4000551C ; Digital Enable 
GPIO_PORTB_AMSEL 	EQU 0x40005528 ; Analog enable 
GPIO_PORTB_PCTL		EQU 0x4000552C ; Alternate Functions 
GPIO_PORTB_PUR 		EQU 	0x40005510 
IOB 				EQU 	0x20       ;INPUT CONFIG OF PORT B
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

			; Setup Port B for signal input 
			; set direction of PB4 
			LDR R1, =GPIO_PORTB_DIR 
			LDR R0,[R1]
			ORR R0,#IOB
			STR R0, [R1] 

			; enable alternate function 
			LDR R1, =GPIO_PORTB_AFSEL 
			LDR R0, [R1] 
			ORR R0, R0, #0x10 				; set bit4,7 for alternate fuction on PB4
			STR R0, [R1] 

			; set alternate function to T0CCP0 (7) 
			LDR R1, =GPIO_PORTB_PCTL 
			LDR R0, [R1] 
			ORR R0, R0, #0x00070000 			; set bits 27:24 of PCTL to 7 
			STR R0, [R1] 					; to enable T1CCP0 on PB4 
			
			LDR R1, =GPIO_PORTB_DEN
			MOV R0, #0xFF ; enable Port as digital port
			STR R0, [R1]

			; disable analog 
			LDR R1, =GPIO_PORTB_AMSEL 
			MOV R0, #0 					; clear AMSEL to diable analog 
			STR R0, [R1]

				
			LDR R0 , =GPIO_PORTB_PUR ;assign pull up pins
			MOV R1 , #PUB  ;CONFIG PULL UP RESISTORS
			STR R1 , [R0]
			
			BX LR
			ENDP
			END