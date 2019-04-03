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
* NAME: Adam Worley ,Mashroor Rashid
*****************************************************************************/
                  
#include <AT91SAM7SE512.H>              /* AT91SAM7SE512 definitions          */
#include "AT91SAM7SE-EK.h"           /* AT91SAM7SE-EK board definitions    */
#include "Exp1_solution.h"
#include "USART0_solution.h"
#include "TWI.h"
#include "temp.h"
#include "Input_Integer.h"
#include <stdio.h>

const unsigned char DECIMAL_PLACES = 3; // number of decimal places to be printed

// converts an FPN into an NTCS
//void FPN_to_STR(unsigned char *output_ntcs, unsigned char *input_fpn);
 
/*
 * Main Program
 */

int main (void)
{
  const unsigned int DS75_DEV_ADDR = 0x48;
  const unsigned int EEPROM_DEV_ADDR = 0x50;

	unsigned char bound_check = 1;
	unsigned int input;
	unsigned int temp;
  unsigned long main_index = 0;
	unsigned char index;
	float temp_float;
  unsigned char array[64];

  // Initialization Area
  POWERLED_INIT();
  USER_LEDS_INIT();
  SWITCH_INIT();
  EXT_LEDS_INIT();
	USART0_INIT();
	TWI_MASTER_INIT();
	PA11_INIT();
	
	array[0] = 0x60;
	
	TWI_MASTER_WRITE(DS75_DEV_ADDR,0x01,1,1,array); // 12 bit temp resolution
	
	printf("\n\r");
  //printf("Press any key to begin.\n\r");
	//input = USART0_Receive();
	
  TWI_MASTER_READ(EEPROM_DEV_ADDR,0x0100,2,64,array);

	printf("Board Serial #: 0642 004\n\rEEPROM Address: 0x0100\n\rMessage: ");
	
	for(index = 0; index < 64; index++)
  {
    USART0_Transmit(array[index]);
  }
	printf("\n\r");
	TWI_MASTER_READ(DS75_DEV_ADDR,0x01,1,1,array);
	printf("DS75 Config Reg: 0x%x\n\r",array[0]);

  printf("\n\rDisplaying temperatures, press \";\" to pause.\n\r");
			
  for (;;)
  {
		if(main_index == 1567295)
    {
      main_index = 0;
			
			// get temperature
      TWI_MASTER_READ(DS75_DEV_ADDR,0x00,1,2,array);
			
			temp_float = (float)array[0] + (((float)array[1]) / 256);
			printf("%6.3f",temp_float);
			printf(" Celsius || ");
			
			temp = CEL_TO_FAR(array[0],array[1]);
			array[1] = temp & 0xFF;
			array[0] = (temp >> 8) & 0xFF;
			
			temp_float = (float)array[0] + (((float)array[1]) / 256);
			printf("%6.3f",temp_float);
			printf(" Farenheit\n\r");
    }
		
		input = USART0_Receive_Check();
		
		if(input == ';')
		{
			//TWI_MASTER_READ(DS75_DEV_ADDR,0x03,1,2,array);
			//printf("\n\rCurrent temp bounds: %u C - ",array[0]);
				
			//TWI_MASTER_READ(DS75_DEV_ADDR,0x02,1,2,array);
			//printf("%u C\n\r",array[0]);
			
			printf("Please enter an upper temp bound in Celsius.\n\r");
			input = Input_Integer();
			
			array[1] = 0;
			array[0] = input;
			
			TWI_MASTER_WRITE(DS75_DEV_ADDR,0x03,1,2,array);
			
			while(bound_check)
			{
				printf("Please enter a lower temp bound in Celsius.\n\r");
				temp = Input_Integer();
			
				if(temp < input)
				{
					array[1] = 0;
					array[0] = temp;
			
					TWI_MASTER_WRITE(DS75_DEV_ADDR,0x02,1,2,array);
					
					bound_check = 0;
				}
			
				else
					printf("Lower bound must be lower than upper bound.\n\r");
			}
			
			printf("Resuming temperature display...\n\r\n\r");
			
			bound_check = 1;
		}
		
		PA11_DISPLAY();
		
   	main_index++;
  }
}
