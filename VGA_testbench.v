`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:03:34 08/06/2013 
// Design Name: 
// Module Name:    VGA 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// VGA controller for 1920*1080@60Hz test

/*  1920*1080@60Hz VGA spec
 *  Pixel Clock        148.5 MHz
 *  +-------------+------+-------------+------+------------+---------------+
 *  |    NAME     | DATA | FRONT_PORCH | SYNC | BACK_PORCH | SYNC Polarity |
 *  +-------------+------+-------------+------+------------+---------------+
 *  | Hor_timings | 1920 |     88      |  44  |     148    |      pos      |
 *  | Ver_timings | 1080 |      4      |   5  |      36    |      pos      |
 *  +-------------+------+-------------+------+------------+---------------+
 */
module test;
  reg clk, reset, keya;
  initial begin
    clk = 0;
    forever #30 clk = ~clk;
  end
  initial begin
    reset = 0;
    keya  = 1;
    #1000;
    reset = 1;
    keya  = 0;
  end
  VGA VGA_a(.F50M_CLK(clk), .KEYA(keya), .RESET(reset), .VGA_HS(), .VGA_VS(), .VGA_R(), .VGA_G(), .VGA_B());
endmodule

module VGA(F50M_CLK,KEYA,RESET,VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B
    );
input F50M_CLK,KEYA,RESET;       // f(CLK) = 148.5Mhz
output VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B;

//  reg HS1,VS1;
 // wire FCLK,CCLK;
  wire CLK;
  wire keyflag;

  reg [1:0] MMD;//--对按键次数进行计录

  // parameter  CC_DATA        = 12'd1920;
  parameter  CC_FRONT_PORCH = 12'd2008;
  parameter  CC_SYNC        = 12'd2052; 
  parameter  CC_BACK_PORCH  = 12'd2199;

  parameter  LL_FRONT_PORCH = 11'd1084;
  parameter  LL_SYNC        = 11'd1089;
  parameter  LL_BACK_PORCH  = 11'd1124;

  reg [11:0] CC;//--用来产生行频的计数器
  reg [10:0] LL;//--用来产生场频的计数器

  reg [3:1] GRBX;//--第一种图象的数据
  reg [3:1] GRBY;//--第二种图象的数据
  reg [3:1] GRBP;//--第三种图象的数据
  wire [3:1] GRB;//--R,G,B数据

  initial begin 
    CC = {$random};
    LL = {$random};
    GRBX = {$random};
    GRBY = {$random};
    GRBP = {$random};
    MMD = {$random};
  end
key5 key5_a(
            .CLK(CLK),
				.RESET(RESET),
				.din(KEYA),
				.dout(keyflag)
           );
assign CLK = F50M_CLK;
// testpll  pll_a(
//             .areset(RESET),
//             .inclk0(F50M_CLK),
//             .c0(CLK),
//             .locked()
// );


assign  GRB[2]=(GRBP[2] ^ KEYA);// && HS1 && VS1;
assign  GRB[3]=(GRBP[3] ^ KEYA);// && HS1 && VS1;
assign  GRB[1]=(GRBP[1] ^ KEYA);// && HS1 && VS1;

  
 //--记录按键的次数  
always @(posedge keyflag)
begin
       if( MMD==2'b10) 
         begin
		     MMD<=0;
			end
       else MMD<=MMD+1;
end  

 //--根据按键次数来选择要显示的图象（竖条/横线/方块）
always @(CLK)
begin
      if (MMD==0)  GRBP<=GRBX;
      else if (MMD==2'b01)  GRBP<=GRBY;
      else if (MMD==2'b10)  GRBP<=GRBX^GRBY;
      else GRBP<=0;
end

always @(posedge CLK)
  begin
    if(CC == CC_BACK_PORCH) 
    begin
      CC <= 0;
      if (LL == LL_BACK_PORCH) LL <= 0;
      else LL <= LL+1;
    end
    else CC <= CC+1;
  end

// //--生产一个基本时钟FCLK（50*1/50M=1us），用来产生行频和场频
// always @(posedge CLK)
//  begin
//      if(FS==50)  FS<=0;
//      else FS<=FS+1;      
//  end


// assign FCLK=FS[5];

// //--产生行频时钟，CCLK=FCLK*29=29us,f=34.482KHZ
// always @(posedge FCLK)
// begin
//         if(CC==29)  CC<=0;
//         else CC<=CC+1;
// end


// assign CCLK=CC[4];

// //--产生场频时钟,480线
// always @(posedge CCLK)
//  begin
//        if (LL==481)  LL<=0;
//          else LL<=LL+1;
//  end

// //--通过行频时钟计数器CC和场频时钟计数器产生HS和VS时序
// always @(CC or LL)
// begin
//   if (CC>=CC_DATA)  HS1<=1;
//       else HS1<=0;
//   if (LL>479)  VS1<=0;
//       else VS1<=1;
// end

//--构造3种图象
always @(CC or LL)
 begin
	if (CC<240)  GRBX<=111;
		else if (CC<480)   GRBX<=110;
		else if (CC<720)   GRBX<=101;
		else if (CC< 960)  GRBX<=100;
		else if (CC<1200)   GRBX<=011;
		else if (CC<1440)   GRBX<=010;
		else if (CC<1680)   GRBX<=001;
		else GRBX<=0 ; 

	
    
	
	
	if (LL<135)   GRBY<=111;
		 else if (LL<270)  GRBY<=110;
		 else if (LL<405)  GRBY<=101;
		 else if (LL<540)  GRBY<=100;
		 else if (LL<675)  GRBY<=011;
		 else if (LL<810)  GRBY<=010;
		 else if (LL<945)  GRBY<=001;
		 else GRBY<=0; 

	
   end
   
assign  VGA_HS=CC >= CC_FRONT_PORCH && CC < CC_SYNC;
assign	VGA_VS=LL >= LL_FRONT_PORCH && LL < LL_SYNC;
assign	VGA_R=GRB[2] && ~VGA_HS && ~VGA_VS;
assign	VGA_G=GRB[3] && ~VGA_HS && ~VGA_VS;
assign	VGA_B=GRB[1] && ~VGA_HS && ~VGA_VS;

endmodule
