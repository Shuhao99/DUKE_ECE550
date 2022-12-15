module decoder_7_128 ( 
binary_in   , //  7 bit binary input 
decoder_out , //  128-bit out  
enable        //  Enable for the decoder 
); 
input [6:0] binary_in  ; 
input  enable ;  
output [127:0] decoder_out ;  
         
wire [127:0] decoder_out ;  
 
assign decoder_out = (enable) ? (1 << binary_in) : 128'b0 ; 
 
endmodule 