
import argparse
import struct
from pathlib import Path
import os

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(dest='spd_file', help="Sprite spd filename")

    # Parse and print the results
    args = parser.parse_args()
    print(args.spd_file)

    data = Path(args.spd_file).read_bytes() 

    numSprites = struct.unpack('B', data[4:5])[0] + 1

    data_list = []
    colors = []
    for i in range(numSprites):
        offs = i*64+9
        spr_data = list(struct.unpack('B'*64, data[offs:offs+64]))
        data_list += spr_data
        col = struct.unpack('B', data[8+(64*(i+1)): 8+(64*(i+1))+1])[0] & 0x0f 
        colors.append(col)

    multicol1 = struct.unpack('B', data[7:8])[0]
    multicol2 = struct.unpack('B', data[8:9])[0]

    print(f"numSprites: {numSprites}")
    print(f"multicol1: {multicol1}")
    print(f"multicol2: {multicol2}")
    print(f"colors: {colors}")
    print(f"data_list: {data_list}")
    
    basename = f"{os.path.splitext(args.spd_file)[0]}.bin"
    
    with open(basename, "wb") as f:
        f.write(bytearray(data_list))