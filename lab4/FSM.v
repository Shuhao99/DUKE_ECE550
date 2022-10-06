// edgeDetector.v
// Moore and Mealy Implementation

module FSM
(
    input wire clk, reset, 
    input wire level, 
    output reg Mealy_tick,
	 output reg [2:0] stateMealy_reg
);
reg Moore_tick;

localparam  [3:0] // 5 states are required for Mealy
    zeroMealy =  3'd0,
    oneMealy =   3'd1,
	 twoMealy =   3'd2,
    threeMealy = 3'd3,
	 fourMealy =  3'd4,
    fiveMealy =  3'd5,
	 sixMealy =   3'd6,
    sevenMealy = 3'd7;
    
localparam  [3:0] // 5 states are required for Moore
    zeroMoore =  3'd0,
    oneMoore =   3'd1,
	 twoMoore =   3'd2,
    threeMoore = 3'd3,
	 fourMoore =  3'd4,
    fiveMoore =  3'd5,
	 sixMoore =   3'd6,
    sevenMoore = 3'd7;

reg [2:0] stateMealy_next; //consistent with length defined previously
reg[2:0] stateMoore_reg, stateMoore_next;

always @(posedge clk, posedge reset)
begin
    if(reset) // go to state zero if rese
        begin
        stateMealy_reg <= zeroMealy;
        stateMoore_reg <= zeroMoore;
        end
    else // otherwise update the states
        begin
        stateMealy_reg <= stateMealy_next;
        stateMoore_reg <= stateMoore_next;
        end
end

// Mealy Design 
always @(stateMealy_reg, level)
begin
    // store current state as next
    stateMealy_next = stateMealy_reg; // required: when no case statement is satisfied
    
    Mealy_tick = 1'b0; // set tick to zero (so that 'tick = 1' is available for 1 cycle only)
    case(stateMealy_reg)
        zeroMealy: // set 'tick = 1' if state = zero and level = '1'
            if(level)  
                begin // if level is 1, then go to state one,
                    stateMealy_next = oneMealy; // otherwise remain in same state.
						  Mealy_tick = 1'b0;
                end
					 
        oneMealy: 
            if(level)  
                begin // if level is 1, then go to state one,
                    stateMealy_next = twoMealy; // otherwise remain in same state.
						  Mealy_tick = 1'b0;
					end
					 
		  twoMealy: // set 'tick = 1' if state = zero and level = '1'
            if(level)  
                begin // if level is 1, then go to state one,
                    stateMealy_next = threeMealy; // otherwise remain in same state.
						  Mealy_tick = 1'b0;
                end
					 
		  threeMealy: // set 'tick = 1' if state = zero and level = '1'
            if(level)  
                begin // if level is 1, then go to state one,
                    stateMealy_next = fourMealy; // otherwise remain in same state.
						  Mealy_tick = 1'b0;
                end
					 
		  fourMealy: // set 'tick = 1' if state = zero and level = '1'
            if(level)  
                begin // if level is 1, then go to state one,
                    stateMealy_next = zeroMealy; // otherwise remain in same state.
						  Mealy_tick = 1'b1;
                end
					 
			default
				begin // if level is 1, then go to state one,
                    stateMealy_next = fourMealy; // otherwise remain in same state.
						  //Mealy_tick = 1'b0;
                end
			
		
					 
					 
					 
    endcase
end

// Moore Design 
always @(stateMoore_reg, level)
begin
    // store current state as next
    stateMoore_next = stateMoore_reg; // required: when no case statement is satisfied
    
    Moore_tick = 1'b0; // set tick to zero (so that 'tick = 1' is available for 1 cycle only)
    case(stateMoore_reg)
	 
        zeroMoore: // if state is zero,
            begin
                Moore_tick = 1'b0; // set the tick to 1.
                if(level) // if level is 1, 
                    stateMoore_next = oneMoore; // go to state one,
                else    
                    stateMoore_next = zeroMoore; // else go to state zero.
            end
				
        oneMoore:
            begin
                Moore_tick = 1'b0; // set the tick to 1.
                if(level) // if level is 1, 
                    stateMoore_next = twoMoore; // go to state one,
                else    
                    stateMoore_next = zeroMoore; // else go to state zero.
            end
				
			twoMoore:
            begin
                Moore_tick = 1'b0; // set the tick to 1.
                if(level) // if level is 1, 
                    stateMoore_next = threeMoore; // go to state one,
                else    
                    stateMoore_next = zeroMoore; // else go to state zero.
            end
				
			threeMoore:
            begin
                Moore_tick = 1'b0; // set the tick to 1.
                if(level) // if level is 1, 
                    stateMoore_next = fourMoore; // go to state one,
                else    
                    stateMoore_next = zeroMoore; // else go to state zero.
            end
				
			fourMoore:
            begin
                Moore_tick = 1'b1; // set the tick to 1.
                if(level) // if level is 1, 
                    stateMoore_next = zeroMoore; // go to state one,
                else    
                    stateMoore_next = zeroMoore; // else go to state zero.
            end
				
			default
			
                stateMoore_next = zeroMoore; // then go to state zero.      
    endcase
end
endmodule
