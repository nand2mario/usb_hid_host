## usb_hid_host - a compact USB HID host core

epsilon, 2/2024

The nand2mario design, described below, has been extended as follows:

  * The usb_hid_host core now has an interface that lets you set the keyboard LEDs. The LED bitmap will be sent to the USB device
    in a SetProtocol transaction implemented in UKP firmware.
  * To be able to implement the SetProtocol transaction, the UKP now has 5-bit opcodes, allowing for a larger instruction set.
  * The following instructions have been added:
  
| OpCode | Instruction | Effect |
|--------|-------------|--------|
| 16     | BR          | Branch when the UKP branch_request signal is set |
| 17     | OUTR0       | Byte Output the UKP OUTR0 register |
| 18     | OUTR1       | Byte Output the UKP OUTR1 register |
| 19     | OUTR2       | Byte Output the UKP OUTR2 register |

nand2mario, 8/2023

This is based on the USB-HID work in [hi631's NES core for Tang Nano 9K](https://qiita.com/hi631/items/4f263ca676e4be14b9f8)
and [UKP in FPGA pc8001](http://kwhr0.g2.xrea.com/hard/pc8001.html). Thanks to the authors.

## Design overview

This core is built to handle USB keyboards, mice and gamepads because I found no suitable options for small FPGAs like the Tang Nano series and boards with Lattice ice40/ECP5. The features of the design are,

  * A small and efficient USB host controller core capable of supporting common HID devices such as keyboards, mice and gamepads.
  * No CPU is required. The core handles all layers of the USB protocol relevant to HID devices.
  * No USB interface IC (PHY) needed. The core communciates directly through the D+/D- USB pins.
  * USB low-speed (1.5Mbps), utilizing a single 12Mhz clock. 

To make USB work is actually tricky. USB is designed to be implemented with both hardware and software. So a CPU is normally needed. The UKP and hi631's design uses a tiny microcode processor to be just able to support keyboards and a specific gamepad. This core extended the original design by adding mouse support, automatic detecting all three types of devices, and accomodating various types of gamepads (tested with 5 different gamepads).

## Get the sample projects to work 

For the Tang Nano demo project to work, follow this diagram to connect a USB-A Female connector to Tang Nano 20K.
```
    __ 
+--|  |--+
|  +--+  | 5V  ------------ VBUS of USB
|        | GND ------------ GND of USB
|        | 76    
|        | 80              
|        | 42  ------------ D- of USB
|        | 41  ------------ D+ of USB
|        | 
|        |
|        |
|        |
| .____. |
+-|HDMI|-+
  +----+
```

* **Series Resistors**: Connect a 15K resistors between D- and GND, and another between D+ and GND for impedance matching. See [Gowin USB 1.1 SoftPHY IP](https://www.gowinsemi.com/upload/database_doc/1328/document/6073e6c99b401.pdf).

The Icesugar-Pro demo project is similar. Note that D+ is pin `G3` and D- is pin `G4`. See [board pinout](https://github.com/wuxx/icesugar-pro/blob/master/doc/iCESugar-pro-pinmap.png). 

## The Microcode Processor (UKP)
* Each instruction has a 4-bit OP code, and 0-3 4-bit operands.
* 5 registers
  * PC: program counter
  * W: 8-bit register that counts the number of times of some operation (e.g. number of bits to receive)
  * C flag: A 1-bit register that indicates whether or not the device is connected
  * T counter: 3-bit counter for USB timing
  * Timer: 14-bit counter making 1ms (12000 clk cycles)
* Our improved UKP instruction set. The `save` instruction is newly added.

| OpCode | Instruction | Effect |
|--------|-------------|------|
| 0      | NOP         | No operation |
| 1      | LDI cc      | Load 8-bit constant into W |
| 2      | START       | Wait until D- becomes 0 and clear the T counter |
| 3      | OUT4        | Output 4 bits |
| 4      | OUT0        | Output 0 on both D+ and D- |
| 5      | HIZ         | Set both D+ and D- to hi-impedance |
| 6      | OUTB        | Output a byte (8 bits) |
| 7      | RET         | Return to the next instruction of last jump |
| 8      | BZ aa       | Jump if D- is 0 |
| 9      | BC aa	     | Jump if C flag is 1 |
| A      | BNAK aa	   | Jump if previous response was NAK/STALL |
| B      | DJNZ aa	   | Decrement W register, jump if not 0 |
| C f f  | TOGGLE      | Toggle C flag |
| C r b  | SAVE r b    | Save receive buffer byte b into output register r  |
| D      | IN          | Wait until the T counter reaches the sampling timing. If both D+ and D- are 0, proceed to the next instruction. Otherwise, decrement the W register and if it is 0, go to the next instruction. |
| E      | WAIT	       | Wait for 1ms timing |
| F      | JMP aa      | Jump to address |

Output Registers: 0 (VID_L), 1 (VID_H), 2 (PID_L), 3 (PID_H), 4 (INTERFACE_CLASS), 5 (INTERFACE_SUBCLASS), 6 (INTERFACE_PROTOCOL)

## Interpreting USB HID reports

All HID events are transmitted in messages, *HID reports* in USB terminology. For our `usb_hid_host` module, the `typ` output indicates the device type, and when it is not zero, a pulse in the `report` output signifies the arrival of a HID report.

## Keyboard

USB keyboards transmits *scancodes* instead of ASCII codes. Therefore the `key1`, `key2`, `key3` and `key4` represents scancodes of the currently pressed keys. The `key_modifiers` output indicates the status of modifier keys like shift, ctrl, etc. If you need to convert the scancodes to ASCII, a simple method is demonstrated in the demo project (which supports up to 2 simultaneously pressed keys and lacks auto-repeat functionality). 

If you prefer to do the conversion on your own, you can find scancodes in the "keyboard/Keypad Page" sector of the HID Usage Tables. See [scancode](https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2)

### Mouse

Mouse reports consists of button states and delta movements in the X and Y directions (`mouse_dx` and `mouse_dy`). To convert this information into an on-screen mouse position, the demo project provides an example implementation.

### Gamepad

Gamepads reports are more straightforward, as they represent the status of the buttons directly. Currently, only 10 buttons are exposed, but it should be straightforward to add more if they are present in the HID report.

## References

* [OSDev Wiki: USB Human Interface Devices](https://wiki.osdev.org/USB_Human_Interface_Devices)
* [USB Made Simple](https://www.usbmadesimple.co.uk/)
* [USB in a Nutshell](https://www.beyondlogic.org/usbnutshell/usb1.shtml)
* [Understanding HID report descriptors](http://who-t.blogspot.com/2018/12/understanding-hid-report-descriptors.html)

