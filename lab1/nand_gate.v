module nand_gate(in1, in2, out);
	input in1, in2;
	output out;
	nand my_hand(out, in1, in2);
endmodule 
