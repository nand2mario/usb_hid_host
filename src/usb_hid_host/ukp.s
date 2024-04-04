; USB HID Host (keyboard/mouse/gamepad) firmware for UKP
; By hi631, nand2mario, 2023

cstart:
; ---- interrupt transfer interval (10-1mS)
	ldi	9
cstart2:
	wait
	bc	connected
	bz	cstart

; ---- wait 200mS after device attached
	ldi	200
w200ms:
	wait
	djnz	w200ms

;
; Detection sequence
;

; reset device
	jmp reset

; ; request device descriptor and receive ACK
; 	jmp getdesc
; 	hiz
; 	jmp rcvdt

; ; ---- send IN(1,0) and receive 1st half of device descriptor
; wait_desc:
; 	jmp in00
; 	hiz
; 	jmp rcvdt
; 	bnak wait_desc
; ; send ACK
; 	jmp  sendack
; 	hiz

; ; request 2nd half of device descriptor
; wait_desc2:
; 	jmp in00
; 	hiz
; 	jmp rcvdt
; 	bnak wait_desc2
; 	vidpid			; register VID and PID just received
; ; send ACK
; 	jmp  sendack
; 	hiz

; Get_Configuration(1)
	jmp getconfig
	hiz
	jmp rcvdt

; IN(0,0), ACK(), configuration descriptor
wait_config:
	jmp in00
	hiz
	jmp rcvdt
	bnak wait_config
	jmp sendack
	hiz

; IN(0,0), ACK(), last byte of config descriptor, then 7 bytes of interface #0
wait_config2:
	jmp in00
	hiz
	jmp rcvdt
	bnak wait_config2
	save 4 6			; interface class
	save 5 7			; interface sub-class 
	jmp sendack
	hiz

; IN(0,0), ACK(), 8 bytes of interface #0
wait_interface:
	jmp in00
	hiz
	jmp rcvdt
	bnak wait_interface
	save 6 0			; interface protocol
	jmp sendack
	hiz

;
; reset device again
	jmp reset

;
; Initialization sequence
; 
; ---- send set address 1
	jmp  setadr1
	hiz

; ---- recieve
	jmp  rcvdt

; ---- send IN(0,0)
sendinlp:
	jmp  in00
	hiz

; ---- receive
	jmp  rcvdt
	bnak	sendinlp

; ---- send ACK
	jmp  sendack
	hiz

; ---- wait 1mS
	wait

; ---- send set configuration 1
	jmp  setconfig1
	hiz

; ---- recieve
	jmp  rcvdt

; ---- send IN(1,0)
in10lp:
	jmp  in10
	hiz

; ---- recieve
	jmp  	rcvdt
	bnak	in10lp

; ---- send ACK
	jmp sendack
	hiz
	toggle
	jmp  cstart

; -------------------
;  when connected    
; -------------------
connected:
	bz	connerr

	out4 0x03
	hiz
	djnz	cstart2
	wait

; ---- IN(1,1) (interrupt transfer)
	jmp  in11
	hiz

; ---- recieve
	jmp  rcvdt
	bnak	cstart

; ---- send ACK
	jmp  sendack
	hiz

; ---- jump startf
	jmp  cstart

; ---- jupm start(&toggle)
connerr:
	toggle
	jmp  cstart

; --------------
; sub           
; --------------

; ---- USB bus reset
reset:
	out0
	ldi	10
busrstlp:
	wait
	djnz	busrstlp
	hiz
	; ---- 40mS wait
	ldi	40
w40ms:
	wait
	out4 0x03		; keep-alive
	hiz
	djnz	w40ms
	wait
	ret

getdesc:			; get device descriptor of (0,0)
	outb 0x80		; SYNC
	outb 0x2d		; PID
	outb 0x00		; ADDR:ENDP = 0:0
	outb 0x10		; + CRC5
	out4 0x03		; EOP
	; outb 0x01		; ADDR:ENDP = 1:0
	; outb 0xe8		; + CRC5
	; out4 0x03		; EOP

	outb 0x80		; SYNC
	outb 0xc3		; PID=DATA0
	outb 0x80		; bmRequestType: 80
	outb 0x06		; bRequest=6 Get_Descriptor
	outb 0x00		; Desc Index: 0
	outb 0x01		; Desc Type: 1 device
	outb 0x00		; Language ID: 0
	outb 0x00		; 
	outb 0x12		; wLength = 18
	outb 0x00
	outb 0xE0		; CRC16
	outb 0xF4
	out4 0x03		; EOP
	ret

getconfig:			; get config descriptor of (0,0)
	outb 0x80		; SYNC
	outb 0x2d		; PID
	outb 0x00		; ADDR:ENDP = 0:0
	outb 0x10		; + CRC5
	out4 0x03		; EOP

	outb 0x80		; SYNC
	outb 0xc3		; PID=DATA0
	outb 0x80		; bmRequestType: 0
	outb 0x06		; bRequest=6 Get_Descriptor
	outb 0x00		; Desc Index: 0
	outb 0x02		; Desc Type: 2 configuration
	outb 0x00		; Language ID: 0
	outb 0x00		; 
	outb 0x18		; wLength = 24 (9 for config, 15 for first interface)
	outb 0x00
	outb 0xa2		; CRC16
	outb 0x54
	out4 0x03		; EOP
	ret

setadr1:			; set address of device 0 to 1
	outb 0x80
	outb 0x2d
	outb 0x00
	outb 0x10
	out4 0x03

	outb 0x80
	outb 0xc3
	outb 0x00
	outb 0x05
	outb 0x01
	outb 0x00
	outb 0x00
	outb 0x00
	outb 0x00
	outb 0x00
	outb 0xeb
	outb 0x25
	out4 0x03
	ret

setconfig1:			; set active configuration of device 1 to 1 (default config)
	outb 0x80
	outb 0x2d
	outb 0x01
	outb 0xe8
	out4 0x03

	outb 0x80
	outb 0xc3
	outb 0x00
	outb 0x09
	outb 0x01
	outb 0x00
	outb 0x00
	outb 0x00
	outb 0x00
	outb 0x00
	outb 0x27
	outb 0x25
	out4 0x03
	ret

rcvdt:				; receive 8 bytes of data from device 
					; and SYNC,PID at beginning, and CRC16 and ENDP at the end
	ldi	104
	start
	in
rcvdt2:
	ldi	2
rcvdt3:
	bz		rcvdt2
	djnz	rcvdt3
	ret

in00:
	outb 0x80
	outb 0x69
	outb 0x00
	outb 0x10
	out4 0x03
	ret

in10:
	outb 0x80
	outb 0x69
	outb 0x01
	outb 0xe8
	out4 0x03
	ret

in11:
	outb 0x80
	outb 0x69
	outb 0x81
	outb 0x58
	out4 0x03
	ret

sendack:
	outb 0x80
	outb 0xd2
	out4 0x03
	ret
prgend:
