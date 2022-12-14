module nand_gate(R,D);
	output [6:0] R;
	input [64:1] D;



 
assign R[0]=D[1]^ D[2 ]^ D[4]^ D[5 ]^ D[7 ]^ D[9 ]^D[11 ]^ D[12]^ D[14 ]^ D[16 ]^ D[18 ]^ D[20 ]^ D[22 ]^ D[24 ]^
D[26 ]^ D[27]^ D[29 ]^ D[31 ]^ D[33 ]^ D[35 ]^ D[37 ]^ D[39 ]^ D[41 ]^ D[43 ]^ D[45 ]^ D[47 ]^ D[49 ]^ D[51 ]^
D[53 ]^ D[55 ]^ D[57 ]^ D[58 ]^ D[60 ]^ D[62]^ D[64];


assign R[1] = D[1]^ D[3 ]^ D[4]^ D[6 ]^ D[7 ]^ D[10 ]^D[11 ]^ D[13]^ D[14 ]^ D[17 ]^ D[18 ]^ D[21 ]^ D[22 ]^ D[25 ]^
D[26 ]^ D[28]^ D[29 ]^ D[32 ]^ D[33 ]^ D[36 ]^ D[37 ]^ D[40 ]^ D[41 ]^ D[44 ]^ D[45 ]^ D[48 ]^ D[49 ]^ D[52 ]^
D[53 ]^ D[56 ]^ D[57 ]^ D[59 ]^ D[60 ]^ D[63]^ D[64];

assign R[2]=D[2]^ D[3 ]^ D[4]^ D[8 ]^ D[9 ]^ D[10 ]^D[11 ]^ D[15]^ D[16 ]^ D[17 ]^ D[18 ]^ D[23 ]^ D[24 ]^ D[25 ]^
D[26 ]^ D[30]^ D[31 ]^ D[32 ]^ D[33 ]^ D[38 ]^ D[39 ]^ D[40 ]^ D[41 ]^ D[46 ]^ D[47 ]^ D[48 ]^ D[49 ]^ D[54 ]^
D[55 ]^ D[56 ]^ D[57 ]^ D[61 ]^ D[62 ]^ D[63]^ D[64];


assign R[3]= D[5]^ D[6 ]^ D[7]^ D[8 ]^ D[9 ]^ D[10 ]^D[11 ]^ D[19]^ D[20 ]^ D[21 ]^ D[22 ]^ D[23 ]^ D[24 ]^ D[25 ]^
D[26 ]^ D[34]^ D[35 ]^ D[36 ]^ D[37 ]^ D[38 ]^ D[39 ]^ D[40 ]^ D[41 ]^ D[50 ]^ D[51 ]^ D[52 ]^ D[53 ]^ D[54 ]^
D[55 ]^ D[56 ]^ D[57];

assign R[4]= D[12]^ D[13 ]^ D[14]^ D[15 ]^ D[16 ]^ D[17 ]^D[18 ]^ D[19]^ D[20 ]^ D[21 ]^ D[22 ]^ D[23 ]^ D[24 ]^
D[25 ]^ D[26 ]^ D[42]^ D[43 ]^ D[44 ]^ D[45 ]^ D[46 ]^ D[47 ]^ D[48 ]^ D[49 ]^ D[50 ]^ D[51 ]^ D[52 ]^ D[53 ]^
D[54 ]^ D[55 ]^ D[56 ]^ D[57];

assign R[5]= D[27]^ D[28 ]^ D[29]^ D[30 ]^ D[31 ]^ D[32 ]^D[33 ]^ D[34]^ D[35 ]^ D[36 ]^ D[37 ]^ D[38 ]^ D[39 ]^
D[40 ]^ D[41 ]^ D[42]^ D[43 ]^ D[44 ]^ D[45 ]^ D[46 ]^ D[47 ]^ D[48 ]^ D[49 ]^ D[50 ]^ D[51 ]^ D[52 ]^ D[53 ]^
D[54 ]^ D[55 ]^ D[56 ]^ D[57];

assign R[6]= D[58]^ D[59 ]^ D[60]^ D[61]^ D[62 ]^D[63 ]^ D[64];


endmodule
