module clk2(clk,reset,out,out_bar);

input clk,reset;
output out,out_bar;

//module dffe_reg(q, d, clk, en, clr);
dffe_reg(out,~out,clk,1,reset);
and a1(out_bar,~out,1);

endmodule

