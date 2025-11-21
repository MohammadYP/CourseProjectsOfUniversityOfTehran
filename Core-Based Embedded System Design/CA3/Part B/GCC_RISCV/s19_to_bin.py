import sys

input_file = sys.argv[1]
output_file = sys.argv[2]

if (sys.argv[1] != ""):
    output_file = sys.argv[2]
else:
    output_file = sys.argv[1] + ".out.txt"

s19 = ""

# read 4 lines at once
# split the data
# use the first address 
# concatinate the first address with all four data 
# use use little-endian convention

with open(input_file, "r") as f:
    s19 = f.read()

def hex_to_bin(hex, scale=16, zero_fill=8):
    # Code to convert hex to binary
    res = bin(int(hex, scale)).zfill(zero_fill)
    return res 

def parse_line(line, hex=True):
    s_type = int(line[1])
    # byte_count = hex_to_bin(line[2:3])
    byte_count = int(line[2:4], 16)
    
    # print("byte_count", byte_count)
    address = ""
    data = ""
    data_count = 0
    if s_type == 1: # 16 bit address
        if hex:
            address = line[4:(4 + 2*2)]
        else:
            address = hex_to_bin(line[4:(4 + 2*2)], 16)
        data_count = byte_count - 3
    elif s_type == 2: # 24 bit address
        if hex:
            address = line[4:(4 + 2*3)]
        else:
            address = hex_to_bin(line[4:(4 + 2*3)], 24)
        data_count = byte_count - 4
    elif s_type == 3: # 32 bit address
        if hex:
            address = line[4:(4 + 2*4)]
        else:
            address = hex_to_bin(line[4:(4 + 2*4)], 32)
        data_count = byte_count - 5
    else: # ignore all other types
        address = ""
    

    if (address): # ignore all other types
        data = line[-(data_count+3):-2]
    # print("Data", data)
    return [address, data]

i = 0
mem = dict()
mem_file = ""
data = ""
address = ""
for line in s19.splitlines():
    partial_address, partial_data = parse_line(line)
    # set endianess to little-endian
    data = partial_data + data 
    # make sure output exists
    if (partial_address) and (partial_data):
        if ((int(partial_address, 16) % 4) == 0):
            address = partial_address

        if ((int(partial_address, 16) % 4) == 3):
            address = address.zfill(8)
            mem.update({address: f'{address}_{data}'})
            mem_file += f'{address}_{data}' + "\n"
            data = ""

with open(output_file, "w") as f:
    f.write(mem_file)