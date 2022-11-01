module clk8(clk,reset,out,out_bar);

input clk,reset;
output out,out_bar;
wire temp,temp_bar;
//module dffe_reg(q, d, clk, en, clr);
clk4 c4(clk,reset,temp,temp_bar);
clk2 c2(temp,reset,out,out_bar);

endmodule
