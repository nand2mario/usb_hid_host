# Usb_hid_host - a compact USB HID host FPGA core

nand2mario, 8/2023

This is a small FPGA core supporting USB keyboards, mice and gamepads in Verilog. It is designed with retro gaming projects in mind. The biggest benefit is it is all-in-one and does not require a CPU to operate. And it is quite small (uses <300 LUTs, <250 registers and 1 BRAM block).

To use usb_hid_host, just pick up `usb_hid_host.v`, `usb_hid_host_rom.v` and `usb_hid_host_rom.hex`. The module interface in `usb_hid_host.v` should be documented well enough to get you started.

See [usb_hid_host.md](doc/usb_hid_host.md) if you are interested in the design details of the core.

## Sample project

The sample project works on Sipeed Tang Nano 20K. Just open `usb_hid_proj.gprj` in Gowin IDE. Connect your USB devices and expect something like the following.

<img src='doc/usb_hid_host_demo.png' width=450> <img src='doc/usb_hid_host_setup.jpg' width=380>


## Future Improvements

The following are potential improvements to be done,
* More than one device on a port (USB hubs).
* Full-speed devices.
* Testing more types of devices.

