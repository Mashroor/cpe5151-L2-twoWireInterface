/******************************************************************************
* Experiment1_solution.C                                                    
******************************************************************************
* This program provides a start point to call assembly functions.            
* The functions are defined in the source code as extern for easier editing.               
* Instead, the programmer may wish to use a header file to define the functions.        
* The examples are intended to show how assembly functions are defined and        
* and called as well as how parameters are passed and values returned.  
******************************************************************************/
/*****************************************************************************
* NAME: Solution by Roger Younger
*****************************************************************************/
                  
#include <AT91SAM7SE512.H>              /* AT91SAM7SE512 definitions          */
#include "AT91SAM7SE-EK.h"           /* AT91SAM7SE-EK board definitions    */
#include "Exp1_solution.h"





 
/*
 * Main Program
 */

int main (void) {
	
  // Initialization Area
  POWERLED_INIT(); 
  USER_LEDS_INIT(); 
  SWITCH_INIT(); 
  EXT_LEDS_INIT();
	//BLINKY();
	//COUNTER_1();
	COUNTER_2();


  
  for (;;) {
		// Endless Loop
		
   		
  }
}
