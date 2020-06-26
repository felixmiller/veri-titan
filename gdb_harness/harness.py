import gdb

gdb.execute('file test_x86')
gdb.execute('b sub')
gdb.execute('r')

frame = gdb.selected_frame()
block = frame.block()
assert block.function is not None

output_file = open("trace", "w+")
start, end = block.start, block.end
arch = frame.architecture()
end_addr = end - 1

instruction = arch.disassemble(end - 1)[0]

if not instruction['asm'].startswith('ret'):
    instructions = arch.disassemble(start, end - 1)
    for instruction in instructions:
        if instruction['asm'].startswith('ret'):
            end_addr = instruction['addr']


while gdb.parse_and_eval("$pc") != end_addr:
    gdb.execute('ni', to_string=True)
    o = gdb.execute('i r', to_string=True)
    output_file.write(o + "\n")
output_file.close()

gdb.execute('c')
gdb.execute('quit')