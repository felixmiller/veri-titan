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

    function method lh64(x: uint64) : (r: uint32)

 	function method uh64(x: uint64) : (r: uint32)

 	lemma split64_lemma(x: uint64)
 	 	ensures uh64(x) as int * (UINT32_MAX as int + 1) + lh64(x) as int == x as int;
 	 	ensures lh64(x) as int == x as int % (UINT32_MAX as int + 1);

    method add(a: array<uint32>, b: array<uint32>, len: uint32)
        requires a != b;
        requires a.Length == b.Length == len as int;
        modifies a;
    {
        var i: uint32 := 0;
        var A: uint64 := 0;

        while i < len
            decreases len as int - i as int;
        {
            assume A == 0 || A == 1;
            A := a[i] as uint64 + b[i] as uint64 + A;
            a[i] := lh64(A);
            A := uh64(A) as uint64;
            i := i + 1;
        }
    }

}