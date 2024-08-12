# HID Devices Test and USB Descriptors

Descriptors read on Windows 10 with:
> UsbTreeView V4.3.4 - Shows the USB Device Tree
>
> Freeware by Uwe Sieber, mail@uwe-sieber.de  
> https://www.uwe-sieber.de/usbtreeview_e.html


## TRUST Keyboard (trust.com/20517)

* works

```text
    ---------------------- Device Descriptor ----------------------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x01 (Device Descriptor)
bcdUSB                   : 0x110 (USB Version 1.1)
bDeviceClass             : 0x00 (defined by the interface descriptors)
bDeviceSubClass          : 0x00
bDeviceProtocol          : 0x00
bMaxPacketSize0          : 0x08 (8 bytes)
idVendor                 : 0x1A2C (Wuxi China Resources Semico Co., Ltd.)
idProduct                : 0x2124
bcdDevice                : 0x0110
iManufacturer            : 0x01 (String Descriptor 1)
 *!*ERROR  String descriptor not found
iProduct                 : 0x02 (String Descriptor 2)
 Language 0x0409         : "USB Keyboard"
iSerialNumber            : 0x00 (No String Descriptor)
bNumConfigurations       : 0x01 (1 Configuration)
Data (HexDump)           : 12 01 10 01 00 00 00 08 2C 1A 24 21 10 01 01 02   ........,.$!....
                           00 01                                             ..

    ------------------ Configuration Descriptor -------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x02 (Configuration Descriptor)
wTotalLength             : 0x003B (59 bytes)
bNumInterfaces           : 0x02 (2 Interfaces)
bConfigurationValue      : 0x01 (Configuration 1)
iConfiguration           : 0x00 (No String Descriptor)
bmAttributes             : 0xA0
 D7: Reserved, set 1     : 0x01
 D6: Self Powered        : 0x00 (no)
 D5: Remote Wakeup       : 0x01 (yes)
 D4..0: Reserved, set 0  : 0x00
MaxPower                 : 0x31 (98 mA)
Data (HexDump)           : 09 02 3B 00 02 01 00 A0 31 09 04 00 00 01 03 01   ..;.....1.......
                           01 00 09 21 10 01 00 01 22 36 00 07 05 81 03 08   ...!...."6......
                           00 0A 09 04 01 00 01 03 00 00 00 09 21 10 01 00   ............!...
                           01 22 32 00 07 05 82 03 08 00 0A                  ."2........

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x00 (Interface 0)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x01 (Boot Interface)
bInterfaceProtocol       : 0x01 (Keyboard)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 00 00 01 03 01 01 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0110 (HID Version 1.10)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 10 01 00 01 22 36 00                        .!...."6.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0036 (54 bytes)
                           (NB: HID Descriptor interpretation removed)
Data (HexDump)           : 09 02 3B 00 02 01 00 A0 31 09 04 00 00 01 03 01   ..;.....1.......
                           01 00 09 21 10 01 00 01 22 36 00 07 05 81 03 08   ...!...."6......
                           00 0A 09 04 01 00 01 03 00 00 00 09 21 10 01 00   ............!...
                           01 22 32 00 07 05                                 ."2...

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x81 (Direction=IN EndpointID=1)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0008
bInterval                : 0x0A (10 ms)
Data (HexDump)           : 07 05 81 03 08 00 0A                              .......

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x01 (Interface 1)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x00 (None)
bInterfaceProtocol       : 0x00 (None)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 01 00 01 03 00 00 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0110 (HID Version 1.10)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 10 01 00 01 22 32 00                        .!...."2.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0032 (50 bytes)
                           (NB: HID Descriptor interpretation removed)
Data (HexDump)           : 09 02 3B 00 02 01 00 A0 31 09 04 00 00 01 03 01   ..;.....1.......
                           01 00 09 21 10 01 00 01 22 36 00 07 05 81 03 08   ...!...."6......
                           00 0A 09 04 01 00 01 03 00 00 00 09 21 10 01 00   ............!...
                           01 22                                             ."

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x82 (Direction=IN EndpointID=2)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0008
bInterval                : 0x0A (10 ms)
Data (HexDump)           : 07 05 82 03 08 00 0A                              .......

      -------------------- String Descriptors -------------------
             ------ String Descriptor 0 ------
bLength                  : 0x04 (4 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language ID[0]           : 0x0409 (English - United States)
Data (HexDump)           : 04 03 09 04                                       ....
             ------ String Descriptor 2 ------
bLength                  : 0x1A (26 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "USB Keyboard"
Data (HexDump)           : 1A 03 55 00 53 00 42 00 20 00 4B 00 65 00 79 00   ..U.S.B. .K.e.y.
                           62 00 6F 00 61 00 72 00 64 00                     b.o.a.r.d.
```

