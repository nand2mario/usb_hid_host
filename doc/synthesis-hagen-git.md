# 2024-08-09 Synthesis message fixing

Toolchain version: Gowin_V1.9.10_x64

## First synthesis run messages

```text
WARN  (EX3786) : Assignment to input 'uart_tx'("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":24)
WARN  (EX3073) : Port 'clkoutp' remains unconnected for this instance("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":37)
WARN  (EX3791) : Expression size 4 truncated to fit in target size 1("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":247)
WARN  (EX3791) : Expression size 15 truncated to fit in target size 14("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":290)
WARN  (EX3791) : Expression size 15 truncated to fit in target size 14("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":298)
WARN  (EX3791) : Expression size 4 truncated to fit in target size 3("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":308)
WARN  (EX3791) : Expression size 4 truncated to fit in target size 3("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":326)
WARN  (EX3791) : Expression size 8 truncated to fit in target size 7("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":333)
WARN  (EX3791) : Expression size 4 truncated to fit in target size 3("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":336)
WARN  (EX3791) : Expression size 15 truncated to fit in target size 14("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":346)
WARN  (EX3791) : Expression size 25 truncated to fit in target size 24("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":355)
WARN  (EX3791) : Expression size 5 truncated to fit in target size 4("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":141)
WARN  (EX3791) : Expression size 24 truncated to fit in target size 23("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":18)
WARN  (EX3791) : Expression size 10 truncated to fit in target size 9("D:\Repo\github\usb_hid_host\boards\common\uart_tx_V2.v":49)
WARN  (EX3791) : Expression size 9 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\print.vh":111)
WARN  (EX3791) : Expression size 11 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":30)
WARN  (EX3791) : Expression size 11 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":31)
WARN  (EX3791) : Expression size 21 truncated to fit in target size 20("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":53)
WARN  (EX3791) : Expression size 32 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\utils.vh":7)
WARN  (EX3791) : Expression size 32 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\utils.vh":9)
WARN  (EX2565) : Input 'reset' on this instance is undriven. Assigning to 0, simulation mismatch possible. Please assign the input or remove the declaration("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":37)
NOTE  (EX0101) : Current top module is "usb_hid_host_demo"
WARN  (EX0206) : Instance "rpll_inst" 's parameter "DEVICE" value invalid("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\nano20k\gowin_pll_usb.v":32)
WARN  (EX0211) : The output port "UART_TXD" of module "usb_hid_host_demo" has no driver, assigning undriven bits to Z, simulation mismatch possible("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":13)
WARN  (CV0016) : Input s1 is unused("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":9)
WARN  (CV0016) : Input UART_RXD is unused("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":12)
WARN  (PA1003) : Invalid parameterized value 'GW2AR-18'(DEVICE) specified for instance 'pll_usb/rpll_inst'
WARN  (TA1117) : Can't calculate clocks' relationship between: "clk" and "clk_usb"
WARN  (PR1014) : Generic routing resource will be used to clock signal 'sys_clk_d' by the specified constraint. And then it may lead to the excessive delay or skew
```

This is already great - no hard errors. Still I want to understand and resolve the warnings (as much as I can).

## Change Tang Nano 20K file paths in project file from absolute to relative

This is necessary to build the project in GOWIN. (Should really have called it "Step 0".)

## Step 1 - add .gitignore for generated files

- Do not add /impl/ files
  - Exception: in a later step I will manually commit the changes in the already present *_process_config.json file
- Do not add *.gprj.user files, these have (local) links to the generated GOWIN Reports

## Step 2 - Fix EX0206 invalid parameter value for DEVICE

- WARN  (EX0206) : Instance "rpll_inst" 's parameter "DEVICE" value invalid("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\nano20k\gowin_pll_usb.v":32)
  - defparam rpll_inst.DEVICE = "GW2AR-18"; ---> defparam rpll_inst.DEVICE = "GW2AR-18C";

## Step 3 - fix top.v warnings for gowin_pll_usb (pll_usb instance)

- WARN  (EX2565) : Input 'reset' on this instance is undriven. Assigning to 0, simulation mismatch possible. Please assign the input or remove the declaration("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":37)
  - add ".reset(~sys_resetn)"
- WARN  (EX3073) : Port 'clkoutp' remains unconnected for this instance("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":37)
  - add .clkoutp() and .lock() specifiers to the module I/O list to indicate that we do not use these signals at the moment
  - (the warning for ".lock()" appears once you fix the ".clkoutp()" warning)

(I also put the module signal list in order of the declaration.)

## Step 4 - fix top.v unused input s1 warning, re-organize physical contraints (cst) file

