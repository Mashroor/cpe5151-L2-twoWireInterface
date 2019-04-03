;*********************************************************************
;    Assembly_Exp1 - This file contains "do-nothing" functions
;        that are setup so that they can be called from a C program
;        using the extern keyword in C.  The exported label is the
;        name of the function in C.  The functions save and restore
;        some registers so that they can be used in the function, but
;        not altered in the C program.
;
;        The do-nothing functions are program stubs that the student
;        can use as a starting point for their solution.
;*********************************************************************
;    Code written by: Roger Younger
;    v1.0 Released: Feb. 9, 2017
;    Solution written by: Roger Younger
;    v1.1 Released: Feb. 28, 2017
;    Solution Updated and more comments added
;    v1.2 Released: Mar. 5, 2018
;*********************************************************************
;    CONSTANT DEFINITIONS
;*********************************************************************
		INCLUDE AT91SAM7SE512.INC



;*********************************************************************
;    VARIABLE DEFINITIONS
;*********************************************************************
         PRESERVE8


		AREA VARIABLES,DATA,READWRITE
			
COUNT_VALUE DCD 0    ; variable with an initial value of 0
INC_VALUE DCD 1      ; variable with an initial value of 1
DEC_VALUE DCD 1      ; variable with an initial value of 1

;***********************************************************
;    AREA DEFINITION AND OPTIONS
;***********************************************************
		PRESERVE8


		AREA EXAMPLE,CODE,READONLY
		ARM



			


;***********************************************************
;    Function: Power LED (PA0) initialization
;              Enables PIOA clock.
;              Sets PA0 to be a push-pull output without pull-up resistor
;              Initial value for PA0 is '1' to switch power LED on.
;***********************************************************
		EXPORT POWERLED_INIT

POWERLED EQU 1<<0		; PA0 connected to power LED
			