----

# BEENIE Mouse (red, OK)

* works
* mouse_y does not seem to increase, only to reduce -> check datagrams

From the HID descriptor it looks like the datagram structure should be:

| Offset | Size    | Data                               |
| ----:  | ----    | ----                               |
| 0      | 1 byte  | Mouse buttons (left, right, wheel) |
| 1      | 2 bytes | Delta X (-32767...+32767)          |
| 3      | 2 bytes | Delta Y (-32767...+32767)          |
| 5      | 1 byte  | Delta Wheel (-127...+127)          |

The HID descriptor lists 5 variable bits for the mouse buttons and three constant ones.  
Maybe there is a variant of this mouse with two additional buttons?

```text
    ---------------------- Device Descriptor ----------------------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x01 (Device Descriptor)
bcdUSB                   : 0x110 (USB Version 1.1)
bDeviceClass             : 0x00 (defined by the interface descriptors)
bDeviceSubClass          : 0x00
bDeviceProtocol          : 0x00
bMaxPacketSize0          : 0x08 (8 bytes)
idVendor                 : 0x28A0 (I-CUBE TECHNOLOGY Co., Ltd.)
idProduct                : 0x1185
bcdDevice                : 0x0100
iManufacturer            : 0x00 (No String Descriptor)
iProduct                 : 0x01 (String Descriptor 1)
 Language 0x0409         : "USB OPTICAL MOUSE "
iSerialNumber            : 0x00 (No String Descriptor)
bNumConfigurations       : 0x01 (1 Configuration)
Data (HexDump)           : 12 01 10 01 00 00 00 08 A0 28 85 11 00 01 00 01   .........(......
                           00 01                                             ..

    ------------------ Configuration Descriptor -------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x02 (Configuration Descriptor)
wTotalLength             : 0x0022 (34 bytes)
bNumInterfaces           : 0x01 (1 Interface)
bConfigurationValue      : 0x01 (Configuration 1)
iConfiguration           : 0x00 (No String Descriptor)
bmAttributes             : 0xA0
 D7: Reserved, set 1     : 0x01
 D6: Self Powered        : 0x00 (no)
 D5: Remote Wakeup       : 0x01 (yes)
 D4..0: Reserved, set 0  : 0x00
MaxPower                 : 0x32 (100 mA)
Data (HexDump)           : 09 02 22 00 01 01 00 A0 32 09 04 00 00 01 03 01   ..".....2.......
                           02 00 09 21 11 01 00 01 22 40 00 07 05 81 03 06   ...!...."@......
                           00 0A                                             ..

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x00 (Interface 0)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x01 (Boot Interface)
bInterfaceProtocol       : 0x02 (Mouse)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 00 00 01 03 01 02 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0111 (HID Version 1.11)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 11 01 00 01 22 40 00                        .!...."@.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0040 (64 bytes)
  05 01             Usage Page (Generic Desktop Controls)
  09 02             Usage (Mouse)
  A1 01             Collection (Application)
  09 01               Usage (Pointer)
  A1 00               Collection (Physical)
  05 09                 Usage Page (Buttons)
  19 01                 Usage Minimum (1)
  29 05                 Usage Maximum (5)
  15 00                 Logical Minimum (0)
  25 01                 Logical Maximum (1)
  95 05                 Report Count (5)
  75 01                 Report Size (1)
  81 02                 Input (Var)
  95 01                 Report Count (1)
  75 03                 Report Size (3)
  81 01                 Input (Const)
  05 01                 Usage Page (Generic Desktop Controls)
  09 30                 Usage (Direction-X)
  09 31                 Usage (Direction-Y)
  16 01 80              Logical Minimum (-32767)
  26 FF 7F              Logical Maximum (32767)
  75 10                 Report Size (16)
  95 02                 Report Count (2)
  81 06                 Input (Var, Rel)
  09 38                 Usage (Wheel)
  15 81                 Logical Minimum (-127)
  25 7F                 Logical Maximum (127)
  75 08                 Report Size (8)
  95 01                 Report Count (1)
  81 06                 Input (Var, Rel)
  C0                  End Collection
  C0                End Collection
Data (HexDump)           : 05 01 09 02 A1 01 09 01 A1 00 05 09 19 01 29 05   ..............).
                           15 00 25 01 95 05 75 01 81 02 95 01 75 03 81 01   ..%...u.....u...
                           05 01 09 30 09 31 16 01 80 26 FF 7F 75 10 95 02   ...0.1...&..u...
                           81 06 09 38 15 81 25 7F 75 08 95 01 81 06 C0 C0   ...8..%.u.......

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x81 (Direction=IN EndpointID=1)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0006
bInterval                : 0x0A (10 ms)
Data (HexDump)           : 07 05 81 03 06 00 0A                              .......

      -------------------- String Descriptors -------------------
             ------ String Descriptor 0 ------
bLength                  : 0x04 (4 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language ID[0]           : 0x0409 (English - United States)
Data (HexDump)           : 04 03 09 04                                       ....
             ------ String Descriptor 1 ------
bLength                  : 0x26 (38 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "USB OPTICAL MOUSE "  *!*CAUTION  trailing space character
Data (HexDump)           : 26 03 55 00 53 00 42 00 20 00 4F 00 50 00 54 00   &.U.S.B. .O.P.T.
                           49 00 43 00 41 00 4C 00 20 00 4D 00 4F 00 55 00   I.C.A.L. .M.O.U.
                           53 00 45 00 20 00                                 S.E. .
```

