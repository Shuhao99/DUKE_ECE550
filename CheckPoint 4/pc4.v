module pc4(
	address_imem,InsPlus4
);
	input [11:0] address_imem;
	output [11:0] InsPlus4;
	wire  c_out, last_in;
	RCA_12bit (address_imem, 12'd4, 1'b0, c_out, InsPlus4, last_in);
endmodule
