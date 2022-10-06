module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output reg [31:0] data_result;
   output reg isNotEqual, isLessThan, overflow;

   // IMPLEMENTATION HERE

   localparam 
        ADD        = 5'b00000, 
        SUBTRACT   = 5'b00001,
        AND        = 5'b00010, 
        OR         = 5'b00011, 
        SLL        = 5'b00100, 
        SRA        = 5'b00101;
    
   always @(data_operandA or data_operandB or ctrl_ALUopcode or ctrl_shiftamt) begin

     case(ctrl_ALUopcode)
       ADD: 
         begin
           data_result = data_operandA + data_operandB;
           overflow = (!data_operandA[31] & !data_operandB[31] & data_result[31]) |
                      (data_operandA[31] & data_operandB[31] & !data_result[31]);
         end
       SUBTRACT: 
         begin
           data_result = data_operandA - data_operandB;
           overflow = (data_operandA[31] & !data_operandB[31] & !data_result[31]) |
                      (!data_operandA[31] & data_operandB[31] & data_result[31]);
         end
       AND: 
         data_result = data_operandA & data_operandB;
       OR: 
         data_result = data_operandA | data_operandB;
       SLL: 
         data_result = data_operandA << ctrl_shiftamt;
       SRA: 
         data_result = $signed(data_operandA) >>> ctrl_shiftamt;
     endcase

     isNotEqual <= (data_operandA != data_operandB) ? 1'b1 : 1'b0;
     isLessThan <= (data_operandA[31] & !data_operandB[31]) | 
                  ((data_operandA[31] ~^ data_operandB[31]) & data_result[31]);

   end

endmodule
