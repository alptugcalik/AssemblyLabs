SYSCTL_RCGCGPIO		EQU		0x400FE608 ;SYSTEM GPIO CLOCK
;GPIO Registers for Port E 
;Port E base 0x40024000
GPIO_PORTE_DATA 	EQU 	0x400243FC ; data address to all pins SPECIFIED WITH REQUIRED MASK 
GPIO_PORTE_DIR 		EQU 	0x40024400
GPIO_PORTE_AFSEL 	EQU 	0x40024420
GPIO_PORTE_AMSEL 	EQU 	0x40024428
GPIO_PORTE_DEN 		EQU 	0x4002451C
GPIO_PORTE_PUR 		EQU 	0x40024510 
IOE 				EQU 	0x00       ;INPUT CONFIG OF PORT E
PUE 				EQU 	0x00 	; or #00001111
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
			
			
			
			AREA		main, READONLY, CODE
            THUMB

			EXPORT		INIT_ADC


INIT_ADC	PROC
			LDR R1, =RCGCADC ; Turn on ADC clock
			LDR R0, [R1]
			ORR R0, R0, #0x01 ; set bit 0 to enable ADC0 clock
			STR R0, [R1]
			NOP
			NOP
			NOP ; Let clock stabilize
			NOP
			NOP
			
			;ENABLE CLOCK FIRST
			LDR R1,=SYSCTL_RCGCGPIO
			LDR R0,[R1]
			ORR R0,#0x10; turn on clock for E port
			STR R0 ,[R1]
			NOP
			NOP
			NOP
			

			; enable alternate function 
			LDR R1, =GPIO_PORTE_AFSEL 
			LDR R0, [R1] 
			ORR R0, R0, #0x08 				; set bit3 for alternate fuction on PE3
			STR R0, [R1] 

			; Setup Port E for signal input 
			; set direction of PE3 
			LDR R1, =GPIO_PORTE_DIR
			LDR R0,[R1]
			BIC R0, R0, #0x08
			STR R0, [R1] 
			
			LDR R1, =GPIO_PORTE_DEN
			LDR R0, [R1]
			BIC R0, R0, #0x08 ; clear bit 3 to disable digital on PE3
			STR R0, [R1]

			; ENABLE analog 
			LDR R1, =GPIO_PORTE_AMSEL 
			LDR R0, [R1] 
			ORR R0, R0, #0x08 				; set bit 3 to enable analog on PE3
			STR R0, [R1] 
			
			;Disable sequencer while ADC setup
			LDR R1, =ADC0_ACTSS
			LDR R0, [R1]
			BIC R0, R0, #0x08 ; clear bit 3 to disable seq 3
			STR R0, [R1]
			
			; Select trigger source
			LDR R1, =ADC0_EMUX
			LDR R0, [R1]
			BIC R0, R0, #0xF000 ; clear bits 15:12 to select SOFTWARE
			STR R0, [R1] ; trigger
			
			; Select input channel
			LDR R1, =ADC0_SSMUX3
			LDR R0, [R1]
			BIC R0, R0, #0x000F ; clear bits 3:0 to select AIN0
			STR R0, [R1]
			
			; Config sample sequence
			LDR R1, =ADC0_SSCTL3
			LDR R0, [R1]
			ORR R0, R0, #0x06 ; set bits 2:1 (IE0, END0)
			STR R0, [R1]
			
			; Set sample rate
			LDR R1, =ADC0_PC
			LDR R0, [R1]
			ORR R0, R0, #0x01 ; set bits 3:0 to 1 for 125k sps
			STR R0, [R1]
			
			; Done with setup, enable sequencer
			LDR R1, =ADC0_ACTSS
			LDR R0, [R1]
			ORR R0, R0, #0x08 ; set bit 3 to enable seq 3
			STR R0, [R1] ; sampling enabled but not initiated yet
			
			BX LR
			ENDP
			END
