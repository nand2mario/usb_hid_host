module usb_hid_host_rom(
	input wire clk, 
	input wire [13:0] adr, 
	output reg [3:0] data);
	
	reg [3:0] mem [0:616];
	initial $readmemh("usb_hid_host_rom.hex", mem);
	always @(posedge clk) data <= mem[adr[9:0]];
endmodule
