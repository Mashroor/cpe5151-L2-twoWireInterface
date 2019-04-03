;******************************************************************************
; TWI.s - Experiment 2 - Adam Worley, Mashroor Rashid
;
; This file contains code for the Two Wire Interface functions:
; TWI_MASTER_INIT
; TWI_MASTER_WRITE
; TWI_MASTER_READ
;******************************************************************************

;********** INCLUDES **********
  INCLUDE AT91SAM7SE512.INC

;********** CONSTANT DECLARATIONS **********
; TWI_CR
START EQU (1<<0)
STOP EQU (1<<1)

; TWI_MMR BITS
MREAD_BIT EQU (1<<12)

; TWI_SR BITS
NACK_BIT EQU (1<<8)
OVRE_BIT EQU (1<<6)
TxRDY_BIT EQU (1<<2)
RxRDY_BIT EQU (1<<1)
TxCOMP_BIT EQU (1<<0)

; CLOCK CONSTANTS
; OVER EQU 0
; BAUDRATE EQU 9600
MCK EQU 47923200 ; 47.9232MHz
TWI_FREQ EQU 25000 ; 25kHz
TWI_RST EQU 1<<7
TWI_MSTR_MODE EQU ((1<<5) :OR: (1<<2))
TWI_SLAV_MODE EQU ((1<<4) :OR: (1<<3))

; CKDIV
; > ln[((MCK / (TWI_FREQ * 2)) - 4) / 255] / ln2
; > 1.904
; = 2
CKDIV EQU 2

; CxDIV
; = ((MCK / (2 * TWI_FREQ)) - 4) / (2^CKDIV)
; = 238.616 rounded to 239
CxDIV EQU 239 ; 0x00EF
CLDIV EQU (CxDIV & 0xFF) ; 0xEF
CHDIV EQU (CxDIV & 0xFF) ; 0xEF
CWGR_VAL EQU ((CKDIV<<16) :OR: (CHDIV<<8) :OR: CLDIV)

; BAUD RATE GEN RELOAD VALUE
; = MCK / (8 * BAUDRATE * (2 - OVER))
; OVER = 0
; actual value = 312
; no rounding necessary -> actual baud rate = 9600
; BRGR_VAL EQU (MCK / (8 * BAUDRATE * (2 - OVER)))

; ERROR CODES
NACK_ERROR EQU (0x10000000)
OVRE_ERROR EQU (0x20000000)

; PINS
SDA EQU (1<<3)
SCL EQU (1<<4)

;*********************************************************************
; VARIABLE DEFINITIONS
;*********************************************************************
  PRESERVE8
  AREA VARIABLES,DATA,READWRITE


;******************************************************************************
; AREA DEFINITION
;******************************************************************************

	PRESERVE8
	AREA TWIPORT,CODE,READONLY
	ARM

;******************************************************************************
; INITIALIZATION ROUTINE
; void TWI_MASTER_INIT(void)
;
; Sets up the TWI to master mode with a 25KHz clock Rate.  
;*******************************************************************************

  EXPORT TWI_MASTER_INIT

