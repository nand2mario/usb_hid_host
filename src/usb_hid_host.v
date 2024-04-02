// Usb_hid_host: A compact USB HID host core.
//
// nand2mario, 8/2023, based on work by hi631
// 
// This should support keyboard, mouse and gamepad input out of the box, over low-speed 
// USB (1.5Mbps). Just connect D+, D-, VBUS (5V) and GND, and two 15K resistors between 
// D+ and GND, D- and GND. Then provide a 12Mhz clock through usbclk.
//
// See https://github.com/nand2mario/usb_hid_host
// 

module usb_hid_host (
    input  wire usbclk,		            // 12MHz clock
    input  wire usbrst_n,	            // reset
    input  wire usb_dm_i, usb_dp_i,     // USB D- and D+ input
    output  wire usb_dm_o, usb_dp_o,    // USB D- and D+ output
    output wire usb_oe,                 // USB Output Enable
    input  wire update_leds_stb,        // Pulse for one clock cycle to request sending of SetReport command to USB HID keyboard to set the LEDs according to the leds bitmap below.
    output wire ack_update_leds_stb,    // Acknowledgement strobe that the USB HID keyboard command has been sent.
    input  wire [3:0] leds,             // The Keyboard LED bitmap: bit0=Num Loc, bit1=CAPS lock, bit2=scroll lock, bit3=compose.
    output reg [1:0] typ,               // device type. 0: no device, 1: keyboard, 2: mouse, 3: gamepad
    output reg report,                  // pulse after report received from device. 
                                        // key_*, mouse_*, game_* valid depending on typ
    output wire conerr,                 // connection or protocol error

    // keyboard
    output reg [7:0] key_modifiers,
    output reg [7:0] key1, key2, key3, key4,

    // mouse
    output reg [7:0] mouse_btn,     // {5'bx, middle, right, left}
    output reg signed [7:0] mouse_dx,      // signed 8-bit, cleared after `report` pulse
    output reg signed [7:0] mouse_dy,      // signed 8-bit, cleared after `report` pulse

    // gamepad 
    output reg game_l, game_r, game_u, game_d,  // left right up down
    output reg game_a, game_b, game_x, game_y, game_sel, game_sta,  // buttons

    // debug
    output wire [63:0] dbg_hid_report	// last HID report
);

wire data_rdy;          // data ready
wire data_strobe;       // data strobe for each byte
wire [7:0] ukpdat;		// actual data
reg [7:0] regs [0:6];   // 0 (VID_L), 1 (VID_H), 2 (PID_L), 3 (PID_H), 4 (INTERFACE_CLASS), 5 (INTERFACE_SUBCLASS), 6 (INTERFACE_PROTOCOL)
wire save;			    // save dat[b] to output register r
wire [3:0] save_r;      // which register to save to
wire [3:0] save_b;      // dat[b]
wire connected;

reg [15:0] crc16;

//CRC16 Look Up Table for the 1-byte data stage of the SetReport transaction for Keyboard LED updates. 
//Key is the LED bitmap sent in the data stage, the result is the corresponding CRC16 value. 
always @(leds) begin
    case (leds)
    4'h0: crc16 = 16'hbf40;
    4'h1: crc16 = 16'h7f81;
    4'h2: crc16 = 16'h7ec1;
    4'h3: crc16 = 16'hbe00;
    4'h4: crc16 = 16'h7c41;
    4'h5: crc16 = 16'hbc80;
    4'h6: crc16 = 16'hbdc0;
    4'h7: crc16 = 16'h7d01;
    4'h8: crc16 = 16'h7941;
    4'h9: crc16 = 16'hb980;
    4'ha: crc16 = 16'hb8c0;
    4'hb: crc16 = 16'h7801;
    4'hc: crc16 = 16'hba40;
    4'hd: crc16 = 16'h7a81;
    4'he: crc16 = 16'h7bc1;
    4'hf: crc16 = 16'hbb00;
    endcase
end

