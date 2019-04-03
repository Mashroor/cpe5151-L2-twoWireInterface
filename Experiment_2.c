/******************************************************************************
* Experiment1_2.C                                                    
******************************************************************************
* This program provides a start point to call assembly functions.            
* The functions are defined in the source code as extern for easier editing.               
* Instead, the programmer may wish to use a header file to define the functions.        
* The examples are intended to show how assembly functions are defined and        
* and called as well as how parameters are passed and values returned.  
******************************************************************************/
/*****************************************************************************
* NAME: Mashroor Rashid
*****************************************************************************/
                  
#include <AT91SAM7SE512.H>              /* AT91SAM7SE512 definitions          */
#include "AT91SAM7SE-EK.h"           /* AT91SAM7SE-EK board definitions    */
#include "Exp1_solution.h"
#include "USART0_solution.h"
#include "TWI_example.h"
#include "Input_Integer.h"
#include <stdio.h>



 
/*
 * Main Program
 */

int main (void) {
//	unsigned int error_flag;
	unsigned int deviceAddr = 0x48;
	unsigned int DS75TempAddr = 0x00;
	unsigned int DS75ConfigAddr = 0x01;
	unsigned int input;
	unsigned char * array;
	array[0] = 0x11;
  // Initialization Area 
  POWERLED_INIT(); 
  USER_LEDS_INIT(); 
  SWITCH_INIT(); 
  EXT_LEDS_INIT();
	USART0_INIT();
	TWI_MASTER_INIT();
	TWI_MASTER_WRITE(deviceAddr, DS75ConfigAddr, 1, 2, array);

	/* Test functions for USART0 that can be edited or removed */
//  printf("Press any key to continue....\n\r");
//	input=USART0_Receive();
//	printf("The entered char was: \n\r");
//	USART0_Transmit(input);
//	USART0_Transmit(CR);
//	USART0_Transmit(LF);

  
  for (;;) {
		// Endless Loop\

		TWI_MASTER_READ(deviceAddr, DS75TempAddr, 1, 1, array);
//		if(TWI_MASTER_READ(deviceAddr, DSinterAddr, 1, 1, array) == 0x00){
			printf("Temperature in Celsius: %d C\n\r", array[0]);
//		}else{
//			printf("ERROR: NACK Error \n\r");
//		}
		DELAY_1MS(200);

  }
}
