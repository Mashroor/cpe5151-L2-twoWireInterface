;******************************************************************************
; TEMP.s - Experiment 2 - Adam Worley, Mashroor Rashid
;
; This file contains code for the temperature and DS75 functions:
; CEL_TO_FAR
; PA11_INIT
; PA11_DISPLAY
;******************************************************************************

;********** INCLUDES **********
  INCLUDE AT91SAM7SE512.INC

;******************************************************************************
; AREA DEFINITION
;******************************************************************************

  PRESERVE8
  AREA TEMPCON,CODE,READONLY
  ARM

;******************************************************************************
; CELSIUS TO FARENHEIT CONVERSION FUNCTION
; unsigned int CEL_TO_FAR(unsigned char integer, unsigned char fraction);
;
; Converts the given temperature from Celsius to Farenheit.  Uses fixed point
; numbers.
;******************************************************************************

  EXPORT CEL_TO_FAR

CEL_TO_FAR
  PUSH {R1,R2,R14}

  MOV R0,R0,LSL#8
  ADD R0,R1,R0
  MOV R2,#460 ; supposed to be #461, but can't be repped by 0-255 & a rotation
  ADD R2,R2,#1
  MUL R0,R2,R0
  MOV R0,R0,LSR#8
  ADD R0,R0,#8192
  ADD R0,R0,#32 ; ADD 32 TO ROUND TO THE THOUSANDTHS DIGIT

  POP {R1,R2,R14}
  BX R14

;******************************************************************************
; PA11 INITIALIZATION FUNCTION
; void PA11_INIT(void);
;
; Converts the given temperature from Celsius to Farenheit.  Uses fixed point
; numbers.
;******************************************************************************

  EXPORT PA11_INIT

PA11_INIT
  PUSH {R4,R5,R14}
  
  LDR R4,=PMC_BASE
  MOV R5,#(1<<PIOA_PID)
  STR R5,[R4,#PMC_PCER]
  
  LDR R4,=PIOA_BASE
  MOV R5,#(1<<11)
  STR R5,[R4,#PIO_PER] ; SET PIN 11 AS INPUT
  STR R5,[R4,#PIO_ODR]
  STR R5,[R4,#PIO_PUER]
  
  POP {R4,R5,R14}
  BX R14

;******************************************************************************
; PA11 STATE DISPLAY FUNCTION
; void PA11_DISPLAY(void);
;
; Turns on the power LED if the DS75 output is low/active and vice-versa.
; Assumes both the power LED and DS75 output have been initialized.
;******************************************************************************

  EXPORT PA11_DISPLAY

PA11_DISPLAY
  PUSH {R4-R6,R14}
  
  LDR R4,=PIOA_BASE
  LDR R5,[R4,#PIO_PDSR]
  LDR R4,=PIOA_BASE
  MOV R6,#(1<<0)
  TST R5,#(1<<11)
  BNE LOW
  STR R6,[R4,#PIO_SODR] ; TURN PLED OFF
  B OUT
LOW
  STR R6,[R4,#PIO_CODR] ; TURN PLED ON
OUT
  
  POP {R4-R6,R14}
  BX R14


  END