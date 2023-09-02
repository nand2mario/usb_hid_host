//
// Example for using the usb_hid_host core
// nand2mario, 8/2023
//

module top (
    input sys_clk,
    // input sys_resetn,
    // input s1,

    // UART
    input UART_RXD,
    output UART_TXD,

    // LEDs
    output led,
    output [7:0] leds,

    // USB
    inout usbdm,
    inout usbdp
);

reg sys_resetn = 0;
// always @(posedge clk) begin
//     sys_resetn <= ~s1;
// end

wire clk = sys_clk;
wire clk_sdram = ~sys_clk;  
wire clk_usb;

// USB clock 12Mhz
clock clock(
    .clkin(sys_clk),
    .clk12(clk_usb),       // 12Mhz usb clock
    .clk100()
);

wire [1:0] usb_type;
wire [7:0] key_modifiers, key1, key2, key3, key4;
wire [7:0] mouse_btn;
wire signed [7:0] mouse_dx, mouse_dy;
wire [63:0] hid_report;
wire usb_report, usb_conerr, game_l, game_r, game_u, game_d, game_a, game_b, game_x, game_y;
wire game_sel, game_sta;

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

reg [22:0] cnt;
always @(posedge clk_usb) cnt <= cnt + 1;

// reg [7:0] uart_din;
// reg uart_wr;

// uart_tx_V2 uart(
//     .clk(clk_usb), .din(uart_din), .wr_en(uart_wr), .tx_busy(), .tx_p(UART_TXD)    
// );

// always @(posedge clk_usb) begin
//     uart_wr <= 0;
//     if (cnt == 0) begin
//         uart_din <= "A";
//         uart_wr <= 1;
//     end
// end

`include "print.vh"
// defparam tx.uart_freq=115200;
// defparam tx.clk_freq=12000000;
assign print_clk = clk_usb;
assign UART_TXD = uart_txp;

always @(posedge clk_usb) begin
    if (cnt[19:0] == 5'h00000) begin
        // `print("ABC\n", STR);
        int_print("ABC" << (1024-24), STR);
    end
end

// `include "utils.vh"                 // scancode2ascii()

// reg [19:0] timer;
// reg signed [10:0] mouse_x, mouse_y; // 0-1023
// wire [7:0] mouse_x2 = mouse_x + mouse_dx;
// wire [7:0] mouse_y2 = mouse_y + mouse_dy;
// reg [7:0] last_dx, last_dy; 

// reg start_print;
// reg [7:0] key_active[2];
// reg [7:0] keydown;                  // scancode of key just pressed
// reg [7:0] keyascii;                 // ascii of key just pressed

// reg [9:0] game_btns_r;
// wire [9:0] game_btns = {game_l, game_r, game_u, game_d, game_a, game_b, 
//                         game_x, game_y, game_sel, game_sta};

// always @(posedge clk_usb) begin
//     if(~sys_resetn) begin
//         `print("usb_hid_host demo. Connect keyboard, mouse or gamepad.\n",STR);
//     end else begin
//         if (timer == 20'hfffff) begin
//             if (start_print) begin
//                 timer <= 0;
//                 start_print <= 0;
//             end
//         end else
//             timer <= timer + 1;

//         // Simple ways to handle HID inputs
//         if (usb_report) begin

//             case (usb_type) 
//             1: begin        // keyboard
//                 // just catch all keydown events. no auto-repeat. no capslock. 
//                 // only 2 simultaneous keys. no special keys like arrows/insert/delete/keypad
//                 if (key1 != 0 && key1 != key_active[0] && key1 != key_active[1]) begin
//                     keydown <= key1; keyascii <= scancode2char(key1, key_modifiers);
//                 end else if (key2 != 0 && key2 != key_active[0] && key2 != key_active[1]) begin
//                     keydown <= key2; keyascii <= scancode2char(key2, key_modifiers);
//                 end
//                 key_active[0] <= key1; key_active[1] <= key2;
//                 start_print <= 1;
//             end
//             2: begin         // mouse
//                 last_dx <= mouse_dx; last_dy <= mouse_dy;
//                 mouse_x <= mouse_x2; mouse_y <= mouse_y2;
//                 if (mouse_x[10:9] == 2'b01 && mouse_x2 < 0) mouse_x <= 1023;  // overflow
//                 else if (mouse_x2 < 0) mouse_x <= 0;
//                 if (mouse_y[10:9] == 2'b01 && mouse_y2 < 0) mouse_y <= 1023;
//                 else if (mouse_y2 < 0) mouse_y = 0;
//                 start_print <= 1;
//             end
//             3: begin        // gamepad
//                 // check if button status is changed
//                 if (game_btns != game_btns_r)
//                     start_print <= 1;
//                 game_btns_r <= game_btns;
//             end
//             endcase
//         end

//         // print result to UART
//         case (usb_type)
//         1: if (start_print && keyascii != 0) begin
//             `print(keyascii, STR);
//             keyascii <= 0;
//             start_print <= 0;
//            end

//         2:  case (timer)                                    // print mouse position
//             20'h00000: `print("\x0dMouse: x=", STR);        // there's no \r ...
//             20'h10000: `print({6'b0, mouse_x[9:0]}, 2);
//             20'h20000: `print(", y=", STR);
//             20'h30000: `print({6'b0, mouse_y[9:0]}, 2);
//             20'h40000: `print(mouse_btn[0] ? " L" : " _", STR);
//             20'h50000: `print(mouse_btn[1] ? " R" : " _", STR);
//             20'h60000: `print(mouse_btn[2] ? " M        " : " _        ", STR);
//             endcase
//         3: case(timer)                                      // print gamepad status
//             20'h00000: `print("\x0dGamepad:", STR);
//             20'h10000: `print(game_l ? " L" : " _", STR);
//             20'h20000: `print(game_u ? " U" : " _", STR);
//             20'h30000: `print(game_r ? " R" : " _", STR);
//             20'h40000: `print(game_d ? " D" : " _", STR);
//             20'h50000: `print(game_a ? " A" : " _", STR);
//             20'h60000: `print(game_b ? " B" : " _", STR);
//             20'h70000: `print(game_x ? " X" : " _", STR);
//             20'h80000: `print(game_y ? " Y" : " _", STR);
//             20'h90000: `print(game_sel ? " SE" : " __", STR);
//             20'ha0000: `print(game_sta ? " ST" : " __", STR);
//             20'hb0000: `print("         ", STR);
//             endcase
//         endcase
//     end

//     // print raw reports
//    case (cnt[19:0])
//    20'h00000: `print(hid_report, 8); 
//    20'h10000: `print(", type=", STR); 
//    20'h20000: `print({6'b0, usb_type}, 1); 
//    20'h30000: `print(", regs=", STR);
//    20'h40000: `print({hid_regs[4], hid_regs[5], hid_regs[6]}, 3);
//    20'hf0000: `print("\n", STR); 
//    endcase

// end

reg report_toggle;      // blinks whenever there's a report
always @(posedge clk_usb) if (usb_report) report_toggle <= ~report_toggle;

// assign led = ~{usb_type, 2'b0, usb_conerr, report_toggle};

assign led = cnt[22];

endmodule