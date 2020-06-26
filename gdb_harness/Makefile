test-x86: test.c
	gcc -m32 test.c -g -o test_x86

harness:
	gdb -q -x harness.py

.PHONY: harness