----

# Speedlink Black Widow (SL-6640)

* works
* mapping of datagrams seems not to be correct

```text
    ---------------------- Device Descriptor ----------------------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x01 (Device Descriptor)
bcdUSB                   : 0x110 (USB Version 1.1)
bDeviceClass             : 0x00 (defined by the interface descriptors)
bDeviceSubClass          : 0x00
bDeviceProtocol          : 0x00
bMaxPacketSize0          : 0x08 (8 bytes)
idVendor                 : 0x07B5 (Mega World International Ltd.)
idProduct                : 0x0317
bcdDevice                : 0x0101
iManufacturer            : 0x01 (String Descriptor 1)
 Language 0x0409         : "Mega World"
iProduct                 : 0x02 (String Descriptor 2)
 Language 0x0409         : "USB Game Controllers"
iSerialNumber            : 0x00 (No String Descriptor)
bNumConfigurations       : 0x01 (1 Configuration)
Data (HexDump)           : 12 01 10 01 00 00 00 08 B5 07 17 03 01 01 01 02   ................
                           00 01                                             ..

    ------------------ Configuration Descriptor -------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x02 (Configuration Descriptor)
wTotalLength             : 0x0022 (34 bytes)
bNumInterfaces           : 0x01 (1 Interface)
bConfigurationValue      : 0x01 (Configuration 1)
iConfiguration           : 0x00 (No String Descriptor)
bmAttributes             : 0xA0
 D7: Reserved, set 1     : 0x01
 D6: Self Powered        : 0x00 (no)
 D5: Remote Wakeup       : 0x01 (yes)
 D4..0: Reserved, set 0  : 0x00
MaxPower                 : 0xAF (350 mA)
Data (HexDump)           : 09 02 22 00 01 01 00 A0 AF 09 04 00 00 01 03 00   ..".............
                           00 00 09 21 10 01 00 01 22 75 00 07 05 81 03 08   ...!...."u......
                           00 0A                                             ..

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x00 (Interface 0)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x00 (None)
bInterfaceProtocol       : 0x00 (None)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 00 00 01 03 00 00 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0110 (HID Version 1.10)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 10 01 00 01 22 75 00                        .!...."u.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0075 (117 bytes)
  05 01             Usage Page (Generic Desktop Controls)
  09 04             Usage (Joystick)
  A1 01             Collection (Application)
  09 01               Usage (Pointer)
  A1 00               Collection (Physical)
  09 30                 Usage (Direction-X)
  09 31                 Usage (Direction-Y)
  09 32                 Usage (Direction-Z)
  09 35                 Usage (Rotate-Z)
  15 80                 Logical Minimum (-128)
  25 7F                 Logical Maximum (127)
  46 FF 00              Physical Maximum (255)
  66 00 00              Unit (0x00)
  75 08                 Report Size (8)
  95 04                 Report Count (4)
  81 02                 Input (Var)
  C0                  End Collection
  09 39               Usage (Hat Switch)
  15 01               Logical Minimum (1)
  25 08               Logical Maximum (8)
  35 00               Physical Minimum (0)
  46 3B 01            Physical Maximum (315)
  65 14               Unit (0x14)
  75 04               Report Size (4)
  95 01               Report Count (1)
  81 02               Input (Var)
  05 09               Usage Page (Buttons)
  19 01               Usage Minimum (1)
  29 08               Usage Maximum (8)
  15 00               Logical Minimum (0)
  25 01               Logical Maximum (1)
  75 01               Report Size (1)
  95 08               Report Count (8)
  81 02               Input (Var)
  95 04               Report Count (4)
  81 03               Input (Const, Var)
  05 08               Usage Page (LEDs)
  09 43               Usage (Slow Blink On Time)
  15 00               Logical Minimum (0)
  26 FF 00            Logical Maximum (255)
  35 00               Physical Minimum (0)
  46 FF 00            Physical Maximum (255)
  75 08               Report Size (8)
  95 01               Report Count (1)
  91 82               Output (Var, Volatile)
  09 44               Usage (Slow Blink Off Time)
  91 82               Output (Var, Volatile)
  09 45               Usage (Fast Blink On Time)
  91 82               Output (Var, Volatile)
  09 46               Usage (Fast Blink Off Time)
  91 82               Output (Var, Volatile)
  55 00               Unit Exponent (0x00: 0)
  65 00               Unit (0x00)
  55 00               Unit Exponent (0x00: 0)
  55 00               Unit Exponent (0x00: 0)
  65 00               Unit (0x00)
  C0                End Collection
Data (HexDump)           : 05 01 09 04 A1 01 09 01 A1 00 09 30 09 31 09 32   ...........0.1.2
                           09 35 15 80 25 7F 46 FF 00 66 00 00 75 08 95 04   .5..%.F..f..u...
                           81 02 C0 09 39 15 01 25 08 35 00 46 3B 01 65 14   ....9..%.5.F;.e.
                           75 04 95 01 81 02 05 09 19 01 29 08 15 00 25 01   u.........)...%.
                           75 01 95 08 81 02 95 04 81 03 05 08 09 43 15 00   u............C..
                           26 FF 00 35 00 46 FF 00 75 08 95 01 91 82 09 44   &..5.F..u......D
                           91 82 09 45 91 82 09 46 91 82 55 00 65 00 55 00   ...E...F..U.e.U.
                           55 00 65 00 C0                                    U.e..

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x81 (Direction=IN EndpointID=1)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0008
bInterval                : 0x0A (10 ms)
Data (HexDump)           : 07 05 81 03 08 00 0A                              .......

      -------------------- String Descriptors -------------------
             ------ String Descriptor 0 ------
bLength                  : 0x04 (4 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language ID[0]           : 0x0409 (English - United States)
Data (HexDump)           : 04 03 09 04                                       ....
             ------ String Descriptor 1 ------
bLength                  : 0x16 (22 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "Mega World"
Data (HexDump)           : 16 03 4D 00 65 00 67 00 61 00 20 00 57 00 6F 00   ..M.e.g.a. .W.o.
                           72 00 6C 00 64 00                                 r.l.d.
             ------ String Descriptor 2 ------
bLength                  : 0x2A (42 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "USB Game Controllers"
Data (HexDump)           : 2A 03 55 00 53 00 42 00 20 00 47 00 61 00 6D 00   *.U.S.B. .G.a.m.
                           65 00 20 00 43 00 6F 00 6E 00 74 00 72 00 6F 00   e. .C.o.n.t.r.o.
                           6C 00 6C 00 65 00 72 00 73 00                     l.l.e.r.s.
```

