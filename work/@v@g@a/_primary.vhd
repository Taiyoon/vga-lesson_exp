library verilog;
use verilog.vl_types.all;
entity VGA is
    port(
        CLK             : in     vl_logic;
        KEYA            : in     vl_logic;
        RESET           : in     vl_logic;
        VGA_HS          : out    vl_logic;
        VGA_VS          : out    vl_logic;
        VGA_R           : out    vl_logic;
        VGA_G           : out    vl_logic;
        VGA_B           : out    vl_logic
    );
end VGA;
