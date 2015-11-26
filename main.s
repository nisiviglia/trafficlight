;;; Memory Address information found in the KL25P80M48SF0RM document
SIM_SCGC5   EQU 0x40048038     	;The control for each ports Clock Gate 
GPIOA_BASE	EQU 0x400FF000 
GPIOB_BASE	EQU 0x400FF040
GPIOC_BASE	EQU 0x400FF080
GPIOD_BASE	EQU 0x400FF0C0
GPIOE_BASE	EQU 0x400FF100
;Base address offsets
GPIO_PDOR	EQU 0x00	;Turn output pin on or off
GPIO_PSOR	EQU 0x04	;Turn output pin on
GPIO_PCOR	EQU 0x08	;Turn output pin off
GPIO_PTOR	EQU 0x0C	;Flip output pin
GPIO_PDIR	EQU 0x10	;Set input pin on or off
GPIO_PDDR	EQU 0x14	;Set as input or output
;Pins in use
PORTA_PCR01 EQU 0x40049004	
	
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
main PROC
		BL initialize
		BL changelight
stop B stop	
		ENDP

initialize PROC
		;Initialize GPIO clock pins
		LDR R0,=SIM_SCGC5     ;Load address of SIM_SCGC5 to R0  
		LDR R1,[R0]           ;Put value of SIM_SCGC5 into R1  
		LDR R2,=0x00003F80    ;Load value to turn on all port clocks into R2    
		ORRS R1,R2            ;OR R2 into R1 for use of masking  
		STR R1,[R0]           ;Put value back into SIM_SCGC5,   
							  ;This puts 0011 1110 0000 0000, binary of 3E, into the Sim_SCGC5 register  
						      ;Which turns on the port clocks A-E.
		;Initialize GPIO pins
		LDR R0,=PORTA_PCR01     ;Load address of PORTA_PCR01 to R0 
		LDR R1,=0x100           ;Load value to R1 
		STR R1,[R0]             ;Put value back into PCR
		
		LDR R0, =0x400FF014      ;Put value of PORTA_PDDR into R0
		LDR R1, =0x0000000F   	 ;Set Pin(s) 0-3 to output
		STR R1,[R0]              ;Put value back into PDDR
		
		BX LR
		ENDP

changelight    PROC
		LDR R0, =0x400FF000     ;Put value of PORTA_PDOR into R0
		LDR R1, =0x0000000F     ;Turn pin(s) 0-3, on
		STR R1, [R0]			;Put value back into PDOR
		BX LR
		ENDP

		END	;End of program