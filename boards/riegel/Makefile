TARGET=usb_hid_host_demo
TOP=usb_hid_host_demo

COM=../common
SRC=../../src

OBJS+=top.v clock.v $(COM)/hid_printer.v $(COM)/uart_tx_V2.v $(SRC)/usb_hid_host.v $(SRC)/usb_hid_host_rom.v

all: ${TARGET}.bin

$(TARGET).json: $(OBJS)
	yosys build.ys

$(TARGET).asc: $(TARGET).json
	nextpnr-ice40 --hx4k --package bg121 --json $< --asc $@ --pcf $(TARGET).pcf

$(TARGET).bin: $(TARGET).asc
	icepack $< $@

prog:
	ldprog -s $(TARGET).bin

clean:
	rm -f *.bin *.config *.asc *.json

.PHONY: prog clean
