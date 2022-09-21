module WTM(A, B, res);
input [4:0] A, B;
output [9:0] res;

wire [4:0] l0;
wire [4:0] l1;
wire [4:0] l2;
wire [4:0] l3;
wire [4:0] l4;

wire [4:0] s0;
wire [4:0] s1;
wire [4:0] s2,s3;

wire [4:0] c0,c1,c2,c3;

genvar i1;
	
generate
	for(i1=0; i1<5; i1=i1+1) begin : generate_l0
		and a0(l0[i1],A[i1],B[0]);
	end
endgenerate

genvar i2;
	
generate
	for(i2=0; i2<5; i2=i2+1) begin : generate_l1
		and a1(l1[i2],A[i2],B[1]);
	end
endgenerate

genvar i3;
	
generate
	for(i3=0; i3<5; i3=i3+1) begin : generate_l2
		and a2(l2[i3],A[i3],B[2]);
	end
endgenerate

genvar i4;
	
generate
	for(i4=0; i4<5; i4=i4+1) begin : generate_l3
		and a3(l3[i4],A[i4],B[3]);
	end
endgenerate

genvar i5;
	
generate
	for(i5=0; i5<5; i5=i5+1) begin : generate_l4
		and a4(l4[i5],A[i5],B[4]);
	end
endgenerate



//FA(a, b, c_in, sum, c_out);
//level 1
FA F10(l0[1], l1[0], 0,     s0[0], c0[0]);
FA F11(l0[2], l1[1], c0[0], s0[1], c0[1]);
FA F12(l0[3], l1[2], c0[1], s0[2], c0[2]);
FA F13(l0[4], l1[3], c0[2], s0[3], c0[3]);
FA F14(  0,   l1[4], c0[3], s0[4], c0[4]);


//level 2
FA F20(s0[1], l2[0], 0    , s1[0], c1[0]);
FA F21(s0[2], l2[1], c1[0], s1[1], c1[1]);
FA F22(s0[3], l2[2], c1[1], s1[2], c1[2]);
FA F23(s0[4], l2[3], c1[2], s1[3], c1[3]);
FA F24(c0[4], l2[4], c1[3], s1[4], c1[4]);


//level 3 
FA F30(s1[1], l3[0], 0    , s2[0], c2[0]);
FA F31(s1[2], l3[1], c2[0], s2[1], c2[1]);
FA F32(s1[3], l3[2], c2[1], s2[2], c2[2]);
FA F33(s1[4], l3[3], c2[2], s2[3], c2[3]);
FA F34(c1[4], l3[4], c2[3], s2[4], c2[4]);

//level 4 
FA F40(s2[1], l4[0], 0    , s3[0], c3[0]);
FA F41(s2[2], l4[1], c3[0], s3[1], c3[1]);
FA F42(s2[3], l4[2], c3[1], s3[2], c3[2]);
FA F43(s2[4], l4[3], c3[2], s3[3], c3[3]);
FA F44(c2[4], l4[4], c3[3], s3[4], c3[4]);

//assing to result[9:0]

and aa1(res[0],l1[0],1);
and aa2(res[1],s0[0],1);
and aa3(res[2],s1[0],1);
and aa4(res[3],s2[0],1);
and aa5(res[4],s3[0],1);
and aa6(res[5],s3[1],1);
and aa7(res[6],s3[2],1);
and aa8(res[7],s3[3],1);
and aa9(res[8],s3[4],1);
and aa10(res[9],c3[4],1);


endmodule


	
	