----

# maxxter mouse (probably broken)

* works
* datagrams look odd

From the HID descriptor it looks like the datagram structure should be:

| Offset | Size    | Data                               |
| ----:  | ----:   | ----                               |
| 0      |  8 bits | Mouse buttons (left, right, wheel), 3 var bits, 5 const bits |
| 1      | 12 bits | Delta X (-2048...+2047)            |
| 2.5    | 12 bits | Delta Y (-2048...+2047)            |
| 4      |  8 bits | Delta Wheel (-127...+127)          |
| 5      |  8 bits | unused                             |

```text
    ---------------------- Device Descriptor ----------------------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x01 (Device Descriptor)
bcdUSB                   : 0x110 (USB Version 1.1)
bDeviceClass             : 0x00 (defined by the interface descriptors)
bDeviceSubClass          : 0x00
bDeviceProtocol          : 0x00
bMaxPacketSize0          : 0x08 (8 bytes)
idVendor                 : 0x0000
idProduct                : 0x0538
bcdDevice                : 0x0100
iManufacturer            : 0x00 (No String Descriptor)
iProduct                 : 0x01 (String Descriptor 1)
 Language 0x0409         : " USB OPTICAL MOUSE"
iSerialNumber            : 0x00 (No String Descriptor)
bNumConfigurations       : 0x01 (1 Configuration)
Data (HexDump)           : 12 01 10 01 00 00 00 08 00 00 38 05 00 01 00 01   ..........8.....
                           00 01                                             ..

    ------------------ Configuration Descriptor -------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x02 (Configuration Descriptor)
wTotalLength             : 0x0022 (34 bytes)
bNumInterfaces           : 0x01 (1 Interface)
bConfigurationValue      : 0x01 (Configuration 1)
iConfiguration           : 0x00 (No String Descriptor)
bmAttributes             : 0xA0
 D7: Reserved, set 1     : 0x01
 D6: Self Powered        : 0x00 (no)
 D5: Remote Wakeup       : 0x01 (yes)
 D4..0: Reserved, set 0  : 0x00
MaxPower                 : 0x32 (100 mA)
Data (HexDump)           : 09 02 22 00 01 01 00 A0 32 09 04 00 00 01 03 01   ..".....2.......
                           02 00 09 21 11 01 00 01 22 42 00 07 05 81 03 06   ...!...."B......
                           00 0A                                             ..

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x00 (Interface 0)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x01 (Boot Interface)
bInterfaceProtocol       : 0x02 (Mouse)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 00 00 01 03 01 02 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0111 (HID Version 1.11)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 11 01 00 01 22 42 00                        .!...."B.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0042 (66 bytes)
  05 01             Usage Page (Generic Desktop Controls)
  09 02             Usage (Mouse)
  A1 01             Collection (Application)
  85 01               Report ID (0x01)
  09 01               Usage (Pointer)
  A1 00               Collection (Physical)
  05 09                 Usage Page (Buttons)
  19 01                 Usage Minimum (1)
  29 03                 Usage Maximum (3)
  15 00                 Logical Minimum (0)
  25 01                 Logical Maximum (1)
  95 03                 Report Count (3)
  75 01                 Report Size (1)
  81 02                 Input (Var)
  95 01                 Report Count (1)
  75 05                 Report Size (5)
  81 01                 Input (Const)
  05 01                 Usage Page (Generic Desktop Controls)
  09 30                 Usage (Direction-X)
  09 31                 Usage (Direction-Y)
  16 00 F8              Logical Minimum (-2048)
  26 FF 07              Logical Maximum (2047)
  75 0C                 Report Size (12)
  95 02                 Report Count (2)
  81 06                 Input (Var, Rel)
  09 38                 Usage (Wheel)
  15 81                 Logical Minimum (-127)
  25 7F                 Logical Maximum (127)
  75 08                 Report Size (8)
  95 01                 Report Count (1)
  81 06                 Input (Var, Rel)
  C0                  End Collection
  C0                End Collection
Data (HexDump)           : 05 01 09 02 A1 01 85 01 09 01 A1 00 05 09 19 01   ................
                           29 03 15 00 25 01 95 03 75 01 81 02 95 01 75 05   )...%...u.....u.
                           81 01 05 01 09 30 09 31 16 00 F8 26 FF 07 75 0C   .....0.1...&..u.
                           95 02 81 06 09 38 15 81 25 7F 75 08 95 01 81 06   .....8..%.u.....
                           C0 C0                                             ..

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x81 (Direction=IN EndpointID=1)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0006
bInterval                : 0x0A (10 ms)
Data (HexDump)           : 07 05 81 03 06 00 0A                              .......

      -------------------- String Descriptors -------------------
             ------ String Descriptor 0 ------
bLength                  : 0x04 (4 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language ID[0]           : 0x0409 (English - United States)
Data (HexDump)           : 04 03 09 04                                       ....
             ------ String Descriptor 1 ------
bLength                  : 0x2E (46 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : " USB OPTICAL MOUSE°°°°"  *!*CAUTION  leading space character  *!*ERROR  contains 4 NULL characters
Data (HexDump)           : 2E 03 20 00 55 00 53 00 42 00 20 00 4F 00 50 00   .. .U.S.B. .O.P.
                           54 00 49 00 43 00 41 00 4C 00 20 00 4D 00 4F 00   T.I.C.A.L. .M.O.
                           55 00 53 00 45 00 00 00 00 00 00 00 00 00         U.S.E.........
```

