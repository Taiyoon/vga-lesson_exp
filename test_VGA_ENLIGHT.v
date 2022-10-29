`timescale 10ps/1ps
`include   "VGA.v"

// 测试例程只给一个时钟信号能不能跑起来

module bench;
    reg clk, reset, keya;
    wire p1, p2, p3, p4, p5;
    VGA VGA_ins(.CLK(clk),.KEYA(keya),.RESET(reset),.VGA_HS(p1),.VGA_VS(p2),.VGA_R(p3),.VGA_G(p4),.VGA_B(p5));
    initial begin
        fork            
            keya = 1;
            reset = 0;
            clk = 0;
        join

        forever #1 begin
             clk = ~clk;
        end
    end
    initial begin
        #10 reset = 1;
        #10 keya = 1;
        #10 keya = 0;
    end
endmodule