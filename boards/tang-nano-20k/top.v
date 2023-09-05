//
// Example for using the usb_hid_host core
// nand2mario, 8/2023
//

module usb_hid_host_demo (
    input sys_clk,
    // input sys_resetn,
    input s1,

    // UART
    input UART_RXD,
    output UART_TXD,

    // LEDs
    output [5:0] led,

    // USB
    inout usbdm,
    inout usbdp

);

reg sys_resetn = 0;
always @(posedge clk) begin
    sys_resetn <= ~s1;
end

wire clk = sys_clk;
wire clk_sdram = ~sys_clk;  
wire clk_usb;

// USB clock 12Mhz
Gowin_rPLL_usb pll_nes(
    .clkin(sys_clk),
    .clkout(clk_usb),       // 12Mhz usb clock
    .clkoutp()
);

wire [1:0] usb_type;
wire [7:0] key_modifiers, key1, key2, key3, key4;
wire [7:0] mouse_btn;
wire signed [7:0] mouse_dx, mouse_dy;
wire [63:0] hid_report;
wire [7:0] hid_regs [7];

usb_hid_host usb (
    .usbclk(clk_usb), .usbrst_n(sys_resetn),
    .usb_dm(usbdm), .usb_dp(usbdp),	
    .typ(usb_type), .report(usb_report),
    .key_modifiers(key_modifiers), .key1(key1), .key2(key2), .key3(key3), .key4(key4),
    .mouse_btn(mouse_btn), .mouse_dx(mouse_dx), .mouse_dy(mouse_dy),
    .game_l(game_l), .game_r(game_r), .game_u(game_u), .game_d(game_d),
    .game_a(game_a), .game_b(game_b), .game_x(game_x), .game_y(game_y), 
    .game_sel(game_sel), .game_sta(game_sta),
    .conerr(usb_conerr), .dbg_hid_report(hid_report)
);

hid_printer prt (
    .clk(clk_usb), .resetn(sys_resetn),
    .uart_tx(UART_TXD), .usb_type(usb_type), .usb_report(usb_report),
    .key_modifiers(key_modifiers), .key1(key1), .key2(key2), .key3(key3), .key4(key4),
    .mouse_btn(mouse_btn), .mouse_dx(mouse_dx), .mouse_dy(mouse_dy),
    .game_l(game_l), .game_r(game_r), .game_u(game_u), .game_d(game_d),
    .game_a(game_a), .game_b(game_b), .game_x(game_x), .game_y(game_y), 
    .game_sel(game_sel), .game_sta(game_sta)
);

reg report_toggle;      // blinks whenever there's a report
always @(posedge clk_usb) if (usb_report) report_toggle <= ~report_toggle;

assign led = ~{usb_type, 2'b0, usb_conerr, report_toggle};

endmodule