----

# Logitech Receiver for K400+

* does not work
* descriptors look OK, but not USB1.1 compatible

```text
    ---------------------- Device Descriptor ----------------------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x01 (Device Descriptor)
bcdUSB                   : 0x200 (USB Version 2.0)
bDeviceClass             : 0x00 (defined by the interface descriptors)
bDeviceSubClass          : 0x00
bDeviceProtocol          : 0x00
bMaxPacketSize0          : 0x20 (32 bytes)
idVendor                 : 0x046D (Logitech Inc.)
idProduct                : 0xC52B
bcdDevice                : 0x2411
iManufacturer            : 0x01 (String Descriptor 1)
 Language 0x0409         : "Logitech"
iProduct                 : 0x02 (String Descriptor 2)
 Language 0x0409         : "USB Receiver"
iSerialNumber            : 0x00 (No String Descriptor)
bNumConfigurations       : 0x01 (1 Configuration)
Data (HexDump)           : 12 01 00 02 00 00 00 20 6D 04 2B C5 11 24 01 02   ....... m.+..$..
                           00 01                                             ..

    ------------------ Configuration Descriptor -------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x02 (Configuration Descriptor)
wTotalLength             : 0x0054 (84 bytes)
bNumInterfaces           : 0x03 (3 Interfaces)
bConfigurationValue      : 0x01 (Configuration 1)
iConfiguration           : 0x04 (String Descriptor 4)
 Language 0x0409         : "RQR24.11_B0036"
bmAttributes             : 0xA0
 D7: Reserved, set 1     : 0x01
 D6: Self Powered        : 0x00 (no)
 D5: Remote Wakeup       : 0x01 (yes)
 D4..0: Reserved, set 0  : 0x00
MaxPower                 : 0x31 (98 mA)
Data (HexDump)           : 09 02 54 00 03 01 04 A0 31 09 04 00 00 01 03 01   ..T.....1.......
                           01 00 09 21 11 01 00 01 22 3B 00 07 05 81 03 08   ...!....";......
                           00 08 09 04 01 00 01 03 01 02 00 09 21 11 01 00   ............!...
                           01 22 94 00 07 05 82 03 08 00 02 09 04 02 00 01   ."..............
                           03 00 00 00 09 21 11 01 00 01 22 62 00 07 05 83   .....!...."b....
                           03 20 00 02                                       . ..

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x00 (Interface 0)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x01 (Boot Interface)
bInterfaceProtocol       : 0x01 (Keyboard)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 00 00 01 03 01 01 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0111 (HID Version 1.11)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 11 01 00 01 22 3B 00                        .!....";.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x003B (59 bytes)
Error reading descriptor : ERROR_GEN_FAILURE (due to a obscure limitation of the Win32 USB API, see F1 Help)

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x81 (Direction=IN EndpointID=1)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0008 (8 bytes)
bInterval                : 0x08 (8 ms)
Data (HexDump)           : 07 05 81 03 08 00 08                              .......

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x01 (Interface 1)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x01 (Boot Interface)
bInterfaceProtocol       : 0x02 (Mouse)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 01 00 01 03 01 02 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0111 (HID Version 1.11)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 11 01 00 01 22 94 00                        .!...."..
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0094 (148 bytes)
Error reading descriptor : ERROR_GEN_FAILURE (due to a obscure limitation of the Win32 USB API, see F1 Help)

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x82 (Direction=IN EndpointID=2)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0008 (8 bytes)
bInterval                : 0x02 (2 ms)
Data (HexDump)           : 07 05 82 03 08 00 02                              .......

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x02 (Interface 2)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x01 (1 Endpoint)
bInterfaceClass          : 0x03 (HID - Human Interface Device)
bInterfaceSubClass       : 0x00 (None)
bInterfaceProtocol       : 0x00 (None)
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 02 00 01 03 00 00 00                        .........

        ------------------- HID Descriptor --------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x21 (HID Descriptor)
bcdHID                   : 0x0111 (HID Version 1.11)
bCountryCode             : 0x00 (00 = not localized)
bNumDescriptors          : 0x01
Data (HexDump)           : 09 21 11 01 00 01 22 62 00                        .!...."b.
Descriptor 1:
bDescriptorType          : 0x22 (Class=Report)
wDescriptorLength        : 0x0062 (98 bytes)
Error reading descriptor : ERROR_GEN_FAILURE (due to a obscure limitation of the Win32 USB API, see F1 Help)

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x83 (Direction=IN EndpointID=3)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0020 (32 bytes)
bInterval                : 0x02 (2 ms)
Data (HexDump)           : 07 05 83 03 20 00 02                              .... ..

      -------------------- String Descriptors -------------------
             ------ String Descriptor 0 ------
bLength                  : 0x04 (4 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language ID[0]           : 0x0409 (English - United States)
Data (HexDump)           : 04 03 09 04                                       ....
             ------ String Descriptor 1 ------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "Logitech"
Data (HexDump)           : 12 03 4C 00 6F 00 67 00 69 00 74 00 65 00 63 00   ..L.o.g.i.t.e.c.
                           68 00                                             h.
             ------ String Descriptor 2 ------
bLength                  : 0x1A (26 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "USB Receiver"
Data (HexDump)           : 1A 03 55 00 53 00 42 00 20 00 52 00 65 00 63 00   ..U.S.B. .R.e.c.
                           65 00 69 00 76 00 65 00 72 00                     e.i.v.e.r.
             ------ String Descriptor 4 ------
bLength                  : 0x1E (30 bytes)
bDescriptorType          : 0x03 (String Descriptor)
Language 0x0409          : "RQR24.11_B0036"
Data (HexDump)           : 1E 03 52 00 51 00 52 00 32 00 34 00 2E 00 31 00   ..R.Q.R.2.4...1.
                           31 00 5F 00 42 00 30 00 30 00 33 00 36 00         1._.B.0.0.3.6.
```

