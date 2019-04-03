#ifndef EXAMPLE_ASSEMBLY_H
#define EXAMPLE_ASSEMBLY_H


/*----------------------*/
/* Constant Definitions */
/*----------------------*/



//   Function Prototypes
 
void POWERLED_INIT(void); 
void USER_LEDS_INIT(void); 
void SWITCH_INIT(void); 
void EXT_LEDS_INIT(void); 
void DELAY_1MS(unsigned int a);
void POWERLED_CONTROL(unsigned int a);
void LED1_CONTROL(unsigned int a);
void LED2_CONTROL(unsigned int a);
void BLINKY(void);
void COUNTER_1(void);
void COUNTER_2(void);
void DISPLAY_FUNCTION(unsigned int a);
unsigned int CHECK_LEFT_JOYSTICK(unsigned int a); 
unsigned int CHECK_RIGHT_JOYSTICK(unsigned int a); 

#endif


