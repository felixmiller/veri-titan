import sys

tace_file = open(sys.argv[1])

for line in tace_file:
    if line == "\n":
        print("new state")

tace_file.close()