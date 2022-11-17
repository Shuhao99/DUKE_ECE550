module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 right, 
							 left, 
							 up, 
							 down
							 );


							 

input iRST_n;
input iVGA_CLK;
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

input right, left, up, down;

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
	.q ( index )	//output color index
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)	//output color hex
	);	
//////
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) begin
	
	if(cur_x > x && cur_x < x + 150 && cur_y > y && cur_y < y+150) begin
		bgr_data <= 24'hff8849;
	end
	else begin
		bgr_data <= bgr_data_raw;
	end
end
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
wire [9:0] cur_x, cur_y;
convert conv(ADDR, cur_x, cur_y);

reg [9:0] x, y;
initial
begin
	x <= 10'b0;
	y <= 10'b0;
end



reg[31:0] count;
initial count = 1;



always @ (posedge iVGA_CLK) begin
	
	if(count % 32'd20000 == 0) begin
		if(right == 1'b0) begin
			y <= y + 10'd1;
		end
		else if(left == 1'b0) begin
			y <= y - 10'd1;
		end
		else if(up == 1'b0) begin
			x <= x - 10'd1;
		end
		else if(down == 1'b0) begin
			x <= x + 10'd1;
		end
	end
	count <= count + 1;
	
end




endmodule