- WARN  (CV0016) : Input s1 is unused("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":9)
  - comment the s1 input in the module signal list (as we don't use a button at the moment)

Additional changes:

- Re-order the I/O Pin mapping in the Physical Constraints File (nano2k.cst)
- Comment s1 definition
- Add (commented) s2 definition

## Step 5 - fix UART warnings

- WARN  (EX3786) : Assignment to input 'uart_tx'("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":24)
  - input uart_tx, --->  output uart_tx,  // UART transmitter is an OUTPUT

- WARN  (EX0211) : The output port "UART_TXD" of module "usb_hid_host_demo" has no driver, assigning undriven bits to Z, simulation mismatch possible("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":13)
  - fixed by declaring uart_tx as an OUTPUT (see directly above)

- WARN  (CV0016) : Input UART_RXD is unused("D:\Repo\github\usb_hid_host\boards\tang-nano20k-primer25k\top.v":12)
  - extend `led[1:0]` to `led[2:0]`
  - assign `led[2]` to UART_RXD, this way UART input should make LED2 flicker
  - NB: this also needs another Physical Constraints (cst) file change, uncommenting the led[2] declarations

## Step 6 - fix EXPRESSION SIZE warnings caused by increment or computation

- WARN  (EX3791) : Expression size 4 truncated to fit in target size 1("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":247)
- WARN  (EX3791) : Expression size 15 truncated to fit in target size 14("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":290)
- WARN  (EX3791) : Expression size 15 truncated to fit in target size 14("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":298)
- WARN  (EX3791) : Expression size 4 truncated to fit in target size 3("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":308)
- WARN  (EX3791) : Expression size 4 truncated to fit in target size 3("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":326)
- WARN  (EX3791) : Expression size 8 truncated to fit in target size 7("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":333)
- WARN  (EX3791) : Expression size 4 truncated to fit in target size 3("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":336)
- WARN  (EX3791) : Expression size 15 truncated to fit in target size 14("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":346)
- WARN  (EX3791) : Expression size 25 truncated to fit in target size 24("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":355)
- WARN  (EX3791) : Expression size 5 truncated to fit in target size 4("D:\Repo\github\usb_hid_host\src\usb_hid_host.v":141)
- WARN  (EX3791) : Expression size 24 truncated to fit in target size 23("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":18)
- WARN  (EX3791) : Expression size 10 truncated to fit in target size 9("D:\Repo\github\usb_hid_host\boards\common\uart_tx_V2.v":49)
- WARN  (EX3791) : Expression size 9 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\print.vh":111)
- WARN  (EX3791) : Expression size 21 truncated to fit in target size 20("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":53)
- WARN  (EX3791) : Expression size 32 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\utils.vh":7)
- WARN  (EX3791) : Expression size 32 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\utils.vh":9)

  - these are overflows caused by computations (e.g. counter <= counter + 1),
  - and they are all resolved by using the expression with '&' and a mask of the proper bit length, e.g.
  - `counter <= ((counter + 1) & 14'h3fff);` // example for a 14-bit counter

## Step 7 - fix EXPRESSION SIZE warnings for mouse x/y positions

- WARN  (EX3791) : Expression size 11 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":30)
- WARN  (EX3791) : Expression size 11 truncated to fit in target size 8("D:\Repo\github\usb_hid_host\boards\common\hid_printer.v":31)

  - these are in the mouse position calculation, the mouse_x2/y2 wire arrays also need to be 11 bits wide and signed

    ```C
    reg signed [10:0] mouse_x, mouse_y; // 0-1023, and negative(!) to detect overflow
    wire signed [10:0] mouse_x2 = mouse_x + mouse_dx;
    wire signed [10:0] mouse_y2 = mouse_y + mouse_dy;
    ```

## Step 8 - fix clock relationship warning

- WARN  (TA1117) : Can't calculate clocks' relationship between: "clk" and "clk_usb"
  - Adjust Timing Constraints File (sdc) with slightly more accurate values:
  - (27MHz) 37.04 -> 37.037, (12MHz) 83.33 -> 83.333

## Manual commit for process config file

   Looks like the GOWIN version I have is a little newer than the one used for the project, and therefore has some additional entries in the process configuration file.
   It's probably not really necessary to use this commit, too, but I include it for completeness.

## Remaining messages

- NOTE  (EX0101) : Current top module is "usb_hid_host_demo"
  - Just an information for the user. Correct.

- WARN  (PR1014) : Generic routing resource will be used to clock signal 'sys_clk_d' by the specified constraint. And then it may lead to the excessive delay or skew
  - **NOFIX**: Sorry, I have no idea how to fix this at the moment. Please let me know if you have an idea what causes this and how to prevent it.

## Thansk and Motivation

**Thanks for the hard work, nand2mario!**

Thanks to Tank Nano 20K and the nestang project I found this usb_hid_host core. Great!

For my "Jupiter Ace on an FPGA" project I was already looking for a USB HID master core.

- USB keyboards are much easier to get than PS/2 keyboards.
- To use PS/2 with any 3V3 platform, some interfacing is needed.
- Cherry on the cake would be if this even works with a wireless keyboard

I also plan to use the wired USB game controller I already have with nestang (did not get the full gaming set).

## Add synthesis-hagen-git.md to project

Last commit, to add this documentation.
