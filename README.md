# Usb_hid_host - a compact USB HID host FPGA core

nand2mario, 8/2023

This is a compact Verilog-based FPGA core designed to support USB keyboards, mice and gamepads. It is designed mainly for FPGA retro gaming and computing projects. The most significant advantage is its all-in-one design. It does not require a CPU to work. And it is quite small (<300 LUTs, <250 registers and 1 BRAM block).

To use usb_hid_host, simply add `usb_hid_host.v`, `usb_hid_host_rom.v` and `usb_hid_host_rom.hex` to your project. The module interface in `usb_hid_host.v` should be sufficiently documented to get you started.

Please refer to [usb_hid_host.md](doc/usb_hid_host.md) for a more comprehensive introduction to the design of the core.

## Sample project

There is currently a sample project that works on Sipeed Tang Nano 20K. Just open `usb_hid_proj.gprj` in Gowin IDE. Connect your USB devices and expect something like the following.

<img src='doc/usb_hid_host_demo.png' width=450> <img src='doc/usb_hid_host_setup.jpg' width=380>

## Future Improvements

* Support more boards (icesugar pro, arty a7/s7...)
* More than one device on a port (USB hubs).
* Full-speed devices.
* Testing more types of devices.

## Credit

* Based on [hi631's work](https://github.com/hi631/tang-nano-9K/tree/master/NES) supporting USB gamepad on Tang Nano 9K.
