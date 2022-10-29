// `timescale 1ns / 1ps
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
module VGA(CLK,KEYA,RESET,VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B
    );
input CLK,KEYA,RESET;
output VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B;

 reg HS1,VS1;
 wire FCLK,CCLK;
  wire keyflag;
  reg [1:0] MMD;//--对按键次数进行计录
  reg [5:0] FS;//--基本时钟计数器
  reg [4:0] CC;//--用来产生行频的计数器
  reg [8:0] LL;//--用来产生场频的计数器
  reg [3:1] GRBX;//--第一种图象的数据
  reg [3:1] GRBY;//--第二种图象的数据
  reg [3:1] GRBP;//--第三种图象的数据
  wire [3:1] GRB;//--R,G,B数据

key5 key5_a(
            .CLK(CLK),
				.RESET(RESET),
				.din(KEYA),
				.dout(keyflag)
           );

initial fork  // 用于modelsim上仿真，要求寄存器里有个初值
  MMD = 10;
  FS = 000000;
  CC = 00000;
  LL = 000000000;
  GRBX = 000;
  GRBY = 000;
  GRBP = 000;
join
assign  GRB[2]=(GRBP[2] ^ KEYA) && HS1 && VS1;
assign  GRB[3]=(GRBP[3] ^ KEYA) && HS1 && VS1;
assign  GRB[1]=(GRBP[1] ^ KEYA) && HS1 && VS1;

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
always @(MMD)
begin
      if (MMD==0)  GRBP<=GRBX;
      else if (MMD==2'b01)  GRBP<=GRBY;
      else if (MMD==2'b10)  GRBP<=GRBX^GRBY;
      else GRBP<=0;
end

//--生产一个基本时钟FCLK（50*1/50M=1us），用来产生行频和场频
always @(posedge CLK)
 begin
     if(FS==50)  FS<=0;
     else FS<=FS+1;      
 end


assign FCLK=FS[5];

//--产生行频时钟，CCLK=FCLK*29=29us,f=34.482KHZ
always @(posedge FCLK)
begin
        if(CC==29)  CC<=0;
        else CC<=CC+1;
end


assign CCLK=CC[4];

//--产生场频时钟,480线
always @(posedge CCLK)
 begin
       if (LL==481)  LL<=0;
         else LL<=LL+1;
 end

//--通过行频时钟计数器CC和场频时钟计数器产生HS和VS时序
always @(CC or LL)
begin
  if (CC>23)  HS1<=0;
      else HS1<=1;
  if (LL>479)  VS1<=0;
      else VS1<=1;
end

//--构造3种图象
always @(CC or LL)
 begin
	if (CC<3)  GRBX<=111;
		else if (CC<6)   GRBX<=110;
		else if (CC<9)   GRBX<=101;
		else if (CC<12)  GRBX<=100;
		else if (CC<15)   GRBX<=011;
		else if (CC<18)   GRBX<=010;
		else if (CC<21)   GRBX<=001;
		else GRBX<=0 ; 

	
    
	
	
	if (LL<60)   GRBY<=111;
		 else if (LL<120)  GRBY<=110;
		 else if (LL<180)  GRBY<=101;
		 else if (LL<240)  GRBY<=100;
		 else if (LL<300)  GRBY<=011;
		 else if (LL<360)  GRBY<=010;
		 else if (LL<420)  GRBY<=001;
		 else GRBY<=0; 

	
   end
   
assign   VGA_HS=HS1;
assign	VGA_VS=VS1;
assign	VGA_R=GRB[2];
assign	VGA_G=GRB[3];
assign	VGA_B=GRB[1];

endmodule
