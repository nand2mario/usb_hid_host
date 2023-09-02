TARGET=usb_hid_host_demo
TOP=usb_hid_host_demo

COM=../common
SRC=../../src

OBJS+=top.v clock.v uart_tx_V2.v $(SRC)/usb_hid_host.v $(SRC)/usb_hid_host_rom.v

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys build.ys

$(TARGET)_out.config: $(TARGET).json
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack --svf ${TARGET}.svf $< $@

${TARGET}.svf: ${TARGET}.bit

prog: ${TARGET}.svf
	icesprog $(TARGET).bit

clean:
	rm -f *.svf *.bit *.config *.ys *.json

.PHONY: prog clean
