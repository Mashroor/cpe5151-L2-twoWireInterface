#ifndef _TWI_EXAMPLE_H
#define _TWI_EXAMPLE_H



void TWI_MASTER_INIT(void);
unsigned int TWI_MASTER_WRITE(unsigned int device_address, unsigned int internal_address, unsigned int int_addr_bytes,unsigned int number_of_bytes, unsigned char * array);
unsigned int TWI_MASTER_READ(unsigned int device_address, unsigned int internal_address, unsigned int int_addr_bytes,unsigned int number_of_bytes, unsigned char * array);
int C_TO_F_CONV(int celsiusVal);

#endif

