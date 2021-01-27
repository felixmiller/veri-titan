include "NativeTypes.dfy"
include "BitVector.dfy"
include "../lib/powers.dfy"
include "../lib/congruences.dfy"

module barret384 {
    import opened NativeTypes
    import opened powers
    import opened congruences
    import opened CutomBitVector

    method mul_384_384_768(a: cbv384, b: cbv384) returns (c: cbv768)
        ensures to_nat(c) == to_nat(a) * to_nat(b);
    {
        assume false;
    }

    lemma trivial(a: nat, b: nat)
        requires a * b < b;
        ensures a == 0;
    {
    }

    lemma trivial2(a: nat, b: nat, c: nat)
        requires a < b;
        requires c != 0;
        ensures a / c <= b / c;
    {
        var q1 := a / c;
        var r1 := a % c;

        var q2 := b / c;
        var r2 := b % c;

        if q1 > q2 {
            assert q1 * c == a - r1;
            assert q2 * c == b - r2;

            assert q1 * c - q2 * c == a - b + r2 - r1;
            assert 0 <= r2 - r1 < c;
            assert q1 * c - q2 * c < a - b + c < c;
            calc ==> {
                q1 * c - q2 * c < c;
                (q1 - q2) * c < c;
                {
                    trivial(q1 - q2, c);
                }
                q1 == q2;
            }
            assert false;
        }

        assert q1 <= q2;
    }

    lemma trivial3(a: nat, b: nat, c: nat)
        requires a * b < c;
        requires b != 0;
        ensures a <= c / b;
    {
        trivial2(a * b, c, b);
        assert (a * b) / b <= c / b;
        assume a * b / b == a;
        assert a <= c / b;
    }

    lemma trivial4(a: nat, b: nat, c: nat)
        requires a * b < c;
        requires b != 0;
        requires c % b == 0;
        ensures a < c / b;
    {
        if a >= c / b {
            calc ==> {
                a >= c / b;
                a * b >= (c / b) * b;
                {
                    assert (c / b) * b == c;
                }
                a * b >= c;
                false;
            }
            assert false;
        }
        assert a < c / b;
    }

    lemma trivial5(a: nat, b: nat)
        requires b != 0;
        ensures (a / b) * b <= a;
    {
        
    }

    /*
    * @param[in] [w9, w8]: a, first operand, max. length 384 bit.
    * @param[in] [w11, w10]: b, second operand, max. length 384 bit.
    * @param[in] [w13, w12]: m, modulus, max. length 384 bit, 2^384 > m > 2^383.
    * @param[in] [w15, w14]: u, pre-computed Barrett constant (without u[384]/MSb
    *                           of u which is always 1 for the allowed range but
    *                           has to be set to 0 here).
    * @param[in] w31: all-zero.
    */
    method barret384(
        a: cbv384,
        b: cbv384,
        m: cbv384,
        u: cbv384,
        ghost gm: nat,
        ghost uf: nat)
        requires gm == to_nat(m) != 0;
        requires to_nat(a) <= gm - 1;
        requires to_nat(b) <= gm - 1;
        requires uf == to_nat(u) + pow2(384) == pow2(768) / gm;
    {
        var x: cbv768 := mul_384_384_768(a, b);
        var t: cbv384 := zero(384);
        var r1: cbv := slice(x, 0, 512);

        var xmsb := msb(x);

        if xmsb == 1 {
        	t := u;
        }

        // q1: 385 := x >> 383;
        // q1 == q1_r + (2 ** 384) * msb
        var q1: cbv385 := rshift(x, 383);

        assert msb(q1) == xmsb;

        assert to_nat(q1) == to_nat(x) / pow2(383) by {
            rshift_is_div_lemma(x, 383, q1);
        }

        // q2': 768 := mul_384_384_768(q1[384:0], u);
        var q1': cbv384 := slice(q1, 0, 384);

        assert to_nat(q1) == to_nat(q1') + pow2(384) * xmsb by {
            to_nat_msb_lemma(q1, 385);
        }

        var q2': cbv768 := mul_384_384_768(q1', u);

        assert to_nat(q2') == to_nat(q1') * to_nat(u);

