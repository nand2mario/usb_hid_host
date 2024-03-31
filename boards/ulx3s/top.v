//
// Example using the usb_hid_host core for ULX3S
// based on the icesugar-pro example by nand2mario, 8/2023
//

module top (
    input clk_25mhz,

    // UART
    input ftdi_txd,
    output ftdi_rxd,

    // BUTTONs
    input [6:0] btn,

    // LEDs
    output [7:0] led,

    // USB
    inout usb_fpga_bd_dn,
    inout usb_fpga_bd_dp,
    
    output usb_fpga_pu_dn,
    output usb_fpga_pu_dp
);

wire sys_resetn = ~btn[1];
wire [3:0] clocks1, clocks2;
wire clk_60mhz;
wire clk_usb;
wire [1:0] usb_type;
wire [7:0] key_modifiers, key1, key2, key3, key4;
wire [7:0] mouse_btn;
wire signed [7:0] mouse_dx, mouse_dy;
wire [63:0] hid_report;
wire usb_report, usb_conerr, game_l, game_r, game_u, game_d, game_a, game_b, game_x, game_y;
wire game_sel, game_sta;
wire [13:0] dbg_pc;
wire [3:0] dbg_inst;

assign usb_fpga_pu_dn = 1'b0; // host pull down 10k
assign usb_fpga_pu_dp = 1'b0; // host pull down 10k

ecp5pll
#(
      .in_hz(25000000), // 25 MHz input
    .out0_hz(60000000), // 60 MHz output
)
ecp5pll_inst_1
(
    .clk_i(clk_25mhz),
    .clk_o(clocks1)
);
assign clk_60mhz = clocks1[0];

ecp5pll
#(
      .in_hz(60000000), // 60 MHz input
    .out0_hz(12000000), // 12 MHz output
)
ecp5pll_inst_2
(
    .clk_i(clk_60mhz),
    .clk_o(clocks2),
    .locked(clk_locked)
);
assign clk_usb = clocks2[0];

usb_hid_host usb (
    .usbclk(clk_usb), .usbrst_n(sys_resetn),
    .usb_dm(usb_fpga_bd_dn), .usb_dp(usb_fpga_bd_dp),
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
    .uart_tx(ftdi_rxd), .usb_type(usb_type), .usb_report(usb_report),
    .key_modifiers(key_modifiers), .key1(key1), .key2(key2), .key3(key3), .key4(key4),
    .mouse_btn(mouse_btn), .mouse_dx(mouse_dx), .mouse_dy(mouse_dy),
    .game_l(game_l), .game_r(game_r), .game_u(game_u), .game_d(game_d),
    .game_a(game_a), .game_b(game_b), .game_x(game_x), .game_y(game_y), 
    .game_sel(game_sel), .game_sta(game_sta)
);

reg report_toggle;      // blinks whenever there's a report
always @(posedge clk_usb) if (usb_report) report_toggle <= ~report_toggle;

assign led[7:4] = 0;
assign led[  3] = ~sys_resetn;
assign led[  2] = report_toggle; // green
assign led[1:0] = usb_type; // orange, red

endmodule
