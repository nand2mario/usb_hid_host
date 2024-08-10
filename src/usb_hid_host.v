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
    input  usbclk,		            // 12MHz clock
    input  usbrst_n,	            // reset
    inout  usb_dm, usb_dp,          // USB D- and D+
    output reg [1:0] typ,           // device type. 0: no device, 1: keyboard, 2: mouse, 3: gamepad
    output reg report,              // pulse after report received from device. 
                                    // key_*, mouse_*, game_* valid depending on typ
    output conerr,                  // connection or protocol error
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
    output [63:0] dbg_hid_report	// last HID report
);

wire data_rdy;          // data ready
wire data_strobe;       // data strobe for each byte
wire [7:0] ukpdat;		// actual data
reg [7:0] regs [7];     // 0 (VID_L), 1 (VID_H), 2 (PID_L), 3 (PID_H), 4 (INTERFACE_CLASS), 5 (INTERFACE_SUBCLASS), 6 (INTERFACE_PROTOCOL)
wire save;			    // save dat[b] to output register r
wire [3:0] save_r;      // which register to save to
wire [3:0] save_b;      // dat[b]
wire connected;

ukp ukp(
    .usbrst_n(usbrst_n), .usbclk(usbclk),
    .usb_dp(usb_dp), .usb_dm(usb_dm), .usb_oe(),
    .ukprdy(data_rdy), .ukpstb(data_strobe), .ukpdat(ukpdat), .save(save), .save_r(save_r), .save_b(save_b),
    .connected(connected), .conerr(conerr));

reg  [3:0] rcvct;		// counter for recv data
reg  data_strobe_r, data_rdy_r;	// delayed data_strobe and data_rdy
reg  [7:0] dat[8];		// data in last response
assign dbg_hid_report = {dat[7], dat[6], dat[5], dat[4], dat[3], dat[2], dat[1], dat[0]};
// assign dbg_regs = regs;

