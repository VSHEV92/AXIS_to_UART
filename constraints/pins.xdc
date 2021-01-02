# clock
set_property PACKAGE_PIN N11 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# ledds
set_property PACKAGE_PIN L5 [get_ports {leds[0]}]
set_property PACKAGE_PIN L4 [get_ports {leds[1]}]; 
set_property PACKAGE_PIN M4 [get_ports {leds[2]}];
set_property PACKAGE_PIN N3 [get_ports {leds[3]}];
set_property PACKAGE_PIN N2 [get_ports {leds[4]}];  
set_property PACKAGE_PIN M2 [get_ports {leds[5]}]; 
set_property PACKAGE_PIN N1 [get_ports {leds[6]}];
set_property PACKAGE_PIN M1 [get_ports {leds[7]}];  
set_property IOSTANDARD LVCMOS33 [get_ports leds[*]]

# reset
set_property PACKAGE_PIN T2 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# uart rx
set_property PACKAGE_PIN M12 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

set_property PACKAGE_PIN N6 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]
