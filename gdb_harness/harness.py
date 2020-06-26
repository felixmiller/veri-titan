import gdb

gdb.execute('file test_x86')
gdb.execute('b sub')
gdb.execute('r')

frame = gdb.selected_frame()
block = frame.block()
assert block.function is not None

start = block.start
end = block.end
arch = frame.architecture()
instructions = arch.disassemble(start, end - 1)
for instruction in instructions:
    if instruction['asm'].startswith('ret'):
        print("found end")
    # print(instruction['asm'])
# o = gdb.execute('i r', to_string=True)
# gdb.execute('ni')
# print(o)

gdb.execute('c')
gdb.execute('quit')