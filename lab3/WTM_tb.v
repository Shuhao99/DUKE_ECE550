// set the timescale
`timescale 1 ns / 100 ps
module WTM_tb(); // testbenches take no arguments
// set up inputs of NAND gate as registers so they can be manipulated at will
reg [4:0]in1;
reg [4:0]in2;

// clocks are useful for testbenches because they allow you to check your
// circuit at regular intervals large enough for signals to propagate
reg clock;
// set up output of NAND gate as wire
wire [9:0] res;
// prepare any other variables you want - nothing is off-limits in a TB
integer num_errors;
// instantiate the RCA==
WTM test (in1, in2,res);
// begin simulation
initial begin
$display($time, " simulation start");
clock = 1'b0;
@(negedge clock);
in1 = 5'd11;
in2 = 5'd12;
@(negedge clock); // wait for the clock to go negative
in1 = 5'd3;
in2 = 5'd20;
@(negedge clock);
$stop;
end
always
#10 clock = ~clock; // toggle clock every 10 timescale units
endmodule