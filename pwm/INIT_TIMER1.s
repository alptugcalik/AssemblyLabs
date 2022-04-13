	
			AREA		main, READONLY, CODE
            THUMB
; Timer channel registers for TIMER1: 
TIMER1_CFG 			EQU 0x40031000 ; Configuration Register 
TIMER1_TAMR 		EQU 0x40031004 ; Mode Register 
TIMER1_CTL 			EQU 0x4003100C ; Control Register 
TIMER1_RIS 			EQU 0x4003101C ; Raw interrupt Status 
TIMER1_ICR 			EQU 0x40031024 ; Interrupt Clear Register 
TIMER1_TAILR		EQU 0x40031028 ; Interval Load Register 
TIMER1_TAMATCHR 	EQU 0x40031030 ; Match Register 
TIMER1_TAPR			EQU 0x40031038 ; Prescaling Divider 
TIMER1_TAR 			EQU 0x40031048 ; Counter Register 

; Timer Gate Control 
SYSCTL_RCGCTIMER	EQU 0x400FE604 ; Timer Clock Gating 

;GPIO Gate Control Register 
SYSCTL_RCGCGPIO 	EQU 0x400FE608 

			EXPORT		INIT_TIMER1

INIT_TIMER1	PROC
		
		; Start Timer 1 clock 
		LDR R1, =SYSCTL_RCGCTIMER 
		LDR R2, [R1] ; Start timer 1 
		ORR R2, R2, #0x02			; Timer module = bit position (1) 
		STR R2, [R1] 
		NOP 
		NOP 
		NOP 					; allow clock to settle 

		; disable timer during setup 
		LDR R1, =TIMER1_CTL 
		LDR R2, [R1] 
		BIC R2, R2, #0x01 			; clear bit 0 to disable Timer 1
		STR R2, [R1] 

		; set to 16bit Timer Mode 
		LDR R1, =TIMER1_CFG 
		MOV R2, #0x04			; set bits 2:0 to 0x04 for 16bit timer 
		STR R2, [R1] 
		
		; set for edge time and capture mode 
		LDR R1, =TIMER1_TAMR 
		MOV R2, #0x07 			; set bit2 to 0x01 for Edge Time Mode
		STR R2, [R1] 				; set bits 1:0 to 0x03 for Capture Mode
		 
		; set edge detection to both 
		LDR R1, =TIMER1_CTL 
		LDR R2, [R1] 
		ORR R2, R2, #0x0C ; set bits 3:2 to 0x03 
		STR R2, [R1] 
		
		LDR R1, =TIMER1_TAPR
		MOV R2, #15 ; divide clock by 16 to
		STR R2, [R1] ; get 1us clocks
		
		; set start value 
		LDR R1, =TIMER1_TAILR 			; counter counts down, 
		MOV R0, #0xFFFFFFFF 			; so start counter at max value 
		STR R0, [R1] 
		
		
			
		; Enable timer 
		LDR R1, =TIMER1_CTL ; 
		LDR R2, [R1] ; 
		ORR R2, R2, #0x01				 ; set bit 0 to enable 
		STR R2, [R1] 

		; Need to clear CAERIS bit of TIMER0_RIS. 
		LDR R1, = TIMER1_ICR
		MOV R2, #0x04 ;				 
		STR R2, [R1] 
		
		BX LR
		ENDP
		END