ukp ukp(
    .usbrst_n(usbrst_n), .usbclk(usbclk),
    .usb_dp_i(usb_dp_i), .usb_dm_i(usb_dm_i),
    .usb_dp_o(usb_dp_o), .usb_dm_o(usb_dm_o),
    .usb_oe(usb_oe),
    .req_branch_stb(update_leds_stb), //the update_leds signal request the UKP firmware to take the branch on the next 'br' instruction.
    .ack_req_branch_stb(ack_update_leds_stb), //indication that the branch has been taken.
    .outr0({4'b0, leds}), //1-byte value to send when firmware executes the 'outr0' instruction.
    .outr1(crc16[7:0]),   //1-byte value to send when firwmare executes the 'outr1' instruction.
    .outr2(crc16[15:8]),  //1-byte valye to send when firmware executes the 'outr2' instruction.
    .ukprdy(data_rdy), .ukpstb(data_strobe), .ukpdat(ukpdat), .save(save), .save_r(save_r), .save_b(save_b),
    .connected(connected), .conerr(conerr));

reg  [2:0] rcvct;		// counter for recv data
reg  data_strobe_r, data_rdy_r;	// delayed data_strobe and data_rdy
reg  [7:0] dat[0:7];		// data in last response
assign dbg_hid_report = {dat[7], dat[6], dat[5], dat[4], dat[3], dat[2], dat[1], dat[0]};
// assign dbg_regs = regs;

// Gamepad types, see response_recognition below
// localparam D_GENERIC = 0;
// localparam D_GAMEPAD = 1;			
// localparam D_DS2_ADAPTER = 2;
// reg [3:0] dev = D_GENERIC;			// device type recognized through VID/PID
// assign dbg_dev = dev;

reg valid = 0;		    // whether current gamepad report is valid

always @(posedge usbclk) begin : process_in_data
    data_rdy_r <= data_rdy; data_strobe_r <= data_strobe;
    report <= 0;                    // ensure pulse
    if (report == 1) begin
        // clear mouse movement for later
        mouse_dx <= 0; mouse_dy <= 0;
    end
    if(~data_rdy) begin
        rcvct <= 0;
    end
    else begin
        if(data_strobe && ~data_strobe_r) begin  // rising edge of ukp data strobe
            dat[rcvct] <= ukpdat;

            if (typ == 1) begin     // keyboard
                case (rcvct)
                0: key_modifiers <= ukpdat;
                2: key1 <= ukpdat;
                3: key2 <= ukpdat;
                4: key3 <= ukpdat;
                5: key4 <= ukpdat;
                endcase
            end else if (typ == 2) begin    // mouse
                case (rcvct)
                0: mouse_btn <= ukpdat;
                1: mouse_dx <= ukpdat;
                2: mouse_dy <= ukpdat;
                endcase
            end else if (typ == 3) begin    // gamepad
                // A typical report layout:
                // - d[3] is X axis (0: left, 255: right)
                // - d[4] is Y axis
                // - d[5][7:4] is buttons YBAX
                // - d[6][5:4] is buttons START,SELECT
                // Variations:
                // - Some gamepads uses d[0] and d[1] for X and Y axis.
                // - Some transmits a different set when d[0][1:0] is 2 (a dualshock adapater)
                case (rcvct)
                0: begin
                    if (ukpdat[1:0] != 2'b10) begin
                        // for DualShock2 adapter, 2'b10 marks an irrelevant record
                        valid <= 1;
                        game_l <= 0; game_r <= 0; game_u <= 0; game_d <= 0;
                    end else
                        valid <= 0;
                    if (ukpdat==8'h00) {game_l, game_r} <= 2'b10;
                    if (ukpdat==8'hff) {game_l, game_r} <= 2'b01;
                end
                1: begin
                    if (ukpdat==8'h00) {game_u, game_d} <= 2'b10;
                    if (ukpdat==8'hff) {game_u, game_d} <= 2'b01;
                end
                3: if (valid) begin 
                    if (ukpdat[7:6]==2'b00) {game_l, game_r} <= 2'b10;
                    if (ukpdat[7:6]==2'b11) {game_l, game_r} <= 2'b01;
                end
                4: if (valid) begin 
                    if (ukpdat[7:6]==2'b00) {game_u, game_d} <= 2'b10;
                    if (ukpdat[7:6]==2'b11) {game_u, game_d} <= 2'b01;
                end
                5: if (valid) begin
                    game_x <= ukpdat[4];
                    game_a <= ukpdat[5];
                    game_b <= ukpdat[6];
                    game_y <= ukpdat[7];
                end
                6: if (valid) begin
                    game_sel <= ukpdat[4];
                    game_sta <= ukpdat[5];
                end
                endcase
                // TODO: add any special handling if needed 
                // (using the detected controller type in 'dev')                
            end
            rcvct <= rcvct + 1;
        end
    end
    if(~data_rdy && data_rdy_r && typ != 0)    // falling edge of ukp data ready
        report <= 1;
end

reg save_delayed;
reg connected_r;
always @(posedge usbclk) begin : response_recognition
    save_delayed <= save;
    if (save) begin
        regs[save_r[2:0]] <= dat[save_b[2:0]];
    end else if (save_delayed && ~save && save_r == 6) begin     
        // falling edge of save for bInterfaceProtocol
        if (regs[4] == 3) begin  // bInterfaceClass. 3: HID, other: non-HID
            if (regs[5] == 1)    // bInterfaceSubClass. 1: Boot device
                typ <= regs[6] == 1 ? 1 : 2;     // bInterfaceProtocol. 1: keyboard, 2: mouse
            else
                typ <= 3;       // gamepad
        end else
            typ <= 0;                   
    end
    connected_r <= connected;
    if (~connected & connected_r) typ <= 0;   // clear device type on disconnect
end

endmodule

module ukp(
    input wire usbrst_n,
    input wire usbclk,				    // 12MHz clock
    input wire usb_dp_i, usb_dm_i,		// D+, D- input
    output wire usb_dp_o, usb_dm_o,     // D+, D- output
    output wire usb_oe,                 // Output Enable
    input wire req_branch_stb,          // When pulsed, UKP firmware will branch on the next 'br' instruction it executes.
    output reg ack_req_branch_stb,     // Indication that 'br' branch has been taken.
    input wire [7:0] outr0,             // 1-byte value to output on USB when 'outr0' instruction executes.
    input wire [7:0] outr1,             // 1-byte value to output on USB when 'outr1' instruction executes.
    input wire [7:0] outr2,             // 1-byte value to output on USB when 'outr2' instruction executes.
    output reg ukprdy, 			        // data frame is outputing
    output wire ukpstb,				    // strobe for a byte within the frame
    output reg [7:0] ukpdat,	        // output data when ukpstb=1
    output reg save,			        // save: regs[save_r] <= dat[save_b]
    output reg [3:0] save_r, save_b,
    output reg connected,
    output wire conerr
);

    parameter S_OPCODE = 0;
    parameter S_LDI0 = 1;
    parameter S_LDI1 = 2;
    parameter S_B0 = 3;
    parameter S_B1 = 4;
    parameter S_B2 = 5;
    parameter S_S0 = 6;
    parameter S_S1 = 7;
    parameter S_S2 = 8;
    parameter S_TOGGLE0 = 9;
    parameter S_TOGGLE1 = 10;

    reg    dpi, dmi; 
    reg    ukprdyd;

    wire [4:0] inst;
    reg  [4:0] insth;
    wire sample;						// 1: an IN sample is available
    // reg connected = 0;
    reg inst_ready = 0, up = 0, um = 0, cond = 0, nak = 0, dmis = 0;
    reg ug, nrzon;					// ug=1: output enabled, 0: hi-Z
    reg bank = 0, record1 = 0;
    reg [1:0] mbit = 0;					// 1: out4/outb is transmitting
    reg [3:0] state = 0;
    reg [7:0] wk = 0;					// W register
    reg [7:0] sb = 0;					// out value
    reg [3:0] sadr;						// out4/outb write ptr
    reg [13:0] pc, wpc;				    // program counter, wpc = next pc
    reg [2:0] timing = 0;				// T register (0~7)
    reg [3:0] lb4 = 0, lb4w;
    reg [13:0] interval = 0;
    reg [6:0] bitadr = 0;				// 0~127
    reg [7:0] data = 0;					// received data
    reg [2:0] nrztxct, nrzrxct;			// NRZI trans/recv count for bit stuffing
    wire interval_cy = interval == 12001;
    wire next = ~(state == S_OPCODE & (
        inst ==2 & dmi |								// start
        (inst==4 || inst==5) & timing != 0 |			// out0/hiz
        inst ==13 & (~sample | (dpi | dmi) & wk != 1) |	// in 
        inst ==14 & ~interval_cy						// wait
    ));
    wire branch = state == S_B1 & cond;
    wire retpc  = state == S_OPCODE && inst==7  ? 1 : 0;
    wire jmppc  = state == S_OPCODE && inst==15 ? 1 : 0;
    wire dbit   = sb[7-sadr[2:0]];
    wire record;
    reg req_branch_reg;
    reg  dmid;
    reg [23:0] conct;

    assign conerr = conct[23] || ~usbrst_n;
    
    usb_hid_host_rom ukprom(.clk(usbclk), .adr(pc), .data(inst));

    always @(posedge usbclk) begin
        if(~usbrst_n) begin 
            pc <= 0; connected <= 0; cond <= 0; inst_ready <= 0; state <= S_OPCODE; timing <= 0; 
            mbit <= 0; bitadr <= 0; nak <= 1; ug <= 0;
            req_branch_reg <= 0; ack_req_branch_stb <= 0;
        end else begin
            ack_req_branch_stb <= 1'b0;
            if (req_branch_stb) begin
                req_branch_reg <= 1'b1;
            end

            dpi <= usb_dp_i; dmi <= usb_dm_i;
            save <= 0;		// ensure pulse
            if (inst_ready) begin
                // Instruction decoding
                case(state)
                    S_OPCODE: begin
                        insth <= inst;
                        if(inst==1) state <= S_LDI0;						// op=ldi
                        if(inst==3) begin sadr <= 3; state <= S_S0; end		// op=out4
                        if(inst==4) begin ug <= 1'b1; up <= 0; um <= 0; end
                        if(inst==5) begin ug <= 0; end
                        if(inst==6) begin sadr <= 7; state <= S_S0; end		// op=outb
                        if (inst[4:2]==3'b010) begin					   // op=10xx(BZ,BC,BNAK,DJNZ)
                            state <= S_B0;
                            case (inst[1:0])
                                2'b00: cond <= ~dmi;
                                2'b01: cond <= connected;
                                2'b10: cond <= nak;
                                2'b11: cond <= wk != 1;
                            endcase
                        end
                        if(inst==11 | inst==13 & sample) wk <= wk - 8'd1;	// op=DJNZ,IN
                        if(inst==15) begin state <= S_B2; cond <= 1; end	// op=jmp
                        if(inst==12) state <= S_TOGGLE0;
                        if(inst==16) begin                                  // op=br
                            state <= S_B0;
                            cond <= req_branch_reg;
                            req_branch_reg <= 1'b0;
                            ack_req_branch_stb <= 1'b1;
                        end
                        if(inst==17) begin sadr <= 7; state <= S_S2; sb <= outr0; mbit <= 1; end    // op=outr0
                        if(inst==18) begin sadr <= 7; state <= S_S2; sb <= outr1; mbit <= 1; end    // op=outr1
                        if(inst==19) begin sadr <= 7; state <= S_S2; sb <= outr2; mbit <= 1; end    // op=outr2
                    end
                    // Instructions with operands
                    // ldi
                    S_LDI0: begin	wk[3:0] <= inst[3:0]; state <= S_LDI1;	end
                    S_LDI1: begin	wk[7:4] <= inst[3:0]; state <= S_OPCODE; end
                    // branch/jmp
                    S_B2: begin lb4w <= inst[3:0]; state <= S_B0; end
                    S_B0: begin lb4  <= inst[3:0]; state <= S_B1; end
                    S_B1: state <= S_OPCODE;
                    // out
                    S_S0: begin sb[3:0] <= inst[3:0]; state <= S_S1; end
                    S_S1: begin sb[7:4] <= inst[3:0]; state <= S_S2; mbit <= 1; end
                    // toggle and save
                    S_TOGGLE0: begin 
                        if (inst == 15) connected <= ~connected;// toggle
                        else save_r <= inst[3:0];                    // save
                        state <= S_TOGGLE1;
                      end
                    S_TOGGLE1: begin
                        if (inst != 15) begin
                            save_b <= inst[3:0];
                            save <= 1;
                        end
                        state <= S_OPCODE;
                    end
                endcase
                // pc control
                if (mbit==0) begin 
                    if(jmppc) wpc <= pc + 4;
                    if (next | branch | retpc) begin
                        if(retpc) pc <= wpc;					// ret
                        else if(branch)
                            if(insth==15)						// jmp
                                pc <= { inst[3:0], lb4, lb4w, 2'b00 };
                            else								// branch
                                pc <= { 4'b0000, inst[3:0], lb4, 2'b00 };
                        else	pc <= pc + 1;					// next
                        inst_ready <= 0;
                    end
                end
            end
            else inst_ready <= 1;
            // bit transmission (out4/outb/outr0)
            if (mbit==1 && timing == 0) begin
                if(ug==0) nrztxct <= 0;
                else
                    if(dbit) nrztxct <= nrztxct + 1;
                    else     nrztxct <= 0;
                if((insth == 5'd6) || (insth == 5'd17) || (insth == 5'd18) || (insth == 5'd19)) begin
                    if(nrztxct!=6) begin up <= dbit ?  up : ~up; um <= dbit ? ~up :  up; end
                    else           begin up <= ~up; um <= up; nrztxct <= 0; end
                end else begin
                    up <=  sb[{1'b1,sadr[1:0]}]; um <= sb[sadr[2:0]];
                end
                ug <= 1'b1; 
                if(nrztxct!=6) sadr <= sadr - 4'd1;
                if(sadr==0) begin mbit <= 0; state <= S_OPCODE; end
            end
            // start instruction
            dmid <= dmi;
            if (inst_ready & state == S_OPCODE & inst == 5'b00010) begin // op=start 
                bitadr <= 0; nak <= 1; nrzrxct <= 0;
            end else 
                if(ug==0 && dmi!=dmid) timing <= 1;
                else                   timing <= timing + 1;
            // IN instruction
            if (sample) begin
                if (bitadr == 8) nak <= dmi;
                if(nrzrxct!=6) begin
                    data[6:0] <= data[7:1]; 
                    data[7] <= dmis ~^ dmi;		    // ~^/^~ is XNOR, testing bit equality
                    bitadr <= bitadr + 1; nrzon <= 0;
                end else nrzon <= 1;
                dmis <= dmi;
                if(dmis ~^ dmi) nrzrxct <= nrzrxct + 1;
                else           nrzrxct <= 0;
                if (~dmi && ~dpi) ukprdy <= 0;      // SE0: packet is finished. Mouses send length 4 reports.
            end
            if (ug==0) begin
                if(bitadr==24) ukprdy <= 1;			// ignore first 3 bytes
                if(bitadr==88) ukprdy <= 0;			// output next 8 bytes
            end
            if ((bitadr>11 & bitadr[2:0] == 3'b000) & (timing == 2)) ukpdat <= data;
            // Timing
            interval <= interval_cy ? 0 : interval + 1;
            record1 <= record;
            if (~record & record1) bank <= ~bank;
            // Connection status & WDT
            ukprdyd <= ukprdy;
            if (ukprdy && ~ukprdyd || inst_ready && state == S_OPCODE && inst == 5'b00010) 
                conct <= 0;     // reset watchdog on data received or START instruction
            else begin 
                if(conct[23:22]!=2'b11) conct <= conct + 1;
                else begin pc <= 0; conct <= 0; end		// !! WDT ON
            end 
        end
    end

    assign usb_dp_o = up;
    assign usb_dm_o = um;
    assign usb_oe = ug;
    assign sample = inst_ready & state == S_OPCODE & inst == 5'b01101 & timing == 4; // IN
    assign record = connected & ~nak;
    assign ukpstb = ~nrzon & ukprdy & (bitadr[2:0] == 3'b100) & (timing == 2);
endmodule