        // q2'': 384 := q2' >> 384;
        var q2'': cbv384 := rshift(q2', 384);

        assert to_nat(q2'') == to_nat(q2') / pow2(384) by {
            rshift_is_div_lemma(q2', 384, q2'');
        }

        // q2''': 385 := q2'' + q1;
        var (q2''', cout1) := add(zext(q2'', 385), q1, 0);

        assert to_nat(q2''') + cout1 * pow2(385) == to_nat(q2'') + to_nat(q1);

        var (q2'''', cout2) := add(q2''', zext(t, 385), 0);

        assert to_nat(q2'''') + cout2 * pow2(385) == to_nat(q2''') + to_nat(t);

        calc <= {
            to_nat(q2'''') * pow2(384) + cout1 * pow2(769) + cout2 * pow2(769);
            {
                assume pow2(385) * pow2(384) == pow2(769);
                assume false;
            }
            (to_nat(q2'''') + cout1 * pow2(385) + cout2 * pow2(385)) * pow2(384);
            calc == {
                to_nat(q2'''') + cout1 * pow2(385) + cout2 * pow2(385);
                to_nat(q2'') + to_nat(q1) + to_nat(t);
                to_nat(q2') / pow2(384) + to_nat(q1') + pow2(384) * xmsb + to_nat(t);
                to_nat(q2') / pow2(384) + to_nat(q1) + to_nat(t);
                (to_nat(q1') * to_nat(u)) / pow2(384) + to_nat(q1) + to_nat(t);
            }
            ((to_nat(q1') * to_nat(u)) / pow2(384) + to_nat(q1) + to_nat(t)) * pow2(384);
            (to_nat(q1') * to_nat(u)) / pow2(384) * pow2(384) + to_nat(q1) * pow2(384) + to_nat(t) * pow2(384);
            {
                trivial5((to_nat(q1') * to_nat(u)), pow2(384));
            }
            to_nat(q1') * to_nat(u) + to_nat(q1) * pow2(384) + to_nat(t) * pow2(384);
            (to_nat(q1) - pow2(384) * xmsb) * to_nat(u) + to_nat(q1) * pow2(384) + to_nat(t) * pow2(384);
            to_nat(q1) * to_nat(u) - pow2(384) * xmsb * to_nat(u) + to_nat(q1) * pow2(384) + to_nat(t) * pow2(384);
            {
                assert if xmsb == 1 then to_nat(t) == to_nat(u) else to_nat(t) == 0;
            }
            to_nat(q1) * to_nat(u) - pow2(384) * xmsb * to_nat(u) + to_nat(q1) * pow2(384) + if xmsb == 1 then to_nat(u) * pow2(384) else 0;
            to_nat(q1) * to_nat(u) + to_nat(q1) * pow2(384);
            to_nat(x) / pow2(383) * (to_nat(u) + pow2(384));
            to_nat(x) / pow2(383) * (pow2(768) / gm);
            (to_nat(a) * to_nat(b)) / pow2(383) * (pow2(768) / gm);
            {
                assert to_nat(a) <= gm - 1;
                assert to_nat(b) <= gm - 1;
                assume false;
            }
            ((gm - 1) * (gm - 1)) / pow2(383) * (pow2(768) / gm);
            {
                assume false;
            }
            pow2(769);
        }

        // calc ==> {
        //     to_nat(q2'''') * pow2(384) + cout1 * pow2(769) + cout2 * pow2(769) < pow2(769);
        //     {
        //         assert cout1 == 0 && cout2 == 0;
        //     }
        //     to_nat(q2'''') * pow2(384) < pow2(769);
        //     {
        //         assume pow2(769) % pow2(384) == 0;
        //         trivial4(to_nat(q2''''), pow2(384), pow2(769));
        //     }
        //     to_nat(q2'''') < pow2(769) / pow2(384);
        //     {
        //         assume pow2(769) / pow2(384) == pow2(385);
        //     }
        //     to_nat(q2'''') < pow2(385);
        // }

        // var q3: bv384 := q2'''' >> 1;
        // var r2: bv512 := mul_384_384_512(q3, m);
        // var r: bv512 := r1 - r2;
    }

    // lemma barrett_reduction_q3_bound(
    //     x: nat,
    //     m: nat,
    //     Q: nat,
    //     q3: nat,
    //     n: nat)

    //     requires n > 0;
    //     requires pow2(n - 1) <= m < pow2(n);
    //     requires 0 < x < pow2(2 * n);
    //     requires Q == x / m;
    //     requires q3 == ((x / pow2(n - 1)) * (pow2(2 * n) / m)) / pow2(n + 1);

    //     ensures Q - 2 <= q3 <= Q;
    // {
    //     var c0 := pow2(n - 1);
    //     var c1 := pow2(n + 1);
    //     var c2 := pow2(2 * n);

    //     var cr0 := pow2(n - 1) as real;
    //     var cr1 := pow2(n + 1) as real;
    //     var cr2 := pow2(2 * n) as real;

    //     var xr := x as real;
    //     var mr := m as real;

    //     var alpha : real := xr / cr0 - (x / c0) as real;
    //     var beta : real := cr2 / mr - (c2 / m) as real;

    //     calc <= {
    //         Q;
    //         x / m;
    //         {
    //             assume false;
    //         }
    //         (xr / mr).Floor;
    //         {
    //             calc <= {
    //                 xr / mr;
    //                 {
    //                     assume cr2 == cr0 * cr1;
    //                 }
    //                 ((xr / cr0) * (cr2 / mr)) / cr1;
    //                 (((x / c0) as real + alpha) * (cr2 / mr)) / cr1;
    //                 (((x / c0) as real + alpha) * ((c2 / m) as real + beta)) / cr1;
    //                 ((x / c0) as real * (c2 / m) as real + beta * (x / c0) as real + alpha * (c2 / m) as real + alpha * beta) / cr1;
    //                 {
    //                     assume 0.0 <= alpha < 1.0;
    //                     assume false; // should be true
    //                 }
    //                 ((x / c0) as real * (c2 / m) as real + beta * (x / c0) as real + (c2 / m) as real + beta) / cr1;
    //                 {
    //                     assume 0.0 <= beta < 1.0;
    //                     assume false; // should be true
    //                 }
    //                 ((x / c0) as real * (c2 / m) as real + (x / c0) as real + (c2 / m) as real + 1.0) / cr1;
    //                 {
    //                     assume (x / c0) as real <= cr1 - 1.0;
    //                     assume false; // unstable
    //                 }
    //                 ((x / c0) as real * (c2 / m) as real) / cr1 + (cr1 + (c2 / m) as real) / cr1;
    //                 {
    //                     assume (c2 / m) as real <= cr1;
    //                     assume false; // unstable
    //                 }
    //                 ((x / c0) as real * (c2 / m) as real) / cr1 + (cr1 + cr1) / cr1;
    //                 {
    //                     assume (cr1 + cr1) / cr1 == 2.0;
    //                 }
    //                 ((x / c0) as real * (c2 / m) as real) / cr1 + 2.0;
    //                 {
    //                     assert (x / c0) as real * (c2 / m) as real == ((x / c0) * (c2 / m)) as real;
    //                     assume false; // unstable
    //                 }
    //                 (((x / c0) * (c2 / m)) as real) / cr1 + 2.0;
    //             }
    //             assert xr / mr <= (((x / c0) * (c2 / m)) as real) / cr1 + 2.0;
    //         }
    //         ((((x / c0) * (c2 / m)) as real) / cr1 + 2.0).Floor;
    //         ((((x / c0) * (c2 / m)) as real) / cr1).Floor + 2.0.Floor;
    //         ((((x / c0) * (c2 / m)) as real) / cr1).Floor + 2;
    //         {
    //             assume (x / c0) * (c2 / m) != 0;
    //             floor_div_lemma((x / c0) * (c2 / m), c1);
    //         }
    //         ((x / c0) * (c2 / m)) / c1 + 2;
    //     }

    //     assert Q - 2 <= ((x / c0) * (c2 / m)) / c1;
    //     assume q3 <= Q;
    // }

    // method barrett_reduction(
    //     x: nat,
    //     m: nat,
    //     ghost Q: nat,
    //     ghost R: nat,
    //     q3: nat,
    //     n: nat)

    //     returns (r: int)

    //     requires n > 0;
    //     requires pow2(n - 1) <= m < pow2(n);
    //     requires 0 < x < pow2(2 * n);

    //     requires Q == x / m;
    //     requires R == x % m;
    //     requires Q - 2 <= q3 <= Q;

    //     ensures r == R;
    // {
    //     var c1 := pow2(n + 2);

    //     var r1 := x % c1;
    //     var r2 := (q3 * m) % c1;
    //     r := r1 as int - r2 as int;

    //     assert 0 - c1 as int < r < c1 as int;

    //     assert r % c1 == (Q - q3) * m + R by {
    //         calc == {
    //             r % c1;
    //             ((x % c1) - (q3 * m) % c1) % c1;
    //             {
    //                 assume false;
    //             }
    //             (x - q3 * m) % c1;
    //             {
    //                 assert x == Q * m + R;
    //             }
    //             ((Q - q3) * m + R) % c1;
    //             {
    //                 var t := (Q - q3) * m + R;
    //                 assume 0 <= t < 3 * m;
    //                 assume 3 * m < c1;
    //                 remainder_unqiue_lemma(t, c1);
    //             }
    //             (Q - q3) * m + R;
    //         }
    //     }

    //     if r < 0 {
    //         var r' := r + c1;
    //         assert 0 <= r' < c1;

    //         calc == {
    //             r';
    //             {
    //                 remainder_unqiue_lemma(r', c1);
    //             }
    //             r' % c1;
    //             {
    //                 assume r' % c1 == r % c1;
    //             }
    //             r % c1;
    //             (Q - q3) * m + R;
    //         }
    //         r := r';
    //     } else {
    //         calc == {
    //             r;
    //             {
    //                 remainder_unqiue_lemma(r, c1);
    //             }
    //             r % c1;
    //             (Q - q3) * m + R;
    //         }
    //     }

    //     assert r == (Q - q3) * m + R;
    //     assert r % m == R by {
    //         mod_factor_lemma(r, Q - q3, R, m);
    //     }
    //     sanity_check(Q, R, q3, r, m);

    //     if r >= m {
    //         assert r <= 2 * m + R;
    //         r := r - m;
    //         assert r <= m + R;

    //         assert r % m == R by {
    //             mod_factor_lemma(r, Q - q3 - 1, R, m);
    //         }
    //     }

    //     if r >= m {
    //         assert r <= m + R;
    //         r := r - m;
    //         assert r <= R;
    //         assert r < m;
    //         assume cong(r, R, m);

    //         assert r % m == R by {
    //             mod_factor_lemma(r, Q - q3 - 2, R, m);
    //         }
    //     }

    //     assert r % m == R;
    //     assert 0 <= r < m;
    //     assert r == R;
    // }

    // lemma sanity_check(Q: nat, R: nat, q3: nat, r: nat, m: nat)
    //     requires r == (Q - q3) * m + R;
    //     requires Q - 2 <= q3 <= Q;
    //     ensures R <= r <= 2 * m + R;
    // {
    //     // assert 0 <= Q - q3 <= 2;
    // }

    // lemma mod_factor_lemma(r: nat, k: int, R: nat, m: nat)
    //     requires r == k * m + R;
    //     requires m != 0;
    //     ensures r % m == R;
    // {
    //     assume false;
    // }

    // lemma remainder_unqiue_lemma(r: nat, m: nat)
    //     requires 0 <= r < m;
    //     ensures r % m == r;
    // {
    //     assert true;
    // }

    // lemma floor_div_lemma(x: nat, y: nat)
    //     requires 0 < x && 0 < y;
    //     ensures  x / y == (x as real / y as real).Floor;
    // {
    //     assume false;
    // }

    // lemma div_bound_lemma(x: nat, y: nat)
    //     requires 0 < x && 0 < y;
    //     // requires rq == (x as real) / (y as real);
    //     ensures (x as real) / (y as real) - 1.0 < (x / y) as real <= (x as real) / (y as real);
    // {
    //     var rq :real := (x as real) / (y as real);
    //     var q := x / y;

    //     var r := x % y;
    //     assert x == y * q + r;
    //     assert y * q == x - r;

    //     var f := r as real / y as real;
    //     assert f < 1.0;
    
    //     calc == {
    //         q as real;
    //         (x as real - r as real) / y as real;
    //         rq - r as real / y as real;
    //         rq - f;
    //     }

    //     assert q as real <= rq;
    //     assert q as real > rq - 1.0;
    // }
}