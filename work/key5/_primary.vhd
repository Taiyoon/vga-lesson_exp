library verilog;
use verilog.vl_types.all;
entity key5 is
    generic(
        s0              : vl_logic := Hi0;
        s1              : vl_logic := Hi1
    );
    port(
        CLK             : in     vl_logic;
        RESET           : in     vl_logic;
        din             : in     vl_logic;
        dout            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of s0 : constant is 1;
    attribute mti_svvh_generic_type of s1 : constant is 1;
end key5;
