module test {
 	newtype{:nativeType "sbyte"} int8 = i:int | -0x80 <= i < 0x80
 	newtype{:nativeType "byte"} uint8 = i:int | 0 <= i < 0x100
 	newtype{:nativeType "short"} int16 = i:int | -0x8000 <= i < 0x8000
 	newtype{:nativeType "ushort"} uint16 = i:int | 0 <= i < 0x10000
 	newtype{:nativeType "int"} int32 = i:int | -0x80000000 <= i < 0x80000000
 	newtype{:nativeType "uint"} uint32 = i:int | 0 <= i < 0x100000000
 	newtype{:nativeType "long"} int64 = i:int | -0x8000000000000000 <= i < 0x8000000000000000
 	newtype{:nativeType "ulong"} uint64 = i:int | 0 <= i < 0x10000000000000000

 	const UINT32_MAX :uint32 := 0xffffffff;
    const BASE :int := UINT32_MAX as int + 1;

    function method lh64(x: uint64) : (r: uint32)

 	function method uh64(x: uint64) : (r: uint32)

 	lemma split64_lemma(x: uint64)
 	 	ensures uh64(x) as int * BASE + lh64(x) as int == x as int;
 	 	ensures lh64(x) as int == x as int % BASE;

    function method {:opaque} power(b:nat, e:nat) : nat
        decreases e;
        ensures b > 0 ==> power(b, e) > 0;
        ensures b == 0 && e != 0 ==> power(b, e) == 0;
    {
        if (e == 0) then 1
        else b * power(b, e - 1)
    }

    function bignum(a: array<uint32>, n: nat) : nat
        reads a;
        decreases n;
        requires 0 <= n <= a.Length;
    {
        if n == 0 then 0
        else a[n - 1] as nat * power(BASE, n - 1) + bignum(a, n - 1)
    }

    lemma uint32_add_lemma(a: uint32, b: uint32, A: uint64)
        requires A <= 1;
        ensures uh64(a as uint64 + b as uint64 + A) <= 1;
    {
        var A' := a as int + b as int + A as int;
        assert A' <= 0x1ffffffff;
        assume false;
    }

    method buffer_fill(a: array<uint8>, v: uint8, len: uint32)
        requires a.Length == len as int;
        modifies a;
        ensures forall j :: j < len ==> a[j] == v;
    {
        var i: uint32 := 0;
        while i < len 
            decreases len as int - i as int;
            invariant 0 <= i <= len;
            invariant forall j :: j < i ==> a[j] == v;
        {
            a[i] := v;
            i := i + 1;
        }
    }

    // method add(a: array<uint32>, b: array<uint32>, len: uint32)
    //     requires a != b;
    //     requires a.Length == b.Length == len as int > 10;
    //     modifies a;
    // {
    //     var i: uint32 := 0;
    //     var A: uint64 := 0;

    //     while i < len
    //         decreases len as int - i as int;
    //         invariant 0 <= i <= len;
    //         invariant A <= 1;
    //     {
    //         assume bignum(a, i as int) + A as nat * power(BASE, i as int) 
    //             == bignum(old(a), i  as int) + bignum(b, i as int);

    //         uint32_add_lemma(a[i], b[i], A);
    //         assume a[i] == old(a[i]);
    //         ghost var old_A := A as int;

    //         A := a[i] as uint64 + b[i] as uint64 + A;
    //         a[i] := lh64(A);
    //         A := uh64(A) as uint64;
    
    //         calc == {
    //             bignum(a, i as int + 1);
    //             bignum(a, i as int) + a[i] as int * power(BASE, i as int);
    //             bignum(a, i as int) + (old(a[i]) as int + b[i] as int + old_A) * power(BASE, i as int);
    //         }
    
    //         i := i + 1;
    //     }
    // }
}