POWERLED_INIT
        PUSH {R4,R5,R6,R14}
		LDR R4,=PMC_BASE        ; Base address of Power Management Controller
		MOV R5,#(1<<PIOA_PID)        ; PID number for PIOA is 1<<2
		STR R5,[R4,#PMC_PCER]   ; Enable clock for PIOA
		LDR R4,=PIOA_BASE		; PIOA base address placed in R4
		MOV R5,#POWERLED		; Bit 0 set to 1 for PA0 (power LED)
		STR R5,[R4,#PIO_PER]		; Enables PA0 as PIO
		STR R5,[R4,#PIO_OER]		; Enables PA0 as an Output
		STR R5,[R4,#PIO_PUDR]		; Disables PA0 pullup resistor
		STR R5,[R4,#PIO_MDDR]		; Select push-pull output
		STR R5,[R4,#PIO_SODR]		; Sets PA0 to ‘1’, POWERLED on
		POP {R4,R5,R6,R14}
		BX R14
		
;***********************************************************
;    Function: USER LED initialization
;              Enables PIOA clock.
;              Sets PA1 and PA2 to be a push-pull outputs without pull-up resistor
;              Initial values for PA1 and PA2 are '1' to switch user LEDs off.
;***********************************************************
		EXPORT USER_LEDS_INIT
			
LED1 EQU 1<<1		; PA1 connected to LED1
LED2 EQU 1<<2		; PA2 connected to LED2
			
USER_LEDS_INIT
        PUSH {R4,R5,R6,R14}
		LDR R4,=PMC_BASE        ; Base address of Power Management Controller
		MOV R5,#(1<<PIOA_PID)        ; PID number for PIOA is 1<<2
		STR R5,[R4,#PMC_PCER]   ; Enable clock for PIOA
		LDR R4,=PIOA_BASE		; PIOA base address placed in R4
		MOV R5,#(LED1:OR:LED2)		; Bits 1 and 2 set to 1 for PA1 and PA2 (user LEDs)
		STR R5,[R4,#PIO_PER]		; Enables as PIO
		STR R5,[R4,#PIO_OER]		; Enables as Outputs
		STR R5,[R4,#PIO_PUDR]		; Disables pullup resistor
		STR R5,[R4,#PIO_MDDR]		; Select push-pull output
		STR R5,[R4,#PIO_SODR]		; Sets PA1 and PA2 to ‘1’, LEDs off
		POP {R4,R5,R6,R14}
		BX R14
		
;***********************************************************
;    Function: Switch Inputs initialization
;              Enables PIOB clock.
;              Sets PB27 to PB 22 to be inputs with pull-up resistors enabled
;              so they can be used to read the input switches on the dev. board.
;***********************************************************
		EXPORT SWITCH_INIT
			
RIGHT_PB EQU 1<<22		; PB22 connected to Right Push Button
UP_SW EQU 1<<23		    ; PB23 connected to Up Joystick
DOWN_SW EQU 1<<24		; PB24 connected to Down Joystick
LEFT_PB EQU 1<<25		; PB25 connected to Left Push Button
RIGHT_SW EQU 1<<26		; PB26 connected to Right Joystick
LEFT_SW EQU 1<<27		; PB27 connected to Left Joystick
ALL_SWITCHES EQU (RIGHT_PB:OR:LEFT_PB:OR:UP_SW:OR:DOWN_SW:OR:LEFT_SW:OR:RIGHT_SW)
			
SWITCH_INIT
        PUSH {R4,R5,R6,R14}
		LDR R4,=PMC_BASE        ; Base address of Power Management Controller
		MOV R5,#(1<<PIOB_PID)        ; PID number for PIOB is 1<<3
		STR R5,[R4,#PMC_PCER]   ; Enable clock for PIOB
		LDR R4,=PIOB_BASE		; PIOA base address placed in R4
		MOV R5,#ALL_SWITCHES		; Bits 27 to 22 are set to 1 for PB27 to PB22
		STR R5,[R4,#PIO_PER]		; Enables as PIO
		STR R5,[R4,#PIO_ODR]		; Disables output (Sets as input)
		STR R5,[R4,#PIO_PUER]		; Enables pullup resistor
		POP {R4,R5,R6,R14}
		BX R14
		
;***********************************************************
;    Function: External LED initialization
;              Enables PIOC clock.
;              Set PC7 to PC0 to be push-pull outputs with pull-up resistor disabled. 
;              The eight bit are set to be controlled by writing a value
;              to the PIO_ODSR so they can be changed as a group.
;              The initial values for the LEDs are '1' to switch them off.
;***********************************************************
		EXPORT EXT_LEDS_INIT
			
EXT_LEDS EQU 0xFF		; External LEDS are lower eight bits of PIOC
			
EXT_LEDS_INIT
        PUSH {R4,R5,R6,R14}
		LDR R4,=PMC_BASE        ; Base address of Power Management Controller
		MOV R5,#(1<<PIOC_PID)        ; PID number for PIOC is 1<<4
		STR R5,[R4,#PMC_PCER]   ; Enable clock for PIOC
		LDR R4,=PIOC_BASE		; PIOA base address placed in R4
		MOV R5,#EXT_LEDS		; Bits 7 to 0 set to 1 for PC7 to PC0
		STR R5,[R4,#PIO_PER]		; Enables as PIO
		STR R5,[R4,#PIO_OER]		; Enables as Output
		STR R5,[R4,#PIO_PUDR]		; Disables pullup resistor
		STR R5,[R4,#PIO_MDDR]		; Select push-pull output
		STR R5,[R4,#PIO_OWER]		; Enables write to Output Data Status reg. (PIO_ODSR)
		STR R5,[R4,#PIO_ODSR]		; Set initial value so that all external LEDs are off.
		POP {R4,R5,R6,R14}
		BX R14
		
;***********************************************************
;    Function: Delay Function
;              Simple loop that takes about 1ms to execute
;
;***********************************************************
DELAY_VAL   EQU   5990        ; Value is adjusted for 1 wait state
	                          ; Original value was 1ms/(4 clock cycles/47.9232MHz)=11980
		EXPORT DELAY_1MS
			
DELAY_1MS
        PUSH {R4,R5,R6,R14}
D_LOOP
		LDR R4,=DELAY_VAL
D_REPEAT
		SUBS R4,R4,#1
		BNE D_REPEAT
		SUBS R0,R0,#1
		BNE D_LOOP
		POP {R4,R5,R6,R14}
		BX R14	

;***********************************************************
;    Function: Power LED Control
;              Uses an input value to control the Power LED
;              Input=='0', Power LED switches off
;              Input=='1'. Power LED switches on
;***********************************************************
		EXPORT POWERLED_CONTROL
			
POWERLED_CONTROL
        PUSH {R4,R5,R6,R14}
		LDR R4,=PIOA_BASE		; PIOA base address placed in R4
		MOV R5,#POWERLED		; Bit 0 set to 1 for PA0 (power LED)
		TEQ R0,#1     			; if(input==1)
		STREQ R5,[R4,#PIO_SODR]		; Then set PA0 to ‘1’, POWERLED on
		STRNE R5,[R4,#PIO_CODR]		; Else clear PA0 to ‘0’, POWERLED off
		POP {R4,R5,R6,R14}
		BX R14
		
;***********************************************************
;    Function: LED1 Control
;              Uses an input value to control the User LED 1
;              Input=='0', User LED 1 switches off
;              Input=='1'. User LED 1 switches on
;***********************************************************
		EXPORT LED1_CONTROL
			
LED1_CONTROL
        PUSH {R4,R5,R6,R14}
		LDR R4,=PIOA_BASE		; PIOA base address placed in R4
		MOV R5,#LED1		; Bit 0 set to 1 for PA0 (power LED)
		TEQ R0,#1     			; if(input==1)
		STREQ R5,[R4,#PIO_CODR]		; Then clear PA1 to ‘0’, LED1 on
		STRNE R5,[R4,#PIO_SODR]		; Else set PA1 to ‘1’, LED1 off
		POP {R4,R5,R6,R14}
		BX R14
		
;***********************************************************
;    Function: LED2 Control
;              Uses an input value to control the User LED 2
;              Input=='0', User LED 2 switches off
;              Input=='1'. User LED 2 switches on
;***********************************************************
		EXPORT LED2_CONTROL
			
LED2_CONTROL
        PUSH {R4,R5,R6,R14}
		LDR R4,=PIOA_BASE		; PIOA base address placed in R4
		MOV R5,#LED2		; Bit 0 set to 1 for PA0 (power LED)
		TEQ R0,#1     			; if(input==1)
		STREQ R5,[R4,#PIO_CODR]		; Then clear PA2 to ‘0’, LED1 on
		STRNE R5,[R4,#PIO_SODR]		; Else set PA2 to ‘1’, LED1 off
		POP {R4,R5,R6,R14}
		BX R14
		
;**************************************************************
;
;	Function: Blink Power LED
;             No inputs and no return value
;             Endless loop to blink Power LED
;             Value in R0 before Delay_1ms call determines blink rate
;*************************************************************
		EXPORT BLINKY

BLINKY
		PUSH {R14}
BLINKY_LOOP
		MOV R0,#1
		BL POWERLED_CONTROL
		MOV R0,#500			  ; delay for about 500ms
		BL DELAY_1MS
		MOV R0,#0
		BL POWERLED_CONTROL
		MOV R0,#500			  ; delay for about 500ms
		BL DELAY_1MS
		B BLINKY_LOOP         ; endless loop
		POP {R14}
		BX R14
		

;*************************************************************
;    Function: Counter Function 1 
;              Written as an endless loop.  Increments by 1
;              if left push button is pressed and decrements
;              by 1 if the right push button is pressed.
;              Calls a display function to display the count.
;*************************************************************
		EXPORT COUNTER_1
			
COUNTER_1

        PUSH {R4,R5,R6,R7,R14}
		MOV R6,#0               ; initialize counter to 0
CNTR_1
		LDR R4,=PIOB_BASE		; PIOA base address placed in R4
		LDR R5,[R4,#PIO_PDSR]   
		TST R5,#LEFT_PB         ; if(leftpb is pressed)
		BNE END_LEFT_PB_1       ; then
		MOV R0,#100             ;   delay_1ms(100) for debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]   ;   if(leftpb is pressed)
		TST R5,#LEFT_PB         ;   then
		ADDEQ R6,R6,#1          ;      increment count
END_LEFT_PB_1   	            ; end if{leftpb pressed}
		LDR R5,[R4,#PIO_PDSR]   
		TST R5,#RIGHT_PB        ; if(rightpb is pressed)
		BNE END_RIGHT_PB_1      ; then
		MOV R0,#100             ;    delay_1ms(100) for debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]   ;    if(rightpb is pressed)
		TST R5,#RIGHT_PB        ;    then
		SUBEQ R6,R6,#1          ;       decrement count
END_RIGHT_PB_1                  ; end if{rightpb pressed}
		AND R6,R6,#0xFF         ; Limits to 8 bits but allows rollover
		MOV R0,R6
        BL DISPLAY_FUNCTION     ; display the count value
		B CNTR_1
		POP {R4,R5,R6,R7,R14}
		BX R14



;*************************************************************
;    Function: Display Function using switch inputs
;*************************************************************
		EXPORT DISPLAY_FUNCTION
			
DISPLAY_FUNCTION

        PUSH {R4,R5,R6,R14}
		LDR R4,=PIOC_BASE		; PIOC base address placed in R4
		MVN R5,R0		        ; R0 is the value to be displayed, invert for active low LEDs
		STR R5,[R4,#PIO_ODSR]		; Value stored to writable portion of the ODSR
		POP {R4,R5,R6,R14}
		BX R14

;*************************************************************
;    Function: Check Left Joystick
;              Reads the inputs and if Left Joystick is pressed
;              then it jumps to the modify increment value mode
;*************************************************************
		EXPORT CHECK_LEFT_JOYSTICK
			
CHECK_LEFT_JOYSTICK

        PUSH {R4,R5,R6,R14}
		LDR R4,=PIOB_BASE		; Read switch values
		LDR R5,[R4,#PIO_PDSR]
		TST R5,#LEFT_SW         ; if(left_joystick is pressed)
		BNE END_LEFT_SW         ; then
		MOV R0,#100             ;    delay for debouncing
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]   ;    read switch values again
		TST R5,#LEFT_SW         ;    if(left_joystick is pressed)
		BNE END_LEFT_SW	        ;    then
		LDR R6,=INC_VALUE       ;      read the increment value from RAM
        LDR R0,[R6]		
		BL MOD_INC_VALUE        ;      go to modify_increment_value function
		LDR R6,=INC_VALUE 
		STR R0,[R6]             ;      write the new increment value to RAM
		;MOV R0,#150            ; addition delay can help when exiting this function 
		;BL DELAY_1MS           ; end both if statements
END_LEFT_SW
		MOV R0,R6
		POP {R4,R5,R6,R14}
		BX R14
				
;*************************************************************
;    Function: Check Right Joystick
;              Reads the inputs and if Right Joystick is pressed
;              then it jumps to the modify decremtn value mode
;*************************************************************
		EXPORT CHECK_RIGHT_JOYSTICK
			
CHECK_RIGHT_JOYSTICK

        PUSH {R4,R5,R6,R14}
		MOV R6,R0
		LDR R4,=PIOB_BASE		
		LDR R5,[R4,#PIO_PDSR]    ; Read switch values
		TST R5,#RIGHT_SW         ; if(right_joystick is pressed)
		BNE END_RIGHT_SW         ; then
		MOV R0,#100              ;    delay for debouncing
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]    ;    read switch values again
		TST R5,#RIGHT_SW         ;    if(right_joystick is pressed)
		BNE END_RIGHT_SW	     ;    then
		LDR R6,=DEC_VALUE        ;       read the decrement value from RAM
		LDR R0,[R6]       
		BL MOD_DEC_VALUE        ;        go to modify_deccrement_value function
		LDR R6,=DEC_VALUE
		STR R0,[R6]              ;       write the new decrement value to RAM
		;MOV R0,#150
		;BL DELAY_1MS
END_RIGHT_SW
		MOV R0,R6		
		POP {R4,R5,R6,R14}
		BX R14
		

;*************************************************************
;    Function: Modify Increment Value
;              Remains in this function until the Left Joystick is pressed
;              Increases the INC_VALUE up to a maximum value of 16 if Up Joystick is pressed.
;              Decreases the INC_VALUE down to a minimum value of 1 if Down Joystick is pressed.
;              Current INC_VALUE is displayed and User LED 1 is on to indicate
;              that the system in in modify increment value mode.
;*************************************************************
		
			
MOD_INC_VALUE

        PUSH {R4,R5,R6,R7,R14}
        MOV R6,R0           ; copy the increment value to R6
		BL DISPLAY_FUNCTION    ; display the increment value immediately
		MOV R0,#1			; "ON" VALUE FOR LED1
		BL LED1_CONTROL     ; passed to function to switch on User LED 1
		MOV R0,#200         ; delay needed to keep from exiting function early
		BL DELAY_1MS
		LDR R4,=PIOB_BASE		
DO_INC_MOD		
		LDR R5,[R4,#PIO_PDSR]     ; read switch inputs
		TST R5,#UP_SW             ; if(up is pressed)
		BNE END_UP_SW_INC         ; then
		MOV R0,#100               ;    debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]     ;    read switch inputs again
		TST R5,#UP_SW             ;    if(up is pressed)
		BNE END_UP_SW_INC         ;    then
		ADD R6,R6,#1              ;       increase increment value
		CMP R6,#16                ;       if(value>MAX_VALUE)  
		BLS END_UP_SW_INC         ;       then
		MOV R6,#16                ;          value=MAX_VALUE
END_UP_SW_INC                     ; end if {up} and {MAX_VALUE}
		LDR R5,[R4,#PIO_PDSR]     ; read switch inputs
		TST R5,#DOWN_SW           ; if(down is pressed)
		BNE END_DOWN_SW_INC       ; then
		MOV R0,#100               ;    debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]     ;    read switch inputs again
		TST R5,#DOWN_SW           ;    if(down is pressed)
		BNE END_DOWN_SW_INC       ;    then
		SUB R6,R6,#1              ;       decrease increment value
		CMP R6,#1                 ;       if(value<MIN_VALUE)
		BHS END_DOWN_SW_INC       ;       then
		MOV R6,#1                 ;          value=MIN_VALUE
END_DOWN_SW_INC                   ; end if {down} and {MIN_VALUE}
        MOV R0,R6
		BL DISPLAY_FUNCTION       ; Display the updated value
		LDR R5,[R4,#PIO_PDSR]     ; read switch inputs 
		TST R5,#LEFT_SW           ; if(left is pressed for exit)
		BNE DO_INC_MOD            ; then
		MOV R0,#100               ;    debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]     ;    read switch inputs again
		TST R5,#LEFT_SW           ;    if(left is pressed for exit)
		BNE DO_INC_MOD            ;    then
		MOV R0,#0			      ;      Switch OFF LED1
		BL LED1_CONTROL           ;      return INC_VALUE in R0
		MOV R0,R6                 ; end if {left}
		POP {R4,R5,R6,R7,R14}
		BX R14
		
;*************************************************************
;    Function: Modify Decrement Value
;              Remains in this function until the Right Joystick is pressed
;              Increases the DEC_VALUE up to a maximum value of 16 if Up Joystick is pressed.
;              Decreases the DEC_VALUE down to a minimum value of 1 if Down Joystick is pressed.
;              Current DEC_VALUE is displayed and User LED 2 is on to indicate
;              that the system in in modify decrement value mode.
;*************************************************************
		
			
MOD_DEC_VALUE

        PUSH {R4,R5,R6,R7,R14}
        MOV R6,R0           ; copy the decrement value to R6
		BL DISPLAY_FUNCTION    ; display the decrement value immediately
		MOV R0,#1			; "ON" VALUE FOR LED2
		BL LED2_CONTROL     ; passed to function to switch on User LED 2
		MOV R0,#200         ; delay needed to keep from exiting function early
		BL DELAY_1MS
		LDR R4,=PIOB_BASE		
DO_DEC_MOD		
		LDR R5,[R4,#PIO_PDSR]     ; read switch inputs
		TST R5,#UP_SW             ; if(up is pressed)
		BNE END_UP_SW_DEC         ; then
		MOV R0,#100               ;    debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]     ;    read switch inputs again
		TST R5,#UP_SW             ;    if(up is pressed)
		BNE END_UP_SW_DEC         ;    then
		ADD R6,R6,#1              ;       increase decrement value
		CMP R6,#16                ;       if(value>MAX_VALUE)  
		BLS END_UP_SW_DEC         ;       then
		MOV R6,#16                ;          value=MAX_VALUE
END_UP_SW_DEC                     ; end if {up} and {MAX_VALUE}
		LDR R5,[R4,#PIO_PDSR]     ; read switch inputs
		TST R5,#DOWN_SW           ; if(down is pressed)
		BNE END_DOWN_SW_DEC       ; then
		MOV R0,#100               ;    debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]     ;    read switch inputs again
		TST R5,#DOWN_SW           ;    if(down is pressed)
		BNE END_DOWN_SW_DEC       ;    then
		SUB R6,R6,#1              ;       decrease decrement value
		CMP R6,#1                 ;       if(value<MIN_VALUE)
		BHS END_DOWN_SW_DEC       ;       then
		MOV R6,#1                 ;          value=MIN_VALUE
END_DOWN_SW_DEC                   ; end if {down} and {MIN_VALUE}
        MOV R0,R6
		BL DISPLAY_FUNCTION       ; Display the updated value
		LDR R5,[R4,#PIO_PDSR]     ; read switch inputs 
		TST R5,#RIGHT_SW           ; if(right is pressed for exit)
		BNE DO_DEC_MOD            ; then
		MOV R0,#100               ;    debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]     ;    read switch inputs again
		TST R5,#RIGHT_SW           ;    if(right is pressed for exit)
		BNE DO_DEC_MOD            ;    then
		MOV R0,#0			      ;      Switch OFF LED2
		BL LED2_CONTROL           ;      return DEC_VALUE in R0
		MOV R0,R6                 ; end if {right}
		POP {R4,R5,R6,R7,R14}
		BX R14		



;*************************************************************
;    Function: Counter Function 2
;              Written as an endless loop.  Increments by INC_VALUE
;              if left push button is pressed and decrements
;              by DEC_VALUE if the right push button is pressed.
;              Calls a display function to display the count.
;*************************************************************
		EXPORT COUNTER_2
			
COUNTER_2

        PUSH {R1,R2,R4,R5,R6,R7,R14}
		MOV R6,#0             ; initialize count value to 0
CNTR_2
		; These values could be passed as parameters, but I chose to store in RAM
		LDR R7,=DEC_VALUE     ; Read the current DEC_VALUE from RAM
		LDR R2,[R7]          
		LDR R7,=INC_VALUE     ; Read the current INC_VALUE from RAM
		LDR R1,[R7] 
        ; Check Left Pushbutton for increment		
		LDR R4,=PIOB_BASE		; PIOB base address placed in R4
		LDR R5,[R4,#PIO_PDSR]
		TST R5,#LEFT_PB         ; if(LEFTPB is pressed)
		BNE END_LEFT_PB_2         ; then
		MOV R0,#100             ;   delay_1ms(100) for debounce
		BL DELAY_1MS
		LDR R5,[R4,#PIO_PDSR]   ;    if (LEFTPB is pressed)
		TST R5,#LEFT_PB         ;    then
		ADDEQ R6,R6,R1          ;        count:= count + INC_VALUE
END_LEFT_PB_2                   ; end if{LEFTPB}
		LDR R5,[R4,#PIO_PDSR]
		TST R5,#RIGHT_PB        ; if(RIGHTBB is pressed)
		BNE END_RIGHT_PB_2        ; then
		MOV R0,#100             ;    delay_1ms(100) for debounce
		BL DELAY_1MS      
		LDR R5,[R4,#PIO_PDSR]   ;    if(RIGHTPB is pressed)
		TST R5,#RIGHT_PB        ;    then
		SUBEQ R6,R6,R2          ;         count:= count - DEC_VALUE
END_RIGHT_PB_2                  ; end if{RIGHTPB}
		AND R6,R6,#0xFF         ; Limits to 8 bits but allows rollover (not needed)
		MOV R0,R6
		BL DISPLAY_FUNCTION     ; Display the updated count
		BL CHECK_LEFT_JOYSTICK  ; Call subroutine to update INC_VALUE
		BL CHECK_RIGHT_JOYSTICK ; Call subroutine to update DEC_VALUE
		B CNTR_2                ; endless loop for counter_2
		POP {R1,R2,R4,R5,R6,R7,R14}
		BX R14


		END