include "NativeTypes.dfy"
include "Powers.dfy"

module d0inv {
    import opened NativeTypes
    import opened Powers

    method d0inv(w28: uint32)
        requires w28 % 2 == 1;
    {
        var w0: uint32 := 2;
        var w29 : uint32 := 1;
        var i := 1;
        
        assert (w29 * w28) % power(2, i) == 1 
            && w0 == power(2, i) by {
            reveal power();
        }

        while i < 32
            invariant 1 <= i <= 32;
            invariant (w29 * w28) % power(2, i) == 1;
            invariant i != 32 ==> w0 == power(2, i);
            decreases 32 - i;
        {
            var w1 :uint32 := (w28 * w29) % UINT32_MAX;
            w1 := (w1 as bv32 & w0 as bv32) as uint32;

            ghost var w29_old := w29;
            w29 := (w29 as bv32 | w1 as bv32) as uint32;

            if w1 == 0 {
                assume w29_old == w29;
                d0inv_bv_lemma_1(w28 * w29, i);
            } else {
                assume w1 == 1;
                assume w29 == w29_old + power(2, i);

                assert (w29 * w28) % power(2, i + 1) == 1 by {
                    ghost var x :int := w28 * w29_old;
                    d0inv_aux_lemma(w29, w29_old, w28, i);
                }
            }

            if i != 31 {
                power_2_bounded_lemma(i + 1);
            }

            w0 := if i != 31 then power(2, i + 1) else 0;
            i := i + 1;
            assert i != 32 ==> w0 == power(2, i);
        }

        assert (w29 * w28) % power(2, 32) == 1;
    }

    lemma d0inv_aux_lemma(w29: int, w29_old: int, w28: uint32, i: nat)
        requires w29 == w29_old + power(2, i);
        requires 0 <= i < 32;
        requires power(2, i) <= UINT32_MAX;
        requires (w28 * w29_old) % power(2, i) == 1;
        requires ((w28 * w29_old) % UINT32_MAX) as bv32 & power(2, i) as bv32 == 1;
        requires w28 % 2 == 1;

        ensures (w29 * w28) % power(2, i + 1) == 1;
    {
        assert w29 * w28 == w28 * w29_old + w28 * power(2, i);

        assert (w28 * w29_old + w28 * power(2, i)) % power(2, i + 1) == 1 by {
            d0inv_bv_lemma_2(w28 * w29_old, w28, i);
        }

        assert (w29 * w28) % power(2, i + 1) == 1;
    }

    lemma power_2_bounded_lemma(i: int)
        requires 0 <= i < 32;
        ensures power(2, i) <= UINT32_MAX; 

    lemma d0inv_bv_lemma_1(x: int, i: int)
        requires 0 <= i < 32;
        requires power(2, i) <= UINT32_MAX;
        requires x % power(2, i) == 1;
        requires (x % UINT32_MAX) as bv32 & power(2, i) as bv32 == 0;
        ensures x % power(2, i + 1) == 1;

    lemma d0inv_bv_lemma_2(x: int, w28: uint32, i: int)
        requires 0 <= i < 32;
        requires power(2, i) <= UINT32_MAX;
        requires x % power(2, i) == 1;
        requires (x % UINT32_MAX) as bv32 & power(2, i) as bv32 == 1;
        requires w28 % 2 == 1;
        ensures (x + w28 * power(2, i)) % power(2, i + 1) == 1;
}