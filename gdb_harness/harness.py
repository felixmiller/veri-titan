import gdb
gdb.execute('file a.out')
gdb.execute('b add', to_string=True)
gdb.execute('r', to_string=True)
o = gdb.execute('i r', to_string=True)
print(o)

gdb.execute('quit')
gdb.execute('y')