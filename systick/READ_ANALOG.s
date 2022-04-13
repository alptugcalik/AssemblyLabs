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
			
			AREA		main, READONLY, CODE
            THUMB

			EXPORT		READ_ANALOG


READ_ANALOG	PROC
			; start sampling routine
			LDR R3, =ADC0_RIS ; interrupt address
			LDR R4, =ADC0_SSFIFO3 ; result address
			LDR R2, =ADC0_PSSI ; sample sequence initiate address
			LDR R6,= ADC0_ISC
			; initiate sampling 
			LDR R0, [R2]
			ORR R0, R0, #0x08 ; set bit 3 for SS3
			STR R0, [R2]
			; check for sample complete 
Cont 		LDR R0, [R3]
			ANDS R0, R0, #8 ; CHECK IF THE RIS FLAG IS SET
			BEQ Cont
			; GO OUT OF THE LOOP IF THE END IS REACHED
			LDR R0,[R4] ; OBTAIN THE DIGITAL INFORMATION
			STR R0, [R6] ; clear flag
			; R0 HAS THE CONVERTED ANANLOG SIGNAL
			BX LR
			ENDP
			END