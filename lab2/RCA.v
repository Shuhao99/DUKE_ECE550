module RCA (A, B, c_in, c_out, sum);

	input [3:0] A,B;
	input c_in;
	output [3:0] sum;
	output c_out;
	
	wire [2:0] connection;
	
	FA FA1(.a(A[0]), .b(B[0]), .c_in(c_in), 
			 .sum(sum[0]), .c_out(connection[0])
			);
			
	FA FA2(.a(A[1]), .b(B[1]), .c_in(connection[0]), 
			 .sum(sum[1]), .c_out(connection[1])
			);
	
	FA FA3(.a(A[2]), .b(B[2]), .c_in(connection[1]), 
			 .sum(sum[2]), .c_out(connection[2])
			);
			
	FA FA4(.a(A[3]), .b(B[3]), .c_in(connection[2]), 
			 .sum(sum[3]), .c_out(c_out)
			);

endmodule

	