----

# Game controller (Lab31 LB-GA-GPVI01-B, XBOX compatible)

* does not work
* descriptors look OK, but not USB1.1 compatible

```text
    ---------------------- Device Descriptor ----------------------
bLength                  : 0x12 (18 bytes)
bDescriptorType          : 0x01 (Device Descriptor)
bcdUSB                   : 0x200 (USB Version 2.0) -> but device is Full-Speed only
bDeviceClass             : 0xFF (Vendor Specific)
bDeviceSubClass          : 0xFF
bDeviceProtocol          : 0xFF
bMaxPacketSize0          : 0x20 (32 bytes)
idVendor                 : 0x045E (Microsoft Corporation)
idProduct                : 0x028E -> (Xbox360 Controller)
bcdDevice                : 0x0110
iManufacturer            : 0x01 (String Descriptor 1)
 *!*ERROR  String descriptor not found
iProduct                 : 0x02 (String Descriptor 2)
 *!*ERROR  String descriptor not found
iSerialNumber            : 0x00 (No String Descriptor)
bNumConfigurations       : 0x01 (1 Configuration)
Data (HexDump)           : 12 01 00 02 FF FF FF 20 5E 04 8E 02 10 01 01 02   ....... ^.......
                           00 01                                             ..

    ------------------ Configuration Descriptor -------------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x02 (Configuration Descriptor)
wTotalLength             : 0x0030 (48 bytes)
bNumInterfaces           : 0x01 (1 Interface)
bConfigurationValue      : 0x01 (Configuration 1)
iConfiguration           : 0x00 (No String Descriptor)
bmAttributes             : 0x80
 D7: Reserved, set 1     : 0x01
 D6: Self Powered        : 0x00 (no)
 D5: Remote Wakeup       : 0x00 (no)
 D4..0: Reserved, set 0  : 0x00
MaxPower                 : 0xFA (500 mA)
Data (HexDump)           : 09 02 30 00 01 01 00 80 FA 09 04 00 00 02 FF 5D   ..0............]
                           01 00 10 21 10 01 01 24 81 14 03 00 03 13 02 00   ...!...$........
                           03 00 07 05 81 03 20 00 04 07 05 02 03 20 00 08   ...... ...... ..

        ---------------- Interface Descriptor -----------------
bLength                  : 0x09 (9 bytes)
bDescriptorType          : 0x04 (Interface Descriptor)
bInterfaceNumber         : 0x00 (Interface 0)
bAlternateSetting        : 0x00
bNumEndpoints            : 0x02 (2 Endpoints)
bInterfaceClass          : 0xFF (Vendor Specific)
bInterfaceSubClass       : 0x5D
bInterfaceProtocol       : 0x01
iInterface               : 0x00 (No String Descriptor)
Data (HexDump)           : 09 04 00 00 02 FF 5D 01 00                        ......]..

        ----------------- Unknown Descriptor ------------------
bLength                  : 0x10 (16 bytes)
bDescriptorType          : 0x21
Data (HexDump)           : 10 21 10 01 01 24 81 14 03 00 03 13 02 00 03 00 
                           
        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x81 (Direction=IN EndpointID=1)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0020 (32 bytes)
bInterval                : 0x04 (4 ms)
Data (HexDump)           : 07 05 81 03 20 00 04                              .... ..

        ----------------- Endpoint Descriptor -----------------
bLength                  : 0x07 (7 bytes)
bDescriptorType          : 0x05 (Endpoint Descriptor)
bEndpointAddress         : 0x02 (Direction=OUT EndpointID=2)
bmAttributes             : 0x03 (TransferType=Interrupt)
wMaxPacketSize           : 0x0020 (32 bytes)
bInterval                : 0x08 (8 ms)
Data (HexDump)           : 07 05 02 03 20 00 08                              .... ..

    ----------------- Device Qualifier Descriptor -----------------
Error                    : ERROR_GEN_FAILURE  (because the device is Full-Speed only)

      -------------------- String Descriptors -------------------
none
```

----
