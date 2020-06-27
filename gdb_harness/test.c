#include <stdint.h>
#include "random_buffer.h"

void add(uint32_t *a, uint32_t *b, uint32_t len) {
    int64_t A = 0;
    int i;
    for (i = 0; i < len; ++i) {
        A += (uint64_t)a[i] - b[i];
        a[i] = (uint32_t)A;
        A >>= 32;
    }
}

int main() {
    size_t words = 4;
	uint32_t* a = random_buffer(words);
	uint32_t* b = random_buffer(words);

	add(a, b, words);

    free(a);
    free(b);
}