#TARGET=ulx3s_v20
TARGET=ulx3s_v316

# 12/25/45/85
FPGA_SIZE=12

TOP=usb_hid_host_demo

COM=../common
SRC=../../src

OBJS+=top.v ecp5pll.sv $(COM)/hid_printer.v $(COM)/uart_tx_V2.v $(SRC)/usb_hid_host.v $(SRC)/usb_hid_host_rom.v

all: ${TARGET}.bit

$(TOP).json: $(OBJS)
	yosys build.ys

$(TARGET)_out.config: $(TOP).json
	nextpnr-ecp5 --$(FPGA_SIZE)k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack --compress $< $@

prog: ${TARGET}.bit
	openFPGALoader -b ulx3s $(TARGET).bit

print: ${TARGET}.bit
	fujprog -t $<

clean:
	rm -f *.svf *.bit *.config *.json *~

.PHONY: prog clean
