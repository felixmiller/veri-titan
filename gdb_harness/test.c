#include <stdint.h>

void sub(uint32_t *a, uint32_t *b, uint32_t len) {
    int64_t A = 0;
    int i;
    for (i = 0; i < len; ++i) {
        A += (uint64_t)a[i] - b[i];
        a[i] = (uint32_t)A;
        A >>= 32;
    }
}

int main() {
	uint32_t a[3] = {0xfa, 0xbb, 0xcf};
	uint32_t b[3] = {0xad, 0xb1, 0xac};
	sub(a, b, 3);
}