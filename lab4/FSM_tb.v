//set the timescale
`timescale 1 ns/100 ps
module FSM_tb();//testbenches takes no arguments
	reg level;
	reg clock;
	wire [2:0] STATE;
	wire count;
	wire reset;
	reg [2:0] state;
	reg [2:0] next_state;
	
	FSM test_FSM(clock,reset,level,count,STATE);
	//begin simulation
	initial begin
		$display($time, "simulation start");
		clock = 1'b0;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		@(negedge clock);
		level =1'b1;
		#100 level=1'b0;
		#40 level=1'b1;
		@(negedge clock);
		$stop;
	
	end
	always
		#10 clock= ~clock; //toggle clock every 10 timescale units
endmodule
