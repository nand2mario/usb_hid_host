TARGET=usb_hid_host_demo

COM=../common
SRC=../../src

OBJS+=top.v clock.v $(COM)/hid_printer.v $(COM)/uart_tx_V2.v $(SRC)/usb_hid_host.v $(SRC)/usb_hid_host_rom.v

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys build.ys

$(TARGET)_out.config: $(TARGET).json
	nextpnr-ecp5 --85k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf ulx3s_v20.lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack --compress --freq 62.0 --input $< --bit $@
	ecppack $< --compress --freq 62.0 --svf-rowsize 800000 --svf ${TARGET}.svf

${TARGET}.svf: ${TARGET}.bit

prog: ${TARGET}.svf
	icesprog $(TARGET).bit

clean:
	rm -f *.svf *.bit *.config *.json

.PHONY: prog clean

