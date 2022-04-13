; ADC0 base address EQU 0x40038000
ADC0_ACTSS 		EQU 0x40038000 ; Sample sequencer (ADC0 base address)
ADC0_RIS 		EQU 0x40038004 ; Interrupt status
ADC0_IM 		EQU 0x40038008 ; Interrupt select
ADC0_EMUX 		EQU 0x40038014 ; Trigger select
ADC0_PSSI 		EQU 0x40038028 ; Initiate sample
ADC0_SSMUX3 	EQU 0x400380A0 ; Input channel select
ADC0_SSCTL3 	EQU 0x400380A4 ; Sample sequence control
ADC0_SSFIFO3 	EQU 0x400380A8 ; Channel 3 results 
ADC0_PC 		EQU 0x40038FC4 ; Sample rate
ADC0_ISC		EQU 0x4003800C	
	
	
; 16/32 Timer Registers
TIMER0_CFG			EQU 0x40030000
TIMER0_TAMR			EQU 0x40030004
TIMER0_CTL			EQU 0x4003000C
TIMER0_IMR			EQU 0x40030018
TIMER0_RIS			EQU 0x4003001C ; Timer Interrupt Status
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR		EQU 0x40030028 ; Timer interval
TIMER0_TAPR			EQU 0x40030038
TIMER0_TAR			EQU	0x40030048 ; Timer register
TIMER0_MATCH		EQU 0x40030030
	
	
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
	
;---------------------------------------------------
; 4KhZ FREQUENCY -> 250 us period -> 250000 ns period
; 1clk 62.5 ns -> 4000 cycle for one period 4000 = 0xfa0
; at match the otput becomes 0
; initial duty cycle 25% -> match = 1000 = 0x3e8
MATCH				EQU	0x0000310   
PERIOD				EQU	0x0000fa0   
;---------------------------------------------------

SYSCTL_RCGCTIMER	EQU 0x400FE604 ; Timer Clock Gating 
			
			
			AREA		main, READONLY, CODE
            THUMB

			EXPORT		__main
			EXTERN		CONVRT
			EXTERN		INIT_ADC
			EXTERN		READ_ANALOG
			EXTERN		CONVRT_DIGITAL
			EXTERN		DELAY100
			EXTERN		InitSysTick

pwm_init proc
			; PB6 is used for pwm 
			
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
			MOV R0,#IOB
			STR R0, [R1] 

			; enable alternate function 
			LDR R1, =GPIO_PORTB_AFSEL 
			LDR R0, [R1] 
			ORR R0, R0, #0x50 				; set bit4,7 for alternate fuction on PB4  AND PB6
			STR R0, [R1] 

			; set alternate function to T0CCP0 (7) 
			LDR R1, =GPIO_PORTB_PCTL 
			LDR R0, [R1] 
			ORR R0, R0, #0x00070000 			; set bits 27:24 of PCTL to 7 
			ORR R0, R0, #0x07000000 			; set bits 27:24 of PCTL to 7 
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
			
			LDR R1, =SYSCTL_RCGCTIMER ; Start Timer0
			LDR R2, [R1]
			ORR R2, R2, #0x01
			STR R2, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =TIMER0_CTL ; disable timer during setup 
			LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
			LDR R1, =TIMER0_CFG ; set 16 bit mode
			MOV R2, #0x04
			STR R2, [R1]
			LDR R1, =TIMER0_TAMR
			MOV R2, #0x0A ; set to PWM
			STR R2, [R1]
			LDR R1, =TIMER0_CTL ;INVERT 
			LDR R2, [R1]
			ORR R2, R2, #0x40
			STR R2, [R1]
			;LDR R1, =TIMER0_TAPR
			;MOV R2, #15 ; divide clock by 16 to
			;STR R2, [R1] ; get 1us clocks
			LDR R1, =TIMER0_TAILR ; initialize LOAD
			LDR R2, =PERIOD
			STR R2, [R1]
			LDR R1, =TIMER0_MATCH ; match clocks
			LDR R2, =MATCH
			STR R2, [R1]
			
; Enable timer
			LDR R1, =TIMER0_CTL
			LDR R2, [R1]
			ORR R2, R2, #0x03 ; set bit0 to enable
			STR R2, [R1] ; and bit 1 to stall on debug
	bx lr
	endp

; NOTICE THAT TIMER 0 IS USED FOR PWM AND PB6 PIN IS USED
	; PB6 IS CONNECTED TO BLUE LED TO SEE THE PWM (PF2)
	; PB6 is used for pwm 

__main		PROC
			BL INIT_ADC ; INITIALIZE THE adc
			BL pwm_init
			BL InitSysTick
loop		b loop
		ENDP
		END