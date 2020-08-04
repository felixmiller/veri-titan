num_bits = 32
BASE = 2 ** num_bits

def print_bin(num):
    print(bin(num)[2:].zfill(num_bits * 2))

def d0inv(w28):
    w0 = 2
    w29 = 1

    for i in range(1, num_bits):

        # start asserts
        x = w29 * w28
        q = x // 2 ** i

        if q % 2 == 0:        
            assert(w29 * w28 % 2 ** i == 1)
            # ==> 
            assert(x % 2 ** (i + 1) == 1)
        else:
            assert(w29 * w28 % 2 ** i == 1)
            # ==>
            assert((x + w28 * 2 ** i) % 2 ** (i + 1) == 1)
        # end asserts

        w1 = (w28 * w29) % BASE
        w1 = w1 & w0
        w29 = w29 | w1
        w0 = w0 * 2
        assert((w29 * w28) % w0 == 1)

    assert((w29 * w28) % BASE == 1)

d0inv(2109612375)