;*************************************************************************************
;*  TWI_example.s
;*		Routines for initializing the Two Wire Interface, transmitting an array of bytes
;*		and receiving an array of bytes.
;*		
;*		CpE312 Experiment #2, Spring 2014
;*************************************************************************************
;*		Version 1.0												Roger Younger
;*************************************************************************************
;*		
;*	CONSTANT DECLARATIONS

			INCLUDE AT91SAM7SE512.INC

BRGR_VAL 	EQU		0				; calculated by student
	
NACK_Error	EQU   1				; defined by student
OVRE_Error	EQU   0				; Not used


;******************************************************************************
;*	AREA DEFINITION
								 
			PRESERVE8
			AREA TWIPORT,CODE,READONLY
			ARM

;******************************************************************************
;*	INITIALIZATION ROUTINE			void TWI_MASTER_INIT(void)
;*		Sets up the TWI to master mode with a 25KHz clock Rate.  
;*******************************************************************************


			EXPORT TWI_MASTER_INIT

TWI_MASTER_INIT
			PUSH {R4-R7,R14}
TWIPORTPINS	EQU	0x18							; set bits 3 and 4 to 1. for TWD(SDA) and TWCK(SCL)
            
			;Enable Peripheral Clocks
			LDR R4,=PMC_BASE
			MOV R5, #((1<<PIOA_PID):OR:(1<<9))	;R5=0x204. to set clock for TWI and PIOA
			STR R5, [R4, #PMC_PCER]				;Enables PIOA Clock, TWI Clock
			
			;set up the I/O Pins
			LDR R4,=PIOA_BASE
			MOV R5, #TWIPORTPINS
			STR R5,[R4,#PIO_PDR]			; Disable Parallel I/O, enables peripheral control
			STR R5,[R4,#PIO_ASR]			; Select the A peripheral
			STR R5,[R4,#PIO_MDER]			; Enable Multi-Drive
			STR R5,[R4,#PIO_PUDR]			; Disable Pull up resistor
			
			LDR R4,=TWI_BASE				;reset the TWI
			MOV R5, #(1<<7)
			STR R5,[R4, #TWI_CR]
			
			;Set up Master Mode, disable Slave
TWIMASTERPINS	EQU	(1<<5) :OR: (1<<2)		; set bits 5 and 2 to 1, for master mode of TWI device
	
			MOV R5, #TWIMASTERPINS			; Move into R5
			STR R5,[R4,#TWI_CR]				; Store 1s for bit 5 and 2 into CR
			
			;Set the TWI Clock To a frequency of 50kHz or Less
CKDIV	EQU	1
CHDIV	EQU	0xEE
CLDIV	EQU	0xEE
	
CWGR_VALUE	EQU	((CKDIV<<16)+(CHDIV<<8)+(CLDIV))
			LDR R5, =CWGR_VALUE
			STR R5,[R4, #TWI_CWGR]

			POP {R4-R7,R14}
			BX R14

;*******************************************************************************
;*	TRANSMIT ROUTINE	
;*      int TWI_WRITE (uint device_address, uint internal_address, uint int_addr_bytes,
;*                      uint number_of_bytes, uint * array)
;*
;*		Places the device address and int_addr_bytes into the Master Mode Reg with the 
;*      MREAD bit cleared to '0'. The internal address is placed in the internal
;*      address register.  The parameter number_of_bytes indicates how many bytes
;*		from array will be transmitted.  An error flag is returned to indicate
;*		if the slave device responds with an NACK.
;*******************************************************************************


			EXPORT TWI_MASTER_WRITE
TWI_MASTER_WRITE

			PUSH {R4-R9,R14}
			
wTXCOMP_bit	EQU	1<<0
wNACK_bit	EQU	1<<8
wTXRDY_bit	EQU	1<<2
wSTOP_bit	EQU 1<<1

			;retrieve send array pointer form stack
			LDR R4,[SP, #20]
			
			MOV R0, R0, LSL#16			;device address
			ORR R0, R0, R2, LSL #8		;internal addr
			LDR R5,=TWI_BASE
			STR R0,[R5, #TWI_MMR]
			;store internal address value
			STR R1,[R5,#TWI_IADR]
			
			MOV R7, #0		; R7 index
			MOV R6, #0		; intitialize status reg val, NACK to 0
WHILE_WRITE
			TST R6, #wNACK_bit	; Check error first
			BNE EXIT_ERR_W		; return a NACK_Error
			CMP R7, R3			; R3 is the number of bytes
			BHS EXIT_WW			; assumes send array is of unsigned bytes
			LDRB R6,[R4,R7]		;R4 is a send-array pointer, R6 is to be sent
			STR R6,[R5,#TWI_THR]		;Store byte value as word to 32bit register
DO_LOOP_W
			LDR R6,[R5,#TWI_SR]
			TST R6,#(wTXRDY_bit :OR: wNACK_bit)
			BEQ DO_LOOP_W
			ADD R7, R7, #1
			B WHILE_WRITE
			
EXIT_ERR_W
			LDR R0,=NACK_Error
			B DO_LOOP_C
EXIT_WW
			MOV R0, #0			; No errors

DO_LOOP_C
			LDR R6,[R5, #TWI_SR]	;re use R6 to hold status register values
			TST R6,#wTXCOMP_bit
			BEQ DO_LOOP_C
			
			POP {R4-R9,R14}
			BX R14

;**********************************************************************************
;*	RECEIVE ROUTINE	
;*      int TWI_READ (uint device_address, uint internal_address, uint int_addr_bytes,
;*                      uint number_of_bytes, uint * array)
;*
;*		Places the device address and int_addr_bytes into the Master Mode Reg with the 
;*      MREAD bit set to '1'. The internal address is placed in the internal
;*      address register.  The parameter number_of_bytes indicates how many bytes
;*		should be read from the slave device.  The transmission is started by
;*		writing a '1' to the START bit.  A '1' should be written to the STOP bit 
;*      before the last byte is received.  If only one byte is to be received,   
;*      then both a '1' should be written to both START and STOP.
;**********************************************************************************


			EXPORT TWI_MASTER_READ
TWI_MASTER_READ
			PUSH {R4-R9,R14}

rMREAD_bit	EQU	1<<12
rTXCOMP_bit	EQU	1<<0
rNACK_bit	EQU	1<<8
rRXRDY_bit	EQU	1<<1
rSTOP_bit	EQU 1<<1
	
			LDR R4,[SP, #24]		; retreive from stack, last parameter
			
			MOV R0, R0, LSL#16		; device address
			ORR R0, R0, R2,LSL#8	; R2, internal address size
			ORR R0, R0, #rMREAD_bit
			
			LDR R5,=TWI_BASE
			STR R0,[R5, #TWI_MMR]
			;Store the internal address value
			STR R1,[R5,#TWI_IADR]
			
			MOV R9, #0x01			; Start bit set here
			TEQ R3, #1				; if reading only 1 bit,
			BNE END_LOOP
			ORR R9, R9, #0x04			; set both start and stop bits
END_LOOP
			STR R9,[R5, #TWI_CR]	; send to CR
			
			MOV R7, #0				; R7 is an index. initialize
			MOV R6, #0				; initializes status value to 0. NACK.
WHILE_READ
			TST R6, #rNACK_bit		;check error first
			BNE EXIT_ERR_R			;Return NACK_ERROR
			CMP R7, R3				; R3 is number of bytes(x4, word)
			BHS EXIT_WR				; Assume read_array is array of words
DO_LOOP_R
			LDR R6,[R5, #TWI_SR]	; reuse R6 to hold status register value
			TST R6,#rNACK_bit		; causes an exit of DO_LOOP_R
			BNE WHILE_READ			; to exit to EXIT_ERR_R
			TST R6,#(rRXRDY_bit)
			BEQ DO_LOOP_R			;While  transmit ready AND nack == 0
			
			LDR R1,[R5, #TWI_RHR]
			STRB R1,[R4,R7]
			ADD R7, R7, #1			; Stored as a word, increment by 4.
			SUB R1, R3, R7			; check if 1 byte is left
			TEQ R1, #1
			BNE WHILE_READ			; continue while
			MOV R1, #rSTOP_bit		; if this is last byte, do following
			STR R1, [R5, #TWI_CR]	; send NACK and STOP condition
			B WHILE_READ
			
EXIT_ERR_R
			LDR R0,=NACK_Error
			B CHECK_TXCOMP_R
			;Error return values left up to student
EXIT_WR
			MOV R0, #0x00				; return the value  
			; loop for checking TXCOMP is left to student
CHECK_TXCOMP_R
			LDR R6,[R5, #TWI_SR]
			TST R6, #rTXCOMP_bit
			BEQ CHECK_TXCOMP_R
			
			POP {R4-R9,R14}
			BX R14

;**********************************************************************************
;*	C TO F CONVERSION ROUTINE	
;*      float C_TO_F_CONV (float celsiusVal);
;*
;**********************************************************************************

			EXPORT C_TO_F_CONV
C_TO_F_CONV
			PUSH {R4-R9,R14}
CtoF_MUL	EQU	461
			
			LDR R1,=CtoF_MUL
			MUL R2, R0, R1
			MOV R0, R2, ASR#8
			ADD R0, R0, #8192
			
			POP {R4-R9,R14}
			BX R14

			END