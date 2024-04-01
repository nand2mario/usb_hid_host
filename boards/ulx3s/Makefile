#TARGET=ulx3s_v20
TARGET=ulx3s_v316

# 12/25/45/85
FPGA_SIZE=12

TOP=usb_hid_host_demo

COM=../common
SRC=../../src

# for ecpbram ROMDEPTH must be first larger divisible by 512
ROMDEPTH=$(shell wc -l $(SRC)/usb_hid_host_rom.hex | cut -f -1 -d ' ')
ROMDEPTH512=$(shell expr \( $(ROMDEPTH) / 512 + 1 \) \* 512)

OBJS+=top.v ecp5pll.sv $(COM)/hid_printer.v $(COM)/uart_tx_V2.v $(SRC)/usb_hid_host.v $(SRC)/usb_hid_host_rom_random.v $(SRC)/usb_hid_host_rom_random.hex

all: ${TARGET}.bit

$(SRC)/usb_hid_host_rom.v $(SRC)/usb_hid_host_rom.hex: $(SRC)/usb_hid_host/ukp.s
	cd $(SRC)/usb_hid_host; perl asukp

$(SRC)/usb_hid_host_rom_random.hex $(SRC)/usb_hid_host_rom_random.v:
	cd $(SRC)/usb_hid_host; perl asukp
	sed	-e "s/usb_hid_host_rom.hex/usb_hid_host_rom_random.hex/g" \
		-e "s/mem \[$(ROMDEPTH)\]/mem \[$(ROMDEPTH512)\]/g" \
		$(SRC)/usb_hid_host_rom.v > $(SRC)/usb_hid_host_rom_random.v
	ecpbram --width 4 --depth $(ROMDEPTH512) --seed 0 --generate $(SRC)/usb_hid_host_rom_random.hex

$(TOP).json: $(OBJS)
	yosys build.ys

$(TARGET)_empty.config: $(TOP).json
	nextpnr-ecp5 --$(FPGA_SIZE)k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET)_out.config: $(TARGET)_empty.config $(SRC)/usb_hid_host_rom_random.hex $(SRC)/usb_hid_host_rom.hex
	ecpbram --verbose --input $(TARGET)_empty.config --from $(SRC)/usb_hid_host_rom_random.hex --to $(SRC)/usb_hid_host_rom.hex --output $@

$(TARGET).bit: $(TARGET)_out.config
	ecppack --compress $< $@

prog: ${TARGET}.bit
	openFPGALoader -b ulx3s $(TARGET).bit

run: ${TARGET}.bit
	fujprog -t $<

clean:
	rm -f *.svf *.bit *.config *.json $(SRC)/*.hex *~ 

.PHONY: prog clean
