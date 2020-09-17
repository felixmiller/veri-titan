from bv_exprs import *

class BinOpEq:
    def __init__(self, op, dst, src_1, src_2):
        self.op = op
        self.dst = dst
        self.src_1 = src_1
        self.src_2 = src_2
    
    def __str__(self):
        if self.op == "&":
            return f"{self.dst} = {self.src_1} & {self.src_2}"
        raise Exception("NYI")

    # def encode():
    #     print("bv_and(x', y', n) == pow2(n) * bv_and(b0, b1, 1) + bv_and(x, y, n - 1)")

class UniOpEq:
    def __init__(self, op, dst, src):
        self.op = op
        self.dst = dst
        self.src = src

    def __str__(self):
        if self.op == "":
            return f"{self.dst} = {self.src}"
        raise Exception("NYI")

class Encoder:
    def __init__(self, q):
        self.tmp_count = 0
        self.bin_count = 0
        self.nbits_vars = set()
        # self.opaque_vars = dict()
        # self.gpass = False
        self.equations = set()

        self.flatten_br(q)
        for eq in self.equations:
            print(eq)

        # for var in self.nbits_vars:
        #     print(var)
        #     print(var + "'")

    def flatten_br(self, q):
        assert type(q) == z3.z3.BoolRef
        assert q.decl().name() == "="
        children = q.children()
        l = self.flatten_bvr(children[0])
        r = self.flatten_bvr(children[1])
        return UniOpEq("", l, r)

    def flatten_bvr(self, e):
        if type(e) == z3.z3.BitVecRef:
            children = [self.flatten_bvr(child) for child in e.children()]
            num_children = len(children)

            if num_children == 0:
                var = str(e.decl())
                self.nbits_vars.add(var)
                return var

            op = str(e.decl())
            v = self.get_fresh_tmp()

            if op == "&":
                [l, r] = children
                eq = BinOpEq(op, v, l, r)
                self.equations.add(eq)
                # print(eq)
                return v
            else:
                raise Exception(f"op {op} not handled")
        elif type(e) == z3.z3.BitVecNumRef:
            return str(e)
        raise Exception("not handled")

    def get_fresh_tmp(self):
        self.tmp_count += 1
        t = "t%d" % self.tmp_count
        self.nbits_vars.add(t)
        return t

    def get_fresh_bin(self):
        self.bin_count += 1
        b = "b%d" % self.bin_count
        # eq = f"{b} * (1 - {b})"
        return b

    # def encode_br(self, q):
    #     children = q.children()
    #     l = self.encode_bvr(children[0])
    #     r = self.encode_bvr(children[1])
    #     eq = l + " - " + r
    #     if self.gpass:
    #         return eq
    #     else:
    #         self.equations.add(eq)

    # def encode_bvr(self, e):
    #     if type(e) == z3.z3.BitVecRef:
    #         children = [self.encode_bvr(child) for child in e.children()]
    #         num_children = len(children)

    #         if num_children == 0:
    #             v = str(e.decl())
    #             if self.gpass:
    #                 return v + "'"
    #             else:
    #                 self.add_input_var(v)
    #                 return v
    #         op = str(e.decl())
    #         var = self.get_fresh_tmp()

    #         if op == "&":
    #             self.encode_and(var, children[0], children[1])
    #             return var
    #         if op == "^":
    #             self.encode_xor(var, children[0], children[1])
    #             return var
    #         else:
    #             raise Exception(f"op {op} not handled")
    #     elif type(e) == z3.z3.BitVecNumRef:
    #         return str(e)
    #     else:
    #         raise Exception("not handled")

    # def encode_and(self, t, l, r):
    #     if self.gpass:
    #         o0 = self.get_opaque(f"bv_and({l}, {r}, n)")
    #         eq = f"{t} - {o0}"
    #         print(f"[DEBUG] adding {t} = bv_and({l}, {r}, n)")
    #         self.equations.add(eq)
    #     else:
    #         o0 = self.get_opaque(f"bv_and({l}, {r}, n - 1)")
    #         print(f"[DEBUG] adding {t} = bv_and({l}, {r}, n - 1)")
    #         eq = f"{t} - {o0}"
    #         self.equations.add(eq)

    #         bl = self.get_assoc_bin(l)
    #         br = self.get_assoc_bin(r)
    #         b = self.get_fresh_bin()
    #         eq = f"{b} - {bl} * {br}"
    #         self.equations.add(eq)

    #         o1 = self.get_opaque(f"bv_and({l}', {r}', n)")
    #         eq = f"{o1} - pow2_n * {b} - {o0}"
    #         print(f"[DEBUG] adding bv_and({l}', {r}', n) = pow2_n * {b} ＋ bv_and({l}, {r}, n)")
    #         self.equations.add(eq)

    # def encode_xor(self, t, l, r):
    #     if self.gpass:
    #         o0 = self.get_opaque(f"bv_xor({l}, {r}, n)")
    #         eq = f"{t} - {o0}"
    #         self.equations.add(eq)
    #     else:
    #         # -b + bl + br - 2 * bl * br == 0
    #         o0 = self.get_opaque(f"bv_xor({l}, {r}, n - 1)")
    #         eq = f"{t} - {o0}"
    #         self.equations.add(eq)

    #         bl = self.get_assoc_bin(l)
    #         br = self.get_assoc_bin(r)
    #         b = self.get_fresh_bin()
    #         eq = f"{bl} + {br} - 2 * {bl} * {br} - {b}"
    #         self.equations.add(eq)

    #         o1 = self.get_opaque(f"bv_xor({l}', {r}', n)")
    #         eq = f"{o1} - pow2_n * {b} - {o0}"
    #         self.equations.add(eq)

    # def add_input_var(self, v):
    #     if v not in self.nbits_vars:
    #         b = self.get_fresh_bin()
    #         self.nbits_vars[v] = b
    #         eq = f"{v}' - pow2_n_1 * {b} - {v}"
    #         self.equations.add(eq)

    # def get_opaque(self, actual):
    #     if actual in self.opaque_vars:
    #         return self.opaque_vars[actual]
    #     o = "o%d" % (len(self.opaque_vars) + 1) 
    #     # print(f"[DEBUG] allocating {o} = {actual}")
    #     self.opaque_vars[actual] = o
    #     return o

    # def get_assoc_bin(self, v):
    #     if v not in self.nbits_vars:
    #         raise Exception("not an nbits var")
    #     return self.nbits_vars[v]

    # def dump_vars(self):
    #     vars = ["pow2_n_1", "pow2_n"]
    #     for v in self.nbits_vars:
    #         vars.append(f"{v}, {v}'")
    #     for i in range(self.bin_count):
    #         vars.append(f"b{i + 1}")
    #     for o in self.opaque_vars.values():
    #         vars.append(o)
    #     print("ring r=integer,(" + ", ".join(vars) + "),lp;")

q = bvand_nested()
enc = Encoder(q)

# print("")
# dump_vars()