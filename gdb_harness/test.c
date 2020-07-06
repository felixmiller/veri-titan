#include <stdint.h>
#include "random_buffer.h"

// void add(uint32_t *a, uint32_t *b, uint32_t len) {
//     int64_t A = 0;
//     int i;
//     for (i = 0; i < len; ++i) {
//         A += (uint64_t)a[i] - b[i];
//         a[i] = (uint32_t)A;
//         A >>= 32;
//     }
// }

void buffer_fill(uint8_t *a, uint8_t v, uint32_t len) {
    uint32_t i = 0;

    while (i < len) {
        a[i] = v;
        i = i + 1;
    }
}

int main() {
    uint32_t len = 0;
    uint8_t *a =  malloc(len);
    buffer_fill(a, 42, len);
    free(a);

    // size_t words = 4;
	// uint32_t* a = random_buffer(words);
	// uint32_t* b = random_buffer(words);
	// add(a, b, words);
    // free(a);
    // free(b);
}