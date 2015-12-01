;;; Memory Address information found in the KL25P80M48SF0RM document
SIM_SCGC5   EQU 0x40048038     	;The control for each ports Clock Gate 
SIM_COPC	EQU 0x40048100		;Computer Operating Properly Control
;Pin Control Registers
PORTA_PCR01 EQU 0x40049004  	;LED(red)
PORTA_PCR02 EQU 0x40049008		;LED(yellow)
PORTA_PCR04 EQU 0x40049010		;LED(green)
PORTC_PCR07 EQU 0x4004B01C  	;Button
;Pin Direction & IO Registers
PORTA_PDDR EQU 0x400FF014
PORTA_PDOR EQU 0x400FF000
PORTC_PDDR EQU 0x400FF094
PORTC_PDIR EQU 0x400FF090	
	
;;; Directives
          PRESERVE8
          THUMB       
 
; Vector Table Mapped to Address 0 at Reset
; Linker requires __Vectors to be exported
 
          AREA    RESET, DATA, READONLY
          EXPORT  __Vectors
__Vectors 
		  DCD  0x20001000     ; stack pointer value when stack is empty
          DCD  Reset_Handler  ; reset vector
          ALIGN
 
; The program
; Linker requires Reset_Handler
 
          AREA    MYCODE, CODE, READONLY
 
   	  ENTRY
   	  EXPORT Reset_Handler
Reset_Handler

;REMEMBER frometf --m32 option for .srec output!

;;;;;;;;;;PROGRAM CODE STARTS HERE;;;;;;;;;;;;		
main	
		BL initialize			;Initialize I/O ports
		
reset	LDR R6,=0X0				;reset button
    	LDR R1,=0x00000002      ;Change light to red
		BL changelight			;
		
		LDR R3,=0x05B8D800		;Put value into counter (4 seconds)
d30_1 	BL buttonpress			;Check for button press
		SUBS R3,#17 			;Subtract # of ticks in loop (17) from counter
		CMP R3,#0
		BGT d30_1
		
		CMP R6,#1				;Check for button press
		BEQ reset				;Reset to red if pressed
		LDR R1,=0x00000010		;Change light to green
		BL changelight			;
		
		LDR R3,=0x05B8D800		;Put value into counter (4 seconds)
d30_2	BL buttonpress			;Check for button press
		SUBS R3,#17 			;Subtract # of ticks in loop (17) from counter
		CMP R3,#0
		BGT d30_2

		CMP R6,#1				;Check for button press
		BEQ reset				;Reset to red if pressed
		LDR R1,=0x00000005		;Change light to yellow
		BL changelight			;
		
		LDR R3,=0x02DC6C00		;Put value into counter (2 seconds)
d10_1	BL buttonpress			;Check for button press
		SUBS R3,#17 			;Subtract # of ticks in loop (17) from counter
		CMP R3,#0
		BGT d10_1
        B reset					;Reset to beginning

;;;Subroutines
buttonpress 
		LDR R0,=PORTC_PDIR      ;Put address of PORTC_PDIR into R0
		LDR R1,[R0]			    ;Put value of PORTC_PDIR into R1
		LDR R0,=0x00000080      ;Put value of monitored input pin
		TST R1,R0				;Check for button press
		BNE nopress				;Break from process if button not pressed (EQ for sim)
		MOVS R6,#1				;Put 1 in R6 if button has been pressed
nopress	BX LR					

changelight 
		LDR R0,=PORTA_PDOR      ;Put address of PORTA_PDOR into R0
		STR R1,[R0]				;Put value into PDOR
		BX LR
			
initialize
		;Disable watchdog COP timer
		LDR R0,=SIM_COPC		;Load address of SIM_COPC to R0
		LDR R1,=0x0				;Disable watchdog COPT
		STR R1,[R0]				;
		
		
		;Initialize GPIO clock
		LDR R0,=SIM_SCGC5       ;Load address of SIM_SCGC5 to R0  
		LDR R1,[R0]             ;Put value of SIM_SCGC5 into R1  
		LDR R2,=0x00003F80      ;Load value to turn on all port clocks into R2    
		ORRS R1,R2              ;OR R2 into R1 for use of masking  
		STR R1,[R0]             ;Put value back into SIM_SCGC5,   
							  
		;;Initialize GPIO pins
		;LED (red)
		LDR R0,=PORTA_PCR01     ;Load address of PORTA_PCR01 to R0 
		LDR R1,=0x100           ;Set port to GPIO 
		STR R1,[R0]             ;Put value back into PCR
		;LED (yellow)
		LDR R0,=PORTA_PCR02     ;Load address of PORTA_PCR02 to R0 
		LDR R1,=0x100           ;Set port to GPIO 
		STR R1,[R0]             ;Put value back into PCR
		;LED (green)
		LDR R0,=PORTA_PCR04     ;Load address of PORTA_PCR04 to R0 
		LDR R1,=0x100           ;Set port to GPIO 
		STR R1,[R0]             ;Put value back into PCR
		;LED PDDR
		LDR R0,=PORTA_PDDR      ;Put value of PORTA_PDDR into R0
		LDR R1,=0x00000016   	;Set Pin(s) 1,2,4 to output (0001 0110)
		STR R1,[R0]             ;Put value back into PDDR
		
		;Button
		LDR R0,=PORTC_PCR07     ;Load address of PORTC_PCR07 to R0 
		LDR R1,=0x103           ;Set port to GPIO and enable pull up. 
		STR R1,[R0]             ;Put value back into PCR
		
		LDR R0,=PORTC_PDDR      ;Put value of PORTC_PDDR into R0
		LDR R1,=0x00000000   	;Set Pins 0-31 to input
		STR R1,[R0]             ;Put value back into PDDR
		
		BX LR

			
		END	;End of program