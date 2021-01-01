import json
from typing import Dict
import re

def get_segment(line: str) -> str:
    r = re.compile('_SEG_(.*?)_START_')
    m = r.search(line)
    if m:
        return m.group(1), "start"
   
    r = re.compile('_SEG_(.*?)_END_')
    m = r.search(line)
    if m:
        return m.group(1), "end"
    
    raise ValueError(f"Incorrect Segment: {line}")

def get_address(line: str) -> str:
    return line[0:4]
    
def int_to_hex(nr):
  h = format(int(nr), 'x')
  return '0' + h if len(h) % 2 else h

def get_offsets(part_path: str) -> Dict:
    
    offsets = {}
    
    with open(part_path, "r") as f:
        labels = f.readlines()
        for label in labels:
            if label.__contains__('_SEG_'):
                segment, pos = get_segment(label)
                address = get_address(label)
                
                if segment not in offsets:
                    offsets[segment] = {}
                
                if pos == "start":
                    offsets[segment]["start"] = int(f"0x{address}", 0)
                else:
                    offsets[segment]["end"] = int(f"0x{address}", 0)
                    offsets[segment]["size"] = offsets[segment]["end"] - offsets[segment]["start"]

    return offsets

def gen_sls(desc: Dict, offsets: Dict) -> str:
    
    script  = f"ID:\t{desc['demo']['id']}\n"
    script += f"Name:\t{desc['demo']['name']}\n"
    script += f"Start:\t{'{0:04x}'.format(desc['sequencer']['segment'])}\n"
    script += f"DirArt:\t{desc['demo']['dir_art']}\n"
    
    for i, interleave in enumerate(desc['demo']['interleaves']):  
        script += f"IL{i}:\t0{interleave}\n"
        
    script += f"ZP:\t{desc['demo']['zp']}\n"
    script += f"Loop:\t{desc['demo']['loop']}\n\n"
   
    if 'script' in desc['sequencer']:
        path = desc['sequencer']['script'].replace('/', '\\')
        script += f"Script:\t{path}\n\n"
        
    parts_order = parts_desc['sequencer']["order"]
    
    for part_name in parts_order:
        if 'align' in parts_desc[part_name] and parts_desc[part_name]['align'] is True:
            script += "Align\n"
        for data in parts_desc[part_name]['data']:
            path = data['path'].replace('/', '\\')
            address = '{0:04x}'.format(data['address'])
            if "size" in data:
                offset = '{0:04x}'.format(data['offset'])
                size = '{0:04x}'.format(data['size'])                      
                script += f"File:\t{path}\t{address}\t{offset}\t{size}\n"
            else:
                script += f"File:\t{path}\t{address}\n"
                
        part_offset = offsets[part_name]
        prg_path = parts_desc[part_name]['path'].replace('/', '\\')
        prg = f"{prg_path}.prg"
        for segment, params in part_offset.items():
            address = '{0:04x}'.format(params['start'])
            delta =  params['start'] - parts_desc[part_name]['seg_init'] + 2
            offset = '{0:04x}'.format(delta)
            size = '{0:04x}'.format(params['size'])
            
            script += f"File:\t{prg}\t{address}\t{offset}\t{size}\n"          
        
        script += "\n"
        
    return script

if __name__ == "__main__":

    demo_offsets = {}
    sls_params = {}
        
    with open("parts.json", "r") as f:
        parts_desc = json.load(f)
        
    parts_order = parts_desc['sequencer']["order"]
    
    # extract offsets from part's labels
    for part_name in parts_order:
        offsets = get_offsets(f"{parts_desc[part_name]['path']}.labels")
        demo_offsets[part_name] = offsets
    
    # save offsets in a json file    
    with open('offsets.json', 'w') as f:
        json.dump(demo_offsets, f, indent=4, sort_keys=False)
    
    # set sls params
    script = gen_sls(parts_desc, demo_offsets)
    with open('demo.sls', 'w') as f:
        f.write(script)
    
    
   