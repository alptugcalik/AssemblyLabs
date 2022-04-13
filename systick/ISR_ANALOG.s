; ADC Registers
RCGCADC 		EQU 0x400FE638 ; ADC clock register
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
ADC0_ISC		EQU	0x4003800C	
	
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

			EXPORT		ISR_ANALOG
			EXTERN		OutChar
			EXTERN		READ_ANALOG
			EXTERN		CONVRT_DIGITAL

ISR_ANALOG	PROC
			PUSH{LR}
			BL		READ_ANALOG
			BL		CONVRT_DIGITAL
			POP{LR}
			BX LR
			ENDP
			END