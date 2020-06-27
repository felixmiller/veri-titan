import sys

trace_file = open(sys.argv[1])
values = dict()
target_regs = set(["eax", "ebx", "ecx", "esi", "edi"])
pc_reg = "eip"

line = "place_holder"
while line != "":
    state, pc_val = list(), 0

    while line != "\n":
        line = trace_file.readline()
        items = line.split()[:2]

        if len(items) == 2:
            [reg, val] = items
            if reg == pc_reg:
                pc_val = val
            elif reg in target_regs and val != "0x0":
                state.append((reg, int(val, 16)))

    for (reg, val) in state:
        if val not in values:
            values[val]=list()
        values[val].append((pc_val, reg))
    line = trace_file.readline()

trace_file.close()

for k, v in values.items():
	print(k)
	print(v)