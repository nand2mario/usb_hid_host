/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:        48.000 MHz
 * Requested output frequency:   24.000 MHz
 * Achieved output frequency:    24.000 MHz
 */

module clock(
	input  clkin,
	output clk24,
	output locked
	);

SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0001111),	// DIVF = 15
		.DIVQ(3'b101),		// DIVQ =  5
		.FILTER_RANGE(3'b100)	// FILTER_RANGE = 4
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.REFERENCECLK(clkin),
		.PLLOUTCORE(clk24)
		);

endmodule
