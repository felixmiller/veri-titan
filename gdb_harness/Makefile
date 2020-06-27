test-x86: test.c random_buffer.h
	gcc -m32 test.c random_buffer.h -g -o test_x86

harness:
	gdb -q -x harness.py

.PHONY: harness