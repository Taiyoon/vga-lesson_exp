#Setup.tcl 
# Setup pin setting for EP2C5_EP2C8 main board 
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED" 
set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF 
            


#config
set_location_assignment PIN_129 -to RESET
set_location_assignment PIN_132 -to CLK

#VGA
set_location_assignment PIN_34 -to VGA_R 
set_location_assignment PIN_33 -to VGA_G
set_location_assignment PIN_32 -to VGA_B
set_location_assignment PIN_30 -to VGA_HS
set_location_assignment PIN_31 -to VGA_VS


#KEY
set_location_assignment PIN_46 -to KEYA
