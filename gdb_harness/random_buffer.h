#include <stdint.h>
#include <stdio.h> 
#include <stdlib.h>

// srand(1234);

uint32_t* random_buffer(size_t size) {
	uint8_t* buffer = malloc(size * 4);
	for(size_t i = 0; i < size * 4; i++) {
		buffer[i] = rand() % 256;
	}
    return (uint32_t*) buffer; 
}