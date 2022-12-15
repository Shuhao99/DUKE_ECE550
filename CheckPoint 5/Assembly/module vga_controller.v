module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,resetn,
							 ps2_out,
							 ps2_key_pressed);

	
input iRST_n;
input resetn;
input [7:0] ps2_out;
input iVGA_CLK;
input ps2_key_pressed;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                       
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
reg [23:0] bgr_data_final;
reg press_flag = 1'b0;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	



//matrix	屏幕像素
reg[9:0] mat [14:0];

//ks599
wire state1,state2;
wire[31:0] outputblock,current_block_data;
integer a,b;
reg[149:0] outmat;



reg[12:0] x,y;

reg[1:0] dire;
reg[2:0] color;
reg[3:0] type=8;
reg[4:0] pos_x;
reg[4:0] pos_y;
reg[10:0] score = 0;
//update current matrix and eliminate

//
reg [10:0] scorestate = 0;
wire [31:0] inst;
reg [14:0] aaa = 15'b001010000100000;
reg [5:0] zero_6 = 0; 
assign inst = {aaa,zero_6,scorestate};

//reg [10:0] scorestate1 = 0;

wire [10:0] score_out;
processor2 p5(VGA_CLK_n,~resetn,inst,score_out,score,score,);



always@(posedge VGA_CLK_n)
begin
	if(!resetn)
	score<=0;
	else
	score<=score_out;	
end
		


always@(posedge VGA_CLK_n or negedge resetn)

begin
//update matrix
	if(!resetn)
		begin
			mat[0] <= 10'b0000000000;
			mat[1] <= 10'b0000000000;
			mat[2] <= 10'b0000000000;
			mat[3] <= 10'b0000000000;
			mat[4] <= 10'b0000000000;
			mat[5] <= 10'b0000000000;
			mat[6] <= 10'b0000000000;
			mat[7] <= 10'b0000000000;
			mat[8] <= 10'b0000000000;
			mat[9] <= 10'b0000000000;
			mat[10] <= 10'b0000000000;
			mat[11] <= 10'b0000000000;
			mat[12] <= 10'b0000000000;
			mat[13] <= 10'b0000000000;
			mat[14] <= 10'b0000000000;
			type<=8;
			//score<=0;
		end
	else if(!state1)
	begin
		dire<=outputblock[12:11];
		type<=outputblock[10:8];
		pos_x<=outputblock[7:4];
		pos_y<=9-outputblock[3:0];
	end
//	else if(state1)
//	begin
//		type<=8;
//	end
	else
begin
	//type 0
//region
    //长条
	if(type == 0)
		begin
			if(dire == 0||dire == 2)
				begin
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x][pos_y-2] <=1;
				end
			else
				begin
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x-2][pos_y] <=1;
				end
		end

    //正方形
	//type 1 
	if(type == 1)
		begin
			if(dire == 0||dire == 2||dire == 1||dire == 3)
			begin
			mat[pos_x][pos_y] <=1;
			mat[pos_x][pos_y-1] <=1;
			mat[pos_x-1][pos_y] <=1;
			mat[pos_x-1][pos_y-1] <=1;
			end
		end
		
	//type 2
	if(type == 2)
		begin
			if(dire == 0)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x-1][pos_y-1] <=1;
				end
			else if(dire == 1)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x-1][pos_y+1] <=1;
				end
			else if(dire == 2)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x+1][pos_y+1] <=1;
				end
			else if(dire == 3)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x+1][pos_y-1] <=1;
				end
		end
	
	//type 3
	if(type == 3)
		begin
			if(dire == 0)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x-1][pos_y+1] <=1;
				end
			else if(dire == 1)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x+1][pos_y+1] <=1;
				end
			else if(dire == 2)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x+1][pos_y-1] <=1;
				end
			else if(dire == 3)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x-1][pos_y-1] <=1;
				end
		end
		
	//type 4
	if(type == 4)
		begin
			if(dire == 0||dire == 2)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x-1][pos_y+1] <=1;
				end
			else
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x+1][pos_y+1] <=1;
					mat[pos_x-1][pos_y] <=1;
				end
		end
		
	//type 5
	if(type == 5)
		begin
			if(dire == 0||dire == 2)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x-1][pos_y-1] <=1;
				end
			else
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x-1][pos_y+1] <=1;
				end
		end
	
	//type 6
	if(type == 6)
		begin
			if(dire == 0)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x+1][pos_y] <=1;
				end
			else if(dire == 1)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x][pos_y-1] <=1;
				end
			else if(dire == 2)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
					mat[pos_x][pos_y-1] <=1;
					mat[pos_x-1][pos_y] <=1;
				end
			else if(dire == 3)
				begin
					mat[pos_x][pos_y] <=1;
					mat[pos_x+1][pos_y] <=1;
					mat[pos_x-1][pos_y] <=1;
					mat[pos_x][pos_y+1] <=1;
				end
		end
        //endregion

