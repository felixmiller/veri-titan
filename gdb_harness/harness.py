import gdb
gdb.execute('file /bin/cat')
o = gdb.execute('disassemble exit', to_string=True)
print(o)
gdb.execute('quit')