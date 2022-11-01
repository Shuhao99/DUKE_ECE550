module clk4(clk,reset,out,out_bar);

input clk,reset;
output out,out_bar;
wire temp,temp_bar;
//module dffe_reg(q, d, clk, en, clr);
dffe_reg d1(temp,~temp,clk,1,reset);
and a1(temp_bar,~temp,1);
dffe_reg d2(out,~out,temp,1,reset);
and a2(out_bar,~out,1);


endmodule
