#!/usr/bin/env python3

# This is python implementation of the asukp.pl script.
# It is used to convert the UKP assembly code `ukp.s` into `../usb_hid_host_rom.hex`
# It also generates a listing file `ukp.lst`

import sys
import shutil
import os

BRAM = True

instructions = {
    "nop": 0,    "ldi": 1,   "start": 2, "out4": 3,
    "out0": 4,   "hiz": 5,   "outb": 6,  "ret": 7,
    "bz": 8,     "bc": 9,    "bnak": 10, "djnz": 11,
    "toggle": 12, "save": 12, "in": 13,   "wait": 14, "jmp": 15
}

def format_instruction(code, operands=None):
    """Format instruction bytes for listing"""
    if code == 12:  # toggle/save
        if operands and len(operands) == 2:
            return f"{code:01x} {int(operands[0]):01x} {int(operands[1]):01x}"
        return f"{code:01x} {15:01x} {15:01x}"
    elif code in [1, 3, 6]:  # ldi/out4/outb with immediate
        value = int(operands[0], 16) if operands[0].startswith("0x") else int(operands[0])
        return f"{code:01x} {value & 0x0F:01x} {(value >> 4) & 0x0F:01x}"
    elif code in [8, 9, 10, 11, 15]:  # jumps
        addr = operands[0] if operands else 0
        if code == 15:  # jmp
            return f"{code:01x} {addr & 0x0F:01x} {(addr >> 4) & 0x0F:01x} {(addr >> 8) & 0x0F:01x}"
        return f"{code:01x} {addr & 0x0F:01x} {(addr >> 4) & 0x0F:01x}"
    return f"{code:01x}"

def main():
    labels = {}
    pc = 0
    source_lines = []  # Store source lines for listing

    # First pass to calculate labels
    with open("ukp.s") as f:
        for line in f:
            source_lines.append(line.rstrip())
            line = line.split(';')[0].strip()
            if not line:
                continue
            
            if ':' in line:
                label = line.split(':')[0].strip()
                if label in labels:
                    sys.stderr.write(f"{line} already defined\n")
                    sys.exit(1)
                pc = (pc + 3) & ~3  # Align to 4-byte boundary
                labels[label] = pc
                print(f"pc={pc:03x}\t{label}")
            else:
                tokens = line.split()
                if not tokens:
                    continue
                
                opcode = tokens[0]
                if opcode not in instructions:
                    sys.stderr.write(f"syntax error: {line}\n")
                    sys.exit(1)
                
                code = instructions[opcode]
                if code == 15:  # jmp
                    pc += 4
                elif code in [1, 3, 6, 8, 9, 10, 11, 12]:  # instructions with operands
                    pc += 3
                else:
                    pc += 1

    # Second pass to generate code and listing
    rom = []
    pc = 0
    listing = []

    with open("ukp.lst", "w") as lst_file:
        lst_file.write("Address  Code    Source\n")
        lst_file.write("-" * 50 + "\n")
        
        for i, line in enumerate(source_lines):
            orig_line = line
            line = line.split(';')[0].strip()
            comment = orig_line.split(';')[1] if ';' in orig_line else ""
            
            if ':' in line:
                label = line.split(':')[0].strip()
                # Align PC and add padding
                if pc % 4 == 1:
                    lst_file.write(f"{pc:04x}    {'0 0 0':8}\n")
                    rom.append(0)
                    rom.append(0)
                    rom.append(0)
                elif pc % 4 == 2:
                    lst_file.write(f"{pc:04x}    {'0 0':8}\n")
                    rom.append(0)
                    rom.append(0)
                elif pc % 4 == 3:
                    lst_file.write(f"{pc:04x}    {'0':8}\n")
                    rom.append(0)

                pc = (pc + 3) & ~3
                lst_file.write(f"{pc:04x}    {'  ':8}  {orig_line:<30} {comment}\n")
                continue
            
            tokens = line.split()
            if not tokens:
                lst_file.write(f"{'  ':8}  {'  ':8}  {orig_line:<30}\n")
                continue
            
            opcode = tokens[0]
            code = instructions[opcode]
            rom.append(code)
            pc_start = pc
            
            # Format instruction bytes for listing
            if code == 12:  # toggle/save
                if opcode == "toggle":
                    bytes_str = format_instruction(code)
                    rom.extend([15, 15])
                    pc += 3
                else:  # save
                    if len(tokens) != 3:
                        sys.stderr.write(f"Malformed instruction: {line}\n")
                        sys.exit(1)
                    bytes_str = format_instruction(code, tokens[1:])
                    rom.append(int(tokens[1]))
                    rom.append(int(tokens[2]))
                    pc += 3
            
            elif code in [1, 3, 6]:  # ldi/out4/outb with immediate
                bytes_str = format_instruction(code, tokens[1:])
                value = int(tokens[1], 16) if tokens[1].startswith("0x") else int(tokens[1])
                rom.append(value & 0x0F)
                rom.append((value >> 4) & 0x0F)
                pc += 3
            
            elif code in [8, 9, 10, 11, 15]:  # jumps
                label = tokens[1]
                address = labels[label] >> 2
                bytes_str = format_instruction(code, [address])
                rom.append(address & 0x0F)
                rom.append((address >> 4) & 0x0F)
                if code == 15:  # jmp
                    rom.append((address >> 8) & 0x0F)
                    pc += 4
                else:
                    pc += 3
            else:
                bytes_str = format_instruction(code)
                pc += 1

            lst_file.write(f"{pc_start:04x}    {bytes_str:8}  {orig_line:<30}\n")

    # Generate output files
    if BRAM:
        write_bram_module(rom)
        write_hex_file(rom)
    else:
        write_case_module(rom)

    # Move files to parent directory
    if os.path.exists("../usb_hid_host_rom.v"):
        os.remove("../usb_hid_host_rom.v")
    shutil.move("./usb_hid_host_rom.v", "../")
    if BRAM:
        if os.path.exists("../usb_hid_host_rom.hex"):
            os.remove("../usb_hid_host_rom.hex")
        shutil.move("./usb_hid_host_rom.hex", "../")

def write_bram_module(rom):
    with open("usb_hid_host_rom.v", "w") as f:
        f.write(f"""module usb_hid_host_rom(clk, adr, data);
    input clk;
    input [13:0] adr;
    output [3:0] data;
    reg [3:0] data; 
    reg [3:0] mem [0:{len(rom)-1}];
    initial $readmemh("usb_hid_host_rom.hex", mem);
    always @(posedge clk) data <= mem[adr];
endmodule
""")

def write_hex_file(rom):
    with open("usb_hid_host_rom.hex", "w") as f:
        for value in rom:
            f.write(f"{value:01x}\n")

def write_case_module(rom):
    with open("usb_hid_host_rom.v", "w") as f:
        f.write("""module usb_hid_host_rom(clk, adr, data);
    input clk;
    input [13:0] adr;
    output [3:0] data;
    reg [3:0] data; 
    always @(posedge clk) begin
        case (adr)
""")
        for i, value in enumerate(rom):
            f.write(f"            10'h{i:03x}: data = 4'h{value:x};\n")
        f.write("""            default: data = 4'hX;
        endcase
    end
endmodule
""")

if __name__ == "__main__":
    main() 