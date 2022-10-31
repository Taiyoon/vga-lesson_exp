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

module VGA(F50M_CLK,KEYA,RESET,VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B,LED
    );
input F50M_CLK,KEYA,RESET;       // f(CLK) = 148.5Mhz
output VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B,LED;
  // 根据输入的时钟信号F50MCLK，使用锁相环产生VGA时钟信号CLK
  // pll配置为三倍频，即CLK的频率为三倍F50MCLK的频率-150Mhz，约等于148.5Mhz
  wire CLK;
  pll  pll_a(
              .inclk0(F50M_CLK),
              .c0(CLK)
  );
// 原作者写的按键更改图片部分，看不懂
  wire keyflag;
  reg [1:0] MMD;
  key5 key5_a(
              .CLK(F50M_CLK),
          .RESET(RESET),
          .din(KEYA),
          .dout(keyflag)
            );
  assign  GRB[2]=(GRBP[2] ^ KEYA);// && HS1 && VS1;
  assign  GRB[3]=(GRBP[3] ^ KEYA);// && HS1 && VS1;
  assign  GRB[1]=(GRBP[1] ^ KEYA);// && HS1 && VS1;

  always @(posedge keyflag)
  begin
      if( MMD==2'b10)
      begin
        MMD<=0;
      end
      else MMD<=MMD+1;
  end

  always @(MMD)
  begin
        if (MMD==0)  GRBP<=GRBX;
        else if (MMD==2'b01)  GRBP<=GRBY;
        else if (MMD==2'b10)  GRBP<=GRBX^GRBY;
        else GRBP<=0;
  end
// 锁相环的输出接一颗LED小灯，用于判断VGA模块的时钟CLK是否正常工作
  reg [26:0] pll_test;
  always@(posedge CLK)
    pll_test <= pll_test+1;
  assign LED = pll_test[26];
// 图像显示的参数，这是本文第24行的注释中的参数
// CC是水平计数器，对应Hor_Timing
  parameter  CC_DATA        = 12'd1920;
  parameter  CC_FRONT_PORCH = 12'd2008;
  parameter  CC_SYNC        = 12'd2052;
  parameter  CC_BACK_PORCH  = 12'd2199;
// LL是垂直计数器，对应Ver_Timing
  parameter  LL_DATA        = 11'd1080;
  parameter  LL_FRONT_PORCH = 11'd1084;
  parameter  LL_SYNC        = 11'd1089;
  parameter  LL_BACK_PORCH  = 11'd1124;
// 记录像素位置的计数器
  reg [11:0] CC;
  reg [10:0] LL;

// 原作者用来产生三种图像的方法所用到的计数器，和按键一样、是玄学
  reg [3:1] GRBX;
  reg [3:1] GRBY;
  reg [3:1] GRBP;
// 原作者RGB输出的三条连线，原来的程序是要对GRB做运算的，现在没有运算只是个单纯的连线
  wire [3:1] GRB;
// VGA模块里最重要的部分，水平计数器CC和垂直计数器LL的更新
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

// 产生三种图像的方法，不懂
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

// 输出
wire blank;   // VGA控制器在计数器超出显示器范围时，blank为一，此时RGB三根引脚均为低电平
assign  blank = (CC >= CC_DATA && CC < CC_BACK_PORCH) || (LL >= LL_DATA && LL < LL_BACK_PORCH);
// 输出同步信号
// 根据计数器LL和CC产生水平信号和垂直信号，在FRONT_PORCH和SYNC之间，同步信号为高电平，其余时间为低电平
assign  VGA_HS=CC >= CC_FRONT_PORCH && CC < CC_SYNC;
assign	VGA_VS=LL >= LL_FRONT_PORCH && LL < LL_SYNC;
// 输出RGB信号
assign	VGA_R=GRB[2] && ~blank;
assign	VGA_G=GRB[3] && ~blank;
assign	VGA_B=GRB[1] && ~blank;
endmodule