TWI_MASTER_INIT
  PUSH {R4-R5,R14}

  ; ENABLE PERIPHERAL CLOCKS PIOA AND TWI
  LDR R4,=PMC_BASE
  MOV R5,#(1<<PIOA_PID)
  ORR R5,R5,#(1<<TWI_PID)
  STR R5,[R4,#PMC_PCER]

  ; SETUP IO PINS
  LDR R4,=PIOA_BASE
  MOV R5,#SDA
  ORR R5,R5,#SCL
  STR R5,[R4,#PIO_PDR] ; DISABLE PIO
  STR R5,[R4,#PIO_ASR] ; SELECT PERIPHERAL A
  STR R5,[R4,#PIO_MDER] ; ENABLE MULTI-DRIVE
  STR R5,[R4,#PIO_PUDR] ; DIABLE PULL-UP RESISTOR

  ; RESET
  LDR R4,=TWI_BASE
  MOV R5,#TWI_RST
  STR R5,[R4,#TWI_CR]

  ; SET CLOCK
  LDR R5,=CWGR_VAL
  STR R5,[R4,#TWI_CWGR]

  ; SET MODE
  LDR R5,=TWI_MSTR_MODE ; DISABLE SLAVE MODE, ENABLE MASTER MODE
  STR R5,[R4,#TWI_CR]

  POP {R4-R5,R14}
  BX R14


;*******************************************************************************
; TRANSMIT ROUTINE	
; int TWI_WRITE (uint device_address, uint internal_address, uint int_addr_bytes,
;                uint number_of_bytes, uint * array)
; R0 = device_address
; R1 = internal_address
; R2 = int_addr_bytes
; R3 = number_of_bytes
; STACK = *array
;
; Places the device address and int_addr_bytes into the Master Mode Reg with the 
; MREAD bit cleared to '0'. The internal address is placed in the internal
; address register.  The parameter number_of_bytes indicates how many bytes
; from array will be transmitted.  An error flag is returned to indicate
;	if the slave device responds with an NACK_BIT.
;*******************************************************************************

	EXPORT TWI_MASTER_WRITE

TWI_MASTER_WRITE
  PUSH {R4-R7,R14}
  
  LDR R4,[R13,#20] ; GET *ARRAY

  ; PLACE DEV_ADDR, CLEAR MREAD, SET INT_ADDR_SZ
  LDR R5,=TWI_BASE
  MOV R0,R0,LSL#16
  ORR R0,R0,R2,LSL#8
  STR R0,[R5,#TWI_MMR]
  STR R1,[R5,#TWI_IADR]

  MOV R7,#0 ; INDEX
  MOV R6,#0 ; STATUS FLAGS

WHILE_WRITE
  TST R6,#NACK_BIT
  BNE EXIT_ERR_W ; NACK_BIT RECEIVED
  CMP R7,R3
  BHS EXIT_WW
  LDRB R6,[R4,R7]
  STRB R6,[R5,#TWI_THR]

DO_LOOP_W
  LDR R6,[R5,#TWI_SR]
  TST R6,#(TxRDY_BIT :OR: NACK_BIT)
  BEQ DO_LOOP_W
  ADD R7,R7,#1
  B WHILE_WRITE

EXIT_WW
  MOV R0,#0 ; NO ERRORS
  B DO_LOOP_CW

EXIT_ERR_W
  LDR R0,=NACK_ERROR

DO_LOOP_CW
  LDR R6,[R5,#TWI_SR]
  AND R6,R6,#1							;TST R6, #TxCOMP_BIT
  TEQ R6,#1 ; CHECK IF TxCOMP = 1		;BEQ DO_LOOP_CW
  BNE DO_LOOP_CW

	POP {R4-R7,R14}
  ; SUB SP,SP,#4 ; GO DOWN TO NEXT STACK ITEM TO "POP" *ARRAY
	BX R14


;**********************************************************************************
;	RECEIVE ROUTINE	
; int TWI_READ (uint device_address, uint internal_address, uint int_addr_bytes,
;               uint number_of_bytes, uint * array)
; R0 = device_address
; R1 = internal_address
; R2 = int_addr_bytes
; R3 = number_of_bytes
; STACK = *array
;
;	Places the device address and int_addr_bytes into the Master Mode Reg with the 
; MREAD bit set to '1'. The internal address is placed in the internal
; address register.  The parameter number_of_bytes indicates how many bytes
;	should be read from the slave device.  The transmission is started by
;	writing a '1' to the START bit.  A '1' should be written to the STOP bit 
; before the last byte is received.  If only one byte is to be received,   
; then both a '1' should be written to both START and STOP.
;**********************************************************************************

	EXPORT TWI_MASTER_READ

TWI_MASTER_READ
	PUSH {R4-R8,R14}

  ; PLACE DEV_ADDR, SET MREAD, SET INT_ADDR_SZ
  LDR R5,=TWI_BASE
  MOV R0,R0,LSL#16
  ORR R0,R0,R2,LSL#8
  ORR R0,R0,#MREAD_BIT
  STR R0,[R5,#TWI_MMR]
  STR R1,[R5,#TWI_IADR]

  LDR R4,[SP,#24] ; GET ARRAY FROM STACK
  MOV R7,#0 ; INDEX
  MOV R6,#0 ; STATUS FLAGS
  
  MOV R8,#START
  TEQ R3,#1
  BNE SEND_START ; BRANCH IF SENDING MULTIPLE BYTES
  ADD R8,R8,#STOP ; SEND STOP AND START FOR ONLY 1 BYTE

SEND_START
  STR R8,[R5,#TWI_CR] ; SEND START

WHILE_READ
  TST R6,#(NACK_BIT :OR: OVRE_BIT)
  BNE EXIT_ERR_R
  CMP R7,R3
  BHS EXIT_WR

DO_LOOP_R

  LDR R6,[R5,#TWI_SR]
  TST R6,#(NACK_BIT)
  BNE WHILE_READ
  TST R6, #RxRDY_BIT
  BEQ DO_LOOP_R
  
  LDR R1,[R5,#TWI_RHR]
  STRB R1,[R4,R7]
  ADD R7,R7,#1
  SUB R1,R3,R7
  TEQ R1,#1 ; CHECK FOR LAST BYTE
  BNE WHILE_READ
  MOV R1,#STOP
  STR R1,[R5,#TWI_CR] ; SEND STOP
  B WHILE_READ

EXIT_WR
  MOV R0,#0 ; NO ERRORS
  B DO_LOOP_CR

EXIT_ERR_R
  LDR R0,=NACK_ERROR

DO_LOOP_CR
  LDR R6,[R5,#TWI_SR]
  AND R6,R6,#TxCOMP_BIT
  TEQ R6,#TxCOMP_BIT ; CHECK IF TxCOMP = 1
  BNE DO_LOOP_CR

	POP {R4-R8,R14}
  ; SUB SP,SP,#4 ; GO DOWN TO NEXT STACK ITEM TO "POP" *ARRAY
	BX R14


	END