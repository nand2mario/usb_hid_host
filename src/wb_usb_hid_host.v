module wb_usb_hid_host (
    input  wire wb_clk,                  // Wishbone clock - assumed to be faster than usb_clock, e.g. 50MHz.
    input  wire usb_clk,		            // 12MHz clock
    input  wire usb_rst_n,                  // USB clock domain active low reset
    input  wire sys_rst_n,                  // System clock domain active low reset
    input  wire usb_dm_i, usb_dp_i,         // USB D- and D+ input
    output wire usb_dm_o, usb_dp_o,         // USB D- and D+ output    
    output wire usb_oe,
    output wire irq,     

    //32-bit pipelined Wishbone slave interface.
    input wire [3:0] wbs_adr,
	input wire [31:0] wbs_dat_w,
	output reg [31:0] wbs_dat_r,
	input wire [3:0] wbs_sel,
    output wire wbs_stall,
	input wire wbs_cyc,
	input wire wbs_stb,
	output wire wbs_ack,
	input wire wbs_we,
	output wire wbs_err          
);

    reg wb_usb_report_ien;
    wire wb_usb_report_stb;
    reg wb_usb_report_isr;

    reg [1:0] wb_usb_typ;
    reg wb_usb_conn_err;

    // keyboard
    reg [7:0] wb_usb_key_modifiers;
    reg [7:0] wb_usb_key1, wb_usb_key2, wb_usb_key3, wb_usb_key4;

    // mouse
    reg [7:0] wb_usb_mouse_btn;     // {5'bx, middle, right, left}
    reg signed [7:0] wb_usb_mouse_dx;      // signed 8-bit, cleared after `report` pulse
    reg signed [7:0] wb_usb_mouse_dy;      // signed 8-bit, cleared after `report` pulse

    // gamepad 
    reg wb_usb_game_l, wb_usb_game_r, wb_usb_game_u, wb_usb_game_d;  // left right up down
    reg wb_usb_game_a, wb_usb_game_b, wb_usb_game_x, wb_usb_game_y, wb_usb_game_sel, wb_usb_game_sta;  // buttons

    reg [63:0] wb_usb_dbg_hid_report;	// last HID report

    reg wb_usb_rst_n;
    (* ASYNC_REG = "TRUE" *) reg [1:0] wb_usb_rst_xfer_pipe;

    wire [1:0] usb_typ;
    wire usb_report;
    reg wb_usb_report_prev, wb_usb_report_new;
    (* ASYNC_REG = "TRUE" *) reg [1:0] usb_report_xfer_pipe; //Synchronization FFs.

    wire usb_conn_err;

    // keyboard
    wire [7:0] usb_key_modifiers;
    wire [7:0] usb_key1, usb_key2, usb_key3, usb_key4;

    // mouse
    wire [7:0] usb_mouse_btn;     // {5'bx, middle, right, left}
    wire signed [7:0] usb_mouse_dx;      // signed 8-bit, cleared after `report` pulse
    wire signed [7:0] usb_mouse_dy;      // signed 8-bit, cleared after `report` pulse

    // gamepad 
    wire usb_game_l, usb_game_r, usb_game_u, usb_game_d;  // left right up down
    wire usb_game_a, usb_game_b, usb_game_x, usb_game_y, usb_game_sel, usb_game_sta;  // buttons

    // debug
    wire [63:0] usb_dbg_hid_report;	// last HID report

    // Wishbone
    reg do_ack_wbs;
    wire do_wbs_wr_reg;
    wire unused = &{wbs_sel, wbs_dat_w[31:1]};

    // Request UKP to branch
    reg wb_req_branch, wb_ack_req_branch, usb_req_branch;
    wire usb_ack_req_branch;
    (* ASYNC_REG = "TRUE" *) reg [1:0] wb_ack_req_branch_xfer_pipe;
    (* ASYNC_REG = "TRUE" *) reg [1:0] usb_req_branch_xfer_pipe;

    always @(posedge wb_clk) begin
        if (do_wbs_wr_reg && (wbs_adr == 4'd9)) wb_req_branch <= 1'b1;
        else if (wb_ack_req_branch) wb_req_branch <= 1'b0;
    end
    
    reg wb_set_leds, usb_set_leds, wb_ack_set_leds, usb_ack_set_leds;
    (* ASYNC_REG = "TRUE" *) reg [1:0] usb_set_leds_xfer_pipe;
    (* ASYNC_REG = "TRUE" *) reg [1:0] wb_ack_set_leds_xfer_pipe;
    
    reg [3:0] wb_leds; 
    reg [3:0] usb_leds;

    always @(posedge wb_clk) begin
        if (do_wbs_wr_reg && (wbs_adr == 4'd10)) begin
            wb_set_leds <= 1'b1;
            wb_leds <= wbs_dat_w[3:0];
        end
        else if (wb_ack_set_leds) begin
            wb_set_leds <= 1'b0;
        end
    end

    usb_hid_host usb_hid_host_inst (
        .usbclk(usb_clk),		            // 12MHz clock
        .usbrst_n(usb_rst_n),	            // reset
        .usb_dm_i(usb_dm_i), 
        .usb_dp_i(usb_dp_i),          // USB D- and D+ input
        .usb_dm_o(usb_dm_o), 
        .usb_dp_o(usb_dp_o),          // USB D- and D+ output
        .usb_oe(usb_oe),
        .req_branch(usb_req_branch),
        .ack_req_branch(usb_ack_req_branch),
        .leds(usb_leds),
        .typ(usb_typ),           // device type. 0: no device, 1: keyboard, 2: mouse, 3: gamepad
        .report(usb_report),              // pulse after report received from device. 
                                    // key_*, mouse_*, game_* valid depending on typ
        .conerr(usb_conn_err),                  // connection or protocol error

        // keyboard
        .key_modifiers(usb_key_modifiers),
        .key1(usb_key1), 
        .key2(usb_key2), 
        .key3(usb_key3), 
        .key4(usb_key4),

        // mouse
        .mouse_btn(usb_mouse_btn),     // {5'bx, middle, right, left}
        .mouse_dx(usb_mouse_dx),      // signed 8-bit, cleared after `report` pulse
        .mouse_dy(usb_mouse_dy),      // signed 8-bit, cleared after `report` pulse

        // gamepad 
        .game_l(usb_game_l), 
        .game_r(usb_game_r), 
        .game_u(usb_game_u), 
        .game_d(usb_game_d),  // left right up down
        .game_a(usb_game_a), 
        .game_b(usb_game_b), 
        .game_x(usb_game_x), 
        .game_y(usb_game_y), 
        .game_sel(usb_game_sel), 
        .game_sta(usb_game_sta),  // buttons

        // debug
        .dbg_hid_report(usb_dbg_hid_report)	// last HID report
    );

    //Synchronize the usb_report and ack_req_branch pulse
    always @(posedge wb_clk) begin
	    {wb_usb_report_prev, wb_usb_report_new, usb_report_xfer_pipe} <= {wb_usb_report_new, usb_report_xfer_pipe, usb_report};
	    {wb_usb_rst_n, wb_usb_rst_xfer_pipe} <= {wb_usb_rst_xfer_pipe, usb_rst_n};
        {wb_ack_req_branch, wb_ack_req_branch_xfer_pipe} <= {wb_ack_req_branch_xfer_pipe, usb_ack_req_branch};
        {wb_ack_set_leds, wb_ack_set_leds_xfer_pipe} <= {wb_ack_set_leds_xfer_pipe, usb_ack_set_leds};
    end

    //Synchronize the req_branch signal
    always @(posedge usb_clk) begin
        {usb_req_branch, usb_req_branch_xfer_pipe} <= {usb_req_branch_xfer_pipe, wb_req_branch};
        {usb_set_leds, usb_set_leds_xfer_pipe} <= {usb_set_leds_xfer_pipe, wb_set_leds};

        if (usb_set_leds) begin
            usb_leds <= wb_leds;
            usb_ack_set_leds <= 1'b1;
        end
        else begin
            usb_ack_set_leds <= 1'b0;
        end
    end

    assign wb_usb_report_stb = (!wb_usb_report_prev) && (wb_usb_report_new);

    assign irq = wb_usb_report_isr && wb_usb_report_ien;

    //WB slave handshake
    assign do_wbs_wr_reg = wbs_cyc && wbs_stb && wbs_we;

    always @(posedge wb_clk) begin 
        if (!sys_rst_n) begin
            do_ack_wbs <=  1'b0;
        end
        else begin
            do_ack_wbs <= 1'b0;
            if (wbs_stb) begin
                do_ack_wbs <= 1'b1;
            end
        end
    end

    assign wbs_ack = do_ack_wbs & wbs_cyc;
    assign wbs_stall = 1'b0;
    assign wbs_err = 1'b0;

    //Register events on the WB clock domain side
    always @(posedge wb_clk) begin
        if ((!wb_usb_rst_n) || (!sys_rst_n)) begin
            if (!sys_rst_n) wb_usb_report_ien <= 1'b0;
            wb_usb_report_isr <= 1'b0;
            wb_usb_typ <= 2'b00;
            wb_usb_conn_err <= 1'b0;
        end
        else if ((wb_usb_report_stb) && (usb_typ!=0)) begin
            wb_usb_report_isr <= 1'b1;
            {wb_usb_typ, wb_usb_conn_err} <= {usb_typ, usb_conn_err};
            {wb_usb_key_modifiers, wb_usb_key1, wb_usb_key2, wb_usb_key3, wb_usb_key4} <= {usb_key_modifiers, usb_key1, usb_key2, usb_key3, usb_key4};
            {wb_usb_mouse_btn, wb_usb_mouse_dx, wb_usb_mouse_dy} <= {usb_mouse_btn, usb_mouse_dx, usb_mouse_dy};
            {wb_usb_game_l, wb_usb_game_r, wb_usb_game_u, wb_usb_game_d, wb_usb_game_a, wb_usb_game_b, wb_usb_game_x, wb_usb_game_y, wb_usb_game_sel, wb_usb_game_sta}
                <= {usb_game_l, usb_game_r, usb_game_u, usb_game_d, usb_game_a, usb_game_b, usb_game_x, usb_game_y, usb_game_sel, usb_game_sta}; 
            wb_usb_dbg_hid_report <= usb_dbg_hid_report;
        end
        //WBS register writes
        else if (do_wbs_wr_reg) begin
            if (wbs_adr== 4'd0) begin
                wb_usb_report_ien <= wbs_dat_w[0];
            end
            else if (wbs_adr == 4'd1) begin
                wb_usb_report_isr <= 1'b0;
            end
        end
    end

    //WBS register reads
    always @* begin
        case(wbs_adr) //wbs address is a word address.
            4'd0: wbs_dat_r = {31'b0, wb_usb_report_ien};
            4'd1: wbs_dat_r = {31'b0, wb_usb_report_isr};
            4'd2: wbs_dat_r = {29'b0, wb_usb_conn_err, wb_usb_typ};
            4'd3: wbs_dat_r = {24'b0, wb_usb_key_modifiers}; 
            4'd4: wbs_dat_r = {wb_usb_key4, wb_usb_key3, wb_usb_key2, wb_usb_key1};
            4'd5: wbs_dat_r = {8'b0, wb_usb_mouse_btn, wb_usb_mouse_dx, wb_usb_mouse_dy};
            4'd6: wbs_dat_r = {22'b0, wb_usb_game_l, wb_usb_game_r, wb_usb_game_u, wb_usb_game_d, wb_usb_game_a, wb_usb_game_b, wb_usb_game_x, wb_usb_game_y, wb_usb_game_sel, wb_usb_game_sta};
            4'd7: wbs_dat_r = wb_usb_dbg_hid_report[31:0];
            4'd8: wbs_dat_r = wb_usb_dbg_hid_report[63:32];
            default: wbs_dat_r = 32'd0;
        endcase
    end
endmodule