localparam TYP_NONE = 2'b00;
localparam TYP_KEYB = 2'b01;
localparam TYP_MOUS = 2'b10;
localparam TYP_GAME = 2'b11;
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
    if(~data_rdy) rcvct <= 0;
    else begin
        if(data_strobe && ~data_strobe_r) begin  // rising edge of ukp data strobe
            dat[rcvct] <= ukpdat;

            if (typ == TYP_KEYB) begin     // keyboard
                case (rcvct)
                0: key_modifiers <= ukpdat;
                2: key1 <= ukpdat;
                3: key2 <= ukpdat;
                4: key3 <= ukpdat;
                5: key4 <= ukpdat;
                endcase
            end else if (typ == TYP_MOUS) begin    // mouse
                case (rcvct)
                0: mouse_btn <= ukpdat;
                1: mouse_dx <= ukpdat;
                2: mouse_dy <= ukpdat;
                endcase
            end else if (typ == TYP_GAME) begin    // gamepad
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
            rcvct <= ((rcvct + 1) & 4'b1111);
        end
    end
    if(~data_rdy && data_rdy_r && typ != TYP_NONE)    // falling edge of ukp data ready
        report <= 1;
end

reg save_delayed;
reg connected_r;
always @(posedge usbclk) begin : response_recognition // (this is a SystemVerilog block name)
    save_delayed <= save;
    if (save) begin
        regs[save_r] <= dat[save_b];
    end else if (save_delayed && ~save && save_r == 6) begin     
        // falling edge of save for bInterfaceProtocol
        if (regs[4] == 3) begin        // bInterfaceClass. 3: HID, other: non-HID
            if (regs[5] == 1) begin    // bInterfaceSubClass. 1: Boot device
                // bInterfaceProtocol. 1: keyboard, 2: mouse
                if      (regs[6] == 1) typ <= TYP_KEYB; 
                else if (regs[6] == 2) typ <= TYP_MOUS;
                else                   typ <= TYP_NONE;
            end else
                typ <= TYP_GAME;       // gamepad
        end else
            typ <= TYP_NONE;           // TODO: eg XBOX controller has 0xFF (proprietary) ID       
    end
    connected_r <= connected;
    if (~connected & connected_r) typ <= 0;   // clear device type on disconnect
end

endmodule // usb_hid_host

//---------------------------------------------------------------------

module ukp (
    input usbrst_n,
    input usbclk,				// 12MHz clock
    inout usb_dp, usb_dm,		// D+, D-
    output usb_oe,
    output reg ukprdy, 			// data frame is outputing
    output ukpstb,				// strobe for a byte within the frame
    output reg [7:0] ukpdat,	// output data when ukpstb=1
    output reg save,			// save: regs[save_r] <= dat[save_b]
    output reg [3:0] save_r, save_b,
    output reg connected,
    output conerr
);

    // state machine states
    localparam S_OPCODE  = 4'd0;
    localparam S_LDI0    = 4'd1;
    localparam S_LDI1    = 4'd2;
    localparam S_B0      = 4'd3;
    localparam S_B1      = 4'd4;
    localparam S_B2      = 4'd5;
    localparam S_S0      = 4'd6;
    localparam S_S1      = 4'd7;
    localparam S_S2      = 4'd8;
    localparam S_TOGGLE0 = 4'd9;
    localparam S_TOGGLE1 = 4'd10;

    // OPCODES
    localparam OP_NOP    = 4'h0;    // NOP -- No operation
    localparam OP_LDI    = 4'h1;    // LDI cc -- Load 8-bit constant into W
    localparam OP_START	 = 4'h2;    // START -- Wait until D- becomes 0 and clear the T counter
    localparam OP_OUT4   = 4'h3;    // OUT4 -- output 4 bits
    localparam OP_OUT0	 = 4'h4;    // Output 0 on both D+ and D-
    localparam OP_HIZ	 = 4'h5;    // Set both D+ and D- to hi-impedance
    localparam OP_OUTB	 = 4'h6;    // Output a byte (8 bits)
    localparam OP_RET	 = 4'h7;    // Return to the next instruction of last jump
    localparam OP_BZ     = 4'h8;    // aa	Jump if D- is 0
    localparam OP_BC     = 4'h9;    // aa	Jump if C flag is 1
    localparam OP_BNAK   = 4'hA;    //  aa	Jump if previous response was NAK/STALL
    localparam OP_DJNZ   = 4'hB;    // aa	Decrement W register, jump if not 0
    localparam OP_TOGGLE = 4'hC;    // C f f --	Toggle C flag
    localparam OP_SAVE   = 4'hC;    // C r b -- Save receive buffer byte b into output register r
    localparam OP_IN     = 4'hD;    // IN -- Wait until the T counter reaches the sampling timing. If both D+ and D- are 0, proceed to the next instruction. Otherwise, decrement the W register and if it is 0, go to the next instruction.
    localparam OP_WAIT	 = 4'hE;    // WAIT -- Wait for 1ms timing
    localparam OP_JMP    = 4'hF;    // JMP aa -- Jump to address

    wire [3:0] inst;
    reg  [3:0] insth;
    wire sample;						// 1: an IN sample is available
    // reg connected = 0;
    reg inst_ready = 0, up = 0, um = 0, cond = 0, nak = 0, dmis = 0;
    reg ug, ugw, nrzon;					// ug=1: output enabled, 0: hi-Z
    reg bank = 0, record1 = 0;
    reg [1:0] mbit = 0;					// 1: out4/outb is transmitting
    reg [3:0] state = 0, stated;
    reg [7:0] wk = 0;					// W register
    reg [7:0] sb = 0;					// out value
    reg [3:0] sadr;						// out4/outb write ptr
    reg [13:0] pc = 0, wpc;				// program counter, wpc = next pc
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
    reg  dmid;
    reg [23:0] conct;
    assign conerr = conct[23] || ~usbrst_n;

    usb_hid_host_rom ukprom(.clk(usbclk), .adr(pc), .data(inst));

    always @(posedge usbclk) begin
        if(~usbrst_n) begin 
            pc <= 0; connected <= 0; cond <= 0; inst_ready <= 0; state <= S_OPCODE; timing <= 0; 
            mbit <= 0; bitadr <= 0; nak <= 1; ug <= 0;
        end else begin
            dpi <= usb_dp; dmi <= usb_dm;
            save <= 0;		// ensure pulse
            if (inst_ready) begin
                // Instruction decoding
                case (state)
                    S_OPCODE: begin
                        insth <= inst;
                        if (inst == OP_LDI) state <= S_LDI0;
                        if (inst == OP_OUT4) begin sadr <= 3; state <= S_S0; end
                        if (inst == OP_OUT0) begin ug <= 1; up <= 0; um <= 0; end
                        if (inst == OP_HIZ) begin ug <= 0; end
                        if (inst == OP_OUTB) begin sadr <= 7; state <= S_S0; end
                        if (inst[3:2]==2'b10) begin // op=10xx(BZ,BC,BNAK,DJNZ)
                            state <= S_B0;
                            case (inst)
                                OP_BZ:   cond <= ~dmi;
                                OP_BC:   cond <= connected;
                                OP_BNAK: cond <= nak;
                                OP_DJNZ: cond <= wk != 1;
                            endcase
                        end
                        if (inst == OP_DJNZ | inst == OP_IN & sample) wk <= wk - 8'd1;
                        if (inst == OP_JMP) begin state <= S_B2; cond <= 1; end
                        if (inst == OP_TOGGLE) state <= S_TOGGLE0;
                    end
                    // Instructions with operands
                    // ldi
                    S_LDI0: begin	wk[3:0] <= inst; state <= S_LDI1;	end
                    S_LDI1: begin	wk[7:4] <= inst; state <= S_OPCODE; end
                    // branch/jmp
                    S_B2: begin lb4w <= inst; state <= S_B0; end
                    S_B0: begin lb4  <= inst; state <= S_B1; end
                    S_B1: state <= S_OPCODE;
                    // out
                    S_S0: begin sb[3:0] <= inst; state <= S_S1; end
                    S_S1: begin sb[7:4] <= inst; state <= S_S2; mbit <= 1; end
                    // toggle and save
                    S_TOGGLE0: begin 
                        if (inst == 4'hF) connected <= ~connected;// toggle (C f f)
                        else save_r <= inst;                    // save (C r b)
                        state <= S_TOGGLE1;
                      end
                    S_TOGGLE1: begin
                        if (inst != 4'hF) begin save_b <= inst; save <= 1; end
                        state <= S_OPCODE;
                    end
                endcase // state
                // pc control
                if (mbit==0) begin 
                    if (jmppc) wpc <= ((pc + 4) & 14'h3fff);
                    if (next | branch | retpc) begin
                        if(retpc) pc <= wpc;					// ret
                        else if (branch)
                            if (insth == OP_JMP)				// jmp
                                pc <= { inst, lb4, lb4w, 2'b00 };
                            else								// branch
                                pc <= { 4'b0000, inst, lb4, 2'b00 };
                        else	pc <= ((pc + 1) & 14'h3fff);	// next
                        inst_ready <= 0;
                    end
                end
            end // if (inst_ready)
            else inst_ready <= 1;
            // bit transmission (out4/outb)
            if (mbit == 1 && timing == 0) begin
                if (ug == 0) nrztxct <= 0;
                else
                    if (dbit) nrztxct <= ((nrztxct + 1) & 3'b111);
                    else      nrztxct <= 0;
                if(insth == 4'd6) begin
                    if (nrztxct!=6) begin up <= dbit ? up : ~up; um <= dbit ? ~up : up; end
                    else            begin up <= ~up; um <= up; nrztxct <= 0; end
                end else begin
                    up <=  sb[{1'b1,sadr[1:0]}]; um <= sb[sadr[2:0]];
                end
                ug <= 1; 
                if (nrztxct != 6) sadr <= sadr - 4'd1;
                if (sadr == 0)    begin mbit <= 0; state <= S_OPCODE; end
            end
            // start instruction
            dmid <= dmi;
            if (inst_ready & state == S_OPCODE & inst == OP_START) begin
                bitadr <= 0; nak <= 1; nrzrxct <= 0;
            end else 
                if (ug == 0 && dmi != dmid) timing <= 1;
                else                        timing <= ((timing + 1) & 3'b111);
            // IN instruction
            if (sample) begin
                if (bitadr == 8) nak <= dmi;
                if (nrzrxct != 6) begin
                    data[6:0] <= data[7:1]; 
                    data[7] <= dmis ~^ dmi;		    // ~^/^~ is XNOR, testing bit equality
                    bitadr <= ((bitadr + 1) & 7'h7f);
                    nrzon <= 0;
                end else nrzon <= 1;
                dmis <= dmi;
                if (dmis ~^ dmi) nrzrxct <= ((nrzrxct + 1) & 3'b111);
                else             nrzrxct <= 0;
                if (~dmi && ~dpi) ukprdy <= 0;      // SE0: packet is finished. Mouses send length 4 reports.
            end
            if (ug == 0) begin
                if(bitadr==24) ukprdy <= 1;			// ignore first 3 bytes
                if(bitadr==88) ukprdy <= 0;			// output next 8 bytes
            end
            if ((bitadr > 11 & bitadr[2:0] == 3'b000) & (timing == 2)) ukpdat <= data;
            // Timing
            interval <= interval_cy ? 0 : ((interval + 1) & 14'h3fff);
            record1 <= record;
            if (~record & record1) bank <= ~bank;
            // Connection status & WDT
            ukprdyd <= ukprdy;
            nakd <= nak;
            if (ukprdy && ~ukprdyd || inst_ready && state == S_OPCODE && inst == OP_START) 
                conct <= 0;     // reset watchdog on data received or START instruction
            else begin 
                if (conct[23:22] != 2'b11) conct <= ((conct + 1) & 24'hffffff);
                else begin pc <= 0; conct <= 0; end		// !! WDT ON
            end 
        end
    end

    assign usb_dp = ug ? up : 1'bZ;
    assign usb_dm = ug ? um : 1'bZ;
    assign usb_oe = ug;
    assign sample = inst_ready & state == S_OPCODE & inst == 4'b1101 & timing == 4; // IN
    assign record = connected & ~nak;
    assign ukpstb = ~nrzon & ukprdy & (bitadr[2:0] == 3'b100) & (timing == 2);
    reg    dpi, dmi; 
    reg    ukprdyd;
    reg    nakd;
endmodule