//check eliminate 消除方块
	if(mat[0]==10'b1111111111)
	begin
		mat[0]<=mat[1];							
		mat[1]<=mat[2];
		mat[2]<=mat[3];
		mat[3]<=mat[4];
		mat[4]<=mat[5];
		mat[5]<=mat[6];
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	//如果满了 向下shift
	if(mat[1]==10'b1111111111)
	begin						
		mat[1]<=mat[2];
		mat[2]<=mat[3];
		mat[3]<=mat[4];
		mat[4]<=mat[5];
		mat[5]<=mat[6];
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[2]==10'b1111111111)
	begin
		mat[2]<=mat[3];
		mat[3]<=mat[4];
		mat[4]<=mat[5];
		mat[5]<=mat[6];
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[3]==10'b1111111111)
	begin
		mat[3]<=mat[4];
		mat[4]<=mat[5];
		mat[5]<=mat[6];
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[4]==10'b1111111111)
	begin
		mat[4]<=mat[5];
		mat[5]<=mat[6];
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[5]==10'b1111111111)
	begin
		mat[5]<=mat[6];
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[6]==10'b1111111111)
	begin
		mat[6]<=mat[7];
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[7]==10'b1111111111)
	begin
		mat[7]<=mat[8];
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[8]==10'b1111111111)
	begin
		mat[8]<=mat[9];
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[9]==10'b1111111111)
	begin
		mat[9]<=mat[10];
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[10]==10'b1111111111)
	begin
		mat[10]<=mat[11];
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[11]==10'b1111111111)
	begin
		mat[11]<=mat[12];
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[12]==10'b1111111111)
	begin
		mat[12]<=mat[13];
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[13]==10'b1111111111)
	begin
		mat[13]<=mat[14];
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
	if(mat[14]==10'b1111111111)
	begin
		mat[14]<=10'b0000000000;
		type <= 8;
		scorestate <= scorestate + 1;
	end
	
//初始化，全部都没东西的时候 scorestate <=0
	
	if(mat[14]!=10'b1111111111&&mat[13]!=10'b1111111111&&mat[12]!=10'b1111111111&&mat[11]!=10'b1111111111&&mat[10]!=10'b1111111111&&
	mat[9]!=10'b1111111111&&mat[8]!=10'b1111111111&&mat[7]!=10'b1111111111&&mat[6]!=10'b1111111111&&mat[5]!=10'b1111111111&&
	mat[4]!=10'b1111111111&&mat[3]!=10'b1111111111&&mat[2]!=10'b1111111111&&mat[1]!=10'b1111111111&&mat[0]!=10'b1111111111)
		scorestate<=0;
	
	end

//2d -> 1d outmat 用
for(a = 0; a <= 14;a = a + 1)
 begin
 for(b = 0; b <= 9; b = b + 1)
  begin
  outmat[a*10+b] <= mat[a][9-b];
  end
 end	
		
end



reg[6:0] seven_seg_display;

always@(posedge VGA_CLK_n)

begin
	//x, y block的坐标, 渲染block
    x <= ADDR/10'd640; 
	y <= ADDR%10'd640;
	if(y<159||y>=480)
	begin
		//pink
		bgr_data_final<=24'hC1FFB6;
		//seven segment
	end
	else
		begin
			//黑边
            if(y == 159 || y== 191 || y==223 || y==255 ||y ==287 || y==319 || y==351 ||y == 383|| y==415 || y==447 || y==479
				||x==0 || x== 31 || x==63 ||x==95|| x==127 || x== 159 || x==191 || x==223 || x==255 || x==287 || x==319 || x==351 || x==383 || x==415 || x==479 || x== 447 )
				begin
					bgr_data_final<=24'h000000;
				end
			else
			begin
			//pink
			bgr_data_final<=24'hFA87CE;
			//in mat[14]
			if(x>=0&&x<=31)
				begin
					//in mat[14][9]
					if(y<192)
						begin
							if(mat[14][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][8]
					else if(y<224)
						begin
							if(mat[14][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][7]
					else if(y<256)
						begin
							if(mat[14][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][6]
					else if(y<288)
						begin
							if(mat[14][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][5]
					else if(y<320)
						begin
							if(mat[14][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][4]
					else if(y<352)
						begin
							if(mat[14][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][3]
					else if(y<384)
						begin
							if(mat[14][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][2]
					else if(y<416)
						begin
							if(mat[14][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][1]
					else if(y<448)
						begin
							if(mat[14][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[14][0]
					else if(y<480)
						begin
							if(mat[14][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
				
			//in mat[13]
			if(x>=32&&x<=63)
				begin
					//in mat[13][9]
					if(y<192)
						begin
							if(mat[13][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][8]
					else if(y<224)
						begin
							if(mat[13][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][7]
					else if(y<256)
						begin
							if(mat[13][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][6]
					else if(y<288)
						begin
							if(mat[13][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][5]
					else if(y<320)
						begin
							if(mat[13][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][4]
					else if(y<352)
						begin
							if(mat[13][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][3]
					else if(y<384)
						begin
							if(mat[13][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][2]
					else if(y<416)
						begin
							if(mat[13][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][1]
					else if(y<448)
						begin
							if(mat[13][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[13][0]
					else if(y<480)
						begin
							if(mat[13][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			
			//in mat[12]
			if(x>=64&&x<=95)
				begin
					//in mat[12][9]
					if(y<192)
						begin
							if(mat[12][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][8]
					else if(y<224)
						begin
							if(mat[12][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][7]
					else if(y<256)
						begin
							if(mat[12][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][6]
					else if(y<288)
						begin
							if(mat[12][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][5]
					else if(y<320)
						begin
							if(mat[12][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][4]
					else if(y<352)
						begin
							if(mat[12][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][3]
					else if(y<384)
						begin
							if(mat[12][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][2]
					else if(y<416)
						begin
							if(mat[12][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][1]
					else if(y<448)
						begin
							if(mat[12][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[12][0]
					else if(y<480)
						begin
							if(mat[12][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[11]
			if(x>=96&&x<=127)
				begin
					//in mat[11][9]
					if(y<192)
						begin
							if(mat[11][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][8]
					else if(y<224)
						begin
							if(mat[11][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][7]
					else if(y<256)
						begin
							if(mat[11][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][6]
					else if(y<288)
						begin
							if(mat[11][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][5]
					else if(y<320)
						begin
							if(mat[11][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][4]
					else if(y<352)
						begin
							if(mat[11][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][3]
					else if(y<384)
						begin
							if(mat[11][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][2]
					else if(y<416)
						begin
							if(mat[11][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][1]
					else if(y<448)
						begin
							if(mat[11][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[11][0]
					else if(y<480)
						begin
							if(mat[11][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[10]
			if(x>=128&&x<=159)
				begin
					//in mat[10][9]
					if(y<192)
						begin
							if(mat[10][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][8]
					else if(y<224)
						begin
							if(mat[10][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][7]
					else if(y<256)
						begin
							if(mat[10][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][6]
					else if(y<288)
						begin
							if(mat[10][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][5]
					else if(y<320)
						begin
							if(mat[10][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][4]
					else if(y<352)
						begin
							if(mat[10][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][3]
					else if(y<384)
						begin
							if(mat[10][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][2]
					else if(y<416)
						begin
							if(mat[10][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][1]
					else if(y<448)
						begin
							if(mat[10][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[10][0]
					else if(y<480)
						begin
							if(mat[10][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[9]
			if(x>=160&&x<=191)
				begin
					//in mat[9][9]
					if(y<192)
						begin
							if(mat[9][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][8]
					else if(y<224)
						begin
							if(mat[9][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][7]
					else if(y<256)
						begin
							if(mat[9][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][6]
					else if(y<288)
						begin
							if(mat[9][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][5]
					else if(y<320)
						begin
							if(mat[9][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][4]
					else if(y<352)
						begin
							if(mat[9][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][3]
					else if(y<384)
						begin
							if(mat[9][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][2]
					else if(y<416)
						begin
							if(mat[9][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][1]
					else if(y<448)
						begin
							if(mat[9][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[9][0]
					else if(y<480)
						begin
							if(mat[9][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[8]
			if(x>=192&&x<=223)
				begin
					//in mat[8][9]
					if(y<192)
						begin
							if(mat[8][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][8]
					else if(y<224)
						begin
							if(mat[8][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][7]
					else if(y<256)
						begin
							if(mat[8][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][6]
					else if(y<288)
						begin
							if(mat[8][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][5]
					else if(y<320)
						begin
							if(mat[8][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][4]
					else if(y<352)
						begin
							if(mat[8][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][3]
					else if(y<384)
						begin
							if(mat[8][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][2]
					else if(y<416)
						begin
							if(mat[8][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][1]
					else if(y<448)
						begin
							if(mat[8][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[8][0]
					else if(y<480)
						begin
							if(mat[8][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[7]
			if(x>=224&&x<=255)
				begin
					//in mat[7][9]
					if(y<192)
						begin
							if(mat[7][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][8]
					else if(y<224)
						begin
							if(mat[7][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][7]
					else if(y<256)
						begin
							if(mat[7][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][6]
					else if(y<288)
						begin
							if(mat[7][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][5]
					else if(y<320)
						begin
							if(mat[7][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][4]
					else if(y<352)
						begin
							if(mat[7][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][3]
					else if(y<384)
						begin
							if(mat[7][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][2]
					else if(y<416)
						begin
							if(mat[7][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][1]
					else if(y<448)
						begin
							if(mat[7][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[7][0]
					else if(y<480)
						begin
							if(mat[7][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[6]
			if(x>=256&&x<=287)
				begin
					//in mat[6][9]
					if(y<192)
						begin
							if(mat[6][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][8]
					else if(y<224)
						begin
							if(mat[6][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][7]
					else if(y<256)
						begin
							if(mat[6][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][6]
					else if(y<288)
						begin
							if(mat[6][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][5]
					else if(y<320)
						begin
							if(mat[6][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][4]
					else if(y<352)
						begin
							if(mat[6][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][3]
					else if(y<384)
						begin
							if(mat[6][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][2]
					else if(y<416)
						begin
							if(mat[6][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][1]
					else if(y<448)
						begin
							if(mat[6][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[6][0]
					else if(y<480)
						begin
							if(mat[6][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[5]
			if(x>=288&&x<=319)
				begin
					//in mat[5][9]
					if(y<192)
						begin
							if(mat[5][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][8]
					else if(y<224)
						begin
							if(mat[5][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][7]
					else if(y<256)
						begin
							if(mat[5][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][6]
					else if(y<288)
						begin
							if(mat[5][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][5]
					else if(y<320)
						begin
							if(mat[5][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][4]
					else if(y<352)
						begin
							if(mat[5][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][3]
					else if(y<384)
						begin
							if(mat[5][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][2]
					else if(y<416)
						begin
							if(mat[5][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][1]
					else if(y<448)
						begin
							if(mat[5][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[5][0]
					else if(y<480)
						begin
							if(mat[5][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[4]
			if(x>=320&&x<=351)
				begin
					//in mat[4][9]
					if(y<192)
						begin
							if(mat[4][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][8]
					else if(y<224)
						begin
							if(mat[4][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][7]
					else if(y<256)
						begin
							if(mat[4][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][6]
					else if(y<288)
						begin
							if(mat[4][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][5]
					else if(y<320)
						begin
							if(mat[4][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][4]
					else if(y<352)
						begin
							if(mat[4][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][3]
					else if(y<384)
						begin
							if(mat[4][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][2]
					else if(y<416)
						begin
							if(mat[4][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][1]
					else if(y<448)
						begin
							if(mat[4][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[4][0]
					else if(y<480)
						begin
							if(mat[4][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[3]
			if(x>=352&&x<=383)
				begin
					//in mat[3][9]
					if(y<192)
						begin
							if(mat[3][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][8]
					else if(y<224)
						begin
							if(mat[3][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][7]
					else if(y<256)
						begin
							if(mat[3][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][6]
					else if(y<288)
						begin
							if(mat[3][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][5]
					else if(y<320)
						begin
							if(mat[3][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][4]
					else if(y<352)
						begin
							if(mat[3][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][3]
					else if(y<384)
						begin
							if(mat[3][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][2]
					else if(y<416)
						begin
							if(mat[3][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][1]
					else if(y<448)
						begin
							if(mat[3][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[3][0]
					else if(y<480)
						begin
							if(mat[3][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[2]
			if(x>=384&&x<=415)
				begin
					//in mat[2][9]
					if(y<192)
						begin
							if(mat[2][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][8]
					else if(y<224)
						begin
							if(mat[2][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][7]
					else if(y<256)
						begin
							if(mat[2][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][6]
					else if(y<288)
						begin
							if(mat[2][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][5]
					else if(y<320)
						begin
							if(mat[2][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][4]
					else if(y<352)
						begin
							if(mat[2][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][3]
					else if(y<384)
						begin
							if(mat[2][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][2]
					else if(y<416)
						begin
							if(mat[2][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][1]
					else if(y<448)
						begin
							if(mat[2][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[2][0]
					else if(y<480)
						begin
							if(mat[2][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[1]
			if(x>=416&&x<=447)
				begin
					//in mat[1][9]
					if(y<192)
						begin
							if(mat[1][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][8]
					else if(y<224)
						begin
							if(mat[1][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][7]
					else if(y<256)
						begin
							if(mat[1][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][6]
					else if(y<288)
						begin
							if(mat[1][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][5]
					else if(y<320)
						begin
							if(mat[1][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][4]
					else if(y<352)
						begin
							if(mat[1][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][3]
					else if(y<384)
						begin
							if(mat[1][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][2]
					else if(y<416)
						begin
							if(mat[1][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][1]
					else if(y<448)
						begin
							if(mat[1][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[1][0]
					else if(y<480)
						begin
							if(mat[1][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
			//in mat[0]
			if(x>=448&&x<=479)
				begin
					//in mat[0][9]
					if(y<192)
						begin
							if(mat[0][9] ==1)
								//green
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][8]
					else if(y<224)
						begin
							if(mat[0][8] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][7]
					else if(y<256)
						begin
							if(mat[0][7] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][6]
					else if(y<288)
						begin
							if(mat[0][6] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][5]
					else if(y<320)
						begin
							if(mat[0][5] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][4]
					else if(y<352)
						begin
							if(mat[0][4] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][3]
					else if(y<384)
						begin
							if(mat[0][3] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][2]
					else if(y<416)
						begin
							if(mat[0][2] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][1]
					else if(y<448)
						begin
							if(mat[0][1] ==1)
								bgr_data_final<=24'h7FFFAA;
						end
					//in mat[0][0]
					else if(y<480)
						begin
							if(mat[0][0] ==1)
								bgr_data_final<=24'h7FFFAA;
						end

						
				end
		end
		end
end	
//////
//////latch valid data at falling edge;
wire clk_4;
//变速器
fd_4 f1(VGA_CLK_n,clk_4,score);


wire [1:0] state;
reg delay = 0;
//reg pause = 0;

reg [1:0] control = 3;
reg [1:0] control2 = 3;
reg [31:0] temp = 0;


wire clock_100;
pll_test p6(~VGA_CLK_n,clock_100);

wire [31:0] speed_2;

assign speed_2 = (score>=7)?600000:((score>=3)?900000:1250000);

reg [3:0] state_current;

//键盘消抖
reg [0:19] Contt;
always@(posedge clock_100)
begin
	if(Contt!=20'hFFFFF)
	begin
		Contt	<=	Contt+1;
	end
	else
	press_flag<=1'b0;
end
// 处理键盘输入，control用来控制block位置
// ctl 0向左，1向右，2转向
always@(posedge clock_100)
begin
if(ps2_key_pressed==1)
begin
	//右键
    if(ps2_key_pressed==1&&ps2_out==8'h 74&&press_flag==1'b0)
	begin
		control<=1;
        press_flag = 1'b1;
	end
    
    //上键
	else if(ps2_key_pressed==1&&ps2_out == 8'h 75&&press_flag==1'b0)
	begin
		control<=2;
        press_flag = 1'b1;
	end
    //左键 
	else if(ps2_key_pressed==1&&ps2_out == 8'h 6b&&press_flag==1'b0)
	begin
		control<=0;
        press_flag = 1'b1;
	end
    // else if(ps2_key_pressed == 1&&ps2_out == 8'h 76&&press_flag==1'b0)
	// begin
	// 	resetn <=1'b0;
	// end
	temp<=0;
	state_current<=state;
	
end
else if(ps2_key_pressed==0)
begin
    
    if(state_current==7)
	begin
   if(temp==speed_2*15)
		begin
			temp<=0;
			control<=3;
		end
	end
	else if(state_current==1||state_current==3||state_current==5)
	begin
   if(temp==speed_2*10)
		begin
			temp<=0;
			control<=3;
		end
	end
	else if(state_current==2||state_current==4||state_current==6)
	begin
   if(temp==speed_2*8)
		begin
			temp<=0;
			control<=3;
		end
	end
	else if(state_current==8)
	begin
		if(temp==speed_2*12)
		begin
			temp<=0;
			control<=3;
		end
	end
	else if(state_current ==9)
	begin
	  if(temp==speed_2*9)
		begin
			temp<=0;
			control<=3;
		end
	end
	else if(state_current == 0)
	begin
	  if(temp==speed_2*5)
		begin
			temp<=0;
			control<=3;
		end
	end
	
		temp<=temp+1;
end

end


//always@(posedge VGA_CLK_n)
//begin
//	control <= control + 1;
//end
//assign outblock = (state==3)?current_block_data:32'b0;
//assign outblock = current_block_data;
//assign outblock = 32'b00000000000000000000000010100101;

wire clk_10;
fd_10 f3(VGA_CLK_n,clk_10);

wire [31:0] random_generate;

randomGenerate g1(clk_10,random_generate);

block p1(clk_4, state, current_block_data, /*32'b00000000000000000000011011100100,*/ random_generate,control, 
outmat
, , ,state1,outputblock,state2,pause,resetn);

 
reg [23:0] bgr_data_final_1;
reg [12:0] xx,yy;
reg [3:0] tempx,tempy;
wire [6:0] seg1;
wire [6:0] seg2;

Hexadecimal_To_Seven_Segment h1(score/10,seg1);
Hexadecimal_To_Seven_Segment h2(score%10,seg2);
always@(posedge VGA_CLK_n)
begin
	xx <= ADDR/10'd640 - 1; 
	yy <= ADDR%10'd640 - 1;
	if(yy<159||yy>=480)
		begin
		//pink
		bgr_data_final_1<=24'hC1FFB6;
		//seven segment
		//seg1
			//0
			if(xx==20&&(yy>=520)&&(yy<=540)&&(seg1[0]==0))
				bgr_data_final_1<=24'h000000;
			//1
			else if(yy==540&&(xx>=20)&&(xx<=40)&&(seg1[1]==0))
				bgr_data_final_1<=24'h000000;
			//2
			else if(yy==540&&(xx>=41)&&(xx<=60)&&(seg1[2]==0))
				bgr_data_final_1<=24'h000000;
			//3
			else if(xx==60&&(yy>=520)&&(yy<=540)&&(seg1[3]==0))
				bgr_data_final_1<=24'h000000;
			//4
			else if(yy==520&&(xx>=41)&&(xx<=60)&&(seg1[4]==0))
				bgr_data_final_1<=24'h000000;
			//5
			else if(yy==520&&(xx>=20)&&(xx<=40)&&(seg1[5]==0))
				bgr_data_final_1<=24'h000000;
			//6
			else if(xx==40&&(yy>=520)&&(yy<=540)&&(seg1[6]==0))
				bgr_data_final_1<=24'h000000;
				
		//seg2
			//0
			else if(xx==20&&(yy>=560)&&(yy<=580)&&(seg2[0]==0))
				bgr_data_final_1<=24'h000000;
			//1
			else if(yy==580&&(xx>=20)&&(xx<=40)&&(seg2[1]==0))
				bgr_data_final_1<=24'h000000;
			//2
			else if(yy==580&&(xx>=41)&&(xx<=60)&&(seg2[2]==0))
				bgr_data_final_1<=24'h000000;
			//3
			else if(xx==60&&(yy>=560)&&(yy<=580)&&(seg2[3]==0))
				bgr_data_final_1<=24'h000000;
			//4
			else if(yy==560&&(xx>=41)&&(xx<=60)&&(seg2[4]==0))
				bgr_data_final_1<=24'h000000;
			//5
			else if(yy==560&&(xx>=20)&&(xx<=40)&&(seg2[5]==0))
				bgr_data_final_1<=24'h000000;
			//6
			else if(xx==40&&(yy>=560)&&(yy<=580)&&(seg2[6]==0))
				bgr_data_final_1<=24'h000000;

		end
	else
	begin
	if(yy == 159 || yy== 191 || yy==223 || yy==255 ||yy ==287 || yy==319 || yy==351 ||yy == 383|| yy==415 || yy==447 || yy==479
				||xx==0 || xx== 31 || xx==63 ||xx==95|| xx==127 || xx== 159 || xx==191 || xx==223 || xx==255 || xx==287 || xx==319 || xx==351 || xx==383 || xx==415 || xx==479 || xx== 447 )
		begin
			bgr_data_final_1<=24'h000000;
		end
	else
		begin
		tempy <= 14-(ADDR/10'd640)/32; 
		tempx <= ((ADDR%10'd640)-160)/32;

		if(outputblock[31]==0)
		begin
    
//type==0
		if(outputblock[10:8] == 0)
		begin
		if(outputblock[12:11]%2 == 0)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+2)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11]%2 == 1)
			begin
			if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-2)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end

//type==1
		if(outputblock[10:8] == 1)
		begin
		if((outputblock[12:11]%2) == 0||(outputblock[12:11]%2) == 1)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0])&&(tempx<=outputblock[3:0]+1)&&(tempy<=outputblock[7:4])&&(tempy>=outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end

//type==2
		if(outputblock[10:8] == 2)
		begin
		if(outputblock[12:11] == 0)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]+1)&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 1)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]-1)&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 2)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]-1)&&(tempy==outputblock[7:4]+1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 3)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]+1)&&(tempy==outputblock[7:4]+1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end

//type==3
		if(outputblock[10:8] == 3)
		begin
		if(outputblock[12:11] == 0)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]-1)&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 1)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]-1)&&(tempy==outputblock[7:4]+1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 2)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]+1)&&(tempy==outputblock[7:4]+1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 3)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]+1)&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end

//type==4
		if(outputblock[10:8] == 4)
		begin
		if(outputblock[12:11]%2 == 0)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0])&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0])&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11]%2 == 1)
			begin
			if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4])&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempy>=outputblock[7:4])&&(tempy<=outputblock[7:4]+1)&&(tempx==outputblock[3:0]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end

//type==5
		if(outputblock[10:8] == 5)
		begin
		if(outputblock[12:11]%2 == 0)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0])&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx>=outputblock[3:0])&&(tempx<=outputblock[3:0]+1)&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11]%2 == 1)
			begin
			if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4])&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4])&&(tempx==outputblock[3:0]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end

//type==6
		if(outputblock[10:8] == 6)
		begin
		if(outputblock[12:11] == 0)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]+1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 1)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]+1)&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 2)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempx>=outputblock[3:0]-1)&&(tempx<=outputblock[3:0]+1)&&tempy==outputblock[7:4])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]-1))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		else if(outputblock[12:11] == 3)
			begin
				if((tempx==outputblock[3:0])&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7AAAFF;
				else if((tempy>=outputblock[7:4]-1)&&(tempy<=outputblock[7:4]+1)&&tempx==outputblock[3:0])
					bgr_data_final_1<= 24'h7FFFAA;
				else if((tempx==outputblock[3:0]-1)&&(tempy==outputblock[7:4]))
					bgr_data_final_1<= 24'h7FFFAA;
				else
					bgr_data_final_1<=bgr_data_final;
			end
		end


end
	





		end
	end
end

always@(posedge VGA_CLK_n) bgr_data <= bgr_data_final_1;

assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end



 
 
endmodule
 	
	

 	
	
//block module
//region

module block(clk, state, current_block_data, random_generate, control, 
line,temp_block_data,next_block_data,state1,outputblock,state2,pause,reset
 );
input clk;
//input state;  //state = 0, rotate and fall down;   state = 1, random generate a current block
input [1:0] control;   //control = 0, move left; control = 1, move right; control = 2; rotate;
input [149:0] line;
//input pause;
output reg pause = 0;
input [31:0] random_generate;
output reg [31:0] current_block_data;
input reset;

output reg [31:0] temp_block_data;
output reg [31:0] next_block_data;

output reg [3:0] state = 0;
output reg state1 = 1;
//decide whether update background;
output reg state2 = 1;

output reg [31:0] outputblock = 32'b10000000000000000000000000000000;
//wire [31:0] outputblockwire = 

integer j;
integer i;

wire [1:0] processor_out;
wire [31:0] inst;
reg [14:0] aaa = 15'b111010000100000;
reg zero_1 = 0; 
assign inst = {aaa,zero_1,current_block_data[15:0]};

processor2 p8(VGA_CLK_n,~resetn,inst,,current_block_data[12:11],current_block_data[12:11],processor_out);

//state sifenping
always@(posedge clk)
begin
 if(!reset)
 begin
 state1<=1;
 state2<=0;
 state<=0;
 current_block_data[7:4]<=14;
 current_block_data[3:0] <=5;
 pause<=0;
 end
 else
 begin
 if(pause == 1)
 begin
	
 end
 else if(pause == 0)
 begin
	if(state==0)
	begin//new block
		if(state1==0||state2==1)
		begin
		if(state1==0&&current_block_data[7:4] == 14)
			pause<=1;
		else
		begin
			current_block_data<=random_generate;
			temp_block_data<=random_generate;    //state 1 zhigaile meijiwei
			next_block_data<=random_generate;
			outputblock<=random_generate;
			state1<=1;
			state2<=0;
		end
		end
		else if(state1==1)
		begin
		
			temp_block_data<=current_block_data;
			next_block_data<=current_block_data;
			outputblock<=current_block_data;
		end
	end
	
	else if(state == 1||state == 3||state == 5||state == 7)
	begin
			temp_block_data<=current_block_data;
			if(control == 0)
			begin
				current_block_data[3:0] <= current_block_data[3:0] - 1;  //may be overflow
				next_block_data[3:0] <= current_block_data[3:0] - 1;
			end			
			else if(control == 1)
			begin
				current_block_data[3:0] <= current_block_data[3:0] + 1;
				next_block_data[3:0] <= current_block_data[3:0] + 1;
			end
			else if(control == 2)
			begin
				current_block_data[12:11]<= current_block_data[12:11] + 1;
				//next_block_data[12:11]<= current_block_data[12:11] + 1;
				next_block_data[12:11]<= processor_out;
			end
			else if(control == 3)
			begin
				current_block_data<=current_block_data;
				next_block_data<=next_block_data;
			end
			if(state == 7)
				current_block_data[7:4] <= current_block_data[7:4] - 1;
			if(state!=1)
				outputblock<=next_block_data;			
	end

	
	else if(state == 2||state == 4||state == 6||state == 8)
	begin
	if(next_block_data[10:8] == 0)
		begin
		//direction 0 2
		if((next_block_data[12:11]%2) == 0)
			begin    
				for(j = -1; j < 3; j = j + 1)
				begin//if collide?
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4])>=15||
						line[10*next_block_data[7:4]+next_block_data[3:0]+j]==1)
					begin//collide
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end//not collide	
			end
		
		else if((next_block_data[12:11]%2) == 1)
		begin    
					for(j = -2; j < 2; j = j + 1)
					begin//if collide? or boundry
						if(line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
							(next_block_data[7:4]+j)>=15||(next_block_data[3:0])>=10)
						begin//collide
							next_block_data<=temp_block_data;							
							current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
							current_block_data[3:0]<=temp_block_data[3:0];
						end
					end//not collide
		end
	end
	else if(next_block_data[10:8] == 1)
		begin
			if((next_block_data[12:11]%2) == 0||(next_block_data[12:11]%2) == 1)
			begin
			for(j = 0; j < 2; j = j + 1)
			begin
				if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]-j)>=15||
					line[10*(next_block_data[7:4]-1)+next_block_data[3:0]+j]==1||
					line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1)
				begin
					next_block_data<=temp_block_data;							
					current_block_data[31:8]<=temp_block_data[31:8];
					if(state==8)
						current_block_data[7:4]<=temp_block_data[7:4] - 1;
					else if(state!=8)
						current_block_data[7:4]<=temp_block_data[7:4];
					current_block_data[3:0]<=temp_block_data[3:0];
				end
			end
			end
		end
	else if(next_block_data[10:8] == 2)
		begin
			if(next_block_data[12:11] == 0)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0])>=10||(next_block_data[7:4]-j)>=15||(next_block_data[3:0]+1)>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]+1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
			end
			else if(next_block_data[12:11]== 1)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]-1)>=15||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
			else if(next_block_data[12:11]== 2)
			begin
						for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]-1)>=10||(next_block_data[7:4]-j)>=15||(next_block_data[3:0])>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4]+1)+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
			else if(next_block_data[12:11]== 3)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4])>=15||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]+1)+next_block_data[3:0]+1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
		end
		
		
	else if(next_block_data[10:8] == 3)
		begin
			if(next_block_data[12:11] == 0)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0])>=10||(next_block_data[7:4]-j)>=15||(next_block_data[3:0]-1)>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
			end
			else if(next_block_data[12:11]== 1)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4])>=15||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]+1)+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
			else if(next_block_data[12:11]== 2)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+1)>=10||(next_block_data[7:4]-j)>=15||(next_block_data[3:0])>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4]+1)+next_block_data[3:0]+1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
			else if(next_block_data[12:11]== 3)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]-1)>=15||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]+1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
		end
	
	
	else if(next_block_data[10:8] == 4)
		begin
			if((next_block_data[12:11]%2) == 0)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]+j)>=15||(next_block_data[3:0]+1)>=10||
						line[10*(next_block_data[7:4])+next_block_data[3:0]-j]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]+j]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
			end
			else if((next_block_data[12:11]%2)== 1)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]+j)>=15||(next_block_data[3:0])>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4]-j)+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end				
			end
			
		end
	
	
		else if(next_block_data[10:8] == 5)
		begin
			if((next_block_data[12:11]%2) == 0)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]+j)>=15||(next_block_data[3:0]+1)>=10||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]-j]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
			end
			else if((next_block_data[12:11]%2)== 1)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]+j)>=15||(next_block_data[3:0])>=10||
						line[10*(next_block_data[7:4]-j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end				
			end
			
		end

		else if(next_block_data[10:8] == 6)
		begin
			if(next_block_data[12:11] == 0)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4])>=15||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]+1)+next_block_data[3:0]]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
			end
			else if(next_block_data[12:11]== 1)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+1)>=10||(next_block_data[7:4]+j)>=15||(next_block_data[3:0])>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
			else if(next_block_data[12:11]== 2)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0]+j)>=10||(next_block_data[7:4]-1)>=15||
						line[10*(next_block_data[7:4])+next_block_data[3:0]+j]==1||
						line[10*(next_block_data[7:4]-1)+next_block_data[3:0]]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
			else if(next_block_data[12:11]== 3)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((next_block_data[3:0])>=10||(next_block_data[7:4]+j)>=15||(next_block_data[3:0]-1)>=10||
						line[10*(next_block_data[7:4]+j)+next_block_data[3:0]]==1||
						line[10*(next_block_data[7:4])+next_block_data[3:0]-1]==1)
					begin
						next_block_data<=temp_block_data;							
						current_block_data[31:8]<=temp_block_data[31:8];
						if(state==8)
							current_block_data[7:4]<=temp_block_data[7:4] - 1;
						else if(state!=8)
							current_block_data[7:4]<=temp_block_data[7:4];
						current_block_data[3:0]<=temp_block_data[3:0];
					end
				end
				
			end
		end
	
	
end
	
	
	
	else if(state == 9)
	begin
		if(current_block_data[10:8] == 0)
		begin
		//direction 0 2
		if((current_block_data[12:11]%2) == 0)
			begin   
					for(j = -1; j < 3; j = j + 1)
					begin//if collide?
						if(/*(current_block_data[3:0]+j)>=10||*/current_block_data[7:4]>=15||
							line[10*current_block_data[7:4]+current_block_data[3:0]+j]==1)
						begin//collide
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
						end
					end
			end//not collide
		else
			begin
				//begin    
					for(j = -2; j < 2; j = j + 1)
					begin//if collide? or boundry
						if(line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
							(current_block_data[7:4]+j)>=15/*||current_block_data[3:0]>=10*/)
						begin//collide
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
						end
					end//not collide
			end
		end
		else if(current_block_data[10:8] == 1)
		begin
			if((current_block_data[12:11]%2) == 0||(current_block_data[12:11]%2) == 1)
			begin
				for(j = 0; j < 2; j = j + 1)
					begin//if collide?
						if((current_block_data[7:4]-j)>=15||
					line[10*(current_block_data[7:4]-1)+current_block_data[3:0]+j]==1||
					line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1)
						begin//collide
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
						end
					end
			end
			
		end
		
		else if(current_block_data[10:8] == 2)
		begin
			if(current_block_data[12:11] == 0)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4]-j)>=15||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]+1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
					end
				end
			end
			else if(current_block_data[12:11]== 1)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4]-1)>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]-1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
					end
				end
				
			end
			else if(current_block_data[12:11]== 2)
			begin
						for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4]-j)>=15||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4]+1)+current_block_data[3:0]-1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
					end
				end
				
			end
			else if(current_block_data[12:11]== 3)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4])>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]+1)+current_block_data[3:0]+1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
							//break;
					end
				end
				
			end
		end
		
		else if(current_block_data[10:8] == 3)
		begin
			if(current_block_data[12:11] == 0)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4]-j)>=15||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]-1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
			end
			else if(current_block_data[12:11]== 1)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4])>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]+1)+current_block_data[3:0]-1]==1)
					begin
						current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
				
			end
			else if(current_block_data[12:11]== 2)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4]-j)>=15||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4]+1)+current_block_data[3:0]+1]==1)
					begin
						current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
				
			end
			else if(current_block_data[12:11]== 3)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[7:4]-1)>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]+1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
				
			end
		end
		
		
		else if(current_block_data[10:8] == 4)
		begin
			if((current_block_data[12:11]%2) == 0)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((current_block_data[7:4]+j)>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]-j]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]+j]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
			end
			else if((current_block_data[12:11]%2)== 1)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((current_block_data[7:4]+j)>=15||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4]-j)+current_block_data[3:0]-1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end				
			end
			
		end
		
		
		else if(current_block_data[10:8] == 5)
		begin
			if((current_block_data[12:11]%2) == 0)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((current_block_data[7:4]+j)>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]-j]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
			end
			else if((current_block_data[12:11]%2)== 1)
			begin
				for(j=-1; j<1; j = j+1)
				begin
					if((current_block_data[7:4]+j)>=15||
						line[10*(current_block_data[7:4]-j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]-1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end				
			end
			
		end
		
		else if(current_block_data[10:8] == 6)
		begin
			if(current_block_data[12:11] == 0)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[3:0]+j)>=10||(current_block_data[7:4])>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]+1)+current_block_data[3:0]]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
			end
			else if(current_block_data[12:11]== 1)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[3:0]+1)>=10||(current_block_data[7:4]+j)>=15||(current_block_data[3:0])>=10||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
				
			end
			else if(current_block_data[12:11]== 2)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[3:0]+j)>=10||(current_block_data[7:4]-1)>=15||
						line[10*(current_block_data[7:4])+current_block_data[3:0]+j]==1||
						line[10*(current_block_data[7:4]-1)+current_block_data[3:0]]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
				
			end
			else if(current_block_data[12:11]== 3)
			begin
				for(j=-1; j<2; j = j+1)
				begin
					if((current_block_data[3:0])>=10||(current_block_data[7:4]+j)>=15||(current_block_data[3:0]-1)>=10||
						line[10*(current_block_data[7:4]+j)+current_block_data[3:0]]==1||
						line[10*(current_block_data[7:4])+current_block_data[3:0]-1]==1)
					begin
							current_block_data<=next_block_data;
							state1<=0;
							state2<=0;
							outputblock<=next_block_data;
					end
				end
				
			end
		end
		
		
	end
	
	else
	begin
		
	end
	if(state==9)
		state<=0;
	else
		state<=state+1;
 end
 end
 
end




endmodule

//endregion



//方块下落加速
module fd_4(clk_50m,clk_4,score);
  input clk_50m;
  input [10:0] score;
  output clk_4;
  reg clk_4;
  reg [31:0]temp = 0;
  
  wire [31:0] speed;
  
  assign speed = (score>=7)?600000:((score>=3)?900000:1250000);
  
  always @(posedge clk_50m)
  begin
   temp=temp+1;
   if(temp==speed)
    begin
     clk_4=1;
     temp=0;
    end
   else
    begin
     clk_4=0;
    end  
  end
endmodule


//用来生成随机数用的clk
module fd_10(clk_50m,clk_4);
  input clk_50m;
  output clk_4;
  reg clk_4;
  reg [31:0]temp;
  always @(posedge clk_50m)
  begin
   temp=temp+1;
   if(temp==125000)
    begin
     clk_4=1;
     temp=0;
    end
   else
    begin
     clk_4=0;
    end  
  end
endmodule


//用来生成随机数, 根据时间生成随机数
module randomGenerate(clk_10,random_generate);
	input clk_10;
	output [31:0] random_generate;
	
	reg [2:0] type=0;
	reg [2:0] color=1;
	reg [15:0] zero = 0;
	reg [1:0] zero_2 = 0;
	reg [7:0] position = 8'b11100101;
	always@(posedge clk_10)
	begin
	if(type==6)
		type<=0;
	else
		type<=type+1;
		color<=color+1;
	end 
	
	assign random_generate = {zero,color,zero_2,type,position};	
		
		
		
endmodule