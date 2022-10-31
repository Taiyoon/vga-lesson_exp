library verilog;
use verilog.vl_types.all;
entity VGA is
    generic(
        CC_FRONT_PORCH  : vl_logic_vector(0 to 11) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0, Hi0, Hi0);
        CC_SYNC         : vl_logic_vector(0 to 11) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        CC_BACK_PORCH   : vl_logic_vector(0 to 11) := (Hi1, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi1, Hi1, Hi1);
        LL_FRONT_PORCH  : vl_logic_vector(0 to 10) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0);
        LL_SYNC         : vl_logic_vector(0 to 10) := (Hi1, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        LL_BACK_PORCH   : vl_logic_vector(0 to 10) := (Hi1, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0)
    );
    port(
        F50M_CLK        : in     vl_logic;
        KEYA            : in     vl_logic;
        RESET           : in     vl_logic;
        VGA_HS          : out    vl_logic;
        VGA_VS          : out    vl_logic;
        VGA_R           : out    vl_logic;
        VGA_G           : out    vl_logic;
        VGA_B           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CC_FRONT_PORCH : constant is 1;
    attribute mti_svvh_generic_type of CC_SYNC : constant is 1;
    attribute mti_svvh_generic_type of CC_BACK_PORCH : constant is 1;
    attribute mti_svvh_generic_type of LL_FRONT_PORCH : constant is 1;
    attribute mti_svvh_generic_type of LL_SYNC : constant is 1;
    attribute mti_svvh_generic_type of LL_BACK_PORCH : constant is 1;
end VGA;
