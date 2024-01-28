module usb_hid_host_rom(
	input wire clk,
	input wire [13:0] adr,
	output reg [4:0] data);
	reg [4:0] mem [0:620];
	initial $readmemh("usb_hid_host_rom.hex", mem);
	always @(posedge clk) data <= mem[adr[9:0]];
endmodule
